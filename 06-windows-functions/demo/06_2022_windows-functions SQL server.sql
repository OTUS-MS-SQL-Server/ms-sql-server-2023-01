DROP TABLE IF EXISTS sales;

Create table sales 
(sales_id INT PRIMARY KEY, sales_dt DATETIME2 DEFAULT GETUTCDATE(),  customer_id INT, item_id INT, cnt INT, price_per_item DECIMAL(19,4));

INSERT INTO sales
(sales_id, sales_dt, customer_id, item_id, cnt, price_per_item)
VALUES
(1, '2020-01-10T10:00:00', 100, 200, 2, 30.15),
(2, '2020-01-11T11:00:00', 100, 311, 1, 5.00),
(3, '2020-01-12T14:00:00', 100, 400, 1, 50.00),
(5, '2020-01-13T10:00:00', 150, 311, 1, 5.00),
(7, '2020-01-14T10:00:00', 150, 200, 2, 30.15);

SELECT * 
FROM sales;

SELECT sales_id, customer_id, cnt, price_per_item, ROW_NUMBER() OVER (ORDER BY customer_id, sales_id) AS rn_customer
FROM sales
ORDER BY customer_id, sales_id;

SELECT sales_id, customer_id, cnt, price_per_item, ROW_NUMBER() OVER (ORDER BY price_per_item) AS rn_price
FROM sales
ORDER BY customer_id, sales_id;

SELECT sales_id, customer_id, cnt, price_per_item, ROW_NUMBER() OVER (ORDER BY price_per_item, sales_id) AS rn_price
FROM sales
ORDER BY customer_id, sales_id;

SELECT sales_id, customer_id, cnt, price_per_item, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id, sales_id) AS rn_customer_partitions
FROM sales
ORDER BY customer_id, sales_id;

----–јЌ∆»–”ёў»≈ ‘”Ќ ÷»»----------

SELECT UnitPrice, SupplierID, StockItemID, StockItemName,
	ROW_NUMBER() OVER (ORDER BY UnitPrice) AS rn,
	RANK() OVER (ORDER BY UnitPrice) AS rnk,
	DENSE_RANK() OVER (ORDER BY UnitPrice) AS dense_rnk
FROM Warehouse.StockItems
WHERE SupplierID = 7
ORDER By UnitPrice;


SELECT UnitPrice, SupplierID, StockItemID, StockItemName, ColorId,
	ROW_NUMBER() OVER (ORDER BY UnitPrice) AS Rn,
	RANK() OVER (ORDER BY UnitPrice) AS Rnk,
	DENSE_RANK() OVER (PARTITION BY SupplierId 
	ORDER BY UnitPrice) AS DenseRnk,
	NTILE(4) OVER (PARTITION BY SupplierId ORDER BY UnitPrice) AS GroupNumber
FROM Warehouse.StockItems
WHERE SupplierID in (5, 7)
ORDER By SupplierID, UnitPrice;

SELECT * 
  , NTILE(2) OVER (ORDER BY price_per_item) AS GroupNumber
  , NTILE(2) OVER (ORDER BY customer_id) AS GroupNumber2
FROM sales
ORDER BY GroupNumber2;


SELECT * 
  , NTILE(2) OVER (ORDER BY price_per_item) AS GroupNumber
  , NTILE(2) OVER (ORDER BY customer_id) AS GroupNumber2
FROM sales
WHERE NTILE(2) OVER (ORDER BY customer_id) = 1
ORDER BY GroupNumber2;

-------—ложные запросы с ROW_NUMBER 

SELECT *
FROM 
	(
	SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
		ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) AS CustomerTransRank
	FROM Sales.Invoices as Invoices
		JOIN Sales.CustomerTransactions as trans
			ON Invoices.InvoiceID = trans.InvoiceID
	) AS tbl
WHERE CustomerTransRank <= 3
order by CustomerID, TransactionAmount desc;

select top(1) *
from Sales.Invoices
order by row_number() OVER (partition by Invoices.CustomerID order by Invoices.InvoiceDate desc);

select row_number() OVER (partition by Invoices.CustomerID order by Invoices.InvoiceDate desc) AS RN, *
from Sales.Invoices
order by Invoices.CustomerID, RN;

select top(1) with ties *
from Sales.Invoices
order by row_number() OVER (partition by Invoices.CustomerID order by Invoices.InvoiceDate desc);

DECLARE @page INT = 2,
	@pageSize INT = 20;

