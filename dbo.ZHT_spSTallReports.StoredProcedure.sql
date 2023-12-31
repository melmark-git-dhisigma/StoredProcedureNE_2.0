USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spSTallReports]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZHT_spSTallReports]
       @StudentID int,
       @PlacementID int,
       @StartDate date,
       @EndDate date,
       @ReportType int
AS

BEGIN
       IF @ReportType=1
       BEGIN
              IF @StudentID=0 AND @PlacementID=0
              BEGIN
              select STID,ClientName,convert(varchar,STDate,101) as STDate1,CONCAT(right('0' + cast(STDurMin as varchar),2),':',right('0' + cast(STDurSec as varchar),2)) as STDur,FORMAT(CAST(STTime as DateTime), 'hh:mm tt') as STTime1,Unconsious,Incontinent,BreatheNormal,Speech,Flushed,Cyanotic,Epileptic,Limp,Rigid,Spastic,EyeUp,EyeDown,EyeLeft,EyeRight,EyeStare,Face,Body,LSide,RSide,LLimb,RLimb,Head,AbOther,AbExplain,Asleep,Drowsy,Confused,Self,VNS,VNS1Time,VNS2Time,VNS3Time,VNS4Time,VNS5Time,VNSNA,VNS1Swipe,VNS2Swipe,VNS3Swipe,VNS4Swipe,VNS5Swipe,NurseNotify,NurseName,convert(varchar,NurseDate,101) as NurseDate1,Convert(varchar,NurseTime,100) as NurseTime1,Precipitating,Comments,DiastatVal,Call911Val              
              from ZHT_STMainTable Z where Z.STDate between @StartDate and @EndDate and Z.ActiveStatus='A' order by ClientName,STDate;
              END
              ELSE IF @StudentID != 0
              BEGIN
              select STID,ClientName,convert(varchar,STDate,101) as STDate1,CONCAT(right('0' + cast(STDurMin as varchar),2),':',right('0' + cast(STDurSec as varchar),2)) as STDur,FORMAT(CAST(STTime as DateTime), 'hh:mm tt') as STTime1,Unconsious,Incontinent,BreatheNormal,Speech,Flushed,Cyanotic,Epileptic,Limp,Rigid,Spastic,EyeUp,EyeDown,EyeLeft,EyeRight,EyeStare,Face,Body,LSide,RSide,LLimb,RLimb,Head,AbOther,AbExplain,Asleep,Drowsy,Confused,Self,VNS,VNS1Time,VNS2Time,VNS3Time,VNS4Time,VNS5Time,VNSNA,VNS1Swipe,VNS2Swipe,VNS3Swipe,VNS4Swipe,VNS5Swipe,NurseNotify,NurseName,convert(varchar,NurseDate,101) as NurseDate1,Convert(varchar,NurseTime,100) as NurseTime1,Precipitating,Comments,DiastatVal,Call911Val
              from ZHT_STMainTable Z where Z.STDate between @StartDate and @EndDate and Z.ActiveStatus='A' and Z.StudentID=@StudentID order by STDate;
              END
              ELSE IF @PlacementID !=0
              BEGIN
              select STID,ClientName,convert(varchar,STDate,101) as STDate1,CONCAT(right('0' + cast(STDurMin as varchar),2),':',right('0' + cast(STDurSec as varchar),2)) as STDur,FORMAT(CAST(STTime as DateTime), 'hh:mm tt') as STTime1,Unconsious,Incontinent,BreatheNormal,Speech,Flushed,Cyanotic,Epileptic,Limp,Rigid,Spastic,EyeUp,EyeDown,EyeLeft,EyeRight,EyeStare,Face,Body,LSide,RSide,LLimb,RLimb,Head,AbOther,AbExplain,Asleep,Drowsy,Confused,Self,VNS,VNS1Time,VNS2Time,VNS3Time,VNS4Time,VNS5Time,VNSNA,VNS1Swipe,VNS2Swipe,VNS3Swipe,VNS4Swipe,VNS5Swipe,NurseNotify,NurseName,convert(varchar,NurseDate,101) as NurseDate1,Convert(varchar,NurseTime,100) as NurseTime1,Precipitating,Comments,DiastatVal,Call911Val from ZHT_STMainTable Z where Z.STDate between @StartDate and @EndDate and Z.ActiveStatus='A' and Z.StudentID IN (select S.StudentPersonalId from StudentPersonal S
              left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
              where StudentType='Client' and P.Location= @PlacementID and P.Status=1  and s.PlacementStatus='A' 
              and (p.EndDate is null or p.EndDate > GETDATE())) order by ClientName,STDate
              END

       END
       IF @ReportType=2
       BEGIN
              SET NOCOUNT ON;
       DECLARE @firstresult TABLE (mont int,yea int,Val int, Duration float)

       IF @StudentID=0 AND @PlacementID=0
       BEGIN

       insert into @firstresult
              select TMonth,TYear,COUNT(*) as val,SUM(Duration) as Duration from (select MONTH(STDate) as TMonth,YEAR(STDate) as TYear,ROUND((CAST(pm.[STDurMin] AS float)*60+ CAST(pm.[STDurSec] AS float)),2) as Duration from ZHT_STMainTable pm where ActiveStatus='A')itemnames Group by TYear,TMonth order by TYear,TMonth
       END
       ELSE IF @StudentID != 0
       BEGIN
              insert into @firstresult
              select TMonth,TYear,COUNT(*) as val,SUM(Duration) as Duration from (select MONTH(STDate) as TMonth,YEAR(STDate) as TYear,ROUND((CAST(pm.[STDurMin] AS float)*60+ CAST(pm.[STDurSec] AS float)),2) as Duration from ZHT_STMainTable pm where StudentID=@StudentID and ActiveStatus='A')itemnames Group by TYear,TMonth order by TYear,TMonth
       END
       ELSE IF @StudentID=0
       BEGIN

       insert into @firstresult

              select TMonth,TYear,COUNT(*) as val,SUM(Duration) as Duration from (select MONTH(STDate) as TMonth,YEAR(STDate) as TYear,ROUND((CAST(pm.[STDurMin] AS float)*60+ CAST(pm.[STDurSec] AS float)),2) as Duration from ZHT_STMainTable pm where StudentID IN (select S.StudentPersonalId from StudentPersonal S 
              left join Placement P on S.StudentPersonalId=P.StudentPersonalId 
              where StudentType='Client' and P.Location= @PlacementID and P.Status=1  and s.PlacementStatus='A' 
              and (p.EndDate is null or p.EndDate > GETDATE()))
              and ActiveStatus='A')itemnames Group by TYear,TMonth order by TYear,TMonth
       END

              

              DECLARE @FirstDate DATE = @StartDate
              DECLARE @LastDate Date = @EndDate
              DECLARE @CalendarMonths TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
              INSERT @CalendarMonths VALUES( @FirstDate)
              WHILE @FirstDate < @LastDate
              BEGIN
              SET @FirstDate = DATEADD( day,1, @FirstDate)
              INSERT @CalendarMonths VALUES( @FirstDate)
              END
              DECLARE @AllMonths TABLE (MID INT IDENTITY(1,1) PRIMARY KEY,Mn int,yr int)
              insert into @AllMonths select month(cdate),YEAR(cdate) from @CalendarMonths

              DECLARE @Finaltbl TABLE (Mn int,yr int)
              insert into @Finaltbl select Mn,yr from @AllMonths group by Mn,yr 

              
              select ft.Mn as TMonth,ft.yr as TYear,ISNULL(fr.Val,0) as val,ISNULL(ROUND(CAST(fr.Duration AS float),2),0) as Duration from @Finaltbl ft 
              left join @firstresult fr on ft.Mn=fr.mont AND ft.yr=fr.yea order by ft.yr,ft.Mn asc
       END
       
END
GO
