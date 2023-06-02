 -- запрос с missing indexes
SELECT AP.EmailAddress, SI.InvoiceDate
FROM [Sales].[Invoices] SI
  INNER JOIN [Application].[People] AP ON SI.LastEditedBy = AP.PersonID
WHERE AP.EmailAddress = 'kaylaw@wideworldimporters.com';
GO

-- Отсутствующие индексы (missing indexes)
SELECT * FROM sys.dm_db_missing_index_groups
SELECT * FROM sys.dm_db_missing_index_group_stats 
SELECT * FROM sys.dm_db_missing_index_details 

SELECT
mig.index_group_handle, mid.index_handle,
CONVERT (decimal (28,1),
migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)
) AS improvement_measure,
'CREATE INDEX missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle)
+ ' ON ' + mid.statement
+ ' (' + ISNULL (mid.equality_columns,'')
+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
+ ISNULL (mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '')
+ ' WITH (ONLINE=ON)' AS create_index_statement,
migs.*, mid.*, mid.database_id, mid.[object_id]
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
-- WHERE CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10 
-- AND database_id = 12
-- AND mid.statement like ('%[DataFile]')
ORDER BY convert(varchar(10), last_user_seek, 120) desc, migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) /*last_user_seek*/ DESC
