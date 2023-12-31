USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[WBC_spWellChkStats]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WBC_spWellChkStats]
       @ClientID varchar(20),
       @ClassId varchar(20),
       @StartDate varchar(20),
       @EndDate varchar(20)

AS
BEGIN
declare @cols as nvarchar(max),   
@query as nvarchar(max)


IF @ClientID !=0
begin
set @cols = STUFF((select '],['+clientConc from 
(select distinct CONCAT(ClientName,'-',IIF(C.ResidenceInd=1,'Res',IIF(C.ResidenceInd=0,'Day','Null'))) as clientConc FROM WBC_MainDataTable W 
left join [Class] C on W.SelectedLocVal=C.ClassId WHERE ActiveStatus='A' 
AND W.StudentID=@ClientID AND IdentifiedDate BETWEEN @StartDate AND @EndDate) ClNames for XML PATH('')),1,2,'') + ']'; 


set @query = 'select * from (SELECT CONCAT(ClientName,''-'',IIF(C.ResidenceInd=1,''Res'', IIF(C.ResidenceInd=0,''Day'',''Null''))) as clientConc, 
IdentifiedDate 
FROM WBC_MainDataTable W 
left join [Class] C on W.SelectedLocVal=C.ClassId 
WHERE ActiveStatus=''A'' 
AND W.StudentID ='+@ClientID+ ' AND IdentifiedDate BETWEEN '''+@StartDate+''' AND '''+@EndDate+''')  as #SourTable PIVOT (Count(clientConc)FOR clientConc IN ('+@cols+')) AS PIVOTTABLE'

execute(@query)
end
else
       
       BEGIN


set @cols = STUFF((select '],['+clientConc from 
(select distinct CONCAT(ClientName,'-',IIF(C.ResidenceInd=1,'Res',IIF(C.ResidenceInd=0,'Day','Null'))) as clientConc FROM WBC_MainDataTable W 
left join [Class] C on W.SelectedLocVal=C.ClassId WHERE ActiveStatus='A' 
AND W.StudentID in (select S.StudentPersonalId from StudentPersonal S 
left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
where StudentType='Client' and P.Location= @ClassId and P.Status=1  and s.PlacementStatus='A' 
and (p.EndDate is null or p.EndDate > GETDATE())) AND IdentifiedDate BETWEEN @StartDate AND @EndDate) ClNames for XML PATH('')),1,2,'') + ']'; 

set @query = 'select * from (SELECT CONCAT(ClientName,''-'',IIF(C.ResidenceInd=1,''Res'', IIF(C.ResidenceInd=0,''Day'',''Null''))) as clientConc, 
IdentifiedDate 
FROM WBC_MainDataTable W 
left join [Class] C on W.SelectedLocVal=C.ClassId 
WHERE ActiveStatus=''A'' 
AND W.StudentID in (select S.StudentPersonalId as ClientName from StudentPersonal S 
left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
where StudentType=''Client'' and P.Location='''+@ClassID+''' and P.Status=1  and s.PlacementStatus=''A'' 
and (p.EndDate is null or p.EndDate > GETDATE())) AND IdentifiedDate BETWEEN '''+@StartDate+''' AND '''+@EndDate+''')  as #SourTable PIVOT (Count(clientConc)FOR clientConc IN ('+@cols+')) AS PIVOTTABLE'

execute(@query)




       
       END

END
GO
