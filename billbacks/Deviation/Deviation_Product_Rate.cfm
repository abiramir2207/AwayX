<CFPARAM name="URL.rdoUOM" default="1">
<CFPARAM name="URL.BBID" default="0">
<CFIF NOT IsDefined("INC_Deviation_Constants")>
	<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Constants.CFM">
</CFIF>

<cfif not isDefined("genSettingsManager")>
	<!---get application settings--->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<CFIF NOT IsDefined("INC_Date_Graph_Settings")>
	<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Date_Graph_Settings.cfm">
</CFIF>
<CFSET Table_Width = 650>

<CFPARAM NAME="URL.Billback_Product_Detail_ID"								DEFAULT="">
<CFSET Billback_Product_Detail_ID=URL.Billback_Product_Detail_ID>

<CFPARAM NAME="URL.BB_Product_Type_ID"										DEFAULT=1>
<CFSET BB_Product_Type_ID=URL.BB_Product_Type_ID>

<CFPARAM NAME="SHOW_DEVIATION_DETAIL_HEADER" 	DEFAULT=True>
<CFPARAM NAME="SHOW_DEVIATION_DETAIL_FOOTER" 	DEFAULT=True>

<cfset rateOverridePrice = 0 />

<cfset bbDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
<cfset bbDeviationManager.setAppSettings(appSettings) />

<cfset objFreight = CreateObject("component","components.freight.FreightBracketSetting") />
<cfset objFreight.getFreightSettings()  />

<cfset useFreightCalcDelTypeFromInvoice = 0 />
<cfif appsettings.getShow_Fixed_Freight() EQ 1
	and (appsettings.getBBDeviationUseMaxPrice() EQ 1 OR appsettings.getBBDeviationUseMaxPrice() EQ 2) and appsettings.getByPassExpectedRateCalculationEnhancement() eq 0>
	<cfset useFreightCalcDelTypeFromInvoice = 1 />

</cfif>

<CFIF SHOW_DEVIATION_DETAIL_HEADER>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Billback <cfoutput>#appSettings.getDeviationLabel()#</cfoutput> - Rate</title>
	<style>
	.top {
		border-width: .5px;
	  border-top: thin solid;
	  border-color: A9A9A9;
	}

	.bottom {
	  border-width: .5px;
	  border-bottom: thin solid;
	  border-color: A9A9A9;
	}

	.left {
	  border-width: .5px;
	  border-left: thin solid;
	  border-color: A9A9A9;
	}

	.right {
	  border-width: .5px;
	  border-right: thin solid;
	  border-color: A9A9A9;
	}
	</style>
<script type="text/javascript" src="/script/tTip.js"></script>
<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>

<!------------------------------show spinner ---------------------------->

<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<br>
<SCRIPT LANGUAGE="JavaScript">
	function show_TR_Details(trName)
	{
		event.returnValue = false;
		var trObj = document.getElementById(trName);
		var bDisplay = "";
		if(trObj.style.display.length == 0)
		{
			bDisplay = "none";
		}
		trObj.style.display = bDisplay;
	}
</SCRIPT>
<CFELSE>
	<BLOCKQUOTE>
</CFIF>
<CFIF ADDSCRIPT EQ "Yes">
	<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript">
	window.onbeforeprint=new Function ("AllOpenLayers(1);");
	</SCRIPT>
</CFIF>
<STYLE>
TABLE.NotMaintable TD
{
	border-bottom:none;
}
</STYLE>
<CFSILENT>


<!---  only use cache when it is a billback detail  --->
<cfset variables.cachedWithin = (cgi.script_name contains "billback_detail.cfm" ? CreateTimeSpan(0, 1, 0, 0) : CreateTimeSpan(0, 0, 0, 0))>

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getBB">
	SELECT	top 1 Billback_Product.Billback_Id as ID,Billback_Product_Detail.BB_Product_Type_ID, Billback_Product_Detail.Billback_Product_ID
	FROM	Billback_Product_Detail
	INNER JOIN Billback_Product
	ON		Billback_Product.Deleted = <cfqueryparam value=0>
	AND		Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
	WHERE	Billback_Product_Detail.Billback_Product_Detail_ID = <cfqueryparam value='#Billback_Product_Detail_ID#'>

</CFQUERY>
<cfset BBproductId = getBB.Billback_Product_ID>

<cfquery dataSource="#application.datasource#" NAME="qGetExpRateOverride">
	IF OBJECT_ID('tempdb..##tmp_ExpRateOverride') IS NOT NULL
	DROP TABLE ##tmp_ExpRateOverride

	SELECT	*
	INTO	##tmp_ExpRateOverride
	FROM	dbo.udfGetBBExpectedRate('#getBB.Id#','#BB_Product_Type_ID#','#BBproductId#')
</cfquery>

