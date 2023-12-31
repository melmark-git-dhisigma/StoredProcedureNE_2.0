USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtAllStdBehav]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_ChrtAllStdBehav]
	@str1 date,
	@str2 date,
	@Pgm varchar(100),
	@BCode NVARCHAR(MAX),
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			DECLARE @StudentNames NVarchar(MAX) =''
			DECLARE @Query NVARCHAR(MAX) = ''

			DECLARE @IntPRogram int = null

			IF(@pgm = 'NULL')
			BEGIN

			set @IntProgram = null

			END

			ELSE
			BEGIN

			set @IntProgram=TRY_CONVERT(int, @pgm)

			END

		
IF (@PgmFlag = 0)
BEGIN

			Select @StudentNames += QUOTENAME(StdName)+','
			FROM
			( 
				select DISTINCT UI.StudentName1 as StdName from UINE_UI UI 
				inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID]
				inner join [UINE_Lookup] lk on Behav.BehavCode=lk.[UINELookupID] where UIDATE BETWEEN CONVERT(VARCHAR(20),@str1, 101)  and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
				UI.ActiveInd= 'A' and 
				UI.[PgmSiteID] =IIF(@IntProgram IS NULL, [PgmSiteID], @IntProgram) and
				[AgencyFlag] =cast(@AgencyFlag as varchar(20)) and 
				Behav.BehavCode= @BCode
					) As Behaviors
				IF (LEN(@StudentNames) = 0)
				Return 0
				Else
	
				SET @StudentNames = LEFT(@StudentNames, LEN(@StudentNames)-1)
	
				SET @Query= 'select * from (Select UI.StudentName1 as StdName,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
				inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID]
				inner join [UINE_Lookup] lk on Behav.BehavCode=lk.[UINELookupID] where  UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
				UI.ActiveInd= ''A'' and 
				UI.[PgmSiteID] =IIF('+@Pgm+' IS NULL, [PgmSiteID], '+@Pgm+') and
				[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''' and 
				Behav.BehavCode= '''+@BCode+''' ) SourceTable 
				PIVOT (Count(StdName) FOR StdName IN (' + @StudentNames +')) AS PivotTa'

			EXECUTE sp_executesql @Query

END

ELSE IF (@PgmFlag = 1)
BEGIN

			Select @StudentNames += QUOTENAME(StdName)+','
			FROM
			( 
				select DISTINCT UI.StudentName1 as StdName from UINE_UI UI 
				inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] where  UIDATE BETWEEN CONVERT(VARCHAR(20),@str1, 101)  and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
				UI.ActiveInd= 'A' and 
				ui.ProgramGroup= @PgmGroup and
				[AgencyFlag] =cast(@AgencyFlag as varchar(20)) and 
				Behav.BehavCode= @BCode
					) As Behaviors
					IF (LEN(@StudentNames) = 0)
				Return 0
				Else
				SET @StudentNames = LEFT(@StudentNames, LEN(@StudentNames)-1)
	
				SET @Query= 'select * from (Select UI.StudentName1 as StdName,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
				inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID]
				inner join [UINE_Lookup] lk on Behav.BehavCode=lk.[UINELookupID] where  UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
				UI.ActiveInd= ''A'' and 
				ui.ProgramGroup= '''+@PgmGroup+''' and [AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''' and
				Behav.BehavCode= '''+@BCode+''' ) SourceTable 
				PIVOT (Count(StdName) FOR StdName IN (' + @StudentNames +')) AS PivotTa'

			EXECUTE sp_executesql @Query

END


END





GO
