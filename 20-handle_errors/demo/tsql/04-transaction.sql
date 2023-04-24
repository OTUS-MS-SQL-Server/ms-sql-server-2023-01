/* tsqllint-disable error conditional-begin-end */
/* tsqllint-disable error select-star */
/* tsqllint-disable error print-statement */

-- Добавляем транзакцию:
-- * 1) логируем изменение цены в отдельную таблицу Warehouse.Logs 
--   (сохраняем старое значение и др. информацию)
-- * 2) изменяем цену в Warehouse.StockItems
-- * 3) добавляем строку в Sales.SpecialDeals 
USE WideWorldImporters;
GO

DROP TABLE IF EXISTS Warehouse.Logs;
GO

CREATE TABLE Warehouse.Logs (
    [Date] DATETIME2 NOT NULL,
    [Details] NVARCHAR(4000) NOT NULL
);
GO

-- Изменяем хранимую процедуру
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
    @StockItemID INT,
    @NewUnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;

    -- Проверку на существование StockItemID специально убрали, 
    -- т.к. добавили транзакцию и все должно быть атомарно и при ошибке ROLLBACK.

    BEGIN TRANSACTION;
        DECLARE @OldUnitPrice DECIMAL(18, 2);

        -- получаем старую цену по @StockItemID, чтобы потом сохранить в историю
        SELECT @OldUnitPrice = UnitPrice 
        FROM Warehouse.StockItems
        WHERE StockItemID = @StockItemID;

        -- сообщение для истории изменений
        DECLARE @LogMessage NVARCHAR(4000) = CONCAT(
            'StockItemID = ', @StockItemID, 
            ', NewUnitPrice = ', @NewUnitPrice, 
            ', OldUnitPrice = ', @OldUnitPrice);
        
        INSERT INTO Warehouse.Logs([Date], Details)
        VALUES(GETDATE(), @LogMessage);
        
        -- обновляем цену в StockItems
        UPDATE Warehouse.StockItems 
        SET UnitPrice = @NewUnitPrice
        WHERE StockItemID = @StockItemID;

        -- добавляем SpecialDeals
        INSERT INTO Sales.SpecialDeals
            (StockItemID, UnitPrice, DealDescription, StartDate, EndDate, LastEditedBy)
            VALUES(@StockItemID, @NewUnitPrice, 'description', SYSDATETIME(), DATEADD(d, 10, GETDATE()), 1);
    COMMIT;
GO
-- Все в транзакции, поэтому, вроде как, при ошибке должно все откатиться

-- Проверяем работу на существующем StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 10, @NewUnitPrice = 15;

SELECT * FROM Warehouse.Logs;
SELECT * FROM Sales.SpecialDeals;
SELECT StockItemID, UnitPrice FROM Warehouse.StockItems WHERE StockItemID = 10;
-- Все хорошо.

-- Не существующий StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @NewUnitPrice = 11;
-- Ошибка FK

-- Все ли хорошо в таблицах?
SELECT * FROM Warehouse.Logs;
SELECT * FROM Sales.SpecialDeals;
SELECT StockItemID, UnitPrice FROM Warehouse.StockItems WHERE StockItemID = 1000;
GO

-- Есть запись в Warehouse.Logs, хоть и транзакция
-- Ваши предложения как решить проблему?
-- Транзакция не работает ???
-- (см. ниже)




-- ---------------------------
-- XACT_ABORT
-- ---------------------------
-- Параметр XACT_ABORT необходим для более надежной обработки ошибок и транзакций.
--
-- Поведение SQL Server по умолчанию в той ситуации, когда не используется TRY-CATCH,
-- заключается в том, что некоторые ошибки прерывают выполнение и откатывают любые открытые транзакции, 
-- в то время как с другими ошибками выполнение последующих инструкций продолжается. 
-- Когда вы включаете XACT_ABORT ON, почти все ошибки начинают вызывать одинаковый эффект: 
-- любая открытая транзакция откатывается, и выполнение кода прерывается.

CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
    @StockItemID INT,
    @UnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- <<< добавили только это

    BEGIN TRANSACTION;
        DECLARE @OldUnitPrice DECIMAL(18, 2);

        -- получаем старую цену по @StockItemID, чтобы потом сохранить в историю
        SELECT @OldUnitPrice = UnitPrice 
        FROM Warehouse.StockItems
        WHERE StockItemID = @StockItemID;

        -- сообщение для истории изменений
        DECLARE @LogMessage NVARCHAR(4000) = CONCAT(
            'StockItemID = ', @StockItemID, ', NewUnitPrice = ', @UnitPrice, ', OldUnitPrice = ', @OldUnitPrice);
        
        INSERT INTO Warehouse.Logs([Date], Details)
        VALUES(GETDATE(), @LogMessage);
        
        -- обновляем цену в StockItems
        UPDATE Warehouse.StockItems 
        SET UnitPrice = @UnitPrice
        WHERE StockItemID = @StockItemID;    

        -- добавляем SpecialDeals
        INSERT INTO Sales.SpecialDeals
            (StockItemID, UnitPrice, DealDescription, StartDate, EndDate, LastEditedBy)
            VALUES(@StockItemID, @UnitPrice, 'description', SYSDATETIME(), DATEADD(d, 10, GETDATE()), 1);
    COMMIT;
