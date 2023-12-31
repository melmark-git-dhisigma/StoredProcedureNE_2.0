USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spBMIReports]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZHT_spBMIReports]
@StartDate date,
@EndDate date,
@ReportNo int,
@ClientID int,
@LocID int

AS
BEGIN
IF @ReportNo=1
	BEGIN
		if  @ClientID!=0
			BEGIN
				with AvgList as 
				(select AVG(B.Weight) as AvgMonth,B.MonthBMIVal,B.YearBMIVal,B.StudentID 
				from ZHT_BMIMainTable B 
				where B.ActiveStatus='A' and StudentID=@ClientID 
				group by B.MonthBMIVal,B.YearBMIVal,B.StudentID) 
				select B0.ClientName,convert(varchar,B0.DateOfBMI,101) as BMIDate,
				concat(Left(B0.MonthBMIText, 3), '-', B0.YearBMIText) as MMYYY,B0.Weight, B0.Height, B0.BMI, 
				round((B0.Weight - A0.AvgMonth), 2) as M1WtDiff,round(((B0.Weight - A0.AvgMonth) / A0.AvgMonth) * 100, 2) as M1WtPer, 
				round((B0.Weight - A1.AvgMonth), 2) as M3WtDiff,round(((B0.Weight - A1.AvgMonth) / A1.AvgMonth) * 100, 2) as M3WtPer, 
				round((B0.Weight - A2.AvgMonth), 2) as M6WtDiff,round(((B0.Weight - A2.AvgMonth) / A2.AvgMonth) * 100, 2) as M6WtPer, 
				B0.SubmittedByName, convert(varchar,B0.SubmittedDate,101) as SubmitDate, convert(varchar,B0.SubmittedTime,100) as SubmitTime, H.HTLookupName as SubmitStatus,B0.Comments 
				from ZHT_BMIMainTable B0  
				left join AvgList A0 on B0.M1MonthVal = A0.MonthBMIVal and B0.M1YearVal = A0.YearBMIVal and A0.StudentID = B0.StudentID 
				left join AvgList A1 on B0.M3MonthVal = A1.MonthBMIVal and B0.M3YearVal = A1.YearBMIVal and A1.StudentID = B0.StudentID 
				left join AvgList A2 on B0.M6MonthVal = A2.MonthBMIVal and B0.M6YearVal = A2.YearBMIVal and A2.StudentID = B0.StudentID 
				left join ZHT_Lookup H on B0.BMIStatus = HTLookupCode 
				where B0.StudentID = @ClientID and B0.ActiveStatus = 'A' and (B0.DateOfBMI between @StartDate and @EndDate) and H.HTLookupapp = 'BMI' 
				order by ClientName, B0.DateOfBMI
			END	
		ELSE
			BEGIN
				IF @LocID=0
					BEGIN
						with AvgList as 
						(select AVG(B.Weight) as AvgMonth,B.MonthBMIVal,B.YearBMIVal,B.StudentID 
						from ZHT_BMIMainTable B 
						where B.ActiveStatus='A' 
						group by B.MonthBMIVal,B.YearBMIVal,B.StudentID) 
						select B0.ClientName,convert(varchar,B0.DateOfBMI,101) as BMIDate,
						concat(Left(B0.MonthBMIText, 3), '-', B0.YearBMIText) as MMYYY,B0.Weight, B0.Height, B0.BMI, 
						round((B0.Weight - A0.AvgMonth), 2) as M1WtDiff,round(((B0.Weight - A0.AvgMonth) / A0.AvgMonth) * 100, 2) as M1WtPer, 
						round((B0.Weight - A1.AvgMonth), 2) as M3WtDiff,round(((B0.Weight - A1.AvgMonth) / A1.AvgMonth) * 100, 2) as M3WtPer, 
						round((B0.Weight - A2.AvgMonth), 2) as M6WtDiff,round(((B0.Weight - A2.AvgMonth) / A2.AvgMonth) * 100, 2) as M6WtPer, 
						B0.SubmittedByName, convert(varchar,B0.SubmittedDate,101) as SubmitDate, convert(varchar,B0.SubmittedTime,100) as SubmitTime, H.HTLookupName as SubmitStatus,B0.Comments 
						from ZHT_BMIMainTable B0  
						left join AvgList A0 on B0.M1MonthVal = A0.MonthBMIVal and B0.M1YearVal = A0.YearBMIVal and A0.StudentID = B0.StudentID 
						left join AvgList A1 on B0.M3MonthVal = A1.MonthBMIVal and B0.M3YearVal = A1.YearBMIVal and A1.StudentID = B0.StudentID 
						left join AvgList A2 on B0.M6MonthVal = A2.MonthBMIVal and B0.M6YearVal = A2.YearBMIVal and A2.StudentID = B0.StudentID 
						left join ZHT_Lookup H on B0.BMIStatus = HTLookupCode 
						where B0.ActiveStatus = 'A' and (B0.DateOfBMI between @StartDate and @EndDate) and H.HTLookupapp = 'BMI' 
						order by ClientName, B0.DateOfBMI
					END
				ELSE
					BEGIN
						with AvgList as 
						(select AVG(B.Weight) as AvgMonth,B.MonthBMIVal,B.YearBMIVal,B.StudentID 
						from ZHT_BMIMainTable B 
						where B.ActiveStatus='A' and StudentID  in 
						(select S.StudentPersonalId 
						from StudentPersonal S 
						left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
						where StudentType='Client' and P.Location= @LocID and P.Status=1  and s.PlacementStatus='A' and (p.EndDate is null or p.EndDate > GETDATE()))
						group by B.MonthBMIVal,B.YearBMIVal,B.StudentID) 
						select B0.ClientName, convert(varchar,B0.DateOfBMI,101) as BMIDate, 
						concat(Left(B0.MonthBMIText, 3), '-', B0.YearBMIText) as MMYYY,B0.Weight, B0.Height, B0.BMI, 
						round((B0.Weight - A0.AvgMonth), 2) as M1WtDiff,round(((B0.Weight - A0.AvgMonth) / A0.AvgMonth) * 100, 2) as M1WtPer, 
						round((B0.Weight - A1.AvgMonth), 2) as M3WtDiff,round(((B0.Weight - A1.AvgMonth) / A1.AvgMonth) * 100, 2) as M3WtPer, 
						round((B0.Weight - A2.AvgMonth), 2) as M6WtDiff,round(((B0.Weight - A2.AvgMonth) / A2.AvgMonth) * 100, 2) as M6WtPer, 
						B0.SubmittedByName, convert(varchar,B0.SubmittedDate,101) as SubmitDate, convert(varchar,B0.SubmittedTime,100) as SubmitTime, H.HTLookupName as SubmitStatus,B0.Comments 
						from ZHT_BMIMainTable B0  
						left join AvgList A0 on B0.M1MonthVal = A0.MonthBMIVal and B0.M1YearVal = A0.YearBMIVal and A0.StudentID = B0.StudentID 
						left join AvgList A1 on B0.M3MonthVal = A1.MonthBMIVal and B0.M3YearVal = A1.YearBMIVal and A1.StudentID = B0.StudentID 
						left join AvgList A2 on B0.M6MonthVal = A2.MonthBMIVal and B0.M6YearVal = A2.YearBMIVal and A2.StudentID = B0.StudentID 
						left join ZHT_Lookup H on B0.BMIStatus = HTLookupCode 
						where B0.StudentID  in 
						(select S.StudentPersonalId 
						from StudentPersonal S 
						left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
						where StudentType='Client' and P.Location= @LocID and P.Status=1  and s.PlacementStatus='A' and (p.EndDate is null or p.EndDate > GETDATE())) 
						and B0.ActiveStatus = 'A' and (B0.DateOfBMI between @StartDate and @EndDate) and H.HTLookupapp = 'BMI' 
						order by ClientName, B0.DateOfBMI
					END
			END
	END

ELSE IF @ReportNo=3
	BEGIN
		SELECT convert(varchar,BT.DateOfBMI,101) as BMIDate, BT.BMI FROM ZHT_BMIMainTable BT WHERE BT.StudentID=@ClientID AND (BT.DateOfBMI BETWEEN @StartDate AND @EndDate) AND BT.ActiveStatus='A' ORDER BY BT.DateOfBMI
	END

ELSE IF @ReportNo=4
	BEGIN
		SELECT convert(varchar,BT.DateOfBMI,101) as BMIDate,BT.[Weight],BT.[Height] FROM ZHT_BMIMainTable BT WHERE BT.StudentID=@ClientID AND (BT.DateOfBMI BETWEEN @StartDate AND @EndDate) AND BT.ActiveStatus='A' ORDER BY BT.DateOfBMI
	END






END
GO
