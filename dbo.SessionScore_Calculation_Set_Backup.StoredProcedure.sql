USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[SessionScore_Calculation_Set_Backup]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SessionScore_Calculation_Set_Backup]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

	DECLARE @Cnt INT,
	 @msg varchar(20),
	 @LoadDate DATETIME

	 SET @LoadDate=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])
     DELETE FROM  [dbo].[StdtAggScoreSet] WHERE CONVERT(DATE,AggregatedDate) >= @LoadDate
	-- TO INSERT DATA TO [dbo].[StdtAggScoreSet] TABLE FROM [dbo].[StdtSessColScore]
	INSERT INTO [StdtAggScoreSet](SchoolId
	,StudentId
	,SetId
	,DSTempSetColCalcId
	,AggregatedDate
	,LessonPlanId
	,CalcType
	,Score
	,ClassId
	,ClassType
	,IsMaintanance
	,ColRptLabelLP) 
	SELECT SchoolId
	,StudentId
	,CurrentSetId
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
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.CurrentSetId=StdCalcs.CurrentSetId) ELSE 
	(SELECT AVG(sc.Score) FROM StdtSessColScore  sc
	INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
	AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,ReportPeriod.PeriodDate)
	AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.CurrentSetId=StdCalcs.CurrentSetId) END AS Score 
	,StdtClassId
	,CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType
	,IsMaintanace
	,(CONVERT(VARCHAR(50),StdCalcs.LessonPlanId)+'-'+(SELECT CASE WHEN StdCalcs.CalcRptLabel='' OR StdCalcs.CalcRptLabel IS NULL THEN StdCalcs.CalcType ELSE StdCalcs.CalcRptLabel
 END )+'-'+(SELECT ColName FROM DSTempSetCol  WHERE DSTempSetColId= (SELECT DSTempSetColId FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=StdCalcs.DsTempSetColCalcId))
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
	,hdr.CurrentSetId
	,hdr.IsMaintanace
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
	,hdr.CurrentSetId
	,sc.DSTempSetColCalcId
	,dcal.CalcType
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd
	,hdr.IsMaintanace
	,dcal.CalcRptLabel
	 ) AS StdCalcs
	,ReportPeriod
	WHERE CONVERT(DATE,PeriodDate) BETWEEN (SELECT CONVERT(DATE,Last_run_date) FROM [dbo].[StdtLoadDates]) AND CONVERT(DATE,GETDATE())	
	GROUP BY StdCalcs.SchoolId
	,StdCalcs.StudentId
	,StdCalcs.LessonPlanId
	,StdCalcs.CurrentSetId
	,StdCalcs.DSTempSetColCalcId
	,ReportPeriod.PeriodDate
	,StdCalcs.CalcType
	,StdCalcs.StdtClassId 
	,StdCalcs.ResidenceInd
	,StdCalcs.IsMaintanace 
	,StdCalcs.CalcRptLabel
	

	


	UPDATE [dbo].[StdtAggScoreSet] SET 
    [dbo].[StdtAggScoreSet].Score = UPDATETBL.Score
FROM
    [dbo].[StdtAggScoreSet]
