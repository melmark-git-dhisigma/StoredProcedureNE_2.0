USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[BiweeklyReport_Trendline_Set_Backup]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BiweeklyReport_Trendline_Set_Backup]
@StartDate datetime,
@ENDDate datetime,
@Studentid int,
@SchoolId int,
@LessonPlanid int,
@Trendtype varchar(50),
@Event varchar(50),
@SetIds varchar(MAX),
@DsTempSetColCalcIds varchar(MAX),
@IsMaintanance VARCHAR(1)

AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @ARROWCNT INT,
	@ARROWID INT,
	@CNTLP INT,
	@SDate datetime,
	@EDate datetime,
	@SID int,
	@LPID int,
	@School int,
	@LCount int,
	@CalcType varchar(50),
	@TempLPId int,
	@LoopLessonPlan int,
	@ClassType varchar(50),
	@Cnt int,
	@Score int,
	@Scoreid int,
	@Nullcnt int,
	@Breaktrendid int,
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
	@TMPLessonPlan int,
	@TMPCalcType varchar(50),
	@TMPClassType varchar(50),
	@TMPDate datetime,
	@TMPStartDate datetime,
	@TMPEndDate datetime,
	@TMPCount int,
	@TMPLoopCount int,
	@TMPSesscnt int,
	@Calc varchar(50),
	@LessonPlanOld int,
	@ClassOld varchar(50),
	@OldTMPDate datetime,
	@NewCalcType varchar(50),
	@RPTLabelOld varchar(500),
	@RPTLabel varchar(500),
	@CalcRptLabelLPOld varchar(500),
	@CalcRptLabelLP varchar(500),
	@RptLbl varchar(500),
	@colname varchar(500),
	@colnameold varchar(500),
	@SetId int,
	@SetIdOld int




	SET @SDate=@StartDate
	SET @EDate=@ENDDate
	SET @SID=@Studentid
	SET @LPID=@LessonPlanid
	SET @School=@SchoolId
	SET @LCount=0
	SET @CalcType=''
	SET @TempLPId=0
	SET @LoopLessonPlan=0
	SET @ClassType=''
	SET @Cnt=1
	SET @Scoreid=0
	SET @Nullcnt=0
	SET @Breaktrendid=1
	SET @TType=@Trendtype
	SET @NumOfTrend=0
	SET @TrendsectionNo=0
	SET @TMPLessonPlan =0
	SET @TMPCalcType=''
	SET @TMPClassType =''
	SET @TMPStartDate= @StartDate
	SET @TMPEndDate =@ENDDate
	SET @TMPCount=0
	SET @TMPLoopCount=1
	SET @TMPSesscnt=1
	SET @Calc=''
	SET @LessonPlanOld=0
	SET @ClassOld=''
	SET @NewCalcType=''
	


	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL  
	DROP TABLE #TEMP


	CREATE TABLE #AGGSCORE
	(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	LessonPlanid int,
	CalcType varchar(50),
	Score float,
	AggDate datetime,
	ClassType varchar(50),
	IOAPerc varchar(50),
	ArrowNote nvarchar(500),
	--SetId int,
	CalcRptLabelLP varchar(500),
	RptLabel varchar(500),
	CNT INT);

	CREATE TABLE #AGGSCORE1
	(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	LessonPlanid int,
	CalcType varchar(50),
	Score float,
	AggDate datetime,
	ClassType varchar(50),
	IOAPerc varchar(50),
	ArrowNote nvarchar(500),
	--SetId int,
	CalcRptLabelLP varchar(500),
	RptLabel varchar(500),
	CNT INT);

	--SELECT ALL LESSON DETAILS BETWEEN STARTDATE AND ENDDATE FROM THE TABLE 'StdtAggScoreSet' AND INSERT IT TO #AGGSCORE TABLE
	IF(@IsMaintanance=0)
	BEGIN
	INSERT INTO #AGGSCORE1
	SELECT DISTINCT LessonPlanId
	,StdtAggScoreSet.CalcType
	,Score
	,AggregatedDate
	,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 AND LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay=1 THEN 
	'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' END END END FROM [dbo].[StdtLessonPlan] WHERE LessonPlanId=
	StdtAggScoreSet.LessonPlanId AND StudentId=@SID AND SchoolId=@School ORDER BY StdtLessonPlanId DESC) AS ClassType
	,IOAPerc
	,'' EventName
	--,StdtAggScoreSet.SetId
	,StdtAggScoreSet.ColRptLabelLP
	,CASE WHEN (SELECT CalcRptLabel FROM DsTempSetColCalc CALC WHERE CALC.DSTempSetColCalcId=StdtAggScoreSet.DSTempSetColCalcId )='' 
	THEN StdtAggScoreSet.CalcType ELSE (SELECT CalcRptLabel FROM DsTempSetColCalc CALC WHERE 
	CALC.DSTempSetColCalcId=StdtAggScoreSet.DSTempSetColCalcId ) END CalcRptLabel 
	,0 AS CNT
	FROM StdtAggScoreSet
	INNER JOIN DsTempSetColCalc DTSCC 
	ON StdtAggScoreSet.DsTempSetColCalcId = DTSCC.DSTempSetColCalcId
	WHERE CONVERT(DATE,AggregatedDate) BETWEEN @SDate AND @EDate
	AND StudentId=@SID 
	AND StdtAggScoreSet.SchoolId=@School 
	AND LessonPlanId=@LPID
	AND (DTSCC.IncludeInGraph <>0)
	AND (SetId IN  (SELECT * FROM Split(@SetIds,',')) 
    AND StdtAggScoreSet.DsTempSetColCalcId IN (SELECT * FROM Split(@DsTempSetColCalcIds,',')))
	AND StdtAggScoreSet.IsMaintanance=CONVERT(BIT, @IsMaintanance)
	AND Score IS NOT NULL
	ORDER BY LessonPlanId,StdtAggScoreSet.ColRptLabelLP
	,StdtAggScoreSet.CalcType
	,AggregatedDate --LessonPlanId,CalcType,AggredatedDate,	
	END
	ELSE
	BEGIN
	INSERT INTO #AGGSCORE1
	SELECT DISTINCT StdtAggScoreSet.LessonPlanId
	,CalcType
	,Score
	,AggregatedDate
	,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 AND LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay=1 THEN 
	'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' END END END FROM [dbo].[StdtLessonPlan] WHERE LessonPlanId=
	StdtAggScoreSet.LessonPlanId AND StudentId=@SID AND SchoolId=@School ORDER BY StdtLessonPlanId DESC) AS ClassType
	,StdtAggScoreSet.IOAPerc
	,'' EventName
	,ColRptLabelLP
	,CASE WHEN (SELECT CalcRptLabel FROM DsTempSetColCalc CALC WHERE CALC.DSTempSetColCalcId=StdtAggScoreSet.DSTempSetColCalcId )='' 
	THEN StdtAggScoreSet.CalcType ELSE (SELECT CalcRptLabel FROM DsTempSetColCalc CALC WHERE 
	CALC.DSTempSetColCalcId=StdtAggScoreSet.DSTempSetColCalcId ) END CalcRptLabel
	,0 AS CNT FROM StdtSessionHdr 
	INNER JOIN	StdtAggScoreSet 
	ON StdtSessionHdr.StudentId=StdtAggScoreSet.StudentId 
	AND StdtSessionHdr.LessonPlanId=StdtAggScoreSet.LessonPlanId
	 WHERE StdtSessionHdr.StudentId=@SID 
	 AND StdtSessionHdr.LessonPlanId=@LPID 
	 AND CONVERT(DATE,StdtSessionHdr.StartTs)=StdtAggScoreSet.AggregatedDate
	  AND IsMaintanace=1 AND IsMaintanance=1
	  AND (SetId IN  (SELECT * FROM Split(@SetIds,',')) 
    AND StdtAggScoreSet.DsTempSetColCalcId IN (SELECT * FROM Split(@DsTempSetColCalcIds,',')))
	AND Score IS NOT NULL
	AND CONVERT(DATE,AggregatedDate) BETWEEN @SDate AND @EDate
	ORDER BY LessonPlanId,StdtAggScoreSet.ColRptLabelLP
	,StdtAggScoreSet.CalcType
	,AggregatedDate
	END
	
	
	UPDATE #AGGSCORE1 SET #AGGSCORE1.Score = SCR.Score FROM
    (SELECT LessonPlanid,CalcType,AVG(Score) Score,AggDate,ClassType,IOAPerc,ArrowNote,CalcRptLabelLP,RptLabel,CNT,cntlp FROM 
	(SELECT *,(SELECT count(*) FROM #AGGSCORE1 agg WHERE agg.CalcType=#AGGSCORE1.CalcType AND agg.AggDate=#AGGSCORE1.AggDate AND 
	agg.CalcRptLabelLP=#AGGSCORE1.CalcRptLabelLP) cntlp FROM #AGGSCORE1) aggscr WHERE cntlp>1 GROUP BY 
	LessonPlanid,CalcType,AggDate,ClassType,IOAPerc,ArrowNote,CalcRptLabelLP,RptLabel,CNT,cntlp) SCR WHERE
    SCR.CalcType=#AGGSCORE1.CalcType AND SCR.AggDate=#AGGSCORE1.AggDate AND SCR.CalcRptLabelLP=#AGGSCORE1.CalcRptLabelLP			
	
	INSERT INTO #AGGSCORE
	SELECT DISTINCT LessonPlanid,CalcType,Score,AggDate,ClassType,IOAPerc,ArrowNote,CalcRptLabelLP,RptLabel,CNT FROM #AGGSCORE1 
	ORDER BY LessonPlanId,CalcRptLabelLP,CalcType,AggDate

	DROP TABLE #AGGSCORE1	

	DELETE FROM #AGGSCORE 
	WHERE LessonPlanid IN (SELECT Data FROM (SELECT *,(SELECT COUNT(*) FROM #AGGSCORE WHERE LessonPlanId=Data) DateCnt ,(SELECT COUNT(*) FROM #AGGSCORE WHERE LessonPlanId=Data AND 
	Score IS NULL) ScoreCnt FROM Split(CONVERT(VARCHAR(50),@LPID),',')) Total WHERE DateCnt=ScoreCnt)	

	;WITH T
     AS (SELECT CNT, Row_number() OVER (ORDER BY ID ) AS RN FROM   #AGGSCORE)
	UPDATE T
	SET CNT = RN 
	
	UPDATE #AGGSCORE SET CalcRptLabelLP=(SELECT TOP 1 CalcRptLabelLP FROM #AGGSCORE AGG WHERE AGG.LessonPlanid=#AGGSCORE.LessonPlanid AND 
	AGG.CalcType=#AGGSCORE.CalcType AND AGG.ClassType=#AGGSCORE.ClassType AND AGG.RptLabel=#AGGSCORE.RptLabel) WHERE CalcRptLabelLP IS NULL

	CREATE TABLE #TEMP
	(Scoreid int PRIMARY KEY NOT NULL IDENTITY(1,1),
	LessonPlanId int,
	CalcType varchar(50),
	Score float,
	AggredatedDate datetime,
	ClassType varchar(50),
	BreakTrendNo int,
	XValue int,
	Trend float,
	IOAPerc varchar(50),
	LessonPlanName varchar(500),
	StudentFname varchar(200),
	ArrowNote nvarchar(500),
	StudentLname varchar(200),
	EventType varchar(50),
	EventName nvarchar(500),
	EvntTs datetime,
	EndTime datetime,
	Comment varchar(500),
	RptLabel varchar(500),
	--SetId int,
	CalcRptLabelLP varchar(500));

	SET @TMPCount = (SELECT COUNT(*) FROM #AGGSCORE)
	WHILE(@TMPCount>0)
	BEGIN
	SET @Calc=(SELECT CalcType FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	SET @LessonPlanOld=(SELECT LessonPlanid FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	SET @ClassOld=(SELECT ClassType FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	SET @OldTMPDate=(SELECT AggDate FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	SET @TMPCalcType=(SELECT CalcType FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	SET @TMPClassType=(SELECT ClassType FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	SET @TMPLessonPlan=(SELECT LessonPlanid FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	SET @TMPDate=(SELECT AggDate FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	SET @RPTLabelOld =(SELECT RptLabel FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	SET @RPTLabel=(SELECT RptLabel FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	SET @CalcRptLabelLPOld =(SELECT CalcRptLabelLP FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	SET @CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	--SET @SetIdOld=(SELECT SetId FROM #AGGSCORE WHERE CNT=(@TMPLoopCount-1))
	--SET @SetId=(SELECT SetId FROM #AGGSCORE WHERE CNT=@TMPLoopCount)
	
	IF(@TMPDate<@OldTMPDate)
	BEGIN
	WHILE(@OldTMPDate<@EDate)
	BEGIN
	SET @OldTMPDate=DATEADD(DAY,1,@OldTMPDate)	
	INSERT INTO #TEMP (LessonPlanId,CalcType,AggredatedDate,ClassType,XValue,RptLabel,
	--SetId,
	CalcRptLabelLP) VALUES 
	( @LessonPlanOld,@Calc,@OldTMPDate,@ClassOld,@TMPSesscnt,@RPTLabelOld,
	--@SetIdOld,
	@CalcRptLabelLPOld)		
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	END	
	
	IF(@CalcRptLabelLPOld<>@CalcRptLabelLP) --(@Calc<>@TMPCalcType) AND
	BEGIN		
	SET @TMPSesscnt=1
	SET @TMPStartDate=@SDate		
	END
	ELSE IF(@TMPLessonPlan<>@LessonPlanOld)
	BEGIN
	SET @TMPSesscnt=1
	SET @TMPStartDate=@SDate
	END

	


	SET @Calc=@TMPCalcType
	IF(@TMPDate=@TMPStartDate)
	BEGIN
	INSERT INTO #TEMP (LessonPlanId,CalcType,AggredatedDate,ClassType,XValue,Score,IOAPerc,ArrowNote,RptLabel,
	--SetId,
	CalcRptLabelLP) 
	SELECT LessonPlanid,CalcType,AggDate,ClassType,@TMPSesscnt,Score,IOAPerc,ArrowNote,RptLabel,
	--SetId,
	CalcRptLabelLP FROM #AGGSCORE WHERE CNT=@TMPLoopCount
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	ELSE
	BEGIN
	WHILE(@TMPDate<>@TMPStartDate)
	BEGIN
	IF(@TMPDate>@TMPStartDate)
	BEGIN	
	INSERT INTO #TEMP (LessonPlanId,CalcType,AggredatedDate,ClassType,XValue,RptLabel,
	--SetId,
	CalcRptLabelLP) VALUES 
	(@TMPLessonPlan,@TMPCalcType,@TMPStartDate,@TMPClassType,@TMPSesscnt,@RptLabel,
	--@SetId,
	@CalcRptLabelLP)	
	SET @TMPStartDate=DATEADD(DAY,1,@TMPStartDate)
	END
	ELSE
	BEGIN	
	INSERT INTO #TEMP (LessonPlanId,CalcType,AggredatedDate,ClassType,XValue,RptLabel,
	--SetId,
	CalcRptLabelLP) VALUES 
	(@TMPLessonPlan,@TMPCalcType,@TMPDate,@TMPClassType,@TMPSesscnt,@RptLabel,
	--@SetId,
	@CalcRptLabelLP)	
	SET @TMPDate=DATEADD(DAY,1,@TMPDate)
	END	
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	IF(@TMPDate=@TMPStartDate)
	BEGIN	
	INSERT INTO #TEMP (LessonPlanId,CalcType,AggredatedDate,ClassType,XValue,Score,IOAPerc,ArrowNote,RptLabel,
	--SetId,
	CalcRptLabelLP) 
	SELECT LessonPlanid,CalcType,AggDate,ClassType,@TMPSesscnt,Score,IOAPerc,ArrowNote,RptLabel,
	--SetId,
	CalcRptLabelLP FROM #AGGSCORE WHERE CNT=@TMPLoopCount
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
	INSERT INTO #TEMP (LessonPlanId,CalcType,AggredatedDate,ClassType,XValue,RptLabel,
	--SetId,
	CalcRptLabelLP) VALUES 
	( @TMPLessonPlan,@TMPCalcType,@TMPDate,@TMPClassType,@TMPSesscnt,@RptLabel,
	--@SetId,
	@CalcRptLabelLP)	
	SET @TMPSesscnt=@TMPSesscnt+1
	END
	END

	
	END		
	
	CREATE TABLE #TMP(ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),LessonPlanId INT,AggredatedDate DATE,Type VARCHAR(10))

	INSERT INTO #TMP (LessonPlanId
	,AggredatedDate
	,Type)
	SELECT 0 LessonId
	,CONVERT(DATE,EvntTs) AggredatedDate 
	,StdtSessEventType
	FROM [dbo].[StdtSessEvent]
	 WHERE StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes'  

	INSERT INTO #TMP (LessonPlanId
	,AggredatedDate
	,Type)
	SELECT 
	[StdtSessEvent].LessonPlanId
	,CONVERT(DATE,EvntTs) AggredatedDate
	,StdtSessEventType
	FROM [dbo].[StdtSessEvent]
	WHERE StudentId=@SID AND [StdtSessEvent].[MeasurementId] IN (SELECT * FROM Split(@LPID,',')) AND EventType='EV' 
	AND EvntTs BETWEEN @SDate AND @EDate AND StdtSessEventType<>'Arrow notes'

	CREATE TABLE #DURATN(ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),Score FLOAT,LessonPlanId INT,CalcRptLabelLP VARCHAR(500))

	INSERT INTO #DURATN
	SELECT MAX(ISNULL(Score,-1)),LessonPlanId,CalcRptLabelLP FROM #TEMP WHERE CalcType IN ('Total Duration','Avg Duration') GROUP BY LessonPlanId,CalcRptLabelLP
	
	SET @TMPCount=(SELECT COUNT(*) FROM #DURATN)
		SET @TMPLoopCount=1
		WHILE(@TMPCount>0)
		BEGIN
		IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)<>-1)
		BEGIN
		IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)<60)
		BEGIN
		UPDATE #TEMP SET RptLabel=RptLabel+' (In Seconds)' WHERE LessonPlanId=(SELECT LessonPlanId FROM #DURATN WHERE ID=@TMPLoopCount) 
		AND CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
		END
		ELSE IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)<3600)
		BEGIN
		UPDATE #TEMP SET RptLabel=RptLabel+' (In Minutes)' WHERE LessonPlanId=(SELECT LessonPlanId FROM #DURATN WHERE ID=@TMPLoopCount) 
		AND CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
		UPDATE #TEMP SET Score=Score/60 WHERE LessonPlanId=(SELECT LessonPlanId FROM #DURATN WHERE ID=@TMPLoopCount) 
		AND CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
		END
		ELSE IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)>=3600)
		BEGIN
		UPDATE #TEMP SET RptLabel=RptLabel+' (In Hours)' WHERE LessonPlanId=(SELECT LessonPlanId FROM #DURATN WHERE ID=@TMPLoopCount) 
		AND CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
		UPDATE #TEMP SET Score=Score/3600 WHERE LessonPlanId=(SELECT LessonPlanId FROM #DURATN WHERE ID=@TMPLoopCount) 
		AND CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
		END
		END
		SET @TMPLoopCount=@TMPLoopCount+1
		SET @TMPCount=@TMPCount-1
		END
	
	DROP TABLE #DURATN
	
	--TO SEPERATE EACH TRENDLINE FROM THE TABLE #TEMP, ADD EACH PAGE SESSION TO #TEMPTYPE 
	CREATE TABLE #TEMPTYPE(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),LPID int,Type VARCHAR(50),ClassType varchar(50),RptLabel varchar(500),CalcRptLabelLP varchar(500));
	INSERT INTO #TEMPTYPE SELECT DISTINCT LessonPlanId,CalcType,ClassType,RptLabel,CalcRptLabelLP FROM #TEMP ORDER BY LessonPlanId,CalcType
	
	--FOR SEPERATING EACH TERAND LINE SECTION AND NUMBERED IT AS 1,2,3 ETC IN 'BreakTrendNo' COLUMN OF #TEMP TABLE
	SET @LCount=(SELECT COUNT(*) FROM #TEMPTYPE)
	WHILE(@LCount>0)
	BEGIN

	SET @CalcType=(SELECT Type FROM #TEMPTYPE WHERE ID=@Cnt)  
	SET @LoopLessonPlan=(SELECT LPID FROM #TEMPTYPE WHERE ID=@Cnt)
	SET @ClassType=(SELECT ClassType FROM #TEMPTYPE WHERE ID=@Cnt)
	SET @CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #TEMPTYPE WHERE ID=@Cnt)
	SET @RptLbl=(SELECT RptLabel FROM #TEMPTYPE WHERE ID=@Cnt)
	SET @Scoreid=(SELECT TOP 1 Scoreid FROM #TEMP WHERE CalcType=@CalcType AND LessonPlanId=@LoopLessonPlan AND ClassType=@ClassType AND CalcRptLabelLP=@CalcRptLabelLP)

	WHILE((SELECT COUNT(*) FROM #TEMP WHERE LessonPlanId=@LoopLessonPlan AND ClassType=@ClassType AND Calctype=@CalcType AND Scoreid=@Scoreid AND CalcRptLabelLP=@CalcRptLabelLP)>0)
	BEGIN
	SET @Score=(SELECT ISNULL(CONVERT(int,Score),-1) FROM #TEMP WHERE Scoreid=@Scoreid)


	IF(@Score=-1)
	BEGIN
	SET @Nullcnt=@Nullcnt+1	
	END
	ELSE IF(@Nullcnt>5 AND @Score<>-1)
	BEGIN	
	SET @Breaktrendid=(SELECT ISNULL(MAX(BreakTrendNo),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendNo=@Breaktrendid WHERE Scoreid=@Scoreid
	SET @Nullcnt=0		
	END
	ELSE IF(@Score<>-1)
	BEGIN		
	UPDATE #TEMP SET BreakTrendNo=@Breaktrendid WHERE Scoreid=@Scoreid
	SET @Nullcnt=0	
	END	


	-------------------------------------------------------------------------------------


	IF CHARINDEX('Major',@Event) > 0
	BEGIN
 
	IF((SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	AND (LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@Scoreid) OR LessonPlanId=0) AND Type ='Major')>0)
	BEGIN
	IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@Scoreid) OR LessonPlanId=0) AND Type ='Major')>0)
	BEGIN
	UPDATE #TEMP SET BreakTrendNo = NULL  WHERE Scoreid=@Scoreid
	SET @Nullcnt=0
	END
	END	
	ELSE IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@Scoreid) OR LessonPlanId=0) AND Type ='Major')>0)
	BEGIN
	SET @Breaktrendid=(SELECT ISNULL(MAX(BreakTrendNo),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendNo=@Breaktrendid WHERE Scoreid=@Scoreid
	SET @Nullcnt=0	
	END
	END
	IF CHARINDEX('Minor',@Event) > 0
	BEGIN	
	IF((SELECT COUNT(*) FROM #TMP WHERE CONVERT(DATE,AggredatedDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #TEMP WHERE Scoreid=@Scoreid) 
	AND (LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@Scoreid) OR LessonPlanId=0) AND Type ='Minor')>0)
	BEGIN
	IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@Scoreid) OR LessonPlanId=0) AND Type ='Minor')>0)
	BEGIN
	UPDATE #TEMP SET BreakTrendNo=NULL WHERE Scoreid=@Scoreid
	SET @Nullcnt=0
	END
	END	
	ELSE IF((SELECT COUNT(*) FROM #TMP WHERE  CONVERT(DATE,AggredatedDate)= CONVERT(DATE,(SELECT AggredatedDate FROM #TEMP WHERE Scoreid=(@Scoreid-1))) 
	AND (LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@Scoreid) OR LessonPlanId=0) AND Type ='Minor')>0)
	BEGIN
	SET @Breaktrendid=(SELECT ISNULL(MAX(BreakTrendNo),0) FROM #TEMP)+1
	UPDATE #TEMP SET BreakTrendNo=@Breaktrendid WHERE Scoreid=@Scoreid
	SET @Nullcnt=0	
	END
	END

	
	
	-------------------------------------------------------------------------------------

	
	SET @Scoreid=@Scoreid+1	
	END

	SET @Breaktrendid=@Breaktrendid+1
	SET @Cnt=@Cnt+1
	SET @LCount=@LCount-1
	END

	DROP TABLE #TEMPTYPE



	--SELECT EACH TREND LINE SECTION FROM #TEMP AND CALCULATE TREND POINT VALUES
	SET @Cnt=0
	IF(@TType='Quarter')
	BEGIN
	SET @NumOfTrend=(SELECT COUNT(DISTINCT BreakTrendNo) FROM #TEMP)
	WHILE(@NumOfTrend>0)
	BEGIN
	SET @Cnt=@Cnt+1
	SET @TrendsectionNo=(SELECT COUNT(*) FROM #TEMP WHERE BreakTrendNo=@Cnt)

	IF(@TrendsectionNo>2)
	BEGIN	
	
	CREATE TABLE #TRENDSECTION(Id int PRIMARY KEY NOT NULL IDENTITY(1,1),Trenddate datetime,Score float,Scoreid int);
	INSERT INTO #TRENDSECTION SELECT AggredatedDate,Score,Scoreid FROM #TEMP WHERE Scoreid BETWEEN (SELECT TOP 1 Scoreid FROM #TEMP WHERE 
	BreakTrendNo=@Cnt ORDER BY Scoreid) AND (SELECT TOP 1 Scoreid FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid DESC) AND Score IS NOT NULL
	IF((SELECT COUNT(*) FROM #TRENDSECTION)%2=0)
	SET @DateCnt=((SELECT COUNT(*) FROM #TRENDSECTION)/2)+1
	ELSE
	SET @DateCnt=((SELECT COUNT(*) FROM #TRENDSECTION)/2)+2
	SET @Midrate1= (SELECT ((SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDSECTION) 
	ORDER BY Score) As A ORDER BY Score DESC) +(SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE 
	Id BETWEEN 1 AND (SELECT COUNT(*)/2 FROM #TRENDSECTION) ORDER BY Score DESC) As A ORDER BY Score Asc)) / 2 )
	SET @Midrate2=(SELECT ((SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDSECTION)
	ORDER BY Score) As A ORDER BY Score DESC) +(SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE 
	Id BETWEEN @DateCnt AND (SELECT COUNT(*) FROM #TRENDSECTION) ORDER BY Score DESC) As A ORDER BY Score Asc)) / 2 )

	
	
	IF(@TrendsectionNo>2)
	BEGIN
	--Applying Line Equation Y=mx+b To find Slope 'm' AND Constant 'b'
	SET @Slope=(@Midrate2-@Midrate1)/((SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid DESC)-(SELECT TOP 1 XValue 
	FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid))
	--b=y-mx
	SET @Const=@Midrate1-(@Slope*(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid))

	SET @Ids=(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid) --FIRST x value
	SET @IdOfTrend=(SELECT TOP 1 Scoreid FROM #TRENDSECTION ORDER BY Id)
	WHILE(@IdOfTrend<=(SELECT MAX(Scoreid) FROM #TRENDSECTION))
	BEGIN		
	UPDATE #TEMP SET Trend=((@Slope*@Ids)+@Const) WHERE Scoreid=@IdOfTrend
	SET @IdOfTrend=@IdOfTrend+1
	SET @Ids=@Ids+1
	END	
	DROP TABLE #TRENDSECTION
	END	
	
	END
	SET @NumOfTrend=@NumOfTrend-1
	END
	END
	ELSE IF(@Trendtype='Least')
	BEGIN
	SET @NumOfTrend=(SELECT COUNT(DISTINCT BreakTrendNo) FROM #TEMP)
	WHILE(@NumOfTrend>0)
	BEGIN
	SET @Cnt=@Cnt+1
	SET @TrendsectionNo=(SELECT COUNT(*) FROM #TEMP WHERE BreakTrendNo=@Cnt)

	IF(@TrendsectionNo>2)
	BEGIN	
	
	CREATE TABLE #TREND(Id int PRIMARY KEY NOT NULL IDENTITY(1,1),Trenddate datetime,Score float,Scoreid int,XVal int);
	INSERT INTO #TREND SELECT AggredatedDate,Score,Scoreid,XValue FROM #TEMP WHERE Scoreid BETWEEN (SELECT TOP 1 Scoreid FROM #TEMP WHERE 
	BreakTrendNo=@Cnt ORDER BY Scoreid) AND (SELECT TOP 1 Scoreid FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid DESC)
	
	SET @SUM_XI=(SELECT SUM(XVal) FROM #TREND) --SUM(xi)
	SET @SUM_YI=(SELECT SUM(Score) FROM #TREND) --SUM(yi)
	SET @SUM_XX=(SELECT SUM(XVal*XVal) FROM #TREND) --SUM(xi*xi)
	SET @SUM_XY=(SELECT SUM(XVal*Score) FROM #TREND) --SUM(xi*yi)


	--A*(SELECT COUNT(*) FROM #LEAST)+B*@SUM_XI=@SUM_YI --(a*M+b*SUM(xi)=SUM(yi))
	--A*@SUM_XI+B*@SUM_XX=@SUM_XY --(a*SUM(xi)+b*SUM(xi*xi)=SUM(xi*yi))

	SET @X1=(SELECT COUNT(*) FROM #TREND)
	SET @Y1=@SUM_XI
	SET @Z1=@SUM_YI
	SET @X2=@SUM_XI
	SET @Y2=@SUM_XX
	SET @Z2=@SUM_XY

	--SLOPE CALCULATION (@B)
	IF((@Y1*@X2)>(@Y2*@X1))
	BEGIN
	SET @B=((@Z1*@X2)-(@Z2*@X1))/((@Y1*@X2)-(@Y2*@X1))
	END
	ELSE IF((@Y1*@X2)<(@Y2*@X1))
	BEGIN
	SET @B=((@Z2*@X1)-(@Z1*@X2))/((@Y2*@X1)-(@Y1*@X2))
	END
	
	SET @A=(@SUM_YI-(@B*@SUM_XI))/@X1 --Y INTERCEPT (@A)
	--Y=@Bx+@A


	SET @Ids=(SELECT TOP 1 XValue FROM #TEMP WHERE BreakTrendNo=@Cnt ORDER BY Scoreid) --FIRST x value
	SET @IdOfTrend=(SELECT TOP 1 Scoreid FROM #TREND ORDER BY Id)
	WHILE(@IdOfTrend<=(SELECT MAX(Scoreid) FROM #TREND))
	BEGIN		
	UPDATE #TEMP SET Trend=((@B*@Ids)+@A) WHERE Scoreid=@IdOfTrend
	SET @IdOfTrend=@IdOfTrend+1
	SET @Ids=@Ids+1
	END	

	DROP TABLE #TREND
	END	
	SET @NumOfTrend=@NumOfTrend-1
	END	
	END

	DROP TABLE #AGGSCORE

	SET @TMPCount = (SELECT COUNT(*) FROM #TEMP)
	WHILE(@TMPCount>0)
	BEGIN
	UPDATE #TEMP SET --LessonPlanName=(SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@TMPCount)),
	LessonPlanName= (CASE WHEN (SELECT LessonPlanName FROM DSTempHdr DSH INNER JOIN LessonPlan DLP ON DSH.LessonPlanId = DLP.LessonPlanId WHERE StatusId =
  (SELECT LookupId FROM LookUp WHERE LookupType = 'TemplateStatus' AND LookupName = 'Inactive') AND DSTempHdrId = (SELECT TOP 1 DSTempHdrId FROM DSTempHdr 
  WHERE LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@TMPCount) AND StudentId=@SID ORDER BY DSTempHdrId DESC) AND 
  DSMode = 'INACTIVE' ) IS NULL THEN (SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE 
  Scoreid=@TMPCount)) ELSE (SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=(SELECT LessonPlanId FROM #TEMP WHERE Scoreid=@TMPCount)) + ' (Inactive)' END) 
  	WHERE Scoreid=@TMPCount
	SET @TMPCount=@TMPCount-1
	END

	UPDATE #TEMP SET StudentFname=(SELECT StudentFname FROM Student WHERE StudentId=@SID),StudentLname=(SELECT StudentLname FROM Student WHERE StudentId=@SID)

	
	----///////////////////NEW CHANGE FOR TWO Y AXIS/////////////////////
		ALTER TABLE #TEMP ADD DummyScore float NULL,LeftYaxis varchar(500) NULL, RightYaxis varchar(500) NULL,PromptCount int NULL,NonPercntCount int NULL,PercntCount int NULL,ColName varchar(200) NULL,Color varchar(50),Shape varchar(50);

		
		CREATE TABLE #TMPLP(ID int NOT NULL IDENTITY(1,1),LessonPlanId int,CalcType varchar(50));
		INSERT INTO #TMPLP SELECT DISTINCT LessonPlanId,CalcType FROM #TEMP ORDER BY LessonPlanId,CalcType 
		CREATE TABLE #TMPLPCNT(ID int NOT NULL IDENTITY(1,1),LessonPlanId int,CalcTypeCNT INT);
		INSERT INTO #TMPLPCNT SELECT LessonPlanId,COUNT(1) AS CNT FROM #TMPLP GROUP BY LessonPlanId		
		
		SET @TMPCount=(SELECT COUNT(*) FROM #TMPLPCNT)
		SET @TMPLoopCount=1
		WHILE(@TMPCount>0)
		BEGIN
		IF((SELECT CalcTypeCNT FROM #TMPLPCNT WHERE ID=@TMPLoopCount)>2)
		BEGIN
		IF((SELECT COUNT(*) FROM #TEMP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount))>0)
		BEGIN
	
	UPDATE #TEMP SET DummyScore=Score WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)

	UPDATE #TEMP SET Score = NULL WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)

	UPDATE #TEMP SET LeftYaxis=(SELECT STUFF((SELECT '/ '+ RptLabel FROM (SELECT DISTINCT RptLabel FROM #TEMP TMP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize','Event') AND TMP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) AND (SELECT COUNT(*) FROM #TEMP TP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND TP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount))>0) LP FOR XML PATH('')),1,1,'')) 
	WHERE #TEMP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)

	

	UPDATE #TEMP SET RightYaxis=(SELECT STUFF((SELECT '/ '+ RptLabel FROM (SELECT DISTINCT RptLabel FROM #TEMP TMP WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND TMP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) AND (SELECT COUNT(*) FROM #TEMP TP WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND TP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount))>0) LP FOR XML PATH('')),1,1,''))
	WHERE #TEMP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)

	

	UPDATE #TEMP SET LeftYaxis=(CASE WHEN LeftYaxis IS NULL THEN RightYaxis ELSE LeftYaxis END )  WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)
	UPDATE #TEMP SET RightYaxis=(CASE WHEN LeftYaxis=RightYaxis THEN NULL ELSE RightYaxis END )  WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)
	IF((SELECT COUNT(*) FROM #TEMP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount))>=2)
	BEGIN
	UPDATE #TEMP SET LeftYaxis='Percent'  WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)
	END
		END
		END
		ELSE
		BEGIN
		IF((SELECT CalcTypeCNT FROM #TMPLPCNT WHERE ID=@TMPLoopCount)=2)
		BEGIN		
		
		UPDATE #TEMP SET DummyScore=Score WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) AND 
		CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)ORDER BY ID DESC) 		
		
		UPDATE #TEMP SET Score = NULL WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) AND 
		CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)ORDER BY ID DESC) 
		
		UPDATE #TEMP SET LeftYaxis=(SELECT TOP 1 RptLabel FROM #TEMP WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE 
		LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) ORDER BY ID --DESC
		) AND LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)) 
		WHERE #TEMP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)
		UPDATE #TEMP SET RightYaxis=(SELECT TOP 1 RptLabel FROM #TEMP WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE 
		LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) ORDER BY ID DESC) AND LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)) 
		WHERE #TEMP.LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount)
				
		END

		ELSE
		BEGIN
		UPDATE #TEMP SET LeftYaxis=(SELECT TOP 1 RptLabel FROM #TEMP WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE 
		LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) )) WHERE LessonPlanId=(SELECT LessonPlanId FROM #TMPLPCNT WHERE ID=@TMPLoopCount) 
		
		END
		END
		SET @TMPLoopCount=@TMPLoopCount+1
		SET @TMPCount=@TMPCount-1
		END
		
		DROP TABLE #TMPLPCNT
		DROP TABLE #TMPLP
--/////////////////////////////////////////////////////////////////

	CREATE TABLE #EVNT(ID INT PRIMARY KEY IDENTITY(1,1),LPID INT)
	INSERT INTO #EVNT SELECT * FROM Split(@LPID,',')
	
	SET @Cnt=(SELECT COUNT(*) FROM #EVNT)		

	WHILE(@Cnt>0)
	BEGIN


	CREATE TABLE #LPARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),LESSONID int,CalcType VARCHAR(50),AggredatedDate datetime
	,ClassType VARCHAR(50),IOAPerc VARCHAR(50),LessonPlanName VARCHAR(200),StudentFname VARCHAR(200),ArrowNote NVARCHAR(500),
	StudentLname VARCHAR(200),EventType VARCHAR(50),EventName NVARCHAR(500),TimeStampForReport datetime,EndTime datetime,Comment VARCHAR(200));
	
	INSERT INTO #LPARROW
	
	SELECT 
	(SELECT LPID FROM #EVNT WHERE ID=@Cnt) AS LESSONID
	,'Event' CalcType
	,TimeStampForReport AS AggredatedDate
	,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 AND LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay=1 THEN 
	'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' END END END FROM [dbo].[StdtLessonPlan] WHERE 
	LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt)
	  AND StudentId=@SID AND SchoolId=@School ORDER BY StdtLessonPlanId DESC) AS ClassType
	,NULL IOAPerc
	,(SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt)) LessonPlanName
	,Student.StudentFname
	,EventName AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN LessonPlan ON LessonPlan.LessonPlanId=[StdtSessEvent].LessonPlanId WHERE Student.StudentId=@SID AND [StdtSessEvent].LessonPlanId 
	IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType='Arrow notes'


	
	INSERT INTO #LPARROW
		SELECT 
	[StdtSessEvent].LessonPlanId
	,'Event' CalcType
	,TimeStampForReport AS AggredatedDate
	,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 AND LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay=1 THEN 
	'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' END END END FROM [dbo].[StdtLessonPlan] WHERE 
	LessonPlanId=([StdtSessEvent].LessonPlanId)
	  AND StudentId=@SID AND SchoolId=@School ORDER BY StdtLessonPlanId DESC) AS ClassType
	,NULL IOAPerc
	,(SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=([StdtSessEvent].LessonPlanId)) LessonPlanName
	,Student.StudentFname
	,EventName AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN LessonPlan ON LessonPlan.LessonPlanId=[StdtSessEvent].LessonPlanId WHERE Student.StudentId=@SID AND [StdtSessEvent].LessonPlanId 
	IN (SELECT LPID FROM #EVNT WHERE ID=@Cnt) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType='Arrow notes'
	
	SET @ARROWCNT =(SELECT COUNT(*) FROM #LPARROW)

	SET @ARROWID=1

	WHILE(@ARROWCNT>0)

	BEGIN

	SET @CNTLP=(SELECT COUNT(*) FROM #TEMP WHERE LessonPlanId=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID) )

	IF(@CNTLP>0)

	BEGIN	

	UPDATE #TEMP SET ArrowNote=(SELECT STUFF((SELECT ','+CONVERT(NVARCHAR(MAX), EventName)  FROM (SELECT 
		--DISTINCT CASE WHEN [EventName]='PROMPT MOVEUP' OR [EventName]='PROMPT MOVEDOWN' THEN [EventName]+'('+CONVERT(VARCHAR(10),COUNT(1))+')' ELSE [EventName] END
		 [EventName]  FROM #LPARROW 
	WHERE LESSONID=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID) 
	--GROUP BY [EventName]
	) EName FOR XML PATH('')),1,1,'')) --+'---------->'
	WHERE LessonPlanId=(SELECT LESSONID FROM #LPARROW WHERE ID=@ARROWID) AND CONVERT(DATE,AggredatedDate)=
	(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID) AND CalcType<>'Event'
	END

	ELSE

	BEGIN

	INSERT INTO #TEMP (LessonPlanId
	,CalcType
	,AggredatedDate
	,ClassType
	,IOAPerc
	,LessonPlanName
	,StudentFname
	,ArrowNote
	,StudentLname
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment
	,Score
	,ColName
	,RptLabel)
	SELECT LESSONID
	,CalcType
	,AggredatedDate
	,ClassType
	,IOAPerc
	,LessonPlanName
	,StudentFname
	,ArrowNote --+'---------->' AS ArrowNote
	,StudentLname
	,EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment
	,0 AS Score
	,(SELECT TOP 1 TMP.ColName FROM #TEMP TMP WHERE TMP.LessonPlanId=LESSONID) ColName
	,(SELECT TOP 1 TMP.RptLabel FROM #TEMP TMP WHERE TMP.LessonPlanId=LESSONID) RptLabel
	 FROM #LPARROW WHERE ID=@ARROWID

	END

	SET @ARROWCNT=@ARROWCNT-1
	SET @ARROWID=@ARROWID+1
	END

	

	 DROP TABLE #LPARROW	


	
	INSERT INTO #TEMP (LessonPlanId
	,CalcType
	,AggredatedDate
	,ClassType
	,IOAPerc
	,LessonPlanName
	,StudentFname
	,ArrowNote
	,StudentLname
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment
	,ColName
	,RptLabel)
	SELECT 
	(SELECT LPID FROM #EVNT WHERE ID=@Cnt) AS LESSONID
	,(SELECT TOP 1 CalcType FROM [dbo].[DSTempSetColCalc] WHERE DSTempSetColId=(SELECT TOP 1 DSTempSetColId FROM [dbo].[DSTempSetCol] 
	WHERE DSTempHdrId=  (SELECT TOP 1 DSTempHdrId FROM DSTempHdr WHERE 
	LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt) AND StudentId=@SID AND SchoolId=@School ORDER BY DSTempHdrId DESC))) CalcType
	,TimeStampForReport AS AggredatedDate
	,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 AND LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay=1 THEN 
	'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' END END END FROM [dbo].[StdtLessonPlan] WHERE 
	LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt)
	  AND StudentId=@SID AND SchoolId=@School ORDER BY StdtLessonPlanId DESC) AS ClassType
	,NULL IOAPerc
	,(SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt)) LessonPlanName
	,Student.StudentFname
	,NULL AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment
	,(SELECT TOP 1 TMP.ColName FROM #TEMP TMP WHERE TMP.LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt)) ColName
	,(SELECT TOP 1 TMP.RptLabel FROM #TEMP TMP WHERE TMP.LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt)) RptLabel FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN LessonPlan ON LessonPlan.LessonPlanId=[StdtSessEvent].LessonPlanId WHERE Student.StudentId=@SID AND [StdtSessEvent].LessonPlanId 
	IN (0) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes'

	INSERT INTO #TEMP (LessonPlanId
	,CalcType
	,AggredatedDate
	,ClassType
	,IOAPerc
	,LessonPlanName
	,StudentFname
	,ArrowNote
	,StudentLname
	,EventType
	,EventName
	,EvntTs
	,EndTime
	,Comment
	,ColName
	,RptLabel)
	SELECT 
	[StdtSessEvent].LessonPlanId
	,(SELECT TOP 1 CalcType FROM [dbo].[DSTempSetColCalc] WHERE DSTempSetColId=(SELECT TOP 1 DSTempSetColId FROM [dbo].[DSTempSetCol] 
	WHERE DSTempHdrId=  (SELECT TOP 1 DSTempHdrId FROM DSTempHdr WHERE 
	LessonPlanId=(SELECT LPID FROM #EVNT WHERE ID=@Cnt) AND StudentId=@SID AND SchoolId=@School ORDER BY DSTempHdrId DESC))) CalcType
	,TimeStampForReport AS AggredatedDate
	,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 AND LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay=1 THEN 
	'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' END END END FROM [dbo].[StdtLessonPlan] WHERE 
	LessonPlanId=([StdtSessEvent].LessonPlanId)
	  AND StudentId=@SID AND SchoolId=@School ORDER BY StdtLessonPlanId DESC) AS ClassType
	,NULL IOAPerc
	,(SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=([StdtSessEvent].LessonPlanId)) LessonPlanName
	,Student.StudentFname
	,NULL AS ArrowNote
	,Student.StudentLname
	,StdtSessEventType AS EventType
	,EventName
	,TimeStampForReport
	,EndTime
	,Comment
	,(SELECT TOP 1 TMP.ColName FROM #TEMP TMP WHERE TMP.LessonPlanId=[StdtSessEvent].LessonPlanId) ColName
	,(SELECT TOP 1 TMP.RptLabel FROM #TEMP TMP WHERE TMP.LessonPlanId=[StdtSessEvent].LessonPlanId) RptLabel FROM [dbo].[StdtSessEvent]
	INNER JOIN Student ON Student.StudentId=[StdtSessEvent].StudentId
	LEFT JOIN LessonPlan ON LessonPlan.LessonPlanId=[StdtSessEvent].LessonPlanId WHERE Student.StudentId=@SID AND [StdtSessEvent].LessonPlanId 
	IN (SELECT LPID FROM #EVNT WHERE ID=@Cnt) AND EventType='EV' AND EvntTs BETWEEN @SDate AND @EDate
	AND StdtSessEventType<>'Arrow notes'

	
	

	SET @Cnt=@Cnt-1
	END

	DROP TABLE #EVNT	
	
		
	
	UPDATE #TEMP SET PromptCount=(SELECT Data FROM SplitWithRow(#TEMP.CalcRptLabelLP,'-') WHERE RWNMBER=4)
		

	
	UPDATE #TEMP  SET NonPercntCount=(SELECT COUNT(DISTINCT CalcType) FROM #TEMP TMP WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize') AND TMP.LessonPlanId=#TEMP.LessonPlanId)

	
	UPDATE #TEMP SET PercntCount=(SELECT COUNT(DISTINCT CalcType) FROM #TEMP TMP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
	'Avg Duration','Customize','Event') AND TMP.LessonPlanId=#TEMP.LessonPlanId)

	
	UPDATE #TEMP SET ColName=(SELECT Data FROM SplitWithRow(#TEMP.CalcRptLabelLP,'-') WHERE RWNMBER=3)
	
	DROP TABLE #TMP

	------------- Coloring Fix start---------------------

	
	SET @CNTLP=1
	SET @CalcRptLabelLP=''

	CREATE TABLE #COLORING (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),CalcRptLabelLP VARCHAR(500));
	INSERT INTO #COLORING	SELECT DISTINCT CalcRptLabelLP  FROM #TEMP 

	DECLARE db_cursor CURSOR FOR  
	SELECT CalcRptLabelLP FROM #COLORING 

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @CalcRptLabelLP   

WHILE @@FETCH_STATUS = 0   
BEGIN 
--SELECT @CNTLP
	UPDATE #TEMP SET Color=(SELECT ColorCode FROM Color WHERE 

ColorId=@CNTLP),Shape=(SELECT Shape FROM Color WHERE ColorId=@CNTLP) WHERE 

CalcRptLabelLP=@CalcRptLabelLP
	SET @CNTLP=@CNTLP+1
        

       FETCH NEXT FROM db_cursor INTO @CalcRptLabelLP
END   

CLOSE db_cursor   
DEALLOCATE db_cursor


DROP TABLE #COLORING


------------------- Coloring fix end ------------------------
UPDATE #TEMP SET ColName = NULL,RptLabel=NULL,CalcType='Event' WHERE EventType IS NOT NULL AND EventName IS NOT NULL

	SELECT *,(SELECT TOP 1 ('Tx: ' + (SELECT LookupName FROM LookUp WHERE LookupId= [TeachingProcId]) + ';' + (SELECT LookupName FROM LookUp WHERE LookupId= [PromptTypeId])) Treatment FROM DSTempHdr  HDR
WHERE LessonPlanId=#TEMP.LessonPlanId AND StudentId=@SID 
AND StatusId IN ((SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Approved'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Expired'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Deleted'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Inactive'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Maintenance'))
ORDER BY DSTempHdrId DESC) Treatment
,(SELECT TOP 1 'Correct Response: '+StudCorrRespDef FROM DSTempHdr WHERE LessonPlanId=#TEMP.LessonPlanId AND StudentId=@SID AND StudCorrRespDef<>'' AND
 StatusId IN ((SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Approved'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Expired'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Deleted'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Inactive'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Maintenance'))
ORDER BY DSTempHdrId DESC) Deftn FROM #TEMP WHERE EventType IN (SELECT * FROM Split(@Event,',')) OR EventType IS NULL

END








GO
