USE [WideWorldImporters]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CustomerSearch_KitchenSink]
		@CustomerID = 401,
		@CustomerName = NULL,
		@BillToCustomerID = NULL,
		@CustomerCategoryID = NULL,
		@BuyingGroupID = NULL,
		@MinAccountOpenedDate = NULL,
		@MaxAccountOpenedDate = NULL,
		@DeliveryCityID = NULL,
		@IsOnCreditHold = NULL

SELECT	'Return Value' = @return_value
-- WITH RECOMPILE

GO
DECLARE	@return_value int
EXEC	@return_value = [dbo].[CustomerSearch_KitchenSink]
		@CustomerID = NULL,
		@CustomerName = NULL,
		@BillToCustomerID = 401,
		@CustomerCategoryID = NULL,
		@BuyingGroupID = NULL,
		@MinAccountOpenedDate = NULL,
		@MaxAccountOpenedDate = NULL,
		@DeliveryCityID = NULL,
		@IsOnCreditHold = NULL
