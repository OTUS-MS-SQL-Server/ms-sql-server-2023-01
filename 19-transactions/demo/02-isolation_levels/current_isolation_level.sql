-- Уровень изоляции текущей сессии
SELECT 
    session_id,
    CASE transaction_isolation_level 
        WHEN 0 THEN 'Unspecified' 
        WHEN 1 THEN 'Read Uncommitted' 
        WHEN 2 THEN 'Read Committed' 
        WHEN 3 THEN 'Repeatable Read' 
        WHEN 4 THEN 'Serializable' 
        WHEN 5 THEN 'Snapshot' 
    END AS TRANSACTION_ISOLATION_LEVEL 
FROM sys.dm_exec_sessions 
WHERE session_id = @@SPID;

DBCC USEROPTIONS

-- Для запросов из SMSS
SELECT 
    session_id,
    CASE transaction_isolation_level 
        WHEN 0 THEN 'Unspecified' 
        WHEN 1 THEN 'Read Uncommitted' 
        WHEN 2 THEN 'Read Committed' 
        WHEN 3 THEN 'Repeatable Read' 
        WHEN 4 THEN 'Serializable' 
        WHEN 5 THEN 'Snapshot' 
    END AS TRANSACTION_ISOLATION_LEVEL 
FROM sys.dm_exec_sessions 
WHERE program_name like '%Microsoft SQL Server Management Studio%'
