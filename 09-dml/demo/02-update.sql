select PhoneNumber,FaxNumber,* 
from [Application].People
WHERE PersonId = 3;

--simple
SELECT 
	PhoneNumber = '(495) 555-1111',
	FaxNumber = '(495) 555-3333', PhoneNumber, FaxNumber, *
from  [Application].People
WHERE PersonId = 3;


Update [Application].People
SET 
	PhoneNumber = '(495) 555-1111',
	FaxNumber = '(495) 555-3333'
WHERE PersonId = 3;

Update [Application].People
SET 
	PhoneNumber = '(415) 555-0102',
	FaxNumber = '(415) 555-0103'
OUTPUT inserted.PhoneNumber as new_phon, inserted.FaxNumber as new_fax, deleted.PhoneNumber as old_phon, deleted.FaxNumber old_fax
WHERE PersonId = 3;

/*
Update [Application].People
SET 
	PhoneNumber = '(415) 555-0102',
	FaxNumber = '(415) 555-0103'
OUTPUT inserted.*, deleted.*
WHERE PersonId = 3;
*/
--PhoneNumber	FaxNumber


-----------
ALTER TABLE [Application].People ADD FirstSale DATETIME;
ALTER TABLE [Application].People ADD FirstSale2 DATETIME;

/*
ALTER TABLE [Application].People Drop column FirstSale; 
ALTER TABLE [Application].People Drop column FirstSale2;
*/
select firstSale, FullName From [Application].People;

UPDATE [Application].People
SET FirstSale = (SELECT MIN(InvoiceDate)
	FROM Sales.Invoices AS I
	WHERE [Application].People.PersonID = I.SalespersonPersonID);
	
SELECT FirstSale,FirstSale2,* 
FROM [Application].People
WHERE FirstSale2 IS NOT NULL;

----если в селекте несколько подходящих записей, какая будет выбрана ?
UPDATE P
SET FirstSale2 = I.MinInvoiceDate
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, MIN(InvoiceDate) AS MinInvoiceDate
	FROM Sales.Invoices
	GROUP BY SalespersonPersonID
	) AS I
		ON P.PersonID = I.SalespersonPersonID;

Select P.FirstSale2,  I.MinInvoiceDate
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, MIN(InvoiceDate) AS MinInvoiceDate
	FROM Sales.Invoices
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

--
UPDATE [Application].People
SET FirstSale = NULL,
	FirstSale2 = NULL;

ALTER TABLE [Application].People DROP COLUMN FirstSale;
ALTER TABLE [Application].People DROP COLUMN FirstSale2;

------------
ALTER TABLE [Application].People ADD TotalSaleCount INT NOT NULL Default 0;

SELECT p.TotalSaleCount, p.TotalSaleCount + I.SalesCount, I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate < '20140101'
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

UPDATE P
SET TotalSaleCount = TotalSaleCount + I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate < '20140101'
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;
--


UPDATE P
SET TotalSaleCount += I.SalesCount 
OUTPUT inserted.PersonId, inserted.FullName,inserted.TotalSaleCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

--
UPDATE [Application].People
SET TotalSaleCount = 0;
 
UPDATE TOP (5) P   --- изменение 5 записей
SET TotalSaleCount += I.SalesCount 
OUTPUT inserted.PersonId, inserted.FullName,inserted.TotalSaleCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20150401'
		AND InvoiceDate < '20150801' 
	GROUP BY SalespersonPersonID, CustomerId) AS I
		ON P.PersonID = I.SalespersonPersonID;


ALTER TABLE [Application].[People] DROP CONSTRAINT [DF__People__TotalSal__61BB7BD9];
ALTER TABLE [Application].People DROP COLUMN TotalSaleCount;


----------
ALTER TABLE Sales.Customers ADD CustomerCategoryName NVARCHAR(50);

WITH Cust AS 
(
	SELECT 
		TOP (50) 
	   s.CustomerID,
       s.CustomerName,
       sc.CustomerCategoryName AS sourceCustomerCategoryName,
	   s.CustomerCategoryName
	FROM Sales.Customers AS s
		LEFT JOIN Sales.CustomerCategories AS sc
		ON s.CustomerCategoryID = sc.CustomerCategoryID
	ORDER BY CustomerID
)
UPDATE Cust
SET CustomerCategoryName = sourceCustomerCategoryName;

SELECT CustomerCategoryName,*
FROM Sales.Customers;

ALTER TABLE Sales.Customers DROP COLUMN CustomerCategoryName;
