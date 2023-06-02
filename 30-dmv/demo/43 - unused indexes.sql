-- unused indexes
-- sys.dm_db_index_usage_stats - статистика использования индексов
-- Плохо, когда user_seeks, user_scans мало, а user_updates много - индекс не используется

declare @dbid int
select @dbid = db_id()
select (cast((user_seeks + user_scans + user_lookups) as float) / case user_updates when 0 then 1.0 else cast(user_updates as float) end) * 100 as [%]
	, (user_seeks + user_scans + user_lookups) AS total_usage
	, objectname=object_name(s.object_id), s.object_id
	, indexname=i.name, i.index_id
	, user_seeks, user_scans, user_lookups, user_updates
	, last_user_seek, last_user_scan, last_user_update
	, last_system_seek, last_system_scan, last_system_update
	, 'DROP INDEX ' + i.name + ' ON ' + object_name(s.object_id) as [Command]
from sys.dm_db_index_usage_stats s,
	sys.indexes i
where database_id = @dbid 
and objectproperty(s.object_id,'IsUserTable') = 1
and i.object_id = s.object_id
and i.index_id = s.index_id
AND i.is_primary_key = 0		-- исключаем Primary Key
AND i.is_unique_constraint = 0	-- исключаем Constraints
--and object_name(s.object_id) = 'MyBigTable'
order by [%] asc

-- https://blog.sqlauthority.com/2011/01/04/sql-server-2008-unused-index-script-download/