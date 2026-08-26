<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFIF Count_Flag EQ "">
	<CFIF Billback_Payee_Type_ID EQ 1>
		<CFSET CountThisItem = 1>
	<CFELSEIF Billback_Payee_Type_ID EQ 2>
		<CFQUERY NAME="GetPayee" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback_Operator WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
		</CFQUERY>
		<CFSET CountThisItem = 0>

		<CFQUERY NAME="CheckCount" DATASOURCE="#Application.Datasource#">
			DECLARE @Programs_To_Check table
			(
				Contract_Main_ID int,
				Contract_Number nvarchar(50)
			)
			DECLARE	@CN nvarchar(50)
			
			INSERT INTO 	@Programs_To_Check (Contract_Main_ID, Contract_Number)
			SELECT 		DISTINCT Contract_Main.Contract_Main_ID, Contract_Number
			FROM 		Contract_Main 
			INNER JOIN 	Contract_Operators 
			ON 			Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID 
			AND 		Contract_Operators.Deleted = 0
			AND			Contract_Operators.BSA_Operator_ID = '#GetPayee.Operator_ID#'
			WHERE 		Contract_Main.Deleted = 0 <!--- only include latest version --->
			AND			Contract_Status_Type_IDX IN (5,6,7) 
			AND			( 	
						(Contract_Start_Date between '#BB_Start_Date#' AND '#BB_End_Date#') OR 
						(Contract_End_Date between '#BB_Start_Date#' AND '#BB_End_Date#') OR 
						(Contract_Start_Date <= '#BB_Start_Date#' AND Contract_End_Date >= '#BB_End_Date#') 
						) 
			
			<!--- check if there is any rebate --->
			SELECT 		Top 1 @CN = Programs_To_Check.Contract_Number
			FROM 		@Programs_To_Check as Programs_To_Check
			
			INNER JOIN 	Contract_Products
			ON			Contract_Products.Deleted = 0
			AND			Contract_Products.BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
			AND			Contract_Products.Contract_Main_ID = Programs_To_Check.Contract_Main_ID
			
			INNER JOIN 	Program_Rebates_Component 
			ON			Program_Rebates_Component.Program_ID = Contract_Products.Contract_Main_ID 
			AND 		Program_Rebates_Component.Component_Paid_To = 1 
			AND 		Program_Rebates_Component.Deleted = 0
			
			INNER JOIN 	Program_Rebates_Product_Data 
			ON 			Program_Rebates_Product_Data.Deleted = 0 
			AND			Program_Rebates_Product_Data.Program_ID = Contract_Products.Contract_Main_ID 
			AND 		Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
			
			INNER JOIN 	Program_Rebates_Component_Data 
			ON 			Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID 
			AND 		Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID 
			AND 		Program_Rebates_Component_Data.Deleted = 0
			AND			cast(Program_Rebates_Component_Data.Rate as float) > 0
			
			IF @CN IS NULL
			BEGIN
			
				<!---- if no rebate found, check if there is any fixed --->
				SELECT 		Top 1 @CN = Programs_To_Check.Contract_Number
				FROM 		@Programs_To_Check as Programs_To_Check
				
				INNER JOIN 	Contract_Products
				ON			Contract_Products.Deleted = 0
				AND			Contract_Products.BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
				AND			Contract_Products.Contract_Main_ID = Programs_To_Check.Contract_Main_ID
				
				INNER JOIN 	Program_Fixed_Component 
				ON			Program_Fixed_Component.Program_ID = Contract_Products.Contract_Main_ID 
				AND 		Fixed_Component_Paid_to = 1 
				AND 		Program_Fixed_Component.Deleted = 0 
				
				INNER JOIN 	Program_Fixed_Price_Product_Data 
				ON 			Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID 
				AND 		Program_Fixed_Price_Product_Data.Program_ID = Contract_Products.Contract_Main_ID 
				AND 		Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID 
				AND 		Program_Fixed_Price_Product_Data.Deleted = 0
				AND 		cast(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) > 0
				
			END
			
			SELECT *
			FROM	@Programs_To_Check
			WHERE	Contract_Number = @CN

		</CFQUERY>

		<CFIF CheckCount.RecordCount EQ 0>
			<CFSET CountThisItem = 1>
		<CFELSE>
			<CFSET CountThisItem = 0>
		</CFIF>		
	<CFELSE>
		<CFSET CountThisItem = 0>
	</CFIF>
<CFELSE>
	<CFSET CountThisItem = Count_Flag>
</CFIF>

<CFQUERY NAME="UpdateActual" DATASOURCE="#Application.Datasource#">
	UPDATE Billback_Product 
	SET Actual_Count_Flag = #CountThisItem#
	WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
</CFQUERY>
</body>
</html>
