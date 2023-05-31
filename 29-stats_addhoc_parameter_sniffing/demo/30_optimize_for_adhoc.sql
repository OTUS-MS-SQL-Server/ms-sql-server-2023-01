
SELECT sc.*
FROM sys.configurations AS sc
WHERE sc.name = 'optimize for ad hoc workloads';

EXEC sp_configure 'show advanced options', 1; 
go
EXEC sp_configure 'optimize for ad hoc workloads', 1;
go
RECONFIGURE;
go