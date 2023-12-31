USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ALLPHReport]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[UINE_ALLPHReport] 
	@str1 date,
	@str2 date,
	@Pgm int,
	@StdID int,
	@AgencyFlag varchar(20),
	@PgmFlag int,
	@PgmGroup Varchar(200)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF (@PgmFlag = 0)
BEGIN


		select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,PH.LocationName as Location, PH.OtherLocation as OtherLocation, CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
									CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,
									CASE WHEN ps.Per1Name <> '--Select--' THEN ps.Per1Name ELSE 'NA' END As StaffName1,ps.Per1Title As StaffTitle1
									 ,ps.[chkPer1BreathMngr] as Person1BreathingMngr
									,ps.[chkPer1LeadMngr] as Person1LeadMngr
										 ,ps.[chkPer1PriorTrain] as Person1PriorTraining										 						  
											,CASE WHEN ps.[Per2Name] <> '--Select--' THEN ps.[Per2Name] ELSE 'NA' END As StaffName2
											,ps.[Per2Title] as StaffTitle2
											,ps.[chkPer2BreathMngr] as Person2BreathingMngr
										,ps.[chkPer2LeadMngr] as Person2LeadMngr
										,ps.[chkPer2PriorTrain] as Person2PriorTraining										
										 ,CASE WHEN ps.[Per3Name] <> '--Select--' THEN ps.[Per3Name] ELSE 'NA' END As StaffName3
										,ps.[Per3Title] as StaffTitle3
										,ps.[chkPer3BreathMngr] as Person3BreathingMngr
										,ps.[chkPer3LeadMngr] as Person3LeadMngr
										,ps.[chkPer3PriorTrain] as Person3PriorTraining										      
											  ,CASE WHEN ps.[Obsrv1Name] <> '--Select--' THEN ps.[Obsrv1Name] ELSE 'NA' END As Observer1Name
											,ps.[Obsrv1Title] as Observer1Title
											 ,ps.[chkObsrv1BreathMngr] as Observer1BreathingMngr
											,ps.[chkObsrv1LeadMgr] as Observer1LeadMngr
											,ps.[chkObsrv1PriorTrain] as Observer1PriorTraining																	
									,CASE WHEN ps.[Obsrv2Name] <> '--Select--' THEN ps.[Obsrv2Name] ELSE 'NA' END As Observer2Name
									  ,ps.[Obsrv2Title] as Observer2Title
									  ,ps.[chkObsrv2BreathMngr] as Observer2BreathingMngr
									  ,ps.[chkObsrv2LeadMgr] as Observer2LeadMngr
									  ,ps.[chkObsrv2PriorTrain] as Observer2PriorTraining					 
									  ,CASE WHEN ps.[Obsrv3Name] <> '--Select--' THEN ps.[Obsrv3Name] ELSE 'NA' END As Observer3Name
									  ,ps.[Obsrv3Title] as Observer3Title
									  ,ps.[chkObsrv3BreathMngr] as Observer3BreathingMngr
									  ,ps.[chkObsrv3LeadMgr] as Observer3LeadMngr
									  ,ps.[chkObsrv3PriorTrain] as Observer3PriorTraining
									  ,[AdminformedName] as AdminInformed
									  ,[AdminformedTitle] As AdminInformedTitle
									  ,[AdminInfoRepbyName] as "Staff Who Reported Info to Admin"
									  ,[AdminInfoRepbyTitle] as "Staff Who Reported Info to Admin Title"												  
										  ,CASE WHEN AdmPar.[AdminApp20MinsName] <> '--Select--' THEN AdmPar.[AdminApp20MinsName] ELSE 'NA' END As "Admin Who Approved 20Mins"
										  ,[AdminApp20MinsTitle] as "Admin Who Approved 20Mins Title"										 
										  
										  ,CASE WHEN AdmPar.[RepByApp20MinsName] <> '--Select--' THEN AdmPar.[RepByApp20MinsName] ELSE 'NA' END As "Staff who Reported for Admin Approval above 20Mins"
										  ,[RepByApp20MinsTitle] As "Staff who Reported for Admin Approval above 20Mins Title"
										  ,[ParentNotName] As "Parent Notified"
										  ,[ParentPhone] As "Parent Phone"
										  ,[CalledByName] As "Staff who Called Parent"
										  ,[CalledByTitle] As "Staff who Called Parent Title"
										  ,CONVERT(VARCHAR(10),CalledDate,101) As "Parent Called on"
										  ,[CalledTime] As "Parent Call Time"
										  ,[DocContactVerbalDesc] As "Documented attempts to contact verbally"
										  ,CONVERT(VARCHAR(10),RepSntDate,101) As "Parent report sent on"
										  ,[RepSntAddress] As "Parent report sent Address"
									    ,[chkTask] As "Activity/Environment prior to Behav(Task)"
									  ,[chkLeisure] As "Activity/Environment prior to Behav(Leisure)"
									  ,[DescActivityPrior] As "Desc. of Activity prior to Behav"
									  ,[chkTantrum] As "Behav that prompted the PH(Tantrum)"
									  ,[chkSelfInj] As "Behav that prompted the PH(Self Inj)"
									  ,[chkAggression] As "Behav that prompted the PH(Aggression)"
									  ,[DescBehPromptRest] As "Desc. of Behav that prompted the PH"
									  ,[chkPrecAdaptiveBeh] As "De-escalateQ1"
									  ,[chkstaffRedTask] As "De-escalateQ2"
									  ,[chkOppStdAdaptiveBeh] As "De-escalateQ3"
									  ,[chkStaffMovAway] As "De-escalateQ4"
									  ,[chkNonPhysicalNotEff] As "JustificationQ1"
									  ,[chkprotectfromSerHarm] As "JustificationQ2"
									  ,[chkprotectotherstd] As "JustificationQ3"
									  ,[chkblockRed] As "JustificationQ4"
									       ,[chkActRes] As "Behav. during Restrint(Active Resist.)"
									  ,[chkPassive] As "Behav. during Restrint(Passive)"
									  ,[chkEmotionDist] As "Behav. during Restrint(Emotional Distress)"
									  ,[DescStdBeh] As "Desc. of Student Behavior during Restraint"
									  ,[chkDetStdCalm] As "CessationQ1"
									  ,[chkIntervAdm] As "CessationQ2"
									  ,[chkStaffMedAssis] As "CessationQ3"
									  ,[chkCesother] As "CessationQ4"
									  ,[DescCess] As "Desc. of Cessation of Restraint"
									  ,[chkStdInj] As "Student Injury"
									  ,[StdInjDesc] As "StudentInjury Desc."
									  ,[chkStaffInj] As "Staff Injury"
									  ,[StaffInkDesc] As "StaffInjury Desc."
									  ,[chkNoInj] As "No Injury"
									  	  ,[DescInjMedCare] As "Description of injuries to each individual and medical care provided,if any:"
										  ,[DescAntecedent] As "Antecedent Activity (describe the setting/environment prior to restraint):"
										  ,[DescBehJustRest] As "Behavior that justified the need to use restraint:"
										  ,[DescDeEscalation] As "Description of de-escalation techniques and alternatives to restraint that were attempted:"
										  ,[DescReasHold] As "Description of why restraint was chosen;"
										  ,[DescChildBeh] As "Description of child's behavior and reaction during the restraint"
										  ,[DescDiscipline] As "Description of discipline and/or further action that may be taken, if appropriate:"
										  ,[DescReason20Mins] As "If a single restraint hold lasted longer than 20 minutes, provide explanation"
										  ,[DtTimeParentNot] As "Date,Time, and Method of Parental Notification:"
										  ,[AdminAppRestName] As "Name of the administrator who approved continuation of restraint:"
										  ,[AdminImmNot] As "Name of the administrator who was immediately notified of restraint:"
										  ,[ParentNot24hrsDoc] As "Parent/Guardian Notification or documented attempts to contact within 24 hrs"
										  ,[WritRepSntParent] As "Written report of administration of restraint sent to parent/guardian"
										  		  ,CASE WHEN Finrep.[SigName] <> '--Select--' THEN Finrep.[SigName] ELSE 'NA' END as "Staff Signed"
										  ,[SigTitle] As "Staff Signed Title"
										  ,CONVERT(VARCHAR(10),DtFinalRep,101) as DateSigned
									 from [UINE_PHMain] PH 

									 inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									inner Join [UINE_PHAdminParent] AdmPar on PH.[PHID] = AdmPar.PHMainID
									Inner Join [UINE_PHStdBehCessInj] Behcess on PH.[PHID] = Behcess.PHMainID
									inner Join [UINE_PHPrecJust] precjust on PH.[PHID] = precjust.PHMainID
									inner Join [UINE_PHDeseReq] desereq on PH.[PHID] = desereq.PHMainID
									inner join [UINE_PHFinalRep] Finrep on PH.[PHID] = Finrep.PHMainID
									where PH.[ActiveInd]='A' and form.IndFormCode='PH' and 

									[ProgramID] =IIF(@Pgm IS NULL, [ProgramID], @Pgm ) and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc

									END
