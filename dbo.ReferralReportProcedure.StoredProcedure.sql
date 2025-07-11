USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ReferralReportProcedure]    Script Date: 6/17/2025 3:00:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReferralReportProcedure]
@SchoolID int
AS
BEGIN
	
	SET NOCOUNT ON;
	IF(@SchoolID=1) --SchoolId 1 for NE
 BEGIN



      SELECT
	  [StudentType]
     ,SD.[StudentPersonalId]
     ,[LocalId] 
     ,SD.LastName+','+SD.FirstName AS studentPersonalName  
	 --,CP.LastName+','+CP.FirstName AS contactPersonalName
     ,[SocialSecurityNo]
	 --,CP.Relation
	 --,CP.Age AS contactAge
	 --,CP.Occupation
	 --,CP.Spouse
	 --,CP.Gender AS contactGender
	 --,CP.MaritalStatus
	 --,CP.CauseDeath
     ,CASE WHEN [ImageUrl] IS NULL OR [ImageUrl]='' THEN CASE WHEN SD.Gender=1 THEN 
	 (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M')
      ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F')
      END ELSE [ImageUrl] END AS [ImageUrl]
     ,CASE WHEN SD.Gender=1 THEN 'Male' 
      ELSE  'Female'
      END Gender
	 ,CONVERT(VARCHAR(10), SD.[BirthDate], 101) AS [BirthDate]   
	 ,CONVERT(VARCHAR(10), SD.[AdmissionDate], 101) AS [DateOfReferral]   
	 ,ADL.AddressLine1
	 ,ADL.StreetName
	 ,ADL.City
	 ,ADL.StateProvince
	 ,(SELECT LookupName FROM LookUp WHERE LookupType = 'State' AND LookupId = ADL.StateProvince) AS [State]
	 ,CASE WHEN DATEPART(MM,SD.BirthDate)>= 01 AND DATEPART(MM,SD.BirthDate)<= 03 THEN 1 ELSE 
	 CASE WHEN DATEPART(MM,SD.BirthDate)>= 04 AND DATEPART(MM,SD.BirthDate)<= 06 THEN 2 ELSE
	 CASE WHEN DATEPART(MM,SD.BirthDate)>= 07 AND DATEPART(MM,SD.BirthDate)<= 09 THEN 3 ELSE 4 END END END AS mMonth
	 ,DATEDIFF(YEAR,SD.BirthDate,GETDATE()) 
	 -
     (CASE
      WHEN DATEADD(YY,DATEDIFF(YEAR,SD.BirthDate,GETDATE()),SD.BirthDate)
            >  GETDATE() THEN 1
      ELSE 0 END) AS Age
     ,SD.[PlaceOfBirth]
     ,[Height]
     ,[Weight]
	 --,PL.[PlacementType]
	 --,PL.[Department]
	 --,PL.[BehaviorAnalyst]
	 --,PL.[PrimaryNurse]
      FROM  [dbo].[StudentPersonal] SD
	  --LEFT JOIN Placement PL ON PL.StudentPersonalId=SD.StudentPersonalId
	  INNER JOIN StudentAddresRel SDR ON SDR.StudentPersonalId=SD.StudentPersonalId
	  INNER JOIN AddressList ADL ON ADL.AddressId=SDR.AddressId
	  --LEFT JOIN ContactPersonal CP ON SD.StudentPersonalId=CP.StudentPersonalId	 	  
	  WHERE StudentType='Referral' AND SD.SchoolId=@SchoolID AND SDR.ContactSequence=0
	  ORDER BY SD.[AdmissionDate] DESC
	  
 END
   ELSE
   BEGIN

      SELECT
	  SD.[StudentType]
     ,SD.[StudentPersonalId]
     ,SD.[LocalId] 
     ,SD.LastName+','+SD.FirstName AS studentPersonalName  
	 --,CP.LastName+','+CP.FirstName AS contactPersonalName
     ,SD.[SocialSecurityNo]
	 --,CP.Relation
	 --,CP.Age AS contactAge
	 --,CP.Occupation
	 --,CP.Spouse
	 --,CP.Gender AS contactGender
	 --,CP.MaritalStatus
	 --,CP.CauseDeath
     ,CASE WHEN [ImageUrl] IS NULL OR [ImageUrl]='' THEN CASE WHEN SD.Gender=1 THEN 
	 (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M') 
      ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F') 
      END ELSE [ImageUrl] END AS [ImageUrl]
     ,CASE WHEN SD.Gender=1 THEN 'Male' 
      ELSE  'Female'
      END Gender
     ,CONVERT(VARCHAR(10), SD.[BirthDate], 101) AS [BirthDate]    
	 ,CONVERT(VARCHAR(10), SD.[AdmissionDate], 101) AS [DateOfReferral]   
	 ,CASE WHEN DATEPART(MM,SD.BirthDate)>= 01 AND DATEPART(MM,SD.BirthDate)<= 03 THEN 1 ELSE 
	 CASE WHEN DATEPART(MM,SD.BirthDate)>= 04 AND DATEPART(MM,SD.BirthDate)<= 06 THEN 2 ELSE
	 CASE WHEN DATEPART(MM,SD.BirthDate)>= 07 AND DATEPART(MM,SD.BirthDate)<= 09 THEN 3 ELSE 4 END END END AS mMonth
	 
	 ,DATEDIFF(YEAR,SD.BirthDate,GETDATE())
     -
     (CASE
      WHEN DATEADD(YY,DATEDIFF(YEAR,SD.BirthDate,GETDATE()),SD.BirthDate)
            >  GETDATE() THEN 1
      ELSE 0 END) AS Age
     ,SD.[PlaceOfBirth]
     ,SD.[Height]
     ,SD.[Weight]
     ,STDPA.NeedForExtraHelp
     ,STDPA.Allergies
     ,STDPA.GeneralInformation
     ,STDPA.StudentPersonalPAId
	 ,ADL.AddressLine1
	 ,ADL.StreetName
	 ,ADL.CITY
	 ,ADL.StateProvince
	 ,(SELECT LookupName FROM LookUp WHERE LookupType = 'State' AND LookupId = ADL.StateProvince) AS [State]
	 ,CONVERT(VARCHAR(10), SD.[AdmissionDate], 101) AS [DateOfReferral]     
	 --,PL.[PlacementType]
	 --,PL.[Department]
	 --,PL.[BehaviorAnalyst]
	 --,PL.[PrimaryNurse]
     FROM StudentPersonal SD
	 --INNER JOIN Placement PL ON PL.StudentPersonalId=SD.StudentPersonalId
     INNER JOIN StudentAddresRel SDR ON SDR.StudentPersonalId=SD.StudentPersonalId
	 INNER JOIN AddressList ADL ON ADL.AddressId=SDR.AddressId
     LEFT JOIN StudentPersonalPA STDPA ON SD.StudentPersonalId=STDPA.StudentPersonalId
	 --LEFT JOIN ContactPersonal CP ON SD.StudentPersonalId=CP.StudentPersonalId
	  WHERE SD.StudentType='Referral' AND SD.SchoolId=@SchoolID AND SDR.ContactSequence=0
	  ORDER BY SD.[AdmissionDate] DESC
  END
END



GO
