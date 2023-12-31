USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_InsertNewUI]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UINE_InsertNewUI] 
	-- Add the parameters for the stored procedure here
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
					@ProgramGroup varchar(300),
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
					@AgencyFlag varchar(10), 
					@FormStatus varchar(20),
					@ActiveInd varchar(20),
					@InitialSubmitID int
					
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @Ret TABLE (EvID int,EvNum int,UIID INT,FormCode varchar(20),FormNum int);
Declare @UINEID int

IF EXISTS (SELECT * FROM UINE_Events WHERE UIEventID=@Flag) 	

BEGIN
UPDATE UINE_Events SET [UINEUINum] = [UINEUINum]+1, ModifiedDate = GETDATE(),FormStatus=@FormStatus WHERE UIEventID=@Flag;
INSERT INTO @Ret (EvID,EvNum,UIID,FormCode,FormNum) values (@Flag,0,0,'',0);

declare @UpdateEventNum int
select @UpdateEventNum = (select [UIEventNum] from UINE_Events where UIEventID=@Flag)

Insert into UINE_UI ([UIEventID],[StudentID1],[StudentName1],[StudentID2],[StudentName2],[StudentID3],[StudentName3],[StudentID4],[StudentName4],[StaffInvolID1],[StaffInvolName1],[StaffInvolPosition1],[StaffInvolID2],[StaffInvolName2],[StaffInvolPosition2],[StaffInvolID3],[StaffInvolName3],[StaffInvolPosition3],[StaffInvolID4],[StaffInvolName4],[StaffInvolPosition4] ,[PgmSiteID] ,[ProgramSite] ,[ProgramGroup] ,[LocID] ,[LocOfIncident] ,[UIDate] ,[UITime] ,[ReportDate] ,[ReportTime] ,[StaffCompRepID] ,[StaffcompRepName] ,[StaffCompRepPOs] ,IncidentDesc ,[chkinciAdminNot] ,[InciAdminNotByID] ,[InciAdminNotBy] ,[InciAdminNotToID] ,[InciAdminNotTo] ,[InciAdminNotDate] ,[InciAdminNotTime] ,[chkimmSupVerbNot] ,[chkNurNot] ,[NurNotByID] ,[NurNotBy] ,[NurNotToID] ,[NurNotTo] ,[NurNotDate] ,[NurNotTime] ,AgencyFlag ,[FormStatus] ,[ActiveInd] ,[CreatedDate]) 
select @Flag, @StdID1, @StdName1, @StdID2,  @StdName2, @StdID3, @StdName3, @StdID4, @StdName4, @StaffID1, @StaffInvolName1, @StaffInvolPos1, @StaffID2, @StaffInvolName2, @StaffInvolPos2, @StaffID3, @StaffInvolName3, @StaffInvolPos3, @StaffID4, @StaffInvolName4, @StaffInvolPos4, @PgmSiteID, @ProgramSite, @ProgramGroup, @LocID, @LocOfIncident, @UIDate, @UITime, @ReportDate, @ReportTime, @StaffCompRepID, @StaffcompRepName, @StaffCompRepPOs, @IncidentDesc, @chkinciAdminNot, @InciAdminNotByID, @InciAdminNotBy, @InciAdminNotToID, @InciAdminNotTo, @InciAdminNotDate, @InciAdminNotTime, @chkimmSupVerbNot, @chkNurNot, @NurNotByID, @NurNotBy, @NurNotToID, @NurNotTo, @NurNotDate, @NurNotTime, @AgencyFlag, @FormStatus, @ActiveInd, GETDATE();	
		
select @UINEID = SCOPE_IDENTITY();

