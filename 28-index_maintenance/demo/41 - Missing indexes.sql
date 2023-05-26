/* tsqllint-disable error select-star */

USE WideWorldImporters;

 -- Запрос с missing indexes
SELECT AP.EmailAddress, SI.InvoiceDate
FROM [Sales].[Invoices] SI
INNER JOIN [Application].[People] AP ON SI.LastEditedBy = AP.PersonID
WHERE AP.EmailAddress = 'kaylaw@wideworldimporters.com';
GO

-- Отсутствующие индексы (missing indexes)
SELECT * FROM sys.dm_db_missing_index_groups;
SELECT * FROM sys.dm_db_missing_index_group_stats;
SELECT * FROM sys.dm_db_missing_index_details;

-- user_seeks            Количество операций поиска по запросам пользователя, 
--                       для которых мог бы использоваться рекомендованный индекс в группе.
-- user_scans            Количество операций просмотра по запросам пользователя, 
--                       для которых мог бы использоваться рекомендованный индекс в группе.
-- avg_total_user_cost   Средняя стоимость запросов пользователя, 
--                       которая могла быть уменьшена с помощью индекса в группе.
-- avg_user_impact       Средний процент выигрыша, который могли получить запросы пользователя, 
--                       если создать эту группу отсутствующих индексов. 
--                       Значение показывает, что стоимость запроса в среднем уменьшится на этот процент, 
--                       если создать эту группу отсутствующих индексов.

SELECT
    mig.index_group_handle, 
    mid.index_handle,
    CONVERT (DECIMAL (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure,
    'CREATE INDEX missing_index_' + CONVERT (VARCHAR(2), mig.index_group_handle) + '_' + CONVERT (VARCHAR(2), mid.index_handle)
    + ' ON ' + mid.statement
    + ' (' + ISNULL (mid.equality_columns,'')
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
    + ISNULL (mid.inequality_columns, '')
    + ')'
    + ISNULL (' INCLUDE (' + mid.included_columns + ')', '')
    + ' WITH (ONLINE=ON)' AS create_index_statement,
    migs.*, 
    mid.*, 
    mid.database_id, 
    mid.[object_id]
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
-- WHERE CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10 
-- AND database_id = 12
-- AND mid.statement like ('%[DataFile]')
ORDER BY CONVERT(VARCHAR(10), last_user_seek, 120) DESC, migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) /*last_user_seek*/ DESC;
