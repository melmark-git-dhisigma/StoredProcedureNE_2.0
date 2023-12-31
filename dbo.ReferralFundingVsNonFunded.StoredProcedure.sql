USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ReferralFundingVsNonFunded]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReferralFundingVsNonFunded]
@Fundtype varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;

    IF(@Fundtype='FD')
	BEGIN
--	SELECT        REFPROCESS.StudentPersonalId, CONTACTPERSONS.StaffName, REFPROCESS.studentName, SchoolId,
--CASE WHEN REFPROCESS.ImageUrl IS NULL OR REFPROCESS.ImageUrl='' THEN CASE WHEN Gender=1 THEN 
--	 (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M')
--      ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F')
--      END ELSE [ImageUrl] END AS [ImageUrl] 
--, CONTACTPERSONS.Nameofcontact
--,QueueType
--FROM            (SELECT        StudentPersonalId,Gender,SchoolId, studentName, ImageUrl,QueueType,
--                                                        (SELECT        MAX(QS.QueueProcess) AS Expr1
--                                                          FROM            ref_QueueStatus AS QS INNER JOIN
--                                                                                    ref_Queue AS Q ON Q.QueueId = QS.QueueId
--                                                          WHERE        (QS.StudentPersonalId = REFQUEUE.StudentPersonalId) AND (Q.QueueType = 'AV')) AS MaxProcess
--                          FROM            (SELECT        SD.StudentPersonalId, SD.LastName + ',' + SD.LastName AS studentName, SD.ImageUrl,SD.Gender,SD.SchoolId,REFQ.QueueType
--                                                    FROM            ref_QueueStatus AS REFST INNER JOIN
--                                                                              StudentPersonal AS SD ON SD.StudentPersonalId = REFST.StudentPersonalId INNER JOIN
--                                                                              ref_Queue AS REFQ ON REFQ.QueueId = REFST.QueueId
--                                                    WHERE        (REFQ.QueueType = 'AV') AND (SD.StudentType = 'Referral')) AS REFQUEUE) AS REFPROCESS LEFT JOIN
--                             (SELECT        REFCL.StaffName, REFCL.Nameofcontact, SD.StudentPersonalId, REFST.QueueProcess
--                               FROM            ref_CallLogs AS REFCL INNER JOIN
--                                                         ref_QueueStatus AS REFST ON REFST.QueueStatusId = REFCL.QueueStatusId INNER JOIN
--                                                         StudentPersonal AS SD ON SD.StudentPersonalId = REFST.StudentPersonalId) AS CONTACTPERSONS ON 
--                         CONTACTPERSONS.StudentPersonalId = REFPROCESS.StudentPersonalId AND CONTACTPERSONS.QueueProcess = REFPROCESS.MaxProcess



SELECT Funded.StudentPersonalId, Funded.StaffName, Funded.studentName, Funded.SchoolId,
Funded.ImageUrl 
, Funded.Nameofcontact
,QueueType FROM (SELECT REFPROCESS.StudentPersonalId, CONTACTPERSONS.StaffName, REFPROCESS.studentName, SchoolId,
CASE WHEN REFPROCESS.ImageUrl IS NULL OR REFPROCESS.ImageUrl='' THEN CASE WHEN Gender=1 THEN 
	 (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M')
      ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F')
      END ELSE [ImageUrl] END AS [ImageUrl] 
, CONTACTPERSONS.Nameofcontact
,QueueType
FROM            (SELECT        StudentPersonalId,Gender,SchoolId, studentName, ImageUrl,QueueType,
                                                        (SELECT        MAX(QS.QueueProcess) AS Expr1
                                                          FROM            ref_QueueStatus AS QS INNER JOIN
                                                                                    ref_Queue AS Q ON Q.QueueId = QS.QueueId
                                                          WHERE        (QS.StudentPersonalId = REFQUEUE.StudentPersonalId) AND (Q.QueueType = 'AV')) AS MaxProcess
                          FROM            (SELECT        SD.StudentPersonalId, SD.LastName + ',' + SD.LastName AS studentName, SD.ImageUrl,SD.Gender,SD.SchoolId,REFQ.QueueType
                                                    FROM            ref_QueueStatus AS REFST INNER JOIN
                                                                              StudentPersonal AS SD ON SD.StudentPersonalId = REFST.StudentPersonalId INNER JOIN
                                                                              ref_Queue AS REFQ ON REFQ.QueueId = REFST.QueueId
                                                    WHERE        (REFQ.QueueType = 'AV') AND (SD.StudentType = 'Referral')) AS REFQUEUE) AS REFPROCESS LEFT JOIN
                             (SELECT        REFCL.StaffName, REFCL.Nameofcontact, SD.StudentPersonalId, REFST.QueueProcess
                               FROM            ref_CallLogs AS REFCL INNER JOIN
                                                         ref_QueueStatus AS REFST ON REFST.QueueStatusId = REFCL.QueueStatusId INNER JOIN
                                                         StudentPersonal AS SD ON SD.StudentPersonalId = REFST.StudentPersonalId) AS CONTACTPERSONS ON 
                         CONTACTPERSONS.StudentPersonalId = REFPROCESS.StudentPersonalId AND CONTACTPERSONS.QueueProcess = REFPROCESS.MaxProcess) Funded
						 INNER JOIN ref_QueueStatus QStatus ON QStatus.StudentPersonalId=Funded.StudentPersonalId
						 WHERE QStatus.QueueId NOT IN (SELECT QueueId FROM ref_Queue WHERE QueueType='IL')
						 AND QStatus.QueueId IN (SELECT QueueId FROM ref_Queue WHERE QueueType='AV')
	END
	ELSE
	BEGIN
	 SELECT
						 SP.StudentPersonalId
						 ,MAX(QS.QueueProcess) AS QueueProcess
						 ,CL.StaffName
						 , SP.LastName+','+SP.FirstName AS StudentName
						 ,CASE WHEN [ImageUrl] IS NULL OR [ImageUrl]='' THEN CASE WHEN SP.Gender=1 THEN 
	 (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='M')
      ELSE  (SELECT FormatImg FROM [dbo].[DefaultImage] WHERE Sex='F')
      END ELSE [ImageUrl] END AS [ImageUrl] 
						 , CL.Nameofcontact						 
						   FROM StudentPersonal SP INNER JOIN ref_QueueStatus QS ON SP.StudentPersonalId=QS.StudentPersonalId
						 INNER JOIN ref_Queue Q ON Q.QueueId=QS.QueueId		
						 LEFT JOIN ref_CallLogs CL ON CL.QueueStatusId=QS.QueueStatusId				 
						 WHERE SP.StudentType='Referral' AND Q.QueueType IN ('WL') AND QS.CurrentStatus='True'
						 GROUP BY SP.StudentPersonalId
						 ,CL.StaffName
						 , SP.LastName
						 ,SP.FirstName 
						 , SP.ImageUrl
						 , CL.Nameofcontact
						 ,SP.Gender
	END
	
END


GO
