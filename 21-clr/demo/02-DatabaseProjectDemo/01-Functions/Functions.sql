/* tsqllint-disable error schema-qualify */

USE WideWorldImporters;
GO

-- Детерменированные и не детерменированные
SELECT 
   dbo.SumDeterministic(1, 2), 
   dbo.SumNondeterministic(3, 4);

-- Можно создать сохраняемое вычисляемое поле
-- для детерменированной функции
CREATE TABLE Table1
(
	a INT,
	b INT,
	summa AS dbo.SumDeterministic(a, b) PERSISTED
);

-- Нельзя создать сохраняемое вычисляемое поле
-- для недетерменированной функции
CREATE TABLE Table2
(
	a INT,
	b INT,
	summa AS dbo.SumNondeterministic(a, b) PERSISTED
);

DROP TABLE Table1;

-- Функция с обращением к данным в БД
SELECT dbo.CountOrdersForCustomer(832) AS [CLR];
SELECT count(*) AS [SQL] FROM Sales.Orders
WHERE CustomerID = 832;
GO

SELECT dbo.CountOrdersForCustomer(105) AS [CLR];
SELECT count(*) AS [SQL] FROM Sales.Orders 
WHERE CustomerID = 105;
GO

-- Табличная функция
-- Разбивает строку по разделителям
SELECT item, num
FROM dbo.Split('a,ab,abc', ',');
