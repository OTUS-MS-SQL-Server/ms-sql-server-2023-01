drop TABLE if exists Sales.InvoiceTotals;

	CREATE TABLE Sales.InvoiceTotals
		(
		TotalId INT IDENTITY(1,1),
		TotalDate DATE,
		InvoiceAmount INT,
		InvoiceLineAmount INT, 
		TotalQuantity Decimal(18,2),
		TotalUnitPrice Decimal(18,2),
		TotalTaxAmount Decimal(18,2),
		TotalExtendedPrice Decimal(18,2)
		)

	SELECT GETDATE(), DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)

	SELECT  DATEADD(mm,DATEDIFF(mm,0,I.InvoiceDate),0) AS InvoiceMonth, 
			Count(I.InvoiceId), Count(IL.InvoiceLineID), 
			SUM(IL.Quantity), Sum(IL.UnitPrice), SUM(IL.TaxAmount), SUM(IL.ExtendedPrice)
	FROM Sales.InvoiceLines AS IL
		join Sales.Invoices AS I
			ON I.InvoiceID = IL.InvoiceID
	WHERE I.InvoiceDate >= '20130101'
		AND I.InvoiceDate < '20130601'
	GROUP BY DATEADD(mm,DATEDIFF(mm,0,InvoiceDate),0) 
	ORDER BY InvoiceMonth

--- step 1
	MERGE Sales.InvoiceTotals AS target 
	USING (SELECT DATEADD(mm,DATEDIFF(mm,0,I.InvoiceDate),0) AS InvoiceMonth, 
				Count(I.InvoiceId), Count(IL.InvoiceLineID), 
				SUM(IL.Quantity), Sum(IL.UnitPrice), SUM(IL.TaxAmount), SUM(IL.ExtendedPrice)
		FROM Sales.InvoiceLines AS IL
			join Sales.Invoices AS I
				ON I.InvoiceID = IL.InvoiceID
		WHERE I.InvoiceDate >= '20130101'
			AND I.InvoiceDate < '20130301'
		GROUP BY DATEADD(mm,DATEDIFF(mm,0,InvoiceDate),0) 
		) 
		AS source (InvoiceMonth, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) 
		ON
	 (target.TotalDate = source.InvoiceMonth) 
	WHEN MATCHED 
		THEN UPDATE SET InvoiceAmount = source.InvoiceAmount,
						InvoiceLineAmount = source.InvoiceLineAmount,
						TotalQuantity = source.TotalQuantity,
						TotalUnitPrice = source.TotalUnitPrice,
						TotalTaxAmount = source.TotalTaxAmount,
						TotalExtendedPrice = source.TotalExtendedPrice
	WHEN NOT MATCHED 
		THEN INSERT (TotalDate, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) 
			VALUES (source.InvoiceMonth, source.InvoiceAmount, source.InvoiceLineAmount, source.TotalQuantity, source.TotalUnitPrice, source.TotalTaxAmount, source.TotalExtendedPrice) 
	OUTPUT deleted.*, $action, inserted.*;


---------step 2
	MERGE Sales.InvoiceTotals AS target 
	USING (SELECT DATEADD(mm,DATEDIFF(mm,0,I.InvoiceDate),0) AS InvoiceMonth, 
					Count(I.InvoiceId), Count(IL.InvoiceLineID), 
					SUM(IL.Quantity), Sum(IL.UnitPrice), SUM(IL.TaxAmount), SUM(IL.ExtendedPrice)
			FROM Sales.InvoiceLines AS IL
				join Sales.Invoices AS I
					ON I.InvoiceID = IL.InvoiceID
			WHERE I.InvoiceDate >= '20130101'
				AND I.InvoiceDate < '20130501'
			GROUP BY DATEADD(mm,DATEDIFF(mm,0,InvoiceDate),0) 
			) 
			AS source (InvoiceMonth, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) ON
		 (target.TotalDate = source.InvoiceMonth) 
	WHEN MATCHED --AND target.InvoiceAmount != source.InvoiceAmount
		THEN UPDATE SET InvoiceAmount = source.InvoiceAmount,
						InvoiceLineAmount = source.InvoiceLineAmount,
						TotalQuantity = source.TotalQuantity,
						TotalUnitPrice = source.TotalUnitPrice,
						TotalTaxAmount = source.TotalTaxAmount,
						TotalExtendedPrice = source.TotalExtendedPrice
	WHEN NOT MATCHED 
		THEN INSERT (TotalDate, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) 
			 VALUES (source.InvoiceMonth, source.InvoiceAmount, source.InvoiceLineAmount, source.TotalQuantity, source.TotalUnitPrice, source.TotalTaxAmount, source.TotalExtendedPrice) 
		OUTPUT deleted.*, $action, inserted.*;


---------step 3
	MERGE Sales.InvoiceTotals AS target 
	USING (SELECT DATEADD(mm,DATEDIFF(mm,0,I.InvoiceDate),0) AS InvoiceMonth, 
					Count(I.InvoiceId), Count(IL.InvoiceLineID), 
					SUM(IL.Quantity), Sum(IL.UnitPrice), SUM(IL.TaxAmount), SUM(IL.ExtendedPrice)
			FROM Sales.InvoiceLines AS IL
				join Sales.Invoices AS I
					ON I.InvoiceID = IL.InvoiceID
			WHERE I.InvoiceDate >= '20130201'
				AND I.InvoiceDate < '20130401'
			GROUP BY DATEADD(mm,DATEDIFF(mm,0,InvoiceDate),0) 
			) 
			AS source (InvoiceMonth, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) ON
		 (target.TotalDate = source.InvoiceMonth) 
	WHEN MATCHED AND target.InvoiceAmount != source.InvoiceAmount
		THEN UPDATE SET InvoiceAmount = source.InvoiceAmount,
						InvoiceLineAmount = source.InvoiceLineAmount,
						TotalQuantity = source.TotalQuantity,
						TotalUnitPrice = source.TotalUnitPrice,
						TotalTaxAmount = source.TotalTaxAmount,
						TotalExtendedPrice = source.TotalExtendedPrice
	WHEN NOT MATCHED 
		THEN INSERT (TotalDate, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) 
			 VALUES (source.InvoiceMonth, source.InvoiceAmount, source.InvoiceLineAmount, source.TotalQuantity, source.TotalUnitPrice, source.TotalTaxAmount, source.TotalExtendedPrice) 
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	OUTPUT deleted.*, $action, inserted.*;
