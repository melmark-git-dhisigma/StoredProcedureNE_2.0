USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[DashboardClientAcademic(Backup3Apr2020)]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[DashboardClientAcademic(Backup3Apr2020)] @ParamClassid VARCHAR(MAX) = NULL,
												@ParamStudid VARCHAR(MAX) = NULL
	
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @SetClassids VARCHAR(MAX),
			@SetStudids	VARCHAR(MAX)
	SET @SetClassids = @ParamClassid
	SET @SetStudids = @ParamStudid

	--[ Inserting Classids Into Table ]--
	DECLARE @ClassSplt TABLE 
	( 
		data INT 
	) 
	INSERT INTO @ClassSplt 
	SELECT * 
	FROM Split(@SetClassids, ',')
	OPTION (MAXRECURSION 5000) 

	--SELECT data FROM @ClassSplt


	--[ Inserting Studentids Into Table ]--
	DECLARE @StudSplt TABLE 
	( 
		data INT 
	) 
	INSERT INTO @StudSplt 
	SELECT * 
	FROM Split(@SetStudids, ',')
	OPTION (MAXRECURSION 5000) 

	--SELECT data FROM @StudSplt



	IF(@SetClassids IS NOT NULL AND @SetStudids IS NOT NULL)
	BEGIN
		-- [PRINT 'Class and Stuid'] --
		SELECT  shd.lessonplanid AS LessonPlanId,
			(SELECT CASE
				WHEN Count(shd.SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
				ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
			END) AS LessonName,
			Count(DISTINCT shd.lessonplanid) AS LessonCount,
			Count(shd.SessionNbr) AS SessionCount,
			(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
			shd.StdtClassId,
			shd.studentid AS StudentID,
			(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select stdtid from stdtclass where stdtid IN(SELECT data FROM @StudSplt) and classid in(SELECT data FROM @ClassSplt) and ActiveInd = 'A') 
			AND CONVERT(VARCHAR(10), createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			AND [sessionstatuscd] = 'S'
			AND StdtClassId IN (SELECT data FROM @ClassSplt)
		GROUP BY shd.studentid,shd.StdtClassId,shd.LessonPlanId
		ORDER BY StudentName
	END
	ELSE IF(@SetClassids IS NOT NULL AND @SetStudids IS NULL)
	BEGIN
		-- [PRINT 'Only clasid'] --
		SELECT  shd.lessonplanid AS LessonPlanId,
			(SELECT CASE
				WHEN Count(shd.SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
			END) AS LessonName,
			Count(DISTINCT shd.lessonplanid) AS LessonCount,
			Count(shd.SessionNbr) AS SessionCount,
			(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
			shd.StdtClassId,
			shd.studentid AS StudentID,
			(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select stdtid from stdtclass where ActiveInd = 'A') 
			AND CONVERT(VARCHAR(10), createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			AND [sessionstatuscd] = 'S'
			AND StdtClassId IN (SELECT data FROM @ClassSplt)
		GROUP BY shd.studentid,shd.StdtClassId,shd.LessonPlanId
		ORDER BY StudentName
	END
	ELSE
	BEGIN
		-- [PRINT 'Only Studentid'] --		
		SELECT  shd.lessonplanid AS LessonPlanId,
			(SELECT CASE
				WHEN Count(shd.SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
			END) AS LessonName,
			Count(DISTINCT shd.lessonplanid) AS LessonCount,
			Count(shd.SessionNbr) AS SessionCount,
			(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
			shd.StdtClassId,
			shd.studentid AS StudentID,
			(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select stdtid from stdtclass where stdtid IN(SELECT data FROM @StudSplt)  and ActiveInd = 'A') 
			AND CONVERT(VARCHAR(10), createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			AND [sessionstatuscd] = 'S'
			
		GROUP BY shd.studentid,shd.StdtClassId,shd.LessonPlanId
		ORDER BY StudentName
	END
END

GO
