USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[BiweeklyExcelView]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[BiweeklyExcelView]
@StartDate datetime,
@ENDDate datetime,
@Studentid int,
@SchoolId int,
@ShowLessonBehavior varchar(5),
@FilterColumn BIT

AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @TempStartDate datetime
	SET @TempStartDate=@StartDate
	DECLARE @TempENDDate datetime
	SET @TempENDDate=@ENDDate
	DECLARE @TempStudentid int
	SET @TempStudentid=@Studentid
	DECLARE @TempSchoolId int
	SET @TempSchoolId=@SchoolId
	DECLARE @TempShowLessonBehavior varchar(5)
	SET @TempShowLessonBehavior=@ShowLessonBehavior


	DECLARE @ColumDisplay BIT
	SET @ColumDisplay = @FilterColumn

	SET @TempENDDate=@TempENDDate+' 23:59:58.998'
	CREATE TABLE #Lesson(ID	int PRIMARY KEY NOT NULL IDENTITY(1,1)
	,ClassId INT
	,DSTempSetColCalcId INT
	,ColName varchar(150)
	,PeriodDate varchar(20)
	,LessonPlanId INT
	,LessonName varchar(150)
	,CalcType varchar(50)
	,Score float
	,Duration float
	,Frequency float
	,Interval float
	,IsLP varchar(3)
	,LessonOrder INT
	,SortDate DATETIME
	,IsDuration BIT
	,IsFrequency BIT
	,IsYesNo BIT);

	DECLARE @Approved INT,@Maintenance INT,@Inactive INT
	SELECT 
		@Approved=CASE WHEN LookupName='Approved' THEN LookupId ELSE @Approved END
		,@Maintenance=CASE WHEN LookupName='Maintenance' THEN LookupId ELSE @Maintenance END 
		,@Inactive=CASE WHEN LookupName='Inactive' THEN LookupId ELSE @Inactive END 
	FROM
	Lookup WHERE LookupType='TemplateStatus' AND LookupName IN('Approved','Maintenance','Inactive')

	IF (@ColumDisplay = 0)
	BEGIN
		
		If(@TempShowLessonBehavior LIKE '%1%')
		BEGIN
			INSERT INTO #Lesson(ClassId,DSTempSetColCalcId,ColName,PeriodDate,LessonPlanId,LessonName,CalcType,Score,IsLP,LessonOrder,SortDate)
				SELECT DISTINCT  StdtClassId AS ClassId
				,DSTempSetColCalcId
				,(SELECT ColName FROM DSTempSetCol WHERE DSTempSetColId=StdCalcs.DSTempSetColId) ColName
				,CONVERT(varchar,ReportPeriod.PeriodDate,101) AS PeriodDate
				,LessonPlanId
				,CASE WHEN EXISTS(SELECT DSTempHdrId FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Approved) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Approved) 
			ELSE CASE WHEN EXISTS(SELECT DSTempHdrId FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Maintenance) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Maintenance)
			ELSE CASE WHEN EXISTS(SELECT TOP 1 DSTempHdrId FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Inactive ORDER BY DSTempHdr.DSTempHdrId DESC) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr WHERE DSTempHdr.LessonPlanId=StdCalcs.LessonPlanId AND DSTempHdr.StudentId=StdCalcs.StudentId AND StatusId=@Inactive ORDER BY DSTempHdr.DSTempHdrId DESC) END END END AS LessonName
				,CASE WHEN CalcType='Avg Duration' OR CalcType = 'Total Duration' THEN CASE WHEN CASE WHEN StdCalcs.MaxDur IS NOT NULL THEN StdCalcs.MaxDur END <60 THEN CalcType+' (In Seconds)'  
			ELSE CASE WHEN CASE WHEN StdCalcs.MaxDur IS NOT NULL THEN StdCalcs.MaxDur END <3600 THEN CalcType++' (In Minutes)' 
			ELSE CASE WHEN CASE WHEN StdCalcs.MaxDur IS NOT NULL THEN StdCalcs.MaxDur END>=3600 THEN CalcType+' (In Hours)' 
			ELSE CalcType END END END ELSE CalcType END CalcType
				,CASE WHEN CalcType = 'Total Duration' OR CalcType = 'Frequency' OR CalcType='Total Correct' 
				OR CalcType='Total Incorrect'
				THEN  (SELECT ROUND(SUM(sc.Score),2) FROM StdtSessColScore  sc
				INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
				INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
				JOIN DSTempSetColCalc dcal
				ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
				AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.EndTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
				AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
				AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.IsMaintanace=0) ELSE 
				(SELECT ROUND(AVG(sc.Score),2) FROM StdtSessColScore  sc
				INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
				INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
				JOIN DSTempSetColCalc dcal
				ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
				AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.EndTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
				AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
				AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.IsMaintanace=0) END  AS Score
				,'1' AS IsLP
				,(SELECT TOP 1 LessonOrder FROM DSTempHdr WHERE DSTempHdr.LessonPlanId=StdCalcs.LessonPlanId 
				AND DSTempHdr.StudentId=StdCalcs.Studentid ) LessonOrder
				,PeriodDate AS SortDate
					FROM (
				SELECT  
				sc.SchoolId
				,sc.StudentId
				,sc.DSTempSetColCalcId
				,dcal.CalcType 
				,dcal.DSTempSetColId
				,hdr.LessonPlanId
				,hdr.StdtClassId
				,Cls.ResidenceInd
				,(SELECT ROUND(MAX(Isc.Score),2) FROM StdtSessColScore  Isc
				INNER JOIN StdtSessionHdr IHdr ON IHdr.StdtSessionHdrId=Isc.StdtSessionHdrId
				INNER JOIN Class ICls ON ICls.ClassId=IHdr.StdtClassId
				JOIN DSTempSetColCalc Idcal
				ON Idcal.DSTempSetColCalcId = Isc.DSTempSetColCalcId WHERE Isc.SchoolId=sc.SchoolId AND Isc.StudentId=sc.StudentId
				AND Isc.DSTempSetColCalcId=sc.DSTempSetColCalcId 
				AND IHdr.LessonPlanId=hdr.LessonPlanId AND Idcal.CalcType=dcal.CalcType AND IHdr.StdtClassId=hdr.StdtClassId
				AND IHdr.IOAInd='N' AND IHdr.SessMissTrailStus ='N' AND IHdr.SessionStatusCd='S' AND Isc.Score>=0 AND IHdr.IsMaintanace=0
				AND @TempStartDate <= IHdr.EndTs AND 
			IHdr.EndTs <= @TempENDDate)	MaxDur	
				FROM StdtSessColScore  sc
				JOIN DSTempSetColCalc dcal
				ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId
				JOIN StdtSessionHdr hdr 
				ON hdr.StdtSessionHdrId=sc.StdtSessionHdrId
				JOIN Class Cls ON Cls.ClassId=hdr.StdtClassId
				LEFT JOIN DSTempHdr dhdr ON dhdr.DSTempHdrId=hdr.DSTempHdrId
				LEFT JOIN LookUp lp ON lp.LookupId = dhdr.StatusId
				WHERE sc.SchoolId=@TempSchoolId AND sc.StudentId=@TempStudentid AND hdr.IOAInd='N' AND hdr.SessMissTrailStus ='N' AND hdr.SessionStatusCd='S' AND 
				hdr.LessonPlanId in(select distinct LessonPlanId from DSTempHdr where StudentId=@TempStudentid) AND
				lp.LookupType='TemplateStatus' AND lp.LookupName in('Approved','Inactive','Maintenance')
				GROUP BY 
				sc.SchoolId
				,sc.StudentId
				,sc.DSTempSetColCalcId
				,dcal.CalcType
				,dcal.DSTempSetColId
				,hdr.LessonPlanId
				,hdr.StdtClassId
				,Cls.ResidenceInd
					) AS StdCalcs
				,ReportPeriod
				WHERE @TempStartDate <= ReportPeriod.PeriodDate AND ReportPeriod.PeriodDate <= @TempENDDate
				GROUP BY 
				StdCalcs.SchoolId
				,StdCalcs.StudentId
				,StdCalcs.LessonPlanId
				,StdCalcs.DSTempSetColCalcId
				,StdCalcs.DSTempSetColId
				,ReportPeriod.PeriodDate
				,StdCalcs.CalcType
				,StdCalcs.StdtClassId 
				,StdCalcs.ResidenceInd
				,StdCalcs.MaxDur ;
		END

		If(@TempShowLessonBehavior LIKE '%0%')
		BEGIN
			INSERT INTO #Lesson(ClassId,PeriodDate,LessonPlanId,LessonName,CalcType,Duration,Frequency,Interval,IsLP,LessonOrder,SortDate,IsDuration,IsFrequency,IsYesNo)
				SELECT DISTINCT  FREQUENCY.ClassId ClassId
				,CONVERT(varchar, FREQUENCY.PeriodDate,101) PeriodDate
				,FREQUENCY.MeasurementId AS LessonPlanId
				,(SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId=FREQUENCY.MeasurementId) LessonName
				,CalcType
				, ROUND(FREQUENCY.DurationMin,2)  AS Duration			
				,CASE WHEN CalcType='%Interval' THEN NULL ELSE ROUND(FREQUENCY.Frequncy,2) END AS Frequency
				,CASE WHEN CalcType='%Interval' THEN ROUND(FREQUENCY.Frequncy,2) ELSE NULL END AS Interval
				,'0' AS IsLP
				,'1000' AS LessonOrder
				,FREQUENCY.PeriodDate AS SortDate
				,FREQUENCY.IsDuration
				,FREQUENCY.IsFrequency
				,FREQUENCY.IsYesNo
				FROM(SELECT BEHAVIOR.ClassId
				,PeriodDate
				,BEHAVIOR.MeasurementId
				,(SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId=BEHAVIOR.MeasurementId) LessonName
				,BEHAVIOR.Type CalcType
				,CASE WHEN BEHAVIOR.Type='%Interval' THEN
				(SELECT TOP 1 CONVERT(FLOAT,(SELECT SUM(FrequencyCount) 
					FROM Behaviour WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
					AND  MeasurementId=BEHAVIOR.MeasurementId AND YesOrNo=1)) /
					CONVERT(FLOAT,(SELECT COUNT (*) FROM Behaviour WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
					AND  MeasurementId=BEHAVIOR.MeasurementId AND YesOrNo IS NOT NULL)) * 100
					FROM Behaviour WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
					AND  MeasurementId=BEHAVIOR.MeasurementId AND YesOrNo IS NOT NULL )
				ELSE (SELECT SUM(FrequencyCount) 
				FROM Behaviour 
				WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
				AND  MeasurementId=BEHAVIOR.MeasurementId )
				END AS Frequncy
				,(SELECT (SUM(CONVERT(float,Duration)))/60 
				FROM Behaviour 
				WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
				AND  MeasurementId=BEHAVIOR.MeasurementId)AS DurationMin
				,ClassType
				,BEHAVIOR.IsFrequency AS IsFrequency
				,BEHAVIOR.IsDuration AS IsDuration
				,BEHAVIOR.IsYesNo AS IsYesNo
				FROM (
				SELECT ALLBEHAVIOR.ResidenceInd
				,ALLBEHAVIOR.PartialInterval
				,ALLBEHAVIOR.Period
				,ALLBEHAVIOR.NumOfTimes
				,ALLBEHAVIOR.ClassId
				,ALLBEHAVIOR.MeasurementId
				,ALLBEHAVIOR.PeriodDate
				,CASE WHEN ALLBEHAVIOR.ResidenceInd=1 
				THEN 'Residence' 
				ELSE 'Day' END ClassType
				,CASE WHEN ALLBEHAVIOR.inter=1 and ALLBEHAVIOR.perinter=1 THEN '%Interval'
				ELSE CASE WHEN ALLBEHAVIOR.inter=1 and ALLBEHAVIOR.perinter=0 THEN 'SumTotal'
				ELSE CASE WHEN ALLBEHAVIOR.IsFrequency=1 or ALLBEHAVIOR.IsYesNo=1 THEN 'Frequency'
				ELSE 'Duration' END END END AS Type
				,ALLBEHAVIOR.IsFrequency
				,ALLBEHAVIOR.IsDuration	
				,ALLBEHAVIOR.IsYesNo
				FROM (SELECT Behaviordata.ClassId
				,Behaviordata.MeasurementId
				,ReportPeriod.PeriodDate
				,Behaviordata.PartialInterval
				,Behaviordata.ResidenceInd
				,Behaviordata.Period
				,Behaviordata.NumOfTimes
				,Behaviordata.IsFrequency
				,Behaviordata.IsDuration	
				,Behaviordata.IsYesNo
				,Behaviordata.PartialInterval as inter
				,Behaviordata.IfPerInterval as perinter
				FROM
				(SELECT BDS.ClassId
				,BDS.MeasurementId
				,BDS.PartialInterval
				,Cls.ResidenceInd
				,BDS.Period,BDS.NumOfTimes
				,BDS.Frequency IsFrequency
				,BDS.Duration IsDuration
				,BDS.YesOrNo IsYesNo
				,BDS.IfPerInterval
				FROM BehaviourDetails BDS
				LEFT JOIN  Behaviour BR 
				ON BR.MeasurementId=BDS.MeasurementId 
				LEFT JOIN Class Cls 
				ON Cls.ClassId=BDS.ClassId 
				WHERE BDS.ActiveInd IN ('A', 'N') AND BDS.StudentId=@TempStudentid AND BDS.SchoolId=@TempSchoolId
				GROUP BY BDS.ClassId
				,BR.CreatedOn
				,BDS.MeasurementId
				,BDS.PartialInterval
				,Cls.ResidenceInd
				,BDS.Period
				,BDS.NumOfTimes
				,BDS.Frequency
				,BDS.Duration
				,BDS.YesOrNo 
				,BDS.IfPerInterval) AS Behaviordata,ReportPeriod
				WHERE @TempStartDate <= ReportPeriod.PeriodDate AND 
				ReportPeriod.PeriodDate <= @TempENDDate AND (Period <>0 OR Period IS NULL)) AS ALLBEHAVIOR) BEHAVIOR)FREQUENCY;
		END

		--SELECT ColName,PeriodDate,LessonPlanId,LessonName,CalcType
		--,CASE WHEN CHARINDEX('Minutes',CalcType)>0 THEN ROUND((Score/60),2)  ELSE CASE WHEN CHARINDEX('Hours',CalcType)>0 THEN ROUND((Score/3600),2)  ELSE Score END END Score
		--,Duration,Frequency,Interval,IsLP,IsDuration,IsFrequency,IsYesNo FROM #Lesson ORDER BY SortDate, LessonOrder

	END
	ELSE IF(@ColumDisplay = 1)
	BEGIN

		If(@TempShowLessonBehavior LIKE '%1%')
		BEGIN
			INSERT INTO #Lesson(ClassId,DSTempSetColCalcId,ColName,PeriodDate,LessonPlanId,LessonName,CalcType,Score,IsLP,LessonOrder,SortDate)
				SELECT DISTINCT  StdtClassId AS ClassId
				,DSTempSetColCalcId
				,(SELECT ColName FROM DSTempSetCol WHERE DSTempSetColId=StdCalcs.DSTempSetColId) ColName
				,CONVERT(varchar,ReportPeriod.PeriodDate,101) AS PeriodDate
				,LessonPlanId
				,CASE WHEN EXISTS(SELECT DSTempHdrId FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Approved) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Approved) 
			ELSE CASE WHEN EXISTS(SELECT DSTempHdrId FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Maintenance) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Maintenance)
			ELSE CASE WHEN EXISTS(SELECT TOP 1 DSTempHdrId FROM DSTempHdr WHERE LessonPlanId=StdCalcs.LessonPlanId AND StudentId=StdCalcs.StudentId AND StatusId=@Inactive ORDER BY DSTempHdr.DSTempHdrId DESC) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr WHERE DSTempHdr.LessonPlanId=StdCalcs.LessonPlanId AND DSTempHdr.StudentId=StdCalcs.StudentId AND StatusId=@Inactive ORDER BY DSTempHdr.DSTempHdrId DESC) END END END AS LessonName
				,CASE WHEN CalcType='Avg Duration' OR CalcType = 'Total Duration' THEN CASE WHEN CASE WHEN StdCalcs.MaxDur IS NOT NULL THEN StdCalcs.MaxDur END <60 THEN CalcType+' (In Seconds)'  
			ELSE CASE WHEN CASE WHEN StdCalcs.MaxDur IS NOT NULL THEN StdCalcs.MaxDur END <3600 THEN CalcType++' (In Minutes)' 
			ELSE CASE WHEN CASE WHEN StdCalcs.MaxDur IS NOT NULL THEN StdCalcs.MaxDur END>=3600 THEN CalcType+' (In Hours)' 
			ELSE CalcType END END END ELSE CalcType END CalcType
				,CASE WHEN CalcType = 'Total Duration' OR CalcType = 'Frequency' OR CalcType='Total Correct' 
				OR CalcType='Total Incorrect'
				THEN  (SELECT ROUND(SUM(sc.Score),2) FROM StdtSessColScore  sc
				INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
				INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
				JOIN DSTempSetColCalc dcal
				ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
				AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.EndTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
				AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
				AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.IsMaintanace=0) ELSE 
				(SELECT ROUND(AVG(sc.Score),2) FROM StdtSessColScore  sc
				INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
				INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
				JOIN DSTempSetColCalc dcal
				ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
				AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.EndTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
				AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
				AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.IsMaintanace=0) END  AS Score
				,'1' AS IsLP
				,(SELECT TOP 1 LessonOrder FROM DSTempHdr WHERE DSTempHdr.LessonPlanId=StdCalcs.LessonPlanId 
				AND DSTempHdr.StudentId=StdCalcs.Studentid ) LessonOrder
				,PeriodDate AS SortDate
					FROM (
				SELECT  
				sc.SchoolId
				,sc.StudentId
				,sc.DSTempSetColCalcId
				,dcal.CalcType 
				,dcal.DSTempSetColId
				,hdr.LessonPlanId
				,hdr.StdtClassId
				,Cls.ResidenceInd
				,(SELECT ROUND(MAX(Isc.Score),2) FROM StdtSessColScore  Isc
				INNER JOIN StdtSessionHdr IHdr ON IHdr.StdtSessionHdrId=Isc.StdtSessionHdrId
				INNER JOIN Class ICls ON ICls.ClassId=IHdr.StdtClassId
				JOIN DSTempSetColCalc Idcal
				ON Idcal.DSTempSetColCalcId = Isc.DSTempSetColCalcId WHERE Isc.SchoolId=sc.SchoolId AND Isc.StudentId=sc.StudentId
				AND Isc.DSTempSetColCalcId=sc.DSTempSetColCalcId 
				AND IHdr.LessonPlanId=hdr.LessonPlanId AND Idcal.CalcType=dcal.CalcType AND IHdr.StdtClassId=hdr.StdtClassId
				AND IHdr.IOAInd='N' AND IHdr.SessMissTrailStus ='N' AND IHdr.SessionStatusCd='S' AND Isc.Score>=0 AND IHdr.IsMaintanace=0
				AND @TempStartDate <= IHdr.EndTs AND 
				IHdr.EndTs <= @TempENDDate)	MaxDur	
				FROM StdtSessColScore  sc
				JOIN DSTempSetColCalc dcal
				ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId
				JOIN StdtSessionHdr hdr 
				ON hdr.StdtSessionHdrId=sc.StdtSessionHdrId
				JOIN Class Cls ON Cls.ClassId=hdr.StdtClassId
				LEFT JOIN DSTempHdr dhdr ON dhdr.DSTempHdrId=hdr.DSTempHdrId
				LEFT JOIN LookUp lp ON lp.LookupId = dhdr.StatusId
				WHERE sc.SchoolId=@TempSchoolId AND sc.StudentId=@TempStudentid AND hdr.IOAInd='N' AND hdr.SessMissTrailStus ='N' AND hdr.SessionStatusCd='S' AND 
				hdr.LessonPlanId in(select distinct LessonPlanId from DSTempHdr where StudentId=@TempStudentid) AND
				lp.LookupType='TemplateStatus' AND lp.LookupName in('Approved','Inactive','Maintenance') AND CONVERT(DATE, hdr.endts) >= @TempStartDate AND CONVERT(DATE, hdr.endts) <= @TempENDDate
				GROUP BY 
				sc.SchoolId
				,sc.StudentId
				,sc.DSTempSetColCalcId
				,dcal.CalcType
				,dcal.DSTempSetColId
				,hdr.LessonPlanId
				,hdr.StdtClassId
				,Cls.ResidenceInd
					) AS StdCalcs
				,ReportPeriod
				WHERE @TempStartDate <= ReportPeriod.PeriodDate AND ReportPeriod.PeriodDate <= @TempENDDate 
				GROUP BY 
				StdCalcs.SchoolId
				,StdCalcs.StudentId
				,StdCalcs.LessonPlanId
				,StdCalcs.DSTempSetColCalcId
				,StdCalcs.DSTempSetColId
				,ReportPeriod.PeriodDate
				,StdCalcs.CalcType
				,StdCalcs.StdtClassId 
				,StdCalcs.ResidenceInd
				,StdCalcs.MaxDur ;
		END

		If(@TempShowLessonBehavior LIKE '%0%')
		BEGIN
			INSERT INTO #Lesson(ClassId,PeriodDate,LessonPlanId,LessonName,CalcType,Duration,Frequency,Interval,IsLP,LessonOrder,SortDate,IsDuration,IsFrequency,IsYesNo)
				SELECT DISTINCT  FREQUENCY.ClassId ClassId
				,CONVERT(varchar, FREQUENCY.PeriodDate,101) PeriodDate
				,FREQUENCY.MeasurementId AS LessonPlanId
				,(SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId=FREQUENCY.MeasurementId) LessonName
				,CalcType
				, ROUND(FREQUENCY.DurationMin,2)  AS Duration			
				,CASE WHEN CalcType='%Interval' THEN NULL ELSE ROUND(FREQUENCY.Frequncy,2) END AS Frequency
				,CASE WHEN CalcType='%Interval' THEN ROUND(FREQUENCY.Frequncy,2) ELSE NULL END AS Interval
				,'0' AS IsLP
				,'1000' AS LessonOrder
				,FREQUENCY.PeriodDate AS SortDate
				,FREQUENCY.IsDuration
				,FREQUENCY.IsFrequency
				,FREQUENCY.IsYesNo
				FROM(SELECT BEHAVIOR.ClassId
				,PeriodDate
				,BEHAVIOR.MeasurementId
				,(SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId=BEHAVIOR.MeasurementId) LessonName
				,BEHAVIOR.Type CalcType
				,CASE WHEN BEHAVIOR.Type='%Interval' THEN
				(SELECT TOP 1 CONVERT(FLOAT,(SELECT SUM(FrequencyCount) 
					FROM Behaviour WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
					AND  MeasurementId=BEHAVIOR.MeasurementId AND YesOrNo=1)) /
					CONVERT(FLOAT,(SELECT COUNT (*) FROM Behaviour WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
					AND  MeasurementId=BEHAVIOR.MeasurementId AND YesOrNo IS NOT NULL)) * 100
					FROM Behaviour WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
					AND  MeasurementId=BEHAVIOR.MeasurementId AND YesOrNo IS NOT NULL )
				ELSE (SELECT SUM(FrequencyCount) 
				FROM Behaviour 
				WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
				AND  MeasurementId=BEHAVIOR.MeasurementId )
				END AS Frequncy
				,(SELECT (SUM(CONVERT(float,Duration)))/60 
				FROM Behaviour 
				WHERE Convert(DATE,CreatedOn)=Convert(DATE,BEHAVIOR.PeriodDate)
				AND  MeasurementId=BEHAVIOR.MeasurementId)AS DurationMin
				,ClassType
				,BEHAVIOR.IsFrequency AS IsFrequency
				,BEHAVIOR.IsDuration AS IsDuration
				,BEHAVIOR.IsYesNo AS IsYesNo
				FROM (
				SELECT ALLBEHAVIOR.ResidenceInd
				,ALLBEHAVIOR.PartialInterval
				,ALLBEHAVIOR.Period
				,ALLBEHAVIOR.NumOfTimes
				,ALLBEHAVIOR.ClassId
				,ALLBEHAVIOR.MeasurementId
				,ALLBEHAVIOR.PeriodDate
				,CASE WHEN ALLBEHAVIOR.ResidenceInd=1 
				THEN 'Residence' 
				ELSE 'Day' END ClassType
				,CASE WHEN ALLBEHAVIOR.inter=1 and ALLBEHAVIOR.perinter=1 THEN '%Interval'
				ELSE CASE WHEN ALLBEHAVIOR.inter=1 and ALLBEHAVIOR.perinter=0 THEN 'SumTotal'
				ELSE CASE WHEN ALLBEHAVIOR.IsFrequency=1 or ALLBEHAVIOR.IsYesNo=1 THEN 'Frequency'
				ELSE 'Duration' END END END AS Type
				,ALLBEHAVIOR.IsFrequency
				,ALLBEHAVIOR.IsDuration	
				,ALLBEHAVIOR.IsYesNo
				FROM (SELECT Behaviordata.ClassId
				,Behaviordata.MeasurementId
				,ReportPeriod.PeriodDate
				,Behaviordata.PartialInterval
				,Behaviordata.ResidenceInd
				,Behaviordata.Period
				,Behaviordata.NumOfTimes
				,Behaviordata.IsFrequency
				,Behaviordata.IsDuration	
				,Behaviordata.IsYesNo
				,Behaviordata.PartialInterval as inter
				,Behaviordata.IfPerInterval as perinter
				FROM
				(SELECT BDS.ClassId
				,BDS.MeasurementId
				,BDS.PartialInterval
				,Cls.ResidenceInd
				,BDS.Period,BDS.NumOfTimes
				,BDS.Frequency IsFrequency
				,BDS.Duration IsDuration
				,BDS.YesOrNo IsYesNo
				,BDS.IfPerInterval
				FROM BehaviourDetails BDS
				LEFT JOIN  Behaviour BR 
				ON BR.MeasurementId=BDS.MeasurementId 
				LEFT JOIN Class Cls 
				ON Cls.ClassId=BDS.ClassId 
				WHERE BDS.ActiveInd IN ('A', 'N') AND BDS.StudentId=@TempStudentid AND BDS.SchoolId=@TempSchoolId AND CONVERT(DATE, BR.TimeOfEvent) >= @TempStartDate AND CONVERT(DATE, BR.TimeOfEvent) <= @TempENDDate
				GROUP BY BDS.ClassId
				,BR.CreatedOn
				,BDS.MeasurementId
				,BDS.PartialInterval
				,Cls.ResidenceInd
				,BDS.Period
				,BDS.NumOfTimes
				,BDS.Frequency
				,BDS.Duration
				,BDS.YesOrNo 
				,BDS.IfPerInterval) AS Behaviordata,ReportPeriod
				WHERE @TempStartDate <= ReportPeriod.PeriodDate AND 
				ReportPeriod.PeriodDate <= @TempENDDate AND (Period <>0 OR Period IS NULL)) AS ALLBEHAVIOR) BEHAVIOR)FREQUENCY;
		END

		--SELECT ColName,PeriodDate,LessonPlanId,LessonName,CalcType
		--,CASE WHEN CHARINDEX('Minutes',CalcType)>0 THEN ROUND((Score/60),2)  ELSE CASE WHEN CHARINDEX('Hours',CalcType)>0 THEN ROUND((Score/3600),2)  ELSE Score END END Score
		--,Duration,Frequency,Interval,IsLP,IsDuration,IsFrequency,IsYesNo FROM #Lesson ORDER BY SortDate, LessonOrder


	END

		SELECT ColName,PeriodDate,LessonPlanId,LessonName,CalcType
		,CASE WHEN CHARINDEX('Minutes',CalcType)>0 THEN ROUND((Score/60),2)  ELSE CASE WHEN CHARINDEX('Hours',CalcType)>0 THEN ROUND((Score/3600),2)  ELSE Score END END Score
		,Duration,Frequency,Interval,IsLP,IsDuration,IsFrequency,IsYesNo FROM #Lesson ORDER BY SortDate, LessonOrder
	
END

GO