WITH InvoiceLinePage AS
(
	SELECT I.InvoiceID, 
		I.InvoiceDate, 
		I.SalespersonPersonID, 
		L.Quantity, 
		L.UnitPrice,
		ROW_NUMBER() OVER (Order by InvoiceLineID) AS Row,
		COUNT(*) OVER () AS total_rows
	FROM Sales.Invoices AS I
		JOIN Sales.InvoiceLines AS L 
			ON I.InvoiceID = L.InvoiceID
)
SELECT *, total_rows/@pageSize
FROM InvoiceLinePage
WHERE Row Between (@page-1)*@pageSize + 1 
	AND @page*@pageSize;


-----------‘”Ќ ÷»» —ћ≈ў≈Ќ»я--------------
SELECT 
  sales_id, 
  customer_id, 
  cnt, 
  price_per_item, 
  ROW_NUMBER() OVER (ORDER BY customer_id, sales_id) AS rn,
  LAG(sales_id) OVER (ORDER BY customer_id, sales_id) AS lag_sales_id,
  LEAD(sales_id) OVER (ORDER BY customer_id, sales_id) AS lead_sales_id
FROM sales
ORDER BY customer_id, sales_id;


SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	LAG(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as prev,
	LEAD(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as Follow ,
	MAX(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId) AS max_amount,
	ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) AS func_order,
	ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) AS other_order
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
--and Invoices.CustomerID = 958
ORDER BY Invoices.CustomerID ,Invoices.InvoiceId, Invoices.InvoiceDate;

SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID,Invoices.BillToCustomerID, trans.TransactionAmount,
	LAG(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as prev,
	LEAD(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as Follow ,
	MAX(trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) AS max_amount,
	ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerID 
ORDER BY trans.TransactionAmount DESC
) AS other_order
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01' 
AND trans.TransactionAmount < 1000
and Invoices.CustomerID in (958, 884)
ORDER BY trans.TransactionAmount DESC;


SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID,Invoices.BillToCustomerID, trans.TransactionAmount,
	LAG(trans.TransactionAmount,1,0) OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) as prev,
	LEAD(trans.TransactionAmount,3,0) OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) as Follow ,
	MAX(trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) AS max_amount,
	ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerID 
ORDER BY trans.TransactionAmount DESC
) AS other_order
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01' 
AND trans.TransactionAmount < 1000
and Invoices.CustomerID in (958, 884)
ORDER BY Invoices.CustomerID, trans.TransactionAmount DESC;


SELECT SupplierID, StockItemID, StockItemName,UnitPrice,
	LAG(UnitPrice) OVER (ORDER BY UnitPrice) AS lagv,
	LEAD(UnitPrice) OVER (ORDER BY UnitPrice) AS leadv,
	FIRST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice) AS f,
	LAST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS l,
	LAST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice) AS l_f,
	LAST_VALUE(UnitPrice) OVER (ORDER BY 1/0) AS l2--,
	--LAST_VALUE(UnitPrice) OVER () AS l_v_nosorting --не работает
FROM Warehouse.StockItems
WHERE SupplierID = 7
ORDER By UnitPrice;



------------ј√–≈√ј“Ќџ≈ ‘”Ќ ÷»»-------------

--заказы и оплаты по заказам
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate;

set statistics io, time on;

--заказы и оплаты по заказам с максимальной суммой за год
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	(SELECT MAX(inr.TransactionAmount)
	FROM Sales.CustomerTransactions as inr
		join Sales.Invoices as InvoicesInner ON 
			InvoicesInner.InvoiceID = inr.InvoiceID
	WHERE inr.CustomerID = trans.CustomerId
		AND InvoicesInner.InvoiceDate < '2014-01-01'
		) AS MaxPerCustomer
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate;

--заказы и оплаты по заказам с максимальной суммой за год
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	MAX(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId) AS MaxPerCustomer
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate;

--заказы и оплаты по заказам с максимальной суммой за год
--с сортировкой по сумме
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	MAX(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId) AS MaxPerCustomer,
	MAX(trans.TransactionAmount) OVER () AS MaxTotal,
	ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId 
						ORDER BY trans.TransactionAmount DESC, Invoices.InvoiceId
						) AS RowNumberByPaymentAmount
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
and Invoices.CustomerID in (858, 958)
ORDER BY Invoices.CustomerId ,Invoices.InvoiceId, Invoices.InvoiceDate;

SELECT Invoices.InvoiceId, Invoices.InvoiceDate, 
	Invoices.CustomerID, trans.TransactionAmount,
	MAX(trans.TransactionAmount) MaxPayment
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
and Invoices.CustomerID = 958
GROUP BY Invoices.InvoiceId, Invoices.InvoiceDate, 
	Invoices.CustomerID, trans.TransactionAmount
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate;

