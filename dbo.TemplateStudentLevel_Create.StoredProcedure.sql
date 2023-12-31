USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[TemplateStudentLevel_Create]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TemplateStudentLevel_Create]

@SchoolId	bigint,
@StudentId	bigint,
@LessonPlanId bigint,
@LessonName	varchar(200),
@CreatedBy	bigint	

AS
BEGIN



   


	Declare @TempSetColId int,@TempSetColCalcId int,@ResultMsg varchar(5000),@NewTemplateId bigint,@BeginTemplateId bigint
	SET NOCOUNT ON;

	Begin try

	Begin Transaction

    IF EXISTS(SELECT * FROM DSTempHdr WHERE LessonPlanId = @LessonPlanId And StudentId=null)
								BEGIN



								INSERT INTO DSTempHdr(
								SchoolId,
								StudentId,
								LessonPlanId,
								DSTemplateName,
								CreatedBy,
								CreatedOn)
								SELECT 
								SchoolId,
								@StudentId,
								LessonPlanId,
								DSTemplateName,
								@CreatedBy,
								getdate() 
								FROM DSTempHdr WHERE LessonPlanId = @LessonPlanId
			
								SET @NewTemplateId = SCOPE_IDENTITY();



								--Insert into DSTempSet(SchoolId,
								--DSTempHdrId,
								--CreatedBy,
								--CreatedOn)
								--SELECT 
								--SchoolId,
								--@NewTemplateId,
								--@CreatedBy,
								--getdate() 
								--FROM DSTempSet WHERE DSTempHdrId = @NewTemplateId


								--Insert into DSTempStep(
								--SchoolId,
								--DSTempHdrId,
								--StepCd,
								--CreatedBy,
								--CreatedOn)
								--SELECT 
								--@SchoolId,
								--@NewTemplateId,
								--'',
								--@CreatedBy,
								--GETDATE()
								--FROM DSTempStep WHERE DSTempHdrId = @NewTemplateId



								--Insert into DSTempSetCol(
								--SchoolId,
								--DSTempHdrId,
								--CreatedBy,
								--CreatedOn)
								--SELECT 
								--@SchoolId,
								--@NewTemplateId,	
								--@CreatedBy,
								--GETDATE()
								--FROM DSTempSetCol WHERE DSTempHdrId = @NewTemplateId
	



								--			insert into DSTempSetColCalc
								--			(
								--			SchoolId, DSTempSetColId,CalcType,CreatedBy,CreatedOn
								--			)
								--			select @SchoolId, DSTempSetColId,'',@CreatedBy,GETDATE()
								--			from DSTempSetCol

									

								--declare cursSetCol cursor for 
								--select DSTempSetColId 
								--from DSTempSetCol WHERE DSTempHdrId = @NewTemplateId

								
								--	open cursSetCol
								--	Loop
								--			FETCH cursSetCol INTO @TempSetColId
								--			Insert into DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CreatedBy,CreatedOn)    Values(@TempSetColId,@TempSetColId,'',@CreatedBy,GETDATE())
								--	End
								--	close cursSetCol
								--	deallocate cursSetCol
	
								--set @TempSetColId=SCOPE_IDENTITY();
								--Insert into DSTempSetColCalc(SchoolId,DSTempSetColId,CalcType,CreatedBy,CreatedOn) Values(@SchoolId,@TempSetColId,'',@CreatedBy,GETDATE())
								--set @TempSetColCalcId=SCOPE_IDENTITY();
								--Insert into DSTempRule(SchoolId,DSTempSetColCalcId,RuleType,CriteriaType,CreatedBy,CreatedOn) Values(@SchoolId,@TempSetColCalcId,'','',@CreatedBy,GETDATE())
		
								set @ResultMsg='Successfully Inserted...'		
								END
	ELSE
				BEGIN


				INSERT INTO DSTempHdr(
				SchoolId,				
				LessonPlanId,
				DSTemplateName,
				CreatedBy,
				CreatedOn)
			   values(
				@SchoolId,				
				@LessonPlanId,
				@LessonName,
				@CreatedBy,
				getdate() )	
		
				SET @BeginTemplateId = SCOPE_IDENTITY();


				INSERT INTO DSTempHdr(
				SchoolId,
				StudentId,
				LessonPlanId,
				DSTemplateName,
				CreatedBy,
				CreatedOn)
				SELECT 
				SchoolId,
				@StudentId,
				LessonPlanId,
				DSTemplateName,
				@CreatedBy,
				getdate() 
				FROM DSTempHdr WHERE DSTempHdrId = @BeginTemplateId	

				
				set @ResultMsg='Successfully Inserted...'

	
	END
	Commit
	end try
	Begin catch
	rollback
	set @ResultMsg='Insertion Failed...'
	end catch

	Select  @ResultMsg
END











GO
