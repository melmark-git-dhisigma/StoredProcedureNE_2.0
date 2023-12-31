USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[SessionScore_Calculation_Backup]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[SessionScore_Calculation_Backup]

	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	BEGIN TRY
	BEGIN TRANSACTION	

	DECLARE @Cnt INT,
	@msg varchar(100),
	@LoadDate datetime,
	@return_value INT 
	
	EXEC @return_value=[dbo].[SessionScore_Calculation_Set]
	SET @LoadDate=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	DELETE FROM  [dbo].[StdtAggScores] WHERE CONVERT(DATE,AggredatedDate) >= @LoadDate
	-- TO INSERT DATA TO [dbo].[StdtAggScores] TABLE FROM [dbo].[StdtSessColScore]
	INSERT INTO [StdtAggScores](SchoolId
	,StudentId
	,DSTempSetColCalcId
	,AggredatedDate
	,LessonPlanId
	,CalcType
	,Score
	,ClassId
	,ClassType
	,ColRptLabelLP) 
	SELECT SchoolId
	,StudentId
	,DSTempSetColCalcId
	,ReportPeriod.PeriodDate
	,LessonPlanId
	,CalcType
	,CASE WHEN CalcType = 'Total Duration' OR CalcType = 'Frequency' OR CalcType='Total Correct' 
	OR CalcType='Total Incorrect'
	THEN  (SELECT SUM(sc.Score) FROM StdtSessColScore  sc
	INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
	AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
	AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0) ELSE 
	(SELECT AVG(sc.Score) FROM StdtSessColScore  sc
	INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
	AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
	AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0) END AS Score 
	,StdtClassId
	,CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType 
	,(CONVERT(VARCHAR(50),StdCalcs.LessonPlanId)+'-'+(SELECT CASE WHEN StdCalcs.CalcRptLabel='' OR StdCalcs.CalcRptLabel IS NULL THEN StdCalcs.CalcType ELSE StdCalcs.CalcRptLabel
 END )+'-'+(SELECT ColName FROM DSTempSetCol WHERE DSTempSetColId= (SELECT DSTempSetColId FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=StdCalcs.DsTempSetColCalcId))
 +'-'+CONVERT(VARCHAR(50),(SELECT COUNT(*) FROM DSTempPrompt WHERE DSTempHdrId= (SELECT [DSTempHdrId] FROM [dbo].[DSTempSetCol] WHERE [DSTempSetColId]=(SELECT 
 [DSTempSetColId] FROM [dbo].[DSTempSetColCalc] WHERE [DSTempSetColCalcId]=StdCalcs.DsTempSetColCalcId)))))
	 FROM (
	SELECT  
	sc.SchoolId
	,sc.StudentId
	,sc.DSTempSetColCalcId
	,dcal.CalcType 
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd
	,dcal.CalcRptLabel	
	FROM StdtSessColScore  sc
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId
	JOIN StdtSessionHdr hdr 
	ON hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	JOIN Class Cls ON Cls.ClassId=hdr.StdtClassId
	WHERE hdr.IOAInd='N' AND hdr.SessMissTrailStus ='N' AND hdr.SessionStatusCd='S'
	GROUP BY sc.SchoolId
	,sc.StudentId
	,sc.DSTempSetColCalcId
	,dcal.CalcType
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd
	,dcal.CalcRptLabel
	 ) AS StdCalcs
	,ReportPeriod
	WHERE CONVERT(DATE,PeriodDate) BETWEEN (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) AND CONVERT(DATE,GETDATE())
	GROUP BY StdCalcs.SchoolId
	,StdCalcs.StudentId
	,StdCalcs.LessonPlanId
	,StdCalcs.DSTempSetColCalcId
	,ReportPeriod.PeriodDate
	,StdCalcs.CalcType
	,StdCalcs.StdtClassId 
	,StdCalcs.ResidenceInd 
	,StdCalcs.CalcRptLabel


	UPDATE [dbo].[StdtAggScores] SET 
    [dbo].[StdtAggScores].Score = UPDATETBL.Score
FROM
    [dbo].[StdtAggScores]
