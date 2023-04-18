USE WideWorldImporters
GO

-- Изменяем таблицы в раном порядке:
-- Меняем Orders, потом People

-- 2. Начинаем транзакцию и выполняем SELECT
BEGIN TRAN

SELECT PersonId, FullName, PreferredName,  PhoneNumber
FROM Application.People
WHERE FullName = 'Kayla Woodcock'
AND IsEmployee = 1;

-- 3. <<<<< UPDATE People в другой транзакции

-- 4. UPDATE Orders 
UPDATE Sales.Orders
SET Comments = 'Deadlock simulation orders'
WHERE SalespersonPersonID = 2
	AND OrderId IN (73535, 73537, 73545);

-- Смотрим блокировки

-- 5. <<<<< UPDATE Orders в другой транзакции

-- 6. UPDATE People 

UPDATE Application.People
SET PhoneNumber = '(495) 777-0304'
WHERE PersonID = 2;

-- !!! deadlock

SELECT * 
FROM Application.People
WHERE PersonID = 2;

SELECT *
FROM Sales.Orders
WHERE OrderId IN (73535, 73537, 73545)

SELECT XACT_STATE() as XACT_STATE

ROLLBACK