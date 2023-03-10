/* tsqllint-disable error select-star */

-- ----------------------
-- OPENJSON
-- ----------------------
-- Этот пример запустить сразу весь по [F5]
-- (предварительно проверив ниже путь к файлу 03-open_json.json)

DECLARE @json NVARCHAR(max);

SELECT @json = BulkColumn
FROM OPENROWSET
(BULK 'Z:\2022-02\11-xml_json_hw\examples\03-open_json.json', 
 SINGLE_CLOB)
AS data;

-- Проверяем, что в @json
SELECT @json AS [@json];

-- OPENJSON Явное описание структуры
SELECT *
FROM OPENJSON (@json, '$.Suppliers')
WITH (
    Id          INT,
    Supplier    NVARCHAR(100)   '$.SupplierInfo.Name',    
    Contact     NVARCHAR(MAX)   '$.Contact' AS JSON,
    City        NVARCHAR(100)   '$.CityName'
);

-- OPENJSON Без структуры

SELECT * FROM OPENJSON(@json);

SELECT * FROM OPENJSON(@json, '$.Suppliers');

-- Type:
--    0 = null
--    1 = string
--    2 = int
--    3 = bool
--    4 = array
--    5 = object