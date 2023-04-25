-- --------------------------------------------------
-- CLR-агрегат в оконной функции
-- --------------------------------------------------
USE WideWorldImporters;

DROP TABLE IF EXISTS #AggregateTest;
GO

CREATE TABLE #AggregateTest(
  [month] INT, 
  [value] INT);
GO

INSERT INTO #AggregateTest 
VALUES (1, 1), (1, 0), (1, 2), (2, 3), (2, 2), (3, 2), (4, 3), (5, 1), (5, 3);
GO

SELECT 
  t.[month]
 ,t.[value]

             ,sum(t.[value]) OVER () AS [sum_total]
      ,dbo.SumClr(t.[value]) OVER () AS [SumClr_total]
 
	         ,sum(t.[value]) OVER (PARTITION BY t.[month]) AS [sum_partition]
      ,dbo.SumClr(t.[value]) OVER (PARTITION BY t.[month]) AS [SumClr_partition]

              -- нарастающий итог
             ,sum(t.[value]) OVER (ORDER BY t.[month]) AS [sum_order]
     --,dbo.SumClr(t.[value]) over (order by t.[month])
 -- SumClr с ORDER BY не работает, 
 -- если раскоментировать, то будет ошибка синтаксиса
FROM #AggregateTest t;
GO

