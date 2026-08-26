<!---
    FILE:
    FILENAME: 	Common_Files/contracts/contract_allowance_analysis.cfm
    CREATED: 	04/04/2006 - CM
    EDITED:		09/26/2008 - RBL [D16314: Margin Analysis - Add Contract Price]
    FUNCTIONALITY: Displays summary of discounts by product, links to margin edit if turned on.
    DEPENDENCIES:
            /Get_Access_Profile.cfm
            commonqueries.cfm
            discount_queries.cfm
            /includes/please_wait.cfm
            (note: Do not display link to margin edit if products are not associated to the discount type. )
    --->
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<cffunction name="NumericRoundDecimal" output="false" returntype="string">
	<cfargument name="iValue" type="numeric" required="true" />
	<cfargument name="iDecimalLen" type="numeric" required="true" />
	<cfset var divVal = 10 ^ arguments.iDecimalLen />
	<cfset var newAmount = arguments.iValue />
	<cfset newAmount = newAmount * divVal />
	<cfset newAmount = Round(newAmount) />
	<cfset newAmount = newAmount / divVal />
	<cfreturn newAmount />
</cffunction>

<cffunction name="PercentageFormat" output="false" returntype="string">
	<cfargument name="iValue" type="numeric" required="true" />
	<cfargument name="iDecimalLen" type="numeric" required="false" default="2" />
	<cfreturn NumericRoundDecimal(arguments.iValue * 100, arguments.iDecimalLen) & "%" />
</cffunction>

<cffunction name="big_star" output="false" hint="Returns a big star element with overriding hovering message and a hidden input for previous value">
	<cfargument name="field_name" required="true">

	<!--- locate previously saved value from a query  --->
	<cfquery name="local.qCostOverride" dbtype="query">
		SELECT *
		  FROM qCostOverride
		 WHERE LOWER(Field_Name) = '#lCase(arguments.field_name)#'		
	</cfquery>

	<cfoutput>
	<cfsavecontent variable="local.result">
		<!--- save old value in a hidden input --->
		<input type="hidden" name="old_#lcase(arguments.field_name)#" value="#replace(request.cost_value,'$','')#">
		<cfif local.qCostOverride.recordCount>
				<!--- override request.cost_value (the display value) with previously entered value --->
				<cfset request.cost_value = local.qCostOverride.new_value>
				<i class="audit" title="Previous value #numberFormat(local.qCostOverride.Old_Value, money_fmt)# was changed by #local.qCostOverride.User_Name# on #dateFormat(local.qCostOverride.Created_Date, 'medium')#">&bigstar;</i>
		</cfif>
	</cfsavecontent>
	</cfoutput>

	<cfreturn application.util.string.compress(local.result)>
</cffunction>

<cfsilent>
    <!--- These parameters are required for this template to process correctly --->
    <cfparam name="URL.CPID" 	default=0>
    <cfparam name="url.ItemId" default=0>
    <cfparam name="url.type" default="A">
    <cfparam name="url.desc" default="">
    <cfparam name="url.margin_type" default="1">
    <cfparam name="STAT_MULTIPLIER" default="1">
    <cfparam name="MULTIPLIER" default="*">
    <cfparam name="url.DC" default="">
    <cfparam name="url.plant" default="">
    <cfparam name="editdiscounts" default="0" />
    <cfparam name="DuplicateProgram" default="0" />
	<cfparam name="url.verticalPNL" default="">

    <cfset Enc_CID = URL.CID>
    <cfset URL.CID = cryp.value>
    <cfset CID=URL.CID>

    <cfparam name="CSL_Contract_Main_ID" default="#CID#" />
	<cfset bAllowEditRateInMarginPage = 0 />
	<cfset bEditFixedPrice = 0 />
	<cfset bEditRebate = 0 />
	<cfset iBasePrice = 0 />
	<cfset bUserCanApproveStar = 0 />
</cfsilent>

<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<CFINCLUDE TEMPLATE="commonqueries.cfm" />
<!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes --->
<cfif (isContractCurrentlyLocked.Contract_Is_Locked EQ 1
  AND isContractCurrentlyLocked.Contract_Locked_By_User_ID NEQ request.Accessstructure.User_ID)
  OR (CSLGetContractInfo.Contract_Status_Type_IDX GT 2)
  OR (application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1)
 OR(CSLGetContractInfo.Contract_Status_Type_IDX EQ 2 AND application.appSettingsGet.getdisablepagesinrfa()) 	>
	<cfset editdiscounts = 0 />
<cfelse>
	<cfset editdiscounts = 1 />
</cfif>

<cfscript>
	/* decimal places setting created for Tyson */
	decimal_places  = (url.margin_type eq "1" ? application.util.query.get_setting("decimal_display_for_cs", 0) : application.util.query.get_setting("decimal_display_for_lb", 0));
	money_fmt       = ',.' & repeatString("_", val(decimal_places) ? val(decimal_places): 4);

	CID             = URL.CID;
	ItemId          = replace(url.ItemId, "-", "_", "ALL");
	Product_ID_GUID = replace(ItemId, "_", "-", "ALL");
	type            = url.type;
	desc            = url.desc;

	genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
	appSettings = genSettingsManager.get();
	Margin_Display_Style = appSettings.get_Setting('Margin_Display_Style');

	if (type EQ "A")
		PAGE_TITLE = "Allowance Calculation";
	else if (type EQ "N")
		PAGE_TITLE = "Net Sales Calculation";
	else if (type EQ "B")
		PAGE_TITLE = "Base Sales Calculation";
	else if (type EQ "C")
		PAGE_TITLE = "Cost Calculation";
	else if (type EQ "CB" OR type EQ "CBD")
		PAGE_TITLE = "Customer Based Cost Calculation";
	else if (type EQ "T")
		PAGE_TITLE = "Margin Calculation";
	else if (type EQ "AG")
		PAGE_TITLE = "Users Agreed";
</cfscript>

<cfinclude template="/get_access_profile.cfm">

<!doctype html>
<html>
<head>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<cfsavecontent variable="head_content">
		<cf_include files="/common_files/DataTable2.css">
		<style>
			TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
			#header {font-size: 12px;}
			#costTable {
				width: 60%;
			}
			div.hdr {
				line-height: 17px;
				text-align: center;
			}
			div.hdr > label {
				font-weight: bold;
				display: inline-block;
				margin: 0 3px 0 9px;
			}
			div.hdr2 {
				text-align: center;
				font-weight: bold;
				margin: 7px 0 11px 0;
			}
			div.hdr2 > label {
				padding-right: 7px;
			}
			div.hdr2 > i {
				font-style: normal;
				font-weight: normal;
			}
			div.hdr3 {
				margin: 11px 0 12px 0;
			}
			input.money {
				text-align: right;
			}
			input[type=text] {
				width: 75%;
				/* float: right; */
			}
			tr.total {
				background-color: #F7F7F7 !important;
				/* border-top: 1px solid !important; */
			}
			td.total {
				padding-left: 26px !important;
				font-weight: bold;
				height: 24px;
				color: green !important;
				text-transform: uppercase;
				white-space: nowrap;
			}
			table.dataTable td {
				padding-top: 4px !important;
				padding-bottom: 3px !important;
			}
			i {
				font-style: normal;
			}
			div#actions {
				text-align: center;
			}
			div#actions > a {
				margin-right: 23px;
			}
			i.audit {
				font-size: 14px;
				font-weight: bold;
				font-style: normal;
				color: green;
				cursor: pointer;
			}
			.hidden {
				opacity: 0;
			}
			table.material th {
				text-align: center !important;
			}
			td:nth-child(2) {
				text-align: right;
			}
		</style>
		<!--- <cfinclude template="/common_files/jQuery.cfm">
		<cfset jQueryUI.widgets = "tooltip">
		<cfinclude template="/common_files/jQueryUI.cfm">
		<cf_include files="/Script/javascript/jQuerytablesorter/js/jquery-latest.min.js, /Script/javascript/jQuerytablesorter/js/jquery.tablesorter.js, /Script/javascript/jQuerytablesorter/js/jquery.tablesorter.widgets.js, /script/javascript/jquery.util.js, /styles/css-loader.css, /script/javascript/numeral.min.js">
		<script>
			<cfif Margin_Display_Style neq "custom_t">
				$(function(){  $("#costTable").tablesorter({ sortList: [[1,1]] });});
			</cfif>
		</script> --->
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<cfquery name="isEditing" datasource="#application.datasource#">
	SELECT 1
		FROM Contract_Main
		WHERE Contract_Main_ID = #CID#
			AND Contract_Is_Locked = 1
			AND Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
</cfquery>
<!----------------- Add Spinner ------------------------>
<!--- 
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT> --->
<!----------------- Add Spinner ------------------------>
<cfif (URL.ItemID EQ 0 OR URL.CID EQ 0) OR NOT isNumeric(URL.CID)>
	<BLOCKQUOTE>
	<BR><BR><BR><SPAN CLASS="TITLE2">Invalid Contract/Product information</SPAN>
	</BLOCKQUOTE>
	<CFABORT>
</cfif>
<cfset useLakebaseForgetGlobalUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGlobalUOM>
	<cftry>
		<cfset getGlobalUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "global_target_uom"
			}), "global_target_uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGlobalUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGlobalUOM>
<cfquery name="getGlobalUOM" datasource="#application.datasource#">
    SELECT Global_Target_UOM
    FROM General_Settings
</cfquery>
</cfif>
<cfif appSettings.getApprovalMarginType() NEQ 3>
    <cfset UOMdisplay = '%'>
<cfelse>
    <cfif getGlobalUOM.Global_Target_UOM EQ 1>    
        <cfset UOMdisplay = 'Per CS'>
    <cfelseif getGlobalUOM.Global_Target_UOM EQ 2>    
        <cfset UOMdisplay = 'Per LB'>
    <cfelseif getGlobalUOM.Global_Target_UOM EQ 3>
        <cfset UOMdisplay = 'Equiv Cs'>
    <cfelse>
        <cfset UOMdisplay = 'Per CS'>
    </cfif>
</cfif>          
<cfif url.margin_type EQ 2>
	<CFQUERY NAME="GetStatValue" datasource="#application.datasource#">
		SELECT ISNULL(CAST(CASE_EQUIVALENT as float),0) as CASE_EQUIVALENT
		FROM BSA_Foodservice_Items_Master
		where BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
	</CFQUERY>
	<cfset STAT_MULTIPLIER = GetStatValue.CASE_EQUIVALENT>
	<cfif STAT_MULTIPLIER EQ 0>
		<cfset MULTIPLIER = "*">
	<cfelse>
		<cfset MULTIPLIER = "/">
	</cfif>
<cfelseif url.margin_type EQ 3>
	<CFQUERY NAME="GetNetValue" datasource="#application.datasource#">
		SELECT ISNULL(CAST(NET_WEIGHT as float),0) as NET_WEIGHT
		FROM BSA_Foodservice_Items_Master
		where BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
	</CFQUERY>
	<cfif GetNetValue.NET_WEIGHT EQ 0>
		<cfset Net = 1>
	<cfelse>
		<cfset Net = GetNetValue.NET_WEIGHT>
	</cfif>
	<cfset STAT_MULTIPLIER = Net>
	<cfset MULTIPLIER = "/">
