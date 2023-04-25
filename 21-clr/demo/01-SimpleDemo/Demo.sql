USE WideWorldImporters;

-- Чистим от предыдущих экспериментов
DROP FUNCTION IF EXISTS dbo.fn_SayHello;
GO
DROP PROCEDURE IF EXISTS dbo.usp_SayHello;
GO
DROP ASSEMBLY IF EXISTS SimpleDemoAssembly;
GO

-- Включаем CLR
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 0;
GO

-- clr strict security 
-- 1 (Enabled): заставляет Database Engine игнорировать сведения PERMISSION_SET о сборках 
-- и всегда интерпретировать их как UNSAFE. По умолчанию, начиная с SQL Server 2017.

RECONFIGURE;
GO

-- Для возможности создания сборок с EXTERNAL_ACCESS или UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- Подключаем dll 
-- Измените путь к файлу!
CREATE ASSEMBLY SimpleDemoAssembly
FROM 'C:\vagrant\2021-08\13-clr_hw\examples\01-SimpleDemo\bin\Debug\SimpleDemo.dll'
WITH PERMISSION_SET = SAFE;  

-- DROP ASSEMBLY SimpleDemoAssembly

-- Файл сборки (dll) на диске больше не нужен, она копируется в БД

-- Как посмотреть зарегистрированные сборки 

-- SSMS
-- <DB> -> Programmability -> Assemblies 

-- Посмотреть подключенные сборки (SSMS: <DB> -> Programmability -> Assemblies)
SELECT name, principal_id, assembly_id, clr_name, permission_set, permission_set_desc, is_visible, create_date, modify_date, is_user_defined
FROM sys.assemblies;
GO

-- Подключить функцию из dll - AS EXTERNAL NAME
CREATE FUNCTION dbo.fn_SayHello(@Name NVARCHAR(100))  
RETURNS NVARCHAR(100)
AS EXTERNAL NAME [SimpleDemoAssembly].[ExampleNamespace.DemoClass].SayHelloFunction;
GO 

-- Без namespace будет так:
-- [SimpleDemoAssembly].[DemoClass].SayHelloFunction

-- Используем функцию
SELECT dbo.fn_SayHello('OTUS Student');
GO

-- Подключить процедуру из dll - AS EXTERNAL NAME 
CREATE PROCEDURE dbo.usp_SayHello  
(  
    @Name NVARCHAR(50)
)  
AS EXTERNAL NAME [SimpleDemoAssembly].[ExampleNamespace.DemoClass].SayHelloProcedure;  
GO 

-- Используем ХП
EXEC dbo.usp_SayHello @Name = 'OTUS Student';

-- --------------------------

-- Список подключенных CLR-объектов
SELECT object_id, assembly_id, assembly_class, assembly_method, null_on_null_input, execute_as_principal_id
FROM sys.assembly_modules;

-- Посмотреть "код" сборки
-- SSMS: <DB> -> Programmability -> Assemblies -> Script Assembly as -> CREATE To