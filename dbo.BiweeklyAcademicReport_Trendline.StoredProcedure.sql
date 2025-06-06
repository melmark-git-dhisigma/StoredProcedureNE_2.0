USE [MelmarkNE]
GO
/****** Object:  StoredProcedure [dbo].[BiweeklyAcademicReport_Trendline]    Script Date: 3/7/2025 2:32:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BiweeklyAcademicReport_Trendline]  @AllLesson INT,@LPStatus VARCHAR(MAX),@StudentId INT
AS
  BEGIN
	DECLARE @Approved INT,@Maintenance INT,@Inactive INT
SELECT 
	@Approved=CASE WHEN LookupName='Approved' THEN LookupId ELSE @Approved END
	,@Maintenance=CASE WHEN LookupName='Maintenance' THEN LookupId ELSE @Maintenance END 
	,@Inactive=CASE WHEN LookupName='Inactive' THEN LookupId ELSE @Inactive END 
FROM Lookup WHERE LookupType='TemplateStatus' AND LookupName IN('Approved','Maintenance','Inactive')

DECLARE @LSID TABLE (LSID INT)
INSERT INTO @LSID(LSID) SELECT * FROM Split(@AllLesson,',') OPTION (MAXRECURSION 500)
DECLARE @LStat TABLE (LStat INT)
INSERT INTO @LStat(LStat) SELECT * FROM Split(@LPStatus,',')

SELECT *, 
	(SELECT CASE WHEN EXISTS (SELECT StatusId  FROM DSTempHdr DH WHERE DH.StudentId = @StudentId AND DH.LessonPlanId = LSN.LessonPlanId AND DH.StatusId=@Approved 
		AND DH.StatusId IN (SELECT LStat FROM @LStat)) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr DH WHERE DH.StudentId = @StudentId AND DH.LessonPlanId = LSN.LessonPlanId 
		AND DH.StatusId=@Approved AND DH.StatusId IN (SELECT LStat FROM @LStat)) 
		ELSE CASE WHEN EXISTS (SELECT StatusId  FROM DSTempHdr DH WHERE DH.StudentId = @StudentId AND DH.LessonPlanId = LSN.LessonPlanId AND DH.StatusId=@Maintenance 
		AND DH.StatusId IN (SELECT LStat FROM @LStat)) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr DH WHERE DH.StudentId = @StudentId AND DH.LessonPlanId = LSN.LessonPlanId 
		AND DH.StatusId=@Maintenance AND DH.StatusId IN (SELECT LStat FROM @LStat)) 
		ELSE CASE WHEN EXISTS (SELECT TOP 1 StatusId FROM DSTempHdr DH WHERE DH.StudentId = @StudentId AND DH.LessonPlanId = LSN.LessonPlanId AND DH.StatusId=@Inactive 
		AND DH.StatusId IN (SELECT LStat FROM @LStat)) THEN (SELECT TOP 1 DSTemplateName FROM DSTempHdr DH WHERE DH.StudentId = @StudentId AND DH.LessonPlanId = LSN.LessonPlanId 
		AND DH.StatusId=@Inactive AND DH.StatusId IN (SELECT LStat FROM @LStat)
		ORDER BY DSTempHdrId DESC) END END END ) AS LessonPlanName 	
	,(SELECT LastName + ', ' + FirstName  FROM StudentPersonal WHERE StudentPersonalId=@StudentId) StudentName
	,(SELECT TOP 1 ('Tx: ' + (SELECT LookupName FROM LookUp WHERE LookupId= [TeachingProcId]) + ';' + (SELECT LookupName FROM LookUp WHERE LookupId= [PromptTypeId])) Treatment 
		FROM DSTempHdr D WHERE D.LessonPlanId=LSN.LessonPlanId AND D.StudentId=@StudentId AND StatusId IN (SELECT LStat FROM @LStat)
		ORDER BY DSTempHdrId DESC) Treatment
	,(SELECT TOP 1 'Correct Response: ' + StudCorrRespDef FROM DSTempHdr D WHERE D.LessonPlanId=LSN.LessonPlanId AND D.StudentId=@StudentId AND D.StudCorrRespDef <>'' 
		AND StatusId IN (SELECT LStat FROM @LStat) ORDER BY DSTempHdrId DESC) Deftn 
		,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 and LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE
		CASE WHEN LessonPlanTypeDay=1 THEN 'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' 
		END END END ClassType FROM StdtLessonPlan WHERE LessonPlanId=LSN.LessonPlanId ORDER BY StdtLessonPlanId DESC) AS ClassType
FROM 
(SELECT D.LessonPlanId FROM DSTempHdr D WHERE D.StudentId=@StudentId AND StatusId IN (SELECT LStat FROM @LStat) AND D.LessonPlanId IN (SELECT LSID FROM @LSID)
GROUP BY D.LessonPlanId) LSN 
END
GO
