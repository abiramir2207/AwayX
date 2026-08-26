<!----------------------------------------------------------------------------------
Name         :	index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date :
Created By   :
Description  :
---------------------------------------------------------------------------------->
<cfsetting showdebugoutput="yes" />
<!doctype html>
<html lang="en">
<head>
	<cfsavecontent variable="head_content">
		<!--- include jQuery and jQueryUI --->
		<cfset jQueryUI.widgets = 'tabs' />
		<cfinclude template="/Common_Files/jQuery.cfm">
		<cf_include file_to_include="/common_files/tabjqui.css, /styles/css-loader.css, /script/javascript/numeral.min.js"/>

		<script>
			$(function() {
		    	$( "#tabs" ).tabs();
				collapsible: true;
		  	});
		</script>
    </cfsavecontent>
    <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
    <cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<cfset objPlannerTemplateManager = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager") />

<cfparam NAME="url.display" 	default="basicInfo">
<cfparam NAME="form.display" 	default="#url.display#">

<cfparam NAME="form.command" 		default="">
<cfparam NAME="url.id" 				default="">
<cfparam NAME="form.id" 			default="#url.id#">
<cfparam NAME="form.default_view" 	default="0">
<cfparam NAME="url.copy" 			default="0">
<cfparam NAME="form.copy" 			default="#url.copy#">
<cfparam NAME="URL.lockUnlock" 		default="0" />

<cfset selectedIndex = 99>
<cfswitch expression="#url.display#">
	<cfcase value="basicInfo">
		<cfset selectedIndex = 0>
	</cfcase>
	<cfcase value="details">
		<cfset selectedIndex = 1>
	</cfcase>
	<cfcase value="fields">
		<cfset selectedIndex = 2>
	</cfcase>
	<cfcase value="profiles">
		<cfset selectedIndex = 3>
	</cfcase>
	<cfcase value="filters">
		<cfset selectedIndex = 4>
	</cfcase>
	<cfcase value="indirect">
		<cfset selectedIndex = 5>
	</cfcase>
</cfswitch>


<cfscript>
	param form.Wholesaler_Planner  = 0;
</cfscript>

<!---/////////////GET PROFILES///////////--->
<cfquery name="qProfiles" datasource="#application.datasource#">
	SELECT DISTINCT
		Profiles.Profiles_ID
		,Profiles_Desc
		,Profiles_Short_Desc
		,2						   AS s_order
	FROM dbo.Profiles
		LEFT JOIN dbo.Profiles_Settings
			ON Profiles_Settings.Deleted = 0
				AND Profiles_Settings.Profiles_ID = Profiles.Profiles_ID
	WHERE Profiles.Deleted = 0

	UNION

	SELECT TOP 1
		0
		,'Any New Profiles'
		,'ANP'
		,1 AS s_order
	FROM dbo.Profiles
	WHERE Deleted = 0
	ORDER BY s_order, Profiles_Desc
</cfquery>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!---****************************** START COMMANDS ***********************************--->

