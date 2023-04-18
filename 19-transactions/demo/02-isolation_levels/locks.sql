-- SELECT * FROM sys.dm_tran_locks

SELECT 
    CASE locks.resource_type
		WHEN N'OBJECT' THEN OBJECT_NAME(locks.resource_associated_entity_id)
		WHEN N'KEY'THEN (SELECT OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = locks.resource_associated_entity_id)
		WHEN N'PAGE' THEN (SELECT OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = locks.resource_associated_entity_id)
		WHEN N'HOBT' THEN (SELECT OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = locks.resource_associated_entity_id)
		WHEN N'RID' THEN (SELECT OBJECT_NAME(object_id) FROM sys.partitions WHERE hobt_id = locks.resource_associated_entity_id)
		ELSE N'Unknown'
    END AS objectName,
    CASE locks.resource_type
		WHEN N'KEY' THEN (SELECT indexes.name 
							FROM sys.partitions JOIN sys.indexes 
								ON partitions.object_id = indexes.object_id AND partitions.index_id = indexes.index_id
							WHERE partitions.hobt_id = locks.resource_associated_entity_id)
		ELSE N'Unknown'
    END AS IndexName,
    locks.resource_type,
	DB_NAME(locks.resource_database_id) AS database_name,
	locks.resource_description,
	locks.resource_associated_entity_id,
	locks.request_mode
FROM sys.dm_tran_locks AS locks
WHERE locks.resource_database_id = DB_ID(N'WideWorldImporters')
ORDER BY locks.request_session_id

/*
-- sp_who2
exec sp_who2

-- кто заблокирован
SELECT * 
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

SELECT session_id, wait_duration_ms, wait_type, blocking_session_id 
FROM sys.dm_os_waiting_tasks 
WHERE blocking_session_id <> 0

*/
-- SSMS:
-- * Activity Monitor
-- * Reports -> All Blocking Transactions
