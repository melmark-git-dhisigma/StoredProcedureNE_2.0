USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtlineDurationDay]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_ChrtlineDurationDay] 
	@str1 date,
	@str2 date,
	@Pgm varchar(100),
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@StdID varchar(100),
	@PgmGroup Varchar(200),
	@Hold NVarchar(Max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @FirstDate DATE = @str1
DECLARE @LastDate Date = @str2

DECLARE @CalendarMonths TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
INSERT @CalendarMonths VALUES( @FirstDate)
WHILE @FirstDate < @LastDate
BEGIN
SET @FirstDate = DATEADD( day,1, @FirstDate)
INSERT @CalendarMonths VALUES( @FirstDate)
END


declare @PHMain table (DateofRest datetime, Duration decimal(11,2))
If(@Hold = 'All')
BEGIN
insert into @PHMain Select DateOfRest,TotalResTimeMin from UINE_PHMain PM inner join UINE_PHRestUsed rt on PM.PHID=rt.PHMainID where PM.ActiveInd= 'A' and [StudentID] =@StdID and [AgencyFlag] =@AgencyFlag 
END
ELSE
BEGIN
insert into @PHMain Select DateOfRest,TotalResTimeMin from UINE_PHMain PM inner join UINE_PHRestUsed rt on PM.PHID=rt.PHMainID where PM.ActiveInd= 'A' and [StudentID] =@StdID and [AgencyFlag] =@AgencyFlag and rt.Holds like '%' + LTRIM(RTRIM(@Hold)) + '%' 
END

Declare @tempresult TABLE (HoldDate date,Duration decimal(11,2),PHcount INT)
insert into @tempresult
Select CAST(cm.cdate As date) As HoldDate,SUM(ISNULL(pm.Duration,0)) As Duration,COUNT(CAST(cm.cdate As date)) as PHcount from @CalendarMonths cm LEFT outer join @PHMain pm on cm.cdate=pm.DateOfRest
GROUP BY CAST(cm.cdate As date) 

update @tempresult set PHcount=0 where Duration=0

select * from @tempresult

END





GO
