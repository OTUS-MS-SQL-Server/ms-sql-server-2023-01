USE WideWorldImporters
GO

-- Изменяем таблицы в раном порядке:
-- Меняем People, потом Orders

-- 0. Смотрим, что блокировок нет (Locks.sql)

-- SET DEADLOCK_PRIORITY LOW

-- 1. Начинаем транзакцию и выполняем SELECT
BEGIN TRAN

SELECT PersonId, FullName, PreferredName,  PhoneNumber
FROM Application.People
WHERE FullName = 'Kayla Woodcock'
AND IsEmployee = 1;

-- 2. начинаем другую транзакцию >>>>>

-- 3. UPDATE People
UPDATE Application.People
SET PreferredName = 'Kaila'
WHERE PersonID = 2;

-- Смотрим блокировки

-- 4. UPDATE Orders в другой транзакции >>>>

-- 5. UPDATE Orders

UPDATE Sales.Orders
SET SalespersonPersonID = 16
WHERE SalespersonPersonID = 2
	AND OrderId IN (73535, 73537, 73545);
 
-- 6. UPDATE People в другой транзакции >>>>

-- !!! deadlock

SELECT XACT_STATE() as XACT_STATE

ROLLBACK
