Use AdventureWorks2017;

SELECT ProductId, Name,DaysToManufacture, StandardCost 
		FROM Production.Product;

SELECT ProductId, Name, DaysToManufacture, StandardCost,
	AVG(StandardCost) OVER (PARTITION BY DaysToManufacture)
FROM Production.Product
ORDER BY DaysToManufacture;

SELECT DaysToManufacture, AVG(StandardCost) 
		FROM Production.Product
	group by DaysToManufacture;

SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, [0], [1], [2], [3], [4]
FROM (SELECT DaysToManufacture, StandardCost 
		FROM Production.Product) AS SourceTable
PIVOT ( AVG(StandardCost) FOR DaysToManufacture
	IN ([0], [1], [2], [3], [4])
) AS PivotTable;


---
with PivotData AS
(SELECT DaysToManufacture, StandardCost 
		FROM Production.Product
)
SELECT 'AverageCost' AS Cost_Sorted_By_Production_Days, [0], [1], [2], [3], [4]
FROM PivotData
PIVOT ( AVG(StandardCost) FOR DaysToManufacture
	IN ([0], [1], [2], [3], [4])
) AS PivotTable;

-----------
use WideWorldImporters;

-- по годам
SELECT * FROM 
	(
	SELECT YEAR(ord.OrderDate) as SalesYear,
			L.UnitPrice*L.Quantity as TotalSales
	 FROM Sales.Orders AS ord 
		 JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
	) AS Sales
PIVOT (sum(TotalSales)
FOR SalesYear IN ([2013],[2014],[2015],[2016]))
as PVT_my;

--https://www.codeproject.com/Tips/500811/Simple-Way-To-Use-Pivot-In-SQL-Query
-- по месяцам
SELECT *
FROM (
    SELECT 
        year(I.InvoiceDate) as [year],left(datename(month,I.InvoiceDate),3)as [month], 
         Trans.TransactionAmount as Amount 
    FROM Sales.Invoices AS I
		JOIN Sales.CustomerTransactions AS Trans
			ON I.InvoiceId = Trans.InvoiceID
) as s
PIVOT
(
    SUM(Amount)
    FOR [month] IN (Янв, Фев, Мар, Апр, Май, Июн, Июл, Авг, Сен, Окт, Ноя, Дек)
)AS pvt
order by [year];

--
Use AdventureWorks2017;

SELECT SalesYear, 
       ISNULL([1], 0) AS Jan, 
       ISNULL([2], 0) AS Feb, 
       ISNULL([3], 0) AS Mar, 
       ISNULL([4], 0) AS Apr, 
       ISNULL([5], 0) AS May, 
       ISNULL([6], 0) AS Jun, 
       ISNULL([7], 0) AS Jul, 
       ISNULL([8], 0) AS Aug, 
       ISNULL([9], 0) AS Sep, 
       ISNULL([10], 0) AS Oct, 
       ISNULL([11], 0) AS Nov, 
       ISNULL([12], 0) AS Dec, 
       (ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0) + ISNULL([4], 0) + ISNULL([5], 0) + ISNULL([6], 0) + ISNULL([7], 0) + ISNULL([8], 0) + ISNULL([9], 0) + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0)) SalesYTD
FROM
(   SELECT YEAR(SOH.OrderDate) AS SalesYear, 
           DATEPART(MONTH, SOH.OrderDate) Months,
          SOH.SubTotal AS TotalSales
    FROM sales.SalesOrderHeader SOH
         JOIN sales.SalesOrderDetail SOD ON SOH.SalesOrderId = SOD.SalesOrderId
 ) AS Data 
 PIVOT (SUM(TotalSales) 
 FOR Months IN([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) AS pvt 
   order by SalesYear;



--по кварталам
use WideWorldImporters;

SELECT SalesYear, 
       ISNULL([Q1], 0) AS Q1, 
       ISNULL([Q2], 0) AS Q2, 
       ISNULL([Q3], 0) AS Q3, 
       ISNULL([Q4], 0) AS Q4, 
       (ISNULL([Q1], 0) + ISNULL([Q2], 0) + ISNULL([Q3], 0) + ISNULL([Q4], 0)) SalesYTD
FROM
(
    SELECT YEAR(OH.OrderDate) AS SalesYear, 
           CAST('Q'+CAST(DATEPART(QUARTER, OH.OrderDate) AS VARCHAR(1)) AS VARCHAR(2)) AS Quarters, 
           SUM(L.UnitPrice*L.Quantity) AS TotalSales
    FROM Sales.Orders OH
         JOIN Sales.OrderLines L ON OH.OrderId = L.OrderId
	GROUP BY YEAR(OH.OrderDate), 
           CAST('Q'+CAST(DATEPART(QUARTER, OH.OrderDate) AS VARCHAR(1)) AS VARCHAR(2))
 ) AS Data 
 PIVOT(SUM(TotalSales) FOR Quarters 
	IN([Q1], 
       [Q2], 
       [Q3], 
       [Q4])) 
	   AS pvt
ORDER BY SalesYear;

--- error
SELECT * 
	FROM (
		SELECT YEAR(ord.OrderDate) as SalesYear,
				L.UnitPrice*L.Quantity as TotalSales
		 FROM Sales.Orders AS ord 
			 JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
		) AS Sales
		PIVOT (SUM(TotalSales), AVG(TotalSales)
		FOR SalesYear IN ([2013],[2014],[2015],[2016]))
		as PVT;


--- unpivot
SELECT * 
	FROM (
		SELECT YEAR(ord.OrderDate) as SalesYear,
				L.UnitPrice*L.Quantity as TotalSales
		 FROM Sales.Orders AS ord 
			 JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
		) AS Sales
		PIVOT (SUM(TotalSales)
		FOR SalesYear IN ([2013],[2014],[2015],[2016]))
		as PVT;

SELECT SalesYear,TotalSales
FROM (
	SELECT * 
	FROM (
		SELECT YEAR(ord.OrderDate) as SalesYear,
				L.UnitPrice*L.Quantity as TotalSales
		 FROM Sales.Orders AS ord 
			 JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
		) AS Sales
		PIVOT (SUM(TotalSales)
		FOR SalesYear IN ([2013],[2014],[2015],[2016]))
		as PVT
) T UNPIVOT(TotalSales FOR SalesYear IN([2013],
                                        [2014],
										[2015],
										[2016])) AS upvt;

---
SELECT 
			PersonID,
			FullName,
			PreferredName,
			LogonName
		FROM Application.People;

SELECT *
FROM (
		SELECT 
			PersonID,
			FullName,
			PreferredName,
			LogonName
		FROM Application.People
	) AS People
UNPIVOT (PersonName FOR Name IN (FullName, PreferredName, LogonName)) AS unpt;
