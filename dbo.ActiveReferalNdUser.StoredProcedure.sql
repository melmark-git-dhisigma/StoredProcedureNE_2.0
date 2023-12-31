USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ActiveReferalNdUser]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ActiveReferalNdUser]
@Type varchar(max),
@SchoolId int,
@UserId int
as
begin
      
 IF   (@Type)='ChecklistUser'    
 begin
 select  CONVERT(VARCHAR(50),Sp.StudentPersonalId)+'_'+CONVERT(VARCHAR(50), Q.QueueId) as QueueId,Sp.LastName+','+Sp.FirstName as RefferalName, Q.QueueName as QueueName,Ur.UserLName+','+ Ur.UserFName  as UserName,'' as ImageUrl,'' as Gender,chkUsr.CreatedOn as AssignDate,letEng.ChecklistName as CheckListName from ref_QueueStatus Qs inner join ref_CheckListAssign ChA on Qs.QueueStatusId=ChA.QueueStatusId inner join StudentPersonal Sp on Qs.StudentPersonalId=Sp.StudentPersonalId inner join ref_CheckListUsers chkUsr on chkUsr.ChecklistUserId=ChA.AssignId inner join [dbo].[User] Ur on chkUsr.UserId=Ur.UserId inner join [dbo].[ref_Checklist] letEng on letEng.ChecklistId=ChA.CheckListId inner join ref_Queue Q On Q.QueueId=Qs.QueueId   where chkUsr.UserId=@UserId and Qs.Draft='Y' order by Qs.QueueStatusId desc
 END

 ELSE IF (@Type)='ActiveRefReferral'
 begin
 select  CONVERT(VARCHAR(50),Sp.StudentPersonalId)+'_'+CONVERT(VARCHAR(50), RQ.QueueId) as QueueId ,SP.LastName+','+SP.FirstName as RefferalName,RQ.QueueName,Ur.UserLName+','+Ur.UserFName  as UserName,SP.ImageUrl,SP.Gender,Ur.CreatedOn as AssignDate,'' as CheckListName	 FROM ref_QueueStatus Qs inner join StudentPersonal SP on Qs.StudentPersonalId=SP.StudentPersonalId inner join ref_Queue RQ on Qs.QueueId=RQ.QueueId inner join [dbo].[User] Ur on Qs.CreatedBy=Ur.UserId where SP.StudentType='Referral' and Qs.CurrentStatus='true' and Qs.SchoolId=@SchoolId
 end 

end










GO
