USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_RetrieveUI]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UINE_RetrieveUI]
	@EventId int,
	@FormNumber int
AS
BEGIN
		
	SET NOCOUNT ON;

	declare @UINEID int

	select @UINEID = (select IndFormID from [UINE_Forms] where  [UIEventID]=@EventId and [IndFormCode]='UI' and FormNumber=@FormNumber and ActiveInd='A')

select [UIEventID],[UINEID],StudentID1,StudentName1,StudentID2,StudentName2,StudentID3,StudentName3,StudentID4,StudentName4,StaffInvolID1,StaffInvolName1,StaffInvolPosition1,StaffInvolID2,StaffInvolName2,StaffInvolPosition2,StaffInvolID3,StaffInvolName3,StaffInvolPosition3,StaffInvolID4,StaffInvolName4,
StaffInvolPosition4,PgmSiteID,ProgramSite,ProgramGroup,LocID,LocOfIncident,UIDate,UITime,ReportDate,ReportTime,StaffCompRepID,StaffcompRepName,StaffCompRepPOs,IncidentDesc,chkinciAdminNot,InciAdminNotByID,InciAdminNotBy,InciAdminNotToID,InciAdminNotTo,
InciAdminNotDate,InciAdminNotTime,chkimmSupVerbNot,chkNurNot,NurNotByID,NurNotBy,NurNotToID,NurNotTo,NurNotDate,NurNotTime,FormStatus from [UINE_UI] where [UINEID]=@UINEID;

select [chkstdFirstAid],[chkstdDigitalPic],[chkstdITS],[chkstdInjWBC],[chkstdParentNot],[chkstdParentCaseNote],[chkstaffWorkersComp],[chkstaffDigitalPic],[chkstaffITS] from [UINE_Injury] where [UINEID]=@UINEID;

select [EmerOrPHcode],[BehavCode],[HealthCode],[ComCode],[OpCode],[PersonCode],[AdminRepReasonID],AdminRepReasonName,[DESERepCode] from [UINE_PrimaryReason] where [UINEID]=@UINEID;
select [FollowupDesc],[StaffCompFollReqID],StaffCompFollReqName,[StaffCompFollReqPos] from [UINE_FollowupReq] where [UINEID]=@UINEID;

select [chkResDir],[ResDirSigID],ResDirsigName,[ResDirSigPos],[ResDirSigDate],[ChkSchoolDir],[SchooDirSigID],SchoolDirSigName,[schoolDirSigPos],[ScholDirSigDate],[ChkNurPerson],[NursingSigID],NursingSigName,[NursingSigPos],[NursingSigDate] from [UINE_DirNurSign] where [UINEID]=@UINEID;

select  [chkAdmFurRewReq],[chkNoAdmRewReq],[AdminStaffSignID],[AdminStaffSign],[AdminStaffSignPos],[AdminStaffSignDate],[FurAdmRewDesc],[FurAdmRewsignID],[FurAdmRewSignName],[FurAdmRewSignPos],[FurAdmRewSignDate] from [UINE_AdmRew] where [UINEID]=@UINEID;


SELECT [ChkInvNecess],[InvestDesc],[ChkExecNot],[ChkFundorFamilyNot],[ChkInvReqNot],[ChkDCF],[DCFDate],[DCFTime],[DCFNotTo],[DCFNotBy],[ChkDPPC],[DPPCDate],[DPPCTime],[DPPCNotTo],[DPPCNotBy],[ChkDESE],[DESEDate],[DESETime],[DESENotTo],[DESENotBy],[ChkDEEC]
      ,[DEECDate],[DEECTime],[DEECNotTo],[DEECNotBy],[ChkLEA],[LEADate],[LEATime],[LEANotTo],[LEANotBy],[ChkFamGuardian],[FamGuarDate],[FamGuarTime],[FamGuarTo],[FamGuarBy],[ChkDDS],[DDSDate],[DDSTime],[DDSNotTo],[DDSNotBy]
       FROM [dbo].[UINE_Investigation] where [UINEID]=@UINEID;

SELECT [FinalReportDate]
      ,[ChkFinalDCF]
      ,[ChkFinalDPPC]
      ,[ChkFinalDESE]
      ,[ChkFinalDEEC]
      ,[ChkFinalLEA]
      ,[ChkFinalFamGuar]
      FROM [dbo].[UINE_FinalProc] where [UINEID]=@UINEID;

END










GO
