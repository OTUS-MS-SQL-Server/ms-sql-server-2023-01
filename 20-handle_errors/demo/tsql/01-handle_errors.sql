/* tsqllint-disable error conditional-begin-end */
/* tsqllint-disable error select-star */
/* tsqllint-disable error print-statement */

-- ----------------------------
-- Обработка ошибок
-- ----------------------------

USE WideWorldImporters;
GO
-- Создадим ХП

-- Процедура изменяет стоимость (UnitPrice) товара (StockItem)

CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
    @StockItemID INT,
    @UnitPrice DECIMAL(18,2)
AS
  UPDATE Warehouse.StockItems
  SET UnitPrice = @UnitPrice
  WHERE StockItemID = @StockItemID;
GO

-- Проверим работу ХП с существующим StockItemID = 10

-- Текущая стоимость товара UnitPrice = 32.00
SELECT StockItemID, UnitPrice 
FROM Warehouse.StockItems 
WHERE StockItemID = 10;

-- Изменяем стоимость на 55.00
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 10, @UnitPrice = 55;

-- Проверяем, что стоимость изменилась
SELECT StockItemID, UnitPrice 
FROM Warehouse.StockItems 
WHERE StockItemID = 10;

-- Проверим работу ХП с НЕ существующим StockItemID

-- Если передадим несуществующее StockItemID = 1000
SELECT StockItemID, UnitPrice 
FROM Warehouse.StockItems 
WHERE StockItemID = 1000;

EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 30;
GO
-- Ошибок нет и вроде видно, что ничего не изменилось:
-- (0 rows affected)
-- (Затронуто строк: 0)

-- SET NOCOUNT ON; - не возвращать количество обработанных строк (rows affected)
-- https://docs.microsoft.com/ru-ru/sql/t-sql/statements/set-nocount-transact-sql
-- Если SET NOCOUNT равно ON, то количество строк не возвращается. 
-- Если SET NOCOUNT равно OFF, то количество строк возвращается.

-- Добавим SET NOCOUNT ON (что часто бывает в реальной жизни и это best practice)
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
    @StockItemID INT,
    @UnitPrice DECIMAL(18,2)
AS
  SET NOCOUNT ON; -- <<< добавили
  
  UPDATE Warehouse.StockItems
  SET UnitPrice = @UnitPrice
  WHERE StockItemID = @StockItemID;
GO

-- Тогда совсем не понятно успешно выполнилась операция или нет
-- для переданного StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 30;
GO

-- Попробуем добавить сообщение об ошибке

-- Добавляем сообщение об ошибке с помошью PRINT
CREATE OR ALTER PROCEDURE Warehouse.ChangeStockItemUnitPrice
    @StockItemID INT,
    @UnitPrice DECIMAL(18,2)
AS
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT * FROM Warehouse.StockItems WHERE StockItemID = @StockItemID) -- <<<
        PRINT CONCAT(N'Ошибка. Не найден StockItemID = ', @StockItemID); -- <<<
    ELSE
        UPDATE Warehouse.StockItems
        SET UnitPrice = @UnitPrice
        WHERE StockItemID = @StockItemID;
GO

-- Проверим, что работает с существующим StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 10, @UnitPrice = 77;

-- Проверим, что стоимость изменилась
SELECT StockItemID, UnitPrice 
FROM Warehouse.StockItems 
WHERE StockItemID = 10;

-- Снова попробуем с несуществующим StockItemID
EXEC Warehouse.ChangeStockItemUnitPrice @StockItemID = 1000, @UnitPrice = 350;
GO

-- Вроде есть сообщение "Ошибка. Не найден StockItemID = 1000"
-- Мы можем понять, что есть ошибка.

-- В чем же проблема?
-- Смотрим пример клиентского приложения в Visual Studio