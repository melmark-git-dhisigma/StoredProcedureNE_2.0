USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_DeleteITS]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UINE_DeleteITS]
	@ItsID INT,
	@EventID INT
AS
	BEGIN
	update UINE_Forms set ActiveInd='D' where IndFormID=@ItsID and UIEventID=@EventID;	
	update UINE_Events set UINEITSNum = UINEITSNum-1 where UIEventID=@EventID and UINEITSNum>0;
	update UINE_Events set ActiveInd='D' where UINEUINum=0 and UINEPHNum=0 and UINEITSNum=0 and UIEventID=@EventID;
	update UINE_ITSMainTable set ActiveInd='D' where EventID=@EventID and ItsID=@ItsID
	update UINE_ITSTrauma set ActiveInd='D' where ActiveInd != 'I' and ItsID=@ItsID and EventID=@EventID
	select ActiveInd from UINE_Events where UIEventID=@EventID;
	
	END
GO
