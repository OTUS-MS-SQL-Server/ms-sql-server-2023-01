/* tsqllint-disable error schema-qualify */

USE WideWorldImporters;
GO

-- Что мы хотим от типа PhoneNumber
-- Номер телефона - 10 цифр
DECLARE @phone PhoneNumber;
SET @phone = '5105495930';
SELECT 
	@phone AS [Binary], 
	@phone.ToString() AS [ToString], 
	@phone.ToFormattedString() AS [Formatted];
GO

-- NULL
DECLARE @phone PhoneNumber;
SELECT 
	@phone AS [Binary], 
	@phone.ToString() AS [ToString], 
	@phone.ToFormattedString() AS [Formatted];
GO

-- C# source

-- Валидация (вызывается Parse())
DECLARE @phone PhoneNumber;
SET @phone = '123';
GO

-- Можно присвоить значение и через свойство
DECLARE @phone PhoneNumber;
SET @phone = '1111111111';
SET @phone.Number = '5105495930';
SELECT 
	@phone AS [Binary], 
	@phone.ToString() AS [ToString], 
	@phone.ToFormattedString() AS [Formatted];
GO

-- Пример использования как типа колонки
DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees
(
	Name NVARCHAR(20),
	Phone PhoneNumber
);
GO

INSERT INTO Employees VALUES('empl_1', '9001234567');
GO

SELECT Name, Phone FROM Employees e;
GO

-- ошибка (значение не валидное)
INSERT INTO Employees VALUES('empl_2', '1234567');
GO

SELECT 
 e.Name, 
 e.Phone, 
 e.Phone.ToString() AS Phone_ToString,
 e.Phone.ToFormattedString() AS Phone_FormattedString
FROM Employees e;
GO

-- Можем применять в WHERE
SELECT 
 e.Name, 
 e.Phone, 
 e.Phone.ToString() AS Phone_ToString,
 e.Phone.ToFormattedString() AS Phone_FormattedString
FROM Employees e
WHERE e.Phone = '9001234567';
GO

-- А так будет работать?
INSERT INTO Employees 
VALUES('empl_3', '(900) 123-45-67');

DROP TABLE Employees;
GO
