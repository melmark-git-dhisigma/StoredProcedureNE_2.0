USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_InsertNewPH]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[UINE_InsertNewPH] 
					@Flag int,
					@NameOfAgency varchar(200), 
					@StudentID int, 
					@StudentName varchar(100), 
					@DateOfRest date, 
					@GenderID int, 
					@Gender varchar(50), 
					@PHProgramID int, 
					@PHProgramName varchar(100),
					@ProgramGroup varchar(300),
					@SASSID varchar(50), 
					@StartTime time,
					@EndTime time,
					@SubjPeriodID int,
					@SubjPeriod varchar(100),
					@SendingDistrict varchar(100),
					@chkStdIEP bit,
					@DurationMin int,
					@DurationSec int,
					@TotalResTimeMin float,
					@RestraintInterval nvarchar(100),
					@AgencyFlag Char(10),
					@FormStatus varchar(20),
					@ActiveInd varchar(20),
					@InitialSubmitID int,
					@LocationName Varchar(Max),
					@OtherLocation Varchar(Max),
					@OtherLocationID Varchar(Max)

AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Ret TABLE (
				EvID int,
				EvNum int,
				PHID INT,
				FormCode varchar(20),
				FormNum int);

		declare @PHID int

IF EXISTS (SELECT * FROM UINE_Events WHERE UIEventID=@Flag) 	

  BEGIN

		  UPDATE UINE_Events SET [UINEPHNum] = [UINEPHNum]+1, ModifiedDate = GETDATE(),FormStatus=@FormStatus WHERE UIEventID=@Flag;
		  INSERT INTO @Ret (EvID,EvNum,PHID,FormCode,FormNum) values (@Flag,0,0,'',0);

		declare @UpdateEventNum int
		select @UpdateEventNum = (select [UIEventNum] from UINE_Events where UIEventID=@Flag)

  	Insert into UINE_PHMain ([UIEventID]
      ,[NameOfAgency]
      ,[StudentID]
      ,[StudentName]
      ,[DateOfRest]
	  ,GenderID
      ,[Gender]
      ,[ProgramID]
      ,[ProgramName]
	  ,ProgramGroup
      ,[SASSID]
      ,[StartTime]
      ,[EndTime]
	  ,[SubjPeriodID]
      ,[SubjPeriod]
      ,[SendingDistrict]
      ,[chkStdIEP]
	  ,DurationMin
	  ,DurationSec
	  ,TotalResTimeMin
	  ,RestraintInterval
	  ,AgencyFlag
      ,[FormStatus]
	  ,[CreatedOn]
	  ,ModifiedOn
      ,[ActiveInd]
	  ,LocationName,
	  OtherLocation,
	  OtherLocationID)
	   select		@Flag,
					@NameOfAgency, 
					@StudentID, 
					@StudentName, 
					@DateOfRest, 
					@GenderID,
					@Gender, 
					@PHProgramID, 
					@PHProgramName,
					@ProgramGroup,
					@SASSID, 
					@StartTime,
					@EndTime,
					@SubjPeriodID,
					@SubjPeriod,
					@SendingDistrict,
					@chkStdIEP,
					@DurationMin,
					@DurationSec,
					@TotalResTimeMin,
					@RestraintInterval,
					@AgencyFlag,
					@FormStatus,
					GETDATE(),
					NULL,
					@ActiveInd,
					@LocationName,
					@OtherLocation,
					@OtherLocationID

		select @PHID = SCOPE_IDENTITY();
		Update @Ret set PHID=@PHID;
		insert into UINE_Forms (UIEventID,IndFormID,IndFormCode,FormNumber,ActiveInd,UIEventNum) values (@Flag,@PHID,'PH',(select ISNULL((select max(FormNumber)+1 from UINE_Forms where UIEventID=@Flag and IndFormCode='PH'),1)),'A',@UpdateEventNum);
		Update @Ret set FormCode='PH',FormNum=(select UINEPHNum from UINE_Events where UIEventID=@Flag),EvNum=@UpdateEventNum;
		select EvID,EvNum,PHID,FormCode,FormNum from @Ret;
  
END

 ELSE

	BEGIN
		Insert into UINE_Events ([UIEventNum],[UINEUINum],[UINEPHNum],[UINEITSNum],[ActiveInd],CreatedDate,[AgencyFlag],FormStatus,InitialSubmitID,SendEmailID) values ((select ISNULL((SELECT MAX([UIEventNum]) + 1 FROM UINE_Events),1)),0,1,0,'A',GETDATE(),@AgencyFlag,@FormStatus,@InitialSubmitID,@InitialSubmitID)
		declare @EventID int
		select @EventID = SCOPE_IDENTITY()
		
			declare @EventNum int
		select @EventNum = (select [UIEventNum] from UINE_Events where UIEventID=@EventID)

		INSERT INTO @Ret(EvID,EvNum,PHID,FormCode,FormNum) values (@EventID,@EventNum,0,'',0)

		Insert into UINE_PHMain ([UIEventID]
      ,[NameOfAgency]
      ,[StudentID]
      ,[StudentName]
      ,[DateOfRest]
	  ,GenderID
      ,[Gender]
      ,[ProgramID]
      ,[ProgramName]
	  ,ProgramGroup
      ,[SASSID]
      ,[StartTime]
      ,[EndTime]
	  ,[SubjPeriodID]
      ,[SubjPeriod]
      ,[SendingDistrict]
      ,[chkStdIEP]
	  ,DurationMin
	  ,DurationSec
	  ,TotalResTimeMin
	  ,RestraintInterval
	  ,[AgencyFlag]
      ,[FormStatus]
	  ,[CreatedOn]
	  ,ModifiedOn
      ,[ActiveInd]
	  ,LocationName,
	  OtherLocation,
	  OtherLocationID)
	   select		@EventID,
					@NameOfAgency, 
					@StudentID, 
					@StudentName, 
					@DateOfRest, 
					@GenderID,
					@Gender, 
					@PHProgramID, 
					@PHProgramName,
					@ProgramGroup,
					@SASSID, 
					@StartTime,
					@EndTime,
					@SubjPeriodID,
					@SubjPeriod,
					@SendingDistrict,
					@chkStdIEP,
					@DurationMin,
					@DurationSec,
					@TotalResTimeMin,
					@RestraintInterval,
					@AgencyFlag,
					@FormStatus,
					GETDATE(),
					NULL,
					@ActiveInd,
					@LocationName,
						@OtherLocation,
					@OtherLocationID

		select @PHID = SCOPE_IDENTITY();
		Update @Ret set PHID=@PHID;

		insert into UINE_Forms (UIEventID,IndFormID,IndFormCode,FormNumber,ActiveInd,UIEventNum) values (@EventID,@PHID,'PH',(select ISNULL((select max(FormNumber)+1 from UINE_Forms where UIEventID=@EventID and IndFormCode='PH'),1)),'A',@EventNum);
		Update @Ret set FormCode='PH',FormNum=(select UINEPHNum from UINE_Events where UIEventID=@EventID),EvNum=@EventNum;
		select EvID,EvNum,PHID,FormCode,FormNum from @Ret;

End
End













GO
