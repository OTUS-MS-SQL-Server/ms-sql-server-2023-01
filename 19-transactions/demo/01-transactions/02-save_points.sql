-- Вложенные транзакции, SAVEPOINT
-- На самостоятельное изучение
-- https://www.mssqltips.com/sqlservertip/5538/understanding-sql-server-transaction-savepoints/

USE WideWorldImporters

DROP TABLE IF EXISTS dbo.TestTable;
CREATE TABLE dbo.TestTable
(
   ID INT NOT NULL,
   Value INT NOT NULL,
   PRIMARY KEY (ID)
)

--No savepoints
TRUNCATE TABLE TestTable

-- nothing has happened yet, so value will be 0 
SELECT @@TRANCOUNT AS '1. - @@TRANCOUNT before starting the first transaction (its value is 0)', XACT_STATE() AS [State]
 
BEGIN TRANSACTION -- trans 1
   SELECT @@TRANCOUNT AS '2. - @@TRANCOUNT after starting the first transaction (its value is incremented by 1)', XACT_STATE() AS [State]
  
   INSERT INTO TestTable(ID, Value) 
   VALUES(1,'10')
   SELECT * FROM TestTable

   BEGIN TRANSACTION t2 -- trans 2
      SELECT @@TRANCOUNT AS '3. - @@TRANCOUNT after starting the second transaction (its value again is incremented by 1)', XACT_STATE() AS [State]

      INSERT INTO TestTable(ID, Value) 
      VALUES(2,'20')
      
	  SELECT * FROM TestTable
      -- ROLLBACK TRANSACTION -- какая транзакция откатится?
      -- SELECT @@TRANCOUNT AS '4. - @@TRANCOUNT after rolling back'
  
      BEGIN TRANSACTION -- trans 3 
         SELECT @@TRANCOUNT AS '5. - @@TRANCOUNT after starting the third transaction (its value is incremented by 1)', XACT_STATE() AS [State]
 
         INSERT INTO TestTable(ID, Value) 
         VALUES(3,'30')
 
		SELECT * FROM TestTable

      ROLLBACK -- все откатится
      SELECT @@TRANCOUNT AS '6. - @@TRANCOUNT after committing the third transaction (its value is decremented by 1)', XACT_STATE() AS [State]
  
      -- only id 1 and 3 remain
      SELECT * FROM TestTable
 
   COMMIT -- trans 2
   SELECT @@TRANCOUNT AS '7. - @@TRANCOUNT after committing second transaction (its value is set to 1)'

COMMIT -- trans 1
SELECT @@TRANCOUNT AS '8. - @@TRANCOUNT after rolling back first transaction (its value is set to 0)'

-- no data remains after rollback
SELECT * FROM TestTable

-- ------------------------
-- SAVEPOINTS
-- ------------------------

TRUNCATE TABLE TestTable
SELECT * FROM TestTable

-- nothing has happened yet, so value will be 0 
SELECT @@TRANCOUNT AS '1. - @@TRANCOUNT before starting the first transaction (its value is 0)'
 
BEGIN TRANSACTION -- trans 1
   SELECT @@TRANCOUNT AS '2. - @@TRANCOUNT after starting the first transaction (its value is incremented by 1)'
  
   INSERT INTO TestTable(ID, Value) 
   VALUES(1,'10')
   
   SAVE TRANSACTION FirstInsert -- <<<<<<<<<<<<<<<

   SELECT * FROM TestTable

   BEGIN TRANSACTION -- trans 2
      SELECT @@TRANCOUNT AS '3. - @@TRANCOUNT after starting the second transaction (its value again is incremented by 1)'

      INSERT INTO TestTable(ID, Value) 
      VALUES(2,'20')
      SELECT * FROM TestTable

	  SELECT * FROM TestTable

      ROLLBACK TRANSACTION FirstInsert -- какая транзакция откатится?

      SELECT @@TRANCOUNT AS '4. - @@TRANCOUNT after rolling back to the savepoint (its value is not changed)'
      
	  SELECT * FROM TestTable

      BEGIN TRANSACTION -- trans 3 
         SELECT @@TRANCOUNT AS '5. - @@TRANCOUNT after starting the third transaction (its value is incremented by 1)'
 
         INSERT INTO TestTable(ID, Value) 
         VALUES(3,'30')
 
      COMMIT -- trans 3
      SELECT @@TRANCOUNT AS '6. - @@TRANCOUNT after committing the third transaction (its value is decremented by 1)'

      -- only id 1 and 3 remain
      SELECT * FROM TestTable
 
   COMMIT -- trans 2
   SELECT @@TRANCOUNT AS '7. - @@TRANCOUNT after committing second transaction (its value is set to 1)'

COMMIT -- trans 1
SELECT @@TRANCOUNT AS '8. - @@TRANCOUNT after rolling back first transaction (its value is set to 0)'

-- no data remains after rollback
SELECT * FROM TestTable


-- ------------------------
-- SAVEPOINTS
-- а если после коммита вложенного сделать роллбэк к сейвпоинту?
-- ------------------------

TRUNCATE TABLE TestTable
SELECT * FROM TestTable

-- nothing has happened yet, so value will be 0 
SELECT @@TRANCOUNT AS '1. - @@TRANCOUNT before starting the first transaction (its value is 0)'
 
BEGIN TRANSACTION -- trans 1
   SELECT @@TRANCOUNT AS '2. - @@TRANCOUNT after starting the first transaction (its value is incremented by 1)'
   select CURRENT_TRANSACTION_ID()

   INSERT INTO TestTable(ID, Value) 
   VALUES(1,'10')
   
   SAVE TRANSACTION FirstInsert -- <<<<<<<<<<<<<<<

   SELECT * FROM TestTable

   BEGIN TRANSACTION -- trans 2
      SELECT @@TRANCOUNT AS '3. - @@TRANCOUNT after starting the second transaction (its value again is incremented by 1)'

      INSERT INTO TestTable(ID, Value) 
      VALUES(2,'20')

      SELECT * FROM TestTable
   COMMIT 

   SELECT * FROM TestTable

   ROLLBACK TRANSACTION FirstInsert -- какая транзакция откатится?

   SELECT * FROM TestTable

COMMIT