<cfelseif url.margin_type EQ 4>
	<CFQUERY NAME="GetVolume" datasource="#application.datasource#">
		SELECT ISNULL(Product_Program_Volume_CS,0) as Volume_Equivalent
		FROM contract_product_margin
		where product_id = '#replace(ItemId, "_", "-", "ALL")#'
		and deleted = 0
		and contract_main_id = #CID#
	</CFQUERY>
	<cfset STAT_MULTIPLIER = GetVolume.Volume_Equivalent>
	<cfset MULTIPLIER = "*">
<cfelse>
	<cfset STAT_MULTIPLIER = 1>
	<cfset MULTIPLIER = "*">
</cfif>

<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
	SELECT Contract_Number, Contract_Start_Date, Contract_End_Date,ProgramType_ID
	FROM Contract_Main WHERE Contract_Main_ID = #CID#
</CFQUERY>

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM	Program_Control_Panel_Options
	WHERE	ProgramControl_Panel_Options_ID = '#trim(Program_Details.ProgramType_ID)#'
</cfquery>

<cfparam name="Contract_Main_ID" default="#CSL_Contract_Main_ID#" />
<CFINCLUDE TEMPLATE="discount_queries.cfm" />

<cfif type EQ "AG" and desc EQ "P">
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT distinct Description, Item,name_first,name_last,Program_Type_Code_Approval_Info.created_date,Description, Item
		FROM  Program_Type_Code_Approval_Info
		INNER JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID =
		Program_Type_Code_Approval_Info.Product_Id
		and BSA_Foodservice_Items_Master.deleted = 0
		INNER JOIN _Users
		ON _Users.user_id = Program_Type_Code_Approval_Info.user_id
		and _users.deleted = 0
		where Program_Type_Code_Approval_Info.program_id = #CID#
		and  Program_Type_Code_Approval_Info.Product_Id = '#replace(ItemId, "_", "-", "ALL")#'
		AND isNULL(AGREE,0) = 1
		and Program_Type_Code_Approval_Info.deleted = 0
	</cfquery>
<cfelseif type EQ "AG" and desc EQ "G">
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT distinct Type_Code_Desc.Type_Code_Desc,name_first,name_last,Program_Type_Code_Approval_Info.created_date
		FROM  Program_Type_Code_Approval_Info
		INNER JOIN Type_Code_Desc
		ON Type_Code_Desc.Type_Code_Desc_ID =
		Program_Type_Code_Approval_Info.Type_Code_Desc_ID
		and Type_Code_Desc.deleted = 0
		INNER JOIN _Users
		ON _Users.user_id = Program_Type_Code_Approval_Info.user_id
		and _users.deleted = 0
		where Program_Type_Code_Approval_Info.program_id = #CID#
		and  Program_Type_Code_Approval_Info.Type_Code_Desc_Id = '#replace(ItemId, "_", "-", "ALL")#'
		AND isNULL(AGREE,0) = 1
		and Program_Type_Code_Approval_Info.deleted = 0
	</cfquery>
<cfelseif type EQ "B">
	<CFQUERY NAME="getitemdetails" datasource="#application.datasource#">
		select BSA_Foodservice_Items_Master.item,BSA_Foodservice_Items_Master.description
		from BSA_Foodservice_Items_Master
		where BSA_Foodservice_Items_Master_id = '#replace(ItemId, "_", "-", "ALL")#'
	</CFQUERY>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		select distinct contract_product_margin.product_id,Margin_Product_customer.customer_weight as program_weight,bsa_foodservice_customers.name,
		bsa_foodservice_customers.shr_ship_to,
		<cfif getSettings.approval_uom EQ 1>
		contract_product_margin.base_sales_CS as base_sales,
		Margin_Product_customer.base_sales_CS as base_price
		<cfelse>
		contract_product_margin.base_sales_lb as base_sales,
		Margin_Product_customer.base_sales_LB as base_price
		</cfif>,delivery_type
		from contract_product_margin
		inner join Margin_Product_customer
		on Margin_Product_customer.program_id =contract_product_margin.Contract_Main_id
		and Margin_Product_customer.product_id =contract_product_margin.product_id
		inner join bsa_foodservice_customers
		on bsa_foodservice_customers.bsa_foodservice_customers_id =Margin_Product_customer.customer_id
		where contract_product_margin.contract_main_id = #CID#
		and contract_product_margin.deleted = 0
		and contract_product_margin.product_id = '#replace(ItemId, "_", "-", "ALL")#'
	</cfquery>
<cfelseif type EQ "CB">
	<CFQUERY NAME="getitemdetails" datasource="#application.datasource#">
		select BSA_Foodservice_Items_Master.item,BSA_Foodservice_Items_Master.description
		from BSA_Foodservice_Items_Master
		where BSA_Foodservice_Items_Master_id = '#replace(ItemId, "_", "-", "ALL")#'
	</CFQUERY>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		select bsa_foodservice_customers.name,bsa_foodservice_customers.shr_ship_to,
		program_weight, bsa_foodservice_customers.bsa_foodservice_customers_id,source_plant,shipping_dc,
		<cfif getSettings.approval_uom EQ 1>
		cp1.cost_cs as cust_cost,(isnull(man_cost,0)+
		isnull(Storage_Cost,0)+isnull(Stand_Freight,0)+
		isnull(Deffered_Freight,0)) as cost
		<cfelse>
		cp1.cost_lb as cust_cost,
		(isnull(man_cost,0)+
		isnull(Storage_Cost,0)+isnull(Stand_Freight,0)+
		isnull(Deffered_Freight,0)) / net_weight as cost
		</cfif>
		from contract_product_margin cp1
		inner join contract_distributors on
		contract_distributors.contract_main_id = cp1.contract_main_id
		and contract_distributors.deleted=0
		inner join bsa_foodservice_customers on bsa_foodservice_customers.bsa_foodservice_customers_id =
		contract_distributors.bsa_foodservice_customers_id
		left join customer_based_costs on
		customer_based_costs.customer_id = contract_distributors.BSA_Foodservice_Customers_id
		and customer_based_costs.product_id = cp1.product_id
		where cp1.contract_main_id = #CID#
		and cp1.product_id = '#replace(ItemId, "_", "-", "ALL")#'
	</cfquery>
<cfelseif type EQ "CBD">
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		select bsa_foodservice_customers.name,bsa_foodservice_customers.shr_ship_to,
		<cfif getSettings.approval_uom EQ 1>
		isnull(man_cost,0) as man_cost,
		isnull(Storage_Cost,0) as Storage_Cost,isnull(Stand_Freight,0) as Stand_Freight,
		isnull(Deffered_Freight,0) as Deffered_Freight
		<cfelse>
		case when net_weight !=0 then
		isnull(man_cost,0)/contract_product_margin.net_weight
		else 0 end
		 as man_cost,
		case when net_weight !=0 then
		isnull(Storage_Cost,0)/contract_product_margin.net_weight else 0 end as Storage_Cost,
		case when net_weight !=0 then
		isnull(Stand_Freight,0)/contract_product_margin.net_weight else 0 end as Stand_Freight,
		case when net_weight !=0 then
		isnull(Deffered_Freight,0)/contract_product_margin.net_weight else 0 end as Deffered_Freight
		</cfif>
		from customer_based_costs
		inner join bsa_foodservice_customers on
		bsa_foodservice_customers.bsa_foodservice_customers_id =
		customer_based_costs.customer_id
		inner join contract_product_margin on
		contract_product_margin.product_id = customer_based_costs.product_id
		where
		customer_based_costs.product_id = '#replace(ItemId, "_", "-", "ALL")#'
		and customer_based_costs.customer_id = '#replace(CPID, "_", "-", "ALL")#'
		and contract_product_margin.contract_main_id = #CID#
		and customer_based_costs.source_plant = '#url.plant#'
		and customer_based_costs.shipping_dc = '#url.dc#'
	</CFQUERY>
