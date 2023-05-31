SELECT SalespersonPersonID, count(*) AS cnt
FROM Sales.Orders
GROUP BY SalespersonPersonID
ORDER BY cnt DESC

SELECT CustomerID, count(*) AS cnt
FROM Sales.Orders
GROUP BY CustomerID
ORDER BY cnt DESC

SELECT CustomerID, count(*) AS cnt
FROM Sales.Invoices
GROUP BY CustomerID
ORDER BY cnt DESC

SELECT BillToCustomerID, count(*) AS cnt
FROM Sales.Invoices
GROUP BY BillToCustomerID
ORDER BY cnt DESC

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

EXEC sp_recompile 'Sales.GetOrderMetricsBySalesPerson';

EXEC Sales.GetOrderMetricsBySalesPerson
	@salesPersonId = 10

EXEC Sales.GetOrderMetricsBySalesPerson
	@salesPersonId = 16

	-- CPU time = 31 ms,  elapsed time = 406 ms.
	-- CPU time = 47 ms,  elapsed time = 203 ms.

EXEC Sales.GetOrderMetricsBySalesPerson
	@salesPersonId = 8


SELECT BillToCustomerID, count(*) AS cnt
FROM Sales.Invoices
GROUP BY BillToCustomerID
ORDER BY cnt DESC

EXEC Sales.GetInvoiceMetricsByBillToCustomerID
	@BillToCustomerID = 1060

EXEC Sales.GetInvoiceMetricsByBillToCustomerID
	@BillToCustomerID = 831

EXEC Sales.GetInvoiceMetricsByBillToCustomerID
	@BillToCustomerID = 1036

EXEC Sales.GetInvoiceMetricsByBillToCustomerID
	@BillToCustomerID = 401

select *
FROM [Sales].[fnGetInvoiceMetricsByBillToCustomerID] (401)

select *
FROM [Sales].[fnGetInvoiceMetricsByBillToCustomerID] (1060)

EXEC sp_recompile @objname = 'Sales.GetInvoiceMetricsByBillToCustomerID';


