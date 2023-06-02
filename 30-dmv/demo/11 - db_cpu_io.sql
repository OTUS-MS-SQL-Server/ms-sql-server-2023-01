WITH DB_CPU_Stats
AS
(
    SELECT DatabaseID, isnull(DB_Name(DatabaseID),case DatabaseID when 32767 then 'Internal ResourceDB' else CONVERT(varchar(255),DatabaseID)end) AS [DatabaseName], 
      SUM(total_worker_time) AS [CPU Time Ms],
      SUM(total_logical_reads)  AS [Logical Reads],
      SUM(total_logical_writes)  AS [Logical Writes],
      SUM(total_logical_reads+total_logical_writes)  AS [Logical IO],
      SUM(total_physical_reads)  AS [Physical Reads],
      SUM(total_elapsed_time)  AS [Duration MicroSec],
      SUM(total_clr_time)  AS [CLR Time MicroSec],
      SUM(total_rows)  AS [Rows Returned],
      SUM(execution_count)  AS [Execution Count],
      count(*) 'Plan Count'

    FROM sys.dm_exec_query_stats AS qs
    OUTER APPLY (
                    SELECT CONVERT(int, value) AS [DatabaseID] 
                  FROM sys.dm_exec_plan_attributes(qs.plan_handle)
                  WHERE attribute = N'dbid') AS F_DB
    GROUP BY DatabaseID
)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU Time Ms] DESC) AS [Rank CPU],
       DatabaseName,
       [CPU Time Hr] = convert(decimal(15,2),([CPU Time Ms]/1000.0)/3600) ,
        CAST((case [CPU Time Ms] when 0 then 0 else [CPU Time Ms] * 1.0 / SUM([CPU Time Ms]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [CPU Percent],
       [Duration Hr] = convert(decimal(15,2),([Duration MicroSec]/1000000.0)/3600) , 
       CAST((case [Duration MicroSec] when 0 then 0 else [Duration MicroSec] * 1.0 / SUM([Duration MicroSec]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [Duration Percent],    
       [Logical Reads],
        CAST((case [Logical Reads] when 0 then 0 else [Logical Reads] * 1.0 / SUM([Logical Reads]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [Logical Reads Percent],      
       [Rows Returned],
        CAST((case [Rows Returned] when 0 then 0 else [Rows Returned] * 1.0 / SUM([Rows Returned]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [Rows Returned Percent],
       [Reads Per Row Returned] = (case [Rows Returned] when 0 then 0 else [Logical Reads]/[Rows Returned] end),
       [Execution Count],
        CAST((case [Execution Count] when 0 then 0 else [Execution Count] * 1.0 / SUM([Execution Count]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [Execution Count Percent],
       [Physical Reads],
       CAST((case [Physical Reads] when 0 then 0 else [Physical Reads] * 1.0 / SUM([Physical Reads]) OVER() * 100.0 end )AS DECIMAL(5, 2)) AS [Physcal Reads Percent], 
       [Logical Writes],
        CAST((case [Logical Writes] when 0 then 0 else [Logical Writes] * 1.0 / SUM([Logical Writes]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [Logical Writes Percent],
       [Logical IO],
        CAST((case [Logical IO] when 0 then 0 else [Logical IO] * 1.0 / SUM([Logical IO]) OVER() * 100.0 end) AS DECIMAL(5, 2)) AS [Logical IO Percent],
       [CLR Time MicroSec],
       CAST([CLR Time MicroSec] * 1.0 / SUM(case [CLR Time MicroSec] when 0 then 1 else [CLR Time MicroSec] end ) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CLR Time Percent],
       [CPU Time Ms],
	   [CPU Time Ms]/1000 [CPU Time Sec],
       [Duration MicroSec],
	   [Duration MicroSec]/1000000 [Duration Sec]
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
-- AND DatabaseID > 4 -- system databases
ORDER BY [Rank CPU] OPTION (RECOMPILE);


