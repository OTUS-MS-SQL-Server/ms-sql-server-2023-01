SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON

REVOKE EXECUTE ON  [dbo].[spUserInsert] TO [SyncWebsite]
REVOKE EXECUTE ON  [dbo].[spUserInsert] TO [SyncXml]

REVOKE EXECUTE ON  [dbo].[spUserEmailConfirm] TO [SyncWebsite]
REVOKE EXECUTE ON  [dbo].[spUserEmailConfirm] TO [SyncXml]

REVOKE EXECUTE ON  [dbo].[spUserLoginFailure] TO [SyncWebsite]
REVOKE EXECUTE ON  [dbo].[spUserLoginFailure] TO [SyncXml]

CREATE NONCLUSTERED INDEX IX_User_EmailConfirmToken_Active_Status
ON [dbo].[User] ([EmailConfirmToken],[Active],[Status])
WITH (ONLINE = ON);

GRANT EXECUTE ON  [dbo].[spUserInsert] TO [SyncWebsite]
GRANT EXECUTE ON  [dbo].[spUserInsert] TO [SyncXml]

GRANT EXECUTE ON  [dbo].[spUserEmailConfirm] TO [SyncWebsite]
GRANT EXECUTE ON  [dbo].[spUserEmailConfirm] TO [SyncXml]

GRANT EXECUTE ON  [dbo].[spUserLoginFailure] TO [SyncWebsite]
GRANT EXECUTE ON  [dbo].[spUserLoginFailure] TO [SyncXml]

