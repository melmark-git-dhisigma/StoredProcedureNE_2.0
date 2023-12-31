USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_DeleteUI]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UINE_DeleteUI]
	@UIForm INT,
	@EventID INT
AS
	BEGIN
	declare @UIID int

	select @UIID = (select IndFormID from UINE_Forms where UIEventID=@EventID and FormNumber=@UIForm and IndFormCode='UI');
	update UINE_Forms set ActiveInd='D' where IndFormID=@UIID and UIEventID=@EventID;	
	update UINE_Events set UINEUINum = UINEUINum-1 where UIEventID=@EventID and UINEUINum>0;
	update UINE_Events set ActiveInd='D' where UINEUINum=0 and UINEPHNum=0 and UINEITSNum=0 and UIEventID=@EventID;
	update UINE_UI set ActiveInd='D' where UINEID=@UIID and UIEventID=@EventID;
	update UINE_AdmRew set ActiveInd='D' where UINEID=@UIID and UIEventID=@EventID;
	update UINE_DirNurSign set ActiveInd='D' where UINEID=@UIID and UIEventID=@EventID;
	update UINE_FinalProc set ActiveInd='D' where UIEventID=@EventID and UINEID=@UIID;
	update UINE_FollowupReq set ActiveInd='D' where UIEventID=@EventID and UINEID=@UIID;
	update UINE_Injury set ActiveInd='D' where UIEventID=@EventID and UINEID=@UIID;
	update UINE_Investigation set ActiveInd='D' where UIEventID=@EventID and UINEID=@UIID;
	update UINE_PrimaryReason set ActiveInd='D' where UIEventID=@EventID and UINEID=@UIID;

	select ActiveInd from UINE_Events where UIEventID=@EventID;
	
	END
GO