<cfif form.command eq "svData">
	<!---/////////////SAVE BASIC INFO ///////////--->
	<cfscript>
		param form.Actual_Default                  = 0;
		param form.Actual_Display                  = "";
		param form.Actual_Percent_Forecast_Default = 0;
		param form.Actual_Percent_Forecast_Display = "";
		param form.AOP_Default                     = 0;
		param form.AOP_Display                     = "";
		param form.Demand_Plan_Default             = 0;
		param form.Demand_Plan_Display             = "";
		param form.Forecast_Default                = 0;
		param form.Forecast_Display                = "";
		param form.Locked_Forecast_Default         = 0;
		param form.Locked_Forecast_Display         = 0;
		param form.Forecast_Percent_PY_Default     = 0;
		param form.Forecast_Percent_PY_Display     = "";
		param form.Margin_Display                  = "";
		param form.Net_Sales_Display               = "";
		param form.NUC_Display                     = "";
		param form.PY_Summary_Display              = "";
		param form.Planner_Calendar_Config_ID      = "";
		param form.Planner_Perf_Types_ID           = "";
		param form.Indirect_Planner_Perf_Types_ID  = "";
		param form.Prior_Yr_Default                = 0;
		param form.Prior_Yr_Display                = "";
		param form.Retroactive_Planner             = 0;
		param form.Retroactive_Revision            = 0;
		param form.Template_Select                 = "";
		param form.Template_Select_Accrual         = "";
		param form.Trade_Display                   = "";
		param form.UOM_CS                          = "";
		param form.UOM_Default                     = "";
		param form.UOM_EA                          = "";
		param form.UOM_LB                          = "";
		param form.Business_Segment_ID             = 0;
		param form.Program_Default_UOM             = 0;
		param form.Wholesaler_Planner               = 0;
		param form.Indirect_Volume_Display         = 0;
		param form.Indirect_Volume_Default         = 0;
		param form.Indirect_Volume_Percent_Forecast_Display         = 0;
		param form.Indirect_Volume_Percent_Forecast_Default         = 0;
		param form.Indirect_Product_Source         = 1;
		param form.Check_Duplicate_Planner         = 0;
		param form.Check_Duplicate_Planner_Action  = 1;
		param form.Include_In_Catalog         		= 0;
		param form.Output_Before_Approval      		= 0;
		param form.Auto_Generate_Accrual_Program	= 0;
		param form.Alert_RFA_Programs         			= 0;
		param form.Alert_RFA_Programs_Days        		= 0;
		param form.Alert_Pending_Accept_Programs		= 0;
		param form.Alert_Pending_Accept_Programs_Days	= 0;
		param form.Program_Volume_Default_UOM			= 1;
		param form.allow_individual_distributors    = 0;
		param form.YTD_Display         = 0;
		param form.YTD_Default         = 0;
		param.form.lsAllPrgTemplateIDs = "";
	</cfscript>

	<cfset objSv = objPlannerTemplateManager.savePlannerTemplateData(
					id=form.ID,
					dataStruct=form
			) />

	<cfset form.Id = objSv />

	<!---//////////// SAVE DETAIL ///////////--->
	<cfset url.display = "details" />
		<!--- if the user picked "yes" then add all the templates available --->
		<cfif (form.Inc_all_Accrual_Prgs_in_Planner EQ 1)>
			<cfset form.Template_Select_Accrual = "" /> <!--- form.lsAllPrgTemplateIDs --->
		</cfif>	
	
	<cfset objPlannerTemplateManager.saveDetails(id=form.ID,
           lPlannerCalendar=form.Planner_Calendar_Config_ID,
           lPlannerPerfTypes=form.Planner_Perf_Types_ID,
           lIndirectPlannerPerfTypes=form.Indirect_Planner_Perf_Types_ID) />
	<cfset objPlannerTemplateManager.saveProgramPlannerTemplates(id=form.id,lProgramTemplateIds=form.Template_Select,lProgramTemplateIdsAccrual=form.Template_Select_Accrual) />

	<!---/////////////SAVE FIELDS///////////--->
	<cfset url.display = "fields" />
	<!--- saved as part of basic info --->

	<!---/////////////SAVE PROFILES///////////--->
	<cfset url.display = "profiles" />
	<cfoutput query="qProfiles">
		<!--- unchecked checkboxes are not included in the submitted form so create them & assigned to off (not allowed)--->
		<cfparam name="form.Allow_Access_#qProfiles.Profiles_ID#" default="off">

		<cfquery name ="qCheckEntryExists" datasource="#application.datasource#">
			SELECT	*
			FROM	Profile_Forbidden_Planner
			WHERE	Profile_ID = #qProfiles.Profiles_ID#
			AND 	Planner_Template_ID = #form.id#
		</cfquery>

		<cfif qCheckEntryExists.RecordCount>

			<cfquery datasource="#application.datasource#">
				UPDATE 	Profile_Forbidden_Planner
			   	SET 	Access_is_forbidden = #(form[ "Allow_Access_" & qProfiles.Profiles_ID ] eq "off" ? 1 : 0)#,
				   		Updated_Date = GetDate()
			 	WHERE 	Profile_ID = #qProfiles.Profiles_ID#
				AND 	Planner_Template_ID = #form.id#
			</cfquery>

		<cfelse>

			<cfquery datasource="#application.datasource#">
				INSERT INTO Profile_Forbidden_Planner
				(
					Profile_ID,
					Access_is_forbidden,
					Planner_Template_ID
				)
				VALUES
				(
					#qProfiles.Profiles_ID#,
					#(form[ "Allow_Access_" & qProfiles.Profiles_ID ] eq "off" ? 1 : 0)#,
					#form.id#
				)
			</cfquery>

		</cfif>

	</cfoutput>

	<!---/////////////SAVE FILTERS///////////--->
	<cfset url.display = "filters" />
	<cfquery name="qDeleteFilterDetail" datasource="#application.datasource#">
		DELETE FROM Planner_Template_Filters_Customers WHERE Planner_Template_ID = '#form.ID#'
		DELETE FROM Planner_Template_Filters_Products WHERE Planner_Template_ID = '#form.ID#'
		DELETE FROM Planner_Template_Filters_Operators WHERE Planner_Template_ID = '#form.ID#'
	</cfquery>

	<cfloop index="gIdx" list="#form.lDistributorGroupLevelIDs#">
		<cfparam name="form.Allow_In_Search_#gIdx#" default="" />
		<cfparam name="form.Allow_In_Group_Search_#gIdx#" default="" />
		<cfparam name="form.Allow_Filter_#gIdx#" default="" />
		<cfparam name="form.Customers_Filters_#gIdx#" default="" />

		<cfoutput>
				<cfset objPlannerTemplateManager.saveFilters(
					id=form.ID,
					groupLevelID=gIdx,
					groupType=2,
					allowInSearch=#trim(form["Allow_In_Search_" & gIdx])#,
					allowInGroupSearch=#trim(form["Allow_In_Group_Search_" & gIdx])#,
					allowFilter=#trim(form["Allow_Filter_" & gIdx])#,
					filtersList=#trim(form["Customers_Filters_" & gIdx])#,
					groupList=#trim(form["Customers_Filters_" & gIdx])#
				) />
		</cfoutput>
	</cfloop>

	<cfloop index="gIdx" list="#form.lProductGroupLevelIDs#">
		<cfparam name="form.Allow_In_Search_Prod_#gIdx#" default="" />
		<cfparam name="form.Allow_In_Group_Search_Prod_#gIdx#" default="" />
		<cfparam name="form.Allow_Filter_Prod_#gIdx#" default="" />
		<cfparam name="form.Product_Filters_#gIdx#" default="" />

		<cfif form.groupLevelId eq gIdx>
			<cfset "form.Product_Filters_#gIdx#" = form.SelectedFilterGroups />
		</cfif>

		<cfoutput>
			<cfset variables.default_view = "0">
			<!--- radio button default view is selected for this product group level --->
			<cfif form.default_view eq gIdx>
				<cfset variables.default_view = "1">
				<!--- assign planner view value due to checkbox being disabled on the screen --->
				<cfset form["Allow_In_Search_Prod_" & gIdx] = 1>
			</cfif>

				<cfset objPlannerTemplateManager.saveFilters(
					id=form.ID,
					groupLevelID=gIdx,
					groupType=1,
					allowInSearch=#trim(form["Allow_In_Search_Prod_" & gIdx])#,
					allowInGroupSearch=#trim(form["Allow_In_Group_Search_Prod_" & gIdx])#,
					allowFilter=#trim(form["Allow_Filter_Prod_" & gIdx])#,
					filtersList=#trim(form["Product_Filters_" & gIdx])#,
					default_view='#variables.default_view#',
					groupList=#trim(form["Product_Filters_" & gIdx])#
				) />

		</cfoutput>
	</cfloop>

	<cfloop index="gIdx" list="#form.lOperatorGroupLevelIDs#">
			<cfparam name="form.Allow_In_Search_#gIdx#" default="" />
			<cfparam name="form.Allow_In_Group_Search_#gIdx#" default="" />
			<cfparam name="form.Allow_Filter_#gIdx#" default="" />
			<cfparam name="form.Operators_Filters_#gIdx#" default="" />

			<cfoutput>
					<cfset objPlannerTemplateManager.saveFilters(
						id=form.ID,
						groupLevelID=gIdx,
						groupType=3,
						allowInSearch=#trim(form["Allow_In_Search_" & gIdx])#,
						allowInGroupSearch=#trim(form["Allow_In_Group_Search_" & gIdx])#,
						allowFilter=#trim(form["Allow_Filter_" & gIdx])#,
						filtersList=#trim(form["Operators_Filters_" & gIdx])#,
						groupList=#trim(form["Operators_Filters_" & gIdx])#
					) />
			</cfoutput>
		</cfloop>

	<cfset url.id = form.id />
	<cfset url.display = "basicInfo" />
	<cfset form.copy = 0 />

