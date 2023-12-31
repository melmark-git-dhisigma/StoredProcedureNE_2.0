USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChrtTypeOfHold]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_ChrtTypeOfHold]
	@str1 date,
	@str2 date,
	@Pgm int,
	@AgencyFlag NVARCHAR(50),
	@PgmFlag int,
	@PgmGroup Varchar(200),
	@DurFlag Varchar(20)
AS
BEGIN

	SET NOCOUNT ON;

If(@DurFlag = 'TypeOfHold')
BEGIN

		IF (@PgmFlag = 0)
		BEGIN

		   select StdName,COUNT(*) as val  from(select NameOfRestUsed as StdName from UINE_PHMain PM 
		inner join UINE_PHRestTABLE rt on PM.PHID=rt.PHMainID where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
								PM.ActiveInd= 'A' and rt.ActiveInd= 'A' and 
								PM.[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm) and
								PM.[AgencyFlag] =cast(@AgencyFlag as varchar(20)))itemnames Group by StdName

		END
		ELSE IF (@PgmFlag = 1)
								BEGIN

								select StdName,COUNT(*) as val  from(select NameOfRestUsed as StdName from UINE_PHMain PM 
								inner join UINE_PHRestTABLE rt on PM.PHID=rt.PHMainID where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
								PM.ActiveInd= 'A' and rt.ActiveInd= 'A' and 
								ProgramGroup= @PgmGroup and
								PM.[AgencyFlag] =cast(@AgencyFlag as varchar(20)))itemnames Group by StdName 
								END
END
ELSE IF (@DurFlag = 'IntervalOfHold')
BEGIN

		IF (@PgmFlag = 0)
		BEGIN

		   select StdName,COUNT(*) as val  from(select  RestraintInterval as StdName from UINE_PHMain
		 where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
								ActiveInd= 'A' and 
								[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm) and
								RestraintInterval is not null and
								[AgencyFlag] =cast(@AgencyFlag as varchar(20)))itemnames Group by StdName

		END
		ELSE IF (@PgmFlag = 1)
								BEGIN

								select StdName,COUNT(*) as val from(select RestraintInterval  as StdName from UINE_PHMain 
								where DateOfRest BETWEEN CONVERT(VARCHAR(20),@str1, 101) and  CONVERT(VARCHAR(20),DATEADD(DD,0,@str2), 101) and 
								ActiveInd= 'A' and 
								ProgramGroup= @PgmGroup and
								RestraintInterval is not null and
								[AgencyFlag] =cast(@AgencyFlag as varchar(20)))itemnames Group by StdName 
								END



END


END





GO
