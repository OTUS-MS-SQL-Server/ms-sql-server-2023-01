/* tsqllint-disable error select-star */
USE WideWorldImporters;

-----------------------------------------
-- Исходные таблицы
-----------------------------------------
DROP TABLE IF EXISTS dbo.Suppliers;
DROP TABLE IF EXISTS dbo.SupplierTransactions;

-- Исходная таблица Suppliers
SELECT
  SupplierID,
  SupplierName
INTO dbo.Suppliers
FROM Purchasing.Suppliers
/* where - чтобы в примере было меньше строк */
WHERE SupplierName IN ('A Datum Corporation', 'Contoso, Ltd.', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY SupplierID;

-- Исходная таблица -- SupplierTransactions
SELECT
  SupplierTransactionID,
  SupplierID,
  TransactionDate,
  TransactionAmount,
  TransactionTypeID
INTO dbo.SupplierTransactions
FROM Purchasing.SupplierTransactions
WHERE SupplierID IN (1, 2, 3, 9) /* чтобы в примере было меньше строк */
ORDER BY SupplierID;

SELECT * FROM dbo.Suppliers;
SELECT * FROM dbo.SupplierTransactions;

-----------------------------------------
-- JOINS 
-----------------------------------------

-- CROSS JOIN через FROM, ANSI SQL-89
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s, dbo.SupplierTransactions t;

-- INNER JOIN через FROM и WHERE, ANSI SQL-89
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s, dbo.SupplierTransactions t
WHERE s.SupplierID = t.SupplierID -- <====== условие соединения
ORDER BY s.SupplierID, t.SupplierID;

-- CROSS JOIN, ANSI SQL-92
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
CROSS JOIN Purchasing.SupplierTransactions t
ORDER BY s.SupplierID, t.SupplierID;

-- Лучше условие соединения писать в JOIN
-- INNER JOIN, ANSI SQL-92
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s
INNER JOIN dbo.SupplierTransactions t
	  ON t.SupplierID = s.SupplierID -- <====== условие JOIN
ORDER BY s.SupplierID;

-- Все поставщики, даже если у них нет транзакций
-- LEFT JOIN 
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s
LEFT OUTER JOIN dbo.SupplierTransactions t
	ON t.SupplierID = s.SupplierID  -- <====== условие JOIN
ORDER BY s.SupplierID;

-- RIGHT JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.SupplierTransactions t
RIGHT JOIN  dbo.Suppliers s
	ON s.SupplierID = t.SupplierID -- <====== условие JOIN
ORDER BY s.SupplierID;

-- Лучше используйте LEFT JOIN вместо RIGHT JOIN - читается проще

-- Найти поставщиков (Supplier) без транзакций (transactions)
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t
	ON t.SupplierID = s.SupplierID -- <====== условие JOIN
WHERE t.SupplierTransactionID IS NULL
ORDER BY s.SupplierID;

---------------------------------------
-- Порядок JOIN
---------------------------------------
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
	l.OrderLineID
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID;

-- Поменяем местами Orders и Customers
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
	l.OrderLineID
FROM Sales.OrderLines l
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.Orders o ON o.OrderID = l.OrderID;

-- Поменяем таблицы в FROM и JOIN
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID;

-- Теперь порядок JOIN не влияет
-- Первоначальный вариант:
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID;

-- Будет ли разница в производительности этих запросов?
-- Смотрим планы запросов

-- Те же запросы с FORCE JOIN - фиксируем порядок выполнения JOIN
-- (смотрим планы)
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
OPTION (FORCE ORDER);

SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID
OPTION (FORCE ORDER);

SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
OPTION (FORCE ORDER);
GO

--------------------------------
-- "Съедание данных" LEFT JOIN
--------------------------------
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount,
  t.TransactionTypeID
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t ON t.SupplierID = s.SupplierID
ORDER BY s.SupplierID;

-- Добавим TransactionTypes через INNER JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount,
  t.TransactionTypeID,
  tt.TransactionTypeName
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t ON t.SupplierID = s.SupplierID
INNER JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
ORDER BY s.SupplierID;

-- Как сделать так, чтобы данные не пропали?











SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount,
  t.TransactionTypeID,
  tt.TransactionTypeName
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t ON t.SupplierID = s.SupplierID
LEFT JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
ORDER BY s.SupplierID;


-- В общем случае, что быстрее LEFT JOIN или INNER JOIN?
