/* tsqllint-disable error select-star */

USE WideWorldImporters;

-- Исходная таблица
SELECT *
FROM Sales.Orders;

-- Сколько всего строк
SELECT COUNT(*), COUNT(1) AS RowsCount 
FROM Sales.Orders;

-- Работа с NULL, DISTINCT
-- Исходная таблица
-- 2 438 строк
SELECT * 
FROM Purchasing.SupplierTransactions 
ORDER BY FinalizationDate;

SELECT 
    COUNT(*) TotalRows, -- Количество строк
    COUNT(t.FinalizationDate) AS FinalizationDate_Count, -- Игнорирование NULL
    COUNT(DISTINCT t.SupplierID) AS SupplierID_DistinctCount, -- Количество уникальных значений в столбце
    COUNT(ALL t.SupplierID) AS SupplierID_AllCount, -- Количество всех значений в столбце (по умолчанию ALL)
    SUM(t.TransactionAmount) AS TransactionAmount_SUM, -- Сумма всех значений
    SUM(DISTINCT t.TransactionAmount) AS TransactionAmount_SUM_DISTINCT, -- Сумма различных значений
    AVG(t.TransactionAmount) AS TransactionAmount_AVG, -- Среднее
    MIN(t.TransactionAmount) AS TransactionAmount_MIN, -- Минимум
    MAX(t.TransactionAmount)AS TransactionAmount_MAX   -- Максимум 
FROM Purchasing.SupplierTransactions t;

-- Использование функций (сколько времени формируются позиции заказа)
-- Разница PickingCompletedWhen и OrderDate в часах
SELECT 
    MIN(DATEDIFF(hour, o.OrderDate, l.PickingCompletedWhen)) AS [Min],
    AVG(DATEDIFF(hour, o.OrderDate, l.PickingCompletedWhen)) AS [Avg],    
    MAX(DATEDIFF(hour, o.OrderDate, l.PickingCompletedWhen)) AS [Max]
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
WHERE l.PickingCompletedWhen IS NOT NULL;
