/*
Msg 15281, Level 16, State 1, Procedure master..xp_cmdshell, Line 1 [Batch Start Line 0]
SQL Server blocked access to procedure 'sys.xp_cmdshell' of component 'xp_cmdshell' because this component is turned off as part of the security configuration for this server. 
A system administrator can enable the use of 'xp_cmdshell' by using sp_configure. For more information about enabling 'xp_cmdshell', search for 'xp_cmdshell' in SQL Server Books Online.
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME


exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\1\InvoiceLines1.txt" -T -w -t, -S VIC-PC\MSSQLSERVER17'



exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\1\InvoiceLines15.txt" -T -w -t"@eu&$1&" -S VIC-PC\MSSQLSERVER17'
-----------
drop table if exists [Sales].[InvoiceLines_BulkDemo]

CREATE TABLE [Sales].[InvoiceLines_BulkDemo](
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_InvoiceLines_BulkDemo] PRIMARY KEY CLUSTERED 
(
	[InvoiceLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
----



	BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines_BulkDemo]
				   FROM "D:\1\InvoiceLines15.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@eu&$1&',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );



select Count(*) from [Sales].[InvoiceLines_BulkDemo];

TRUNCATE TABLE [Sales].[InvoiceLines_BulkDemo];
