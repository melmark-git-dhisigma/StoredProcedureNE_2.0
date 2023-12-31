USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[BehaviorReport_Trendline_backup]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BehaviorReport_Trendline_backup]
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
	@BehaviorIDs varchar(100),
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


	CREATE TABLE #AGGSCORE(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId int,Frequency int,Duration int,Rate float,AggDate datetime,
	IOAFrequency varchar(50),IOADuration varchar(50),ArrowNote varchar(500),ClassType varchar(50));

	--SELECT ALL LESSON DETAILS BETWEEN STARTDATE AND ENDDATE FROM THE TABLE 'StdtAggScores' AND INSERT IT TO #AGGSCORE TABLE
	INSERT INTO #AGGSCORE
	SELECT DISTINCT MeasurementId,Frequency,Duration,Rate,AggredatedDate,IOAFrequency,IOADuration,EventName,ClassType FROM StdtAggScores WHERE CONVERT(DATE,AggredatedDate) BETWEEN @SDate AND @EDate
	AND StudentId=@SID AND SchoolId=@School AND StdtSessEventId IS NULL AND MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,',')) ORDER BY MeasurementId,AggredatedDate

	CREATE TABLE #TEMP(Scoreid int PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId int,Frequency int,Duration int,Rate float,AggredatedDate datetime,BreakTrendFrequency int,BreakTrendDuration int,
	XValue int,TrendFrequency float,TrendDuration float,IOAFrequency varchar(50),IOADuration varchar(50),Behaviour varchar(500),StudentFname varchar(200),ArrowNote varchar(500),StudentLname varchar(200),EventType varchar(50),EventName varchar(500),
	EvntTs datetime,EndTime datetime,Comment varchar(500),ClassType varchar(50));

	SET @TMPCount = (SELECT COUNT(*) FROM #AGGSCORE)
	WHILE(@TMPCount>0)
	BEGIN	
	SET @BehaviorOld=(SELECT MeasurementId FROM #AGGSCORE WHERE ID=(@TMPLoopCount-1))
	SET @OldTMPDate=(SELECT AggDate FROM #AGGSCORE WHERE ID=(@TMPLoopCount-1))
	
	SET @TMPBehavior=(SELECT MeasurementId FROM #AGGSCORE WHERE ID=@TMPLoopCount)
	SET @TMPDate=(SELECT AggDate FROM #AGGSCORE WHERE ID=@TMPLoopCount)


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
	SELECT MeasurementId,AggDate,@TMPSesscnt,Frequency,Duration,Rate,IOAFrequency,IOADuration,ArrowNote FROM #AGGSCORE WHERE ID=@TMPLoopCount
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
	SELECT MeasurementId,AggDate,@TMPSesscnt,Frequency,Duration,Rate,IOAFrequency,IOADuration,ArrowNote FROM #AGGSCORE WHERE ID=@TMPLoopCount
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

	UPDATE #TEMP SET Frequency=0 WHERE Frequency IS NULL AND CONVERT(DATE,AggredatedDate) IN (SELECT CONVERT(DATE,EvntTs) FROM 
	StdtSessEvent WHERE EventType='CH' AND StudentId=@SID)
	UPDATE #TEMP SET Duration=0 WHERE Duration IS NULL AND MeasurementId IN (SELECT MeasurementId FROM BehaviourDetails WHERE Duration='true' 
	AND MeasurementId IN (SELECT DISTINCT MeasurementId FROM #TEMP)) AND CONVERT(DATE,AggredatedDate) IN (SELECT CONVERT(DATE,EvntTs) FROM 
	StdtSessEvent WHERE EventType='CH' AND StudentId=@SID)

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
	WHERE StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (SELECT * FROM Split(@BehaviorIDs,',')) AND EventType='EV' 
	AND EvntTs BETWEEN @SDate AND @EDate AND StdtSessEventType<>'Arrow notes'
	
	--SELECT * FROM #TMP ORDER BY AggredatedDate

	--TO SEPERATE EACH TRENDLINE FROM THE TABLE #TEMP, ADD EACH PAGE SESSION TO #TEMPTYPE 
	CREATE TABLE #TEMPTYPE(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),BehaviorId int);
	INSERT INTO #TEMPTYPE SELECT DISTINCT MeasurementId FROM #TEMP

	--FOR SEPERATING EACH TERAND LINE SECTION AND NUMBERED IT AS 1,2,3 ETC IN 'BreakTrendFrequency' COLUMN OF #TEMP TABLE
	SET @LCount=(SELECT COUNT(*) FROM #TEMPTYPE)
	WHILE(@LCount>0)
	BEGIN
	
	SET @LoopBehavior=(SELECT BehaviorId FROM #TEMPTYPE WHERE ID=@Cnt)
	SET @Scoreid=(SELECT TOP 1 Scoreid FROM #TEMP WHERE MeasurementId=@LoopBehavior )

	WHILE((SELECT COUNT(*) FROM #TEMP WHERE MeasurementId=@LoopBehavior AND Scoreid=@Scoreid)>0)
	BEGIN
	SET @Frequency=(SELECT ISNULL(CONVERT(int,Frequency),001) FROM #TEMP WHERE Scoreid=@Scoreid)
	SET @Duration=(SELECT ISNULL(CONVERT(int,Duration),001) FROM #TEMP WHERE Scoreid=@Scoreid)

	IF(@Frequency=001)
	BEGIN
	SET @NullcntFrequency=@NullcntFrequency+1	
	END
	ELSE IF(@NullcntFrequency>5 AND @Frequency<>001)
	BEGIN
	SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0		
	END
	ELSE IF(@Frequency<>001)
	BEGIN
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0	
	END	

	IF(@Duration=001)
	BEGIN
	SET @NullcntDuration=@NullcntDuration+1	
	END
	ELSE IF(@NullcntDuration>5 AND @Duration<>001)
	BEGIN
	SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0		
	END
	ELSE IF(@Duration<>001)
	BEGIN
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0	
	END	

	-------------------------------------------------------------------------------------


	IF CHARINDEX('Major',@Event) > 0
	BEGIN
 --   select @Scoreid as scoreid
	--SELECT CONVERT(DATE,AggredatedDate) aggdate FROM #TEMP WHERE Scoreid=@Scoreid

	--SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type='Major'

	--SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major'

	--SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major'

	IF((SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major')>0)
	BEGIN
	IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major')>0)
	BEGIN
	UPDATE #TEMP SET BreakTrendFrequency = NULL  WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0

	UPDATE #TEMP SET BreakTrendDuration=NULL WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0
	END
	END	
	ELSE IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Major')>0)
	BEGIN
	SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0	


	SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0
	END
	END
	IF CHARINDEX('Minor',@Event) > 0
	BEGIN
	--select @Scoreid as scoreid
	--SELECT CONVERT(DATE,AggredatedDate) aggdate FROM #TEMP WHERE Scoreid=@Scoreid

	--SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor'

	--SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor'

	--SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	--AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor'

	IF((SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor')>0)
	BEGIN
	IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor')>0)
	BEGIN
	UPDATE #TEMP SET BreakTrendFrequency=NULL WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0

	UPDATE #TEMP SET BreakTrendDuration=NULL WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0
	END
	END	
	ELSE IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE Scoreid=@Scoreid) OR MeasurementId=0) AND Type ='Minor')>0)
	BEGIN
	SET @Breaktrendfrequencyid=(SELECT ISNULL(MAX(BreakTrendFrequency),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendFrequency=@Breaktrendfrequencyid WHERE Scoreid=@Scoreid
	SET @NullcntFrequency=0	


	SET @Breaktrenddurationid=(SELECT ISNULL(MAX(BreakTrendDuration),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendDuration=@Breaktrenddurationid WHERE Scoreid=@Scoreid
	SET @NullcntDuration=0
	END
	END

	
	
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
	ORDER BY Frequency) As A ORDER BY Frequency DESC) +(SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE 
	Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDSECTION) ORDER BY Frequency DESC) As A ORDER BY Frequency Asc)) / 2 )
	SET @Midrate2=(SELECT ((SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDSECTION)
	ORDER BY Frequency) As A ORDER BY Frequency DESC) +(SELECT TOP 1 Frequency FROM (SELECT  TOP 50 PERCENT Frequency FROM #TRENDSECTION WHERE 
	Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDSECTION) ORDER BY Frequency DESC) As A ORDER BY Frequency Asc)) / 2 )
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

	SET @Cnt=0
	SET @NumOfTrend=(SELECT COUNT(DISTINCT BreakTrendDuration) FROM #TEMP)
	WHILE(@NumOfTrend>0)
	BEGIN
	SET @Cnt=@Cnt+1
	SET @TrendsectionNo=(SELECT COUNT(*) FROM #TEMP WHERE BreakTrendDuration=@Cnt)

	IF(@TrendsectionNo>2)
	BEGIN	
	
	CREATE TABLE #TRENDS(Id int PRIMARY KEY NOT NULL IDENTITY(1,1),Trenddate datetime,Duration float,Scoreid int);
	INSERT INTO #TRENDS SELECT AggredatedDate,CONVERT(float,Duration),Scoreid FROM #TEMP WHERE Scoreid BETWEEN (SELECT TOP 1 Scoreid FROM #TEMP WHERE 
	BreakTrendDuration=@Cnt ORDER BY Scoreid) AND (SELECT TOP 1 Scoreid FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid DESC)
	IF((SELECT COUNT(*) FROM #TRENDS)%2=0)
	SET @DateCnt=((SELECT COUNT(*) FROM #TRENDS)/2)+1
	ELSE
	SET @DateCnt=((SELECT COUNT(*) FROM #TRENDS)/2)+2
	SET @Midrate1= (SELECT ((SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM #TRENDS WHERE Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDS) 
	ORDER BY Duration) As A ORDER BY Duration DESC) +(SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM #TRENDS WHERE 
	Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDS) ORDER BY Duration DESC) As A ORDER BY Duration Asc)) / 2 )
	SET @Midrate2=(SELECT ((SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM #TRENDS WHERE Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDS)
	ORDER BY Duration) As A ORDER BY Duration DESC) +(SELECT TOP 1 Duration FROM (SELECT  TOP 50 PERCENT Duration FROM #TRENDS WHERE 
	Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDS) ORDER BY Duration DESC) As A ORDER BY Duration Asc)) / 2 )

	
	
	IF(@TrendsectionNo>2)
	BEGIN
	--Applying Line Equation Y=mx+b To find Slope 'm' AND Constant 'b'
	SET @Slope=(@Midrate2-@Midrate1)/((SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid DESC)-(SELECT TOP 1 XValue 
	FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid))
	--b=y-mx
	SET @Const=@Midrate1-(@Slope*(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid))

	SET @Ids=(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendDuration=@Cnt ORDER BY Scoreid) --FIRST x value
	SET @IdOfTrend=(SELECT TOP 1 Scoreid FROM #TRENDS ORDER BY Id)
	WHILE(@IdOfTrend<=(SELECT MAX(Scoreid) FROM #TRENDS))
	BEGIN		
	UPDATE #TEMP SET TrendDuration=((@Slope*@Ids)+@Const) WHERE Scoreid=@IdOfTrend
	SET @IdOfTrend=@IdOfTrend+1
	SET @Ids=@Ids+1
	END		
	END	
	DROP TABLE #TRENDS
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

	IF((SELECT COUNT(*) FROM #AGGSCORE)>0)
	BEGIN
	UPDATE #TEMP SET StudentFname=(SELECT StudentFname FROM Student WHERE StudentId=@SID)
	,StudentLname=(SELECT StudentLname FROM Student WHERE StudentId=@SID)
	,ClassType=(SELECT ClassType FROM #AGGSCORE WHERE ID=1)
	END


	DROP TABLE #AGGSCORE

	
	CREATE TABLE #EVNT(ID INT PRIMARY KEY IDENTITY(1,1),LPID INT)
	INSERT INTO #EVNT SELECT * FROM Split(@BehaviorIDs,',')
	
	SET @CNTBEHAV=(SELECT COUNT(*) FROM #EVNT)		

	WHILE(@CNTBEHAV>0)
	BEGIN


	CREATE TABLE #LPARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),LESSONID int,AggredatedDate datetime,
	IOAfreqPerc VARCHAR(50),IOAdurPerc VARCHAR(50),BehavName VARCHAR(200),StudentFname VARCHAR(200),ArrowNote VARCHAR(500),
	StudentLname VARCHAR(200),EventType VARCHAR(50),EventName VARCHAR(500),TimeStampForReport datetime,EndTime datetime,
	Comment VARCHAR(200));
	
	INSERT INTO #LPARROW
	
	SELECT 
	(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) AS BehavId	
	,TimeStampForReport AS AggredatedDate
	,NULL IOAFreq
	,NULL IOADur
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV)) BehavName
	,Student.StudentFname
	,EventName AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,[StdtSessEvent].EndTime
	,Comment FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE 
	Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType='Arrow notes'


	
	INSERT INTO #LPARROW
		SELECT 
	[StdtSessEvent].[MeasurementId]
	,TimeStampForReport AS AggredatedDate
	,NULL IOAFreq
	,NULL IOADur
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV)) BehavName
	,Student.StudentFname
	,EventName AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,[StdtSessEvent].EndTime
	,Comment FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] 
	IN (SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType='Arrow notes'
	
	SET @ARROWCNT =(SELECT COUNT(*) FROM #LPARROW)

	SET @ARROWID=1

	WHILE(@ARROWCNT>0)

	BEGIN

	SET @CNTBEHAVLP=(SELECT COUNT(*) FROM #TEMP WHERE [MeasurementId]=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID) ) 

	IF(@CNTBEHAVLP>0)

	BEGIN	

	UPDATE #TEMP SET ArrowNote=(SELECT STUFF((SELECT ','+CONVERT(VARCHAR(500), EventName)  FROM (SELECT EventName  FROM #LPARROW 
	WHERE LESSONID=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID)) EName FOR XML PATH('')),1,1,''))   --+'---------->'
	WHERE [MeasurementId]=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID) 
	END

	ELSE

	BEGIN

	INSERT INTO #TEMP (MeasurementId
	,Frequency
	,AggredatedDate
	,IOAFrequency
	,IOADuration
	,Behaviour
	,StudentFname
	,ArrowNote
	,StudentLname
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
	,StudentFname
	,ArrowNote   --+'---------->' AS ArrowNote
	,StudentLname
	,EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment
	 FROM #LPARROW WHERE ID=@ARROWID

	END

	SET @ARROWCNT=@ARROWCNT-1
	SET @ARROWID=@ARROWID+1
	END

	

	 DROP TABLE #LPARROW	


	
	INSERT INTO #TEMP (MeasurementId
	,AggredatedDate
	,IOAFrequency
	,IOADuration
	,Behaviour
	,StudentFname
	,ArrowNote
	,StudentLname
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment
	,ClassType)
	SELECT 
	(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) AS Behavid
	,TimeStampForReport AS AggredatedDate
	,NULL IOAFrequency
	,NULL IOADuration
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV)) BehavName
	,Student.StudentFname
	,NULL AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,[StdtSessEvent].EndTime
	,Comment
	,(SELECT CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType FROM Class WHERE ClassId=[dbo].[StdtSessEvent].ClassId) ClassType
	 FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE 
	Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes'

	INSERT INTO #TEMP (MeasurementId
	,AggredatedDate
	,IOAFrequency
	,IOADuration
	,Behaviour
	,StudentFname
	,ArrowNote
	,StudentLname
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment
	,ClassType)
	SELECT 
	[StdtSessEvent].[MeasurementId]
	,TimeStampForReport AS AggredatedDate
	,NULL IOAFrequency
	,NULL IOADuration
	,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=([StdtSessEvent].[MeasurementId])) BehavName
	,Student.StudentFname
	,NULL AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,[StdtSessEvent].EndTime
	,Comment 
	,(SELECT CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType FROM Class WHERE ClassId=[dbo].[StdtSessEvent].ClassId) ClassType
	FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE 
	Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (SELECT LPID FROM #EVNT WHERE ID=@CNTBEHAV) AND EventType='EV' 
	AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes'

	
	

	SET @CNTBEHAV=@CNTBEHAV-1
	END

	DROP TABLE #EVNT	

	------------------/////////////// EVENT SECOND OLD////////////-------------------------
	--CREATE TABLE #EVNT(ID INT PRIMARY KEY IDENTITY(1,1),BehavId INT)
	--INSERT INTO #EVNT SELECT * FROM Split(@BehaviorIDs,',')
	
	--SET @BehaviorOld=(SELECT COUNT(*) FROM #EVNT)		

	--WHILE(@BehaviorOld>0)
	--BEGIN
	--IF((SELECT COUNT(*) FROM #TEMP WHERE MeasurementId=(SELECT BehavId FROM #EVNT WHERE ID=@BehaviorOld))>0)
	--BEGIN	
	
	
	---- INSERT EVENTS TO #TEMP TABLE
	--INSERT INTO #TEMP (MeasurementId
	--,AggredatedDate
	--,IOAFrequency
	--,IOADuration
	--,Behaviour
	--,StudentFname
	--,ArrowNote
	--,StudentLname
	--,EventType
	--,EventName
	--,EvntTs
	--,EndTime
	--,Comment)
	--SELECT DISTINCT StdtAggScores.MeasurementId
	--,StdtAggScores.AggredatedDate
	--,StdtAggScores.IOAFrequency
	--,StdtAggScores.IOADuration
	--,BehaviourDetails.Behaviour
	--,Student.StudentFname
	--,StdtAggScores.EventName AS ArrowNote
	--,Student.StudentLname
	--,Events.StdtSessEventType AS EventType
	--,Events.EventName
	--,Events.EvntTs
	--,Events.EndTime
	--,Events.Comment
	--FROM StdtAggScores 
	--INNER JOIN
	--BehaviourDetails 
	--ON StdtAggScores.MeasurementId = BehaviourDetails.MeasurementId 
	--INNER JOIN
	--Student 
	--ON StdtAggScores.StudentId = Student.StudentId 
	--LEFT OUTER JOIN
	--StdtSessEvent AS Events 
	--ON Events.StdtSessEventId = StdtAggScores.StdtSessEventId
	--WHERE StdtAggScores.AggredatedDate 
	--BETWEEN @SDate AND @EDate
	--AND StdtAggScores.StudentId=@SID 
	--AND StdtAggScores.SchoolId=@School
	--AND StdtAggScores.MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,',')) 
	--AND StdtAggScores.StdtSessEventId IS NOT NULL
	--AND Events.StdtSessEventType<>'Arrow notes'


	---- INSERT ARROW NOTES TO #TEMP TABLE
	--CREATE TABLE #ANOTES(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId int,AggredatedDate datetime,EventName varchar(500));
	--INSERT INTO #ANOTES (MeasurementId
	--,AggredatedDate
	--,EventName)
	--SELECT DISTINCT StdtAggScores.MeasurementId
	--,StdtAggScores.AggredatedDate
	--,Events.EventName
	--FROM StdtAggScores 
	--INNER JOIN	
	--StdtSessEvent AS Events 
	--ON Events.StdtSessEventId = StdtAggScores.StdtSessEventId
	--WHERE StdtAggScores.AggredatedDate 
	--BETWEEN @SDate AND @EDate
	--AND StdtAggScores.StudentId=@SID 
	--AND StdtAggScores.SchoolId=@School
	--AND StdtAggScores.MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,',')) 
	--AND StdtAggScores.StdtSessEventId IS NOT NULL
	--AND Events.StdtSessEventType='Arrow notes'

	--SET @Cnt=1
	--SET @LCount=(SELECT COUNT(*) FROM #ANOTES)

	--WHILE(@LCount>0)
	--BEGIN
	--UPDATE #TEMP SET ArrowNote=(SELECT STUFF((SELECT ','+CONVERT(VARCHAR, EventName)  FROM (SELECT EventName FROM #ANOTES 
	--WHERE MeasurementId=(SELECT MeasurementId FROM #ANOTES WHERE ID=@Cnt) AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate 
	--FROM #ANOTES WHERE ID=@Cnt))) EName FOR XML PATH('')),1,1,''))+'--->' WHERE MeasurementId=(SELECT MeasurementId FROM #ANOTES WHERE ID=@Cnt) 
	--AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #ANOTES WHERE ID=@Cnt))
	--SET @LCount=@LCount-1
	--SET @Cnt=@Cnt+1
	--END
	
	--DROP TABLE #ANOTES

	--END

	--ELSE

	--BEGIN

	

	--IF((SELECT COUNT(*) FROM [dbo].[StdtSessEvent] WHERE MeasurementId=(SELECT BehavId FROM #EVNT WHERE ID=@BehaviorOld) AND StudentId=@SID AND 
	--SchoolId=@School AND EvntTs BETWEEN @SDate AND @EDate)=0)
	--BEGIN	

	

	--INSERT INTO #TEMP (MeasurementId
	--,Frequency
	--,AggredatedDate
	--,IOAFrequency
	--,IOADuration
	--,Behaviour
	--,StudentFname
	--,ArrowNote
	--,StudentLname
	--,EventType
	--,EventName
	--,EvntTs
	--,EndTime
	--,Comment)
	--SELECT (SELECT BehavId FROM #EVNT WHERE ID=@BehaviorOld)	
	--,CASE WHEN StdtSessEventType ='Major' OR StdtSessEventType ='Minor' THEN 100 ELSE 0 END AS Frequency
	--,TimeStampForReport AS AggredatedDate	
	--,NULL IOAFrequency
	--,NULL IOADuration
	--,(SELECT [Behaviour] FROM [dbo].[BehaviourDetails] WHERE [MeasurementId]=(SELECT BehavId FROM #EVNT WHERE ID=@BehaviorOld)) [Behaviour]
	--,Student.StudentFname
	--,EventName AS ArrowNote
	--,Student.StudentLname
	--,StdtSessEventType AS EventType
	--,EventName
	--,TimeStampForReport
	--,EndTime
	--,Comment
	-- FROM [dbo].[StdtSessEvent]
	--INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	--LEFT JOIN [dbo].[BehaviourDetails] ON [BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] 
	--IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate

	--END

	--ELSE

	--BEGIN

	
	--INSERT INTO #TEMP (MeasurementId,
	--Frequency
	--,AggredatedDate
	--,IOAFrequency
	--,IOADuration
	--,Behaviour
	--,StudentFname
	--,ArrowNote
	--,StudentLname
	--,EventType
	--,EventName
	--,EvntTs
	--,EndTime
	--,Comment)
	--SELECT DISTINCT * FROM (SELECT LP.[MeasurementId]
	--,CASE WHEN ZEROLP.EventType ='Major' OR ZEROLP.EventType ='Minor' THEN 100 ELSE 0 END AS Frequency
	--,ZEROLP.TimeStampForReport AggredatedDate
	--,NULL IOAFrequency
	--,NULL IOADuration
	--,LP.[Behaviour]
	--,ZEROLP.StudentFname
	--,ZEROLP.ArrowNote
	--,ZEROLP.StudentLname
	--,ZEROLP.EventType
	--,ZEROLP.EventName
	--,ZEROLP.TimeStampForReport
	--,ZEROLP.EndTime
	--,ZEROLP.Comment	 
	--FROM (SELECT [StdtSessEvent].[MeasurementId]
	--,CASE WHEN StdtSessEventType ='Major' OR StdtSessEventType ='Minor' THEN 100 ELSE 0 END AS Frequency	
	--,[StdtSessEvent].EvntTs AS AggredatedDate	
	--,NULL IOAFrequency
	--,NULL IOADuration
	--,[dbo].[BehaviourDetails].[Behaviour]
	--,Student.StudentFname
	--,EventName AS ArrowNote
	--,Student.StudentLname
	--,StdtSessEventType AS EventType
	--,EventName
	--,TimeStampForReport
	--,EndTime
	--,Comment
	--FROM [dbo].[StdtSessEvent]	
	--INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	--LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] 
	--IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate 
	--AND @EDate) ZEROLP,

	--(SELECT [StdtSessEvent].[MeasurementId]
	--,CASE WHEN StdtSessEventType ='Major' OR StdtSessEventType ='Minor' THEN 100 ELSE 0 END AS Frequency
	--,[StdtSessEvent].EvntTs AS AggredatedDate	
	--,NULL IOAFrequency
	--,NULL IOADuration
	--,[dbo].[BehaviourDetails].[Behaviour]
	--,Student.StudentFname
	--,EventName AS ArrowNote
	--,Student.StudentLname
	--,StdtSessEventType AS EventType
	--,EventName
	--,TimeStampForReport
	--,EndTime
	--,Comment
	-- FROM [dbo].[StdtSessEvent]
	--INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	--LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] 
	--IN (SELECT BehavId FROM #EVNT WHERE ID=@BehaviorOld) AND EventType='EV' AND EvntTs BETWEEN  
	--@SDate AND @EDate) LP

	--UNION ALL 

	--SELECT [StdtSessEvent].[MeasurementId]
	--,CASE WHEN StdtSessEventType ='Major' OR StdtSessEventType ='Minor' THEN 100 ELSE 0 END AS Frequency
	--,[StdtSessEvent].EvntTs AS AggredatedDate	
	--,NULL IOAFrequency
	--,NULL IOADuration
	--,[dbo].[BehaviourDetails].[Behaviour]
	--,Student.StudentFname
	--,EventName AS ArrowNote
	--,Student.StudentLname
	--,StdtSessEventType AS EventType
	--,EventName
	--,TimeStampForReport
	--,EndTime
	--,Comment FROM [dbo].[StdtSessEvent]
	--INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	--LEFT JOIN [dbo].[BehaviourDetails] ON [dbo].[BehaviourDetails].[MeasurementId]=[StdtSessEvent].[MeasurementId] WHERE Student.StudentId=@SID AND [StdtSessEvent].[MeasurementId] 
	--IN (SELECT BehavId FROM #EVNT WHERE ID=@BehaviorOld) AND EventType='EV' AND EvntTs BETWEEN   
	--@SDate AND @EDate) EVNT 

	--END


	--END

	--SET @BehaviorOld=@BehaviorOld-1
	--END

	--DROP TABLE #EVNT	



	---------------------------------/// EVENT FIRST OLD //// -------------------------------

--	IF((SELECT COUNT(*) FROM #TEMP)>0)

--	BEGIN

--	-- INSERT EVENTS TO #TEMP TABLE
--	INSERT INTO #TEMP (MeasurementId
--	,AggredatedDate
--	,IOAFrequency
--	,IOADuration
--	,Behaviour
--	,StudentFname
--	,ArrowNote
--	,StudentLname
--	,EventType
--	,EventName
--	,EvntTs
--	,EndTime
--	,Comment)
--	SELECT DISTINCT StdtAggScores.MeasurementId
--	,StdtAggScores.AggredatedDate
--	,StdtAggScores.IOAFrequency
--	,StdtAggScores.IOADuration
--	,BehaviourDetails.Behaviour
--	,Student.StudentFname
--	,StdtAggScores.EventName AS ArrowNote
--	,Student.StudentLname
--	,Events.StdtSessEventType AS EventType
--	,Events.EventName
--	,Events.EvntTs
--	,Events.EndTime
--	,Events.Comment
--	FROM StdtAggScores 
--	INNER JOIN
--	BehaviourDetails 
--	ON StdtAggScores.MeasurementId = BehaviourDetails.MeasurementId 
--	INNER JOIN
--	Student 
--	ON StdtAggScores.StudentId = Student.StudentId 
--	LEFT OUTER JOIN
--	StdtSessEvent AS Events 
--	ON Events.StdtSessEventId = StdtAggScores.StdtSessEventId
--	WHERE StdtAggScores.AggredatedDate 
--	BETWEEN @SDate AND @EDate
--	AND StdtAggScores.StudentId=@SID 
--	AND StdtAggScores.SchoolId=@School
--	AND StdtAggScores.MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,',')) 
--	AND StdtAggScores.StdtSessEventId IS NOT NULL
--	AND Events.StdtSessEventType<>'Arrow notes'


--	-- INSERT ARROW NOTES TO #TEMP TABLE
--	CREATE TABLE #ANOTES(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),MeasurementId int,AggredatedDate datetime,EventName varchar(500));
--	INSERT INTO #ANOTES (MeasurementId
--	,AggredatedDate
--	,EventName)
--	SELECT DISTINCT StdtAggScores.MeasurementId
--	,StdtAggScores.AggredatedDate
--	,Events.EventName
--	FROM StdtAggScores 
--	INNER JOIN	
--	StdtSessEvent AS Events 
--	ON Events.StdtSessEventId = StdtAggScores.StdtSessEventId
--	WHERE StdtAggScores.AggredatedDate 
--	BETWEEN @SDate AND @EDate
--	AND StdtAggScores.StudentId=@SID 
--	AND StdtAggScores.SchoolId=@School
--	AND StdtAggScores.MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,',')) 
--	AND StdtAggScores.StdtSessEventId IS NOT NULL
--	AND Events.StdtSessEventType='Arrow notes'

