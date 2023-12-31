USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[IOABehaviorPercentage_Calculation]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[IOABehaviorPercentage_Calculation]
@MeasurmentId INT,
@StudentId INT,
@BehaviorIOAId INT,
@NormalBehavId INT,
@Status VARCHAR(15)

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

	DECLARE 
	@Frequency BIT,
	@YesOrNo BIT,
	@Interval BIT,
	@IfPerInterval BIT,
	@NormalDur FLOAT,
	@IOAdur FLOAT,
	@NormalFrq INT,
	@IOAfrq INT,
	@FrqPerc FLOAT,
	@NormalYesOrNo INT,
	@IOAYesOrNo INT,
	@YesOrNoPerc INT,
	@EventTime DATETIME,
	@Stat INT


	SET @Frequency=(SELECT Frequency FROM BehaviourDetails WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId)
	SET @YesOrNo=(SELECT YesOrNo FROM BehaviourDetails WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId)
	SET @Interval=(SELECT PartialInterval FROM BehaviourDetails WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId)

	IF(@Status='Frequency')
		SET @Stat=1
	ELSE IF(@Status='YesOrNo')
		SET @Stat=2

	----------FREQUNCY----------
	IF( @Frequency=1 AND @Stat=1)
	BEGIN 		
		SET @NormalFrq=(SELECT FrequencyCount FROM Behaviour WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviourId=@NormalBehavId)		
		IF(@NormalFrq IS NOT NULL)
		BEGIN
			SET @IOAfrq= (SELECT FrequencyCount FROM BehaviorIOADetails WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviorIOAId=@BehaviorIOAId)	
			IF(@NormalFrq = 0 AND @IOAfrq = 0)
				SET @FrqPerc = 100	
			ELSE IF(@NormalFrq<=@IOAfrq)
			BEGIN	
				SET @FrqPerc=(CONVERT(FLOAT,@NormalFrq)/CONVERT(FLOAT,@IOAfrq))*100
			END
			ELSE
				SET @FrqPerc=(CONVERT(FLOAT,@IOAfrq)/CONVERT(FLOAT,@NormalFrq))*100
			SET @FrqPerc=ROUND(@FrqPerc,2)
			UPDATE BehaviorIOADetails SET IOAPerc=@FrqPerc, NormalBehaviorId=@NormalBehavId WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviorIOAId=@BehaviorIOAId
		END		
	END

	----------YES OR NO----------
	IF(@YesOrNo=1 AND @Stat=2)
	BEGIN
		SET @NormalYesOrNo=(SELECT FrequencyCount FROM Behaviour WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviourId=@NormalBehavId)
		IF(@NormalYesOrNo IS NOT NULL)
		BEGIN
			SET @IOAYesOrNo=(SELECT FrequencyCount FROM BehaviorIOADetails WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviorIOAId=@BehaviorIOAId)
			IF (@NormalYesOrNo=@IOAYesOrNo)
				SET @YesOrNoPerc=100
			ELSE
				SET @YesOrNoPerc=0
			UPDATE BehaviorIOADetails SET IOAPerc=@YesOrNoPerc, NormalBehaviorId=@NormalBehavId WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviorIOAId=@BehaviorIOAId
		END
	END

	------------INTERVAL FREQUENCY----------
	--IF(@Frequency=1 AND @Stat=1 AND @Interval=1)
	--BEGIN
	--	SET @NormalFrq=(SELECT FrequencyCount FROM Behaviour WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviourId=@NormalBehavId)
	--	IF(@NormalFrq IS NOT NULL)
	--	BEGIN
	--		SET @IOAfrq= (SELECT FrequencyCount FROM BehaviorIOADetails WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviorIOAId=@BehaviorIOAId)		
	--		IF(@NormalFrq<=@IOAfrq)
	--		BEGIN		
	--			SET @FrqPerc=(CONVERT(FLOAT,@NormalFrq)/CONVERT(FLOAT,@IOAfrq))*100
	--		END
	--		ELSE
	--			SET @FrqPerc=(CONVERT(FLOAT,@IOAfrq)/CONVERT(FLOAT,@NormalFrq))*100
	--		SET @FrqPerc=ROUND(@FrqPerc,2)
	--		UPDATE BehaviorIOADetails SET IOAPerc=@FrqPerc, NormalBehaviorId=@NormalBehavId WHERE MeasurementId=@MeasurmentId AND StudentId=@StudentId AND BehaviorIOAId=@BehaviorIOAId
	--	END	
	--END	
	
	
	COMMIT
	END TRY
	BEGIN CATCH
	ROLLBACK
	END CATCH
END


GO
