<!------
Deviation_Do_All.cfm
----->

<CFSET RUN_ROUTINES = 1>
<CFSET VALIDATION_SHOW_ALL = 0>
<CFPARAM NAME="SHOW_FAX_EMAIL_VERSION" 	DEFAULT="0">
<CFPARAM NAME="SHOW_PRINT_VERSION" 		DEFAULT="0">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">
<CFSET ADDSCRIPT="Yes">
<CFINCLUDE TEMPLATE="Date_Graph_Settings.cfm">


<CFPARAM NAME="FORM.Deviation_Show_Expected_Values" 	DEFAULT=0>
<CFSET Deviation_Show_Expected_Values = FORM.Deviation_Show_Expected_Values>



<CFPARAM NAME="FORM.BBID" 								DEFAULT="">
<CFPARAM NAME="URL.BBID"								DEFAULT="#FORM.BBID#">
<CFSET Billback_ID=URL.BBID>

<html>
<head>
	<title>Billback Validation</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<CFINCLUDE TEMPLATE="Deviation_Display_Style.cfm">

<!--- Ana: D15311 -- Clear the Deviation Ran Details --->
<cfquery name="ClearDev" datasource="#application.datasource#">
	UPDATE 	Billback 
	SET 	Deviation_Ran_Date = NULL,
			Deviation_Ran_By = NULL
	WHERE	Billback_ID = '#Billback_ID#'
</cfquery>

<CFINCLUDE TEMPLATE="Validation_Req.cfm">


<!---------------------- Get All Growth ----------------------------->
<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Growth">
	SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth, 
			Billback_Program.Billback_Program_ID,
			CASE
			WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
				NULL
			WHEN (BB_Growth_Program.Deviated_Amount * -1) > SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) THEN
				SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
			WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
				BB_Growth_Program.Deviated_Amount * -1
			ELSE
				0
			END AS Growth_Deviation,
			CASE
			WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
				NULL
			WHEN (BB_Growth_Program.Deviated_Amount * -1) > SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) THEN
				100
			WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
				(BB_Growth_Program.Deviated_Amount * -1 * 100) / SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
			ELSE
				0
			END AS Growth_Deviation_Percent,
			ISNull(Expected_Amount, 0) AS Expected_Amount,
			ISNull(BB_Growth_Amount, 0) AS BB_Growth_Amount,
			Approved_Amount AS BB_Approved_Amount
	FROM	
			Billback
			INNER JOIN Billback_Program
			ON
			(
				(Billback_Program.Billback_ID = Billback.Billback_ID)
				AND
				(Billback_Program.Deleted = 0)
			)			
			INNER JOIN 	Billback_product
			ON
			(	(Billback_Product.Billback_ID = '#Billback_ID#')
				 AND
				(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_product.Deleted = 0)
			)
			INNER JOIN Billback_Product_Detail
			ON
			(   (Billback_Product_Detail.Billback_ID = '#Billback_ID#')
				 AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				AND
				(LEN(Billback_Product_Detail.BB_Rate) > 0)
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
				AND
				(Billback_Product_Detail.BB_Product_Type_ID = 4)
			)
			LEFT JOIN BB_Growth_Program
			ON
			(
				(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(BB_Growth_Program.Deleted = 0)
			)			
		WHERE
			Billback.Billback_ID = '#Billback_ID#'				
		GROUP BY Billback_Program.Billback_Program_ID, BB_Growth_Program.Deviated_Amount
					, Expected_Amount, BB_Growth_Amount, Approved_Amount
</CFQUERY>


<!---------------------- LumpsUm --------------------------->
	<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
				, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount
				, CASE
				WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
					NULL
				WHEN (BB_Lump_Sums.Lump_Sum_Deviation * -1) > SUM(CAST(Amount AS FLOAT)) THEN
					SUM(CAST(Amount AS FLOAT))
				WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
					BB_Lump_Sums.Lump_Sum_Deviation * -1
				ELSE
					0
				END AS Lumpsum_Deviation,
				CASE
				WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
					NULL
				WHEN (BB_Lump_Sums.Lump_Sum_Deviation * -1) > SUM(CAST(Amount AS FLOAT)) THEN
					100
				WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
					(BB_Lump_Sums.Lump_Sum_Deviation * -1 * 100) / SUM(CAST(Amount AS FLOAT))
				ELSE
					0
				END AS Lumpsum_Deviation_Percent,
				ISNull(BB_Lump_Sums.LS_Expected_Amount, 0) AS Expected,
				ISNull(LS_Billback_Amount, 0) AS Billback,
				LS_Approved_Amount AS Approved
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN BB_Lump_Sums
				ON
				(
					(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
				)
	WHERE 
			Billback_Program_Lumpsum_Component.Billback_ID 		= '#Billback_ID#'
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= 0
	GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID, BB_Lump_Sums.Lump_Sum_Deviation
			, BB_Lump_Sums.LS_Expected_Amount, LS_Billback_Amount, LS_Approved_Amount
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	</CFQUERY>
	
	
	
	<CFSET SHOW_PAYEE_UNKNOWN=0>
	<CFSET SHOW_PROGRAM_PNF=0>
	<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=0>
	<CFSET SHOW_PROGRAM_DATE_MISMATCH=0>
	<CFSET SHOW_PRODUCT_UNKNOWN=0>
	<CFSET SHOW_DISCOUNT_UN_AUTH=0>
	<CFSET SHOW_DISCOUNT_RATE=0>
	<CFSET SHOW_DISCOUNT_VOLUME=0>
	<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
	<CFSET SHOW_DISCOUNT_RATE="">
	<CFSET SHOW_DISCOUNT_VOLUME="">
	<CFSET SHOW_LUMPSUM=0>
	<CFSET SHOW_GROWTH=0>

	
	<CFSET SHOW_STEP_PROGRESS = 1>
	<CFINCLUDE TEMPLATE="Validation_Steps.cfm">
	
	<CFSET NEXT_STEP = THIS_STEP_LEVEL_IN_LIST + 1>
	<CFIF NEXT_STEP GT ListLen(VALIDATION_STEPS)>
		<!--- Ana: D15311 -- Set the Deviation Ran Details --->
		<cfquery name="SetDev" datasource="#application.datasource#">
			UPDATE 	Billback 
			SET 	Deviation_Ran_Date = GETDATE(),
					Deviation_Ran_By = '#request.AccessStructure.User_ID#' 
			WHERE	Billback_ID = '#Billback_ID#'
		</cfquery>	
	</CFIF>
	
	<CFOUTPUT>
	<SCRIPT>
		function GotoNextStep()
		{
			<CFIF NEXT_STEP LTE ListLen(VALIDATION_STEPS)>
				window.location.href="Deviation_Do_All.cfm?BBID=#Billback_ID#&STEP_LEVEL=#ListGetAt(VALIDATION_STEPS, NEXT_STEP, ",")#";
			<CFELSE>
				window.location.href="Deviation.cfm?BBID=#Billback_ID#&STEP_LEVEL=0";
			</CFIF>
		}
		setTimeout('GotoNextStep()',500); 
	</SCRIPT>
	
	</CFOUTPUT>
	
	
</BODY>
</html>