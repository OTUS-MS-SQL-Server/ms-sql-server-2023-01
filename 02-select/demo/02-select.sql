/* tsqllint-disable error select-star */

USE WideWorldImporters;

-- просто константы
SELECT 1, N'какой-то текст', 10 * 123, 'abc' + 'def';

-- звездочку лучше не использовать
-- лишнее чтение с диска и использование памяти
-- (и приложение может сломаться, если оно не ожидает или ожидает какие-то колонки)
SELECT *
FROM Application.Cities;
-- Application.Cities - справочник городов

-- лучше выбирать только нужные поля
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities;

-- алиасы (псевдонимы) колонок
SELECT 
    CityID,
    CityName AS City,
    CityName City2,
    CityName AS [City Name],
    CityName AS "City Name Again",
    City3 = CityName,
    c.StateProvinceID
FROM Application.Cities AS c;

-- а так будет работать? 
-- что здесь странного?
SELECT
    CityID,
    CityName AS City,
    CityName City,
    CityName AS City,
    City3 = CityName,
    c.StateProvinceID
FROM Application.Cities AS c;

-- -------------------------------
--  ORDER BY - сортировка
-- -------------------------------
-- не забывайте, что без ORDER BY порядка нет

-- ORDER BY
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities
ORDER BY CityName; -- ASC

-- ORDER BY (несколько колонок), ASC / DESC
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities c
ORDER BY c.StateProvinceID ASC, c.CityName DESC;

-- А так что будет? ORDER BY 1, 2, 3
-- Выполниться запрос?
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities c
ORDER BY 1, 2, 3;

-- -------------------------------
--  DISTINCT - удаление дублей
-- -------------------------------

SELECT 
    CityName AS City
FROM Application.Cities;

SELECT DISTINCT 
    CityName AS City
FROM Application.Cities;
GO

-- несколько колонок => уникальные строки
SELECT DISTINCT 
    CityName AS City,
    CityID,
    StateProvinceID
FROM Application.Cities;

-- -------------------------------
-- TOP - первые N записей
-- -------------------------------
-- по какому принципу (cортировка) сервер отобрал первые 10 записей?
SET STATISTICS TIME ON;

SELECT TOP 10
    CityID,
    CityName AS City,
    CityName City2,
    City3 = CityName,
    StateProvinceID
FROM Application.Cities;

-- а здесь?
SELECT TOP 10 
    CityID,
    CityName AS City, 
    CityName City2,
    City3 = CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY City;

SET STATISTICS TIME OFF;

-- А какой из запросов быстрее?
-- А насколько?
-- Смотрим вкладку Messages и планы запросов

-- Дополнительные материалы:
-- "Почему SQL Server не гарантирует сортировку результатов без ORDER BY"
-- https://habr.com/ru/company/otus/blog/504144/
--
-- "Использование SET STATISTICS TIME ON в SQL Server"
-- https://habr.com/ru/company/otus/blog/572854/

-- -------------------------------
-- TOP WITH TIES
-- -------------------------------
SELECT TOP 3 
    CityID, 
    CityName AS City, 
    CityName City2, 
    City3 = CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY City;

SELECT TOP 3 WITH TIES
    CityID, 
    CityName AS City, 
    CityName City2, 
    City3 = CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY City;
GO

-- -------------------------------
-- OFFSET - разбивка по страницам
-- с SQL Server 2012
-- -------------------------------

SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName;

SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName
OFFSET 10 ROWS FETCH FIRST 5 ROWS ONLY;
GO

-- упрощенный OFFSET
SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName
OFFSET 10 ROWS;

-- постраничный вывод
DECLARE 
    @pagesize BIGINT = 10, -- Размер страницы
    @pagenum  BIGINT = 3;  -- Номер страницы

SELECT 
    CityID, 
    CityName AS City,
    StateProvinceID
FROM Application.Cities
ORDER BY City, CityID
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY; 

-- а если не будет ORDER BY, то будет ли работать OFFSET ?
/*
SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
OFFSET 1 ROWS FETCH FIRST 5 ROWS ONLY;
*/


-- OFFSET - это часть ORDER BY 
SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName
OFFSET 1 ROWS FETCH FIRST 5 ROWS ONLY;