/* tsqllint-disable error non-sargable */
/* tsqllint-disable error select-star */

USE WideWorldImporters;

-- -----------------------------------------
-- 2) TABLE SCAN, INDEX SEEK, ...
-- -----------------------------------------

-- Вернем БД в первоначальное состояние 
DROP TABLE IF EXISTS Application.CountriesCount;
DROP INDEX IX_Application_Countries_CountryName_INCLUDE_Continent
ON Application.Countries;


-- Создаем тестовую таблицу с помощью SELECT INTO
SELECT Continent, COUNT(*) AS CountryCount 
   INTO Application.CountriesCount
FROM Application.Countries
GROUP BY Continent;

-- Посмотрим, что получилось
SELECT * 
FROM Application.CountriesCount;
-- Созданная таблица будет "кучей" (heap)

-- Table Scan 
-- Как по плану выполнения понять куча или кластеризованная таблица?
SELECT CountryCount
FROM Application.CountriesCount
WHERE Continent = 'Asia';

-- Clustered Index Scan
SELECT * 
FROM Application.Countries;

-- Добавим условие WHERE
SELECT CountryName
FROM Application.Countries
WHERE Continent = 'Asia';

-- С помощью sp_helpindex можно посмотреть индексы в таблице
-- а также в SSMS: <table> \ Indexes

EXEC sp_helpindex 'Application.Countries';
-- есть индекс по CountryName
-- попробуем WHERE CountryName

-- Index Seek (используется индекс)
SELECT CountryID
FROM Application.Countries
WHERE CountryName = 'Korea';

-- Сравним с Index Scan
SELECT CountryID
FROM Application.Countries WITH(INDEX(1))
WHERE CountryName = 'Korea';
-- Если есть кластерный индекс: 
-- INDEX(0) - clustered index scan, 
-- INDEX(1) - clustered index scan или seek. 
-- 
-- Если кластерного индекса нет: 
-- INDEX(0) - table scan, 
-- INDEX(1) - ошибка.

-- Key Lookup
-- предыдущий запрос
SELECT CountryID
FROM Application.Countries
WHERE CountryName = 'Korea';

-- здесь Key Lookup
-- Откуда в плане JOIN? 
SELECT CountryID, Continent
FROM Application.Countries 
WHERE CountryName = 'Korea';

-- Как убрать Key Lookup?
CREATE NONCLUSTERED INDEX IX_Application_Countries_CountryName_INCLUDE_Continent
ON Application.Countries(CountryName)
INCLUDE(Continent);
GO

EXEC sp_helpindex 'Application.Countries';

-- Это будет "покрывающий" индекс
-- SQL Server берет все данные из индекса и не обращается к другим данным

-- Проверим использование IX_Application_Countries_CountryName_INCLUDE_Continent

SELECT CountryID, Continent
FROM Application.Countries 
WHERE CountryName = 'Korea';
GO

-- Удалим индекс, он нам больше не понадобиться
DROP INDEX IX_Application_Countries_CountryName_INCLUDE_Continent
ON Application.Countries;
GO

-- Создаем еще одну кучу (heap) и потом создадим индекс для нее 
DROP TABLE IF EXISTS Application.CountriesCount_Index;

-- тестовая heap-табличка с индексом
SELECT * 
INTO Application.CountriesCount_Index
FROM Application.CountriesCount;
GO

CREATE INDEX IX_CountryCount_ContinentIndex 
ON Application.CountriesCount_Index (Continent);
GO

-- Что в табличке и какие индексы
SELECT * FROM Application.CountriesCount_Index;
EXEC sp_helpindex 'Application.CountriesCount_Index';
GO

-- RID Lookup
SELECT CountryCount
FROM Application.CountriesCount_Index
WITH (INDEX(IX_CountryCount_ContinentIndex))
WHERE Continent = 'Asia';

-- Сравним без хинта WITH (INDEX(IX_CountryCount_ContinentIndex))
SELECT CountryCount
FROM Application.CountriesCount_Index
WHERE Continent = 'Asia';

-- Вспомним, что в таблице CountriesCount_Index
SELECT *
FROM Application.CountriesCount_Index;

-- Несколько индексов в одном запросе
EXEC sp_helpindex 'Sales.Invoices';

SELECT InvoiceID
FROM Sales.Invoices 
WHERE SalespersonPersonID = 16 AND CustomerID = 57;

-- Несколько индексов в одном запросе + Key Lookup
SELECT InvoiceID, InvoiceDate
FROM Sales.Invoices
WHERE SalespersonPersonID = 16 AND CustomerID = 57;

-- Опять JOIN, аж две штуки. Откуда? В исходном запросе нет ни одного?

-- А в чем отличие RID Lookup и Key Lookup?

-- SARGable (Search ARGguments able)
-- Можно ли в условии WHERE использовать индексы или нет 
-- Надо стремиться создавать запросы, которые SARGable

-- Где будет использоваться индекс?
EXEC sp_helpindex 'Sales.Invoices';

-- Есть индекс по ConfirmedDeliveryTime

-- Здесь 
SELECT InvoiceID
FROM Sales.Invoices
WHERE YEAR(ConfirmedDeliveryTime) = 2014;

-- Или здесь
SELECT InvoiceID
FROM Sales.Invoices
WHERE ConfirmedDeliveryTime BETWEEN '2014-01-01' AND '2015-01-01';
GO

-- ConfirmedDeliveryTime - тип datetime2

-- плохо  - WHERE f(field) = 'some_value'
-- хорошо - WHERE field = f(x)

-- А здесь?
SELECT FullName, LEFT(FullName, 1)
FROM Application.People
WHERE LEFT(FullName, 1) = 'K';
-- Если нет, то как исправить?







-- Index Seek
SELECT FullName  
FROM Application.People
WHERE FullName LIKE 'K%';

-- А здесь?
SELECT FullName  
FROM Application.People
WHERE FullName LIKE '%K';

-- А здесь?
SELECT FullName  
FROM Application.People
WHERE FullName LIKE '%K%';
GO