USE WideWorldImporters;
GO

-- результат в output-переменную 
-- (C# - out SqlInt32 result)
DECLARE @result INT;
EXEC dbo.[Add] 3, 4, @result OUTPUT;
SELECT @result;
GO

-- Простое использование SqlPipe (аналог print)
PRINT 'hello';
EXEC dbo.MyPrint 'hello message';
GO

-- Генерирование ResultSet
EXEC dbo.Fibonacci 2, 3, 30;
GO

-- Запрос данных в БД
EXEC usp_CountOrdersFoDeliveryCity_ExecuteAndSend 242;

EXEC usp_CountOrdersFoDeliveryCity_ExecuteReader 242;
GO
