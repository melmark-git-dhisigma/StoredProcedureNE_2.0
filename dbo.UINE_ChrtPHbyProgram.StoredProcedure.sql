USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtPHbyProgram]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UINE_ChrtPHbyProgram]
	@str1 date,
	@str2 date,
	@Pgm int,
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN
	IF (@PgmFlag = 0)
	BEGIN

		select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,ProgramGroup as StdName from UINE_PHMain where ProgramGroup is not null and ProgramGroup <>'' 
		and DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
		ActiveInd= 'A' and 
		[ProgramID] =IIF(@Pgm IS NULL, ProgramID, @Pgm) and
		[AgencyFlag] =cast(@AgencyFlag as varchar(20))) itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
	END
	ELSE IF (@PgmFlag = 1)
	BEGIN

		select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,ProgramGroup as StdName from UINE_PHMain where ProgramGroup is not null and ProgramGroup <>'' 
		and DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
		ActiveInd= 'A' and 
		ProgramGroup= @PgmGroup and
		[AgencyFlag] =cast(@AgencyFlag as varchar(20))) itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
	END
END
END


GO
