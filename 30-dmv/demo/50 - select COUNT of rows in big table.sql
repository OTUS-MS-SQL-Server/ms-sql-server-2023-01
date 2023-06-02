-- Как быстро посмотреть количество строк

-- Обычный способ
SELECT COUNT(*) 
FROM Warehouse.ColdRoomTemperatures_Archive;

-- Хитрый способ
SELECT SUM(st.row_count)
FROM sys.dm_db_partition_stats st
WHERE object_name(object_id) = 'ColdRoomTemperatures_Archive' AND (index_id < 2);


-- А еще можно так
exec sp_spaceused 'Warehouse.ColdRoomTemperatures_Archive';

DBCC UPDATEUSAGE (WideWorldImporters,'Warehouse.ColdRoomTemperatures_Archive');  
