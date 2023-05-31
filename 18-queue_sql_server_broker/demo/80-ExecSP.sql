
SELECT InvoiceId, InvoiceConfirmedForProcessing, *
FROM Sales.Invoices
WHERE InvoiceID IN ( 61210,61211,61212,61213) ;

--Send message
EXEC Sales.SendNewInvoice
	@invoiceId = 61210;

SELECT InvoiceID
FROM Sales.Invoices AS Inv
WHERE InvoiceID = 61220
FOR XML AUTO, root('RequestMessage')

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI;

--Target
EXEC Sales.GetNewInvoice;

--Initiator
EXEC Sales.ConfirmInvoice;
