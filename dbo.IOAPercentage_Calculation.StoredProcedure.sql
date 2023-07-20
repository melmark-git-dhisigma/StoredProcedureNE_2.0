USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[IOAPercentage_Calculation]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[IOAPercentage_Calculation]
@NormalSessHdr int,
@IOASessHdr int
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION	

	DECLARE @NormalSessHdrID int,
	@IOASessHdrID int,
	@Agreement int,
	@Disagreement int,
	@Total int,
	@ColumnNumber int,
	@ColumnType varchar(50),
	@NumberOfColumn int,
	@Cnt int,
	@StartLoopId int,
	@EndLoopId int,
	@IOAPer float,
	@SmallerTotal float,
	@LargerTotal float,
	@TempScrIOA float,
	@TempScrSess float,
	@IOAPercResult float,
	@IOASTEPVAL varchar(50),
	@NORMALSTEPVAL varchar(50)
	


    

	SET @NormalSessHdrID=@NormalSessHdr
	SET @IOASessHdrID=@IOASessHdr
	SET @Agreement=0
	SET @Disagreement=0
	SET @Total=0
	SET @ColumnNumber=0	
	SET @ColumnType=''
	SET @NumberOfColumn=0
	SET @Cnt=1
	SET @StartLoopId=0
	SET @EndLoopId=0
	

	IF OBJECT_ID('tempdb..#Normal') IS NOT NULL  
	DROP TABLE #Normal
	IF OBJECT_ID('tempdb..#IOA') IS NOT NULL  
	DROP TABLE #IOA
	IF OBJECT_ID('tempdb..#COLUMN') IS NOT NULL  
	DROP TABLE #COLUMN

	CREATE TABLE #Normal(ID	int PRIMARY KEY NOT NULL IDENTITY(1,1),ColID int,Coltype varchar(50),Stepval varchar(50));
	CREATE TABLE #IOA(ID	int PRIMARY KEY NOT NULL IDENTITY(1,1),ColID int,Coltype varchar(50),Stepval varchar(50));
	CREATE TABLE #COLUMN(ID	int PRIMARY KEY NOT NULL IDENTITY(1,1),ColID int,IOAPerc float);

	INSERT INTO #Normal
	SELECT Dtl.DSTempSetColId,Col.ColTypeCd,Dtl.StepVal FROM (StdtSessionDtl Dtl INNER JOIN DSTempSetCol Col
	ON Col.DSTempSetColId=Dtl.DSTempSetColId) INNER JOIN StdtSessionStep Stp 
	ON Stp.StdtSessionStepId=Dtl.StdtSessionStepId 
	WHERE StdtSessionHdrId=@NormalSessHdrID ORDER BY Dtl.DSTempSetColId,Dtl.StdtSessionDtlId

	INSERT INTO #IOA
	SELECT Dtl.DSTempSetColId,Col.ColTypeCd,Dtl.StepVal FROM (StdtSessionDtl Dtl INNER JOIN DSTempSetCol Col
	ON Col.DSTempSetColId=Dtl.DSTempSetColId) INNER JOIN StdtSessionStep Stp 
	ON Stp.StdtSessionStepId=Dtl.StdtSessionStepId 
	WHERE StdtSessionHdrId=@IOASessHdrID ORDER BY Dtl.DSTempSetColId,Dtl.StdtSessionDtlId

	INSERT INTO #COLUMN 
	SELECT DISTINCT ColID,NULL FROM #Normal ORDER BY ColID

	SET @NumberOfColumn=(SELECT COUNT(DISTINCT ColID) FROM #Normal)
	WHILE(@NumberOfColumn>0)
	BEGIN
	SET @ColumnNumber=(SELECT ColID FROM #COLUMN WHERE ID=@Cnt)
	SET @StartLoopId=(SELECT TOP 1 ID FROM #Normal WHERE ColID=@ColumnNumber ORDER BY ID)
	SET @EndLoopId =(SELECT TOP 1 ID FROM #Normal WHERE ColID=@ColumnNumber ORDER BY ID DESC)
	SET @ColumnType=(SELECT Coltype FROM #Normal WHERE ID=@StartLoopId)
	SET @Agreement=0
	SET @Disagreement=0	
	SET @SmallerTotal=0.0
	SET @LargerTotal=0.0
	SET @TempScrIOA=0.0
	SET @TempScrSess=0.0
	IF(@ColumnType='+/-' OR @ColumnType='Prompt' OR @ColumnType='Text')	
	BEGIN	
	WHILE(@StartLoopId<=@EndLoopId)
	BEGIN
	
	SET @NORMALSTEPVAL=''
	SET @IOASTEPVAL=''
	SET @NORMALSTEPVAL=(SELECT Stepval FROM #Normal WHERE ID=@StartLoopId)
	SET @IOASTEPVAL=(SELECT Stepval FROM #IOA WHERE ID=@StartLoopId)
	
	IF((@NORMALSTEPVAL<>'' OR @IOASTEPVAL<>'')AND(@NORMALSTEPVAL<>'0' OR @IOASTEPVAL<>'0')AND(@NORMALSTEPVAL<>'-1' OR @IOASTEPVAL<>'-1'))
	  BEGIN
	   IF(@NORMALSTEPVAL=@IOASTEPVAL)
		      BEGIN
			   SET @Agreement=@Agreement+1
	         END
	    ELSE 
		     BEGIN
			  SET @Disagreement=@Disagreement+1
	         END
	   END
	 SET @StartLoopId=@StartLoopId+1
	END	
	
	IF(@Agreement=0 AND @Disagreement=0)
	  BEGIN
	   SET @IOAPer=0
	  END
    ELSE
	  BEGIN
	  SET @IOAPer=(CONVERT(float,@Agreement)/(CONVERT(float,@Agreement)+CONVERT(float,@Disagreement)))*100
	  UPDATE #COLUMN SET IOAPerc=@IOAPer WHERE ColID=@ColumnNumber
	  END
	END	
	ELSE
	BEGIN
	SET @TempScrSess=(SELECT AVG(CASE WHEN Score='-1' THEN 0 ELSE Score END) FROM StdtSessColScore WHERE StdtSessionHdrId=@NormalSessHdrID and DSTempSetColId=@ColumnNumber)
	SET @TempScrIOA=(SELECT AVG(CASE WHEN Score='-1' THEN 0 ELSE Score END) FROM StdtSessColScore WHERE StdtSessionHdrId=@IOASessHdrID and DSTempSetColId=@ColumnNumber)
	IF(@TempScrIOA>@TempScrSess)
	BEGIN
	SET @SmallerTotal=@TempScrSess
	SET @LargerTotal=@TempScrIOA
	END
	ELSE
	BEGIN
	SET @SmallerTotal=@TempScrIOA
	SET @LargerTotal=@TempScrSess
	END
	SET @IOAPer=((@SmallerTotal/@LargerTotal)*100)
	UPDATE #COLUMN SET IOAPerc=@IOAPer WHERE ColID=@ColumnNumber
	END
	SET @NumberOfColumn=@NumberOfColumn-1
	SET @Cnt=@Cnt+1
	END


	SET @IOAPercResult=(SELECT AVG(IOAPerc) FROM #COLUMN)
	--Select * from #COLUMN
	--Select * from #Normal
	--Select * from #IOA
	--Select @IOAPercResult
	DROP TABLE #COLUMN
	DROP TABLE #Normal
	DROP TABLE #IOA

	UPDATE StdtSessionHdr SET IOAPerc=CONVERT(varchar(50),@IOAPercResult) WHERE StdtSessionHdrId IN (@NormalSessHdrID,@IOASessHdrID) AND IOAInd='Y'
	COMMIT
	END TRY
	BEGIN CATCH
	ROLLBACK
	END CATCH
	
END











GO
