/* tsqllint-disable error select-star */
/* tsqllint-disable error non-sargable */

USE WideWorldImporters;

-- --------------------------
-- equals
-- --------------------------
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName = 'Chocolate sharks 250g';

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemID = 225;

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemID != 225; -- StockItemID <> 225

-- --------------------------
-- LIKE
-- --------------------------
-- Строка начинается с Chocolate
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName LIKE 'Chocolate%';

-- Строка заканчивается на 250g
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%250g';
GO

-- В строке есть 'flash'
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%flash%';
GO

-- Начинается на Chocolate и заканчивается на 250g
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName LIKE 'Chocolate%250g';
GO

-- Есть 250, 251, 252, 253, 254, 255 или 256
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%25[0-6]%';
GO

-- --------------------------
-- AND, OR
-- --------------------------
-- Нужно вывести StockItems, где цена от 350 до 500 и
-- название начинается с USB или Ride.
-- Все правильно?
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    RecommendedRetailPrice BETWEEN 350 AND 500
    AND StockItemName LIKE 'USB%' 
    OR StockItemName LIKE 'Ride%';



-- Не забывайте про приоритеты
-- Используйте скобки
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    (RecommendedRetailPrice BETWEEN 350 AND 500) 
    AND (StockItemName LIKE 'USB%' 
         OR StockItemName LIKE 'Ride%');

-- --------------------------
-- Функции в WHERE
-- --------------------------
SELECT OrderID, OrderDate, year(OrderDate)
FROM Sales.Orders o
WHERE year(OrderDate) = 2013;
-- Но так лучше не писать (не может использоваться индекс).

-- Лучше через BETWEEN
SELECT OrderDate, OrderID
FROM Sales.Orders o
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31';

