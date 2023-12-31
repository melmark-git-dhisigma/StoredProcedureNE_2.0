USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_MTChart]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZHT_MTChart]
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

Create Table #TempMTMain ([MTDate] date,[MTCodeType] varchar(50), [MTTime] Time)
	insert into #TempMTMain
	Select MTDate, [MTCodeType],MTTime from ZHT_MTMain where ActiveInd='A' and ClientID=@StudentID
	
Select CAST(cm.cdate As nvarchar(50)) as cdate,ISNULL(CONVERT(varchar(15),CAST(MTTime AS TIME),100),'0') as MTTime, ISNULL(mt.MTCodeType,'0') as MTType from @CalendarMonths cm LEFT outer join #TempMTMain mt 
on cm.cdate=mt.MTDate order by cdate
drop table #TempMTMain
END






GO
