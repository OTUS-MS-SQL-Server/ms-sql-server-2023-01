
declare @today date = Cast(GetDate() as date)

SELECT EOMONTH('2019-09-01 23:50:00');

select CAST('2019-09-01 23:59:59.999' AS DATETIME) AS Dt,
	CAST('2019-09-01 23:59:59.999' AS DATETIME2) AS Dt2

SELECT OrderId, OrderDate, EOMONTH(OrderDate) AS 'End of Month'
,FORMAT(OrderDate,'dd.MM.yyyy') AS FormattedDate
,CONVERT(VARCHAR,OrderDate,109)
FROM Sales.Orders
WHERE OrderDate < '2014-01-01';

select format(getdate(),'\a\t \g\h\j dd day MM month yyyy year'),dateadd(month,1,'2020-01-31'),dateadd(dd,30,'2020-01-31'),
dateadd(month,3,'2020-01-31')




--set dateformat dmy;

SELECT 
	TRY_CONVERT(decimal(18,2) , '51,5' ),
	TRY_CONVERT(float, 'five'), --TRY_CONVERT ( data_type [ ( length ) ], expression [, style ] )  
	--CONVERT(float, 'five'),
	TRY_CONVERT(float, ' 5.44'), 
	TRY_CAST('51.5' as decimal(18,2)),--TRY_CAST ( expression AS data_type [ ( length ) ] ) 
	TRY_PARSE('2019/12/23' AS datetime2 USING 'en-US'),--TRY_PARSE ( string_value AS data_type [ USING culture ] ) 
	TRY_PARSE('06.12.2018' AS datetime2 USING 'en-US');
--MS docs : Используйте инструкцию TRY_PARSE только для преобразования данных из строкового типа в типы даты или времени и числовые типы.

--
SELECT Stuff('Big big problem',9,3,'challenge');

SELECT IsPermittedToLogon,STRING_AGG(FullName, ';') WITHIN GROUP ( ORDER BY FullName desc ) -- сортировка внутри group by
FROM Application.People
WHERE IsSalesperson = 1
GROUP BY IsPermittedToLogon;



SELECT *
FROM STRING_SPLIT('Appoved;On approval',';');
--
SELECT STRING_ESCAPE('Kdf " dkdk','json');

SELECT STRING_ESCAPE('Kdf " dkdk','json');





declare @json nvarchar(150)--Пример не обязательно для json, скорее для форматированных email или локализации. 
					       --что-то вроде select Formatmessage(Exception,@exText) from localization.language where PersonID=2
						   --ведущие нули, пробелы, имеют интересное решение в этой фукции. (microsoft примеры)
SET @json = FORMATMESSAGE('{ "id": %d,"name": "%s", "surname": "%s" }',   17, STRING_ESCAPE('t""f','json'), STRING_ESCAPE('test2','json') );
select @json

--для json лучше (Было на прошлом занятии углубленно, если что повторяем поверхностно)
select 17 id,
	   't""f' name ,
	   'test2' surname
for json path, WITHOUT_ARRAY_WRAPPER--Without array wrapper - позволяет не оборачивать массивом [] 

set statistics io,time on
SELECT 			p.FullName Name,
				(select top(5) InvoiceDate,TotalDryItems from Sales.Invoices i where i.SalespersonPersonID=p.PersonID for json path)  Invoices
FROM Application.People p
WHERE p.IsSalesperson = 1 and p.PersonID=2
for json path, root('Person');

SELECT top(5)
				People.FullName Name,
				Invoices.InvoiceDate InvoiceDate,
				Invoices.TotalDryItems TotalDryItems
FROM  Application.People People
INNER JOIN Sales.Invoices Invoices on Invoices.SalespersonPersonID=People.PersonID
WHERE People.IsSalesperson = 1 and People.PersonID=2
for json auto, root('Person');

select 1
where 'AC0005' = 'AC0005 '-- like не выводит

--Ещё надо знать LOWER, ASCII 
--Скорее всего все знают: LEN, RIGHT, CHARINDEX, REVERSE, SUBSTRING
--Применять операции со строками в БД надо с осторожностью
--Полный набор функций майкрософте: https://docs.microsoft.com/ru-ru/sql/t-sql/functions/string-functions-transact-sql?view=sql-server-ver15
--Примеры Formatmessage: https://docs.microsoft.com/ru-ru/sql/t-sql/functions/formatmessage-transact-sql?view=sql-server-ver15