</cfif>

<cfif isDefined("URL.lockUnlock")>
	<!--- 1 = lock; 0 = unlock --->
	<cfif URL.lockUnlock EQ 1>
		<cfset temp = objPlannerTemplateManager.lockUnlockPlannerTemplate(request.accessstructure.user_ID,URL.id,1) />
	<cfelse>
		<cfset temp = objPlannerTemplateManager.lockUnlockPlannerTemplate(request.accessstructure.user_ID,URL.id,0) />
	</cfif>
</cfif>

<cfset form.command = "" />
<cfset qGetPlannerTemplate = objPlannerTemplateManager.getPlannerTemplates(id=form.id) />

<cfif qGetPlannerTemplate.RecordCount>
    <cfset form.Wholesaler_Planner = qGetPlannerTemplate.Wholesaler_Planner
                                        or (isDefined("qGetPlannerTemplate.category") and qGetPlannerTemplate.category is "Wholesaler")
                                        ? 1
                                        : 0>
</cfif>



<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->
<cfscript>
    objLabels        = createObject("component", "components.settings.Labels.Labels").init();
    sWholesaleLabel  = objLabels.GetPlannerLabels('Wholesaler').Planner_Labels_Singular;
    sIndirectLabel   = objLabels.GetPlannerLabels('Indirect').Planner_Labels_Singular;
    TR_BORDER_WIDTH  = 2;
    TD_FORE_COLOR    = "FFE083";
    TD_FORE_COLORTOP = "999999";

	param url.display  = "basicInfo";
	param form.command = "";
	param PAGE_NAME    = "1";

	PAGE_TITLES  = "basic info,details,fields,profiles,filters,#sIndirectLabel#";
	PAGE_ACTIONS = "basic info,details,fields,profiles,filters,indirect";

	width = "120";
	if (url.display EQ "basicInfo")
		PAGE_NAME = 1;
	else if (url.display EQ "details")
		PAGE_NAME = 2;
	else if (url.display EQ "fields")
		PAGE_NAME = 3;
	else if (url.display EQ "profiles")
		PAGE_NAME = 4;
	else if (url.display EQ "filters")
		PAGE_NAME = 5;
	else if (url.display EQ "indirect")
		PAGE_NAME = 6;