GO

-- Посмотрим, что в таблицах
SELECT * FROM Warehouse.Logs; -- 2
SELECT * FROM Sales.SpecialDeals; -- 3 

-- Не существующий StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 999, @UnitPrice = 11;
-- Ожидаемая ошибка

-- Смотрим, что в таблицах
SELECT * FROM Warehouse.Logs;
SELECT * FROM Sales.SpecialDeals;
SELECT StockItemID, UnitPrice FROM Warehouse.StockItems WHERE StockItemID = 999;
GO
-- вроде работает
-- но есть решение правильнее - TRY/CATCH

-- XACT_ABORT OFF — это значение по умолчанию , а.
-- @XACT_ABORT по умолчанию OFF в инструкциях T-SQL, ON значение по умолчанию в триггере
-- Но можно изменить через user options -- 16384
-- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-user-options-server-configuration-option

EXEC sys.sp_configure N'user options', N'16384';
GO
RECONFIGURE ;
GO

-- Посмотреть текущее значение
DECLARE @XACT_ABORT VARCHAR(3) = 'OFF';
IF ( (16384 & @@OPTIONS) = 16384 ) 
BEGIN
	SET @XACT_ABORT = 'ON';
END
SELECT @XACT_ABORT AS XACT_ABORT;
GO
-- или в SSMS
-- Instance properties -> Connections -> Default connection options


-- ---------------------------
-- TRY / CATCH 
-- ---------------------------
-- см. слайд

-- Ошибок нет
BEGIN TRY
  PRINT 10 / 2;
  PRINT N'Ошибок нет';
END TRY
BEGIN CATCH
  PRINT N'Ошибка';
END CATCH

-- Ошибка
BEGIN TRY
  PRINT 10 / 0;
  PRINT N'Ошибок нет';
END TRY
BEGIN CATCH
  PRINT N'Ошибка';
END CATCH

-- Добавляем TRY / CATCH
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
    @StockItemID INT,
    @UnitPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- <<< это оставляем
    
    BEGIN TRY -- <<<
        BEGIN TRANSACTION;
            DECLARE @OldUnitPrice DECIMAL(18, 2);

            -- получаем старую цену по @StockItemID, чтобы потом сохранить в историю
            SELECT @OldUnitPrice = UnitPrice 
            FROM Warehouse.StockItems
            WHERE StockItemID = @StockItemID;

            -- сообщение для истории изменений
            DECLARE @LogMessage NVARCHAR(4000) = CONCAT(
                'StockItemID = ', @StockItemID, ', NewUnitPrice = ', @UnitPrice, ', OldUnitPrice = ', @OldUnitPrice);    
            INSERT INTO Warehouse.Logs([Date], Details)
            VALUES(GETDATE(), @LogMessage);
        
            -- обновляем цену в StockItems
            UPDATE Warehouse.StockItems 
            SET UnitPrice = @UnitPrice
            WHERE StockItemID = @StockItemID;

            -- добавляем SpecialDeals
            INSERT INTO Sales.SpecialDeals
                (StockItemID, UnitPrice, DealDescription, StartDate, EndDate, LastEditedBy)
                VALUES(@StockItemID, @UnitPrice, 'description', SYSDATETIME(), DATEADD(d, 10, GETDATE()), 1);
        COMMIT;
    END TRY -- <<<
    BEGIN CATCH -- <<<
        PRINT '--- CATCH ---';
        IF @@TRANCOUNT > 0 -- << !!! Обратите внимание на проверку транзакции 
            ROLLBACK;
      
        DECLARE @errorCode INT, @errorMessage NVARCHAR(1000);
          SET @errorCode = ERROR_NUMBER();
        SET @errorMessage = 
            'Server: ' + @@SERVERNAME
            + ', Error: '+ ERROR_MESSAGE() 
            + ', ErrorNumber: ' + CAST(@errorCode AS VARCHAR(10))
            + ', ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(),'')
            + ', ErrorLine: ' + CAST(ERROR_LINE() AS VARCHAR(10));

        PRINT @errorMessage;

        -- Можем дальше бросить ту же ошибку:
        -- RAISERROR (@errorMessage, 16, 1)
        -- или
        -- THROW;

        -- Или отправить более внятный текст:
        THROW 50005, N'Ошибка при изменении цены StockItem', 1;
    END CATCH; -- <<<
END
GO

-- Не существующий StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice  @StockItemID = 999, @UnitPrice = 11;

-- ERROR_LINE() - относительно ХП, а не скрипта
SELECT OBJECT_DEFINITION (OBJECT_ID(N'WideWorldImporters.Warehouse.ChangeStockItemUnitPrice')); 
 
EXEC sp_helptext N'WideWorldImporters.Warehouse.ChangeStockItemUnitPrice';


SELECT * FROM Warehouse.Logs;
SELECT * FROM Sales.SpecialDeals;
SELECT StockItemID, UnitPrice FROM Warehouse.StockItems WHERE StockItemID = 999;

-- Прибираемся за собой
DROP PROCEDURE Warehouse.ChangeStockItemUnitPrice;
DROP TABLE Warehouse.Logs;