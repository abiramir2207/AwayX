<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<cfsavecontent variable="head_content">
		<cf_include files="/styles/jQueryUI_18/jquery.multiselect.css, /styles/jQueryUI_18/jquery-ui-1.8.10.custom.css">
		<style>
			body { margin: 0; }
			p { margin: 0; }
			fieldset#border_9999 { 
				box-sizing: border-box;
				margin: 0 1%; 
			}
			span#title_9999 { font-family: Arial; }
			table.adv_search {
				border: 0;
				margin: 0 auto;
				width: 100%;
			}
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<cfif ISDEfined("URL.ForReport") AND URL.ForReport EQ 1>
	<cfset PAGE_TITLE="Deductions Report Builder">
<CFELSE>
	<cfset PAGE_TITLE="Advanced Search">
</cfif>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfinclude template="/common_files/javascript.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---User profile--->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", { "profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<CFQUERY NAME="DeductionsProfilesSettings" DATASOURCE="#application.datasource#">
	SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</CFQUERY>
</cfif>

<cfset useLakebaseForUserHasAssignments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForUserHasAssignments>
	<cftry>
		<cfset UserHasAssignments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", { "analyst_user_id" = "eq.#request.AccessStructure.User_ID#", "deleted" = "eq.0" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUserHasAssignments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUserHasAssignments>
<CFQUERY NAME="UserHasAssignments" DATASOURCE="#Application.Datasource#">
	 SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0
</CFQUERY>
</cfif>

<cfset useLakebaseForisSupervisor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForisSupervisor>
	<cftry>
		<cfset isSupervisor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", { "analyst_user_id" = "eq.#request.AccessStructure.User_ID#", "is_supervisor" = "eq.1", "deleted" = "eq.0" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisSupervisor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisSupervisor>
<CFQUERY NAME="isSupervisor" DATASOURCE="#Application.Datasource#">
	 SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Is_Supervisor = 1 AND Deleted=0
</CFQUERY>
</cfif>

<cfset AppLevelAllowCredits = application.oApplicationAppSettingsManager.getApplicationAppSettings().getDDAllowNegativeAmountCredits() />

<cfset AccessAllDeductions = 0>

<!---- If user is not an analyst ----->
<cfif (NOT UserHasAssignments.Recordcount OR isSupervisor.recordcount) AND DeductionsProfilesSettings.DD_ACCESS_LEVEL>
	<cfset AccessAllDeductions = 1>
</cfif>

<CFINCLUDE TEMPLATE="/Deductions/DD_Supervisor_Qry.cfm">
<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.User_ID, 0, 1) />

<!--- DEV NOT: DAA; D14555 --->
<CFPARAM NAME="SrchByAnalystAllowed" DEFAULT="false">
<!---- if the user profile "search by analyst"" = on or if user is an HQ, they can access all deductions ---->
<cfif DeductionsProfilesSettings.DD_Search_By_Analyst OR ListFind(UserPositionList, HQPosition.User_Positions_ID)>
	<cfset SrchByAnalystAllowed = true>
	<cfset AccessAllDeductions = 1>
</cfif>
<!---
<CFDUMP VAR="#URL#">
<CFDUMP VAR="#FORM#">
 --->

<CFPARAM NAME="Selected_Distributor" DEFAULT="">
<CFPARAM NAME="Selected_Broker" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" 	DEFAULT="">
<CFPARAM NAME="FORM.DD_Number" DEFAULT="">
<CFPARAM NAME="FORM.Dollar_Operator" DEFAULT="">
<CFPARAM NAME="FORM.DD_Amount" DEFAULT="">
<CFPARAM NAME="FORM.DD_To_Amount" DEFAULT="">
<CFPARAM NAME="FORM.Date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Date_Time" DEFAULT="">
<CFPARAM NAME="FORM.To_Date_Time" DEFAULT="">

<CFPARAM NAME="FORM.ClDate_Operator" DEFAULT="">
<CFPARAM NAME="FORM.ClDate_Time" DEFAULT="">
<CFPARAM NAME="FORM.ClTo_Date_Time" DEFAULT="">

<CFPARAM NAME="FORM.Check_No" DEFAULT="">
<CFPARAM NAME="FORM.Service_Market_ID" DEFAULT="">
<CFPARAM NAME="FORM.Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Family_ID" DEFAULT="">
<CFPARAM NAME="FORM.Analyst_User_ID" DEFAULT="">
<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="">
<CFPARAM NAME="FORM.Broker" DEFAULT="">
<CFPARAM NAME="FORM.DD_Stage_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Aging" DEFAULT="">
<CFPARAM NAME="FORM.Service_Zone_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Reason_Code_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Status" DEFAULT="">
<CFPARAM NAME="FORM.DD_Parent_ID" DEFAULT="">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<!--- <CFPARAM NAME="SubmitTheForm" default="0"> --->
<!--- <CFPARAM NAME="FORM.Distributor_Bill_To_ID" DEFAULT=""> --->
<CFPARAM NAME="FORM.Distributor_Bill_To" DEFAULT="">
<CFPARAM NAME="FORM.Line_Of_Business_ID" DEFAULT="">
<CFPARAM NAME="FORM.Business_Segment_ID" DEFAULT="">
<CFPARAM NAME="FORM.Q_Brand_ID" DEFAULT="">
<CFPARAM NAME="FORM.DD_Operator_ID" DEFAULT="">
<CFPARAM NAME="FORM.IsBusEnabled" DEFAULT="0">
<CFPARAM NAME="FORM.IsParentDeduction" 	DEFAULT="1">
<CFPARAM NAME="FORM.Filter_Closed" DEFAULT="1">
<CFPARAM NAME="FORM.Only_DD_With_Inactive_Relations" DEFAULT="0">
<CFPARAM NAME="FORM.Rebill_Number" DEFAULT="">
<cfparam name="form.date_type" default="deduction">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<!--- Dev Note: KAL; 7821 --->
<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />

<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
	SELECT 		User_ID, Name_First, Name_Last
	FROM 		DD_Analyst INNER JOIN 	_Users ON _Users.user_ID = DD_Analyst.Analyst_User_ID
	WHERE 		DD_Analyst.Deleted=0 AND _Users.Deleted=0
	ORDER BY	_Users.Name_First,_Users.Name_Last
</CFQUERY>
<cfset useLakebaseForGet_Action = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForGet_Action>
	<cftry>
		<cfset Get_Action = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_stage", { "select" = "dd_stage_description,dd_stage_id", "deleted" = "eq.0" }),
			"dd_stage_description,dd_stage_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Action = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Action>
<CFQUERY NAME="Get_Action" DATASOURCE="#Application.Datasource#">
	SELECT 	DD_Stage_Description, DD_Stage_ID
	FROM 	DD_Stage
	WHERE	Deleted=0
</CFQUERY>
</cfif>
<cfset useLakebaseForGet_Market = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_markets")>
<cfif useLakebaseForGet_Market>
	<cftry>
		<cfset Get_Market = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_markets", { "select" = "service_market_id,market_name,market_number", "deleted" = "eq.0", "order" = "market_name.asc" }),
			"service_market_id,market_name,market_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Market = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Market>