</cfscript>


<BODY>

	<cfif cgi.REQUEST_METHOD is "post">
	</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "#Application.PlannerLabel# TEMPLATES: Basic Info">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfset selectedIndex = 99>

<!--- 115103: Retail Planner Template - updates / Anand Rao / 31-May-2022 --->
<CFINCLUDE TEMPLATE="planner_template_lock_unlock.cfm">   

<!--- this form is used in "select filter" option --->
<form name="add_groups" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_groups')">
    <input type="hidden" name="product_group_level_id" value="">
    <input type="hidden" name="parent_call_back" value="">
	<input type="hidden" name="selection_input_name" value="filter_product_list">
    <input type="hidden" name="filter_product_list" value="">
</form>

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">
<style>
	li a { outline: none; }
	.hideElem {visibility: hidden;}
</style>
<div id="tabs" class="tab">
	<cfoutput>
	<cfset C_Counter = 1>
	<ul>
	<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
		<cfif C_Counter eq 1>
			<li>
				<a href="##tabs-1">
					#ThisMenuItem#
				</a>
			</li>
		</cfif>
		<cfif C_Counter eq 2>
			<li>
				<a href="##tabs-2">
					#ThisMenuItem#
				</a>
			</li>
		</cfif>
		<cfif C_Counter eq 3>
			<li>
				<a href="##tabs-3">
					#ThisMenuItem#
				</a>
			</li>
		</cfif>
		<cfif C_Counter eq 4>
			<li>
				<a href="##profiles-tab">
					#ThisMenuItem#
				</a>
			</li>
		</cfif>
		<cfif C_Counter eq 5>
			<li>
				<a href="##filters-tab">
					#ThisMenuItem#
				</a>
			</li>
		</cfif>
        <cfif C_Counter eq 6 and form.Wholesaler_Planner eq 1>
			<li>
				<a href="##indirect-tab">
					#ThisMenuItem#
				</a>
			</li>
		</cfif>
		<CFSET C_Counter = C_Counter + 1>
	</CFLOOP>
	</ul>
	<br>
	<a title="click to save changes" id="save_changes" style="display:none;font-size:10px;">#application.util.string.LinkFormat("save")#</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a title="click to go back to #Application.PlannerLabel# templates list" href="/Planners/Templates/page_list.cfm" style="font-size:10px;">#application.util.string.LinkFormat(" Back to template list")#</a>
	
	<div id="tabs-1">
		<cfinclude template="planner_template_basic_info.cfm" />
	</div>
	<div id="tabs-2">
		<cfinclude template="planner_template_details.cfm" />
	</div>
	<div id="tabs-3">
		<cfinclude template="planner_template_fields.cfm" />
	</div>
	<div id="profiles-tab">
		<cfinclude template="planner_template_profiles.cfm" />
	</div>
	<div id="filters-tab">
		<cfinclude template="planner_template_filters.cfm" />
	</div>

    <cfif isDefined("form.planner_category") and form.planner_category is "Wholesaler">
        <cfset form.Wholesaler_Planner = 1>
    </cfif>

	<cfif form.Wholesaler_Planner eq 1>
        <div id="indirect-tab">
            <cfinclude template="planner_template_indirect.cfm" />
        </div>
	</cfif>

	</cfoutput>
