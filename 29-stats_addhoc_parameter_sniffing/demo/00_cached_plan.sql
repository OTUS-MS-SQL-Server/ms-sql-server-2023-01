--Kimberly L. Tripp
--ad hoc part
SELECT st.text
	, qs.execution_count
	, qs.*
	, pl.*
FROM sys.dm_exec_query_stats AS qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS pl
WHERE st.text like '%CitiesCopy%'
ORDER BY st.text, qs.execution_count DESC;


SELECT TOP 10
	qt.text AS TSQL_Text,
	qs.creation_time, 
	qs.execution_count,
	qs.total_worker_time AS total_cpu_time,
	qs.total_elapsed_time, 
	qs.total_logical_reads, 
	qs.total_physical_reads, 
	pl.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS pl
WHERE qt.text LIKE '%Cit%';


SELECT objtype, cacheobjtype, 
  AVG(usecounts) AS Avg_UseCount, 
  SUM(refcounts) AS AllRefObjects, 
  SUM(CAST(size_in_bytes AS bigint))/1024/1024 AS Size_MB
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' AND usecounts = 1
GROUP BY objtype, cacheobjtype;


SELECT objtype, cacheobjtype, usecounts, refcounts, size_in_bytes, *
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc';
