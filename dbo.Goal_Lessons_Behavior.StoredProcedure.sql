USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[Goal_Lessons_Behavior]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Goal_Lessons_Behavior]
@StartDate DATETIME,
@EndDate DATETIME,
@StudentId int
AS
BEGIN
	
	SET NOCOUNT ON;


	 
	
	SELECT * FROM (SELECT GoalId,(SELECT GoalName FROM Goal WHERE GoalId=LESSONS.GoalId) GoalName,LessonPlanId,(SELECT LessonPlanName FROM LessonPlan WHERE LessonPlanId=LESSONS.LessonPlanId) LessonPlanName,DSTempHdrId,NULL Behavior,CalcType,
	AVG(CONVERT(FLOAT,Score)) AS Score,'False' IsBehavior,Objective1,Objective2,Objective3,Objective,Baseline
	,CASE WHEN Created>0 THEN 1 ELSE 0 END CreatedOnDesiredTime
	FROM (SELECT GoalId,LessonPlanId,DSTempHdrId,CalcType,(SELECT AVG([Score]) FROM [dbo].[StdtSessColScore] 
	WHERE [DSTempSetColCalcId]=LESSON.DSTempSetColCalcId AND CONVERT(DATE,CreatedOn)<=CONVERT(DATE,@EndDate) AND CONVERT(DATE,CreatedOn)>=CONVERT(DATE,@StartDate)) Score 
	,(SELECT Objective1 FROM StdtLessonPlan WHERE StdtLessonPlanId=(SELECT StdtLessonPlanId FROM DSTempHdr WHERE DSTempHdrId=LESSON.DSTempHdrId)) Objective1
	,(SELECT Objective2 FROM StdtLessonPlan WHERE StdtLessonPlanId=(SELECT StdtLessonPlanId FROM DSTempHdr WHERE DSTempHdrId=LESSON.DSTempHdrId)) Objective2
	,(SELECT Objective3 FROM StdtLessonPlan WHERE StdtLessonPlanId=(SELECT StdtLessonPlanId FROM DSTempHdr WHERE DSTempHdrId=LESSON.DSTempHdrId)) Objective3
	,(SELECT Objective FROM StdtLessonPlan WHERE StdtLessonPlanId=(SELECT StdtLessonPlanId FROM DSTempHdr WHERE DSTempHdrId=LESSON.DSTempHdrId)) Objective
	,(SELECT Baseline FROM StdtLessonPlan WHERE StdtLessonPlanId=(SELECT StdtLessonPlanId FROM DSTempHdr WHERE DSTempHdrId=LESSON.DSTempHdrId)) Baseline
	,(SELECT COUNT([CreatedOn]) FROM [dbo].[StdtSessColScore] WHERE [DSTempSetColCalcId]=LESSON.DSTempSetColCalcId AND CONVERT(DATE,CreatedOn)<=CONVERT(DATE,@EndDate) AND CONVERT(DATE,CreatedOn)>=CONVERT(DATE,@StartDate)) Created
	FROM ( SELECT DISTINCT SLP.GoalId,SLP.LessonPlanId,(SELECT TOP 1 DSTempHdrId FROM 
	[dbo].[DSTempHdr] DHDR WHERE DHDR.LessonPlanId=SLP.LessonPlanId AND DHDR.StudentId=SLP.StudentId ORDER BY DSTempHdrId DESC) DSTempHdrId,
	DCALC.CalcType,DCALC.DSTempSetColCalcId FROM [dbo].[StdtLessonPlan] SLP INNER JOIN DSTempHdr DHDR ON SLP.StdtLessonPlanId=DHDR.StdtLessonplanId 
	 LEFT JOIN [dbo].[DSTempSetCol] DSCOL ON DHDR.DSTempHdrId=DSCOL.DSTempHdrId LEFT JOIN [dbo].[DSTempSetColCalc] DCALC ON 
	 DSCOL.DSTempSetColId=DCALC.DSTempSetColId WHERE SLP.StudentId=@StudentId 
	 --AND CONVERT(DATE,SLP.CreatedOn) BETWEEN CONVERT(DATE,@StartDate) AND CONVERT(DATE,@EndDate)  
	AND SLP.ActiveInd='A' AND SLP.GoalId IS NOT NULL AND DHDR.StatusId IN ((SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Approved'),
	(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Maintenance'),(SELECT LookupId FROM LookUp WHERE LookupType='TemplateStatus' AND LookupName='Inactive'))) LESSON) LESSONS 
	GROUP BY GoalId,LessonPlanId,DSTempHdrId,CalcType,Objective1,Objective2,Objective3,Objective,Baseline
	,Created
	) Goal_Lesson
	WHERE CreatedOnDesiredTime=1

	UNION ALL

	(SELECT (SELECT GoalId FROM Goal WHERE GoalCode='Behavior') GoalId,'Behaviors' GoalName,BLP.LessonPlanId,(SELECT LessonPlanName FROM LessonPlan WHERE 
	LessonPlanId=BLP.LessonPlanId) LessonPlanName,BDS.MeasurementId,BDS.Behaviour,'Frequency' AS CalcType,
	AVG(CONVERT(FLOAT,BHR.FrequencyCount)) Score,'True' IsBehavior,NULL Objective1,NULL Objective2,NULL Objective3,NULL Objective,NULL Baseline	,NULL CreatedOnDesiredTime
	 FROM [dbo].[BehaviourDetails] BDS LEFT JOIN (SELECT MeasurementId,FrequencyCount,Duration FROM [Behaviour] WHERE  
	CONVERT(DATE,CreatedOn)<=CONVERT(DATE,@EndDate) AND CONVERT(DATE,CreatedOn)>=CONVERT(DATE,@StartDate)) BHR ON BDS.MeasurementId=BHR.MeasurementId LEFT JOIN [dbo].[BehaviourLPRel] BLP ON 
	BDS.MeasurementId=BLP.MeasurementId WHERE BDS.StudentId=@StudentId AND BDS.ActiveInd='A' AND BDS.[Frequency]='True'  
	 GROUP BY BLP.LessonPlanId,BDS.MeasurementId,BDS.Behaviour,BDS.[Frequency],BDS.[Duration]

	 UNION ALL

	 	SELECT (SELECT GoalId FROM Goal WHERE GoalCode='Behavior') GoalId,'Behaviors' GoalName,BLP.LessonPlanId,(SELECT LessonPlanName FROM LessonPlan WHERE 
	LessonPlanId=BLP.LessonPlanId) LessonPlanName,BDS.MeasurementId,BDS.Behaviour,
	 'Duration' CalcType,AVG(CONVERT(FLOAT,BHR.Duration)) Score,'True' IsBehavior,NULL Objective1,NULL Objective2,NULL Objective3,NULL Objective,NULL Baseline
	 ,NULL CreatedOnDesiredTime FROM [dbo].[BehaviourDetails] BDS LEFT JOIN (SELECT MeasurementId,FrequencyCount,Duration FROM [Behaviour] WHERE 
	 CONVERT(DATE,CreatedOn)<=CONVERT(DATE,@EndDate) AND CONVERT(DATE,CreatedOn)>=CONVERT(DATE,@StartDate)) BHR ON BDS.MeasurementId=BHR.MeasurementId LEFT JOIN [dbo].[BehaviourLPRel] BLP ON 
	BDS.MeasurementId=BLP.MeasurementId WHERE BDS.StudentId=@StudentId AND BDS.ActiveInd='A' AND BDS.Duration='True'  
	 GROUP BY BLP.LessonPlanId,BDS.MeasurementId,BDS.Behaviour,BDS.[Frequency],BDS.[Duration])
	
	
END

GO
