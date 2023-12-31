USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spFIEmail]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Khyati Desai
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ZHT_spFIEmail]
	AS
BEGIN
	SET NOCOUNT ON;

	
	DECLARE @FirstDate DATE 
	DECLARE @LastDate DATE 
	set @FirstDate = DATEADD(day, -3, GETDATE())
	set @LastDate = DATEADD(day, -1, GETDATE())
	DECLARE @CalendarMonths TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,cdate date)
	INSERT @CalendarMonths VALUES( @FirstDate)
	WHILE @FirstDate < @LastDate
	BEGIN
		SET @FirstDate = DATEADD( day,1, @FirstDate)
		INSERT @CalendarMonths VALUES( @FirstDate)
	END

	select * from @CalendarMonths

	 DECLARE @FITable TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,studentname varchar(100),StudentID int,FIDate date,TotQty int, Goal int, QtyDiff int)
	 INSERT @FITable
	 SELECT F1.ClientName,F1.StudentID,F1.FIDate,SUM(F1.FIQty) AS TotQty,G1.Goal,G1.Goal - sum(F1.FIQty)  as QtyDiff 
	 FROM ZHT_FIMainTable F1 
	 JOIN ZHT_FIGoals G1 ON F1.FIGoalID=G1.GoalID 
	 JOIN @CalendarMonths C1 ON F1.FIDate=C1.cdate
	 WHERE F1.ActiveStatus='A' 
	 GROUP BY F1.FIDate, F1.StudentID,F1.ClientName,G1.Goal 
	 ORDER BY F1.FIDate,F1.ClientName

	 DECLARE @StudentList TABLE(StudentID int, ClientName varchar(150))
	 INSERT @StudentList
	select G.StudentID, CONCAT(S.FirstName, ' ', S.LastName) from ZHT_FIGoals G JOIN StudentPersonal S ON G.StudentID=S.StudentPersonalId where G.ActiveStatus='A' order by S.FirstName


	 SELECT StudentID, ClientName FROM @StudentList st WHERE NOT EXISTS  
	 (SELECT StudentID from @FITable FI2 where st.StudentID=FI2.StudentID)


	 DECLARE @ResultTbl Table(FIDate date, studentid int, studentname varchar(100), TotQty int, Goal int, QtyDiff int) 
	 INSERT @ResultTbl
	 SELECT CAST(C1.cdate AS nvarchar(50)) as cdate, F2.StudentID,F2.studentname,F2.TotQty,ISNULL(F2.Goal,0) as Goal1,F2.QtyDiff FROM @CalendarMonths C1 inner JOIN @FITable F2 ON C1.cdate=F2.FIDate  

	 SELECT * FROM @ResultTbl where QtyDiff>0

	 select studentname, Count(*) as DataDays, COUNT(CASE WHEN QtyDiff > 0 THEN 1 END) as MissGoal, 3-Count(*) as NoData, count(*)-COUNT(CASE WHEN QtyDiff > 0 THEN 1 END) as MetGoal  from @ResultTbl group by studentname order by studentname
END
GO
