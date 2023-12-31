USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[WBC_spNoNewInjuryReports]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WBC_spNoNewInjuryReports]
	@ClientID int,
	@ClassId int, 
	@StartDate date,
	@EndDate date
AS
	BEGIN
	IF(@ClientID=0)
	SELECT ClientName,IdentifiedInitials,convert(varchar(15),IdentifiedDate,101) as IdentifiedDate,
	convert(varchar(15),IdentifiedTime,100) as IdentifiedTime,
	SubmittedByName,convert(varchar(15),SubmittedByDate,101) as SubmittedByDate,convert(varchar(15),SubmittedByTime,100) as SubmittedByTime 
	FROM WBC_MainDataTable WHERE ActiveStatus='A' AND (IdentifiedDate BETWEEN @StartDate AND @EndDate) AND LabelID='Lbl237'
	AND StudentID in (select S.StudentPersonalId as ClientName 
	from StudentPersonal S left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
	where StudentType='Client' and P.Location=@ClassId and P.Status=1  
	and s.PlacementStatus='A' and (p.EndDate is null or p.EndDate > GETDATE()))
	ELSE
	SELECT ClientName,IdentifiedInitials,convert(varchar(15),IdentifiedDate,101) as IdentifiedDate,
	convert(varchar(15),IdentifiedTime,100) as IdentifiedTime,
	SubmittedByName,convert(varchar(15),SubmittedByDate,101) as SubmittedByDate,convert(varchar(15),SubmittedByTime,100) as SubmittedByTime 
	FROM WBC_MainDataTable 
	WHERE ActiveStatus='A' and StudentID=@ClientID AND (IdentifiedDate BETWEEN @StartDate AND @EndDate) AND LabelID='Lbl237'
	END
GO
