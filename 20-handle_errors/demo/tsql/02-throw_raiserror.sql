/* tsqllint-disable error conditional-begin-end */
/* tsqllint-disable error select-star */
/* tsqllint-disable error print-statement */

-- ----------------------------
-- Обработка ошибок
-- ----------------------------

USE WideWorldImporters;
GO

-- Для генерирования ошибок на стороне SQL Serveer используются 
-- RAISERROR или THROW (с SQL Server 2012)
-- см. слайд
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
	@StockItemID INT,
	@UnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM Warehouse.StockItems WHERE StockItemID = @StockItemID)
	BEGIN
		DECLARE @message NVARCHAR(50) = CONCAT(N'Не найден StockItemID = ', @StockItemID);
		THROW 50000, @message, 1; -- <<< добавили
		-- error_number от 50 000 до 2 147 483 647
	END
	ELSE
	BEGIN
		UPDATE Warehouse.StockItems
		SET UnitPrice = @UnitPrice
		WHERE StockItemID = @StockItemID;
	END;
GO

EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 30;
GO
-- Видим ошибку
-- Смотрим клиента в Visual Studio

-- RAISERROR
-- https://docs.microsoft.com/ru-ru/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-ver15
-- Обязательные параметры: 
--   * текст (или message_id)
--   * severity - уровень серьезности (0 - 25) (в THROW = 16)
--   * state - Целое число (0 - 255)
--     Указывает состояние, которое должно быть связано с сообщением
--     Если одна и та же пользовательская ошибка возникает в нескольких местах, 
--     то при помощи уникального номера состояния для каждого местоположения можно определить, 
--     в каком месте кода появилась ошибка.
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
	@StockItemID INT,
	@UnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM Warehouse.StockItems WHERE StockItemID = @StockItemID)
	BEGIN
		DECLARE @message NVARCHAR(50) = CONCAT(N'Не найден StockItemID = ', @StockItemID);
		RAISERROR (@message, 11, 1);-- <<< добавили
	END
	ELSE
	BEGIN
		UPDATE Warehouse.StockItems
		SET UnitPrice = @UnitPrice
		WHERE StockItemID = @StockItemID;
	END;
GO

EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 30;
GO
-- Смотрим клиента в Visual Studio
-- (и исключения там)

-- RAISERROR c разным уровнем @severity
-- Чем значение больше, тем ошибка серьезнее
-- 0  - 11 информационные сообщения
RAISERROR(N'Сообщение severinity = 0', 0, 1);
RAISERROR(N'Сообщение severinity = 1', 1, 1);
RAISERROR(N'Сообщение severinity = 2', 2, 1);
RAISERROR(N'Сообщение severinity = 3', 3, 1);
RAISERROR(N'Сообщение severinity = 4', 4, 1);
RAISERROR(N'Сообщение severinity = 5', 5, 1);
RAISERROR(N'Сообщение severinity = 6', 6, 1);
RAISERROR(N'Сообщение severinity = 7', 7, 1);
RAISERROR(N'Сообщение severinity = 8', 8, 1);
RAISERROR(N'Сообщение severinity = 9', 9, 1);
RAISERROR(N'Сообщение severinity = 10', 10, 1)  WITH LOG;

-- 11 - 18 ошибка
RAISERROR(N'Сообщение severinity = 11', 11, 1);
RAISERROR(N'Сообщение severinity = 12', 12, 1);
RAISERROR(N'Сообщение severinity = 13', 13, 1);
RAISERROR(N'Сообщение severinity = 14', 14, 1);
RAISERROR(N'Сообщение severinity = 15', 15, 1);
RAISERROR(N'Сообщение severinity = 16', 16, 1);
RAISERROR(N'Сообщение severinity = 17', 17, 1);
RAISERROR(N'Сообщение severinity = 18', 18, 1);
RAISERROR(N'Сообщение severinity = 19', 19, 1) WITH LOG; 

-- 20 - 25 неустраняемая ошибка (требуются WITH LOG с 18)
-- соединение с клиентом обрывается 
-- и регистрируется сообщение об ошибке в логах
RAISERROR(N'Сообщение severinity = 20', 20, 1) WITH LOG;
RAISERROR(N'Сообщение severinity = 21', 21, 1) WITH LOG;
RAISERROR(N'Сообщение severinity = 22', 22, 1) WITH LOG;
RAISERROR(N'Сообщение severinity = 23', 23, 1) WITH LOG;
RAISERROR(N'Сообщение severinity = 24', 24, 1) WITH LOG;
RAISERROR(N'Сообщение severinity = 25', 25, 1) WITH LOG;

-- Если WITH LOG, то сообщение логируется в лог
-- SSMS: Management \ SQL Server Logs
-- Можно логировать и информационные сообщения
RAISERROR(N'Сообщение severinity = 1', 1, 1) WITH LOG;
GO

-- Поменяем severity на 10
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
	@StockItemID INT,
	@UnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM Warehouse.StockItems WHERE StockItemID = @StockItemID)
	BEGIN
		DECLARE @message NVARCHAR(50) = CONCAT(N'Не найден StockItemID = ', @StockItemID);
		RAISERROR (@message, 10, 1); -- <<< severenity поменяли c 11 на 10;
	END
	ELSE
	BEGIN
		UPDATE Warehouse.StockItems
		SET UnitPrice = @UnitPrice
		WHERE StockItemID = @StockItemID;
	END;
GO

EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 30;
GO
-- Смотрим клиента в Visual Studio

-- Вернем severinity = 11
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
	@StockItemID INT,
	@UnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM Warehouse.StockItems WHERE StockItemID = @StockItemID)
	BEGIN
		DECLARE @message NVARCHAR(50) = CONCAT(N'Не найден StockItemID = ', @StockItemID);
		RAISERROR (@message, 11, 1); -- <<< severenity поменяли c 11 на 10;
	END
	ELSE
	BEGIN
		UPDATE Warehouse.StockItems
		SET UnitPrice = @UnitPrice
		WHERE StockItemID = @StockItemID;
	END;
GO

EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 30;
GO

-- SQL Agent и Alerts

-- Дополнительно про sys.messages, message_id и т.д.
-- См. 03-messsages.sql