</div>
<cfoutput>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<br>

<a title="click to save changes" id="save_changes" style="display:none;font-size:11px;">#application.util.string.LinkFormat("save")#</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a title="click to go back to #Application.PlannerLabel# templates list" href="/Planners/Templates/page_list.cfm" style="font-size:10px;">#application.util.string.LinkFormat(" Back to template list")#</a>

<cfif form.copy eq 1>
	<cfset form.id =  -1 />
</cfif>

<!---hidden form fields--->
<input name="id" 		type="hidden" value="#form.id#" />
<input name="display"	type="hidden" value="#form.display#" />
<input name="command" 	type="hidden" value="#form.command#" />
<input name="copy" 		type="hidden" value="#form.copy#" />

<!--- include wholesaler indicator in posting form for proper update in backend row --->
<input name="Wholesaler_Planner" type="hidden" value="#form.Wholesaler_Planner#">
</FORM>
</cfoutput>
<script>
	$("a#save_changes").click(function(){

        <cfif application.appsettingsget.getPriceListByTemplate()>
		if(DataForm.Price_List_Header_ID.value == 0)
		{
			alert("Please select a Price List in basic info.");
			return;
		}
        </cfif>

		$(this).hide().attr("disabled", "disabled");
		show_loader( "SAVING CHANGES..." );

		// insert hidden form fields for selected profiles
		selectedProfilesUpdate();
		$("input[name=save_profiles]").val( "true" );

		DataForm.command.value = 'svData';
		DataForm.submit();
	});

	function selectedProfilesUpdate() {
		var paSpan = document.getElementById("profileAccess");
	  	var selectedRows = gridOptions.api.getSelectedRows();
	  	selectedRows.forEach( function(selectedRow, index) {
			var pa = document.createElement("input"); //input element, Submit button
			pa.setAttribute('type',"hidden");
			pa.setAttribute('name',"Allow_Access_"+selectedRow.ID);
			pa.setAttribute('value',"1");
			paSpan.appendChild(pa);
	    });
	}

	setTimeout("$('a#save_changes').show();", 500);
 
<cfif( qGetPlannerTemplate.Is_Locked EQ 0 OR ((qGetPlannerTemplate.Is_Locked EQ 1) AND (qGetPlannerTemplate.Locked_By_User_ID NEQ request.AccessStructure.User_ID)))>
	 $("input[type=text], select, textarea").attr("disabled", true).addClass("disabled");
	 $("input[type=radio]").attr("disabled", true);
 	 $("input[type=checkbox]").attr("disabled", true);
	 $("a#save_changes").attr("disabled", true).addClass("disabled");
</cfif>
</script>

</BODY>
</html>
