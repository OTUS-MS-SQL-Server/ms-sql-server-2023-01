USE WideWorldImporters;

-- Алиас в WHERE
SELECT OrderLineID AS [Order Line ID],
       Quantity,
       UnitPrice,
       (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE [TotalCost] > 1000;

-- Алиас в ORDER BY
SELECT OrderLineID AS [Order Line ID],
       Quantity,
       UnitPrice,
       (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
ORDER BY [TotalCost];

-- Порядок выполнения SELECT: 
--  FROM
--  WHERE
--  GROUP BY
--  HAVING
--  SELECT
--  ORDER BY
