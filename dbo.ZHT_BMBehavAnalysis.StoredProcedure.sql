USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_BMBehavAnalysis]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		Haritha
-- Create date: 31Mar2022
-- Description:	BM and Behavior Analysis
-- =============================================
CREATE PROCEDURE [dbo].[ZHT_BMBehavAnalysis] 
	@str1 date,
	@str2 date,
	@StudentID int,
	@MeasurementID int,
	@Frequency int,
	@Duration int,
	@TypeOfBM bit,
	@DailyOrMonthyFlag bit
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @FirstDate DATE 
	DECLARE @LastDate DATE 
	set @FirstDate = @str1
	set @LastDate = @str2

IF (@DailyOrMonthyFlag = 0)
BEGIN

	iF(@Frequency = 1)
	BEGIN

	--Declare table variables
	DECLARE @TempBMMain TABLE ([BMDate] date,BMCnt int)
	DECLARE @TempBMNoBMCnt TABLE ([NoBMDate] date,NoBMCnt int)
	DECLARE @BehavDet TABLE (TimeOfEvent date, BehavCnt int)


		DECLARE @CalendarMonths TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
		INSERT @CalendarMonths VALUES( @FirstDate)
		WHILE @FirstDate < @LastDate
		BEGIN
		SET @FirstDate = DATEADD( day,1, @FirstDate)
		INSERT @CalendarMonths VALUES( @FirstDate)
		END

		--Create Table #TempBMMain ([BMDate] date,BMCnt int)
							if(@TypeOfBM =0)
							BEGIN
							insert into @TempBMMain
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' group by BMDate order by BMDate
							END
							ELSE IF (@TypeOfBM =1)
							BEGIN
							insert into @TempBMMain
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' and BMCodeType <> 'Type3' and BMCodeType <> 'Type4' and BMCodeType <> 'Type5' group by BMDate order by BMDate
							END
			--Create Table #TempBMNoBMCnt ([NoBMDate] date,NoBMCnt int)
			insert into @TempBMNoBMCnt
			Select BMDate as NoBMDate,Count(*) as NoBMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and BMCodeType= 'No BM' group by BMDate order by BMDate
			--Create Table #BehavDet(TimeOfEvent date, BehavCnt int)
			insert into @BehavDet
			select cast(TimeOfEvent as DATE) as TimeOFEvent,SUM(FrequencyCount) from Behaviour  where ActiveInd='A' and studentID=@StudentID and MeasurementId=@MeasurementID group by cast(TimeOfEvent as DATE)  order by cast(TimeOfEvent as DATE) 
		
		Select CAST(cm.cdate As nvarchar(50)) as cdate,BMDate,BMCnt,[NoBMDate],NoBMCnt,COALESCE(cast((BMCnt - NoBMCnt) as varchar(10)),cast(BMCnt as Varchar(10)),'') as CountColumn,BehavCnt  from @CalendarMonths cm 
		LEFT outer join @TempBMMain bm on cm.cdate=bm.BMDate 
		LEFT outer join @TempBMNoBMCnt nobm on cm.cdate=nobm.NoBMDate
		LEFT outer join @BehavDet behav on cm.cdate=behav.TimeOfEvent

		 order by cdate 
		END
		ELSE IF(@Duration = 1)
		BEGIN
			DECLARE @CalendarMonthsDur TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
			INSERT @CalendarMonthsDur VALUES( @FirstDate)
			WHILE @FirstDate < @LastDate
			BEGIN
			SET @FirstDate = DATEADD( day,1, @FirstDate)
			INSERT @CalendarMonthsDur VALUES( @FirstDate)
			END

			--Create Table #TempBMMain ([BMDate] date,BMCnt int)
							if(@TypeOfBM =0)
							BEGIN
							insert into @TempBMMain
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' group by BMDate order by BMDate
							END
							ELSE IF (@TypeOfBM =1)
							BEGIN
							insert into @TempBMMain
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' and BMCodeType <> 'Type3' and BMCodeType <> 'Type4' and BMCodeType <> 'Type5' group by BMDate order by BMDate
							END
				--Create Table #TempBMNoBMCnt ([NoBMDate] date,NoBMCnt int)
				insert into @TempBMNoBMCnt
				Select BMDate as NoBMDate,Count(*) as NoBMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and BMCodeType= 'No BM' group by BMDate order by BMDate
				--Create Table #BehavDet(TimeOfEvent date, BehavCnt int)
				insert into @BehavDet
				select cast(TimeOfEvent as DATE) as TimeOFEvent,SUM(CAST(Duration AS decimal(10,4))) as Duration from Behaviour  where ActiveInd='A' and studentID=@StudentID and MeasurementId=@MeasurementID group by cast(TimeOfEvent as DATE)  order by cast(TimeOfEvent as DATE) 
		
			Select CAST(cm.cdate As nvarchar(50)) as cdate,BMDate,BMCnt,[NoBMDate],NoBMCnt,COALESCE(cast((BMCnt - NoBMCnt) as varchar(10)),cast(BMCnt as Varchar(10)),'') as CountColumn,BehavCnt  from @CalendarMonthsDur cm 
			LEFT outer join @TempBMMain bm on cm.cdate=bm.BMDate 
			LEFT outer join @TempBMNoBMCnt nobm on cm.cdate=nobm.NoBMDate
			LEFT outer join @BehavDet behav on cm.cdate=behav.TimeOfEvent

			 order by cdate 

		END

