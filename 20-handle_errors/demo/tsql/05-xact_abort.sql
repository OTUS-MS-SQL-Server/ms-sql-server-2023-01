/*
SET XACT_ABORT ON при ошибке вся транзакция завершается и выполняется ее откат
*/
-- https://docs.microsoft.com/ru-ru/sql/t-sql/statements/set-xact-abort-transact-sql


DROP TABLE IF EXISTS #t1;  
DROP TABLE IF EXISTS #t2;  
GO

CREATE TABLE #t1 (Col INT NOT NULL PRIMARY KEY);  
CREATE TABLE #t2 (Col INT NOT NULL REFERENCES t1(a));  
GO  

INSERT INTO #t1 VALUES (1);  
INSERT INTO #t1 VALUES (3);  
INSERT INTO #t1 VALUES (4);  
INSERT INTO #t1 VALUES (6);  
GO  

-- XACT_ABORT OFF ---

SET XACT_ABORT OFF;  

GO  

SELECT Col FROM #t1;
SELECT Col FROM #t2;

BEGIN TRANSACTION;  
	INSERT INTO #t2 VALUES (1);  
	INSERT INTO #t2 VALUES (2); -- Foreign key error.  
	INSERT INTO #t2 VALUES (3);  
COMMIT TRANSACTION;  

-- Что будет в t2?
SELECT Col FROM #t2; 
GO  

-- XACT_ABORT ON ---
SET XACT_ABORT ON;  
GO  

SELECT Col FROM #t1;
SELECT Col FROM #t2;

BEGIN TRANSACTION;  
	INSERT INTO #t2 VALUES (4);  
	INSERT INTO #t2 VALUES (5); -- Foreign key error.  
	INSERT INTO #t2 VALUES (6);  
COMMIT TRANSACTION;  
GO  

-- Что будет в t2?
SELECT Col FROM #t2; 
GO  


DROP TABLE IF EXISTS #t1;
DROP TABLE IF EXISTS #t2;
GO