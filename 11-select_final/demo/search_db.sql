DECLARE @TextForSearch NVARCHAR(MAX)=N'';
--SET @TextForSearch=N'Текст для поиска';
SELECT *
FROM [sys].[objects]
WHERE --[type] IN(N'P',N'TR') AND 
OBJECT_DEFINITION([object_id])
LIKE N'%'+REPLACE(REPLACE(REPLACE(@TextForSearch,N'[',N'[[]'),N'%',N'[%]'),N'_',N'[_]')+N'%';

--https://download.red-gate.com/installers/SQL_Search/2019-12-19/SQL_Search.exe
