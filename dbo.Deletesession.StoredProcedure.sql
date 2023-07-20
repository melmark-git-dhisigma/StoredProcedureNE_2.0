USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[Deletesession]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Deletesession]
AS
BEGIN
	
	SET NOCOUNT ON;

    DELETE from StdtSessionHdr where StdtSessionHdrId in (select StdtSessionHdrId from StdtSessionHdr INNER JOIN DSTempHdr on StdtSessionHdr.DSTempHdrId = DSTempHdr.DSTempHdrId where deletessn = 'true' and SessionStatusCd = 'D')
END

GO