<CFQUERY NAME="Get_Market" DATASOURCE="#Application.Datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
	SELECT 		Service_Market_ID, Market_Name, Market_Number
	FROM 		Service_Markets
	WHERE 		Deleted = 0
	ORDER BY	Market_Name
</CFQUERY>
</cfif>
<cfset useLakebaseForGet_Region = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_regions")>
<cfif useLakebaseForGet_Region>
	<cftry>
		<cfset Get_Region = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_regions", { "select" = "service_region_id,region_number,region_name", "deleted" = "eq.0", "order" = "region_name.asc" }),
			"service_region_id,region_number,region_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Region = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Region>
<CFQUERY NAME="Get_Region" DATASOURCE="#Application.Datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
	SELECT 		Service_Region_ID, Region_Number, Region_Name
	FROM 		Service_Regions
	WHERE 		Deleted = 0
	ORDER BY 	Region_Name
</CFQUERY>
</cfif>
<cfset useLakebaseForGet_Zone = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_zones")>
<cfif useLakebaseForGet_Zone>
	<cftry>
		<cfset Get_Zone = application.oLakebase.toQuery(
			application.oLakebase.selectRows("service_zones", { "select" = "service_zone_id,zone_number,zone_name", "deleted" = "eq.0", "zone_name" = "neq.", "order" = "zone_name.asc" }),
			"service_zone_id,zone_number,zone_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Zone = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Zone>
<CFQUERY NAME="Get_Zone" DATASOURCE="#Application.Datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
	SELECT 		Service_Zone_ID, Zone_Number, Zone_Name
	FROM 		Service_Zones
	WHERE 		Deleted=0 AND len(Zone_Name) > 0
	ORDER BY 	Zone_Name
</CFQUERY>
</cfif>
<cfset useLakebaseForGet_ReasonCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForGet_ReasonCode>
	<cftry>
		<cfset Get_ReasonCode = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"select" = "dd_reason_code_id,dd_reason_code_description,dd_reason_code",
				"deleted" = "eq.0",
				"display_in" = "in.(1,3)",
				"dd_reason_code" = "not.is.null",
				"order" = "dd_reason_code_description.asc"
			}),
			"dd_reason_code_id,dd_reason_code_description,dd_reason_code"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_ReasonCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_ReasonCode>
<CFQUERY NAME="Get_ReasonCode" DATASOURCE="#Application.Datasource#">
	SELECT 		DD_Reason_Code_ID, DD_Reason_Code_Description, DD_Reason_Code
	FROM 		DD_Reason_Code
	WHERE 		Deleted=0 AND Display_In IN (1,3)
	AND			DD_Reason_Code IS NOT NULL
	ORDER BY	DD_Reason_Code_Description
</CFQUERY>
</cfif>
<cfset useLakebaseForGet_Aging = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_aging")>
<cfif useLakebaseForGet_Aging>
	<cftry>
		<cfset Get_Aging = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_aging", { "select" = "tier_number,dd_aging_label", "deleted" = "eq.0", "order" = "tier_number.asc" }),
			"tier_number,dd_aging_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Aging = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Aging>
<CFQUERY NAME="Get_Aging" DATASOURCE="#Application.Datasource#">
	SELECT 		Tier_Number, DD_Aging_Label
	FROM 		DD_Aging
	WHERE 		Deleted=0
	ORDER BY	Tier_Number
</CFQUERY>
</cfif>
<cfset useLakebaseForGetFamilyNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForGetFamilyNames>
	<cftry>
		<cfset GetFamilyNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_family", { "select" = "family_id,family_name,family", "deleted" = "eq.0", "order" = "family_name.asc" }),
			"family_id,family_name,family"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFamilyNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFamilyNames>
<cfquery name="GetFamilyNames" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
	SELECT 		Family_ID, Family_Name, Family
	FROM 		Distributor_Family
	WHERE 		Deleted = 0
	ORDER BY 	Family_Name
</cfquery>
</cfif>
<!----
<cfset useLakebaseForGetBillTo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_bill_to")>
<cfif useLakebaseForGetBillTo>
	<cftry>
		<cfset GetBillTo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_bill_to", {
				"deleted" = "eq.0",
				"order" = "name.asc",
				"select" = "distributor_bill_to_id,shr_bill_to,name"
			}), "distributor_bill_to_id,shr_bill_to,name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillTo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillTo>
<CFQUERY NAME="GetBillTo" DATASOURCE="#Application.Datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
	SELECT 		Distributor_Bill_To_ID, Shr_Bill_To, Name
	FROM 		Distributor_Bill_To
	WHERE 		Deleted=0
	ORDER BY	Name
</CFQUERY>
</cfif>
--->
<cfset useLakebaseForGetLOB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("line_of_business")>
<cfif useLakebaseForGetLOB>
	<cftry>
		<cfset GetLOB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("line_of_business", { "select" = "line_of_business_name,line_of_business,line_of_business_id", "deleted" = "eq.0", "order" = "line_of_business_name.asc" }),
			"line_of_business_name,line_of_business,line_of_business_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLOB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLOB>
<CFQUERY NAME="GetLOB" DATASOURCE="#Application.Datasource#">
	SELECT 		Line_Of_Business_Name, Line_Of_Business, Line_Of_Business_ID
	FROM 		Line_Of_Business
	WHERE 		Deleted=0
	ORDER BY Line_Of_Business_Name
</CFQUERY>
</cfif>
<cfif FORM.Distributor_List NEQ "">
	<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
	<cfif useLakebaseForDist_Search_Result>
		<cftry>
			<cfset Dist_Search_Result = application.oLakebase.toQuery(
				application.oLakebase.selectRows("bsa_foodservice_customers", {
					"select" = "bsa_foodservice_customers_id,name,shr_ship_to",
					"bsa_foodservice_customers_id" = "in.(#FORM.Distributor_List#)",
					"deleted" = "eq.0",
					"active_code" = "eq.A",
					"order" = "name.asc"
				}),
				"bsa_foodservice_customers_id,name,shr_ship_to"
			)>
			<cfcatch type="any">
				<cfset useLakebaseForDist_Search_Result = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDist_Search_Result>
	<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT BSA_Foodservice_Customers_ID,Name,Shr_Ship_To
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(FORM.Distributor_List, "'", ",")#)
			AND BSA_Foodservice_Customers.Deleted = 0
			AND BSA_Foodservice_Customers.Active_Code = 'A'
		ORDER BY Name
	</CFQUERY>
	</cfif>
	<cfset Selected_Distributor=VAlueList(Dist_Search_Result.Shr_Ship_To)>
