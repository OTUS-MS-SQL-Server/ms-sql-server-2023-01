/* tsqllint-disable error select-star */

-- ------------
-- OPEN XML
---------------
-- Этот пример запустить сразу весь по [F5]
-- (предварительно проверив ниже путь к файлу 02-open_xml.xml)

-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument XML;

-- Считываем XML-файл в переменную
-- !!! измените путь к XML-файлу
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'Z:\2022-02\11-xml_json_hw\examples\02-open_xml.xml', 
 SINGLE_CLOB)
AS data;

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

-- docHandle - это просто число
SELECT @docHandle AS docHandle;

SELECT *
FROM OPENXML(@docHandle, N'/Orders/Order')
WITH ( 
	[ID] INT  '@ID',
	[OrderNum] INT 'OrderNumber',
	[CustomerNum] INT 'CustomerNumber',
	[City] NVARCHAR(10) 'Address/City',
	[Address] NVARCHAR(100) 'Address',
	[OrderDate] DATE 'OrderDate');

-- можно вставить результат в таблицу
DROP TABLE IF EXISTS #Orders;

CREATE TABLE #Orders(
	[ID] INT,
	[OrderNumber] INT,
	[CustomerNumber] INT,
	[City] NVARCHAR(100),
	[OrderDate] DATE
);

INSERT INTO #Orders
SELECT *
FROM OPENXML(@docHandle, N'/Orders/Order')
WITH ( 
	[ID] INT  '@ID',
	[OrderNum] INT 'OrderNumber',
	[CustomerNum] INT 'CustomerNumber',
	[City] NVARCHAR(10) 'Address/City',
	[OrderDate] DATE 'OrderDate');

-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle;

SELECT * FROM #Orders;

DROP TABLE IF EXISTS #Orders;
GO
