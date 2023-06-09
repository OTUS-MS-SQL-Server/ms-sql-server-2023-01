SET STATISTICS io, time on;

SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	INNER LOOP JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
WHERE PayClient.CustomerID = 1;

--JOIN HINT

SELECT Inv.InvoiceID, Inv.InvoiceDate, 
	Details.Quantity, Details.UnitPrice
FROM Sales.Invoices AS Inv
	INNER JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID;

SELECT Inv.InvoiceID, Inv.InvoiceDate, 
	Details.Quantity, Details.UnitPrice
FROM Sales.Invoices AS Inv
	INNER MERGE JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID;

SELECT People.FullName, 
	Inv.InvoiceID--, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv
	INNER JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID;

SELECT People.FullName, 
	Inv.InvoiceID, Inv.InvoiceDate	
FROM Sales.Invoices AS Inv
	INNER JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID;

SELECT People.FullName, 
	Inv.InvoiceID, Inv.InvoiceDate
FROM Sales.Invoices AS Inv
	INNER LOOP JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID;

SELECT People.FullName, 
	Inv.InvoiceID, Inv.InvoiceDate
FROM Sales.Invoices AS Inv
	LEFT LOOP JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID;

SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	INNER JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
WHERE PayClient.CustomerID = 1;

SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Sales.Invoices AS Inv
	INNER MERGE JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	INNER HASH JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	INNER LOOP JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	INNER JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	INNER JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
WHERE PayClient.CustomerID = 1;


SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	INNER JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
WHERE PayClient.CustomerID = 1;

SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Warehouse.StockItems AS Item 
	JOIN Sales.InvoiceLines AS Details
		ON Item.StockItemID = Details.StockItemID
	JOIN Sales.Invoices AS Inv
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE PayClient.CustomerID = 1;

SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Warehouse.StockItems AS Item 
	JOIN Sales.InvoiceLines AS Details
		ON Item.StockItemID = Details.StockItemID
	JOIN Sales.Invoices AS Inv
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
WHERE PayClient.CustomerID = 1
OPTION (FORCE ORDER);


