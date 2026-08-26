<!DOCTYPE html>
<cfoutput>
<html>
<head>
	<title>Group Items</title>
	<cfsavecontent variable="head_content">
		<cfset jQueryUI.widgets = "tooltip">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/styles/css-loader.css">
		<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /script/javascript/default.js" />
		<cf_include files="/common_files/datatable.css">
		<style>
		title { display:block; }
		div.title { font-size:14px; font-weight:bold; }
		div.group { margin:5px; }
		span.group { color: ##818152; font-size: 14px; font-weight: bold; letter-spacing:0.25px; }
		table.datagrid { margin-bottom: 15px; }
		th { height:20px; }
		td { height:18px; }
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<cfsilent>
<cfparam name="url.Group_ID" default="" />
<cfparam name="form.Group_ID" default="#url.Group_ID#" />
<cfparam name="url.Group_Level_ID" default="" />
<cfparam name="form.Group_Level_ID" default="#url.Group_Level_ID#" />
<cfparam name="url.program_ID" default="" />
<cfparam name="url.programID" default="#url.program_ID#" />
<cfparam name="form.programID" default="#url.programID#" />
<cfparam name="url.showProgramItems" default="0" />
<cfparam name="form.showProgramItems" default="#url.showProgramItems#" />
<cfparam name="ShowTitles" default="1" />
<cfparam name="url.producttype_id" default="">
<cfparam name="progBusSegId" default="">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="StartRow" default="1">
<cfparam name="frompage" default="1">
<cfparam name ="URL.populateMembers" default="0">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset prodManager = CreateObject("component", "components.products.ProductManager").init()>

<cfif businessSegManager.isEnabled() eq 1 and form.programID neq "" >
	<cfset progBusSegId = businessSegManager.getSegmentIdByProgram(form.programID) />
</cfif>
<cfset templateFilterProgramID = form.programID /><!--- D34317 Incorrect group items in pop-up --->
<!---if showProgramItems is 0 then clear url.Program_ID because we don't want to get groups items based on the program--->
<cfif form.showProgramItems eq 0>
	<cfset form.programID = "" />
</cfif>

<!--- When "update membership" link is clicked. --->
<cfif URL.populateMembers eq 1>
	<cfset prodManager.populateProductGroupMembers(url.programID)>
</cfif>

	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#url.programID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#url.programID#'
	</cfquery>
</cfif>

	<cfif isDefined("GetContractInfo.ProgramType_ID") and GetContractInfo.RecordCount GTE 1>
	  <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id,fixed_rebate_grid_option"
			}), "first_parent_id,fixed_rebate_grid_option"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID,Fixed_Rebate_Grid_Option
	    FROM Program_Control_Panel_Options
	    WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
	  </cfquery>
</cfif>
	</cfif>
	<cfif isDefined("GetTemplateInfo.First_parent_ID") and GetTemplateInfo.RecordCount GTE 1>
		<cfset varFirstParentID = GetTemplateInfo.First_parent_ID />
	<cfelse>
		<cfset varFirstParentID = 0 />
	</cfif>
<!---initialize group data manager--->
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset qGetGroup = GroupDataManager.getByProductGroupData(prodGroupLevelId=form.Group_Level_ID, prodGroupId=form.Group_ID,FirstParentID=varFirstParentID) />
<cfset qGetGroupDesc = qGetGroup.Group_Level_Desc />
<cfset qGetGroupID = "" />
<cfif isDefined("qGetGroup.Group_ID")>
	<cfset qGetGroupID = qGetGroup.Group_ID />
</cfif>
<cfset useCacheQuery = 1 />
<cfif form.programID NEQ "">
	<cfset useCacheQuery = 0 />
</cfif>

	<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND varFirstParentID NEQ 0>
		<cfset qGetItemsInGroup = GroupDataManager.getItemsInMultiAttrGroup(
							ProductGroupId = form.Group_ID,
							TemplateId = varFirstParentID,
							programId = form.programID,
							producttype_id = url.producttype_id) /> <!--- D35295 Multiple Product Attr Groups defined in Template Allow_In_Group_Search --->
					<!---<cfdump var="#qGetItemsInGroup#"/><cfabort>--->
	<CFELSE>

		<cfset qGetItemsInGroup = GroupDataManager.getItemsInGroup(
							groupId = form.Group_ID,
							groupLevelId = form.Group_Level_ID,
							programId = form.programID,
							producttype_id = url.producttype_id,
							cacheQuery = useCacheQuery,
							ItemBusSegID = progBusSegId,
							templateFiltePRogramID = templateFilterProgramID) /><!--- D34317 Incorrect group items in pop-up --->
	</cfif>

