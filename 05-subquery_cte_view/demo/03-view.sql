DROP VIEW IF EXISTS Website.CustomerDelivery;
Go 

CREATE VIEW Website.CustomerDelivery 
AS
SELECT s.CustomerID,
       s.CustomerName,      
       s.PhoneNumber,
       s.FaxNumber,       
       s.WebsiteURL,       
       c.CityName AS CityName,
       s.DeliveryLocation AS DeliveryLocation,
       s.DeliveryRun,
       s.RunPosition
FROM Sales.Customers AS s
	LEFT OUTER JOIN [Application].Cities AS c
	ON s.DeliveryCityID = c.CityID

GO

SELECT *
FROM Website.CustomerDelivery
order by CustomerID;


--------------------------
DROP VIEW IF EXISTS Website.SalesManager;
Go 

CREATE VIEW Website.SalesManager 
AS
SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber,                
       (SELECT COUNT(*)
	   FROM Sales.Orders
	   WHERE SalespersonPersonID = s.PersonID) AS AmountOfSales
FROM Application.People AS s
WHERE s.IsSalesperson = 1;	

GO
select * 
FROM Website.SalesManager;

GO
DROP VIEW IF EXISTS Website.SalesManagerIX;
Go 

CREATE VIEW Website.SalesManagerIX 
WITH SCHEMABINDING
AS
SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber
FROM Application.People AS s
WHERE s.IsSalesperson = 1;	
GO

CREATE UNIQUE CLUSTERED INDEX IXV_WebsiteSalesManager
	ON Website.SalesManagerIX (PersonID);
GO

SELECT *
FROM Website.SalesManager
WHERE PersonID = 7;

SELECT *
FROM Website.SalesManagerIX
WHERE PersonID = 7;

GO

DROP VIEW IF EXISTS Website.SalesManagerCheck;
Go 

CREATE VIEW Website.SalesManagerCheck 
AS
(SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber, 
	   s.IsSalesperson
FROM Application.People AS s
WHERE s.IsSalesperson = 1)
WITH CHECK OPTION;

UPDATE Website.SalesManagerCheck 
SET PhoneNumber = '(415) 555-0102' --'(415) 555-0505'  
WHERE PersonID = 7;

SELECT * FROM Website.SalesManagerCheck; 

UPDATE Website.SalesManagerCheck 
SET IsSalesperson = 0
WHERE PersonID = 7;
