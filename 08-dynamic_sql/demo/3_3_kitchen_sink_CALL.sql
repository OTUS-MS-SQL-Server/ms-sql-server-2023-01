USE [WideWorldImporters]

set statistics io, time on

exec [dbo].[OrdersSearch_DynamicSql]
  @OrderId		              = NULL,
  @CustomerID               = 1,
  @OrderDateFrom            = '20140201',
  @OrderDateTo			        = '20140301',
  @SalespersonPersonID	    = NULL

exec [dbo].[OrdersSearch_KitchenSink]
  @OrderId		              = Null,
  @CustomerID               = 1,
  @OrderDateFrom            = '20140201',
  @OrderDateTo			        = '20140301',
  @SalespersonPersonID	    = NULL
