--compute scalar
SELECT StockItemID, SUM(UnitPrice)
FROM Sales.InvoiceLines 
WHERE InvoiceID > 600
GROUP BY StockItemID;

--compute scalar
SELECT SUM(UnitPrice)
FROM Sales.InvoiceLines 
WHERE InvoiceID > 600;

--windows agg this temp db
SELECT SUM(UnitPrice) OVER ()
FROM Sales.InvoiceLines 
WHERE InvoiceID > 600;

--windows agg normal
SELECT SUM(UnitPrice) OVER (), UnitPrice, InvoiceID
FROM Sales.InvoiceLines 
WHERE InvoiceID < 600;

--concatenation-- and sorts
SET STATISTICS TIME,IO ON
SELECT     FullName, PreferredName, EmailAddress
FROM Application.People
WHERE IsSalesPerson = 1
UNION
SELECT  FullName, PreferredName, EmailAddress-- PersonID,
FROM Application.People
WHERE IsSalesPerson = 0 AND IsEmployee = 1;

--stream aggregate -- нет 
SELECT SD1.OrderId,SD1.OrderLineId
FROM Sales.OrderLines SD1
WHERE SD1.Quantity > (SELECT AVG(SD2.Quantity) 
					  FROM Sales.OrderLines SD2 
					  WHERE SD2.OrderLineId = SD1.OrderLineId);

--https://www.sqlservergeeks.com/sql-server-table-spool-operator-lazy-spool-part1/
use AdventureWorks2019;

--stream aggregate план, только на AdventureWorks, на WWI план лучше из-за колумнстора.
SELECT SD1.SalesOrderID,SD1.SalesOrderDetailID
FROM Sales.SalesOrderDetail SD1
WHERE SD1.OrderQty > (SELECT AVG(SD2.OrderQty) 
					  FROM Sales.SalesOrderDetail SD2 
					  WHERE SD2.SalesOrderID = SD1.SalesOrderID);
					  --трудности добавления аггрегаций в условие

--USE WideWorldImporters
--SELECT OrderID,OrderLineID
--FROM Sales.OrderLines ol
--Where ol.Quantity > (SELECT AVG(ol2.Quantity)
--					 FROM Sales.OrderLines ol2
--					 WHERE ol.OrderLineID=ol2.OrderLineID)


--Как можно написать без зависимости
WITH CTE AS 
(
	SELECT AVG(SD2.OrderQty)  AvgQty,
			SD2.SalesOrderID
	FROM Sales.SalesOrderDetail SD2 
	GROUP BY SD2.SalesOrderID
)
SELECT SD1.SalesOrderID,SD1.SalesOrderDetailID
FROM Sales.SalesOrderDetail SD1
LEFT JOIN CTE on CTE.SalesOrderID=SD1.SalesOrderID
WHERE SD1.OrderQty > CTE.AvgQty;

--Иногда можно получить прирост, если полностью понимаем что делаем.
SELECT SD1.SalesOrderID,SD1.SalesOrderDetailID
FROM Sales.SalesOrderDetail SD1
CROSS APPLY  (SELECT AVG(SD2.OrderQty) AvgQty
				--	MIN(SD2.OrderQty) Test--Тоже легко масштабируется
					  FROM Sales.SalesOrderDetail SD2 
					  WHERE SD2.SalesOrderID = SD1.SalesOrderID) SD3
WHERE SD1.OrderQty > SD3.AvgQty;

--https://www.red-gate.com/simple-talk/sql/learn-sql-server/operator-of-the-week-spools-eager-spool/
--Author: Fabiano Amorim
--Table Spool Eager Spool -все данные.
--The Halloween Problem

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees(ID Int IDENTITY(1,1) PRIMARY KEY, 
                       EmpName VARCHAR(30), 
                       Salary DECIMAL(18,2));

DECLARE @I INT = 0; 

WHILE @I < 1000 
BEGIN 
  INSERT INTO Employees(EmpName, Salary) 
  SELECT 'Bob', ABS(CONVERT(Numeric(18,2), (CheckSUM(NEWID()) / 500000.0)));

  SET @I = @I + 1; 
END 
CREATE NONCLUSTERED INDEX IX_Employees_SALARY ON Employees(Salary);
GO

UPDATE Employees 
SET Salary = 0 
WHERE ID = 10;

UPDATE Employees 
SET Salary = Salary * 1.1 
FROM Employees 
WHERE Salary < 2000; 

select *, Salary * 1.1 
from Employees
order by salary;

--168, 429
--665,719
UPDATE Employees 
SET Salary = Salary * 1.1 
FROM Employees WITH(INDEX=IX_Employees_SALARY) 
WHERE Salary < 2000;

--adaptive join
use AdventureWorks2019;


declare @TerritoryID int = 1;
select
	sum(soh.SubTotal)
from 
	Sales.SalesOrderHeader soh
	join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
where
	soh.TerritoryID = @TerritoryID;

drop index if exists dummy ON Sales.SalesOrderHeader;

create nonclustered columnstore index dummy on Sales.SalesOrderHeader(SalesOrderID) where SalesOrderID = -1 and SalesOrderID = -2;
go

