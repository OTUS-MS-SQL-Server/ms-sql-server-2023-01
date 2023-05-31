DROP PROCEDURE IF EXISTS Sales.GetOrderMetricsBySalesPerson;
GO
DROP PROCEDURE IF EXISTS Sales.GetInvoiceMetricsByBillToCustomerID;
GO

CREATE PROCEDURE Sales.GetOrderMetricsBySalesPerson
	@salesPersonId INT
AS
BEGIN
	SET NOCOUNT ON;
 
	SELECT
		so.OrderId,
		so.OrderDate,
		so.ExpectedDeliveryDate
	FROM Sales.Orders AS so
	WHERE so.SalespersonPersonID = @salesPersonId;
END
Go

CREATE PROCEDURE Sales.GetInvoiceMetricsByBillToCustomerID
	@BillToCustomerID INT
AS
BEGIN
	SET NOCOUNT ON;
 
	SELECT
		si.CustomerID,
		si.BillToCustomerID,
		si.InvoiceID,
		si.InvoiceDate,
		si.ConfirmedDeliveryTime,
		si.IsCreditNote
	FROM Sales.Invoices AS si
	WHERE si.BillToCustomerID = @BillToCustomerID;
END

GO
CREATE FUNCTION [Sales].[fnGetInvoiceMetricsByBillToCustomerID]
(	
	@BillToCustomerID INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		si.CustomerID,
		si.BillToCustomerID,
		si.InvoiceID,
		si.InvoiceDate,
		si.ConfirmedDeliveryTime,
		si.IsCreditNote
	FROM Sales.Invoices AS si
	WHERE si.BillToCustomerID = @BillToCustomerID
)
GO