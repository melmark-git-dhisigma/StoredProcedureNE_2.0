USE [MelmarkNE]
GO
/****** Object:  StoredProcedure [dbo].[DashboardClientClinicalNew]    Script Date: 4/25/2025 1:12:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[DashboardClientClinicalNew] @ParamClassid VARCHAR(MAX) = NULL,
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

	--max session
	DECLARE @MaxSesNumber INT
	SET @MaxSesNumber = (SELECT TOP 1 Count(b.MeasurementId) AS MaxSessionCount
	FROM Behaviour b
	WHERE b.StudentId IN(SELECT data FROM @StudSplt) AND
	ClassId IN(SELECT ClassId FROM BehaviourDetails WHERE Measurementid = b.measurementid)AND b.FrequencyCount>0 AND
	CONVERT(VARCHAR(10), b.createdon, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)
	Group by b.studentid
	ORDER BY MaxSessionCount desc)

	--SELECT data FROM @StudSplt

	IF(@SetClassids IS NOT NULL AND @SetStudids IS NOT NULL)
	BEGIN
		-- [PRINT 'Class and Stuid'] --
		SELECT 
			BHV.MeasurementId AS MeasurementId,
			BHV.StudentId AS StudentId,
			(SELECT classid FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) AS Classid,
			CASE 
    WHEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN BHV.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (BHV.Duration IS NOT NULL AND BHV.Duration <> 0)
                   OR (BHV.YesOrNo IS NOT NULL AND BHV.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS BehaviourSession,
			(SELECT CASE
				WHEN Count(BHV.MeasurementId) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
				ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
			END) AS BehaviourName,
			BHVDET.Behaviour AS BehaviorNameToolTip ,
			(SELECT (CONCAT(LastName,', '+FirstName)) FROM StudentPersonal WHERE StudentPersonalId = BHV.StudentId) AS StudentName,
			(SELECT @MaxSesNumber) as MaxCount
			FROM Behaviour BHV INNER JOIN BehaviourDetails BHVDET
							ON BHV.MeasurementId = BHVDET.MeasurementId
			WHERE BHV.StudentId IN (SELECT data FROM @StudSplt) AND BHV.Classid IN (SELECT data FROM @ClassSplt) AND BHV.FrequencyCount>0 AND CONVERT(VARCHAR(10), BHV.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
			GROUP BY BHV.Observerid,BHV.MeasurementId,BHV.StudentId,BHVDET.Behaviour,BHVDET.ClassId
			ORDER BY StudentName
	END
	ELSE IF(@SetClassids IS NOT NULL AND @SetStudids IS NULL)
	BEGIN
		-- [PRINT 'Only clasid'] --
		SELECT 
		BHV.MeasurementId AS MeasurementId,
		BHV.StudentId AS StudentId,
		BHVDET.ClassId AS Classid,
		CASE 
    WHEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN BHV.FrequencyCount IS NOT NULL THEN BHV.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (BHV.Duration IS NOT NULL AND BHV.Duration <> 0)
                   OR (BHV.YesOrNo IS NOT NULL AND BHV.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS BehaviourSession,
		(SELECT CASE
			WHEN Count(BHV.MeasurementId) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
			ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = BHV.MeasurementId) 
		END) AS BehaviourName,
		BHVDET.Behaviour AS BehaviorNameToolTip,
		(SELECT (CONCAT(LastName,', '+FirstName)) FROM StudentPersonal WHERE StudentPersonalId = BHV.StudentId) AS StudentName,
		(SELECT @MaxSesNumber) as MaxCount
		FROM Behaviour BHV INNER JOIN BehaviourDetails BHVDET
						ON BHV.MeasurementId = BHVDET.MeasurementId
		WHERE  BHV.Classid IN (SELECT data FROM @ClassSplt) AND BHV.FrequencyCount>0 AND CONVERT(VARCHAR(10), BHV.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120)
		GROUP BY BHV.Observerid,BHV.MeasurementId,BHV.StudentId,BHVDET.Behaviour,BHVDET.ClassId
		ORDER BY StudentName
	END
	ELSE
	BEGIN
		-- [PRINT 'Only Studid'] --
		SELECT 
			b.Measurementid,
			b.Studentid,
			(SELECT classid FROM BehaviourDetails WHERE MeasurementId = b.MeasurementId) AS Classid,
			(SELECT CASE 
    WHEN SUM(CASE WHEN b.FrequencyCount IS NOT NULL THEN 1 ELSE 0 END) > 0 
         THEN SUM(CASE WHEN b.FrequencyCount IS NOT NULL THEN b.FrequencyCount ELSE 0 END)
    WHEN SUM(CASE WHEN (b.Duration IS NOT NULL AND b.Duration <> 0)
                   OR (b.YesOrNo IS NOT NULL AND b.YesOrNo <> 0) 
              THEN 1 ELSE 0 END) > 0 
         THEN 1
    ELSE 0
END AS BehaviourSession) AS BehaviourSession,
			(SELECT CASE
				WHEN Count(Behaviourid) <= 4 THEN (SELECT SUBSTRING(Behaviour, 1, 4) FROM BehaviourDetails WHERE MeasurementId = b.MeasurementId) 
				ELSE (SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = b.MeasurementId) 
			END) AS BehaviourName,
			(SELECT Behaviour FROM BehaviourDetails WHERE MeasurementId = b.MeasurementId) AS BehaviourNameToolTip,	
			(SELECT CONCAT(lastname,+', '+FirstName) FROM StudentPersonal WHERE StudentPersonalID = b.studentid) AS StudentName,
			(SELECT @MaxSesNumber) as MaxCount
		FROM Behaviour b 
		WHERE b.StudentId IN(SELECT data FROM @StudSplt) AND 
		ClassId IN(SELECT ClassId FROM BehaviourDetails WHERE Measurementid = b.measurementid)AND b.FrequencyCount>0 AND
		CONVERT(VARCHAR(10), b.createdon, 120) = CONVERT(VARCHAR(10), Getdate(), 120) 
		Group by b.MeasurementId,b.studentid
		order by StudentName
	END
END

GO
