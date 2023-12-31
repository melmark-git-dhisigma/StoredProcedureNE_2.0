USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spUTReports]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZHT_spUTReports]
	@StartDate date,
	@EndDate date,
	@StudentID int,
	@ProgramID int
AS
BEGIN
	IF @StudentID != 0
		BEGIN
			select UT.UTID,UT.ProgramName,UT.ClientName,CAST(FORMAT(UT.UTDate,'MM/dd/yyyy') as varchar) as UTDate1, 
			CONVERT(varchar(15), CAST(UT.UTTime AS TIME), 100) as UTTime1,UT.UTCodeType,LU.HTLookupName,UT.UTComments 
			from ZHT_UTMain UT 
			join ZHT_Lookup LU on  CONVERT(varchar(2),UT.utcodetype) = LU.HTLookupCode
			where UT.ActiveInd='A' and LU.HTLookupapp='UT' and LU.HTActiveInd='A' AND UT.ClientID=@StudentID AND UT.UTDate BETWEEN @StartDate AND @EndDate
			ORDER BY UT.ClientName,UT.UTDate,UT.UTTime;
		END

	ELSE IF @ProgramID=0
		BEGIN
select UT.UTID,UT.ProgramName,UT.ClientName,CAST(FORMAT(UT.UTDate,'MM/dd/yyyy') as varchar) as UTDate1, 
			CONVERT(varchar(15), CAST(UT.UTTime AS TIME), 100) as UTTime1,UT.UTCodeType,LU.HTLookupName,UT.UTComments  
			from ZHT_UTMain UT 
			join ZHT_Lookup LU on  CONVERT(varchar(2),UT.utcodetype) = LU.HTLookupCode
			where UT.ActiveInd='A' and LU.HTLookupapp='UT' and LU.HTActiveInd='A' AND UT.UTDate BETWEEN @StartDate AND @EndDate
			ORDER BY UT.ClientName,UT.UTDate,UT.UTTime;
		END

	ELSE
		BEGIN
			select UT.UTID,UT.ProgramName,UT.ClientName,CAST(FORMAT(UT.UTDate,'MM/dd/yyyy') as varchar) as UTDate1, 
CONVERT(varchar(15), CAST(UT.UTTime AS TIME), 100) as UTTime1,UT.UTCodeType,LU.HTLookupName,UT.UTComments  
from ZHT_UTMain UT 
join ZHT_Lookup LU on CONVERT(varchar(2),UT.utcodetype) = LU.HTLookupCode
where UT.ActiveInd='A' and LU.HTLookupapp='UT' and LU.HTActiveInd='A' 
AND UT.ClientID IN 
(select S.StudentPersonalId 
						from StudentPersonal S 
						left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
						where StudentType='Client' and P.Location= @ProgramID and P.Status=1  and s.PlacementStatus='A' and (p.EndDate is null or p.EndDate > GETDATE())) AND UT.UTDate BETWEEN @StartDate AND @EndDate
			ORDER BY UT.ClientName,UT.UTDate,UT.UTTime;
		
		END
END
GO
