USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[GenerateDates_Hour]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateDates_Hour] @Start_Date DateTime, @End_Date DateTime
AS
-- ============================================================
	-- Author:		DhiLogics
	-- Create date: 	
	-- Description:	This SP is used to populate the Dimension table DimDateHour
-- ============================================================
	DECLARE 
		@Days_To_Insert Integer, 
		@Day_Nbr_of_Week tinyint,
		@English_Week_Name nvarchar(10), 
		@Day_Nbr_of_Month tinyint,
		@Day_Nbr_of_Year smallint,
		@Week_Nbr_of_Year tinyint, 
		@English_Month_Name nvarchar(10), 
		@Month_Nbr_of_Year tinyint,
		@Calendar_Quarter tinyint, 
		@Calendar_Year char(4), 
		@Calendar_Semester tinyint, 
		@IsValidDate tinyint,
		@Hour_Cnt Integer,
		@Date_Hour DateTime

BEGIN
	Begin Try
		SELECT @IsValidDate = IsDate(@End_Date)
		If 
			(@IsValidDate = 0)
		RAISERROR 
			('Error: Invalid Date!!', 16, 1);
		IF
			(@Start_Date = '')
		BEGIN
			SELECT 
				@Start_Date = Max(FullDate) 
			FROM 
				[dbo].[DimDateHour]
			SET @Start_Date = @Start_Date + 1
			END
		SELECT 
			@Days_To_Insert = DateDiff(day,@Start_Date,@End_Date)
		If 
			(@Days_To_Insert < 0)
		RAISERROR 
			('Warning: Dates has been already Generated!!', 16, 1);
		Else
		BEGIN
		While (@Days_To_Insert > 0)
		BEGIN
			SELECT @Day_Nbr_of_Week = DATEPART(dw,@Start_Date)
			SELECT @English_Week_Name = DATENAME(dw, @Start_Date)
			SELECT @Day_Nbr_of_Month = DATEPART(dd, @Start_Date)
			SELECT @Day_Nbr_of_Year = DATEPART(dy,@Start_Date)
			SELECT @Week_Nbr_of_Year = DATEPART(wk,@Start_Date)
			SELECT @English_Month_Name = DATENAME(mm, @Start_Date)
			SELECT @Month_Nbr_of_Year = DATEPART(mm,@Start_Date)
			IF 
				(@Month_Nbr_of_Year < 7)
			SET 
				@Calendar_Semester = 1
			ELSE
			SET @Calendar_Semester = 2
			
			SELECT @Calendar_Quarter = DATEPART(qq,@Start_Date)
			SELECT @Calendar_Year = DATEPART(yy,@Start_Date)
			
			SELECT @Hour_Cnt = 0
			While (@Hour_Cnt < 24)
			BEGIN
			SELECT @Date_Hour = CONVERT(Datetime,CONVERT(VARCHAR(10),@Start_Date,1) + ' ' + CONVERT(VARCHAR(2),@Hour_Cnt) + ':00:00')
			--SELECT	@Date_Hour
			INSERT INTO DimDateHour	
			(
				[FullDateHour],
				[FullDate],
				[DayNumberOfWeek],
				[EnglishDayNameOfWeek],
				[DayNumberOfMonth],
				[DayNumberOfYear],
				[WeekNumberOfYear],
				[EnglishMonthName],
				[MonthNumberOfYear],
				[CalendarQuarter],
				[CalendarYear],
				[CalendarSemester])
			VALUES
			(	@Date_Hour,
				@Start_Date, 
				@Day_Nbr_of_Week,
				@English_Week_Name, 
				@Day_Nbr_of_Month,
				@Day_Nbr_of_Year, 
				@Week_Nbr_of_Year,
				@English_Month_Name,
				@Month_Nbr_of_Year,
				@Calendar_Quarter, 
				@Calendar_Year, 
				@Calendar_Semester)

	SELECT @Hour_Cnt = @Hour_Cnt + 1
	end
		SET @Days_To_Insert = @Days_To_Insert - 1
		SET @Start_Date = @Start_Date + 1
		SET @Day_Nbr_of_Week = 0
		SET @English_Week_Name = ''
		SET @Day_Nbr_of_Month = 0
		SET @Day_Nbr_of_Year = 0
		SET @Week_Nbr_of_Year = 0
		SET @English_Month_Name = ''
		SET @Month_Nbr_of_Year = 0
		SET @Calendar_Quarter = 0
		SET @Calendar_Year = ''
		SET @Calendar_Semester = 0
		END
	END
	End Try
Begin Catch

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

SELECT
@ErrorMessage = ERROR_MESSAGE(),
@ErrorSeverity = ERROR_SEVERITY(),
@ErrorState = ERROR_STATE();
RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
End Catch
END



GO