<cf_Number_of_Rows maxrows=15>
<Cfif ShowTitles IS 0><cfset MAXROWS = 1000 /></cfif>
</cfsilent>
<body>
<script>
	function callPopulateMembers()
	{
		disableButton('grpMembers', true, false);
		show_loader("UPDATING MEMBERSHIP, PLEASE WAIT...");
		window.location.href='group_items.cfm?populateMembers=1&programID=#url.programId#&showProgramItems=1&producttype_id=#url.producttype_id#&Group_Level_ID=#url.Group_Level_ID#&Group_ID=#url.Group_ID#';
	}
</script>

<cfif url.programID neq "" AND URL.showProgramItems eq 1 AND URL.Group_ID neq "" AND url.Group_Level_ID neq 0>
	<div id="grpMembers" style="font-size:8px;">
		Click <a href="javascript:void();" onClick="callPopulateMembers()">#application.util.string.actionLinkFormat("update membership")#</a> to update the membership for this program. 
		<br /><br /><span style="font-style:italic">Note:</b> **The standard nightly job will not update membership for expired status programs.  This link allows you to manually update the membership.**
	</div>
<br />
</cfif>

<!--- Search page using keyword(s). --->
<CFINCLUDE TEMPLATE="/includes/Search_on_Page.cfm">
<br />
<Cfif ShowTitles IS 1><div class="page_title1">Group Items</div></cfif>
<div class="group">
	<span class="group">#qGetGroupID#: #qGetGroupDesc# </span>
	<span class="count">(#qGetItemsInGroup.RecordCount# products)</span>
</div>
</cfoutput>

<FORM action=""  NAME="MyForm" ID="MyForm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<table border="0" cellpadding="1" cellspacing="0" class="datagrid" width="700">
	<thead>
		<tr>
			<th width="10px">&nbsp;</th>
		<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
			<th>	<cfoutput>#application.returned_customer_setting.item_label#</cfoutput> #</th>
		</cfif>
		<cfif (application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string) AND application.returned_customer_setting.upc_switch EQ 1>
			<th><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></th>
		</cfif>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<cfif qGetItemsInGroup.RecordCount eq 0>
			<tr>
				<td colspan="100%" align="center">There are no products for this group</td>
			</tr>
		</cfif>
		<cfoutput query="qGetItemsInGroup">
			<tr>
				<td>#qGetItemsInGroup.CurrentRow#</td>
			<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
				<td>#qGetItemsInGroup.item#</td>
			</cfif>
			<cfif (application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string) AND application.returned_customer_setting.upc_switch EQ 1>
				<td>#qGetItemsInGroup.upc#</td>
			</cfif>
				<td>#qGetItemsInGroup.description#</td>
			</tr>
		</cfoutput>
	</tbody>
</table>
<Cfif ShowTitles IS 1>
	<cfoutput><a onclick="parent.dhx_window_close ? parent.dhx_window_close() : window.parent.close();">#application.util.string.linkFormat("close")#</a></cfoutput>
</cfif>

<cfoutput>
<INPUT TYPE="Hidden" NAME="Group_ID" VALUE="#form.Group_ID#">
<INPUT TYPE="Hidden" NAME="Group_Level_ID" VALUE="#form.Group_Level_ID#">
<INPUT TYPE="Hidden" NAME="programID" VALUE="#form.programID#">
<INPUT TYPE="Hidden" NAME="showProgramItems" VALUE="#form.showProgramItems#">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
</cfoutput>
</FORM>

<script>
	jQuery('tbody').on('hover', 'tr', function() { jQuery(this).toggleClass("over"); });
	//console.log(window.opener)
	//console.log(parent.windows.window(999))
</script>
</body>
</html>