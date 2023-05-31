--do not run on Prod
DBCC FREEPROCCACHE 
GO 
DBCC DROPCLEANBUFFERS 
Go 
DBCC FREESYSTEMCACHE ('ALL') 
GO 
DBCC FREESESSIONCACHE 
GO

Declare @dbid int
select @dbid = database_id
from sys.databases
where name = 'World Wide Importers'

DBCC FLUSHPROCINDB(@dbid) 
GO

EXEC sp_recompile @objname = '';