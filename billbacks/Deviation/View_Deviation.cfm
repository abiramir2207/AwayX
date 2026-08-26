<CFPARAM NAME="URL.BBID"								DEFAULT="">
<CFSET Billback_ID=URL.BBID>

<CFLOCATION URL="Deviation.cfm?BBID=#Billback_ID#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfinclude template="/get_access_profile.cfm">

<CFIF Get_Profile_Settings.BB_View_Deviation NEQ 1>
	<CFLOCATION URL="Billback_Summary.cfm" ADDTOKEN="No">
</CFIF>

<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">



<html>
<head>
	<title>Billback Validation</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
<CFOUTPUT>
<A HREF="Deviation.cfm?BBID=#Billback_ID#">New Deviation</A>
</CFOUTPUT>
<BLOCKQUOTE>

<!------------------------------show spinner ---------------------------->
<!------

<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
----->

<!------------ Step level ----------------->
<cfparam name="URL.STEP_LEVEL" 	default=1>
<CFIF URL.STEP_LEVEL EQ "" OR NOT IsNumeric(URL.STEP_LEVEL)>
	<CFSET URL.STEP_LEVEL = 1>
</CFIF>

<CFSET STEP_LEVEL=URL.STEP_LEVEL>

<!------------------ Get Status ------------------------------>
<CFQUERY  dataSource="#application.datasource#" NAME="Get_BB_Status">
	SELECT	Billback_Status_ID
	FROM	
			Billback
	WHERE
			Billback.Billback_ID = '#Billback_ID#'
</CFQUERY>
<CFSET BB_Status = Get_BB_Status.Billback_Status_ID>

<!------------------- Build Validation Steps ---------------------------->
<CFSET Step_Discount_Type_List="Fixed Price, #Application.RebateLabel#, , Growth, Formula Price">
<CFSET VALIDATION_STEPS="1,2,3">
<CFSET VALIDATION_STEPS_DESC="Known and Authorized Products,Known Program &##44; Authorized Payee and Date Match,Known Payee and Product level Date Overlap">

<CFSET FIXED_STEP_LEVEL=STEP_LEVEL>
<CFQUERY  dataSource="#application.datasource#" NAME="Check_Discount_Type">
	SELECT	Count(Billback.BB_Code) AS this_Count, Billback_Product_Detail.BB_Product_Type_ID, Program_Control_Panel_Options.Generic_Type
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
			(	(Billback_product.Billback_ID = '#Billback_ID#')
				AND
				(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_product.Deleted = 0)
			)
			INNER JOIN Billback_Product_Detail
			ON
			(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#')
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
				(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5))
			)	
			LEFT JOIN Contract_Main
			ON
			(
				(Contract_main.Contract_Main_ID = Billback_Program.Program_ID)
			)
			LEFT JOIN	Program_Control_Panel_Options
			ON
			(
				(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
			)			
		WHERE
			Billback.Billback_ID = '#Billback_ID#'				
		GROUP BY Program_Control_Panel_Options.Generic_Type, Billback_Product_Detail.BB_Product_Type_ID
</CFQUERY>
<!------
BB_D_GROWTH_RATE_DEV
saru says:
BB_D_GROWTH_VOLUME_DEV
----->
<CFSET Fixed_Step_Count = ListLen(VALIDATION_STEPS, ",")>
<CFOUTPUT QUERY="Check_Discount_Type" GROUP="BB_Product_Type_ID">
	<CFIF this_Count GT 0>
		<CFSET thisRebateType = ListGetAt(Step_Discount_Type_List, BB_Product_Type_ID)>
		<CFIF LEN(Trim(thisRebateType)) GT 0>
			<CFSET rate_Step=Fixed_Step_Count + ((BB_Product_Type_ID - 1) * 2) + 1>
			<CFSET vol_Step=Fixed_Step_Count + ((BB_Product_Type_ID - 1) * 2) + 2>
			
			<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, rate_Step , ",")>			
			<CFIF BB_Product_Type_ID EQ 4>
				<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Growth Amount", ",")>
			<CFELSE>
				<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Rate", ",")>
				<CFSET added_Volume=0>			
				<CFOUTPUT>
					<CFIF NOT added_Volume>
						<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNoCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0 OR Associated_Ship_TO NEQ "">
							<CFIF BB_Product_Type_ID EQ 4 AND Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter>
								<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, vol_Step , ",")>
								<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Volume", ",")>
								<CFSET added_Volume=1>
							<CFELSEIF BB_Product_Type_ID NEQ 4>
								<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, vol_Step , ",")>
								<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "#thisRebateType# Volume", ",")>
								<CFSET added_Volume=1>
							</CFIF>
							
						</CFIF>
					</CFIF>
				</CFOUTPUT>						
			</CFIF>
		</CFIF>
	</CFIF>
</CFOUTPUT>


<!---------------------- Get All Growth ----------------------------->
<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Growth">
	SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth, 
			Billback_Program.Billback_Program_ID,
			CASE
			WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
				NULL
			WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
				BB_Growth_Program.Deviated_Amount * -1
			ELSE
				0
			END AS Growth_Deviation,
			CASE
			WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
				NULL
			WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
				(BB_Growth_Program.Deviated_Amount * -1 * 100) / SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
			ELSE
				0
			END AS Growth_Deviation_Percent
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
			(	(Billback_product.Billback_ID = '#Billback_ID#')
				AND
				(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_product.Deleted = 0)
			)
			INNER JOIN Billback_Product_Detail
			ON
			(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#')
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
</CFQUERY>


<CFIF Get_Program_Growth.recordCount GT 0>
	<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, 14 , ",")>
	<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Total Growth Amount", ",")>
</CFIF>

<!---------------------- LumpsUm --------------------------->
	<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
				, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount
				, CASE
				WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
					NULL
				WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
					BB_Lump_Sums.Lump_Sum_Deviation * -1
				ELSE
					0
				END AS Lumpsum_Deviation
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN Program_Lump_Sums
				ON
				(
					(Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID)
				)
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
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	</CFQUERY>
	
	<!-------------- Show Buttons ------------->
<CFIF Get_Program_Lumpsum.recordCount GT 0>
	<CFSET VALIDATION_STEPS = ListAppend(VALIDATION_STEPS, 15 , ",")>
	<CFSET VALIDATION_STEPS_DESC= ListAppend(VALIDATION_STEPS_DESC, "Total #Application.LumpsumLabel# Amount", ",")>
</CFIF>

<CFSET THIS_STEP_LEVEL_IN_LIST=ListFindNoCase(VALIDATION_STEPS, STEP_LEVEL, ",")>
<CFSET MAX_LEVEL=ListLen(VALIDATION_STEPS, ",")>
<CFIF THIS_STEP_LEVEL_IN_LIST GT MAX_LEVEL>
	<CFSET STEP_LEVEL = 1>
