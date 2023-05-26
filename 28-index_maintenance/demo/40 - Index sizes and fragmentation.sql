USE WideWorldImporters;

-- Размеры индексов

SELECT i.[name] AS IndexName
	,SUM(s.[used_page_count]) * 8/ 1024/1024 AS IndexSizeGB
	,SUM(s.[used_page_count]) * 8/ 1024 AS IndexSizeMB
FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
	AND s.[index_id] = i.[index_id] 
-- WHERE s.[object_id] = object_id('Sales.Invoices')
GROUP BY i.[name]
ORDER BY IndexSizeMB DESC;
GO

-- По размерам таблиц есть удобный отчет в SSMS 

-- Больше информации, в т.ч. фрагментация
SELECT [DatabaseName]
    ,[ObjectId]
    ,[ObjectName]
    ,[IndexId]
	,[IndexName]
    ,[IndexDescription]
    ,CONVERT(DECIMAL(16, 1), (SUM([avg_record_size_in_bytes] * [record_count]) / (1024.0 * 1024))) AS [IndexSize(MB)]
    ,[lastupdated] AS [StatisticLastUpdated]
    ,[AvgFragmentationInPercent]
FROM (
    SELECT DISTINCT DB_Name(s.Database_id) AS 'DatabaseName'
        ,s.OBJECT_ID AS ObjectId
        ,Object_Name(s.Object_id) AS ObjectName
        ,s.Index_ID AS IndexId
		,i.Name AS IndexName
        ,s.Index_Type_Desc AS IndexDescription
        ,s.avg_record_size_in_bytes
        ,s.record_count
        ,STATS_DATE(s.object_id, s.index_id) AS 'lastupdated'
        ,CONVERT([varchar](512), round(s.Avg_Fragmentation_In_Percent, 3)) AS 'AvgFragmentationInPercent'
    FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'detailed') s
	JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    WHERE s.OBJECT_ID IS NOT NULL
        AND s.Avg_Fragmentation_In_Percent <> 0
    ) T
GROUP BY DatabaseName
    ,ObjectId
    ,ObjectName
    ,IndexId
	,IndexName
    ,IndexDescription
    ,lastupdated
    ,AvgFragmentationInPercent;