SET STATISTICS IO, TIME ON;

DECLARE @dt_from DATETIME, 
		@dt_to DATETIME;

SET @dt_from = DATEFROMPARTS( YEAR(DATEADD(yy, -7, GETDATE())), 01,01); 
SET @dt_to = DATEFROMPARTS( YEAR(DATEADD(yy, -7, GETDATE())), 12,31);

SELECT @dt_from,@dt_to;

SELECT Client.CustomerName, 
	Inv.InvoiceID, 
	Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, 
    SUM(Details.Quantity) OVER (Partition BY Details.StockItemID) AS TotalItems,
	MAX(Details.Quantity) OVER (Partition BY Inv.CustomerID) AS MaxByClient,
	PayClient.CustomerName AS BillForCustomer,
	Pack.PackageTypeName,
	People.FullName AS SalePerson,
	OrdLines.PickedQuantity
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
	JOIN Sales.Orders AS Ord 
		ON Ord.OrderID = Inv.OrderID
	JOIN Sales.OrderLines AS OrdLines
		ON OrdLines.OrderID = Ord.OrderID
		AND OrdLines.StockItemID = Item.StockItemID
	JOIN Warehouse.PackageTypes AS Pack
		ON Pack.PackageTypeID = OrdLines.PackageTypeID
WHERE Inv.InvoiceDate BETWEEN @dt_from AND @dt_to
	 AND 
	 OrdLines.PickedQuantity > 0
ORDER BY TotalItems DESC, Details.Quantity DESC, CustomerName;

















--https://otus.ru/polls/30743/