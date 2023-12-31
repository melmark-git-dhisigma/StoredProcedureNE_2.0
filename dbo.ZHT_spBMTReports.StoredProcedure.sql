USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spBMTReports]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZHT_spBMTReports]
@StartDate date,
@EndDate date,
@ReportNo int,
@ClientID int,
@LocID int,
@BMType varchar(15)

AS

BEGIN
IF @ReportNo=1
	BEGIN
		IF @ClientID=0 
			BEGIN		
				IF @LocID=0
					BEGIN
						SELECT B0.BMID,B0.ProgramName,B0.ClientName,B0.BMDate,convert(varchar,B0.BMTime,100) as BMTime1,B0.BMCodeType,B0.BMComments, 
						CONCAT(U1.UserFName,' ',U1.UserLName) AS SubmittedName, B0.BMSubmittedOn 						
						FROM ZHT_BMMain B0 
						LEFT JOIN [User] U1 ON B0.BMSubmittedby=U1.UserId 
						LEFT JOIN [User] U2 ON B0.BMModifiedBy=U2.UserId 
						WHERE B0.ActiveInd='A' AND (B0.BMDATE BETWEEN @StartDate AND @EndDate) 
						AND B0.BMCodeType = IIF(@BMType='0',B0.BMCodeType,@BMType) 
						ORDER BY B0.ClientName, B0.BMDate, B0.BMTime
					END
				ELSE
					BEGIN
						SELECT B0.BMID,B0.ProgramName,B0.ClientName,B0.BMDate,convert(varchar,B0.BMTime,100) as BMTime1,B0.BMCodeType,B0.BMComments, 
						CONCAT(U1.UserFName,' ',U1.UserLName) AS SubmittedName, B0.BMSubmittedOn 
						FROM ZHT_BMMain B0 
						LEFT JOIN [User] U1 ON B0.BMSubmittedby=U1.UserId 
						LEFT JOIN [User] U2 ON B0.BMModifiedBy=U2.UserId 
						WHERE B0.ActiveInd='A' AND B0.ClientID  in 
						(select S.StudentPersonalId 
						from StudentPersonal S 
						left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
						where StudentType='Client' and P.Location= @LocID and P.Status=1  and s.PlacementStatus='A' and (p.EndDate is null or p.EndDate > GETDATE())) 
						AND (B0.BMDATE BETWEEN @StartDate AND @EndDate) 
						AND B0.BMCodeType = IIF(@BMType='0',B0.BMCodeType,@BMType) 
						ORDER BY B0.ClientName, B0.BMDate, B0.BMTime
					END
			END
		ELSE
			BEGIN
				SELECT B0.BMID,B0.ProgramName,B0.ClientName,B0.BMDate,convert(varchar,B0.BMTime,100) as BMTime1,B0.BMCodeType,B0.BMComments, 
				CONCAT(U1.UserFName,' ',U1.UserLName) AS SubmittedName, B0.BMSubmittedOn 
				FROM ZHT_BMMain B0 
				LEFT JOIN [User] U1 ON B0.BMSubmittedby=U1.UserId 
				LEFT JOIN [User] U2 ON B0.BMModifiedBy=U2.UserId 
				WHERE B0.ActiveInd='A' AND (B0.BMDATE BETWEEN @StartDate AND @EndDate) AND B0.ClientID=@ClientID 
				AND B0.BMCodeType = IIF(@BMType='0',B0.BMCodeType,@BMType) 
				ORDER BY B0.ClientName, B0.BMDate, B0.BMTime
			END		
	END
END
GO
