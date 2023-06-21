SET STATISTICS IO, TIME ON;

DECLARE @dt_from DATETIME, 
		@dt_to DATETIME;

SET @dt_from = DATEFROMPARTS( YEAR(DATEADD(yy, -7, GETDATE())), 01,01); 
SET @dt_to = DATEFROMPARTS( YEAR(DATEADD(yy, -7, GETDATE())), 12,31);

SELECT @dt_from,@dt_to;
/*​
DECLARE @TotalItems TABLE 
	(StockItemId INT, 
	Quantity INT);
​
DECLARE @MaxQuantityPerCustomer TABLE 
	(CustomerId INT, 
	Quantity INT);
​
INSERT INTO @TotalItems
(StockItemId, Quantity)
SELECT L.StockItemID, SUM(L.Quantity)
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
WHERE I.InvoiceDate BETWEEN @dt_from AND @dt_to
GROUP BY L.StockItemId;
​
INSERT INTO @MaxQuantityPerCustomer
(CustomerId, Quantity)
SELECT I.CustomerID, MAX(L.Quantity) AS Q
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
WHERE I.InvoiceDate BETWEEN @dt_from AND @dt_to
GROUP BY I.CustomerID;
*/​
WITH Invoices AS 
(SELECT Inv.InvoiceDate, Inv.BillToCustomerID, 
	Inv.CustomerID, Inv.SalespersonPersonID, Inv.OrderID, Details.* 
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID)
SELECT Client.CustomerName, 
	Inv.InvoiceID, 
	Inv.InvoiceDate, 
	Item.StockItemName, 
	Inv.Quantity, 
	--(SELECT T.Quantity 
	--	FROM @TotalItems AS T 
	--	WHERE T.StockItemID = Inv.StockItemID) AS TotalItems,
    SUM(Inv.Quantity) OVER (Partition BY Inv.StockItemID) AS TotalItems,
	--(SELECT C.Quantity 
	--	FROM @MaxQuantityPerCustomer AS C 
	--	WHERE C.CustomerId = Inv.CustomerID) AS MaxByClient,
	MAX(Inv.Quantity) OVER (Partition BY Inv.CustomerID) AS MaxByClient,
	PayClient.CustomerName AS BillForCustomer,
	Pack.PackageTypeName,
	People.FullName AS SalePerson,
	OrdLines.PickedQuantity
FROM Invoices AS Inv
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Inv.StockItemID
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
ORDER BY TotalItems DESC, Quantity DESC, CustomerName;

















--https://otus.ru/polls/30743/