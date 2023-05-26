/* tsqllint-disable error invalid-syntax */
/* tsqllint-disable error select-star */

-- Пример Page Split

-- Удаляем старое, создаем новую БД
USE [master];
GO

ALTER DATABASE PageSplitDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE IF EXISTS PageSplitDemo;
GO

CREATE DATABASE PageSplitDemo;
GO

USE PageSplitDemo;
GO

-- ---------------

-- Создаем таблицу
CREATE TABLE dbo.TestTable (
  [ID] INT,
  [Data] CHAR(4000),
  CONSTRAINT [PK_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);
GO

-- Вставим несколько строк 
DECLARE @n INT = 0;
WHILE (@n < 20) 
BEGIN  
	INSERT INTO dbo.TestTable VALUES (@n, REPLICATE ('data', 1000));
	SET @n = @n + 2;
END  
GO

-- Посмотрим данные
-- fn_PhysLocFormatter -- возвращает адреса слотов данных (FileNum:PageNum:SlotNum)
SELECT sys.fn_PhysLocFormatter(t.%%physloc%%) AS [page], * 
FROM TestTable t;

-- и список страниц
DBCC IND(PageSplitDemo, N'TestTable', 1);
GO

-- Таблица кластеризованная
-- IndexLevel – уровень страницы в индексе
--   0   - листья
--   ... - корень

-- и фрагментацию
SELECT a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N'PageSplitDemo'), NULL, NULL, NULL, NULL) AS a  
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id;   
GO
-- avg_fragmentation_in_percent 20

-- Вставляем данные "между строк", что приведет в PAGE SPLIT
INSERT INTO dbo.TestTable VALUES (13, REPLICATE ('data', 1000));
GO

-- Опять посмотрим данные
SELECT sys.fn_PhysLocFormatter(t.%%physloc%%) AS [page], * 
FROM TestTable t 

-- и страницы
DBCC IND(PageSplitDemo, N'TestTable', 1);

-- и фрагментацию
SELECT a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N'PageSplitDemo'), NULL, NULL, NULL, NULL) AS a  
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id;   
GO

-- С помощью fn_dblog(NULL, NULL) можно прочитать журнал транзакций
SELECT * FROM fn_dblog(NULL, NULL);

-- Смотрим операции Page Split
SELECT
    operation,
	AllocUnitName,
	[Context],
	(CASE [Context]
		WHEN N'LCX_INDEX_LEAF' THEN N'Nonclustered'
		WHEN N'LCX_CLUSTERED' THEN N'Clustered'
		ELSE N'Non-Leaf'
	END) AS [SplitType],
	Description,
	AllocUnitId,
	[Page ID],
	[Slot ID],
	[New Split Page]
FROM fn_dblog(NULL, NULL)
WHERE Operation = 'LOP_DELETE_SPLIT' AND 
      AllocUnitName NOT LIKE 'sys.%';

-- Общее количество Page Split в разрезе таблиц/индексов
SELECT
    [AllocUnitName] AS N'Index',
    (CASE [Context]
        WHEN N'LCX_INDEX_LEAF' THEN N'Nonclustered'
        WHEN N'LCX_CLUSTERED' THEN N'Clustered'
        ELSE N'Non-Leaf'
    END) AS [SplitType],
    COUNT (1) AS [SplitCount]
FROM fn_dblog (NULL, NULL)
WHERE Operation = N'LOP_DELETE_SPLIT' AND 
      AllocUnitName NOT LIKE 'sys.%'
GROUP BY [AllocUnitName], [Context]
ORDER BY [AllocUnitName];

-- см. слайды REBUILD, REORG

-- ---------------------------
-- дефрагментируем
-- ---------------------------
-- Было 20%, потом 50%
-- REORGANIZE
ALTER INDEX PK_ID ON TestTable 
REORGANIZE;
GO

SELECT a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N'PageSplitDemo'), NULL, NULL, NULL, NULL) AS a  
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id;   
GO

-- REBUILD 
ALTER INDEX PK_ID ON TestTable 
REBUILD;
GO

SELECT a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N'PageSplitDemo'), NULL, NULL, NULL, NULL) AS a  
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id;   
GO
