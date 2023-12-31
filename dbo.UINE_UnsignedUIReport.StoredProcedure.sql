USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_UnsignedUIReport]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_UnsignedUIReport] 
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


											IF(@SignFlag = 'Unsigned')
											BEGIN
												select ui.[UIEventID],ev.UIEventNum,ui.[UINEID],UIDate,CONVERT(VARCHAR(10),UIDate,101) as IncidentDate,CONVERT(varchar(15), 
												CAST([UITime] AS TIME), 100) as IncidentTime,[StaffcompRepName],[StudentName1],[ProgramSite],[LocOfIncident],IncidentDesc
												from [UINE_UI] ui 
												inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
												inner join [UINE_DirNurSign] esign on ui.UINEID = esign.UINEID 
												where datalength(ResDirSigPos)=0 and datalength(schoolDirSigPos)=0 and datalength(NursingSigPos)=0 and
	
												ui.[ActiveInd]='A' and 
												[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm ) and
												[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
												ui.UIDate between @str1 and @str2 and
												ui.AgencyFlag=@AgencyFlag
												order by [UIDate] Desc
											END
											ELSE IF(@SignFlag = 'Signed')
											BEGIN
												select ui.[UIEventID],ev.UIEventNum,ui.[UINEID],UIDate,CONVERT(VARCHAR(10),UIDate,101) as IncidentDate,CONVERT(varchar(15), 
												CAST([UITime] AS TIME), 100) as IncidentTime,[StaffcompRepName],[StudentName1],[ProgramSite],[LocOfIncident],IncidentDesc 
												from [UINE_UI] ui 
												inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
												inner join [UINE_DirNurSign] esign on ui.UINEID = esign.UINEID 
												where (datalength(ResDirSigPos)!=0 or datalength(schoolDirSigPos)!=0 or datalength(NursingSigPos)!=0) and
												ui.UIDate between @str1 and @str2 and
	
												ui.[ActiveInd]='A' and 
												[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm ) and
												[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
	
												ui.AgencyFlag=@AgencyFlag
												order by [UIDate] Desc

											END
											ELSE IF(@SignFlag = 'ALL')
											BEGIN

												select ui.[UIEventID],ev.UIEventNum,ui.[UINEID],UIDate,CONVERT(VARCHAR(10),UIDate,101) as IncidentDate,CONVERT(varchar(15), 
												CAST([UITime] AS TIME), 100) as IncidentTime,[StaffcompRepName],[StudentName1],[ProgramSite],[LocOfIncident],IncidentDesc 
												from [UINE_UI] ui 
												inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
												where ui.[ActiveInd]='A' and 
												[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm ) and
												[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
												ui.UIDate between @str1 and @str2 and
												ui.AgencyFlag=@AgencyFlag
												order by [UIDate] Desc

											END

						END

ELSE IF (@PgmFlag = 1)

				BEGIN
									IF(@SignFlag = 'Unsigned')
									BEGIN
										select ui.[UIEventID],ev.UIEventNum,ui.[UINEID],UIDate,CONVERT(VARCHAR(10),UIDate,101) as IncidentDate,CONVERT(varchar(15), 
										CAST([UITime] AS TIME), 100) as IncidentTime,[StaffcompRepName],[StudentName1],[ProgramSite],[LocOfIncident],IncidentDesc
										from [UINE_UI] ui 
										inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
										inner join [UINE_DirNurSign] esign on ui.UINEID = esign.UINEID 
										where datalength(ResDirSigPos)=0 and datalength(schoolDirSigPos)=0 and datalength(NursingSigPos)=0 and
	
										ui.[ActiveInd]='A' and 
										ui.ProgramGroup=@PgmGroup and
										[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
										ui.UIDate between @str1 and @str2 and
										ui.AgencyFlag=@AgencyFlag
										order by [UIDate] Desc
									END
									ELSE IF(@SignFlag = 'Signed')
									BEGIN
										select ui.[UIEventID],ev.UIEventNum,ui.[UINEID],UIDate,CONVERT(VARCHAR(10),UIDate,101) as IncidentDate,CONVERT(varchar(15), 
										CAST([UITime] AS TIME), 100) as IncidentTime,[StaffcompRepName],[StudentName1],[ProgramSite],[LocOfIncident],IncidentDesc 
										from [UINE_UI] ui 
										inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
										inner join [UINE_DirNurSign] esign on ui.UINEID = esign.UINEID 
										where (datalength(ResDirSigPos)!=0 or datalength(schoolDirSigPos)!=0 or datalength(NursingSigPos)!=0) and
										ui.UIDate between @str1 and @str2 and
	
										ui.[ActiveInd]='A' and 
										ui.ProgramGroup=@PgmGroup and
										[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
	
										ui.AgencyFlag=@AgencyFlag
										order by [UIDate] Desc

									END
									ELSE IF(@SignFlag = 'ALL')
									BEGIN

										select ui.[UIEventID],ev.UIEventNum,ui.[UINEID],UIDate,CONVERT(VARCHAR(10),UIDate,101) as IncidentDate,CONVERT(varchar(15), 
										CAST([UITime] AS TIME), 100) as IncidentTime,[StaffcompRepName],[StudentName1],[ProgramSite],[LocOfIncident],IncidentDesc 
										from [UINE_UI] ui 
										inner join UINE_Events ev on ev.UIEventID= ui.UIEventID
										where ui.[ActiveInd]='A' and 
										ui.ProgramGroup=@PgmGroup and
										[StudentID1] =IIF(@StdID IS NULL, [StudentID1], @StdID ) and 
										ui.UIDate between @str1 and @str2 and
										ui.AgencyFlag=@AgencyFlag
										order by [UIDate] Desc

									END


						END



  
END






GO
