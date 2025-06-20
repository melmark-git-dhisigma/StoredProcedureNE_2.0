USE [MelmarkNE]
GO
/****** Object:  StoredProcedure [dbo].[DashboardStaffClinicalNew]    Script Date: 4/25/2025 1:12:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

	CREATE PROCEDURE [dbo].[DashboardStaffClinicalNew] @ParamClassid VARCHAR(MAX) = NULL,
												   @ParamStudid VARCHAR(MAX) = NULL,
												   @ParamUserid VARCHAR(MAX) = NULL
	
	AS
	BEGIN
	
		SET NOCOUNT ON;

		DECLARE @SetClassids VARCHAR(MAX),
				@SetStudids	VARCHAR(MAX),
				@SetUserids	VARCHAR(MAX)
		SET @SetClassids = @ParamClassid
		SET @SetStudids = @ParamStudid
		SET @SetUserids = @ParamUserid

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
	SET @MaxSesNumber = (SELECT TOP 1 Count(b.FrequencyCount) AS MaxSessionCount
	FROM Behaviour b
	WHERE b.StudentId IN(SELECT data FROM @StudSplt) AND
	ClassId IN(SELECT ClassId FROM BehaviourDetails WHERE Measurementid = b.measurementid)AND b.FrequencyCount>0 AND
	CONVERT(VARCHAR(10), b.createdon, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)
	Group by b.ModifiedBy
	ORDER BY MaxSessionCount desc)

		IF(@SetClassids IS NOT NULL AND @SetStudids IS NOT NULL AND @SetUserids IS NOT NULL)
		BEGIN
			-- [PRINT 'Class and Stuid'] --
			SELECT (SELECT (CONCAT(UserLName,', '+UserFName)) FROM [USER] WHERE Userid = BHV.Observerid) AS StaffName,
			BHV.Observerid AS Staffid,
			BHVDET.ClassId AS Classid,
			(SELECT (CONCAT(LastName,', '+FirstName)) FROM StudentPersonal WHERE StudentPersonalId = BHV.StudentId) AS StudentName,
			BHV.StudentId AS StudentId,
			BHV.MeasurementId AS MeasurementId,
			CASE 
    WHEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN BHV.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (BHV.Duration IS NOT NULL AND BHV.Duration <> 0)
                   OR (BHV.YesOrNo IS NOT NULL AND BHV.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS MeasurementCount,
			(SELECT CASE
				WHEN Count(BHV.MeasurementId) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
				ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
			END) AS BehaviourName,
			(SELECT @MaxSesNumber) as MaxCount,
			BHVDET.Behaviour AS BehaviorNameToolTip 
			FROM Behaviour BHV INNER JOIN BehaviourDetails BHVDET
							ON BHV.MeasurementId = BHVDET.MeasurementId
			WHERE BHV.Observerid IN (Select * from @UserSplt) AND BHV.StudentId IN (Select * from @StudSplt) AND BHV.Classid IN (Select * from @ClassSplt) AND BHV.FrequencyCount>0 AND CONVERT(VARCHAR(10), BHV.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			GROUP BY BHV.Observerid,BHV.MeasurementId,BHV.StudentId,BHVDET.Behaviour,BHVDET.ClassId, BHV.TimeOfEvent
			ORDER BY StaffName
		END
		ELSE IF(@SetClassids IS NOT NULL AND @SetUserids IS NOT NULL)
		BEGIN
			-- [PRINT 'Only clasid'] --
			SELECT (SELECT (CONCAT(UserLName,', '+UserFName)) FROM [USER] WHERE Userid = BHV.Observerid) AS StaffName,
			BHV.Observerid AS Staffid,
			BHVDET.ClassId AS Classid,
			(SELECT (CONCAT(LastName,', '+FirstName)) FROM StudentPersonal WHERE StudentPersonalId = BHV.StudentId) AS StudentName,
			BHV.StudentId AS StudentId,
			BHV.MeasurementId AS MeasurementId,
			CASE 
    WHEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN BHV.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (BHV.Duration IS NOT NULL AND BHV.Duration <> 0)
                   OR (BHV.YesOrNo IS NOT NULL AND BHV.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS MeasurementCount,
			(SELECT CASE
				WHEN Count(BHV.MeasurementId) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
				ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
			END) AS BehaviourName,
			(SELECT @MaxSesNumber) as MaxCount,
			BHVDET.Behaviour AS BehaviorNameToolTip 
			FROM Behaviour BHV INNER JOIN BehaviourDetails BHVDET
							ON BHV.MeasurementId = BHVDET.MeasurementId
			WHERE BHV.Observerid IN (Select * from @UserSplt) AND BHV.Classid IN (Select * from @ClassSplt) AND BHV.FrequencyCount>0 AND CONVERT(VARCHAR(10), BHV.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			GROUP BY BHV.Observerid,BHV.MeasurementId,BHV.StudentId,BHVDET.Behaviour,BHVDET.ClassId, BHV.TimeOfEvent
			ORDER BY StaffName
		END
		ELSE IF(@SetStudids IS NOT NULL AND @SetUserids IS NOT NULL)
		BEGIN
			-- [PRINT 'Only clasid'] --
			SELECT (SELECT (CONCAT(UserLName,', '+UserFName)) FROM [USER] WHERE Userid = BHV.Observerid) AS StaffName,
			BHV.Observerid AS Staffid,
			BHVDET.ClassId AS Classid,
			(SELECT (CONCAT(LastName,', '+FirstName)) FROM StudentPersonal WHERE StudentPersonalId = BHV.StudentId) AS StudentName,
			BHV.StudentId AS StudentId,
			BHV.MeasurementId AS MeasurementId,
			CASE 
    WHEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN BHV.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (BHV.Duration IS NOT NULL AND BHV.Duration <> 0)
                   OR (BHV.YesOrNo IS NOT NULL AND BHV.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS MeasurementCount,
			(SELECT CASE
				WHEN Count(BHV.MeasurementId) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
				ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
			END) AS BehaviourName,
			(SELECT @MaxSesNumber) as MaxCount,
			BHVDET.Behaviour AS BehaviorNameToolTip 
			FROM Behaviour BHV INNER JOIN BehaviourDetails BHVDET
							ON BHV.MeasurementId = BHVDET.MeasurementId
			WHERE BHV.Observerid IN (Select * from @UserSplt) AND BHV.StudentId IN (Select * from @StudSplt) AND BHV.FrequencyCount>0 AND CONVERT(VARCHAR(10), BHV.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			GROUP BY BHV.Observerid,BHV.MeasurementId,BHV.StudentId,BHVDET.Behaviour,BHVDET.ClassId, BHV.TimeOfEvent
			ORDER BY StaffName
		END
		ELSE
		BEGIN
			-- [PRINT 'Only Studid'] --
			SELECT (SELECT (CONCAT(UserLName,', '+UserFName)) FROM [USER] WHERE Userid = BHV.Observerid) AS StaffName,
			BHV.Observerid AS Staffid,
			BHVDET.ClassId AS Classid,
			(SELECT (CONCAT(LastName,', '+FirstName)) FROM StudentPersonal WHERE StudentPersonalId = BHV.StudentId) AS StudentName,
			BHV.StudentId AS StudentId,
			BHV.MeasurementId AS MeasurementId,
			CASE 
    WHEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN BHV.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (BHV.Duration IS NOT NULL AND BHV.Duration <> 0)
                   OR (BHV.YesOrNo IS NOT NULL AND BHV.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS MeasurementCount,
			(SELECT CASE
				WHEN Count(BHV.MeasurementId) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
				ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
			END) AS BehaviourName,
			(SELECT @MaxSesNumber) as MaxCount,
			BHVDET.Behaviour AS BehaviorNameToolTip 
			FROM Behaviour BHV INNER JOIN BehaviourDetails BHVDET
							ON BHV.MeasurementId = BHVDET.MeasurementId
			WHERE BHV.StudentId IN (Select * from @StudSplt) AND BHV.FrequencyCount>0 AND CONVERT(VARCHAR(10), BHV.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			GROUP BY BHV.Observerid,BHV.MeasurementId,BHV.StudentId,BHVDET.Behaviour,BHVDET.ClassId, BHV.TimeOfEvent
			ORDER BY StaffName
		END
	END

GO
