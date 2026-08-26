CREATE PROCEDURE PROGRAM_FORMULA_PRICING
AS
DECLARE 
@Program_ID INT, 
@Release_Date Datetime,
@C_Date Datetime,
@D_Date Datetime,
@R_COUNT INT,
@Contract_Status_Type_IDX int,
@Release_Type int,
@Program_Formula_Pricing_Period_ID UNIQUEIDENTIFIER,
@End_Date Datetime,
@Force_Price_Calculation_For_This_Period bit

SET @C_Date = CONVERT(NVARCHAR(10),GETDATE(),101)
DELETE FROM Program_Formula_Pricing_Release_Programs
WHERE Process_Status = 60

DECLARE FORMULA_PRICING SCROLL CURSOR FOR
SELECT Program_Formula_Pricing_Period_ID,Program_ID,Release_Date,End_Date,Force_Price_Calculation_For_This_Period
FROM Program_Formula_Pricing_Periods
WHERE Active = 1 AND Deleted = 0 AND CONVERT(NVARCHAR(10),Release_Date,101) <= @C_Date
AND Process_By_System = 0 AND Created_By_System = 0
AND Program_ID IN (SELECT Program_ID FROM Contract_Main WHERE Deleted = 0 AND Contract_Status_Type_IDX <= 6)
OPEN FORMULA_PRICING
FETCH FIRST FROM FORMULA_PRICING INTO
@Program_Formula_Pricing_Period_ID,
@Program_ID, 
@Release_Date,
@End_Date,
@Force_Price_Calculation_For_This_Period
WHILE @@fetch_status = 0			
BEGIN
SET @D_Date = CONVERT(NVARCHAR(10),@Release_Date,101)
IF (@C_Date <= @D_Date AND CONVERT(NVARCHAR(10),@End_Date,101) >= @C_Date)  OR (@Force_Price_Calculation_For_This_Period = 1)
BEGIN
SET @Release_Type = 0
SELECT @Contract_Status_Type_IDX = Contract_Status_Type_IDX FROM Contract_Main WHERE Contract_Main_ID = @Program_ID
IF @Contract_Status_Type_IDX > 2 AND @Contract_Status_Type_IDX < 7
BEGIN
SET @Release_Type = 2
END
IF @Contract_Status_Type_IDX < 3 
BEGIN
SET @Release_Type = 1
END
IF @Contract_Status_Type_IDX > 0 AND @Contract_Status_Type_IDX < 7
BEGIN
INSERT INTO Program_Formula_Pricing_Release_Programs
(Program_ID, Process_Status,Release_Type,Update_Date,Program_Formula_Pricing_Period_ID)
Values
(@Program_ID, 0,@Release_Type,GETDATE(),@Program_Formula_Pricing_Period_ID)
/*
UPDATE Program_Formula_Pricing_Periods
SET Process_By_System = 1
WHERE Program_Formula_Pricing_Period_ID = @Program_Formula_Pricing_Period_ID
*/
END
END
/*
IF (CONVERT(NVARCHAR(10),@End_Date,101) <= @C_Date)
BEGIN
UPDATE Program_Formula_Pricing_Periods
SET Process_By_System = 1
WHERE Program_Formula_Pricing_Period_ID = @Program_Formula_Pricing_Period_ID
END
*/
FETCH NEXT FROM FORMULA_PRICING INTO 
@Program_Formula_Pricing_Period_ID,
@Program_ID, 
@Release_Date,
@End_Date 
END

UPDATE Program_Formula_Pricing_Release_Programs
SET Process_Status = 1
WHERE Process_Status = 0

UPDATE Program_Formula_Pricing_Periods
SET Is_Current_Period = 1
WHERE Active = 1 AND Deleted = 0 AND CONVERT(NVARCHAR(10),Start_Date,101) <= @C_Date
AND CONVERT(NVARCHAR(10),End_Date,101) >= @C_Date

UPDATE Program_Formula_Pricing_Periods
SET Is_Current_Period = 0
WHERE Active = 1 AND Deleted = 0 AND CONVERT(NVARCHAR(10),Start_Date,101) <= @C_Date
AND CONVERT(NVARCHAR(10),End_Date,101) < @C_Date

CLOSE FORMULA_PRICING
DEALLOCATE FORMULA_PRICING
GO
