USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[StudentBasicDetailsNE]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[StudentBasicDetailsNE]
@SchoolId int,
@StudentId int

AS
BEGIN

                  SELECT dbo.StudentPersonal.LastName+','+ dbo.StudentPersonal.FirstName+','+ dbo.StudentPersonal.MiddleName as  Name,
				         dbo.AddressList.AddressLine1+','+AddressList.AddressLine2+','+AddressList.AddressLine3 as Address, dbo.StudentPersonal.NickName, 
						 dbo.StudentPersonal.CountryOfCitizenship,
                         dbo.StudentPersonal.BirthDate, dbo.StudentPersonal.Height, dbo.StudentPersonal.Weight, dbo.StudentPersonal.HairColor, dbo.StudentPersonal.EyeColor, 
                         dbo.StudentPersonal.MaritalStatus, dbo.StudentPersonal.PrimaryLanguage, dbo.StudentPersonal.DistingushingMarks, 
                         dbo.StudentPersonal.MaritalStatusofBothParents, dbo.StudentPersonal.StudentType, dbo.StudentPersonal.SchoolId, dbo.StudentPersonal.ImageUrl, 
                         dbo.StudentPersonal.Gender, dbo.StudentPersonal.AdmissionDate, dbo.StudentAddresRel.ContactSequence,LookUp.LookupName as Race
                  FROM   dbo.StudentPersonal INNER JOIN
                         dbo.StudentAddresRel ON dbo.StudentPersonal.StudentPersonalId = dbo.StudentAddresRel.StudentPersonalId INNER JOIN
                         dbo.AddressList ON dbo.StudentAddresRel.AddressId = dbo.AddressList.AddressId INNER JOIN
                         dbo.LookUp ON dbo.StudentPersonal.RaceId = dbo.LookUp.LookupId 
				  Where  dbo.StudentAddresRel.ContactSequence=0 And StudentPersonal.StudentType='Client' 
						 And dbo.StudentPersonal.SchoolId=@SchoolId And dbo.StudentPersonal.StudentPersonalId=@StudentId

END










GO
