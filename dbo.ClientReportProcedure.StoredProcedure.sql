USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ClientReportProcedure]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ClientReportProcedure]
@SchoolType varchar(10)
AS
BEGIN
	
	SET NOCOUNT ON;
	IF(@SchoolType='NE')

	BEGIN
		SELECT 
		SD.StudentPersonalId
		,SD.SchoolId
		,SD.LastName+','+SD.FirstName AS studentPersonalName
		,CASE WHEN [ImageUrl] IS NULL OR [ImageUrl]='' THEN CASE WHEN SD.Gender=1 THEN 
		(SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M') 
		ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F') 
		END ELSE [ImageUrl] END AS [ImageUrl]
		,CONVERT(VARCHAR(10), SD.[BirthDate], 101) AS BirthDate
		,SD.[PlaceOfBirth]
		,SD.[CountryOfBirth]
		,[Height]
		,[Weight]		
		,(SELECT  LookupName FROM LookUp WHERE LookupId=PL.PlacementType) AS PlacementType
		,(SELECT LookupName FROM LookUp WHERE LookupId=PL.Department) AS [Department]
		,(SELECT LookupName FROM LookUp WHERE LookupId=PL.BehaviorAnalyst) AS [BehaviorAnalyst]
		,(SELECT LookupName FROM LookUp WHERE LookupId=PL.PrimaryNurse) AS [PrimaryNurse]
		,EC.LastName+','+EC.FirstName AS emerContact
		,EC.Title
		,EC.Phone
		,DATEDIFF(YEAR,SD.BirthDate,GETDATE()) 
		-
		(CASE WHEN DATEADD(YY,DATEDIFF(YEAR,SD.BirthDate,GETDATE()),SD.BirthDate) >  GETDATE() THEN 1
		ELSE 0 END) AS Age

		,CASE WHEN DATEPART(MM,SD.BirthDate)>= 01 AND DATEPART(MM,SD.BirthDate)<= 03 THEN 1 ELSE 
		CASE WHEN DATEPART(MM,SD.BirthDate)>= 04 AND DATEPART(MM,SD.BirthDate)<= 06 THEN 2 ELSE
		CASE WHEN DATEPART(MM,SD.BirthDate)>= 07 AND DATEPART(MM,SD.BirthDate)<= 09 THEN 3 ELSE 4 END END END AS mMonth
		,CASE WHEN SD.Gender=1 THEN 'Male'
		ELSE 'Female'
		END Gender
	 
		FROM StudentPersonal SD
		LEFT JOIN Placement PL ON PL.StudentPersonalId=SD.StudentPersonalId
		LEFT JOIN EmergencyContactSchool EC ON EC.StudentPersonalId=SD.StudentPersonalId
		--INNER JOIN ContactPersonal CP ON SD.StudentPersonalId=CP.StudentPersonalId
		WHERE StudentType='Client '
	
	END
	ELSE
	BEGIN
		SELECT
		SD.StudentPersonalId
		,SD.SchoolId
		,LastName+','+FirstName AS studentPersonalName
		,CASE WHEN [ImageUrl] IS NULL OR [ImageUrl]='' THEN CASE WHEN SD.Gender=1 THEN 
		(SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M') 
		ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F') 
		END ELSE [ImageUrl] END AS [ImageUrl]
		,CONVERT(VARCHAR(10), SD.[BirthDate], 101) AS BirthDate
		,[Gender]
		,[PlaceOfBirth]
		,[CountryOfBirth]
		,[Height]
		,[Weight]
		,SDPA.[NeedForExtraHelp]
		,SDPA.[Diet]
		,SDPA.[GeneralInformation]
		,(SELECT  LookupName FROM LookUp WHERE LookupId=PL.PlacementType) AS PlacementType
		,(SELECT LookupName FROM LookUp WHERE LookupId=PL.Department) AS [Department]
		,(SELECT LookupName FROM LookUp WHERE LookupId=PL.BehaviorAnalyst) AS [BehaviorAnalyst]
		,(SELECT LookupName FROM LookUp WHERE LookupId=PL.PrimaryNurse) AS [PrimaryNurse]
		,CASE WHEN Gender=1 THEN 'Male'
		ELSE 'Female'
		END
		,[BirthDate]
		,DATEDIFF(YEAR,SD.BirthDate,GETDATE()) 
		-
		(CASE
		WHEN DATEADD(YY,DATEDIFF(YEAR,SD.BirthDate,GETDATE()),SD.BirthDate) >  GETDATE() THEN 1
		ELSE 0 END) AS Age

		,CASE WHEN DATEPART(MM,SD.BirthDate)>= 01 AND DATEPART(MM,SD.BirthDate)<= 03 THEN 1 ELSE 
		CASE WHEN DATEPART(MM,SD.BirthDate)>= 04 AND DATEPART(MM,SD.BirthDate)<= 06 THEN 2 ELSE
		CASE WHEN DATEPART(MM,SD.BirthDate)>= 07 AND DATEPART(MM,SD.BirthDate)<= 09 THEN 3 ELSE 4 END END END AS mMonth
	
		FROM StudentPersonal SD
		LEFT JOIN StudentPersonalPA SDPA ON SDPA.StudentPersonalId=SD.StudentPersonalId
		LEFT JOIN Placement PL ON PL.StudentPersonalId=SD.StudentPersonalId
		WHERE StudentType='Client'
	
	END
   
END




GO
