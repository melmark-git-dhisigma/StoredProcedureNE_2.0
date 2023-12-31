USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_DeletePH]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[UINE_DeletePH]
	@PHID int,
	@EventID int
AS
	BEGIN
	update UINE_Forms set ActiveInd='D' where IndFormID=@PHID and UIEventID=@EventID;	
	update UINE_Events set UINEPHNum = UINEPHNum-1 where UIEventID=@EventID and UINEPHNum>0;
	update UINE_Events set ActiveInd='D' where UINEUINum=0 and UINEPHNum=0 and UINEITSNum=0 and UIEventID=@EventID;
	update UINE_PHMain set ActiveInd='D' where UIEventID=@EventID and PHID=@PHID;
	update UINE_PHAdminParent set ActiveInd='D' where UIEventID=@EventID and PHMainID=@PHID;
	update UINE_PHDeseReq set ActiveInd='D' where UIEventID=@EventID and PHMainID=@PHID;
	update UINE_PHFinalRep set ActiveInd='D' where UIEventID=@EventID and PHMainID=@PHID;
	update UINE_PHPersons set ActiveInd='D' where UIEventID=@EventID and PHMainID=@PHID;
	update UINE_PHPrecJust set ActiveInd = 'D' where UIEventID = @EventID and PHMainID=@PHID;
	update UINE_PHRestUsed set ActiveInd='D' where UIEventID=@EventID and PHMainID=@PHID;
	update UINE_PHStdBehCessInj set ActiveInd='D' where UIEventID=@EventID and PHMainID=@PHID;

	select ActiveInd from UINE_Events where UIEventID=@EventID;
	
	END
GO
