-- ISJSON

DECLARE @jsonDataWithError AS NVARCHAR(MAX) = N'
    {
        "OrderId": 5,
        "CustomerId : 6
';

SELECT ISJSON(@jsonDataWithError);
-- Будет 0, т.к. в JSON есть ошибка. 
-- Кто заметил какая?

-- ---------------------------------
DROP TABLE IF EXISTS #BooksJson;

-- Использование ISJSON в ограничении CHECK
CREATE TABLE #BooksJson(
    BookId INT PRIMARY KEY,
    BookDoc NVARCHAR(MAX) NOT NULL CHECK (ISJSON(BookDoc) = 1)
);

INSERT INTO #BooksJson VALUES (1, '
    {
        "category": "ITPro",
        "title": "Programming SQL Server",
        "author": "Lenni Lobel",
        "price": {
            "amount": 49.99,
            "currency": "USD"
        },
        "purchaseSites": [
            "amazon.com",
            "booksonline.com"
        ]
    }
');

INSERT INTO #BooksJson VALUES (2, '
    {
        "category": "Developer",
        "title": "Developing ADO .NET",
        "author": "Andrew Brust",
        "price": {
            "amount": 39.93,
            "currency": "USD"
        },
        "purchaseSites": [
            "booksonline.com"
        ]
    }
');

INSERT INTO #BooksJson VALUES (3, '
    {
        "category": "ITPro",
        "title": "Windows Cluster Server",
        "author": "Stephen Forte",
        "price": {
            "amount": 59.99,
            "currency": "CAD"
        },
        "purchaseSites": [
            "amazon.com"
        ]
    }
');

SELECT BookId, BookDoc FROM #BooksJson;

-- простой JSON_VALUE (аналог xml value())
SELECT 
    BookId, 
    JSON_VALUE(BookDoc, '$.category') AS BookCategory,
    BookDoc
FROM #BooksJson;

-- не существующий путь
SELECT 
    BookId, 
    JSON_VALUE(BookDoc, '$.not_exist_property') AS BookCategory,
    BookDoc
FROM #BooksJson;

-- не существующий путь, strict
SELECT 
    BookId, 
    JSON_VALUE(BookDoc, 'strict$.not_exist_property') AS BookCategory,
    BookDoc
FROM #BooksJson;


-- JSON_QUERY (аналогичен xml query) - возвращает JSON
SELECT
    BookId,
    JSON_VALUE(BookDoc, '$.category') AS Category,
    JSON_VALUE(BookDoc, '$.title') AS Title,
    JSON_VALUE(BookDoc, '$.price.amount') AS PriceAmount,
    JSON_VALUE(BookDoc, '$.price.currency') AS PriceCurrency,
    JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites,
    JSON_VALUE(BookDoc, '$.purchaseSites[0]') AS FirstPurchaseSite
 FROM #BooksJson;

-- Хотим найти книги на 'amazon.com'
-- Выводим книгу и на каких сайтах продается
SELECT
    BookId,
    JSON_VALUE(BookDoc, '$.title') AS Title,
    JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites,
    sites.[key],
    sites.value
FROM #BooksJson
CROSS APPLY OPENJSON(BookDoc, '$.purchaseSites') sites;

-- можно отфильтровать
SELECT
    BookId,
    JSON_VALUE(BookDoc, '$.title') AS Title,
    JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites,
    sites.[key],
    sites.value
FROM #BooksJson
CROSS APPLY OPENJSON(BookDoc, '$.purchaseSites') sites
WHERE sites.value = 'amazon.com';

DROP TABLE #BooksJson;

-- -----------------
-- JSON MODIFY
-- -----------------

USE WideWorldImporters;
-- modify в select
SELECT 
    CustomFields,
    JSON_VALUE(CustomFields, '$.Tags[1]'),
    JSON_MODIFY(CustomFields, '$.Tags[1]', 'Super Sound') /* вернет измененнное значение */
FROM Warehouse.StockItems
WHERE StockItemID = 63;
GO

-- обновляем данные в таблице
UPDATE Warehouse.StockItems
SET CustomFields = JSON_MODIFY(CustomFields, '$.Tags[1]', 'Super Sound')
WHERE StockItemID = 63;
GO

-- смотрим результат
SELECT 
    CustomFields,
    JSON_VALUE(CustomFields, '$.Tags[1]')
FROM Warehouse.StockItems
WHERE StockItemID = 63;
GO

















/* tsqllint-disable error select-star */

-- --------------------------------
-- PIVOT, OPENJSON()
-- --------------------------------

SELECT TOP 5 * FROM Application.People

-- Свойства из JSON в столбцы
-- JSON в колонке CustomFields в таблице Application.People
;WITH peoples AS 
(
    SELECT 
        PersonID,
        FullName,
        js.[Key] AS JsonKey,
        js.Value AS JsonValue,
        CustomFields
    FROM Application.People
    OUTER APPLY OPENJSON(CustomFields) js
)
SELECT
    PersonID,
    FullName,
    OtherLanguages,
    HireDate,
    Title,
    PrimarySalesTerritory,
    CommissionRate
FROM peoples
PIVOT
(
    MAX(JsonValue)
    FOR JsonKey IN (OtherLanguages, HireDate, Title, PrimarySalesTerritory, CommissionRate)
) pvt ;

/* tsqllint-enable error select-star */