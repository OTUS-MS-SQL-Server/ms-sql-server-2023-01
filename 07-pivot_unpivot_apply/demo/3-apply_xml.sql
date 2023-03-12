select *
from [Warehouse].[Colors]
for xml auto;

select *
from [Warehouse].[Colors]
for json auto;


declare @xml XML 
SET @xml = (SELECT ColorId
FROM Warehouse.Colors 
FOR XML AUTO);

select @xml;

SET @xml = (SELECT ColorId AS Id
FROM Warehouse.Colors AS C
FOR XML AUTO);

select @xml;

SELECT t.C.value('@Id','INT')
FROM @xml.nodes('C') as t(C);

declare @xml XML 
SET @xml = 
(SELECT top 100
	Invoices.InvoiceID,
	Invoices.InvoiceDate,
	Invoices.SalespersonPersonID,
	InvoiceLines.InvoiceLineID,
	InvoiceLines.Quantity,
	InvoiceLines.UnitPrice,
	InvoiceLines.TaxAmount
FROM Sales.Invoices 
	JOIN Sales.InvoiceLines 
		ON Invoices.InvoiceID = InvoiceLines.InvoiceID
FOR XML AUTO, Elements, root('invoices'));

select @xml;


select Ids.InvoiceId, 
	InvoiceDate,
	LineId
from @xml.nodes('./invoices') AS invoicesDoc(Invoices)
	cross apply 
		Invoices.nodes('(./Sales.Invoices)') SI(InvoiceEx)
	cross apply 
		(select InvoiceEx.value('(./InvoiceID[1])', 'INT') AS InvoiceId) AS Ids
	cross apply 
		(select InvoiceEx.value('(./InvoiceDate[1])', 'DATE') AS InvoiceDate) AS Dates
	cross apply 
		InvoiceEx.nodes('(./Sales.InvoiceLines)') AS SIL(T)
	cross apply 
		(select T.value('(./InvoiceLineID[1])', 'INT') AS LineId) AS lines;


use AdventureWorks2017;

select *
from HumanResources.JobCandidate;

with xmlnamespaces 
(
  'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume' as ns
)
select JobCandidateID
      ,Name
      ,Education=stuff(EduList,1,2,''),
	  Resume
from HumanResources.JobCandidate
cross apply
  Resume.nodes('/ns:Resume') F_ResumeNode(ResumeNode)
cross apply 
  ResumeNode.nodes('(./ns:Name)') F_NameNode(NameNode)
cross apply 
  (select Name=NameNode.value('(./ns:Name.First[1])','nvarchar(50)')
              +' '
              +NameNode.value('(./ns:Name.Last[1])','nvarchar(50)')
  ) F_Name
cross apply 
  (select EduList=ResumeNode.query('for $p in (./ns:Education)
                                    order by $p/ns:Edu.EndDate
                                    return concat("; ",string($p/ns:Edu.School))'
                                   ).value('.','nvarchar(200)')
  ) F_Edu
where JobCandidateID<=10;
