USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[StudentMoreDetailsNE]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[StudentMoreDetailsNE]
@SchoolId int,
@StudentId int,
@Type  varchar(50)

AS
BEGIN

IF(@Type='SM')-- IDENTIFICATION --

	

	   	BEGIN

						 SELECT dbo.StudentPersonal.LastName+','+ dbo.StudentPersonal.FirstName+
						 CASE WHEN StudentPersonal.MiddleName IS NULL THEN '' ELSE ','+  StudentPersonal.MiddleName END as  Name,
						 CASE WHEN AddressList.StreetName IS NULL THEN '' ELSE AddressList.StreetName+'<br>' END +
 						 CASE WHEN dbo.AddressList.ApartmentType IS NULL THEN ''ELSE dbo.AddressList.ApartmentType+'<br>' END+
						 CASE WHEN dbo.AddressList.City IS NULL THEN '' ELSE dbo.AddressList.City+',' END+
						 CASE WHEN dbo.AddressList.StateProvince IS NULL THEN '' ELSE (SELECT LookupCode FROM LookUp WHERE LookupId= dbo.AddressList.StateProvince)+'  ' END+
						 CASE WHEN dbo.AddressList.PostalCode IS NULL THEN '' ELSE dbo.AddressList.PostalCode+'<br>' END +
						 CASE WHEN dbo.AddressList.[County] IS NULL THEN '' ELSE dbo.AddressList.[County]+',' END+
						 CASE WHEN dbo.AddressList.[CountryId] IS NULL THEN '' ELSE (SELECT LookupName FROM LookUp WHERE LookupId= dbo.AddressList.[CountryId]) END
						 as Address, 
						 dbo.StudentPersonal.NickName, 
						 CASE WHEN dbo.StudentPersonal.CitizenshipStatus=1014 THEN 'Dual national'
						  ELSE
						  CASE WHEN dbo.StudentPersonal.CitizenshipStatus=1015 THEN 'Non-resident alien'
						  ELSE
						  CASE WHEN dbo.StudentPersonal.CitizenshipStatus=1016 THEN 'Resident alien'
						  ELSE
						  CASE WHEN dbo.StudentPersonal.CitizenshipStatus=9999 THEN 'United States Citizen'
						  END END END END AS CountryOfCitizenship,
						  CONVERT(VARCHAR(10),dbo.StudentPersonal.BirthDate,101) as BirthDate  , 
						  dbo.StudentPersonal.Height, 
						  dbo.StudentPersonal.Weight, 
						  dbo.StudentPersonal.HairColor, 
						  dbo.StudentPersonal.EyeColor, 
                          dbo.StudentPersonal.PrimaryLanguage, 
						  dbo.StudentPersonal.DistingushingMarks,
                          dbo.StudentPersonal.MaritalStatusofBothParents, 
                          CASE WHEN dbo.StudentPersonal.Gender=1 THEN 'Male' ELSE 'Female' END AS Gender, 
						  CONVERT(VARCHAR(10),dbo.StudentPersonal.AdmissionDate,101) as  AdmissionDate,
						  CASE WHEN StudentPersonal.ModifiedOn IS NULL THEN CONVERT(VARCHAR(10),StudentPersonal.CreatedOn,101)
						  ELSE CONVERT(VARCHAR(10),StudentPersonal.ModifiedOn,101) END AS Updated,	
						  dbo.StudentPersonal.PlaceOfBirth,
						  dbo.StudentPersonal.ImageUrl,
						  dbo.StudentPersonal.LegalCompetencyStatus,dbo.StudentPersonal.GuardianShip,
						  dbo.StudentPersonal.OtherStateAgenciesInvolvedWithStudent,dbo.StudentPersonal.CaseManagerResidential,
						  dbo.StudentPersonal.CaseManagerEducational,
						  LookUp.LookupName as Race,
						  CONVERT(VARCHAR(10),dbo.StudentPersonal.Photodate,101) AS Photodate,
					     (SELECT dbo.ContactPersonal.LastName+','+
					      dbo.ContactPersonal.FirstName+
					      CASE WHEN ContactPersonal.MiddleName IS NULL THEN '' ELSE +','+ContactPersonal.MiddleName END
					      FROM ContactPersonal WHERE ContactPersonal.ContactPersonalId IN (SELECT ContactPersonalId FROM StudentContactRelationship 
					      WHERE RELATIONSHIPID IN (SELECT LookupId FROM [LOOKUP] WHERE LookupName='Educational Surrogate'))
						  AND ContactPersonal.StudentPersonalId=@StudentId)AS EducationalSurrogate			   				   
					      -- CONVERT(VARCHAR(10),StudentPersonal.ModifiedOn,101) AS Updated,
					      -- FORMAT(StudentPersonal.ModifiedOn,'MM/yyyy') as modified
                     FROM dbo.StudentPersonal INNER JOIN
                         dbo.StudentAddresRel ON dbo.StudentPersonal.StudentPersonalId = dbo.StudentAddresRel.StudentPersonalId 
			  INNER JOIN dbo.AddressList ON dbo.StudentAddresRel.AddressId = dbo.AddressList.AddressId 
			  LEFT JOIN  dbo.LookUp ON dbo.StudentPersonal.RaceId = dbo.LookUp.LookupId 
				  WHERE  dbo.StudentAddresRel.ContactSequence=0 AND StudentPersonal.StudentType='Client' 
						 AND dbo.StudentPersonal.SchoolId=@SchoolId AND dbo.StudentPersonal.StudentPersonalId=@StudentId


	END

