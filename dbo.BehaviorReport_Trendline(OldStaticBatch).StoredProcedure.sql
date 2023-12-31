USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[BehaviorReport_Trendline(OldStaticBatch)]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[BehaviorReport_Trendline(OldStaticBatch)]
@StartDate datetime,
@ENDDate datetime,
@Studentid int,
@SchoolId int,
@Behavior varchar(500),
@Trendtype varchar(50),
@Event varchar(50)

AS
BEGIN
	
	SET NOCOUNT ON;


	DECLARE @SDate datetime,
	@EDate datetime,
	@SID int,
	@BehaviorIDs varchar(500),
	@School int,
	@LCount int,
	@TempLPId int,
	@LoopBehavior int,
	@ClassType varchar(50),
	@Cnt int,
	@Frequency int,
	@Scoreid int,
	@NullcntFrequency int,
	@NullcntDuration int,
	@Breaktrendfrequencyid int,
	@Breaktrenddurationid int,
	@BreakTrenddate datetime,
	@TType varchar(50),
	@NumOfTrend int,
	@TrendsectionNo int,
	@DateCnt int,
	@Midrate1 float,
	@Midrate2 float,
	@Slope float,
	@Const float,
	@Ids int,
	@IdOfTrend int,
	@SUM_XI float,
	@SUM_YI float,
	@SUM_XX float,
	@SUM_XY float,
	@X1 float,
	@Y1 float,
	@Z1 float,
	@X2 float,
	@Y2 float,
	@Z2 float,
	@A float,
	@B float,
	@TMPBehavior int,
	@TMPClassType varchar(50),
	@TMPDate datetime,
	@TMPStartDate datetime,
	@TMPEndDate datetime,
	@TMPCount int,
	@TMPLoopCount int,
	@TMPSesscnt int,	
	@BehaviorOld int,	
	@OldTMPDate datetime,
	@Duration int,
	@CNTBEHAV int,
	@ARROWCNT int,
	@ARROWID int,
	@CNTBEHAVLP int,
	@DupEvent int
	,@SumTotal int
	,@PerInterval float
	,@COUNT INT
	,@FRQ_CNT INT
	,@MID INT
	,@FRQ INT
	,@DATE DATE
	,@IOACOUNT INT
	,@IOAfrq FLOAT
	,@IOAdur FLOAT
	,@CREATD_ON datetime
	,@Time datetime
	,@CREATD_BY VARCHAR(50)
	
	declare @splt table(data int)
	SET @SDate=@StartDate
	SET @EDate=@ENDDate
	SET @SID=@Studentid
	SET @BehaviorIDs=@Behavior
	SET @School=@SchoolId
	SET @LCount=0
	SET @TempLPId=0
	SET @LoopBehavior=0
	SET @ClassType=''
	SET @Cnt=1
	SET @Scoreid=0
	SET @NullcntFrequency=0
	SET @NullcntDuration=0
	SET @Breaktrendfrequencyid=1
	SET @Breaktrenddurationid=1
	SET @TType=@Trendtype
	SET @NumOfTrend=0
	SET @TrendsectionNo=0
	SET @TMPBehavior =0
	SET @TMPClassType =''
	SET @TMPStartDate= @StartDate
	SET @TMPEndDate =@ENDDate
	SET @TMPCount=0
	SET @TMPLoopCount=1
	SET @TMPSesscnt=1
	SET @BehaviorOld=0
	


	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL  
	DROP TABLE #TEMP

	insert into @splt SELECT * FROM Split(@BehaviorIDs,',')

	declare @AGGSCORE table (ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId int,Frequency int,Duration float,Rate float,AggDate datetime,
	IOAFrequency varchar(50),IOADuration varchar(50),ArrowNote varchar(500),ClassType varchar(50));
	
	--SELECT ALL LESSON DETAILS BETWEEN STARTDATE AND ENDDATE FROM THE TABLE 'StdtAggScores' AND INSERT IT TO #AGGSCORE TABLE
	INSERT INTO @AGGSCORE
	SELECT DISTINCT MeasurementId,Frequency,Duration,Rate,AggredatedDate,IOAFrequency,IOADuration,EventName,ClassType FROM StdtAggScores WHERE AggredatedDate BETWEEN @SDate AND @EDate
	AND StudentId=@SID AND SchoolId=@School AND StdtSessEventId IS NULL AND MeasurementId IN (SELECT * from @splt) ORDER BY MeasurementId,AggredatedDate
	--SELECT * FROM #AGGSCORE
	CREATE TABLE #TEMP(Scoreid int PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId int,Frequency FLOAT,Duration float,Rate float,IOAPercFrq VARCHAR(50),IOAPercDur VARCHAR(50),AggredatedDate datetime,BreakTrendFrequency int,BreakTrendDuration int,
	XValue int,TrendFrequency float,TrendDuration float,IOAFrequency varchar(50),IOADuration varchar(50),Behaviour varchar(500),ArrowNote varchar(500),EventType varchar(50),EventName nvarchar(max),
	EvntTs datetime,EndTime datetime,Comment varchar(500),ClassType varchar(50), FrqStat int);

	SET @TMPCount = (SELECT COUNT(*) FROM @AGGSCORE)
	WHILE(@TMPCount>0)
	BEGIN	
	SELECT @BehaviorOld=MeasurementId,@OldTMPDate=AggDate FROM @AGGSCORE WHERE ID=(@TMPLoopCount-1)
	SELECT @TMPBehavior=MeasurementId,@TMPDate=AggDate FROM @AGGSCORE WHERE ID=@TMPLoopCount
	
	--SET @TMPBehavior=(SELECT MeasurementId FROM #AGGSCORE WHERE ID=@TMPLoopCount)
	--SET @TMPDate=(SELECT AggDate FROM #AGGSCORE WHERE ID=@TMPLoopCount)


	IF(@TMPDate<=@OldTMPDate)
	BEGIN
	WHILE(@OldTMPDate<=@EDate)
	BEGIN
	SET @OldTMPDate=DATEADD(DAY,1,@OldTMPDate)
	INSERT INTO #TEMP (MeasurementId,AggredatedDate,XValue) VALUES ( @BehaviorOld,@OldTMPDate,@TMPSesscnt)	
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	END
	
	IF(@TMPBehavior<>@BehaviorOld)
	BEGIN		
	SET @TMPSesscnt=1
	SET @TMPStartDate=@SDate		
	END
	ELSE IF(@TMPBehavior<>@BehaviorOld)
	BEGIN
	SET @TMPSesscnt=1
	SET @TMPStartDate=@SDate
	END

	


	SET @BehaviorOld=@TMPBehavior
	IF(@TMPDate=@TMPStartDate)
	BEGIN
	INSERT INTO #TEMP (MeasurementId,AggredatedDate,XValue,Frequency,Duration,Rate,IOAFrequency,IOADuration,ArrowNote) 
	SELECT MeasurementId,AggDate,@TMPSesscnt,Frequency,Duration,Rate,IOAFrequency,IOADuration,ArrowNote FROM @AGGSCORE WHERE ID=@TMPLoopCount
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	ELSE
	BEGIN
	WHILE(@TMPDate<>@TMPStartDate)
	BEGIN
	IF(@TMPDate>@TMPStartDate)
	BEGIN
	INSERT INTO #TEMP (MeasurementId,AggredatedDate,XValue) VALUES (@TMPBehavior,@TMPStartDate,@TMPSesscnt)
	SET @TMPStartDate=DATEADD(DAY,1,@TMPStartDate)
	END
	ELSE
	BEGIN
	INSERT INTO #TEMP (MeasurementId,AggredatedDate,XValue) VALUES (@TMPBehavior,@TMPDate,@TMPSesscnt)
	SET @TMPDate=DATEADD(DAY,1,@TMPDate)
	END	
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	IF(@TMPDate=@TMPStartDate)
	BEGIN
	INSERT INTO #TEMP (MeasurementId,AggredatedDate,XValue,Frequency,Duration,Rate,IOAFrequency,IOADuration,ArrowNote) 
	SELECT MeasurementId,AggDate,@TMPSesscnt,Frequency,Duration,Rate,IOAFrequency,IOADuration,ArrowNote FROM @AGGSCORE WHERE ID=@TMPLoopCount
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	END

	SET @TMPLoopCount=@TMPLoopCount+1	
	SET @TMPCount=@TMPCount-1	
	SET @TMPStartDate=DATEADD(DAY,1,@TMPStartDate)	
	IF(@TMPCount=0)
	BEGIN
	WHILE(@TMPDate<=@EDate)
	BEGIN
	SET @TMPDate=DATEADD(DAY,1,@TMPDate)
	INSERT INTO #TEMP (MeasurementId,AggredatedDate,XValue) VALUES ( @TMPBehavior,@TMPDate,@TMPSesscnt)	
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	END

	
	END	

	--UPDATE #TEMP SET Frequency=0 WHERE Frequency IS NULL AND CONVERT(DATE,AggredatedDate) IN (SELECT CONVERT(DATE,EvntTs) FROM 
	--StdtSessEvent WHERE EventType='CH' AND StudentId=@SID)
	--UPDATE #TEMP SET Duration=0 WHERE Duration IS NULL AND MeasurementId IN (SELECT MeasurementId FROM BehaviourDetails WHERE Duration='true'
	--AND MeasurementId IN (SELECT DISTINCT MeasurementId FROM #TEMP)) AND CONVERT(DATE,AggredatedDate) IN (SELECT CONVERT(DATE,EvntTs) FROM 
	--StdtSessEvent WHERE EventType='CH' AND StudentId=@SID)

	CREATE TABLE #TMP(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId INT,AggredatedDate DATE,Type VARCHAR(10))

	INSERT INTO #TMP (MeasurementId
	,AggredatedDate
	,Type)
	SELECT 0 MeasurementId
	,CONVERT(DATE,EvntTs) AggredatedDate 
	,StdtSessEventType
	FROM [dbo].[StdtSessEvent]
	 WHERE StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes'  

	INSERT INTO #TMP (MeasurementId
	,AggredatedDate
	,Type)
	SELECT 
	[StdtSessEvent].[MeasurementId]
	,CONVERT(DATE,EvntTs) AggredatedDate
	,StdtSessEventType
	FROM [dbo].[StdtSessEvent]
	WHERE StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (SELECT * from @splt) AND EventType='EV' 
	AND EvntTs BETWEEN @SDate AND @EDate AND StdtSessEventType<>'Arrow notes'
	
	CREATE TABLE #EVNT(ID INT PRIMARY KEY IDENTITY(1,1),LPID INT)
	INSERT INTO #EVNT SELECT * from @splt
	
	SET @CNTBEHAV=(SELECT COUNT(*) FROM #EVNT)		

	WHILE(@CNTBEHAV>0)
	BEGIN


	CREATE TABLE #LPARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),LESSONID int,AggredatedDate datetime,
	IOAfreqPerc VARCHAR(50),IOAdurPerc VARCHAR(50),BehavName VARCHAR(200),ArrowNote VARCHAR(500)
	,EventType VARCHAR(50),EventName NVARCHAR(max),TimeStampForReport datetime,EndTime datetime,
	Comment VARCHAR(200));
	
	INSERT INTO #LPARROW
	
	SELECT 
	(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) AS BehavId	
	,TimeStampForReport AS AggredatedDate
	,NULL IOAFreq
	,NULL IOADur
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV)) BehavName
	
	,EventName AS ArrowNote
	
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,[StdtSessEvent].EndTime
	,Comment FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE 
	Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType='Arrow notes' AND @Event LIKE '%' + 'Arrow' + '%'


	
	INSERT INTO #LPARROW
		SELECT 
	[StdtSessEvent].[MeasurementId]
	,TimeStampForReport AS AggredatedDate
	,NULL IOAFreq
	,NULL IOADur
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV)) BehavName
	
	,EventName AS ArrowNote
	
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,[StdtSessEvent].EndTime
	,Comment FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] 
	IN (SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType='Arrow notes'AND @Event LIKE '%' + 'Arrow' + '%'
	
	SET @ARROWCNT =(SELECT COUNT(*) FROM #LPARROW)

	SET @ARROWID=1

	WHILE(@ARROWCNT>0)

	BEGIN

	SET @CNTBEHAVLP=(SELECT COUNT(*) FROM #TEMP WHERE [MeasurementId]=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID) ) 
		
	INSERT INTO #TEMP (MeasurementId
	,Frequency
	,AggredatedDate
	,IOAFrequency
	,IOADuration
	,Behaviour
	
	,ArrowNote
	
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment)
	SELECT LESSONID
	,0 Frequency
	,AggredatedDate
	,NULL IOAFrequency
	,NULL IOADuration	
	,BehavName
	
	,ArrowNote   --+'---------->' AS ArrowNote
	
	,EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment
	 FROM #LPARROW WHERE ID=@ARROWID

	SET @ARROWCNT=@ARROWCNT-1
	SET @ARROWID=@ARROWID+1
	END

	

	 DROP TABLE #LPARROW
	 
IF((SELECT COUNT(*) FROM #TEMP WHERE MeasurementId=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV))>0)
BEGIN

	INSERT INTO #TEMP (MeasurementId
	,AggredatedDate
	,IOAFrequency
	,IOADuration
	,Behaviour
	
	,ArrowNote
	
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment
	,ClassType)
	SELECT 
	(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) MeasurementId
	,DATEADD(HOUR,-12, CONVERT(DATETIME,CONVERT(DATE,EvntTs)))  AS AggredatedDate
	--,DATEADD(HOUR,1, CONVERT(DATE,EvntTs)) AS AggredatedDate
	,NULL IOAFrequency
	,NULL IOADuration
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV)) BehavName
	
	,NULL AS ArrowNote
	
	,StdtSessEventType AS EventType
	,(SELECT FORMAT(CONVERT(DATE,EvntTs),'MM/dd') +','+ STUFF((SELECT  ', '+ EventName FROM (SELECT EventName  FROM [dbo].[StdtSessEvent] EVNT
	WHERE EVNT.StudentId=@SID AND EventType='EV' AND CONVERT(DATE,EVNT.EvntTs) =CONVERT(DATE,VNT.EvntTs) --AND EVNT.StdtSessEventType=VNT.StdtSessEventType
	AND StdtSessEventType<>'Arrow notes' AND (EVNT.MeasurementId=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) OR EVNT.MeasurementId=0)) LP FOR XML PATH('')),1,1,'')) EventName
	,CONVERT(DATE,EvntTs) EvntTs
	,NULL AS EndTime
	,NULL AS Comment
	,(SELECT CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType FROM Class WHERE ClassId=VNT.ClassId) ClassType
	 FROM [dbo].[StdtSessEvent] VNT
	 WHERE VNT.StudentId=@SID AND (VNT.MeasurementId =(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) OR VNT.MeasurementId=0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes' GROUP BY VNT.MeasurementId,CONVERT(DATE,EvntTs),VNT.StdtSessEventType,VNT.ClassId
	END

	SET @CNTBEHAV=@CNTBEHAV-1
	END

	DROP TABLE #EVNT

	--TO SEPERATE EACH TRENDLINE FROM THE TABLE #TEMP, ADD EACH PAGE SESSION TO #TEMPTYPE 
	CREATE TABLE #TEMPTYPE(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),BehaviorId int);
	INSERT INTO #TEMPTYPE SELECT DISTINCT MeasurementId FROM #TEMP

	SET @Cnt=1
	--FOR SEPERATING EACH TERAND LINE SECTION AND NUMBERED IT AS 1,2,3 ETC IN 'BreakTrendFrequency' COLUMN OF #TEMP TABLE
	SET @LCount=(SELECT COUNT(*) FROM #TEMPTYPE)
	WHILE(@LCount>0)
	BEGIN
	
	SET @LoopBehavior=(SELECT BehaviorId FROM #TEMPTYPE WHERE ID=@Cnt)
	SET @Scoreid=(SELECT TOP 1 Scoreid FROM #TEMP WHERE MeasurementId=@LoopBehavior )

	WHILE((SELECT COUNT(*) FROM #TEMP WHERE MeasurementId=@LoopBehavior AND Scoreid=@Scoreid)>0)
	BEGIN
	SET @Frequency=(SELECT ISNULL(CONVERT(int,Frequency),-1) FROM #TEMP WHERE Scoreid=@Scoreid)
	SET @Duration=(SELECT ISNULL(CONVERT(float,Duration),-1) FROM #TEMP WHERE Scoreid=@Scoreid)

	IF((SELECT COUNT(*) FROM #TEMP WHERE MeasurementId=@LoopBehavior AND AggredatedDate=DATEADD(HOUR,-12, (SELECT AggredatedDate FROM #TEMP WHERE Scoreid=@Scoreid)))>0 )
	BEGIN
	IF(@Frequency=-1)
	BEGIN
	SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	END
	ELSE
	BEGIN
	SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0	
	END
	END

	IF((SELECT COUNT(*) FROM #TEMP WHERE MeasurementId=@LoopBehavior AND AggredatedDate=DATEADD(HOUR,-12, (SELECT AggredatedDate FROM #TEMP WHERE Scoreid=@Scoreid)))>0 )
	BEGIN
	IF(@Duration=-1)
	BEGIN
	SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	END
	ELSE
	BEGIN
	SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0	
	END
	END

	IF(@Frequency=-1)
	BEGIN
	SET @NullcntFrequency=@NullcntFrequency+1	
	END
	ELSE IF(@NullcntFrequency>5 AND @Frequency<>-1)
	BEGIN
	SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0		
	END
	ELSE IF(@Frequency<>-1)
	BEGIN
	IF((SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)<>0)
	BEGIN
	IF((SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid)<>(SELECT TOP 1 MeasurementId FROM #TEMP WHERE BreakTrendFrequency= (SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)))
	BEGIN	
	SET @Breaktrendfrequencyid=@Breaktrendfrequencyid+1
	END
	END
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0	
	END	

	IF(@Duration=-1)
	BEGIN
	SET @NullcntDuration=@NullcntDuration+1	
	END
	ELSE IF(@NullcntDuration>5 AND @Duration<>-1)
	BEGIN
	SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0		
	END
	ELSE IF(@Duration<>-1)
	BEGIN
	IF((SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)<>0)
	BEGIN
	IF((SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid)<>(SELECT TOP 1 MeasurementId FROM #TEMP WHERE BreakTrendDuration= (SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)))
	BEGIN	
	SET @Breaktrenddurationid=@Breaktrenddurationid+1
	END
	END
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0	
	END	

	-------------------------------------------------------------------------------------


	--IF CHARINDEX('Major',@Event) > 0
	--BEGIN
 ----   select @Scoreid as scoreid
	----SELECT CONVERT(DATE,AggredatedDate) aggdate FROM #TEMP WHERE Scoreid=@Scoreid

	----SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type='Major'

	----SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major'

	----SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major'

	--IF((SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major')>0)
	--BEGIN
	--IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major')>0)
	--BEGIN
	--UPDATE #TEMP SET BreakTrendFrequency = NULL  WHERE Scoreid=@Scoreid
	--SET @NullcntDuration=0

	--UPDATE #TEMP SET BreakTrendDuration=NULL WHERE Scoreid=@Scoreid
	--SET @NullcntDuration=0
	--END
	--END	
	----ELSE IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major')>0)
	----BEGIN
	----SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	----UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	----SET @NullcntFrequency=0	


	----SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	----UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	----SET @NullcntDuration=0
	----END
	--END
	--IF CHARINDEX('Minor',@Event) > 0
	--BEGIN
	----select @Scoreid as scoreid
	----SELECT CONVERT(DATE,AggredatedDate) aggdate FROM #TEMP WHERE Scoreid=@Scoreid

	----SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor'

	----SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor'

	----SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor'

	--IF((SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor')>0)
	--BEGIN
	--IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor')>0)
	--BEGIN
	--UPDATE #TEMP SET BreakTrendFrequency=NULL WHERE Scoreid=@Scoreid
	--SET @NullcntDuration=0

	--UPDATE #TEMP SET BreakTrendDuration=NULL WHERE Scoreid=@Scoreid
	--SET @NullcntDuration=0
	--END
	--END	
	----ELSE IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	----AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor')>0)
	----BEGIN
	----SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	----UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	----SET @NullcntFrequency=0	


	----SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	----UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	----SET @NullcntDuration=0
	----END
	--END

	
	
	-------------------------------------------------------------------------------------

	SET @Scoreid=@Scoreid+1
	END


	SET @Cnt=@Cnt+1
	SET @LCount=@LCount-1
	END

	DROP TABLE #TEMPTYPE
	DROP TABLE #TMP



	--SELECT EACH TREND LINE SECTION FROM #TEMP AND CALCULATE TREND POINT VALUES
	SET @Cnt=0
	IF(@TType='Quarter')
	BEGIN
	SET @NumOfTrend=(SELECT COUNT(DISTINCT BreakTrendFrequency) FROM #TEMP)
	
	WHILE(@NumOfTrend>0)
	BEGIN
	SET @Cnt=@Cnt+1
	SET @TrendsectionNo=(SELECT COUNT(*) FROM #TEMP WHERE BreakTrendFrequency=@Cnt)
	
	IF(@TrendsectionNo>2)
	BEGIN		
	CREATE TABLE #TRENDSECTION(Id int PRIMARY KEY NOT NULL IDENTITY(1,1),Trenddate datetime,Frequency float,Scoreid int);
	INSERT INTO #TRENDSECTION SELECT AggredatedDate,CONVERT(float,Frequency),Scoreid FROM #TEMP WHERE Scoreid BETWEEN (SELECT TOP 1 Scoreid FROM #TEMP WHERE 
	BreakTrendFrequency=@Cnt ORDER BY Scoreid) AND (SELECT TOP 1 Scoreid FROM #TEMP WHERE BreakTrendFrequency=@Cnt ORDER BY Scoreid DESC)
		
	IF((SELECT COUNT(*) FROM #TRENDSECTION)%2=0)
	SET @DateCnt=((SELECT COUNT(*) FROM #TRENDSECTION)/2)+1
	ELSE
	SET @DateCnt=((SELECT COUNT(*) FROM #TRENDSECTION)/2)+2

	
	SET @Midrate1= (SELECT ((SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDSECTION) 
	AND Frequency IS NOT NULL ORDER BY Frequency) As A ORDER BY Frequency DESC) +(SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE 
	Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDSECTION) AND Frequency IS NOT NULL ORDER BY Frequency DESC) As A ORDER BY Frequency Asc)) / 2 )
	SET @Midrate2= (SELECT ((SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDSECTION)
	AND Frequency IS NOT NULL ORDER BY Frequency) As A ORDER BY Frequency DESC) +(SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE 
	Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDSECTION) AND Frequency IS NOT NULL ORDER BY Frequency DESC) As A ORDER BY Frequency Asc)) / 2 )
	
	
	IF(@TrendsectionNo>2)
	BEGIN
	--Applying Line Equation Y=mx+b To find Slope 'm' AND Constant 'b'
	SET @Slope=(@Midrate2-@Midrate1)/((SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendFrequency=@Cnt ORDER BY Scoreid DESC)-(SELECT TOP 1 XValue 
	FROM #TEMP WHERE BreakTrendFrequency=@Cnt ORDER BY Scoreid))
	--b=y-mx
	SET @Const=@Midrate1-(@Slope*(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendFrequency=@Cnt ORDER BY Scoreid))

	SET @Ids=(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendFrequency=@Cnt ORDER BY Scoreid) --FIRST x value
	SET @IdOfTrend=(SELECT TOP 1 Scoreid FROM #TRENDSECTION ORDER BY Id)
	WHILE(@IdOfTrend<=(SELECT MAX(Scoreid) FROM #TRENDSECTION))
	BEGIN		
	UPDATE #TEMP SET TrendFrequency=((@Slope*@Ids)+@Const) WHERE Scoreid=@IdOfTrend
	SET @IdOfTrend=@IdOfTrend+1
	SET @Ids=@Ids+1
	END		
	END	
	DROP TABLE #TRENDSECTION
	END
	SET @NumOfTrend=@NumOfTrend-1
	END
	--------------------------------------------------------
	SET @Cnt=0
	SET @NumOfTrend=(SELECT COUNT(DISTINCT BreakTrendDuration) FROM #TEMP)
	WHILE(@NumOfTrend>0)
	BEGIN
	SET @Cnt=@Cnt+1
	SET @TrendsectionNo=(SELECT COUNT(*) FROM #TEMP WHERE BreakTrendDuration=@Cnt)

	IF(@TrendsectionNo>2)
	BEGIN	
	
	Declare @TRENDS table (Id int PRIMARY KEY NOT NULL IDENTITY(1,1),Trenddate datetime,Duration float,Scoreid int);
	INSERT INTO @TRENDS SELECT AggredatedDate,CONVERT(float,Duration),Scoreid FROM #TEMP WHERE Scoreid BETWEEN (SELECT TOP 1 Scoreid FROM #TEMP WHERE 
	BreakTrendDuration=@Cnt ORDER BY Scoreid) AND (SELECT TOP 1 Scoreid FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid DESC)
	IF((SELECT COUNT(*) FROM @TRENDS)%2=0)
	SET @DateCnt=((SELECT COUNT(*) FROM @TRENDS)/2)+1
	ELSE
	SET @DateCnt=((SELECT COUNT(*) FROM @TRENDS)/2)+2
	SET @Midrate1= (SELECT ((SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM @TRENDS WHERE Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM @TRENDS) 
	AND Duration IS NOT NULL ORDER BY Duration) As A ORDER BY Duration DESC) +(SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM @TRENDS WHERE 
	Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM @TRENDS) AND Duration IS NOT NULL ORDER BY Duration DESC) As A ORDER BY Duration Asc)) / 2 )
	SET @Midrate2= (SELECT ((SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM @TRENDS WHERE Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM @TRENDS)
	AND Duration IS NOT NULL ORDER BY Duration) As A ORDER BY Duration DESC) +(SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM @TRENDS WHERE 
	Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM @TRENDS) AND Duration IS NOT NULL  ORDER BY Duration DESC) As A ORDER BY Duration Asc)) / 2 )

	
	
	IF(@TrendsectionNo>2)
	BEGIN
	--Applying Line Equation Y=mx+b To find Slope 'm' AND Constant 'b'
	SET @Slope=(@Midrate2-@Midrate1)/((SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid DESC)-(SELECT TOP 1 XValue 
	FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid))
	--b=y-mx
	SET @Const=@Midrate1-(@Slope*(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid))

	SET @Ids=(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid) --FIRST x value
	SET @IdOfTrend=(SELECT TOP 1 Scoreid FROM @TRENDS ORDER BY Id)
	WHILE(@IdOfTrend<=(SELECT MAX(Scoreid) FROM @TRENDS))
	BEGIN		
	UPDATE #TEMP SET TrendDuration=((@Slope*@Ids)+@Const) WHERE Scoreid=@IdOfTrend
	SET @IdOfTrend=@IdOfTrend+1
	SET @Ids=@Ids+1
	END		
	END	
	--DROP TABLE #TRENDS
	END
	SET @NumOfTrend=@NumOfTrend-1
	END
	END	

	

	SET @TMPCount = (SELECT COUNT(*) FROM #TEMP)
	WHILE(@TMPCount>0)
	BEGIN
	UPDATE #TEMP SET Behaviour=(SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@TMPCount))
	WHERE Scoreid=@TMPCount
	SET @TMPCount=@TMPCount-1
	END

	IF((SELECT COUNT(*) FROM @AGGSCORE)>0)
	BEGIN
	UPDATE #TEMP SET 
	ClassType=(SELECT ClassType FROM @AGGSCORE WHERE ID=1)
	END


	--DROP TABLE #AGGSCORE

	----------------------Update frq sumtotal and interval status---------------------
	--For Frequency
	UPDATE #TEMP SET FrqStat=0 where MeasurementId IN (SELECT MeasurementId FROM BehaviourDetails WHERE FrqStat=1 OR (PartialInterval=0 AND YesOrNo=1))
	--For Sum Total
	UPDATE #TEMP SET FrqStat=1 WHERE MeasurementId IN(SELECT MeasurementId FROM BehaviourDetails WHERE YesOrNo=1 AND ((PartialInterval=1 AND IfPerInterval=0) OR (PartialInterval=1 AND IfPerInterval is null)))
	--For %Interval
	UPDATE #TEMP SET FrqStat=2 WHERE MeasurementId IN (SELECT MeasurementId FROM BehaviourDetails WHERE PartialInterval=1 AND YesOrNo=1 AND IfPerInterval=1)


	--------------------------------Update Sumtotal and %Interval values-------------------------------------
	--Update Sum Total
	CREATE TABLE #UPDATESUM(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1), CreatedOn DATE, MeasurId INT)
	--INSERT INTO #UPDATESUM SELECT MeasurementId,CreatedOn FROM BehaviourDetails WHERE PartialInterval=1 AND YesOrNo=1 AND IfPerInterval=0 AND StudentId=@SID
	INSERT INTO #UPDATESUM SELECT DISTINCT CONVERT(DATE,BH.CreatedOn), BH.MeasurementId FROM Behaviour BH 
			INNER JOIN BehaviourDetails BD ON  BD.MeasurementId = BH.MeasurementId
			WHERE BD.YesOrNo=1 AND ((PartialInterval=1 AND IfPerInterval=0) OR (PartialInterval=1 AND IfPerInterval = null) ) AND BD.StudentId=@SID AND BH.CreatedOn BETWEEN @SDate AND @EDate
			ORDER BY MeasurementId
	SET @COUNT= (SELECT COUNT(*)FROM #UPDATESUM)
	SET @FRQ_CNT=1
	WHILE (@COUNT>=0)
	BEGIN
		SET @MID=(SELECT MeasurId FROM #UPDATESUM WHERE ID=@FRQ_CNT)
		SET @DATE=(SELECT CONVERT(DATE,CreatedOn) FROM #UPDATESUM WHERE ID=@FRQ_CNT)
		SET @FRQ=(SELECT SUM(FrequencyCount) FROM Behaviour BH 
			INNER JOIN BehaviourDetails BD ON  BD.MeasurementId = BH.MeasurementId
			WHERE CONVERT(DATE,BH.CreatedOn)=@DATE
			AND BD.PartialInterval=1 AND BD.YesOrNo=1 AND IfPerInterval=0 AND BD.MeasurementId=@MID )
		UPDATE #TEMP SET Frequency=@FRQ WHERE MeasurementId=@MID AND FrqStat=1 AND CONVERT(DATE,AggredatedDate)=@DATE
		SET @COUNT=@COUNT-1
		SET @FRQ_CNT=@FRQ_CNT+1
	END
	DROP TABLE #UPDATESUM

	--Update %Interval
	CREATE TABLE #UPDATEINTERVAL(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1), CreatedOn DATE, MeasurId INT)
	--INSERT INTO #UPDATEINTERVAL SELECT MeasurementId,CreatedOn FROM BehaviourDetails WHERE PartialInterval=1 AND YesOrNo=1 AND IfPerInterval=1 AND StudentId=@SID
	INSERT INTO #UPDATEINTERVAL SELECT DISTINCT CONVERT(DATE,BH.CreatedOn), BH.MeasurementId FROM Behaviour BH 
			INNER JOIN BehaviourDetails BD ON  BD.MeasurementId = BH.MeasurementId
			WHERE PartialInterval=1 AND BD.YesOrNo=1 AND IfPerInterval=1 AND BD.StudentId=@SID AND CONVERT(DATE,BH.CreatedOn) BETWEEN @SDate AND @EDate
			ORDER BY MeasurementId
	SET @COUNT= (SELECT COUNT(*)FROM #UPDATEINTERVAL)
	SET @FRQ_CNT=1
	WHILE (@COUNT>=0)
	BEGIN
		SET @MID=(SELECT MeasurId FROM #UPDATEINTERVAL WHERE ID=@FRQ_CNT)
		SET @DATE=(SELECT CONVERT(DATE,CreatedOn) FROM #UPDATEINTERVAL WHERE ID=@FRQ_CNT)
		SET @PerInterval=(SELECT TOP 1 CONVERT(FLOAT,(SELECT SUM(FrequencyCount) FROM Behaviour BH 
			INNER JOIN BehaviourDetails BD ON  BD.MeasurementId = BH.MeasurementId
			WHERE CONVERT(DATE,BH.CreatedOn)=@DATE AND BH.YesOrNo=1
			AND BD.PartialInterval=1 AND BD.YesOrNo=1 AND IfPerInterval=1 AND BD.MeasurementId=@MID)) /
			CONVERT(FLOAT,(SELECT COUNT (*) FROM Behaviour WHERE CONVERT(DATE,CreatedOn)=@DATE 
			AND  MeasurementId=@MID AND YesOrNo IS NOT NULL)) * 100
			FROM Behaviour WHERE CONVERT(DATE,CreatedOn)=@DATE
			AND  MeasurementId=@MID AND YesOrNo IS NOT NULL)
		SET @PerInterval= ROUND(@PerInterval,2)
		UPDATE #TEMP SET Frequency=@PerInterval WHERE MeasurementId=@MID AND FrqStat=2 AND CONVERT(DATE,AggredatedDate)=@DATE
		SET @COUNT=@COUNT-1
		SET @FRQ_CNT=@FRQ_CNT+1
	END
	DROP TABLE #UPDATEINTERVAL


	--IOA % calculation for freq and duration
	declare  @IOAPERC TABLE(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1), CreatedOn DATETIME, MeasurId INT,CreatedBy INT)
	INSERT INTO @IOAPERC SELECT DISTINCT CONVERT(DATETIME,CreatedOn), MeasurementId,CreatedBy FROM BehaviorIOADetails WHERE CONVERT(DATE,CreatedOn) BETWEEN @SDate AND @EDate 
		AND IOAPerc IS NOT NULL AND MeasurementId IN(SELECT DISTINCT MeasurementId FROM #TEMP) ORDER BY MeasurementId
    SET @COUNT= (SELECT COUNT(*) FROM @IOAPERC)
	SET @IOACOUNT=1
	
	WHILE(@COUNT>=0)
	BEGIN
	   
		SET @MID=(SELECT MeasurId FROM @IOAPERC WHERE ID=@IOACOUNT)
        SET @DATE=(SELECT CONVERT(DATE,CreatedOn) FROM @IOAPERC WHERE ID=@IOACOUNT)
		SET @CREATD_BY=(SELECT CreatedBy FROM @IOAPERC WHERE ID=@IOACOUNT)
		SET @CREATD_ON=(SELECT CONVERT(DATETIME,CreatedOn) FROM @IOAPERC WHERE ID=@IOACOUNT)
		
		SET @Time=DATEADD(minute, -5, @CREATD_ON)
		SET @IOAfrq=(SELECT ROUND(AVG(CONVERT(FLOAT,IOAPerc)),0) FROM BehaviorIOADetails WHERE FrequencyCount IS NOT NULL AND Duration IS NULL AND MeasurementId=@MID AND CONVERT(DATE,CreatedOn)=@DATE)
		SET @IOAdur=(SELECT ROUND(AVG(CONVERT(FLOAT,IOAPerc)),0) FROM BehaviorIOADetails WHERE Duration IS NOT NULL AND FrequencyCount IS NULL AND MeasurementId=@MID AND CONVERT(DATE,CreatedOn)=@DATE)
		UPDATE #TEMP SET IOAPercFrq='IOA '+CONVERT(VARCHAR(10),@IOAfrq)+'%', IOAPercDur='IOA '+CONVERT(VARCHAR(10),@IOAdur)+'%'--, EventType='Arrow notes',
			--IOAFrequency=CONVERT(VARCHAR,@IOAfrq), IOADuration=CONVERT(VARCHAR,@IOAdur) 
			WHERE CONVERT(DATE,AggredatedDate)=@DATE AND MeasurementId=@MID
			
	    UPDATE #TEMP SET IOAPercFrq=(IOAPercFrq+' '+(SELECT TOP 1 RTRIM(LTRIM(UPPER(US.UserInitial))) FROM Behaviour BH INNER JOIN [USER] US ON BH.CreatedBy = US.UserId 
		WHERE BH.CreatedOn between @Time AND @CREATD_ON  ORDER BY BH.CreatedOn DESC)+'/'+(SELECT TOP 1 RTRIM(LTRIM(UPPER(US.UserInitial))) FROM BehaviorIOADetails BI INNER JOIN [USER] US ON BI.CreatedBy = US.UserId 
		WHERE BI.CreatedOn=@CREATD_ON ORDER BY BI.CreatedOn DESC)) where CONVERT(DATE,AggredatedDate)=@DATE  AND MeasurementId=@MID

		UPDATE #TEMP SET IOAPercDur=(IOAPercDur+' '+(SELECT TOP 1 RTRIM(LTRIM(UPPER(US.UserInitial))) FROM Behaviour BH INNER JOIN [USER] US ON BH.CreatedBy = US.UserId 
		WHERE BH.CreatedOn between @Time AND @CREATD_ON ORDER BY BH.CreatedOn DESC)+'/'+(SELECT TOP 1 RTRIM(LTRIM(UPPER(US.UserInitial))) FROM BehaviorIOADetails BI INNER JOIN [USER] US ON BI.CreatedBy = US.UserId 
		WHERE BI.CreatedOn=@CREATD_ON ORDER BY BI.CreatedOn DESC)) where CONVERT(DATE,AggredatedDate)=@DATE  AND MeasurementId=@MID

          SET @COUNT=@COUNT-1
		SET @IOACOUNT=@IOACOUNT+1
	END
	
	--DROP TABLE #IOAPERC

	-------------------------------UPDATE FREQUENCY AND DURATION-------------------------------------------------
	--UPDATE #TEMP SET Frequency=0 WHERE Frequency IS NULL AND CONVERT(DATE,AggredatedDate) IN (SELECT CONVERT(DATE,EvntTs) FROM 
	--StdtSessEvent WHERE EventType='CH' AND StudentId=@SID) --AND FrqStat=0
	--UPDATE #TEMP SET Duration=0 WHERE Duration IS NULL AND MeasurementId IN (SELECT MeasurementId FROM BehaviourDetails WHERE Duration='true'
	--AND MeasurementId IN (SELECT DISTINCT MeasurementId FROM #TEMP)) AND CONVERT(DATE,AggredatedDate) IN (SELECT CONVERT(DATE,EvntTs) FROM 
	--StdtSessEvent WHERE EventType='CH' AND StudentId=@SID) --AND FrqStat=0

	-------------------------------------------------------------------------------------

	
	SELECT *,(SELECT Duration FROM BehaviourDetails WHERE MeasurementId=#TEMP.MeasurementId)DuratnStat,
	(SELECT BehavDefinition FROM BehaviourDetails BDS WHERE BDS.MeasurementId=#TEMP.MeasurementId) Deftn,
	'Stgy: '+(SELECT BehavStrategy FROM BehaviourDetails BDS WHERE BDS.MeasurementId=#TEMP.MeasurementId) Stratgy
	 FROM #TEMP ORDER BY MeasurementId,AggredatedDate,XValue
	 
END

GO
