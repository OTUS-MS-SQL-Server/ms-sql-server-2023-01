-- https://www.sqlskills.com/blogs/paul/can-guid-cluster-keys-cause-non-clustered-index-fragmentation/

USE [master];
GO

ALTER DATABASE GuidsDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE IF EXISTS GuidsDemo;
GO

CREATE DATABASE GuidsDemo;
GO

USE GuidsDemo;
GO

-- -------------------------------------------
SELECT NEWID();
GO

SELECT NEWSEQUENTIALID(); /* Работать не будет - только в DEFAULT */
GO

-- Таблица с GUID 
CREATE TABLE dbo.Table_NEWID (
   c1 UNIQUEIDENTIFIER DEFAULT NEWID (),
   c2 DATETIME DEFAULT GETDATE (),
   c3 CHAR (400) DEFAULT 'a');
CREATE CLUSTERED INDEX CI_Table_NEWID_c1 ON Table_NEWID (c1);
CREATE NONCLUSTERED INDEX IX_Table_NEWID_c2 ON Table_NEWID (c2);
GO


-- Таблица с NEWSEQUENTIALID 
CREATE TABLE dbo.Table_NEWSEQUENTIALID (
   c1 UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID (),
   c2 DATETIME DEFAULT GETDATE (),
   c3 CHAR (400) DEFAULT 'a');
CREATE CLUSTERED INDEX CI_Table_NEWSEQUENTIALID_c1 ON Table_NEWSEQUENTIALID (c1);
CREATE NONCLUSTERED INDEX IX_Table_NEWSEQUENTIALID_c2 ON Table_NEWSEQUENTIALID (c2);
GO

-- Вставляем данные
DECLARE @a INT;
SELECT @a = 1;
WHILE (@a < 10000)
BEGIN
   INSERT INTO dbo.Table_NEWID DEFAULT VALUES;
   INSERT INTO dbo.Table_NEWSEQUENTIALID DEFAULT VALUES;
   SELECT @a = @a + 1;
END;
GO

SELECT TOP 10 c1, c2, c3 FROM dbo.Table_NEWID;
SELECT TOP 10 c1, c2, c3 FROM dbo.Table_NEWSEQUENTIALID;

-- Смотрим общее количество Page Split в разрезе таблиц/индексов и фрагментацию
SELECT
    [AllocUnitName] AS N'Index',
    (CASE [Context]
        WHEN N'LCX_INDEX_LEAF' THEN N'Nonclustered'
        WHEN N'LCX_CLUSTERED' THEN N'Clustered'
        ELSE N'Non-Leaf'
    END) AS [SplitType],
    COUNT (1) AS [SplitCount]
FROM
    fn_dblog (NULL, NULL)
WHERE
   [Operation] = N'LOP_DELETE_SPLIT'
	AND AllocUnitName NOT LIKE 'sys.%'
GROUP BY [AllocUnitName], [Context]
ORDER BY [AllocUnitName];

-- фрагментация
SELECT
   OBJECT_NAME (ips.[object_id]) AS 'Object Name',
   si.name AS 'Index Name',
   ROUND (ips.avg_fragmentation_in_percent, 2) AS 'Fragmentation',
   ips.page_count AS 'Pages',
   ROUND (ips.avg_page_space_used_in_percent, 2) AS 'Page Density'
FROM sys.dm_db_index_physical_stats (DB_ID ('GuidsDemo'), NULL, NULL, NULL, 'DETAILED') ips
CROSS APPLY sys.indexes si
WHERE
   si.object_id = ips.object_id
   AND si.index_id = ips.index_id
   AND ips.index_level = 0;
GO

-- Попробуем дефрагментировать
ALTER INDEX CI_Table_NEWID_c1 ON Table_NEWID REORGANIZE;
GO

ALTER INDEX IX_Table_NEWID_c2 ON Table_NEWID REORGANIZE;
GO

ALTER INDEX CI_Table_NEWSEQUENTIALID_c1 ON Table_NEWSEQUENTIALID REORGANIZE;
GO

ALTER INDEX IX_Table_NEWSEQUENTIALID_c2 ON Table_NEWSEQUENTIALID REORGANIZE;
GO

-- Смотрим фрагментацию
SELECT
   OBJECT_NAME (ips.[object_id]) AS 'Object Name',
   si.name AS 'Index Name',
   ROUND (ips.avg_fragmentation_in_percent, 2) AS 'Fragmentation',
   ips.page_count AS 'Pages',
   ROUND (ips.avg_page_space_used_in_percent, 2) AS 'Page Density'
FROM sys.dm_db_index_physical_stats (DB_ID ('GuidsDemo'), NULL, NULL, NULL, 'DETAILED') ips
CROSS APPLY sys.indexes si
WHERE
   si.object_id = ips.object_id
   AND si.index_id = ips.index_id
   AND ips.index_level = 0;
GO


-- Попробуем дефрагментировать через REBUILD
ALTER INDEX CI_Table_NEWID_c1 ON Table_NEWID REBUILD;
GO

ALTER INDEX IX_Table_NEWID_c2 ON Table_NEWID REBUILD;
GO

ALTER INDEX CI_Table_NEWSEQUENTIALID_c1 ON Table_NEWSEQUENTIALID REBUILD;
GO

ALTER INDEX IX_Table_NEWSEQUENTIALID_c2 ON Table_NEWSEQUENTIALID REBUILD;
GO

SELECT
   OBJECT_NAME (ips.[object_id]) AS 'Object Name',
   si.name AS 'Index Name',
   ROUND (ips.avg_fragmentation_in_percent, 2) AS 'Fragmentation',
   ips.page_count AS 'Pages',
   ROUND (ips.avg_page_space_used_in_percent, 2) AS 'Page Density'
FROM sys.dm_db_index_physical_stats (DB_ID ('GuidsDemo'), NULL, NULL, NULL, 'DETAILED') ips
CROSS APPLY sys.indexes si
WHERE
   si.object_id = ips.object_id
   AND si.index_id = ips.index_id
   AND ips.index_level = 0;
GO