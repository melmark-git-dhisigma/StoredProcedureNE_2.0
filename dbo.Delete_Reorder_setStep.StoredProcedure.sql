USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[Delete_Reorder_setStep]    Script Date: 1/3/2025 7:21:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_Reorder_setStep]
@id INT, @type VARCHAR(10)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	DECLARE

	@sortOrder INT,
	@hdrId	INT,
	@DSTempParentStepId INT,
	@CNT INT,
	@Loop INT,
	@CNTSTEP INT,
	@DSPARENTID INT

	SET NOCOUNT ON;
	IF(@type = 'set')
	BEGIN
	SELECT @hdrId = DSTempHdrId, @sortOrder = SortOrder FROM DSTempSet WHERE DSTempSetId = @id

	UPDATE DSTempSet SET SortOrder = (SortOrder - 1) WHERE SortOrder > @sortOrder AND DSTempHdrId=@hdrId

	DELETE FROM DSTempSet WHERE DSTempSetId = @id

	CREATE TABLE #DSSTEP(ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),DSTempParentStepId INT);
	INSERT INTO #DSSTEP SELECT DSTempParentStepId from DSTEMPSTEP  where DSTempSetId=@id AND DSTempHdrId=@hdrId
	
	SET @CNTSTEP= (SELECT COUNT(*) FROM #DSSTEP)
	
	WHILE(@CNTSTEP>0)
	BEGIN
	SET @DSPARENTID= (SELECT DSTempParentStepId FROM #DSSTEP WHERE ID=@CNTSTEP)
	IF((SELECT COUNT(DSTempStepId) FROM DSTEMPSTEP WHERE DSTempParentStepId=@DSPARENTID AND DSTempHdrId=@hdrId)>1 )
	BEGIN
	UPDATE DSTempStep set ActiveInd='D' where DSTempSetId=@id  AND DSTempParentStepId=@DSPARENTID AND DSTempHdrId=@hdrId
	END
	ELSE 
	BEGIN 
	UPDATE DSTempStep set DstempsetId=0 where DSTempSetId=@id AND DSTempParentStepId=@DSPARENTID AND DSTempHdrId=@hdrId
	END
	set @CNTSTEP=@CNTSTEP-1
	END
	--UPDATE DSTempStep set ActiveInd='D' where DSTempSetId=@id

	CREATE TABLE #PARENTSET(ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),DSTempParentStepId INT ,SetIds VARCHAR(MAX),CNT INT,Data NVARCHAR(MAX));

	INSERT INTO #PARENTSET

	--SELECT DSTempParentStepId,SetIds,(SELECT COUNT(*) FROM Split(SetIds,',')) CNT,Data FROM (SELECT * FROM DSTempParentStep MT ---//Commmented for Fixing Errorlog production log 2020
	--CROSS APPLY ( SELECT * FROM Split(SetIds,',') ) f1) PARENTSET ---//Commmented for Fixing Errorlog production log 2020
	--WHERE PARENTSET.Data=@id ---//Commmented for Fixing Errorlog production log 2020

	SELECT DSTempParentStepId,SetIds,(SELECT COUNT(*) FROM Split(SetIds,',') WHERE CHARINDEX(',' ,SetIds) > 0) CNT,Data FROM (SELECT * FROM DSTempParentStep MT
	CROSS APPLY ( SELECT * FROM Split(SetIds,',') WHERE CHARINDEX(',' ,SetIds) > 0 ) f1) PARENTSET
	WHERE PARENTSET.Data=@id option (maxrecursion 0)

	SET @CNT= (SELECT COUNT(*) FROM #PARENTSET)

	WHILE(@CNT>0)
	BEGIN
	IF((SELECT CNT FROM #PARENTSET WHERE ID=@CNT)=2)
	BEGIN
	UPDATE DSTempParentStep SET SetIds='',SetNames='' WHERE DSTempParentStepId=(SELECT DSTempParentStepId FROM #PARENTSET WHERE ID=@CNT)
	END
	ELSE IF((SELECT CNT FROM #PARENTSET WHERE ID=@CNT)>2)
	BEGIN
	UPDATE DSTempParentStep SET SetIds=(SELECT STUFF((SELECT ','+ RTRIM(LTRIM(Data))  FROM (SELECT * FROM Split((SELECT SetIds FROM #PARENTSET 
	WHERE ID=@CNT),',')) SETNAME WHERE RTRIM(LTRIM(Data))<>CONVERT(NVARCHAR,@id) FOR XML PATH(''),root('MyString'),type).value('/MyString[1]',
	'varchar(max)') ,1,1,'')),SetNames=
	((SELECT STUFF((SELECT ','+ (SELECT SetCd FROM DSTempSet WHERE DSTempSetId=CONVERT(INT,RTRIM(LTRIM(Data))))  FROM (SELECT * FROM Split((SELECT SetIds FROM #PARENTSET 
	WHERE ID=@CNT),',')) SETNAME WHERE RTRIM(LTRIM(Data))<>CONVERT(NVARCHAR,@id) FOR XML PATH(''),root('MyString'),type).value('/MyString[1]',
	'varchar(max)') ,1,1,''))+',')
	 WHERE DSTempParentStepId=(SELECT DSTempParentStepId FROM #PARENTSET WHERE ID=@CNT)
	END
	SET @CNT=@CNT-1
	END


	DROP TABLE #PARENTSET
	END
	ELSE IF(@type = 'step')
	BEGIN

	SET @id=(SELECT DSTempParentStepId FROM DSTempStep WHERE DSTempStepId=@id)
	
	CREATE TABLE #PARENTSTEP(ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),DSTempStepId INT ,DSTempSetId INT,SortOrder INT);
	INSERT INTO #PARENTSTEP SELECT DSTempStepId,DSTempSetId,SortOrder FROM DSTempStep WHERE DSTempParentStepId=@id

	SET @CNT=(SELECT COUNT(*) FROM #PARENTSTEP)
	SET @Loop=1
	WHILE(@CNT>0)
	BEGIN
	SET @sortOrder=(SELECT SortOrder FROM #PARENTSTEP WHERE ID=@Loop)
	SET @hdrId=(SELECT DSTempSetId FROM #PARENTSTEP WHERE ID=@Loop)
	UPDATE DSTempStep SET SortOrder = (SortOrder - 1) WHERE SortOrder > @sortOrder AND DSTempSetId=@hdrId AND IsDynamic=0
	SET @CNT=@CNT-1
	SET @Loop=@Loop+1
	END	

	DROP TABLE #PARENTSTEP

	DELETE FROM DSTempStep WHERE DSTempParentStepId=@id
	DELETE FROM DSTempParentStep WHERE DSTempParentStepId = @id
	END

    
END

GO
