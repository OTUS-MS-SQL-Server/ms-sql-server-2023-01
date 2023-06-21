SET STATISTICS IO, TIME ON;
​
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
SELECT DISTINCT L.StockItemID, SUM(L.Quantity)
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
		AND DATEDIFF(yy, I.InvoiceDate, GETDATE()) = 7
GROUP BY L.StockItemId
ORDER BY L.StockItemID;
​
INSERT INTO @MaxQuantityPerCustomer
(CustomerId, Quantity)
SELECT I.CustomerID, MAX(L.Quantity) AS Q
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
		AND DATEDIFF(yy, I.InvoiceDate, GETDATE()) = 7
GROUP BY I.CustomerID
ORDER BY Q DESC;
​
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
	(SELECT T.Quantity 
		FROM @TotalItems AS T 
		WHERE T.StockItemID = Inv.StockItemID) AS TotalItems,
	(SELECT C.Quantity 
		FROM @MaxQuantityPerCustomer AS C 
		WHERE C.CustomerId = Inv.CustomerID) AS MaxByClient,
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
WHERE DATEDIFF(yy, Inv.InvoiceDate, GETDATE()) = 7
	 AND 
	 OrdLines.PickedQuantity > 0
ORDER BY TotalItems DESC, Quantity DESC, CustomerName;

















--https://otus.ru/polls/30743/