--	SET @Cnt=1
--	SET @LCount=(SELECT COUNT(*) FROM #ANOTES)

--	WHILE(@LCount>0)
--	BEGIN
--	UPDATE #TEMP SET ArrowNote=(SELECT STUFF((SELECT ','+CONVERT(VARCHAR, EventName)  FROM (SELECT EventName FROM #ANOTES 
--	WHERE MeasurementId=(SELECT MeasurementId FROM #ANOTES WHERE ID=@Cnt) AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate 
--	FROM #ANOTES WHERE ID=@Cnt))) EName FOR XML PATH('')),1,1,''))+'--->' WHERE MeasurementId=(SELECT MeasurementId FROM #ANOTES WHERE ID=@Cnt) 
--	AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #ANOTES WHERE ID=@Cnt))
--	SET @LCount=@LCount-1
--	SET @Cnt=@Cnt+1
--	END
	
--	DROP TABLE #ANOTES

	
--	END

--	ELSE

--	BEGIN

--		INSERT INTO #TEMP (MeasurementId
--	,AggredatedDate
--	,IOAFrequency
--	,IOADuration
--	,Behaviour
--	,StudentFname
--	,ArrowNote
--	,StudentLname
--	,EventType
--	,EventName
--	,EvntTs
--	,EndTime
--	,Comment
--	,Score)
--	SELECT MeasurementId
--	,AggredatedDate
--	,IOAFrequency
--	,IOADuration
--	,Behaviour
--	,StudentFname
--	,ArrowNote
--	,StudentLname
--	,EventType
--	,EventName
--	,TimeStampForReport
--	,EndTime
--	,Comment
--	,CASE WHEN EventType='Arrow notes' THEN 0 ELSE 100 END Score
--	FROM (SELECT Events.MeasurementId	
--	,Events.TimeStampForReport AS AggredatedDate	
--	,'' AS IOAFrequency
--	,'' AS IOADuration
--	,BehaviourDetails.Behaviour
--	,Student.StudentFname
--	,Events.EventName AS ArrowNote
--	,Student.StudentLname
--	,Events.StdtSessEventType AS EventType
--	,Events.EventName
--	,Events.TimeStampForReport
--	,Events.EndTime
--	,Events.Comment
--	FROM StdtSessEvent AS Events 	
--	LEFT OUTER JOIN	
--	BehaviourDetails 
--	ON Events.MeasurementId = BehaviourDetails.MeasurementId 
--	INNER JOIN
--	Student 
--	ON Events.StudentId = Student.StudentId 	
--	WHERE Events.EvntTs 
--	BETWEEN @SDate AND @EDate
--	AND Events.StudentId=@SID 
--	AND Events.SchoolId=@School
--	AND Events.MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,',')) ) SPECLP

