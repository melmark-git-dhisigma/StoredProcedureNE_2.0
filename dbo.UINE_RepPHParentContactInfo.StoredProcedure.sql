USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_RepPHParentContactInfo]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_RepPHParentContactInfo]
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

select Distinct PH.StudentName,PH.ProgramName,PH.[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,CONVERT(VARCHAR(10),AdPar.CalledDate,101) As ParentCalledOn,CONVERT(VARCHAR(10),AdPar.RepSntDate,101) As ParentReportSentOn,
[TotalResTimeMin] as Duration,Res.Holds,PH.[UIEventID],ev.UIEventNum,
form.FormNumber as PHID,PH.[PHID] as MainID
from [UINE_PHMain] PH 
inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
inner join UINE_Forms form on PH.[PHID] = form.IndFormID
Inner Join UINE_PHRestUsed Res on PH.[PHID] = Res.PHMainID
inner Join UINE_PHAdminParent AdPar on PH.[PHID] = AdPar.PHMainID
									
where PH.[ActiveInd]='A' and form.IndFormCode='PH' and 

									[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm ) and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc



END
ELSE IF (@PgmFlag = 1)
BEGIN
select Distinct PH.StudentName,PH.ProgramName,PH.[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,CONVERT(VARCHAR(10),AdPar.CalledDate,101) As ParentCalledOn,CONVERT(VARCHAR(10),AdPar.RepSntDate,101) As ParentReportSentOn,
[TotalResTimeMin] as Duration,Res.Holds,PH.[UIEventID],ev.UIEventNum,
form.FormNumber as PHID,PH.[PHID] as MainID
from [UINE_PHMain] PH 
inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
inner join UINE_Forms form on PH.[PHID] = form.IndFormID
Inner Join UINE_PHRestUsed Res on PH.[PHID] = Res.PHMainID
inner Join UINE_PHAdminParent AdPar on PH.[PHID] = AdPar.PHMainID
									
			where PH.[ActiveInd]='A' and form.IndFormCode='PH' and 

									PH.ProgramGroup=@PgmGroup and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc


END





END


GO