IF (@PgmFlag = 1)
BEGIN



	select Distinct PH.[UIEventID],ev.UIEventNum,form.FormNumber as PHID,PH.[PHID] as MainID,[DateOfRest],CONVERT(VARCHAR(10),DateOfRest,101) as RestraintDate,StudentName,PH.SendingDistrict,lk.LookupName as Setting,ProgramName,PH.LocationName as Location, PH.OtherLocation as OtherLocation,CONVERT(varchar(15),  CAST(StartTime AS TIME), 100) as RestStartTime,
					CONVERT(varchar(15),  CAST(EndTime AS TIME), 100) as RestEndTime,[TotalResTimeMin] as Duration,RestraintInterval as TimeInterval,Res.Holds,
									CASE WHEN ps.Per1Name <> '--Select--' THEN ps.Per1Name ELSE 'NA' END As StaffName1,ps.Per1Title As StaffTitle1
									 ,ps.[chkPer1BreathMngr] as Person1BreathingMngr
									,ps.[chkPer1LeadMngr] as Person1LeadMngr
										 ,ps.[chkPer1PriorTrain] as Person1PriorTraining										 						  
											,CASE WHEN ps.[Per2Name] <> '--Select--' THEN ps.[Per2Name] ELSE 'NA' END As StaffName2
											,ps.[Per2Title] as StaffTitle2
											,ps.[chkPer2BreathMngr] as Person2BreathingMngr
										,ps.[chkPer2LeadMngr] as Person2LeadMngr
										,ps.[chkPer2PriorTrain] as Person2PriorTraining										
										 ,CASE WHEN ps.[Per3Name] <> '--Select--' THEN ps.[Per3Name] ELSE 'NA' END As StaffName3
										,ps.[Per3Title] as StaffTitle3
										,ps.[chkPer3BreathMngr] as Person3BreathingMngr
										,ps.[chkPer3LeadMngr] as Person3LeadMngr
										,ps.[chkPer3PriorTrain] as Person3PriorTraining										      
											  ,CASE WHEN ps.[Obsrv1Name] <> '--Select--' THEN ps.[Obsrv1Name] ELSE 'NA' END As Observer1Name
											,ps.[Obsrv1Title] as Observer1Title
											 ,ps.[chkObsrv1BreathMngr] as Observer1BreathingMngr
											,ps.[chkObsrv1LeadMgr] as Observer1LeadMngr
											,ps.[chkObsrv1PriorTrain] as Observer1PriorTraining																	
									,CASE WHEN ps.[Obsrv2Name] <> '--Select--' THEN ps.[Obsrv2Name] ELSE 'NA' END As Observer2Name
									  ,ps.[Obsrv2Title] as Observer2Title
									  ,ps.[chkObsrv2BreathMngr] as Observer2BreathingMngr
									  ,ps.[chkObsrv2LeadMgr] as Observer2LeadMngr
									  ,ps.[chkObsrv2PriorTrain] as Observer2PriorTraining					 
									  ,CASE WHEN ps.[Obsrv3Name] <> '--Select--' THEN ps.[Obsrv3Name] ELSE 'NA' END As Observer3Name
									  ,ps.[Obsrv3Title] as Observer3Title
									  ,ps.[chkObsrv3BreathMngr] as Observer3BreathingMngr
									  ,ps.[chkObsrv3LeadMgr] as Observer3LeadMngr
									  ,ps.[chkObsrv3PriorTrain] as Observer3PriorTraining
									  ,[AdminformedName] as AdminInformed
									  ,[AdminformedTitle] As AdminInformedTitle
									  ,[AdminInfoRepbyName] as "Staff Who Reported Info to Admin"
									  ,[AdminInfoRepbyTitle] as "Staff Who Reported Info to Admin Title"												  
										  ,CASE WHEN AdmPar.[AdminApp20MinsName] <> '--Select--' THEN AdmPar.[AdminApp20MinsName] ELSE 'NA' END As "Admin Who Approved 20Mins"
										  ,[AdminApp20MinsTitle] as "Admin Who Approved 20Mins Title"										 
										  
										  ,CASE WHEN AdmPar.[RepByApp20MinsName] <> '--Select--' THEN AdmPar.[RepByApp20MinsName] ELSE 'NA' END As "Staff who Reported for Admin Approval above 20Mins"
										  ,[RepByApp20MinsTitle] As "Staff who Reported for Admin Approval above 20Mins Title"
										  ,[ParentNotName] As "Parent Notified"
										  ,[ParentPhone] As "Parent Phone"
										  ,[CalledByName] As "Staff who Called Parent"
										  ,[CalledByTitle] As "Staff who Called Parent Title"
										  ,CONVERT(VARCHAR(10),CalledDate,101) As "Parent Called on"
										  ,[CalledTime] As "Parent Call Time"
										  ,[DocContactVerbalDesc] As "Documented attempts to contact verbally"
										  ,CONVERT(VARCHAR(10),RepSntDate,101) As "Parent report sent on"
										  ,[RepSntAddress] As "Parent report sent Address"
									    ,[chkTask] As "Activity/Environment prior to Behav(Task)"
									  ,[chkLeisure] As "Activity/Environment prior to Behav(Leisure)"
									  ,[DescActivityPrior] As "Desc. of Activity prior to Behav"
									  ,[chkTantrum] As "Behav that prompted the PH(Tantrum)"
									  ,[chkSelfInj] As "Behav that prompted the PH(Self Inj)"
									  ,[chkAggression] As "Behav that prompted the PH(Aggression)"
									  ,[DescBehPromptRest] As "Desc. of Behav that prompted the PH"
									  ,[chkPrecAdaptiveBeh] As "De-escalateQ1"
									  ,[chkstaffRedTask] As "De-escalateQ2"
									  ,[chkOppStdAdaptiveBeh] As "De-escalateQ3"
									  ,[chkStaffMovAway] As "De-escalateQ4"
									  ,[chkNonPhysicalNotEff] As "JustificationQ1"
									  ,[chkprotectfromSerHarm] As "JustificationQ2"
									  ,[chkprotectotherstd] As "JustificationQ3"
									  ,[chkblockRed] As "JustificationQ4"
									       ,[chkActRes] As "Behav. during Restrint(Active Resist.)"
									  ,[chkPassive] As "Behav. during Restrint(Passive)"
									  ,[chkEmotionDist] As "Behav. during Restrint(Emotional Distress)"
									  ,[DescStdBeh] As "Desc. of Student Behavior during Restraint"
									  ,[chkDetStdCalm] As "CessationQ1"
									  ,[chkIntervAdm] As "CessationQ2"
									  ,[chkStaffMedAssis] As "CessationQ3"
									  ,[chkCesother] As "CessationQ4"
									  ,[DescCess] As "Desc. of Cessation of Restraint"
									  ,[chkStdInj] As "Student Injury"
									  ,[StdInjDesc] As "StudentInjury Desc."
									  ,[chkStaffInj] As "Staff Injury"
									  ,[StaffInkDesc] As "StaffInjury Desc."
									  ,[chkNoInj] As "No Injury"
									  	  ,[DescInjMedCare] As "Description of injuries to each individual and medical care provided,if any:"
										  ,[DescAntecedent] As "Antecedent Activity (describe the setting/environment prior to restraint):"
										  ,[DescBehJustRest] As "Behavior that justified the need to use restraint:"
										  ,[DescDeEscalation] As "Description of de-escalation techniques and alternatives to restraint that were attempted:"
										  ,[DescReasHold] As "Description of why restraint was chosen;"
										  ,[DescChildBeh] As "Description of child's behavior and reaction during the restraint"
										  ,[DescDiscipline] As "Description of discipline and/or further action that may be taken, if appropriate:"
										  ,[DescReason20Mins] As "If a single restraint hold lasted longer than 20 minutes, provide explanation"
										  ,[DtTimeParentNot] As "Date,Time, and Method of Parental Notification:"
										  ,[AdminAppRestName] As "Name of the administrator who approved continuation of restraint:"
										  ,[AdminImmNot] As "Name of the administrator who was immediately notified of restraint:"
										  ,[ParentNot24hrsDoc] As "Parent/Guardian Notification or documented attempts to contact within 24 hrs"
										  ,[WritRepSntParent] As "Written report of administration of restraint sent to parent/guardian"
										  		  ,CASE WHEN Finrep.[SigName] <> '--Select--' THEN Finrep.[SigName] ELSE 'NA' END as "Staff Signed"
										  ,[SigTitle] As "Staff Signed Title"
										  ,CONVERT(VARCHAR(10),DtFinalRep,101) as DateSigned
									 from [UINE_PHMain] PH 

									 inner join UINE_Events ev on ev.UIEventID= PH.UIEventID
									inner join UINE_Forms form on PH.[PHID] = form.IndFormID
									Inner Join UINE_Lookup lk on PH.ProgramName=lk.LookupCode
									Inner Join UINE_PHRestUsed Res on PH.[PHID] = REs.PHMainID
									Inner Join UINE_PHPersons ps on PH.[PHID] = ps.PHMainID
									inner Join [UINE_PHAdminParent] AdmPar on PH.[PHID] = AdmPar.PHMainID
									inner Join [UINE_PHDeseReq] desereq on PH.[PHID] = desereq.PHMainID
									inner join [UINE_PHFinalRep] Finrep on PH.[PHID] = Finrep.PHMainID
									inner Join [UINE_PHPrecJust] precjust on PH.[PHID] = precjust.PHMainID
									inner Join [UINE_PHStdBehCessInj] Behcess on PH.[PHID] = Behcess.PHMainID
									where PH.[ActiveInd]='A' and form.IndFormCode='PH' and 

									PH.ProgramGroup=@PgmGroup and
									[StudentID] =IIF(@StdID IS NULL, [StudentID], @StdID ) and

									PH.AgencyFlag = @AgencyFlag and
									PH.[DateOfRest] between @str1 and @str2
									order by [DateOfRest] desc

									END

END

									







GO
