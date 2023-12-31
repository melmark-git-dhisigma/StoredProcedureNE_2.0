USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertLesson]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertLesson]
	-- Add the parameters for the stored procedure here
	 @lessonName varchar(100),
	 @description varchar(MAX),
	 @keyword varchar(MAX),
	 @domain varchar(MAX),
	 @category varchar(MAX),
	 @discreate varchar(MAX),
	 @setNumber int,
	 @stepNumber int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE  @lessonId int  
  
   BEGIN 
   try
   begin transaction
    -- Insert statements for procedure here
	INSERT into LE_Lesson(LessonName,Description,Keyword,LessonType,DomainId,NmbrSet,NmbrStep,IsDiscreate) VALUES(@lessonName,@description,@keyword,@category,@domain,@setNumber,@stepNumber,@discreate)

	SELECT @lessonId = SCOPE_IDENTITY()

	INSERT INTO LE_LessonDetails(LessonId,SetValue,StepValue) VALUES(@lessonId,@setNumber,@stepNumber) 
		
	commit
  END try

  BEGIN catch
  RollBack
  END catch
END











GO
