/* tsqllint-disable error select-star */
/* tsqllint-disable error non-sargable */

USE WideWorldImporters;

/*1*/ SELECT OrderID, OrderDate, PickingCompletedWhen, DATEDIFF(mm, OrderDate, PickingCompletedWhen)
FROM Sales.Orders
WHERE DATEDIFF(mm, OrderDate, PickingCompletedWhen) > 0;

/*2*/ SELECT *
FROM Sales.Invoices
WHERE CustomerID != 100
ORDER BY InvoiceDate DESC;

/*3*/ SELECT ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (SELECT SupplierId
         FROM Warehouse.StockItems AS It
         WHERE It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            JOIN Sales.Orders AS ordTotal
                ON ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID;

/*4 missing index*/ 
SELECT InvoiceDate
FROM Sales.Invoices
WHERE InvoiceDate = '2013-09-03';

/*5 missing index */ 
SELECT AP.EmailAddress, SI.InvoiceDate
FROM [Sales].[Invoices] SI
  INNER JOIN [Application].[People] AP ON SI.LastEditedBy = AP.PersonID
WHERE AP.EmailAddress = 'kaylaw@wideworldimporters.com';

/*6 missing index */
SELECT cus.CustomerName,
    cit.CityName,
    cit.LatestRecordedPopulation
FROM Sales.customers cus
     JOIN Application.Cities cit            
    ON cit.CityName = cus.PostalAddressLine2;

GO 1000
