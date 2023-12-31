USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_GetUserEvents]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UINE_GetUserEvents]
     -- Add the parameters for the stored procedure here
     @AgencyFlag varchar(10),
     @UserID int
AS
BEGIN
     -- SET NOCOUNT ON added to prevent extra result sets from
     -- interfering with SELECT statements.
     SET NOCOUNT ON;


 if @AgencyFlag='MCS'
Begin

SELECT UIEventID,[UIEventNum] FROM UINE_Events where AgencyFlag='MCS' and ActiveInd='A' and SendEmailID=@UserID order by UIEventID desc

END

ELSE

Begin

SELECT UIEventID,[UIEventNum] FROM UINE_Events where AgencyFlag!='MCS' and ActiveInd='A' and SendEmailID=@UserID order by UIEventID desc

END

END

GO