Update @Ret set UIID=@UINEID;
insert into UINE_Forms (UIEventID,IndFormID,IndFormCode,FormNumber,ActiveInd,UIEventNum) values (@Flag,@UINEID,'UI',(select ISNULL((select max(FormNumber)+1 from UINE_Forms where UIEventID=@Flag and IndFormCode='UI'),1)),'A',@UpdateEventNum);
Update @Ret set FormCode='UI',FormNum=(select UINEUINum from UINE_Events where UIEventID=@Flag),EvNum=@UpdateEventNum;
select EvID,EvNum,UIID,FormCode,FormNum from @Ret;
END
ELSE
BEGIN
Insert into UINE_Events ([UIEventNum],[UINEUINum],[UINEPHNum],[UINEITSNum],[ActiveInd],CreatedDate,AgencyFlag,FormStatus,InitialSubmitID,SendEmailID) values ((select ISNULL((SELECT MAX([UIEventNum]) + 1 FROM UINE_Events),1)),1,0,0,'A',GETDATE(),@AgencyFlag,@FormStatus,@InitialSubmitID,@InitialSubmitID)

declare @EventID int
select @EventID = SCOPE_IDENTITY()
declare @EventNum int
select @EventNum = (select [UIEventNum] from UINE_Events where UIEventID=@EventID)
		
INSERT INTO @Ret(EvID,EvNum,UIID,FormCode,FormNum) values (@EventID,@EventNum,0,'',0)
Insert into UINE_UI ([UIEventID],[StudentID1] ,[StudentName1] ,[StudentID2] ,[StudentName2] ,[StudentID3] ,[StudentName3] ,[StudentID4] ,[StudentName4] ,[StaffInvolID1] ,[StaffInvolName1] ,[StaffInvolPosition1] ,[StaffInvolID2] ,[StaffInvolName2] ,[StaffInvolPosition2] ,[StaffInvolID3] ,[StaffInvolName3] ,[StaffInvolPosition3] ,[StaffInvolID4] ,[StaffInvolName4] ,[StaffInvolPosition4] ,[PgmSiteID] ,[ProgramSite] ,[ProgramGroup] ,[LocID] ,[LocOfIncident] ,[UIDate] ,[UITime] ,[ReportDate] ,[ReportTime] ,[StaffCompRepID] ,[StaffcompRepName] ,[StaffCompRepPOs] ,IncidentDesc ,[chkinciAdminNot] ,[InciAdminNotByID] ,[InciAdminNotBy] ,[InciAdminNotToID] ,[InciAdminNotTo] ,[InciAdminNotDate] ,[InciAdminNotTime] ,[chkimmSupVerbNot] ,[chkNurNot] ,[NurNotByID] ,[NurNotBy] ,[NurNotToID] ,[NurNotTo] ,[NurNotDate] ,[NurNotTime] ,AgencyFlag ,[FormStatus] ,[ActiveInd] ,[CreatedDate])
select @EventID, @StdID1, @StdName1, @StdID2,  @StdName2, @StdID3, @StdName3, @StdID4, @StdName4, @StaffID1, @StaffInvolName1, @StaffInvolPos1, @StaffID2, @StaffInvolName2, @StaffInvolPos2, @StaffID3, @StaffInvolName3, @StaffInvolPos3, @StaffID4, @StaffInvolName4, @StaffInvolPos4, @PgmSiteID, @ProgramSite, @ProgramGroup, @LocID, @LocOfIncident, @UIDate, @UITime, @ReportDate, @ReportTime, @StaffCompRepID, @StaffcompRepName, @StaffCompRepPOs, @IncidentDesc, @chkinciAdminNot, @InciAdminNotByID, @InciAdminNotBy, @InciAdminNotToID, @InciAdminNotTo, @InciAdminNotDate, @InciAdminNotTime, @chkimmSupVerbNot, @chkNurNot, @NurNotByID, @NurNotBy, @NurNotToID, @NurNotTo, @NurNotDate, @NurNotTime, @AgencyFlag,  @FormStatus, @ActiveInd, GETDATE()	 	
		
select @UINEID = SCOPE_IDENTITY()

Update @Ret set UIID=@UINEID

insert into UINE_Forms (UIEventID,IndFormID,IndFormCode,FormNumber,ActiveInd,UIEventNum) values (@EventID,@UINEID,'UI',(select ISNULL((select max(FormNumber)+1 from UINE_Forms where UIEventID=@Flag and IndFormCode='UI'),1)),'A',@EventNum);
Update @Ret set FormCode='UI',FormNum=(select UINEUINum from UINE_Events where UIEventID=@EventID);
Select EvID,EvNum,UIID,FormCode,FormNum from @Ret
END
END














GO