</cfif>
<cfif FORM.Broker_List NEQ "">
	<cfset useLakebaseForBroker_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
	<cfif useLakebaseForBroker_Search_Result>
		<cftry>
			<cfset Broker_Search_Result = application.oLakebase.toQuery(
				application.oLakebase.selectRows("bsa_foodservice_brokers", {
					"select" = "bsa_foodservice_brokers_id,broker_name",
					"bsa_foodservice_brokers_id" = "in.(#FORM.Broker_List#)",
					"deleted" = "eq.0",
					"active_code" = "eq.A",
					"order" = "broker_name.asc"
				}),
				"bsa_foodservice_brokers_id,broker_name"
			)>
			<cfcatch type="any">
				<cfset useLakebaseForBroker_Search_Result = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForBroker_Search_Result>
	<CFQUERY NAME="Broker_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT BSA_Foodservice_Brokers_ID,LTRIM(RTRIM(Broker_Name)) AS Broker_Name
		FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN (#ListQualify(FORM.Broker_List, "'", ",")#)
			AND BSA_Foodservice_Brokers.Deleted = 0
			AND BSA_Foodservice_Brokers.Active_Code = 'A'
		ORDER BY Broker_Name
	</CFQUERY>
	</cfif>
	<cfset Selected_Broker = VAlueList(Broker_Search_Result.Broker_Name)>
</cfif>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<CFQUERY NAME="GetAllBusinessSegmet" DATASOURCE="#Application.Datasource#">
		SELECT DISTINCT Business_Segment.Business_Segment_ID, Business_Unit_ID, Business_Unit_Desc
		FROM Business_Segment INNER JOIN Deductions ON Deductions.Business_Segment_ID = Business_Segment.Business_Segment_ID AND	Deductions.Deleted = 0
		WHERE Active = 1 AND Business_Segment.Deleted = 0
	</CFQUERY>
</cfif>
<cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
	<CFQUERY NAME="GetQBrand" DATASOURCE="#Application.Datasource#">
		SELECT DISTINCT Q_Brand_Desc.Q_Brand_ID, Q_Brand
		FROM Q_Brand_Desc
		INNER JOIN Deductions ON Deductions.Q_Brand_ID = Q_Brand_Desc.Q_Brand_ID AND Deductions.Deleted = 0
		WHERE Q_Brand_Desc.Deleted = 0
	</CFQUERY>
</cfif>
<cfif application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
	<CFQUERY NAME="GetOperator" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT DD_Operator.DD_Operator_ID, DD_Operator_Name
		FROM 		DD_Operator INNER JOIN 	Deductions ON Deductions.DD_Operator_ID = DD_Operator.DD_Operator_ID AND Deductions.Deleted = 0
		WHERE 		DD_Operator.Deleted = 0
	</CFQUERY>
</cfif>

<cfif deductionsprofilessettings.dd_access_level gt 0>
	<table border="0" cellpadding="0" cellspacing="0" align="right">
		<tr>
			<td>
				<a href="/deductions/scorecard/index.cfm?SC_Shr_Ship_To=&SC_Broker_Shard=&Show_Status=1&Program_Agree_Status_ID=">
					<cfoutput>#application.util.string.actionLinkFormat("scorecard")#</cfoutput>
				</a>
			</td>
		</tr>
	</table>
</cfif>
<br>

<CFPARAM NAME="FORM.DD_Number" DEFAULT="">
<CFPARAM NAME="FORM.pageLength" DEFAULT="10">
<CFPARAM NAME="FORM.PassForReport" DEFAULT="0">
<cfset IFRAMEHeight = "310">


<cfif IsDefined("URL.ForReport")>
	<cfset FORM.PassForReport = 1>
</cfif>

<FORM NAME="DD_Adv_Search" ACTION="Ded_report_Builder.cfm" METHOD="post" TARGET="Search_Result">
<CFOUTPUT>
<!--- <FORM NAME="DD_Adv_Search" ACTION="#CGI.SCRIPT_Name#" METHOD="post" TARGET="Search_Result"> --->
<input NAME="Form_Submitted" 				TYPE="Hidden"	VALUE="1">
<input NAME="Distributor_List" 				TYPE="Hidden"   VALUE="#FORM.Distributor_List#" ID="Distributor_List">
<input NAME="Broker_List" 					TYPE="Hidden"	VALUE="#FORM.Broker_List#"		ID="Broker_List">
<input NAME="pageLength" 					TYPE="Hidden"  	VALUE="#FORM.pageLength#">
<input NAME="PassForReport" 				TYPE="Hidden"  	VALUE="#FORM.PassForReport#">
<input NAME="AccessAllDeductions" 			TYPE="Hidden"  	VALUE="#AccessAllDeductions#">
<input NAME="SelectSingleSearchResultOnly"	TYPE="Hidden"  	VALUE="0">
<cfif FORM.PassForReport EQ 1>
<input NAME="DD_Report_CashSpan" TYPE="Hidden" VALUE="#Now()#">
</cfif>

</CFOUTPUT>
<cfset Layer_ID = 9999>
<CF_openLayer
	Border="Yes"
	BorderSize="1"
	BorderColor="orange"
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="Hide Deductions Search Screen"
	TitleClosed="Show Deductions Search Screen"
	TitleTooltip="Click to Show/Hide Search Screen"
	TitleFont="font"
	TitleColor="Blue"
	TitleSize="9"
	IsClosed="No"
	Width="98%"
	layerid="#Layer_ID#">
<CFOUTPUT>
	<TABLE class="adv_search">
		<TR>
			<TD colspan="6">
				<FONT SIZE="2" COLOR="red">
					<B>Deduction:</B>
				</FONT><BR>
				<HR COLOR="navy">
			</TD>
		</TR>
		<TR>
			<TD colspan="6">
				<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="1250">  <!--26491-->
					<TR>
						<TD <cfif Isdefined("FORM.FromSmallSearch") AND FORM.DD_Number NEQ "">BGCOLOR= "C0C0C0"</cfif>>
							<B>Deduction Number:</B><BR>
							<input TYPE="Text" NAME="DD_Number" VALUE="#FORM.DD_Number#" STYLE="Width:170px">
						</TD>
						<TD>
							<B>Check ## :</B><BR>
							<input TYPE="Text" NAME="Check_No" VALUE="#FORM.Check_No#" SIZE="10">
						</TD>
						<TD <cfif Isdefined("FORM.FromSmallSearch") AND FORM.DD_Amount NEQ "">BGCOLOR= "C0C0C0"</cfif>><B>Amount $:</B><BR>
							<SELECT NAME="Dollar_Operator" ID="Dollar_Operator" ONCHANGE="Javascript: enableInput('Dollar_Operator','DD_To_Amount')" >
								<!--- <OPTION VALUE="" <cfif FORM.Dollar_Operator EQ "">SELECTED</cfif>></OPTION> --->
								<OPTION VALUE="=" <cfif FORM.Dollar_Operator EQ "=">SELECTED</cfif>>=</OPTION>
								<OPTION VALUE="<" <cfif FORM.Dollar_Operator EQ "<">SELECTED</cfif>><</OPTION>
								<OPTION VALUE=">" <cfif FORM.Dollar_Operator EQ ">">SELECTED</cfif>>></OPTION>
								<OPTION VALUE="between" <cfif FORM.Dollar_Operator EQ "between">SELECTED</cfif>>between</OPTION>
							</SELECT>

							<input TYPE="Text" NAME="DD_Amount" VALUE="#FORM.DD_Amount#" SIZE="11" onKeyUp="clenseText(this, '0123456789.-');" >&nbsp;&nbsp;&nbsp;
							<input TYPE="Text" NAME="DD_To_Amount" VALUE="#FORM.DD_To_Amount#" SIZE="11" onKeyUp="clenseText(this, '0123456789.-');" DISABLED STYLE="background-color: cccccc">

						</TD>
						<TD COLSPAN="2" <cfif Isdefined("FORM.FromSmallSearch") AND FORM.Date_Time NEQ "">BGCOLOR= "C0C0C0"</cfif>>
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="5">
								<TR>
									<td><b>Date:</b><br>
										<select name="date_type" id="date_type">
											<option <cfif form.date_type is "deduction">selected</cfif>>Deduction</option>
											<option <cfif form.date_type is "created">selected</cfif>>Created</option>
											<option <cfif form.date_type is "closed">selected</cfif>>Closed</option>
										</select>
									</td>
									<TD><BR>
										<SELECT NAME="Date_Operator" ID="Date_Operator" style="width:65px;" ONCHANGE="Javascript: enableDate(1)"><!--- <cfif Isdefined("FORM.FromSmallSearch") AND FORM.Date_Operator NEQ "">STYLE="background-color: FF00FF;"</cfif> --->
											<!--- <OPTION VALUE="" <cfif FORM.Date_Operator EQ "">SELECTED</cfif>></OPTION> --->
											<OPTION VALUE=">=" <cfif FORM.Date_Operator EQ ">=">SELECTED</cfif>>>=</OPTION>
											<OPTION VALUE="=" <cfif FORM.Date_Operator EQ "=">SELECTED</cfif>> = </OPTION>
											<OPTION VALUE="<=" <cfif FORM.Date_Operator EQ "<=">SELECTED</cfif>><=</OPTION>
											<OPTION VALUE="between" <cfif FORM.Date_Operator EQ "between">SELECTED</cfif>>between</OPTION>
										</SELECT>
									</TD>
									<TD NOWRAP><BR>
										<CF_EASYDATE FORMNAME="DD_Adv_Search" FIELDNAME="Date_Time" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Date_Time#" STYLE="background-color: FF00FF;"><!--- <cfif Isdefined("FORM.FromSmallSearch") AND FORM.BROKER_LIST NEQ "">STYLE="background-color: FF00FF;"</cfif> --->
									</TD>
									<TD><BR>
										<DIV style="display:inline;" ID="Div_DD_Adv_Search">
										<CF_EASYDATE FORMNAME="DD_Adv_Search" FIELDNAME="To_Date_Time" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.To_Date_Time#">
										</DIV>
									</TD>
								</TR>
							</TABLE>
						</TD>
					</TR>
					<TR>
						<TD><B>Aging:</B><BR>
							<SELECT NAME="DD_Aging" ID="DD_Aging" multiple="multiple">
								<cfloop QUERY="Get_Aging">
									<OPTION VALUE="#Tier_Number#" <cfif Tier_Number EQ FORM.DD_Aging>SELECTED</cfif>>
										#DD_Aging_Label#
									</OPTION>
								</cfloop>
							</SELECT>
						</TD>

						<TD><B>Status:</B><BR>
							<cfif DeductionsProfilesSettings.DD_Delete EQ 1>
								<cfset Status_List = "New,Open,<cfif application.returned_customer_setting.DD_Show_Rebill EQ 1>Rebill,</cfif>RFA,Closed,Auto Closed,Deleted">
							<CFELSE>
								<cfset Status_List = "New,Open,<cfif application.returned_customer_setting.DD_Show_Rebill EQ 1>Rebill,</cfif>RFA,Closed,Auto Closed">
							</cfif>
							<cfset excludedDDStatusIDs = []>
<cfif (application.returned_customer_setting.DD_Show_Rebill NEQ 1 AND appSettings.getIntegrated_Rebill() EQ 0)>
	<cfset arrayAppend(excludedDDStatusIDs, 7)>
</cfif>
<cfif AppLevelAllowCredits NEQ 1>
	<cfset arrayAppend(excludedDDStatusIDs, 8)>
	<cfset arrayAppend(excludedDDStatusIDs, 9)>
</cfif>
<cfif Get_Profile_Settings.DD_Delete EQ 0>
	<cfset arrayAppend(excludedDDStatusIDs, 6)>
</cfif>
<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset stGetStatusParams = {
			"select" = "dd_status_id,dd_status_description,dd_status_order",
			"deleted" = "eq.0",
			"order" = "dd_status_order.asc"
		}>
		<cfif arrayLen(excludedDDStatusIDs)>
			<cfset stGetStatusParams["dd_status_id"] = "not.in.(#arrayToList(excludedDDStatusIDs)#)">
		</cfif>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_status", stGetStatusParams),
			"dd_status_id,dd_status_description,dd_status_order"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
								SELECT 	DD_Status_ID,
										DD_Status_Description,
										DD_Status_Order
								FROM 	DD_Status
                <!--- 	Dev Notes: 19384/Anand Rao/05-Apr-10	Rebill Interface and changes/ Added Integrated_Rebill appsetting --->
								WHERE 	<cfif (application.returned_customer_setting.DD_Show_Rebill NEQ 1 AND appSettings.getIntegrated_Rebill() EQ 0)>
										DD_Status_ID <> 7 AND
										</cfif>
										<cfif AppLevelAllowCredits NEQ 1>
										DD_Status_ID NOT IN (8,9) AND
										</cfif>
										<cfif Get_Profile_Settings.DD_Delete EQ 0>
										DD_Status_ID <> 6 AND
										</cfif>
										DD_Status.Deleted = 0
								ORDER BY DD_Status_Order
							</CFQUERY>
</cfif>
							<SELECT NAME="DD_Status" id="dd_status" multiple="multiple">   <!--26491-->
								<CFLOOP QUERY="GetStatus">
								<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>
									<OPTION VALUE="#DD_Status_ID#" <cfif DD_Status_ID EQ FORM.DD_Status>SELECTED</cfif>>
										#DD_Status_Description#
									</OPTION>
								</cfif>
								</CFLOOP>
							</SELECT>
						</TD>
						<TD><B>Deduction Analyst:</B><BR>
							<SELECT NAME="Analyst_User_ID" ID="Analyst_User_ID" multiple="multiple" <cfif NOT AccessAllDeductions OR NOT SrchByAnalystAllowed>DISABLED</cfif>>
								<cfloop QUERY="Get_Analyst">
									<OPTION VALUE="#User_ID#" <cfif NOT AccessAllDeductions OR NOT SrchByAnalystAllowed><cfif UserHasAssignments.Recordcount AND NOT isSupervisor.recordcount AND User_ID EQ request.AccessStructure.User_ID>SELECTED</cfif><CFELSE><cfif User_ID EQ FORM.Analyst_User_ID>SELECTED</cfif></cfif>>#Name_First# #Name_Last#</OPTION>
								</cfloop>
							</SELECT>
							<cfif NOT AccessAllDeductions OR NOT SrchByAnalystAllowed>
								<cfif UserHasAssignments.Recordcount AND NOT isSupervisor.recordcount> <!--- only include user id in teh hidden if teh user is an analyst, if not the search query will take care of access permissions --->
									<input TYPE="Hidden" NAME="Analyst_User_ID" VALUE="#request.AccessStructure.User_ID#">
								</cfif>
							</cfif>
						</TD>
						<TD><B>Current #stDeductionLabels["Action"]#:</B><BR>
							<SELECT NAME="DD_Stage_ID" ID="DD_Stage_ID" multiple="multiple">
								<cfloop QUERY="Get_Action">
									<OPTION VALUE="#DD_Stage_ID#" <cfif DD_Stage_ID EQ FORM.DD_Stage_ID>SELECTED</cfif>>
										#DD_Stage_Description#
									</OPTION>
								</cfloop>
							</SELECT>
						</TD>
						<TD>
							<B>#stDeductionLabels["Reason Code"]#:</B><BR>
							<SELECT NAME="DD_Reason_Code_ID" ID="DD_Reason_Code_ID" multiple="multiple">
								<cfloop QUERY="Get_ReasonCode">
									<OPTION VALUE="#DD_Reason_Code_ID#" <cfif DD_Reason_Code_ID EQ FORM.DD_Reason_Code_ID>SELECTED</cfif>>
										#trim(DD_Reason_Code_Description)# (#trim(DD_Reason_Code)#)
									</OPTION>
								</cfloop>
							</SELECT>
						</TD>
					</TR>

					<cfset BusEnabled = 0>
					<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
					<cfsavecontent variable="segment_operator">
						<cfif businessSegManager.isEnabled()>
							<cfset BusEnabled = 1>
							<cfif application.util.query.get_setting("Display_Segment_In_Deduction", 0) is "1">
								<TD COLSPAN="2">
									<B>Business Segment:</B><BR>
									<SELECT NAME="Business_Segment_ID" ID="Business_Segment_ID" STYLE="Width:100px" multiple="multiple">
										<cfloop QUERY="GetAllBusinessSegmet">
											<OPTION VALUE="#Business_Segment_ID#" <cfif Business_Segment_ID EQ FORM.Business_Segment_ID>SELECTED</cfif>>
												#Business_Unit_ID# - #Business_Unit_Desc#
											</OPTION>
										</cfloop>
									</SELECT>
								</TD>
							</cfif>
						</cfif>
						<cfset QbrandEnabled = 0>
						<cfif application.returned_customer_setting.DD_Show_IsTrade_Box_and_Associate_a_Program EQ 1>
							<cfset QbrandEnabled = 1>
							<TD <cfif BusEnabled EQ 0>COLSPAN="2"</cfif>>
								<B>Q Brand:</B><BR>
								<SELECT NAME="Q_Brand_ID" ID="Q_Brand_ID" multiple="multiple">
									<cfloop QUERY="GetQBrand">
										<OPTION VALUE="#Q_Brand_ID#" <cfif Q_Brand_ID EQ FORM.Q_Brand_ID>SELECTED</cfif>>
											#Q_Brand#
										</OPTION>
									</cfloop>
								</SELECT>
							</TD>
						</cfif>

						<TD <cfif BusEnabled EQ 1 AND QbrandEnabled EQ 0>COLSPAN="1"<CFELSE>COLSPAN="2"</cfif>>
							<cfif application.returned_customer_setting.DD_Show_Operator_For_RC_Of_Accrual EQ 1>
								<B>#application.returned_customer_setting.operator_label_singular#:</B><BR>
								<SELECT NAME="DD_Operator_ID" ID="DD_Operator_ID" multiple="multiple">
									<cfloop QUERY="GetOperator">
										<OPTION VALUE="#DD_Operator_ID#" <cfif DD_Operator_ID EQ FORM.DD_Operator_ID>SELECTED</cfif>>
											#trim(DD_Operator_Name)#
										</OPTION>
									</cfloop>
								</SELECT>
							</cfif>
						</TD>
					</cfsavecontent>
					
					<cfset segment_operator = application.util.string.compress(segment_operator)>
					<cfif BusEnabled>
						<input type="hidden" name="IsBusEnabled" value="1">
						<!--- bus segment dropdown is not displayed --->
						<cfif application.util.query.get_setting("Display_Segment_In_Deduction", 0) neq "1">
							<input type="hidden" name="Business_Segment_ID" value="">
						</cfif>
					</cfif>

					<cfif trim(segment_operator) gt "">
						<tr>
							#segment_operator#
						</tr>
					</cfif>

					<TR>
						<TD NOWRAP class="alignTop"><B>#stDeductionLabels["Reference"]#:</B><br> <input type="text" name="C1AR_Reference" maxlength="30" STYLE="Width:170px"></TD>
						<cfif appSettings.getIntegrated_Rebill() EQ 1>
							<cfset td_colspan = 2>
						<cfelse>
							<cfset td_colspan = 1>
							<cfif (appSettings.getDD_Show_Classification() EQ 1)>
								<cfset td_colspan = td_colspan + 1>
							</cfif>
							<cfif (appSettings.getDD_Show_DeductionType() EQ 1)>
								<cfset td_colspan = td_colspan + 1>
							</cfif>
						</cfif>
						<cfsavecontent variable="check_boxes">
							<TD class="alignTop" nowrap>
								<input type="checkbox" name="Filter_Closed" value="1" <cfif FORM.Filter_Closed EQ 1>CHECKED</cfif>><B>Filter out all Closed Statuses</B><br>
								<input type="checkbox" name="IsParentDeduction" value="1" <cfif FORM.IsParentDeduction EQ 1>CHECKED</cfif>><B>Filter out Parent</B><br>
								<input type="checkbox" name="Only_DD_With_Inactive_Relations" value="1" <cfif FORM.Only_DD_With_Inactive_Relations EQ 1>CHECKED</cfif>><B>Deductions associated to inactive positions</B>
							</TD>
						</cfsavecontent>
						<TD colspan="#(td_colspan + 1)#" NOWRAP class="alignTop">
							<table border="0">
							<tr>
								<td class="alignTop">
									<B>#stDeductionLabels["Customer Reference"]#:</B><br> <input type="text" name="C1Cust_RefNo" maxlength="50" STYLE="Width:170px">
								</td>
								<td class="alignTop"><B>Invoice ##</B><br><input type="text" name="InvoiceNo" maxlength="30"></td>
								<!---
								Dev Notes: 19384/Anand Rao/05-Apr-10
								Rebill Interface and changes
								--->
								<cfset td_count = 2>
								<cfif (appSettings.getIntegrated_Rebill() EQ 1)>
									<td class="alignTop">
										<B>Rebill Number: </B><br>
										<input type="text" name="Rebill_Number" maxlength="50" STYLE="Width:170px">
										<cfset td_count = td_count + 1>
									</td>
								<!--26472 - 2011-mar-8 chrisn: place classification here when re bill is disabled-->
								<cfelse>
									<cfif (appSettings.getDD_Show_Classification() EQ 1)>
										<td class="alignTop">
											<cfinclude template="select_classification.cfm">
											<cfset td_count = td_count + 1>
										</td>
									</cfif>
									<cfif (appSettings.getDD_Show_DeductionType() EQ 1)>
										<td class="alignTop">
											<cfinclude template="select_deductiontype.cfm">
											<cfset td_count = td_count + 1>
										</td>
									</cfif>
								</cfif>
								<cfif td_count lt 3>
									#check_boxes#
									<cfset check_boxes = "">
								</cfif>
							</tr>
							</table>
            			</TD>
					</TR>
					<TR>
						<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
							<td><B>Order ##</B><br><input type="text" name="OrderNo" maxlength="30" STYLE="Width:170px"></td>
						</cfif>
						<cfif BusEnabled EQ 1 and application.util.query.get_setting("Display_Operating_Unit_In_Deduction") is "1">
							<TD>
								<B>Operating Unit:</B><BR>
								<cfset useLakebaseForGetOpUnit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_unit")>
								<cfif useLakebaseForGetOpUnit>
									<cftry>
										<cfset GetOpUnit = application.oLakebase.toQuery(
											application.oLakebase.selectRows("operating_unit", {})
										)>
										<cfcatch type="any">
											<cfset useLakebaseForGetOpUnit = false>
										</cfcatch>
									</cftry>
								</cfif>
								<cfif NOT useLakebaseForGetOpUnit>
								<CFQUERY NAME="GetOpUnit" DATASOURCE="#Application.Datasource#">
									SELECT * FROM Operating_Unit
								</CFQUERY>
								</cfif>
								<SELECT NAME="Operating_Unit_ID" ID="Operating_Unit_ID" multiple="multiple">
									<cfloop QUERY="GetOpUnit">
										<OPTION VALUE="#Operating_Unit_ID#">#Code# - #Operating_unit_Description#</OPTION>
									</cfloop>
								</SELECT>
							</TD>
						</cfif>
						<input type="hidden" name="ClDate_Operator">
						<!--- <TD style="padding-top:15px;">
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
							<!--- <TR>								<TD colspan="4"><B>Closure Date:</B></TD>							</TR> --->
							<TR>
								<TD class="alignTop" nowrap>
									<b>Closure Date:</b><br>
									<SELECT NAME="ClDate_Operator" ID="ClDate_Operator" ONCHANGE="Javascript: enableDate(2)">
										<OPTION VALUE="=" <cfif FORM.ClDate_Operator EQ "=">SELECTED</cfif>>=</OPTION>
										<OPTION VALUE="<" <cfif FORM.ClDate_Operator EQ "<">SELECTED</cfif>><</OPTION>
										<OPTION VALUE=">" <cfif FORM.ClDate_Operator EQ ">">SELECTED</cfif>>></OPTION>
										<OPTION VALUE="between" <cfif FORM.ClDate_Operator EQ "between">SELECTED</cfif>>between</OPTION>
									</SELECT>
								</TD>
								<TD  class="alignTop" NOWRAP><BR>
									<CF_EASYDATE FORMNAME="DD_Adv_Search" FIELDNAME="ClDate_Time" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.ClDate_Time#" STYLE="background-color: FF00FF;">
								</TD>
								<TD class="alignTop"><BR>
									<DIV style="display:inline;" ID="ClDiv_DD_Adv_Search">
									<CF_EASYDATE FORMNAME="DD_Adv_Search" FIELDNAME="ClTo_Date_Time" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.ClTo_Date_Time#">
									</DIV>
								</TD>
								<cfif (appSettings.getIntegrated_Rebill() EQ 1)>
								<TD class="alignTop">
									<!--26472 - 2011-mar-8 chrisn: place classification here when re bill is enabled-->
									<cfif (appSettings.getDD_Show_Classification() EQ 1)>
										<cfinclude template="select_classification.cfm"><br/>
									</cfif>
									<!---26487 - 2011-mar-9 chrisn: added deduction type--->
									<cfif (appSettings.getDD_Show_DeductionType() EQ 1)>
										<cfinclude template="select_deductiontype.cfm">
									</cfif>
								</TD>
								</cfif>
							</TR>
							</TABLE>
						</TD> --->
						<cfif check_boxes gt "">
							#check_boxes#
						</cfif>
					</TR>

				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD colspan="6"><BR><BR><FONT SIZE="2" COLOR="Red"><B>#application.returned_customer_setting.distributor_label_singular#:</B></FONT><BR><HR COLOR="navy"></TD>
		</TR>
		<TR>
			<TD <cfif Isdefined("FORM.FromSmallSearch") AND FORM.DISTRIBUTOR_LIST NEQ "">BGCOLOR= "C0C0C0"</cfif>>
				<SCRIPT LANGUAGE="JavaScript">
					function showDistSearchWindow()
					{
						document.all.Form_Submitted.value=0;
						document.DD_Adv_Search.target = "_self";
						document.DD_Adv_Search.SelectSingleSearchResultOnly.value = 0;
						document.DD_Adv_Search.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
						NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=DD_Adv_Search", "searchwindow", 800, 600, "yes", "yes")
					}
				</SCRIPT>
				<CFPARAM NAME="Selected_Name" 	DEFAULT="">
				<B>#application.returned_customer_setting.shard_ship_to_label#:</B>
				<span style="color:navy;font-size:10px;font-weight:bold;">(Enter ID followed by enter key)</span>
				<BR>
				<textarea NAME="Distributor" cols="50" rows="3"><cfloop index = "ListElement" list = "#Selected_Distributor#">#Trim(ListElement)#&##13;</cfloop></textarea>
				<A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif" width="20" height="20"></A>
			</TD>

			<TD <cfif Isdefined("FORM.FromSmallSearch") AND FORM.BROKER_LIST NEQ "">BGCOLOR= "C0C0C0"</cfif>>
				<SCRIPT LANGUAGE="JavaScript">
					function showSearchWindow()
					{
						document.all.Form_Submitted.value=0;
						document.DD_Adv_Search.target = "_self";
						document.DD_Adv_Search.action = "#CGI.SCRIPT_NAME#";
						NewWindow("/Billbacks/search_Screens/PM_select_Brokers.cfm?Formname=DD_Adv_Search", "searchwindow", 800, 600, "yes", "yes")
					}
				</SCRIPT>
				<CFPARAM NAME="Selected_Name" 	DEFAULT="">
					<B>#application.returned_customer_setting.broker_label_singular#:</B><BR>
					<!--- <input TYPE="TEXT" NAME="Broker" VALUE="#Selected_Broker#" STYLE="Width:285px;" READONLY> --->
					<textarea NAME="Broker" cols="50" rows="3" style="background-color:cccccc" READONLY><cfif FORM.Broker_List NEQ ""><CFLOOP QUERY="Broker_Search_Result">#TRIM(Broker_Name)#</CFLOOP></cfif></textarea>
					<A HREF="javascript: void(0);" onClick="javaScript: showSearchWindow();"><IMG border="0" src="/images/searchtool.gif" width="20" height="20"></A>
			</TD>
			<TD>
				<B>#application.returned_customer_setting.family_name_label_singular#:</B><BR>
				<SELECT NAME="Family_ID" ID="Family_ID" multiple="multiple">
						<cfloop QUERY="GetFamilyNames">
							<OPTION VALUE="#Family_ID#" <cfif Family_ID EQ FORM.Family_ID>SELECTED</cfif>>
								#trim(Family_Name)#
							</OPTION>
						</cfloop>
				</SELECT>
			</TD>

		</TR>
		<TR>
			<TD colspan="6">
				<B>#application.returned_customer_setting.billto_label#:</B><BR>
				<input type="text" name="Distributor_Bill_To" value="#Form.Distributor_Bill_To#" STYLE="Width:170px">
				<!-----
				<SELECT NAME="Distributor_Bill_To_ID">
					<OPTION VALUE="">**Any** <cfoutput>#application.returned_customer_setting.billto_label#</cfoutput></OPTION>
					<CFOUTPUT QUERY="GetBillTo"><OPTION VALUE="#Distributor_Bill_To_ID#" <cfif Distributor_Bill_To_ID EQ FORM.Distributor_Bill_To_ID>SELECTED</cfif>>#trim(Name)# (#trim(Shr_Bill_To)#)</OPTION></CFOUTPUT>
				</SELECT>
				----->
			</TD>
		</TR>
		<TR>
			<TD colspan="6"><BR><BR><FONT SIZE="2" COLOR="Red"><B>Geographic location:</B></FONT><BR><HR COLOR="navy"</TD>
		</TR>
		<TR>
			<TD>
				<B>#application.returned_customer_setting.zone_label_singular#:</B><BR>
				<SELECT NAME="Service_Zone_ID" ID="Service_Zone_ID" multiple="multiple">
					<cfloop QUERY="Get_Zone">
						<OPTION VALUE="#Service_Zone_ID#" <cfif Service_Zone_ID EQ FORM.Service_Zone_ID>SELECTED</cfif>>
							#trim(Zone_Name)#
						</OPTION>
					</cfloop>
				</SELECT>
			</TD>
</CFOUTPUT>
			<TD>
				<B><CFOUTPUT>#application.returned_customer_setting.region_label_singular#:</CFOUTPUT></B><BR>
				<SELECT NAME="Service_Region_ID" ID="Service_Region_ID" multiple="multiple">
					<cfset RegionIDList = ""/>
					<CFOUTPUT QUERY="Get_Region" GROUP="Region_Name">
								<cfset RegionIDList = listAppend(RegionIDList,trim(Get_Region.Service_Region_ID))>
						<OPTION VALUE="#ListQualify(RegionIDList,"'",",","ALL")#" <cfif TRIM(RegionIDList) EQ TRIM(FORM.Service_Region_ID)>SELECTED</cfif>>
							#trim(Region_Name)#
						</OPTION>
						<cfset RegionIDList = ""/>
					</CFOUTPUT>
				</SELECT>

			</TD>
			<TD>
				<B><CFOUTPUT>#application.returned_customer_setting.market_label_singular#:</CFOUTPUT></B><BR>
				<SELECT NAME="Service_Market_ID" ID="Service_Market_ID" multiple="multiple">
					<cfset MarketIDList = ""/>
					<CFOUTPUT QUERY="Get_Market" GROUP="Market_Name">
							<cfset MarketIDList = listAppend(MarketIDList,trim(Get_Market.Service_Market_ID))>
						<OPTION VALUE="#ListQualify(MarketIDList,"'",",","ALL")#" <cfif MarketIDList EQ FORM.Service_Market_ID>SELECTED</cfif>>
							#trim(Market_Name)#
						</OPTION>
						<cfset MarketIDList = ""/>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
<CFOUTPUT>
		<TR>
			<TD>
				<cfif application.returned_customer_setting.lob_search_switch EQ 1>
				<B>#application.returned_customer_setting.lob_label_singular#:</B><BR>
				<SELECT NAME="Line_Of_Business_ID" ID="Line_Of_Business_ID" multiple="multiple">
					<cfloop QUERY="GetLOB">
						<OPTION VALUE="#Line_Of_Business_ID#" <cfif Line_Of_Business_ID EQ FORM.Line_Of_Business_ID>SELECTED</cfif>>
							#Line_Of_Business_Name# (#Line_Of_Business#)
						</OPTION>
					</cfloop>
				</SELECT>
				</cfif>
			</TD>

			<TD ALIGN="right" COLSPAN="2"><BR><BR>
				<B>
				<FONT SIZE="2" COLOR="Red">[ </FONT><A HREF="Javascript: resetForm();">reset</A><FONT SIZE="2" COLOR="Red"> ]</FONT>&nbsp;&nbsp;
				<FONT SIZE="2" COLOR="Red">[ </FONT><A HREF="Javascript: Validate();"><cfif PassForReport EQ 1>build report<CFELSE>search deductions</cfif></A><FONT SIZE="2" COLOR="Red"> ]</FONT>&nbsp;&nbsp;
				</B>
			</TD>
		</TR>
	</TABLE>
	</CFOUTPUT>
</CF_openLayer>

</FORM>

<CFOUTPUT>
<IFRAME ID="Search_Result" NAME="Search_Result" SRC="blank_page.html" WIDTH="100%" HEIGHT="1" FRAMEBORDER="0" style="border: 0px none ##000000;Display:None;"></IFRAME>
</CFOUTPUT>
<cf_include files="/Script/javascript/Ajax_JS/jquery-1.5.1-min.js, /Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /script/javascript/string_functions.js">
<SCRIPT language="JavaScript">
function enableInput(opr,input)
{
	var oprObj = eval("document.all."+opr);
	var inputObj = eval("document.all."+input);

	if (oprObj.value == "between")
	{
		inputObj.style.backgroundColor='ffffff';
		inputObj.disabled = false;
	}
	else
	{
		inputObj.style.backgroundColor='cccccc';
		inputObj.disabled = true;
	}
}
document.body.onload = new Function("disableDate()");


function disableDate()
{
	if (document.all.Dollar_Operator.value == "between")
	{
		document.all.DD_To_Amount.style.backgroundColor='ffffff';
		document.all.DD_To_Amount.disabled = false;
	}

	if (document.all.Date_Operator.value == "between")
	{
		disableDiv("Div_DD_Adv_Search", false, false);
	}
	else
	{
		disableDiv("Div_DD_Adv_Search", true, false);
	}

	if (document.all.ClDate_Operator.value == "between")
	{
		disableDiv("ClDiv_DD_Adv_Search", false, false);
	}
	else
	{
		disableDiv("ClDiv_DD_Adv_Search", true, false);
	}
}
function enableDate(Type)
{
	if (Type == 1)
	{
		if(document.all.Date_Operator.value == "between")
		{
			disableDiv("Div_DD_Adv_Search", false, false);
		}
		else
		{
			disableDiv("Div_DD_Adv_Search", true, false);
		}
	}
	else if (Type == 2)
	{
		if(document.all.ClDate_Operator.value == "between")
		{
			disableDiv("ClDiv_DD_Adv_Search", false, false);
		}
		else
		{
			disableDiv("ClDiv_DD_Adv_Search", true, false);
		}
	}
}

function Validate()
{
	var submit_Ok = 1;
	var x = document.all;
	var IsFromReport = "<CFOUTPUT>#PassForReport#</CFOUTPUT>";

	if (x.DD_Amount.value == "." || x.DD_Amount.value == "-"  || x.DD_Amount.value == "-.")
	{
		alert("Please enter a valid amount in the Start Range.");
		submit_Ok = 0;
		x.DD_Amount.focus();
		return;
	}

	if (x.Dollar_Operator.value == "between")
	{
		if (x.DD_Amount.value != "" && (x.DD_To_Amount.value.length == 0 || x.DD_To_Amount.value == "-."  || x.DD_To_Amount.value == "." || x.DD_To_Amount.value == "-"))
		{
			alert("Enter Value in Amount 'End Range'.");
			submit_Ok = 0;
			x.DD_To_Amount.focus();
			return;
		}

		var startAmount = parseFloat(x.DD_Amount.value);
		var endAmount = parseFloat(x.DD_To_Amount.value);

		if (startAmount > endAmount)
		{
			alert("Amount 'Start range' must be less than 'End range'.");
			submit_Ok = 0;
			x.DD_To_Amount.focus();
			return;
		}
	}
	if (x.Date_Operator.value == "between")
	{
		if (x.Date_Time.value != "" && x.To_Date_Time.value == "")
		{
			alert("Enter some value in 'End Range'.");
			submit_Ok = 0;
			x.To_Date_Time.focus();
			return;
		}
		if(checkDate(x.Date_Time.value,x.To_Date_Time.value) <= 0)
		{
		}
		else
		{
			alert("Date 'Start range' must be less than 'End range'.");
			submit_Ok = 0;
			x.To_Date_Time.focus();
			return;
		}
	}

	if (x.ClDate_Operator.value == "between")
	{
		if (x.ClDate_Time.value != "" && x.ClTo_Date_Time.value == "")
		{
			alert("Enter some value in 'End Range'.");
			submit_Ok = 0;
			x.ClTo_Date_Time.focus();
			return;
		}
		if(checkDate(x.ClDate_Time.value,x.ClTo_Date_Time.value) <= 0)
		{
		}
		else
		{
			alert("Date 'Start range' must be less than 'End range'.");
			submit_Ok = 0;
			x.ClTo_Date_Time.focus();
			return;
		}
	}

	if (x.C1AR_Reference.value.length > 30)
	{
			alert("Deduction Reference must be less than 30 characters.");
			submit_Ok = 0;
			x.C1AR_Reference.focus();
			return;
	}
	if (x.C1Cust_RefNo.value.length > 50)
	{
			alert("Customer Reference Number must be less than 50 characters.");
			submit_Ok = 0;
			x.C1Cust_RefNo.focus();
			return;
	}
	if (IsFromReport == 1 && document.all.DD_Status.value == "")
	{
		alert("Please select a status and build report.");
		submit_Ok = 0;
		x.DD_Status.focus();
		return;
	}

	if (submit_Ok == 1)
	{
		document.all.Form_Submitted.value=1;
		///// collapse the open layer
		var searhFormHideImg = document.all.image_<CFOUTPUT>#Layer_ID#</CFOUTPUT>;
		searhFormHideImg.click();
		document.DD_Adv_Search.target = "Search_Result";
		if (IsFromReport == 0)
		{
			document.DD_Adv_Search.action = "Ded_advanced_search_Result.cfm";
		}
		else
		{
			document.DD_Adv_Search.action = "Ded_report_Builder.cfm"
		}

		document.DD_Adv_Search.submit();

	}
}



function resetForm()
	{
		document.all.DD_Number.value = "";
		document.all.DD_Amount.value = "";
		document.all.DD_To_Amount.value = "";
		document.all.Date_Time.value = "";
		document.all.To_Date_Time.value = "";
		// document.all.ClDate_Time.value = "";
		// document.all.ClTo_Date_Time.value = "";
		document.all.Check_No.value = "";
		//document.all.Distributor.value = ""; CHROMEFIX
		jQuery("textarea[name=Distributor]").val('');
		//document.all.Broker.value = ""; CHROMEFIX
		jQuery("textarea[name=Broker]").val('');
		document.all.Distributor_List.value="";
		document.all.Broker_List.value="";
		document.all.Distributor_Bill_To.value="";
		document.all.IsParentDeduction.checked = false;
		document.all.C1AR_Reference.value="";
		document.all.C1Cust_RefNo.value="";

		jQuery('select[multiple]').multiselect("uncheckAll");
		jQuery("select#date_type").val("Deduction");
	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			callfireEvent(document,sObj,'Change');
		}
	}

