USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_UnsignedPHReport]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[UINE_UnsignedPHReport] 
	@str1 date,
	@str2 date,
	@Pgm int,
	@StdID int,
	@AgencyFlag varchar(20),
	@SignFlag varchar(50),
	@PgmFlag int,
	@PgmGroup Varchar(200)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF (@PgmFlag = 0)
BEGIN

									iF(@SignFlag = 'Unsigned')

									BEGIN

									select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,ps.Per1Name As StaffName,ps.Per1Title As StaffTitle from [UINE_PHMain] PH 
									inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner Join [UINE_PHFinalRep] Esign on PH.[PHID] = Esign.PHMainID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									where datalength(SigTitle)=0 and PH.[ActiveInd]='A' and form.IndFormCode='PH' and

									[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm ) and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc
									END

									ELSE IF(@SignFlag = 'Signed')
									BEGIN

									select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,ps.Per1Name As StaffName,ps.Per1Title As StaffTitle from [UINE_PHMain] PH 
									inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner Join [UINE_PHFinalRep] Esign on PH.[PHID] = Esign.PHMainID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									where datalength(SigTitle)!=0 and PH.[ActiveInd]='A' and form.IndFormCode='PH' and

									[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm ) and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc
									 END

									 ELSE IF(@SignFlag = 'ALL')
									BEGIN

									select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,ps.Per1Name As StaffName,ps.Per1Title As StaffTitle from [UINE_PHMain] PH 
									inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									 where PH.[ActiveInd]='A' and form.IndFormCode='PH' and

									[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm ) and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc
     
									END

END
IF (@PgmFlag = 1)
BEGIN
				iF(@SignFlag = 'Unsigned')

									BEGIN

									select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,ps.Per1Name As StaffName,ps.Per1Title As StaffTitle from [UINE_PHMain] PH 
									inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner Join [UINE_PHFinalRep] Esign on PH.[PHID] = Esign.PHMainID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									where datalength(SigTitle)=0 and PH.[ActiveInd]='A' and form.IndFormCode='PH' and

									PH.ProgramGroup=@PgmGroup and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc
									END

			ELSE IF(@SignFlag = 'Signed')
									BEGIN

									select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,ps.Per1Name As StaffName,ps.Per1Title As StaffTitle from [UINE_PHMain] PH 
									inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner Join [UINE_PHFinalRep] Esign on PH.[PHID] = Esign.PHMainID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									where datalength(SigTitle)!=0 and PH.[ActiveInd]='A' and form.IndFormCode='PH' and

									PH.ProgramGroup=@PgmGroup and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc
									 END

				 ELSE IF(@SignFlag = 'ALL')
									BEGIN

									select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,ps.Per1Name As StaffName,ps.Per1Title As StaffTitle from [UINE_PHMain] PH 
									inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									 where PH.[ActiveInd]='A' and form.IndFormCode='PH' and

									PH.ProgramGroup=@PgmGroup and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc
     
									END

 END   
END




GO
