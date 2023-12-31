USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtDESEReportableMonYr]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UINE_ChrtDESEReportableMonYr]
	@str1 date,
	@str2 date,
	@Pgm varchar(100),
	@StdID varchar(100),
	@DESERepCode NVARCHAR(MAX),
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200)

AS
BEGIN

	SET NOCOUNT ON;

DECLARE @DESERepNames NVarchar(MAX) =''
DECLARE @Query NVARCHAR(MAX) = ''


	
IF (@PgmFlag = 0)
BEGIN

Select @DESERepNames += QUOTENAME(LookupName)+','
FROM
( 
	select LookupName from UINE_Lookup where LookupType='DESEReportable'
	) As Behaviors
	
	SET @DESERepNames = LEFT(@DESERepNames, LEN(@DESERepNames)-1)
	
	SET @Query= 'select * from (select Behav.[DESERepName] as Behav,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
	inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] 
	inner join [UINE_Lookup] lk on Behav.DESERepCode=lk.[UINELookupID] where UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
	UI.ActiveInd= ''A'' and 
	UI.[PgmSiteID] =IIF('+@Pgm+' IS NULL, [PgmSiteID], '+@Pgm+') and
	[StudentID1] =IIF('+@StdID+' IS NULL, [StudentID1], '+@StdID+' ) and
	[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''' and
	 [DESERepCode] =IIF('+@DESERepCode+' IS NULL,[DESERepCode], '+@DESERepCode+')) SourceTable 
PIVOT (Count(Behav) FOR Behav IN (' + @DESERepNames +')) AS PivotTa'

EXECUTE sp_executesql @Query

END


ELSE IF (@PgmFlag = 1)
BEGIN


Select @DESERepNames += QUOTENAME(LookupName)+','
FROM
( 
	select LookupName from UINE_Lookup where LookupType='DESEReportable'
	) As Behaviors
	
	SET @DESERepNames = LEFT(@DESERepNames, LEN(@DESERepNames)-1)
	
	SET @Query= 'select * from (select Behav.[DESERepName] as Behav,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
	inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] 
	inner join [UINE_Lookup] lk on Behav.DESERepCode=lk.[UINELookupID] where UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
	UI.ActiveInd= ''A'' and 
	ui.ProgramGroup= '''+@PgmGroup+''' and
	[StudentID1] =IIF('+@StdID+' IS NULL, [StudentID1], '+@StdID+' ) and
	[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''' and
	 [DESERepCode] =IIF('+@DESERepCode+' IS NULL,[DESERepCode], '+@DESERepCode+')) SourceTable 
PIVOT (Count(Behav) FOR Behav IN (' + @DESERepNames +')) AS PivotTa'

EXECUTE sp_executesql @Query

END

  
END

GO
