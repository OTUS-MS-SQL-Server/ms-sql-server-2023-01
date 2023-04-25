USE WideWorldImporters;
GO

-- ===================
-- NULL
-- ===================

-- Проверим, что работает
SELECT dbo.AddNullError(1, 2);
GO

-- не работает с NULL
SELECT dbo.AddNullError(NULL, 2);
GO

-- int? (nullable) - работает, но лучше так не делать
-- null внутри функции считается за ноль
SELECT dbo.AddNullable(NULL, 2);
GO

-- работает с NULL (NULL никак не обрабатываем)
SELECT dbo.AddNullGood(NULL, 2);
SELECT dbo.AddNullGood(1, NULL);
SELECT dbo.AddNullGood(NULL, NULL);
GO

SELECT dbo.AddNullGood(200000000,2000000000);
GO

-- SqlInt32 - работает с NULL (NULL считаем за 0) 
SELECT dbo.AddNullGoodZero(NULL, 2);
SELECT dbo.AddNullGoodZero(1, NULL);
SELECT dbo.AddNullGoodZero(NULL, NULL);
GO

-- возвращаем NULL
SELECT dbo.NullIfZero(2);
SELECT dbo.NullIfZero(0);
GO
-- return null работает, но так лучше не делать
SELECT dbo.NullBad();
GO
