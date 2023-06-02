USE WideWorldImporters

-- Список доступных collation
SELECT * FROM sys.fn_helpcollations();

-- Текущие collation
SELECT 
   (CONVERT(varchar, SERVERPROPERTY('collation'))) [Instance],
   (SELECT CONVERT (VARCHAR(50), DATABASEPROPERTYEX('WideWorldImporters','collation'))) as [DB],
   (SELECT COLLATION_NAME FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_SCHEMA='Sales' and TABLE_NAME = 'Orders' and COLUMN_NAME = 'Comments') as [Column]
GO

-- ---------------------
-- TempDB
-- ---------------------

-- Новая БД с "неправильным" collation
DROP DATABASE IF EXISTS [CollationTest];
GO
CREATE DATABASE [CollationTest] COLLATE Latin1_General_CI_AS;
GO

use [CollationTest];
GO

select databasepropertyex ('tempdb', 'collation') as tempdb
select databasepropertyex ('CollationTest', 'collation') as CollationTestDb



-- Создаем таблицу
CREATE TABLE [Test] (
 id int,
 name nvarchar(10)
);
GO
 
-- Вставляем данные
insert into Test values (1, 'aaa'),
						(2, 'bbb'),
						(3, 'ccc');
 
 -- текущий collation
CREATE TABLE #TempTable (
 id int,
 name nvarchar(10)
);
 GO

INSERT INTO #TempTable
SELECT TOP 2 * FROM Test;
GO
 
SELECT *
FROM Test t
JOIN #TempTable tmp
ON tmp.[name] = t.[name]
 
DROP TABLE #TempTable;

-- Как лечить?
-- Способ 1
CREATE TABLE #TempTable (
 id int,
 name nvarchar(10)
);
 GO

INSERT INTO #TempTable
SELECT TOP 2 * FROM Test;
GO
 
SELECT *
FROM Test t
JOIN #TempTable tmp
ON tmp.[name] = t.[name]  COLLATE Latin1_General_CI_AS;
 
DROP TABLE #TempTable;

-- Способ 2
CREATE TABLE #TempTable (
 id int,
 name nvarchar(10)
);
 GO

INSERT INTO #TempTable
SELECT TOP 2 * FROM Test;
GO
 
SELECT *
FROM Test t
JOIN #TempTable tmp
ON tmp.[name] = t.[name]  COLLATE DATABASE_DEFAULT;

DROP TABLE #TempTable;

-- Способ 3
CREATE TABLE #TempTable (
 id int,
 name nvarchar(10) COLLATE DATABASE_DEFAULT
);
GO

INSERT INTO #TempTable
SELECT TOP 2 * FROM Test;
GO
 
SELECT *
FROM Test t
JOIN #TempTable tmp
ON tmp.[name] = t.[name];

DROP TABLE #TempTable;

------регистры
SELECT TOP (1000) [id]
      ,[name]
  FROM [CollationTest].[dbo].[Test]
  where name = 'aAA'

CREATE TABLE Table2 (
 id int,
 name nvarchar(10) COLLATE Latin1_General_CS_AS
);
 GO

INSERT INTO Table2
	SELECT TOP 2 * FROM Test;
GO

SELECT *
  FROM Table2
  where name = lower('aAA');

-- Влияет ли явный COLLATE на производительность запроса ?

use WideWorldImporters

SELECT COLLATION_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA='Application' and TABLE_NAME = 'People' and COLUMN_NAME = 'FullName'
GO

SELECT PersonID, FullName
FROM [Application].People
ORDER BY FullName 
-- COLLATE Latin1_General_100_CI_AS

SELECT PersonID, FullName
FROM [Application].People
ORDER BY FullName COLLATE Cyrillic_General_CI_AS
GO
  
