<!------
Deviation.cfm
----->
<cfparam name="CountThisItem" default="0">
<cfinclude template="/get_access_profile.cfm">
<CFSET Max_Approval_Amount = Get_Profile_Settings.BB_Tot_Approve_Amount>

<cfheader name="Cache-Control" value="no-store">

<CFSET Print_Button_Show 		= 0>
<CFSET Email_Button_Show 		= 0>
<CFSET Fax_Button_Show 			= 0>
<CFSET Exptd_BB_Diff_Show		= 1> <!--- Dev Note: KAL; 6311 --->

<CFPARAM NAME="URL.SHOW_PRINT_VERSION" 	DEFAULT=0>
<CFSET SHOW_PRINT_VERSION = URL.SHOW_PRINT_VERSION>
<CFPARAM NAME="URL.SHOW_FAX_EMAIL_VERSION" 	DEFAULT=0>
<CFSET SHOW_FAX_EMAIL_VERSION = URL.SHOW_FAX_EMAIL_VERSION>

<CFSET SHOW_LINK_IF_QUESTION_MARK = 0>
<CFSET RUN_ROUTINES = 1>
<CFSET SHOW_NEXT_PREV = 1>
<CFSET VALIDATION_SHOW_ALL = 0>
<CFSET SHOW_IMAGE = 1>

<CFSET Total_Billback_Deviation_Percent = 0>

<CFIF SHOW_PRINT_VERSION EQ 1>
	<CFSET RUN_ROUTINES = 0>
	<CFSET SHOW_NEXT_PREV = 0>
</CFIF>
<CFIF SHOW_FAX_EMAIL_VERSION EQ 1>
	<CFSET RUN_ROUTINES = 0>
	<CFSET SHOW_NEXT_PREV = 0>
	<CFSET SHOW_IMAGE = 0>
</CFIF>

<cfset format3Decimal = "_$___,___,___,___,___.___">

<CFPARAM NAME="Discount_Expected_Rate"				DEFAULT=0> <!--- KAL; 6311 --->
<CFPARAM NAME="URL.Deviation_Show_Expected_Values" 	DEFAULT=0>
<CFPARAM NAME="FORM.Deviation_Show_Expected_Values" 	DEFAULT="#URL.Deviation_Show_Expected_Values#">
<CFSET Deviation_Show_Expected_Values = FORM.Deviation_Show_Expected_Values>
<cfif Deviation_Show_Expected_Values EQ 1> <!--- Dev Note: KAL; 6311 --->
	<CFSET Exptd_BB_Diff_Show		= 0>
</cfif>

<CFPARAM NAME="FORM.BBID" 								DEFAULT="">
<CFPARAM NAME="URL.BBID"								DEFAULT="#FORM.BBID#">
<CFSET Billback_ID=URL.BBID>
<CFSET InfoBar_BBID = Billback_ID>
<!--- 19441 Starts --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
    <!---
         21160: Anand Rao/09-Nov-09
        Added the below query to fetch the Uploaded_Billback value from the DB
        for this Billback_D and added the condition "AND (GetUploadedBB.Uploaded_Billback NEQ 0)" so
        that the grid can be used only for the uploaded_billbacks and not for all
        types. This was to avaoid getting the lumpsum into the flex grid.
    --->
    <cfset useLakebaseForGetUploadedBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetUploadedBB>
	<cftry>
		<cfset GetUploadedBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_title,bb_reference,bb_code,billback_status_id,uploaded_billback"
			}), "bb_title,bb_reference,bb_code,billback_status_id,uploaded_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUploadedBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUploadedBB>
<cfquery name="GetUploadedBB" datasource="#application.datasource#">
	   SELECT BB_Title,BB_Reference,BB_Code,Billback_Status_ID,Uploaded_Billback
     FROM Billback
     WHERE Billback_ID = '#Billback_ID#'
	  </cfquery>
</cfif>
 <!---  <cfif appSettings.get_Setting('BB_Deviation_Format') is 'Flex' AND GetUploadedBB.Uploaded_Billback NEQ 0> --->
<!---  <cfif (((Billback_Status_ID EQ 2) OR((Billback_Status_ID EQ 3) AND(appSettings.getUpdate_BB_Approve_Amt() EQ 1)))  AND (appSettings.get_Setting('BB_Deviation_Format') is 'Flex') )>
 --->
  <cfif (appSettings.get_Setting('BB_Deviation_Format') is 'Flex') OR appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
<!---AND (DD_Closure_Sent_on EQ "")  AND (Uploaded_Billback NEQ 0) was removed from the condition --->
<!---   <HR>
  <FONT SIZE="+1">Payable number: <cfoutput>#GetUploadedBB.BB_Code#</cfoutput></FONT>
  <HR> --->
  <!---
      D21923/Anand Rao/22-Feb-10
      This will display the Billback header at the top of the page.
  --->
  <cfset InfoBar_BBID = Billback_ID />
	<cfinclude template="../capture/billback_load_infobar.cfm" />


    <div id="divFlexApp" align="center" >
      <!--- 19441: If the Billback status is 2 then show the image/link for the Flex BB deviation  --->
 	    <br><br><br>
      <FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

		<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
			<cfset newWindowPage ="/billbacks/deviation/deviation_main.cfm">
			<cfset callerArg = "AgGridBB">
			<cfset source = "BBAgGridScoreCard">
		<cfelse>
			 <cfset newWindowPage ="/flex/Billback/BillbackDevAppFX.cfm">
			 <cfset callerArg = "flexBB">
			 <cfset source = "BBFlexScoreCard">
		</cfif>

		<cfoutput>

<cfset URL.BBID = ListRemoveDuplicates(URL.BBID)>
			<a href="##" title="Flex BB Deviation Tool" onclick="javascript:window.open('#newWindowPage#?bbid=#URL.BBID#&userID=#request.AccessStructure.User_ID#&caller=#callerArg#&source=#source#','BBDeviation','location=1,status=1,scrollbars=1,resizable=1,width=1350,left=0,height=800');return false;"> View Deviations </A>
		</cfoutput>
			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
    </div>
    <cfabort>
  </cfif>
<!---
19441 Ends
--->

<cfinclude template="../capture/billback_load_infobar.cfm" />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">
<CFSET ADDSCRIPT = "Yes">
<CFINCLUDE TEMPLATE="Date_Graph_Settings.cfm">

<html>
<head>
	<title>Billback Validation</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="3" MARGINWIDTH="0">


<CFINCLUDE TEMPLATE="Deviation_Display_Style.cfm">

<CFINCLUDE TEMPLATE="Validation_Req.cfm">

<CFIF NOT SHOW_FAX_EMAIL_VERSION>
	<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
</CFIF>

