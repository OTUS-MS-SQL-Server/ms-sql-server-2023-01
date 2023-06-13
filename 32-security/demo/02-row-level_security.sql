-- -------------------------------
-- Row-Level Security (RLS) 
-- -------------------------------
USE master;
ALTER DATABASE RlsDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS RlsDemo;
GO

CREATE DATABASE RlsDemo;
GO 

USE RlsDemo;
GO

CREATE TABLE Sales(
    OrderID INT,
    SalesUsername VARCHAR(50),
    Product VARCHAR(50),
    Qty INT
);
GO

INSERT Sales VALUES 
    (1, 'User1', 'Lemon', 5), 
    (2, 'User1', 'Banana', 2), 
    (3, 'User2', 'Orange', 2), 
    (4, 'User2', 'Banana', 5), 
    (5, 'User2', 'Tomato', 5);
GO

-- Что там есть
SELECT * FROM Sales;
GO

-- Создание пользователей (обратите внимание, что без логинов)
CREATE USER ManagerUser WITHOUT LOGIN;
CREATE USER User1 WITHOUT LOGIN;
CREATE USER User2 WITHOUT LOGIN;
GO

-- Предоставляем права
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO ManagerUser;
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO User1;
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO User2;
GRANT SHOWPLAN TO ManagerUser;
GRANT SHOWPLAN TO User1;
GRANT SHOWPLAN TO User2;
GO


-- predicate-функция, которая будет контролировать доступ
CREATE FUNCTION dbo.fn_SecurityPredicate(@Username AS VARCHAR(50))
    RETURNS TABLE
    WITH SCHEMABINDING
AS
    RETURN
        SELECT
            1 AS result 
        WHERE
            user_name() = @Username OR
            user_name() = 'ManagerUser';
GO

-- Создаем SECURITY POLICY
CREATE SECURITY POLICY dbo.SalesPolicyFilter
ADD FILTER /* BLOCK*/ PREDICATE dbo.fn_SecurityPredicate(SalesUsername) 
ON dbo.Sales
WITH (STATE = ON);
GO

-- В SSMS: <DB> \ Security \ Security Policies

-- Для пользователя dbo должно быть пусто
-- (нет строк, где SalesUsername = 'dbo')
SELECT user_name();

SELECT * FROM Sales;

SELECT COUNT(*) FROM Sales;
GO

-- Смотрим план выполнения

-- Для EXECUTE AS должно быть разрешение:
-- GRANT IMPERSONATE ON USER::User2 TO User1;
-- User1 сможет переключиться в контекст User2
-- Права EXECUTE AS действуют до REVERT

-- Только данные User1
EXECUTE AS USER = 'User1';
    SELECT CURRENT_USER;
    SELECT * FROM Sales;
    SELECT COUNT(*) AS [Count] FROM Sales;
REVERT;
GO

-- Только данные User2
EXECUTE AS USER = 'User2';
    SELECT CURRENT_USER;
    SELECT * FROM Sales;
    SELECT COUNT(*) FROM Sales;
REVERT;
GO

-- Все данные 
EXECUTE AS USER = 'ManagerUser';
    SELECT CURRENT_USER;
    SELECT * FROM Sales;
REVERT;
GO

-- Изменяем свои данные
EXECUTE AS USER = 'User1';
    SELECT CURRENT_USER;
    INSERT Sales VALUES (7, 'User1', 'Banana inserted by User1', 2);
    SELECT * FROM Sales;
REVERT;
GO

-- Изменяем чужие данные
EXECUTE AS USER = 'User1';
    SELECT CURRENT_USER;
    INSERT Sales VALUES (7, 'User2', 'Apple inserted by User1', 2);
    SELECT * FROM Sales;
REVERT;
GO

-- Как запретить изменение "чужих" данных?
-- см. ниже 


























/*
-- Для запрета изменения надо использовать BLOCK PREDICATE

CREATE SECURITY POLICY dbo.SalesPolicyFilter
ADD BLOCK PREDICATE dbo.fn_SecurityPredicate(SalesUsername) 
ON dbo.Sales
WITH (STATE = ON)
GO
*/

EXECUTE AS USER = 'ManagerUser';
    SELECT * FROM Sales;
REVERT;
GO

-- -------------------------------
-- Вкл/выкл  SECURITY POLICY
-- -------------------------------

-- пусто
SELECT * FROM Sales;
GO

-- отключаем
ALTER SECURITY POLICY dbo.SalesPolicyFilter WITH (STATE = OFF);
GO

-- данные есть
SELECT * FROM Sales;
GO

-- включаем
ALTER SECURITY POLICY dbo.SalesPolicyFilter WITH (STATE = ON);
GO
SELECT * FROM Sales;
GO

-- Более сложный пример можно посмотреть в WideWorldImporters:
-- * политика Application.FilterCustomersBySalesTerritoryRole
-- * функция Application.DetermineCustomerAccess