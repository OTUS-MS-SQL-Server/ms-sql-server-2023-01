/*
SET XACT_ABORT ON при ошибке вся транзакция завершается и выполняется ее откат
*/
-- https://docs.microsoft.com/ru-ru/sql/t-sql/statements/set-xact-abort-transact-sql

use WideWorldImporters

DROP TABLE IF EXISTS t1;  
DROP TABLE IF EXISTS t2;  
GO

CREATE TABLE t1 (a INT NOT NULL PRIMARY KEY);  
CREATE TABLE t2 (a INT NOT NULL REFERENCES t1(a));  
GO  

INSERT INTO t1 VALUES (1);  
INSERT INTO t1 VALUES (3);  
INSERT INTO t1 VALUES (4);  
INSERT INTO t1 VALUES (6);  
GO  

-- XACT_ABORT OFF ---

SET XACT_ABORT OFF;  

GO  

SELECT * FROM t1;
SELECT * FROM t2;

BEGIN TRANSACTION;  
	INSERT INTO t2 VALUES (1);  
	INSERT INTO t2 VALUES (2); -- Foreign key error.  
	INSERT INTO t2 VALUES (3);  
COMMIT TRANSACTION;  

-- Что будет в t2?
SELECT * FROM t2; 
GO  

-- XACT_ABORT ON ---
SET XACT_ABORT ON;  
GO  

SELECT * FROM t1;
SELECT * FROM t2;

BEGIN TRANSACTION;  
	INSERT INTO t2 VALUES (4);  
	INSERT INTO t2 VALUES (5); -- Foreign key error.  
	INSERT INTO t2 VALUES (6);  
COMMIT TRANSACTION;  
GO  

-- Что будет в t2?
SELECT * FROM t2; 
GO  

-- По умолчанию OFF
-- Но можно изменить через user options -- 16384
-- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-user-options-server-configuration-option

EXEC sys.sp_configure N'user options', N'16384'
GO
RECONFIGURE 
GO

-- или в SSMS
-- Instace properties -> Connections -> Default connection options