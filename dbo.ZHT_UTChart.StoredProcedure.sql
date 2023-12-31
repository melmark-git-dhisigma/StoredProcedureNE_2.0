USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_UTChart]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ZHT_UTChart]
	@str1 date,
	@str2 date,
	@StudentID int

AS
BEGIN

	SET NOCOUNT ON;

DECLARE @FirstDate DATE 
	DECLARE @LastDate DATE 
	set @FirstDate = @str1
	set @LastDate = @str2


DECLARE @CalendarMonths TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
INSERT @CalendarMonths VALUES( @FirstDate)
WHILE @FirstDate < @LastDate
BEGIN
SET @FirstDate = DATEADD( day,1, @FirstDate)
INSERT @CalendarMonths VALUES( @FirstDate)
END

Create Table #TempUTMain ([UTDate] date,[UTCodeType] varchar(50), [UTTime] Time)
	insert into #TempUTMain
	Select UTDate, [UTCodeType],UTTime from ZHT_UTMain where ActiveInd='A' and ClientID=@StudentID
	
Select CAST(cm.cdate As nvarchar(50)) as cdate,ISNULL(CONVERT(varchar(15),CAST(UTTime AS TIME),100),'0') as UTTime, ISNULL(mt.UTCodeType,'0') as UTType from @CalendarMonths cm LEFT outer join #TempUTMain mt 
on cm.cdate=mt.UTDate order by cdate
drop table #TempUTMain
END






GO
