USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OrdersSearch_DynamicSql]
  @OrderId		           int            = NULL,
  @CustomerID            int            = NULL,
  @OrderDateFrom         DATE           = NULL,
  @OrderDateTo			     DATE           = NULL,
  @SalespersonPersonID   INT            = NULL
AS
BEGIN
  SET NOCOUNT ON;
 
  DECLARE @sql nvarchar(max),
		  @params nvarchar(max);

  SET @params = N'
      @OrderId		         int,     
	  @CustomerID            int,     
	  @OrderDateFrom         DATE,    
	  @OrderDateTo			 DATE,    
	  @SalespersonPersonID	 INT';

  SET @sql =  'SELECT OrderId, OrderDate, CustomerID, SalespersonPersonID 
	FROM Sales.Orders
	WHERE 1=1';

  IF @OrderId IS NOT NULL
	SET @sql = @sql + ' AND OrderId = @OrderId'

  IF @CustomerID IS NOT NULL
	SET @sql = @sql + ' AND CustomerID = @CustomerID';

  IF @OrderDateFrom IS NOT NULL
	SET @sql = @sql + ' AND OrderDate >= @OrderDateFrom';

  IF @OrderDateTo IS NOT NULL
	SET @sql = @sql + ' AND OrderDate <= @OrderDateTo';

  IF @SalespersonPersonID IS NOT NULL
	SET @sql = @sql + ' AND SalespersonPersonID = @SalespersonPersonID'
 
    PRINT @sql;
 
    EXEC sys.sp_executesql @sql, @params, 
       @OrderId,
       @CustomerID,
       @OrderDateFrom,
       @OrderDateTo,
       @SalespersonPersonID;
END
