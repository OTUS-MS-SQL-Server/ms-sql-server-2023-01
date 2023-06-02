USE WideWorldImporters;

---- Возвращаем БД в исходное сосотяние (для работы демо)
--UPDATE Application.People
--SET PhoneNumber = '(415) 555-0102'
--WHERE FullName = 'Kayla Woodcock';
--GO

--DELETE FROM [Application].[People] 
--WHERE FullName = 'Kayla Woodcock 111'
--GO

BEGIN TRAN;
	UPDATE Application.People
	SET PhoneNumber = '(777) 777-77777'
	WHERE FullName = 'Kayla Woodcock';

	-- запускаем до сюда, специально не коммитим

-- ROLLBACK;    
