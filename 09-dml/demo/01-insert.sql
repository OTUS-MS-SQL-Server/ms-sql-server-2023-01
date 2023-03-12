USE WideWorldImporters;

INSERT INTO Warehouse.Colors
	(ColorId, ColorName, LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID, 'Ohra1', 1);

select *
FROM Warehouse.Colors;
---------
Declare 
	@colorId INT, 
	@LastEditedBySystemUser INT,
	@SystemUserName NVARCHAR(50) = 'Data Conversion Only'
		
SET @colorId = NEXT VALUE FOR Sequences.ColorID;

SELECT @LastEditedBySystemUser = PersonID
FROM [Application].People
WHERE FullName = @SystemUserName

INSERT INTO Warehouse.Colors
	(ColorId, ColorName, LastEditedBy)
VALUES
	(@colorId, 'Ohra22', @LastEditedBySystemUser);

---------
select ColorId, ColorName, LastEditedBy into Warehouse.Color_Copy 
from Warehouse.Colors
 where 1 = 2;


select * from Warehouse.Color_Copy;

-- DROP TABLE if exists Warehouse.Color_Copy


INSERT INTO Warehouse.Colors
		(ColorId, ColorName, LastEditedBy)
	OUTPUT inserted.ColorId, inserted.ColorName, inserted.LastEditedBy 
		INTO Warehouse.Color_Copy (ColorId, ColorName, LastEditedBy)
	OUTPUT inserted.ColorId
	VALUES
		(NEXT VALUE FOR Sequences.ColorID,'Dark Blue1', 1), 
		(NEXT VALUE FOR Sequences.ColorID,'Light Blue1', 1);

SELECT @@ROWCOUNT;

SELECT *
FROM Warehouse.Color_Copy;

---------
drop table if exists Sales.Invoices_Q12016;

SELECT  top 1 * into Sales.Invoices_Q12016
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-04-01';

select * from Sales.Invoices_Q12016
ORDER BY LastEditedWhen DESC;

-- drop table Sales.Invoices_Q12016;

delete from Sales.Invoices_Q12016;


INSERT INTO Sales.Invoices_Q12016
SELECT TOP (5) 
	InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID + 1000 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,GETDATE()
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-04-01'
ORDER BY InvoiceID;
 
INSERT INTO Sales.Invoices_Q12016
	(InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,LastEditedWhen)
SELECT TOP (5) 
	InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID + 1000 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,GETDATE()
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-04-01'
ORDER BY InvoiceID;


INSERT INTO Sales.Invoices_Q12016
	(InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,LastEditedWhen)
EXEC Sales.GetNewInvoices @batchsize = 10


SELECT *
FROM Sales.Invoices_Q12016
ORDER BY invoiceID;

------------
CREATE PROCEDURE Sales.GetNewInvoices (@batchsize INT = 100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (@batchsize) 
		InvoiceID
		,CustomerID
		,BillToCustomerID
		,OrderID + 1000 
		,DeliveryMethodID
		,ContactPersonID
		,AccountsPersonID
		,SalespersonPersonID
		,PackedByPersonID
		,InvoiceDate
		,CustomerPurchaseOrderNumber
		,IsCreditNote
		,CreditNoteReason
		,Comments
		,DeliveryInstructions
		,InternalComments
		,TotalDryItems
		,TotalChillerItems
		,DeliveryRun
		,RunPosition
		,ReturnedDeliveryData
		,[ConfirmedDeliveryTime]
		,[ConfirmedReceivedBy]
		,LastEditedBy
		,GETDATE()
	FROM Sales.Invoices
	WHERE InvoiceDate >= '2016-01-01' 
		AND InvoiceDate < '2016-04-01';
END
GO
