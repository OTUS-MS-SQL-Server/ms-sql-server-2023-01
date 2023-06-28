-- Создаем исходную БД
USE master;
GO;

ALTER DATABASE TestReplicationDB SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS TestReplicationDB;
GO
CREATE DATABASE TestReplicationDB;
GO

USE TestReplicationDB;
GO

CREATE TABLE Table1
(
   ID INT IDENTITY PRIMARY KEY,
   [Name] NVARCHAR(50)
)
GO

-- Вставляем данные
USE TestReplicationDB;
GO
INSERT INTO Table1(Name) VALUES('aaa');
GO

-- Смотрим данные
SELECT * FROM Table1;
GO

-- Создаем БД для репликации 
USE master
GO
ALTER DATABASE TestReplicationDB_Copy SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS TestReplicationDB_Copy;
GO
CREATE DATABASE TestReplicationDB_Copy;
GO

-- Смотрим данные
USE TestReplicationDB;
SELECT * FROM Table1;
-- Строка, которую до этого вставили
GO

USE TestReplicationDB_Copy;
SELECT * FROM Table1;
-- Таблицы Table1 нет, что логично
GO

-- Создать публикацию в SSMS
-- (репликация транзакций)
-- ...

-- Создать подписку в SSMS
-- ...

-- Смотрим данные
USE TestReplicationDB;
SELECT * FROM Table1;
GO

USE TestReplicationDB_Copy;
SELECT * FROM Table1;
-- Table1 появилась автоматически
GO

-- Запустить в отдельном окне "нагрузку" из Load.sql

-- Опять смотрим данные
USE TestReplicationDB;
SELECT * FROM Table1;

USE TestReplicationDB_Copy;
SELECT * FROM Table1;
GO

-- --------------
-- DELETE
-- --------------
USE TestReplicationDB;
DELETE FROM Table1 
WHERE ID > 2;
GO

-- Опять смотрим данные
USE TestReplicationDB;
SELECT * FROM Table1;

USE TestReplicationDB_Copy;
SELECT * FROM Table1;
GO

-- --------------
-- UPDATE
-- --------------
USE TestReplicationDB;
UPDATE Table1 
SET Name = 'updated_name'
WHERE ID < 5;
GO

-- Опять смотрим данные
USE TestReplicationDB
SELECT * FROM Table1;

USE TestReplicationDB_Copy
SELECT * FROM Table1;
GO

-- --------------
-- А если изменим реплику? (TestReplicationDB_Copy)
-- --------------
USE TestReplicationDB_Copy
UPDATE Table1 
SET Name = 'changed_on_replica'
WHERE ID < 5;

USE TestReplicationDB
SELECT * FROM Table1;

USE TestReplicationDB_Copy
SELECT * FROM Table1;

-- а теперь то же самое на исходной БД
USE TestReplicationDB
UPDATE Table1 
SET Name = 'changed_on_primary'
WHERE ID < 5;

USE TestReplicationDB
SELECT * FROM Table1;

USE TestReplicationDB_Copy
SELECT * FROM Table1;

-- SSMS Replication Monitor



