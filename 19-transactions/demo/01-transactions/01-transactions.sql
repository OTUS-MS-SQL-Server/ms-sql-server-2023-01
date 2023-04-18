USE WideWorldImporters
GO

DROP TABLE IF EXISTS dbo.test
SET IMPLICIT_TRANSACTIONS OFF;
GO

CREATE TABLE dbo.test 
(
	id INT IDENTITY(1,1), 
	[name] VARCHAR(10), 
	amount INT
)
GO

SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;
GO

-- XACT_STATE():
-- 1  - активная транзакция
-- 0  - нет активной транзакции
-- -1 - есть активная транзакция, но произошла какая-то оошибка

-- Успешное завершение транзакции

BEGIN TRAN --  BEGIN TRANSACTION
  SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;

  INSERT INTO dbo.test (name, amount)
  VALUES ('orange', 10);

  SELECT * FROM dbo.test;

  INSERT INTO dbo.test (name, amount)
  VALUES ('apple', 10);

  SELECT * FROM dbo.test;

COMMIT -- COMMIT TRAN -- COMMIT TRANSACTION

SELECT * FROM dbo.test;

-- Откат транзакции, ROLLBACK
BEGIN TRAN 

  UPDATE dbo.test
  SET amount = 0 
  WHERE name = 'apple';

  SELECT * FROM dbo.test;

  INSERT INTO dbo.test (name, amount)
  VALUES ('banana', 99);

  SELECT * FROM dbo.test;

ROLLBACK -- ROLLBACK TRANSACTION 

SELECT * FROM dbo.test;


-- autocommit,
-- одиночные операторы автоматически начинают и фиксируют транзакцию

INSERT INTO dbo.test (name, amount)
VALUES ('banana', 123);

SELECT * FROM dbo.test;

-- неявные транзакции
-- не требуют BEGIN

SET IMPLICIT_TRANSACTIONS ON;
-- при запуске INSERT неявный BEGIN TRAN 

	SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;

	INSERT INTO dbo.test (name, amount)
	VALUES ('lemon', 111);

	SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;

	SELECT * FROM dbo.test;

ROLLBACK

-- Смотрим, что в таблице
SELECT * FROM dbo.test;

-- Выключим неявные транзакции
SET IMPLICIT_TRANSACTIONS OFF;


DROP TABLE IF EXISTS dbo.test
GO