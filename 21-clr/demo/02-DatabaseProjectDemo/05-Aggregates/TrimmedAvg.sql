/* tsqllint-disable error schema-qualify */

USE WideWorldImporters;
GO

-- Reset
DROP TABLE IF EXISTS Table2;
GO
CREATE TABLE Table2 (Col1 INT);
GO

INSERT INTO Table2
VALUES (1), (2), (4), (10);
GO

SELECT Col1
FROM Table2;


-- SumClr
SELECT  
	SUM(Col1) AS [Sum],	
	dbo.SumClr(Col1) AS [SumClr]
FROM Table2;

-- demo: debug 

-- TrimmedAvg
SELECT  
	SUM(Col1) AS [Sum],	
	AVG(Col1) AS [Avg],
	dbo.TrimmedAvg(Col1) AS [TrimmedAvg]
FROM Table2;
GO

DROP TABLE Table2;