-- =========================================
-- Колоночные индексы 
-- Column-store indexes
-- =========================================

USE WideWorldImporters;
GO

-- В таблице ColdRoomTemperatures много исторических данных
SELECT COUNT(*) AS ROWS_COUNT
FROM Warehouse.ColdRoomTemperatures
FOR SYSTEM_TIME ALL;

SELECT TOP 20
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
FROM Warehouse.ColdRoomTemperatures
FOR SYSTEM_TIME ALL;
GO

-- Таблицы для тестов
DROP TABLE IF EXISTS dbo.Test_Index_RowStore; -- здесь создадим обычный индекс (row store)
DROP TABLE IF EXISTS dbo.Test_Index_ColumnStore; -- здесь создадим колоночный индекс (column store)
GO

-- Создаем таблицы для тестов на основе Warehouse.ColdRoomTemperatures
SELECT 
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo 
INTO dbo.Test_Index_RowStore
FROM Warehouse.ColdRoomTemperatures_Archive;
GO

SELECT 
    ColdRoomTemperatureID,
    ColdRoomSensorNumber,
    RecordedWhen,
    Temperature,
    ValidFrom,
    ValidTo
INTO dbo.Test_Index_ColumnStore
FROM Warehouse.ColdRoomTemperatures_Archive;
GO

-- Создаем обычный (row store) индекс в Test_Index_RowStore
CREATE INDEX IX_Test_Index_RowStore_Temperature
ON dbo.Test_Index_RowStore(Temperature);
GO

-- Создаем Column Store индекс в Test_Index_ColumnStore
CREATE COLUMNSTORE INDEX IX_Test_Index_ColumnStore_Temperature
ON dbo.Test_Index_ColumnStore(Temperature);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Что быстрее, насколько (по стоимости планов)? Или разницы не будет?
SELECT AVG(Temperature) FROM dbo.Test_Index_RowStore OPTION(MAXDOP 1); 
GO

SELECT AVG(Temperature) FROM dbo.Test_Index_ColumnStore OPTION(MAXDOP 1);
GO

-- Чистим БД от экспериментов
DROP TABLE IF EXISTS dbo.Test_Index_RowStore;
DROP TABLE IF EXISTS dbo.Test_Index_ColumnStore;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
