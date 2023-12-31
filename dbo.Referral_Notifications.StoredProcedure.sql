USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[Referral_Notifications]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Referral_Notifications]
@SchoolId int
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @School int

	
	SET @School=@SchoolId

	IF(@School<>0)
	BEGIN
	
	SELECT QueueId
	,CASE WHEN AttentionNeeded=-1 THEN
	(SELECT COUNT(*) FROM ref_QueueStatus QS INNER JOIN StudentPersonal SP ON QS.StudentPersonalId=SP.StudentPersonalId
	WHERE SP.StudentType='Referral' AND QS.CurrentStatus='True' AND SP.SchoolId=@School
	AND QS.QueueId IN (SELECT QueueId FROM ref_Queue WHERE MasterId=NOTIFY.QueueId))
	ELSE AttentionNeeded END AS AttentionNeeded
	,New
	,Total FROM (SELECT QueueId,CASE WHEN (QueueType<>'AV' AND QueueType<>'WL' AND QueueType<>'IL') THEN -1
	
	
	
	
	
	ELSE (SELECT COUNT(*) FROM ref_QueueStatus WHERE 
	QueueId=refqueue.QueueId AND CurrentStatus='True' AND SchoolId=@School) END AttentionNeeded,



	CASE WHEN (QueueType<>'AV' AND QueueType<>'WL' AND QueueType<>'IL' AND QueueType<>'RL') THEN (
	CASE WHEN (QueueType='PA') THEN ( SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE 
	QST.Draft='Y' AND QST.SchoolId=@School AND SP.StudentType='Referral' And QST.CurrentStatus='True' And QST.QueueId IN (Select QueueId From ref_Queue Where MasterId=(Select QueueId From ref_Queue Where QueueType='PA'))               ) ELSE (
	

	
	CASE WHEN (QueueType='IA') THEN (SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE 
	QST.Draft='Y' AND QST.SchoolId=@School AND SP.StudentType='Referral' And QST.CurrentStatus='True' And QST.QueueId IN (Select QueueId From ref_Queue Where MasterId=(Select QueueId From ref_Queue Where QueueType='IA')	)) ELSE (
	
	SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE 
	QST.Draft='Y' AND QST.SchoolId=@School AND SP.StudentType='Referral' And QST.CurrentStatus='True' And QST.QueueId IN (Select QueueId From ref_Queue Where MasterId=(Select QueueId From ref_Queue Where QueueType='AP')
	))
	
	
	 END) END) 
	ELSE (
	
	
	
	
	CASE WHEN (QueueType='AV' ) 
	THEN
	
	 (SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId
	INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE QST.QueueId In(Select QueueId from ref_Queue Where QueueType='AV') AND QST.Draft='Y' AND 
	QST.CurrentStatus='True' AND SP.StudentType='Referral' AND QST.SchoolId=@School)
	
	WHEN (QueueType='WL' ) 
	THEN
	(SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId
	INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE QST.QueueId In(Select QueueId from ref_Queue Where QueueType='WL') AND QST.Draft='Y' AND 
	QST.CurrentStatus='True' AND SP.StudentType='Referral' AND QST.SchoolId=@School)
	

	WHEN (QueueType='CL' ) 
	THEN
	(SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId
	INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE QST.QueueId In(Select QueueId from ref_Queue Where QueueType='CL') AND QST.Draft='Y' AND QST.CurrentStatus='True' AND SP.StudentType='Client' AND QST.SchoolId=@School)


	WHEN (QueueType='IL' ) 
	THEN
	 
	 (SELECT COUNT(DISTINCT QST.StudentPersonalId) FROM ref_QueueStatus QST INNER JOIN ref_Queue QU ON QST.QueueId=QU.QueueId
	INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QST.StudentPersonalId WHERE QST.QueueId In(Select QueueId from ref_Queue Where QueueType='IL') AND QST.Draft='Y' AND QST.CurrentStatus='True' AND SP.StudentType='Referral' AND QST.SchoolId=@School)  
	 
	 ELSE 0
	 END) END New,
	
	(SELECT COUNT(DISTINCT QS.StudentPersonalId) FROM ref_QueueStatus QS INNER JOIN StudentPersonal SP ON SP.StudentPersonalId=QS.StudentPersonalId WHERE Draft='Y' 
AND QS.CurrentStatus='True' AND QS.SchoolId=@School AND SP.StudentType='Referral')  Total FROM ref_Queue refqueue WHERE MasterId=0) NOTIFY
	
	END
END




GO
