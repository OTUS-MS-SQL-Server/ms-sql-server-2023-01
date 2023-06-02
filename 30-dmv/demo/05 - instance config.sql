-- https://www.sqlskills.com/blogs/glenn/sql-server-diagnostic-information-queries-for-december-2019/

-- SQL Server version
-- Не DMV, но очень полезно
SELECT @@VERSION

-- --------------------------------------------------
--how to search for all DMV
SELECT * 
FROM sys.all_objects 
WHERE --TYPE='V' AND 
NAME LIKE 'dm_%' order by name ASC;



-- sys.dm_os_sys_memory
-- Good basic information about OS memory amounts and state  (Query 13) (System Memory)
SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
       available_physical_memory_kb/1024 AS [Available Memory (MB)], 
       total_page_file_kb/1024 AS [Total Page File (MB)], 
	   available_page_file_kb/1024 AS [Available Page File (MB)], 
	   system_cache_kb/1024 AS [System Cache (MB)],
       system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);
------

-- You want to see "Available physical memory is high" for System Memory State
-- This indicates that you are not under external memory pressure

-- Possible System Memory State values:
-- Available physical memory is high
-- Physical memory usage is steady
-- Available physical memory is low
-- Available physical memory is running low
-- Physical memory state is transitioning

-- sys.dm_os_sys_memory (Transact-SQL)
-- https://bit.ly/2pcV0xq

-- --------------------------------------------------

-- sys.dm_os_memory_clerks
-- Еще про память - на какие типы объектов она расходуется
-- вспоминаем про Parameter Sniffing
-- много MEMORYCLERK_SQLBUFFERPOOL - хорошо
-- много CACHESTORE_SQLCP - плохо

-- Memory Clerk Usage for instance  (Query 47) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) mc.[type] AS [Memory Clerk Type], 
       CAST((SUM(mc.pages_kb)/1024.0) AS DECIMAL (15,2)) AS [Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks AS mc WITH (NOLOCK)
GROUP BY mc.[type]  
ORDER BY SUM(mc.pages_kb) DESC OPTION (RECOMPILE);
------

-- MEMORYCLERK_SQLBUFFERPOOL was new for SQL Server 2012. It should be your highest consumer of memory

-- CACHESTORE_SQLCP  SQL Plans         
-- These are cached SQL statements or batches that aren't in stored procedures, functions and triggers
-- Watch out for high values for CACHESTORE_SQLCP
-- Enabling 'optimize for ad hoc workloads' at the instance level can help reduce this
-- Running DBCC FREESYSTEMCACHE ('SQL Plans') periodically may be required to better control this

-- CACHESTORE_OBJCP  Object Plans      
-- These are compiled plans for stored procedures, functions and triggers

-- sys.dm_os_memory_clerks (Transact-SQL)
-- https://bit.ly/2H31xDR

-- --------------------------------------------------

-- sys.dm_os_sys_info
-- Процессор, ядра
-- Можно посмотреть время старта SQL Server
-- Большинство DMV отображают информацию с момента старта

-- Hardware information from SQL Server 2017  (Query 17) (Hardware Info)
SELECT cpu_count AS [Logical CPU Count], scheduler_count, 
       (socket_count * cores_per_socket) AS [Physical Core Count], 
       socket_count AS [Socket Count], cores_per_socket, numa_node_count,
       physical_memory_kb/1024 AS [Physical Memory (MB)], 
       max_workers_count AS [Max Workers Count], 
	   affinity_type_desc AS [Affinity Type], 
       sqlserver_start_time AS [SQL Server Start Time],
	   DATEDIFF(hour, sqlserver_start_time, GETDATE()) AS [SQL Server Up Time (hrs)],
	   virtual_machine_type_desc AS [Virtual Machine Type], 
       softnuma_configuration_desc AS [Soft NUMA Configuration], 
	   sql_memory_model_desc, process_physical_affinity -- New in SQL Server 2017
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);

-- --------------------------------------------------

-- sys.master_files
-- Файлы
-- File names and paths for all user and system databases on instance  (Query 25) (Database Filenames and Paths)
SELECT DB_NAME([database_id]) AS [Database Name], 
		[file_id], [name], physical_name, [type_desc], state_desc,
		is_percent_growth, growth, 
		CONVERT(bigint, growth/128.0) AS [Growth in MB], 
		CONVERT(bigint, size/128.0) AS [Total Size in MB], max_size
FROM sys.master_files WITH (NOLOCK)
ORDER BY DB_NAME([database_id]), [file_id] OPTION (RECOMPILE);
------

-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Is tempdb on dedicated drives?
-- Is there only one tempdb data file?
-- Are all of the tempdb data files the same size?
-- Are there multiple data files for user databases?
-- Is percent growth enabled for any files (which is bad)?

-- --------------------------------------------------

-- sys.dm_os_enumerate_fixed_drives
-- Диски (сколько свободно)
-- Drive information for all fixed drives visible to the operating system (Query 26) (Fixed Drives)
SELECT 
 fixed_drive_path, 
 drive_type_desc, 
 CONVERT(DECIMAL(18,2), free_space_in_bytes/1073741824.0) AS [Available Space (GB)]
