-- =========================================
-- Пространственные индексы
-- Spatial indexes
-- =========================================

USE WideWorldImporters;
GO

-- Примеры данных
DECLARE @line GEOMETRY = 'LINESTRING(1 1,2 3,4 8, -6 3)'; 
SELECT @line;
GO

DECLARE @curve GEOMETRY = 'CIRCULARSTRING(1 1, 2 0, 2 0, 1 1, 0 1)';
SELECT @curve;
GO

DECLARE @polygon GEOMETRY = 'CURVEPOLYGON(CIRCULARSTRING(1 3, 3 5, 4 7, 7 3, 1 3))';
SELECT @polygon;
GO


-- Отключаем ROW LEVEL SECURITY (безопасность на уровне строк)
-- сейчас она не нужна, а с ней очень большие планы запросов
DROP SECURITY POLICY IF EXISTS [Application].[FilterCustomersBySalesTerritoryRole];
GO

-- Почистим от предыдущих экспериментов
DROP INDEX IF EXISTS [SI_Customers_DeliveryLocation] 
ON Sales.Customers;
GO

-- Indexes
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Задача: найти все адреса доставки в штате Alabama

SELECT 
    StateProvinceID,
    StateProvinceCode,
    StateProvinceName,
    SalesTerritory,
    Border
FROM Application.StateProvinces;

SELECT
	cust.CustomerName AS CustomerName,
	cust.DeliveryLocation AS DeliveryLocation,
	cust.DeliveryLocation.ToString() AS DeliveryLocation_ToString
FROM Sales.Customers cust;

-- Посмотрим как выглядит граница штата
DECLARE @StateBorder GEOGRAPHY = (
    SELECT Border
    FROM Application.StateProvinces
    WHERE StateProvinceName = 'Alabama');
SELECT @StateBorder;
GO

-- Ищем адреса в штате Alabama
DECLARE @StateBorder GEOGRAPHY = (
    SELECT Border
    FROM Application.StateProvinces
    WHERE StateProvinceName = 'Alabama');

SELECT
	cust.CustomerName AS CustomerName,
	cust.DeliveryLocation AS DeliveryLocation,
	cust.DeliveryLocation.ToString() AS DeliveryLocation_ToString
FROM Sales.Customers cust
WHERE cust.DeliveryLocation.STWithin(@StateBorder) = 1;



-- Создаем Spatial Index (пространственный индекс)
CREATE SPATIAL INDEX [SI_Customers_DeliveryLocation]
ON Sales.Customers (DeliveryLocation);
GO

-- Еще раз все адреса в штате Alabama (с индексом)
DECLARE @StateBorder GEOGRAPHY = (
    SELECT Border
    FROM Application.StateProvinces
    WHERE StateProvinceName = 'Alabama');

SELECT
	cust.CustomerName AS CustomerName,
	cust.DeliveryLocation AS DeliveryLocation,
	cust.DeliveryLocation.ToString() AS DeliveryLocation_ToString
FROM Sales.Customers cust
WHERE cust.DeliveryLocation.STWithin(@StateBorder) = 1;