</SCRIPT>


<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>

<!--26491-->


<SCRIPT>
function checkDate(dateStr1,dateStr2)
{
 var dateSplit;
 var retVal = null;
 dateSplit = dateStr1.split("/");
 if(dateSplit.length > 2)
 {
  var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
  dateSplit = dateStr2.split("/");
  if(dateSplit.length > 2)
  {
   var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
   retVal = days_between(date1, date2, true);
  }
 }
 return retVal;
}


 <!--
		function switchLayer(lyrID, title, titleclosed, borderwidth, imageA,imageB, colorA,colorB)
		{
			if (document.all.length)
			{
				var iFrameOBj = document.all.Search_Result;

				// Determine if the layer is currently expanded or collapsed:
				var tmpStatus;
				eval("tmpStatus = document.all.lyrGroup_"+ lyrID +".style.display");
				// OK, then now expand or collapse it...
				if (tmpStatus == 'none')
				{
					eval("document.all.lyrGroup_"+ lyrID +".style.display='block';");
					eval("document.all.border_"+ lyrID +".style.borderWidth='"+borderwidth+"px';");
					eval("document.all.title_"+ lyrID +".innerHTML='"+title+"';");
					tmpImage = imageA;
					tmpColor = colorA;
					<!------ show ----->
					<!------ 2. hide the search result ----->
					iFrameOBj.style.display = "none";
				}
				else
				{
					eval("document.all.lyrGroup_"+ lyrID +".style.display='none'");
					eval("document.all.border_"+ lyrID +".style.borderWidth='0px';");
					eval("document.all.title_"+ lyrID +".innerHTML='"+titleclosed+"';");
					tmpImage = imageB;
					tmpColor = colorB;
					<!------ hide ----->
					<!------ 2. show the search result ----->
					iFrameOBj.style.height = "730";
					iFrameOBj.style.display = "";

				}
				// If an image is used as the click-control, switch it...
				if ((tmpImage != null) && (imageA != imageB))
				{
					eval("document.all.image_"+ lyrID +".src='"+tmpImage+"'");
				}
				// If different title-colors are used, switch them...
				if (tmpColor != '')
				{
					eval("document.all.title_"+ lyrID +".style.color='"+tmpColor+"'");
				}

			}
		}

	// save all dropdowns on the page into an array
	var dropdowns = [	"#dd_status",
						"#Analyst_User_ID",
						"#Business_Segment_ID",
						"#DD_Aging",
						"#DD_Stage_ID",
						"#DD_Reason_Code_ID",
						"#DD_Operator_ID",
						"#Family_ID",
						"#Line_Of_Business_ID",
						"#Operating_Unit_ID",
						"#Q_Brand_ID",
						"#Service_Zone_ID",
						"#Service_Region_ID",
						"#Service_Market_ID"
					];

	<cfif (appSettings.getDD_Show_Classification() eq 1)>
		dropdowns.push("#classification");
	</cfif>
	<cfif (appSettings.getDD_Show_DeductionType() eq 1)>
		dropdowns.push("#deductiontype");
	</cfif>

	// pass all dropdowns to multi_select() to filter out large dropdowns and apply multiselect()
	$(multi_select( dropdowns )).multiselect();
</SCRIPT>
</body>
</html>