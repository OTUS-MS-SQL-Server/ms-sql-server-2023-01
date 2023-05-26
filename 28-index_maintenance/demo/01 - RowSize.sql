-- https://www.microsoftpressstore.com/articles/article.aspx?p=2225060

DROP TABLE IF EXISTS #bigrows_fixed;
DROP TABLE IF EXISTS #bigrows;

-- Можно ли создать такую таблицу?
CREATE TABLE #bigrows_fixed
(
    a CHAR(3000),
    b CHAR(3000),
    c CHAR(2000),
    d CHAR(60) 
);
GO

DROP TABLE IF EXISTS  #bigrows;

-- А такую?
CREATE TABLE #bigrows
(
   a VARCHAR(3000),
   b VARCHAR(3000),
   c VARCHAR(3000),
   d VARCHAR(3000) 
);
GO
