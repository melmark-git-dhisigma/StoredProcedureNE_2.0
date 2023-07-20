USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[SelectStudentPersonalDetails]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SelectStudentPersonalDetails]
@StdId int
as 
begin
select   StudentPersonalId,LastName+','+FirstName as studentPersonalName,Gender,BirthDate,ImageUrl,AdmissionDate,PlaceOfBirth,StateOfBirth,CountryOfBirth,CountryOfCitizenship,MaritalStatus,PrimaryLanguage,Height,Weight from StudentPersonal where StudentPersonalId=@StdId
end




GO
