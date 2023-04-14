
DROP SERVICE [//WWI/SB/TargetService]
GO

DROP SERVICE [//WWI/SB/InitiatorService]
GO

DROP QUEUE [dbo].[TargetQueueWWI]
GO 

DROP QUEUE [dbo].[InitiatorQueueWWI]
GO

DROP CONTRACT [//WWI/SB/Contract]
GO

DROP MESSAGE TYPE [//WWI/SB/RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/SB/ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  Sales.SendNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.GetNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.ConfirmInvoice;


ALTER TABLE Sales.Invoices 
DROP COLUMN InvoiceConfirmedForProcessing;