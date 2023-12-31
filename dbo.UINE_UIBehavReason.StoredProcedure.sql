USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_UIBehavReason]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_UIBehavReason]
	@str1 date,
	@str2 date,
	@Pgm int,
	@StdID int,
	@AgencyFlag varchar(20),
	@SignFlag varchar(50),
	@BehavName NVarchar(Max),
	@PgmFlag int,
	@PgmGroup Varchar(200)
	
AS
BEGIN
	SET NOCOUNT ON;

IF (@PgmFlag = 0)
BEGIN

IF(@SignFlag = 'ALL')
BEGIN
select ui.UIEventID,ev.UIEventNum,UIDate,CONVERT(VARCHAR(10),UIDate,101) as UnIncDate,StudentName1,StudentName2,StaffInvolName1,ProgramSite,LocOfIncident,PR.BehavName as BehavName, IncidentDesc from UINE_UI ui
inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
inner join [UINE_PrimaryReason] PR on ui.UINEID = PR.UINEID  where PR.BehavName =IIF(@BehavName IS NULL, PR.BehavName, @BehavName ) and
ui.[ActiveInd]='A' and PR.BehavName != '--Select--' and
[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm ) and
[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
ui.UIDate between @str1 and @str2 and
ui.AgencyFlag=@AgencyFlag
order by [UIDate] Desc
END
ELSE IF(@SignFlag = 'Signed')
BEGIN
select ui.UIEventID,ev.UIEventNum,UIDate,CONVERT(VARCHAR(10),UIDate,101) as UnIncDate,StudentName1,StudentName2,StaffInvolName1,ProgramSite,LocOfIncident,PR.BehavName, IncidentDesc from UINE_UI ui
inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
inner join [UINE_PrimaryReason] PR on ui.UINEID = PR.UINEID
inner join [UINE_DirNurSign] esign on ui.[UIEventID] = esign.UIEventID 
where (datalength(ResDirSigPos)!=0 or datalength(schoolDirSigPos)!=0 or datalength(NursingSigPos)!=0) and
PR.BehavName =IIF(@BehavName IS NULL, PR.BehavName, @BehavName ) and
ui.[ActiveInd]='A' and PR.BehavName != '--Select--' and
[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm ) and
[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
ui.UIDate between @str1 and @str2 and
ui.AgencyFlag=@AgencyFlag
order by [UIDate] Desc
END
ELSE IF(@SignFlag = 'Unsigned')
BEGIN
select ui.UIEventID,ev.UIEventNum,UIDate,CONVERT(VARCHAR(10),UIDate,101) as UnIncDate,StudentName1,StudentName2,StaffInvolName1,ProgramSite,LocOfIncident,PR.BehavName, IncidentDesc from UINE_UI ui
inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
inner join [UINE_PrimaryReason] PR on ui.UINEID = PR.UINEID
inner join [UINE_DirNurSign] esign on ui.[UIEventID] = esign.UIEventID 
where datalength(ResDirSigPos)=0 and datalength(schoolDirSigPos)=0 and datalength(NursingSigPos)=0 and
PR.BehavName =IIF(@BehavName IS NULL, PR.BehavName, @BehavName ) and
ui.[ActiveInd]='A' and PR.BehavName != '--Select--' and
[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm ) and
[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
ui.UIDate between @str1 and @str2 and
ui.AgencyFlag=@AgencyFlag
order by [UIDate] Desc
END

END

ELSE IF (@PgmFlag = 1)
BEGIN

IF(@SignFlag = 'ALL')
BEGIN
select ui.UIEventID,ev.UIEventNum,UIDate,CONVERT(VARCHAR(10),UIDate,101) as UnIncDate,StudentName1,StudentName2,StaffInvolName1,ProgramSite,LocOfIncident,PR.BehavName as BehavName, IncidentDesc from UINE_UI ui
inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
inner join [UINE_PrimaryReason] PR on ui.UINEID = PR.UINEID where PR.BehavName =IIF(@BehavName IS NULL, PR.BehavName, @BehavName ) and ui.ProgramGroup=@PgmGroup and
ui.[ActiveInd]='A' and PR.BehavName != '--Select--' and
[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
ui.UIDate between @str1 and @str2 and
ui.AgencyFlag=@AgencyFlag
order by [UIDate] Desc
END
ELSE IF(@SignFlag = 'Signed')
BEGIN
select ui.UIEventID,ev.UIEventNum,UIDate,CONVERT(VARCHAR(10),UIDate,101) as UnIncDate,StudentName1,StudentName2,StaffInvolName1,ProgramSite,LocOfIncident,PR.BehavName, IncidentDesc from UINE_UI ui
inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
inner join [UINE_PrimaryReason] PR on ui.UINEID = PR.UINEID
inner join [UINE_DirNurSign] esign on ui.[UIEventID] = esign.UIEventID 
where (datalength(ResDirSigPos)!=0 or datalength(schoolDirSigPos)!=0 or datalength(NursingSigPos)!=0) and ui.ProgramGroup=@PgmGroup and 
PR.BehavName =IIF(@BehavName IS NULL, PR.BehavName, @BehavName ) and
ui.[ActiveInd]='A' and PR.BehavName != '--Select--' and
[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
ui.UIDate between @str1 and @str2 and
ui.AgencyFlag=@AgencyFlag
order by [UIDate] Desc
END
ELSE IF(@SignFlag = 'Unsigned')
BEGIN
select ui.UIEventID,ev.UIEventNum,UIDate,CONVERT(VARCHAR(10),UIDate,101) as UnIncDate,StudentName1,StudentName2,StaffInvolName1,ProgramSite,LocOfIncident,PR.BehavName, IncidentDesc from UINE_UI ui
inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
inner join [UINE_PrimaryReason] PR on ui.UINEID = PR.UINEID
inner join [UINE_DirNurSign] esign on ui.[UIEventID] = esign.UIEventID 
where datalength(ResDirSigPos)=0 and datalength(schoolDirSigPos)=0 and datalength(NursingSigPos)=0 and ui.ProgramGroup=@PgmGroup and 
PR.BehavName =IIF(@BehavName IS NULL, PR.BehavName, @BehavName ) and
ui.[ActiveInd]='A' and PR.BehavName != '--Select--' and
[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
ui.UIDate between @str1 and @str2 and
ui.AgencyFlag=@AgencyFlag
order by [UIDate] Desc
END
END
END




GO
