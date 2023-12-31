USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[WBC_spInjuryCounts]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Desai,Khyati>
-- Create date: <February 10 2020>
-- Description:	<Injury Map stored procedure, It will display info on WBC label map>
-- =============================================
CREATE PROCEDURE [dbo].[WBC_spInjuryCounts]
	@ClientID int,
	@ClassId int, 
	@StartDate date,
	@EndDate date
AS
	BEGIN

	IF @ClientID<>0
	BEGIN
	SELECT LabelID, count(*) as LblCnt FROM WBC_MainDataTable M where M.ActiveStatus='A' and M.StudentID = @ClientID and (M.IdentifiedDate between @StartDate and @EndDate) group by LabelID

	END

	


	END
GO
