select 
l.request_type
,DB_NAME(l.resource_database_id)  as [DB_Name]
,OBJECT_NAME(i.object_id) as Table_name
,i.name as IndexName
,i.type_desc
,l.resource_associated_entity_id as [blk object]
,l.request_session_id as blocked_session_id
,l.request_mode
,l.request_type
,l.resource_type
,l.resource_description
,l.request_status
,l.request_owner_type from  sys.dm_tran_locks as l
inner join sys.partitions  as p on p.partition_id = l.resource_associated_entity_id
inner join sys.indexes as i on i.object_id = p.object_id and i.index_id = p.index_id

