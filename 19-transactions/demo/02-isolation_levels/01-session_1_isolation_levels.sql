USE WideWorldImporters;

-- ====================================================
-- READ UNCOMMITTED
-- ====================================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRAN;

	-- Данные в начале транзакции
	SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> Запускаем что-то параллельно >>>>>
	
	-- Данные после параллельных изменений
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';

COMMIT;

-- ====================================================
-- READ COMMITTED
-- ====================================================
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SET LOCK_TIMEOUT time  -- миллисекунды, 
-- -1 - бесконечно, 
--  0 - не ждет

-- SET LOCK_TIMEOUT 10000
-- SELECT @@LOCK_TIMEOUT

BEGIN TRAN;
	-- Данные в начале транзакции
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> Запускаем что-то параллельно >>>>>
		
	-- Данные после параллельных изменений
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;


-- ====================================================
-- REPEATABLE READ
-- ====================================================
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN;

	-- Данные в начале транзакции
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> Запускаем что-то параллельно >>>>>
	
	-- Данные после параллельных изменений
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;


-- ====================================================
-- SERIALIZABLE
-- ====================================================
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRAN;

	-- Данные в начале транзакции
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> Запускаем что-то параллельно >>>>>
	
	-- Данные после параллельных изменений
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;

-- ROLLBACK;

-- ====================================================
-- READ_COMMITTED_SNAPSHOT
-- ====================================================

-- Включение READ_COMMITTED_SNAPSHOT
USE master

ALTER DATABASE WideWorldImporters 
SET READ_COMMITTED_SNAPSHOT ON;
GO

USE WideWorldImporters;

-- Проверка, что включен SNAPSHOT
SELECT 
    DB_NAME(database_id), 
    is_read_committed_snapshot_on,
    snapshot_isolation_state_desc     
FROM sys.databases
WHERE database_id = DB_ID();
GO

-- ====================================================
-- READ COMMITTED (with READ_COMMITTED_SNAPSHOT ON)
-- ====================================================
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRAN;

	-- Данные в начале транзакции
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> Запускаем что-то параллельно >>>>>
	
	-- Данные после параллельных изменений
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;

-- SNAPSHOT
-- ALTER DATABASE WideWorldImporters 
-- SET ALLOW_SNAPSHOT_ISOLATION ON;