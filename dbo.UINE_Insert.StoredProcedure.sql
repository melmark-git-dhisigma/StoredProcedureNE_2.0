USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_Insert]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[UINE_Insert]
					@Flag int,
					@StdName1 varchar(100), 
					@StdID1 int, 
					@StdName2 varchar(100), 
					@StdID2 int, 
					@StdName3 varchar(100), 
					@StdID3 int, 
					@StdName4 varchar(100),
					@StdID4 int, 
					@StaffInvolName1 varchar(100), 
					@StaffID1 int, 
					@StaffInvolPos1 varchar(500), 
					@StaffInvolName2 varchar(100), 
					@StaffID2 int, 
					@StaffInvolPos2 varchar(500), 
					@StaffInvolName3 varchar(100), 
					@StaffID3 int, 
					@StaffInvolPos3 varchar(500), 
					@StaffInvolName4 varchar(100), 
					@StaffID4 int, 
					@StaffInvolPos4 varchar(500),
					@PgmSiteID int, 
					@ProgramSite varchar(100), 
					@LocID int, 
					@LocOfIncident varchar(100), 
					@UIDate date, 
					@UITime Time, 
					@ReportDate date, 
					@ReportTime Time, 
					@StaffCompRepID int, 
					@StaffcompRepName varchar(100), 
					@StaffCompRepPOs varchar(500),
					@IncidentDesc nvarchar(Max), 
					@chkinciAdminNot bit, 
					@InciAdminNotByID int, 
					@InciAdminNotBy varchar(100), 
					@InciAdminNotToID int, 
					@InciAdminNotTo varchar(100), 
					@InciAdminNotDate date,
					@InciAdminNotTime time, 
					@chkimmSupVerbNot bit,
					@chkNurNot bit,
					@NurNotByID int, 
					@NurNotBy varchar(100), 
					@NurNotToID int, 
					@NurNotTo varchar(100), 
					@NurNotDate date, 
					@NurNotTime time, 
					@FormStatus varchar(20),
					@ActiveInd varchar(20)	
AS
BEGIN
	if (@Flag = 1)
	Begin


		Insert into UINE_Events ( [UINEUINum],[UINEPHNum],[UINEITSNum],[ActiveInd]) values (1,0,0,'A')

		declare @EventID int
		select @EventID = SCOPE_IDENTITY()

		Insert into UINE_UI ([UIEventID]
      ,[StudentID1]
      ,[StudentName1]
      ,[StudentID2]
      ,[StudentName2]
      ,[StudentID3]
      ,[StudentName3]
      ,[StudentID4]
      ,[StudentName4]
      ,[StaffInvolID1]
      ,[StaffInvolName1]
      ,[StaffInvolPosition1]
      ,[StaffInvolID2]
      ,[StaffInvolName2]
      ,[StaffInvolPosition2]
      ,[StaffInvolID3]
      ,[StaffInvolName3]
      ,[StaffInvolPosition3]
      ,[StaffInvolID4]
      ,[StaffInvolName4]
      ,[StaffInvolPosition4]
      ,[PgmSiteID]
      ,[ProgramSite]
      ,[LocID]
      ,[LocOfIncident]
      ,[UIDate]
      ,[UITime]
      ,[ReportDate]
      ,[ReportTime]
      ,[StaffCompRepID]
      ,[StaffcompRepName]
      ,[StaffCompRepPOs]
	  ,IncidentDesc
      ,[chkinciAdminNot]
      ,[InciAdminNotByID]
      ,[InciAdminNotBy]
      ,[InciAdminNotToID]
      ,[InciAdminNotTo]
      ,[InciAdminNotDate]
      ,[InciAdminNotTime]
      ,[chkimmSupVerbNot]
      ,[chkNurNot]
      ,[NurNotByID]
      ,[NurNotBy]
      ,[NurNotToID]
      ,[NurNotTo]
      ,[NurNotDate]
      ,[NurNotTime]
      ,[FormStatus]
      ,[ActiveInd]) 

	  select		@EventID,
					@StdID1,
					@StdName1, 
					@StdID2,  
					@StdName2, 
					@StdID3,
					@StdName3, 
					@StdID4, 
					@StdName4,
					@StaffID1, 
					@StaffInvolName1, 
					@StaffInvolPos1, 
					@StaffID2, 
					@StaffInvolName2,
					@StaffInvolPos2,
					@StaffID3, 
					@StaffInvolName3, 
					@StaffInvolPos3, 
					@StaffID4, 
					@StaffInvolName4, 
					@StaffInvolPos4,
					@PgmSiteID, 
					@ProgramSite, 
					@LocID, 
					@LocOfIncident, 
					@UIDate, 
					@UITime, 
					@ReportDate, 
					@ReportTime, 
					@StaffCompRepID, 
					@StaffcompRepName, 
					@StaffCompRepPOs,
					@IncidentDesc, 
					@chkinciAdminNot, 
					@InciAdminNotByID, 
					@InciAdminNotBy, 
					@InciAdminNotToID, 
					@InciAdminNotTo, 
					@InciAdminNotDate,
					@InciAdminNotTime, 
					@chkimmSupVerbNot,
					@chkNurNot,
					@NurNotByID, 
					@NurNotBy, 
					@NurNotToID, 
					@NurNotTo, 
					@NurNotDate, 
					@NurNotTime, 
					@FormStatus,
					@ActiveInd	

		return @EventID

	End
End




GO
