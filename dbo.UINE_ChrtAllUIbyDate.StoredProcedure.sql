USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtAllUIbyDate]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[UINE_ChrtAllUIbyDate]
	@str1 date,
	@str2 date,
	@Pgm int,
	@StdID int,
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200),
	@UIPHFlag Varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF(@UIPHFlag = 'UI')
BEGIN
	IF (@PgmFlag = 0)
	BEGIN

		select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear,StudentName1 as StdName from UINE_UI 
		where UIDATE BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
		ActiveInd= 'A' and 
		[PgmSiteID] =IIF(@Pgm IS NULL, [PgmSiteID], @Pgm) and
		[StudentID1] =IIF(@StdID IS NULL, [StudentID1],@StdID) and
		[AgencyFlag] =cast(@AgencyFlag as varchar(20))) itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
	END
	ELSE IF (@PgmFlag = 1)
	BEGIN

		select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear,StudentName1 as StdName from UINE_UI 
		where UIDATE BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
		ActiveInd= 'A' and 
		ProgramGroup= @PgmGroup and
		[StudentID1] =IIF(@StdID IS NULL, [StudentID1],@StdID) and
		[AgencyFlag] =cast(@AgencyFlag as varchar(20))) itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
	END
END
ELSE IF (@UIPHFlag = 'PH')
BEGIN
IF (@PgmFlag = 0)
	BEGIN

		select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,StudentName as StdName from UINE_PHMain
		where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
		ActiveInd= 'A' and 
		[ProgramID] =IIF(@Pgm IS NULL, ProgramID, @Pgm) and
		[StudentID] =IIF(@StdID IS NULL, [StudentID],@StdID) and
		[AgencyFlag] =cast(@AgencyFlag as varchar(20))) itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
	END
	ELSE IF (@PgmFlag = 1)
	BEGIN

		select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,StudentName as StdName from UINE_PHMain
		where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
		ActiveInd= 'A' and 
		ProgramGroup= @PgmGroup and
		[StudentID] =IIF(@StdID IS NULL, [StudentID],@StdID) and
		[AgencyFlag] =cast(@AgencyFlag as varchar(20))) itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
	END
	

END

END




GO
