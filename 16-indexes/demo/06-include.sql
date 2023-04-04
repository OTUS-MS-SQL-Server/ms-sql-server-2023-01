/* tsqllint-disable error select-star */

-- =========================================
-- Покрывающие индексы
-- Covering index
-- =========================================

USE WideWorldImporters;

-----------------------------------
-- Покрывающие (INCLUDE)
-----------------------------------
SET STATISTICS IO ON;

-- Index Seek 
SELECT CustomerID 
FROM Sales.Orders
WHERE CustomerID = 803;

-- Index Seek + Key Lookup 
SELECT CustomerID, OrderDate
FROM Sales.Orders
WHERE CustomerID = 803;

-- Добавляем индекс с INCLUDE
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_CustomerID_INCL_CustomerID] 
ON [Sales].[Orders]
(
	[CustomerID] ASC
)
INCLUDE(OrderDate);
GO

-- Только INDEX SEEK 
SELECT CustomerID, OrderDate
FROM Sales.Orders
WHERE CustomerID = 803;

-- А если * ?
SELECT *
FROM Sales.Orders
WHERE CustomerID = 803;