<CFSET Previously_Approved_Total_For_JavaScript = 0>
<CFSET Approved_Total_For_JavaScript = 0>
<cfset ApprovedTotal=0>
<cfset BB_Amount_Total=0>
<cfset E_Amount_Total=0>
<cfset Amount_Deviation = 0>

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
			BB_Growth_Program_User_Selection.Approved_Amount AS BB_Approved_Amount,
			ISNull(BB_Growth_Program_User_Selection.Manual_Growth_Amount, 0) AS Manual_Growth_Amount
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
			(    (Billback_Product.Billback_ID = '#Billback_ID#')
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
			LEFT JOIN BB_Growth_Program_User_Selection
			ON	BB_Growth_Program_User_Selection.Deleted = 0
			AND	BB_Growth_Program_User_Selection.Billback_Program_ID = BB_Growth_Program.Billback_Program_ID
		WHERE
			Billback.Billback_ID = '#Billback_ID#'
		GROUP BY Billback_Program.Billback_Program_ID, BB_Growth_Program.Deviated_Amount
					, Expected_Amount, BB_Growth_Amount, BB_Growth_Program_User_Selection.Approved_Amount, BB_Growth_Program_User_Selection.Manual_Growth_Amount
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
				BB_Lump_Sums_User_Selection.LS_Approved_Amount AS Approved,
				ISNull(BB_Lump_Sums_User_Selection.LS_Manual_Amount, 0) AS Manual
	FROM       Billback_Program_Lumpsum_Component
				LEFT JOIN BB_Lump_Sums
				ON
				(
					(BB_Lump_Sums.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID)
				)
				LEFT JOIN BB_Lump_Sums_User_Selection
				ON	BB_Lump_Sums_User_Selection.Deleted = 0
				AND	BB_Lump_Sums_User_Selection.Billback_Program_ID = BB_Lump_Sums.Billback_Program_ID
	WHERE
			(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
			AND
			(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
			AND
			(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
			AND
			(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
			AND
			Billback_Program_Lumpsum_Component.Billback_ID 		= '#Billback_ID#'
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= 0
	GROUP BY Billback_Program_Lumpsum_Component.Billback_Program_ID, BB_Lump_Sums.Lump_Sum_Deviation
			, BB_Lump_Sums.LS_Expected_Amount, LS_Billback_Amount, BB_Lump_Sums_User_Selection.LS_Approved_Amount, BB_Lump_Sums_User_Selection.LS_Manual_Amount
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

	<!---<CFTRY>---><!---try to get a handle on PK insert errors--->
		<!--- Ana: 17523 - Stop unnecessary procedure exec --->
		<CFSET Call_From_DeviationDotCfm = 1>
		<CFINCLUDE TEMPLATE="Validation_Steps.cfm">
		<CFSET Call_From_DeviationDotCfm = 0>
		<!---<CFCATCH type="database">
				<p>
			 <span style="font-size:14px; color:990000">Please try your request again.  The data necessary for the transaction was temporarily unavailable.
				<br>Data Code:
				<cfoutput>#cfcatch.NativeErrorCode# ::  #cfcatch.SQLState#</cfoutput></span>
				<cfmail from="application@#cgi.SERVER_NAME#" to="msaunders@bigredflame.com" cc="RemoteEvents@BigRedFlame.com" subject="Error in Deviations">
					<cfoutput>#cfcatch.queryError#  :: #cfcatch.NativeErrorCode# ::  #cfcatch.SQLState#
					<br>
					#cgi.SERVER_NAME#  :: #application.returned_customer_setting.company_name#
					<br>
					#cfcatch.message#
					<br>
					#cfcatch.detail#
					<br>
					#cfcatch.SQL#
					<br>
					<cfloop
						 index = i
						 from = 1 to = #ArrayLen(cfcatch.tagContext)#>
						 <cfset sCurrent = #cfcatch.tagContext[i]#>
							  <br>#i# #sCurrent["ID"]#
						 (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#)
						 #sCurrent["TEMPLATE"]#
					  </cfloop>
					</cfoutput>
				</cfmail>
			  <cfabort>
		</CFCATCH>
	</CFTRY>--->


	<cfquery name="Get_Billback_Lumpsum" datasource="#application.datasource#">
	SELECT     	Billback_Program_Lumpsum_Component.Billback_Program_ID
				, Billback_Program_Lumpsum_Component_ID
				, Manual_Lumpsum_Amount
				, CAST(Amount AS FLOAT) BB_Lumpsum_Amount
				, Component_Type_ID
				,CASE
				WHEN Component_Type_ID = 1 THEN
					Program_Lump_Sum_Name.Program_Lump_Sum_Name
				WHEN Component_Type_ID = 3 THEN
					Program_Growth_Components.Component_Name + ' Tier ' + Program_Growth_Component_Tiers.Tier_Number
				ELSE
					Billback_Program_Lumpsum_Component.Name
				END AS Component_Name
	FROM       	Billback_Program_Lumpsum_Component
				LEFT JOIN Program_Lump_Sums
				ON
				Program_Lump_Sums.Program_Lump_Sum_ID =	Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				LEFT JOIN Program_Lump_Sum_Name
					ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
				LEFT JOIN Program_Growth_Components
				ON
				(
					Program_Growth_Components.Program_Growth_Component_ID = Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID
				)
				LEFT JOIN Program_Growth_Component_Tiers
				ON
				(
					Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Billback_Program_Lumpsum_Component.Program_Growth_Component_Tier_ID
				)
	WHERE
			Billback_Program_Lumpsum_Component.Billback_ID 		= '#Billback_ID#'
			AND
			Billback_Program_Lumpsum_Component.Deleted 			= 0
	ORDER BY Billback_Program_Lumpsum_Component.Billback_Program_ID
	</CFQUERY>




<!--------------------Set Constants        ------------------------------>


<!------
<CFSET Mouse_Over_Script=" onmouseover=""initTheTooltip('')"" onmouseout=""popOut()""">
----->
<CFSET Mouse_Over_Script="">
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


<CFOUTPUT>
<!------ for showCountNoCount ----->
<cfif isDefined("url.showCountNoCount")>
	<cfset showCountNoCount = url.showCountNoCount />
<cfelse>
	<cfset showCountNoCount = 0 />
</cfif>
<cfset useLakebaseForBBStatus_Check = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForBBStatus_Check>
	<cftry>
		<cfset BBStatus_Check = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBBStatus_Check = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBBStatus_Check>
<cfquery name="BBStatus_Check" datasource="#application.datasource#">
SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>

<CFIF BBStatus_Check.Billback_Status_ID GT 2>
	<cfset showCountNoCount = 1 />
</CFIF>
<CFIF NOT Deviation_Show_Expected_Values>
	<DIV ID="oDiv_Next_Prev_Buttons">
	<CFINCLUDE TEMPLATE="Next_Prev_Buttons.cfm">
	</DIV>
</CFIF>
<!------ <cfset showCountNoCount = 0> ----->
<cfif BBStatus_Check.Billback_Status_ID gte 3>
<cfset variables.bb_OverrideObj = createObject("component", "components.Billback.BB_Volume_Override").init() />
<cfset variables.bb_OverrideRateObj = createObject("component", "components.Billback.BB_Rate_Override").init() />
<cfset variables.overRideExists = variables.bb_OverrideObj.getBBOverrideInfo(Billback_ID) />
<cfset variables.RateOverRideExists = variables.bb_OverrideRateObj.getBBRateOverrideInfo(Billback_ID) />

<cfif variables.overRideExists.RecordCount>
 <div style="position:absolute;top:10px; width:200px;font-weight:bold;">
 Volume Override applied by <cfoutput>#variables.overRideExists.UserName# on #DateFormat(variables.overRideExists.Override_Date, "mm/dd/yyyy")#</cfoutput>
</div>
</cfif>
<cfif variables.RateOverRideExists.RecordCount>
 <div style="position:absolute;top:10px; width:200px;font-weight:bold;">
 Rate Override applied by <cfoutput>#variables.RateOverRideExists.UserName# on #DateFormat(variables.RateOverRideExists.Override_Date, "mm/dd/yyyy")#</cfoutput>
</div>
</cfif>
</cfif>

<!-------------------------------------------------------------------------
Queries
-------------------------------------------------------------------------->


<!-------------------------------------------
Get Program and Product Info
------------------------------------>


	<cfquery name="Get_Program_Products" datasource="#application.datasource#">
		SELECT	Billback.BB_Code,
				Billback.BB_Title,
				Billback.BB_Start_Date,
				Billback.BB_End_Date,
				Billback_Program.Billback_Program_ID,
				Billback_Program.Program_ID,
				Billback_Product.Billback_Product_ID,
				Billback_Product.Count_Flag,
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				Billback_Product.BB_Product_Quantity,
				Units_Of_Measure.Abbreviation,
				Units_Of_Measure.Unit_Of_Measure_Desc,
				Billback_Product.BB_Product_UOM,
				Program_Control_Panel_Options.Generic_Type,
				Billback.Billback_Payee_Type_ID,
				Billback_Program.Program_ID,
				<!---The item selections--->
				BB_Item_Final.BB_Item_Final_ID,
				BB_Item_Final_Detail.BB_Item_Final_Detail_ID,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						ISNULL(Manual_Rate_CS, 0)
					ELSE
						ISNULL(Manual_Rate_LB, 0)
				END AS Manual_Rate,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						ISNULL(Expected_rate_CS, 0) <!--- From BB_Item_Final_Detail -- already has adjustment included--->
					ELSE
						ISNULL(Expected_rate_LB, 0)
				END AS Expected_Rate,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						ISNULL(Billback_Rate_CS, 0)
					ELSE
						ISNULL(Billback_Rate_LB, 0)
				END AS Billback_Rate,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						Approved_Rate_CS
					ELSE
						Approved_Rate_LB
				END AS Q_Approved_Rate,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						ISNULL(Item_BB_Volume_CS, 0)
					ELSE
						ISNULL(Item_BB_Volume_LB, 0)
				END AS Item_BB_Volume,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						ISNULL(Item_E_Volume_CS, 0)
					ELSE
						ISNULL(Item_E_Volume_LB, 0)
				END AS Item_E_Volume,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						Item_Volume_Approved_CS
					ELSE
						Item_Volume_Approved_LB
				END AS Q_Item_Volume_Approved,

				CASE
					WHEN Billback_Product.BB_Product_UOM = 1
					THEN
						ISNULL(Item_MU_Volume_CS, 0)
					ELSE
						ISNULL(Item_MU_Volume_LB, 0)
				END AS Item_M_Volume,
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
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Formula_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Formula_Product_Rate.Rate_Deviation_LB
					END
				</CFCASE>
				<CFCASE VALUE="11">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 11 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Bid_Request_Product_Rate.Rate_Deviation_CS
					ELSE
						BB_Bid_Request_Product_Rate.Rate_Deviation_LB
					END
				</CFCASE>
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Rate_Deviation
		</CFIF>
		<!---- Expected Rate ----->
		<CFIF ListLen(SHOW_DISCOUNT_RATE, ",") GT 0>
		,CASE
		<CFLOOP LIST="#SHOW_DISCOUNT_RATE#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">
				<CFCASE VALUE="1">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 1 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Fixed_Product_Rate.Adjusted_Rate_CS < 0 THEN
							0
						ELSE
							BB_Fixed_Product_Rate.Adjusted_Rate_CS
						END
					ELSE
						CASE
						WHEN BB_Fixed_Product_Rate.Adjusted_Rate_LB < 0 THEN
							0
						ELSE
							BB_Fixed_Product_Rate.Adjusted_Rate_LB
						END
					END
				</CFCASE>
				<CFCASE VALUE="2">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 2 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Rebate_Product_Rate.Adjusted_Rate_CS < 0 THEN
							0
						ELSE
							BB_Rebate_Product_Rate.Adjusted_Rate_CS
						END
					ELSE
						CASE
						WHEN BB_Rebate_Product_Rate.Adjusted_Rate_LB < 0 THEN
							0
						ELSE
							BB_Rebate_Product_Rate.Adjusted_Rate_LB
						END
					END
				</CFCASE>
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Formula_Product_Rate.Adjusted_Rate_CS < 0 THEN
							0
						ELSE
							BB_Formula_Product_Rate.Adjusted_Rate_CS
						END
					ELSE
						CASE
						WHEN BB_Formula_Product_Rate.Adjusted_Rate_LB < 0 THEN
							0
						ELSE
							BB_Formula_Product_Rate.Adjusted_Rate_LB
						END
					END
				</CFCASE>
				<CFCASE VALUE="11">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 11 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Bid_Request_Product_Rate.Adjusted_Rate_CS < 0 THEN
							0
						ELSE
							BB_Bid_Request_Product_Rate.Adjusted_Rate_CS
						END
					ELSE
						CASE
						WHEN BB_Bid_Request_Product_Rate.Adjusted_Rate_LB < 0 THEN
							0
						ELSE
							BB_Bid_Request_Product_Rate.Adjusted_Rate_LB
						END
					END
				</CFCASE>
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Expected_Rate
		</CFIF>
		,(CAST(Billback_Product_Detail.BB_Rate AS Float) / Billback_Product.BB_Product_Quantity) Discount_BB_Rate
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
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Formula_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Formula_Product_Volume.Volume_Deviation_LB
					END
				</CFCASE>
				<CFCASE VALUE="11">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 11 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						BB_Bid_Request_Product_Volume.Volume_Deviation_CS
					ELSE
						BB_Bid_Request_Product_Volume.Volume_Deviation_LB
					END
				</CFCASE>
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Volume_Deviation
		</CFIF>
		<!---- Expected Volume ----->
		<CFIF ListLen(SHOW_DISCOUNT_VOLUME, ",") GT 0>
		,CASE
		<CFLOOP LIST="#SHOW_DISCOUNT_VOLUME#" DELIMITERS="," INDEX="this_Discount_Type">
			<CFSWITCH EXPRESSION="#this_Discount_Type#">
				<CFCASE VALUE="1">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 1 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Fixed_Product_Volume.Adjusted_Volume_CS < 0 THEN
							0
						ELSE
							BB_Fixed_Product_Volume.Adjusted_Volume_CS
						END
					ELSE
						CASE
						WHEN BB_Fixed_Product_Volume.Adjusted_Volume_LB < 0 THEN
							0
						ELSE
							BB_Fixed_Product_Volume.Adjusted_Volume_LB
						END
					END
				</CFCASE>
				<CFCASE VALUE="2">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 2 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Rebate_Product_Volume.Adjusted_Volume_CS < 0 THEN
							0
						ELSE
							BB_Rebate_Product_Volume.Adjusted_Volume_CS
						END
					ELSE
						CASE
						WHEN BB_Rebate_Product_Volume.Adjusted_Volume_LB < 0 THEN
							0
						ELSE
							BB_Rebate_Product_Volume.Adjusted_Volume_LB
						END
					END
				</CFCASE>
				<CFCASE VALUE="5">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 5 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Formula_Product_Volume.Adjusted_Volume_CS < 0 THEN
							0
						ELSE
							BB_Formula_Product_Volume.Adjusted_Volume_CS
						END
					ELSE
						CASE
						WHEN BB_Formula_Product_Volume.Adjusted_Volume_LB < 0 THEN
							0
						ELSE
							BB_Formula_Product_Volume.Adjusted_Volume_LB
						END
					END
				</CFCASE>
				<CFCASE VALUE="11">
				WHEN Billback_Product_Detail.BB_Product_Type_ID = 11 THEN
					CASE
					WHEN Billback_Product.BB_Product_UOM = 1 THEN
						CASE
						WHEN BB_Bid_Request_Product_Volume.Adjusted_Volume_CS < 0 THEN
							0
						ELSE
							BB_Bid_Request_Product_Volume.Adjusted_Volume_CS
						END
					ELSE
						CASE
						WHEN BB_Bid_Request_Product_Volume.Adjusted_Volume_LB < 0 THEN
							0
						ELSE
							BB_Bid_Request_Product_Volume.Adjusted_Volume_LB
						END
					END
				</CFCASE>
			</CFSWITCH>
		</CFLOOP>
		ELSE
			NULL
		END AS Discount_Expected_Volume
		</CFIF>
		, Contract_Main.Manual_Cancel,Contract_Main.Cancel_And_End_Dated,
				CASE
					WHEN Earned_From_Group = 0	THEN
						Billback_Product_Detail.Distributor_ID_Earned
					ELSE
						Billback_Product_Detail.Customer_Group_ID
					END as dist_id,
				c.name,
				c.ship_to,
				c.shr_ship_to

		<!--- The billback may have an associated distributor when the payee is an operator OR broker. --->
		,CASE Billback.Billback_Payee_Type_ID
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
			(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID=Billback_Product.Product_ID)
			LEFT JOIN	Units_of_Measure
			ON
			(Units_of_Measure.Unit_Of_Measure_ID = Billback_Product.BB_Product_UOM)
			)
			RIGHT JOIN	Billback_Product_Detail
			ON
			(	Billback_Product_Detail.Billback_ID = '#Billback_ID#'
				AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				AND
				(LEN(Billback_Product_Detail.BB_Rate) <> 0)
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) <> 0)
				AND
				<CFIF showCountNoCount EQ 1>
				(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5,10,11))
				<CFELSE>
				(Billback_Product_Detail.BB_Product_Type_ID IN (1,2,5,11))
				</CFIF>
			)
		ON
		(
		(Billback_Product.Billback_ID = '#Billback_ID#')
			AND
		(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND
		(Billback_Product.Deleted = 0)
		)
		LEFT JOIN BB_Product_Deviation_Info
		ON
		(	(BB_Product_Deviation_Info.Billback_ID = Billback_Product.Billback_ID)
			AND
			(BB_Product_Deviation_Info.Billback_Product_ID = Billback_Product.Billback_Product_ID)
			AND
			(BB_Product_Deviation_Info.Deleted = 0)
			AND
			(BB_Product_Deviation_Info.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		<CFIF SHOW_DISCOUNT_DATE_OVERLAP EQ 1>
		LEFT JOIN BB_Overlap_Deviation_Info
		ON
		(	(BB_Overlap_Deviation_Info.Billback_ID = Billback_Product.Billback_ID)
			AND
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
				<CFCASE VALUE="5">
					<CFSET discount_Type_Deviation_Table = "BB_Formula_Product_Rate">
				</CFCASE>
				<CFCASE VALUE="11">
					<CFSET discount_Type_Deviation_Table = "BB_Bid_Request_Product_Rate">
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
				<CFCASE VALUE="5">
					<CFSET discount_Type_Deviation_Table = "BB_Formula_Product_Volume">
				</CFCASE>
				<CFCASE VALUE="11">
					<CFSET discount_Type_Deviation_Table = "BB_Bid_Request_Product_Volume">
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
		LEFT JOIN BB_Item_Final
			ON
			(	BB_Item_Final.Billback_ID = '#Billback_ID#'
				AND
				BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID
				AND
				BB_Item_Final.Deleted =0
			)
		LEFT JOIN BB_Item_Final_Detail
			ON
			(
				BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
				AND
				BB_Item_Final_Detail.Deleted = 0
				AND
				BB_Item_Final_Detail.BB_Product_Type = Billback_Product_Detail.BB_Product_Type_ID
			)
			Left join   BSA_Foodservice_customers C on C.BSA_Foodservice_Customers_ID =  CASE
																WHEN Earned_From_Group = 0	THEN
																	Billback_Product_Detail.Distributor_ID_Earned
																ELSE
																	Billback_Product_Detail.Customer_Group_ID
																END
		LEFT JOIN Billback_Operator
		 ON
		 (
			 Billback.Billback_ID = Billback_Operator.Billback_ID
			 AND Billback_Operator.Deleted = 0
		 )
		LEFT JOIN Billback_Broker
		 ON
		 (
			 Billback.Billback_ID = Billback_Broker.Billback_ID
			 AND Billback_Broker.Deleted = 0
		 )
		WHERE
		Billback.Billback_ID = '#Billback_ID#'
		ORDER BY Billback_Program.Billback_Program_ID, c.ship_to, c.shr_ship_to, BSA_Foodservice_Items_Master.Item, Distributor_ID_Earned, Billback_Product.Billback_Product_ID, Billback_Product_Detail.BB_Product_Type_ID
	</cfquery>

	<CFSET Billback_Payable_Number = Get_Program_Products.BB_Code>
	<CFSET Billback_Billback_Title = Get_Program_Products.BB_Title>

<!-------------------------------------------------------------------------
Deviation Header Constants
-------------------------------------------------------------------------->

<!-------------------------------------------------------------------------
Deviation Header
-------------------------------------------------------------------------->

<CFSET D_TD_Program 	= 	5>
<CFSET D_TD_Product 	= 	36>
<CFSET D_TD_Discount 	= 	225>

<CFSET D_TD_Value	 	= 	90>

<CFSET D_TD_Valid_1 	= 	32>
<CFSET D_TD_Valid_2 	= 	32>
<CFSET D_TD_Valid_3 	= 	32>
<CFSET D_TD_Valid_4 	= 	32>
<CFSET D_TD_Blank	 	= 	0>
<cfset D_TD_Rates		=	53>

<CFSET D_TD_Dev_Dollar 	= 	89>
<CFSET D_TD_Dev_Percent	= 	71>


<CFSET D_TD_BB_VALUE	=	90>
<CFSET D_TD_EX_VALUE	=	90>
<CFSET D_TD_N_VALUE		=	45>

<CFSET D_TD_Count_No_Count	= 	31>

<CFSET D_TD_Extra		= 	0>

<CFIF NOT Deviation_Show_Expected_Values>
	<CFSET D_TD_Discount 	= 	D_TD_Discount - (15 * 3)>
	<cfset D_TD_Rates		=	D_TD_Rates + 15>
</CFIF>

<CFSET D_TABLE_W		=	D_TD_Program + D_TD_Product + D_TD_Discount>
<CFIF NOT Deviation_Show_Expected_Values>
	<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_Value>
<CFELSE>
	<CFSET D_TD_Blank	 	= 	18>
</CFIF>


<CFIF SHOW_IMAGE EQ 1>
	<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_Valid_1 + D_TD_Valid_2>
	<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_Valid_3 + D_TD_Valid_4>
</CFIF>
<CFIF Exptd_BB_Diff_Show>
	<cfset D_Table_W	=	D_Table_W + D_TD_Rates*3>
</CFIF>
<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_Blank + D_TD_Dev_Dollar>
<CFIF NOT Deviation_Show_Expected_Values>
	<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_Dev_Percent + D_TD_Extra>
	<CFSET D_TD_LEN			=	14>
<CFELSE>
	<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_BB_VALUE + D_TD_EX_VALUE + D_TD_N_VALUE>
	<CFIF SHOW_IMAGE EQ 1>
		<CFSET D_TD_LEN			=	13>
	<CFELSE>
		<CFSET D_TD_LEN			=	9>
	</CFIF>
</CFIF>
<CFSET D_TABLE_H		=	270>
<!------ for showCountNoCount ----->
<cfif showCountNoCount>
	<CFSET D_TABLE_W		=	D_TABLE_W + D_TD_Count_No_Count>
</cfif>




<CFIF Deviation_Show_Expected_Values>

<CFOUTPUT>
<CFIF NOT SHOW_FAX_EMAIL_VERSION>
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


function Auto_Select_Program(thisObj, chIndex)
{
	var trObj = getParentObject(thisObj, "TR");
	var tableObj = trObj.parentElement;
	var trObjs = tableObj.rows;
	var i, trLen;
	trLen = trObjs.length;
	for(i=trObj.rowIndex+1;i<trLen;i++)
	{
		if(trObjs[i].id)
		{
			if(trObjs[i].id == "Program_TR_NO_Colapse")
			{
				break;
			}
		}
		Auto_Select_CheckBox_In_This_TR(trObjs[i], chIndex);
	}
}

function Auto_Select_CheckBox_In_This_TR(trObj, check_For_Value)
{
	var i, chLen, chObjs;
	chObjs = trObj.getElementsByTagName("INPUT");
	chLen = chObjs.length;
	var thisCheck;
	var whichIsChecked = null;
	for(i=0;i<chLen;i++)
	{
		if(chObjs[i].type == "radio")
		{
			if(chObjs[i].name)
			{
				thisCheck = chObjs[chObjs[i].name];
				if(thisCheck)
				{
					whichIsChecked = null;
					for(j=0;j<thisCheck.length;j++)
					{
						if(thisCheck[j].checked)
						{
							whichIsChecked = j;
						}
					}
					switch(parseInt(check_For_Value))
					{
						case 0:
							if(whichIsChecked != 0)
							{
								thisCheck[0].click();
							}
							break;
						case 1:
							if(thisCheck.length > 2)
							{
								if(whichIsChecked != 1)
								{
									thisCheck[1].click();
								}
							}
							else
							{
								if(whichIsChecked != 0)
								{
									thisCheck[0].click();
								}
							}
							break;
						case 2:
							if(thisCheck.length > 2)
							{
								if(whichIsChecked != 2)
								{
									thisCheck[2].click();
								}
							}
							break;
						case 3:
							if(thisCheck.length > 3)
							{
								if(whichIsChecked != 3)
								{
									thisCheck[3].click();
								}
							}
							break;
					}
				}
			}
			break;
		}
	}
}

function checkRadios()
{
	//var el = document.forms[0].elements;
	<CFOUTPUT>
	var MaxApprovalAmt = "#Max_Approval_Amount#";
	</CFOUTPUT>
	var el = document.forms[0].getElementsByTagName("input");
	var existingList = "";
	var bErr = false;
	var AboveApprovalAmountErr = 0;
	var itemchecked, itemcheckedIndex, bNextField, bTextBoxFailed, iNextFieldValue, chNameList;

	if (MaxApprovalAmt != "*")
	{
		var totalApprovingAmount = parseFloat(document.all.Tally_Total_Approved_Amount.value);
		var totalCanApproveAmount = parseFloat(MaxApprovalAmt);
		if (totalApprovingAmount > totalCanApproveAmount)
		{
			AboveApprovalAmountErr = 1;
			bErr = true;
			alert("Amount selected is greater than your approval amount limit.\n -- Selected Amount = "+document.all.Tally_Total_Approved_Amount.value+"\n -- Your approval limit = "+MaxApprovalAmt+"\n\n Please make the selected amount less than or equal approval amount and try again.")
		}
	}
	for(var i = 0 ; i < el.length ; ++i)
	{
		if(el[i].type == "radio")
		{
			if (el[i].name)
			{
				if (el[i].name != "Chk_Auto_Select")
				{
					regExp = new RegExp(el[i].name + ",", "igm");
					if(!existingList.match(regExp))
					{
						var radiogroup = el[el[i].name]; // get the whole set of radio buttons.
						// alert("1+" + el[i].name)
						itemchecked = false;
						for(var j = 0 ; j < radiogroup.length ; ++j)
						{
							//alert(radiogroup[j].checked)
							radiogroup[j].disabled = false;
							if(radiogroup[j].checked)
							{
								itemchecked = true;
								itemcheckedIndex = j;
								break;
							}
						}

						// check for manual entry
						bTextBoxFailed = 0;
						if(itemchecked)
						{
							if(itemcheckedIndex == 3)
							{
								bNextField = eval("document.all." + radiogroup[itemcheckedIndex].bNextField);
								if(bNextField)
								{
									iNextFieldValue = parseFloat(bNextField.value);
									if(isNaN(iNextFieldValue))
									{
										bTextBoxFailed = 1;
									}
								}
								else if(radiogroup[itemcheckedIndex].bManual)
								{
									var k, chNameList = radiogroup[itemcheckedIndex].lsNameList;
									var arChNames = chNameList.split(",");
									for(k=0;k<arChNames.length;k++)
									{
										tempObj = eval("document.all.MU_LS_" + arChNames[k]);
										iNextFieldValue = parseFloat(tempObj.value);
										if(isNaN(iNextFieldValue))
										{
											bTextBoxFailed = 1;
											break;
										}
									}
								}
							}
						}

						if(!itemchecked)
						{
							queueMessage("You have not selected a payment amount for an item.", eval("document.all.SP_" + el[i].name + ";"));
							if(el[i].focus)
								el[i].focus();
							bErr = true;
						}
						else if(bTextBoxFailed)
						{
							queueMessage("You have not entered the value for payment amount.", eval("document.all.SP_" + el[i].name + ";"));
							bErr = true;
						}
						else
						{
							clearQueue(eval("document.all.SP_" + el[i].name + ";"));
						}
						existingList = existingList + el[i].name + ",";
					}
				}
			}
		}
	}
	//document.forms[0].submit();
	if(bErr)
	{
		if (AboveApprovalAmountErr == 0)
		{
			showMessageWindow();
		}
		return false;
	}
	else
	{
		return true;
	}
}

</SCRIPT>
</CFIF>
</CFOUTPUT>
	<FORM ACTION="/Billbacks/Approval/payment.cfm" METHOD="POST" ID="CostList" NAME="CostList" onSubmit="javaScript: return checkRadios();" STYLE="DISPLAY:INLINE">
<!------ for showCountNoCount ----->
<cfelse>
	<FORM ACTION="/Billbacks/Approval/populate_table.cfm?BBID=#Billback_ID#" METHOD="POST" ID="frmDeviation" NAME="frmDeviation" STYLE="DISPLAY:INLINE">
</CFIF>
<!--- D13678 - Used for volumeoverride bit
      is set in the js function runOverride() function in Next_Prev_Buttons.cfm
--->
<input type="hidden" name="volume_override" id="volume_override" value="0" />
<input type="hidden" name="rate_override" id="rate_override" value="0" />
<CFSET Total_Billback_Amount = Billback_Amount_Match.BB_Item_Summary>
<CFSET Total_Billback_Deviation = 0>

<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="#D_TABLE_W#">
	<COL SPAN="1" WIDTH="#D_TD_Program#" NOWRAP></COL><!---Program--->
	<COL SPAN="1" WIDTH="#D_TD_Product#" NOWRAP></COL><!---Product--->
	<COL SPAN="1" WIDTH="#D_TD_Discount#" NOWRAP></COL><!---Discount Type--->
	<CFIF NOT Deviation_Show_Expected_Values>
		<COL SPAN="1" WIDTH="#D_TD_Value#" NOWRAP ALIGN="RIGHT"></COL><!---Value--->
	</CFIF>
	<COL SPAN="1" WIDTH="#D_TD_Valid_1#" NOWRAP ALIGN="CENTER"></COL><!---Deviation 1--->
	<COL SPAN="1" WIDTH="#D_TD_Valid_2#" NOWRAP ALIGN="CENTER"></COL><!---Deviation 2--->
	<COL SPAN="1" WIDTH="#D_TD_Valid_3#" NOWRAP ALIGN="CENTER"></COL><!---Deviation 3--->
	<COL SPAN="1" WIDTH="#D_TD_Valid_4#" NOWRAP ALIGN="CENTER"></COL><!---Deviation 4--->
	<COL SPAN="1" WIDTH="#D_TD_Blank#" NOWRAP></COL><!---Blank--->
	<CFIF Exptd_BB_Diff_Show>  <!--- Dev Note: KAL; 6311 --->
		<COL SPAN="3" WIDTH="#D_TD_Rates#" NOWRAP></COL><!---Exptd --->
	</CFIF>
	<CFIF NOT Deviation_Show_Expected_Values>
		<COL SPAN="1" WIDTH="#D_TD_Dev_Dollar#" NOWRAP ALIGN="RIGHT"></COL><!---Deviation $--->
		<COL SPAN="1" WIDTH="#D_TD_Dev_Percent#" NOWRAP ALIGN="RIGHT"></COL><!---Deviation %--->
	<CFELSE>
		<COL SPAN="1" WIDTH="#D_TD_BB_VALUE#" NOWRAP ALIGN="LEFT"></COL><!--- BB Value --->
		<COL SPAN="1" WIDTH="#D_TD_EX_VALUE#" NOWRAP ALIGN="LEFT"></COL><!--- Ex Value --->
		<COL SPAN="1" WIDTH="#D_TD_N_VALUE#" NOWRAP ALIGN="LEFT"></COL><!--- None --->
	</CFIF>
	<!------ for showCountNoCount ----->
	<cfif showCountNoCount>
	<COL SPAN="1" WIDTH="#D_TD_Count_No_Count#" NOWRAP ALIGN="CENTER"></COL><!--- Count No Count --->
	</cfif>

	<tr><td>&nbsp;</td></tr>

	<cfif NOT Deviation_Show_Expected_Values> <!--- deviation display ----->
    	<TR>
			<TD CLASS="Table_Header" ROWSPAN="2" ID="oTd_Next_Prev_Button_Place_Holder">&nbsp;</TD>
			<TD CLASS="Table_Header" ROWSPAN="2">&nbsp;</TD>
			<TD CLASS="Table_Header" ROWSPAN="2">&nbsp;</TD>
			<TD CLASS="Table_Header" ROWSPAN="2">&nbsp;</TD>
			<CFIF SHOW_IMAGE EQ 1>
			<TD CLASS="Table_Header" COLSPAN="4" ALIGN="CENTER" STYLE="border-bottom:2px solid navy">Validation</TD>
			</CFIF>
			<TD CLASS="Table_Header">&nbsp;</TD>
			<CFIF Exptd_BB_Diff_Show> <!--- Dev Note: KAL; 6311 : Notice the rowspan = 2 --->
				<TD CLASS="Table_Header" ALIGN="CENTER" rowspan="2" STYLE="font-size: 10px">Exptd <BR>Rate</TD>
				<TD CLASS="Table_Header" ALIGN="CENTER" rowspan="2" STYLE="font-size: 10px">Reqtd <BR>Rate</TD>
				<TD CLASS="Table_Header" ALIGN="CENTER" rowspan="2" STYLE="font-size: 10px">Rate <BR>Diff
				<CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>Rate deviation is calculated with a greater precision than the display � for example, four red zeroes indicate that the claim rate does not match the expected rate at that higher precision.</center>
				</CF_SmallHelp>
				&nbsp;</TD>
			</CFIF>
			<TD CLASS="Table_Header" COLSPAN="2" ALIGN="CENTER" STYLE="border-bottom:2px solid navy">#appSettings.getDeviationLabel()#</TD>
			<!------ for showCountNoCount ----->
			<cfif showCountNoCount>
			<TD CLASS="Table_Header" ALIGN="LEFT">Count</TD>
			</cfif>
		</TR>
	<cfelse> <!--- make decision display ---->
		<tr><td>&nbsp;</td></tr>
		<TR>
			<TD CLASS="Table_Header" rowspan="2" colspan="3" ID="oTd_Next_Prev_Button_Place_Holder">&nbsp;<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></TD><!---Program--->
			<TD CLASS="Table_Header" colspan="4" align="center" STYLE="border-bottom:2px solid navy">&nbsp;Validation</TD><!---Product--->
		</TR>
	</cfif>

	<TR>
		<CFIF SHOW_IMAGE EQ 1>
		<TD CLASS="Table_Header" ALIGN="CENTER" STYLE="font-size: 10px">Date</TD>
		<TD CLASS="Table_Header" ALIGN="CENTER" STYLE="font-size: 10px">Auth</TD>
		<TD CLASS="Table_Header" ALIGN="CENTER" STYLE="font-size: 10px">Rate</TD>
		<TD CLASS="Table_Header" ALIGN="CENTER" STYLE="font-size: 10px">Volume</TD>
		</CFIF>
		<TD CLASS="Table_Header">&nbsp;</TD>
		<CFIF NOT Deviation_Show_Expected_Values>
			<TD CLASS="Table_Header"><DIV ID="Total_BB_Deviation" STYLE="display: inline;color:Red; font-size: 10px">$</DIV></TD>
			<TD CLASS="Table_Header"><DIV ID="Total_BB_Deviation_Percent" STYLE="display: inline;color:Red; font-size: 10px">%</DIV></TD>
		</CFIF>
		<!------ for showCountNoCount ----->
		<cfif showCountNoCount>
		<TD CLASS="Table_Header" ALIGN="CENTER">&nbsp;</TD>
		</cfif>
		<!----<TD CLASS="Table_Header">&nbsp;</TD>---->
	</TR>

</CFOUTPUT>
			<CFIF Get_Program_Products.RecordCount GT 0>
				<CFOUTPUT QUERY="Get_Program_Products" GROUP="Billback_Program_ID">
					<cfif showCountNoCount>
						<CFSET Repalced_BB_Program_ID = REPLACE(Billback_Program_ID,"-","_","All")>
						<INPUT TYPE="hidden" NAME="BillBack_Program_ID_List" VALUE="#Repalced_BB_Program_ID#">
					</cfif>
					<TR ID="Program_TR_NO_Colapse" HEIGHT="25" CLASS="programTD">
						<CFIF Deviation_Show_Expected_Values>
						<TD COLSPAN="8">
						<CFELSE>
						<TD COLSPAN="#Evaluate("#D_TD_LEN#")#" ALIGN="LEFT">
						</CFIF>
						[#Get_Program_Products.Program_Number#] #Get_Program_Products.Program_Title#
						&nbsp;

						<CF_CRYP type="en" string="#Get_Program_Products.Program_ID#" key="#request.key#" return="Enc">
						<CFSET EncryptedCID = Enc.value>
						<A  HREF="##" onClick="NewWindow('/scorecard/program_display.cfm?display_program=1&CID=#EncryptedCID#' ,'CurrentProgram','800','600','Yes', 'No'); return false;"><span style="font-size:10px;">Current Program</span></A>
						&nbsp;
						<A  HREF="##" onClick="window.open('/common_files/contracts/contract_revision_history.cfm?Contract_number=<cfoutput>#Get_Program_Products.Program_Number#</cfoutput>&CID=#EncryptedCID#','RevisionHistory','width=1300,height=600,left=0,scrollbars=yes,resizable=no'); return false;"><span style="font-size:10px;">Program Revision History</span></A>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
						<CFIF SHOW_PROGRAM_DATE_MISMATCH EQ 1 AND SHOW_IMAGE EQ 1>
						<A CLASS="<CFIF Dates_Not_Match GT 0>NoValidDesc<CFELSE>YesValidDesc</CFIF>" HREF="Deviation_Program_Date_Mismatch.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">Date Match</A>
						</CFIF>

						<CFIF SHOW_IMAGE EQ 1>
							<CFSET PGM_Unauthorized_Payee = 0>
							<CFSET PGM_Not_Found = 0>
							<CFIF (SHOW_PROGRAM_UN_AUTH_PAYEE EQ 1) AND (Unauthorized_Payee NEQ "")>
								<CFIF Unauthorized_Payee GT 0>
									<CFSET PGM_Unauthorized_Payee = 1>
								</CFIF>
							</CFIF>
							<CFIF (SHOW_PROGRAM_PNF EQ 1) AND (Program_Not_Found NEQ "")>
								<CFIF Program_Not_Found GT 0>
									<CFSET PGM_Not_Found = 1>
								</CFIF>
							</CFIF>

							<CFSET displayString = "">
							<CFIF PGM_Unauthorized_Payee>
								<CFSET displayString = ListAppend(displayString, "Unauthorized Payee", ",")>
							</CFIF>
							<CFIF PGM_Not_Found>
								<CFSET displayString = ListAppend(displayString, "Program Not Found", ",")>
							</CFIF>
							<CFIF PGM_Unauthorized_Payee OR PGM_Not_Found>
								<IMG SRC="/Images/Deviations/stop.gif" TITLE="#ListChangeDelims(displayString, "#chr(13)#", ",")#" ALIGN="absmiddle">
							</CFIF>
							<FONT COLOR="Red">
							<CFIF PGM_Unauthorized_Payee AND SHOW_IMAGE EQ 1>
							<A CLASS="NoValidDesc" HREF="Authorized_Payee_List.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">UnAuthorized Payee</A>
							</CFIF>
							<CFIF PGM_Unauthorized_Payee AND PGM_Not_Found>
							&nbsp;|&nbsp;
							</CFIF>
							<CFIF PGM_Not_Found>
							Program Not Found
							</CFIF>
							</FONT>
						</CFIF>
						</TD>
						<CFIF Deviation_Show_Expected_Values>
							<TD>
							<A HREF="javaScript:void(0);" onClick="javaScript: Auto_Select_Program(this,0);" TITLE="click here to select all"><IMG SRC="/Images/Deviations/select_all.gif" BORDER="0" ALIGN="absmiddle" TITLE="click here to select all">&nbsp;Billback</A>
							</TD>
							<TD>
							<A HREF="javaScript:void(0);" onClick="javaScript: Auto_Select_Program(this,1);" TITLE="click here to select all"><IMG SRC="/Images/Deviations/select_all.gif" BORDER="0" ALIGN="absmiddle" TITLE="click here to select all">&nbsp;Expected</A>
							</TD>
							<TD>
							<A HREF="javaScript:void(0);" onClick="javaScript: Auto_Select_Program(this,2);" TITLE="click here to select all"><IMG SRC="/Images/Deviations/select_all.gif" BORDER="0" ALIGN="absmiddle" TITLE="click here to select all">&nbsp;None</A>
							</TD>
							<TD>
							<A HREF="javaScript:void(0);" onClick="javaScript: Auto_Select_Program(this,3);" TITLE="click here to select all"><IMG SRC="/Images/Deviations/select_all.gif" BORDER="0" ALIGN="absmiddle" TITLE="click here to select all">&nbsp;Manual</A>
							</TD>
						</CFIF>
						<!-----
						<TD CLASS="programTD" OnClick="javaScript: Open_Close(this);" STYLE="CURSOR:pointer" NOWRAP><IMG SRC="/Images/up_1.gif" ID="IMG_CLOSE"><IMG SRC="/Images/down_1.gif" ID="IMG_OPEN" STYLE="DISPLAY:NONE;"></TD>
						------>
						<!------ for showCountNoCount ----->
						<cfif showCountNoCount>
						<TD colspan="1">&nbsp;</TD>
						</cfif>
					</TR>

					<!------ Start Lumpsum ---------------->
					<CFQUERY DBTYPE="query" NAME="This_Program_lumpsum">
					SELECT	*
					FROM	Get_Program_Lumpsum
					WHERE
							Billback_Program_ID = '#Billback_Program_ID#'
					</CFQUERY>



					<CFIF This_Program_lumpsum.recordCount GT 0>
						<TR CLASS="lumpsumInTR">
							<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
							<TD CLASS="lumpsumTD" COLSPAN="2" HEIGHT="20">#Application.LumpsumLabel#s</TD>
							<CFIF NOT Deviation_Show_Expected_Values>
								<TD CLASS="lumpsumTD">#DollarFormat(This_Program_lumpsum.Total_Program_Lumpsum_Amount)#</TD>
							</CFIF>
							<CFIF SHOW_IMAGE EQ 1>
							<TD CLASS="lumpsumTD">&nbsp;</TD>
							<TD CLASS="lumpsumTD">&nbsp;</TD>
							</CFIF>
							<CFIF (SHOW_LUMPSUM EQ 1) AND This_Program_lumpsum.Lumpsum_Deviation NEQ "">
								<CFIF This_Program_lumpsum.Lumpsum_Deviation GT 0>
									<CFIF SHOW_IMAGE EQ 1>
									<TD CLASS="lumpsumTD">
									<A CLASS="NoValidDesc" HREF="Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">#show_No#</A>
									</TD>
									</CFIF>
									<CFSET Lumpsum_Deviation_Amount = This_Program_lumpsum.Lumpsum_Deviation>
									<CFSET Lumpsum_Deviation_Percent = This_Program_lumpsum.Lumpsum_Deviation_Percent>
								<CFELSE>
									<CFIF SHOW_IMAGE EQ 1>
									<TD CLASS="lumpsumTD">
									<A CLASS="YesValidDesc" HREF="Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">#show_Yes#</A>
									</TD>
									</CFIF>
									<CFSET Lumpsum_Deviation_Amount = "">
									<CFSET Lumpsum_Deviation_Percent = 0>
								</CFIF>
							<CFELSE>
								<CFIF SHOW_IMAGE EQ 1>
									<TD CLASS="lumpsumTD">
									<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
									<A CLASS="YesValidDesc" HREF="Deviation_Lumpsum.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">
									</CFIF>
									#show_Question#
									<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
									</A>
									</TD></CFIF>

								</CFIF>
								<CFSET Lumpsum_Deviation_Amount = "">
								<CFSET Lumpsum_Deviation_Percent = 0>
							</CFIF>
							<CFIF SHOW_IMAGE EQ 1>
							<TD>&nbsp;</TD>
							</CFIF>

							<CFIF NOT Deviation_Show_Expected_Values>
								<TD>&nbsp;</TD>
								<CFIF Exptd_BB_Diff_Show>  <!--- Dev Note: KAL; 6311 --->
									<CFSET BB_EXPTD_DIFF = Get_Program_Lumpsum.Billback - Get_Program_Lumpsum.Expected>
									<TD CLASS="YesValidDesc" ALIGN="RIGHT" NOWRAP><nobr>#NumberFormat(Get_Program_Lumpsum.Expected, format3Decimal)#</nobr></TD>
									<TD CLASS="YesValidDesc" ALIGN="RIGHT" NOWRAP><nobr>#NumberFormat(Get_Program_Lumpsum.Billback, format3Decimal)#</nobr>&nbsp;</TD>
									<TD ALIGN="RIGHT" NOWRAP STYLE="border: 1px solid #IIf(BB_EXPTD_DIFF GT 0, DE("red"), DE("green"))#; color:#IIf(BB_EXPTD_DIFF GT 0, DE("red"), DE("green"))#;"><nobr>#NumberFormat(BB_EXPTD_DIFF, '+' & format3Decimal)#</nobr></TD>
								</CFIF>
								<CFIF Lumpsum_Deviation_Percent EQ 0>
									<TD>&nbsp;</TD>
									<TD>&nbsp;</TD>
								<CFELSE>
									<TD CLASS="NoValidDesc" align="right">#DollarFormat(Lumpsum_Deviation_Amount)#</TD>
									<TD CLASS="NoValidDesc" align="right">#NumberFormat(Lumpsum_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
									<CFSET Total_Billback_Deviation = Total_Billback_Deviation + Lumpsum_Deviation_Amount>
								</CFIF>
							<CFELSE>
								<CFSET Input_Name = "TLS_#Replace(Billback_Program_ID, "-","_", "all")#">
								<TD><SPAN ID="SP_#Input_Name#"></SPAN></TD>


								<CFQUERY DBTYPE="query" NAME="This_Billback_lumpsum">
								SELECT	*
								FROM	Get_Billback_Lumpsum
								WHERE
										Billback_Program_ID = '#Billback_Program_ID#'
								</CFQUERY>

								<CFQUERY DBTYPE="query" NAME="This_Billback_lumpsum_Sum">
								SELECT	SUM(BB_Lumpsum_Amount) AS BB_Lump_Total
								FROM	Get_Billback_Lumpsum
								WHERE
										Billback_Program_ID = '#Billback_Program_ID#'
								</CFQUERY>


								<CFSET Billback_LS_Name_List = Replace(ValueList(This_Billback_lumpsum.Billback_Program_Lumpsum_Component_ID), "-", "_", "ALL")>

								<cfset E_Amount_Total = E_Amount_Total + This_Program_lumpsum.Expected>
								<cfset BB_Amount_Total = BB_Amount_Total + This_Program_lumpsum.Billback>
								<cfset Lumpsum_Approved = This_Program_lumpsum.Approved />
								<CFIF Lumpsum_Approved EQ "">
									<CFSET Lumpsum_Approved = This_Program_lumpsum.Expected />
								</CFIF>
								<CFIF Lumpsum_Approved NEQ "">
									<CFSET Previously_Approved_Total_For_JavaScript = Previously_Approved_Total_For_JavaScript + Lumpsum_Approved>
								</CFIF>

								<TD>
								<CFSET CHECK_ALL_LUMP=0>
								<INPUT blump="0" TYPE="RADIO" onClick="javaScript:adjust_Tally_Lump(this);" onPropertyChange="javaScript: setCheckAll('#Billback_LS_Name_List#', this, 'B');" name="#Input_Name#" value="None"
								<cfif Lumpsum_Approved EQ This_Billback_lumpsum_Sum.BB_Lump_Total AND Lumpsum_Approved NEQ This_Program_lumpsum.Expected AND Lumpsum_Approved NEQ 0><CFSET CHECK_ALL_LUMP=1> subtractLump="1" checked
								<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + This_Billback_lumpsum_Sum.BB_Lump_Total>
								<cfelse> subtractLump="0"</cfif>>Billback
								</TD>
								<TD>
								<INPUT blump="#This_Program_lumpsum.Expected#" TYPE="RADIO" onClick="javaScript:adjust_Tally_Lump(this);" name="#Input_Name#" value="E"
								<cfif Lumpsum_Approved EQ This_Program_lumpsum.Expected AND Lumpsum_Approved NEQ 0> subtractLump="1" checked
								<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + This_Program_lumpsum.Expected>
								<cfelse> subtractLump="0"</cfif>>#LSCurrencyFormat(This_Program_lumpsum.Expected)#
								</TD>
								<TD>
								<INPUT blump="0" TYPE="RADIO" onClick="javaScript:adjust_Tally_Lump(this);" name="#Input_Name#" value="None"
								<cfif Lumpsum_Approved EQ 0> subtractLump="1" checked<cfelse> subtractLump="0"</cfif>>
								</TD>
								<TD><INPUT bManual="1" lsNameList="#Billback_LS_Name_List#" blump="0" TYPE="RADIO" onClick="javaScript:adjust_Tally_Lump(this);" onPropertyChange="javaScript: setCheckAll('#Billback_LS_Name_List#', this, 'M');" name="#Input_Name#" value="M"
								<cfif Lumpsum_Approved EQ This_Program_lumpsum.Manual AND Lumpsum_Approved NEQ 0> subtractLump="1" checked<cfelse> subtractLump="0"</cfif>></TD>
							</CFIF>
							<!------ for showCountNoCount ----->
							<cfif showCountNoCount>
							<TD>&nbsp;</TD>
							</cfif>
						<CFIF Deviation_Show_Expected_Values>
							<CFLOOP QUERY="This_Billback_lumpsum">
							<CFSET Input_Name2 = "LS_#Replace(This_Billback_lumpsum.Billback_Program_Lumpsum_Component_ID, "-","_", "all")#">
							<CFSET MU_Input_Name2 = "MU_LS_#Replace(This_Billback_lumpsum.Billback_Program_Lumpsum_Component_ID, "-","_", "all")#">
							<TR CLASS="lumpsumInTR">
								<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
								<TD COLSPAN="1"></TD>
								<TD COLSPAN="6">#This_Billback_lumpsum.Component_Name#</TD>
								<TD>
								<INPUT NAME="#Input_Name2#"
								<CFIF CHECK_ALL_LUMP EQ 1> bLumpOldValue="#This_Billback_lumpsum.BB_Lumpsum_Amount#" bLumpAdded="1" checked<CFELSE>bLumpOldValue="0" disabled bLumpAdded="0"</CFIF> onPropertyChange="javaScript:adjust_Tally_BB_Lump(this);" value="#This_Billback_lumpsum.BB_Lumpsum_Amount#" TYPE="CHECKBOX">
								#LSCurrencyFormat(This_Billback_lumpsum.BB_Lumpsum_Amount)#
								</TD>
								<TD></TD>
								<TD>&nbsp;

								</TD>

								<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									$<INPUT TYPE="Text" NAME="#MU_Input_Name2#" SIZE="5" onKeyUp="clenseText(this, '0123456789.')"
									onPropertyChange="javaScript:adjust_Tally_BB_Lump(this);"
									<cfif Lumpsum_Approved EQ This_Program_lumpsum.Manual AND Lumpsum_Approved NEQ 0 AND This_Program_lumpsum.Manual NEQ 0>
									<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + Val(Manual_Lumpsum_Amount)>
									VALUE="#Manual_Lumpsum_Amount#" bLumpAdded="1" bLumpOldValue="#Manual_Lumpsum_Amount#"
									<CFELSE> bLumpAdded="0" bLumpOldValue="0" DISABLED STYLE="background-color:cccccc;"</cfif>>
								</TD>
							</TR>
							</CFLOOP>
						</CFIF>
					</CFIF>


					<!---------- Start Growth Get_Program_Growth --------->
					<CFQUERY DBTYPE="query" NAME="This_Program_Growth">
					SELECT	*
					FROM	Get_Program_Growth
					WHERE
							Billback_Program_ID = '#Billback_Program_ID#'
					</CFQUERY>
					<CFIF This_Program_Growth.recordCount GT 0>
						<TR CLASS="growthInTR">
							<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
							<TD CLASS="growthTD" COLSPAN="2" HEIGHT="20">Growth</TD>
							<CFIF NOT Deviation_Show_Expected_Values>
								<TD CLASS="growthTD">#DollarFormat(This_Program_Growth.Total_Growth)#</TD>
							</CFIF>
							<CFIF SHOW_IMAGE EQ 1>
							<TD CLASS="growthTD">&nbsp;</TD>
							<TD CLASS="growthTD">&nbsp;</TD>
							</CFIF>
							<CFSET Growth_Deviation_Amount = 0>
							<CFSET Growth_Deviation_Percent = 0>
							<CFIF (SHOW_GROWTH EQ 1) AND This_Program_Growth.Growth_Deviation NEQ "">
								<CFSET Growth_Deviation_Amount = RoundToDecimalPlaces(This_Program_Growth.Growth_Deviation, DEVIATION_ROUND_TO_DECIMAL_PLACES_TO_CHECK_VALIDATION)>
								<CFSET Growth_Deviation_Percent = This_Program_Growth.Growth_Deviation_Percent>

								<CFIF Growth_Deviation_Amount GT 0>
									<CFIF SHOW_IMAGE EQ 1>
									<TD CLASS="NoValidDesc">
									<A CLASS="NoValidDesc" HREF="Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);" TITLE="#NumberFormat(Growth_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%">#show_No#</A>
									</TD>
									</CFIF>
								<CFELSE>
									<CFIF SHOW_IMAGE EQ 1>
									<TD CLASS="YesValidDesc">
									<A CLASS="YesValidDesc" HREF="Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">#show_Yes#</A>
									</TD>
									</CFIF>
								</CFIF>
							<CFELSE>
								<CFIF SHOW_IMAGE EQ 1>
									<TD CLASS="growthTD">
									<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
									<A CLASS="YesValidDesc" HREF="Deviation_Growth_New.cfm?Billback_Program_ID=#Billback_Program_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">
									</CFIF>
									#show_Question#
									<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
									</A>
									</TD></CFIF>

								</CFIF>
								<CFSET Growth_Deviation_Amount = 0>
								<CFSET Growth_Deviation_Percent = 0>
							</CFIF>
							<CFIF SHOW_IMAGE EQ 1>
							<TD CLASS="growthTD">&nbsp;</TD>
							</CFIF>

							<CFIF NOT Deviation_Show_Expected_Values>
								<TD CLASS="growthTD">&nbsp;</TD>
								<CFIF Exptd_BB_Diff_Show>  <!--- Dev Note: KAL; 6311 --->
									<CFSET BB_EXPTD_DIFF = Get_Program_Growth.BB_Growth_Amount - Get_Program_Growth.Expected_Amount>
									<TD CLASS="YesValidDesc" ALIGN="RIGHT" NOWRAP><nobr>#NumberFormat(Get_Program_Growth.Expected_Amount, format3Decimal)#</nobr></TD>
									<TD CLASS="YesValidDesc" ALIGN="RIGHT" NOWRAP><nobr>#NumberFormat(Get_Program_Growth.BB_Growth_Amount, format3Decimal)#</nobr>&nbsp;</TD>
									<TD ALIGN="RIGHT" NOWRAP STYLE="border: 1px solid #IIf(BB_EXPTD_DIFF GT 0, DE("red"), DE("green"))#; color:#IIf(BB_EXPTD_DIFF GT 0, DE("red"), DE("green"))#;">#NumberFormat(BB_EXPTD_DIFF, '+' & format3Decimal)#</TD>
								</CFIF>
								<CFIF Growth_Deviation_Amount EQ 0>
									<TD CLASS="growthTD">&nbsp;</TD>
									<TD CLASS="growthTD">&nbsp;</TD>
								<CFELSE>
									<TD CLASS="NoValidDesc" align="right">#DollarFormat(Growth_Deviation_Amount)#</TD>
									<TD CLASS="NoValidDesc" align="right">#NumberFormat(Growth_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</TD>
									<CFSET Total_Billback_Deviation = Total_Billback_Deviation + Growth_Deviation_Amount>
								</CFIF>
							<CFELSE>

								<CFSET Input_Name = "GR_#Replace(Billback_Program_ID, "-","_", "all")#">
								<TD><SPAN ID="SP_#Input_Name#"></SPAN></TD>

								<cfset E_Amount_Total = E_Amount_Total + This_Program_Growth.Expected_Amount>
								<cfset BB_Amount_Total = BB_Amount_Total + This_Program_Growth.BB_Growth_Amount>
								<CFSET Growth_Approved_Amount = This_Program_Growth.BB_Approved_Amount />
								<CFIF Growth_Approved_Amount EQ "">
									<CFSET Growth_Approved_Amount = This_Program_Growth.Expected_Amount />
								</CFIF>
								<CFIF Growth_Approved_Amount NEQ "">
									<CFSET Previously_Approved_Total_For_JavaScript = Previously_Approved_Total_For_JavaScript + Growth_Approved_Amount>
								</CFIF>

								<TD>
								<input bgrowth="#This_Program_Growth.BB_Growth_Amount#" onClick="javaScript:adjust_Tally_Growth(this);" type="radio" name="#Input_Name#" value="Billback_Growth"
								<cfif This_Program_Growth.BB_Growth_Amount EQ Growth_Approved_Amount AND Growth_Approved_Amount NEQ This_Program_Growth.Expected_Amount AND Growth_Approved_Amount NEQ 0> subtractGrowth="1" checked
								<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + This_Program_Growth.BB_Growth_Amount>
								<cfelse> subtractGrowth="0"</cfif>>
								#LSCurrencyFormat(This_Program_Growth.BB_Growth_Amount)#
								</TD>
								<TD>
								<input bgrowth="#This_Program_Growth.Expected_Amount#" onClick="javaScript:adjust_Tally_Growth(this);" type="radio" name="#Input_Name#" value="Expected_Growth"
								<cfif This_Program_Growth.Expected_Amount EQ Growth_Approved_Amount AND Growth_Approved_Amount NEQ 0> subtractGrowth="1" checked
								<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + This_Program_Growth.Expected_Amount>
								<cfelse> subtractGrowth="0"</cfif>>
								#LSCurrencyFormat(This_Program_Growth.Expected_Amount)#
								</TD>
								<TD>
								<input bgrowth="0" onClick="javaScript:adjust_Tally_Growth(this);" type="radio" name="#Input_Name#" value="None"
								<cfif Growth_Approved_Amount EQ 0> subtractGrowth="1" checked<cfelse> subtractGrowth="0"</cfif>>
								</TD>
								<TD>
									<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
										<TR>
											<TD>
											<input bgrowth="0" bNextField="MU_#Input_Name#" onClick="javaScript:adjust_Tally_Growth(this);" ONPROPERTYCHANGE="javascript:enableDisableInput('#Input_Name#',this)" type="radio" name="#Input_Name#" value="Manual_Growth"
											<CFIF This_Program_Growth.Manual_Growth_Amount EQ Growth_Approved_Amount AND Growth_Approved_Amount NEQ 0>CHECKED subtractGrowth="1" subtractGrowthValue="#Growth_Approved_Amount#" <CFELSE> subtractGrowth="0" subtractGrowthValue="" </CFIF>></TD>
											<TD>$
											<INPUT TYPE="Text" NAME="MU_#Input_Name#"
											<CFIF This_Program_Growth.Manual_Growth_Amount EQ Growth_Approved_Amount AND Growth_Approved_Amount NEQ 0>VALUE="#Growth_Approved_Amount#"
											<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + Growth_Approved_Amount>
											<CFELSE>DISABLED style="background-color:cccccc;"</CFIF>
											SIZE="5"  onKeyUp="clenseText(this, '0123456789.')"
											onChange="javaScript:adjust_Tally_Growth(document.all.#Input_Name#[document.all.#Input_Name#.length-1]);"
											></TD>
										</TR>
									</TABLE>
								</TD>
							</CFIF>
							<!------ for showCountNoCount ----->
							<cfif showCountNoCount>
							<TD>&nbsp;</TD>
							</cfif>
						</TR>
					</CFIF>
					<!---------- Start Products --------------->
					<cfset variables.showdist = 0>
					<cfset variables.dist = "">
				<CFIF Billback_Product_ID NEQ "">
					<CFOUTPUT GROUP="Billback_Product_ID">
						<cfif showCountNoCount and BSA_Foodservice_Items_Master_ID neq "">
							<CFINCLUDE TEMPLATE="count_Dont_Count_Inc.cfm">
						</cfif>

					<cfif variables.dist neq Get_Program_Products.Dist_id>
						<cfset variables.showdist = 1>
						<cfset variables.dist = Get_Program_Products.Dist_id>
					</cfif>
					<cfif variables.showdist eq 1><cfset variables.showdist = 0>
						<TR>
							<TD COLSPAN="100%" BGCOLOR="8B0000" style="border-top: 1px solid Black;"><!---EAFFEA--->
								<span style="color:white;">#Get_Program_Products.name#&nbsp;<CFIF Len(Trim(Get_Program_Products.shr_ship_to)) GT 0>(#Get_Program_Products.shr_ship_to#)<CFELSEIF Len(Trim(Get_Program_Products.ship_to)) GT 0>(#Get_Program_Products.ship_to#)<cfelse>No #application.returned_customer_setting.distributor_label_singular#</CFIF></span>
							</TD>
						</TR>
					</cfif>
						<TR CLASS="productTR">
							<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
							<CFIF NOT Deviation_Show_Expected_Values>
							<TD COLSPAN="4">#Get_Program_Products.Item_Number# #Left(Get_Program_Products.Description, 30)# <B>#Get_Program_Products.BB_Product_Quantity# #Abbreviation#</B></TD>
							<CFELSE>
							<TD COLSPAN="3">#Get_Program_Products.Item_Number# #Left(Get_Program_Products.Description, 30)# </TD>
							</CFIF>
							<CFIF NOT Deviation_Show_Expected_Values>
								<!--- <TD>&nbsp;</TD> --->
								<TD COLSPAN="#Evaluate("#D_TD_LEN#-5")#">&nbsp;</TD>
							<CFELSE>
								<TD COLSPAN="3" CLASS="productTD">&nbsp;</TD>
								<CFSET Input_Name = "BB_#Replace(BB_Item_Final_ID, "-","_", "all")#">
								<TD><SPAN ID="SP_#Input_Name#"></SPAN></TD>
								<CFSET Approved_Volume_JS = 0>
								<cfset Item_Volume_Approved = Q_Item_Volume_Approved />
								<cfif Item_Volume_Approved EQ "">
									<cfset Item_Volume_Approved = Item_E_Volume />
								</cfif>
								<TD>
								<input bvolume="#Item_BB_Volume#" onClick="javaScript:adjust_Tally_volume(this);" type="radio" name="#Input_Name#" value="Item_BB_Volume"
								<cfif Item_BB_Volume EQ Item_Volume_Approved AND Item_Volume_Approved NEQ 0> subtractVolume="1" checked
								<CFSET Approved_Volume_JS = Item_BB_Volume><cfelse> subtractVolume="0"
								</cfif>>
								#NumberFormat(Item_BB_Volume, '___,___,___,___.__')# #Abbreviation#
								</TD>
								<TD>
								<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNoCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0  OR Associated_Ship_TO neq "">
									<CFSET Expected_Volume = Item_E_Volume>
									<input bvolume="#Expected_Volume#" onClick="javaScript:adjust_Tally_volume(this);" type="radio" name="#Input_Name#" value="Item_E_Volume"
									<cfif Item_E_Volume EQ Item_Volume_Approved AND Item_Volume_Approved NEQ 0> subtractVolume="1" checked
									<CFSET Approved_Volume_JS = Item_E_Volume><cfelse> subtractVolume="0"
									</cfif>>
									#NumberFormat(Item_E_Volume, '___,___,___,___.__')# #Abbreviation#
								<cfelse>
									<CFSET Expected_Volume = Item_BB_Volume>
									&nbsp;
								</CFIF>
								</TD>
								<TD>
								<input bvolume="0" onClick="javaScript:adjust_Tally_volume(this);" type="radio" name="#Input_Name#" value="None"
								<cfif Item_Volume_Approved EQ 0> subtractVolume="1" checked
								<CFSET Approved_Volume_JS = 0><cfelse> subtractVolume="0"
								</cfif>>
								</TD>
								<TD>
									<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
										<TR>
											<TD>
											<input bvolume="0" bNextField="MU_#Input_Name#" onClick="javaScript:adjust_Tally_volume(this);" ONPROPERTYCHANGE="javascript:enableDisableInput('#Input_Name#',this)" type="radio" name="#Input_Name#" value="Item_MU_Volume"
											<cfif Item_M_Volume EQ Item_Volume_Approved AND Item_Volume_Approved NEQ 0>CHECKED subtractVolume="1" subtractVolumeValue = "#Item_Volume_Approved#"<cfelse>subtractVolume="0" subtractVolumeValue = ""</cfif>
											>
											</TD>
											<TD>&nbsp;&nbsp;<INPUT TYPE="Text" NAME="MU_#Input_Name#"
											<cfif Item_M_Volume EQ Item_Volume_Approved AND Item_Volume_Approved NEQ 0>VALUE="#Item_Volume_Approved#"
											<CFSET Approved_Volume_JS = Item_Volume_Approved>
											<CFELSE>DISABLED style="background-color:cccccc;" </CFIF>
											 SIZE="5" onChange="javaScript:adjust_Tally_volume(document.all.#Input_Name#[document.all.#Input_Name#.length-1]);" onKeyUp="clenseText(this, '0123456789.')">&nbsp;</TD>
											<TD NOWRAP>#Abbreviation#</TD>
										</TR>
									</TABLE>
								</TD>
							</CFIF>
							<!------ for showCountNoCount ----->
							<cfif showCountNoCount>
									<CFIF CountThisItem EQ 1>
										<CFSET CheckthisBox = "checked">
									<CFELSE>
										<CFSET CheckthisBox = "">
									</CFIF>
								<TD colspan="1" align="center">
									<input type="Checkbox" name="Count_Dont_Count_#Repalced_BB_Program_ID#" value="#Billback_Product_ID#" #CheckthisBox#>
								</TD>
							</cfif>

						</TR>
						<!-----Start Discount Type ------->
						<CFIF BB_Product_Type_ID NEQ "">
							<CFOUTPUT>
								<CFSET Discount_Amount =  BB_Rate>
								<CFSET Total_Deviation_Percent = 0>
								<CFSET Total_Amount_Deviation = 0>
								<CFSET This_Expected_Rate = "">
								<CFSET This_Expected_Volume = "">
								<CFSET NegativeClaimForItem = 0 />
								<CFIF BB_Rate LT 0 OR BB_Product_Quantity LT 0>
										<CFSET NegativeClaimForItem = 0 />
								</CFIF>

								<TR CLASS="productInTR">
									<TD COLSPAN="1" CLASS="programLeft">&nbsp;</TD>
									<TD COLSPAN="1">&nbsp;</TD>
									<TD CLASS="discountTD">
									<CFIF BB_Product_Type_ID EQ 10>
									<FONT COLOR="Red">Claim Adjustment</FONT>
									<CFELSE>
									<CFIF BB_Product_Type_ID LTE ListLen(Discount_Type_List,",")>#Trim(ListGetAt(Discount_Type_List,BB_Product_Type_ID,","))#</CFIF>
									</CFIF>
									<CFIF NOT Deviation_Show_Expected_Values>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<B><CFIF BB_Product_Type_ID EQ 10><FONT COLOR="Red">#DollarFormat(BB_Rate)#</FONT><CFELSE>#DollarFormat(BB_Rate)#</CFIF></B>
									</CFIF>
									</TD>
									<CFIF NOT Deviation_Show_Expected_Values>
										<TD CLASS="discountTD">&nbsp;</TD>
									</CFIF>

									<!---------------- Date Overlap --------------->

									<CFIF (SHOW_DISCOUNT_DATE_OVERLAP EQ 1) AND (Overlap NEQ "") AND (UnKnown_Product LTE 0)>
										<CFIF Overlap GT 0>
											<CFSET Date_Overlap_Percent = (Overlap / BB_Rate) * 100>
											<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="NoValidDesc" ALIGN="CENTER" TITLE="#Date_Overlap_Percent#%">
											<CFIF BB_Product_Type_ID NEQ 10>
											<A CLASS="NoValidDesc" HREF="Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_No#</A>
											</CFIF>
											</TD>
											</CFIF>
										<CFELSE>
											<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="YesValidDesc" ALIGN="CENTER">
											<CFIF BB_Product_Type_ID NEQ 10>
											<A CLASS="YesValidDesc" HREF="Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_Yes#</A>
											</CFIF>
											</TD>
											</CFIF>
											<CFSET Date_Overlap_Percent = 0>
										</CFIF>
									<CFELSE>
										<CFIF SHOW_IMAGE EQ 1>
											<CFIF UnKnown_Product GT 0>
												<CFIF BB_Product_Type_ID NEQ 10>
												<TD CLASS="NotprocessedValidDesc" ALIGN="CENTER">#show_Nothing#</TD>
												</CFIF>
											<CFELSE>
												<TD CLASS="NotprocessedValidDesc" ALIGN="CENTER">
												<CFIF BB_Product_Type_ID NEQ 10>
												<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
												<A CLASS="YesValidDesc" HREF="Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">
												</CFIF>
												#show_Question#
												<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
												</A>
												</CFIF>
												</TD></CFIF>

											</CFIF>
										</CFIF>
										<CFSET Date_Overlap_Percent = 0>
									</CFIF>

									<!---------------- Authorized Discount Type --------------->
									<CFIF (SHOW_DISCOUNT_UN_AUTH EQ 1) AND (Unauthorized_Product NEQ "")>
										<CFIF Unauthorized_Product GT 0>
											<CFSET UnAuthorized_Dev_Percent = 100>
											<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="NoValidDesc" ALIGN="CENTER" TITLE="#UnAuthorized_Dev_Percent#%">
											<CFIF BB_Product_Type_ID NEQ 10>
											<A CLASS="NoValidDesc" HREF="Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_No#</A>
											</CFIF>
											</TD>
											</CFIF>
										<CFELSE>
											<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="YesValidDesc" ALIGN="CENTER">
											<CFIF BB_Product_Type_ID NEQ 10>
											<A CLASS="YesValidDesc" HREF="Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_Yes#</A>
											</CFIF>
											</TD>
											</CFIF>
											<CFSET UnAuthorized_Dev_Percent = 0>
										</CFIF>
									<CFELSE>
										<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="NotprocessedValidDesc" ALIGN="CENTER">
											<CFIF BB_Product_Type_ID NEQ 10>
												<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
												<A CLASS="YesValidDesc" HREF="Authorized_Product_List.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">
												</CFIF>
												#show_Question#
												<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
												</A>
												</CFIF>
											</TD></CFIF>

										</CFIF>
										<CFSET UnAuthorized_Dev_Percent = 0>
									</CFIF>

									<!---------------- Rate --------------->
									<CFPARAM NAME="Rate_Dev_Percent" 	DEFAULT=0>

									<CFIF (ListLen(SHOW_DISCOUNT_RATE,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_RATE)) AND (Discount_Rate_Deviation NEQ "")>
										<CFSET This_Expected_Rate = Discount_Expected_Rate>
										<CFIF appSettings.getBBExpectedRateGTClaimRate() NEQ 1 AND This_Expected_Rate GT Discount_BB_Rate>
											<CFSET This_Expected_Rate = Discount_BB_Rate>
										</CFIF>
										<CFIF NegativeClaimForItem EQ 1>
											<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="YesValidDesc" ALIGN="CENTER" TITLE="#appSettings.getDeviationLabel()# not calculated for negative claim">
											<CFIF BB_Product_Type_ID NEQ 10>
											#show_Nothing#
											</CFIF>
											</TD>
											</CFIF>
										<CFELSE>
											<CFIF (Discount_Rate_Deviation NEQ "" AND request.app_general_functions.roundDecimalPlaces(Discount_Rate_Deviation, 4) NEQ 0) OR Get_Program_Products.MANUAL_CANCEL EQ 1>
												<CFSET Discount_Amount_Deviation = Discount_Rate_Deviation * BB_Product_Quantity>
												<CFIF Discount_Amount_Deviation GT BB_Rate>
													<CFSET Discount_Amount_Deviation = BB_Rate>
												</CFIF>

												<CFSET Amount_Deviation = Discount_Amount_Deviation>
												<CFSET Amount_Deviation = Abs(Amount_Deviation)>
												<CFIF IsNumeric(BB_Rate) AND (BB_Rate NEQ "") AND BB_Rate NEQ 0>
													<CFSET Rate_Dev_Percent = (Amount_Deviation/BB_Rate) * 100>
												<CFELSE>
													<CFSET Rate_Dev_Percent = 0>
												</CFIF>
												<CFIF Rate_Dev_Percent GT 100>
													<CFSET Rate_Dev_Percent=100>
												</CFIF>
												<CFSET Rate_Dev_Percent = Abs(Rate_Dev_Percent)>
												<CFIF SHOW_IMAGE EQ 1>
												<TD CLASS="NoValidDesc" ALIGN="CENTER" TITLE="#Rate_Dev_Percent#%">
												<CFIF BB_Product_Type_ID NEQ 10>
												<A CLASS="NoValidDesc" HREF="Deviation_Product_Rate.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_No#</A>
												</CFIF>
												</TD>
												</CFIF>
											<CFELSE>
												<CFIF SHOW_IMAGE EQ 1>
												<TD CLASS="YesValidDesc" ALIGN="CENTER">
												<CFIF BB_Product_Type_ID NEQ 10>
												<A CLASS="YesValidDesc" HREF="Deviation_Product_Rate.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_Yes#</A>
												</CFIF>
												</TD>
												</CFIF>
												<CFSET Rate_Dev_Percent = 0>
											</CFIF>
										</CFIF>
									<CFELSE>
										<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="NotprocessedValidDesc" ALIGN="CENTER">
											<CFIF BB_Product_Type_ID NEQ 10>
											<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
											<A CLASS="YesValidDesc" HREF="Deviation_Product_Rate.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">
											</CFIF>
											#show_Question#
											<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
											</A>
											</CFIF>
											</TD></CFIF>

										</CFIF>
										<CFSET Rate_Dev_Percent = 0>
									</CFIF>

									<!---------------- Volume --------------->
									<CFIF (ListLen(SHOW_DISCOUNT_VOLUME,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_VOLUME)) AND (Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNOCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0  OR Associated_Ship_TO neq "") AND (Discount_Volume_Deviation NEQ "")>
										<CFSET This_Expected_Volume = Discount_Expected_Volume>
										<!----- The app switch Expected rate greater than claimed rate is applicable only for rate and not volume ------->
										<CFIF This_Expected_Volume GT Get_Program_Products.BB_Product_Quantity>
											<CFSET This_Expected_Volume = Get_Program_Products.BB_Product_Quantity>
										</CFIF>
										<CFIF NegativeClaimForItem EQ 1>
											<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="YesValidDesc" ALIGN="CENTER" TITLE="#appSettings.getDeviationLabel()# not calculated for negative claim">
											<CFIF BB_Product_Type_ID NEQ 10>
											#show_Nothing#
											</CFIF>
											</TD>
											</CFIF>
										<CFELSE>
											<CFIF Discount_Volume_Deviation NEQ "" AND Discount_Volume_Deviation NEQ 0>
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
												<CFIF SHOW_IMAGE EQ 1>
												<TD CLASS="NoValidDesc" ALIGN="CENTER" TITLE="#NumberFormat(Volume_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%">
												<CFIF BB_Product_Type_ID NEQ 10>
												<A CLASS="NoValidDesc" HREF="Deviation_Product_Volume.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_No#</A>
												</CFIF>
												</TD>
												</CFIF>
											<CFELSE>
												<CFIF SHOW_IMAGE EQ 1>
												<TD CLASS="YesValidDesc" ALIGN="CENTER">
												<CFIF BB_Product_Type_ID NEQ 10>
												<A CLASS="YesValidDesc" HREF="Deviation_Product_Volume.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">#show_Yes#</A>
												</CFIF>
												</TD>
												</CFIF>
												<CFSET Volume_Deviation_Percent = 0>
											</CFIF>
										</CFIF>
									<CFELSE>
										<CFIF (Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter OR ListFindNOCase(DEVIATION_CONSTANTS_Operator_Deviated, Generic_Type) NEQ 0 OR Associated_Ship_TO neq "")>
											<CFSET show_Status_Image = show_Question>
											<CFIF (ListLen(SHOW_DISCOUNT_VOLUME,",") GT 0) AND (FindNoCase(BB_Product_Type_ID, SHOW_DISCOUNT_VOLUME))>
												<CFSET This_Expected_Volume = Discount_Expected_Volume>
											</CFIF>
										<CFELSE>
											<CFSET show_Status_Image = show_Nothing>
											<CFSET This_Expected_Volume = BB_Product_Quantity>
										</CFIF>
										<CFIF SHOW_IMAGE EQ 1>
											<TD CLASS="NotprocessedValidDesc" ALIGN="CENTER">
											<CFIF BB_Product_Type_ID NEQ 10>
											<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
											<A CLASS="YesValidDesc" HREF="Deviation_Product_Volume.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#" onClick="javaScript: return showThisLinkPopup(this,1);">
											</CFIF>
											#show_Status_Image#
											<CFIF SHOW_LINK_IF_QUESTION_MARK EQ 1>
											</A>
											</CFIF>
											</TD></CFIF>

										</CFIF>
										<CFSET Volume_Deviation_Percent=0>
									</CFIF>



									<CFSET Discount_Amount =  BB_Rate>
									<CFIF This_Expected_Rate NEQ "" AND This_Expected_Volume NEQ "">
										<CFSET Discount_Expected_Amount = This_Expected_Rate * This_Expected_Volume>
										<CFIF Discount_Expected_Amount LT 0>
											<CFSET Discount_Expected_Amount = 0>
										</CFIF>
										<CFSET Total_Amount_Deviation = Discount_Amount - Discount_Expected_Amount>
									<CFELSE>
										<CFIF UnAuthorized_Dev_Percent GT 0>
											<CFSET Total_Deviation_Percent = UnAuthorized_Dev_Percent>
											<CFSET Total_Amount_Deviation = (UnAuthorized_Dev_Percent * Discount_Amount) / 100>
										<CFELSEIF Date_Overlap_Percent GT 0>
											<CFSET Total_Deviation_Percent = Date_Overlap_Percent>
											<CFSET Total_Amount_Deviation = (Date_Overlap_Percent * Discount_Amount) / 100>
										<CFELSEIF Rate_Dev_Percent GT 0>
											<CFSET Total_Deviation_Percent = Rate_Dev_Percent>
											<CFSET Total_Amount_Deviation = (Rate_Dev_Percent * Discount_Amount) / 100>
										<CFELSEIF Volume_Deviation_Percent GT 0>
											<CFSET Total_Deviation_Percent = Volume_Deviation_Percent>
											<CFSET Total_Amount_Deviation = (Volume_Deviation_Percent * Discount_Amount) / 100>
										</CFIF>
									</CFIF>

									<cfif appSettings.getBBExpectedRateGTClaimRate() EQ 0 AND NOT (BB_Rate LT 0 OR BB_Product_Quantity LT 0)>
										<CFIF Total_Amount_Deviation LT 0>
											<CFSET Total_Amount_Deviation = 0>
										</CFIF>
									</cfif>

									<CFSET Total_Deviation_Percent = (Total_Amount_Deviation / Discount_Amount) * 100>


									<CFIF Total_Deviation_Percent NEQ 0>
										<CFSET Use_Class = "NoValidDesc">
									<CFELSE>
										<CFSET Use_Class = "YesValidDesc">
									</CFIF>
									<CFIF Deviation_Show_Expected_Values>
										<CFSET Input_Name = "PR_#Replace(BB_Item_Final_Detail_ID, "-", "_", "all")#">
										<TD><SPAN ID="SP_#Input_Name#"></SPAN></TD>
									<CFELSE>
										<TD>&nbsp;</TD>
									</CFIF>
									<CFIF Exptd_BB_Diff_Show>  <!--- Dev Note: KAL; 6311 --->
										<CFSET BB_EXPTD_DIFF = Val(Discount_BB_Rate) - Val(Discount_Expected_Rate)>
										<TD CLASS="YesValidDesc" ALIGN="RIGHT" NOWRAP><CFIF NegativeClaimForItem EQ 0><nobr>#NumberFormat(Discount_Expected_Rate, format3Decimal)#/#Abbreviation#</nobr><CFELSE>&nbsp;</CFIF></TD>
										<TD CLASS="YesValidDesc" ALIGN="RIGHT" NOWRAP><CFIF NegativeClaimForItem EQ 0><nobr>#NumberFormat(Discount_BB_Rate, format3Decimal)#/#Abbreviation#</nobr><CFELSE>&nbsp;</CFIF>&nbsp;</TD>
										<CFIF NegativeClaimForItem EQ 0>
										<TD ALIGN="RIGHT" NOWRAP STYLE="border: 1px solid #IIf(BB_EXPTD_DIFF GT 0, DE("red"), DE("green"))#; color:#IIf(BB_EXPTD_DIFF GT 0, DE("red"), DE("green"))#;"><nobr>#NumberFormat(BB_EXPTD_DIFF, '+_' & format3Decimal)#</nobr></TD>
										<CFELSE>
										<TD ALIGN="RIGHT" NOWRAP STYLE="border: 1px solid cccccc; color:cccccc;">&nbsp;</TD>
										</CFIF>
									</CFIF>
									<CFIF BB_UP EQ 1>
										<TD CLASS="#Use_Class#"></TD>
										<TD CLASS="#Use_Class#"></TD>
									<CFELSEIF (NOT Deviation_Show_Expected_Values)>
										<TD CLASS="#Use_Class#" ALIGN="right"><CFIF Total_Amount_Deviation GT 0>#DollarFormat(Total_Amount_Deviation)#</span><CFELSEIF Total_Amount_Deviation LT 0><span style="color:##009900">#DollarFormat(Total_Amount_Deviation)#</span><CFELSE>&nbsp;</CFIF></TD>
										<TD CLASS="#Use_Class#" ALIGN="right"><CFIF Total_Amount_Deviation GT 0>#NumberFormat(Total_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%<CFELSEIF Total_Amount_Deviation LT 0><span style="color:##009900">#NumberFormat(Total_Deviation_Percent, DEVIATION_MAIN_PAGE_PERCENT_FORMAT)#%</span><CFELSE>&nbsp;</CFIF></TD>
										<CFSET Total_Billback_Deviation = Total_Billback_Deviation + NumberFormat(Total_Amount_Deviation,'.99')>
									<CFELSE>
										<cfif appSettings.getBBExpectedRateGTClaimRate()>
											<cfset newExpected_Rate = Discount_Expected_Rate />
										<cfelse>
											<cfset newExpected_Rate = Expected_Rate />
										</cfif>

										<cfset E_Amount_Total = E_Amount_Total + (newExpected_Rate * Item_E_Volume)>
										<cfset BB_Amount_Total = BB_Amount_Total + (Billback_Rate * Item_BB_Volume)>

										<CFSET Approved_Rate = Q_Approved_Rate />
										<CFIF Approved_Rate EQ "">
											<CFSET Approved_Rate = newExpected_Rate />
										</CFIF>
										<CFIF Approved_Rate NEQ "" AND Approved_Volume_JS NEQ "">
											<CFSET Previously_Approved_Total_For_JavaScript = Previously_Approved_Total_For_JavaScript + (Approved_Rate * Approved_Volume_JS)>
										</CFIF>
										<TD>
										<input brate="#Billback_rate#" bvolume="#Approved_Volume_JS#" onClick="javaScript:adjust_Tally_rate(this);" type="radio" name="#Input_Name#" value="Billback_Rate"
										<cfif Billback_Rate EQ Approved_Rate AND Expected_Rate NEQ Approved_Rate AND Approved_Rate NEQ 0> subtractRate="1" checked
										<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (Billback_Rate * Approved_Volume_JS)>
										<cfelse> subtractRate="0"
										</cfif>>
										#LSCurrencyFormat(Billback_rate)# / #Abbreviation#
										</TD>
										<TD>


										<input brate="#newExpected_Rate#" bvolume="#Approved_Volume_JS#" onClick="javaScript:adjust_Tally_rate(this);" type="radio" name="#Input_Name#" value="Expected_Rate"
										<cfif newExpected_Rate EQ Approved_Rate AND Approved_Rate NEQ 0> subtractRate="1" checked
										<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (newExpected_Rate * Approved_Volume_JS)>
										<cfelse> subtractRate="0"
										</cfif>>
										 #LSCurrencyFormat(newExpected_Rate)# / #Abbreviation#
										</TD>
										<TD>
										<input brate="0" type="radio" bvolume="#Approved_Volume_JS#" onClick="javaScript:adjust_Tally_rate(this);" name="#Input_Name#" value="None"
										<cfif Approved_Rate EQ 0> subtractRate="1" checked
										<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (0 * Approved_Volume_JS)>
										<cfelse> subtractRate="0"
										</cfif>>
										</TD>
										<TD>
										<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
											<TR>
												<TD>
												<input brate="0" bNextField="MU_#Input_Name#" type="radio" bvolume="#Approved_Volume_JS#" onClick="javaScript:adjust_Tally_rate(this);" ONPROPERTYCHANGE="javascript:enableDisableInput('#Input_Name#',this)" name="#Input_Name#" value="Manual_Rate"
									 			<cfif Manual_Rate EQ Approved_Rate AND Approved_Rate NEQ 0>CHECKED subtractRate="1" subtractRateValue="#Approved_Rate#"<cfelse>subtractRate="0" subtractRateValue=""</cfif>
												>
												</TD>
												<TD>$<INPUT TYPE="TEXT" NAME="MU_#Input_Name#"
												<cfif Manual_Rate EQ Approved_Rate AND Approved_Rate NEQ 0>VALUE="#Approved_Rate#"
												<CFSET Approved_Total_For_JavaScript = Approved_Total_For_JavaScript + (Approved_Rate * Approved_Volume_JS)>
												<CFELSE>DISABLED style="background-color:cccccc;"</CFIF>
												 SIZE="5" onChange="javaScript:adjust_Tally_rate(document.all.#Input_Name#[document.all.#Input_Name#.length-1]);" onKeyUp="clenseText(this, '0123456789.')">&nbsp;</TD>
												<TD NOWRAP> / #Abbreviation#</TD>
											</TR>
										</TABLE>
										</TD>
									</CFIF>
									<!------ for showCountNoCount ----->
									<cfif showCountNoCount>
									<TD>&nbsp;</TD>
									</cfif>
								</TR>
							</CFOUTPUT>
						</CFIF> <!------------- BB_Product_Type_ID NEQ "" ---------->
					</CFOUTPUT>
				</CFIF><!-------  Billback_Product_ID NEQ "" ---------->
				<TR>
					<TD COLSPAN="100%">&nbsp;</TD>
				</TR>
				</CFOUTPUT>
			</CFIF>
				<TR>
					<TD COLSPAN="100%" ID="lastRow"></TD>
				</TR>
		</TD>
	</TR>

	<TR>
		<TD COLSPAN="100%">
		<!----------------- print , email and fax ------------------->
		<CFINCLUDE TEMPLATE="Print_Email_Buttons.cfm">
		</TD>
	</TR>
</TABLE>

<CFIF Total_Billback_Amount NEQ 0>
	<CFSET Total_Billback_Deviation_Percent = (Total_Billback_Deviation / Total_Billback_Amount) * 100>
</CFIF>

<CFIF SHOW_FAX_EMAIL_VERSION EQ 0>
<SCRIPT>
	var oDiv = document.all.oDiv_Deviation_Details;
	<!--- oDiv.style.height = getDetailsDivHeight(); --->


	function getDetailsDivHeight()
	{
		var lastRow = document.all.lastRow;
		var lastRowTop = getTotalOffsetProperty(lastRow, "body", "offsetTop", 0) + 10;

		maxHeight = document.body.clientHeight;
		<CFIF Deviation_Show_Expected_Values>
			maxHeight = maxHeight - 22;
		</CFIF>

		<CFIF Print_Button_Show EQ 1>
			maxHeight = maxHeight - 30;
		</CFIF>


		if(lastRowTop > maxHeight)
		{
			maxHeight = maxHeight;
		}
		else
		{
			maxHeight = lastRowTop;
		}

		<CFIF SHOW_PRINT_VERSION EQ 1>
			maxHeight = lastRowTop;
		</CFIF>

		return (maxHeight - getTotalOffsetProperty(oDiv, "body", "offsetTop", 0) - 5) + "px";

	}


	<CFIF NOT Deviation_Show_Expected_Values>
		place_Next_Prev_Buttons();
		Place_Total_BB_Deviation();
	</CFIF>

	function place_Next_Prev_Buttons()
	{
		var oDiv = document.all.oDiv_Next_Prev_Buttons;
		var oTd = document.all.oTd_Next_Prev_Button_Place_Holder;

		var imgRealLeft = getTotalOffsetProperty(oDiv, "body", "offsetLeft", 0);
		var imgRealTop = getTotalOffsetProperty(oDiv, "body", "offsetTop", 0);

		oDiv.style.position 	= "absolute";
		oDiv.style.left 		= imgRealLeft;
		oDiv.style.top 			= imgRealTop - 5;
	}

	function Place_Total_BB_Deviation()
	{
		var oDiv = document.all.Total_BB_Deviation;
		oDiv.innerText = "<CFOUTPUT>#DollarFormat(Total_Billback_Deviation)#</CFOUTPUT>";
		var oDiv = document.all.Total_BB_Deviation_Percent;
		oDiv.innerText = "<CFOUTPUT>#NumberFormat(Total_Billback_Deviation_Percent,"_.__")#</CFOUTPUT>%";

	}
</SCRIPT>
</CFIF>


<CFIF Deviation_Show_Expected_Values>
	<CFOUTPUT>
		<input type="hidden" name="BBID" value="#Billback_ID#">
		<input type="hidden" name="E_Amount_Total" value="#E_Amount_Total#">
		<input type="hidden" name="Billback_Amount_Total" value="#BB_Amount_Total#">
		<input type="hidden" name="ProcessDetails" value="1">
		<div align="center">
			<span style="font-weight:bold;color:red"> [ </span>
			<a href="##" OnClick="javascript:document.forms[0].submit();return false;" ID="Save_Product_Approval" style="font-weight:bold;">continue</a>
			<span style="font-weight:bold;color:red"> ] </span>
		</div>
	</FORM>
	</CFOUTPUT>
	<cfparam name="ApprovedTotal" 	default=0>

	<div id="floatLayer" style="position: absolute; height:20px; width:340px; left:375px; top:1px; z-index: 100;">
		<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" width="100%">
			<TR>
				<TD WIDTH="100">&nbsp;

				</TD>
				<TD>
				<table border="0" cellspacing="0" cellpadding="2" align="center" id="oTable" width="100%" style="border: 1 solid Navy; background-color: F5F5F5;">
			  	<TR>
					<TD style="font-size:16px;font-weight:bold;color:Red;" align="right" nowrap width="30%">Amount Selected:<SPAN ID="Amount_Selected_To_Pay" STYLE="DISPLAY:NONE;"></SPAN></TD>
					<CFOUTPUT>
					<TD style="font-size:16px;font-weight:bold;color:Red;" nowrap width="70%" ALIGN="right">
					$<SPAN id="Total_Approved_Amount">#NumberFormat(Approved_Total_For_JavaScript, "-_.__")#</SPAN>
					<INPUT TYPE="HIDDEN" ID="Tally_Total_Approved_Amount" NAME="Tally_Total_Approved_Amount" VALUE="#Approved_Total_For_JavaScript#">
					</TD>
					</CFOUTPUT>
				</TR>
			  </table>
				</TD>
			</TR>
		</TABLE>
	 </div>

	<CFIF SHOW_FAX_EMAIL_VERSION EQ 0>
	<script src="/billbacks/common/common_js_functions.js"></script>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	<script language="JavaScript">
		//storeinparent = 0;
		//layerDisplayToggle();
		//storeinparent = 1;

		//floatLayer

		place_floatLayer();


		function place_floatLayer()
		{
			var oDiv = document.all.floatLayer;
			var oTd = document.all.oTd_Next_Prev_Button_Place_Holder;

			var imgRealLeft = getTotalOffsetProperty(oDiv, "body", "offsetLeft", 0);
			var imgRealTop = getTotalOffsetProperty(oDiv, "body", "offsetTop", 0);

			oDiv.style.position 	= "absolute";
			oDiv.style.left 		= imgRealLeft;
			oDiv.style.top 			= imgRealTop;

		}

		function adjust_Tally_BB_Lump(thisObj)
		{
			var lumpOldValue, lumpCurrentValue;
			if(event.propertyName == "checked" || event.propertyName == "disabled" || event.propertyName == "value")
			{
				var DeltaAmount = 0;
				// checkbox
				if((thisObj.type == "checkbox" && thisObj.checked))
				{
					if(thisObj.bLumpAdded == 0)
					{
						DeltaAmount = parseFloat(thisObj.value);
						thisObj.bLumpAdded = 1;
					}

				}
				else if((thisObj.type == "checkbox" && !thisObj.checked))
				{
					if(thisObj.bLumpAdded == 1)
					{
						DeltaAmount = parseFloat(thisObj.value) * -1;
						thisObj.bLumpAdded = 0;
					}

				}
				// textbox enabled
				else if((thisObj.type == "text" && !thisObj.disabled))
				{
					lumpCurrentValue = parseFloat(thisObj.value);
					if(isNaN(lumpCurrentValue))
					{
						lumpCurrentValue = 0;
					}
					lumpOldValue = parseFloat(thisObj.bLumpOldValue);
					if(isNaN(lumpOldValue))
					{
						lumpOldValue = 0;
					}

					DeltaAmount = lumpCurrentValue - lumpOldValue;
					thisObj.bLumpOldValue = lumpCurrentValue;
					thisObj.bLumpAdded = 1;

				}
				// textbox disabled
				else if((thisObj.type == "text" && thisObj.disabled))
				{
					if(thisObj.bLumpAdded == 1)
					{
						DeltaAmount = parseFloat(thisObj.value) * -1;
						thisObj.bLumpAdded = 0;
						thisObj.bLumpOldValue = 0;
					}

				}
				//alert(iType);
				if(isNaN(DeltaAmount))
				{
					DeltaAmount = 0;
				}
				var existing_Amount = parseFloat(document.all.Tally_Total_Approved_Amount.value);

				//var existing_Amount = parseFloat(document.all.Total_Approved_Amount.innerText);
				existing_Amount = existing_Amount + DeltaAmount;

				document.all.Tally_Total_Approved_Amount.value = existing_Amount;

				existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);


				document.all.Total_Approved_Amount.innerText = existing_Amount;

				event.cancelBubble = true;
			}
		}

		function adjust_Tally_Lump(thisObj)
		{
			var chObjCol = document.all[thisObj.name];
			var chLen, checkedLumpObj, subtractLumpObj;
			var subtractLump = 0;
			var thisLump = 0;
			chLen = chObjCol.length;
			var DeltaAmount = 0;
			for(i=0;i<chLen;i++)
			{
				if(chObjCol[i].checked)
				{
					checkedLumpObj = chObjCol[i];
					thisLump = parseFloat(checkedLumpObj.blump);
				}
				if(chObjCol[i].subtractLump == 1)
				{
					subtractLumpObj = chObjCol[i];
					subtractLump = parseFloat(subtractLumpObj.blump);
				}
			}
			if(subtractLumpObj)
			{
				subtractLumpObj.subtractLump = 0;
			}
			if(checkedLumpObj)
			{
				checkedLumpObj.subtractLump = 1;
			}
			DeltaAmount = thisLump - subtractLump;

			//var existing_Amount = parseFloat(document.all.Total_Approved_Amount.innerText);
			var existing_Amount = parseFloat(document.all.Tally_Total_Approved_Amount.value);
			existing_Amount = existing_Amount + DeltaAmount;

			document.all.Tally_Total_Approved_Amount.value = existing_Amount;

			existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);

			document.all.Total_Approved_Amount.innerText = existing_Amount;

			event.cancelBubble = true;
		}

		function adjust_Tally_Growth(thisObj)
		{
			var chObjCol = document.all[thisObj.name];
			var chLen, checkedGrowthObj, subtractGrowthObj;
			var subtractGrowth = 0;
			var thisGrowth = 0;
			var manualObj, growthManual, subtractGrowthManual;
			growthManual = 0;
			subtractGrowthManual = 0;

			chLen = chObjCol.length;
			var DeltaAmount = 0;
			for(i=0;i<chLen;i++)
			{
				if(chObjCol[i].checked)
				{
					checkedGrowthObj = chObjCol[i];
					if(checkedGrowthObj.bNextField)//This is applicable only in the case of manual radio button
					{
						growthManual = 1;
						manualObj = eval("document.all." + checkedGrowthObj.bNextField);
						thisGrowth = parseFloat(manualObj.value);
					}
					else
					{
						thisGrowth = parseFloat(checkedGrowthObj.bgrowth);
					}
				}
				if(chObjCol[i].subtractGrowth == 1)
				{
					subtractGrowthObj = chObjCol[i];
					if(subtractGrowthObj.bNextField)//This is applicable only in the case of manual radio button
					{
						subtractGrowthManual = 1;
						subtractGrowth =  parseFloat(subtractGrowthObj.subtractGrowthValue);
					}
					else
					{
						subtractGrowth = parseFloat(subtractGrowthObj.bgrowth);
					}
				}
			}

			if(isNaN(thisGrowth))
			{
				thisGrowth = 0;
			}
			if(isNaN(subtractGrowth))
			{
				subtractGrowth = 0;
			}

			if(subtractGrowthObj)
			{
				subtractGrowthObj.subtractGrowth = 0;
			}
			if(checkedGrowthObj)
			{
				checkedGrowthObj.subtractGrowth = 1;

				if(growthManual)
				{
					checkedGrowthObj.subtractGrowthValue = thisGrowth;
					checkedGrowthObj.bgrowth = thisGrowth;
				}
			}
			DeltaAmount = thisGrowth - subtractGrowth;

			//var existing_Amount = parseFloat(document.all.Total_Approved_Amount.innerText);
			var existing_Amount = parseFloat(document.all.Tally_Total_Approved_Amount.value);
			existing_Amount = existing_Amount + DeltaAmount;

			document.all.Tally_Total_Approved_Amount.value = existing_Amount;

			existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);

			document.all.Total_Approved_Amount.innerText = existing_Amount;
			event.cancelBubble = true;
		}

		function adjust_Tally_volume(thisObj)
		{
			//Volume BB_
			//Rate PR_

			var checkName = "PR_";
			var chObjCol = document.all[thisObj.name];
			var i, chLen, thisVolume, subtractVolume, checkedVolumeObj, subtractVolumeObj, startIndex;
			subtractVolume = 0;
			var DeltaAmount = 0;
			var manualObj, volumeManual, subtractVolumeManual;
			volumeManual = 0;
			subtractVolumeManual = 0;


			chLen = chObjCol.length;
			thisVolume = 0;
			for(i=0;i<chLen;i++)
			{
				if(chObjCol[i].checked)
				{
					checkedVolumeObj = chObjCol[i];
					if(checkedVolumeObj.bNextField)//This is applicable only in the case of manual radio button
					{
						volumeManual = 1;
						manualObj = eval("document.all." + checkedVolumeObj.bNextField);
						thisVolume = parseFloat(manualObj.value);
					}
					else
					{
						thisVolume = parseFloat(checkedVolumeObj.bvolume);
					}
				}
				if(isNaN(thisVolume))
				{
					thisVolume = 0;
				}
				if(chObjCol[i].subtractVolume == 1)
				{
					subtractVolumeObj = chObjCol[i];
					if(subtractVolumeObj.bNextField)//This is applicable only in the case of manual radio button
					{
						subtractVolumeManual = 1;
						subtractVolume =  parseFloat(subtractVolumeObj.subtractVolumeValue);
					}
					else
					{
						subtractVolume = parseFloat(subtractVolumeObj.bvolume);
					}
				}
			}

			if(checkedVolumeObj)
			{
				var PR_Started = 0;
				var Volume_Started = 0;
				var iRate, nameStart, thisAmount;
				startIndex = checkedVolumeObj.sourceIndex;
				chObjCol = document.getElementsByTagName("INPUT");
				chLen = chObjCol.length;
				for(i=0;i<chLen;i++)
				{
					if(chObjCol[i] == checkedVolumeObj)
					{
						if(PR_Started)
						{
							break;
						}
						Volume_Started = 1;
					}
					if(Volume_Started)
					{
						if(chObjCol[i].type == "radio")
						{
							nameStart = chObjCol[i].name.substr(0, checkName.length);
							if(nameStart != checkName)
							{
								if(PR_Started)
								{
									break;
								}
							}
							else if(chObjCol[i].brate != "undefined")
							{
								PR_Started = 1;
								chObjCol[i].bvolume = thisVolume;
								if(chObjCol[i].checked)
								{
									iRate = parseFloat(chObjCol[i].brate)
									if(isNaN(iRate))
									{
										iRate = 0;
									}
									thisAmount = (thisVolume - subtractVolume) * iRate;
									DeltaAmount = parseFloat(DeltaAmount) + thisAmount;
								}
							}
						}
					}
				}
			}

			if(subtractVolumeObj)
			{
				subtractVolumeObj.subtractVolume = 0;
			}
			if(checkedVolumeObj)
			{
				checkedVolumeObj.subtractVolume = 1;
				if(volumeManual)
				{
					checkedVolumeObj.subtractVolumeValue = thisVolume;
					checkedVolumeObj.bvolume = thisVolume;
				}
			}

			//var existing_Amount = parseFloat(document.all.Total_Approved_Amount.innerText);
			var existing_Amount = parseFloat(document.all.Tally_Total_Approved_Amount.value);
			existing_Amount = existing_Amount + DeltaAmount;

			document.all.Tally_Total_Approved_Amount.value = existing_Amount;

			existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);

			document.all.Total_Approved_Amount.innerText = existing_Amount;
			event.cancelBubble = true;
		}

		function adjust_Tally_rate(thisObj)
		{

			var i,chLen;
			var chObjCol = document.all[thisObj.name];
			var DeltaAmount = 0;
			var thisRate = 0;
			var subtractRate = 0;
			var thisVolume = 0;
			var checkedRateObj, subtractRateObj;
			var manualObj, rateManual, subtractRateManual;
			rateManual = 0;
			subtractRateManual = 0;

			chLen = chObjCol.length;

			for(i=0;i<chLen;i++)
			{
				if(chObjCol[i].checked)
				{
					checkedRateObj = chObjCol[i];
					thisVolume = checkedRateObj.bvolume;
					if(checkedRateObj.bNextField)//This is applicable only in the case of manual radio button
					{
						rateManual = 1;
						manualObj = eval("document.all." + checkedRateObj.bNextField);
						thisRate = manualObj.value;
					}
					else
					{
						thisRate = checkedRateObj.brate;
					}
				}
				if(chObjCol[i].subtractRate == 1)
				{
					subtractRateObj = chObjCol[i];
					if(subtractRateObj.bNextField)//This is applicable only in the case of manual radio button
					{
						subtractRateManual = 1;
						subtractRate =  subtractRateObj.subtractRateValue;
					}
					else
					{
						subtractRate = subtractRateObj.brate;
					}
				}
			}
			if(subtractRateObj)
			{
				subtractRateObj.subtractRate = 0;
			}
			if(checkedRateObj)
			{
				checkedRateObj.subtractRate = 1;
				if(rateManual)
				{
					checkedRateObj.subtractRateValue = thisRate;
					checkedRateObj.brate = thisRate;
				}
			}
			if(checkedRateObj)
			{
				DeltaAmount = (thisRate - subtractRate) * thisVolume;
				var existing_Amount = parseFloat(document.all.Tally_Total_Approved_Amount.value);
				existing_Amount = parseFloat(existing_Amount + DeltaAmount).toFixed(2);

				document.all.Tally_Total_Approved_Amount.value = existing_Amount;

				document.all.Total_Approved_Amount.innerText = existing_Amount;
				event.cancelBubble = true;
			}

		}

		function setCheckAll(chNameList, thisObj, objValue)
		{
			var arChNames = chNameList.split(",");
			var i, tempObj;
			if(event.propertyName == "checked")
			{
				for(i=0;i<arChNames.length;i++)
				{
					if(objValue == "B")
					{
						eval("document.all.LS_" + arChNames[i] + ".checked=" + thisObj.checked + ";");
						eval("document.all.LS_" + arChNames[i] + ".disabled=" + !thisObj.checked + ";");
					}
					else if(objValue == "M")
					{
						tempObj = eval("document.all.MU_LS_" + arChNames[i]);
						if(!thisObj.checked)
						{
							tempObj.value = "0";
						}
						tempObj.disabled = !thisObj.checked;
						if(tempObj.disabled)
						{
							tempObj.style.backgroundColor = "cccccc";
						}
						else
						{
							tempObj.style.backgroundColor = "ffffff";
						}
					}
				}
			}
		}
		<CFOUTPUT>
		function Amount_Selected_To_Pay_Error(bError)
		{
			if(bError)
			{
				queueMessage("The total for the amounts you entered (#DollarFormat(Previously_Approved_Total_For_JavaScript)#) exceeds the amount you can approve.", document.all.Amount_Selected_To_Pay);
			}
			else
			{
				clearQueue(document.all.Amount_Selected_To_Pay);
			}
		}
		</CFOUTPUT>


		function enableDisableInput(input, thisObj)
		{
			/*alert(suffix)
			alert(input)
			alert(eval("document.all."+suffix+input))
			alert(thisObj)*/
			var textBox = eval("document.all.MU_"+input)
			//var radioObj = //eval("document.all." + arChNames[i]); eval("document.all."+thisObj)
			//alert(thisObj.checked)
			if (thisObj.checked)
			{
				textBox.disabled = false;
				textBox.style.backgroundColor = "ffffff";
			}
			else
			{
				textBox.disabled = true;
				textBox.style.backgroundColor = "cccccc";
			}
			//alert(radioObj[3].checked)
		}
		function disable_Manual_Input()
		{
			//alert()
		}
		document.body.onload=new Function ("disable_Manual_Input();")


	</script>

	<!--------- Floating Layer -------------------->

	<CF_MessageWindow>
	<CFIF IsDefined("URL.Error")>
		<CFIF URL.Error EQ "E">
			<SCRIPT LANGUAGE="JavaScript">
				Amount_Selected_To_Pay_Error(true);
				showMessageWindow();
			</SCRIPT>
		</CFIF>
	</CFIF>
	</CFIF>
<CFELSE>
	</FORM>
	<script language="JavaScript">
	function submitForm()
	{
		event.returnValue = false;
		document.frmDeviation.submit();
		return false;
	}
	</script>
</CFIF>

<!--- BSD 11544  --->
<script>
	var url = '<cfoutput>#lcase(cgi.script_name)#</cfoutput>';
   if (url == '/billbacks/deviation/deviation.cfm')
   {
	try { window.parent.dyniframesize(); } catch (err) { };
   }
</script>
</BODY>
</html>
