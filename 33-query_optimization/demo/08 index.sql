/*
Missing Index Details from 07 remove orders.sql - RDWN-220729-02\MSSQLServer01.WideWorldImporters (VIMPELCOM_MAIN\KNKucherova (83))
The Query Processor estimates that implementing the following index could improve the query cost by 87.5859%.
*/

/*
USE [WideWorldImporters]
GO
CREATE NONCLUSTERED INDEX IX_Invoice_InvoiceDate_inc_CustomerId_BillToCustomerId_SalespersonPersonID
ON [Sales].[Invoices] ([InvoiceDate])
INCLUDE ([CustomerID],[BillToCustomerID],[SalespersonPersonID])
GO
*/
