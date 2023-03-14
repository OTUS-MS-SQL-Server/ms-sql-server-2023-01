SELECT 
	CASE IsSalesPerson
		WHEN 1 THEN 'Sales'
		WHEN 0 THEN 'Other'
		ELSE 'Unexpected'
	END as EmployeeStatus,
	FullName, 
	EmailAddress,
	IsSalesperson
FROM Application.People;

--ALTER TABLE Application.People ADD TotalSaleCount INT;-- Если не добавляли в другом занятии

--UPDATE P
--SET TotalSaleCount = I.SalesCount
--FROM [Application].People AS P
--	JOIN
--	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
--	FROM Sales.Invoices
--	GROUP BY SalespersonPersonID) AS I
--		ON P.PersonID = I.SalespersonPersonID;

--Логическая ошибка.
SELECT 
	CASE 
		WHEN IsSalesperson = 1 AND TotalSaleCount <= 7000 THEN 'Normal Sale'
		WHEN TotalSaleCount > 7000 THEN 'Good Sale'
		WHEN TotalSaleCount > 7100 THEN 'Great Sale'
		WHEN IsEmployee = 1 AND IsSalesperson = 1 THEN 'Bad Sale'
		WHEN IsEmployee = 1 AND IsSalesperson = 0 THEN 'Not Sale'
		ELSE 'Not Employee'
	END as EmployeeStatus,
	FullName, 
	EmailAddress,
	TotalSaleCount
FROM Application.People;

-----ответ------------
SELECT 
	CASE 
		WHEN IsSalesperson = 1 AND TotalSaleCount <= 7000 THEN 'Normal Sale'
		WHEN TotalSaleCount BETWEEN 7001 AND 7100 THEN 'Good Sale'
		WHEN TotalSaleCount > 7100 THEN 'Great Sale'
		WHEN IsEmployee = 1 AND IsSalesperson = 1 THEN 'Bad Sale'
		WHEN IsEmployee = 1 AND IsSalesperson = 0 THEN 'Not Sale'
		ELSE 'Not Employee'
	END as EmployeeStatus,
	FullName, 
	EmailAddress,
	TotalSaleCount
FROM Application.People;

SELECT IIF(TotalSaleCount > 7000, 'Great', 'Ok') AS State,
	FullName, 
	EmailAddress,
	TotalSaleCount
FROM Application.People
WHERE IsSalesperson = 1;


--Выборка с другой базы в файле Query in agg function


SELECT CHOOSE(4, 'Abba', 'Black sabbath', 'Cesaria Evora', 'Doors', 'Enigma');

SELECT StockItemID, StockItemName, CHOOSE(ColorId, 'Azure', 'Beige', 'Black', 'Blue', 'Charcoal')
FROM Warehouse.StockItems
WHERE ColorId IS NOT NULL;

SELECT StockItemID, StockItemName, CHOOSE(1, (select top 1 ColorName from [Warehouse].[Colors]),(select top 1 ColorName from [Warehouse].[Colors] where ColorId > 1))
FROM Warehouse.StockItems
WHERE ColorId IS NOT NULL;

DECLARE @v1 VARCHAR(12) = 'Azure',
		@v3 VARCHAR(12) = 'Black'

SELECT StockItemID, StockItemName, CHOOSE(ColorId, @v1, 'Beige', @v3, 'Blue', 'Charcoal')
FROM Warehouse.StockItems
WHERE ColorId IS NOT NULL;

select * 
from Warehouse.Colors;



