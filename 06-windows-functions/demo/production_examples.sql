INSERT INTO #IrmObjectsThatCanBeDeletedTemp 
SELECT FileUnqId, VersionNumber, FolderId, StorageEndpointId 
FROM 
	(
	SELECT TOP 10000 GFI.FileUnqId, 
	RANK() OVER(PARTITION BY DFV.DataFileId ORDER BY DFV.GenerationId DESC) AS VersionNumber,
	DFV.FolderId, NULL AS StorageEndpointId
	FROM 
		[dbo].[SD(Id)_DataFile] DF WITH (NOLOCK)
			INNER JOIN [dbo].[SD(Id)_DataFileVersion] DFV WITH (NOLOCK) 
				ON (DF.DataFileId = DFV.DataFileId AND DF.FolderId = DFV.FolderId)
			INNER JOIN dbo.FileIrm GFI WITH (NOLOCK) 
				ON (DF.DataFileId = GFI.DataFileId AND DF.FolderId = GFI.FolderId
				AND DFV.FileId = GFI.FileId)
	)T
WHERE VersionNumber > 1

WITH Q
AS (
	SELECT S.[UserFolderId]
		,S.ParentDirId
		,S.NAME
		,Active = 1
		,DirversionId = 1
		,S.NameDataLength
		,S.FolderId
		,ROW_NUMBER() OVER (
			ORDER BY [UserFolderId]
			) AS RN
	FROM #userDirs S
	WHERE DirId IS NULL
	)
INSERT INTO [dbo].[DataDirectory_BigInt] (
	DirId
	,[UserFolderId]
	,ParentDirId
	,NAME
	,Active
	,DirVersionId
	,DirNameDataLength
	)
OUTPUT INSERTED.DirId
	,INSERTED.[UserFolderId]
	,INSERTED.ParentDirId
	,0
	,INSERTED.DirVersionId
	,Inserted.NAME
INTO @dirIds(DirId, [UserFolderId], ParentDirId, Active, DirVersionId, NAME)
SELECT (
		SELECT LongValue
		FROM #tmp_LongIds T
		WHERE Q.RN = T.ID
		) AS DirId
	,[UserFolderId]
	,ParentDirId
	,NAME
	,Active
	,DirVersionId
	,NameDataLength
FROM Q;


SELECT V.DataFileVersionId, 
	V.DataSourceId, 
	V.FileId, 
	V.Length,
	V.LastWriteTimeUtc, 
	V.DateAdded, 
	V.DirVersionId,
	ROW_NUMBER() OVER (PARTITION BY V.DirVersionId ORDER BY V.DateAdded DESC)
 dbo.vwDataFileVersion V WITH (NOLOCK)
E V.DataFileId = @dataFileId
AND V.[UserFolderId] = @UserFolderId
R BY V.DataFileVersionId;


WITH Seq
AS (
	SELECT TOP (10) ROW_NUMBER() OVER (
			ORDER BY object_id
			) AS RN
	FROM sys.objects
	)
INSERT INTO #dirs (
	FolderId
	,ParentDirId
	,NAME
	)
SELECT FolderId
	,DirId
	,CONVERT(NVARCHAR(5), @dirLevel) + '-' + CONVERT(NVARCHAR(5), Seq.RN)
FROM #insertedDirs
INNER JOIN Seq ON (1 = 1);
-------------

UPDATE tFolder
SET rowid = rowidtbl.rowid
FROM #tmp_Folder AS tFolder
	JOIN (SELECT ROW_NUMBER() OVER (ORDER BY DataFileVersionToDeleteCount DESC) as rowid, vfId, vfOwnerId, UserFolderId
		  FROM #tmp_Folder) AS rowidtbl ON 
		tFolder.vfId = rowidtbl.vfId
		AND tFolder.vfOwnerId = rowidtbl.vfOwnerId
		AND tFolder.[UserFolderId] = rowidtbl.[UserFolderId];	

SELECT 
	Extension
   ,[Description]
   ,UserId
   ,FirstName 
   ,LastName
   ,Email
   ,[Status]
   ,ActiveFileNumber
   ,ActiveBytes
   ,DeletedBytes
   ,TotalBytes
   ,PreviousVersionBytes
   ,ROW_NUMBER() OVER (ORDER BY 
	CASE WHEN @lorderBy = 1 AND @lorderByDirection = 1 THEN [TotalBytes] END,  
	CASE WHEN @lorderBy = 2 AND @lorderByDirection = 1 THEN [ActiveBytes] END,  
	CASE WHEN @lorderBy = 3 AND @lorderByDirection = 1 THEN [PreviousVersionBytes] END,  
	CASE WHEN @lorderBy = 4 AND @lorderByDirection = 1 THEN [DeletedBytes]  END,  
	CASE WHEN @lorderBy = 5 AND @lorderByDirection = 1 THEN [ActiveFileNumber] END,
	CASE WHEN @lorderBy = 1 AND @lorderByDirection = 2 THEN [TotalBytes] END DESC,  
	CASE WHEN @lorderBy = 2 AND @lorderByDirection = 2 THEN [ActiveBytes] END DESC,  
	CASE WHEN @lorderBy = 3 AND @lorderByDirection = 2 THEN [PreviousVersionBytes] END DESC,  
	CASE WHEN @lorderBy = 4 AND @lorderByDirection = 2 THEN [DeletedBytes] END DESC,  
	CASE WHEN @lorderBy = 5 AND @lorderByDirection = 2 THEN [ActiveFileNumber] END DESC, 
	Extension) AS RowId				
FROM PropertyExtendedResult;


with SRC as (	select 		pr.Product		, pr.Price Price		, pr.Date BeginDate		, isNull(dateadd(day, -1, lead(pr.Date) 			over (partition by pr.Product order by pr.Date)), N'29990101') as EndDate	from sch.Prices pr)select pt.Product,s.Price SoldByPrice from sch.plantable pt	left join SRC s 
	on pt.SoldDate 
		between BeginDate and EndDate and s.Product=pt.Product