ELSE IF(@Type='ED')-- EMERGENCY CONTACT PERSONAL --

	BEGIN
					 SELECT LK.LookupName as Relation,
					        CP.LastName+','+cp.FirstName as Name,
							CP.PrimaryLanguage,
					        CASE WHEN AL.StreetName IS NULL THEN '' ELSE AL.StreetName+',' END+
					        CASE WHEN AL.ApartmentType IS NULL THEN '' ELSE AL.ApartmentType+',' END+
					        CASE WHEN AL.City IS NULL THEN '' ELSE AL.City END AS Address,
							AL.Phone,
							AL.OtherPhone,
							AL.PrimaryEmail 
					   FROM AddressList AL
					INNER JOIN [StudentAddresRel] ADR ON ADR.AddressId=AL.AddressId
					INNER JOIN StudentPersonal SP ON ADR.StudentPersonalId=SP.StudentPersonalId
					LEFT JOIN ContactPersonal CP ON ADR.ContactPersonalId=CP.ContactPersonalId
					INNER JOIN  StudentContactRelationship SCR on SCR.ContactPersonalId=CP.ContactPersonalId
					INNER JOIN  LookUp LK on LK.LookupId=SCR.RelationshipId
					  WHERE SP.SchoolId=@SchoolId AND 
					        SP.StudentPersonalId=@StudentId AND 
						    ContactSequence=1 AND
						    CP.IsEmergency=1 and cp.Status=1
	END

ELSE IF(@Type='SD')-- EMERGENCY CONTACT SCHOOL --

	BEGIN
					Select EC.FirstName+' '+EC.LastName+','+EC.Title as FullName,
					       EC.Phone 
			     	  FROM EmergencyContactSchool EC  
					 WHERE EC.StudentPersonalId=@StudentId And 
					       EC.SchoolId=@SchoolId

	END

ELSE IF(@Type='PP')-- PRIMARY PHYSICIAN --

		BEGIN		

					   SELECT CASE WHEN MI.LastName IS NULL THEN ''ELSE MI.LastName +',' END+ 
				       MI.FirstName as  Name ,
				       OfficePhone,
					   CASE WHEN Adr.StreetName IS NULL THEN '' ELSE Adr.StreetName+',' END+
					   CASE WHEN Adr.ApartmentType IS NULL THEN '' ELSE Adr.ApartmentType+',' END+
					   CASE WHEN Adr.City IS NULL THEN '' ELSE Adr.City+',' END+
					   CASE WHEN Adr.PostalCode IS NULL THEN '' ELSE Adr.PostalCode END AS Address
				  FROM MedicalAndInsurance MI 
			left Join AddressList Adr on MI.AddressId=Adr.AddressId 
				 WHERE SchoolId=@SchoolId And 
				       StudentPersonalId=@StudentId
		
		END

