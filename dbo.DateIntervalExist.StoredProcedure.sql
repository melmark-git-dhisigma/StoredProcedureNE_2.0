USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[DateIntervalExist]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================

-- Author:		 <Author,,Name>

-- Create date: <Create Date,,>

-- Description:	 <Description,,>
 
-- =============================================

CREATE PROCEDURE [dbo].[DateIntervalExist]

@StartTime varchar(MAX),

@EndTime varchar(MAX),

@StartDate datetime,

@EndDate datetime,
 
@schoolId int,

@ClassId int,

@NumOfTime int

AS

BEGIN

	 -- SET NOCOUNT ON added to prevent extra result sets from

 	-- interfering with SELECT statements.

	 SET NOCOUNT ON;




	 DECLARE @Start time(7)
 
	,@End time(7)

	 ,@SCount int

	 ,@ECount int

	 ,@Result varchar(50)
 



	SET @Result='True'

	 WHILE(@StartDate<=@EndDate)

	 BEGIN
 
	IF(@StartDate NOT IN (SELECT HolDate FROM SchoolHoliday WHERE SchoolId=@schoolId))

	 BEGIN

	 SELECT @Start=StartTime,@End=EndTime FROM SchoolCal WHERE SchoolId=@schoolId AND ResidenceInd<>(SELECT ResidenceInd FROM Class 
 
	WHERE ClassId=@ClassId) AND Weekday=(SELECT DATENAME(dw,@StartDate))




	 SET @SCount= (SELECT COUNT(*) FROM (SELECT Data FROM Split(@StartTime,',') WHERE Data <>'') ST WHERE CONVERT(TIME(7),ST.Data)>=CONVERT(TIME(7),@Start))	  
 
	SET @ECount= (SELECT COUNT(*) FROM (SELECT Data FROM Split(@EndTime,',') WHERE Data <>'') ST WHERE CONVERT(TIME(7),ST.Data)<=CONVERT(TIME(7),@End))
 



	IF(@SCount<>@NumOfTime OR @ECount<>@NumOfTime)

	 BEGIN

	 SET @Result='False'
 
	END

	 END

	 SET @StartDate=@StartDate+1

	 END
 



	

	

    SELECT @Result

END


GO
