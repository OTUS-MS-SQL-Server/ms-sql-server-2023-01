USE TestReplicationDB;

DECLARE @n INT = 1;

WHILE 1 = 1
BEGIN	
	INSERT INTO Table1([Name])
	VALUES ('name' + cast(@n as nvarchar(10)));

	WAITFOR DELAY '00:00:05';	
	SET @n = @n + 1;
END;