ELSE IF(@Type='IN' OR @Type='INEX')-- MEDICAL AND INSURANCE --

		BEGIN
	
			SELECT InsuranceType,
			       PolicyNumber,
				   PolicyHolder 
			  FROM Insurance 
		     WHERE SchoolId=@SchoolId And 
			       StudentPersonalId=@StudentId
		
		END
		
--ELSE IF(@Type='INEX')-- Medical and Insurance Export --

--		BEGIN
	
--			SELECT InsuranceType,
--			       PolicyNumber,
--				   PolicyHolder 
--			  FROM Insurance 
--		     WHERE SchoolId=0 And 
--			       StudentPersonalId=@StudentId and 
--				   PreferType='Primary'
		
--		END

ELSE IF(@Type='MT')-- Medical and Insurance3 --

		BEGIN

				Select  TOP 1 CONVERT(VARCHAR(10),MI.DateOfLastPhysicalExam,101) as DateOfLastPhysicalExam,
				        DG.Diaganoses AS MedicalConditionsDiagnosis,
						SP.Allergies,
						MI.CurrentMedications,
						MI.SelfPreservationAbility,
					    MI.SignificantBehaviorCharacteristics,
						MI.Capabilities,
						MI.Limitations,
						MI.Preferances 
				   FROM MedicalAndInsurance MI
				   INNER JOIN StudentPersonalPA SP ON MI.StudentPersonalId=SP.StudentPersonalId
				   INNER JOIN DiaganosesPA DG ON MI.StudentPersonalId=DG.StudentPersonalId
				 WHERE SP.SchoolId=@SchoolId And 
				       SP.StudentPersonalId=@StudentId
		END

ELSE IF(@Type='SA')--School Attended--

		BEGIN

				Select SchoolName,
				       CONVERT(VARCHAR(10),DateFrom,101)+'-'+
					   CASE WHEN CONVERT(VARCHAR(10),DateTo,101) IS NULL
					   THEN 'Present' ELSE  CONVERT(VARCHAR(10),DateTo,101) END as DateAttended,
					   CASE WHEN Address1 IS NULL THEN '' ELSE Address1+',' END +
					   CASE WHEN Address2 IS NULL THEN '' ELSE Address2+',' END + 
					   CASE WHEN City IS NULL THEN '' ELSE City+',' END + 
					   CASE WHEN State IS NULL THEN '' ELSE 
					  (SELECT LookupName FROM LookUp WHERE LookupId=State) END	as Address 
				  FROM SchoolsAttended 
				 WHERE SchoolId=@SchoolId And 
				       StudentPersonalId=@StudentId

		END

ELSE IF(@Type='DD')--Education History--

		BEGIN

				Select CONVERT(VARCHAR(10),DateInitiallyEligibleforSpecialEducation,101) as DateInitiallyEligibleforSpecialEducation, 
					   CONVERT(VARCHAR(10),DateofMostRecentSpecialEducationEvaluations,101) as DateofMostRecentSpecialEducationEvaluations ,
					   CONVERT(VARCHAR(10),DateofNextScheduled3YearEvaluation,101) as DateofNextScheduled3YearEvaluation,
					   CONVERT(VARCHAR(10),CurrentIEPStartDate,101) as CurrentIEPStartDate,
					   CONVERT(VARCHAR(10),CurrentIEPExpirationDate,101) as CurrentIEPExpirationDate
				  FROM StudentPersonal 
				 WHERE SchoolId=@SchoolId And 
				       StudentPersonalId=@StudentId

		END

ELSE IF(@Type='DI')--Dicharge Information--

		BEGIN

				Select CONVERT(VARCHAR(10),DischargeDate,101) as DischargeDate,
				       LocationAfterDischarge,
					   MelmarkNewEnglandsFollowUpResponsibilities 
				  FROM StudentPersonal 
				 WHERE SchoolId=@SchoolId And 
				       StudentPersonalId=@StudentId

		END

ELSE IF(@Type='IEP')--IEP

		BEGIN

				Select  IEPReferralFullName+','+IEPReferralTitle AS Name,
				        IEPReferralPhone,
						IEPReferralReferrinAgency AS RAgency,
						IEPReferralSourceofTuition AS RTuition 
				   FROM StudentPersonal
				  WHERE SchoolId=@SchoolId And 
				        StudentPersonalId=@StudentId

		END

END














GO
