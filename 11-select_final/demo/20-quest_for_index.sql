SELECT TOP(10) [o].[OrderLineID], [o].[Description], [o].[LastEditedBy], [o].[LastEditedWhen], [o].[OrderID], [o].[PackageTypeID], [o].[PickedQuantity], [o].[PickingCompletedWhen], [o].[Quantity], [o].[StockItemID], [o].[TaxRate], [o].[UnitPrice]
FROM [Sales].[OrderLines] AS [o]
ORDER BY [o].[LastEditedWhen] DESC


SELECT [o].[OrderLineID], [o].[Description], [o].[LastEditedBy], [o].[LastEditedWhen], [o].[OrderID], [o].[PackageTypeID], [o].[PickedQuantity], [o].[PickingCompletedWhen], [o].[Quantity], [o].[StockItemID], [o].[TaxRate], [o].[UnitPrice]
FROM [Sales].[OrderLines] AS [o]
WHERE [o].[LastEditedWhen] = (
    SELECT MAX([o0].[LastEditedWhen])
    FROM [Sales].[OrderLines] AS [o0])
