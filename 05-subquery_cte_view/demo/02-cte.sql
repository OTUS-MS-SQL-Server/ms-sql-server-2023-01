-- Обычный подзапрос
SELECT P.PersonID, P.FullName, I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID
go
-- CTE 		
;WITH InvoicesCTE (SalespersonPersonID, SalesCount) AS 
(
	SELECT SalespersonPersonID, Count(InvoiceId) 
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID
)
SELECT P.PersonID, P.FullName, I.SalesCount
FROM [Application].People AS P
	JOIN InvoicesCTE AS I
		ON P.PersonID = I.SalespersonPersonID;

-- Несколько CTE (и без названия колонок)
WITH InvoicesCTE AS 
(
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID
),
InvoicesLinesCTE AS 
(
	SELECT Invoices.SalespersonPersonID, SUM(Lines.Quantity) AS TotalQuantity, 
			SUM(Lines.Quantity*Lines.UnitPrice) AS TotalSumm
	FROM Sales.Invoices	
		JOIN Sales.InvoiceLines AS Lines
			ON Invoices.InvoiceID = Lines.InvoiceID
	GROUP BY Invoices.SalespersonPersonID
)
SELECT P.PersonID, P.FullName, I.SalesCount, L.TotalQuantity, L.TotalSumm
FROM [Application].People AS P
	JOIN InvoicesCTE AS I
		ON P.PersonID = I.SalespersonPersonID
	JOIN InvoicesLinesCTE AS L
		ON P.PersonID = L.SalespersonPersonID
ORDER BY L.TotalSumm DESC, I.SalesCount DESC;

---
WITH InvoicesCTE AS 
(
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID
),
InvoicesLinesCTE AS 
(
	SELECT Invoices.SalespersonPersonID, SUM(Lines.Quantity) AS TotalQuantity, SUM(Lines.Quantity*Lines.UnitPrice) AS TotalSumm
	FROM Sales.Invoices	
		JOIN Sales.InvoiceLines AS Lines
			ON Invoices.InvoiceID = Lines.InvoiceID
		JOIN InvoicesCTE AS sls
			ON sls.SalespersonPersonID = Invoices.SalespersonPersonID
	GROUP BY Invoices.SalespersonPersonID
)
SELECT P.PersonID, P.FullName, I.SalesCount, L.TotalQuantity, L.TotalSumm
FROM [Application].People AS P
	JOIN InvoicesCTE AS I
		ON P.PersonID = I.SalespersonPersonID
	JOIN InvoicesLinesCTE AS L
		ON P.PersonID = L.SalespersonPersonID
ORDER BY L.TotalSumm DESC, I.SalesCount DESC;

--delete CTE
DROP TABLE IF EXISTS Sales.Invoices_DeleteDemo;

select top 300 * into Sales.Invoices_DeleteDemo from Sales.Invoices;
delete top (10) from  Sales.Invoices_DeleteDemo;

SELECT TOP 100 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID;

WITH OrdDelete AS
(	
	SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID
)
DELETE FROM OrdDelete;

SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID;


--- рекурсивные CTE
Declare @maxId INT = 200;

WITH GenId (Id) AS 
(	
	SELECT 1 

	UNION ALL
	
	SELECT GenId.Id + 1
	FROM GenId 
	WHERE GenId.Id < @maxId
)
Select * 
from GenId
OPTION (MAXRECURSION 400);
-- MAXRECURSION default 100, 0 - 32 767
-- как сгенерировать нечетные?
-- как начать с 10 ?


DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
	EmployeeID INT PRIMARY KEY,
	FullName VARCHAR(256),
	Title VARCHAR(256),
	ManagerID INT
);

INSERT INTO Employee
	(EmployeeID, FullName, Title, ManagerID)
VALUES 
	(1, 'John Mann', 'CEO', NULL),
	(2, 'Irvin Bow', 'CEO Deputy', 1), 
	(3, 'Abby Gold', 'HR', 1), 
	(4, 'Mary Wang', 'HR', 3),
	(5, 'Jim Johnson', 'HR', 4),
	(6, 'Linda Smith', 'HR', 3);

WITH CTE AS (
SELECT EmployeeID, FullName, Title, ManagerID
FROM Employee
WHERE ManagerID IS NULL
UNION ALL
SELECT e.EmployeeID, e.FullName, e.Title, e.ManagerID
FROM Employee e
INNER JOIN CTE ecte ON ecte.EmployeeID = e.ManagerID
)
SELECT *
FROM CTE;

-- Получить всех начальников
DECLARE @employeeId INT = 4;

WITH CTEParent AS (
SELECT EmployeeID, FullName, Title, ManagerID
FROM Employee
WHERE EmployeeID = @employeeId
UNION ALL
SELECT e.EmployeeID, e.FullName, e.Title, e.ManagerID
FROM Employee e
INNER JOIN CTEParent ecte ON ecte.ManagerID = e.EmployeeID
)
SELECT *
FROM CTEParent;
