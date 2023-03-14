  SET STATISTICS IO,TIME ON;
  with SessionResult as(
		select UserID,
			   Session,
			   Success,
			   Count(*) Count 
		from Calculate.UsersResult
		group by UserID,Session,Success
	)
  	select
			Cast(us.ResultDateStamp as nvarchar(Max)) [Дата],
			Cast(us.Time as nvarchar(Max)) [Длительность прохождения],
			Cast(isnull(srS.Count,0) as nvarchar(Max)) [Количество правильных ответов],
			Cast(isnull(srF.Count,0)+isnull(srS.Count,0) as nvarchar(Max)) [Всего вопросов]
	from [Calculate].[UsersScore] us
	join Users.Main um on um.Id=us.UserId
	left join SessionResult srF on srF.UserId=us.UserId and srF.Session=us.Session and srF.Success=0
	left join SessionResult srS on srS.UserId=us.UserId and srS.Session=us.Session and srS.Success=1
	where us.UserID=1
	order by us.ResultDateStamp desc
	
	select s.ResultDateStamp [Дата],
		   s.Time [Длительность прохождения], 
		   s.score [Количество правильных ответов], 
		   sum(CASE WHEN (r.success = 0 or r.Success is null) THEN 0 ELSE 1 END) [Количество правильных ответов], 
		   --sum(IIF(isnull(r.success,0)=0,0,1)) [Количество правильных ответов], 
		   --sum(f.x) [Количество правильных ответов], 
		   count(r.EquationId) [Всего вопросов] 
	from Calculate.UsersScore s 
	left join Calculate.UsersResult r on s.session = r.session 
	--cross apply (select 
	--					CASE WHEN (r.success = 0 or r.Success is null) 
	--					THEN 0 ELSE 1 
	--			 END) f(x)
	where s.UserId = 1
	group by s.[ResultDateStamp], s.[Time], s.score
	order by s.ResultDateStamp desc







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