INNER JOIN
(SELECT SchoolId
	,StudentId
	,CurrentSetId
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
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.CurrentSetId=StdCalcs.CurrentSetId 
	AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,StdCalcs.CreatedOn)) ELSE 
	(SELECT AVG(sc.Score) FROM StdtSessColScore  sc
	INNER JOIN StdtSessionHdr Hdr ON Hdr.StdtSessionHdrId=sc.StdtSessionHdrId
	INNER JOIN Class Cls ON Cls.ClassId=Hdr.StdtClassId
	JOIN DSTempSetColCalc dcal
	ON dcal.DSTempSetColCalcId = sc.DSTempSetColCalcId WHERE sc.SchoolId=StdCalcs.SchoolId AND sc.StudentId=StdCalcs.StudentId
	AND sc.DSTempSetColCalcId=StdCalcs.DSTempSetColCalcId 
	AND Hdr.LessonPlanId=StdCalcs.LessonPlanId AND dcal.CalcType=StdCalcs.CalcType AND Hdr.StdtClassId=StdCalcs.StdtClassId
	AND Hdr.IOAInd='N' AND Hdr.SessMissTrailStus ='N' AND Hdr.SessionStatusCd='S' AND sc.Score>=0 AND Hdr.CurrentSetId=StdCalcs.CurrentSetId 
	AND CONVERT(DATE,Hdr.StartTs)=CONVERT(DATE,StdCalcs.CreatedOn)) END AS Score 
	,StdtClassId
	,CASE WHEN ResidenceInd=1 THEN 'Residence' ELSE  'Day' END AS ClassType
	,IsMaintanace  FROM (
	SELECT  
	sc.SchoolId
	,sc.StudentId
	,hdr.CurrentSetId
	,sc.DSTempSetColCalcId
	,dcal.CalcType 
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd	
	,hdr.CreatedOn
	,hdr.IsUpdate
	,hdr.ModifiedOn
	,IsMaintanace
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
	,hdr.CurrentSetId
	,sc.DSTempSetColCalcId
	,dcal.CalcType
	,hdr.LessonPlanId
	,hdr.StdtClassId
	,Cls.ResidenceInd
	,hdr.CreatedOn
	,hdr.IsUpdate
	,hdr.ModifiedOn
	,hdr.IsMaintanace
	 ) AS StdCalcs	
	WHERE CONVERT(DATE,StdCalcs.ModifiedOn) BETWEEN (SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates]) 
	AND CONVERT(DATE,GETDATE())	
	AND StdCalcs.IsUpdate ='true' 
	GROUP BY StdCalcs.SchoolId
	,StdCalcs.StudentId
	,StdCalcs.LessonPlanId
	,StdCalcs.CurrentSetId
	,StdCalcs.DSTempSetColCalcId
	,StdCalcs.CreatedOn
	,StdCalcs.CalcType
	,StdCalcs.StdtClassId 
	,StdCalcs.ResidenceInd
	,StdCalcs.ModifiedOn
	,StdCalcs.IsMaintanace ) UPDATETBL
	ON
    StdtAggScoreSet.SchoolId = UPDATETBL.SchoolId AND StdtAggScoreSet.StudentId = UPDATETBL.StudentId AND StdtAggScoreSet.DsTempSetColCalcId = UPDATETBL.DSTempSetColCalcId 
	AND CONVERT(DATE,StdtAggScoreSet.AggregatedDate) = CONVERT(DATE,UPDATETBL.CreatedOn) AND StdtAggScoreSet.LessonPlanId = UPDATETBL.LessonPlanId 
	AND StdtAggScoreSet.CalcType = UPDATETBL.CalcType AND StdtAggScoreSet.ClassId = UPDATETBL.StdtClassId AND StdtAggScoreSet.SetId=UPDATETBL.CurrentSetId 
	AND StdtAggScoreSet.IsMaintanance=UPDATETBL.IsMaintanace
 
 --Update Lesson Plan IOA value to [dbo].[StdtAggScoreSet] TABLE		 
	 CREATE TABLE #IOA(ID int PRIMARY KEY IDENTITY(1,1),IOAPerc varchar(50),SetId int,DSTempSetColCalcId int,SchoolId int,StudentId int,
	 LessonPlanId int,StdtClassId int,CreatedDate date,NormalUsr VARCHAR(100),IOAUsr VARCHAR(100),IsMaintanance bit);

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
	 AND Hdr.CurrentSetId=DATA.CurrentSetId 
	 AND CONVERT(DATE,StartTs)=DATA.STARTTS ORDER BY Hdr.StdtSessionHdrId DESC)IOAPerc
	 ,DATA.CurrentSetId
	 ,DATA.DSTempSetColCalcId	 
	 ,DATA.SchoolId
	 ,DATA.StudentId
	 ,DATA.LessonPlanId
	 ,DATA.StdtClassId
	 ,DATA.STARTTS 
	 ,DATA.NormalUsr
	 ,DATA.IOAUsr
	 ,DATA.IsMaintanace
	 FROM
	 (SELECT Hdr.IOAPerc
	 ,CScr.DSTempSetColCalcId
	 ,CScr.SchoolId
	 ,CScr.StudentId
	 ,Hdr.LessonPlanId
	 ,Hdr.StdtClassId
	 ,Hdr.CurrentSetId
	 ,CONVERT(DATE,StartTs) STARTTS
	 ,(SELECT UserInitial FROM [User] WHERE UserId=(SELECT CreatedBy FROM StdtSessionHdr WHERE StdtSessionHdrId= Hdr.IOASessionHdrId)) NormalUsr
	 , (SELECT UserInitial FROM [User] WHERE UserId=Hdr.IOAUserId) IOAUsr
	 ,Hdr.IsMaintanace
	 FROM StdtSessionHdr Hdr 
	 INNER JOIN StdtSessColScore CScr 
	 ON Hdr.StdtSessionHdrId=CScr.StdtSessionHdrId 
	 WHERE Hdr.IOAInd='Y'
	 AND CONVERT(DATE,StartTs)>=(SELECT CONVERT(DATE,[Last_run_date]) FROM [dbo].[StdtLoadDates])) AS DATA
	 
	 


	 SET @Cnt=1
	 WHILE(@Cnt<=(SELECT COUNT(*) FROM #IOA)) 
	 BEGIN
	 UPDATE [dbo].[StdtAggScoreSet] 
	 SET IOAPerc='IOA '+(SELECT IOAPerc FROM #IOA WHERE ID=@Cnt)+' % ' +(SELECT NormalUsr FROM #IOA WHERE ID=@Cnt )+'/'+(SELECT IOAUsr FROM #IOA WHERE ID=@Cnt )
	 WHERE DsTempSetColCalcId=(SELECT DSTempSetColCalcId FROM #IOA WHERE ID=@Cnt) 
	 AND SchoolId=(SELECT SchoolId FROM #IOA WHERE ID=@Cnt) 
	 AND StudentId=(SELECT StudentId FROM #IOA WHERE ID=@Cnt) 
	 AND LessonPlanId=(SELECT LessonPlanId FROM #IOA WHERE ID=@Cnt)
	 AND ClassId=(SELECT StdtClassId FROM #IOA WHERE ID=@Cnt)
	 AND SetId=(SELECT SetId FROM #IOA WHERE ID=@Cnt)
	 AND CONVERT(DATE,AggregatedDate)=(SELECT CreatedDate FROM #IOA WHERE ID=@Cnt) 
	 AND IsMaintanance=(SELECT IsMaintanance FROM #IOA WHERE ID=@Cnt)
	 SET @Cnt=@Cnt+1
	 END

	 DROP TABLE #IOA	

	--  UPDATE StdtAggScoreSet SET ColRptLabelLP =(CONVERT(VARCHAR(50),LessonPlanId)+'-'+(SELECT CASE WHEN CalcRptLabel='' THEN CalcType ELSE CalcRptLabel
 --END FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=StdtAggScoreSet.DsTempSetColCalcId)+'-'+(SELECT ColName FROM DSTempSetCol 
 --WHERE DSTempSetColId= (SELECT DSTempSetColId FROM DSTempSetColCalc WHERE DSTempSetColCalc.DSTempSetColCalcId=StdtAggScoreSet.DsTempSetColCalcId))
 --+'-'+CONVERT(VARCHAR(50),(SELECT COUNT(*) FROM DSTempPrompt WHERE DSTempHdrId= (SELECT [DSTempHdrId] FROM [dbo].[DSTempSetCol] WHERE [DSTempSetColId]=(SELECT 
 --[DSTempSetColId] FROM [dbo].[DSTempSetColCalc] WHERE [DSTempSetColCalcId]=StdtAggScoreSet.DsTempSetColCalcId))))) WHERE ColRptLabelLP IS NULL 
 -- AND DsTempSetColCalcId IS NOT NULL

 SET @msg='SUCCESS'
	 COMMIT
	END TRY
	BEGIN CATCH
	ROLLBACK
	SET @msg='FAILED'	
	END CATCH
	
END
GO
