USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spMTReports]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZHT_spMTReports]
	@StartDate date,
	@EndDate date,
	@StudentID int,
	@ProgramID int
AS
BEGIN
	IF @StudentID != 0
		BEGIN
			select MT.MTID, MT.ProgramName, MT.ClientName,CAST(FORMAT(MT.MTDate,'MM/dd/yyyy') as varchar) as MTDate1, 
			CONVERT(varchar(15), CAST(MT.MTTime AS TIME), 100) as MTTime1, MT.MTCodeID, MT.MTCodeType, MT.MTComments 
			from ZHT_MTMain MT
			where MT.ActiveInd='A' and MT.ClientID=@StudentID and MT.MTDate between @StartDate and @EndDate 
			order by MT.MTDate,MT.MTTime;
		END

	ELSE IF @ProgramID=0
		BEGIN
			select MT.MTID, MT.ProgramName, MT.ClientName,CAST(FORMAT(MT.MTDate,'MM/dd/yyyy') as varchar) as MTDate1, 
			CONVERT(varchar(15), CAST(MT.MTTime AS TIME), 100) as MTTime1, MT.MTCodeID, MT.MTCodeType, MT.MTComments 
			from ZHT_MTMain MT
			where MT.ActiveInd='A' and MT.MTDate between @StartDate and @EndDate 
			order by MT.MTDate,MT.MTTime;
		END

	ELSE
		BEGIN
			select MT.MTID, MT.ProgramName, MT.ClientName,CAST(FORMAT(MT.MTDate,'MM/dd/yyyy') as varchar) as MTDate1, 
			CONVERT(varchar(15), CAST(MT.MTTime AS TIME), 100) as MTTime1, MT.MTCodeID, MT.MTCodeType, MT.MTComments 
			from ZHT_MTMain MT
			where MT.ActiveInd='A' and MT.MTDate between @StartDate and @EndDate 
			AND MT.ClientID IN (select S.StudentPersonalId 
						from StudentPersonal S 
						left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
						where StudentType='Client' and P.Location= @ProgramID and P.Status=1  and s.PlacementStatus='A' and (p.EndDate is null or p.EndDate > GETDATE()))
			order by MT.MTDate,MT.MTTime;
		END
END
GO