--заказы и оплаты по заказам с максимальной суммой за год
--с сортировкой по сумме
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.CustomerId, trans.TransactionAmount,
	MAX(trans.TransactionAmount) OVER (ORDER BY Invoices.InvoiceID),
	ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) AS rn
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
and Invoices.CustomerID = 958
ORDER BY Invoices.CustomerID, trans.TransactionAmount ASC;

SELECT SupplierID, ColorId, StockItemID, StockItemName,
	UnitPrice,
	SUM(UnitPrice) OVER() AS Total,
	SUM(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningTotal,
	SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningTotalSort,
	AVG(UnitPrice) OVER() AS Total,
	AVG(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningTotal,
	AVG(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningTotalSort,
	COUNT(UnitPrice) OVER() AS Total,
	COUNT(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningTotal,
	COUNT(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningTotalSort
FROM Warehouse.StockItems
WHERE SupplierID in (5, 7)
ORDER By UnitPrice, StockItemID;


-----------------ќконные функции RANGE и ROW -------------------

INSERT INTO sales
(sales_id, sales_dt, customer_id, item_id, cnt, price_per_item)
VALUES
(4, '2020-01-12T20:00:00', 100, 311, 5, 5.00),
(6, '2020-01-13T11:00:00', 100, 315, 1, 17.00),
(8, '2020-01-14T15:00:00', 100, 380, 1, 8.00),
(9, '2020-01-14T18:00:00', 170, 380, 3, 8.00),
(10, '2020-01-15T09:30:00', 100, 311, 1, 5.00),
(11, '2020-01-15T12:45:00', 150, 311, 5, 5.00),
(12, '2020-01-15T21:30:00', 170, 200, 1, 30.15);


SELECT sales_id, customer_id, cnt, 
SUM(cnt) OVER (ORDER BY customer_id, sales_id) AS cum_uniq,
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS UNBOUNDED PRECEDING) AS current_and_all_before,
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS current_and_all_before2
FROM sales
ORDER BY customer_id, sales_id;

SELECT sales_id, customer_id, cnt, 
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS current_and_all_frame
--как сделать тоже самое только без ROWS? 
FROM sales
ORDER BY customer_id, sales_id;







SELECT sales_id, customer_id, cnt, 
SUM(cnt) OVER (ORDER BY customer_id, sales_id) AS cum_uniq,
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS current_and_all_before,
SUM(cnt) OVER (ORDER BY customer_id DESC, sales_id DESC) AS current_and_all_before2
FROM sales
ORDER BY cnt;





SELECT sales_id, customer_id, cnt, 
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS before_and_current,
cnt,
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS current_and_1_next,
cnt,
SUM(cnt) OVER (ORDER BY customer_id, sales_id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS before2_and_2_next
FROM sales
ORDER BY customer_id, sales_id;


SELECT sales_id, customer_id, cnt, 
SUM(cnt) OVER (ORDER BY customer_id) AS cum_uniq,
cnt,
SUM(cnt) OVER (ORDER BY customer_id ROWS UNBOUNDED PRECEDING) AS current_and_all_before,
customer_id,
cnt,
SUM(cnt) OVER (ORDER BY customer_id RANGE UNBOUNDED PRECEDING) AS current_and_all_before2
FROM sales
ORDER BY customer_id, sales_id;

SELECT sales_id, customer_id, price_per_item, cnt, 
SUM(cnt) OVER (ORDER BY customer_id DESC, price_per_item DESC) AS cum_uniq,
cnt,
SUM(cnt) OVER (ORDER BY customer_id, price_per_item ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS current_and_all_before,
customer_id,
cnt,
SUM(cnt) OVER (ORDER BY customer_id, price_per_item RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS current_and_all_before2
FROM sales
ORDER BY 2, price_per_item, sales_id desc;

-------‘”Ќ ÷»» –ј—ѕ–≈ƒЋ≈Ќ»я -----------------

SELECT UnitPrice, SupplierID, StockItemID, StockItemName, ColorId,
	ROW_NUMBER() OVER (ORDER BY UnitPrice) AS Rn,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ColorId) OVER (PARTITION BY SupplierId) AS PC,
	CUME_DIST() OVER (ORDER BY UnitPrice)
FROM Warehouse.StockItems
WHERE SupplierID in (5, 7)
ORDER By SupplierID, UnitPrice;

SELECT SupplierID, PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY SupplierID) OVER() AS median
FROM Warehouse.StockItems
GROUP BY SupplierID;

SELECT 	
	OrderId, OrderDate, 
	NEXT VALUE FOR Sequences.OrderID OVER(ORDER BY OrderDate, OrderId DESC) AS SeqValue
FROM (select top 10 * 
	FROM Sales.Orders) AS ord;


