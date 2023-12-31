USE [MelmarkNE1]
GO
/****** Object:  StoredProcedure [dbo].[ZHT_spSubmitBMI]    Script Date: 7/20/2023 4:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZHT_spSubmitBMI]
                @ClientID varchar(50),
@ClientName varchar(50),
@BMIDt date,
@BMIHt float,
@BMIWt float,
@BMI float,
@BMICmnt varchar(max),
@MonthBMIVal varchar(50),
@MonthBMIText varchar(50),
@YearBMIVal varchar(50),
@YearBMIText varchar(50),
@SubmittedDate date,
@SubmittedTime time(7),
@SubmittedByID varchar(50),
@SubmittedByName varchar(50),
@BMIStatus  varchar(5),
@ActiveStatus varchar(5),
@BMIID varchar(50),
@M1MonthVal varchar(50),
@M1YearVal varchar(50),
@M3MonthVal varchar(50),
@M3YearVal varchar(50),
@M6MonthVal varchar(50),
@M6YearVal varchar(50),
@PlacementVal VARCHAR(25),
@PlacementTxt VARCHAR(200)
AS
BEGIN

                if @BMIID IS Null
                BEGIN
                INSERT INTO [dbo].[ZHT_BMIMainTable] ([StudentID],[ClientName],[DateOfBMI],[BMI],[Weight],[Height],[Comments],[SubmittedDate],[SubmittedTime],[SubmittedByID],[SubmittedByName],[BMIStatus],[ActiveStatus],[MonthBMIVal], [MonthBMIText], [YearBMIVal], [YearBMIText],[M1MonthVal],[M1YearVal],[M3MonthVal],[M3YearVal],[M6MonthVal],[M6YearVal],[AgeInMnthAtBMI],[HeightIncm],[PlacementVal],[PlacementTxt]) 
                VALUES (@ClientID, @ClientName, @BMIDt, @BMI, @BMIWt, @BMIHt, @BMICmnt, @SubmittedDate, @SubmittedTime, @SubmittedByID, @SubmittedByName, @BMIStatus, @ActiveStatus,@MonthBMIVal, @MonthBMIText, @YearBMIVal, @YearBMIText, @M1MonthVal, @M1YearVal, @M3MonthVal, @M3YearVal, @M6MonthVal, @M6YearVal,DATEDIFF(month, (select BirthDate from StudentPersonal where StudentPersonalId=@ClientID),@BMIDt),IIF(@BMIHt IS NULL, NULL, @BMIHt*2.54),@PlacementVal,@PlacementTxt);
                SELECT @BMIID = SCOPE_IDENTITY();     
                INSERT INTO [dbo].[ZHT_UpdateData] (ModuleName,ModuleID,UpdateFlag,UpdatedByID,UpdatedByName,UpdateDate,UpdateTime) values('BMI',@BMIID,@BMIStatus,@SubmittedByID,@SubmittedByName,@SubmittedDate,@SubmittedTime); 
                END

                ELSE
                BEGIN
                UPDATE [dbo].[ZHT_BMIMainTable] set [DateOfBMI] = @BMIDt,[BMI]=@BMI, [Weight]= @BMIWt, [Height]=@BMIHt,[Comments]=@BMICmnt,[BMIStatus]=@BMIStatus, [ActiveStatus]=@ActiveStatus, [MonthBMIVal]=@MonthBMIVal, [MonthBMIText]=@MonthBMIText, [YearBMIVal]=@YearBMIVal, [YearBMIText]=@YearBMIText, [M1MonthVal] = M1MonthVal, [M1YearVal] = @M1YearVal, [M3MonthVal] = @M3MonthVal, [M3YearVal] = @M3YearVal, [M6MonthVal] = @M6MonthVal, [M6YearVal] = @M6YearVal,[AgeInMnthAtBMI]= DATEDIFF(month, (select BirthDate from StudentPersonal where StudentPersonalId=@ClientID),@BMIDt),[HeightIncm]= IIF(@BMIHt IS NULL, NULL, @BMIHt*2.54) where  BMIID=@BMIID;
                INSERT INTO [dbo].[ZHT_UpdateData] (ModuleName,ModuleID,UpdateFlag,UpdatedByID,UpdatedByName,UpdateDate,UpdateTime) values('BMI',@BMIID,@BMIStatus,@SubmittedByID,@SubmittedByName,@SubmittedDate,@SubmittedTime); 
                END
                                
END



GO
