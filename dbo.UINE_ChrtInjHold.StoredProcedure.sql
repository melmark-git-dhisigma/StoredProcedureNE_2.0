USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtInjHold]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[UINE_ChrtInjHold]
	@str1 date,
	@str2 date,
	@Pgm int,
	@StdID int,
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200),
	@strInjFlag Varchar(200)

AS
BEGIN
	
	SET NOCOUNT ON;

	IF(@strInjFlag = 'ChrtInjHold')
	BEGIN

				IF (@PgmFlag = 0)
								BEGIN

									select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,StudentName as StdName from UINE_PHMain PM
								inner join UINE_PHStdBehCessInj inj on PM.PHID=inj.PHMainID
								where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
								PM.ActiveInd= 'A' and 
								PM.[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm) and
								PM.[StudentID] =IIF(@StdID IS NULL, [StudentID],@StdID) and
								PM.[AgencyFlag] =cast(@AgencyFlag as varchar(20)) and inj.chkStdInj=1)itemnames Group by TYear,TMonth,StdName order by TYear,TMonth

								END
					ELSE IF (@PgmFlag = 1)
								BEGIN

									select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,StudentName as StdName from UINE_PHMain PM
									inner join UINE_PHStdBehCessInj inj on PM.PHID=inj.PHMainID
									where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
									PM.ActiveInd= 'A' and 
									ProgramGroup= @PgmGroup and
									PM.[StudentID] =IIF(@StdID IS NULL, [StudentID],@StdID) and
									PM.[AgencyFlag] =cast(@AgencyFlag as varchar(20)) and inj.chkStdInj=1)itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
								END
	END
	ELSE IF(@strInjFlag = 'chrtPHInjStaff')
	BEGIN

				IF (@PgmFlag = 0)
								BEGIN

									select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,per.Per1Name as StdName from UINE_PHMain PM
								inner join UINE_PHStdBehCessInj inj on PM.PHID=inj.PHMainID
								inner join UINE_PHPersons per on PM.PHID=per.PHMainID
								where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
								PM.ActiveInd= 'A' and 
								PM.[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm) and
								PM.[StudentID] =IIF(@StdID IS NULL, [StudentID],@StdID) and
								PM.[AgencyFlag] =cast(@AgencyFlag as varchar(20)) and inj.chkStaffInj=1)itemnames Group by TYear,TMonth,StdName order by TYear,TMonth

								END
					ELSE IF (@PgmFlag = 1)
								BEGIN

									select TMonth,TYear,StdName,COUNT(*) as val from(select MONTH(DateOfRest) as TMonth,YEAR(DateOfRest) as TYear,Per1Name as StdName from UINE_PHMain PM
									inner join UINE_PHStdBehCessInj inj on PM.PHID=inj.PHMainID
									inner join UINE_PHPersons per on PM.PHID=per.PHMainID
									where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
									PM.ActiveInd= 'A' and 
									ProgramGroup= @PgmGroup and
									PM.[StudentID] =IIF(@StdID IS NULL, [StudentID],@StdID) and
									PM.[AgencyFlag] =cast(@AgencyFlag as varchar(20)) and inj.chkStaffInj=1)itemnames Group by TYear,TMonth,StdName order by TYear,TMonth
								END

	END



END



GO
