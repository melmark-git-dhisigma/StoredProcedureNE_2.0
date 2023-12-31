USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[UINE_ChangeFlags]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UINE_ChangeFlags]
@EventID int,
@FormStatus char(1)

AS
BEGIN
  
	UPDATE UINE_Events SET FormStatus=@FormStatus WHERE UIEventID=@EventID AND ActiveInd='A';


	if exists (select * from uine_ui where UIEventID=@EventID and ActiveInd='A') 
	BEGIN 
	UPDATE UINE_UI SET FormStatus=@FormStatus WHERE UIEventID=@EventID AND ActiveInd='A';
	END

	IF EXISTS (SELECT * FROM UINE_PHMain WHERE UIEventID=@EventID AND ActiveInd='A') 
	BEGIN 
	UPDATE UINE_PHMain SET FormStatus=@FormStatus WHERE UIEventID=@EventID AND ActiveInd='A';
	END

	IF EXISTS (SELECT * FROM UINE_ITSMainTable WHERE EventID=@EventID AND ActiveInd='A')
	BEGIN 
	UPDATE UINE_ITSMainTable SET FormStatus=@FormStatus WHERE EventID=@EventID AND ActiveInd='A';
	UPDATE UINE_ITSTrauma SET FormStatus=@FormStatus WHERE EventID=@EventID AND ActiveInd='A';
	END
END



GO
