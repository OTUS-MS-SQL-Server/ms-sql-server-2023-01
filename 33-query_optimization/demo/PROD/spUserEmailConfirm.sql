USE [SyncUser]
GO
/****** Object:  StoredProcedure [dbo].[spUserEmailConfirm]    Script Date: 2/28/2017 9:30:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spUserEmailConfirm]
	@token CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ltoken CHAR(10)

	SELECT @ltoken = @token

    SET ROWCOUNT 1;
    DECLARE @userId INT, @email NVARCHAR(254), @status tinyint;
    
    -- enable the user's account if they are unverified with a matching token
    UPDATE dbo.User SET [Status] = 1
		WHERE Active = 1 
			AND EmailConfirmToken = @ltoken
			AND [Status] = 4;
    
    SELECT @userId = UserId, @email = Email, @status = [Status]
    FROM dbo.User
    WHERE Active = 1 AND DateEmailConfirmed IS NULL AND EmailConfirmToken = @ltoken;
    
    IF (@userId IS NOT NULL)
    BEGIN   
		UPDATE dbo.User SET DateEmailConfirmed = GETUTCDATE()
		WHERE Active = 1 
			AND DateEmailConfirmed IS NULL
			AND EmailConfirmToken = @ltoken;

		-- deleting all secondary instatnces of that email (confirmed or not)
		DELETE FROM dbo.UserEmailList WHERE Email = @email;

		SELECT 4 AS Result, @userId AS UserId, @email AS Email; -- PrimaryConfirmed
	END
	ELSE
	BEGIN
		SELECT @userId = UserId, @email = Email
		FROM dbo.UserEmailList UE
		WHERE DateConfirmed IS NULL 
			AND ConfirmToken = @ltoken
			AND EXISTS (SELECT * FROM dbo.User U WHERE U.UserId = UE.UserId AND U.Active = 1);
			
		IF (@userId IS NOT NULL)
		BEGIN
			
			IF EXISTS (SELECT 1 FROM dbo.User U WHERE U.Active = 1 AND U.Email = @email AND U.DateEmailConfirmed IS NOT NULL )
			   OR EXISTS (SELECT 1 FROM dbo.UserEmailList UE WHERE UE.UserId = @userId AND UE.Email = @email AND UE.Confirmed = 1)
			BEGIN
				-- deleting this instance of email
				DELETE FROM dbo.UserEmailList WHERE ConfirmToken = @ltoken;

				SELECT 3 AS Result, NULL as UserId, NULL as Email; -- BelognsToAnother
			END
			
			UPDATE dbo.UserEmailList SET DateConfirmed = GETUTCDATE(), Confirmed = 1
			FROM dbo.UserEmailList UE
			WHERE DateConfirmed IS NULL
				AND ConfirmToken = @ltoken
				AND UserId = @userId;

			-- deleting all secondary instatnces of that email (all of them are not confirmed)
			DELETE FROM dbo.UserEmailList WHERE Email = @email and ConfirmToken != @ltoken;;

			SELECT 1 AS Result, @userId AS UserId, @email AS Email; -- Confirmed
		END
		ELSE IF (EXISTS (SELECT 1 FROM dbo.User WHERE EmailConfirmToken = @ltoken) OR
				 EXISTS (SELECT 1 FROM dbo.UserEmailList WHERE ConfirmToken = @ltoken))
			-- Token already redeemed
			BEGIN
				SELECT 2 AS Result, UserId AS UserId, Email AS Email
				FROM dbo.User
				WHERE EmailConfirmToken = @ltoken; -- PreviouslyConfirmed
			END;
		ELSE
			SELECT 0 AS Result, NULL AS UserId, NULL AS Email; -- NotFound
	END;
		
	SET ROWCOUNT 0;
END
