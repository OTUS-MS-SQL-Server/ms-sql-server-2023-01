SET NOCOUNT ON;

DECLARE @Conversation uniqueidentifier;

WHILE EXISTS(SELECT 1 FROM sys.transmission_queue)
BEGIN
  SET @Conversation = 
                (SELECT TOP(1) conversation_handle 
                                FROM sys.transmission_queue);
  END CONVERSATION @Conversation WITH CLEANUP;
END;



--END CONVERSATION '74360DB8-4C88-E911-B304-D053495EBE5E' WITH CLEANUP;