USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_InsertUpdateITS]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UINE_InsertUpdateITS]
@EventID int,
@UINEUINum int,
@UINEPHNum int,
@UINEITSNum int,
@EventsActiveInd char(10),
@StudentName varchar(200),
@StudentNameValue varchar(50),
@StudentDate date,
@CompletedOn varchar(200),
@CompletedOnValue varchar(50),
@CompletedOnDate date,
@CompletedBy varchar(200),
@CompletedByValue varchar(50),
@NumberIndex int,
@SeverityIndex1 int,
@SeverityIndex2 int,
@SeverityIndex3 int,
@RiskLevel varchar(50),
@MNeNursing bit,
@ERVisit bit,
@AgencyFlag varchar(10),
@ItsFormStatus varchar(1),
@ItsMainActiveInd varchar(1),
@InitialSubmitID int

AS
BEGIN
CREATE TABLE #TEMP(EvID int,EvNum int,ItsID int);
DECLARE @ItsID int

IF EXISTS (SELECT * FROM UINE_Events WHERE UIEventID=@EventID) 

BEGIN
UPDATE UINE_Events SET [UINEITSNum] = [UINEITSNum]+1,[ModifiedDate]=GETDATE(),FormStatus=@ItsFormStatus WHERE UIEventID=@EventID;
declare @UpdateEventNum int
select @UpdateEventNum = (select [UIEventNum] from UINE_Events where UIEventID=@EventID)
INSERT INTO #TEMP(EvID,EvNum,ItsID) VALUES (@EventID,@UpdateEventNum,0);
INSERT INTO UINE_ITSMainTable ([EventID], [StudentName], [StudentNameValue], [StudentDate], [CompletedOn], [CompletedOnValue], [CompletedOnDate], [CompletedBy], [CompletedByValue], [NumberIndex], [SeverityIndex1], [SeverityIndex2], [SeverityIndex3], [RiskLevel], [MNeNursing], [ERVisit],[AgencyFlag],[FormStatus], [ActiveInd]) VALUES (@EventID,  @StudentName,  @StudentNameValue,  @StudentDate,  @CompletedOn,  @CompletedOnValue,  @CompletedOnDate,  @CompletedBy,  @CompletedByValue,  @NumberIndex,  @SeverityIndex1,  @SeverityIndex2,  @SeverityIndex3,  @RiskLevel,  @MNeNursing,  @ERVisit,@AgencyFlag, @ItsFormStatus, @ItsMainActiveInd);
select @ItsID = SCOPE_IDENTITY();
update #TEMP set ItsID=@ItsID;
insert into UINE_Forms (UIEventID,IndFormID,IndFormCode,FormNumber,ActiveInd,UIEventNum) values (@EventID,@ItsID,'ITS',(select ISNULL((select max(FormNumber)+1 from UINE_Forms where UIEventID=@EventID and IndFormCode='ITS'),1)),'A',@UpdateEventNum);
select EvID,EvNum,ItsID from #TEMP;
DROP TABLE #TEMP;
END

ELSE
BEGIN
INSERT INTO UINE_Events ([UIEventNum],[UINEUINum],[UINEPHNum],[UINEITSNum],[ActiveInd],[CreatedDate],[AgencyFlag],[FormStatus],[InitialSubmitID],[SendEmailID]) VALUES((SELECT MAX([UIEventNum]) + 1 FROM UINE_Events),@UINEUINum,@UINEPHNum,@UINEITSNum,@EventsActiveInd,GETDATE(),@AgencyFlag,@ItsFormStatus,@InitialSubmitID,@InitialSubmitID);
select @EventID = SCOPE_IDENTITY();
declare @EventNum int
select @EventNum = (select [UIEventNum] from UINE_Events where UIEventID=@EventID)

INSERT INTO #TEMP(EvID,EvNum,ItsID) VALUES (@EventID,@EventNum,0);
INSERT INTO UINE_ITSMainTable ([EventID], [StudentName], [StudentNameValue], [StudentDate], [CompletedOn], [CompletedOnValue], [CompletedOnDate], [CompletedBy], [CompletedByValue], [NumberIndex], [SeverityIndex1], [SeverityIndex2], [SeverityIndex3], [RiskLevel], [MNeNursing], [ERVisit],[AgencyFlag],[FormStatus], [ActiveInd]) VALUES (@EventID,  @StudentName,  @StudentNameValue,  @StudentDate,  @CompletedOn,  @CompletedOnValue,  @CompletedOnDate,  @CompletedBy,  @CompletedByValue,  @NumberIndex,  @SeverityIndex1,  @SeverityIndex2,  @SeverityIndex3,  @RiskLevel,  @MNeNursing,  @ERVisit,@AgencyFlag,@ItsFormStatus, @ItsMainActiveInd);
select @ItsID = SCOPE_IDENTITY();
update #TEMP set ItsID=@ItsID;
insert into UINE_Forms (UIEventID,IndFormID,IndFormCode,FormNumber,ActiveInd,UIEventNum) values (@EventID,@ItsID,'ITS',(select ISNULL((select max(FormNumber)+1 from UINE_Forms where UIEventID=@EventID and IndFormCode='ITS'),1)),'A',@EventNum);
select EvID,EvNum,ItsID from #TEMP;
DROP TABLE #TEMP;
END

END





GO
