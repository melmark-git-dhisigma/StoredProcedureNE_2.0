USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtUnusualCodeMonYr]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UINE_ChrtUnusualCodeMonYr]
	@str1 date,
	@str2 date,
	@Pgm varchar(100),
	@StdID varchar(100),
	@UCode NVARCHAR(MAX),
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200)

AS
BEGIN

	SET NOCOUNT ON;

DECLARE @UNames NVarchar(MAX) =''
DECLARE @Query NVARCHAR(MAX) = ''


	
IF (@PgmFlag = 0)
BEGIN

Select @UNames += QUOTENAME(LookupName)+','
FROM
( 
	select LookupName from UINE_Lookup where LookupType='UnusualCode'
	) As Behaviors
	
	SET @UNames = LEFT(@UNames, LEN(@UNames)-1)
	
	SET @Query= 'select * from (select Behav.[PersonName] as Behav,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
	inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] 
	inner join [UINE_Lookup] lk on Behav.PersonCode=lk.[UINELookupID] where UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
	UI.ActiveInd= ''A'' and 
	UI.[PgmSiteID] =IIF('+@Pgm+' IS NULL, [PgmSiteID], '+@Pgm+') and
	[StudentID1] =IIF('+@StdID+' IS NULL, [StudentID1], '+@StdID+' ) and
	[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''' and
	 [PersonCode] =IIF('+@UCode+' IS NULL,[PersonCode], '+@UCode+')) SourceTable 
PIVOT (Count(Behav) FOR Behav IN (' + @UNames +')) AS PivotTa'

EXECUTE sp_executesql @Query

END


ELSE IF (@PgmFlag = 1)
BEGIN


Select @UNames += QUOTENAME(LookupName)+','
FROM
( 
	select LookupName from UINE_Lookup where LookupType='UnusualCode'
	) As Behaviors
	
	SET @UNames = LEFT(@UNames, LEN(@UNames)-1)
	
	SET @Query= 'select * from (select Behav.[PersonName] as Behav,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
	inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] 
	inner join [UINE_Lookup] lk on Behav.PersonCode=lk.[UINELookupID] where UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
	UI.ActiveInd= ''A'' and 
	ui.ProgramGroup= '''+@PgmGroup+''' and
	[StudentID1] =IIF('+@StdID+' IS NULL, [StudentID1], '+@StdID+' ) and
	[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''' and
	 [PersonCode] =IIF('+@UCode+' IS NULL,[PersonCode], '+@UCode+')) SourceTable 
PIVOT (Count(Behav) FOR Behav IN (' + @UNames +')) AS PivotTa'

EXECUTE sp_executesql @Query

END

  
END



GO
