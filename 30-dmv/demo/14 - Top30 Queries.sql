-- TOP 30 запросов, которыми занят сервер


select * from sys.dm_exec_query_stats 
-- DMF - sys.dm_exec_sql_text(q.sql_handle) 
-- DMF - sys.dm_exec_query_plan(q.plan_handle)

select Batch_Text = ISNULL(cast(object_name(st.objectid, st.dbid) as nvarchar(max)), st.text)
	, Statement = (SELECT SUBSTRING(st.text, statement_start_offset / 2, 
									(CASE WHEN statement_end_offset = -1 
										THEN LEN(CONVERT (NVARCHAR (MAX), text)) * 2 
										ELSE statement_end_offset END - statement_start_offset) / 2))
	, q.*
	, qp.query_plan, Database_id = st.dbid, Object_id = st.objectid
from
(select TOP 30 qs.query_hash, qs.query_plan_hash, statement_start_offset, statement_end_offset
	, LastRequest = max(last_execution_time)
	, Query_Count = count(1), Executions = SUM(execution_count)
	, TotalCPU = SUM(total_worker_time), MinCPU = min(min_worker_time), MaxCPU = max(max_worker_time), AvgCPU = sum(total_worker_time) / sum(execution_count)
	, Reads = SUM(total_logical_reads), MinReads = min(min_logical_reads), MaxReads = max(max_logical_reads), AvgReads = sum(total_logical_reads) / sum(execution_count)
	, Duration = SUM(total_elapsed_time), MinDuration = min(min_elapsed_time), MaxDuration = max(max_elapsed_time), AvgDuration = sum(total_elapsed_time) / sum(execution_count)
	, sql_handle = max(sql_handle)
	, plan_handle = max(plan_handle)
from sys.dm_exec_query_stats qs
group by qs.query_hash, qs.query_plan_hash, statement_start_offset, statement_end_offset
order by TotalCPU desc) q
cross apply sys.dm_exec_sql_text(q.sql_handle) st
cross apply sys.dm_exec_query_plan(q.plan_handle) qp

-- Очистить кэш
-- DBCC FREEPROCCACHE
-- DBCC FREESYSTEMCACHE('SQL Plans')