</CFIF>
<CFIF BB_Status GT 2>
	<CFSET STEP_LEVEL=ListGetAt(VALIDATION_STEPS, MAX_LEVEL, ",")>
	<CFSET FIXED_STEP_LEVEL=ListGetAt(VALIDATION_STEPS, MAX_LEVEL, ",")>
</CFIF>

<CFSET THIS_STEP_LEVEL_IN_LIST=ListFindNoCase(VALIDATION_STEPS, STEP_LEVEL, ",")>
<CFSET FIXED_STEP_LEVEL=STEP_LEVEL>

<!--------------------Set Constants        ------------------------------>


<CFSET Mouse_Over_Script=" onmouseover=""initTheTooltip('')"" onmouseout=""popOut()""">
<CFSET show_Yes_Start="<IMG SRC=""/Images/yes_small.gif"" BORDER=""0""">
<CFSET show_No_Start="<IMG SRC=""/Images/no_small.gif"" BORDER=""0""">
<CFSET show_Question_Start="<IMG SRC=""/Images/question_small.gif"" BORDER=""0""">
<CFSET show_Nothing_Start="<IMG SRC=""/Images/nothing_small.gif"" BORDER=""0""">
 
 
<CFSET show_Yes="#show_Yes_Start# #Mouse_Over_Script#>">
<CFSET show_No="#show_No_Start# #Mouse_Over_Script#>">
<CFSET show_Question="#show_Question_Start# #Mouse_Over_Script#>">
<CFSET show_Nothing="#show_Nothing_Start# #Mouse_Over_Script#>">

<CFSET show_Yes_Start="#show_Yes_Start#>">
<CFSET show_No_Start="#show_No_Start#>">
<CFSET show_Question_Start="#show_Question_Start#>">
<CFSET show_Nothing_Start="#show_Nothing_Start#>">