declare @TerritoryID int = 9;
select
	sum(soh.SubTotal)
from 
	Sales.SalesOrderHeader soh
	join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
where
	soh.TerritoryID = @TerritoryID;


----!!!! не работает
--пишем lazy spool
use AdventureWorks2019;

drop index if exists dummy ON Sales.SalesOrderHeader;

select
	soh.SalesPersonID, 
	soh.TerritoryID,
	sum(soh.SubTotal)
from 
	Sales.SalesOrderHeader AS soh
		INNER JOIN Sales.SalesOrderDetail AS sod on soh.SalesOrderID = sod.SalesOrderID
		JOIN Sales.Customer AS C ON C.CustomerID = soh.CustomerID
		JOIN Person.Person AS P ON P.BusinessEntityID = soh.CustomerID  
		JOIN Sales.SalesPerson AS SP ON SP.BusinessEntityID = soh.SalesPersonID
		JOIN Sales.SalesTerritory AS ST ON ST.TerritoryId = soh.TerritoryID
WHERE P.FirstName like 'L%'
	and sod.UnitPrice > 20
	AND ST.CostLastYear > 10000
GROUP BY soh.SalesPersonID, soh.TerritoryID;

--assert
--https://sqlserverfast.com/blog/hugo/2018/01/plansplaining-part-1-unexpected-aggregation-assert/
set statistics io, time off;
SELECT p.BusinessEntityID,
       p.FirstName,
       p.MiddleName,
       p.LastName,
      (SELECT pp.PhoneNumber 
       FROM   Person.PersonPhone AS pp
       WHERE  pp.BusinessEntityID = p.BusinessEntityID) AS PhoneNum
FROM   Person.Person AS p;

SELECT p.BusinessEntityID,
       p.FirstName,
       p.MiddleName,
       p.LastName,
      (SELECT TOP 1 pp.PhoneNumber
       FROM   Person.PersonPhone AS pp
       WHERE  pp.BusinessEntityID = p.BusinessEntityID) AS PhoneNum
FROM   Person.Person AS p;
with cte as
(
	  SELECT string_agg(pp.PhoneNumber,',') PhoneNumber,
			pp.BusinessEntityID
       FROM   Person.PersonPhone AS pp
	   group by pp.BusinessEntityID
)
SELECT p.BusinessEntityID,
       p.FirstName,
       p.MiddleName,
       p.LastName,
       cte.PhoneNumber AS PhoneNum
FROM   Person.Person AS p
inner join cte on cte.BusinessEntityID=p.BusinessEntityID;


--assert
--на CONSTRAINT
--ideas https://www.red-gate.com/simple-talk/sql/learn-sql-server/showplan-operator-of-the-week-assert/

DROP TABLE IF EXISTS Genders 
GO
CREATE TABLE Genders(ID Integer, Gender CHAR(1))  
GO
ALTER TABLE Genders ADD CONSTRAINT ck_Gender_M_F CHECK(Gender IN ('M','F'))  
GO
INSERT INTO Genders (ID, Gender) VALUES(1,'X') 
GO
ALTER TABLE Genders ADD ID_Genders INT 
  
DROP TABLE IF EXISTS GenderList 
 
CREATE TABLE GenderList(ID Integer PRIMARY KEY, Gender CHAR(1))  
  
INSERT INTO GenderList(ID, Gender) VALUES(1, 'F') 
INSERT INTO GenderList(ID, Gender) VALUES(2, 'M') 
INSERT INTO GenderList(ID, Gender) VALUES(3, 'N') 
 
ALTER TABLE Genders ADD CONSTRAINT fk_GenderList FOREIGN KEY (ID_Genders) REFERENCES GenderList(ID) 

SET SHOWPLAN_TEXT ON
Go
INSERT INTO Genders(ID, ID_Genders, Gender) VALUES(1, 4, 'X') 
GO
SET SHOWPLAN_TEXT OFF
Go

--bitmap & Lazy Spool 



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
	MAX(trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) AS MaxPerCustomer
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate;


--https://sqlserverfast.com/blog/hugo/2018/05/plansplaining-part-5-bitmaps/
--SELECT     ds.StoreManager,
--           dp.BrandName,
--           SUM(fos.TotalCost)
--FROM       dbo.FactOnlineSales AS fos
--INNER JOIN dbo.DimStore AS ds
--      ON   ds.StoreKey = fos.StoreKey
--INNER JOIN dbo.DimProduct AS dp
--      ON   dp.ProductKey = fos.ProductKey
--WHERE      ds.EmployeeCount < 30
--AND        dp.ColorName = 'Black'
--GROUP BY   ds.StoreManager,
--           dp.BrandName;

-- ещё операторы https://docs.microsoft.com/ru-ru/sql/relational-databases/showplan-logical-and-physical-operators-reference?view=sql-server-ver15&viewFallbackFrom=sql-server-ver17
--https://www.red-gate.com/products/sql-development/sql-search/


--https://download.red-gate.com/installers/SQL_Search/2019-12-19/SQL_Search.exe
--Life hack от студентов alt f1 на таблице или другом объекте SSMS
