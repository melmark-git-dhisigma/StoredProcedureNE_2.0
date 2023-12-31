USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[DashboardStaffAcademic]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[DashboardStaffAcademic] @ParamClassid VARCHAR(MAX) = NULL,
											   @ParamStudid VARCHAR(MAX) = NULL,
											   @ParamUserid VARCHAR(MAX) = NULL,
											   @ParamMistrial VARCHAR(MAX) = NULL
	
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @SetClassids VARCHAR(MAX),
			@SetStudids	VARCHAR(MAX),
			@SetUserids	VARCHAR(MAX),
			@SetMistrial VARCHAR(MAX)
	SET @SetClassids = @ParamClassid
	SET @SetStudids = @ParamStudid
	SET @SetUserids = @ParamUserid
	SET @SetMistrial = @ParamMistrial

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


	--[ Inserting Userids Into Table ]--
	DECLARE @UserSplt TABLE 
	( 
		data INT 
	) 
	INSERT INTO @UserSplt 
	SELECT * 
	FROM Split(@SetUserids, ',')
	OPTION (MAXRECURSION 5000) 

	--max session
	DECLARE @MaxSesNumber INT
	IF(@SetMistrial=1)
	BEGIN
	SET @MaxSesNumber = (SELECT TOP 1 Count(shdmax.SessionNbr) AS MaxSessionCount
	FROM stdtsessionhdr shdmax
	WHERE studentid IN (SELECT stdtid
    FROM stdtclass WHERE stdtid IN (SELECT data FROM @StudSplt) AND ActiveInd = 'A') AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)
	AND [sessionstatuscd] = 'S'
	GROUP BY shdmax.ModifiedBy
	ORDER BY MaxSessionCount desc)
	END
	ELSE
	BEGIN
	SET @MaxSesNumber = (SELECT TOP 1 Count(shdmax.SessionNbr) AS MaxSessionCount
	FROM stdtsessionhdr shdmax
	WHERE studentid IN (SELECT stdtid
    FROM stdtclass WHERE stdtid IN (SELECT data FROM @StudSplt) AND ActiveInd = 'A') AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)
	AND [sessionstatuscd] = 'S' AND shdmax.SessMissTrailStus ='N'
	GROUP BY shdmax.ModifiedBy
	ORDER BY MaxSessionCount desc)
	END

	IF(@SetClassids IS NOT NULL AND @SetStudids IS NOT NULL AND @SetUserids IS NOT NULL)
	BEGIN
		-- [PRINT 'Class and Stuid'] --
		IF(@SetMistrial=1)
	BEGIN
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S'
				AND shd.StdtClassId IN (Select * from @ClassSplt) AND shd.StudentId IN(Select * from @StudSplt) AND shd.ModifiedBy IN(Select * from @UserSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		END
		else
		begin
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S' AND shd.SessMissTrailStus ='N'
				AND shd.StdtClassId IN (Select * from @ClassSplt) AND shd.StudentId IN(Select * from @StudSplt) AND shd.ModifiedBy IN(Select * from @UserSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
	END
	ELSE IF(@SetClassids IS NOT NULL AND @SetUserids IS NOT NULL)
	BEGIN
		-- [PRINT 'Only clasid'] --
		IF(@SetMistrial=1)
	BEGIN
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S'
				AND shd.StdtClassId IN (Select * from @ClassSplt) AND shd.ModifiedBy IN(Select * from @UserSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
		else
		begin
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc ) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S' AND shd.SessMissTrailStus ='N'
				AND shd.StdtClassId IN (Select * from @ClassSplt) AND shd.ModifiedBy IN(Select * from @UserSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
	END
	ELSE IF(@SetStudids IS NOT NULL AND @SetUserids IS NOT NULL)
	BEGIN
		-- [PRINT 'Only clasid'] --
		IF(@SetMistrial=1)
	BEGIN
		 SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S'
				AND shd.StudentId IN(Select * from @StudSplt) AND shd.ModifiedBy IN(Select * from @UserSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
		else
		begin
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S' AND shd.SessMissTrailStus ='N'
				AND shd.StudentId IN(Select * from @StudSplt) AND shd.ModifiedBy IN(Select * from @UserSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
	END
	ELSE
	BEGIN
		-- [PRINT 'Only Studid'] --
		IF(@SetMistrial=1)
	BEGIN
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S'
				--AND shd.StudentId IN(Select * from @StudSplt) 
				AND shd.StdtClassId IN (Select * from @ClassSplt) AND shd.StudentId IN(Select * from @StudSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
		else
		begin
		SELECT  shd.lessonplanid AS LessonPlanId,
		--(SELECT CASE
		--	WHEN Count(SessionNbr) <= 4 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--	ELSE (select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc)
		--END) AS LessonName,
		(SELECT CASE
				WHEN @MaxSesNumber > 35 THEN  (select TOP 1 SUBSTRING(DStemplatename, 1, 1) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >4 then (select TOP 1 SUBSTRING(DStemplatename, 1, 4) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )
				ELSE 
				case when @MaxSesNumber >1 then (select TOP 1 SUBSTRING(DStemplatename, 1, 25) from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc  )				
				else(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc )
				END end end) AS LessonName,
		Count(DISTINCT shd.lessonplanid) AS LessonCount,
		Count(SessionNbr) AS SessionCount,
		(select TOP 1 DStemplatename from DSTempHdr where LessonPlanid = shd.LessonPlanId order by dstemphdrid desc) AS LessonNameToolTip,
		shd.studentid AS StudentID,
		(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = studentid) AS StudentName,
		shd.ModifiedBy AS Staffid,
		(SELECT distinct (CONCAT(UserLName,', '+UserFName)) AS StaffName FROM [User] Where UserId = shd.ModifiedBy) AS StaffName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM   stdtsessionhdr shd
		WHERE  studentid IN(select distinct stdtid from stdtclass where ActiveInd = 'A')
				AND CONVERT(VARCHAR(10), ModifiedOn, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
				AND [sessionstatuscd] = 'S' AND shd.SessMissTrailStus ='N'
				--AND shd.StudentId IN(Select * from @StudSplt) 
				AND shd.StdtClassId IN (Select * from @ClassSplt) AND shd.StudentId IN(Select * from @StudSplt)
		GROUP BY shd.ModifiedBy,shd.studentid,shd.LessonPlanId
		ORDER BY StudentName
		end
	END

END

GO