<CFSET Discount_Type_List="Fixed Price, #Application.RebateLabel#, #Application.LumpsumLabel#, Growth, Formula Price">


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
<!--------------------- call stored proc -------------------------------->
<CFSWITCH EXPRESSION="#FIXED_STEP_LEVEL#">
	<CFCASE VALUE="1">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_1">
			EXEC BB_D_PRODUCT_DEVIATION '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=0>
		<CFSET SHOW_PROGRAM_PNF=0>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=0>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=0>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
		<CFSET SHOW_DISCOUNT_RATE="">
		<CFSET SHOW_DISCOUNT_VOLUME="">
	</CFCASE>
	<CFCASE VALUE="2">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_2">
		EXEC BB_D_PROGRAM_DEVIATION '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=0>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
		<CFSET SHOW_DISCOUNT_RATE="">
		<CFSET SHOW_DISCOUNT_VOLUME="">
	</CFCASE>
	<CFCASE VALUE="3">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_OVERLAP_DEVIATION '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="">
		<CFSET SHOW_DISCOUNT_VOLUME="">
	</CFCASE>
	<CFCASE VALUE="4">		
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_FIXED_RATE_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1">
		<CFSET SHOW_DISCOUNT_VOLUME="">
	</CFCASE>
	<CFCASE VALUE="5">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_FIXED_VOLUME_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1">
		<CFSET SHOW_DISCOUNT_VOLUME="1">
	</CFCASE>
	<CFCASE VALUE="6">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_REBATE_RATE_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2">
		<CFSET SHOW_DISCOUNT_VOLUME="1">
	</CFCASE>
	<CFCASE VALUE="7">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_REBATE_VOLUME_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2">
		<CFSET SHOW_DISCOUNT_VOLUME="1,2">
	</CFCASE>	
	<CFCASE VALUE="12">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_FORMULA_RATE_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2,5">
		<CFSET SHOW_DISCOUNT_VOLUME="1,2">
	</CFCASE>
	<CFCASE VALUE="13">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_FORMULA_VOLUME_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2,4,5">
		<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5">
	</CFCASE>
	<CFCASE VALUE="14">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_GROWTH_RATE_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2,5">
		<CFSET SHOW_DISCOUNT_VOLUME="1,2,5">
		<CFSET SHOW_GROWTH=1>
		
		
					
			<!---------------------- Get All Growth ----------------------------->
			<CFQUERY  dataSource="#application.datasource#" NAME="Get_Program_Growth">
				SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT)) AS Total_Growth, 
						Billback_Program.Billback_Program_ID,
						CASE
						WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
							NULL
						WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
							BB_Growth_Program.Deviated_Amount * -1
						ELSE
							0
						END AS Growth_Deviation,
						CASE
						WHEN BB_Growth_Program.Deviated_Amount IS NULL THEN
							NULL
						WHEN BB_Growth_Program.Deviated_Amount < 0 THEN
							(BB_Growth_Program.Deviated_Amount * -1 * 100) / SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
						ELSE
							0
						END AS Growth_Deviation_Percent
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
						(
							(Billback_Product.Billback_ID = '#Billback_ID#')
							AND
							(Billback_product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
							AND
							(Billback_product.Deleted = 0)
						)
						INNER JOIN Billback_Product_Detail
						ON
						(	(Billback_Product_Detail.Billback_ID = '#Billback_ID#')
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
			</CFQUERY>
	</CFCASE>	
	<CFCASE VALUE="15">
		<CFIF BB_Status LT 3>
		<CFQUERY  dataSource="#application.datasource#" NAME="SP_3">
		EXEC BB_D_LUMPSUM_DEV '#Billback_ID#'
		</CFQUERY>
		</CFIF>
		
		<CFSET SHOW_PAYEE_UNKNOWN=1>
		<CFSET SHOW_PROGRAM_PNF=1>
		<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=1>
		<CFSET SHOW_PROGRAM_DATE_MISMATCH=1>
		<CFSET SHOW_PRODUCT_UNKNOWN=1>
		<CFSET SHOW_DISCOUNT_UN_AUTH=1>
		<CFSET SHOW_DISCOUNT_RATE=0>
		<CFSET SHOW_DISCOUNT_VOLUME=0>
		<CFSET SHOW_DISCOUNT_DATE_OVERLAP=1>
		<CFSET SHOW_DISCOUNT_RATE="1,2,4,5">
		<CFSET SHOW_DISCOUNT_VOLUME="1,2,4,5">
		<CFSET SHOW_GROWTH=1>
		<CFSET SHOW_LUMPSUM=1>		
		
		
		<!---------------------- LumpsUm --------------------------->
			<cfquery name="Get_Program_Lumpsum" datasource="#application.datasource#">
			SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
						, SUM(CAST(Amount AS FLOAT)) Total_Program_Lumpsum_Amount
						, CASE
						WHEN BB_Lump_Sums.Lump_Sum_Deviation IS NULL THEN
							NULL
						WHEN BB_Lump_Sums.Lump_Sum_Deviation < 0 THEN
							BB_Lump_Sums.Lump_Sum_Deviation * -1
						ELSE
							0
						END AS Lumpsum_Deviation
			FROM       Billback_Program_Lumpsum_Component
						LEFT JOIN Program_Lump_Sums
						ON
						(
							(Program_Lump_Sums.Program_Lump_Sum_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID)
						)
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
			ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
			</CFQUERY>
	</CFCASE>
	<CFDEFAULTCASE>
		<CFABORT>
	</CFDEFAULTCASE>
</CFSWITCH>

<!------------------------ Define Style ---------------------------------->

<CFSET PAYEE_TD_COLOR		="FFFFFF">
<CFSET PAYEE__IN_TD_COLOR	="FFFFFF">
<!------
<CFSET PROGRAM_TD_COLOR		="ffe4b5">
----->
<CFSET PROGRAM_TD_COLOR		="ccffcc">

<CFSET PROGRAM_TD_Width		="2">
<CFSET PRODUCT_TD_COLOR		="DDDDDD">
<CFSET PRODUCT_IN_TR_COLOR	="WhiteSmoke">
<CFSET LUMPSUM_TD_COLOR		="FFE4C4">
<CFSET LUMPSUM_IN_TR_COLOR	="FFFFFF">
<CFSET GROWTH_TD_COLOR		="D8BFD8">
<CFSET GROWTH_IN_TR_COLOR	="FFFFFF">

<CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript">
function Open_Close(thisObj)
{
	var trObj = thisObj.parentElement;
	var tableObj = trObj.parentElement;
	var imgObj = event.srcElement;
	var nestImgObj;
	var displayString = "";
	if(imgObj.tagName == "TD")
	{
		if(imgObj.all.IMG_CLOSE.style.display == "")
		{
			imgObj = imgObj.all.IMG_CLOSE;
		}
		else
		{
			imgObj = imgObj.all.IMG_OPEN;
		}
	}
	
	if(imgObj.id == "IMG_CLOSE")
	{
		nestImgObj = thisObj.all.IMG_OPEN;
		displayString = "none";
	}
	else
	{
		nestImgObj = thisObj.all.IMG_CLOSE;
		displayString = "";
	}

	var trObjs = tableObj.rows;
	var i, trLen;
	trLen = trObjs.length;
	for(i=trObj.rowIndex;i<trLen;i++)
	{
		if(trObjs[i].id)
		{
			if(trObjs[i].id == "Program_TR_NO_Colapse")
			{
				break;
			}
		}
		trObjs[i].style.display = displayString;
	}
	nestImgObj.style.display = "";
	imgObj.style.display = "none";
}

</SCRIPT>

<STYLE>
	.Table_Header
	{
		font-size : 12px;
		font-weight:bold;
	}
	.payeeTD	
	{
		background-color:#PAYEE_TD_COLOR#;
	}
	.payeeInsideTD	
	{
		background-color:#PAYEE__IN_TD_COLOR#;
	}
	.NoValidDesc
	{
		color:red;
		font-weight:bold;
	}
	.NoValidDesc:LINK,.NoValidDesc:VISITED,.NoValidDesc:HOVER 
	{
		color:red;
	}
	.YesValidDesc
	{
		color: black;
	}
	.YesValidDesc:LINK,.YesValidDesc:VISITED,.YesValidDesc:HOVER
	{
		color: blue;
	}	
	.NotprocessedValidDesc
	{
		color: 999999;
	}
	.programTD
	{
		background-color:#PROGRAM_TD_COLOR#;
	}
	.programLeft
	{
		border-left:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color:FFFFFF;
	}
	.programBottom
	{
		border-left:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		border-bottom:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		border-right:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color: FFFFFF;
	}
	.programRight
	{
		border-right:solid #PROGRAM_TD_COLOR# #PROGRAM_TD_Width#px;
		background-color: FFFFFF;
	}
	.lumpsumTD	
	{
		background-color:#LUMPSUM_TD_COLOR#;
	}
	.lumpsumInTR
	{
		background-color:#LUMPSUM_IN_TR_COLOR#;
	}
	.growthTD	
	{
		background-color:#GROWTH_TD_COLOR#;
	}
	.growthInTR
	{
		background-color:#GROWTH_IN_TR_COLOR#;
	}
	.productTD	
	{
		background-color:#PRODUCT_TD_COLOR#;
	}
	.productInTR
	{
		background-color:#PRODUCT_IN_TR_COLOR#;
	}
	.discountTD	
	{
		border-bottom:solid 000000 1px;
	}
</STYLE>

</CFOUTPUT>


<!--------------------------------------------------------------------------------
Get payee Info
--------------------------------------------------------------------------------->
<cfquery name="Get_Payee_Info" datasource="#application.datasource#">
		SELECT	  
		------------------------Name
		CASE
			WHEN bb.Billback_Payee_Type_ID=1 THEN  
			BSA_Foodservice_Customers.Name  
			
			WHEN bb.Billback_Payee_Type_ID=2 THEN
			BSA_Operator.Operator_Name  
			
			WHEN bb.Billback_Payee_Type_ID=3 THEN 
			BSA_Foodservice_Brokers.Broker_Name
			 
			WHEN bb.Billback_Payee_Type_ID=4 THEN
			Billback_Unidentified_Payee.BB_UP_Name
			
			WHEN bb.Billback_Payee_Type_ID=5 THEN
			Billback_Distributor.BB_Distributor_Name
			
			WHEN bb.Billback_Payee_Type_ID=6 THEN
			Billback_Operator.BB_Operator_Name
			
			WHEN bb.Billback_Payee_Type_ID=7 THEN
			Billback_Broker.BB_Broker_Name
			 
		END AS Payee_Name
		-------------------------City
		,CASE
		WHEN bb.Billback_Payee_Type_ID=1 THEN		
			BSA_Foodservice_Customers.City
			
		WHEN bb.Billback_Payee_Type_ID=2 THEN
			BSA_Operator.Operator_City
			
		WHEN bb.Billback_Payee_Type_ID=3 THEN	
			BSA_Foodservice_Brokers.City
			
		WHEN bb.Billback_Payee_Type_ID=4 THEN
			Billback_Unidentified_Payee.BB_UP_Name

		WHEN bb.Billback_Payee_Type_ID=5 THEN		
			Billback_Distributor.BB_Distributor_City
			
		WHEN bb.Billback_Payee_Type_ID=6 THEN
				Billback_Operator.BB_Operator_City

		WHEN bb.Billback_Payee_Type_ID=7 THEN	
				Billback_Broker.BB_Broker_City

		END AS City
		-------------------------State
		,CASE
		WHEN bb.Billback_Payee_Type_ID=1 THEN		
			BSA_Foodservice_Customers.State		
		
		WHEN bb.Billback_Payee_Type_ID=2 THEN
			BSA_Operator.Operator_State
		
		WHEN bb.Billback_Payee_Type_ID=3 THEN	
			BSA_Foodservice_Brokers.State
		
		WHEN bb.Billback_Payee_Type_ID=4 THEN
			_States.State_Code
		
		WHEN bb.Billback_Payee_Type_ID=5 THEN		
			_States.State_Code
		
		WHEN bb.Billback_Payee_Type_ID=6 THEN
			_States.State_Code
		
		WHEN bb.Billback_Payee_Type_ID=7 THEN	
			_States.State_Code
		
		END AS State_Code
		<CFIF SHOW_PAYEE_UNKNOWN EQ 1>
		,BB_Major_Deviation_Info.Unidentified_Payee
		</CFIF>

		<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
		,CASE bb.Billback_Payee_Type_ID
			WHEN 2
				THEN 
					Billback_Operator.Associated_Ship_to
			WHEN 3
				THEN				
					Billback_Broker.Associated_Ship_to
			ELSE
				NULL
			END

		As Associated_Ship_to

		FROM	
		Billback bb
		----------------------------------------------------
		LEFT JOIN	
			(
			Billback_Broker
			LEFT JOIN
			BSA_Foodservice_Brokers
			ON
			(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
			)
		ON
		(
		(Billback_Broker.Billback_ID = bb.Billback_ID)
		AND
		(
			(bb.Billback_Payee_Type_ID = 3)
			OR
			(bb.Billback_Payee_Type_ID = 7)
		)
		AND
		(Billback_Broker.Deleted = 0)
		)
		----------------------------------------------------				
		LEFT JOIN	
			(
			Billback_Distributor
			LEFT JOIN 
			BSA_Foodservice_Customers
			ON 
			(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
			)
		ON
		(
		(Billback_Distributor.Billback_ID = bb.Billback_ID)
		AND
		(
			(bb.Billback_Payee_Type_ID = 1)
			OR
			(bb.Billback_Payee_Type_ID = 5)
		)
		AND
		(Billback_Distributor.Deleted = 0)
		)
		
		----------------------------------------------------				
		LEFT JOIN	
			(
			Billback_Operator
			LEFT JOIN
			BSA_Operator
			ON
			(Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
			)
		ON
		(
		(Billback_Operator.Billback_ID = bb.Billback_ID)
		AND
		(
			(bb.Billback_Payee_Type_ID = 2)
			OR
			(bb.Billback_Payee_Type_ID = 6)
		)
		AND
		(Billback_Operator.Deleted = 0)				
		)
		----------------------------------------------------				
		LEFT JOIN	Billback_Unidentified_Payee
		ON
		(
		(Billback_Unidentified_Payee.Billback_ID = bb.Billback_ID)
		AND
		(bb.Billback_Payee_Type_ID = 4)
		AND
		(Billback_Unidentified_Payee.Deleted = 0)
		)
		----------------------------------------------------				
		LEFT JOIN _States
		ON
		(
		((bb.Billback_Payee_Type_ID = 5) AND (_States.State_ID=Billback_Distributor.BB_Distributor_State))
		OR
		((bb.Billback_Payee_Type_ID = 6) AND (_States.State_ID=Billback_Operator.BB_Operator_State))
		OR
		((bb.Billback_Payee_Type_ID = 7) AND (_States.State_ID=Billback_Broker.BB_Broker_State))
		OR
		((bb.Billback_Payee_Type_ID = 4) AND (_States.State_ID=Billback_Unidentified_Payee.BB_UP_State))
		)
		<CFIF SHOW_PAYEE_UNKNOWN EQ 1>
		LEFT JOIN BB_Major_Deviation_Info
		ON
		(
			(BB_Major_Deviation_Info.Billback_ID = '#Billback_ID#')
			AND
			(BB_Major_Deviation_Info.Deleted = 0)
		)
		</CFIF>
		WHERE
		bb.Deleted = 0				
		AND
		(
			(bb.Billback_Payee_Type_ID = 1 AND Billback_Distributor.Billback_Distributor_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID = 2 AND Billback_Operator.Billback_Operator_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID = 3 AND Billback_Broker.Billback_Broker_ID IS NOT NULL)
			OR
			(bb.Billback_Payee_Type_ID >= 4)
		)
		AND
		bb.Billback_ID = '#Billback_ID#'
	</cfquery>


<!-------------------------------------------
Get Program and Product Info
------------------------------------>
	

	<cfquery name="Get_Program_Products" datasource="#application.datasource#">
		SELECT	Billback_Program.Billback_Program_ID, Billback_Product.Billback_Product_ID, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Billback_Product.BB_Product_Quantity, Units_Of_Measure.Unit_Of_Measure_Desc, Billback_Product.BB_Product_UOM,
				Program_Control_Panel_Options.Generic_Type,
		CASE 
			WHEN Billback_Program.Program_ID IS NULL THEN
				Billback_Program.BB_Program_Title
			ELSE
				Contract_Main.Contract_Title
		END AS Program_Title
		,CASE 
			WHEN Billback_Program.Program_ID IS NULL THEN
				Billback_Program.BB_Program_Number
			ELSE
				Contract_Main.Contract_Number
		END AS Program_Number
		,CASE 
			WHEN Billback_Product.Product_ID IS NULL THEN
				Billback_Product.BB_Unknown_Product_Item_Number
			ELSE
				BSA_Foodservice_Items_Master.Item
		END AS Item_Number
		,CASE 
			WHEN Billback_Product.Product_ID IS NULL THEN
				Billback_Product.BB_Unknown_Product_Description
			ELSE
				BSA_Foodservice_Items_Master.Description
		END AS Description,
		Billback_Product_Detail.Billback_Product_Detail_ID, Billback_Product_Detail.BB_Product_Type_ID, Billback_Product_Detail.BB_Rate
		,BB_Product_Deviation_Info.Unauthorized_Product, BB_Product_Deviation_Info.Unknown_product
		<!---PNF--->
		<CFIF SHOW_PROGRAM_PNF EQ 1>
		,BB_Program_Deviation_Info.Program_Not_Found
		</CFIF>
		<!---Unauthorized Payee--->
		<CFIF SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1>
		,BB_Program_Deviation_Info.Unauthorized_Payee
		</CFIF>
		<!----Date does not match---->
		<CFIF SHOW_PROGRAM_DATE_MISMATCH EQ 1>
		,BB_Program_Deviation_Info.Dates_Not_Match
		,CASE
		WHEN BB_Program_Deviation_Info.BB_Dollar_Amount = 0 THEN
			0 
		ELSE
			((BB_Program_Deviation_Info.Dates_Not_Match) * 100 / BB_Program_Deviation_Info.BB_Dollar_Amount) 	
		END AS Dates_Not_Match_Percent
		</CFIF>
		<!-----Date Overlap----->
		<CFIF SHOW_DISCOUNT_DATE_OVERLAP EQ 1>
		,BB_Overlap_Deviation_Info.Overlap
		</CFIF>
		<!---- Rate Devition ----->
		<CFIF ListLen(SHOW_DISCOUNT_RATE, ",") GT 0>
		,CASE 
		<CFLOOP LIST="#SHOW_DISCOUNT_RATE#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 1 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Fixed_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Fixed_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="2">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 2 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Rebate_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Rebate_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="4">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 4 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Growth_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Growth_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Formula_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Formula_Product_Rate.Rate_Deviation_LB
					END				
				</CFCASE>
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Rate_Deviation		
		</CFIF>		
		<!---- Volume Devition ----->
		<CFIF ListLen(SHOW_DISCOUNT_VOLUME, ",") GT 0>
		,CASE 
		<CFLOOP LIST="#SHOW_DISCOUNT_VOLUME#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 1 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Fixed_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Fixed_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="2">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 2 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Rebate_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Rebate_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>
				<CFCASE VALUE="4">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 4 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Growth_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Growth_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>		
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN			
					CASE 
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Formula_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Formula_Product_Volume.Volume_Deviation_LB
					END				
				</CFCASE>				
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Volume_Deviation		
		</CFIF>		
		FROM	
		Billback
		INNER JOIN	
			(	
				Billback_Program
				LEFT JOIN	Contract_Main
				ON
				(
				(Billback_Program.Program_ID = Contract_Main.Contract_Main_ID)
				)
				LEFT JOIN	Program_Control_Panel_Options
				ON
				(
					(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
				)
			)
		ON
		(
		(Billback_Program.Billback_ID = Billback.Billback_ID)
		AND
		(Billback_Program.Deleted = 0)
		)
		<CFIF (SHOW_PROGRAM_PNF EQ 1) OR (SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1) OR (SHOW_PROGRAM_DATE_MISMATCH EQ 1)>
		LEFT JOIN BB_Program_Deviation_Info
		ON
		(
			(BB_Program_Deviation_Info.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Program_Deviation_Info.Deleted = 0)
		)
		</CFIF>		
		LEFT JOIN	
			(
			Billback_Product
			LEFT JOIN	BSA_Foodservice_Items_Master
			ON
			(
			(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=Billback_Product.Product_ID)
			AND
			(BSA_Foodservice_Items_Master.Deleted = 0)
			)
			LEFT JOIN	Units_of_Measure
			ON
			(Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM)
			)
			RIGHT JOIN	Billback_Product_Detail
			ON
			(
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
				(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5))
			)
		ON
		(
		(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND
		(Billback_Product.Deleted = 0)
		)
		LEFT JOIN BB_Product_Deviation_Info
		ON
		(
			(BB_Product_Deviation_Info.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND
			(BB_Product_Deviation_Info.Deleted = 0)
			AND
			(BB_Product_Deviation_Info.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		<CFIF SHOW_DISCOUNT_DATE_OVERLAP EQ 1>
		LEFT JOIN BB_Overlap_Deviation_Info
		ON
		(
			(BB_Overlap_Deviation_Info.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND
			(BB_Overlap_Deviation_Info.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
			AND
			(BB_Overlap_Deviation_Info.Deleted = 0)
		)
		</CFIF>
		<CFIF ListLen(SHOW_DISCOUNT_RATE, ",") GT 0>		
		<CFLOOP LIST="#SHOW_DISCOUNT_RATE#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSET discount_Type_Deviation_Table = "">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
					<CFSET discount_Type_Deviation_Table = "BB_Fixed_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="2">
					<CFSET discount_Type_Deviation_Table = "BB_Rebate_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="4">
					<CFSET discount_Type_Deviation_Table = "BB_Growth_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="5">
					<CFSET discount_Type_Deviation_Table = "BB_Formula_Product_Rate">
				</CFCASE>						
			</CFSWITCH>
			<CFIF discount_Type_Deviation_Table NEQ "">
				LEFT JOIN	#discount_Type_Deviation_Table#
				ON
				(
					(#discount_Type_Deviation_Table#.Billback_ID = Billback.Billback_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Product_ID = Billback_Product.Billback_Product_ID)
					AND
					(#discount_Type_Deviation_Table#.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
					AND
					(#discount_Type_Deviation_Table#.Deleted = 0)
				)
			</CFIF>
		</CFLOOP>		
		</CFIF>
		<CFIF ListLen(SHOW_DISCOUNT_VOLUME, ",") GT 0>		
		<CFLOOP LIST="#SHOW_DISCOUNT_VOLUME#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSET discount_Type_Deviation_Table = "">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">	
				<CFCASE VALUE="1">
					<CFSET discount_Type_Deviation_Table = "BB_Fixed_Product_Volume">
				</CFCASE>
				<CFCASE VALUE="2">
					<CFSET discount_Type_Deviation_Table = "BB_Rebate_Product_Volume">
				</CFCASE>
				<CFCASE VALUE="4">
					<CFSET discount_Type_Deviation_Table = "BB_Growth_Product_Volume">
				</CFCASE>				
				<CFCASE VALUE="5">
					<CFSET discount_Type_Deviation_Table = "BB_Formula_Product_Volume">
				</CFCASE>
			</CFSWITCH>
			<CFIF discount_Type_Deviation_Table NEQ "">
				LEFT JOIN	#discount_Type_Deviation_Table#
				ON
				(
					(#discount_Type_Deviation_Table#.Billback_ID = Billback.Billback_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(#discount_Type_Deviation_Table#.Billback_Product_ID = Billback_Product.Billback_Product_ID)
					AND
					(#discount_Type_Deviation_Table#.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
					AND
					(#discount_Type_Deviation_Table#.Deleted = 0)
				)
			</CFIF>
		</CFLOOP>		
		</CFIF>
		WHERE
		Billback.Billback_ID = '#Billback_ID#'
		ORDER BY Billback_Program.Billback_Program_ID, Billback_Product.Billback_Product_ID, Billback_Product_Detail.BB_Product_Type_ID
	</cfquery>

	
	<CFINCLUDE TEMPLATE="Show_Next_Prev_Buttons.cfm">
	<TABLE ALIGN="CENTER" WIDTH="90%">
	<TR>
		<TD ALIGN="LEFT">
		<CFOUTPUT>
		<SPAN CLASS="Title2">Step #THIS_STEP_LEVEL_IN_LIST# of #MAX_LEVEL# - Validate #ListGetAt(VALIDATION_STEPS_DESC, THIS_STEP_LEVEL_IN_LIST, ",")#</SPAN>
		</CFOUTPUT>
		</TD>
	</TR>
	</TABLE>
	
	<CFSET TOTAL_COLUMNS=10>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0">
		<COL SPAN="1" NOWRAP></COL><!---Payee--->
		<COL SPAN="1" NOWRAP></COL><!---Program--->
		<COL SPAN="1" WIDTH="50" NOWRAP></COL><!---Product--->
		<COL SPAN="2" WIDTH="15%" NOWRAP></COL><!---Discount Type--->
		<COL SPAN="1" NOWRAP WIDTH="20%"></COL><!---Validation--->
		<COL SPAN="1" WIDTH="100" NOWRAP></COL><!---val img--->
		<COL SPAN="2" WIDTH="100" NOWRAP></COL><!---val %--->
		<COL SPAN="1" WIDTH="10" NOWRAP></COL><!---val amount--->
		
	<THEAD BGCOLOR="FFCE84">
		<TD CLASS="Table_Header">Payee</TD>
		<TD CLASS="Table_Header">Program</TD>
		<TD CLASS="Table_Header">Product&nbsp;&nbsp;</TD>
		<TD COLSPAN="2" CLASS="Table_Header">Discount Type</TD>
		<TD CLASS="Table_Header">Validation</TD>
		<TD CLASS="Table_Header">&nbsp;</TD>
		<TD CLASS="Table_Header">Deviation %</TD>
		<TD CLASS="Table_Header">Deviation Amount</TD>
		<TD CLASS="Table_Header">&nbsp;</TD>
	</THEAD>
	<!--------- Show Payee -------->
	<TR>
		<TD COLSPAN="100%" CLASS="payeeTD"> 
		<CFOUTPUT>
		<CFIF Get_Payee_Info.recordCount GT 0>
			#Get_Payee_Info.Payee_Name#, #Get_Payee_Info.City#<CFIF Len(Trim(Get_Payee_Info.State_Code)) GT 0>, </CFIF>#Get_Payee_Info.State_Code#
		<CFELSE>
			NONE SUPPLIED
		</CFIF>
		</CFOUTPUT>
		</TD>
	</TR>
	<!--------- Show Unknown Payee -------->
	<CFOUTPUT>
	<TR CLASS="payeeInsideTD">
		<TD COLSPAN="5" CLASS="payeeInsideTD">&nbsp;</TD>
	<CFIF (SHOW_PAYEE_UNKNOWN EQ 1) AND (Get_Payee_Info.Unidentified_Payee NEQ "")>
		<CFIF Get_Payee_Info.Unidentified_Payee GT 0>
			<TD CLASS="NoValidDesc">Known Payee</TD>
			<TD CLASS="NoValidDesc">#show_No#</TD>
			<TD CLASS="NoValidDesc">100.00%</TD>
			<TD CLASS="NoValidDesc">#DollarFormat(Get_Payee_Info.Unidentified_Payee)#</TD>
		<CFELSE>
			<TD CLASS="YesValidDesc">Known Payee</TD>
			<TD CLASS="YesValidDesc">#show_Yes#</TD>
			<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
		</CFIF>
	<CFELSE>
			<TD CLASS="NotprocessedValidDesc">Known Payee</TD>
			<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
			<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>
	</CFIF>
		<TD>&nbsp;</TD>
	</TR>
	</CFOUTPUT>
	<!----- Show Programs and Products ------>
	<CFIF Get_Program_Products.RecordCount GT 0>
		<CFOUTPUT QUERY="Get_Program_Products" GROUP="Billback_Program_ID">
			<TR ID="Program_TR_NO_Colapse">
				<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="8" CLASS="programTD">[#Get_Program_Products.Program_Number#] #Get_Program_Products.Program_Title#</TD>
				<TD CLASS="programTD" OnClick="javaScript: Open_Close(this);" STYLE="CURSOR:pointer" NOWRAP><IMG SRC="/Images/up_1.gif" ID="IMG_CLOSE"><IMG SRC="/Images/down_1.gif" ID="IMG_OPEN" STYLE="DISPLAY:NONE;"></TD>
			</TR>
			
			<!----- Show Unknown Program ---------->
			
			<TR>
			<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
			<TD COLSPAN="4" CLASS="programLeft">&nbsp;</TD>
			<CFIF (SHOW_PROGRAM_PNF EQ 1) AND (Program_Not_Found NEQ "")>
					<CFIF Program_Not_Found GT 0>
					<TD CLASS="NoValidDesc">Known Program</TD>
					<TD CLASS="NoValidDesc">#show_No#</TD>
					<TD CLASS="NoValidDesc">100.00%</TD>
					<TD CLASS="NoValidDesc">#DollarFormat(Program_Not_Found)#</TD>
					<CFELSE>
					<TD CLASS="YesValidDesc">Known Program</TD>
					<TD CLASS="YesValidDesc">#show_Yes#</TD>
					<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
					</CFIF>
			<CFELSE>				
					<TD CLASS="NotprocessedValidDesc">Known Program</TD>
					<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
					<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>					
			</CFIF>
				<TD CLASS="programRight">&nbsp;</TD>
			</TR>
			
			<!-------------- Show Unauthorized Payee -------------------->
			<TR>
				<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="4" CLASS="programLeft">&nbsp;</TD>
			<CFIF (SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1) AND (Unauthorized_Payee NEQ "")>
				<CFIF Unauthorized_Payee GT 0>
					<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="Authorized_Payee_List.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Payee</A></TD>
					<TD CLASS="NoValidDesc">#show_No#</TD>
					<TD CLASS="NoValidDesc">100.00%</TD>
					<TD CLASS="NoValidDesc">#DollarFormat(Unauthorized_Payee)#</TD>
				<CFELSE>
					<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="Authorized_Payee_List.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Payee</A></TD>
					<TD CLASS="YesValidDesc">#show_Yes#</TD>
					<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
				</CFIF>					
			<CFELSE>
				<TD CLASS="NotprocessedValidDesc">Authorized Payee</TD>
				<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
				<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>
			</CFIF>
				 <TD CLASS="programRight">&nbsp;</TD>
			</TR>
			
			<!-------------- Date mismatch --------------->
			<TR>
				<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="4" CLASS="programLeft">&nbsp;</TD>
			<CFIF (SHOW_PROGRAM_DATE_MISMATCH EQ 1) AND (Dates_Not_Match NEQ "")>
				<CFIF Dates_Not_Match GT 0>
					<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="Deviation_Program_Date_Mismatch.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date Match</A></TD>
					<TD CLASS="NoValidDesc">#show_No#</TD>
					<TD CLASS="NoValidDesc">#NumberFormat(Dates_Not_Match_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
					<TD CLASS="NoValidDesc">#DollarFormat(Dates_Not_Match)#</TD>
				<CFELSE>
					<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="Deviation_Program_Date_Mismatch.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date Match</A></TD>
					<TD CLASS="YesValidDesc">#show_Yes#</TD>
					<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
				</CFIF>				
			<CFELSE>
				<TD CLASS="NotprocessedValidDesc">Date Match</TD>
				<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
				<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>
			</CFIF>
				 <TD CLASS="programRight">&nbsp;</TD>
			</TR>
			
			<!------ Start Lumpsum ---------------->
			<CFQUERY DBTYPE="query" NAME="This_Program_lumpsum">
			SELECT	*
			FROM	Get_Program_Lumpsum
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			<CFIF This_Program_lumpsum.recordCount GT 0>
				<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="7" CLASS="lumpsumTD">#Application.LumpsumLabel# #DollarFormat(This_Program_lumpsum.Total_Program_Lumpsum_Amount)#</TD>		
					<TD CLASS="programRight">&nbsp;</TD>
				</TR>
				<TR CLASS="lumpsumInTR">
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="3">&nbsp;</TD>
					<CFIF (SHOW_LUMPSUM EQ 1) AND This_Program_lumpsum.Lumpsum_Deviation NEQ "">
						<CFIF This_Program_lumpsum.Lumpsum_Deviation GT 0>
							<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="NoValidDesc">#show_No#</TD>
							<TD CLASS="NoValidDesc">100.00%</TD>
							<TD CLASS="NoValidDesc">#DollarFormat(This_Program_lumpsum.Lumpsum_Deviation)#</TD>						
						<CFELSE>
							<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="YesValidDesc">#show_Yes#</TD>
							<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
						</CFIF>
					<CFELSE>
						<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
						<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
						<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>					
					</CFIF>
				 	<TD CLASS="programRight">&nbsp;</TD>
				</TR>
				
				<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="7">&nbsp;</TD>
				 	<TD CLASS="programRight">&nbsp;</TD>
				</TR>
			</CFIF>
			<!------ End Lumpsum ------->
			
			<!---------- Start Growth Get_Program_Growth --------->
			<CFQUERY DBTYPE="query" NAME="This_Program_Growth">
			SELECT	*
			FROM	Get_Program_Growth
			WHERE
					Billback_Program_ID = '#Billback_Program_ID#'
			</CFQUERY>
			<CFIF This_Program_Growth.recordCount GT 0>
				<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="7" CLASS="growthTD">Growth #DollarFormat(This_Program_Growth.Total_Growth)#</TD>		
					<TD CLASS="programRight">&nbsp;</TD>
				</TR>
				<TR CLASS="growthInTR">
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="3">&nbsp;</TD>
					<CFIF (SHOW_GROWTH EQ 1) AND This_Program_Growth.Growth_Deviation NEQ "">
						<CFIF This_Program_Growth.Growth_Deviation GT 0>
							<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="NoValidDesc">#show_No#</TD>
							<TD CLASS="NoValidDesc">#NumberFormat(This_Program_Growth.Growth_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
							<TD CLASS="NoValidDesc">#DollarFormat(This_Program_Growth.Growth_Deviation)#</TD>						
						<CFELSE>
							<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
							<TD CLASS="YesValidDesc">#show_Yes#</TD>
							<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
						</CFIF>
					<CFELSE>
						<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Total Amount</A></TD>
						<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
						<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>					
					</CFIF>
				 	<TD CLASS="programRight">&nbsp;</TD>
				</TR>
				
				<TR>
					<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
					<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
					<TD COLSPAN="7">&nbsp;</TD>
				 	<TD CLASS="programRight">&nbsp;</TD>
				</TR>
			</CFIF>
			<!---------- End Growth --------->
			
			<!---------- Start Products --------------->
			<CFIF Billback_Product_ID NEQ "">
				<CFOUTPUT GROUP="Billback_Product_ID">
					<TR>
						<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="7" CLASS="productTD">#Get_Program_Products.Item_Number# #Get_Program_Products.Description#&nbsp;&nbsp;&nbsp;&nbsp;#Get_Program_Products.BB_Product_Quantity# #Unit_Of_Measure_Desc#</TD>		
					 	<TD CLASS="programRight">&nbsp;</TD>
					</TR>
					
					<!------- Show Product Unknown ------------->
					<TR CLASS="productInTR">
						<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="3">&nbsp;</TD>
						<CFIF (SHOW_PRODUCT_UNKNOWN EQ 1) AND (Unknown_product NEQ "")>
							<CFIF Unknown_product GT 0>
								<TD CLASS="NoValidDesc">Known Product</TD>
								<TD CLASS="NoValidDesc">#show_No#</TD>
								<TD CLASS="NoValidDesc">100.00%</TD>
								<TD CLASS="NoValidDesc">#DollarFormat(Unknown_product)#</TD>						
							<CFELSE>
								<TD CLASS="YesValidDesc">Known Product</TD>
								<TD CLASS="YesValidDesc">#show_Yes#</TD>
								<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
							</CFIF>
						<CFELSE>
							<TD CLASS="NotprocessedValidDesc">Know Product</TD>
							<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
							<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>
						</CFIF>
						 <TD CLASS="programRight">&nbsp;</TD>
					</TR>
					<!-----Start Discount Type ------->
					<CFIF BB_Product_Type_ID NEQ "">
						<CFOUTPUT>
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="1">&nbsp;</TD>								
								<TD COLSPAN="6" CLASS="discountTD">
								<CFIF BB_Product_Type_ID LTE ListLen(Discount_Type_List,",")>#Trim(ListGetAt(Discount_Type_List,BB_Product_Type_ID,","))#</CFIF>
								 ($#BB_Rate#)</TD>
								  <TD CLASS="programRight">&nbsp;</TD>				
							</TR>
							
							<!----- Unauthorized Discount Type --------->
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (SHOW_DISCOUNT_UN_AUTH EQ 1) AND (Unauthorized_Product NEQ "")>
								<CFIF Unauthorized_Product GT 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Product</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<TD CLASS="NoValidDesc">100.00%</TD>
									<TD CLASS="NoValidDesc">#DollarFormat(Unauthorized_Product)#</TD>
								<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Authorized Product</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
									<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
								</CFIF>
							<CFELSE>
								<TD CLASS="NotprocessedValidDesc">Authorized Product</TD>
								<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
								<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>								
							</CFIF>
								<TD CLASS="programRight">&nbsp;</TD>
							</TR>
							
							<!----- Rate --------------->
							<CFSET This_Discount_Type_Rate_Detail_Page=Trim(ListGetAt(DETAIL_PAGE_EXPECTED_RATE, BB_Product_Type_ID, ","))>
							<CFSET This_Discount_Volume_Rate_Detail_Page=Trim(ListGetAt(DETAIL_PAGE_EXPECTED_VOLUME, BB_Product_Type_ID, ","))>
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (ListLen(SHOW_DISCOUNT_RATE,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_RATE)) AND (Discount_Rate_Deviation NEQ "")>								
								<CFIF Discount_Rate_Deviation NEQ "" AND Discount_Rate_Deviation NEQ 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="#This_Discount_Type_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#&Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<CFSET Discount_Amount_Deviation=Discount_Rate_Deviation*BB_Product_Quantity>
									<CFIF Discount_Amount_Deviation GT BB_Rate>
										<CFSET Discount_Amount_Deviation = BB_Rate>
									</CFIF>
									
									<CFSET Amount_Deviation = Discount_Amount_Deviation>
									<CFSET Amount_Deviation = Abs(Amount_Deviation)>									
									<CFIF IsNumeric(BB_Rate) AND (BB_Rate NEQ "") AND BB_Rate NEQ 0>
										<CFSET Deviation_Percent = (Amount_Deviation/BB_Rate)*100>
									<CFELSE>
										<CFSET Deviation_Percent = 0>
									</CFIF>
									<CFIF Deviation_Percent GT 100>
										<CFSET Deviation_Percent=100>
									</CFIF>
									<CFSET Deviation_Percent = Abs(Deviation_Percent)>
									<TD CLASS="NoValidDesc">#NumberFormat(Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
									<TD CLASS="NoValidDesc">#DollarFormat(Amount_Deviation)#</TD>
								<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="#This_Discount_Type_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#&Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
									<TD CLASS="YesValidDesc"></TD>
									<TD CLASS="YesValidDesc"></TD>	
								</CFIF>
							<CFELSE>
									
									<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="#This_Discount_Type_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#&Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</A></TD>
									
									<!----
									<TD CLASS="NotprocessedValidDesc">Rate/#Left(Unit_Of_Measure_Desc, Len(Unit_Of_Measure_Desc) - 1)#</TD>									
									---->
									<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
									<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>
							</CFIF>
								<TD CLASS="programRight">&nbsp;</TD>
							</TR>

							<!--------- Volume ------------->							
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (ListLen(SHOW_DISCOUNT_VOLUME,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_VOLUME)) AND (Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNoCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0 OR Associated_Ship_TO NEQ "") AND (Discount_Volume_Deviation NEQ "")>
								<CFIF Discount_Volume_Deviation NEQ "" AND Discount_Volume_Deviation NEQ 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="#This_Discount_Volume_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Volume</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<CFIF Discount_Volume_Deviation GT BB_Product_Quantity>
										<CFSET Volume_Deviation = BB_Product_Quantity>
									<CFELSE>
										<CFSET Volume_Deviation = Discount_Volume_Deviation>
									</CFIF>	
									<CFIF IsNumeric(BB_Product_Quantity) AND (BB_Product_Quantity NEQ "") AND BB_Product_Quantity NEQ 0>
										<CFSET Volume_Deviation_Percent=Evaluate("#Volume_Deviation#/#BB_Product_Quantity#*100")>
									<CFELSE>
										<CFSET Volume_Deviation_Percent=0>
									</CFIF>									
									<CFSET Volume_Deviation_Percent = Abs(Volume_Deviation_Percent)>
									<CFIF Volume_Deviation_Percent GT 100>
										<CFSET Volume_Deviation_Percent=100>
									</CFIF>
									<CFSET Discount_Amount_Volume_Deviation=(BB_Rate*Volume_Deviation_Percent)/100>									
									<TD CLASS="NoValidDesc">#NumberFormat(Volume_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
									<TD CLASS="NoValidDesc">#DollarFormat(Discount_Amount_Volume_Deviation)#</TD>
								<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="#This_Discount_Volume_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Volume</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
									<TD CLASS="YesValidDesc"></TD>
									<TD CLASS="YesValidDesc"></TD>
								</CFIF>
							<CFELSE>
									<CFIF (Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNoCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0 OR Associated_Ship_TO NEQ "")>
										<CFSET show_Status_Image = show_Question>
									<CFELSE>
										<CFSET show_Status_Image = show_Nothing>
									</CFIF>									
									<TD CLASS="NotprocessedValidDesc"><A CLASS="NotprocessedValidDesc" HREF="#This_Discount_Volume_Rate_Detail_Page#?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Volume</A></TD>
									
									<!------
									<TD CLASS="NotprocessedValidDesc">Volume</TD>
									----->
									<TD CLASS="NotprocessedValidDesc">#show_Status_Image#</TD>
									<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>									
							</CFIF>
								<TD CLASS="programRight">&nbsp;</TD>
							</TR>
							
							
							<!--------- Date Overlap --------->
							<TR CLASS="productInTR">
								<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="3">&nbsp;</TD>
							<CFIF (SHOW_DISCOUNT_DATE_OVERLAP EQ 1) AND (Overlap NEQ "")>
									<CFIF Overlap GT 0>
									<TD CLASS="NoValidDesc"><A CLASS="NoValidDesc" HREF="Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date</A></TD>
									<TD CLASS="NoValidDesc">#show_No#</TD>
									<TD CLASS="NoValidDesc">#NumberFormat(Evaluate("#Overlap#/#BB_Rate#*100"), DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
									<TD CLASS="NoValidDesc">#DollarFormat(Overlap)#</TD>
									<CFELSE>
									<TD CLASS="YesValidDesc"><A CLASS="YesValidDesc" HREF="Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date</A></TD>
									<TD CLASS="YesValidDesc">#show_Yes#</TD>
									<TD COLSPAN="2" CLASS="YesValidDesc">&nbsp;</TD>
									</CFIF>									
							<CFELSE>
									<TD CLASS="NotprocessedValidDesc">Date</TD>
									<TD CLASS="NotprocessedValidDesc">#show_Question#</TD>
									<TD COLSPAN="2" CLASS="NotprocessedValidDesc">&nbsp;</TD>
							</CFIF>
								<TD CLASS="programRight">&nbsp;</TD>
							</TR>
						</CFOUTPUT>
					</CFIF>
					
					<!--------- Close Product ---------->
					<TR>
						<TD COLSPAN="1" CLASS="payeeInsideTD">&nbsp;</TD>
						<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
						<TD COLSPAN="7">&nbsp;</TD>
					 	<TD CLASS="programRight">&nbsp;</TD>
					</TR>
				</CFOUTPUT>
			</CFIF>
			
			<!------------ End Programs --------------->
			<TR>
				<TD CLASS="payeeInsideTD">&nbsp;</TD>
				<TD COLSPAN="100%" CLASS="programBottom">&nbsp;</TD>
			</TR>
			<TR ID="Program_TR_NO_Colapse">				 
				<TD COLSPAN="100%" CLASS="payeeInsideTD">&nbsp;</TD>					
			</TR>
			
		</CFOUTPUT> <!----- Programs ----->
	</CFIF>
	</TABLE>
	
	<CFINCLUDE TEMPLATE="Show_Next_Prev_Buttons.cfm">

	
	<!--- temporary code for approval--->
	<!------------------
	<CFIF THIS_STEP_LEVEL_IN_LIST GT 1 AND THIS_STEP_LEVEL_IN_LIST EQ MAX_LEVEL>
		<form action="../capture/Billback_Approval_Action.cfm" method="post" name="ApprovalForm" id="ApprovalForm">
			<input type="Hidden" name="Billback_ID" value="<cfoutput>#Billback_ID#</cfoutput>">
			<input type="Hidden" name="Status_Value" value="3">
		</FORM>
	</CFIF>
	-------->
</BLOCKQUOTE>
<CFOUTPUT>
<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: F5F5DC; z-index: 5000;width:250;height:50;border:1px solid black;">
<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0">
	 	<TR>
			<TD>
				#show_Yes_Start#&nbsp;No Deviation
			</TD>
			<TD>
				#show_No_Start#&nbsp;Deviated
			</TD>
		</TR>
		<TR>
			<TD>
				#show_Question_Start#&nbsp;Not yet processed
			</TD>
			<TD>
				#show_Nothing_Start#&nbsp;Will not be processed
			</TD>
		</TR>
	</TABLE>
</DIV>
</CFOUTPUT>
<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")


function initTheTooltip()
{
	popUp(-1)
}
		
</SCRIPT>

</BODY>
</HTML>

<!--- update the status flags in the menu --->
<CFSET thisBBID = Billback_ID>
<cfinclude template="../capture/Billback_Status_Indicator.cfm">