-- WHERE по выражению
SELECT  OrderLineID AS [Order Line ID],
        Quantity,
        UnitPrice,
        (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE (Quantity * UnitPrice) > 1000;

-- --------------------------
-- Даты
-- --------------------------

-- Назовите дату, которая указана в запросе?

SELECT *
FROM [Sales].[Orders]
WHERE OrderDate = '02.05.2016' 
ORDER BY OrderDate;





















SET DATEFORMAT mdy;
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate = '02.05.2016' -- пятое февраля
ORDER BY OrderDate;
GO


SET DATEFORMAT dmy;
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate = '02.05.2016' -- второе мая
ORDER BY OrderDate;
GO

SET DATEFORMAT mdy;
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate = '20160502' -- второе мая
ORDER BY OrderDate;
GO

-- язык по умолчанию
EXEC sp_configure 'default language';
SELECT @@language;

-- доступные языки
SELECT * FROM sys.syslanguages;

-- изменить язык для сеанса

SET LANGUAGE Russian;
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate = '02.05.2016' -- пятое февраля
ORDER BY OrderDate;

SET LANGUAGE English;
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate = '02.05.2016' -- второе мая
ORDER BY OrderDate;

-- --------------------------
-- Функции с DATE, CONVERT
-- --------------------------

-- MONTH, DAY, YEAR
SELECT DISTINCT o.OrderDate,
       MONTH(o.OrderDate) AS OrderMonth,
       DAY(o.OrderDate) AS OrderDay,
       YEAR(o.OrderDate) AS OrderYear
FROM Sales.Orders AS o;

-- DATEPART ( datepart , date )
SELECT o.OrderID,
       o.OrderDate,
       DATEPART(m, o.OrderDate) AS OrderMonth,
       DATEPART(d, o.OrderDate) AS OrderDay,
       DATEPART(yy, o.OrderDate) AS OrderYear
FROM Sales.Orders AS o;

-- Справка по DATEPART
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/datepart-transact-sql

-- -----------------------------------------------
-- DATEDIFF ( datepart , startdate , enddate )
-- -----------------------------------------------
-- Справка DATEDIFF https://docs.microsoft.com/ru-ru/sql/t-sql/functions/datediff-transact-sql
-- Справка DATEADD  https://docs.microsoft.com/ru-ru/sql/t-sql/functions/dateadd-transact-sql

-- Years
SELECT DATEDIFF (yy,'2007-12-31', '2008-01-03') AS 'YearDiff';

-- Days
SELECT DATEDIFF (dd,'2007-12-31', '2008-01-03') AS 'DayDiff';

-- Months
SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen,
       DATEDIFF(mm, o.OrderDate, o.PickingCompletedWhen) AS MonthsDiff
FROM Sales.Orders o
WHERE DATEDIFF(mm, o.OrderDate, o.PickingCompletedWhen) > 0;

-- DATEADD (datepart , number , date )
SELECT o.OrderID,
       o.OrderDate,
       DATEADD (yy, 1, o.OrderDate) AS DateAddOneYear,
       EOMONTH(o.OrderDate) AS EndOfMonth
FROM Sales.Orders o;

-- DATETIME to string, CONVERT
-- Показать заказы с 2013-01-05 по 2013-01-07 включительно.
-- Есть ошибка?
SELECT
 PickingCompletedWhen,
 CAST(PickingCompletedWhen AS DATE) CastDate,
 CONVERT(NVARCHAR(16), PickingCompletedWhen, 104) AS ConvertString,
 FORMAT(PickingCompletedWhen, 'dd.MM.yyyy') AS FORMAT_1,
 FORMAT(PickingCompletedWhen, 'dd.MM.yyyy hh:mm:ss') AS FORMAT_2,
 FORMAT(PickingCompletedWhen, 'd', 'ru') AS FORMAT_DATE_RU,
 FORMAT(PickingCompletedWhen, 't', 'ru') AS FORMAT_TIME_RU,
 *
FROM Sales.Orders o
WHERE PickingCompletedWhen BETWEEN '20130105' AND '20130107';

-- PickingCompletedWhen - datetime2

-- Справка по CONVERT
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/cast-and-convert-transact-sql

-- Справка по FORMAT
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/format-transact-sql

-- Дополнительный материал:
-- "Ошибки при работе с датой и временем в SQL Server"
-- https://habr.com/ru/company/otus/blog/487774/

-- --------------------------
-- IS NULL, IS NOT NULL
-- --------------------------

-- проверка на NULL
SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen IS NULL;

SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen IS NOT NULL;
GO

-- Конкатенация с NULL
SELECT 'abc' + NULL;

SET CONCAT_NULL_YIELDS_NULL OFF;
    SELECT 'abc' + NULL;
SET CONCAT_NULL_YIELDS_NULL ON;
-- По умолчанию CONCAT_NULL_YIELDS_NULL = ON, 
-- в будущих версиях OFF будет вызывать ошибку


-- Арифметические операции с NULL
SELECT 3 + NULL;

-- -----------------------------------
-- ISNULL(), COALESCE()
-- -----------------------------------
SELECT 
    OrderId,    
    ISNULL(PickingCompletedWhen,'1900-01-01')
FROM Sales.Orders;

-- Задача - вывести значение "Unknown", там, где NULL
-- Так будет работать?
SELECT 
    OrderId,    
    ISNULL(PickingCompletedWhen, 'Unknown') AS PickingCompletedWhen
FROM Sales.Orders;














-- вариант решения (и примеры CASE)
SELECT 
    OrderId,    
    PickingCompletedWhen,
    
    ISNULL(CONVERT(NVARCHAR(10), PickingCompletedWhen, 104), 'Unknown') AS PickingCompletedWhenDay1,

    CASE 
        WHEN PickingCompletedWhen IS NULL THEN 'Unknown'
        -- WHEN ... THEN ...
        ELSE CONVERT(NVARCHAR(10), PickingCompletedWhen, 104) 
    END PickingCompletedWhenDay2,

    CASE DATEDIFF(d, o.OrderDate, o.PickingCompletedWhen)
        WHEN 0 THEN 'today'
        WHEN 1 THEN 'one day'
        ELSE 'more then one day'
    END [Order and Picking Date Diff]
FROM Sales.Orders o
ORDER BY PickingCompletedWhen;

-- COALESCE()
DECLARE @val1 INT = NULL;
DECLARE @val2 INT = NULL;
DECLARE @val3 INT = 2;
DECLARE @val4 INT = 5;

SELECT COALESCE(@val1, @val2, @val3, @val4);
