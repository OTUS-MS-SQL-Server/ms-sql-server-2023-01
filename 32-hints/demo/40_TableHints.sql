SET STATISTICS io, time on;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv	
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = 401;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv WITH (INDEX ([FK_Sales_Invoices_BillToCustomerID]))
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = 401;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv	
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = 401;

SELECT PayClient.CustomerID,PayClient.CustomerName AS CustomerWhoPays, Inv.CustomerID AS CustomerWhoOrded,
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv WITH (FORCESEEK,INDEX ([FK_Sales_Invoices_BillToCustomerID]))
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE Inv.BillToCustomerID = 401;

ALTER INDEX FK_Sales_Invoices_BillToCustomerID ON Sales.Invoices DISABLE;

ALTER INDEX FK_Sales_Invoices_BillToCustomerID ON Sales.Invoices REBUILD;

Update [Application].People WITH (ROWLOCK)
SET 
	PhoneNumber = '(495) 555-0102',
	FaxNumber = '(495) 555-0103'
WHERE PersonId = 3;

BEGIN TRAN

SELECT PhoneNumber, FaxNumber
FROM [Application].People
WHERE PersonId = 3;

SELECT PhoneNumber, FaxNumber
FROM [Application].People WITH (UPDLOCK)
WHERE PersonId = 3;

Update [Application].People --WITH (ROWLOCK)
SET 
	PhoneNumber = '(495) 555-0102',
	FaxNumber = '(495) 555-0103',
	[ValidFrom] = getdate()
WHERE PersonId = 3;

Update [Application].People WITH (ROWLOCK)
SET 
	PhoneNumber = '(495) 555-0102',
	FaxNumber = '(495) 555-0103',
	[ValidFrom] = getdate()
WHERE PersonId = 3;

Update [Application].People WITH (TABLOCK)
SET 
	PhoneNumber = '(495) 555-0102',
	FaxNumber = '(495) 555-0103',
	[ValidFrom] = getdate()
WHERE PersonId = 3;

COMMIT TRAN


begin tran
SELECT PersonId, PhoneNumber, FaxNumber
FROM [Application].People WITH (READPAST)
WHERE PersonId between 1 and 5;

COMMIT TRAN