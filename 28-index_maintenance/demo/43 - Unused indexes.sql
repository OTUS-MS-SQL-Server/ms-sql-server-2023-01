/* tsqllint-disable error object-property */
/* tsqllint-disable error non-sargable */

USE WideWorldImporters;

-- unused indexes
-- sys.dm_db_index_usage_stats - статистика использования индексов
-- Плохо, когда user_seeks, user_scans мало, а user_updates много - индекс не используется

DECLARE @dbid INT;
SELECT @dbid = db_ID();
SELECT (CAST((user_seeks + user_scans + user_lookups) AS FLOAT(24)) / CASE user_updates WHEN 0 THEN 1.0 ELSE CAST(user_updates AS FLOAT(24)) END) * 100 AS [%]
    , (user_seeks + user_scans + user_lookups) AS total_usage
    , objectname=object_name(s.object_id), s.object_id
    , indexname=i.name, i.index_id
    , user_seeks, user_scans, user_lookups, user_updates
    , last_user_seek, last_user_scan, last_user_update
    , last_system_seek, last_system_scan, last_system_update
    , 'DROP INDEX ' + i.name + ' ON ' + object_name(s.object_id) AS [Command]
FROM sys.dm_db_index_usage_stats s, sys.indexes i
WHERE database_id = @dbid 
AND OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
AND i.object_id = s.object_id
AND i.index_id = s.index_id
AND i.is_primary_key = 0        -- исключаем Primary Key
AND i.is_unique_constraint = 0    -- исключаем Constraints
--AND OBJECT_NAME(s.object_id) = 'MyBigTable'
ORDER BY [%] ASC;

-- https://blog.sqlauthority.com/2011/01/04/sql-server-2008-unused-index-script-download/