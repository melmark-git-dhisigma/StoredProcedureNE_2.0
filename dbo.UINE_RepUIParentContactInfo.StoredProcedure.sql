USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_RepUIParentContactInfo]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UINE_RepUIParentContactInfo]
	@str1 date,
	@str2 date,
	@Pgm int,
	@StdID int,
	@AgencyFlag varchar(20),
	@PgmFlag int,
	@PgmGroup Varchar(200)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF (@PgmFlag = 0)
BEGIN

Select et.UIEventNum,ui.StudentName1,ui.UIDate as udate,CONVERT(VARCHAR(10),UIDate,101) as UIDate,CONVERT(VARCHAR(10),fp.FinalReportDate,101) as FinalReportDate,ui.Formstatus,ui.ProgramGroup,
fp.ChkFinalDCF,fp.ChkFinalDPPC,fp.ChkFinalDESE,fp.ChkFinalDEEC,fp.ChkFinalLEA,fp.ChkFinalFamGuar from UINE_UI ui 
LEFT Join UINE_FinalProc fp on fp.UINEID=ui.UINEID
LEFT Join UINE_Events et on ui.UIEventID=et.UIEventID 
where ui.AgencyFlag = @AgencyFlag and ui.ActiveInd='A'and ui.Formstatus<>'V' and	
									ui.PgmSiteID =IIF(@Pgm IS NULL, PgmSiteID, @Pgm ) and
									ui.[StudentID1] =IIF(@StdID IS NULL, ui.[StudentID1], @StdID ) and
									ui.UIDate between @str1 and @str2
									order by udate desc

END
ELSE IF (@PgmFlag = 1)
BEGIN
Select et.UIEventNum,ui.StudentName1,ui.UIDate as udate,CONVERT(VARCHAR(10),UIDate,101) as UIDate,CONVERT(VARCHAR(10),fp.FinalReportDate,101) as FinalReportDate,ui.Formstatus,ui.ProgramGroup,
fp.ChkFinalDCF,fp.ChkFinalDPPC,fp.ChkFinalDESE,fp.ChkFinalDEEC,fp.ChkFinalLEA,fp.ChkFinalFamGuar from UINE_UI ui 
LEFT Join UINE_FinalProc fp on fp.UINEID=ui.UINEID
LEFT Join UINE_Events et on ui.UIEventID=et.UIEventID 
where ui.AgencyFlag = @AgencyFlag and ui.ActiveInd='A'and ui.Formstatus<>'V' and	
									ui.PgmSiteID = @PgmGroup and
									ui.[StudentID1] =IIF(@StdID IS NULL, ui.[StudentID1], @StdID ) and
									ui.UIDate between @str1 and @str2
									order by udate desc


END





END

GO
