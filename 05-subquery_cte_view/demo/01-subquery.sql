-- Зависимый или не зависимый?
SELECT 
	StockItemID, 
	StockItemName, 
	UnitPrice, 
	(SELECT 
		MAX(UnitPrice) 
	FROM Warehouse.StockItems) AS MaxPrice
FROM Warehouse.StockItems;

-- Сколько продаж было у менеджеров по продажам
SELECT
	PersonId, 
	FullName, 
		(SELECT 
			COUNT(InvoiceId) AS SalesCount
		FROM Sales.Invoices
		WHERE Invoices.SalespersonPersonID = People.PersonID
		) AS TotalSalesCount
FROM Application.People
WHERE IsSalesperson = 1



-- эквивалентно
SELECT top 5
	p.PersonId, 
	p.FullName, 
	count(*) as TotalSalesCount
FROM Application.People p
JOIN Sales.Invoices i ON i.SalespersonPersonID = p.PersonID
WHERE p.IsSalesperson = 1
GROUP BY p.PersonID, p.FullName
order by TotalSalesCount desc

-- Как вывести 5 лучших менеджеров по продажам?

----------------
-- IN
----------------

-- Показать информацию о менеджерах по продажам
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices);

SELECT *
FROM Application.People
WHERE PersonId IN (SELECT distinct SalespersonPersonID FROM Sales.Invoices);


-- NULL
SELECT *
FROM Application.People
WHERE PersonId IN (1,2,NULL);

-- эквивалентно
SELECT *
FROM Application.People
WHERE PersonId = 1 OR PersonID = 2 OR PersonId = NULL;



-- поэтому писать надо так
SELECT *
FROM Application.People
WHERE PersonId IN (1,2) OR PersonId IS NULL;

-- с NULL правильно так
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices) OR PersonID IS NULL
ORDER BY PersonID;

SELECT *
FROM Application.People
WHERE PersonId NOT IN (1,2, NULL);

SELECT *
FROM Application.People
WHERE NOT (PersonId = 1 OR PersonID = 2 OR PersonId = NULL);

--PersonId <> 1 AND PersonID <> 2 and PersonId <> NULL;

----------------
-- EXISTS
----------------
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices) 
ORDER BY PersonID;

SELECT *
FROM Application.People
WHERE EXISTS (
    SELECT *
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)
ORDER BY PersonID;

-- Плохо ли здесь "SELECT *" ?
-- Не лучше ли "SELECT TOP 1 *" или "SELECT 1"?
SELECT *
FROM Application.People
WHERE EXISTS (
    SELECT 1
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)
ORDER BY PersonID;

SELECT DISTINCT Application.People.*
FROM Application.People
	JOIN Sales.Invoices 
		ON Invoices.SalespersonPersonID = People.PersonID
ORDER BY People.PersonID;
--

--- NOT EXISTS / NOT IN

SELECT *
FROM Application.People
WHERE NOT EXISTS ( 
    SELECT SalespersonPersonID
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)
ORDER BY PersonID;


-- SELECT 1 vs count 

SELECT *
FROM Application.People
WHERE EXISTS (
   SELECT 1 
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID);

SELECT *
FROM Application.People
WHERE (SELECT count(*)
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID) > 0

----------------
-- ALL, ANY
----------------
-- какая цена самая маленькая
SELECT MIN(UnitPrice)
FROM Warehouse.StockItems;
GO

-- Товары с минимальной ценой
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL (
	SELECT UnitPrice 
	FROM Warehouse.StockItems);

-- эквивалентно
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT min(UnitPrice) FROM Warehouse.StockItems);



-- IN, = ANY
-- IN vs = ANY - в чем разница?
SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice IN (SELECT UnitPrice 
	FROM Warehouse.StockItems);

SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice = ANY (SELECT UnitPrice 
	FROM Warehouse.StockItems);


--derrived tables (производные таблицы)
SELECT P.PersonID, P.FullName, I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;
