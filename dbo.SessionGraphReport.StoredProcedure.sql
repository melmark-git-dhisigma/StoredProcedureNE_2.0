USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[SessionGraphReport]    Script Date: 05/10/2024 4:55:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
ALTER PROCEDURE [dbo].[SessionGraphReport] 
	@LessonPlan int,
	@StudentId int
AS
BEGIN
	
    SELECT (SELECT StudentLName+', '+StudentFName FROM Student WHERE StudentId=@StudentId)AS StudentName
	  ,(SELECT TOP 1 CASE WHEN LessonPlanTypeDay=1 and LessonPlanTypeResi=1 THEN 'Day,Residence' ELSE
		CASE WHEN LessonPlanTypeDay=1 THEN 'Day' ELSE CASE WHEN LessonPlanTypeResi=1 THEN 'Residence' 
		END END END ClassType FROM StdtLessonPlan WHERE LessonPlanId=@LessonPlan ORDER BY StdtLessonPlanId DESC) AS ClassType
	  ,(SELECT TOP 1  ('Tx: ' + (SELECT LookupName FROM LookUp WHERE LookupId= [TeachingProcId]) + ';' + 
					  (SELECT LookupName FROM LookUp WHERE LookupId= [PromptTypeId])) Treatment 
		FROM DSTempHdr HDR LEFT JOIN Lookup LK ON HDR.StatusId=LK.LookupId WHERE LessonPlanId=@LessonPlan AND StudentId=@StudentId
		AND LookupType='TemplateStatus' AND LookupName in('Approved','Maintenance','Inactive')	
		ORDER BY DSTempHdrId DESC) Treatment 
	  ,(SELECT TOP 1 'Correct Response: '+StudCorrRespDef FROM DSTempHdr HDR LEFT JOIN Lookup LK ON HDR.StatusId=LK.LookupId 
		WHERE LessonPlanId=@LessonPlan AND StudentId=@StudentId AND StudCorrRespDef<>'' AND StudCorrRespDef IS NOT NULL AND
		LookupType='TemplateStatus' AND LookupName in('Approved','Maintenance','Inactive')
		ORDER BY DSTempHdrId DESC) Deftn
END
