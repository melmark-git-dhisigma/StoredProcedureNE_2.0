USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_UpdateUI]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UINE_UpdateUI]
					@UINEID int,
					@UIEventID int,
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
					@ProgramGroup varchar(300), 
					@LocID int, 
					@LocOfIncident varchar(100), 
					@UIDate date, 
					@UITime Time, 
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
					@ActiveInd varchar(20)
AS
BEGIN
		SET NOCOUNT ON;

    Update UINE_UI set 
	  [StudentID1] = @StdID1
      ,[StudentName1]=@StdName1
      ,[StudentID2]=@StdID2
      ,[StudentName2]=@StdName2
      ,[StudentID3]=@StdID3
      ,[StudentName3]=@StdName3
      ,[StudentID4]=@StdID4
      ,[StudentName4]=@StdName4
      ,[StaffInvolID1]=@StaffID1
	  ,[StaffInvolName1]=@StaffInvolName1
      ,[StaffInvolPosition1]=@StaffInvolPos1
      ,[StaffInvolID2]=@StaffID2
      ,[StaffInvolName2]=@StaffInvolName2
      ,[StaffInvolPosition2]=@StaffInvolPos2
      ,[StaffInvolID3]=@StaffID3
      ,[StaffInvolName3]=@StaffInvolName3
      ,[StaffInvolPosition3]=@StaffInvolPos3
      ,[StaffInvolID4]=@StaffID4
      ,[StaffInvolName4]=@StaffInvolName4
      ,[StaffInvolPosition4]=@StaffInvolPos4
      ,[PgmSiteID]=@PgmSiteID 
      ,[ProgramSite]=@ProgramSite
	  ,[ProgramGroup]=@ProgramGroup
      ,[LocID]=@LocID
      ,[LocOfIncident]=@LocOfIncident
      ,[UIDate]=@UIDate
      ,[UITime]=@UITime
      ,[StaffCompRepID]=@StaffCompRepID
      ,[StaffcompRepName]=@StaffcompRepName
      ,[StaffCompRepPOs]=@StaffCompRepPOs
      ,[IncidentDesc]=@IncidentDesc
      ,[chkinciAdminNot]=@chkinciAdminNot
      ,[InciAdminNotByID]=@InciAdminNotByID
      ,[InciAdminNotBy]=@InciAdminNotBy
      ,[InciAdminNotToID]=@InciAdminNotToID
      ,[InciAdminNotTo]=@InciAdminNotTo
      ,[InciAdminNotDate]=@InciAdminNotDate
      ,[InciAdminNotTime]=@InciAdminNotTime
      ,[chkimmSupVerbNot]=@chkimmSupVerbNot
      ,[chkNurNot]=@chkNurNot
      ,[NurNotByID]=@NurNotByID
      ,[NurNotBy]=@NurNotBy
      ,[NurNotToID]=@NurNotToID
      ,[NurNotTo]=@NurNotTo
      ,[NurNotDate]=@NurNotDate
      ,[NurNotTime]=@NurNotTime
      ,[ActiveInd]=@ActiveInd
      ,[ModifiedDate]=GETDATE() where [UINEID]=@UINEID and [UIEventID]=@UIEventID
  

	
END






GO
