--http://sqlserverdb.blogspot.com/2011/08/how-to-check-autocreatestatistics-is.html
SELECT name AS 'Name', 
    is_auto_create_stats_on AS 'Auto Create Stats',
    is_auto_update_stats_on AS 'Auto Update Stats',
	is_auto_update_stats_async_on AS 'Auto Update Stats Async', 
    is_read_only AS 'Read Only' 
FROM sys.databases
WHERE database_ID > 4;

ALTER DATABASE WideWorldImporters SET AUTO_CREATE_STATISTICS ON;	
ALTER DATABASE WideWorldImporters SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE WideWorldImporters SET AUTO_UPDATE_STATISTICS_ASYNC OFF;

DROP TABLE IF EXISTS Application.CitiesCopy;

SELECT * INTO Application.CitiesCopy 
FROM [Application].[Cities];

ALTER DATABASE WideWorldImporters SET AUTO_CREATE_STATISTICS OFF;	
ALTER DATABASE WideWorldImporters SET AUTO_UPDATE_STATISTICS OFF;

ALTER TABLE [Application].[CitiesCopy] ADD  CONSTRAINT [PK_Application_Cities_Copy] PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
) ON [USERDATA];

CREATE NONCLUSTERED INDEX CitiesCopy_StateProvinceId ON [Application].[CitiesCopy]
(
	[StateProvinceID] ASC
)  ON [USERDATA];
GO

CREATE NONCLUSTERED INDEX CitiesCopy_StateProvinceId ON [Application].[CitiesCopy]
(
	[StateProvinceID] ASC
)  ON [USERDATA];
GO

SELECT *
FROM Application.CitiesCopy
WHERE CityId = 10;

SELECT CityName, count(*) AS cnt
FROM Application.CitiesCopy
GROUP BY CityName 
ORDER BY cnt DESC;

SELECT StateProvinceID, count(*) AS cnt
FROM Application.CitiesCopy
GROUP BY StateProvinceID 
ORDER BY cnt DESC;

SELECT * 
FROM Application.CitiesCopy
WHERE CityName = 'Jeffersonville';

SELECT * 
FROM Application.CitiesCopy
WHERE CityName = 'Jeff';
 
SELECT CityID, CityName 
FROM Application.CitiesCopy
WHERE CityName = 'Jack';

SELECT CityID, CityName 
FROM Application.CitiesCopy
WHERE CityName = 'Franklin';

SELECT * 
FROM Application.CitiesCopy
WHERE StateProvinceID = 45;

set statistics io on;
set statistics time on;
set showplan_all on;

SELECT * 
FROM Application.CitiesCopy
WHERE StateProvinceID = 41;

       |--Clustered Index Seek(OBJECT:([WideWorldImporters].[Application].[CitiesCopy].[PK_Application_Cities_Copy]), 
			 --SEEK:([WideWorldImporters].[Application].[CitiesCopy].[CityID]
				--		=[WideWorldImporters].[Application].[CitiesCopy].[CityID]) 
				--	LOOKUP ORDERED FORWARD)

	       |--Index Seek(OBJECT:([WideWorldImporters].[Application].[CitiesCopy].[CitiesCopy_StateProvinceId]), 
			--SEEK:([WideWorldImporters].[Application].[CitiesCopy].[StateProvinceID]=(41)) ORDERED FORWARD)

SELECT StateProvinceID, count(*) AS cnt
FROM Application.CitiesCopy
GROUP BY StateProvinceID 
ORDER BY StateProvinceID ASC;
DBCC SHOW_Statistics (N'Application.CitiesCopy',N'CitiesCopy_StateProvinceId');

select *
from Application.CitiesCopy
WHERE CityName BETWEEN 'Aaronsburg'
AND 'Addison'
ORDER BY CityName;

CREATE NONCLUSTERED INDEX CitiesCopy_CityName ON [Application].[CitiesCopy]
(
	CityName ASC
)  ON [USERDATA];
GO

DBCC SHOW_Statistics (N'Application.CitiesCopy',N'_WA_Sys_00000002_44160A59');

DBCC SHOW_Statistics (N'Application.CitiesCopy',N'CityName');

SELECT COUNT(*), COUNT(DISTINCT CityName)
FROM Application.CitiesCopy
WHERE CityName > N'Albany'
	AND CityName < N'Alexandria';

UPDATE STATISTICS Application.CitiesCopy;
UPDATE STATISTICS Application.CitiesCopy WITH FULLSCAN;

ALTER DATABASE WideWorldImporters SET AUTO_CREATE_STATISTICS ON;	
ALTER DATABASE WideWorldImporters SET AUTO_UPDATE_STATISTICS ON;

--https://www.mssqltips.com/sqlservertip/2734/what-are-the-sql-server-wasys-statistics/
SELECT stat.name AS 'Statistics',
 OBJECT_NAME(stat.object_id) AS 'Object',
 COL_NAME(scol.object_id, scol.column_id) AS 'Column', stat.*
FROM sys.stats AS stat (NOLOCK) Join sys.stats_columns AS scol (NOLOCK)
 ON stat.stats_id = scol.stats_id AND stat.object_id = scol.object_id
 INNER JOIN sys.tables AS tab (NOLOCK) on tab.object_id = stat.object_id
WHERE --stat.name like '_WA%'
--AND 
OBJECT_NAME(stat.object_id) = 'CitiesCopy'
ORDER BY stat.name;