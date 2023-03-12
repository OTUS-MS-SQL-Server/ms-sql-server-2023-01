USE WideWorldImporters; 

--в подзапросе можно выбрать только 0 или 1 запись
SELECT C.CustomerName, (SELECT TOP 1 OrderId
                FROM Sales.Orders O
                WHERE O.CustomerID = C.CustomerID
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC)
FROM Sales.Customers C
ORDER BY C.CustomerName;

--последние 2 заказа, аналог Inner join
SELECT C.CustomerName, O.*
FROM Sales.Customers C
CROSS APPLY (SELECT TOP 2 *
                FROM Sales.Orders O
                WHERE O.CustomerID = C.CustomerID
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC) AS O
ORDER BY C.CustomerName;

--последние 2 заказа, аналог Left join
SELECT C.CustomerName, O.*
FROM Sales.Customers C
OUTER APPLY (SELECT TOP 2 *
                FROM Sales.Orders O
                WHERE O.CustomerID = C.CustomerID
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC) AS O
ORDER BY C.CustomerName;


--function call
SELECT C.CustomerName, O.*
FROM Sales.Customers C
OUTER APPLY [Sales].[orders_customer](C.CustomerID) AS O
ORDER BY C.CustomerName;


--- редактирование с APPLY
--alter table Sales.Customers add LastInvoiceId int ;
--update Sales.Customers set LastInvoiceId = NULL;

select top 10 LastInvoiceId, *
FROM Sales.Customers;
 
UPDATE C
SET LastInvoiceId = LatestTransaction.InvoiceID
FROM Sales.Customers AS C
CROSS APPLY (
	SELECT TOP 1 Invoices.InvoiceId, Invoices.InvoiceDate, trans.TransactionAmount
		FROM Sales.Invoices as Invoices
			join Sales.CustomerTransactions as trans
				ON Invoices.InvoiceID = trans.InvoiceID
	WHERE Invoices.CustomerID = C.CustomerID
	ORDER BY Invoices.InvoiceDate DESC
	) AS LatestTransaction;

--alter table Sales.Customers drop column LastInvoiceId;





SELECT DATEADD(hh,DATEDIFF(hh,0,GETDATE()),0), 
		GETDATE(), 
		DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)

-- через group by и apply
SELECT CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE) AS PurchaseOrderMonth,
	COUNT(*) AS PurchaseCount
FROM Purchasing.PurchaseOrders AS P
GROUP BY CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE)
ORDER BY CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE);

--cross apply
SELECT CA.PurchaseOrderMonth,
	COUNT(*) AS PurchaseCount
FROM Purchasing.PurchaseOrders AS P
CROSS APPLY (SELECT CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE) AS PurchaseOrderMonth) AS CA
GROUP BY CA.PurchaseOrderMonth
ORDER BY CA.PurchaseOrderMonth;

-------------
create table #t
(
   ID int identity(1,1)
  ,ListOfNums varchar(50)
)
insert #t
values ('279,37,972,15,175')
      ,('17,72')
      ,('672,52,19,23')
      ,('153,798,266,52,29')
      ,('77,349,14')
select * from #t;
-- 2, 5, 3, 1
--необходимо выбрать строки, у которых в 4 позиции число меньше 50
--и отсортировать по 3 символу
select ID
      ,ListOfNums,
	  convert(int,substring(ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
		  charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,')+1)+1)+1,
		  (charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
		  charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,')+1)+1)+1)-
		  charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
		  charindex(',',ListOfNums+',,,,')+1)+1))-1))
from #t
where convert(int,substring(ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
		  charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,')+1)+1)+1,
		  (charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
		  charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,')+1)+1)+1)-
		  charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
		  charindex(',',ListOfNums+',,,,')+1)+1))-1)) < 50
order by convert(int,substring(ListOfNums+',,,,',charindex(',',ListOfNums+',,,,',
         charindex(',',ListOfNums+',,,,')+1)+1,(charindex(',',ListOfNums+',,,,',
         charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,')+1)+1)-
         charindex(',',ListOfNums+',,,,',charindex(',',ListOfNums+',,,,')+1))-1));


select ID,
	Num4,
	ListOfNums
from #t
cross apply (select WorkString=ListOfNums+',,,,') F_Str
cross apply (select p1=charindex(',',WorkString)) F_P1
cross apply (select p2=charindex(',',WorkString,p1+1)) F_P2
cross apply (select p3=charindex(',',WorkString,p2+1)) F_P3
cross apply (select p4=charindex(',',WorkString,p3+1)) F_P4      
cross apply (select Num3=convert(int,substring(WorkString,p2+1,p3-p2-1))
                   ,Num4=convert(int,substring(WorkString,p3+1,p4-p3-1))) F_Nums
where Num4<50
order by Num3;