END

ELSE IF(@DailyOrMonthyFlag = 1)
BEGIN
	iF(@Frequency = 1)
	BEGIN

	--Declare table variables
	DECLARE @TempBMMain1 TABLE ([BMDate] date,BMCnt int)
	DECLARE @TempBMNoBMCnt1 TABLE ([NoBMDate] date,NoBMCnt int)
	DECLARE @BehavDet1 TABLE (TimeOfEvent date, BehavCnt int)


		DECLARE @CalendarMonths1 TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
		INSERT @CalendarMonths1 VALUES( @FirstDate)
		WHILE @FirstDate < @LastDate
		BEGIN
		SET @FirstDate = DATEADD( day,1, @FirstDate)
		INSERT @CalendarMonths1 VALUES( @FirstDate)
		END

		--Create Table #TempBMMain ([BMDate] date,BMCnt int)
							if(@TypeOfBM =0)
							BEGIN
							insert into @TempBMMain1
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' group by BMDate order by BMDate
							END
							ELSE IF (@TypeOfBM =1)
							BEGIN
							insert into @TempBMMain1
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' and BMCodeType <> 'Type3' and BMCodeType <> 'Type4' and BMCodeType <> 'Type5' group by BMDate order by BMDate
							END
			--Create Table #TempBMNoBMCnt ([NoBMDate] date,NoBMCnt int)
			insert into @TempBMNoBMCnt1
			Select BMDate as NoBMDate,Count(*) as NoBMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and BMCodeType= 'No BM' group by BMDate order by BMDate
			--Create Table #BehavDet(TimeOfEvent date, BehavCnt int)
			insert into @BehavDet1
			select cast(TimeOfEvent as DATE) as TimeOFEvent,SUM(FrequencyCount) from Behaviour  where ActiveInd='A' and studentID=@StudentID and MeasurementId=@MeasurementID group by cast(TimeOfEvent as DATE)  order by cast(TimeOfEvent as DATE) 
		

			
	
		DECLARE @IntResult TABLE(cdate Date, BMDate Date,BMCnt int,NoBMDate Date,NoBMCnt int, Countcolumn Varchar,Behavecnt int)
		insert into @IntResult
		Select CAST(cm.cdate As nvarchar(50)) as cdate,BMDate,BMCnt,[NoBMDate],NoBMCnt,COALESCE(cast((BMCnt - NoBMCnt) as varchar(10)),cast(BMCnt as Varchar(10)),'') as CountColumn,BehavCnt  from @CalendarMonths1 cm 
		LEFT outer join @TempBMMain1 bm on cm.cdate=bm.BMDate 
		LEFT outer join @TempBMNoBMCnt1 nobm on cm.cdate=nobm.NoBMDate
		LEFT outer join @BehavDet1 behav on cm.cdate=behav.TimeOfEvent

		 order by cdate 
		 select MONTH(cdate) as TMonth, Year(cdate) as TYear,SUM(CAST (CountColumn AS INT)) as CountColumn,SUM(CAST(Behavecnt as INT)) as Behavcnt from @IntResult group by MONTH(cdate),Year(cdate)  order by Year(cdate),MONTH(cdate)




		END
		ELSE IF(@Duration = 1)
		BEGIN
			DECLARE @CalendarMonthsDur1 TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
			INSERT @CalendarMonthsDur1 VALUES( @FirstDate)
			WHILE @FirstDate < @LastDate
			BEGIN
			SET @FirstDate = DATEADD( day,1, @FirstDate)
			INSERT @CalendarMonthsDur1 VALUES( @FirstDate)
			END

			--Create Table #TempBMMain ([BMDate] date,BMCnt int)
							if(@TypeOfBM =0)
							BEGIN
							insert into @TempBMMain1
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' group by BMDate order by BMDate
							END
							ELSE IF (@TypeOfBM =1)
							BEGIN
							insert into @TempBMMain1
							Select BMDate,Count(*) as BMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and  BMCodeType <> 'LOA' and BMCodeType <> 'Type3' and BMCodeType <> 'Type4' and BMCodeType <> 'Type5' group by BMDate order by BMDate
							END
				--Create Table #TempBMNoBMCnt ([NoBMDate] date,NoBMCnt int)
				insert into @TempBMNoBMCnt1
				Select BMDate as NoBMDate,Count(*) as NoBMCnt from ZHT_BMMain where ActiveInd='A' and ClientID=@StudentID and BMCodeType= 'No BM' group by BMDate order by BMDate
				--Create Table #BehavDet(TimeOfEvent date, BehavCnt int)
				insert into @BehavDet1
				select cast(TimeOfEvent as DATE) as TimeOFEvent,SUM(CAST(Duration AS decimal(10,4))) as Duration from Behaviour  where ActiveInd='A' and studentID=@StudentID and MeasurementId=@MeasurementID group by cast(TimeOfEvent as DATE)  order by cast(TimeOfEvent as DATE) 
			
		DECLARE @IntResultDur TABLE(cdate Date, BMDate Date,BMCnt int,NoBMDate Date,NoBMCnt int, Countcolumn Varchar,Behavecnt int)
		insert into @IntResultDur
			Select CAST(cm.cdate As nvarchar(50)) as cdate,BMDate,BMCnt,[NoBMDate],NoBMCnt,COALESCE(cast((BMCnt - NoBMCnt) as varchar(10)),cast(BMCnt as Varchar(10)),'') as CountColumn,BehavCnt  from @CalendarMonthsDur1 cm 
			LEFT outer join @TempBMMain1 bm on cm.cdate=bm.BMDate 
			LEFT outer join @TempBMNoBMCnt1 nobm on cm.cdate=nobm.NoBMDate
			LEFT outer join @BehavDet1 behav on cm.cdate=behav.TimeOfEvent

			 order by cdate 
			 select MONTH(cdate) as TMonth, Year(cdate) as TYear,SUM(CAST (CountColumn AS INT)) as CountColumn,SUM(CAST(Behavecnt as INT)) as Behavcnt from @IntResultDur group by MONTH(cdate),Year(cdate)  order by Year(cdate),MONTH(cdate)
		END








END


   
END






GO
