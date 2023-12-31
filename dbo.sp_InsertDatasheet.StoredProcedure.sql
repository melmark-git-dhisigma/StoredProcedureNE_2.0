USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertDatasheet]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertDatasheet]
	-- Add the parameters for the stored procedure here
	
	 @SchoolId int,	 @StudentId int, @LessonPlanId int,	 @TeachingProcId int, @TemplateName varchar(250), @NmbrOfTrials int,
	 @ChainType varchar(100), @PromptTypeID int, @StatusID int, @IsVisualTool varchar(100), @CreatedBy varchar(100),
	 @Prompt1 varchar(100), @Prompt2 varchar(100), @Prompt3 varchar(100), 
	 @Set1 varchar(100), @Set2 varchar(100), @Set3 varchar(100),
	 @Step1 varchar(100), @Step2 varchar(100), @Step3 varchar(100),
	 @Measure1Name varchar(100), @Measure1Type varchar(100), @Measure1CorrectAnswer varchar(100),@mistrial1 bit, @Measure2Name varchar(100),
	 @Measure2Type varchar(100), @Measure2CorrectAnswer varchar(100),@mistrial2 bit,
	-- @RuleType varchar(100),@CriteriaType varchar(100),@IOA bit,@MultiTchr bit,@Concecutive bit, @ReqScore int,@TotInstance int, @TotCorectInst int,
	 @GoalId int,@AsmtYearId int,@IncIEP bit,@LessonStatID int
	 

	
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE  @TempHdrId int,@PromptCount int =3,@count int =1,@PromptName varchar(100),@SetName varchar(100),@StepName varchar(100),
			 @SetCount int =3,@StepCount int =3, @SetID int,@StpCount int,@ColCount int=2,@MeasureName varchar(100),@MeasureType varchar(100),
			 @MeasureCorrectAnswer varchar(100),@DSSetColID int,@DSSetColCalcId int,@LesPlanId int,@mistrial bit
   BEGIN 
   try
   begin transaction
    -- Insert statements for procedure here
	INSERT INTO StdtLessonPlan(SchoolId,StudentId,LessonPlanId,GoalId,AsmntYearId,IncludeIEP,ActiveInd,StatusId,CreatedBy,CreatedOn)
	VALUES(@SchoolId,@StudentId,@LessonPlanId,@GoalId,@AsmtYearId,@IncIEP,'A',@LessonStatID,@CreatedBy,GETDATE())
	
	INSERT into DSTempHdr(SchoolId,StudentId,LessonPlanId,TeachingProcId,DSTemplateName,
	NbrOfTrials,SkillType,PromptTypeId,StatusId,IsVisualTool,CreatedBy,CreatedOn)
	VALUES(@SchoolId,@StudentId,@LessonPlanId,@TeachingProcId,@TemplateName,@NmbrOfTrials,@ChainType,
	@PromptTypeID,@StatusID,@IsVisualTool,@CreatedBy,GETDATE())
	
	SELECT @TempHdrId = SCOPE_IDENTITY()
	 WHILE(@PromptCount > 0)
	   BEGIN
			  if(@count=1)
			  BEGIN 
			  set @PromptName=@Prompt1
			  END
			  else if(@count=2)
			  BEGIN 
			  set @PromptName=@Prompt2
			  END
			  else if(@count=3)
			  BEGIN 
			  set @PromptName=@Prompt3
			  END
			  INSERT INTO DSTempPrompt(DSTempHdrId,PromptId,PromptOrder,ActiveInd,CreatedBy,CreatedOn)
			  VALUES(@TempHdrId,(select LookUp.LookupId from LookUp where LookupName=@PromptName),@count,'A',@CreatedBy,GETDATE())
			  SET @count=@count+1
			  SET @PromptCount=@PromptCount-1;

	   END
	   

	   SET @count=1
	   SET @SetCount=3
	   WHILE(@SetCount > 0)
	   BEGIN
			  if(@count=1)
			  BEGIN 
			  set @SetName=@Set1
			  END
			  else if(@count=2)
			  BEGIN 
			  set @SetName=@Set2
			  END
			  else if(@count=3)
			  BEGIN 
			  set @SetName=@Set3
			  END
			  INSERT INTO DSTempSet(SchoolId,DSTempHdrId,SetCd,SortOrder,ActiveInd,CreatedBy,CreatedOn)
			  VALUES(@SchoolId,@TempHdrId,@SetName,@count,'A',@CreatedBy,GETDATE())
			  SELECT @SetID = SCOPE_IDENTITY()

		 SET @StpCount=1
		 SET @StepCount=3
		 WHILE(@StepCount > 0)
			BEGIN
				if(@StpCount=1)
				BEGIN 
				set @StepName=@Step1
				END
				else if(@StpCount=2)
				BEGIN 
				set @StepName=@Step2
				END
				else if(@StpCount=3)
				BEGIN 
				set @StepName=@Step3
				END
				INSERT INTO DSTempStep(SchoolId,DSTempHdrId,DSTempSetId,StepCd,SortOrder,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@TempHdrId,@SetID,@StepName,@StpCount,'A',@CreatedBy,GETDATE())
				SET @StpCount=@StpCount+1
				SET @StepCount=@StepCount-1;
	        END	
			 
			  SET @SetCount=@SetCount-1
			  SET @count=@count+1 

	   END	
	  
	   SET @count=1

	   WHILE(@ColCount > 0)
	   BEGIN
			  if(@count=1)
			  BEGIN 
			  set @MeasureName=@Measure1Name
			  set @MeasureType=@Measure1Type
			  set @MeasureCorrectAnswer=@Measure1CorrectAnswer
			  set @mistrial=@mistrial1
			  END
			  else if(@count=2)
			  BEGIN 
			  set @MeasureName=@Measure2Name
			  set @MeasureType=@Measure2Type
			  set @MeasureCorrectAnswer=@Measure2CorrectAnswer
			  set @mistrial=@mistrial2
			  END
			  INSERT INTO DSTempSetCol(SchoolId,DSTempHdrId,ColName,ColTypeCd,CorrResp,ActiveInd,CreatedBy,CreatedOn,IncMisTrialInd)
			  VALUES(@SchoolId,@TempHdrId,@MeasureName,@MeasureType,@MeasureCorrectAnswer,'A',@CreatedBy,GETDATE(),@mistrial)
			  SELECT @DSSetColID = SCOPE_IDENTITY()
			 
				SET @count=1
				IF(@MeasureType='+/-')
				BEGIN
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'% Accuracy','% Accuracy','A',@CreatedBy,GETDATE())
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'% Independant','% Independant','A',@CreatedBy,GETDATE())
				END
				ELSE IF(@MeasureType='Prompt')
				BEGIN
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'% Accuracy','% Accuracy','A',@CreatedBy,GETDATE())
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'% Prompted','% Prompted','A',@CreatedBy,GETDATE())
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'% Independant','% Independant','A',@CreatedBy,GETDATE())
				END
				ELSE IF(@MeasureType='Duration')
				BEGIN
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'AvgDuration','AvgDuration','A',@CreatedBy,GETDATE())
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'TotalDuration','TotalDuration','A',@CreatedBy,GETDATE())
				END
				ELSE IF(@MeasureType='Frequency')
				BEGIN
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'Frequency','Frequency','A',@CreatedBy,GETDATE())
				END
				ELSE IF(@MeasureType='Text')
				BEGIN
				INSERT INTO DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CalcLabel,ActiveInd,CreatedBy,CreatedOn)
				VALUES(@SchoolId,@DSSetColID,'Customize','Customize','A',@CreatedBy,GETDATE())
				END

				


			  SET @count=@count+1
			  SET @ColCount=@ColCount-1;
		END

		
	commit
  END try

  BEGIN catch
  RollBack
  END catch
END











GO
