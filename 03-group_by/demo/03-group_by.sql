/* tsqllint-disable error non-sargable */

USE WideWorldImporters;

-- Простейший GROUP BY по одному полю
-- Исходная таблица
SELECT   
  s.SupplierID,
  s.SupplierName,
  c.SupplierCategoryID,
  c.SupplierCategoryName
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c ON c.SupplierCategoryID = s.SupplierCategoryID;

-- GROUP BY
SELECT 
  c.SupplierCategoryName [Category],
  COUNT(*) AS [Suppliers Count]
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c 
  ON c.SupplierCategoryID = s.SupplierCategoryID
GROUP BY c.SupplierCategoryName;

-- Группировка по нескольким полям, по функции, ORDER BY по агрегирующей функции
-- Сколько заказов собрал сотрудник по годам
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
GROUP BY YEAR(o.OrderDate), p.FullName
ORDER BY YEAR(o.OrderDate), p.FullName;
-- Что можно улучшить в запросе (с точки зрения текста запроса)?

-- Добавили ContactPersonID. Не работает. Почему?
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  o.ContactPersonID AS ContactPersonID, -- <===============
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
GROUP BY YEAR(o.OrderDate), p.FullName
ORDER BY OrderYear, p.FullName;

 -- HAVING
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
GROUP BY YEAR(o.OrderDate), p.FullName
HAVING COUNT(*) > 1200 -- <========
ORDER BY OrdersCount DESC;

-- HAVING vs WHERE
-- -- не работает, надо писать в HAVING

SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE COUNT(*) > 1200 -- <========
GROUP BY YEAR(o.OrderDate), p.FullName
ORDER BY OrdersCount DESC;

-- -- Но если условия можно написать в WHERE, то лучше писать их в WHERE
-- -- (фильтруем не по значению агрегатной функции, а исходные данные)
-- HAVING работает
SELECT 
  YEAR(o.OrderDate) AS OrderDate, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
GROUP BY YEAR(o.OrderDate)
HAVING YEAR(o.OrderDate) > 2014; -- <========

-- -- с WHERE план одинаковый
SELECT 
  YEAR(o.OrderDate) AS OrderDate, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
WHERE YEAR(o.OrderDate) > 2014 -- <========
GROUP BY YEAR(o.OrderDate);

-- GROUPING SETS
-- -- Что это такое - аналог с UNION
SELECT TOP 5 o.ContactPersonID AS ContactPersonID, NULL AS [OrderYear], COUNT(*) AS ContactPersonCount_OrderCountPerYear
FROM Sales.Orders o
GROUP BY o.ContactPersonID

UNION

SELECT TOP 5 NULL AS ContactPersonID, YEAR(o.OrderDate) AS [OrderYear], COUNT(*) AS OrderCountPerYear
FROM Sales.Orders o
GROUP BY YEAR(o.OrderDate);

-- -- GROUPING SETS 
SELECT TOP 10
  o.ContactPersonID,
  YEAR(o.OrderDate) AS OrderYear,
  COUNT(*) AS [Count]
FROM Sales.Orders o
GROUP BY GROUPING SETS (o.ContactPersonID, YEAR(o.OrderDate));

-- ROLLUP (промежуточные итоги)
-- -- запрос для проверки итоговых значений
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY YEAR(o.OrderDate)
ORDER BY YEAR(o.OrderDate);

-- -- ROLLUP
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY ROLLUP (YEAR(o.OrderDate), p.FullName)
ORDER BY YEAR(o.OrderDate), p.FullName;
GO

-- ROLLUP, GROUPING
SELECT 
  GROUPING(YEAR(o.OrderDate)) AS OrderYear_GROUPING,
  GROUPING(p.FullName) AS PickedBy_GROUPING,
  YEAR(o.OrderDate) AS OrderDate, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount,
  -- -------
  CASE GROUPING(YEAR(o.OrderDate)) 
    WHEN 1 THEN 'Total'
    ELSE CAST(YEAR(o.OrderDate) AS NCHAR(5))
  END AS Count_GROUPING,

  CASE GROUPING(p.FullName) 
    WHEN 1 THEN 'Total'
    ELSE p.FullName 
  END AS PickedBy_GROUPING,

  COUNT(*) AS OrdersCount
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY ROLLUP (YEAR(o.OrderDate), p.FullName)
ORDER BY YEAR(o.OrderDate), p.FullName;

-- CUBE (тот же ROLLUP, но для всех комбинаций групп)
SELECT 
  GROUPING(YEAR(o.OrderDate)) AS OrderYear_GROUPING,
  GROUPING(p.FullName) AS PickedBy_GROUPING,
  
  YEAR(o.OrderDate) AS OrderDate, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY CUBE (p.FullName, YEAR(o.OrderDate))
ORDER BY YEAR(o.OrderDate), p.FullName;

-- Функция STRING_AGG (с 2017)
-- Склеивание записей в строку
SELECT 
  c.SupplierCategoryName
FROM Purchasing.SupplierCategories c;

SELECT 
  STRING_AGG(c.SupplierCategoryName, '; ') AS Categories
FROM Purchasing.SupplierCategories c;
GO

-- Поставщики в разрезе категорий
SELECT 
  c.SupplierCategoryName AS Category,
  STRING_AGG(s.SupplierName, '; ') AS Suppliers
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c ON c.SupplierCategoryID = s.SupplierCategoryID
GROUP BY c.SupplierCategoryName;

SELECT 
  c.SupplierCategoryName,
  s.SupplierName
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c ON c.SupplierCategoryID = s.SupplierCategoryID
ORDER BY c.SupplierCategoryName, s.SupplierName;

-- Есть обратная функция STRING_SPLIT
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/string-split-transact-sql?view=sql-server-ver15

SELECT res.value
FROM STRING_SPLIT('A Datum Corporation;Contoso, Ltd.;Graphic Design Institute;Lucerne Publishing;Nod Publishers;The Phone Company', ';') res;
