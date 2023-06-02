USE WideWorldImporters;

-- ====================================================
-- SERIALIZABLE
-- ====================================================
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRAN;

	-- Данные в начале транзакции
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	SELECT @@TRANCOUNT
	-- >>>>> Запускаем что-то параллельно >>>>>
	
	-- Данные после параллельных изменений
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;

-- ROLLBACK;