--	UNION

--SELECT * FROM 
--(SELECT LP.MeasurementId
--	,AggredatedDate
--	,IOAFrequency
--	,IOADuration
--	,LP.Behaviour
--	,StudentFname
--	,ArrowNote
--	,StudentLname
--	,EventType
--	,EventName
--	,TimeStampForReport
--	,EndTime
--	,Comment
--	,CASE WHEN EventType='Arrow notes' THEN 0 ELSE 100 END Score
-- FROM (SELECT  DISTINCT BDS.MeasurementId,BDS.StudentId,BDS.Behaviour FROM BehaviourDetails BDS
--	  WHERE BDS.StudentId=@SID AND BDS.ActiveInd='A' AND BDS.SchoolId=@School 
--	   AND BDS.MeasurementId IN (SELECT * FROM Split(@BehaviorIDs,','))) LP
--	JOIN
--	 ( SELECT Events.MeasurementId	 
--	 ,Events.StudentId
--	,Events.EvntTs AS AggredatedDate
--	,'' AS IOAFrequency
--	,'' AS IOADuration	
--	,BehaviourDetails.Behaviour
--	,Student.StudentFname
--	,Events.EventName AS ArrowNote
--	,Student.StudentLname
--	,Events.StdtSessEventType AS EventType
--	,Events.EventName
--	,Events.TimeStampForReport
--	,Events.EndTime
--	,Events.Comment
--	FROM StdtSessEvent AS Events 	
--	LEFT OUTER JOIN	
--	BehaviourDetails 
--	ON Events.MeasurementId = BehaviourDetails.MeasurementId 
--	INNER JOIN
--	Student 
--	ON Events.StudentId = Student.StudentId 	
--	WHERE Events.EvntTs 
--	BETWEEN @SDate AND @EDate
--	AND Events.StudentId=@SID
--	AND Events.SchoolId=@School
--	AND Events.MeasurementId =0 ) ZEROLP
--	ON LP.StudentId=ZEROLP.StudentId) ALLLP

--	END
	
	
	
	SELECT *,(SELECT Duration FROM BehaviourDetails WHERE MeasurementId=#TEMP.MeasurementId)DuratnStat,
	(SELECT BehavDefinition FROM BehaviourDetails BDS WHERE BDS.MeasurementId=#TEMP.MeasurementId) Deftn,
	'Stgy: '+(SELECT BehavStrategy FROM BehaviourDetails BDS WHERE BDS.MeasurementId=#TEMP.MeasurementId) Stratgy,
	@SchoolId AS SchoolId FROM #TEMP

END









GO