<cfelse>
	<cfif (type eq "T" and desc eq "P") OR type neq "T">
		<cfif type eq "C" and appsettings.getApprovalLayeredCosts() EQ 3> <!--- customer based cost --->
			<CFQUERY NAME="getitemdetails" datasource="#application.datasource#">
				select 	BSA_Foodservice_Items_Master.item,BSA_Foodservice_Items_Master.description
				from 	BSA_Foodservice_Items_Master
				where 	BSA_Foodservice_Items_Master_id = '#replace(ItemId, "_", "-", "ALL")#'
			</CFQUERY>
			<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
				select	bsa_foodservice_customers.shr_ship_to, bsa_foodservice_customers.name,
						avg(Blended_Cost_CS) as Blended_Cost_CS, avg(Freight_Cost_CS) as Freight_Cost_CS,
						cast(contract_distributors.program_weight as decimal(10, 4)) as program_weight,
						ISNULL(contract_product_margin.cost_cs, 0) as cost_cs
				from	contract_product_margin
				left join contract_distributors
				on		contract_distributors.deleted = 0
				and		contract_distributors.contract_main_id = contract_product_margin.contract_main_id
				and		contract_distributors.is_group = 0
				left join bsa_foodservice_customers
				on		bsa_foodservice_customers.bsa_foodservice_customers_id = contract_distributors.bsa_foodservice_customers_id
				left join gross_margin
				on		gross_margin.product_id = contract_product_margin.product_id
				and		gross_margin.customer_id = contract_distributors.bsa_foodservice_customers_id
				where 	contract_product_margin.contract_main_id = #CID#
				and 	contract_product_margin.product_id = '#replace(ItemId, "_", "-", "ALL")#'
				group by bsa_foodservice_customers.shr_ship_to, bsa_foodservice_customers.name,contract_distributors.program_weight,contract_product_margin.cost_cs
			</CFQUERY>
			<CFQUERY NAME="getDistributorWeight" dbtype="query">
				SELECT 	sum(program_weight) as total_dist_prog_weight
				FROM	TheQuery
				WHERE	Blended_Cost_CS + Freight_Cost_CS <> 0
			</CFQUERY>
		<cfelse>
			<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
				SELECT  Contract_Product_Margin.Net_Weight,ISNULL(FPR_CS,0) as Fixed_Price_CS, ISNULL(RER_CS,0) as Rebate_Price_CS,
				 ISNULL(GRR_CS,0) as Growth_Price_CS, ISNULL(KPR_CS,0) as Formula_Price_CS,
				ISNULL(OER_CS,0) as Offinvoice_Price_CS, isnull(LumpsumAmount_CS, 0) as LumpsumAmount_CS,
				isnull(LumpsumAmount_LB, 0) as LumpsumAmount_LB,
				Description, Item, UPC,
				ISNULL(Base_Sales_LB,0) as Base_Sales_LB,
				ISNULL(Base_Sales_CS,0) as Base_Sales_CS,
				ISNULL(Program_Fixed_Price_CS, 0) as Program_Fixed_Price_CS,
				ISNULL(Used_Fixed_Price, 0) as Used_Fixed_Price,
				ISNULL(Net_Price_CS, 0) as Net_Price_CS,
				ISNULL(Used_Net_Price, 0) as Used_Net_Price,
				(ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance_CS,
				(ISNULL(Item_Allowance_LB,0) + ISNULL(LumpsumAmount_LB,0)) as Item_Allowance_LB,
				(ISNULL(Annualized_Allowance_CS,0) + ISNULL(Annualized_Lumpsum_Allowance_CS,0)) as Item_Annualized_Allowance_CS,
				(ISNULL(Annualized_Allowance_LB,0) + ISNULL(Annualized_Lumpsum_Allowance_LB,0)) as Item_Annualized_Allowance_LB,
				ISNULL(TPA_CS,0) as TPA_CS,ISNULL(PullbackAmount_CS,0) as PullbackAmount_CS,ISNULL(Cash_Discount_CS,0) as Cash_Discount_CS,ISNULL(Net_Sales_CS,0) as Net_Sales_CS,
				ISNULL(Cost_CS,0) as Cost_CS,ISNULL(Diff_Fixed_Price_CS,0) as Diff_Fixed_Price_CS,
				ISNULL(Diff_Formula_Price_CS,0) as Diff_Formula_Price_CS,
				ISNULL(Var_Man_Cost, 0) as Variable_Mfg_Cost,
				ISNULL(Fx_Man_Cost,0) as Fixed_Mfg_Cost,
				ISNULL(Del_Frt_Cost,0) as Del_Frt_Cost,
				ISNULL(Del_Del_Cost,0) as Del_Del_Cost,
				ISNULL(Del_Var_Warhs,0) as Del_Var_Warhs,
				ISNULL(Del_Cust_Pickup,0) as Del_Cust_Pickup,
				ISNULL(FOB_Frt_Cost,0) as FOB_Frt_Cost,
				ISNULL(FOB_Warhs,0) as FOB_Warhs,
				ISNULL(CS_Curr_Cost,0) as Current_Cost,
				ISNULL(Cost_From_Component_CS,0) as Cost_From_Component_CS,
				Item_Deliverytype,ISNULL(TargetMargin,0) as TargetMargin
				<!--- 66894 --->
				<cfif getSettings.Generic_Type EQ 'Operator Direct or HQ Programs' OR getSettings.Generic_Type EQ 'Operator-Deviated Pricing'>
					,ISNULL(Group_ID_Margin_Operator,0) AS Margin_Target_Variation
					,Group_Approval_Rights.Group_ID_Margin_Operator AS Group_ID_Margin
				<cfelse>
					,ISNULL(Group_ID_Margin,0) AS Margin_Target_Variation
					,Group_Approval_Rights.Group_ID_Margin AS Group_ID_Margin
				</cfif>
				<!--- 66894 --->
				,Group_Approval_Rights.Group_ID_List_Price AS Group_ID_List_Price  <!--- 72497 --->
				,Cost_COGS_CS, Cost_Manufacturing_Variance_CS, Cost_Predicted_Adjustment_CS, Cost_Production_Adjustment_CS, Cost_Historical_Adjustment_CS
				FROM        dbo.Contract_Product_Margin
				INNER JOIN BSA_Foodservice_Items_Master
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 	= Contract_Product_Margin.Product_Id
				and BSA_Foodservice_Items_Master.deleted = 0
				INNER JOIN Type_Code_Desc
				ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
				and Type_Code_Desc.deleted = 0
				LEFT JOIN Group_Approval_Rights
				ON	Group_Approval_Rights.Group_ID = Type_Code_Desc.Type_Code_Desc_ID
				and Group_Approval_Rights.User_Profile_ID = #request.Accessstructure.Profiles_ID#
				and Group_Approval_Rights.deleted = 0
				WHERE Contract_Main_ID = #CID#
				AND Contract_Product_Margin.product_id = '#replace(ItemId, "_", "-", "ALL")#'
			</CFQUERY>
		</cfif>
	<cfelseif type eq "T" and desc eq "G">
		<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
			SELECT  Type_Code_Desc.Type_Code_Desc
			<!--- 66894 --->
			<cfif getSettings.Generic_Type EQ 'Operator Direct or HQ Programs' OR getSettings.Generic_Type EQ 'Operator-Deviated Pricing'>
				,Target_Margin_Operator AS TargetMargin
				,ISNULL(Group_ID_Margin_Operator,0) AS Group_ID_Margin
			<cfelse>
				,Target_Margin AS TargetMargin
				,ISNULL(Group_ID_Margin,0) AS Group_ID_Margin
			</cfif>
			<!--- 66894 --->
	 		,ISNULL(Group_ID_List_Price, 0) AS Group_ID_List_Price <!--- 72497 --->
			FROM   Type_Code_Desc
			LEFT JOIN Group_Approval_Rights
			ON 	Group_Approval_Rights.Group_ID = Type_Code_Desc.Type_Code_Desc_ID
			and Group_Approval_Rights.User_Profile_ID = #request.Accessstructure.Profiles_ID#
			and Group_Approval_Rights.deleted = 0
			WHERE  Type_Code_Desc.Type_Code_Desc_Id = '#replace(ItemId, "_", "-", "ALL")#'
			and Type_Code_Desc.deleted = 0
		</CFQUERY>
	</cfif>
</cfif>
<cfquery name="qCostOverride" datasource="#application.datasource#">
	  SELECT
			Field_Name
			,Old_Value
			,New_Value
			,Created_Date
			,ISNULL(u.name_first + ' ' + u.name_last, 'Unknown') AS User_Name
		FROM Contract_Product_Margin_Override cpmo
			LEFT JOIN _Users u ON cpmo.Created_By = u.user_ID
		WHERE Contract_Main_ID = <cfqueryparam value="#CID#">
			AND BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
			AND cpmo.Deleted = 0
</cfquery>
<!--- <BR><BR> --->
<cfoutput>
<h3 style="text-align:center;padding:0;margin:0;">#PAGE_TITLE#</h3>
<hr class="two">
<cfloop QUERY="Program_Details">
	<div class="hdr">
		<label>Program:</label> [#Program_Details.Contract_Number#]
		<label>Start Date:</label> #DateFormat(Program_Details.Contract_Start_Date, "medium")#
		<label>End Date:</label> #DateFormat(Program_Details.Contract_End_Date, "medium")#
	</div>
</cfloop>
<hr class="two">

<cfif  type EQ "B" OR  type EQ "CB" OR (type eq "C" and appsettings.getApprovalLayeredCosts() EQ 3)>
	<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></td>
		<td colspan="2" style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#getitemdetails.item# -  #getitemdetails.description#</B></td>
	</tr>
	</table>
	<cfif type EQ "B">
		<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
		<tr VALIGN="bottom" bgcolor="Orange">
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Customer/Shipto</B></td>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weight</B></td>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Price</B></td>
			<!--- Dev Note: 10661 Milan - Removed this column --->
			<!--- <td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Deliver Type</B></td> --->
		</tr>
		<cfloop QUERY="TheQuery">
		<tr VALIGN="bottom">
			<td><B>#name# -  #shr_ship_to#</B></td>
			<td align="center"><B>#program_weight#%</B></td>
			<td><B>#trim(numberformat(base_price, money_fmt))#</B></td>
			<!--- Dev Note: 10661 Milan - Removed this column --->
			<!--- <td align="center"><B><cfif delivery_type EQ 'F'>FOB<cfelse>DEL</cfif></B></td> --->
		</tr>
		</CFLOOP>
		</table>
		<CFQUERY NAME="getbasesales" dbtype="query">
			select distinct base_sales from TheQuery
		</CFQUERY>
		<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<!--- D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable--->
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B><cfoutput>#appSettings.getBaseSaleLabel()#</cfoutput></B></td>
			<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">	<B><cfoutput>$#getbasesales.Base_Sales#</cfoutput></B></td>
		</tr>
		<tr>
			<td COLSPAN="2">&nbsp;</td>
		</tr>
		</table>
	<cfelseif type EQ "CB">
		<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
		<tr VALIGN="bottom" bgcolor="Orange">
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Customer/Shipto</B></td>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>DC</B></td>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Plant</B></td>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weight</B></td>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Cost</B></td>
		</tr>
		<cfloop QUERY="TheQuery">
		<tr VALIGN="bottom">
			<cfset tmpBsaItem = replace(bsa_foodservice_customers_id, "-", "_", "ALL") />
			<td><B><A style="cursor:pointer;"ONCLICK="showDetailCalculation('#tmpBsaItem#','#Shipping_DC#','#source_plant#')"> #name# -  #shr_ship_to#</A></B></td>
			<td align="center"><B><cfif Shipping_DC IS NOT "">#Shipping_DC#<cfelse>&nbsp;</cfif></B></td>
			<td align="center"><B><cfif source_plant IS NOT "">#source_plant# <cfelse>&nbsp;</cfif></B></td>
			<td align="center"><B>#program_weight#%</B></td>
			<td><B>#trim(numberformat(cost, money_fmt))#</B></td>
		</tr>
		</CFLOOP>
		</table>
		<cfset useLakebaseForgetcustcost = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("thequery")>
<cfif useLakebaseForgetcustcost>
	<cftry>
		<cfset getcustcost = application.oLakebase.toQuery(
			application.oLakebase.selectRows("thequery", {
				"select" = "cust_cost"
			}), "cust_cost"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetcustcost = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetcustcost>
<CFQUERY NAME="getcustcost" dbtype="query">
			select distinct cust_cost from TheQuery
		</CFQUERY>
</cfif>
		<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
		<tr>
			<td COLSPAN="2">&nbsp;</td>
		</tr>
		<tr>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Customer Based cost:</B></td>
			<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B><cfoutput>$#trim(numberformat(getcustcost.cust_cost, money_fmt))#</cfoutput></B></td>
		</tr>
		<tr>
			<td COLSPAN="2">&nbsp;</td>
		</tr>
		</table>
	<cfelseif type EQ "C"><!--- customer based cost --->
		<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
			<tr VALIGN="bottom" bgcolor="Orange">
				<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Customer/Shipto</B></td>
				<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Blended Cost</B></td>
				<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Freight Cost</B></td>
				<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weight</B></td>
				<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weighted Avg.</B></td>
			</tr>

			<cfset totalDistributorWeight = getDistributorWeight.total_dist_prog_weight />
			<cfif totalDistributorWeight eq "" or totalDistributorWeight eq 0>
				<cfset totalDistributorWeight = 100 />
			</cfif>
			<cfloop QUERY="TheQuery">
			<cfset Blended_Cost = Val(Blended_Cost_CS) />
			<cfset Freight_Cost = Val(Freight_Cost_CS) />
			<cfset Product_Cost = TheQuery.cost_cs />
			<cfif url.margin_type EQ 3>
				<cfset Blended_Cost = Blended_Cost / Net />
				<cfset Freight_Cost = Freight_Cost / Net />
				<cfset Product_Cost = Product_Cost / Net />
			</cfif>
			<tr VALIGN="bottom">
				<td><B>#name# -  #shr_ship_to#</B></td>
				<td align="center"><B><cfif Blended_Cost_CS IS NOT "">#NumericRoundDecimal(Blended_Cost_CS, 4)#<cfelse>&nbsp;</cfif></B></td>
				<td align="center"><B><cfif Freight_Cost_CS IS NOT "">#NumericRoundDecimal(Freight_Cost_CS, 4)# <cfelse>&nbsp;</cfif></B></td>
				<td align="center"><B>#PercentageFormat(program_weight/100, 4)#</B></td>
				<cfset weightedAvg = ((Blended_Cost + Freight_Cost) * program_weight) / totalDistributorWeight />
				<td>#NumericRoundDecimal(weightedAvg, 4)#</td>
			</tr>
			</CFLOOP>
			<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
				<tr>
					<TD COLSPAN="2">&nbsp;</td>
				</tr>
				<tr>
					<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Cost:</B></td>
					<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">	<B><cfoutput>$#trim(NumericRoundDecimal(Product_Cost, 4))#</cfoutput></B></td>
				</tr>
				<tr>
					<td COLSPAN="2">&nbsp;</td>
				</tr>
			</table>
		</table>
	</cfif>
</cfif>

<cfif type EQ "CBD">
	&nbsp;&nbsp;<A style="cursor:pointer;" ONCLICK="window.history.back()">#application.util.string.actionLinkFormat('Back')#</A>
	<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Customer:</B></td>
		<td colspan="2" style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#TheQuery.name# -  #TheQuery.shr_ship_to#</B></td>
	</tr>
	</table>
	<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<tr BGCOLOR="##FFCE84" VALIGN="bottom">
		<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Manufacturing Cost:</B></td>
		<td colspan="2" style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#trim(numberformat(TheQuery.man_cost, money_fmt))#</B></td>
	</tr>
	<tr BGCOLOR="##FFCE84" VALIGN="bottom">
		<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Storage Cost:</B></td>
		<td colspan="2" style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#trim(numberformat(TheQuery.Storage_Cost, money_fmt))#</B></td>
	</tr>
	<tr BGCOLOR="##FFCE84" VALIGN="bottom">
		<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Standard Freight:</B></td>
		<td colspan="2" style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#trim(numberformat(TheQuery.Stand_Freight, money_fmt))#</B></td>
	</tr>
	<tr BGCOLOR="##FFCE84" VALIGN="bottom">
		<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Deferred Freight:</B></td>
		<td colspan="2" style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#trim(numberformat(TheQuery.Deffered_Freight, money_fmt))#</B></td>
	</tr>
	</table>
</cfif>

<cfif isdefined("TheQuery") and TheQuery.recordCount GT 0>
<cfif NOT (type eq "C" and appsettings.getApprovalLayeredCosts() EQ 3)>
<cfloop query="TheQuery">
<div class="hdr2">
	<cfif  type NEQ "AG" and desc eq "G">
		<label>#uCase(application.returned_customer_setting.type_code_label_singular)#:</label> <b>#Type_Code_Desc#</b><br>
	<cfelseif type NEQ "AG" and desc neq "G" and type NEQ "B" and type NEQ "CB"  and type NEQ "CBD">
		<label>PRODUCT:</label> <i>#TheQuery.Item# - #TheQuery.Description#</i><br>
	</cfif>
	<cfif type EQ "A">
		<cfset BASE_SALES = "#Base_Sales_CS##MULTIPLIER##STAT_MULTIPLIER#">
		<label>#appSettings.getBaseSaleLabel()#</label> <i>$#trim(numberformat(evaluate(BASE_SALES), money_fmt))#</i><br>
		<cfif Used_Net_Price EQ 1 AND Net_Price_CS NEQ 0>
			<cfset Net_Price = "#Net_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
			<label>Net Price:</label> <i>$#trim(numberformat(evaluate(Net_Price), money_fmt))#</i><br>
		</cfif>
		<cfif Used_Fixed_Price EQ 1 AND Program_Fixed_Price_CS NEQ 0>
			<cfset Program_Fixed_Price = "#Program_Fixed_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
			<label>Fixed Price:</label> <i>$#trim(numberformat(evaluate(Program_Fixed_Price), money_fmt))#</i><br>
		</cfif>
		<label>Delivery Type:</label> <i><cfif Item_Deliverytype EQ 1>DEL<cfelse>FOB</cfif></i><br>
	</cfif>
</div>
<cfif type EQ "A">
	<cf_include files="/script/javascript/string_functions.js, /billbacks/common/common_js_functions.js, /Script/javascript/format_functions.js">

<cfif 	isContractCurrentlyLocked.Contract_Is_Locked EQ 1
  AND 	isContractCurrentlyLocked.Contract_Locked_By_User_ID EQ request.Accessstructure.User_ID
  AND	CSLGetContractInfo.Contract_Status_Type_IDX LTE 2
  AND	CSLGetContractInfo.Single_Component_Per_Discount_Type>
	<cfset bAllowEditRateInMarginPage = 1 />
</cfif>
<cfset viewprogramtemplateManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") >
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<tr BGCOLOR="##FFCE84" VALIGN="bottom">
	<td NOWRAP><B>Discount Type</B></td>
	<td NOWRAP><B>Allowance</B></td>
	<cfif bAllowEditRateInMarginPage>
	<td NOWRAP><B>Price/Rate</B></td>
	</cfif>
</tr>
<cfif GetSettings.Discount_Fixed_Prices EQ 1>
	<tr>
		<td><B>Fixed</B></td>
		<td align="right">
			<cfset diff_fixed_price = "#Diff_Fixed_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
			<cfset diff_fixed_price = evaluate(diff_fixed_price) />
			<cfif editdiscounts AND FixedPricesStatus.Recordcount >
				<a href="##" onclick="NewWindow('Contract_Discount_Fixed_Component.cfm?CID=#EncryptedCID#&bFromMargin=1','editdiscounts','850','600','Yes', 'Yes');">
			</cfif>
			$#trim(numberformat(diff_fixed_price, money_fmt))#
			<cfif editdiscounts AND FixedPricesStatus.Recordcount >
				</a>
			</cfif>
		</td>
		<cfif bAllowEditRateInMarginPage>
			<td>
			<cfset qFixedPrice = viewprogramtemplateManager.getFixedPriceOnEmail(Contract_Main_ID = CSL_Contract_Main_ID, Product_ID = Product_ID_GUID) />
			<!---
			Do not allow edit if there are more than one fixed component
			Do not allow edit if fixed component type = Price Extension (2)
			--->
			<cfif qFixedPrice.recordCount eq 1 and qFixedPrice.Fixed_Price_Type neq 2>
				<cfset bEditFixedPrice = 1 />
				<cfif qFixedPrice.Unit_Of_Measure_ID eq 2>
					<cfset iBasePrice = TheQuery.Base_Sales_LB />
				<cfelse>
					<cfset iBasePrice = TheQuery.Base_Sales_CS />
				</cfif>
				<input type="text" name="Fixed_Price_Value" size="3" value="#NumberFormat(qFixedPrice.Fixed_Price_Value, ".____")#" ONKEYUP="clenseText(this,'0123456789.')" onChange="
						<cfif appSettings.getProgram_Allow_Null_Rate() EQ 1>
							this.value = formatToDeciamalPlacesAllowNull(this.value,4,1);
						<cfelse>
							this.value = formatToDeciamalPlaces(this.value,4);
						</cfif>"
						> /#qFixedPrice.Abbreviation#
				<input type="hidden" name="Fixed_Price_UOM" value="#qFixedPrice.Unit_Of_Measure_ID#" />
			</cfif>&nbsp;
			</td>
		</cfif>
	</tr>
<!--- Dev Note: Clay 10023 (Margin Edit was not intended for Bid Request)  --->
<cfelseif GetSettings.Generic_Type IS "Bid Request">
	<tr>
		<td><B>Fixed</B></td>
		<td align="right">
			<cfset diff_fixed_price = "#Diff_Fixed_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
			<cfset diff_fixed_price = evaluate(diff_fixed_price) />
			$#trim(numberformat(diff_fixed_price, money_fmt))#
		</td>
	</tr>
</cfif>
<cfif GetSettings.Discount_Rebates EQ 1>
<tr>
	<td><B>#Application.RebateLabel#</B></td>
	<td align="right">
		<cfset Rebate_Price = "#Rebate_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
		<cfset Rebate_Price = evaluate(Rebate_Price) />
		<cfif editdiscounts AND RebateStatus.RecordCount>
			<a href="##" onclick="NewWindow('Contract_Discount_Rebates.cfm?CID=#EncryptedCID#&bFromMargin=1','editdiscounts','850','600','Yes', 'Yes');">
		</cfif>
			$#trim(numberformat(Rebate_Price, money_fmt))#
		<cfif editdiscounts AND RebateStatus.RecordCount>
			</a>
		</cfif>
	</td>
	<cfif bAllowEditRateInMarginPage>
	<td>
	<cfset qRebate = viewprogramtemplateManager.getRebateOnEmail(Contract_Main_ID = CSL_Contract_Main_ID, Product_ID = Product_ID_GUID) />
	<!--- According to Paul client will only have eitehr fixed or rebate. If fixed exists they can edit fixed, if not they can edit rebate
	Even though there is no technical difficulty to let users edit both	--->
	<cfif qRebate.recordCount eq 1 and bEditFixedPrice eq 0>
	<cfset bEditRebate = 1 />
	<input type="text" name="Rebate_Value" size="3" value="#NumberFormat(qRebate.Rate, ".____")#" ONKEYUP="clenseText(this,'0123456789.')"
	onChange="
	<cfif appSettings.getProgram_Allow_Null_Rate() EQ 1>
		this.value = formatToDeciamalPlacesAllowNull(this.value,4,1);
	<cfelse>
		this.value = formatToDeciamalPlaces(this.value,4);
	</cfif>"
	> /#qRebate.Abbreviation#
	<input type="hidden" name="Rebate_UOM" value="#qRebate.Unit_Of_Measure_ID#" />
	</cfif>&nbsp;
	</td>
	</cfif>
</tr>
</cfif>
<cfif GetSettings.Discount_Lump_Sums EQ 1>
<tr>
	<td><B>#Application.LumpsumLabel#</B></td>
	<td align="right">
		<cfif url.margin_type EQ 3>
			<cfset LumpsumAmount  = LumpsumAmount_LB>
		<cfelse>
			<cfset LumpsumAmount = "#LumpsumAmount_CS##MULTIPLIER##STAT_MULTIPLIER#">
			<cfset LumpsumAmount = evaluate(LumpsumAmount) />
		</cfif>
		<cfif editdiscounts AND LumpStatus.RecordCount>
			<a href="##" onclick="NewWindow('Contract_Discount_Lump_Sums_Margin.cfm?CID=#EncryptedCID#','editdiscounts','800','600','Yes', 'Yes');"></cfif>
		 	$#trim(numberformat(LumpsumAmount, money_fmt))#
		<cfif editdiscounts AND LumpStatus.RecordCount>
			</a>
		</cfif>
	</td>
</tr>
</cfif>
<cfif GetSettings.Discount_Growth EQ 1>
<tr>
	<td><B>Growth</B></td>
	<td align="right">
	<cfset Growth_Price = "#Growth_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
	<cfset Growth_Price = evaluate(Growth_Price) />
	<cfif editdiscounts AND GrowthStatus.RecordCount >
		<a href="##" onclick="NewWindow('Contract_Discount_Growth_margin.cfm?CID=#EncryptedCID#','editdiscounts','850','600','Yes', 'Yes');">
	</cfif>
	$#trim(numberformat(Growth_Price, money_fmt))#
	<cfif editdiscounts AND GrowthStatus.RecordCount>
		</a>
	</cfif>
	</td>
</tr>
</cfif>
<cfif GetSettings.Discount_Formula_Pricing EQ 1>
<tr>
	<td><B>Formula</B></td>
	<td style="border-bottom: 1px ##93BEE2  solid;" align="right">
		<cfset Formula_Price ="#Diff_Formula_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
		$#trim(numberformat(evaluate(Formula_Price), money_fmt))#
	</td>
</tr>
</cfif>
<cfif GetSettings.Generic_Type IS "Distributor Off-Invoice">
<tr>
	<td><B>Off Invoice</B></td>
	<td align="right">
		<cfset Offinvoice_Price = "#Offinvoice_Price_CS##MULTIPLIER##STAT_MULTIPLIER#">
		<cfset Offinvoice_Price = evaluate(Offinvoice_Price) />
		<cfif editdiscounts AND Off_Invoice.RecordCount >
			<a href="##" onclick="NewWindow('off-invoice_margin.cfm?CID=#EncryptedCID#','editdiscounts','800','600','Yes', 'Yes');"></cfif>
			 $#trim(numberformat(OffInvoice_Price, money_fmt))#
		<cfif editdiscounts AND Off_Invoice.RecordCount>
			</a>
		</cfif>
	</td>
</tr>
</cfif>
</table>
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total Allowance:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">
	<cfif url.margin_type EQ 3>
		<cfset ItemAllowance = Item_Allowance_LB>
	<cfelse>
		<cfset ItemAllowance = "#Item_Allowance_CS##MULTIPLIER##STAT_MULTIPLIER#">
	</cfif>
	<B>
	<cfif ItemAllowance LT 0>
		<span style="color: red;">
			<cfset Item_Allowance = evaluate(ItemAllowance) * (-1)>
			[$#trim(numberformat(Item_Allowance, money_fmt))#]
		</span>
	<cfelse>
		$#trim(numberformat(evaluate(ItemAllowance), money_fmt))#
	</cfif>
	</B>
	</td>
</tr>
<cfif appSettings.getApprovalMarginType() eq 2><!--- Approval = Annual Case Rate --->
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total Annualized Allowance:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">
	<cfif url.margin_type EQ 3>
		<cfset ItemAllowance = Item_Annualized_Allowance_LB>
	<cfelse>
		<cfset ItemAllowance = "#Item_Annualized_Allowance_CS##MULTIPLIER##STAT_MULTIPLIER#">
	</cfif>
	<B>
	<cfif ItemAllowance LT 0>
		<span style="color: red;">
			<cfset Item_Allowance = evaluate(ItemAllowance) * (-1)>
			[$#trim(numberformat(Item_Allowance, money_fmt))#]
		</span>
	<cfelse>
			$#trim(numberformat(evaluate(ItemAllowance), money_fmt))#
	</cfif>
	</B>
	</td>
</tr>
</cfif>
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
</table>
<cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
	<cfsilent>
	<CFQUERY NAME="getFOBcalculation" datasource="#application.datasource#">
	SELECT DISTINCT CPM.product_id,
		CUST.Program_Weight as program_weight,
		C.name, C.shr_ship_to,
		ISNULL(PFFR.Delivered_Price,0.0000) as Delivered_Price,
		ISNULL(Freight_Rate,0.0000) as Freight_Rate,
		ISNULL(FOB_Price,0.0000) as FOB_Price,
		ISNULL(CPM.net_weight,1) as net_weight
	FROM Contract_Product_Margin CPM
	INNER JOIN Contract_Distributors CUST
	ON CUST.Contract_Main_ID = CPM.Contract_Main_id
	--and Margin_Product_customer.product_id =contract_product_margin.product_id
	INNER JOIN bsa_foodservice_customers C
	ON C.bsa_foodservice_customers_id = CUST.BSA_Foodservice_Customers_ID
	INNER JOIN Contract_Products CP
	ON CPM.Product_Id = CP.BSA_Foodservice_Items_Master_ID
	AND CP.Contract_Main_ID = CPM.Contract_Main_ID
	AND CP.Product_Type_ID = 1
	LEFT JOIN Program_Fixed_Freight_Rates PFFR
	ON ((PFFR.product_id = CP.BSA_Foodservice_Items_Master_ID AND CP.Captured_From_Group = 0) OR (PFFR.product_id = CP.Product_Group_ID AND CP.Captured_From_Group = 1))
	AND PFFR.deleted = 0
	AND PFFR.program_id = CP.Contract_Main_ID
	AND PFFR.customer_id = CUST.BSA_Foodservice_Customers_ID
	WHERE CPM.contract_main_id = #CID#
	AND CUST.Deleted = 0
	AND CPM.deleted = 0
	AND CPM.product_id = '#replace(ItemId, "_", "-", "ALL")#'
	</CFQUERY>
	</cfsilent>
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<SPAN CLASS="TITLE2">Customer Rates</SPAN>
<tr VALIGN="bottom" bgcolor="FFCE84">
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Customer/Shipto</B></td>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weight</B></td>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Delivered Price</B></td>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weight. Del Rate</B></td>
	<!---<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Freight</B></td>--->
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>F.O.B</B></td>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Weight. Rate</B></td>
</tr>
<cfset total_fob_rate = 0>
<cfset total_Delivered_rate = 0>
<cfloop QUERY="getFOBcalculation">
	<cfsilent>
	<!---<cfif url.margin_type EQ 1>
			<cfset del_price = getFOBcalculation.Delivered_Price * getFOBcalculation.NET_WEIGHT>
	       <cfset frt_rate = getFOBcalculation.freight_rate * getFOBcalculation.NET_WEIGHT>
	       <cfset fob_rate = getFOBcalculation.fob_price * getFOBcalculation.NET_WEIGHT>
	       <cfset weighted_rate = (program_weight * fob_rate)/100>
	   <cfelse>--->
	   <cfset del_price = getFOBcalculation.Delivered_Price>
	   <cfset frt_rate = getFOBcalculation.freight_rate>
	   <cfset fob_rate = getFOBcalculation.fob_price>
	   <cfset weighted_rate = (program_weight * fob_rate)/100>
		<cfset weighted_delivered_rate = (program_weight * del_price)/100>
	<!--- </cfif>--->
	<cfset total_fob_rate = total_fob_rate + weighted_rate>
	<cfset total_Delivered_rate = total_Delivered_rate + weighted_delivered_rate>
	</cfsilent>
<tr VALIGN="bottom">
	<td><B>#name# -  #shr_ship_to#</B></td>
	<td align="center">#program_weight#%</td>
	<td>$#trim(numberformat(del_price, money_fmt))#</td>
	<td>$#trim(numberformat(weighted_delivered_rate, money_fmt))#</td>
	<!--- <td>$#trim(numberformat(frt_rate, money_fmt))#	</td> --->
	<td>$#trim(numberformat(fob_rate, money_fmt))#</td>
	<td>$#trim(numberformat(weighted_rate, money_fmt))#</td>
</tr>
</CFLOOP>
</table>
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total Weighted Delivered Rate:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">	<B>$#trim(numberformat(total_Delivered_rate, money_fmt))#</B></td>
</tr>
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
</table>
</cfif>
<!--- D28741: Display competitor information on rate pop up on margin page --->
<cfif  appsettings.getUseFixedPriceType() and (bEditFixedPrice or bEditRebate)>
<!--- JS Function --->
<script language="JavaScript">
	function showCompetitorSourceOther(sourceDropDownName, sourceOtherTextbox)	{
		if(document.getElementById(sourceDropDownName).value == '-1')	{
			document.getElementById(sourceOtherTextbox).style.display = "block";
		}
		else{
			document.getElementById(sourceOtherTextbox).style.display = "none";
		}
	}
</script>

	<!--- Function to display the competitor info section --->
	<cffunction name="displayCompetitorInfo" output="true">
		<cfargument name="prefix" type="string" required="true" />
		<cfargument name="Saved_Competitor_Name_ID" type="string" required="true" />
		<cfargument name="Saved_Competitor_Price" type="string" required="true" />
		<cfargument name="Saved_Competitor_Time_Frame" type="string" required="true" />
		<tr valign="top">
			<td NOWRAP>
			<cfset not_other ="">
			<cfset bOtherSelected = 0 />
			<cfset other_value = "">
			<select name="#arguments.prefix#_Competitor_Name_ID" onChange="showCompetitorSourceOther('#arguments.prefix#_Competitor_Name_ID', '#arguments.prefix#_CompetitorSourceOther')" id="#arguments.prefix#_Competitor_Name_ID" style="width:200px">
				<OPTION VALUE="0" SELECTED>Select a Competitor</OPTION>
				<cfloop QUERY="CompetitorList">
					<cfset sChecked = "" />
					<cfif CompetitorList.Program_Bid_Won_By_ID eq arguments.Saved_Competitor_Name_ID>
						<cfset sChecked = " selected " />
						<cfset not_other ="yes">
					</cfif>
					<OPTION VALUE="#CompetitorList.Program_Bid_Won_By_ID#" #sChecked#>
					#trim(CompetitorList.Program_Bid_Won_By_Description)#
					</OPTION>
				</cfloop>
				<cfif not_other eq "" and isNumeric(arguments.Saved_Competitor_Name_ID) and arguments.Saved_Competitor_Name_ID neq 0><!--- none of the above options are selected, but there one in the TABLE --->
					<cfset useLakebaseForqGetOtherCompetitor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForqGetOtherCompetitor>
	<cftry>
		<cfset qGetOtherCompetitor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"program_bid_won_by_id" = "eq.#arguments.Saved_Competitor_Name_ID#",
				"select" = "program_bid_won_by_description"
			}), "program_bid_won_by_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOtherCompetitor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOtherCompetitor>
<cfquery name="qGetOtherCompetitor" datasource="#application.datasource#">
					SELECT 	Program_Bid_Won_By_Description
					FROM	Program_Bid_Won_By
					WHERE 	Program_Bid_Won_By_ID = #arguments.Saved_Competitor_Name_ID#
					</cfquery>
</cfif>
					<cfif qGetOtherCompetitor.recordCount>
						<cfset other_value = qGetOtherCompetitor.Program_Bid_Won_By_Description />
						<cfset bOtherSelected = 1 />
					</cfif>
				</cfif>
				<OPTION VALUE="-1" <cfif bOtherSelected>SELECTED</cfif>>Other</OPTION>
			</select>
			<input type="text" name="#arguments.prefix#_CompetitorSourceOther" id="fixed_CompetitorSourceOther" value="#other_value#" style="width:200px" <cfif bOtherSelected>style="display: block;"<cfelse>style="display: none;"</cfif>>
			</td>
			<td NOWRAP>
				<input type="text" value="#arguments.Saved_Competitor_Price#" size="2" name="#arguments.prefix#_Competitor_Price" maxlength="20" ONKEYUP="clenseText(this,'0123456789.')" />
			</td>
			<td NOWRAP>
				<input type="text" value="#arguments.Saved_Competitor_Time_Frame#" size="5" name="#arguments.prefix#_Competitor_Time_Frame" maxlength="15" />
			</td>
		</tr>
	</cffunction>

	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	<cfset CompetitorList = programManager.getCompetitorList()>
	<table BORDER="0" CELLPADDING="3" CELLSPACING="2" ALIGN="Center">
		<tr BGCOLOR="##FFCE84" VALIGN="bottom">
			<td NOWRAP><B>Competitor Name</B></td>
			<td NOWRAP><B>Dist Cost</B></td>
			<td NOWRAP><B>Time Frame</B></td>
		</tr>
		<!--- Call function to display the competitor info section for fixed price --->
		<cfif bEditFixedPrice and appsettings.getUseFixedPriceType() and (qFixedPrice.Fixed_Price_Type eq 1 or qFixedPrice.Fixed_Price_Type eq 3)>
			<cfset displayCompetitorInfo("fixed", qFixedPrice.Competitor_Name_ID, qFixedPrice.Competitor_Price, qFixedPrice.Competitor_Time_Frame) />
		</cfif>
		<!--- Call function to display the competitor info section for rebate --->
		<cfif bEditRebate and appsettings.getUseFixedPriceType()>
			<cfset displayCompetitorInfo("rebate", qRebate.Competitor_Name_ID, qRebate.Competitor_Price, qRebate.Competitor_Time_Frame) />
		</cfif>
	</table>
	<BR>
</cfif>

<cfelseif type EQ "N">
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<tr>
	<td><B>#appsettings.getMarginColHeader2()#</B></td>
	<td>
		<cfset Base_Sales = "#Base_Sales_CS##MULTIPLIER##STAT_MULTIPLIER#">
		$#trim(numberformat(evaluate(Base_Sales), money_fmt))#
	</td>
</tr>
<tr>
	<td><B><cfif appSettings.getlocalcostvariables() eq 1>#appsettings.getMarginColHeader4()#<cfelse>#appsettings.getMarginColHeader3()#</cfif></B></td>
	<td>
		<cfset Cash_Discount = "#Cash_Discount_CS##MULTIPLIER##STAT_MULTIPLIER#">
		$#trim(numberformat(evaluate(Cash_Discount), money_fmt))#
	</td>
</tr>
<tr>
	<td><B>#appsettings.getMarginColHeader5()#</B></td>
	<td>
		<cfset ItemAllowance = "#Item_Allowance_CS##MULTIPLIER##STAT_MULTIPLIER#">
		<cfif Item_Allowance_CS LT 0>
			<span style="color: red;">
				<cfset Item_Allowance = evaluate(ItemAllowance) * (-1)>
				[$#trim(numberformat(evaluate(Item_Allowance), money_fmt))#]
			</span>
		<cfelse>
			$#trim(numberformat(evaluate(ItemAllowance), money_fmt))#
		</cfif>
	</td>
</tr>
<tr>
	<td><B>#appsettings.getMarginColHeader6()#</B></td>
	<td>
		<cfset TPA = "#TPA_CS##MULTIPLIER##STAT_MULTIPLIER#">
		$#trim(numberformat(evaluate(TPA), money_fmt))#
	</td>
</tr>
<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
	<tr>
		<td><B>#appSettings.getPullbackLabel()# Amt.</B></td>
		<td>
			<cfset Pullback = "#PullbackAmount_CS##MULTIPLIER##STAT_MULTIPLIER#">
			$#trim(numberformat(evaluate(Pullback), money_fmt))#
		</td>
	</tr>
</cfif>
</table>
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Net Sales:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">
	<B>
	<cfset NetSales = "#Net_Sales_CS##MULTIPLIER##STAT_MULTIPLIER#">
	<cfif Net_Sales_CS LT 0>
	<span style="color: red;">
		<cfset Net_Sales = evaluate(NetSales) * STAT_MULTIPLIER>
		[$#trim(numberformat(Net_Sales, money_fmt))#]
	</span>
	<cfelse>
		$#trim(numberformat(evaluate(NetSales), money_fmt))#
	</cfif>
	</B>
	</td>
</tr>
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
</table>
<cfelseif type EQ "C">
<!--- ******************************************************************************************************************************************** --->
<!--- ********************************************************** Cost logic starts here ********************************************************** --->
<!--- ******************************************************************************************************************************************** --->
<form name="costs" action="cost_action.cfm" method="post">
	<input type="hidden" name="contract_main_id" value="#CID#">
	<input type="hidden" name="product_id" value='#replace(ItemId, "_", "-", "ALL")#'>
	<input type="hidden" name="action">
	<input type="hidden" name="margin_type" value="#url.margin_type#">
	<table border="0" cellpadding="6" cellspacing="0" style="border: 1px solid ##CCC;" id="costTable" class="tablesorter row-border hover dataTable material">
		<thead>
			<tr>
				<th>Description</th>
				<th>Value</th>
			</tr>
		</thead>
		<tbody>
		<cfif Margin_Display_Style eq "custom_t">	
			<cfset predicted_total = 0>
			<cfif appSettings.get_Setting('Margin_Cost_Predictive_Selected') EQ "ON">
				<!---------------------------------------------- Predictive --------------------------------------------------------->
				
				<CFQUERY NAME="qGetPredictedCost" datasource="#application.datasource#">
					DECLARE 
					@Contract_Start_Date DATE = '#DateFormat(Program_Details.Contract_Start_Date, "mm/dd/yyyy")#', 
					@Contract_End_Date DATE = '#DateFormat(Program_Details.Contract_End_Date, "mm/dd/yyyy")#',
					@Product_ID uniqueidentifier = '#replace(ItemId, "_", "-", "ALL")#'

					IF OBJECT_ID('tempdb..##tmp_cost_popup_predictive_cost') IS NOT NULL
					DROP TABLE ##tmp_cost_popup_predictive_cost

					SELECT	c.Product_ID, CAST(i.Net_Weight as Float) as Net_Weight, 
							Start_Date, End_Date, Unit_of_Measure, Meat_Cost, Var_Cost, Fixed_Cost,
							Start_Date as Use_Start,
							End_Date as Use_End,
							Min(Start_Date) Over (Partition by c.Product_ID) as Min_Start, 
							Max(End_Date) Over (Partition by c.Product_ID) as Max_End,
							CAST(0 as int) as Num_Days
					INTO	##tmp_cost_popup_predictive_cost
					FROM	Product_Cost_Custom c
					INNER JOIN BSA_Foodservice_Items_Master i
					ON		i.BSA_Foodservice_Items_Master_ID = c.Product_ID
					WHERE	c.Product_ID = @Product_ID
					AND		c.Start_Date <= @Contract_End_Date -- Has started
					AND		c.End_Date >= @Contract_Start_Date -- Has not ended

					-- convert from LB to CS
					UPDATE	##tmp_cost_popup_predictive_cost
					SET		Meat_Cost = Meat_Cost * Net_Weight,
							Var_Cost = Var_Cost * Net_Weight,
							Fixed_Cost = Fixed_Cost * Net_Weight
					WHERE	Unit_of_Measure = 'LB'

					-- If program start is in the middle, set Use_Start = program start to the first cost record
					UPDATE	##tmp_cost_popup_predictive_cost
					SET		Use_Start = @Contract_Start_Date
					WHERE	Start_Date = Min_Start -- First record
					AND		@Contract_Start_Date > Min_Start

					-- If program end is in the middle, set Use_End = program end to the last cost record
					UPDATE	##tmp_cost_popup_predictive_cost
					SET		Use_End = @Contract_End_Date
					WHERE	End_Date = Max_End -- Last record
					AND		@Contract_End_Date < Max_End

					UPDATE	##tmp_cost_popup_predictive_cost
					SET		Num_Days = Datediff(d, Use_Start, Use_End) + 1

					SELECT	Product_ID, 
							SUM(Meat_Cost * Num_Days / Sum_Num_Days) as Meat_Cost,
							SUM(Var_Cost * Num_Days / Sum_Num_Days) as Var_Cost,
							SUM(Fixed_Cost * Num_Days / Sum_Num_Days) as Fixed_Cost
					FROM	(
						SELECT	*, SUM(Num_Days) Over (Partition by 1) as Sum_Num_Days
						FROM	##tmp_cost_popup_predictive_cost
						WHERE	Num_Days != 0
					) as tmp
					GROUP BY Product_ID
				</CFQUERY>
				
				
				<tr>
					<td><B>#appsettings.getMarginCostColHeader7()#</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Val(qGetPredictedCost.Meat_Cost)##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("FOB_Frt_Cost")#
						<cfset predicted_total    = predicted_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money predicted" name="fob_frt_cost" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>#appsettings.getMarginCostColHeader1()#</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Val(qGetPredictedCost.Var_Cost)##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("var_man_cost")#
						<cfset predicted_total    = predicted_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money predicted" name="var_man_cost" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>#appsettings.getMarginCostColHeader2()#</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Val(qGetPredictedCost.Fixed_Cost)##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("fx_man_cost")#
						<cfset predicted_total    = predicted_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money predicted" name="fx_man_cost" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>Predicted Adjustment</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Cost_Predicted_Adjustment_CS##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("Cost_Predicted_Adjustment_CS")#
						<cfset predicted_total    = predicted_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money predicted" name="cost_predicted_adjustment_cs" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<!--- Total row --->
				<tr class="total">
					<td class="total">Predicted Total</td>
					<td style="color:green">
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money" name="predicted_total" disabled value="#numberformat(predicted_total, money_fmt)#">
						<cfelse>
							$#numberformat(predicted_total, money_fmt)#
						</cfif>
					</td>
				</tr>
			</cfif>
			<cfif appSettings.get_Setting('Margin_Cost_Production_Selected') EQ "ON">
				<cfset production_total = 0>
				<!---------------------------------------------- Current / Production --------------------------------------------------------->
				<tr>
					<td><B>#appsettings.getMarginCostColHeader6()#</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Del_Frt_Cost##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("Del_Frt_Cost")#
						<cfset production_total   = production_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money production" name="del_frt_cost" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>#appsettings.getMarginCostColHeader5()#</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Del_Var_Warhs##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("Del_Var_Warhs")#
						<cfset production_total   = production_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money production" name="del_var_warhs" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>#appsettings.getMarginCostColHeader8()#</B></td>
					<td>
						<cfset request.cost_value = evaluate("#FOB_Warhs##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("FOB_Warhs")#
						<cfset production_total   = production_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money production" name="fob_warhs" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>Current Adjustment</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Cost_Production_Adjustment_CS##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("Cost_Production_Adjustment_CS")#
						<cfset production_total   = production_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money production" name="cost_production_adjustment_cs" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<!--- Total row --->
				<tr class="total">
					<td class="total">Current Total</td>
					<td style="color:green">
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money" name="production_total" disabled value="#numberformat(production_total, money_fmt)#">
						<cfelse>
							$#numberformat(production_total, money_fmt)#
						</cfif>
					</td>
				</tr>
			</cfif>
			<cfif appSettings.get_Setting('Margin_Cost_Historical_Selected') EQ "ON">
				<cfset historical_total = 0>
				<tr>
					<td><B>Historical Sales Cost</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Cost_COGS_CS##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("Cost_COGS_CS")#
						<cfset historical_total = historical_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money historical" name="cost_cogs_cs" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr>
					<td><B>Historical Adjustment</B></td>
					<td>
						<cfset request.cost_value = evaluate("#Cost_Historical_Adjustment_CS##MULTIPLIER##STAT_MULTIPLIER#")>
						#big_star("Cost_Historical_Adjustment_CS")#
						<cfset historical_total = historical_total + request.cost_value>
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money historical" name="cost_historical_adjustment_cs" value="#numberformat(request.cost_value, money_fmt)#">
						<cfelse>
							$#numberformat(request.cost_value, money_fmt)#
						</cfif>
					</td>
				</tr>
				<tr class="total">
					<td class="total">Historical Total</td>
					<td style="color:green">
						<cfif isEditing.recordCount and url.verticalPNL neq ''>
							$ <input type="text" class="money" name="historical_total" disabled value="#numberformat(historical_total, money_fmt)#">
						<cfelse>
							$#numberformat(historical_total, money_fmt)#
						</cfif>
					</td>
				</tr>
			</cfif>
		<cfelse>
			<cfif appsettings.getApprovalLayeredCosts() EQ 2>
				<cfif ! appsettings.getMarginCostColHeader1_delete()>
					<tr>
						<td><B>#appsettings.getMarginCostColHeader1()#</B></td>
						<td>
							<cfset Var_Mfg_Cost = "#Variable_Mfg_Cost##MULTIPLIER##STAT_MULTIPLIER#">
							$#trim(numberformat(evaluate(Var_Mfg_Cost), money_fmt))#
						</td>
					</tr>
				</cfif>
				<cfif ! appsettings.getMarginCostColHeader2_delete() and appSettings.get_Setting('Contribution_Margin_Calculation') NEQ '1'>
					<tr>
						<td><B>#appsettings.getMarginCostColHeader2()#</B></td>
						<td>
							<cfset F_Mfg_Cost = "#Fixed_Mfg_Cost##MULTIPLIER##STAT_MULTIPLIER#">
							$#trim(numberformat(evaluate(F_Mfg_Cost), money_fmt))#
						</td>
					</tr>
				</cfif>
				<cfif Item_Deliverytype EQ "1">
					<cfif ! appsettings.getMarginCostColHeader6_delete()>
						<tr>
							<!--- D42728 :: Freight Delivered cost factor --->
							<td><B>#appSettings.getMarginCostColHeader6()#<!---Freight Delivered---></B></td>
							<td>
								<cfset D_Frt_Cost = "#Del_Frt_Cost##MULTIPLIER##STAT_MULTIPLIER#">
								$#trim(numberformat(evaluate(D_Frt_Cost), money_fmt))#
							</td>
						</tr>
					</cfif>
					<cfif ! appsettings.getMarginCostColHeader3_delete()>
						<tr>
							<td><B>#appsettings.getMarginCostColHeader3()#</B></td>
							<td>
								<cfset D_Del_Cost = "#Del_Del_Cost##MULTIPLIER##STAT_MULTIPLIER#">
								$#trim(numberformat(evaluate(D_Del_Cost), money_fmt))#
							</td>
						</tr>
					</cfif>
					<cfif ! appsettings.getMarginCostColHeader4_delete()>
						<tr>
							<td><B>#appsettings.getMarginCostColHeader4()#</B></td>
							<td>
								<cfset D_Cust_Pickup = "#Del_Cust_Pickup##MULTIPLIER##STAT_MULTIPLIER#">
								$#trim(numberformat(evaluate(D_Cust_Pickup), money_fmt))#
							</td>
						</tr>
					</cfif>
					<cfif ! appsettings.getMarginCostColHeader5_delete()>
						<tr>
							<td><B>#appsettings.getMarginCostColHeader5()#</B></td>
							<td>
								<cfset D_Var_Warhs = "#Del_Var_Warhs##MULTIPLIER##STAT_MULTIPLIER#">
								$#trim(numberformat(evaluate(D_Var_Warhs), money_fmt))#
							</td>
						</tr>
					</cfif>
				</cfif>
				<cfif Item_Deliverytype EQ "2">
					<tr>
						<td><B>#appsettings.getMarginCostColHeader7()#</B></td>
						<td>
							<cfset F_Frt_Cost = "#FOB_Frt_Cost##MULTIPLIER##STAT_MULTIPLIER#">
							$#trim(numberformat(evaluate(F_Frt_Cost), money_fmt))#
						</td>
					</tr>
					<tr>
						<td><B>#appsettings.getMarginCostColHeader8()#</B></td>
						<td>
							<cfset F_Warhs = "#FOB_Warhs##MULTIPLIER##STAT_MULTIPLIER#">
							$#trim(numberformat(evaluate(F_Warhs), money_fmt))#
						</td>
					</tr>
				</cfif>
			<cfelseif appsettings.getApprovalLayeredCosts() EQ 1>
				<tr>
					<td><B>Current Cost</B></td>
					<td>
						<cfset C_Cost = "#Current_Cost##MULTIPLIER##STAT_MULTIPLIER#">
						$#trim(numberformat(evaluate(C_Cost),'_-___,___,___,___,___.___'))#
					</td>
				</tr>
			</cfif>
			<!--- Display TPA Cost value --->
			<tr>
				<td><B><a onclick="javascript: displayComponentCostDetails();return false;" href="##">Component Cost</a></B></td>
				<td>
					<cfset TPA_Cost = "#Cost_From_Component_CS##MULTIPLIER##STAT_MULTIPLIER#">
					$#trim(numberformat(evaluate(TPA_Cost),'_-___,___,___,___,___.___'))#
				</td>
			</tr>
		</cfif>
		</tbody>
	</table>
</form>

<!--- <table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total Cost:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfset Cost = "#Cost_CS##MULTIPLIER##STAT_MULTIPLIER#">
		$#trim(numberformat(evaluate(Cost),'_-___,___,___,___,___.___'))#
	</td>
</tr>
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
</table> --->
<div class="hdr2 hdr3">
	<cfset Cost = "#Cost_CS##MULTIPLIER##STAT_MULTIPLIER#">
	<label>Total Cost:</label> <i id="total_cost">$#trim(numberformat(evaluate(Cost), money_fmt))#</i>
</div>
<!--- ******************************************************************************************************************************************** --->
<!--- ********************************************************** Cost logic ends here ********************************************************** --->
<!--- ******************************************************************************************************************************************** --->
<cfelseif type EQ "T" and desc EQ "P">
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<tr>
	<td><B>Item Margin Target</B></td>
	<td align="right">
		#trim(numberformat(Round(TargetMargin),'_-___,___,___,___,___'))#%
	</td>
</tr>
<tr>
	<td><B>Margin Target Variation </B></td>
	<td align="right">
	<cfif Get_Profile_Settings.program_margin_approval_method EQ 6>
		<cfset MarginTargetVariation = Thequery.Margin_Target_Variation>
	<cfelse>
		<cfset MarginTargetVariation = Get_Profile_Settings.Margin_Target_Variation>
	</cfif>
	<cfif trim(MarginTargetVariation) NEQ "*">
		#trim(numberformat(Round(MarginTargetVariation),'_-___,___,___,___,___'))#%
	<cfelse>
		*
	</cfif>
	</td>
</tr>
</table>
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Margin #UOMdisplay#:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfif trim(MarginTargetVariation) NEQ "*">
			<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<cfset totalmargin = TargetMargin + ((TargetMargin * MarginTargetVariation)/100)>
			<cfelse>
				<cfset totalmargin = TargetMargin - ((TargetMargin * MarginTargetVariation)/100)>
			</cfif>
		<cfelse>
			<cfset totalmargin = TargetMargin>
		</cfif>
         #dollarformat(totalmargin)#
	</td>
</tr>
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
</table>
<cfelseif type EQ "T" and desc EQ "G">
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<tr>
	<td><B>#UCASE(application.returned_customer_setting.type_code_label_singular)# Margin Target</B></td>
	<td align="right">
		#trim(dollarformat(TargetMargin))# #replace(UOMdisplay,'Per','/')#
	</td>
</tr>
<tr>
	<td><B>Margin Target Variation </B></td>
	<td align="right">
	<cfif trim(Group_ID_Margin) NEQ "*">
		#trim(dollarformat(Group_ID_Margin))# #replace(UOMdisplay,'Per','/')#
	<cfelse>
		*
	</cfif>
	</td>
</tr>
</table>
<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
<tr>
	<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Margin #UOMdisplay#:</B></td>
	<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfif trim(Group_ID_Margin) NEQ "*">
			<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<cfset totalmargin = TargetMargin + ((TargetMargin * Group_ID_Margin)/100)>
			<cfelse>
				<cfset totalmargin = TargetMargin - ((ABS(TargetMargin) * Group_ID_Margin)/100)>
			</cfif>
		<cfelse>
			<cfset totalmargin = TargetMargin>
		</cfif>
            #dollarformat(totalmargin)#
	</td>
</tr>
<tr>
	<td COLSPAN="2">&nbsp;</td>
</tr>
</table>
</cfif>
</CFLOOP>
</cfif>
<cfelse>
	<div align="center"><font color="red">NO DATA</font></div>
</cfif>
</cfoutput>
<cfif (isdefined("TheQuery") and TheQuery.recordCount GT 0) and type EQ "AG">
	<cfif desc EQ 'G'>
		<cfset groupby = "type_code_desc">
	<cfelse>
		<cfset groupby = "item">
	</cfif>
<cfoutput query="TheQuery" group="#groupby#">
	<table align="center" border="0">
	<cfif desc EQ 'G'>
		<tr>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>#UCASE(application.returned_customer_setting.type_code_label_singular)#:</B></td>
			<td style="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#Type_Code_Desc#</B></td>
		</tr>
	<cfelse>
		<tr>
			<td style="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></td>
			<td style="border-bottom: 0px; font-size: 12px;"><B>#TheQuery.Item# - #TheQuery.Description#</B></td>
		</tr>
	</cfif>
	</table>
	<table BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" style="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<tr>
		<td><B>User Name</B></td>
		<td>Date/Time</td>
	</tr>
	<tr>
		<td><B>#name_first# #name_last#</B></td>
		<td>#Dateformat(created_date,"mm/dd/yyyy")#</td>
	</tr>
	</table>
</cfoutput>
</cfif>
<cfoutput>
<div id="actions">
	<cfif Margin_Display_Style eq "custom_t">	
		<cfif type is 'C' and isEditing.recordCount>
			<a href="javascript:saveCost()">#application.util.string.actionLinkFormat2('save')#</a>
		</cfif>
	<cfelseif bAllowEditRateInMarginPage and (bEditRebate or bEditFixedPrice)>
		<a href="javascript:saveRate()">#application.util.string.actionLinkFormat2('save')#</a>
	</cfif>
	<a href="javascript:closeWindow()">#application.util.string.actionLinkFormat2('close window')#</a>
</div>
<div align="center" style="overflow:auto;color:green;" id="divMessage"></div>

<cfif bAllowEditRateInMarginPage>
	<cfmodule template="/CustomTags/wddxAjax/wddxAjax.cfm" ajaxComponent="components.programs.program"  className="programAjax">
</cfif>

<cfset jQueryUI.version = "1.9.1">
<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQuery.cfm">

<cfif Margin_Display_Style eq "custom_t">
	<cf_include files="/script/javascript/jquery.util.js, /styles/css-loader.css, /script/javascript/numeral.min.js">
<cfelse>
	<cf_include files="/Script/javascript/jQuerytablesorter/js/jquery-latest.min.js, /Script/javascript/jQuerytablesorter/js/jquery.tablesorter.js, /Script/javascript/jQuerytablesorter/js/jquery.tablesorter.widgets.js, /script/javascript/jquery.util.js, /styles/css-loader.css, /script/javascript/numeral.min.js">
</cfif>

<cfset isRebate = 0 />
<cfset isFixed = 0 />
<cfif (isDefined("qRebate") AND qRebate.RecordCount NEQ 0)>
	<cfset isRebate = 1 />
</cfif>
<cfif (isDefined("qFixedPrice") AND qFixedPrice.RecordCount NEQ 0)>
	<cfset isFixed = 1 />
</cfif>

<script>
	<cfif Margin_Display_Style neq "custom_t">
		$(function(){  $("##costTable").tablesorter({ sortList: [[1,1]] });});
	</cfif>

	function displayComponentCostDetails(){
		NewWindow('Contract_Trade_Analysis.cfm?ItemId=#ItemId#&CID=#Enc_CID#&margin_type=#url.margin_type#&TPA_TYPE=1','componentcostdetails','800','600','Yes', 'Yes');
	}
	<cfif isDefined("TheQuery.Group_ID_Margin") and TheQuery.Group_ID_Margin eq "*">
		<cfset bUserCanApproveStar = 1 />
	</cfif>
	// Make sure that user have entered the Competitor Info if required
	function validateCompetitorInfo()	{
		var bReturnValue = true;
		<cfif bEditRebate and not bUserCanApproveStar>
			var rebateValue = $('[name=Rebate_Value]').val();
			if(rebateValue != 0){
				//check if competitor info for rebate exists
				if(		$('[name=rebate_Competitor_Name_ID]').val() == 0
					|| 	$('[name=rebate_Competitor_Price]').val() == ""
					|| 	$('[name=rebate_Competitor_Time_Frame]').val() == ""){
					bReturnValue = false;
				}
			}
		</cfif>
		 <cfif bEditFixedPrice and not bUserCanApproveStar>
			var fixedPriceValue = $('[name=Fixed_Price_Value]').val();
			var iBasePrice = #iBasePrice#;
			var fixedPriceDiscount = iBasePrice - fixedPriceValue ;
			if(numericRoundDecimal(fixedPriceDiscount, 2) != 0){
				//check if competitor info for fixed price exists
				if(		$('[name=fixed_Competitor_Name_ID]').val() == 0
					|| 	$('[name=fixed_Competitor_Price]').val() == ""
					|| 	$('[name=fixed_Competitor_Time_Frame]').val() == ""){
					bReturnValue = false;
				}
			}
		 </cfif>
		 return bReturnValue;
	}
	function getRebateProdRateArg(){
		var argument = new Array();
	    <cfif bEditRebate>
		var i = 0;
		argument[0] = new Array();
		argument[i][0]	= $('[name=Rebate_Value]').val();  //rate
		argument[i][1]	= #qRebate.Unit_Of_Measure_ID#;  //uom
		argument[i][2]	= #qRebate.Program_Rebates_Component_Data_ID#; //prodCompId
		argument[i][3] = 0;
		argument[i][4] = 0;
		argument[i][5]	= 0; //scanVolume
		argument[i][6]	= 0; //rebateType
		argument[i][7]	= 1; //EAConversion
		argument[i][8]	= "#qRebate.Inventory_UM#" //productInventoryUOM
		//argument[i][9]	= 2; //Discount Type
		<cfif appsettings.getUseFixedPriceType()>
			argument[i][9]	= $('[name=rebate_Competitor_Name_ID]').val();
			argument[i][10]	= $('[name=rebate_Competitor_Price]').val();
			argument[i][11]	= $('[name=rebate_Competitor_Time_Frame]').val();
			argument[i][12]	= $('[name=rebate_CompetitorSourceOther]').val();
		<cfelse>
			argument[i][9]	= 0;
			argument[i][10]	= 0;
			argument[i][11]	= 0;
			argument[i][12]	= 0;
		</cfif>
		argument[i][13] = 0;
		argument[i][14] = 0;
		argument[i][15] = 0;
		argument[i][16] = 0;
		argument[i][17] = 0;
		argument[i][18] = 0;
		argument[i][19] = 0;
		argument[i][20] = 0;
		argument[i][21] = 0;
		argument[i][22] = 0;
		</cfif>
		
		return argument;
	}
	function getFixedProdRateArg(){
		var argument = new Array();
	    <cfif bEditFixedPrice>
		var i = 0;		
		argument[0] = new Array();
		argument[i][0]	= $('[name=Fixed_Price_Value]').val();  //rate
		argument[i][1]	= #qFixedPrice.Unit_Of_Measure_ID#;  //uom
		argument[i][2]	= #qFixedPrice.Program_Fixed_Price_Product_Data_ID#; //prodCompId
		//argument[i][9]	= 1 //Discount Type
		<cfif appsettings.getUseFixedPriceType() and (qFixedPrice.Fixed_Price_Type eq 1 or qFixedPrice.Fixed_Price_Type eq 3)>
			argument[i][3]	= $('[name=fixed_Competitor_Name_ID]').val();
			argument[i][4]	= $('[name=fixed_Competitor_Price]').val();
			argument[i][5]	= $('[name=fixed_Competitor_Time_Frame]').val();
			argument[i][6]	= $('[name=fixed_CompetitorSourceOther]').val();
		<cfelse>
			argument[i][3]	= 0;
			argument[i][4]	= 0;
			argument[i][5]	= 0;
			argument[i][6]	= 0;
		</cfif>
		argument[i][7]	= #CSL_Contract_Main_ID#;
		</cfif>
		return argument;
	}
	function saveProdRateResponse(arrResponse){
		var altText = '';
		for ( var j=0; j<arrResponse.length; ++j ){
			response = arrResponse[j];
			for ( var i=response.length-1; i>=0; --i ){
			  try {
			  		var sDiscountType = "";
			  		if(i == 1) sDiscountType = "fixed price";
			  		else if(i == 2) sDiscountType = "#LCase(Application.RebateLabel)#";
			  		altText = 'Saved ' + sDiscountType + ': ' + response[i][0];
	       			if(response[i][1] == 1)
	       				{altText = altText + ' CS'}
	       			else if(response[i][1] == 2)
	       				{altText = altText + ' LB'}
	       			else if(response[i][1] == 3)
	       				{altText = altText + ' %'}
	       			document.all.divMessage.innerHTML =  document.all.divMessage.innerHTML + altText + "<br>";
	     	  }
			  catch (err) {
			  }
			}
		}
		// close the window and reload margin page
		window.close();
		if(!top.opener.closed){
			top.opener.focus();
			top.opener.document.all.MyForm.action = "layered_margin_calculation.cfm?CID=#Enc_CID#&DuplicateProgram=#DuplicateProgram#";
			top.opener.document.all.MyForm.submit();
		}
	}

	function showDetailCalculation(CustId,DCInfo,PlantInfo){
		location.href = "Contract_Allowance_Analysis.cfm?CPID="+CustId+"&ItemId=#URL.ItemId#&CID=#Enc_CID#&Type=CBD&DC="+DCInfo+"&Plant="+PlantInfo;
	}
	function closeWindow(){
		window.close();
		if(!top.opener.closed){
			top.opener.focus();
			<!--- Dev Note: Clay 9980 Only Refresh on Close from Allowance Analysis --->
			<cfif url.type EQ 'A' and url.verticalPNL neq "1">
			<!--- Set the form action to point back to the parent page's address and then submit (effectively refreshing). --->
			top.opener.document.all.MyForm.action = "layered_margin_calculation.cfm?CID=#Enc_CID#&DuplicateProgram=#DuplicateProgram#";
			top.opener.document.all.MyForm.submit();
			</cfif>
		}
		return true;
	}
	<cfif bAllowEditRateInMarginPage>
	function saveRate()	{
		//iBasePrice
		//validate first whether the user have entered the competitor info
		if(!validateCompetitorInfo()){
			alert("Please fill in the complete competitor info (Name,Price,Time Frame)");
			return false;
		}
		 var ajaxRebate = new programAjax();
		// ajaxRebate.call('saveProgramProductRate',saveProdRateResponse,getFixedProdRateArg(),getRebateProdRateArg()); 
		// The above code does not work any more so below code was added.
		
	 show_loader("SAVING RATE, PLEASE WAIT...");
		fxArray = getFixedProdRateArg();
		rbArray = getRebateProdRateArg();
		$.ajax({type    : "post"
				,url     : "/components/programs/Program.cfc"
				// ,dataType: "array"
				,dataType: "JSON"
				,data: { method: "saveProgramProductRateRemote"
						,fixedArray:  JSON.stringify(fxArray)
						,rebateArray: JSON.stringify(rbArray)
						,isRebate: #isRebate#
						,isFixed: #isFixed#
						}
				,success: function (response) {
					saveProdRateResponse(response);
				}
				,error: function(response)
				{
					//alert(response);
					alert('Error occured trying to save ');
				}
		}); 
		
		// ajax response function saveProdRateResponse will close the window
		 
		return;
	}
	</cfif>
	<cfif Margin_Display_Style neq "custom_t">
		$(function(){  $("##costTable").tablesorter();});
	<cfelseif type is 'C' and url.verticalPNL neq '' and isEditing.recordCount>
		function repeatString(string, count) {
			return new Array(count + 1).join(string);
		}

		/* use no. of decimal places from setting */
		numeral.defaultFormat('($0,0.' + repeatString('0', #decimal_places#) + ')');

		$('input.money').forceNumeric();

		/* enable automated calculations for totals */
		refresh_total("predicted");
		refresh_total("production");
		refresh_total("historical");
		refresh_total_cost();

		function isZero( element_name ) {
			let element_value = $("input[name=" + element_name + "]").val();
			/* blank empty value is considered as zero */
			if (element_value.trim() == "")
				return true;
			else
				return numeral( element_value ).value() == 0;
		}

		function refresh_total_cost() {
			let debug      = 0;
			let total_cost = 0;
			/* use predicted as total cost when both predicted var cost & predicted fixed cost have non zero values */
			if (!isZero("var_man_cost") && !isZero("fx_man_cost")) {
				total_cost = $("input[name=predicted_total]").val();
				if (debug) alert("predicted");
			}
			/* use current as total cost when both current var cost & current fixed cost have non zero values */
			else if (!isZero("del_var_warhs") && !isZero("fob_warhs")) {
				total_cost = $("input[name=production_total]").val();
				if (debug) alert("production");
			}
			/* use historical as total cost when above conditions are not met */
			else {
				total_cost = $("input[name=historical_total]").val();
				if (debug) alert("historical");
			}
			/* refresh total cost */
			$("##total_cost").text( numeral(total_cost).format() );
		}
		
		function refresh_total( class_name ) {
			/* calculate upon leaving input element */
			$("input." + class_name).blur(function() {
				let total = 0;
				$("input." + class_name).each(function(){
					total = total + numeral($(this).val()).value();
				});
				/* refresh individual total */
				$("input[name=" + class_name + "_total]").val( numeral(total).format() );
				refresh_total_cost();
			});
		}
	
		function saveCost() {
			show_loader();
			/* update cost element in parent page */
			<cfif url.parent_element_id neq "0">
				$("###url.parent_element_id#", opener.document).text( numeral($("##total_cost").text()).format() );
			</cfif>
			$("input[name=action]").val("save");
			$("form[name=costs]").submit();
		}
	</cfif>
</script>
</cfoutput>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>