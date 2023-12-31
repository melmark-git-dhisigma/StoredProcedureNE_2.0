USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spFIGoals]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZHT_spFIGoals]
@StudentID INT, 
@Goal INT, 
@SubmittedBy INT, 
@SubmissionDate DATE, 
@SubmissionTime Time(7), 
@ActiveStatus varchar(1)
AS
BEGIN
	if ((select COUNT(*) from ZHT_FIGoals where ActiveStatus='A' and StudentID=@StudentID)>0)
	BEGIN 

	UPDATE ZHT_FIGoals SET ActiveStatus = 'D' WHERE ActiveStatus = 'A' and StudentID = @StudentID ; 
	Insert into ZHT_FIGoals (StudentID, Goal, SubmittedBy, SubmissionDate, SubmissionTime, ActiveStatus) values (@StudentID, @Goal, @SubmittedBy, @SubmissionDate, @SubmissionTime, @ActiveStatus);

	END

	ELSE

	BEGIN
	Insert into ZHT_FIGoals (StudentID, Goal, SubmittedBy, SubmissionDate, SubmissionTime, ActiveStatus) values (@StudentID, @Goal, @SubmittedBy, @SubmissionDate, @SubmissionTime, @ActiveStatus);
	END

END
GO
