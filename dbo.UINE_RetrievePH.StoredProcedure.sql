USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_RetrievePH]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UINE_RetrievePH]
			@EventId int,
			@PHMainID int
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT [PHID]
      ,[UIEventID]
      ,[NameOfAgency]
      ,[StudentID]
      ,[StudentName]
      ,[DateOfRest]
	  ,GenderID
      ,[Gender]
      ,[ProgramID]
      ,[ProgramName]
      ,[SASSID]
      ,[StartTime]
      ,[EndTime]
      ,[SubjPeriodID]
      ,[SubjPeriod]
      ,[SendingDistrict]
      ,[chkStdIEP]
	  ,[DurationMin]
      ,[DurationSec]
      ,[TotalResTimeMin]
      ,[RestraintInterval]
      ,[FormStatus]
      ,[CreatedOn]
      ,[ModifiedOn]
      ,[ActiveInd],
	  [LocationName],OtherLocation, OtherLocationId
  FROM [dbo].[UINE_PHMain] where [PHID]=@PHMainID


  SELECT [PersonsInvolID]
      ,[UIEventID]
      ,[PHMainID]
      ,[Per1ID]
      ,[Per1Name]
      ,[Per1Title]
      ,[chkPer1BreathMngr]
      ,[chkPer1LeadMngr]
      ,[chkPer1PriorTrain]
      ,[Per2ID]
      ,[Per2Name]
      ,[Per2Title]
      ,[chkPer2BreathMngr]
      ,[chkPer2LeadMngr]
      ,[chkPer2PriorTrain]
      ,[Per3ID]
      ,[Per3Name]
      ,[Per3Title]
      ,[chkPer3BreathMngr]
      ,[chkPer3LeadMngr]
      ,[chkPer3PriorTrain]
      ,[Obsrv1ID]
      ,[Obsrv1Name]
      ,[Obsrv1Title]
      ,[chkObsrv1BreathMngr]
      ,[chkObsrv1LeadMgr]
      ,[chkObsrv1PriorTrain]
      ,[Obsrv2ID]
      ,[Obsrv2Name]
      ,[Obsrv2Title]
      ,[chkObsrv2BreathMngr]
      ,[chkObsrv2LeadMgr]
      ,[chkObsrv2PriorTrain]
      ,[Obsrv3ID]
      ,[Obsrv3Name]
      ,[Obsrv3Title]
      ,[chkObsrv3BreathMngr]
      ,[chkObsrv3LeadMgr]
      ,[chkObsrv3PriorTrain]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHPersons] where [PHMainID]=@PHMainID

  SELECT [AdminParID]
      ,[UIEventID]
      ,[PHMainID]
      ,[AdmininformedID]
      ,[AdminformedName]
      ,[AdminformedTitle]
      ,[AdminInfoRepbyID]
      ,[AdminInfoRepbyName]
      ,[AdminInfoRepbyTitle]
      ,[AdminApp20MinsID]
      ,[AdminApp20MinsName]
      ,[AdminApp20MinsTitle]
      ,[RepByApp20MinsID]
      ,[RepByApp20MinsName]
      ,[RepByApp20MinsTitle]
      ,[ParentNotName]
      ,[ParentPhone]
      ,[CalledByID]
      ,[CalledByName]
      ,[CalledByTitle]
      ,[CalledDate]
      ,[CalledTime]
      ,[DocContactVerbalDesc]
      ,[RepSntDate]
      ,[RepSntAddress]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHAdminParent] where [PHMainID]=@PHMainID

  SELECT [PrecJustID]
      ,[UIEventID]
      ,[PHMainID]
      ,[chkTask]
      ,[chkLeisure]
      ,[DescActivityPrior]
      ,[chkTantrum]
      ,[chkSelfInj]
      ,[chkAggression]
      ,[DescBehPromptRest]
      ,[chkPrecAdaptiveBeh]
      ,[chkstaffRedTask]
      ,[chkOppStdAdaptiveBeh]
      ,[chkStaffMovAway]
      ,[chkNonPhysicalNotEff]
      ,[chkprotectfromSerHarm]
      ,[chkprotectotherstd]
      ,[chkblockRed]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHPrecJust] where [PHMainID]=@PHMainID

  SELECT [RestUsedID]
      ,[UIEventID]
      ,[PHMainID]
      ,[chkCPISeatPosHand]
      ,[chkCPIstandPostHand]
      ,[chkCPIChldContStand]
      ,[chkCPIChldContSeat]
      ,[chkCPITeamCntr]
      ,[chkCPIIntCntrSeat]
      ,[chkCPIIntCntrStand]
      ,[chkCPIAPSStand]
      ,[chkCPIAPSErFloor]
	  ,[chksmallPVerCar]
      ,[chksmallPHorCar]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHRestUsed] where [PHMainID]=@PHMainID

  SELECT [StdBehCesInjID]
      ,[UIEventID]
      ,[PHMainID]
      ,[chkActRes]
      ,[chkPassive]
      ,[chkEmotionDist]
      ,[DescStdBeh]
      ,[chkDetStdCalm]
      ,[chkIntervAdm]
      ,[chkStaffMedAssis]
      ,[chkCesother]
      ,[DescCess]
      ,[chkStdInj]
      ,[StdInjDesc]
      ,[chkStaffInj]
      ,[StaffInkDesc]
      ,[chkNoInj]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHStdBehCessInj] where [PHMainID]=@PHMainID

  SELECT [DESEReqID]
      ,[UIEventID]
      ,[PHMainID]
      ,[DescInjMedCare]
      ,[DescAntecedent]
      ,[DescBehJustRest]
      ,[DescDeEscalation]
      ,[DescReasHold]
      ,[DescChildBeh]
      ,[DescDiscipline]
      ,[DescReason20Mins]
      ,[DtTimeParentNot]
      ,[AdminAppRestName]
      ,[AdminImmNot]
      ,[ParentNot24hrsDoc]
      ,[WritRepSntParent]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHDeseReq] where [PHMainID]=@PHMainID

  SELECT [FinalRepID]
      ,[UIEventID]
      ,[PHMainID]
      ,[SigNameID]
      ,[SigName]
      ,[SigTitle]
      ,[DtFinalRep]
      ,[ActiveInd]
  FROM [dbo].[UINE_PHFinalRep] where [PHMainID]=@PHMainID
 
	
END






GO
