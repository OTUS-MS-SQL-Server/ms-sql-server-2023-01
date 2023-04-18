USE WideWorldImporters;

-- Возвращаем БД в исходное сосотяние (для работы демо)
UPDATE Application.People
SET PhoneNumber = '(415) 555-0102'
WHERE FullName = 'Kayla Woodcock';
GO

DELETE FROM [Application].[People] 
WHERE FullName = 'Kayla Woodcock 222'
GO

-- ----------------------
-- DirtyRead
-- ----------------------
BEGIN TRAN;

	UPDATE Application.People
	SET PhoneNumber = '(999) 999-7777'
	WHERE FullName = 'Kayla Woodcock';

    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
-- -------------------
-- ROLLBACK;
COMMIT;

-- ----------------------
-- NonRepeatableRead
-- ----------------------
BEGIN TRAN;
	UPDATE Application.People
	SET PhoneNumber = '(777) 777-77777'
	WHERE FullName = 'Kayla Woodcock';

COMMIT;

BEGIN TRAN;
	UPDATE Application.People
	SET PhoneNumber = '(888) 888-8888'
	WHERE FullName = 'Kayla Woodcock';

COMMIT;

SELECT PersonId, FullName, PhoneNumber
FROM Application.People
WHERE FullName like 'Kayla Woodcock%';

-- ----------------------
-- PhantomRead
-- ----------------------
SET LOCK_TIMEOUT 10000

BEGIN TRAN;

INSERT INTO [Application].[People] 
([FullName],[PhoneNumber],[PreferredName],[IsPermittedToLogon], [IsExternalLogonProvider], [IsSystemUser],[IsEmployee],[IsSalesperson],[LastEditedBy])
VALUES 
('Kayla Woodcock 333','(000) 123-45-67', 'Kayla Woodcock 333', 1, 1, 1, 1, 1,1);

COMMIT
-- -------------
ROLLBACK;

SELECT PersonId, FullName, PhoneNumber
FROM Application.People
WHERE FullName like 'Kayla Woodcock%';
	