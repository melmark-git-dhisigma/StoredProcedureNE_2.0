USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[WBC_spInjuryMap]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Desai,Khyati>
-- Create date: <February 10 2020>
-- Description:	<Injury Map stored procedure, It will display info about the injuries on label selected>
-- =============================================
CREATE PROCEDURE [dbo].[WBC_spInjuryMap]
	@ClientID varchar(20),
	@LblID varchar(20),
	@StartDate varchar(20),
	@EndDate varchar(20)
AS
	BEGIN

	select CONCAT(BodyPartIDLvl1,' - ',BodyPartIDLvl2,' - ',BodyPartIDLvl3,' (',LabelLocFtorBk,') : ') AS [LabelDesc] 
	from WBC_LookupTable 
	where LabelNo=@LblID and ActiveStatus='A' and QualifyingID='LabelLoc';

	SELECT InjuryLocText as [Inujry Location],COUNT(*) AS [Total] 
	FROM WBC_MainDataTable 
	WHERE StudentID=@ClientID AND LabelID=@LblID AND (IdentifiedDate BETWEEN @StartDate AND @EndDate) AND ActiveStatus='A' 
	GROUP BY InjuryLocText;
	
	SELECT InjuryOriginText as [Inujry Origin],COUNT(*) AS [Total] 
	FROM WBC_MainDataTable 
	WHERE StudentID=@ClientID AND LabelID=@LblID AND (IdentifiedDate BETWEEN @StartDate AND @EndDate) AND ActiveStatus='A' 
	GROUP BY InjuryOriginText;

	SELECT InjuryTypeText as [Inujry Type],COUNT(*) AS [Total] 
	FROM WBC_MainDataTable 
	WHERE StudentID=@ClientID AND LabelID=@LblID AND (IdentifiedDate BETWEEN @StartDate AND @EndDate) AND ActiveStatus='A' 
	GROUP BY InjuryTypeText


	END


GO
