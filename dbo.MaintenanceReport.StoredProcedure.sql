USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[MaintenanceReport]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MaintenanceReport]

@StartDate datetime,
@EndDate datetime,
@SchoolId int,
@StudentId int,
@LessonHdrId varchar(50),
@SetId varchar(50),
@Events varchar(50),
@TrendType varchar(50),
@IncludeIOA varchar(50),
@ClsType varchar(50)

AS
BEGIN
	
	SET NOCOUNT ON;

	Declare 
	@LessonId varchar(50)
	,@CNT int
	,@Rowcnt int
	,@Totalcnt int
	,@TMPCount int
	,@calctype varchar(50)
	,@CalcRptLabelLP varchar(500) 
	,@TMPLoopCount int
	,@ARROWCNT int
	,@ARROWID int
	,@CNTLP int
	,@Scoreid int 
	,@Breaktrendid int
	,@LCount int
	,@ClassType varchar(50)
	,@ColRptLabelLP varchar(500)
	,@RptLbl varchar(200)
	,@Score int
	,@Nullcnt int
	,@NumOfTrend int
	,@TrendsectionNo int
	,@DateCnt int
	,@Midrate1 float
	,@Midrate2 float
	,@Slope float
	,@Const float
	,@Ids int
	,@IdOfTrend int
	,@SUM_XI float
	,@SUM_YI float
	,@SUM_XX float
	,@SUM_XY float
	,@X1 float
	,@Y1 float
	,@Z1 float
	,@X2 float
	,@Y2 float
	,@Z2 float
	,@A float
	,@B float
	,@datePrev datetime
	,@dateCurr datetime
	,@XValue int
	,@EVNTCNT INT
	,@RNUM INT
	,@CalcRpt VARCHAR(200)
	,@CLCNT INT
	,@RPTCNT INT
	,@PScore FLOAT
	,@PDummy FLOAT
	,@SNbr INT
	,@SNbr2 INT
	,@INDEX INT
	,@IOACNT INT
	,@IOAPer VARCHAR(50)
	,@HdrId INT
	,@SessDate DATETIME
	,@newrownum INT
	,@newsessionnmbr INT
	,@CurrentSessionDate DATETIME
	,@MajorMinor varchar(15)
	,@EventName nvarchar(max)
	,@cTyp varchar(50)
	,@cstype varchar(50)

	SET @EndDate=@EndDate+'23:59:59:998'

	IF OBJECT_ID('tempdb..#TEMP1') IS NOT NULL  
	DROP TABLE #TEMP1	
	
	CREATE TABLE #TEMP1(Scoreid int NOT NULL PRIMARY KEY IDENTITY(1,1),SessionDate datetime,Rownum int,SNbr int,StartTs datetime,CalcType varchar(50),ClassType varchar(50),Score float,LessonPlanId int,LessonPlanName varchar(500)
	,IOAPerc varchar(50),ArrowNote nvarchar(500),EventType varchar(50),EventName nvarchar(max),EvntTs datetime,EndTime datetime,Comment varchar(500),StudentName varchar(200)
	,PromptCnt int,CalcRptLabelLP VARCHAR(500),ClassNameType varchar(50),BreakTrendNo int,XValue int,Trend float,StdtSessionHdr int
	,DummyScore float NULL,LeftYaxis varchar(500) NULL,RightYAxis varchar(500) NULL,PromptCount int NULL,
	NonPercntCount int NULL,PercntCount int NULL,ColName varchar(200) NULL,RptLabel varchar(200) NULL,Color varchar(50),Shape varchar(50), Score1 float NULL, Score2 float NULL, 
	PreScore float NULL, PreDummy float NULL, MaxScore FLOAT NULL, MaxDummyScore FLOAT NULL,CType varchar(50));
	

	SET @LessonId=(SELECT LessonPlanId FROM DSTempHdr WHERE DSTempHdrId=@LessonHdrId AND StudentId= @StudentId)

	SET @cstype=(SELECT TOP (1) CASE WHEN LessonPlanTypeDay = 1 AND LessonPlanTypeResi = 1 
				THEN 'Day,Residence' ELSE CASE WHEN LessonPlanTypeDay = 1 THEN 'Day' 
				ELSE CASE WHEN LessonPlanTypeResi = 1 THEN 'Residence' END END END AS Expr1
				FROM StdtLessonPlan WHERE (LessonPlanId = @LessonId) AND (StudentId = @StudentId) AND (SchoolId = @SchoolId)
				ORDER BY StdtLessonPlanId DESC)			

				
	IF (@ClsType='Day' OR @ClsType='Residence')
	BEGIN
		INSERT INTO #TEMP1(
		SessionDate
		,Rownum
		,SNbr
		,StartTs 
		,CalcType
		,ClassType
		,Score
		,LessonPlanId
		,IOAPerc
		,CalcRptLabelLP
		,ClassNameType
		,StdtSessionHdr
		,CType)
	SELECT STARTDATE
		,ROW_NUMBER() OVER (PARTITION BY LessonPlanId, CalcRptLabelLP ORDER BY SNbr,STARTDATE ASC) AS RowNumber
		,SNbr		
		,EndTs 
		,CalcType
		,Residence
		,Score
		,LessonPlanId
		,IOAPERCENTAGE
		,CalcRptLabelLP
		,ClassNameType
		,StdtSessionHdrId
		,CType
	FROM (SELECT 
		CONVERT(DATE,HDR.EndTs) AS STARTDATE
		,HDR.SessionNbr AS SNbr
		,HDR.EndTs
		,CALC.CalcType
		,@ClsType AS Residence 
		,CASE WHEN CSR.Score =-1 THEN NULL ELSE CSR.Score END AS Score
		,HDR.LessonPlanId	
		,CASE WHEN (SELECT IOAPerc FROM StdtSessionHdr WHERE IOASessionHdrId=HDR.StdtSessionHdrId AND EndTs >= @StartDate AND  EndTs <= @EndDate 
			AND IOAPerc IS NOT NULL) IS NOT NULL THEN 'IOA '+(SELECT CONVERT(VARCHAR(50),ROUND(IOAPerc,0)) FROM StdtSessionHdr WHERE IOASessionHdrId=HDR.StdtSessionHdrId 
			AND EndTs >= @StartDate AND EndTs <= @EndDate AND IOAPerc IS NOT NULL)+'% ' ELSE NULL END IOAPERCENTAGE
		,(CONVERT(VARCHAR(50),HDR.LessonPlanId)+'@'+(SELECT CASE WHEN CALC.CalcRptLabel='' THEN CALC.CalcType ELSE CALC.CalcRptLabel END )+'@'+(SELECT ColName FROM DSTempSetCol 
			WHERE DSTempSetColId= (SELECT DSTempSetColId FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=CALC.DsTempSetColCalcId))) AS CalcRptLabelLP	
		,CASE WHEN CLS.ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassNameType
		,HDR.StdtSessionHdrId
		,@cstype as CType
	FROM StdtSessionHdr HDR
	INNER JOIN StdtSessColScore CSR ON HDR.StdtSessionHdrId=CSR.StdtSessionHdrId
	INNER JOIN DSTempSetColCalc CALC ON CSR.DSTempSetColCalcId=CALC.DSTempSetColCalcId
	INNER JOIN Class CLS ON HDR.StdtClassId=CLS.ClassId
	WHERE HDR.StudentId=@StudentId AND HDR.IOAInd='N' AND HDR.SessMissTrailStus ='N' AND HDR.SessionStatusCd='S' 
		AND ((@SetId= -1 AND HDR.LessonPlanId=@LessonId AND HDR.IsMaintanace=0) OR (@SetId!=-1 AND HDR.DSTempHdrId =@LessonHdrId AND HDR.CurrentSetId=@SetId AND HDR.IsMaintanace=1))
		AND HDR.SchoolId=@SchoolId AND HDR.EndTs <= @EndDate AND HDR.EndTs >= @StartDate AND CALC.IncludeInGraph<>0 AND 
		(SELECT TOP 1  CASE WHEN LessonPlanTypeDay=1 and (LessonPlanTypeResi=0 OR LessonPlanTypeResi IS NULL) THEN 'Day' 
		ELSE CASE WHEN (LessonPlanTypeDay=0 OR LessonPlanTypeDay IS NULL) and LessonPlanTypeResi=1 THEN 'Residence' END 
		END  FROM [dbo].[StdtLessonPlan] WHERE LessonPlanId=HDR.LessonPlanId AND StudentId=@StudentId AND SchoolId=@SchoolId ORDER BY StdtLessonPlanId DESC)=@ClsType
	) SESS
	ORDER BY CalcRptLabelLP,LessonPlanId,EndTs
	END

	ELSE IF (@ClsType='Day,Residence')
	BEGIN
		INSERT INTO #TEMP1(
		SessionDate
		,Rownum
		,SNbr
		,StartTs 
		,CalcType
		,ClassType
		,Score
		,LessonPlanId
		,IOAPerc
		,CalcRptLabelLP
		,ClassNameType
		,StdtSessionHdr
		,CType)
	SELECT STARTDATE
		,ROW_NUMBER() OVER (PARTITION BY LessonPlanId, CalcRptLabelLP ORDER BY SNbr,STARTDATE ASC) AS RowNumber
		,SNbr		
		,EndTs 
		,CalcType
		,Residence
		,Score
		,LessonPlanId
		,IOAPERCENTAGE
		,CalcRptLabelLP
		,ClassNameType
		,StdtSessionHdrId
		,CType
	FROM (SELECT 
		CONVERT(DATE,HDR.EndTs) AS STARTDATE
		,HDR.SessionNbr AS SNbr
		,HDR.EndTs
		,CALC.CalcType
		,@ClsType AS Residence 
		,CASE WHEN CSR.Score =-1 THEN NULL ELSE CSR.Score END AS Score
		,HDR.LessonPlanId	
		,CASE WHEN (SELECT IOAPerc FROM StdtSessionHdr WHERE IOASessionHdrId=HDR.StdtSessionHdrId AND EndTs >= @StartDate AND  EndTs <= @EndDate 
			AND IOAPerc IS NOT NULL) IS NOT NULL THEN 'IOA '+(SELECT CONVERT(VARCHAR(50),ROUND(IOAPerc,0)) FROM StdtSessionHdr WHERE IOASessionHdrId=HDR.StdtSessionHdrId 
			AND EndTs >= @StartDate AND EndTs <= @EndDate AND IOAPerc IS NOT NULL)+'% ' ELSE NULL END IOAPERCENTAGE
		,(CONVERT(VARCHAR(50),HDR.LessonPlanId)+'@'+(SELECT CASE WHEN CALC.CalcRptLabel='' THEN CALC.CalcType ELSE CALC.CalcRptLabel END )+'@'+(SELECT ColName FROM DSTempSetCol 
			WHERE DSTempSetColId= (SELECT DSTempSetColId FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=CALC.DsTempSetColCalcId))) AS CalcRptLabelLP	
		,CASE WHEN CLS.ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassNameType
		,HDR.StdtSessionHdrId
		,@cstype as CType
	FROM StdtSessionHdr HDR
	INNER JOIN StdtSessColScore CSR ON HDR.StdtSessionHdrId=CSR.StdtSessionHdrId
	INNER JOIN DSTempSetColCalc CALC ON CSR.DSTempSetColCalcId=CALC.DSTempSetColCalcId
	INNER JOIN Class CLS ON HDR.StdtClassId=CLS.ClassId
	WHERE HDR.StudentId=@StudentId AND HDR.IOAInd='N' AND HDR.SessMissTrailStus ='N' AND HDR.SessionStatusCd='S' 
		AND ((@SetId= -1 AND HDR.LessonPlanId=@LessonId AND HDR.IsMaintanace=0) OR (@SetId!=-1 AND HDR.DSTempHdrId =@LessonHdrId AND HDR.CurrentSetId=@SetId AND HDR.IsMaintanace=1))
		AND HDR.SchoolId=@SchoolId AND HDR.EndTs <= @EndDate AND HDR.EndTs>=@StartDate AND CALC.IncludeInGraph<>0 AND 
		(SELECT TOP 1  CASE WHEN LessonPlanTypeDay=1 OR LessonPlanTypeResi=1 THEN 'Day,Residence' END  FROM [dbo].[StdtLessonPlan] 
		WHERE LessonPlanId= HDR.LessonPlanId AND StudentId=@StudentId AND SchoolId=@SchoolId ORDER BY StdtLessonPlanId DESC)=@ClsType
	) SESS
	ORDER BY CalcRptLabelLP,LessonPlanId,EndTs
	END
	
		
	
	UPDATE #TEMP1 SET RptLabel=(SELECT Data FROM SplitWithRow(#TEMP1.CalcRptLabelLP,'@') WHERE RWNMBER=2)
	
	CREATE TABLE #DURATN(ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),Score FLOAT,LessonPlanId INT,CalcRptLabelLP varchar(500))
	INSERT INTO #DURATN
	SELECT MAX(ISNULL(Score,-1)),LessonPlanId,CalcRptLabelLP FROM #TEMP1 WHERE CalcType IN ('Total Duration','Avg Duration') GROUP BY LessonPlanId,CalcRptLabelLP
	
	SET @TMPCount=(SELECT COUNT(ID) FROM #DURATN)
	SET @TMPLoopCount=1
	WHILE(@TMPCount>0)
	BEGIN
		IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)<>-1)
		BEGIN
			IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)<60)
			BEGIN
				UPDATE #TEMP1 SET RptLabel=RptLabel+' (In Seconds)' WHERE CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
			END
			ELSE IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)<3600)
			BEGIN
				UPDATE #TEMP1 SET RptLabel=RptLabel+' (In Minutes)' WHERE CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
				UPDATE #TEMP1 SET Score=Score/60 WHERE CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
			END
			ELSE IF((SELECT Score FROM #DURATN WHERE ID=@TMPLoopCount)>=3600)
			BEGIN
				UPDATE #TEMP1 SET RptLabel=RptLabel+' (In Hours)' WHERE CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
				UPDATE #TEMP1 SET Score=Score/3600 WHERE CalcRptLabelLP=(SELECT CalcRptLabelLP FROM #DURATN WHERE ID=@TMPLoopCount)
			END
		END
	SET @TMPLoopCount=@TMPLoopCount+1
	SET @TMPCount=@TMPCount-1
	END		
	DROP TABLE #DURATN
	
	UPDATE #TEMP1  SET NonPercntCount=(SELECT COUNT(DISTINCT CalcType) FROM #TEMP1 TMP WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
		'Avg Duration','Customize'))	
	UPDATE #TEMP1 SET PercntCount=(SELECT COUNT(DISTINCT CalcType) FROM #TEMP1 TMP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency',
		'Avg Duration','Customize','Event'))	
	UPDATE #TEMP1 SET ColName=(SELECT Data FROM [dbo].[SplitWithRow](#TEMP1.CalcRptLabelLP,'@') WHERE RWNMBER=3)
	
	--------------------------------------AVOID NULL SESSIONS-------------------------------------------
	CREATE TABLE #NULLSESSION (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), SessNbr INT)
	INSERT INTO #NULLSESSION SELECT DISTINCT SNbr FROM #TEMP1 WHERE CalcType<>'Event' AND Score IS NULL AND DummyScore IS NULL ORDER BY SNbr
	SET @CNT=1
	SET @Rowcnt=(SELECT COUNT(ID) FROM #NULLSESSION)
	WHILE (@Rowcnt>0)
	BEGIN
		SET @SNbr=(SELECT SessNbr FROM #NULLSESSION WHERE ID=@CNT)
		SET @Totalcnt=(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE SNbr=@SNbr AND (Score IS NOT NULL OR DummyScore IS NOT NULL))
		IF(@Totalcnt=0)
			DELETE FROM #TEMP1 WHERE SNbr=@SNbr and CalcType<>'Event'
		SET @CNT=@CNT+1
		SET @Rowcnt=@Rowcnt-1
	END
	DROP TABLE #NULLSESSION

	CREATE TABLE #NULLTEMP (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), CalcRptLabl VARCHAR(200))
	INSERT INTO #NULLTEMP SELECT DISTINCT CalcRptLabelLP FROM #TEMP1 where CalcType<>'Event' 
	SET @CNT=1
	SET @Rowcnt=(SELECT COUNT(ID) FROM #NULLTEMP)
	WHILE (@Rowcnt>0)
	BEGIN
		SET @CalcRptLabelLP=(SELECT CalcRptLabl FROM #NULLTEMP WHERE ID=@CNT) 
		SET @Totalcnt=(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE CalcRptLabelLP=@CalcRptLabelLP)
		SET @CLCNT=(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE CalcRptLabelLP=@CalcRptLabelLP AND Score IS NULL AND DummyScore IS NULL)
		IF (@Totalcnt=@CLCNT)
			DELETE FROM #TEMP1 WHERE CalcRptLabelLP=@CalcRptLabelLP and CalcType<>'Event'
		SET @CNT=@CNT+1
		SET @Rowcnt=@Rowcnt-1
	END
	DROP TABLE #NULLTEMP

	--------------------Arrow Notes-----------------
	IF('Arrow' in ( SELECT * FROM Split(@Events,',') ))
	BEGIN
		CREATE TABLE #LPARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),LESSONID int,CalcType VARCHAR(50),AggredatedDate datetime,ClassType VARCHAR(50),IOAPerc VARCHAR(50),
			LessonPlanName VARCHAR(200),StudentFname VARCHAR(200),ArrowNote NVARCHAR(500),StudentLname VARCHAR(200),EventType VARCHAR(50),EventName NVARCHAR(max),
			TimeStampForReport datetime,EndTime datetime,Comment VARCHAR(200));	
		INSERT INTO #LPARROW
		SELECT 
			SE.LessonPlanId
			,'Event' CalcType
			,TimeStampForReport AS AggredatedDate
			,@cstype AS ClassType
			,NULL IOAPerc
			,DH.DSTemplateName AS LessonPlanName
			,S.FirstName
			,EventName AS ArrowNote
			,S.LastName
			,StdtSessEventType AS EventType
			,EventName
			,TimeStampForReport
			,EndTime
			,Comment 
		FROM StdtSessEvent SE
		INNER JOIN StudentPersonal S ON S.StudentPersonalId=SE.StudentId
		LEFT JOIN DSTempHdr DH ON DH.LessonPlanId=SE.LessonPlanId AND DH.DSTempHdrId=@LessonHdrId 
		WHERE SE.StudentId=@StudentId AND SE.LessonPlanId IN (0, @LessonId) AND EventType='EV' AND EvntTs >= @StartDate AND EvntTs <= @EndDate 
			AND StdtSessEventType='Arrow notes' --SETID

		SET @ARROWCNT =(SELECT COUNT(ID) FROM #LPARROW)
		SET @ARROWID=1
		WHILE(@ARROWCNT>0)
		BEGIN
			SET @CNTLP=(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE CONVERT(DATE,SessionDate)=(SELECT CONVERT(DATE,AggredatedDate) FROM #LPARROW WHERE ID=@ARROWID))	
			IF(@CNTLP>0)
		    BEGIN
				UPDATE top (1) #TEMP1 SET ArrowNote=(SELECT STUFF((SELECT ','+CONVERT(NVARCHAR(MAX), EventName) FROM (SELECT [EventName] FROM #LPARROW 
					WHERE CONVERT(DATE,AggredatedDate)= CONVERT(DATE,SessionDate)) EName FOR XML PATH('')),1,1,''))	WHERE CONVERT(DATE,SessionDate)=(SELECT CONVERT(DATE,AggredatedDate) 
					FROM #LPARROW WHERE ID=@ARROWID)
			END
			ELSE IF exists(SELECT Scoreid FROM #TEMP1)
			BEGIN
				INSERT INTO #TEMP1 (LessonPlanId
					,CalcType
					,SessionDate
					,ClassType
					,IOAPerc
					,LessonPlanName
					,ArrowNote
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
					,ArrowNote 
					,EventType
					,NULL as EventName
					,TimeStampForReport
					,EndTime
					,Comment
					,0 AS Score
					,(SELECT TOP 1 TMP.ColName FROM #TEMP1 TMP) ColName
					,(SELECT TOP 1 TMP.RptLabel FROM #TEMP1 TMP) RptLabel
				FROM #LPARROW WHERE ID=@ARROWID	and  CONVERT(DATE,AggredatedDate) IN (SELECT DISTINCT SessionDate FROM #TEMP1)
			END
			SET @ARROWCNT=@ARROWCNT-1
			SET @ARROWID=@ARROWID+1
		END	
		DROP TABLE #LPARROW	
	END

	-----------------------Events for current Set and Maintenance Sets----------------------------	
	IF('Major' in ( SELECT * FROM Split(@Events,',') ))
		SET @MajorMinor='Major'
	IF('Minor' in ( SELECT * FROM Split(@Events,',') ))
	BEGIN
		IF (@MajorMinor IS NOT NULL)
			SET @MajorMinor= @MajorMinor+',Minor'
		ELSE
			SET @MajorMinor='Minor'
	END

	declare @spl table(sp varchar(50))
	insert into @spl (sp) SELECT * FROM Split(@MajorMinor,',') 


	IF(@SetId = -1)
	BEGIN
		IF exists(SELECT Scoreid FROM #TEMP1 WHERE  Score is not null AND CalcType<>'Event')
		BEGIN	 
			INSERT INTO #TEMP1 (LessonPlanId
			,CalcType
			,SessionDate
			,ClassType
			,LessonPlanName
			,EventType
			,EventName
			,EvntTs
			,EndTime
			,Comment
			,Rownum
			,SNbr
			,CType)
			SELECT  @LessonId	
			,'Event' AS CalcType
			,CONVERT(DATE,EvntTs) AS AggredatedDate
			,@cstype AS ClassType
			,DH.DSTemplateName AS LessonPlanName	
			,CASE WHEN (SELECT COUNT(StdtSessEventId) FROM StdtSessEvent where StdtSessEventType='Major' AND StdtSessEventType IN (SELECT sp FROM @spl) and 
				((SessionNbr >0 and SessionNbr=SE.SessionNbr) OR (SE.SessionNbr IS NULL)) AND (LessonPlanId=@LessonId OR LessonPlanId=0) AND StudentId=@StudentId and 
				CONVERT(DATE,EvntTs) =CONVERT(DATE,SE.EvntTs)) >0 THEN 'Major' ELSE 'Minor' END AS EventType
			,CASE WHEN SE.SessionNbr IS NOT NULL THEN (SELECT STUFF((SELECT ', '+ EventName FROM (SELECT EventName  FROM StdtSessEvent EVNT WHERE EVNT.StudentId=@StudentId AND 
				EventType='EV' AND CONVERT(DATE,EVNT.EvntTs) =CONVERT(DATE,SE.EvntTs) AND StdtSessEventType<>'Arrow notes' AND StdtSessEventType IN (SELECT sp FROM @spl) 
				AND EVNT.SessionNbr >0 AND EVNT.SessionNbr=SE.SessionNbr AND (EVNT.LessonPlanId=@LessonId OR EVNT.LessonPlanId=0)) LP FOR XML PATH('')),1,1,'')) 
				ELSE (SELECT STUFF((SELECT  ', '+ EventName FROM (SELECT EventName FROM StdtSessEvent EVNT WHERE EVNT.StudentId=@StudentId AND EventType='EV' AND CONVERT(DATE,EVNT.EvntTs)= 
				CONVERT(DATE,SE.EvntTs) AND StdtSessEventType<>'Arrow notes' AND StdtSessEventType IN (SELECT sp FROM @spl)
				AND EVNT.SessionNbr IS NULL  AND (EVNT.LessonPlanId=@LessonId OR EVNT.LessonPlanId=0)) LP FOR XML PATH('')),1,1,''))  END EventName	
			,CONVERT(DATE,EvntTs) EvntTs
			,NULL AS EndTime
			,NULL AS Comment	
			,(CASE WHEN SE.SessionNbr IS NOT NULL THEN (CASE WHEN (SELECT TOP 1 Rownum FROM #TEMP1 WHERE StdtSessionHdr = (SELECT StdtSessionHdrId FROM StdtSessionHdr WHERE 
				SessionNbr= SE.SessionNbr AND LessonPlanId IN (@LessonId, 0) AND StudentId=@StudentId AND CONVERT(DATE,EndTs)=CONVERT(DATE,SE.EvntTs))) IS NOT NULL THEN
				(SELECT TOP 1 Rownum FROM #TEMP1 WHERE StdtSessionHdr = (SELECT StdtSessionHdrId FROM StdtSessionHdr WHERE SessionNbr= SE.SessionNbr AND LessonPlanId IN (@LessonId,0)
				AND StudentId=@StudentId AND CONVERT (DATE,EndTs)=CONVERT(DATE,SE.EvntTs))) ELSE (SELECT TOP 1 Rownum FROM #TEMP1 WHERE 
				 #TEMP1.SessionDate=CONVERT(DATE,SE.EvntTs)) END) ELSE (SELECT TOP 1 Rownum FROM #TEMP1 WHERE #TEMP1.SessionDate=CONVERT(DATE,SE.EvntTs))  END ) AS Rownum
			,(CASE WHEN SessionNbr IS NOT NULL THEN SessionNbr ELSE (SELECT TOP 1 SNbr FROM #TEMP1 WHERE #TEMP1.SessionDate=CONVERT(DATE,SE.EvntTs) )END)
			,@cstype as CType
			FROM StdtSessEvent SE
			LEFT JOIN DSTempHdr DH ON DH.DSTempHdrId=SE.DSTempHdrId 
			WHERE SE.StudentId=@StudentId AND (SE.LessonPlanId=@LessonId OR SE.LessonPlanId=0) AND EventType='EV' AND EvntTs >= @StartDate AND EvntTs <= @EndDate 
				AND StdtSessEventType<>'Arrow notes' AND StdtSessEventType IN (SELECT sp FROM @spl)
			GROUP BY SE.LessonPlanId,CONVERT(DATE,EvntTs),SE.StdtSessEventType,SE.SessionNbr,SE.StudentId,DSTemplateName
			ORDER BY SessionNbr	
		END
	END	
	ELSE
	BEGIN
		IF ((SELECT COUNT(Scoreid) FROM #TEMP1)>=1)
		INSERT INTO #TEMP1 (LessonPlanId
			,CalcType
			,SessionDate
			,ClassType
			,EventType
			,EventName
			,EvntTs
			,EndTime
			,Comment
			,CType)
		SELECT distinct @LessonId AS LessonPlanId
			,'Event' AS CalcType
			,CONVERT(DATE,EvntTs) AS AggredatedDate
			,@cstype AS ClassType	
			,StdtSessEventType AS EventType
			,EventName EventName	
			,CONVERT(DATE,EvntTs) EvntTs
			,NULL AS EndTime
			,NULL AS Comment	
			,@cstype as CType
			FROM StdtSessEvent SE
			LEFT JOIN DSTempHdr DH ON DH.DSTempHdrId=SE.DSTempHdrId 
			WHERE SE.StudentId=@StudentId AND (SE.LessonPlanId=@LessonId OR SE.LessonPlanId=0) AND EventType='EV' AND EvntTs >= @StartDate AND EvntTs <= @EndDate 
				AND StdtSessEventType<>'Arrow notes' AND StdtSessEventType IN (SELECT sp FROM @spl) AND SE.DSTempHdrId IS  NULL
			ORDER BY AggredatedDate,EventType,EventName,EvntTs
	END

	-------------------------UPDATE LESSON NAME-----------------------------
	UPDATE #TEMP1 SET
	LessonPlanName= (SELECT  DSTemplateName FROM DSTempHdr  WHERE DSTempHdrId = @LessonHdrId AND StudentId=@StudentId) 
	
	--------------------------- Event Move back to previous session when null event occure(Event Tracker)---------------------------
	DECLARE @newsamesnbr INT, @newdate DATETIME, @newsamedate DATETIME
	CREATE TABLE #SEDATE (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), SessionDate DATE, SessNbr INT, Rownum INT)
	INSERT INTO #SEDATE SELECT DISTINCT SessionDate, SNbr,Rownum FROM #TEMP1 ORDER BY SessionDate,SNbr

	SET @Totalcnt=(SELECT COUNT(ID) FROM #SEDATE)
	SET @CNT=1
	WHILE(@Totalcnt>0)
	BEGIN
		SELECT @SNbr= SessNbr from #SEDATE WHERE ID=@CNT
		IF(@SNbr IS NULL)
		BEGIN	
			SET @CurrentSessionDate = (SELECT SessionDate FROM #SEDATE WHERE ID=@CNT)	
			IF((SELECT COUNT(SessionDate) FROM #TEMP1 WHERE SessionDate=@CurrentSessionDate AND SNbr IS NOT NULL)>=1)
			BEGIN
				SET @SNbr= (SELECT TOP 1 SNbr FROM #TEMP1 WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate)
				SET @RNUM= (SELECT TOP 1 Rownum FROM #TEMP1 WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate)
				UPDATE #TEMP1 SET snbr=@SNbr, Rownum=@RNUM	WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate AND SNbr IS NULL AND CalcType='Event'
			END
			ELSE
			BEGIN
				SET @newsessionnmbr=(SELECT SessNbr FROM #SEDATE WHERE ID=@CNT-1)			
				SET @newrownum=(SELECT Rownum FROM #SEDATE WHERE ID=@CNT-1)

				IF(@newsessionnmbr IS NOT NULL)				
					UPDATE #TEMP1 SET snbr=@newsessionnmbr, Rownum=@newrownum,SessionDate=(SELECT SessionDate FROM #SEDATE WHERE ID=@CNT-1)  
						WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate AND SNbr IS NULL AND CalcType='Event'	
				ELSE
				BEGIN
					IF (@CurrentSessionDate=(SELECT TOP 1 CONVERT(DATE,SessionDate) FROM #TEMP1 WHERE SNbr IS NOT NULL ORDER BY SessionDate ASC))
					BEGIN
						SET @SNbr= (SELECT TOP 1 SNbr FROM #TEMP1 WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate)
						SET @RNUM= (SELECT TOP 1 Rownum FROM #TEMP1 WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate)
						UPDATE #TEMP1 SET snbr=@SNbr, Rownum=@RNUM	WHERE CONVERT(DATE,SessionDate)=@CurrentSessionDate AND SNbr IS NULL AND CalcType='Event'
					END
					ELSE				
						DELETE FROM #TEMP1 WHERE SNbr IS NULL AND CalcType='Event' AND CONVERT(DATE,SessionDate)<
							(SELECT TOP 1 CONVERT(DATE,SessionDate) FROM #TEMP1 where SNbr IS NOT NULL ORDER BY SessionDate ASC)	
				END
			END
		END
		SET @CNT=@CNT+1
		SET @Totalcnt=@Totalcnt-1
	END
	DROP TABLE #SEDATE

	--------------------------------OVERRIDE SHOULD MOVE BACK TO PRIOR SESSION-------------------------------------
	CREATE TABLE #OVERRIDE (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), RowNum INT, SessNbr INT, SessDate DATETIME)
	INSERT INTO #OVERRIDE SELECT Rownum, SNbr, SessionDate FROM #TEMP1 WHERE EventName LIKE '%(OV)' AND CalcType='Event' ORDER BY SNbr
	DECLARE @NewSessDate DATETIME

	SET @CNT= 1
	SET @Totalcnt= (SELECT COUNT(ID) FROM #OVERRIDE)
	WHILE(@Totalcnt>0)
	BEGIN
		SET @RNUM=(SELECT RowNum FROM #OVERRIDE WHERE ID=@CNT)
		SET @SessDate=(SELECT SessDate FROM #OVERRIDE WHERE ID=@CNT)			
		SET @NewSessDate=(SELECT TOP 1 SessionDate FROM #TEMP1 WHERE Rownum=@RNUM-1 ORDER BY SessionDate DESC)
		IF (@NewSessDate IS NOT NULL)
			UPDATE #TEMP1 SET SessionDate=@NewSessDate, Rownum= (SELECT TOP 1 Rownum FROM #TEMP1 WHERE Rownum= @RNUM-1 ORDER BY SessionDate DESC), 
				SNbr=(SELECT TOP 1 SNbr FROM #TEMP1 WHERE Rownum= @RNUM-1 ORDER BY SessionDate DESC) WHERE Rownum=@RNUM AND CalcType='Event'
		ELSE
			DELETE FROM #TEMP1 WHERE EventName LIKE '%(OV)' AND CalcType='Event' and Rownum=@RNUM and SessionDate=@SessDate
		SET @CNT=@CNT+1
		SET @Totalcnt=@Totalcnt-1
	END
	DELETE FROM #TEMP1 WHERE Rownum =0
	DROP TABLE #OVERRIDE

	--------------------------Avoid Repeating Events----------------------------	
	CREATE TABLE #RPT (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), RowNum INT, EType VARCHAR(50),EName NVARCHAR(MAX))
	INSERT INTO #RPT SELECT DISTINCT Rownum, EventType, EventName FROM #TEMP1 WHERE CalcType='Event' 
	DECLARE @EType VARCHAR(20)
	SET @CNT= 1
	SET @Totalcnt= (SELECT COUNT(ID) FROM #RPT)
	WHILE(@Totalcnt>0)
	BEGIN
		SET @RNUM=(SELECT RowNum FROM #RPT WHERE ID=@CNT)
		SET @EType=(SELECT EType FROM #RPT WHERE ID=@CNT)
		SET @EventName=(SELECT EName FROM #RPT WHERE ID=@CNT)
		SET @CalcRpt=(SELECT COUNT(RowNum) FROM #TEMP1 WHERE CalcType='Event' AND Rownum=@RNUM AND EventType=@EType AND EventName=@EventName)
		IF (@CalcRpt>1)
		BEGIN
			DELETE FROM #TEMP1 WHERE Scoreid=(SELECT TOP 1 Scoreid  FROM #TEMP1 WHERE CalcType='Event' AND Rownum=@RNUM AND EventType=@EType AND EventName=@EventName 
				ORDER BY Scoreid DESC)
		END
		SET @CNT=@CNT+1
		SET @Totalcnt=@Totalcnt-1
	END
	DROP TABLE #RPT

	----------------SAME ROW NUMBERS WITH DIFFERENT SESSION NUMBER--------------
	CREATE TABLE #ROWNUM (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), Scoreid INT, RowNum INT, SessNbr INT)
	INSERT INTO #ROWNUM SELECT Scoreid,Rownum, SNbr FROM #TEMP1 WHERE CalcType='Event' order by Rownum,SNbr
	DECLARE @NextRowNUM INT, @NextScoreId INT, @NextEventName nvarchar(max)
	SET @CNT= 1
	SET @Totalcnt= (SELECT COUNT(ID) FROM #ROWNUM)
	WHILE(@Totalcnt>0)
	BEGIN	
		SET @RNUM=(SELECT RowNum FROM #ROWNUM WHERE ID=@CNT)
		SET @NextRowNUM=(SELECT RowNum FROM #ROWNUM WHERE ID=@CNT+1)
		SET @Scoreid=(SELECT Scoreid FROM #ROWNUM WHERE ID=@CNT)
		SET @NextScoreId=(SELECT Scoreid FROM #ROWNUM WHERE ID=@CNT+1)
		IF (@RNUM=@NextRowNUM)
		BEGIN
			SET @EventName=(SELECT EventName FROM #TEMP1 WHERE Scoreid=@Scoreid)
			SET @NextEventName=(SELECT EventName FROM #TEMP1 WHERE Scoreid=@NextScoreId)
			UPDATE #TEMP1 SET EventName=(@EventName+', '+@NextEventName) WHERE Scoreid=@Scoreid
			DELETE FROM #TEMP1 WHERE Scoreid=@NextScoreId
			DELETE FROM #ROWNUM WHERE Scoreid=@NextScoreId
		END
		SET @CNT=@CNT+1
		SET @Totalcnt=@Totalcnt-1
	END
	DROP TABLE #ROWNUM

	
	------------#TEMP1 SORTING BASED ON SESSION NUMBER--------------
	CREATE TABLE #TEMPSESSION (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),RNum INT, SessNbr INT)
	INSERT INTO #TEMPSESSION SELECT Rownum, SNbr FROM #TEMP1 ORDER BY SNbr
	SET @INDEX=1
	SET @CNT=1
	SET @Rowcnt=(SELECT COUNT(ID) FROM #TEMPSESSION)
	WHILE (@Rowcnt>0)
	BEGIN
		SET @SNbr=(SELECT SessNbr FROM #TEMPSESSION WHERE ID=@CNT)
		IF (@SNbr!=@SNbr2)
		BEGIN
			IF (@SNbr IS NOT NULL)
			BEGIN
				SET @INDEX=@INDEX+1
				UPDATE #TEMP1 SET Rownum=@INDEX WHERE SNbr=@SNbr AND LessonPlanId=@LessonId
			END
		END
		ELSE
			UPDATE #TEMP1 SET Rownum=@INDEX WHERE SNbr=@SNbr AND LessonPlanId=@LessonId					
		
		SET @SNbr2=@SNbr
		SET @CNT=@CNT+1
		SET @Rowcnt=@Rowcnt-1
	END
	DROP TABLE #TEMPSESSION

	---------------TO SEPERATE EACH TRENDLINE FROM THE TABLE #TEMP, ADD EACH PAGE SESSION TO #TEMPTYPE 
	CREATE TABLE #TEMPTYPE(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),Type VARCHAR(50),ClassType varchar(50),RptLabel varchar(500),ColRptLabelLP varchar(500));
	INSERT INTO #TEMPTYPE SELECT DISTINCT CalcType,ClassType,RptLabel,CalcRptLabelLP FROM #TEMP1 WHERE CalcType<>'Event' ORDER BY CalcType
	SET @Cnt=1
	SET @Breaktrendid=1
	SET @Nullcnt=0

	--FOR SEPERATING EACH TERAND LINE SECTION AND NUMBERED IT AS 1,2,3 ETC IN 'BreakTrendNo' COLUMN OF #TEMP TABLE
	SET @LCount=(SELECT COUNT(ID) FROM #TEMPTYPE)
	WHILE(@LCount>0)
	BEGIN
		SET @Nullcnt=0
		SET @XValue= 1
		SET @CalcType=(SELECT Type FROM #TEMPTYPE WHERE ID=@Cnt)  
		SET @ClassType=(SELECT ClassType FROM #TEMPTYPE WHERE ID=@Cnt)
		SET @ColRptLabelLP=(SELECT ColRptLabelLP FROM #TEMPTYPE WHERE ID=@Cnt)
		SET @RptLbl=(SELECT RptLabel FROM #TEMPTYPE WHERE ID=@Cnt)
		SET @Scoreid=(SELECT TOP 1 Scoreid FROM #TEMP1 WHERE CalcType=@CalcType AND ClassType=@ClassType AND CalcRptLabelLP=@ColRptLabelLP order by SessionDate,Rownum asc)

		WHILE((SELECT COUNT(Scoreid) FROM #TEMP1 WHERE ClassType=@ClassType AND Calctype=@CalcType AND Scoreid=@Scoreid AND CalcRptLabelLP=@ColRptLabelLP)>0)
		BEGIN
			SET @Score=(SELECT CASE WHEN Score IS NOT NULL THEN Score ELSE CASE WHEN DummyScore IS NOT NULL THEN DummyScore ELSE ISNULL(CONVERT(int,Score),-1) END END
				FROM #TEMP1 WHERE Scoreid=@Scoreid)	
			SET @ARROWCNT=(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE CalcType='Event' AND SessionDate=(SELECT SessionDate FROM #TEMP1 WHERE Scoreid=@Scoreid) 
				AND Rownum=(SELECT Rownum FROM #TEMP1 WHERE Scoreid=@Scoreid))	
			IF(@ARROWCNT>0 )
			BEGIN
				IF(@Score=-1)
				BEGIN
					SET @Breaktrendid=(SELECT ISNULL(MAX(BreakTrendNo),0) FROM #TEMP1)+1	
				END
				ELSE
				BEGIN
					SET @Breaktrendid=(SELECT ISNULL(MAX(BreakTrendNo),0) FROM #TEMP1)+1
					SET @Nullcnt=0	
				END
			END
			IF(@Score=-1 AND ((@datePrev<=@dateCurr) OR @datePrev IS NULL))
			BEGIN	
				SET @Nullcnt=@Nullcnt+1	
			END
			ELSE IF(@Nullcnt>=5 AND @Score<>-1)
			BEGIN	
				SET @Breaktrendid=(SELECT ISNULL(MAX(BreakTrendNo),0) FROM #TEMP1)+1
				UPDATE #TEMP1 SET BreakTrendNo=@Breaktrendid WHERE Scoreid=@Scoreid
				SET @Nullcnt=0	
			END
			ELSE IF(@Score<>-1)
			BEGIN	
				IF(@ColRptLabelLP<>(SELECT CalcRptLabelLP FROM #TEMP1 WHERE Scoreid=(@Scoreid-1)))
				BEGIN
					SET @Breaktrendid=@Breaktrendid+1
				END
				IF(@ARROWCNT=0 )
				BEGIN
					UPDATE #TEMP1 SET BreakTrendNo=@Breaktrendid WHERE Scoreid=@Scoreid
					SET @Nullcnt=0	
				END
			END		
			UPDATE #TEMP1 SET XValue=@XValue WHERE Scoreid=@Scoreid	
			SET @XValue= @XValue+1	
			SET @Scoreid=@Scoreid+1	
		END
		SET @Breaktrendid=@Breaktrendid+1
		SET @Cnt=@Cnt+1
		SET @LCount=@LCount-1	
	END
	DROP TABLE #TEMPTYPE

	--SELECT EACH TREND LINE SECTION FROM #TEMP AND CALCULATE TREND POINT VALUES
	SET @Cnt=0
	IF(@Trendtype='Quarter')
	BEGIN
		SET @NumOfTrend=(SELECT MAX(BreakTrendNo) FROM #TEMP1)	
		WHILE(@NumOfTrend>0)
		BEGIN
			SET @Cnt=@Cnt+1
			SET @TrendsectionNo=(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE BreakTrendNo=@Cnt)
	
			IF(@TrendsectionNo>2)
			BEGIN		
				CREATE TABLE #TRENDSECTION(Id int PRIMARY KEY NOT NULL IDENTITY(1,1),Trenddate datetime,Score float,Scoreid int);
				INSERT INTO #TRENDSECTION SELECT SessionDate,Score,Scoreid FROM #TEMP1 WHERE Scoreid BETWEEN (SELECT TOP 1 Scoreid FROM #TEMP1 WHERE 
					BreakTrendNo=@Cnt ORDER BY Scoreid) AND (SELECT TOP 1 Scoreid FROM #TEMP1 WHERE BreakTrendNo=@Cnt ORDER BY Scoreid DESC) AND Score IS NOT NULL	
				IF((SELECT COUNT(Id) FROM #TRENDSECTION)%2=0)
					SET @DateCnt=((SELECT COUNT(Id) FROM #TRENDSECTION)/2)+1
				ELSE
					SET @DateCnt=((SELECT COUNT(Id) FROM #TRENDSECTION)/2)+2

				SET @Midrate1= (SELECT ((SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE Id BETWEEN 1 AND (SELECT COUNT(Id)/2 FROM #TRENDSECTION) 
					ORDER BY Score) As A ORDER BY Score DESC) +(SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE 
					Id BETWEEN 1 AND (SELECT COUNT(Id)/2 FROM #TRENDSECTION) ORDER BY Score DESC) As A ORDER BY Score Asc)) / 2 )

				SET @Midrate2=(SELECT ((SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE Id BETWEEN @DateCnt AND (SELECT COUNT(Id) FROM #TRENDSECTION)
					ORDER BY Score) As A ORDER BY Score DESC) +(SELECT TOP 1 Score FROM (SELECT  TOP 50 PERCENT Score FROM #TRENDSECTION WHERE 
					Id BETWEEN @DateCnt AND (SELECT COUNT(Id) FROM #TRENDSECTION) ORDER BY Score DESC) As A ORDER BY Score Asc)) / 2 )	
	
				IF(@TrendsectionNo>2)
				BEGIN
					SET @Slope=(@Midrate2-@Midrate1)/((SELECT TOP 1 XValue FROM #TEMP1 WHERE BreakTrendNo=@Cnt ORDER BY Scoreid DESC)-(SELECT TOP 1 XValue 
						FROM #TEMP1 WHERE BreakTrendNo=@Cnt ORDER BY Scoreid))
					--b=y-mx
					SET @Const=@Midrate1-(@Slope*(SELECT TOP 1 XValue FROM #TEMP1 WHERE BreakTrendNo=@Cnt ORDER BY Scoreid))
					SET @Ids=(SELECT TOP 1 XValue FROM #TEMP1 WHERE BreakTrendNo=@Cnt ORDER BY Scoreid) --FIRST x value	
					SET @IdOfTrend=(SELECT TOP 1 Scoreid FROM #TRENDSECTION ORDER BY Id)	
	
					WHILE(@IdOfTrend<=(SELECT MAX(Scoreid) FROM #TRENDSECTION))	
					BEGIN	
						UPDATE #TEMP1 SET Trend=((@Slope*@Ids)+@Const) WHERE Scoreid=@IdOfTrend
						SET @IdOfTrend=@IdOfTrend+1
						SET @Ids=@Ids+1
					END	
					DROP TABLE #TRENDSECTION
				END		
			END	
			SET @NumOfTrend=@NumOfTrend-1
		END
	END	
	--------------------------- Trend End----------------------------

	----------NEW CHANGE FOR TWO Y AXIS----------
	CREATE TABLE #TMPLP(ID int NOT NULL IDENTITY(1,1),CalcType varchar(50));
	INSERT INTO #TMPLP SELECT DISTINCT CalcType FROM #TEMP1 WHERE CalcType<>'Event' ORDER BY CalcType

	CREATE TABLE #TMPLPCNT(ID int NOT NULL IDENTITY(1,1),CalcTypeCNT INT);
	INSERT INTO #TMPLPCNT SELECT COUNT(1) AS CNT FROM #TMPLP

	SET @TMPCount=(SELECT COUNT(ID) FROM #TMPLPCNT)
	SET @TMPLoopCount=1
	WHILE(@TMPCount>0)
	BEGIN
		IF((SELECT CalcTypeCNT FROM #TMPLPCNT WHERE ID=@TMPLoopCount)>2)
		BEGIN
			IF exists(SELECT COUNT(Scoreid) FROM #TEMP1 WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize'))
			BEGIN	
				UPDATE #TEMP1 SET DummyScore=Score WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize') 
					AND LessonPlanId = @LessonId
				
				UPDATE #TEMP1 SET Score = NULL WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize') 
					AND LessonPlanId = @LessonId
	
				UPDATE #TEMP1 SET LeftYaxis=(SELECT STUFF((SELECT '/ '+ RptLabel FROM (SELECT DISTINCT RptLabel FROM #TEMP1 TMP WHERE CalcType NOT IN 
					('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize','Event') AND TMP.LessonPlanId= @LessonId 
					AND (SELECT COUNT(Scoreid) FROM #TEMP1 TP WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize') 
					AND TP.LessonPlanId=@LessonId)>0) LP FOR XML PATH('')),1,1,'')) WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
	
				UPDATE #TEMP1 SET RightYaxis=(SELECT STUFF((SELECT '/ '+ RptLabel FROM (SELECT DISTINCT RptLabel FROM #TEMP1 TMP WHERE CalcType IN 
					('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize') AND TMP.LessonPlanId=@LessonId 
					AND (SELECT COUNT(Scoreid) FROM #TEMP1 TP WHERE CalcType IN ('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize') 
					AND TP.LessonPlanId=@LessonId)>0) LP FOR XML PATH('')),1,1,'')) WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
	
				UPDATE #TEMP1 SET LeftYaxis=(CASE WHEN LeftYaxis IS NULL THEN RightYaxis ELSE LeftYaxis END )  WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
				UPDATE #TEMP1 SET RightYaxis=(CASE WHEN LeftYaxis=RightYaxis THEN NULL ELSE RightYaxis END )  WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
	
				IF((SELECT COUNT(Scoreid) FROM #TEMP1 WHERE CalcType NOT IN ('Total Duration','Total Correct','Total Incorrect','Frequency','Avg Duration','Customize') 
					AND LessonPlanId=@LessonId)>=2)
				BEGIN	
					UPDATE #TEMP1 SET LeftYaxis='Percent'  WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
				END
			END
		END
		ELSE
		BEGIN
			IF((SELECT CalcTypeCNT FROM #TMPLPCNT WHERE ID=@TMPLoopCount)=2)
			BEGIN
				UPDATE #TEMP1 SET DummyScore=Score WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=@LessonId ORDER BY ID DESC) AND LessonPlanId=@LessonId
				UPDATE #TEMP1 SET Score = NULL WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=@LessonId ORDER BY ID DESC) AND LessonPlanId=@LessonId
	
				UPDATE #TEMP1 SET LeftYaxis=(SELECT TOP 1 RptLabel FROM #TEMP1 WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=@LessonId  ORDER BY ID) 
					AND LessonPlanId=@LessonId) WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
	
				UPDATE #TEMP1 SET RightYaxis=(SELECT TOP 1 RptLabel FROM #TEMP1 WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=@LessonId ORDER BY ID DESC ) 
					AND LessonPlanId=@LessonId) WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'
			END
			ELSE
			BEGIN
				UPDATE #TEMP1 SET LeftYaxis=(SELECT TOP 1 RptLabel FROM #TEMP1 WHERE CalcType = (SELECT TOP 1 CalcType FROM #TMPLP WHERE LessonPlanId=@LessonId) 
					AND LessonPlanId=@LessonId) WHERE LessonPlanId=@LessonId AND CalcType <> 'Event'	
			END
		END
		SET @TMPLoopCount=@TMPLoopCount+1
		SET @TMPCount=@TMPCount-1
	END

	DROP TABLE #TMPLPCNT
	DROP TABLE #TMPLP

	------------- Coloring Fix start---------------------
	SET @CNTLP=1
	SET @ColRptLabelLP=''

	CREATE TABLE #COLORING (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),Lessonplanid int,ColRptLabelLP VARCHAR(500),Rownum int);
	INSERT INTO #COLORING(Lessonplanid,ColRptLabelLP)
	SELECT DISTINCT LessonPlanId,CalcRptLabelLP  FROM #TEMP1 WHERE CalcRptLabelLP IS NOT NULL

	;WITH T
    AS (SELECT Rownum, Row_number() OVER (PARTITION BY Lessonplanid ORDER BY Lessonplanid ) AS RN FROM   #COLORING)
	UPDATE T
	SET Rownum = RN 	

	DECLARE db_cursor CURSOR FOR  
	SELECT ColRptLabelLP,Rownum FROM #COLORING     
	OPEN db_cursor;      
		FETCH NEXT FROM db_cursor  
		INTO @ColRptLabelLP, @TMPCount; 	  

		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			IF(@TMPCount=1)
			BEGIN
				SET @CNTLP=1
				UPDATE #TEMP1 SET Color='Blue' WHERE CalcRptLabelLP=@ColRptLabelLP
			END
			ELSE IF(@TMPCount=2)
			BEGIN
				UPDATE #TEMP1 SET Color='Red' WHERE CalcRptLabelLP=@ColRptLabelLP
			END
			ELSE
			BEGIN
				UPDATE #TEMP1 SET Color='Black' WHERE CalcRptLabelLP=@ColRptLabelLP
			END
		
			UPDATE #TEMP1 SET Shape=(SELECT Shape FROM Color WHERE ColorId=@CNTLP) WHERE CalcRptLabelLP=@ColRptLabelLP
			SET @CNTLP=@CNTLP+1
        
			FETCH NEXT FROM db_cursor INTO @ColRptLabelLP , @TMPCount;
		END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor
	DROP TABLE #COLORING
	------------------- Coloring fix end ------------------------

	CREATE TABLE #COMBINE(ID int NOT NULL PRIMARY KEY IDENTITY(1,1),Rownum int,SessionDate datetime)
	INSERT INTO #COMBINE SELECT DISTINCT Rownum,SessionDate FROM #TEMP1 WHERE CalcType='Event' GROUP BY Rownum,SessionDate

	SET @CNT=1
	SET @CNTLP=(SELECT COUNT(ID) FROM #COMBINE)
	WHILE(@CNTLP>0)
	BEGIN
		SET @Rowcnt=(SELECT Rownum FROM #COMBINE WHERE ID=@CNT)
		SET @dateCurr=(SELECT CONVERT(DATE,SessionDate) FROM #COMBINE WHERE ID=@CNT) 
		UPDATE #TEMP1 SET EventName=(SELECT FORMAT(CONVERT(DATE,@dateCurr),'MM/dd')+','+ STUFF((SELECT  ', '+ EventName  FROM (SELECT EventName  FROM #TEMP1
			WHERE LessonPlanId=@LessonId AND Rownum=@Rowcnt AND CONVERT(DATE,SessionDate) =@dateCurr AND CalcType='Event' ) LP FOR XML PATH('')),1,1,''))
			WHERE LessonPlanId=@LessonId AND Rownum=@Rowcnt AND CONVERT(DATE,SessionDate)=@dateCurr AND CalcType='Event'
		SET @CNT=@CNT+1
		SET @CNTLP=@CNTLP-1
	END
	DROP TABLE #COMBINE

	-----------------------update #TEMP1 with score1 and score2------------------------	
	CREATE TABLE #TEMPSCORE (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), Rownum INT, SessionDate DATE)
	INSERT INTO #TEMPSCORE SELECT DISTINCT Rownum, SessionDate FROM #TEMP1 WHERE CalcType='Event' 
	SET @CNT=1
	SET @EVNTCNT=(SELECT COUNT(ID) FROM #TEMPSCORE)
	WHILE(@EVNTCNT>0)
	BEGIN
		SET @RNUM=(SELECT Rownum FROM  #TEMPSCORE WHERE ID=@CNT)
		SET @dateCurr=(SELECT CONVERT(DATE,SessionDate) FROM #TEMPSCORE WHERE ID=@CNT)
		CREATE TABLE #TEMPCALCRPT (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),CalcRptLabelLP VARCHAR(200))
		INSERT INTO #TEMPCALCRPT SELECT CalcRptLabelLP FROM #TEMP1 WHERE CONVERT(DATE,SessionDate)=@dateCurr AND Rownum=@RNUM and CalcRptLabelLP IS NOT NULL
		SET @CLCNT=1
		SET @RPTCNT=(SELECT COUNT(ID) FROM #TEMPCALCRPT)
		WHILE(@RPTCNT>0)
		BEGIN
			SET @CalcRpt=(SELECT CalcRptLabelLP FROM #TEMPCALCRPT WHERE ID=@CLCNT)
			UPDATE #TEMP1 SET Score1=Score, Score2=DummyScore WHERE Rownum=@RNUM AND LessonPlanId=@LessonId AND CalcRptLabelLP=@CalcRpt
					
			SET @PScore=(SELECT Score FROM  #TEMP1 WHERE Rownum=@RNUM AND LessonPlanId=@LessonId AND CalcRptLabelLP=@CalcRpt AND Score IS NOT NULL)
			SET @PDummy=(SELECT DummyScore FROM  #TEMP1 WHERE Rownum=@RNUM AND LessonPlanId=@LessonId AND CalcRptLabelLP=@CalcRpt AND DummyScore IS NOT NULL)
			UPDATE #TEMP1 SET Score1=Score, Score2=DummyScore, PreScore=@PScore, PreDummy=@PDummy WHERE Rownum=@RNUM+1 AND LessonPlanId=@LessonId AND CalcRptLabelLP=@CalcRpt

			SET @CLCNT=@CLCNT+1
			SET @RPTCNT=@RPTCNT-1
		END
		DROP TABLE #TEMPCALCRPT

		CREATE TABLE #TEMPEXCEPTCALCRPT (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),CalcRptLabelLP VARCHAR(200))
		INSERT INTO #TEMPEXCEPTCALCRPT SELECT CalcRptLabelLP FROM #TEMP1 WHERE Rownum=@RNUM+1 and CalcRptLabelLP not IN (SELECT CalcRptLabelLP FROM #TEMP1 
		WHERE CONVERT(DATE,SessionDate)=@dateCurr AND Rownum=@RNUM and CalcRptLabelLP is not null) AND CalcRptLabelLP IS NOT NULL AND LessonPlanId=@LessonId
		SET @CLCNT=1
		SET @RPTCNT=(SELECT COUNT(ID) FROM #TEMPEXCEPTCALCRPT)
		WHILE(@RPTCNT>0)
		BEGIN
			SET @CalcRpt=(SELECT CalcRptLabelLP FROM #TEMPEXCEPTCALCRPT WHERE ID=@CLCNT)
			SET @PScore=(SELECT TOP 1 Score FROM  #TEMP1 WHERE Rownum=@RNUM AND LessonPlanId=@LessonId AND Score IS NOT NULL)
			SET @PDummy=(SELECT TOP 1 DummyScore FROM  #TEMP1 WHERE Rownum=@RNUM AND LessonPlanId=@LessonId AND DummyScore IS NOT NULL)
			UPDATE #TEMP1 SET Score1=Score, Score2=DummyScore, PreScore=@PScore, PreDummy=@PDummy WHERE Rownum=@RNUM+1 AND LessonPlanId=@LessonId AND CalcRptLabelLP=@CalcRpt

			SET @CLCNT=@CLCNT+1
			SET @RPTCNT=@RPTCNT-1
		END
		DROP TABLE #TEMPEXCEPTCALCRPT

		SET @CNT=@CNT+1
		SET @EVNTCNT=@EVNTCNT-1
	END
	DROP TABLE #TEMPSCORE

	-------------------------UPDATE IOAPerc WITH NORMALUSER AND IOA USER NAME------------------------------------
	IF (@IncludeIOA='true' AND @SetId = -1)
	BEGIN
		CREATE TABLE #TEMPIOA (ID INT NOT NULL PRIMARY KEY IDENTITY(1,1), IOAPerc VARCHAR(50), StdtSessionHdrId INT)
		INSERT INTO #TEMPIOA SELECT IOAPerc, StdtSessionHdr FROM #TEMP1 WHERE IOAPerc IS NOT NULL ORDER BY LessonPlanId, StdtSessionHdr

		SET @CNT=1
		SET @IOACNT=(SELECT COUNT(ID) FROM #TEMPIOA)
		WHILE(@IOACNT>0)
		BEGIN
			SET @HdrId =(SELECT StdtSessionHdrId FROM #TEMPIOA WHERE ID=@CNT)
			SET @IOAPer =(SELECT IOAPerc FROM #TEMPIOA WHERE ID=@CNT)

			UPDATE #TEMP1 SET IOAPerc=@IOAPer+' '+ (SELECT RTRIM(LTRIM(UPPER(US.UserInitial))) AS IOALUser FROM StdtSessionHdr HDR INNER JOIN [USER] US ON HDR.IOAUserId = US.UserId 
				WHERE StdtSessionHdrId=@HdrId and IOAInd='N' AND LessonPlanId=@LessonId AND StudentId=@StudentId)+'/'+(SELECT RTRIM(LTRIM(UPPER(US.UserInitial))) AS NormalLUser 
				FROM StdtSessionHdr HDR INNER JOIN [USER] US ON HDR.IOAUserId = US.UserId WHERE IOASessionHdrId=@HdrId and IOAInd='Y' AND LessonPlanId=@LessonId 
				AND StudentId=@StudentId) WHERE StdtSessionHdr=@HdrId AND LessonPlanId=@LessonId 
			IF ((SELECT Score FROM #TEMP1 WHERE StdtSessionHdr=@HdrId AND LessonPlanId=@LessonId AND scoreid=(SELECT TOP (1) Scoreid FROM #TEMP1 WHERE StdtSessionHdr=@HdrId 
				AND LessonPlanId=@LessonId )) IS NOT NULL OR (SELECT DummyScore FROM #TEMP1 WHERE StdtSessionHdr=@HdrId AND LessonPlanId=@LessonId and scoreid=(SELECT TOP (1) 
				Scoreid FROM #TEMP1 WHERE StdtSessionHdr=@HdrId AND LessonPlanId=@LessonId)) IS NOT NULL)
				Update #TEMP1 SET IOAPerc=NULL WHERE StdtSessionHdr=@HdrId AND LessonPlanId=@LessonId AND scoreid NOT IN (SELECT TOP (1) Scoreid FROM #TEMP1 WHERE 
					StdtSessionHdr=@HdrId AND LessonPlanId=@LessonId)

			SET @CNT=@CNT+1
			SET @IOACNT=@IOACNT-1
		END
		DROP TABLE #TEMPIOA
	END
	ELSE
		Update #TEMP1 SET IOAPerc=NULL
	----------------------------------------UPDATE MaxScore and MaxDummyScore-------------------------------------------------
	DECLARE @MaxScore FLOAT, @MaxDummyScore FLOAT
	SET @MaxScore=(SELECT MAX(Score) FROM #TEMP1 WHERE LessonPlanId=@LessonId)
	SET @MaxDummyScore=(SELECT MAX(DummyScore) FROM #TEMP1 WHERE LessonPlanId=@LessonId)
	IF (@MaxScore IS NOT NULL OR @MaxDummyScore IS NOT NULL)
		UPDATE #TEMP1 SET MaxScore=@MaxScore, MaxDummyScore=@MaxDummyScore WHERE LessonPlanId=@LessonId AND CalcType<>'Event'
	SET @CNT=@CNT+1
	SET @LCount=@LCount-1

---------------------------------------------END---------------------------------------------------

--update student Name

Update #TEMP1 set StudentName=(Select StudentlName+', '+StudentfName from Student where studentid=@StudentId)


    SELECT SessionDate,Rownum,CalcType,Score,IOAPerc,ArrowNote,EventType,EventName,EvntTs,EndTime,Comment
	,CalcRptLabelLP,Trend,DummyScore,LeftYaxis,RightYAxis,NonPercntCount,PercntCount,ColName,RptLabel,Color,Shape,Score1,Score2,
	PreScore,PreDummy,MaxScore,MaxDummyScore,LessonPlanId,LessonPlanName,StudentName,CType,(SELECT TOP 1 ('Tx: ' + (SELECT LookupName FROM LookUp WHERE LookupId= [TeachingProcId]) + ';' + (SELECT LookupName FROM LookUp WHERE LookupId= [PromptTypeId])) Treatment FROM DSTempHdr  HDR
WHERE LessonPlanId=#TEMP1.LessonPlanId AND StudentId=@StudentId
AND StatusId IN ((SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Approved'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Expired'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Deleted'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Inactive'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Maintenance'))
ORDER BY DSTempHdrId DESC) Treatment
,(SELECT TOP 1 'Correct Response: '+StudCorrRespDef FROM DSTempHdr WHERE LessonPlanId=#TEMP1.LessonPlanId AND StudentId=@StudentId AND StudCorrRespDef<>'' AND
 StatusId IN ((SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Approved'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Expired'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Deleted'),
(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Inactive'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Maintenance'))
ORDER BY DSTempHdrId DESC) Deftn FROM #TEMP1 ORDER BY CalcType,CalcRptLabelLP,Rownum,Scoreid 
	
END
GO
