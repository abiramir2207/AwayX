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

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfif businessSegManager.isEnabled() eq 1 and form.programID neq "" >
	<cfset progBusSegId = businessSegManager.getSegmentIdByProgram(form.programID) />
</cfif>
<cfset templateFilterProgramID = form.programID /><!--- D34317 Incorrect group items in pop-up --->
<!---if showProgramItems is 0 then clear url.Program_ID because we don't want to get groups items based on the program--->
<cfif form.showProgramItems eq 0>
	<cfset form.programID = "" />
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
							producttype_id = url.producttype_id) />
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

</cfsilent>

<table border="0" cellpadding="2" cellspacing="2" widtd="700">
		<tr style="font-size: 14px; font-weight:bold; background-color: orange">
			<td widtd="10px">&nbsp;</td>
			<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
			<td>	<cfoutput>#application.returned_customer_setting.item_label#</cfoutput> #</td>
			</cfif>
			<cfif (application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string) AND application.returned_customer_setting.upc_switch EQ 1>
			<td><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></td>
			</cfif>
			<td>Description</td>
		</tr>
		<tr style="font-size: 14px; font-weight:bold;">
			<td colspan="2"><cfoutput>#qGetGroupID#: #qGetGroupDesc# (#qGetItemsInGroup.RecordCount# products)</cfoutput></td>
		</tr>
		<cfif qGetItemsInGroup.RecordCount eq 0>
			<tr>
				<td colspan="100%" align="center">there are no products for tdis group</td>
			</tr>
		<cfelse>
		<cfoutput query="qGetItemsInGroup">
			<tr <cfif #qGetItemsInGroup.CurrentRow# MOD 2>style="background-color: c6ffc6"</cfif>>
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
		</cfif>
</table>