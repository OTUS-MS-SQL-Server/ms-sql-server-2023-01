select * from Warehouse.Colors;

DELETE FROM		Warehouse.Colors
WHERE			ColorName like '%2%';


DROP TABLE IF EXISTS Warehouse.Colors_DeleteDemo;

--JOIN and Exists
SELECT ColorId, ColorName, LastEditedBy INTO Warehouse.Colors_DeleteDemo
FROM Warehouse.Colors;

INSERT INTO Warehouse.Colors_DeleteDemo
	(ColorId, ColorName, LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID,'Dark Blue11991', 1), 
	(NEXT VALUE FOR Sequences.ColorID,'Light Blue119991', 1);

select * from Warehouse.Colors_DeleteDemo;

SELECT * FROM Warehouse.Colors_DeleteDemo
WHERE EXISTS (SELECT * 
	FROM Warehouse.Colors
	WHERE Warehouse.Colors_DeleteDemo.ColorName = Warehouse.Colors.ColorName);

DELETE FROM Warehouse.Colors_DeleteDemo
WHERE EXISTS (SELECT * 
	FROM Warehouse.Colors
	WHERE Warehouse.Colors.ColorName = Warehouse.Colors_DeleteDemo.ColorName);

DELETE FROM Demo
FROM Warehouse.Colors_DeleteDemo AS Demo
	JOIN  Warehouse.Colors AS C
		ON Demo.ColorName = C.ColorName;

--Drop table IF EXISTS Warehouse.Colors_DeleteDemo;

---удаление дублирующих строк
SELECT ColorId, ColorName, LastEditedBy INTO Warehouse.Colors_DeleteDemo
FROM Warehouse.Colors;

select * from Warehouse.Colors_DeleteDemo
order by ColorName;

insert into Warehouse.Colors_DeleteDemo
 select * from Warehouse.Colors_DeleteDemo
  where colorid between 18 and 20;

select colorid, colorname, lasteditedby, count(*)
from Warehouse.Colors_DeleteDemo
 group by colorid, colorname, lasteditedby
  having count(*) > 1;

select	row_number() over (partition by colorname order by colorname) as nomer,
		colorid, colorname, lasteditedby
from Warehouse.Colors_DeleteDemo;

---просмотр
with del AS 
(
select	row_number() over (partition by colorname order by colorname) as nomer,
		colorid, colorname, lasteditedby
from Warehouse.Colors_DeleteDemo
) select * 
	from del
	 where nomer > 1;

--- удаление
with del AS 
(
select	row_number() over (partition by colorname order by colorname) as nomer,
		colorid, colorname, lasteditedby
from Warehouse.Colors_DeleteDemo
) delete
	from del
	 where nomer > 1;

------ удаление строк по частям (батчевый метод)
--Drop table IF EXISTS Sales.Invoices_Q12016_Archive
--Drop table IF EXISTS Sales.Invoices_Q12016

select * into Sales.Invoices_Q12016
 from Sales.Invoices
  WHERE InvoiceDate >= '2016-01-01' 
		AND InvoiceDate < '2017-01-01';

 select * from Sales.Invoices_Q12016;

select * into Sales.Invoices_Q12016_Archive
 from Sales.Invoices_Q12016
  where 1 = 2;

  select * from Sales.Invoices_Q12016_Archive

DECLARE @rowcount INT,
		@batchsize INT = 1000; 

SET @rowcount = @batchsize;

--- удаление по частям
WHILE @rowcount = @batchsize
BEGIN
	DELETE top (@batchsize) FROM Sales.Invoices_Q12016
	OUTPUT
		deleted.InvoiceID
		,deleted.CustomerID
		,deleted.BillToCustomerID
		,deleted.OrderID
		,deleted.DeliveryMethodID
		,deleted.ContactPersonID
		,deleted.AccountsPersonID
		,deleted.SalespersonPersonID
		,deleted.PackedByPersonID
		,deleted.InvoiceDate
		,deleted.CustomerPurchaseOrderNumber
		,deleted.IsCreditNote
		,deleted.CreditNoteReason
		,deleted.Comments
		,deleted.DeliveryInstructions
		,deleted.InternalComments
		,deleted.TotalDryItems
		,deleted.TotalChillerItems
		,deleted.DeliveryRun
		,deleted.RunPosition
		,deleted.ReturnedDeliveryData
		,deleted.ConfirmedDeliveryTime
		,deleted.ConfirmedReceivedBy
		,deleted.LastEditedBy
		,deleted.LastEditedWhen
	  INTO Sales.Invoices_Q12016_Archive
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
		,ConfirmedDeliveryTime
		,ConfirmedReceivedBy
		,LastEditedBy
		,LastEditedWhen)
	--OUTPUT deleted.InvoiceID
	WHERE InvoiceDate >= '2016-01-01' 
		AND InvoiceDate < '2016-04-01';

	SET @rowcount = @@ROWCOUNT;
END
