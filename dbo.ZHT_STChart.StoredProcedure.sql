USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_STChart]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZHT_STChart] 
	@str1 date,
	@str2 date,
	@StudentID int
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @firstresult TABLE (mont int,yea int,Val int, Duration float)
		insert into @firstresult
		select TMonth,TYear,COUNT(*) as val,SUM(Duration) as Duration from (select MONTH(STDate) as TMonth,YEAR(STDate) as TYear,ROUND((CAST(pm.[STDurMin] AS float)*60+ CAST(pm.[STDurSec] AS float)),2) as Duration from ZHT_STMainTable pm where StudentID=@StudentID and ActiveStatus='A')itemnames Group by TYear,TMonth order by TYear,TMonth

		DECLARE @FirstDate DATE = @str1
		DECLARE @LastDate Date = @str2
		DECLARE @CalendarMonths TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
		INSERT @CalendarMonths VALUES( @FirstDate)
		WHILE @FirstDate < @LastDate
		BEGIN
		SET @FirstDate = DATEADD( day,1, @FirstDate)
		INSERT @CalendarMonths VALUES( @FirstDate)
		END
		DECLARE @AllMonths TABLE (MID INT IDENTITY(1,1) PRIMARY KEY,Mn int,yr int)
		insert into @AllMonths select month(cdate),YEAR(cdate) from @CalendarMonths

		DECLARE @Finaltbl TABLE (Mn int,yr int)
		insert into @Finaltbl select Mn,yr from @AllMonths group by Mn,yr 

		
		select ft.Mn as TMonth,ft.yr as TYear,ISNULL(fr.Val,0) as val,ISNULL(ROUND(CAST(fr.Duration AS float),2),0) as Duration from @Finaltbl ft 
		left join @firstresult fr on ft.Mn=fr.mont AND ft.yr=fr.yea order by ft.yr,ft.Mn asc

END




GO
