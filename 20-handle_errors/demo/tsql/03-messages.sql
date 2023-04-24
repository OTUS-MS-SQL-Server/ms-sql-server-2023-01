/* tsqllint-disable error print-statement */

-- Msg 8134, Level 16, State 1, Line 2
-- Divide by zero error encountered.
SELECT 1 / 0;

-- код последней ошибки
PRINT @@ERROR;

-- https://learn.microsoft.com/ru-ru/sql/t-sql/functions/error-transact-sql

-- Поскольку функция @@ERROR очищается и сбрасывается для каждой выполняемой инструкции, 
-- проверяйте ее сразу после инструкции или сохраните значение в локальную переменную 
-- для последующей проверки.

-- можно работать с ошибками и через @@ERROR (но лучше TRY/CATCH)

DECLARE @ErrorNum INT;
SELECT 1 / 0;

SET @ErrorNum = @@ERROR;
IF @ErrorNum = 0
BEGIN
    PRINT N'ошибки нет';
END
ELSE
BEGIN
    PRINT N'была ошибка ' + CAST(@ErrorNum AS NCHAR(5));
END
GO

SELECT message_id, language_id, severity, is_event_logged, [text]
FROM sys.messages
WHERE message_id = 8134;

-- --------------------------
-- RAISERROR 
-- --------------------------

-- Параметры RAISERROR:
-- msg_id | msg_str | @local_variable
-- severity
-- state

-- Можно использовать готовые сообщения из sys.messages
-- и добавлять свои 

EXEC sp_addmessage 
    @msgnum=50002,
    @severity=16,
    @msgtext='Cannot process Employee with ID=%s';
GO

RAISERROR(50002, 16, 1, '12345');
GO

SELECT message_id, language_id, severity, is_event_logged, [text]
FROM sys.messages
WHERE message_id = 50002;

EXEC sp_dropmessage @msgnum=50002;
GO
