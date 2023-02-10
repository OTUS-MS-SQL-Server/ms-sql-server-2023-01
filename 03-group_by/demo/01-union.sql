USE WideWorldImporters;

-- --------------
-- UNION
-- --------------
-- Какие записи изменял последним сотрудник с ID = 1
-- (Customers для CustomerCategoryID = 7, и Suppliers)

SELECT CustomerID AS ID, CustomerName AS [Name], 'customers', 0 AS Sort
FROM Sales.Customers
WHERE LastEditedBy = 1
AND CustomerCategoryID = 7

UNION

SELECT SupplierID AS ID2, SupplierName AS [Name2], 'suppliers', 1
FROM Purchasing.Suppliers
WHERE LastEditedBy = 1

ORDER BY Sort;

-- см. слайды

-- Задачка - вывести в одном столбце
SELECT 'a' AS Col1
UNION
SELECT 'b' AS Col2
UNION
SELECT 'c' AS Col3;
GO

SELECT Col1, Col2 
FROM (VALUES('a', 2), ('b', 4), ('c', 1)) AS tbl (Col1, Col2);
GO

-- Более полезный пример (пригодиться в ДЗ)
SELECT [Year], [Month] 
FROM (VALUES
	(2015, 1),(2015, 2),(2015, 3),(2015, 4), (2015, 5), (2015, 6),
	(2015, 7),(2015, 8),(2015, 9),(2015, 10),(2015, 11),(2015, 12)
) AS cal ([Year], [Month])
GO

-- Будет ли разница в производительности между этими вариантами?

-- Что быстрее UNION или UNION ALL?
SELECT 'a'
UNION ALL
SELECT 'a';

SELECT 'a'
UNION
SELECT 'a';

-- Совместимость по типам 
-- ошибка
SELECT 'a'
UNION 
SELECT 123;
GO

SELECT 'a'
UNION 
SELECT CAST(123 AS NCHAR(3));
GO

-- --------------
-- INTERSECT
-- --------------

-- Что делает запрос?

SELECT LastEditedBy
FROM Sales.Customers

INTERSECT

SELECT LastEditedBy
FROM Sales.Orders;

-- --------------
-- EXCEPT
-- --------------

-- Найти поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
-- (в ДЗ так делать не надо, там надо только через JOIN)

-- решение: (все поставщики) минус (поставщики с заказами)

-- все поставщики
SELECT SupplierID, SupplierName 
FROM Purchasing.Suppliers

EXCEPT

-- поставщики с заказами
SELECT 
	s.SupplierID, 
	s.SupplierName
FROM Purchasing.PurchASeOrders o
JOIN Purchasing.Suppliers s ON o.SupplierID = s.SupplierID;