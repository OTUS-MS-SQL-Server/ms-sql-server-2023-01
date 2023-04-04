/* tsqllint-disable error non-sargable */

-- =========================================
-- Полнотекстовые индексы
-- Fulltext indexes
-- =========================================

USE WideWorldImporters;
GO

-------------------------------------------
-- Настройка полнотекстового поиска
-------------------------------------------

-- Должен быть установлен компонент "Full-Text and Semantic Extraction for Search"

-- Создаем Full-Text Catalog
-- SSMS: <DB> \ Storage \ Full Text Catalogs

-- Поддерживаемые языки
SELECT lcid, name
FROM sys.fulltext_languages;
-- если пусто, то значит компоненты полнотекстового поиска не установлены

-- есть русский
SELECT lcid, name
FROM sys.fulltext_languages
WHERE name = 'Russian';

-- язык для полнотекстового поиска по умолчанию
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'default full-text language';

SELECT lcid, name 
FROM sys.fulltext_languages
WHERE lcid = 1033;

-- Подробнее о выборе языка при создании полнотекстового индекса
-- https://learn.microsoft.com/ru-RU/sql/relational-databases/search/choose-a-language-when-creating-a-full-text-index?view=sql-server-ver15

-- Создаем полнотекстовый каталог
CREATE FULLTEXT CATALOG WWI_FT_Catalog
WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
AUTHORIZATION [dbo];
-- ON FILEGROUP
GO

-- DROP FULLTEXT CATALOG WWI_FT_Catalog

-- Будем создавать индекс для колонки StockItemName в Warehouse.StockItems
-- Посмотрим, что там есть в таблице
SELECT StockItemID, StockItemName
FROM Warehouse.StockItems;

-- Создаем полнотекстовый индекс на StockItemName
CREATE FULLTEXT INDEX ON Warehouse.StockItems(StockItemName LANGUAGE Russian)
KEY INDEX PK_Warehouse_StockItems -- первичный ключ
ON (WWI_FT_Catalog)
WITH (
  CHANGE_TRACKING = AUTO, /* AUTO, MANUAL, OFF */
  STOPLIST = SYSTEM /* SYSTEM, OFF или пользовательский stoplist */
);
GO

-- DROP FULLTEXT INDEX PK_Warehouse_StockItems

-- Посмотрим на индекс в SSMS
-- <DB> \ Storage \ Full Text Catalog \ ...

-- Обновление Full-Text Index (если CHANGE_TRACKING != AUTO)
ALTER FULLTEXT INDEX ON Warehouse.StockItems
START FULL POPULATION;
/*
FULL POPULATION
INCREMENTAL POPULATION - должна быть колонка rowversion
UPDATE POPULATION - change-tracking population, change-tracking index
*/

-------------------------------------------
-- Запросы
-------------------------------------------

-- The CONTAINS predicate provides access to phrase search, 
-- proximity search, strict search, and advanced query capability.

-- CONTAINS 
-- где встречается developer
SELECT StockItemID, StockItemName
FROM Warehouse.StockItems 
WHERE CONTAINS(StockItemName, N'developer');

-- где встречается usb или dev*
SELECT StockItemID, StockItemName
FROM Warehouse.StockItems 
WHERE CONTAINS(StockItemName, N'"usb" or "dev*"');

-- Свой "язык запросов" 
-- https://docs.microsoft.com/ru-RU/sql/relational-databases/search/query-with-full-text-search?view=sql-server-ver15#specific-types-of-searches


-- Добавляем товары на русском языке

INSERT INTO  Warehouse.StockItems(StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy, LeadTimeDays, IsChillerStock)
VALUES 
(N'Плед Karna с размерами: 240х220 см', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Конструктор LEGO City 60195 Передвижная арктическая база', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Конструктор LEGO Hidden Side 70425 Школа с привидениями Ньюбери', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Корм сухой Cat Chow "Adult" для взрослых кошек, с домашней птицей, 1,5 кг', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Конструктор LEGO NINJAGO 70677 Райский уголок', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Конструктор LEGO DC Comics Super Heroes 76122 Вторжение Глиноликого в бэт-пещеру', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Камера инспекционная Bosch "Universal Inspect"', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Корм сухой Felix Двойная вкуснятина для кошек, с птицей, 1,5 кг', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Средство для мытья посуды в посудомоечной машине Таблетки Somat Gold, 72 шт', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Набор инструментов Stayer "Standard" "Умелец", для ремонтных работ, 36 предметов', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Консервы "Pro Plan", для взрослых кошек, с индейкой, желе, 24 шт x 85 г', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Станок фрезерный Ставр СДФ-1500', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Gosh Набор хайлайтеров для стробинга Strobe''N Glow, 001 Highlight', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Набор оснастки "Dremel", 150 предметов', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'DEO-Крем для ног WooHoo Berry Natural Extracts, 75 мл', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Корм сухой Cat Chow "Special Care" для кошек с чувствительным пищеварением, 1,5 кг', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Конструктор LEGO Hidden Side 70419 Старый рыбацкий корабль', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Крем Achromin для лица со стволовыми клетками, 50 мл', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Щетка стеклоочистителя "Denso", гибридная, 50 см, 1 шт', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Корм Padovan "Pappagalli Grandmix", для крупных попугаев, 2 кг', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Пенка-скраб для умывания Markell Everyday Lux Comfort Японские водоросли, 100 мл', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Светодиодные лампы для салона X-tremeUltinon LED Philips, W5W (T10), 2 шт, 8000K. 12799 8000KX2', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(N'Корм сухой Pro Plan "Sterilised" для стерилизованных кошек и кастрированных котов, с кроликом, 400 г', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);

-- Поиск по словоформам
SELECT StockItemID, StockItemName
FROM Warehouse.StockItems 
WHERE CONTAINS (StockItemName, N'FORMSOF(INFLECTIONAL, "кошка")');
GO  

-- CONTAINSTABLE
-- RANK - релевантность
-- чем меньше значение, тем меньше релевантность
SELECT 
    StockItemID, 
    StockItemName,
    t.[KEY],
    t.[RANK]
FROM Warehouse.StockItems s
INNER JOIN CONTAINSTABLE(Warehouse.StockItems, StockItemName,  N'"black" NEAR "tape"' /*, 5*/) AS t
ON s.StockItemID = t.[KEY]
ORDER BY t.RANK DESC;
-- RANK - релевантность результата (чем больше, тем лучше)

-- FREETEXT
-- более гибкий, нечеткий поиск
-- The FREETEXT predicate provides fuzzy search and basic query capabilities.    

-- FREETEXTTABLE
SELECT 
    StockItemID, 
    StockItemName,
    t.[KEY],
    t.[RANK]
FROM Warehouse.StockItems s
INNER JOIN FREETEXTTABLE(Warehouse.StockItems, StockItemName,  N'попугай корм') AS t
ON s.StockItemID = t.[KEY]
ORDER BY t.RANK DESC;

-- DIFFERENCE
-- Ищем "Kayla", в примере специально описка "Kaula"

SELECT
 PersonID,
 FullName,
 DIFFERENCE(FullName, N'Kaula') AS FullName_Difference
FROM [Application].People
WHERE DIFFERENCE(FullName, N'Kaula') >= 3
ORDER BY DIFFERENCE(FullName, N'Kaula') DESC;
GO
