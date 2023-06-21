
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
	SET XACT_ABORT ON;

	DECLARE @ltoken CHAR(10)

	SET @ltoken = @token;

    DECLARE @userId INT, 
			@email NVARCHAR(254), 
			@status tinyint,
			@dateEmailConfirmed DATETIME,
			@dateEmailConfirmedNew DATETIME = GETUTCDATE(),
			@result INT = 0;

	--select UserId to use it as filter for SP 
	--to use PK for all other select and update statements
	SELECT @userID = userId
	FROM dbo.User WITH (NOLOCK)
	WHERE Active = 1 
		AND EmailConfirmToken = @ltoken;

	IF @userId IS NOT NULL
	BEGIN
		--select one more time from User
		--to use PK and avoid key lookup
		SELECT @email = Email, 
			@status = [Status],
			@dateEmailConfirmed = DateEmailConfirmed
		FROM dbo.User
		WHERE Active = 1 
			AND userId = @userID;
		  
		BEGIN TRAN
		-- enable the user's account if they are unverified with a matching token
		-- we need to do update with dateEmailConfirmed even if status is not 4
		-- and if status 4 Unverified we update status to 1, even if dateEmailConfirmed has value
		IF @status = 4 
			OR @dateEmailConfirmed IS NULL
		BEGIN
			UPDATE dbo.User 
			SET	DateEmailConfirmed = COALESCE(DateEmailConfirmed, @dateEmailConfirmedNew),
				[Status] = CASE [Status] WHEN 4 THEN 1 ELSE [Status] END
			WHERE Active = 1 
				AND userId = @userID;
		END

		IF @dateEmailConfirmed IS NULL
		BEGIN 
			-- deleting all secondary instances of that email (confirmed or not)
			DELETE FROM dbo.UserEmailList 
			WHERE Email = @email;

			SET @result = 4;
		END;
		COMMIT TRAN
		
		IF @result = 0 
			AND @dateEmailConfirmed IS NOT NULL
		BEGIN
			--already confirmed
			SET @result = 2
		END;
	END;

	--if there is no user with this token in User 
	--then check UserEmailList
	IF @result = 0 AND @userId IS NULL
	BEGIN
		SELECT 
			@userId = UserId, 
			@email = Email,
			@dateEmailConfirmed = DateConfirmed
		FROM dbo.UserEmailList UE
		WHERE ConfirmToken = @ltoken
			AND EXISTS (SELECT * 
						FROM dbo.User U WITH (NOLOCK)
						WHERE U.UserId = UE.UserId 
							AND U.Active = 1);

		IF @userId IS NOT NULL
		BEGIN
			--check that this Email is not confirmed 
			IF EXISTS (SELECT 1 FROM dbo.User U WHERE U.Active = 1 AND U.Email = @email AND U.DateEmailConfirmed IS NOT NULL)
				OR EXISTS (SELECT 1 FROM dbo.UserEmailList UE WHERE UE.UserId = @userId AND UE.Email = @email AND UE.Confirmed = 1)
			BEGIN
				--this email is already confirmed in other session
				-- deleting this instance of email
				DELETE FROM dbo.UserEmailList WHERE ConfirmToken = @ltoken;

				SET @result = 3;
				SET @userId = NULL;
				SET @Email = NULL;
			END
			ELSE --if this email is not Confirmed  
			BEGIN
				IF @dateEmailConfirmed IS NULL
				BEGIN
					BEGIN TRAN 
					UPDATE dbo.UserEmailList 
					SET DateConfirmed = GETUTCDATE(), 
						Confirmed = 1
					WHERE DateConfirmed IS NULL
						AND ConfirmToken = @ltoken
						AND UserId = @userId;

					-- deleting all secondary instatnces of that email (all of them are not confirmed)
					DELETE FROM dbo.UserEmailList 
					WHERE Email = @email 
						AND ConfirmToken != @ltoken;
					COMMIT TRAN

					SET @result = 1;-- Confirmed
				END
				ELSE
				BEGIN
					SET @result = 2;--already Confirmed
				END;
			END;
		END;
	END;

	SELECT @result AS Result, @userId AS UserId, @email AS Email; -- PrimaryConfirmed
END
GO
