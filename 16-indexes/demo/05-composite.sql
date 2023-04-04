-- =========================================
-- Составные индексы
-- Composite indexes
-- =========================================

USE WideWorldImporters;

-- -------------------------------------------------
-- WHERE Population = 422
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Population_Name
ON [Application].[Cities](LatestRecordedPopulation, CityName);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE LatestRecordedPopulation = 422;
GO

-- -------------------------------------------------
-- WHERE CityName = 'Davis'
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Population_Name
ON [Application].[Cities](LatestRecordedPopulation, CityName);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE CityName = 'Davis';
GO

-- -------------------------------------------------
-- WHERE Population = 422 and CityName = 'Davis'
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Population_Name
ON [Application].[Cities](LatestRecordedPopulation, CityName);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE LatestRecordedPopulation = 422 AND CityName = 'Davis';
GO

-- -------------------------------------------------
-- WHERE Population > 422 and CityName = 'Davis'
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Population_Name
ON [Application].[Cities](LatestRecordedPopulation, CityName);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE LatestRecordedPopulation > 422 AND CityName = 'Davis';
GO

-- -------------------------------------------------
-- IX_Name_Population
-- WHERE Population = 422 and CityName = 'Davis'
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Name_Population
ON [Application].[Cities](CityName, LatestRecordedPopulation);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE LatestRecordedPopulation = 422 AND CityName = 'Davis';
GO

-- -------------------------------------------------
-- IX_Name_Population
-- WHERE Population > 422 and CityName = 'Davis'
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Name_Population
ON [Application].[Cities](CityName, LatestRecordedPopulation);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE LatestRecordedPopulation > 422 AND CityName = 'Davis';
GO

-- -------------------------------------------------
-- WHERE Population = 422 or CityName = 'Davis'
-- -------------------------------------------------
DROP INDEX IF EXISTS IX_Population_Name ON [Application].[Cities];
DROP INDEX IF EXISTS IX_Name_Population ON [Application].[Cities];
GO

CREATE INDEX IX_Population_Name
ON [Application].[Cities](LatestRecordedPopulation, CityName);
GO

CREATE INDEX IX_Name_Population
ON [Application].[Cities](CityName, LatestRecordedPopulation);
GO

SELECT CityName, LatestRecordedPopulation 
FROM [Application].[Cities]
WHERE LatestRecordedPopulation = 422 OR CityName = 'Davis';
GO

