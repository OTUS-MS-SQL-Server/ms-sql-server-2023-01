
-----------------------------------------------------------------
--------------Поиск ПРОПУСКОВ------------------------------------
-----------------------------------------------------------------
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
(7, '2020-01-14T10:00:00', 150, 200, 2, 30.15),
(10, '2020-01-14T15:00:00', 100, 380, 1, 8.00),
(11, '2020-01-15T12:45:00', 150, 311, 5, 5.00),
(12, '2020-01-15T21:30:00', 170, 200, 1, 30.15),
(15, '2020-01-14T18:00:00', 170, 380, 3, 8.00),
(16, '2020-01-15T09:30:00', 100, 311, 1, 5.00);

--подзапрос
SELECT s.sales_id, s.sales_id - 
	ISNULL((SELECT MAX(s2.sales_id) 
	 FROM sales AS s2 
	 WHERE s2.sales_id < s.sales_id),0) AS diff
FROM sales AS s
ORDER BY s.sales_id;

--оконная функция
SELECT sales_id, sales_id - LAG(sales_id,1,0) OVER (ORDER BY sales_id) AS diff
FROM sales
ORDER BY sales_id

-----------------------------------------------------------------
--------------Поиск Дубликатов-----------------------------------
-----------------------------------------------------------------
DROP TABLE IF EXISTS sales;

Create table sales 
(sales_id INT PRIMARY KEY, sales_dt DATETIME2 DEFAULT GETUTCDATE(),  customer_id INT, item_id INT, cnt INT, price_per_item DECIMAL(19,4));

INSERT INTO sales
(sales_id, sales_dt, customer_id, item_id, cnt, price_per_item)
VALUES
(1, '2020-01-10T10:00:00', 100, 200, 2, 30.15),
(2, '2020-01-11T11:00:00', 100, 311, 1, 5.00),
(3, '2020-01-12T14:00:00', 100, 400, 1, 50.00),
(4, '2020-01-12T14:00:00', 100, 400, 1, 50.00),
(5, '2020-01-13T10:00:00', 150, 311, 1, 5.00),
(6, '2020-01-14T10:00:00', 150, 200, 2, 30.15),
(7, '2020-01-14T10:00:00', 150, 200, 2, 30.15),
(10, '2020-01-14T15:00:00', 100, 380, 1, 8.00),
(11, '2020-01-15T12:45:00', 150, 311, 5, 5.00),
(12, '2020-01-15T21:30:00', 170, 200, 1, 30.15),
(13, '2020-01-15T21:30:00', 170, 200, 1, 30.15),
(14, '2020-01-15T21:30:00', 170, 200, 1, 30.15),
(15, '2020-01-14T18:00:00', 170, 380, 3, 8.00),
(16, '2020-01-15T09:30:00', 100, 311, 1, 5.00);

----Дубликат строка с одинковым клиентом, продуктом, кол-вом и датой
----То есть по условиям бизнес логики один и тот же клиент не может совершить ту же покупку в тот же день
----Просто для того чтобы определить дубликат по каким-то условиям

SELECT CAST(sales_dt AS DATE),customer_id, item_id, cnt,  COUNT(*) AS record_count, MIN(sales_id)
FROM sales
GROUP BY CAST(sales_dt AS DATE),customer_id, item_id, cnt
HAVING COUNT(*) > 1;

SELECT *, COUNT(*) OVER (PARTITION BY CAST(sales_dt AS DATE),customer_id, item_id, cnt), MIN(sales_id) OVER (PARTITION BY CAST(sales_dt AS DATE),customer_id, item_id, cnt)
FROM sales

DROP TABLE sales