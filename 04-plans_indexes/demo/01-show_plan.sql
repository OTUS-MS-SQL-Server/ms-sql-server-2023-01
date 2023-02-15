/* tsqllint-disable error select-star */

USE WideWorldImporters;

-- -----------------------------------------------
-- 1) Что такое план запроса и как его смотреть
-- -----------------------------------------------

-- Действительный план в виде текста
-- Запрос выполняется и отображается его план
SET STATISTICS PROFILE ON;

SELECT TOP 10 *
FROM Sales.Orders;

SET STATISTICS PROFILE OFF;
GO

-- ------------------------------------------------

-- Действительный план в виде XML
-- Запрос выполняется и отображается его план
SET STATISTICS XML ON;

SELECT TOP 10 *
FROM Sales.Orders;

SET STATISTICS XML OFF;
GO

-- -----------------------------------------------

-- Предполагаемый (потенциальный, оценочный, estimated) план в виде текста
-- Запрос НЕ выполняется, только отображается его план

SET SHOWPLAN_TEXT ON;
GO

SELECT TOP 10 *
FROM Sales.Orders;
GO

SET SHOWPLAN_TEXT OFF;
GO

-- -----------------------------------------------

-- Предполагаемый (потенциальный, оценочный, estimated) план в виде текста
-- с дополнительной информацияей.
-- Запрос НЕ выполняется, только отображается его план

SET SHOWPLAN_ALL ON;
GO

SELECT TOP 10 *
FROM Sales.Orders;
GO

SET SHOWPLAN_ALL OFF;
GO

-- -----------------------------------------------

-- Предполагаемый (потенциальный, оценочный, estimated) план в виде XML
-- Запрос НЕ выполняется, только отображается его план
SET SHOWPLAN_XML ON;
GO

SELECT TOP 10 *
FROM Sales.Orders;
GO

SET SHOWPLAN_XML OFF;
GO

-- -----------------------------------------------

-- Просмотр планов в SSMS:
--  Предполагаемый план - Меню: Query \ Display Estimated Execution Plan
--  Действительный план - Меню: Query \ Include Actual Execution Plan
--  "Живой" план        - Меню: Query \ Include Live Query Statistics

-- Тяжелый запрос для Live Query Statistics
SELECT *
FROM [Sales].[InvoiceLines] il
INNER JOIN [Sales].[Invoices] i ON i.InvoiceID = il.InvoiceID
INNER JOIN [Sales].[OrderLines] ol ON ol.OrderID = i.OrderID
INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID;


-- Будет ли разница в следующих запросах?

SELECT so.*, li.*
FROM Sales.Orders AS so
JOIN Sales.OrderLines AS li ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2;

SELECT so.*, li.*
FROM Sales.OrderLines AS li
JOIN Sales.Orders AS so ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2;
GO

-- Стоимость запросов, операторов.

-- Сохранение планов в XML в SSMS: 
-- правой кнопкой на плане -> Save Execution Plan As...

-- Сравнение планов в SSMS: 
-- правой кнопкой на плане -> Compare Showplan
-- https://docs.microsoft.com/ru-ru/sql/relational-databases/performance/compare-execution-plans

-- SSMS: 
-- панель свойств оператора (выделить оператор в плане и нажать F4)
-- всплывающая подсказка на операторе (навести мышку над оператором)
-- XML

-- Actual vs Estimated значения в свойствах оператора
-- Для стоимости только Estimated

-- А если FORCE ORDER ?

SELECT so.*, li.*
FROM Sales.Orders AS so
JOIN Sales.OrderLines AS li ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2
OPTION (FORCE ORDER);

SELECT so.*, li.*
FROM Sales.OrderLines AS li
JOIN Sales.Orders AS so ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2
OPTION (FORCE ORDER);
GO

-- Запросы выше из статьи (перевод) "Почему для SQL Server важна статистика" 
-- https://habr.com/ru/company/otus/blog/489366/


-- Планы запросов кэшируются
-- Можно посмотреть планы для ранее выполненных запросов

SELECT p.query_plan , query.[text] AS [sql], c.* 
FROM sys.dm_exec_cached_plans c
CROSS APPLY sys.dm_exec_query_plan(c.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) query
WHERE query.[text] LIKE '%Sales.Orders%';

-- Очистка кэша
DBCC FREEPROCCACHE;