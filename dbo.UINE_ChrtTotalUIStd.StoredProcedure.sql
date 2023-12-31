USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtTotalUIStd]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_ChrtTotalUIStd]
	@str1 date,
	@str2 date,
	@Pgm varchar(100),
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200)
	AS
BEGIN
	
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
				select DISTINCT StudentName1 as StdName from UINE_UI where UIDATE BETWEEN CONVERT(VARCHAR(20),@str1, 101)  and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
				ActiveInd= 'A' and [PgmSiteID] =IIF(@IntProgram IS NULL, [PgmSiteID], @IntProgram) and [AgencyFlag] =cast(@AgencyFlag as varchar(20))
				 ) As tb

				IF (LEN(@StudentNames) = 0)
				Return
				Else
	
				SET @StudentNames = LEFT(@StudentNames, LEN(@StudentNames)-1)
	
				SET @Query= 'select * from (Select StudentName1 as StdName,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear,LocOfIncident from UINE_UI where  UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
				ActiveInd= ''A'' and 
				[PgmSiteID] =IIF('+@Pgm+' IS NULL, [PgmSiteID], '+@Pgm+') and
				[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''') SourceTable 
				PIVOT (Count(StdName) FOR StdName IN (' + @StudentNames +')) AS PivotTa'		

				EXECUTE sp_executesql @Query
END
ELSE IF (@PgmFlag = 1)
BEGIN



Select @StudentNames += QUOTENAME(StdName)+','
			FROM
			( 
				select DISTINCT StudentName1 as StdName from UINE_UI where UIDATE BETWEEN CONVERT(VARCHAR(20),@str1, 101)  and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
				ActiveInd= 'A' and ProgramGroup= @PgmGroup and [AgencyFlag] =cast(@AgencyFlag as varchar(20))
				 ) As tb

				IF (LEN(@StudentNames) = 0)
				Return
				Else
	
				SET @StudentNames = LEFT(@StudentNames, LEN(@StudentNames)-1)
	
				SET @Query= 'select * from (Select StudentName1 as StdName,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear,LocOfIncident from UINE_UI where  UIDATE BETWEEN ''' + CONVERT(VARCHAR(20),@str1, 101) + ''' and ''' + CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) + ''' and 
				ActiveInd= ''A'' and 
				ProgramGroup= '''+@PgmGroup+''' and 
				[AgencyFlag] ='''+cast(@AgencyFlag as varchar(20))+''') SourceTable 
				PIVOT (Count(StdName) FOR StdName IN (' + @StudentNames +')) AS PivotTa'		

				EXECUTE sp_executesql @Query

END
END



GO
