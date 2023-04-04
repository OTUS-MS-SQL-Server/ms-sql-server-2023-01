-- =========================================
-- Фильтрованные индексы
-- Filtered index
-- =========================================

USE WideWorldImporters;

-----------------------------------
-- Фильтрованные  (WHERE)
-----------------------------------

-- UNIQUE

CREATE TABLE #demo(
	Col INT NULL UNIQUE(Col)   
);

INSERT INTO #demo VALUES(1);
INSERT INTO #demo VALUES(1);
INSERT INTO #demo VALUES(NULL);
INSERT INTO #demo VALUES(NULL);

SELECT Col FROM #demo;

-- А если хотим, чтобы было несколько NULL, 
-- но остальные значения уникальные?

-- FILTERED INDEX

CREATE TABLE #demo2(
	Col INT NULL
);

CREATE UNIQUE NONCLUSTERED INDEX IX_Col
ON #demo2(Col)
WHERE(Col IS NOT NULL);

INSERT INTO #demo2 VALUES(1);
INSERT INTO #demo2 VALUES(1);
INSERT INTO #demo2 VALUES(NULL);
INSERT INTO #demo2 VALUES(NULL);

SELECT Col FROM #demo2;
