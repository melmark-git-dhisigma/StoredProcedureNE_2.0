USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtStdInj]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_ChrtStdInj]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			DECLARE @StudentNames NVarchar(MAX) =''
			DECLARE @Query NVARCHAR(MAX) = ''

			Select @StudentNames += QUOTENAME(StdName)+','
			FROM
			( 
				select DISTINCT UI.StudentName1 as StdName from UINE_UI UI 
				inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] where  Behav.BehavCode=1020
					) As Behaviors
	
				SET @StudentNames = LEFT(@StudentNames, LEN(@StudentNames)-1)
	
				SET @Query= 'select * from (Select UI.StudentName1 as StdName,MONTH([UIDate]) as TMonth,YEAR([UIDate]) as TYear from UINE_UI UI 
				inner join  [UINE_PrimaryReason] Behav on UI.[UINEID]=Behav.[UINEID] where  Behav.BehavCode=1020) SourceTable 
			PIVOT (Count(StdName) FOR StdName IN (' + @StudentNames +')) AS PivotTa'

			EXECUTE sp_executesql @Query
 
END

GO