FROM sys.dm_os_enumerate_fixed_drives WITH (NOLOCK) OPTION (RECOMPILE);
------

-- This shows all of your fixed drives, not just LUNs with SQL Server database files

-- --------------------------------------------------

EXEC xp_fixeddrives;


-- Справляется ли ввод-вывод (по дискам)
-- Latency больше 30-40ms обычно плохо

-- Drive level latency information (Query 28) (Drive Level Latency)
-- Based on code from Jimmy May
SELECT tab.[Drive], tab.volume_mount_point AS [Volume Mount Point], 
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (io_stall_read_ms/num_of_reads) 
	END AS [Read Latency],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (io_stall_write_ms/num_of_writes) 
	END AS [Write Latency],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE (io_stall/(num_of_reads + num_of_writes)) 
	END AS [Overall Latency],
	CASE 
		WHEN num_of_reads = 0 THEN 0 
		ELSE (num_of_bytes_read/num_of_reads) 
	END AS [Avg Bytes/Read],
	CASE 
		WHEN num_of_writes = 0 THEN 0 
		ELSE (num_of_bytes_written/num_of_writes) 
	END AS [Avg Bytes/Write],
	CASE 
		WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
		ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
	END AS [Avg Bytes/Transfer]
FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
	         SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
	         SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
	         SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.volume_mount_point 
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
	  CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs 
      GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.volume_mount_point) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);
------

-- Shows you the drive-level latency for reads and writes, in milliseconds
-- Latency above 30-40ms is usually a problem
-- These latency numbers include all file activity against all SQL Server 
-- database files on each drive since SQL Server was last started

-- --------------------------------------------------

-- sys.dm_io_virtual_file_stats
-- Задержки ввода-вывода по файлам

-- Calculates average stalls per read, per write, and per total input/output for each database file  (Query 29) (IO Latency by File)
SELECT DB_NAME(fs.database_id) AS [Database Name], CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_latency_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_latency_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_latency_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io],
io_stall_queued_read_ms AS [Resource Governor Total Read IO Latency (ms)], io_stall_queued_write_ms AS [Resource Governor Total Write IO Latency (ms)] 
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_latency_ms DESC OPTION (RECOMPILE);
------

-- Helps determine which database files on the entire instance have the most I/O bottlenecks
-- This can help you decide whether certain LUNs are overloaded and whether you might
-- want to move some files to a different location or perhaps improve your I/O performance
-- These latency numbers include all file activity against each SQL Server 
-- database file since SQL Server was last started

-- --------------------------------------------------

-- sys.databases
-- Список БД (статус, модель восстановления и др)

-- Recovery model, log reuse wait description, log file size, log usage size  (Query 32) (Database Properties)
-- and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name], SUSER_SNAME(db.owner_sid) AS [Database Owner], db.recovery_model_desc AS [Recovery Model], 
db.state_desc, db.containment_desc, db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0) AS [Log Size (MB)], CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS [Log Used (MB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
db.[compatibility_level] AS [DB Compatibility Level], 
db.is_mixed_page_allocation_on, db.page_verify_option_desc AS [Page Verify Option], 
db.is_auto_create_stats_on, db.is_auto_update_stats_on, db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on, db.is_auto_close_on, db.is_auto_shrink_on, 
db.target_recovery_time_in_seconds, db.is_cdc_enabled, db.is_published, db.is_distributor,
db.group_database_id, db.replica_id,db.is_memory_optimized_elevate_to_snapshot_on, 
db.delayed_durability_desc, db.is_auto_create_stats_incremental_on,
db.is_query_store_on, db.is_sync_with_backup, db.is_temporal_history_retention_enabled,
db.is_supplemental_logging_enabled, db.is_remote_data_archive_enabled,
db.is_encrypted, de.encryption_state, de.percent_complete, de.key_algorithm, de.key_length, db.resource_pool_id      
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
ON db.name = ls.instance_name
LEFT OUTER JOIN sys.dm_database_encryption_keys AS de WITH (NOLOCK)
ON db.database_id = de.database_id
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 
ORDER BY db.[name] OPTION (RECOMPILE);
------

-- Things to look at:
-- How many databases are on the instance?
-- What recovery models are they using?
-- What is the log reuse wait description?
-- How full are the transaction logs?
-- What compatibility level are the databases on? 
-- What is the Page Verify Option? (should be CHECKSUM)
-- Is Auto Update Statistics Asynchronously enabled?
-- Is Delayed Durability enabled
-- Make sure auto_shrink and auto_close are not enabled!

-- is_mixed_page_allocation_on is a new property for SQL Server 2016. Equivalent to TF 1118 for a user database
-- SQL Server 2016: Changes in default behavior for autogrow and allocations for tempdb and user databases
-- https://bit.ly/2evRZSR

-- A non-zero value for target_recovery_time_in_seconds means that indirect checkpoint is enabled 
-- If the setting has a zero value it indicates that automatic checkpoint is enabled

-- Changes in SQL Server 2016 Checkpoint Behavior
-- https://bit.ly/2pdggk3