<!--------------------------------------------------------------------------------------
Get Program , Product Info for display and for being used in other queries
--------------------------------------------------------------------------------------->

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Product_Program">
SELECT	Billback.Billback_ID, Billback.BB_Start_Date, Billback.BB_End_Date, Billback.BB_Code, Billback.BB_Title, Billback_Product.BB_Product_UOM,
		Billback.Billback_Payee_Type_ID, Billback.Uploaded_Billback,
		Billback_Program.Program_ID,
		CASE
		WHEN Billback_Program.Program_ID IS NULL THEN
			Billback_Program.BB_Program_Number
		ELSE
			Contract_Main.Contract_Number
		END AS Contract_Number,
		Program_Control_Panel_Options.Created_Type,
		Program_Control_Panel_Options.Generic_Type,
		Program_Control_Panel_Options.BidRequestStatusOn,
		Program_Control_Panel_Options.BB_D_Template_Overrides_Deviation_Tolerances,
		Program_Control_Panel_Options.BB_D_Purchase_Period_OverRide_Rate,
		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.UPC,
		BSA_Foodservice_Items_Master.Net_Weight, BSA_Foodservice_Items_Master.Gross_Weight,
		BSA_Foodservice_Items_Master.Del_Del_Cost, BSA_Foodservice_Items_Master.Del_Cust_Pickup,
		CASE LTRIM(RTRIM(BSA_Foodservice_Items_Master.Inventory_UM))
		WHEN 'LB' THEN 2
		ELSE 1
		END As Del_Cost_UOM
		,Contract_Main.Manual_Cancel
		,Distributor_id_earned
		,IsNull(Type_Code_Desc.proxy_del_cost,0) As proxy_del_cost
		,IsNull(gross_weight,0) As gross_weight,
		ExpectedRate.ProductID AS ExpRT_ProductID,
    	ExpectedRate.Rate AS ExpRT_Rate,
    	ExpectedRate.Unit_Of_Measure_ID AS ExpRT_Unit_Of_Measure_ID,
    	ExpectedRateOverrideUom.Unit_Of_Measure_Desc_Singular AS ExpRT_UOM,
    	ExpectedRate.Expected_Rate_Flag AS ExpRT_Expected_Rate_Flag, -- 1 -> RATE = $0, 2 -> Rate = Less Program Rebate, 3 -> Rate = Add Program Rebate
    	ExpectedRate.Contract_Number AS ExpRT_Contract_Number,
    	ExpectedRate.Discount_Type_Id AS ExpRT_Discount_Type_Id,
		ISNULL(Program_Control_Panel_Options.Ignore_Rate_Deviation, 0) as Ignore_Rate_Deviation
		,Contract_Main.Planner_ID
		FROM	Billback_Product_Detail
		INNER JOIN	Billback_Product
		ON
		(
			(Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(Billback_Product.Deleted = 0)
		)
		INNER JOIN	Billback_Program
		ON
		(
			(Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID)
			AND
			(Billback_Program.Deleted = 0)
		)
		INNER JOIN	Billback
		ON
		(
			(Billback.Billback_ID = Billback_Program.Billback_ID)
			AND
			(Billback.Deleted = 0)
		)
		LEFT JOIN	Contract_Main
		ON
		(
				(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
		)
		LEFT JOIN	Program_Control_Panel_Options
		ON
		(
			(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID)
		)
		LEFT JOIN	BSA_Foodservice_Items_Master
		ON
		(
			(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID)
		)
		LEFT JOIN Type_Code_Desc
		ON
		(
			(BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID)
		)
		LEFT JOIN ##tmp_ExpRateOverride ExpectedRate ON <!---,#getBB.BB_Product_Type_ID#'--->
			ExpectedRate.ProductId  = Billback_Product.Product_ID
		LEFT JOIN	Units_of_Measure ExpectedRateOverrideUom ON ExpectedRateOverrideUom.Unit_Of_Measure_ID = ExpectedRate.Unit_Of_Measure_ID
	WHERE
		Billback_Product_Detail.Billback_Product_Detail_ID = <cfqueryparam value='#Billback_Product_Detail_ID#'>
		AND
		Billback_Product_Detail.Deleted = <cfqueryparam value=0>
</CFQUERY>

<!-----------------------------------------------------------------------------
Set the variables to be used later for calulation adn also other queries
-------------------------------------------------------------------------->

<CFSET BSA_Foodservice_Items_Master_ID 	= Billback_Product_Program.BSA_Foodservice_Items_Master_ID>
<CFSET Billback_Start_Date 					= Billback_Product_Program.BB_Start_Date>
<CFSET Billback_End_Date 					= Billback_Product_Program.BB_End_Date>
<CFSET Program_Number 						= Billback_Product_Program.Contract_Number>
<CFSET Generic_Type 						= Billback_Product_Program.Generic_Type>
<CFSET Created_Type 						= Billback_Product_Program.Created_Type>
<CFSET Billback_Total_Days 					= DateDiff("d", Billback_Start_Date, Billback_End_Date) + 1>
<CFSET Billback_ID 							= Billback_Product_Program.Billback_ID>
<CFSET Net_Weight 							= Billback_Product_Program.Net_Weight>
<CFSET Gross_Weight							= Billback_Product_Program.Gross_Weight>
<CFSET Net_Weight 							= ReReplace(Net_Weight, "^0*", "", "All")>
<CFSET Del_Del_Cost 						= Billback_Product_Program.Del_Del_Cost>
<CFSET Del_Cust_Pickup 						= Billback_Product_Program.Del_Cust_Pickup>
<CFSET Del_Cost_UOM							= Billback_Product_Program.Del_Cost_UOM>

<CFSET Payable_Number 						= Billback_Product_Program.BB_Code>
<CFSET Billback_Title 						= Billback_Product_Program.BB_Title>
<CFSET Ignore_Rate_Deviation				= Billback_Product_Program.Ignore_Rate_Deviation />
<CFSET Use_MSA_Data = 0 />
<CFIF Billback_Product_Program.Planner_ID NEQ "" AND Billback_Product_Program.Planner_ID NEQ "0">
	<cfquery cachedWithin="#variables.cachedWithin#" dataSource="#application.datasource#" NAME="qCountComponents">
		SELECT	Use_MSA_Data = CASE WHEN pt.Category = 'MSA' THEN 1 ELSE 0 END
		FROM	Planners p
		INNER JOIN Planner_Template pt
		ON		pt.Planner_Template_ID = p.Planner_Template_ID
		WHERE	p.Planner_ID = <cfqueryparam value='#Billback_Product_Program.Planner_ID#' cfsqltype="CF_SQL_NUMERIC">
	</CFQUERY>
	<CFSET Use_MSA_Data = Val(qCountComponents.Use_MSA_Data) />
</CFIF>

<cfif (isDefined("pgSrc") AND pgSrc EQ "Details")>
	<cfif (isDefined("URL.rdoUOM") and URL.rdoUOM NEQ "")>
		<cfset Billback_UOM 						= URL.rdoUOM>
	<cfelse>
		<cfset Billback_UOM 						= Billback_Product_Program.BB_Product_UOM>
	</cfif>
<cfelse>
	<cfif (isDefined("FORM.rdoUOM") and FORM.rdoUOM NEQ "")>
		<cfset Billback_UOM 						= FORM.rdoUOM>
	<cfelse>
		<cfset Billback_UOM 						= Billback_Product_Program.BB_Product_UOM>
	</cfif>
</cfif>

<CFSET BB_Payee_Type_ID							= Billback_Product_Program.Billback_Payee_Type_ID>

<CFSET Billback_Program_Program_ID			= Billback_Product_Program.Program_ID>

<CFSET ExpRT_Rate							= Billback_Product_Program.ExpRT_Rate />
<CFSET ExpRT_Unit_Of_Measure_ID				= Billback_Product_Program.ExpRT_Unit_Of_Measure_ID />

<cfif ExpRT_Unit_Of_Measure_ID neq Billback_UOM>
	<cfif ExpRT_Unit_Of_Measure_ID eq 1 and Billback_UOM eq 2>
		<cfset ExpRT_Rate = ExpRT_Rate / Net_Weight /> <!---- convert from CS to LB ---->
		<CFSET ExpRT_Unit_Of_Measure_ID = Billback_UOM />
	<cfelseif ExpRT_Unit_Of_Measure_ID eq 2 and Billback_UOM eq 1>
		<cfset ExpRT_Rate = ExpRT_Rate * Net_Weight /> <!---- convert from LB to CS ---->
		<CFSET ExpRT_Unit_Of_Measure_ID = Billback_UOM />
	</cfif>
</cfif>

<CFSET BB_D_Template_Overrides_Deviation_Tolerances = 0>
<cfif Billback_Product_Program.BB_D_Template_Overrides_Deviation_Tolerances EQ 1>
	<CFSET BB_D_Template_Overrides_Deviation_Tolerances = 1>
	<CFSET BB_D_Purchase_Period_OverRide_Rate = Billback_Product_Program.BB_D_Purchase_Period_OverRide_Rate />
<cfelse>
	<CFSET BB_D_Purchase_Period_OverRide_Rate = 0 />
</cfif>

<!---<cfset Get_Dist_ID = bbDeviationManager.getBillbackDistributor(Billback_ID, BB_Payee_Type_ID)>	--->
<cfset PayTo = bbDeviationManager.getPayTo(BB_Payee_Type_ID, appSettings.getBBCheckPayTo())>
<!---new for multi Dist BB's	--->
<cfset Get_Dist_ID = bbDeviationManager.getBBProdDistId(Billback_ID, Billback_Product_Detail_ID)>
<CFSET Dist_ID = "">
<CFIF Get_Dist_ID.RecordCount GT 0>
	<CFSET Dist_ID = Get_Dist_ID.BSA_Foodservice_Customers_ID>
</CFIF>

<cfset zipCode = "0" />
<cfif trim(Billback_Product_Program.Distributor_id_earned) neq "" and trim(Billback_Product_Program.Distributor_id_earned) neq '00000000-0000-0000-0000-000000000000'>
	<cfset Get_Dist_Info = bbDeviationManager.getDistributorInfo(Billback_Product_Program.Distributor_id_earned) />
	<cfset zipCode = Get_Dist_Info.zipCode />
</cfif>

<cfset ProductReplacementID = "" />
<cfif appSettings.getProductReplacementEnabled()>
	<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
	<cfset ProductReplacementID = BillbackDeviationManager.getProductReplacementID(productId=BSA_Foodservice_Items_Master_ID)>
</cfif>

<cfquery cachedWithin="#variables.cachedWithin#" dataSource="#application.datasource#" NAME="qGetBillbackSetting">
	SELECT	BB_Start_Offset_Days = ISNULL(BB_Start_Offset_Days, 0),
			BB_End_Offset_Days = ISNULL(BB_End_Offset_Days, 0)
	FROM	Billback_Settings
</CFQUERY>

<cfset _Setting_BB_Start_Offset_Days = Val(qGetBillbackSetting.BB_Start_Offset_Days) />
<cfset _Setting_BB_End_Offset_Days = Val(qGetBillbackSetting.BB_End_Offset_Days) />
<cfset _Setting_Dist_Trade_Deviation_Tolerance_Override = appSettings.get_Setting('Dist_Trade_Deviation_Tolerance_Override') />
<!--- If offset is being used, do not use Dist_Trade_Deviation_Tolerance_Override --->
<cfif _Setting_BB_Start_Offset_Days GT 0 OR _Setting_BB_End_Offset_Days GT 0>
	<cfset _Setting_Dist_Trade_Deviation_Tolerance_Override = 0 />
</cfif>

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getDatesForProgram">
SELECT      MIN(Approval_Start_Date) As Approval_Start_Date, MAX(Approval_End_Date) As Approval_End_Date
FROM BB_Program_Info
WHERE       Contract_Number =  <cfqueryparam value='#Program_Number#'>
</CFQUERY>

<!--- Effective start date --->
<cfset MinProgramApprovalDate = getDatesForProgram.Approval_Start_Date>
<!--- Effective end date --->
<cfset MaxProgramApprovalDate = getDatesForProgram.Approval_End_Date>

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Rate_Tolerance">
SELECT	BB_DPPR_Rate AS BB_Tolerance_DPP,
		BB_DPPO AS BB_Tolerance_DPPO,
		BB_TET AS BB_Tolerance_TET,
		BB_ERT AS BB_Tolerance_ERT
FROM	BB_Basic_Setting_Detail
WHERE
		Billback_ID = <cfqueryparam value='#Billback_ID#'> AND
		Contract_Main_Id = <cfqueryparam value=#Billback_Program_Program_ID#>
</CFQUERY>

<cfif Billback_Rate_Tolerance.RecordCount eq 0>
	<!---
	D32309 : Event error value "" cannot be converted to a number on bbk deviations grid
	It is possible that deviation ran agianst this billback before label D31930 was in place, handle for it
	Get any value available at billback level
	--->
	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Rate_Tolerance">
	SELECT	top 1
			BB_DPPR_Rate AS BB_Tolerance_DPP,
			BB_DPPO AS BB_Tolerance_DPPO,
			BB_TET AS BB_Tolerance_TET,
			BB_ERT AS BB_Tolerance_ERT
	FROM	BB_Basic_Setting_Detail
	WHERE
			Billback_ID = <cfqueryparam value='#Billback_ID#'>
	</CFQUERY>
</cfif>

<!--------------------------------------------------------------------------------------
Get information for finding out the expected rate
--------------------------------------------------------------------------------------->

<CFSET Rate_FieldName = "">
<CFSWITCH EXPRESSION="#BB_Product_Type_ID#">
	<CFCASE VALUE="1">
		<CFSET Rate_FieldName = "0">
		<CFSET Rate_ID_FieldName = "BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID">
	</CFCASE>
	<CFCASE VALUE="2">
		<CFSET Rate_FieldName = "Program_Rebates_Product_Data.Rebate_Value">
		<CFSET Rate_ID_FieldName = "Program_Rebates_Product_Data_ID">
	</CFCASE>
	<CFCASE VALUE="5">
		<CFSET Rate_FieldName = "Program_Formula_Pricing_Rule_Products.Price">
		<CFSET Rate_ID_FieldName = "Program_Formula_Pricing_Rule_Product_ID">
	</CFCASE>
	<CFCASE VALUE="11">
		<CFSET Rate_FieldName = "0">
		<CFSET Rate_ID_FieldName = "BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID">
	</CFCASE>
</CFSWITCH>
<CFSET PGM_UOM_FIELD_NAME = "Unit_Of_Measure_ID" />
<CFIF BB_Product_Type_ID EQ 11>
	<CFSET PGM_UOM_FIELD_NAME = "UOM" />
</CFIF>
<cfset distributor_unauthorized = 0 />
<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Check_Distriburtor_UnAuthorized">
	SELECT	ISNULL(BillBack_Program_Distributor.Unauthorized, 0) as Unauthorized
	FROM	Billback_Product_Detail
	INNER JOIN Billback_Product
	ON		Billback_Product.Deleted = <cfqueryparam value=0>
	AND		Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
	INNER JOIN BillBack_Program_Distributor
	ON		BillBack_Program_Distributor.Deleted = <cfqueryparam value=0>
	AND		BillBack_Program_Distributor.Billback_ID = Billback_Product.Billback_ID
	AND		BillBack_Program_Distributor.Billback_Program_ID = Billback_Product.Billback_Program_ID
	AND		BillBack_Program_Distributor.Distributor_ID = Billback_Product.Distributor_ID
	WHERE	Billback_Product_Detail.Billback_Product_Detail_ID = <cfqueryparam value='#Billback_Product_Detail_ID#'>
	AND		Billback_Product_Detail.Deleted = <cfqueryparam value=0>
</CFQUERY>
<cfif Check_Distriburtor_UnAuthorized.recordCount>
	<cfif Check_Distriburtor_UnAuthorized.Unauthorized eq 1>
		<cfset distributor_unauthorized = 1 />
	</cfif>
</cfif>

<cfset Overlap_Only_With_Date_Tolerance = 0>

<cfif MaxProgramApprovalDate LT Billback_Start_Date OR MinProgramApprovalDate GT Billback_End_Date>
	<cfif appSettings.getDateTolerance() NEQ 0>
		<!--- Dev Note:45782 and 46562 - Normally a billback should be within the program's dates (at least a day) to be picked up, but when the
		"appSettings.getDateTolerance()" has a value, the billback dates could be within the "appSettings.getDateTolerance()" limit to be considered.
		--->
		<cfif
	          ( (DATEDIFF('d', MaxProgramApprovalDate, Billback_Start_Date) LTE appSettings.getDateTolerance())
                        AND
                    (DATEDIFF('d', Billback_End_Date, MinProgramApprovalDate) LTE appSettings.getDateTolerance())
                  )>
		  <cfset Overlap_Only_With_Date_Tolerance = 1>
		</cfif>
	</cfif>
</cfif>

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Program_Dates_Pre">
	SELECT	Billback.Billback_ID, #Rate_ID_FieldName#, Contract_Products.BSA_Foodservice_Items_Master_ID,
		<CFIF Billback_UOM EQ 1><!---- answer in cases --------->
			<CFIF BB_Product_Type_ID NEQ "5">
			CASE
			WHEN #PGM_UOM_FIELD_NAME# = 1 THEN
				ISNULL(CAST(#Rate_FieldName# AS Float), 0)
			ELSE
				ISNULL(CAST(#Rate_FieldName# AS Float), 0) * ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float), 1)
			END AS Product_Rate,
			<CFELSE><!---- Formula UOM = 2--->
			ISNULL(CAST(#Rate_FieldName# AS Float), 0) * ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float), 1)
			 AS Product_Rate,
			</CFIF>
		<CFELSE><!---- answer in pounds --------->
			<CFIF BB_Product_Type_ID NEQ "5">
			CASE
			WHEN #PGM_UOM_FIELD_NAME# = 1 THEN
				ISNULL(CAST(#Rate_FieldName# AS Float), 0) / ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight AS Float), 1)
			ELSE
				ISNULL(CAST(#Rate_FieldName# AS Float), 0)
			END AS Product_Rate,
			<CFELSE><!---- Formula UOM = 2--->
			ISNULL(CAST(#Rate_FieldName# AS Float), 0)
			AS Product_Rate,
			</CFIF>
		</CFIF>
		CAST(#Rate_FieldName# AS Float) AS Product_Rate_IN_PGM_UOM,
		<CFIF BB_Product_Type_ID EQ "5">2 AS <CFELSE>#PGM_UOM_FIELD_NAME# </CFIF>Unit_Of_Measure_ID,
		<cfif Overlap_Only_With_Date_Tolerance EQ 1>
		/* Dev Note:45782 - Normally a billback should be within the program's dates (at least a day) to be picked up, but when the
		"Overlap_Only_With_Date_Tolerance" is ON, the billback dates could be within the "date tolerance" limit to be considered.
		*/
		'#Billback_Start_Date#' AS Start_Date,
		'#Billback_End_Date#' AS End_Date,
		<cfelse>
		BB_Program_Info.Approval_Start_Date AS Start_Date,
		BB_Program_Info.Approval_End_Date AS End_Date,
		</cfif>
		0 AS Doc_Type,
		BB_Program_Info.Contract_Main_ID As Revision_Program_ID,
		CASE
		WHEN Program_Product_Bid_Info.Won IS NULL OR Program_Product_Bid_Info.Won = 1 THEN 0
		ELSE 1
		END as Lost
		FROM	Billback_Product_Detail
		INNER JOIN	Billback_Product
		ON
		(
			(Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(Billback_Product.Deleted = 0)
		)
		INNER JOIN	Billback_Program
		ON
		(
			(Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID)
			AND
			(Billback_Program.Deleted = 0)
		)
		INNER JOIN	Billback
		ON
		(
			(Billback.Billback_ID = Billback_Program.Billback_ID)
			AND
			(Billback.Deleted = 0)
		)
		INNER JOIN	BB_Program_Info
		ON
		(
			(BB_Program_Info.Contract_Number = '#Program_Number#')
			AND
			(BB_Program_Info.Deleted = 0)
			<cfif Overlap_Only_With_Date_Tolerance EQ 1>
			/* Dev Note:45782 and 46562 - Normally a billback should be within the program's dates (at least a day) to be picked up, but when the
			"Overlap_Only_With_Date_Tolerance" is ON, the billback dates could be within the "date tolerance" limit to be considered.
			*/
                        AND   ( ('#MaxProgramApprovalDate#' < '#Billback_Start_Date#' AND BB_Program_Info.Approval_End_Date = '#MaxProgramApprovalDate#') <!--- Pick the last version that ended just before bb start --->
                                    AND
                                ('#MinProgramApprovalDate#' > '#Billback_End_Date#' AND BB_Program_Info.Approval_Start_Date = '#MinProgramApprovalDate#') <!--- Pick the first version which started just after bb end --->
                              )
			<cfelse>
			AND
			(
				((DATEDIFF(d, BB_Program_Info.Approval_Start_Date, Billback.BB_End_Date) >= 0) AND (DATEDIFF(d, Billback.BB_End_Date, BB_Program_Info.Approval_End_Date) >= 0))
				OR
				((DATEDIFF(d, BB_Program_Info.Approval_Start_Date, Billback.BB_Start_Date) >= 0) AND (DATEDIFF(d, Billback.BB_Start_Date, BB_Program_Info.Approval_End_Date) >= 0))
				OR
				((DATEDIFF(d, Billback.BB_Start_Date, BB_Program_Info.Approval_End_Date) >= 0) AND (DATEDIFF(d, BB_Program_Info.Approval_End_Date, Billback.BB_End_Date) >= 0))
				OR
				((DATEDIFF(d, Billback.BB_Start_Date, BB_Program_Info.Approval_Start_Date) >= 0) AND (DATEDIFF(d, BB_Program_Info.Approval_Start_Date, Billback.BB_End_Date) >= 0))
			)
			</cfif>
		)
		INNER JOIN BB_Program_Deviation_Info
		ON
		(
			(BB_Program_Deviation_Info.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Program_Deviation_Info.Deleted = 0)
			AND
			((BB_Program_Deviation_Info.Unauthorized_Payee = 0) OR (BB_Program_Deviation_Info.Unauthorized_Payee < BB_Dollar_Amount AND '#appSettings.get_Setting('PG_Effective_Date_Upload_Download')#' = '1' ) )  ----(BB_Program_Deviation_Info.Unauthorized_Payee = 0)
		)
		<CFIF BB_Product_Type_ID EQ 2>LEFT<CFELSE>INNER</CFIF> JOIN	Contract_Products
		ON
		(
			(Contract_Products.Contract_Main_ID = BB_Program_Info.Contract_Main_ID)
			AND
			(Billback_Product.product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			<cfif appSettings.getProductReplacementEnabled() AND ProductReplacementID NEQ "">
			OR	Contract_Products.BSA_Foodservice_Items_Master_ID = '#ProductReplacementID#'
			</cfif>
			)
			<!------ discount_type = 10 is bid request in programs, but as claim adjustment already used up the id 10 in billback,
				bid request has an id of 11 in billback, but when looking at program tables we have to keep using 10 ----->
			AND
			(Contract_Products.Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID
			OR (Contract_Products.Product_Type_ID = 10 AND Billback_Product_Detail.BB_Product_Type_ID = 11))
			AND
			(Contract_Products.Deleted = 0)
		)
		<CFIF BB_Product_Type_ID EQ 2>LEFT<CFELSE>INNER</CFIF> JOIN	BSA_Foodservice_Items_Master
		ON
		(
			(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID)
		)
		LEFT JOIN Program_Product_Bid_Info
		ON	Program_Product_Bid_Info.Deleted = 0
		AND	Program_Product_Bid_Info.Program_ID = Contract_Products.Contract_Main_ID
		AND	Program_Product_Bid_Info.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
		<CFSWITCH EXPRESSION="#BB_Product_Type_ID#">
		<CFCASE VALUE="1">
		INNER JOIN	Program_Fixed_Price_Product_Data
		ON
		(
			(Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID)
			AND
			(Program_Fixed_Price_Product_Data.Deleted = 0)
			AND
			(Program_Fixed_Price_Product_Data.Fixed_Price_Value IS NOT NULL)
			AND
			(CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS Float) > 0)
		)
		</CFCASE>
		<CFCASE VALUE="2">
		LEFT JOIN	Program_Rebates_Product_Data
		ON
		(
			(Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID)
			AND
			(Program_Rebates_Product_Data.Deleted = 0)
			--AND (Program_Rebates_Product_Data.Rebate_Value IS NOT NULL)
		)
		</CFCASE>
		<CFCASE VALUE="5">
		INNER JOIN	Program_Formula_Pricing_Rule_Products
		ON
		(
			(Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID)
			AND
			(Program_Formula_Pricing_Rule_Products.Deleted = 0)
			AND
			(Program_Formula_Pricing_Rule_Products.Price IS NOT NULL)
		)
		</CFCASE>
		<CFCASE VALUE="11">
		INNER JOIN	Program_Bid_Request_Product
		ON
		(
			(Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID)
			AND
			(Program_Bid_Request_Product.Deleted = 0)
			AND
			(Program_Bid_Request_Product.Price IS NOT NULL)

		)
		</CFCASE>
		</CFSWITCH>
	WHERE
		Billback_Product_Detail.Billback_Product_Detail_ID = <cfqueryparam value='#Billback_Product_Detail_ID#'>
		AND
		Billback_Product_Detail.Deleted = <cfqueryparam value=0>
		AND #distributor_unauthorized# = <cfqueryparam value=0>
</CFQUERY>

<!--- Billback was item lost --->
<cfset CheckProductWon = 0 />
<cfset ProductLost = 0>
<CFIF (BB_Product_Type_ID IS 11 OR BB_Product_Type_ID IS 1 OR BB_Product_Type_ID IS 2) AND  appsettings.getLost_Bids_Deviated() IS 1 AND Billback_Product_Program.BidRequestStatusOn EQ 1>
	<cfset CheckProductWon = 1 />

	<!--- Dev Note: KAL; D21475: Solo - Rate deviaion screen shows incorrect message --->
	<cfquery cachedWithin="#variables.cachedWithin#" name="BBProgramsList" datasource="#application.datasource#">
		SELECT 		BB_Program_Info.Contract_Main_ID
		FROM 		Billback
		INNER JOIN	BB_Program_Info
		ON
		(
			(Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_idstamp">)
			AND
			(BB_Program_Info.Contract_Number = <cfqueryparam value="#Program_Number#" cfsqltype="cf_sql_varchar">)
			AND
			(BB_Program_Info.Deleted = <cfqueryparam value=0>)
			AND
			(
				((DATEDIFF(d, BB_Program_Info.Approval_Start_Date, Billback.BB_End_Date) >= 0) AND (DATEDIFF(d, Billback.BB_End_Date, BB_Program_Info.Approval_End_Date) >= 0))
				OR
				((DATEDIFF(d, BB_Program_Info.Approval_Start_Date, Billback.BB_Start_Date) >= 0) AND (DATEDIFF(d, Billback.BB_Start_Date, BB_Program_Info.Approval_End_Date) >= 0))
				OR
				((DATEDIFF(d, Billback.BB_Start_Date, BB_Program_Info.Approval_End_Date) >= 0) AND (DATEDIFF(d, BB_Program_Info.Approval_End_Date, Billback.BB_End_Date) >= 0))
				OR
				((DATEDIFF(d, Billback.BB_Start_Date, BB_Program_Info.Approval_Start_Date) >= 0) AND (DATEDIFF(d, BB_Program_Info.Approval_Start_Date, Billback.BB_End_Date) >= 0))
			)
		)
	</cfquery>

	<!--- Dev Note: KAL; D21475: Solo - Rate deviaion screen shows incorrect message; Convert the program_ID's to a list  --->
	<cfset BBProgramIDs = #ValueList(BBProgramsList.Contract_Main_ID)# />

	<cfquery cachedWithin="#variables.cachedWithin#" name="IsProductLost" datasource="#application.datasource#">
		SELECT Top 1 Won
		FROM Program_Product_Bid_Info
			INNER JOIN Contract_Products ON
			Program_Product_Bid_Info.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND Contract_Products.Deleted = 0
			AND Contract_Products.Contract_Main_ID = Program_Product_Bid_Info.Program_ID
		WHERE Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#'>
		AND Program_Product_Bid_Info.Program_ID IN (<cfqueryparam value="#BBProgramIDs#" cfsqltype="cf_sql_integer" list="true" separator=",">)
		AND Program_Product_Bid_Info.deleted = <cfqueryparam value=0>
		ORDER BY Won DESC
	</cfquery>

	<cfif IsProductLost.Won IS NOT 1>
		<!---- if original product is not won, see if the replacement product is won/lost ---->
		<cfif appSettings.getProductReplacementEnabled() AND ProductReplacementID NEQ "">
			<cfquery cachedWithin="#variables.cachedWithin#" name="IsProductLost" datasource="#application.datasource#">
				SELECT Top 1 Won
				FROM Program_Product_Bid_Info
					INNER JOIN Contract_Products ON
					Program_Product_Bid_Info.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					AND Contract_Products.Deleted = 0
					AND Contract_Products.Contract_Main_ID = Program_Product_Bid_Info.Program_ID
				WHERE Contract_Products.BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#ProductReplacementID#'>
				AND Program_Product_Bid_Info.Program_ID IN (<cfqueryparam value="#BBProgramIDs#" cfsqltype="cf_sql_integer" list="true" separator=",">)
				AND Program_Product_Bid_Info.deleted = <cfqueryparam value=0>
				ORDER BY Won DESC
			</cfquery>
		</cfif>
	</cfif>

	<cfif IsProductLost.Won IS NOT 1>
		<cfset ProductLost = 1>
	</cfif>
</CFIF>

<cfset sCurrentProductHasRatesInThesePrograms = "" />
<cfif appSettings.getProductReplacementEnabled() AND ProductReplacementID NEQ "">
	<CFQUERY DBTYPE="QUERY" NAME="CurrentProductHasRatesInThesePrograms">
		SELECT DISTINCT Revision_Program_ID
		FROM 	Billback_Program_Dates_Pre
		WHERE 	BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#'>
		AND		Lost = <cfqueryparam value=0>
	</CFQUERY>
	<cfset sCurrentProductHasRatesInThesePrograms = ValueList(CurrentProductHasRatesInThesePrograms.Revision_Program_ID) />
</cfif>

<!---
D13872 JRS -Identify how to handle BB purchase validation when sku number changes
We need to account for bis status = lost at item lebel because of below reasons
If there was a product replacement A=B
Program has A as lost at 1.1/CS
Program has B as won at 1.2/CS
When billback has A,
the stored procedure will pick up B's rate and show 1.2/CS
we need the cfm also to do the same other wise will show 1.1/CS which will not match the SP value
So we are going to implement the logic to ignore products which are lost altogether even if the "product replacment" is on or off to avoid confusion
Otherwise, originally even though teh stored procedure would caluclate a rate of 0/CS when the product is lost, the cfm would have shown the values.
Which is alright as long as it was a value in cfm against 0 from sp
But will have problem if we have a value in cfm against a different value from sp
--->
<CFQUERY DBTYPE="QUERY" NAME="Billback_Program_Dates">
	SELECT	*
	FROM	Billback_Program_Dates_Pre
	WHERE	(BSA_Foodservice_Items_Master_ID IS NULL
	OR		BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#'>)
	AND		Lost = 0
	<cfif appSettings.getProductReplacementEnabled() AND ProductReplacementID NEQ "">
	<!----- Get rate/price from replacement product only if current product has no rate / price for a particular version ------>
	UNION
	SELECT	*
	FROM	Billback_Program_Dates_Pre
	WHERE	BSA_Foodservice_Items_Master_ID = <cfqueryparam value='#ProductReplacementID#'>
	AND		Lost = 0
	<cfif sCurrentProductHasRatesInThesePrograms NEQ "">
	AND		Revision_Program_ID NOT IN (#sCurrentProductHasRatesInThesePrograms#)
	</cfif>
	</cfif>
</CFQUERY>

<CFSET temp = QueryAddRow(Billback_Program_Dates)>
<CFSET temp2 = QuerySetCell(Billback_Program_Dates, "Product_Rate", 0, temp) >
<CFSET temp2 = QuerySetCell(Billback_Program_Dates, "Start_Date", Billback_Start_Date, temp)>
<CFSET temp2 = QuerySetCell(Billback_Program_Dates, "End_Date", Billback_End_Date, temp)>
<CFSET temp2 = QuerySetCell(Billback_Program_Dates, "Doc_Type", 1, temp)>

</CFSILENT>

<!------------------------------------------------
Display header Info
- program
- product
- Billback
-------------------------------------------------->

<CFOUTPUT>
<cfif Ignore_Rate_Deviation eq 1>
	<span style="color:red;font-weight:bold;">Expected Rate Calculation is not viewable because the setting - "Ignore rate deviation" is ON for the program template</span>
	<br /><br /><br />
	<TABLE ALIGN="CENTER" WIDTH="50%">
		<tr>
			<TD ALIGN="CENTER">
			<CF_button
					button_name		=	""
					button_caption	=	"close this window"
					button_action	=	"window.close();"
					button_type		=	"javascript_link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	"close this window"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</tr>
	</TABLE>
	<cfabort />
</cfif>

<form name="frmDeviationPrdRate" method="post" action="/billbacks/Deviation/Deviation_Product_Rate.cfm?Billback_Product_Detail_ID=#Billback_Product_Detail_ID#&BB_Product_Type_ID=#BB_Product_Type_ID#">
<!--- <span style="position: absolute;right:0;"> --->
<script>
function submitPgLoader(rdoOption){
<cfif (isDefined('pgSrc') AND pgSrc EQ "Details")>
	window.location.href='/billbacks/common/Billback_Detail.cfm?bbid=<cfoutput>#URL.BBID#</cfoutput>&isAutoBB=0&rdoUOM=' + rdoOption;
<cfelse>
	document.frmDeviationPrdRate.submit();
</cfif>
}
</script>
<cfif (isDefined('pgSrc') AND pgSrc EQ "Details")>
	<cfset Billback_UOM = URL.rdoUOM/>
</cfif>

<table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">
	<tr>
		<td>
			<SPAN CLASS="Title2">Expected Rate Calculation</SPAN>
			<HR COLOR="Orange">
		</td>
	</tr>
	<cfif Billback_Product_Program.Manual_Cancel EQ 1>
		<tr>
			<td>
				<div style="font-weight:bold;color:##DF0000;font-size:12pt;margin-bottom:5px;" align="center">*** This is a Cancelled Program. ***</div>
			</td>
		</tr>
	</cfif>
	<tr>
		<td align="right">
			<strong>Change the UOM:</strong>
			<input type ="radio" name="rdoUOM" <cfif (Billback_UOM EQ 1)>checked</cfif> onclick="submitPgLoader('1');" value="1">CS
			<input type ="radio" name="rdoUOM" <cfif (Billback_UOM EQ 2)>checked</cfif> onclick="submitPgLoader('2');" value="2">LB<br>
		</td>
	</tr>
	<TR>
		<TD COLSPAN="100%">
		<B>Billback ## #Payable_Number# #Billback_Title# (#DateFormat(Billback_Start_Date, "mm/dd/yyyy")# - #DateFormat(Billback_End_Date, "mm/dd/yyyy")#) (#Billback_Total_Days# days)</B>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%">
		<B>Program ## #Program_Number#</B> <CFIF Billback_Program_Program_ID NEQ "">(#ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label)# - #Created_Type#)<CFELSE>#DEVIATION_SHOW_PNF#</CFIF>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%"><strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> ## </strong>
		<cfif trim(Billback_Product_Program.Distributor_id_earned) neq "" and trim(Billback_Product_Program.Distributor_id_earned) neq '00000000-0000-0000-0000-000000000000'>
			<strong>#Get_Dist_Info.Ship_To#</strong>&nbsp;(#Get_Dist_Info.name#&nbsp;::&nbsp;#Get_Dist_Info.city#,&nbsp;::&nbsp;#Get_Dist_Info.state#)
		 <cfelse>
		 	No <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>
		 </cfif>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%">
		<CFIF BSA_Foodservice_Items_Master_ID NEQ "">
		<B>Product: #Billback_Product_Program.Item# #Billback_Product_Program.UPC# #Billback_Product_Program.Description#</B> (Net Weight = #Net_Weight#) (#ListGetAt(Discount_Type_List, BB_Product_Type_ID, ",")#)
		<CFELSE>
		<B>Product: <font color="red">Not found in the system</font></B>
		</CFIF>
		</TD>
	</TR>
	<CFIF ProductLost EQ 1>
	<TR>
		<TD COLSPAN="100%">

		<B><font color="Red">This item has 100% rate deviation either because the item or proposal was marked as lost, or because the proposal was never updated as won/lost/split.</font></b>
		</TD>
	</TR>
	</CFIF>


</TABLE>

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getUseGPO">
	SELECT	dbo.udf_UseGPO('#Billback_Product_Program.Billback_ID#', #Billback_Product_Program.Uploaded_Billback#) as UseGPO
</CFQUERY>
<cfset bUseGPO = getUseGPO.UseGPO />

<cfif distributor_unauthorized eq 1>
	<BR>
	<B><FONT COLOR="Red">This distributor is not authorized to billback against this program</FONT></B>
	<BR>
<cfelseif Billback_Product_Program.Manual_Cancel EQ 1>
	<BR>
	<B><FONT COLOR="Red">Rate Deviated 100% because Program was canceled</FONT></B>
	<BR>
<cfelseif bUseGPO EQ 1>
	<!---- Get GPO details ---->
	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getCustomBillbackInfo">
		select	Tier
		from	Billback_Allied
		where	Billback_ID = <cfqueryparam value='#Billback_Product_Program.Billback_ID#' cfsqltype="cf_sql_varchar">
	</CFQUERY>

	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getCustomBillbackProgramInfo">
		select	Billback_Program_ID = bpg.Billback_Program_ID,
				Contract_Main_ID = bpg.Program_ID,
				cleansed_CPA = cm.Contract_Reference_Number,
				Contract_Number = cm.Contract_Number,
				Discount_Identifier_Number = di.Discount_Identifier_Number,
				Override_Price_List_Id = aux.Override_Price_List_Id
		from	Billback_Program bpg
		inner join Contract_Main cm
		on		cm.Contract_Main_ID = bpg.Program_ID
		inner join Contract_Main_Aux_Data aux
		on		aux.Contract_Main_ID = cm.Contract_Main_ID
		inner join Program_Control_Panel_Options t
		on		t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
		inner join Discount_Identifier di
		on		di.Discount_Identifier_ID = t.Discount_Identifier_ID
		where	bpg.Billback_ID = <cfqueryparam value='#Billback_Product_Program.Billback_ID#' cfsqltype="cf_sql_varchar">
		and		bpg.Deleted = 0
	</CFQUERY>

	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getCustomProgramOperator">
		select 	G.GPO_Key,
				G.Operator_GPO_ID,
				ISNULL(CO.Group_Level_ID, 0) as Group_Level_ID,
				CO.Group_Level_Desc,
				CASE ISNULL(CO.Group_Level_ID, 0)
					WHEN '0' THEN 'GPO Key'
					WHEN '1' THEN 'Top Parent Name 1'  -- Operator_Number_Of_Locations
					WHEN '2' THEN 'Top Parent Name 2'  -- Operator_Phone
					WHEN '3' THEN 'Direct Parent Name 1'  -- Operator_First_Name
					WHEN '4' THEN 'Direct Parent Name 2' -- Operator_Last_Name
					WHEN '5' THEN 'End User Parent' -- Operator_DBA
					WHEN '6' THEN 'End User Child' -- Operator_Priority.Priority_Label
					ELSE ''
				END AS Level
		from	Billback_Program bpg
		inner join Contract_Main cm
		on		cm.Contract_Main_ID = bpg.Program_ID
		INNER join Contract_Operators CO
		on		CO.Contract_Main_ID = cm.Contract_Main_ID
		and		CO.Is_group = 1
		and		CO.Deleted = 0
		LEFT JOIN Operator_GPO G
		ON		G.Operator_GPO_ID = CO.Operator_Group_ID_Int
		where	bpg.Billback_ID = <cfqueryparam value='#Billback_Product_Program.Billback_ID#' cfsqltype="cf_sql_varchar">
		and		bpg.Deleted = 0
	</CFQUERY>

	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getCustomExpectedRateCalcDetail">
		select	cd.*,
				CASE cd.Unit_Of_Measure_ID WHEN 1 THEN '/CS' WHEN 2 THEN '/LB' WHEN 3 THEN '%' END as UOM,
				opr.Legacy_ID as Operator_Number, opr.Operator_Name,
				locationOpr.Legacy_ID as Location_Operator_Number, locationOpr.Operator_Name as Location_Operator_Name,
				G.GPO_Key as Location_Operator_GPO_Key,
				<cfif getCustomProgramOperator.Group_Level_ID EQ "1">
					locationOpr.Operator_Number_Of_Locations
				<cfelseif getCustomProgramOperator.Group_Level_ID EQ "2">
					locationOpr.Operator_Phone
				<cfelseif getCustomProgramOperator.Group_Level_ID EQ "3">
					locationOpr.Operator_First_Name
				<cfelseif getCustomProgramOperator.Group_Level_ID EQ "4">
					locationOpr.Operator_Last_Name
				<cfelseif getCustomProgramOperator.Group_Level_ID EQ "5">
					locationOpr.Operator_DBA
				<cfelseif getCustomProgramOperator.Group_Level_ID EQ "6">
					Operator_Priority.Priority_Label
				<cfelse>
					''
				</cfif> as Operator_Group_Level_Desc
		from	BB_item_Invoice_Level i
		inner join BB_Custom_Expected_Rate_Calc_Detail cd on cd.BB_item_Invoice_Level_ID = i.BB_item_Invoice_Level_ID
		left join BSA_Operator opr on opr.BSA_Operator_ID = i.Operator_ID
		left join Operator_Priority ON Operator_Priority.Operator_Priority_ID = opr.Operator_Priority_ID
		left join BSA_Operator locationOpr on locationOpr.BSA_Operator_ID = i.Location_Operator_ID
		left join Operator_GPO g ON g.Operator_GPO_ID = locationOpr.Operator_GPO_ID
		where	i.Billback_Product_ID = <cfqueryparam value='#BBproductId#' cfsqltype="cf_sql_varchar">
		and		i.Discount_Type_ID = <cfqueryparam value='#BB_Product_Type_ID#' cfsqltype="cf_sql_varchar">
		and		i.Deleted = 0
	</CFQUERY>
	<!--------------------------------- Variables ------------------------------------------>
	<cfset Tier = Val(getCustomBillbackInfo.Tier) />
	<cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css"/>
	<style>
	##datagrid {
		width: 100%;
	}
	table.datagrid {
		border: 0;
		table-layout: fixed;
	}
	table.datagrid td, table.datagrid th {
		word-wrap: break-word;
		vertical-align: top;
		font-size : 10px;
	}
	table.datagrid th {
		text-align: left;
	}
	table.datagrid td.right {
		text-align: right;
	}
	</style>


	<br>
	<table cellpadding="0" cellspacing="2" border="0" width="#Table_Width#">
		<tr>
			<CFIF BB_Product_Type_ID EQ 1>
			<td><b>Program Type:</b> #getCustomBillbackProgramInfo.Discount_Identifier_Number#</td>
			<td>
				<cfif getCustomExpectedRateCalcDetail.Family_Strategic eq 1>Strategic<cfelse>Non-Strategic</cfif> /
				<cfif getCustomExpectedRateCalcDetail.Family_Network eq 1>Network<cfelse>Non-Network</cfif>
			</td>
			<td>
				<b>Program Acute/Non-Acute:</b> #getCustomExpectedRateCalcDetail.Program_Acute#
			</td>
			</CFIF>
			<cfif getCustomBillbackProgramInfo.Discount_Identifier_Number EQ "GPO" and BB_Product_Type_ID EQ 1>
			<td><b>Tier:</b> #getCustomBillbackInfo.Tier#</td>
			</cfif>
		</tr>
		<cfif getCustomProgramOperator.recordCount>
		<tr>
			<td><b>GPO Key:</b> #getCustomProgramOperator.GPO_Key#</td>
			<td><cfif getCustomProgramOperator.Group_Level_ID NEQ "0"><b>#getCustomProgramOperator.Level#:</b> #getCustomProgramOperator.Group_Level_Desc#</cfif></td>
		</tr>
		</cfif>
	</table>
	<br>
	<table id="tCustomExpDetails" class="datagrid">
		<col width="15%"> <!--- End User --->
		<col width="15%"> <!--- Facility --->
		<cfif getCustomProgramOperator.recordCount>
		<col width="10%"> <!--- Group --->
		</cfif>
		<col width="10%"> <!--- Price List --->
		<col width="10%"> <!--- Price/CS --->
		<col width="10%"> <!--- Fixed Price --->
		<col width="10%"> <!--- Expected Rate/CS --->
		<col width="20%"> <!--- Message --->
		<thead>
		<tr>
			<th>End User</th>
			<th>Facility</th>
			<cfif getCustomProgramOperator.recordCount>
			<th>GPO Key<cfif getCustomProgramOperator.Group_Level_ID NEQ "0">/#getCustomProgramOperator.Level#</cfif></th>
			</cfif>
			<th>Price List</th>
			<th>Price</th>
			<th><CFIF BB_Product_Type_ID EQ 1>Fixed Price<CFELSE>Rebate</CFIF></th>
			<th>Expected Rate</th>
			<th>Message</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="getCustomExpectedRateCalcDetail">
			<cfset Product_Price_LB = Val(Product_Price_CS) / Net_Weight />
			<cfset Expected_Rate_LB = Val(Expected_Rate_CS) / Net_Weight />
		<tr>
			<td>#Operator_Name# (#Operator_Number#)<br>
			#Operator_Rebate_Account_Type#<br>
			</td>
			<td>#Location_Operator_Name# <cfif Location_Operator_Number neq "">(#Location_Operator_Number#)</cfif>
			<cfif getCustomProgramOperator.recordCount>
			<td>#Location_Operator_GPO_Key#<br>#Operator_Group_Level_Desc#
			</cfif>
			<td>#Price_List_Type#</td>
			<td class="right"><cfif Product_Price_CS NEQ "">#Product_Price_CS# / CS<br>#Product_Price_LB# / LB</cfif>
			</td>
			<td class="right">
				<cfif Unit_Of_Measure_ID EQ 1>
					<cfset Program_Price_CS = Program_Price_Rate />
					<cfset Program_Price_LB = Program_Price_Rate / Net_Weight />
					#Program_Price_CS# / CS<br>
					#Program_Price_LB# / LB
				<cfelseif Unit_Of_Measure_ID EQ 2>
					<cfset Program_Price_CS = Program_Price_Rate * Net_Weight />
					<cfset Program_Price_LB = Program_Price_Rate />
					#Program_Price_CS# / CS<br>
					#Program_Price_LB# / LB
				<cfelseif Unit_Of_Measure_ID EQ 3>
					#Program_Price_Rate# #UOM#
				<cfelse>
					Not found
				</cfif>
			</td>
			<td class="right">#Expected_Rate_CS# / CS <br>
				#Expected_Rate_LB# / LB
			</td>
			<td><cfif Zero_Expected_Rate>#Zero_Expected_Rate_Message#</cfif></td>
		</tr>
		</cfloop>
		</tbody>
	</table>

	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables2.cfm">
	<script>
			window.resizeTo(1050, 650);

			var myDataGrid = jQuery('##tCustomExpDetails').DataTable({
					  "autoWidth": false
					  ,"columns": [  {"orderable":true,  "searchable":false }   // End User
									,{"orderable":true,  "searchable":false }   // Facility
								    ,{"orderable":true,  "searchable":false }   // Group
									,{"orderable":true,  "searchable":false }   // Price List
									,{"orderable":true,  "searchable":false, "type":"html-num" }   // Price/CS
									,{"orderable":true,  "searchable":false, "type":"html-num" }   // Fixed Price
									,{"orderable":true,  "searchable":false, "type":"html-num" }   // Expected Rate/CS
									,{"orderable":true,  "searchable":false }   // Message
									]
					  ,"dom": "ti"
					  ,"language": { search: ":", paginate: { previous:"prev", next:" next" }  }
					  ,"paging": false
					  ,"order": []
					  ,"orderClasses": false
					  ,"scrollCollapse": true
					  ,"scrollY": Math.floor(jQuery(window).height()) - 220
					});
		</script>

<CFELSEIF BSA_Foodservice_Items_Master_ID NEQ "">
<CFSILENT>


<cfset Fob_Price_Indicator = bbDeviationManager.getComponentFobPriceIndicator(
		Billback_ID = Billback_ID,
		Program_Number = Program_Number,
		BB_Payee_Type_ID = BB_Payee_Type_ID,
		Billback_Start_Date = Billback_Start_Date,
		Billback_End_Date = Billback_End_Date,
		BB_Product_Type_ID = BB_Product_Type_ID
	   ) />

<cfset Invoice_Type_Filter_List = "" />
<cfset Invoice_Type_Exclude_List = "" />
<cfset Setting_REDI_Invoice_Type_List = appSettings.get_Setting('REDI_Invoice_Type_List') />
<cfif 		appSettings.get_Setting('Oper_REDI_BB_Only_Include_REDI_Invoice') eq "1"
	  and	Setting_REDI_Invoice_Type_List neq ""
	  and	BB_Payee_Type_ID eq 1>

	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getBBPayeeDistributorIsREDI">
		SELECT	1
		FROM	Billback_Distributor
		INNER JOIN BSA_Foodservice_Customers
		ON		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
		INNER JOIN Distributor_Type_C tc on tc.Distributor_Type_C_ID = BSA_Foodservice_Customers.Distributor_Type_C_ID
		INNER JOIN Distributor_Type_D td on td.Distributor_Type_D_ID = BSA_Foodservice_Customers.Distributor_Type_D_ID
		WHERE	Billback_Distributor.Billback_ID = <cfqueryparam value='#Billback_ID#'>
		AND		Billback_Distributor.Deleted = 0
		AND		td.Distributor_Type_D = 'ZSDT'
		AND		tc.Distributor_Type_C = 'RE'
	</CFQUERY>

	<cfif getBBPayeeDistributorIsREDI.RecordCount> <!--- If Payee is ZSDT/RE, exclude YRD, YRRD --->
		<cfset Invoice_Type_Exclude_List = Setting_REDI_Invoice_Type_List />
	<cfelse>
		<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getBBVendorIsREDI">
			SELECT	1
			FROM	Billback_Distributor
			INNER JOIN BSA_Foodservice_Customers
			ON		BSA_Foodservice_Customers.Shr_Ship_To = Billback_Distributor.Uploaded_Vendor_ID
			INNER JOIN Distributor_Type_C tc on tc.Distributor_Type_C_ID = BSA_Foodservice_Customers.Distributor_Type_C_ID
			INNER JOIN Distributor_Type_D td on td.Distributor_Type_D_ID = BSA_Foodservice_Customers.Distributor_Type_D_ID
			WHERE	Billback_Distributor.Billback_ID = <cfqueryparam value='#Billback_ID#'>
			AND		Billback_Distributor.Deleted = 0
			AND		Len(Billback_Distributor.Uploaded_Vendor_ID) != 0
			AND		td.Distributor_Type_D = 'ZSDT'
			AND		tc.Distributor_Type_C = 'RE'
		</CFQUERY>
		<cfif getBBVendorIsREDI.RecordCount> <!--- If vendor is ZSDT/RE and Payee is not ZSDT/RE, include YRD, YRRD --->
			<cfset Invoice_Type_Filter_List = Setting_REDI_Invoice_Type_List />
		</cfif>
	</cfif>
</cfif>

<!--------------------------------------------
Start date overlap along with each revisions
to find out the rate
--------------------------------------------->

	<CFQUERY DBTYPE="QUERY" NAME="Get_All_Dates">
	SELECT	Billback_ID, Start_Date AS This_Date, Doc_Type + 0 AS Date_Type, Product_Rate, #ListLast(Rate_ID_FieldName, ".")#, Revision_Program_ID
	FROM	Billback_Program_Dates
	UNION
	SELECT	Billback_ID, End_Date AS This_Date, Doc_Type + 2 AS Date_Type, Product_Rate, #ListLast(Rate_ID_FieldName, ".")#, Revision_Program_ID
	FROM	Billback_Program_Dates
	</CFQUERY>

	<CFQUERY DBTYPE="QUERY" NAME="Get_All_Dates_Ordered">
	SELECT	Billback_ID, This_Date, Date_Type, Product_Rate, #ListLast(Rate_ID_FieldName, ".")#, Revision_Program_ID
	FROM	Get_All_Dates
	ORDER BY 	This_Date, DATE_TYPE
	</CFQUERY>
	<!------ <cfdump var="#Get_All_Dates_Ordered#"><cfabort> ----->

	<CFSET P_Total_Days_With_Product= 0>
	<CFSET This_Billback_Intervals	= "">
	<CFSET Other_Billbacks_Started 	= 0>
	<CFSET This_Billback_Started 	= false>
	<CFSET Start_Counting			= false>
	<CFSET D_First_Date				= "">
	<CFSET D_Last_Date				= "">
	<CFSET Stop_Loop				= false>
	<CFSET last_Mile_Stone			= "">
	<CFSET this_Rate				= "norate">
	<CFSET Rate_ID_FieldValue		= "">
	<CFSET Proper_Date_Span			= "">
	<cfset revProgramId				= "">
	<cfset arRevisionProperties = ArrayNew(1)>

	<CFLOOP QUERY="Get_All_Dates_Ordered">
		<CFIF Get_All_Dates_Ordered.Date_Type EQ 0>
			<!----- Other Billback STart ---->
			<CFIF This_Billback_Started EQ true>
				<CFSET Start_Counting = true>
				<CFIF Other_Billbacks_Started LTE 0>
					<CFSET D_First_Date	= Get_All_Dates_Ordered.This_Date>
					<CFIF DATEDIFF("d", last_Mile_Stone, Get_All_Dates_Ordered.This_Date) GTE 0>
					</CFIF>
				</CFIF>
			</CFIF>
			<CFSET Other_Billbacks_Started 	= Other_Billbacks_Started + 1>
			<CFSET this_Rate				= Get_All_Dates_Ordered.Product_Rate>
			<cfset revProgramId				= Get_All_Dates_Ordered.Revision_Program_ID>
			<CFSET Rate_ID_FieldValue		= Evaluate("Get_All_Dates_Ordered.#ListLast(Rate_ID_FieldName, ".")#")>
		<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 1>
			<!---- This Billback Start ---->
			<CFSET This_Billback_Started 	= true>
			<CFIF Other_Billbacks_Started GT 0>
				<CFSET Start_Counting = true>
				<CFSET D_First_Date	= Get_All_Dates_Ordered.This_Date>
			</CFIF>
			<CFSET last_Mile_Stone			= Get_All_Dates_Ordered.This_Date>
		<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 2>
			<!---- Other billback End ---->
			<CFSET Other_Billbacks_Started 	= Other_Billbacks_Started - 1>
			<CFIF Other_Billbacks_Started LTE 0>
				<CFIF Start_Counting>
					<CFSET D_Last_Date	= Get_All_Dates_Ordered.This_Date>
					<CFIF IsDate(D_First_Date) AND IsDate(D_Last_Date)>
						<CFIF DATEDIFF("d", D_First_Date, D_Last_Date) GTE 0>
							<CFSET P_Total_Days_With_Product = P_Total_Days_With_Product + DATEDIFF("d", D_First_Date, D_Last_Date) + 1>
							<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#D_First_Date#~#D_Last_Date#~#Rate_ID_FieldValue#~#this_Rate#", ",")>
							<CFSET Proper_Date_Span			= ListAppend(Proper_Date_Span, D_First_Date, ",")>
							<CFSET Proper_Date_Span			= ListAppend(Proper_Date_Span, D_Last_Date, ",")>

							<!------ populate array ----->
							<cfset ArrayAppend(arRevisionProperties, getStRevisionProperties(D_First_Date, D_Last_Date, Rate_ID_FieldValue, this_Rate, revProgramId))>
						</CFIF>
						<CFSET last_Mile_Stone			= DateAdd("d", 1, Get_All_Dates_Ordered.This_Date)>
					</CFIF>
				</CFIF>
				<CFSET Start_Counting = false>
			</CFIF>
			<CFSET this_Rate				= 0>
			<cfset revProgramId				= "">
			<CFSET Rate_ID_FieldValue		= "">
		<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 3>
			<!----- This Billback End ---->
			<CFIF Start_Counting>
				<CFSET D_Last_Date	= Get_All_Dates_Ordered.This_Date>
				<CFIF IsDate(D_First_Date) AND IsDate(D_Last_Date)>
					<CFIF DATEDIFF("d", D_First_Date, D_Last_Date) GTE 0>
						<CFSET P_Total_Days_With_Product = P_Total_Days_With_Product + DATEDIFF("d", D_First_Date, D_Last_Date) + 1>
						<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#D_First_Date#~#D_Last_Date#~#Rate_ID_FieldValue#~#this_Rate#", ",")>
						<CFSET Proper_Date_Span			= ListAppend(Proper_Date_Span, D_First_Date, ",")>
						<CFSET Proper_Date_Span			= ListAppend(Proper_Date_Span, D_Last_Date, ",")>

						<!------ populate array ----->
						<cfset ArrayAppend(arRevisionProperties, getStRevisionProperties(D_First_Date, D_Last_Date, Rate_ID_FieldValue, this_Rate, revProgramId))>
					</CFIF>
				</CFIF>
			</CFIF>
			<CFSET This_Billback_Started 	= false>
			<CFSET Stop_Loop				= true>
			<CFSET Start_Counting			= false>
		</CFIF>
		<CFIF Stop_Loop>
			<CFBREAK>
		</CFIF>
	</CFLOOP>
</CFSILENT>
<STYLE>
TR.MaintableTHEAD TD
{
	font-size : 11px;
	border-bottom:solid 93BEE2 0px;
	font-weight : bold;
}
</STYLE>
<!-----------------------------------------
Display the rates across each revision
------------------------------------------>
<cfset arRevisionPropertiesLen = ArrayLen(arRevisionProperties)>
	<CFSILENT>
	<CFSET Total_Weighted_Rate=0>
	<CFSET counter=1>
	<CFSET Valid_Billback_Total_Days=0>
	<CFSET Invoice_First_Date_For_Rabate 	= Now()>
	<CFSET Invoice_Last_Date_For_Rabate 	= Now()>

	<!--- BJF: In some setting configurations these were never getting set. This should usually get overwritten --->
	<CFSET 	Sample_Size_End_Date = Billback_End_Date>
	<CFSET 	Sample_Size_Start_Date= Billback_Start_Date>

	<cfif arRevisionPropertiesLen GT 0>
		<CFSET first_Date_Set 					= arRevisionProperties[1]>
		<CFSET last_Date_Set 					= arRevisionProperties[arRevisionPropertiesLen]>
		<CFSET Invoice_First_Date_For_Rabate 	= first_Date_Set.firstDate>
		<CFSET Invoice_Last_Date_For_Rabate 	= last_Date_Set.lastDate>
	</cfif>
	<CFIF appSettings.getBBDateDevInExpectedVol() EQ 1><!--- If date mismatch with program is already taken care of in volume, don't take it out of rate  ---->
		<CFSET Valid_Billback_Total_Days = P_Total_Days_With_Product>
	<CFELSEIF BB_Product_Type_ID EQ 2 OR appSettings.getBBFixedCalcTypesOn() EQ 1>
		<CFSET Valid_Billback_Total_Days = DateDiff("d", Billback_Start_Date, Billback_End_Date) + 1>
	<CFELSE>
		<!---- For fixed and formula, as date increase, price decrease ----->
		<CFSET Valid_Billback_Total_Days = P_Total_Days_With_Product>
	</CFIF>

	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Volume_Tolerance">
	SELECT
			BB_TET AS BB_Tolerance_TET
	FROM	BB_Basic_Setting_Detail
	WHERE
			Billback_ID = <cfqueryparam value='#Billback_ID#'> AND
		Contract_Main_Id = <cfqueryparam value=#Billback_Program_Program_ID#>
	</CFQUERY>

	 </CFSILENT>

	<!------ Find all the rates ----->
	<cfset arBillbackRateDisplay = ArrayNew(1)>
	<cfset invalidDatesTobeRemovedFromTotalValidSpan = 0>

	<!------ <CFIF ListLen(This_Billback_Intervals,",") GT 0> ----->
	<cfif arRevisionPropertiesLen GT 0>
		<CFSET P_Valid_Discount_Type = 1>
	<CFELSE>
		<CFSET P_Valid_Discount_Type = 0>
	</CFIF>
<cfif arRevisionPropertiesLen GT 0><!----- if no version of the program that mathes date was found, no need to show this information ----->
	<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND _Setting_Dist_Trade_Deviation_Tolerance_Override neq '1'>
		<cfif _Setting_BB_Start_Offset_Days GT 0 OR _Setting_BB_End_Offset_Days GT 0>
			<CFOUTPUT>
			<!--------------------- Show how we arrived at the sample size --------------->
			<CFSET Open_layer_Desc="Invoice Sample Size Details">
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"
				BorderColor="#BorderColor#"
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="#Open_layer_Desc#"
				TitleClosed="#Open_layer_Desc#"
				TitleTooltip="#Open_layer_Desc#"
				TitleColor="#TitleColor#"
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="Yes"
				Width="#width#"
				AddScript="#AddScript#">
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
					<cfif _Setting_BB_Start_Offset_Days GT 0>
					<TR>
						<TD>BB Delivery Start Date Offset</TD>
						<TD>&nbsp;</TD>
						<TD>#_Setting_BB_Start_Offset_Days# day(s)</TD>
					</TR>
					<cfset Sample_Size_Start_Date = DateAdd("d", _Setting_BB_Start_Offset_Days * -1, Sample_Size_Start_Date) />
					</cfif>

					<cfif _Setting_BB_End_Offset_Days GT 0>
					<TR>
						<TD>BB Delivery End Date Offset</TD>
						<TD>&nbsp;</TD>
						<TD>#_Setting_BB_End_Offset_Days# day(s)</TD>
					</TR>
					<cfset Sample_Size_End_Date = DateAdd("d", _Setting_BB_End_Offset_Days, Sample_Size_End_Date) />
					</cfif>

					<TR>
						<TD>Invoice Sample</TD>
						<TD>&nbsp;</TD>
						<TD>#DateFormat(Sample_Size_Start_Date, "mm/dd/yyyy")# - #DateFormat(Sample_Size_End_Date, "mm/dd/yyyy")#</TD>
					</TR>
				</TABLE>
			</CF_openLayer>
			</CFOUTPUT>
			<BR><BR>
		</cfif>
	<CFELSE>
		<!------ TODO: Dates has to be adjusted to take care of revisions ----->
		<!------ use ED - 2(Y - Xn + X1-(n-1)) ----->
		<CFOUTPUT>
		<!--------------------- Show how we arrived at the sample size --------------->
		<CFSET Open_layer_Desc="Invoice Sample Size Details">
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"
			BorderColor="#BorderColor#"
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="#Open_layer_Desc#"
			TitleClosed="#Open_layer_Desc#"
			TitleTooltip="#Open_layer_Desc#"
			TitleColor="#TitleColor#"
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="Yes"
			Width="#width#"
			AddScript="#AddScript#">
			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
				<TR>
					<TD>Valid Billback Delivery Interval</TD>
					<TD>&nbsp;</TD>
					<TD>#DateFormat(Invoice_First_Date_For_Rabate, "mm/dd/yyy")#  -  #DateFormat(Invoice_Last_Date_For_Rabate, "mm/dd/yyyy")#</TD>
				</TR>
				<cfset Valid_Billback_Delivery_Interval = DateDiff("d", Invoice_First_Date_For_Rabate, Invoice_Last_Date_For_Rabate) + 1>
				<TR>
					<TD>Billback No of Days</TD>
					<TD>&nbsp;</TD>
					<TD>#Valid_Billback_Delivery_Interval#</TD>
				</TR>
				<CFIF BB_D_Template_Overrides_Deviation_Tolerances EQ 1><!--- BB_D_Purchase_Period_OverRide_Rate --->
					<CFSET Sample_Size =  BB_D_Purchase_Period_OverRide_Rate>
					<CFSET 	Sample_Size_End_Date = Billback_End_Date>
					<!--- Do not consider 0,as then the "Sample_Size_Start_Date" will have (+ 1) date which sometimes (billback is for a day only)
					could go beyond the "Sample_Size_End_Date". --->
					<cfif BB_D_Purchase_Period_OverRide_Rate neq 0>
					<CFSET 	Sample_Size_Start_Date=DateAdd("d", (BB_D_Purchase_Period_OverRide_Rate * -1) + 1, Sample_Size_End_Date)>
					</cfif>
					<TR>
						<TD>Template Purchase Period Over Ride</TD>
						<TD>&nbsp;</TD>
						<TD>#BB_D_Purchase_Period_OverRide_Rate#</TD>
					</TR>

				<CFELSE>
					<TR>
						<TD>#application.returned_customer_setting.distributor_label_singular# Purchase Period Ratio</TD>
						<TD>&nbsp;</TD>
						<TD>#Billback_Rate_Tolerance.BB_Tolerance_DPP#</TD>
					</TR>
					<CFSET Sample_Size = Valid_Billback_Delivery_Interval * Billback_Rate_Tolerance.BB_Tolerance_DPP>
					<TR>
						<TD>Sample Size</TD>
						<TD>#Valid_Billback_Delivery_Interval# * #Billback_Rate_Tolerance.BB_Tolerance_DPP# = </TD>
						<TD>#Sample_Size#</TD>
					</TR>
					<TR>
						<TD>#application.returned_customer_setting.distributor_label_singular# Purchase Period Offset</TD>
						<TD>&nbsp;</TD>
						<TD>#Billback_Rate_Tolerance.BB_Tolerance_DPPO# days</TD>
					</TR>
					<CFSET 	Purchase_Period_Buffer=DateAdd("d", (Billback_Rate_Tolerance.BB_Tolerance_DPPO * -1) + 1, Billback_End_Date)>
					<TR>
						<TD>#application.returned_customer_setting.distributor_label_singular# Purchase Period Buffer</TD>
						<TD>&nbsp;</TD>
						<TD>
						<CFIF DateDiff("d", Purchase_Period_Buffer, Billback_End_Date) GTE 0>
						#DateFormat(Purchase_Period_Buffer, "mm/dd/yyyy")# - #DateFormat(Billback_End_Date, "mm/dd/yyyy")#
						<CFELSE>
						No Buffer
						</CFIF>
						</TD>
					</TR>
						<CFSET 	Sample_Size_End_Date=DateAdd("d", -1, Purchase_Period_Buffer)>
						<CFSET 	Sample_Size_Start_Date=DateAdd("d", (Sample_Size * -1) + 1, Sample_Size_End_Date)>

				</CFIF>
				<TR>
					<TD>Invoice Sample</TD>
					<TD>&nbsp;</TD>
					<TD>#DateFormat(Sample_Size_Start_Date, "mm/dd/yyyy")# - #DateFormat(Sample_Size_End_Date, "mm/dd/yyyy")#</TD>
				</TR>

				<TR>
					<TD>Eligibility Trigger</TD>
					<TD>&nbsp;</TD>
					<TD>
					#ListGetAt(DEVIATION_CONSTANTS_Trade_Eligibility_Triggers, Billback_Rate_Tolerance.BB_Tolerance_TET, ",")#
					</TD>
				</TR>
			</TABLE>
			<CFSET 	Current_Sample_Size_End_Date = Sample_Size_Start_Date>
		</CF_openLayer>
		</CFOUTPUT>
	</CFIF>


	<CFIF Billback_Volume_Tolerance.BB_Tolerance_TET EQ 1>
		<CFSET check_Date="Invoice_Header.Invoice_Date">
	<CFELSE>
		<CFSET check_Date="Invoice_Header.Ship_Date">
	</CFIF>

	<cfset useLakebaseForGet_BB_Tolerance_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_tolerance_settings")>
<cfif useLakebaseForGet_BB_Tolerance_Settings>
	<cftry>
		<cfset Get_BB_Tolerance_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_tolerance_settings", {
				"select" = "auto_deviation_family_level"
			}), "auto_deviation_family_level"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_BB_Tolerance_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_BB_Tolerance_Settings>
<cfquery NAME="Get_BB_Tolerance_Settings" DATASOURCE="#application.datasource#">
		SELECT Auto_Deviation_Family_Level FROM Billback_Tolerance_Settings
	</cfquery>
</cfif>

	<cfif Use_MSA_Data>
		<cfset Fob_Price_Indicator = "X" />
	</cfif>

	<!----- Get the invoice, in case any component in rebate has percent UOM ----->
	<cfquery cachedWithin="#variables.cachedWithin#" NAME="Get_Invoice_For_This_Distributor_For_Rebate" DATASOURCE="#application.datasource#">

		IF OBJECT_ID('tempdb..##tempDistProd') IS NOT NULL
		DROP TABLE ##tempDistProd

		CREATE TABLE ##tempDistProd(
		       Distributor_ID uniqueidentifier,
		       Product_id uniqueidentifier,
		       Billback_Program_ID uniqueidentifier,
		       Billback_Product_ID uniqueidentifier,
		       Family_ID uniqueidentifier
		)


      <cfif Get_BB_Tolerance_Settings.Auto_Deviation_Family_Level EQ 0 OR BB_Payee_Type_ID NEQ 1>
	       BEGIN
	              Insert into ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)
	              Select Distinct Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID, '00000000-0000-0000-0000-000000000000' as Family_ID
	              from   Billback_Product
	              Where Billback_Product.Billback_Product_ID = <cfqueryparam value='#BBproductId#'>
	              and    deleted = 0
	       END
       <cfelse>
	       BEGIN
	              <!--- family exists in settings to be considered for auto deviation --->
	              INSERT INTO ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)

	              SELECT DISTINCT fam.BSA_Foodservice_Customers_ID as Distributor_ID,Product_Id, Billback_Program_ID, Billback_Product_ID ,BPC.Family_ID
	              FROM   Billback_Product
	              INNER JOIN  BSA_Foodservice_Customers BPC
	              ON            BPC.BSA_Foodservice_Customers_ID = Billback_Product.Distributor_ID
	              INNER JOIN  BSA_Foodservice_Customers fam
	              ON            fam.Family_ID = BPC.Family_ID
	              AND           fam.Ship_To <> 'Group'
	              WHERE Billback_Product.Billback_Product_ID = <cfqueryparam value='#BBproductId#'>
	              AND    Billback_Product.deleted = 0
	              AND   EXISTS (SELECT  * FROM Auto_Match_Deviation_Family S WHERE BPC.Family_ID  = S.Family_ID AND S.Auto_Deviation_Family =1)

	              <!--- family does not exists in settings for auto deviation--->
	              INSERT INTO ##tempDistProd (  Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID,Family_ID)

	              SELECT DISTINCT Distributor_ID, Product_Id, Billback_Program_ID, Billback_Product_ID, '00000000-0000-0000-0000-000000000000' as Family_ID
	              FROM   Billback_Product
	              INNER JOIN  BSA_Foodservice_Customers BPC
	              ON            BPC.BSA_Foodservice_Customers_ID = Billback_Product.Distributor_ID
	              WHERE Billback_Product.Billback_Product_ID = <cfqueryparam value='#BBproductId#'>
	              AND    Billback_Product.deleted = 0
	              AND    NOT EXISTS (SELECT * FROM Auto_Match_Deviation_Family S WHERE  BPC.Family_ID  = S.Family_ID AND S.Auto_Deviation_Family =1)
	       END
	</cfif>

	<cfif Use_MSA_Data EQ 1>
		<!---
		For MSA programs:
		When payee is distributor, we will include MSA data for all operators in the program and associated distributor.
		When payee is operator, we will include MSA data for the payee and associated distributor
		--->
		IF OBJECT_ID('tempdb..##tmp_program_operators') IS NOT NULL
		DROP TABLE ##tmp_program_operators

		<cfif BB_Payee_Type_ID EQ 2>
			SELECT	Operator_ID as BSA_Operator_ID
			INTO	##tmp_program_operators
			FROM	Billback_Operator
			WHERE	Billback_Operator.Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Billback_ID#" />
			AND		Billback_Operator.Deleted = <cfqueryparam value=0>
		<cfelse>
			SELECT	Contract_Operators.BSA_Operator_ID
			INTO	##tmp_program_operators
			FROM	Contract_Operators
			WHERE	Contract_Operators.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Program_ID#" />
			AND		Contract_Operators.Deleted = <cfqueryparam value=0>
		</cfif>
	</cfif>

		SELECT	ISNULL(CAST(<CFIF Billback_UOM EQ 1>CS_Unit_Price
				<CFELSE>LB_Unit_Price
				</CFIF> AS FLOAT), 0) AS UOM_Unit_Price ,
				ISNULL(CAST(<CFIF Billback_UOM EQ 1>Cases_Invoiced
				<CFELSE>Pounds_Invoiced
				</CFIF> AS FLOAT), 0) AS UOM_Volume_Invoiced,
				ISNULL(Gross_Sales_Dollars, 0) Gross_Sales_Dollars,
				Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number AS Invoice_Number,
				#check_Date# AS Invoice_Check_Date
		FROM	Invoice_Header
				INNER JOIN Invoice_Detail
				ON
				Invoice_Detail.Deleted = 0
				<cfif appSettings.getCheckOrderClass()>
				AND Invoice_Detail.Order_Class IN (#ListQualify(appSettings.getOrderClassValue(), "'", ",")#)
				</cfif>
				AND Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
				AND Invoice_Detail.BSA_Foodservice_Items_Master_ID IN ('#BSA_Foodservice_Items_Master_ID#'<cfif ProductReplacementID neq "">,'#ProductReplacementID#'</cfif>)
				AND	ISNULL(Invoice_Detail.FOB_PRICE_IND, 'N') IN (#ListQualify(Fob_Price_Indicator, "'", ",")#)
				/* 21605 - Commenting the below based on the discussion with PAUL.
				Paul said we need to count the records with Operator if the FOB indicator is not in the above list
				*/
				--- D22024 -- Uncommenting the Operator and commenting the Negative CS check -- We should do 21756 only in fixed rate
				<cfif Use_MSA_Data eq 0>
				AND ISNULL(Invoice_Detail.BSA_Operator_ID, 0) = 0
				</cfif>
				AND ISNULL(Cast(Invoice_Detail.Cases_Invoiced as float), 0) > 0
		WHERE
				<CFIF IsDefined("Sample_Size_Start_Date") AND IsDefined("Sample_Size_End_Date")>
					<CFIF IsDate(Sample_Size_Start_Date) AND IsDate(Sample_Size_End_Date)>
						DATEDIFF(d, #check_Date#, #CreateODBCDate(Sample_Size_Start_Date)#) <= 0
						AND
						DATEDIFF(d, #check_Date#, #CreateODBCDate(Sample_Size_End_Date)#) >= 0
					<CFELSE><!----- If date is not proper, return nothing ----->
						1 = 2
					</CFIF>
				<CFELSE><!----- If date is not proper, return nothing, may be in the case of fixed or formula ----->
					1 = 2
				</CFIF>
				AND Invoice_Header.BSA_Foodservice_Customers_ID IN (select Distributor_ID from ##tempDistProd)
				<cfif Invoice_Type_Filter_List neq "">
				AND Invoice_Header.Invoice_Type IN (#ListQualify(Invoice_Type_Filter_List, "'", ",")#)
				</cfif>
				<cfif Invoice_Type_Exclude_List neq "">
				AND Invoice_Header.Invoice_Type NOT IN (#ListQualify(Invoice_Type_Exclude_List, "'", ",")#)
				</cfif>
				<cfif Use_MSA_Data EQ 0>
					AND ISNULL(Invoice_Header.BSA_Operator_ID, 0) = 0 <!--- Do not include MSA data --->
				<cfelse>
					AND Invoice_Header.BSA_Operator_ID IN (SELECT BSA_Operator_ID FROM ##tmp_program_operators)
				</cfif>

		IF OBJECT_ID('tempdb..##tempDistProd') IS NOT NULL
		DROP TABLE ##tempDistProd

	</CFQUERY>

	<CFQUERY NAME="Get_Sum_Volume" DBTYPE="query">
		SELECT	SUM(UOM_Volume_Invoiced) AS Total_Volume_UOM
		FROM	Get_Invoice_For_This_Distributor_For_Rebate
	</CFQUERY>
	<CFSET Total_Volume_For_Percent_Calc = Get_Sum_Volume.Total_Volume_UOM>

		<CFLOOP from="1" to="#arRevisionPropertiesLen#" index="i">
		<cfset stBillbackRateDisplay = StructNew()>
		<cfset stRevisionProperties = arRevisionProperties[i]>
		<CFSET product_Rate 		= stRevisionProperties.thisRate>
		<CFSET program_ibf_Rate 		= 0 />
		<CFSET program_obf_Rate 		= 0 />
		<CFSET deliveryTypeToUse		= 0 />
		<CFIF IsNumeric(product_Rate) OR BB_Product_Type_ID EQ 2>
			<CFSET start_date 			= stRevisionProperties.firstDate>
			<CFSET end_date 			= stRevisionProperties.lastDate>
			<CFSET this_Interval_Days 	= DateDiff("d", start_date, end_date) + 1>
			<CFSET this_Rate_Weight		= (this_Interval_Days/Valid_Billback_Total_Days) * 100>
			<CFSET revisionProgramId	= stRevisionProperties.programId>
			<cfset programDelType 		= 0 />
			<cfset warehouseMasterId 	= 0 />
			<cfif AppSettings.getShow_Fixed_Freight() eq 1>
				<cfquery cachedWithin="#variables.cachedWithin#" NAME="qGetProgramDelivertType" DATASOURCE="#application.datasource#">
					SELECT	Freight_Component_Type
					FROM	Contract_Main_Aux_Data
					WHERE	Contract_Main_ID = <cfqueryparam value="#revisionProgramId#" cfsqltype="cf_sql_integer">
				</cfquery>
				<cfif qGetProgramDelivertType.Freight_Component_Type eq 1> <!--- DEL --->
					<cfset programDelType = 1 />
				<cfelseif qGetProgramDelivertType.Freight_Component_Type eq 4> <!--- FOB DC --->
					<cfset programDelType = 4 />
				</cfif>

				<cfquery cachedWithin="#variables.cachedWithin#" NAME="qGetProgramDistributorWarehouse" DATASOURCE="#application.datasource#">
					SELECT	Warehouse_Master_ID
					FROM	Program_Distributor_Freight
					WHERE	Deleted = <cfqueryparam value=0>
					AND		Program_ID = <cfqueryparam value="#revisionProgramId#" cfsqltype="cf_sql_integer">
					<CFIF Dist_ID NEQ "">
					AND		Distributor_ID = <cfqueryparam value="#Dist_ID#" cfsqltype="cf_sql_varchar">
					<CFELSE>
					AND 1 = 2
					</CFIF>
				</cfquery>
				<cfif qGetProgramDistributorWarehouse.recordCount>
					<cfset warehouseMasterId = qGetProgramDistributorWarehouse.Warehouse_Master_ID />
				</cfif>
			</cfif>
				<!--- enhancement on rebate components for mcCain
					  based on mcCain requirement, billback can be claimed based on the components level
					  therefore, the devitation for rebate will be based on the selected components for the
					  specified billback/program.
				--->

				<CFSAVECONTENT VARIABLE="This_Rebate_Details">
				<CFIF BB_Product_Type_ID EQ 2><!----- If rebate go look for the components ---->
				<TR VALIGN="top">
					<TD COLSPAN="1">&nbsp;</TD>
					<TD COLSPAN="9" BGCOLOR="##F5F5DC">
					<CFSET Program_Rebates_Product_Data_ID = stRevisionProperties.idFieldValue>
					<CFIF Program_Rebates_Product_Data_ID NEQ "" AND IsNumeric(Program_Rebates_Product_Data_ID)>
						<cfquery cachedWithin="#variables.cachedWithin#" NAME="Get_Rebate_Components" DATASOURCE="#application.datasource#">
							SELECT	Rate,
									Program_Rebates_Component_Data.Unit_Of_Measure_ID,
									Units_of_Measure.Abbreviation,
									Program_Rebates_Component_Name.Program_Rebates_Component_Name,
									Program_Rebates_Component_Data.Program_Rebates_Component_Data_ID,
									Program_Rebates_Component_Name.Rebate_Percent_Option_ID
							FROM	Program_Rebates_Component_Data
									INNER JOIN Units_of_Measure
									ON
									Units_of_Measure.Unit_Of_Measure_ID = Program_Rebates_Component_Data.Unit_Of_Measure_ID
									INNER JOIN Program_Rebates_Component
									ON
									Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
									<cfif PayTo NEQ 0>
									AND (Program_Rebates_Component.Component_Paid_To = #PayTo# or (Program_Rebates_Component.Component_Paid_To = 4 and #PayTo# IN (1,2)))
									</cfif>
									INNER JOIN Program_Rebates_Component_Name
									ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
								  	LEFT JOIN Billback_Program_Rebate_Component on
									Billback_Program_Rebate_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID and
									Billback_Program_Rebate_Component.billback_id = '#Billback_id#' and
									Billback_Program_Rebate_Component.Billback_Program_ID = '#billback_program_program_id#'
							WHERE
									Program_Rebates_Product_Data_ID = <cfqueryparam value=#Program_Rebates_Product_Data_ID#>
									<cfif appSettings.Claims_at_Comp_Level>
										and Billback_Program_Rebate_Component.Checked = <cfqueryparam value='true'>
										and Billback_Program_Rebate_Component.deleted = <cfqueryparam value=0>
									</cfif>
						</CFQUERY>
					</CFIF>
 					<CFSET Current_Item_Total_Component_Rate = 0>
					<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="100%" BORDER="0" CLASS="NotMaintable">
						<TR BGCOLOR="EEEEEE">
							<TD ID="header" WIDTH="30%"><B>Name</B></TD>
							<TD ID="header" WIDTH="20%"><B>Rate</B></TD>
							<TD ID="header" WIDTH="5%">&nbsp;</TD>
							<TD ID="header" WIDTH="20%"><B>Net Weight</B></TD>
							<TD ID="header" WIDTH="5%">&nbsp;</TD>
							<TD ID="header" ALIGN="right" WIDTH="20%"><B>Rate / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
						</TR>
						<CFIF Program_Rebates_Product_Data_ID NEQ "" AND IsNumeric(Program_Rebates_Product_Data_ID)>
                            
							<!--- Get invoice date range to use per program version --->
							<cfset Sample_Size_Start_Date = start_date />
							<cfset Sample_Size_End_Date = End_date />


							<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND _Setting_Dist_Trade_Deviation_Tolerance_Override neq '1'>
								<cfif _Setting_BB_Start_Offset_Days GT 0>
									<cfset Sample_Size_Start_Date = DateAdd("d", _Setting_BB_Start_Offset_Days * -1, Sample_Size_Start_Date) />
								</cfif>

								<cfif _Setting_BB_End_Offset_Days GT 0>
									<cfset Sample_Size_End_Date = DateAdd("d", _Setting_BB_End_Offset_Days, Sample_Size_End_Date) />
								</cfif>
							<CFELSE>

									<CFIF BB_D_Template_Overrides_Deviation_Tolerances EQ 1> <!--- BB_D_Purchase_Period_OverRide_Rate --->
										<!--- if the template purchase period override is set, use that span all the time ---->
										<CFSET 	Sample_Size_End_Date = Invoice_Last_Date_For_Rabate>
										<!--- Do not consider 0,as then the "Sample_Size_Start_Date" will have (+ 1) date which sometimes (billback is for a day only)
										could go beyond the "Sample_Size_End_Date". --->
										<cfif BB_D_Purchase_Period_OverRide_Rate neq 0>
										<CFSET 	Sample_Size_Start_Date = DateAdd("d", (BB_D_Purchase_Period_OverRide_Rate * -1) + 1, Sample_Size_End_Date)>
										</cfif>
									<CFELSE>
										<!--- use the sample size and take the appropriate span for this program ---->
										<cfset Sample_Size_Start_Date = Current_Sample_Size_End_Date>
										<cfset currentSpan = DateDiff("d", start_date, end_date) + 1>

										<cfset currentSampleSizeLen = currentSpan * Billback_Rate_Tolerance.BB_Tolerance_DPP>

										<!--- currentSampleSizeLen - 1 because start amd end dates are inclusive--->
										<cfset Sample_Size_End_Date = DateAdd("d", currentSampleSizeLen - 1, Sample_Size_Start_Date)>

										<CFSET 	Current_Sample_Size_End_Date = DateAdd("d", 1, Sample_Size_End_Date)>
										<CFSET 	Current_Sample_Size_Start_Date = Sample_Size_Start_Date>
									</CFIF>
							</CFIF>
                                            
						<CFLOOP QUERY="Get_Rebate_Components">
							<CFSET Add_Up_Rate = 0>
						<TR>
							<TD ID="header">#Program_Rebates_Component_Name#</TD>
							<cfset Use_Rebate_Percent_Option_ID = Rebate_Percent_Option_ID>
							<!---- If component uom = %, find rate / bb uom ----->
							<CFSET percent_Detail_Expand = false>
							<CFSET ReProgram_Rebates_Component_Data_ID = "">
							<CFIF Unit_Of_Measure_ID  EQ 3>

								<CFSAVECONTENT VARIABLE="This_Component_Percent_Details">
									<CFQUERY NAME="Get_Invoice_Between_These_Dates" DBTYPE="query">
										SELECT	*
										FROM	Get_Invoice_For_This_Distributor_For_Rebate
										WHERE 	Invoice_Check_Date >= #CreateODBCDate(Sample_Size_Start_Date)#
										AND	Invoice_Check_Date <= #CreateODBCDate(Sample_Size_End_Date)#
									</CFQUERY>
									<CFSET This_UOM_Product_Rate_Percent = Rate>
									<CFSET Percent_Amount_Total = 0>
									<CFSET Percent_Detail_Display = "inline">
									<CFIF SHOW_DEVIATION_DETAIL_HEADER>
										<CFSET Percent_Detail_Display = "none">
										<CFSET percent_Detail_Expand = true>
									</CFIF>
									<CFSET ReProgram_Rebates_Component_Data_ID = "TR_#request.app_general_functions.replaceHyphen(Program_Rebates_Component_Data_ID)#">
									<TR STYLE="display:#Percent_Detail_Display#;" ID="#ReProgram_Rebates_Component_Data_ID#">
									<TD COLSPAN="4">
									<TABLE align="right" BGCOLOR="##F0FFFF" CELLPADDING="0" CELLSPACING="0" WIDTH="80%" BORDER="0" CLASS="NotMaintable">
									<CFIF Get_Invoice_Between_These_Dates.RecordCount Gt 0>
									<TR BGCOLOR="EEEEEE">
										<TD ID="header"><B>Invoice Number</B></TD>
										<cfif Use_Rebate_Percent_Option_ID EQ 1>
										<TD ID="header" ALIGN="right"><B>Price/#ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
										<TD ID="header">&nbsp;</TD>
										</cfif>
										<TD ID="header" ALIGN="right"><B>Volume #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
										<cfif Use_Rebate_Percent_Option_ID EQ 1>
										<TD ID="header">&nbsp;</TD>
										</cfif>
										<TD ID="header" ALIGN="right"><B>Amount</B></TD>
									</TR>
									<CFLOOP QUERY="Get_Invoice_Between_These_Dates">
										<TR>
											<TD STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#Invoice_Number#</TD>
											<cfif Use_Rebate_Percent_Option_ID EQ 1>
												<TD ALIGN="right" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#NumberFormat(UOM_Unit_Price, DEVIATION_RATE_FORMAT)#</TD>
												<TD ALIGN="center" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">&nbsp;*&nbsp;</TD>
												<CFSET Current_Percent_Amount = (UOM_Unit_Price * UOM_Volume_Invoiced)>
											<cfelse>
												<CFSET Current_Percent_Amount = Gross_Sales_Dollars>
											</cfif>
											<TD ALIGN="right" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#NumberFormat(UOM_Volume_Invoiced, DEVIATION_VOLUME_FORMAT)#</TD>
											<cfif Use_Rebate_Percent_Option_ID EQ 1>
												<TD ALIGN="center" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">&nbsp;=&nbsp;</TD>
											</cfif>
											<CFSET Percent_Amount_Total = Percent_Amount_Total + Current_Percent_Amount>
											<TD ALIGN="right" STYLE="border-bottom:solid 93BEE2 1px; font-size : 10px;">#NumberFormat(Current_Percent_Amount, DEVIATION_RATE_FORMAT)#</TD>
										</TR>
									</CFLOOP>
									<CFELSE>
										<TR>
											<TD COLSPAN="4" STYLE="color:red;font-size:12px;">No invoice found</TD>
										</TR>
									</CFIF>
									<TR>
										<TD COLSPAN="3" ALIGN="right" ID="header"><B>&##931; Amount</B></TD>
										<TD ID="header"><B>&nbsp;=&nbsp;</B></TD>
										<TD ALIGN="right" ID="header"><B>#NumberFormat(Percent_Amount_Total, DEVIATION_RATE_FORMAT)#</B></TD>
									</TR>
									<TR>
										<TD COLSPAN="3" ALIGN="right" ID="header"><B>&##931; Volume</B></TD>
										<TD ID="header"><B>&nbsp;=&nbsp;</B></TD>
										<TD ALIGN="right" ID="header"><B>#NumberFormat(Total_Volume_For_Percent_Calc, DEVIATION_VOLUME_FORMAT)#</B></TD>
									</TR>
									<CFIF Total_Volume_For_Percent_Calc NEQ 0 AND Total_Volume_For_Percent_Calc NEQ "">
										<CFSET Add_Up_Rate = This_UOM_Product_Rate_Percent * (Percent_Amount_Total/Total_Volume_For_Percent_Calc) / 100>
									</CFIF>
									<TR>
										<TD COLSPAN="3" ALIGN="right" ID="header"><B>#NumberFormat(This_UOM_Product_Rate_Percent, DEVIATION_PERCENT_FORMAT)#% ( #NumberFormat(Percent_Amount_Total, DEVIATION_RATE_FORMAT)# / #NumberFormat(Total_Volume_For_Percent_Calc, DEVIATION_VOLUME_FORMAT)#)</B></TD>
										<TD ID="header"><B>&nbsp;=&nbsp;</B></TD>
										<TD ALIGN="right" ID="header" style="border:2px solid blue;"><B>#NumberFormat(Add_Up_Rate, DEVIATION_RATE_FORMAT)#</B></TD>
									</TR>
									</TABLE>
									</TD></TR>
								</CFSAVECONTENT>
							</CFIF>
							<TD VALIGN="top"><CFIF Unit_Of_Measure_ID LT 3>#NumberFormat(Rate, DEVIATION_RATE_FORMAT)#<CFELSE>#Rate#</CFIF> <CFIF Unit_Of_Measure_ID LT 3>/</CFIF> #Abbreviation#</TD>
							<CFIF Unit_Of_Measure_ID NEQ Billback_UOM  AND Unit_Of_Measure_ID  NEQ 3>
								<TD><CFIF Unit_Of_Measure_ID EQ 1><CFSET Add_Up_Rate = Rate/Net_Weight>/<CFELSE><CFSET Add_Up_Rate = Rate*Net_Weight>*</CFIF></TD>
								<TD>#Net_Weight#</TD>
							<CFELSE>
								<CFIF Unit_Of_Measure_ID  NEQ 3>
									<CFSET Add_Up_Rate = Rate>
								</CFIF>
								<TD COLSPAN="2">&nbsp;</TD>
							</CFIF>
							<TD VALIGN="bottom">=</TD>
							<TD ALIGN="right" VALIGN="bottom"<CFIF percent_Detail_Expand> onClick="javaScript: show_TR_Details('#ReProgram_Rebates_Component_Data_ID#');" STYLE="cursor:pointer;color:blue;"</CFIF>>#NumberFormat(Add_Up_Rate, DEVIATION_RATE_FORMAT)#</TD>
						</TR>
						<CFIF Unit_Of_Measure_ID  EQ 3>
							#This_Component_Percent_Details#
						</CFIF>
						<CFSET Current_Item_Total_Component_Rate = Current_Item_Total_Component_Rate + Add_Up_Rate>
						</CFLOOP>
						</CFIF>
						<TR>
							<TD COLSPAN="4" ALIGN="RIGHT" ID="header"><B>&##931; Rate / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
							<TD ALIGN="left" ID="header">=</TD>
							<TD ALIGN="RIGHT" ID="header"><B>#NumberFormat(Current_Item_Total_Component_Rate, DEVIATION_RATE_FORMAT)#</B></TD>
						</TR>
					</TABLE>
					</TD>
				</TR>
					<CFSET product_Rate = Current_Item_Total_Component_Rate>
					<!----- If rebate go look for the components ---->
				</CFIF>
				<CFIF Billback_Product_Program.ExpRT_Discount_Type_Id eq 1 OR BB_Product_Type_ID NEQ 2>
					<!------ 0 will be default rule for formula ----->
					<cfset fixedPriceLogicType = 0>
					<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<!---///////////////////////////////////////////
					Rule 1. Program Fixed Components contain Delivered only
					 - If there is entry in special price list, get delivered price at the end of the particular time span from special price list
					 - Else get the lowest non-bid Delivered price in the window. Compare it with National Delivered Truckload Price from regular price list, take the lower of the both
					Price - avg. Delivered Fixed Price = Rebate
					Rule 2. Program Fixed Components contain FOB only
					 - From invoice get the lost commonly occuring FOB price based on cased ordered
					 - If no FOB price occurance, retrieve lowest non-bid Delivered price and subtract (del_del_cost + del_cust_pickup)
					Price - avg. FOB Fixed Price = Rebate
					Rule 3. Program Fixed Componets contain Delivered and FOB
					 - From invoice get most commonly occuring price (FOB/delivered) based on cases ordered. If delivered applu rule, else apply rule 2
					Rule 0. Old invoice amount scheme OR if appsetting.getBBDeviationUseMaxPrice() get max price from invoices

					Fixed_Component_Type: (1= delivered, 2 =FOB)
					 ////////////////////////////////////////////////////--->
					<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
					<!---#Billback_Product_Program.ExpRT_Discount_Type_Id# : 1 : AND #BSA_Foodservice_Items_Master_ID# : '' : #P_Valid_Discount_Type# : 1 :--->
					<CFSET Total_Price=0>
					<CFSET Total_Pounds_Invoiced = 0>
					<CFIF (BB_Product_Type_ID EQ 1 OR BB_Product_Type_ID EQ 5 OR BB_Product_Type_ID EQ 11 OR Billback_Product_Program.ExpRT_Discount_Type_Id eq 1) AND BSA_Foodservice_Items_Master_ID NEQ "" AND P_Valid_Discount_Type EQ 1>
					<!------ Get Distributor Info ----->

						<cfset qGetBBDistributor = Get_Dist_ID>
						<CFIF qGetBBDistributor.recordCount GT 0>
							<CFSET BSA_Foodservice_Customers_ID = qGetBBDistributor.BSA_Foodservice_Customers_ID>
							<cfset distributorId = qGetBBDistributor.BSA_Foodservice_Customers_ID>

							<CFIF Generic_Type EQ DEVIATION_CONSTANTS_Trade_Shelter AND _Setting_Dist_Trade_Deviation_Tolerance_Override neq '1'>
								<!------ to acccomodate getting invoice for each revision ----->
								<CFIF appsettings.getBBDeviationUseMaxPrice()>
									<!--- TODO: If app switch  use max price" is on, always use the same invoice date span for all versions of the program "--->
									<CFSET 	Sample_Size_Start_Date = Invoice_First_Date_For_Rabate>
									<CFSET 	Sample_Size_End_Date = Invoice_Last_Date_For_Rabate>
								<CFELSE>
									<CFSET 	Sample_Size_Start_Date = start_date>
									<CFSET 	Sample_Size_End_Date = end_date>
								</CFIF>

								<cfif _Setting_BB_Start_Offset_Days GT 0>
									<cfset Sample_Size_Start_Date = DateAdd("d", _Setting_BB_Start_Offset_Days * -1, Sample_Size_Start_Date) />
								</cfif>

								<cfif _Setting_BB_End_Offset_Days GT 0>
									<cfset Sample_Size_End_Date = DateAdd("d", _Setting_BB_End_Offset_Days, Sample_Size_End_Date) />
								</cfif>
							<CFELSE>

								<CFIF BB_D_Template_Overrides_Deviation_Tolerances EQ 1> <!--- BB_D_Purchase_Period_OverRide_Rate --->
									<!--- if the template purchase period override is set, use that span all the time ---->
									<CFSET 	Sample_Size_End_Date = Invoice_Last_Date_For_Rabate>
									<!--- Do not consider 0,as then the "Sample_Size_Start_Date" will have (+ 1) date which sometimes (billback is for a day only)
									could go beyond the "Sample_Size_End_Date". --->
									<cfif BB_D_Purchase_Period_OverRide_Rate neq 0>
									<CFSET 	Sample_Size_Start_Date = DateAdd("d", (BB_D_Purchase_Period_OverRide_Rate * -1) + 1, Sample_Size_End_Date)>
									</cfif>
								<CFELSEIF appsettings.getBBDeviationUseMaxPrice()>
									<!--- If app switch  use max price" is on, always use the original invoice date span for all versions of the program "--->
									<!---
									If we were to set some thing it would look this this, but there is no need ro set var A = var A
									<CFSET 	Sample_Size_Start_Date = Sample_Size_Start_Date />
									<CFSET 	Sample_Size_End_Date = Sample_Size_End_Date />
									--->
								<CFELSE>
									<!--- use the sample size and take the appropriate span for this program ---->
									<cfset Sample_Size_Start_Date = Current_Sample_Size_End_Date>
									<cfset currentSpan = DateDiff("d", start_date, end_date) + 1>

									<cfset currentSampleSizeLen = currentSpan * Billback_Rate_Tolerance.BB_Tolerance_DPP>

									<!--- currentSampleSizeLen - 1 because start amd end dates are inclusive--->
									<cfset Sample_Size_End_Date = DateAdd("d", currentSampleSizeLen - 1, Sample_Size_Start_Date)>

									<CFSET 	Current_Sample_Size_End_Date = DateAdd("d", 1, Sample_Size_End_Date)>
									<CFSET 	Current_Sample_Size_Start_Date = Sample_Size_Start_Date>
								</CFIF>
								<!-----
								Example.
								Billback Span: (05/06/2007 - 05/12/2007) (7 days)
								Program Version 1: 9/1/2006 - 10/31/2007 (Effective Dates: 9/1/2006 - 5/9/2007)
								Program Version 2: 5/10/2007 - 10/31/2007 (Effective Dates: 5/10/2007 - 10/31/2007)
								Billback Valid Span: (05/06/2007 - 05/12/2007) (7 days) - out of which 4 days from version 1 and 3 days from version 2

								Case 1:
								Template Purchase Period Over Ride: 10
								Invoice Sample for billback, version 1 and version 2 : 05/03/2007 - 05/12/2007

								Case 2:
								Template Purchase Period Over Ride: 0
								Customer Purchase Period Ratio: 2 (from settings panel)
								Sample Size: 7 * 2 = 14
								Customer Purchase Period Offset: 2 days (from settings panel)
								Invoice Sample for billback: 04/27/2007 - 05/10/2007 (14 days span with 2 days offset)
								Invoice Sample for version 1: 04/27/2007 - 05/04/2007 (4 days * 2)
								Invoice Sample for version 1: 05/05/2007 - 05/10/2007 (3 days * 2)
								---->

							</CFIF>
							<CFSET Product_ID = BSA_Foodservice_Items_Master_ID>
							<!----- If fixed go look for the components ---->
							<CFIF BB_Product_Type_ID EQ 1 OR BB_Product_Type_ID EQ 11 OR Billback_Product_Program.ExpRT_Discount_Type_Id eq 1>
								<CFIF Product_ID NEQ "">
									<cfif BB_Product_Type_ID EQ 11>
										<cfset qGetFixedComponents = bbDeviationManager.getBidRequestProductComponentDeliveryTypes(Product_ID, revisionProgramId, PayTo)>
									<cfelseif BB_Product_Type_ID EQ 1>
										<cfset qGetFixedComponents = bbDeviationManager.getFixedProductComponentDeliveryTypes(Product_ID, revisionProgramId, PayTo)>
									<cfelse> <!--- special rate override from component calc --->
										<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="getOverRide">
											SELECT Contract_Main_Id
											FROM Contract_Main
											WHERE Contract_Number = <cfqueryparam value='#Billback_Product_Program.Contract_Number#'> AND
											Approved = <cfqueryparam value=1> AND
											Deleted = <cfqueryparam value=0>
										</cfquery>
										<cfset qGetFixedComponents = bbDeviationManager.getFixedProductComponentDeliveryTypes(Product_ID, getOverRide.Contract_Main_Id, PayTo)>
									</cfif>

									<cfif qGetFixedComponents.recordCount EQ 0>
										<cfset fixedPriceLogicType = 0>
										<cfif appSettings.getFixedcomponents_on()>
											<cfset fixedPriceLogicType = 1 />
										</cfif>
									<cfelseif qGetFixedComponents.recordCount EQ 1>
										<cfset fixedPriceLogicType = 0>
										<cfif appSettings.getFixedcomponents_on()>
											<cfset fixedPriceLogicType = qGetFixedComponents.Fixed_Component_Type />
										</cfif>
									<cfelse>
										<!------ more than 1, so find out which one to consider from invoice ----->
										<cfset qGetMaxOccuringDeliveryType = bbDeviationManager.getInvoiceDetails(
											   distributorId = distributorId, productId = Product_ID,
											   date1 = Sample_Size_Start_Date, date2 = Sample_Size_End_Date,
											   billbackUOM = Billback_UOM, invoiceDateField = check_Date,
											   returnType = 2, FobPriceIndicator = Fob_Price_Indicator)>
										<cfset fixedPriceLogicType = 1><!--- D12681: default to DEL, so if no invlice found for DEL or FOB it will use DEL logic --->
										<cfif qGetMaxOccuringDeliveryType.recordCount>
											<cfset maxVolume = 0>
											<cfloop query="qGetMaxOccuringDeliveryType">
												<cfif TotalVolume GT maxVolume>
													<cfif FOB_PRICE_IND EQ "Y">
														<cfset fixedPriceLogicType = 2>
														<cfset maxVolume = TotalVolume>
													<cfelseif FOB_PRICE_IND EQ "N">
														<cfset fixedPriceLogicType = 1>
														<cfset maxVolume = TotalVolume>
													</cfif>
												</cfif>
											</cfloop>
										</cfif>
									</cfif>
									<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
													special Overide rate from program components
										  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
									<!---<cfif Billback_Product_Program.ExpRT_Discount_Type_Id eq 1 and BB_Product_Type_ID EQ 2>
										<cfset fixedPriceLogicType = 1>
									</cfif>	--->
									<!------ If the settings says not to look for all the different cases to find the price from price list, follow the case 0 which is the normal way ----->
									<cfif appSettings.getBBFixedCalcTypesOn() NEQ 1 OR (fixedPriceLogicType NEQ 1 AND fixedPriceLogicType NEQ 2) OR objFreight.bFREIGHT_VERSION_ITEM>
										<!------ get average delivered program price ----->
										<cfset product_Rate = 0>
										<cfif BB_Product_Type_ID eq 11>
											<cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramBidRequestPrice(revisionProgramId, Product_ID, Billback_UOM, fixedPriceLogicType, appSettings.getFixedcomponents_on(), PayTo)>
										<cfelse>
											<cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramFixedPrice(revisionProgramId, Product_ID, Billback_UOM, fixedPriceLogicType, appSettings.getFixedcomponents_on(), PayTo, Dist_ID, programDelType, CheckProductWon, useFreightCalcDelTypeFromInvoice,objFreight.bFREIGHT_VERSION_ITEM,Billback_ID)>
											<!----
											D13872 JRS -Identify how to handle BB purchase validation when sku number changes
											If product replacement is set up,
											If we did not get a fixed price from the program for this product,
											find if there is a price for teh replacement product
											----->
											<cfif ProductReplacementID neq "">
												<cfif not (qGetAvgProgramPrice.recordCount and isNumeric(qGetAvgProgramPrice.AvgProgramPrice) neq 0)>
													<cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramFixedPrice(revisionProgramId, ProductReplacementID, Billback_UOM, fixedPriceLogicType, appSettings.getFixedcomponents_on(), PayTo, Dist_ID, programDelType, CheckProductWon, useFreightCalcDelTypeFromInvoice,objFreight.bFREIGHT_VERSION_ITEM,Billback_ID)>
												</cfif>
											</cfif>
										</cfif>
										<cfif qGetAvgProgramPrice.recordCount>
											<cfif isNumeric(qGetAvgProgramPrice.AvgProgramPrice)>
												<cfset product_Rate = qGetAvgProgramPrice.AvgProgramPrice>
											</cfif>
											<cfif isNumeric(qGetAvgProgramPrice.IBF_Rate)>
												<cfset program_ibf_Rate = qGetAvgProgramPrice.IBF_Rate />
											</cfif>
											<cfif isNumeric(qGetAvgProgramPrice.OBF_Rate)>
												<cfset program_obf_Rate = qGetAvgProgramPrice.OBF_Rate />
											</cfif>
										</cfif>
										<cfif NOT objFreight.bFREIGHT_VERSION_ITEM AND (Billback_Product_Program.ExpRT_Discount_Type_Id Neq 1 OR BB_Product_Type_ID NEQ 2)>
											<cfset fixedPriceLogicType = 0>
										</cfif>
									</cfif>
								</CFIF>
							</cfif>
							<!---<cfoutput>  ::  #fixedPriceLogicType#  ::</cfoutput>--->
							<TR VALIGN="top">
								<TD colspan="10">
								<cfif objFreight.bFREIGHT_VERSION_ITEM >
									<!--- Special Handling For new Item level Freight Handling
									**		components.freight.FreightBracketSetting  ** --->
									<cfinclude template="Deviation_Fixed_Rate_Case_4.cfm">

									<cfswitch expression="#fixedPriceLogicType#">
									<cfcase value="1">
										<cfinclude template="Deviation_Fixed_Rate_Case_1_Freight.cfm">
									</cfcase>
									<cfcase value="2">
										<cfinclude template="Deviation_Fixed_Rate_Case_2_Freight.cfm">
									</cfcase>
									</cfswitch>
								<cfelse>
									<cfswitch expression="#fixedPriceLogicType#">
									<cfcase value="1">
										<cfinclude template="Deviation_Fixed_Rate_Case_1.cfm">
									</cfcase>
									<cfcase value="2">
										<cfinclude template="Deviation_Fixed_Rate_Case_2.cfm">
									</cfcase>
									<cfdefaultcase>
										<cfinclude template="Deviation_Fixed_Rate_Case_4.cfm">
									</cfdefaultcase>
									</cfswitch>
								</cfif>
									<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
													special Overide rate from program components
										  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
										<cfif Billback_Product_Program.ExpRT_Discount_Type_Id eq 1 and BB_Product_Type_ID EQ 2>
											<CFSET product_Rate = Current_Item_Total_Component_Rate>
										</cfif>

								 <!--- OVERIDE product_rate from custon RFP freight --->
								<cfif application.util.query.get_Setting('Custom_RFP_Process',0) EQ 1 AND BB_Product_Type_ID EQ 1>
									<cfquery dataSource="#application.datasource#" NAME="getPrgPriceFromFreight">
										SELECT    Final_Price
										FROM      Program_Fixed_Freight_Rates D
										WHERE     Program_ID = #revisionProgramId#
										AND     Product_ID = '#Product_ID#'
										AND     Customer_ID = '#Billback_Product_Program.Distributor_id_earned#'
										<!---AND     Fixed_Component_Type = #fixedPriceLogicType# fixedPriceLogicType is 0, so can't filter on this --->
										AND     Deleted = 0
									</cfquery>
									<cfif ISNUMERIC(getPrgPriceFromFreight.Final_Price) AND getPrgPriceFromFreight.Final_Price NEQ 0>
										<CFSET product_Rate = getPrgPriceFromFreight.Final_Price>
									</cfif>

								</cfif>


								<!--- fixedPriceLogicType = #fixedPriceLogicType# :: getBBDeviationUseMaxPrice = #appsettings.getBBDeviationUseMaxPrice()# :: getBBFixedCalcTypesOn = #appSettings.getBBFixedCalcTypesOn()# :: deliveryTypeToUse = #deliveryTypeToUse# --->
							<!------ subtract program fixed price from paid price ----->
							<TABLE bgcolor="FAF89A" CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="100%" CLASS="Maintable">
							<COLGROUP>
								<COL SPAN="1" WIDTH="90"></COL><!------ invoice # ----->
								<COL SPAN="1" WIDTH="90"></COL><!------ invoice date ----->
								<COL SPAN="1" ALIGN="RIGHT"></COL><!------ volume ----->
								<COL SPAN="1" ALIGN="CENTER" WIDTH="90"></COL><!------ * ----->
								<COL SPAN="1" ALIGN="RIGHT"></COL><!------ Price/CS ----->
								<COL SPAN="1" ALIGN="CENTER" WIDTH="90"></COL><!------ = ----->
								<COL SPAN="1" ALIGN="RIGHT" WIDTH="70"></COL><!------ Price ----->
							</COLGROUP>
							<CFSET Total_Weighted_Program_Rate=product_Rate>
							<cfif NOT isNumeric(product_Rate)>
								<cfset product_Rate = 0>
							</cfif>
							<cfif NOT isNumeric(avgPricePaid)>
								<cfset avgPricePaid = 0>
							</cfif>
							<cfset rateOverridePrice = avgPricePaid />

							<cfif not useFreightCalcDelTypeFromInvoice and appsettings.getShow_Fixed_Freight() EQ 1>
								<cfif programDelType eq 1> <!--- programDelType: 1=DEL, 4=FOB DC ----->
									<cfparam name="OBF_Rate_PER_BB_UOM" default=0>
								    <cfset rateOverridePrice = rateOverridePrice - OBF_Rate_PER_BB_UOM /> <!---- Get FDC Price ---->
								</cfif>
							</cfif>
							<TR CLASS="MaintableTHEAD">
								<TD COLSPAN="5" ALIGN="RIGHT"><B>
									<cfif objFreight.bFREIGHT_VERSION_ITEM>
										Validation
									<cfelse>
										<cfif appsettings.getBBDeviationUseMaxPrice() EQ 1>Max<cfelseif appsettings.getBBDeviationUseMaxPrice() EQ 2>Min<cfelse>Possible</cfif>
									 	Invoice
									</cfif>&nbsp;Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
								<TD ALIGN="CENTER"><B>=</B></TD>
								<TD>#NumberFormat(avgPricePaid, DEVIATION_RATE_FORMAT)#</TD>
							</TR>
							<!--- **** Extra IBF/OBF Handling start *** --->
							<CFIF useFreightCalcDelTypeFromInvoice AND (deliveryTypeToUse eq 1 or deliveryTypeToUse eq 4 or deliveryTypeToUse eq 5)>
							<!--- IBF --->
							<!--- If FDC/DEL, show IBF --->
							<cfif deliveryTypeToUse Neq 5 >
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="5" ALIGN="RIGHT"><B>
										Invoice IBF / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
									<TD ALIGN="CENTER"><B>=</B></TD>
									<TD>#NumberFormat(minmax_ibf_rate, DEVIATION_RATE_FORMAT)# </TD>
								</TR>
								<cfset avgPricePaid = avgPricePaid + minmax_ibf_rate />
								<cfset rateOverridePrice = avgPricePaid + minmax_ibf_rate />
							</cfif>

							<!--- OBF --->
							<cfif deliveryTypeToUse eq 1 or deliveryTypeToUse eq 5> <!--- If DEL, show OBF --->
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="5" ALIGN="RIGHT"><B>
										Invoice OBF / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
									<TD ALIGN="CENTER"><B>=</B></TD>
									<TD>#NumberFormat(minmax_obf_rate, DEVIATION_RATE_FORMAT)#</TD>
								</TR>
								<cfset avgPricePaid = avgPricePaid + minmax_obf_rate />
							</cfif>
							<TR CLASS="MaintableTHEAD">
								<TD COLSPAN="5" ALIGN="RIGHT"><B>
									Invoice
									<cfif deliveryTypeToUse eq 4>FOB DC
									<cfelseif deliveryTypeToUse eq 1 or deliveryTypeToUse eq 5>DEL
									</cfif>
									Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
								<TD ALIGN="CENTER"><B>=</B></TD>
								<TD>#NumberFormat(avgPricePaid, DEVIATION_RATE_FORMAT)#</TD>
							</TR>
							</CFIF>
							<!--- **** Extra IBF/OBF Handling end *** --->
							<TR CLASS="MaintableTHEAD">
								<TD COLSPAN="5" ALIGN="RIGHT"><B>Program <cfif useFreightCalcDelTypeFromInvoice AND NOT objFreight.bFREIGHT_VERSION_ITEM AND NOT deliveryTypeToUse eq 5>FOB <cfelseif deliveryTypeToUse eq 5>DEL </cfif>Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
								<TD ALIGN="CENTER"><B>=</B></TD>
								<TD>#NumberFormat(product_Rate, DEVIATION_RATE_FORMAT)#</TD>
							</TR>
							<!--- **** Extra IBF/OBF Handling start *** --->
							<CFIF useFreightCalcDelTypeFromInvoice AND (deliveryTypeToUse eq 1 or deliveryTypeToUse eq 4)>
								<!--- IBF --->
								<!--- If FDC/DEL, show IBF --->
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="5" ALIGN="RIGHT"><B>
										Program IBF / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
									<TD ALIGN="CENTER"><B>=</B></TD>
									<TD>#NumberFormat(program_ibf_Rate, DEVIATION_RATE_FORMAT)#</TD>
								</TR>
								<cfset product_Rate = product_Rate + program_ibf_Rate />
							</cfif>
							<!--- OBF --->
							<cfif useFreightCalcDelTypeFromInvoice AND (deliveryTypeToUse eq 1 OR objFreight.bFREIGHT_VERSION_ITEM) > <!--- If DEL, show OBF --->
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="5" ALIGN="RIGHT"><B>
										Program <cfif objFreight.bFREIGHT_VERSION_ITEM>Freight<cfelse>OBF</cfif> / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
									<TD ALIGN="CENTER"><B>=</B></TD>
									<TD>#NumberFormat(program_obf_Rate, DEVIATION_RATE_FORMAT)#</TD>
								</TR>
								<cfset product_Rate = product_Rate + program_obf_Rate />
							</cfif>
							<CFIF useFreightCalcDelTypeFromInvoice AND (deliveryTypeToUse eq 1 or deliveryTypeToUse eq 4)>
								<TR CLASS="MaintableTHEAD">
									<TD COLSPAN="5" ALIGN="RIGHT"><B>Program
										<cfif deliveryTypeToUse eq 4>FOB DC
										<cfelseif deliveryTypeToUse eq 1>DEL
										</cfif>
										Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
									<TD ALIGN="CENTER"><B>=</B></TD>
									<TD>#NumberFormat(product_Rate, DEVIATION_RATE_FORMAT)#</TD>
								</TR>
							</CFIF>
							<!--- **** Extra IBF/OBF Handling end *** --->
							<CFSET Total_Weighted_Rate_Display = avgPricePaid - product_Rate>
							<cfif avgPricePaid EQ 0 OR product_Rate EQ 0>
								<CFSET Total_Weighted_Rate_Display = 0>
								<cfset invalidDatesTobeRemovedFromTotalValidSpan = invalidDatesTobeRemovedFromTotalValidSpan + this_Interval_Days>
							</cfif>
							<!--- Special rate override from component  --->
							<cfif Billback_Product_Program.ExpRT_Discount_Type_Id NEQ 1 OR BB_Product_Type_ID NEQ 2>
								<TR CLASS="MaintableTHEAD" TITLE="#NumberFormat(avgPricePaid, DEVIATION_RATE_FORMAT)# - #NumberFormat(product_Rate, DEVIATION_RATE_FORMAT)# = #NumberFormat(Total_Weighted_Rate_Display, DEVIATION_RATE_FORMAT)#">
									<TD COLSPAN="5" ALIGN="RIGHT">
									<B>Expected Rate / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")# &nbsp;&nbsp; (Invoice Price - Program Price) </B>
									<br>(#NumberFormat(avgPricePaid, DEVIATION_RATE_FORMAT)# - #NumberFormat(product_Rate, DEVIATION_RATE_FORMAT)#)
									</TD>
									<TD ALIGN="CENTER"><B>=</B></TD>
									<TD>#NumberFormat(Total_Weighted_Rate_Display, DEVIATION_RATE_FORMAT)#</TD>
								</TR>
							</cfif>
							</TABLE>
							<!------ set the product rate to be the new product rate we just found ----->
							<cfif Billback_Product_Program.ExpRT_Discount_Type_Id NEQ 1 OR BB_Product_Type_ID NEQ 2>
								<cfset product_Rate = Total_Weighted_Rate_Display>
							</cfif>
							</TD>
							</TR>
						<cfelse>
							<cfoutput><BR><FONT COLOR="Red"><B>Did not retrieve invoice information. Payee not found in the #lcase(application.returned_customer_setting.distributor_label_singular)# database</B></FONT><BR></cfoutput>
						</cfif>
					</CFIF>
				</CFIF>
				</CFSAVECONTENT>
			<cfset stBillbackRateDisplay.start_date 		= start_date>
			<cfset stBillbackRateDisplay.end_date 			= end_date>
			<cfset stBillbackRateDisplay.Sample_Size_Start_Date 		= Sample_Size_Start_Date>
			<cfset stBillbackRateDisplay.Sample_Size_End_Date 			= Sample_Size_End_Date>
			<cfset stBillbackRateDisplay.this_Interval_Days = this_Interval_Days>
			<cfset stBillbackRateDisplay.this_Rate_Weight 	= this_Rate_Weight>
			<cfset stBillbackRateDisplay.product_Rate 		= product_Rate>
			<cfset stBillbackRateDisplay.This_Rebate_Details = This_Rebate_Details>
			<cfset ArrayAppend(arBillbackRateDisplay, stBillbackRateDisplay)>
			<CFSET counter=counter+1>
		</CFIF>
	</CFLOOP>
	<br>
	<br>

	<TABLE CELLPADDING="2" CELLSPACING="2" BORDER="1" ALIGN="CENTER" width="103%" rules="groups" bordercolor="A9A9A9" >
		<TR>
		<TD class="top bottom left">
			Total Interval: #Valid_Billback_Total_Days# days
			</TD>
			<CFIF NOT (BB_Product_Type_ID EQ 2 OR appSettings.getBBFixedCalcTypesOn() EQ 1)
			AND appSettings.getBBDateDevInExpectedVol() EQ 0
			>
			<TD class="top bottom">
			Days not to count: #invalidDatesTobeRemovedFromTotalValidSpan# days<!---  <br>
			<font color="red">(Any time span which has 0 rate will not be included to take the weighted rate)</font> --->
			</TD>
			<cfset Valid_Billback_Total_Days = Valid_Billback_Total_Days - invalidDatesTobeRemovedFromTotalValidSpan>
			<TD class="top bottom">
			Total Valid Interval: #Valid_Billback_Total_Days# days
			</TD>
			</cfif>
			<td class="top bottom right" align="left"
			<CFIF NOT (BB_Product_Type_ID EQ 2 OR appSettings.getBBFixedCalcTypesOn() EQ 1) AND appSettings.getBBDateDevInExpectedVol() EQ 0>
					width="120"
				<cfelse>
					width="82%"
				</cfif>
			>
				<span onmouseout="popUpTip(event,'sTip');" onmouseover="popUpTip(event,'sTip');">
	 			<img src="/images/help_small.gif" />
				&nbsp; <div id="sTip" class="tip" style="width:475px;">
						  <CFIF NOT (BB_Product_Type_ID EQ 2 OR appSettings.getBBFixedCalcTypesOn() EQ 1) AND appSettings.getBBDateDevInExpectedVol() EQ 0>
		   					Total Interval, Days not to count and Total Valid Interval are only applicable to the deviation calculation if there are multiple program versions that overlap with the billback span and have different fixed prices. In that type of scenario, we will take a date weighted average from the versions that resulted in a non-zero rate. The Days not to count is used to avoid causing the date weighted average from being incorrect if there is a version with 0 fixed price rate.
						  <cfelse>
							Total Interval is only applicable to the deviation calculation if there are multiple program versions that overlap with the billback span and have different fixed prices. In that type of scenario, we will take a weighted average from the versions that resulted in a non-zero rate.
						</cfif>
						</div>
				</span>

	</TABLE><br>

</cfif><!----- <cfif arRevisionPropertiesLen GT 0> ----->
	<TABLE CLASS="Maintable" WIDTH="#Table_Width#" CELLPADDING="2" CELLSPACING="0" ALIGN="center">
	<COLGROUP>
	<COL SPAN="4"></COL>
	<COL SPAN="5" ALIGN="CENTER"></COL>
	</COLGROUP>
	<CFIF ListLen(This_Billback_Intervals,",") GT 0>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
			<TD>&nbsp;</TD>
			<TD><B>From</B></TD>
			<TD><B>To</B></TD>
			<TD><B>No of Days</B></TD>
			<TD>&nbsp;</TD>
			<TD><B>Total Valid Interval</B></TD>
			<TD>&nbsp;</TD>
			<TD><B>Weight</B></TD>
			<TD>&nbsp;</TD>
			<TD ALIGN="right"><B>Rate/#ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
			<TD>&nbsp;</TD>
			<TD><B>Weighted Rate</B></TD>
		</TR>
		<CFSET P_Valid_Discount_Type = 1>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">This discount type is not present in the required span for this payee</FONT></B></TD>
		</TR>
		<CFSET P_Valid_Discount_Type = 0>
	</CFIF>

	<cfset Total_Weighted_Rate = 0>
	<cfset arLen = ArrayLen(arBillbackRateDisplay)>
	<cfloop index="i" from="1" to="#arLen#">
		<cfset stBillbackRateDisplay = arBillbackRateDisplay[i]>
		<CFSET start_date 			= stBillbackRateDisplay.start_date>
		<CFSET end_date 			= stBillbackRateDisplay.end_date>
		<CFSET this_Interval_Days 	= stBillbackRateDisplay.this_Interval_Days>
		<CFSET this_Rate_Weight		= 0>
		<cfif Valid_Billback_Total_Days NEQ 0>
			<CFSET this_Rate_Weight=(this_Interval_Days/Valid_Billback_Total_Days) * 100>
		</cfif>
		<cfset product_Rate			= stBillbackRateDisplay.product_Rate>
		<CFSET Weighted_Rate = (this_Rate_Weight * product_Rate) / 100>
		<CFSET Total_Weighted_Rate = Total_Weighted_Rate + Weighted_Rate>
		<TR BGCOLOR=ccffcc>
			<TD>&nbsp;</TD>
			<TD>#DateFormat(start_date, "mm/dd/yyyy")#</TD>
			<TD>#DateFormat(end_date, "mm/dd/yyyy")#</TD>
			<TD>#this_Interval_Days#</TD>
			<TD ALIGN="CENTER">/</TD>
			<TD>#Valid_Billback_Total_Days#</TD>
			<TD ALIGN="CENTER">=</TD>
			<TD>#NumberFormat(this_Rate_Weight, DEVIATION_VOLUME_FORMAT)# %</TD>
			<TD ALIGN="CENTER">*</TD>
			<TD ALIGN="right">#NumberFormat(product_Rate, DEVIATION_RATE_FORMAT)#</TD>
			<TD ALIGN="CENTER">=</TD>
			<TD ALIGN="CENTER">#NumberFormat(Weighted_Rate, DEVIATION_RATE_FORMAT)#</TD>
		</TR>
		<TR BGCOLOR=ccffcc>
			<TD>&nbsp;</TD>
			<TD colspan="11">invoice/price sample period: #DateFormat(stBillbackRateDisplay.Sample_Size_Start_Date, "mm/dd/yyyy")# - #DateFormat(stBillbackRateDisplay.Sample_Size_End_Date, "mm/dd/yyyy")#</TD>
		</TR>
		#stBillbackRateDisplay.This_Rebate_Details#
	</cfloop>
<!---	<cfif Billback_Product_Program.ExpRT_Discount_Type_Id eq 1 and BB_Product_Type_ID EQ 2>
		<TR CLASS="MaintableTHEAD" bgcolor="FFFF00">
		<TD COLSPAN="10" ALIGN="RIGHT"><B>Expected Program Rate / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")# &nbsp;&nbsp;<CFIF NOT appsettings.getBBDeviationUseMaxPrice()> (&##931; Weighted Rate) </CFIF></B></TD>
		<TD ALIGN="CENTER"><B>=</B></TD>
		<TD<CFIF Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 0>style="border:solid 2px blue;"</CFIF>>#NumberFormat(product_Rate, DEVIATION_RATE_FORMAT)#</TD>
	</TR>
	<cfelse>--->
		<TR CLASS="MaintableTHEAD" bgcolor="FFFF00">
			<TD COLSPAN="10" ALIGN="RIGHT"><B>Expected Program Rate / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")# &nbsp;&nbsp;<CFIF NOT appsettings.getBBDeviationUseMaxPrice()> (&##931; Weighted Rate) </CFIF></B></TD>
			<TD ALIGN="CENTER"><B>=</B></TD>
			<TD<CFIF Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 0>style="border:solid 2px blue;"</CFIF>>#NumberFormat(Total_Weighted_Rate, DEVIATION_RATE_FORMAT)#</TD>
		</TR>
	<!---</cfif>--->
	<CFIF Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 1 OR Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 2 OR Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 3>
		<cfset OverRideRateFlag = Billback_Product_Program.ExpRT_Expected_Rate_Flag />
		<CFIF OverRideRateFlag EQ 2 OR OverRideRateFlag EQ 3>
			<cfset overRideAddSubtractMultiplier = 1 /><!---- 1 = Subtract, -1 = Add ---->
			<cfif OverRideRateFlag eq 3>
				<cfset overRideAddSubtractMultiplier = -1 /><!---- 1 = Subtract, -1 = Add ---->
			</cfif>
			<cfif Billback_Product_Program.ExpRT_Discount_Type_Id eq 1 >
				<cfset rOver = avgPricePaid - ExpRT_Rate />
				<cfset expRate = Total_Weighted_Rate - rOver * overRideAddSubtractMultiplier />
					<TR CLASS="MaintableTHEAD" bgcolor="FFFF00">
						<TD COLSPAN="10" ALIGN="RIGHT"><B>Rate Override (#Billback_Product_Program.ExpRT_Contract_Number#)</B></TD>
						<TD ALIGN="CENTER"><B>=</B></TD>
						<TD>#NumberFormat(avgPricePaid, DEVIATION_RATE_FORMAT)# - #NumberFormat(ExpRT_Rate, DEVIATION_RATE_FORMAT)# = #NumberFormat(rOver, DEVIATION_RATE_FORMAT)# </TD>
					</TR>
			<cfelse>
				<cfset rOver = ExpRT_Rate />

				<cfif ExpRT_Unit_Of_Measure_ID neq Billback_UOM>
					<cfif ExpRT_Unit_Of_Measure_ID eq 1 and Billback_UOM eq 2>
						<cfset rOver = rOver / Net_Weight /> <!---- convert from CS to LB ---->
					<cfelseif ExpRT_Unit_Of_Measure_ID eq 2 and Billback_UOM eq 1>
						<cfset rOver = rOver * Net_Weight /> <!---- convert from LB to CS ---->
					<cfelseif ExpRT_Unit_Of_Measure_ID eq 3>
						<cfset rOver = rOver * 0.01 * rateOverridePrice />
					</cfif>
					<cfset ExpRT_Unit_Of_Measure_ID = Billback_UOM />
					<cfset ExpRT_Rate = rOver />
				</cfif>

				<cfset expRate = Total_Weighted_Rate - rOver * overRideAddSubtractMultiplier />
				<TR CLASS="MaintableTHEAD" bgcolor="FFFF00">
					<TD COLSPAN="10" ALIGN="RIGHT"><B>Rate Override (#Billback_Product_Program.ExpRT_Contract_Number#)</B></TD>
					<TD ALIGN="CENTER"><B>=</B></TD>
					<TD>#NumberFormat(ExpRT_Rate, DEVIATION_RATE_FORMAT)# / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</TD>
				</TR>

			</cfif>
		<cfelse>
			<!--- Expected Rate = 0 since Billback_Product_Program.Expected_Rate_Flag EQ 1 --->
			<cfset expRate = 0 />
		</CFIF>
			<TR CLASS="MaintableTHEAD" bgcolor="FFFF00">
				<TD COLSPAN="10" ALIGN="RIGHT"><B><CFIF OverRideRateFlag EQ 1>Override Expected Rate (#Billback_Product_Program.ExpRT_Contract_Number#)
			   		<CFELSEIF OverRideRateFlag EQ 2 OR OverRideRateFlag EQ 3>Override Adjusted Rate</CFIF></B></TD>
				<TD ALIGN="CENTER"><B>=</B></TD>
				<TD style="border:solid 2px blue;">#NumberFormat(expRate, DEVIATION_RATE_FORMAT)#
			/ #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</TD>
			</TR>
	</CFIF>
</TABLE>
<CFELSE>
	<BR>
	<B><FONT COLOR="Red">This product does not exist in the system</FONT></B>
	<BR>
</CFIF>
</CFOUTPUT>


<!--------------------------------------------------------------------------------------
Get information for finding out the invoive revenue for product types fixed and formula
--------------------------------------------------------------------------------------->

<!----------------- show invoice days to be taken into account ------------------>

<!------------------ End Invoice Info display for fixed and formula ----------------------------->
<CFSILENT>

<!----------------- Get deviation info from database -------------------------------------------->
<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Product_Discount_Type_Rate">
SELECT	CASE
		<cfif Billback_UOM eq 2> <!--- Convert from CS to LB --->
		WHEN Billback_Product.BB_Product_UOM = 1 THEN CAST(Billback_Product.BB_Product_Quantity as float) * #Net_Weight#
		<cfelse> <!--- Convert from LB to CS --->
		WHEN Billback_Product.BB_Product_UOM = 2 THEN CAST(Billback_Product.BB_Product_Quantity as float) / #Net_Weight#
		</cfif>
		ELSE Billback_Product.BB_Product_Quantity
		END as BB_Product_Quantity,
		Units_of_Measure.Unit_Of_Measure_Desc,Units_of_Measure.Unit_Of_Measure_Desc_Singular
		, Billback_Product_Detail.BB_Rate
		,CASE
		WHEN Units_of_Measure.Unit_Of_Measure_ID = 1 THEN
			BB_Rate_CS
		ELSE
			BB_Rate_LB
		END AS Billback_Rate
		,CASE
		WHEN Units_of_Measure.Unit_Of_Measure_ID = 1 THEN
			E_Rate_CS
		ELSE
			E_Rate_LB
		END AS Expected_Rate,
    	<cfif BB_Product_Type_ID eq 1>
    	CASE
    	WHEN Units_of_Measure.Unit_Of_Measure_ID = 1 THEN
    			Orig_E_Rate_CS
    		ELSE
    			Orig_E_Rate_LB
    		END AS Orig_E_Rate
    	<cfelse>
    	null AS Orig_E_Rate
    	</cfif>
		FROM	Billback_Product_Detail
		INNER JOIN	Billback_Product
		ON
		(
			(Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(Billback_Product.Deleted = 0)
		)
		<CFSWITCH EXPRESSION="#BB_Product_Type_ID#">
		<CFCASE VALUE="1">
		INNER JOIN	BB_Fixed_Product_Rate
		ON
		(
			(BB_Fixed_Product_Rate.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(BB_Fixed_Product_Rate.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		</CFCASE>
		<CFCASE VALUE="2">
		INNER JOIN	BB_Rebate_Product_Rate
		ON
		(
			(BB_Rebate_Product_Rate.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(BB_Rebate_Product_Rate.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		</CFCASE>
		<CFCASE VALUE="5">
		INNER JOIN	BB_Formula_Product_Rate
		ON
		(
			(BB_Formula_Product_Rate.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(BB_Formula_Product_Rate.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		</CFCASE>
		<CFCASE VALUE="11">
		INNER JOIN	BB_Bid_Request_Product_Rate
		ON
		(
			(BB_Bid_Request_Product_Rate.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
			AND
			(BB_Bid_Request_Product_Rate.BB_Product_Type_ID = Billback_Product_Detail.BB_Product_Type_ID)
		)
		</CFCASE>
		</CFSWITCH>
		LEFT JOIN	Units_of_Measure
		ON		(Units_of_Measure.Unit_Of_Measure_ID = #Billback_UOM#)
	WHERE
		Billback_Product_Detail.Billback_Product_Detail_ID = <cfqueryparam value='#Billback_Product_Detail_ID#'>
		AND
		Billback_Product_Detail.Deleted = <cfqueryparam value=0>
</CFQUERY>
</CFSILENT>

<!------------- Show deviation calculation ------------------>
<BR>
<SPAN CLASS="Title2">Rate <cfoutput>#appSettings.getDeviationLabel()#</cfoutput> calculation</SPAN>
<HR COLOR="Orange">
<CFIF Billback_Product_Discount_Type_Rate.recordCount GT 0>
	<!--- 89725 Set Expected = Claimed when Claimed is negative --->
	<cfset showNegativeClaimedAmtMsg = 0 />
	<cfset showNegativeClaimedAmtMsgExtraWidth = 0 />
	<cfif Billback_Product_Discount_Type_Rate.BB_Rate LT 0 AND Billback_Product_Discount_Type_Rate.Expected_Rate NEQ Total_Weighted_Rate>
		<cfset showNegativeClaimedAmtMsg = 1 />
		<cfset showNegativeClaimedAmtMsgExtraWidth = 300 />
	</cfif>
	<CFOUTPUT>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="#Evaluate("(Table_Width*2/3)+#showNegativeClaimedAmtMsgExtraWidth#")#">
		<TR>
			<TD>Total Amount Claimed</TD>
			<TD>A1</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			#DollarFormat(Billback_Product_Discount_Type_Rate.BB_Rate)#
			</TD>
		</TR>
		<TR>
			<TD>Total Volume Claimed</TD>
			<TD>V1</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			#Billback_Product_Discount_Type_Rate.BB_Product_Quantity# #Billback_Product_Discount_Type_Rate.Unit_Of_Measure_Desc#
			</TD>
		</TR>
		<TR>
			<TD>Rate Claimed</TD>
			<TD>R1 = A1 / V1</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			<cfif Billback_Product_Discount_Type_Rate.BB_Product_Quantity NEQ 0>
				<CFSET Rate_Claimed=(Billback_Product_Discount_Type_Rate.BB_Rate/Billback_Product_Discount_Type_Rate.BB_Product_Quantity)>
			<cfelse>
				<CFSET Rate_Claimed=Billback_Product_Discount_Type_Rate.BB_Rate>
			</cfif>
			#NumberFormat(Rate_Claimed, DEVIATION_RATE_FORMAT)# / #Billback_Product_Discount_Type_Rate.Unit_Of_Measure_Desc_Singular#
			</TD>
		</TR>
		<CFIF showNegativeClaimedAmtMsg EQ 0 AND (Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 1 OR Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 2 OR Billback_Product_Program.ExpRT_Expected_Rate_Flag EQ 3)>
			<cfif BB_Product_Type_ID eq 1 and Billback_Product_Discount_Type_Rate.Orig_E_Rate neq "">
				<cfset expRate = Billback_Product_Discount_Type_Rate.Orig_E_Rate />
			<cfelse>
				<cfset expRate = Weighted_Rate />
			</cfif>
			<!---  USE Weighted_Rate since Expected_Rate has the component Override baked in already
				<cfset r = Billback_Product_Discount_Type_Rate.Expected_Rate + Billback_Product_Discount_Type_Rate.Rate />--->
			<cfset OverRideRateFlag = Billback_Product_Program.ExpRT_Expected_Rate_Flag />
			<cfif Billback_Product_Program.ExpRT_Discount_Type_Id eq 1 >
				<cfset rOver = avgPricePaid - ExpRT_Rate />
			<cfelse>
				<cfset rOver = ExpRT_Rate />

			</cfif>

			<TR>
				<TD><B>Expected Rate</B></TD>
				<TD><B>ER</B></TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<B>#NumberFormat(expRate, DEVIATION_RATE_FORMAT)#
				/ #Billback_Product_Discount_Type_Rate.Unit_Of_Measure_Desc_Singular#</B>
				</TD>
			</TR>
			<CFIF OverRideRateFlag EQ 2 OR OverRideRateFlag EQ 3>
			<TR>
				<TD><B>Rate Override (#Billback_Product_Program.ExpRT_Contract_Number#)</B></TD>
				<TD><B>RO</B></TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<B>#NumberFormat(rOver, DEVIATION_RATE_FORMAT)# / #Billback_Product_Discount_Type_Rate.Unit_Of_Measure_Desc_Singular#</B>
				</TD>
			</TR>
			</CFIF>
			<TR>
				<TD><B><CFIF OverRideRateFlag EQ 1>Override Expected Rate (#Billback_Product_Program.ExpRT_Contract_Number#)
				   <CFELSEIF OverRideRateFlag EQ 2 OR OverRideRateFlag EQ 3>Override Adjusted Rate</CFIF></B></TD>
				<TD><B><CFIF OverRideRateFlag EQ 2>R2 = ER - RO<CFELSEIF OverRideRateFlag EQ 3>R2 = ER + RO<cfelse>R2</cfif></B></TD>
				<TD>&nbsp:&nbsp;</TD>
				<TD>
				<B>#NumberFormat(Billback_Product_Discount_Type_Rate.Expected_Rate, DEVIATION_RATE_FORMAT)#
				/ #Billback_Product_Discount_Type_Rate.Unit_Of_Measure_Desc_Singular#</B>
				</TD>
			</TR>
		<cfelse>
		<TR>
			<TD><B>Expected Rate</B></TD>
			<TD><B>R2</B></TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			<B>#NumberFormat(Billback_Product_Discount_Type_Rate.Expected_Rate, DEVIATION_RATE_FORMAT)#
			/ #Billback_Product_Discount_Type_Rate.Unit_Of_Measure_Desc_Singular#</B>
			</TD>
			<!--- 89725 Set Expected = Claimed when Claimed is negative --->
			<cfif showNegativeClaimedAmtMsg>
			<TD width="#showNegativeClaimedAmtMsgExtraWidth#">Expected Rate = Claimed Rate, as claimed amount is negative</TD>
			</cfif>
		</TR>
		</CFIF>
		<CFIF Billback_Rate_Tolerance.recordCount GT 0>
			<CFSET rate_Tolerance = Billback_Rate_Tolerance.BB_Tolerance_ERT>
		<CFELSE>
			<CFSET rate_Tolerance = 0>
		</CFIF>
		<TR>
			<TD>Rate Tolerance</TD>
			<TD>R3</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			#NumberFormat(rate_Tolerance,"___")#%
			</TD>
		</TR>
		<TR>
			<TD>Adjusted Expected Rate</TD>
			<TD>R4 = R2 + (R2 * R3)</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			<CFSET addAdjustedRate = (Billback_Product_Discount_Type_Rate.Expected_Rate * rate_Tolerance) / 100>
			<CFSET adjusted_Expected_rate = Billback_Product_Discount_Type_Rate.Expected_Rate + addAdjustedRate>
			#NumberFormat(adjusted_Expected_rate, DEVIATION_RATE_FORMAT)#
			</TD>
		</TR>
		<TR>
			<TD>#appSettings.getDeviationLabel()# Rate</TD>
			<TD>R5 = R4 - R1</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			<CFSET dev_Rate = adjusted_Expected_rate - Rate_Claimed>
			#NumberFormat(dev_Rate, DEVIATION_RATE_FORMAT)#
			</TD>
		</TR>
		<CFIF dev_Rate GT 0 AND application.appSettingsGet.get_Setting('Claim_Less_Than_Expected_Deviation') neq '1'>
			<CFSET dev_Rate = 0>
		</CFIF>
		<TR>
			<TD>Effective #appSettings.getDeviationLabel()# Rate</TD>
			<TD>R6</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			#NumberFormat(dev_Rate, DEVIATION_RATE_FORMAT)#
			</TD>
		</TR>
		<TR>
			<TD>Rate #appSettings.getDeviationLabel()# Percentage</TD>
			<TD>R7 = R6 / R1</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			<CFSET dev_Rate_Percent = 0 />
			<cfif Rate_Claimed NEQ 0>
				<CFSET dev_Rate_Percent = (dev_Rate * 100) / Rate_Claimed>
			</cfif>
			#NumberFormat(dev_Rate_Percent, DEVIATION_PERCENT_FORMAT)#%
			</TD>
		</TR>
		<TR>
			<TD>#appSettings.getDeviationLabel()# Amount</TD>
			<TD>A2 = A1 * R7</TD>
			<TD>&nbsp:&nbsp;</TD>
			<TD>
			<CFSET dev_Amount = (Billback_Product_Discount_Type_Rate.BB_Rate * dev_Rate_Percent) / 100>
			#NumberFormat(dev_Amount, DEVIATION_RATE_FORMAT)#
			</TD>
		</TR>
	</TABLE>
	</CFOUTPUT>
</CFIF>

<CFIF SHOW_DEVIATION_DETAIL_FOOTER>
<BR><BR>
<TABLE ALIGN="CENTER" WIDTH="50%">
	<TD ALIGN="CENTER">
	<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"printPage();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"print"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
	<TD ALIGN="CENTER">
	<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</TABLE>
		<BR><BR>


</BLOCKQUOTE>
</form>
</BODY>
</HTML>
<CFELSE>
	</BLOCKQUOTE>
</CFIF>