INNER JOIN
(SELECT SchoolId
	,StudentId
	,DSTempSetColCalcId
	,CreatedOn
	,ModifiedOn
	,LessonPlanId
	,CalcType
	,CASE WHEN CalcType = 'Total Duration' OR CalcType = 'Frequency' OR CalcType='Total Correct' 
	OR CalcType='Total Incorrect'
	THEN  (SELECT SUM(sc.Score) FROM StdtSessColScore  sc
	INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
	AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId 
	AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,StdCalcs.CreatedOn)) ELSE 
	(SELECT AVG(sc.Score) FROM StdtSessColScore  sc
	INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
	AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId 
	AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,StdCalcs.CreatedOn)) END AS Score 
	,StdtClassId
	,CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType  FROM (
	SELECT  
	sc.SchoolId
	,sc.StudentId
	,sc.DSTempSetColCalcId
	,dcal.CalcType 
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd	
	,hdr.CreatedOn
	,hdr.IsUpdate
	,hdr.ModifiedOn
	FROM StdtSessColScore  sc
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId
	JOIN StdtSessionHdr hdr 
	ON hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	JOIN Class Cls ON Cls.ClassId=hdr.StdtClassId
	WHERE hdr.IOAInd='N' AND hdr.SessMissTrailStus ='N' AND hdr.SessionStatusCd='S'
	AND hdr.IsUpdate ='true'
	GROUP BY sc.SchoolId
	,sc.StudentId
	,sc.DSTempSetColCalcId
	,dcal.CalcType
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd
	,hdr.CreatedOn
	,hdr.IsUpdate
	,hdr.ModifiedOn
	 ) AS StdCalcs	
	WHERE CONVERT(DATE,StdCalcs.ModifiedOn) BETWEEN (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	AND CONVERT(DATE,GETDATE())	
	AND StdCalcs.IsUpdate ='true' 
	GROUP BY StdCalcs.SchoolId
	,StdCalcs.StudentId
	,StdCalcs.LessonPlanId
	,StdCalcs.DSTempSetColCalcId
	,StdCalcs.CreatedOn
	,StdCalcs.CalcType
	,StdCalcs.StdtClassId 
	,StdCalcs.ResidenceInd
	,StdCalcs.ModifiedOn ) UPDATETBL
	ON
    StdtAggScores.SchoolId = UPDATETBL.SchoolId AND StdtAggScores.StudentId = UPDATETBL.StudentId AND StdtAggScores.DsTempSetColCalcId = UPDATETBL.DSTempSetColCalcId 
	AND CONVERT(DATE,StdtAggScores.AggredatedDate) = CONVERT(DATE,UPDATETBL.CreatedOn) AND StdtAggScores.LessonPlanId = UPDATETBL.LessonPlanId 
	AND StdtAggScores.CalcType = UPDATETBL.CalcType AND StdtAggScores.ClassId = UPDATETBL.StdtClassId


	-----------------------------------------/////////////// Events Insertion Start///////////////////////------------------------------

	----TO INSERT MAJOR,MINOR AND MEDICATION EVENTS (Including Lesson Plan) TO [dbo].[StdtAggScores] TABLE
	--INSERT INTO [StdtAggScores](SchoolId
	--,StudentId
	--,DsTempSetColCalcId
	--,LessonPlanId
	--,CalcType
	--,AggredatedDate
	--,StdtSessEventId
	--,ClassId
	--,ClassType)  
	--SELECT EVNT.SchoolId
	--,EVNT.StudentId
	--,SCR.DsTempSetColCalcId
	--,EVNT.LessonPlanId
	--,SCR.CalcType
	--,EVNT.TimeStampForReport
	--,EVNT.StdtSessEventId
	--,SCR.ClassId
	--,SCR.ClassType FROM [dbo].[StdtSessEvent] EVNT JOIN [dbo].[StdtAggScores] SCR 
	--ON EVNT.LessonPlanId=SCR.LessonPlanId  
	--WHERE CONVERT(DATE,EVNT.EvntTs)=CONVERT(DATE,SCR.AggredatedDate) AND EVNT.StudentId=SCR.StudentId AND EVNT.SchoolId=SCR.SchoolId 
	--AND CONVERT(DATE,EVNT.EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EVNT.EvntTs)<=CONVERT(DATE,GETDATE())
	--AND EVNT.EventType='EV' 
	

	----TO INSERT ARROW NOTES (Including Lesson Plan) TO [dbo].[StdtAggScores] TABLE
	
	--CREATE TABLE #ARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),SchoolId int,StudentId int,LessonPlanId int,
	--TimeStampForReport datetime,EventName VARCHAR(500));
	--INSERT INTO #ARROW
	--SELECT LPARROW.SchoolId,LPARROW.StudentId,LPARROW.LessonPlanId,LPARROW.EventTs,
	--(SELECT STUFF((SELECT ','+CONVERT(VARCHAR, EventName)  FROM (SELECT EventName  FROM StdtSessEvent 
	--WHERE SchoolId=LPARROW.SchoolId AND StudentId=LPARROW.StudentId AND LessonPlanId=LPARROW.LessonPlanId AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE()) AND EventType='EV' 
	--AND StdtSessEventType='Arrow notes') EName FOR XML PATH('')),1,1,'')) EName FROM 
	--(SELECT SchoolId,StudentId,LessonPlanId,CONVERT(DATE,EvntTs) EventTs FROM [dbo].[StdtSessEvent] WHERE EventType='EV' 
	--AND StdtSessEventType='Arrow notes'
	--AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE())) AS LPARROW
	--GROUP BY LPARROW.SchoolId,LPARROW.StudentId,LPARROW.LessonPlanId,LPARROW.EventTs

	
	-- SET @Cnt=1
	-- WHILE(@Cnt<=(SELECT COUNT(*) FROM #ARROW)) 
	-- BEGIN
	-- UPDATE [dbo].[StdtAggScores] 
	-- SET EventName=(SELECT EventName FROM #ARROW WHERE ID=@Cnt)+'------------>' 
	-- WHERE SchoolId=(SELECT SchoolId FROM #ARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #ARROW WHERE ID=@Cnt) 
	-- AND LessonPlanId=(SELECT LessonPlanId FROM #ARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #ARROW WHERE ID=@Cnt))
	-- AND StdtSessEventId IS NULL
	-- SET @Cnt=@Cnt+1
	-- END

	-- DROP TABLE #ARROW	
	




	----TO INSERT MAJOR,MINOR AND MEDICATION EVENTS (Lesson Plan=0) TO [dbo].[StdtAggScores] TABLE
	--INSERT INTO [StdtAggScores](SchoolId
	--,StudentId
	--,DsTempSetColCalcId
	--,LessonPlanId
	--,CalcType
	--,AggredatedDate
	--,StdtSessEventId
	--,ClassId
	--,ClassType)
	--SELECT SCR.SchoolId
	--,SCR.StudentId
	--,SCR.DsTempSetColCalcId
	--,SCR.LessonPlanId
	--,SCR.CalcType
	--,EVNT.TimeStampForReport
	--,EVNT.StdtSessEventId
	--,SCR.ClassId
	--,SCR.ClassType FROM StdtSessEvent EVNT JOIN StdtAggScores SCR 
	--ON EVNT.StudentId=SCR.StudentId 
	--WHERE SCR.AggredatedDate=EVNT.EvntTs
	--AND EVNT.LessonPlanId=0 AND EVNT.SchoolId=SCR.SchoolId AND EVNT.EventType='EV' 
	--AND CONVERT(DATE,EVNT.EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EVNT.EvntTs)<=CONVERT(DATE,GETDATE())
	--AND SCR.LessonPlanId IS NOT NULL 	
	--GROUP BY 
	--SCR.SchoolId
	--,SCR.StudentId
	--,SCR.DsTempSetColCalcId
	--,SCR.LessonPlanId
	--,SCR.CalcType
	--,EVNT.TimeStampForReport
	--,EVNT.StdtSessEventId
	--,SCR.ClassId
	--,SCR.ClassType

	----TO INSERT ARROW NOTES EVENTS (Lesson Plan=0) TO [dbo].[StdtAggScores] TABLE
	
	--CREATE TABLE #LPARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),SchoolId int,StudentId int,LessonPlanId int,
	--TimeStampForReport datetime,EventName VARCHAR(500));
	--INSERT INTO #LPARROW
	--SELECT LPARROW.SchoolId,LPARROW.StudentId,StdtAggScores.LessonPlanId,LPARROW.EventTs,
	--(SELECT STUFF((SELECT ','+CONVERT(VARCHAR, EventName)  FROM (SELECT EventName  FROM StdtSessEvent 
	--WHERE SchoolId=LPARROW.SchoolId AND StudentId=LPARROW.StudentId AND LessonPlanId=0 AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE()) AND EventType='EV' 
	--AND StdtSessEventType='Arrow notes') EName FOR XML PATH('')),1,1,'')) EName FROM 
	--(SELECT SchoolId,StudentId,CONVERT(DATE,EvntTs) EventTs FROM [dbo].[StdtSessEvent] WHERE EventType='EV' 
	--AND StdtSessEventType='Arrow notes'
	--AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE())
	--AND LessonPlanId=0) AS LPARROW
	--INNER JOIN StdtAggScores ON StdtAggScores.SchoolId=LPARROW.SchoolId
	--AND	LPARROW.StudentId=StdtAggScores.StudentId 
	--AND CONVERT(DATE,StdtAggScores.AggredatedDate)=CONVERT(DATE,LPARROW.EventTs)
	--GROUP BY LPARROW.SchoolId,LPARROW.StudentId,StdtAggScores.LessonPlanId,LPARROW.EventTs
	
	-- SET @Cnt=1
	-- WHILE(@Cnt<=(SELECT COUNT(*) FROM #LPARROW)) 
	-- BEGIN
	-- SET @Label=( SELECT TOP 1 ISNULL(EventName,'###') FROM [dbo].[StdtAggScores] WHERE SchoolId=(SELECT SchoolId FROM #LPARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #LPARROW WHERE ID=@Cnt) 
	-- AND LessonPlanId=(SELECT LessonPlanId FROM #LPARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #LPARROW WHERE ID=@Cnt)))

	-- IF (@Label='###')
	-- BEGIN
	-- UPDATE [dbo].[StdtAggScores] 
	-- SET EventName=(SELECT EventName FROM #LPARROW WHERE ID=@Cnt)+'------------>' 
	-- WHERE SchoolId=(SELECT SchoolId FROM #LPARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #LPARROW WHERE ID=@Cnt) 
	-- AND LessonPlanId=(SELECT LessonPlanId FROM #LPARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #LPARROW WHERE ID=@Cnt))
	-- AND StdtSessEventId IS NULL
	-- END
	-- ELSE
	-- BEGIN 
	-- UPDATE [dbo].[StdtAggScores] 
	-- SET EventName=@Label+','+(SELECT EventName FROM #LPARROW WHERE ID=@Cnt)+'------------>' 
	-- WHERE SchoolId=(SELECT SchoolId FROM #LPARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #LPARROW WHERE ID=@Cnt) 
	-- AND LessonPlanId=(SELECT LessonPlanId FROM #LPARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #LPARROW WHERE ID=@Cnt))
	-- AND StdtSessEventId IS NOT NULL
	-- END
	-- SET @Cnt=@Cnt+1
	-- END

	-- DROP TABLE #LPARROW	

	-----------------------------------------/////////////// Events Insertion End ///////////////////////------------------------------
	 
	 --Update Lesson Plan IOA value to [dbo].[StdtAggScores] TABLE		 
	 CREATE TABLE #IOA(ID int PRIMARY KEY IDENTITY(1,1),IOAPerc varchar(50),DSTempSetColCalcId int,SchoolId int,StudentId int,
	 LessonPlanId int,StdtClassId int,CreatedDate date,NormalUsr VARCHAR(100),IOAUsr VARCHAR(100));

	 INSERT INTO #IOA
	 SELECT (SELECT TOP 1 Hdr.IOAPerc 
	 FROM StdtSessionHdr Hdr 
	 INNER JOIN StdtSessColScore CScr 
	 ON Hdr.StdtSessionHdrId=CScr.StdtSessionHdrId 
	 WHERE Hdr.IOAInd='Y'
	 AND CONVERT(DATE,StartTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	 AND CScr.DSTempSetColCalcId =DATA.DSTempSetColCalcId 
	 AND CScr.SchoolId=DATA.SchoolId 
	 AND CScr.StudentId=DATA.StudentId
	 AND Hdr.LessonPlanId=DATA.LessonPlanId 
	 AND Hdr.StdtClassId=DATA.StdtClassId 
	 AND CONVERT(DATE,StartTs)=DATA.STARTTS ORDER BY Hdr.StdtSessionHdrId DESC)IOAPerc
	 ,DATA.DSTempSetColCalcId
	 ,DATA.SchoolId
	 ,DATA.StudentId
	 ,DATA.LessonPlanId
	 ,DATA.StdtClassId
	 ,DATA.STARTTS 
	 ,DATA.NormalUsr
	 ,DATA.IOAUsr
	 FROM
	 (SELECT Hdr.IOAPerc
	 ,CScr.DSTempSetColCalcId
	 ,CScr.SchoolId
	 ,CScr.StudentId
	 ,Hdr.LessonPlanId
	 ,Hdr.StdtClassId
	 ,CONVERT(DATE,StartTs) STARTTS
	 ,(SELECT UserInitial FROM [User] WHERE UserId=(SELECT CreatedBy FROM StdtSessionHdr WHERE StdtSessionHdrId= Hdr.IOASessionHdrId)) NormalUsr
	 , (SELECT UserInitial FROM [User] WHERE UserId=Hdr.IOAUserId) IOAUsr
	 FROM StdtSessionHdr Hdr 
	 INNER JOIN StdtSessColScore CScr 
	 ON Hdr.StdtSessionHdrId=CScr.StdtSessionHdrId 
	 WHERE Hdr.IOAInd='Y'
	 AND CONVERT(DATE,StartTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])) AS DATA
	 
	 


	 SET @Cnt=1
	 WHILE(@Cnt<=(SELECT COUNT(*) FROM #IOA)) 
	 BEGIN
	 UPDATE [dbo].[StdtAggScores] 
	 SET IOAPerc='IOA '+(SELECT IOAPerc FROM #IOA WHERE ID=@Cnt)+' % ' +(SELECT NormalUsr FROM #IOA WHERE ID=@Cnt )+'/'+(SELECT IOAUsr FROM #IOA WHERE ID=@Cnt )
	 WHERE DsTempSetColCalcId=(SELECT DSTempSetColCalcId FROM #IOA WHERE ID=@Cnt) 
	 AND SchoolId=(SELECT SchoolId FROM #IOA WHERE ID=@Cnt) 
	 AND StudentId=(SELECT StudentId FROM #IOA WHERE ID=@Cnt) 
	 AND LessonPlanId=(SELECT LessonPlanId FROM #IOA WHERE ID=@Cnt)
	 AND ClassId=(SELECT StdtClassId FROM #IOA WHERE ID=@Cnt)
	 AND CONVERT(DATE,AggredatedDate)=(SELECT CreatedDate FROM #IOA WHERE ID=@Cnt)
	 SET @Cnt=@Cnt+1
	 END

	 DROP TABLE #IOA	
	

	--INSERT BEHAVIOR DETAILS TO [dbo].[StdtAggScores] TABLE

	INSERT INTO [StdtAggScores](SchoolId
	,StudentId	
	,ClassId
	,MeasurementId
	,AggredatedDate
	,Frequency
	,Duration
	,ClassType
	,Rate)
	SELECT BEHAVIOR.SchoolId
	,BEHAVIOR.StudentId
	,BEHAVIOR.ClassId
	,BEHAVIOR.MeasurementId
	,BEHAVIOR.PeriodDate
	--,CASE WHEN BEHAVIOR.Frequncy=0 THEN NULL ELSE BEHAVIOR.Frequncy END AS Frequncy
	,BEHAVIOR.Frequncy
	,BEHAVIOR.DurationMin
	,BEHAVIOR.ClassType
	,CASE WHEN BEHAVIOR.Frequncy IS NOT NULL AND BEHAVIOR.Frequncy<>0
	THEN CASE WHEN BEHAVIOR.PartialInterval='True' 
	THEN CONVERT(float,BEHAVIOR.Frequncy)/(CONVERT(float,(BEHAVIOR.Period*BEHAVIOR.NumOfTimes))) --/60
	ELSE CONVERT(float,BEHAVIOR.Frequncy)/((CONVERT(float,(
	SELECT DATEDIFF(HH,CONVERT(DATETIME,StartTime),CONVERT(DATETIME,EndTime)) 
	FROM SchoolCal
	WHERE Weekday=(SELECT DATENAME(dw,BEHAVIOR.PeriodDate)) 
	AND SchoolCal.ResidenceInd=BEHAVIOR.ResidenceInd 
	AND SchoolCal.SchoolId=BEHAVIOR.SchoolId) ))*60)
	END END AS Rate 
	FROM (
	SELECT ALLBEHAVIOR.ResidenceInd
	,ALLBEHAVIOR.PartialInterval
	,ALLBEHAVIOR.Period
	,ALLBEHAVIOR.NumOfTimes
	,ALLBEHAVIOR.SchoolId
	,ALLBEHAVIOR.StudentId
	,ALLBEHAVIOR.ClassId
	,ALLBEHAVIOR.MeasurementId
	,ALLBEHAVIOR.PeriodDate,
	CASE WHEN (ALLBEHAVIOR.Frequency=1 AND ALLBEHAVIOR.Duration=1) THEN (SELECT COUNT(Duration) + CASE WHEN COUNT(Duration)>0 THEN 
	ISNULL(SUM(FrequencyCount),0) ELSE SUM(FrequencyCount) END
	FROM Behaviour 
	WHERE CONVERT(DATE,TimeOfEvent)=CONVERT(DATE,ALLBEHAVIOR.PeriodDate) 
	AND  MeasurementId=ALLBEHAVIOR.MeasurementId )  
	ELSE CASE WHEN (ALLBEHAVIOR.Duration=1)
	THEN (SELECT COUNT(Duration) 
	FROM Behaviour 
	WHERE CONVERT(DATE,TimeOfEvent)=CONVERT(DATE,ALLBEHAVIOR.PeriodDate) 
	AND  MeasurementId=ALLBEHAVIOR.MeasurementId )  ELSE (SELECT SUM(FrequencyCount) 
	FROM Behaviour 
	WHERE CONVERT(DATE,TimeOfEvent)=CONVERT(DATE,ALLBEHAVIOR.PeriodDate) 
	AND  MeasurementId=ALLBEHAVIOR.MeasurementId )END END AS Frequncy
	,(SELECT (SUM(CONVERT(float,Duration)))/60 
	FROM Behaviour 
	WHERE CONVERT(DATE,TimeOfEvent)=CONVERT(DATE,ALLBEHAVIOR.PeriodDate) 
	AND  MeasurementId=ALLBEHAVIOR.MeasurementId) AS DurationMin
    ,CASE WHEN ALLBEHAVIOR.ResidenceInd=1 
	THEN 'Residence' 
	ELSE 'Day' END ClassType
	FROM (SELECT Behaviordata.SchoolId
	,Behaviordata.StudentId
	,Behaviordata.ClassId
	,Behaviordata.MeasurementId
	,ReportPeriod.PeriodDate
	,Behaviordata.PartialInterval
	,Behaviordata.ResidenceInd
	,Behaviordata.Period
	,Behaviordata.NumOfTimes
	,Behaviordata.Frequency
	,Behaviordata.Duration	
	FROM
	(SELECT BDS.SchoolId
	,BDS.StudentId
	,BDS.ClassId
	,BDS.MeasurementId
	,BDS.PartialInterval
	,Cls.ResidenceInd
	,BDS.Period,BDS.NumOfTimes
	,BDS.Frequency
	,BDS.Duration 
	FROM Behaviour BR 
	INNER JOIN BehaviourDetails BDS 
	ON BR.MeasurementId=BDS.MeasurementId 
	INNER JOIN Class Cls 
	ON Cls.ClassId=BDS.ClassId 
	GROUP BY BDS.StudentId,BDS.SchoolId,BDS.ClassId
	,CONVERT(DATE,BR.CreatedOn)
	,BDS.MeasurementId
	,BDS.PartialInterval
	,Cls.ResidenceInd
	,BDS.Period
	,BDS.NumOfTimes
	,BDS.Frequency
	,BDS.Duration) AS Behaviordata,ReportPeriod
	WHERE CONVERT(DATE,PeriodDate) 
	BETWEEN (SELECT CONVERT(DATE,Last_run_date) 
	FROM [dbo].[StdtLoadDates]) 
	AND CONVERT(DATE,GETDATE()) AND (Period <>0 OR Period IS NULL)) AS ALLBEHAVIOR) BEHAVIOR


	-----------------------------------------/////////////// Events Insertion Start///////////////////////------------------------------

	
	----TO INSERT MAJOR AND MINOR EVENTS (Including Behavior) TO [dbo].[StdtAggScores] TABLE
	--INSERT INTO [StdtAggScores](SchoolId
	--,StudentId
	--,DsTempSetColCalcId
	--,MeasurementId
	--,AggredatedDate
	--,StdtSessEventId
	--,ClassId
	--,ClassType)  
	--SELECT EVNT.SchoolId
	--,EVNT.StudentId
	--,SCR.DsTempSetColCalcId
	--,EVNT.MeasurementId
	--,EVNT.TimeStampForReport
	--,EVNT.StdtSessEventId
	--,SCR.ClassId
	--,SCR.ClassType FROM [dbo].[StdtSessEvent] EVNT JOIN [dbo].[StdtAggScores] SCR 
	--ON EVNT.MeasurementId=SCR.MeasurementId  
	--WHERE EVNT.EvntTs=SCR.AggredatedDate AND EVNT.StudentId=SCR.StudentId AND EVNT.SchoolId=SCR.SchoolId 
	--AND CONVERT(DATE,EVNT.EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EVNT.EvntTs)<=CONVERT(DATE,GETDATE())
	--AND EVNT.EventType='EV'


	----TO INSERT ARROW NOTES (Including Behavior) TO [dbo].[StdtAggScores] TABLE		 
	--CREATE TABLE #BEHAVIORARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),SchoolId int,StudentId int,MeasurementId int,
	--TimeStampForReport datetime,EventName VARCHAR(500));
	--INSERT INTO #BEHAVIORARROW
	--SELECT LPARROW.SchoolId,LPARROW.StudentId,LPARROW.MeasurementId,LPARROW.EventTs,
	--(SELECT STUFF((SELECT ','+CONVERT(VARCHAR, EventName)  FROM (SELECT EventName  FROM StdtSessEvent 
	--WHERE SchoolId=LPARROW.SchoolId AND StudentId=LPARROW.StudentId AND MeasurementId=LPARROW.MeasurementId AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE()) AND EventType='EV' 
	--AND StdtSessEventType='Arrow notes') EName FOR XML PATH('')),1,1,'')) EName FROM 
	--(SELECT SchoolId,StudentId,MeasurementId,CONVERT(DATE,EvntTs) EventTs FROM [dbo].[StdtSessEvent] WHERE EventType='EV' 
	--AND StdtSessEventType='Arrow notes'
	--AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE())) AS LPARROW
	--GROUP BY LPARROW.SchoolId,LPARROW.StudentId,LPARROW.MeasurementId,LPARROW.EventTs
	
	-- SET @Cnt=1
	-- WHILE(@Cnt<=(SELECT COUNT(*) FROM #BEHAVIORARROW)) 
	-- BEGIN
	-- UPDATE [dbo].[StdtAggScores] 
	-- SET EventName=(SELECT EventName FROM #BEHAVIORARROW WHERE ID=@Cnt)+'------------>' 
	-- WHERE SchoolId=(SELECT SchoolId FROM #BEHAVIORARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #BEHAVIORARROW WHERE ID=@Cnt) 
	-- AND MeasurementId=(SELECT MeasurementId FROM #BEHAVIORARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #BEHAVIORARROW WHERE ID=@Cnt))
	-- AND StdtSessEventId IS NULL
	-- SET @Cnt=@Cnt+1
	-- END

	-- DROP TABLE #BEHAVIORARROW	




	----TO INSERT MAJOR AND MINOR EVENTS (Behavior=0) TO [dbo].[StdtAggScores] TABLE
	--INSERT INTO [StdtAggScores](SchoolId
	--,StudentId
	--,DsTempSetColCalcId
	--,MeasurementId
	--,AggredatedDate
	--,StdtSessEventId
	--,ClassId
	--,ClassType)
	--SELECT SCR.SchoolId
	--,SCR.StudentId
	--,SCR.DsTempSetColCalcId
	--,SCR.MeasurementId
	--,EVNT.TimeStampForReport
	--,EVNT.StdtSessEventId
	--,SCR.ClassId
	--,SCR.ClassType FROM StdtSessEvent EVNT JOIN StdtAggScores SCR 
	--ON EVNT.StudentId=SCR.StudentId 
	--WHERE SCR.AggredatedDate=EVNT.EvntTs
	--AND EVNT.MeasurementId=0 AND EVNT.SchoolId=SCR.SchoolId AND EVNT.EventType='EV' 
	--AND CONVERT(DATE,EVNT.EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EVNT.EvntTs)<=CONVERT(DATE,GETDATE())

	
	--	--TO INSERT ARROW NOTES EVENTS (Behavior=0) TO [dbo].[StdtAggScores] TABLE	
	--CREATE TABLE #BRARROW(ID int PRIMARY KEY NOT NULL IDENTITY(1,1),SchoolId int,StudentId int,MeasurementId int,
	--TimeStampForReport datetime,EventName VARCHAR(500));
	--INSERT INTO #BRARROW
	--SELECT LPARROW.SchoolId,LPARROW.StudentId,StdtAggScores.MeasurementId,LPARROW.EventTs,
	--(SELECT STUFF((SELECT ','+CONVERT(VARCHAR, EventName)  FROM (SELECT EventName  FROM StdtSessEvent 
	--WHERE SchoolId=LPARROW.SchoolId AND StudentId=LPARROW.StudentId AND MeasurementId=0 AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE()) AND EventType='EV' 
	--AND StdtSessEventType='Arrow notes') EName FOR XML PATH('')),1,1,'')) EName FROM 
	--(SELECT SchoolId,StudentId,CONVERT(DATE,EvntTs) EventTs FROM [dbo].[StdtSessEvent] WHERE EventType='EV' 
	--AND StdtSessEventType='Arrow notes'
	--AND CONVERT(DATE,EvntTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
	--AND CONVERT(DATE,EvntTs)<=CONVERT(DATE,GETDATE())
	--AND LessonPlanId=0) AS LPARROW
	--INNER JOIN StdtAggScores ON StdtAggScores.SchoolId=LPARROW.SchoolId
	--AND	LPARROW.StudentId=StdtAggScores.StudentId 
	--AND CONVERT(DATE,StdtAggScores.AggredatedDate)=CONVERT(DATE,LPARROW.EventTs)
	--AND StdtAggScores.MeasurementId IS NOT NULL
	--GROUP BY LPARROW.SchoolId,LPARROW.StudentId,StdtAggScores.MeasurementId,LPARROW.EventTs
	
	-- SET @Cnt=1
	-- WHILE(@Cnt<=(SELECT COUNT(*) FROM #BRARROW)) 
	-- BEGIN
	-- SET @Label=( SELECT TOP 1 ISNULL(EventName,'###') FROM [dbo].[StdtAggScores] WHERE SchoolId=(SELECT SchoolId FROM #BRARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #BRARROW WHERE ID=@Cnt) 
	-- AND MeasurementId=(SELECT MeasurementId  FROM #BRARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #BRARROW WHERE ID=@Cnt)))

	-- IF (@Label='###')
	-- BEGIN
	-- UPDATE [dbo].[StdtAggScores] 
	-- SET EventName=(SELECT EventName FROM #BRARROW WHERE ID=@Cnt)+'------------>' 
	-- WHERE SchoolId=(SELECT SchoolId FROM #BRARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #BRARROW WHERE ID=@Cnt) 
	-- AND MeasurementId=(SELECT MeasurementId FROM #BRARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #BRARROW WHERE ID=@Cnt))
	-- AND StdtSessEventId IS NULL
	-- END
	-- ELSE
	-- BEGIN 
	-- UPDATE [dbo].[StdtAggScores] 
	-- SET EventName=@Label+','+(SELECT EventName FROM #BRARROW WHERE ID=@Cnt)+'------------>' 
	-- WHERE SchoolId=(SELECT SchoolId FROM #BRARROW WHERE ID=@Cnt) 
	-- AND StudentId=(SELECT StudentId FROM #BRARROW WHERE ID=@Cnt) 
	-- AND LessonPlanId=(SELECT LessonPlanId FROM #BRARROW WHERE ID=@Cnt)	 
	-- AND CONVERT(DATE,AggredatedDate)=CONVERT(DATE,(SELECT TimeStampForReport FROM #BRARROW WHERE ID=@Cnt))
	-- AND StdtSessEventId IS NOT NULL
	-- END
	-- SET @Cnt=@Cnt+1
	-- END

	-- DROP TABLE #BRARROW

	-----------------------------------------/////////////// Events Insertion End///////////////////////------------------------------

        
	-- Update Behavior IOA value to [dbo].[StdtAggScores] TABLE


	CREATE TABLE #TEMP(
	ID int PRIMARY KEY NOT NULL IDENTITY(1,1)
	,IOAFrequency varchar(50)
	,IOADuration varchar(50)
	,SchoolId int
	,StudentId int
	,MeasurementId int
	,DateOfBahavior datetime
	,IOAUser int);
	INSERT INTO #TEMP 
	SELECT CASE WHEN (PARTIAL.Frequncy)>(PARTIALIOA.Frequncy) 
	THEN ROUND(((CONVERT(float,(PARTIALIOA.Frequncy))/CONVERT(float,(PARTIAL.Frequncy)))*100),2) 
	ELSE ROUND(((CONVERT(float,(PARTIAL.Frequncy))/CONVERT(float,(PARTIALIOA.Frequncy)))*100),2) END AS IOAFrequency,
	CASE WHEN (PARTIAL.DurationMin)>(PARTIALIOA.DurationMin) 
	THEN ROUND(((CONVERT(float,(PARTIALIOA.DurationMin))/CONVERT(float,(PARTIAL.DurationMin)))*100),2) 
	ELSE ROUND(((CONVERT(float,(PARTIAL.DurationMin))/CONVERT(float,(PARTIALIOA.DurationMin)))*100),2) END AS IOADuration
	,PARTIAL.SchoolId
	,PARTIAL.StudentId
	,PARTIAL.MeasurementId
	,PARTIAL.Date
	,PARTIALIOA.IOAUser
	FROM
	(
	SELECT CASE WHEN BDS.Frequency='True' AND BDS.Duration='True' 
	THEN COUNT(BHR.Duration)+SUM(BHR.FrequencyCount) ELSE SUM(BHR.FrequencyCount) END AS Frequncy
	,SUM(CONVERT(float,BHR.Duration))/60 AS DurationMin
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	,BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId 
	FROM 
	BehaviourCalc CALC INNER JOIN Behaviour BHR ON CALC.MeasurmentId=BHR.MeasurementId 
	INNER JOIN BehaviourDetails BDS ON BDS.MeasurementId=BHR.MeasurementId 
	WHERE IsPartial=1 AND ObserverId!=IOAUser AND CONVERT(DATE,BHR.CreatedOn)=CONVERT(DATE,CALC.Date) 
	AND CONVERT(TIME,BHR.CreatedOn) BETWEEN CONVERT(TIME,CALC.StartTime) AND CONVERT(TIME,CALC.EndTime) 
	AND CONVERT(DATE,BHR.CreatedOn) >= (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	GROUP BY BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId
	,BDS.Frequency
	,BDS.Duration
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	) PARTIAL
	JOIN 
	(
	SELECT CASE WHEN BDS.Frequency='True' AND BDS.Duration='True' 
	THEN COUNT(BHR.Duration)+SUM(BHR.FrequencyCount) ELSE SUM(BHR.FrequencyCount) END AS Frequncy
	,SUM(CONVERT(float,BHR.Duration))/60 AS DurationMin
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	,BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId
	,IOAUser 
	FROM 
	BehaviourCalc CALC INNER JOIN Behaviour BHR ON CALC.MeasurmentId=BHR.MeasurementId 
	INNER JOIN BehaviourDetails BDS ON BDS.MeasurementId=BHR.MeasurementId 
	WHERE IsPartial=1 AND IOAFlag=1 AND ObserverId=IOAUser AND CONVERT(DATE,BHR.CreatedOn)=CONVERT(DATE,CALC.Date) 
	AND CONVERT(TIME,BHR.CreatedOn) BETWEEN CONVERT(TIME,CALC.StartTime) AND CONVERT(TIME,CALC.EndTime) 
	AND CONVERT(DATE,BHR.CreatedOn) >= (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	GROUP BY BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId
	,BDS.Frequency
	,BDS.Duration
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	,IOAUser
	) PARTIALIOA ON 1=1


	SET @Cnt=1
	WHILE(@Cnt<=(SELECT COUNT(*) FROM #TEMP)) 
	BEGIN
	UPDATE StdtAggScores 
	SET IOAFrequency='IOA '+(SELECT IOAFrequency FROM #TEMP WHERE ID=@Cnt)+' %'
	,IOADuration='IOA '+(SELECT IOADuration FROM #TEMP WHERE ID=@Cnt)+' %'
	,IOAUser=(SELECT IOAUser FROM #TEMP WHERE ID=@Cnt)
	WHERE 
	SchoolId=(SELECT SchoolId FROM #TEMP WHERE ID=@Cnt) 
	AND StudentId=(SELECT StudentId FROM #TEMP WHERE ID=@Cnt)
	AND MeasurementId=(SELECT MeasurementId FROM #TEMP WHERE ID=@Cnt)
	AND AggredatedDate=(SELECT DateOfBahavior FROM #TEMP WHERE ID=@Cnt)
	SET @Cnt=@Cnt+1
	END


	DROP TABLE #TEMP

	CREATE TABLE #TEMP1(ID int PRIMARY KEY NOT NULL IDENTITY(1,1)
	,IOAFrequency varchar(50)
	,IOADuration varchar(50)
	,SchoolId int
	,StudentId int
	,MeasurementId int
	,DateOfBahavior datetime
	,IOAUser int);
	INSERT INTO #TEMP1
	SELECT CASE WHEN (NONPARTIAL.Frequncy)>(NONPARTIALIOA.Frequncy) 
	THEN ROUND(((CONVERT(float,(NONPARTIALIOA.Frequncy))/CONVERT(float,(NONPARTIAL.Frequncy)))*100),2) 
	ELSE ROUND(((CONVERT(float,(NONPARTIAL.Frequncy))/CONVERT(float,(NONPARTIALIOA.Frequncy)))*100),2) END AS IOAFrequency,
	CASE WHEN (NONPARTIAL.DurationMin)>(NONPARTIALIOA.DurationMin) 
	THEN ROUND(((CONVERT(float,(NONPARTIALIOA.DurationMin))/CONVERT(float,(NONPARTIAL.DurationMin)))*100),2) 
	ELSE ROUND(((CONVERT(float,(NONPARTIAL.DurationMin))/CONVERT(float,(NONPARTIALIOA.DurationMin)))*100),2) END AS IOADuration
	,NONPARTIAL.SchoolId
	,NONPARTIAL.StudentId
	,NONPARTIAL.MeasurementId
	,NONPARTIAL.Date
	,NONPARTIALIOA.IOAUser
	FROM
	(
	SELECT CASE WHEN BDS.Frequency='True' AND BDS.Duration='True' 
	THEN COUNT(BHR.Duration) ELSE SUM(BHR.FrequencyCount) END AS Frequncy
	,SUM(CONVERT(float,BHR.Duration))/60 AS DurationMin
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	,BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId 
	FROM 
	BehaviourCalc CALC INNER JOIN Behaviour BHR ON CALC.MeasurmentId=BHR.MeasurementId 
	INNER JOIN BehaviourDetails BDS ON BDS.MeasurementId=BHR.MeasurementId 
	WHERE IsPartial=0 AND ObserverId!=IOAUser AND CONVERT(DATE,BHR.CreatedOn)=CONVERT(DATE,CALC.Date) 
	AND CONVERT(TIME,BHR.CreatedOn) BETWEEN CONVERT(TIME,CALC.StartTime) AND CONVERT(TIME,CALC.EndTime) 
	AND CONVERT(DATE,BHR.CreatedOn) >= (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	GROUP BY BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId
	,BDS.Frequency
	,BDS.Duration
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	) NONPARTIAL
	JOIN 
	(
	SELECT CASE WHEN BDS.Frequency='True' AND BDS.Duration='True' THEN COUNT(BHR.Duration) ELSE SUM(BHR.FrequencyCount) END AS Frequncy
	,SUM(CONVERT(float,BHR.Duration))/60 AS DurationMin
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	,BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId
	,IOAUser 
	FROM 
	BehaviourCalc CALC INNER JOIN Behaviour BHR ON CALC.MeasurmentId=BHR.MeasurementId 
	INNER JOIN BehaviourDetails BDS ON BDS.MeasurementId=BHR.MeasurementId 
	WHERE IsPartial=0 AND IOAFlag=1 AND ObserverId=IOAUser AND CONVERT(DATE,BHR.CreatedOn)=CONVERT(DATE,CALC.Date) 
	AND CONVERT(TIME,BHR.CreatedOn) BETWEEN CONVERT(TIME,CALC.StartTime) AND CONVERT(TIME,CALC.EndTime) 
	AND CONVERT(DATE,BHR.CreatedOn) >= (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	GROUP BY BDS.StudentId
	,BDS.SchoolId
	,BDS.MeasurementId
	,BDS.Frequency
	,BDS.Duration
	,CALC.StartTime
	,CALC.EndTime
	,CALC.Date
	,IOAUser
	) NONPARTIALIOA ON 1=1



	SET @Cnt=1
	WHILE(@Cnt<=(SELECT COUNT(*) FROM #TEMP1)) 
	BEGIN
	UPDATE StdtAggScores 
	SET IOAFrequency='IOA '+(SELECT IOAFrequency FROM #TEMP1 WHERE ID=@Cnt)+' %'
	,IOADuration='IOA '+(SELECT IOADuration FROM #TEMP1 WHERE ID=@Cnt)+' %'
	,IOAUser=(SELECT IOAUser FROM #TEMP1 WHERE ID=@Cnt)
	WHERE SchoolId=(SELECT SchoolId FROM #TEMP1 WHERE ID=@Cnt) 
	AND StudentId=(SELECT StudentId FROM #TEMP1 WHERE ID=@Cnt)
	AND MeasurementId=(SELECT MeasurementId FROM #TEMP1 WHERE ID=@Cnt)
	AND AggredatedDate=(SELECT DateOfBahavior FROM #TEMP1 WHERE ID=@Cnt)
	SET @Cnt=@Cnt+1
	END

	DROP TABLE #TEMP1

	--UPDATE StdtAggScores SET ColRptLabelLP =(CONVERT(VARCHAR(50),LessonPlanId)+'-'+(SELECT CASE WHEN CalcRptLabel='' THEN CalcType ELSE CalcRptLabel
 --END FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=StdtAggScores.DsTempSetColCalcId)+'-'+(SELECT ColName FROM DSTempSetCol 
 --WHERE DSTempSetColId= (SELECT DSTempSetColId FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=StdtAggScores.DsTempSetColCalcId))
 --+'-'+CONVERT(VARCHAR(50),(SELECT COUNT(*) FROM DSTempPrompt WHERE DSTempHdrId= (SELECT [DSTempHdrId] FROM [dbo].[DSTempSetCol] WHERE [DSTempSetColId]=(SELECT 
 --[DSTempSetColId] FROM [dbo].[DSTempSetColCalc] WHERE [DSTempSetColCalcId]=StdtAggScores.DsTempSetColCalcId))))) WHERE ColRptLabelLP IS NULL 
 --AND DsTempSetColCalcId IS NOT NULL


	UPDATE StdtLoadDates SET Last_run_date=GETDATE()

	SET @msg='SUCCESS'
	COMMIT
	END TRY
	BEGIN CATCH
	ROLLBACK
	SET @msg='FAILED'	
	END CATCH
    

	SELECT @msg
END
GO
