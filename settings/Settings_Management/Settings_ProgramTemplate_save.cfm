<!----
/settings/Settings_Management/Settings_ProgramTemplate_save.cfm
Created By: Jianxiu
Created On: Sep 10, 2010
Modified By: 
Last Modified On: 
--->

<cfset SettingIDManager = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").init() />
<cfset SettingID = SettingIDManager.getSettingIDs()>

<cfparam name="Form.Generic_Type" 					default="0">
<cfparam name="Form.Generic_Type_ID" 					default="0">
<cfparam name="Form.Created_Type" 					default="1">
<cfparam name="Form.Program_Description" 				default="1">
<cfparam name="Form.Created_Type" 	default="">
<cfset sBasicInfo  ="">
<cfset SettingsInCFMPage  ="create_edit.cfm">

<cfset useLakebaseForgetDefaultForm = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("settings_list")>
<cfif useLakebaseForgetDefaultForm>
	<cftry>
		<cfset getDefaultForm = application.oLakebase.toQuery(
			application.oLakebase.selectRows("settings_list", {
				"setting_type" = "eq.Template",
				"order" = "setting_name.asc",
				"select" = "setting_name"
			}), "setting_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDefaultForm = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDefaultForm>
<CFQUERY NAME="getDefaultForm" datasource="#application.datasource#">
	select Setting_Name
	from settings_list
	where setting_Type = 'Template'
	order by Setting_Name
</CFQUERY>
</cfif>

<cfoutput query = getDefaultForm>
	<cfparam name="Form.#getDefaultForm.Setting_Name#"  default="1">
</cfoutput>

<cfoutput>
<!--- Copy Settings_Template_Display to Settings_Template_Display_History  ---> 
<cfquery name="CopyOverToHistory" datasource="#application.datasource#">
	insert into  Settings_Template_Display_History(Settings_Template_Display_ID,Generic_Type,Generic_Type_ID,Setting_Display_Value,Deleted,Deleted_Date,Excluded_First_Parent_ID,Updated_Date,Updated_By,SettingsInCFMPage)
	select 	Settings_Template_Display_ID,Generic_Type,Generic_Type_ID,Setting_Display_Value,Deleted,Deleted_Date,Excluded_First_Parent_ID,Updated_Date,Updated_By,SettingsInCFMPage
	from 	Settings_Template_Display
	where 	Generic_Type = '#Form.Generic_Type#'
</cfquery>

<!--- Keep the value of exceptions  ---> 
<cfquery name="ResetDeletedValue" datasource="#application.datasource#">
	delete from  Settings_Template_Display
	where 	Generic_Type = '#Form.Generic_Type#'
	and	Excluded_First_Parent_ID IS NULL
	and 	Setting_ID in (select Setting_ID from Settings_List where Setting_Type like '%Template%' and TemplatePageSequence <> 2)
</cfquery>

<!--- start:: reinsert settings with 0-hide value to Settings_Template_Display table---> 
<cfoutput>
<cfloop query = "getDefaultForm">
	<CFSET ValueFormField = evaluate("FORM.#getDefaultForm.Setting_Name#")>
	<cfif ValueFormField eq 0 >
		<CFSET ValueSettingID = evaluate("SettingID.#getDefaultForm.Setting_Name#")>
		<CFQUERY NAME="update_#getDefaultForm.Setting_Name#" datasource="#application.datasource#">
			INSERT INTO Settings_Template_Display
			(Generic_Type,Setting_ID,Setting_Display_Value,SettingsInCFMPage)
			VALUES
			('#Form.Generic_Type#',#ValueSettingID#,0,'create_edit.cfm')
		</CFQUERY>
	</cfif>
</cfloop>
</cfoutput>
<!--- end::reinsert settings with 0-hide value to Settings_Template_Display table---> 

<!--- update the updated by info --->			
<cfset useLakebaseForUpdate_Updated_By = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("settings_template_display")>
<cfif useLakebaseForUpdate_Updated_By>
	<cftry>
		<cfset application.oLakebase.updateRows("settings_template_display",
			{
				"generic_type" = "eq.#Form.Generic_Type#",
				"excluded_first_parent_id" = "is.null"
			},
			{
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Updated_By = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Updated_By>
<cfquery name="Update_Updated_By" datasource="#application.datasource#">
	update Settings_Template_Display
	set Updated_By = '#request.AccessStructure.User_ID#' 
	where 	Generic_Type = '#Form.Generic_Type#'
	and	Excluded_First_Parent_ID IS NULL
</cfquery>
</cfif>

<!--- update the last updated by info --->			
<cfquery name="GetGenericTypeID" datasource="#application.datasource#">
	SELECT ISNULL(Generic_Type_ID, 0) as Generic_Type_ID
	FROM Generic_Type
	WHERE Generic_Type = '#Form.Generic_Type#'
	AND Settings_Management =1
</cfquery>

<cfquery name="UpdateChangedBy" datasource="#application.datasource#">
	update general_Settings
	set 	Settings_Management_Updated_Date = #Now()#
		,Settings_Management_Updated_By = '#request.AccessStructure.User_ID#' 
	<cfif #GetGenericTypeID.Generic_Type_ID# eq "1">
		,Settings_Management_Distributor_Updated_Date = #Now()#
		,Settings_Management_Distributor_Updated_By = '#request.AccessStructure.User_ID#' 
	<cfelseif #GetGenericTypeID.Generic_Type_ID# eq "2">
		,Settings_Management_FieldExe_Updated_Date = #Now()#
		,Settings_Management_FieldExe_Updated_By = '#request.AccessStructure.User_ID#' 
	<cfelseif #GetGenericTypeID.Generic_Type_ID# eq "3">
		,Settings_Management_OperatorHQ_Updated_Date = #Now()#
		,Settings_Management_OperatorHQ_Updated_By = '#request.AccessStructure.User_ID#' 
	<cfelseif #GetGenericTypeID.Generic_Type_ID# eq "4">
		,Settings_Management_OperatorDP_Updated_Date = #Now()#
		,Settings_Management_OperatorDP_Updated_By = '#request.AccessStructure.User_ID#' 
	<cfelseif #GetGenericTypeID.Generic_Type_ID# eq "8">
		,Settings_Management_Brokerage_Updated_Date = #Now()#
		,Settings_Management_Brokerage_Updated_By = '#request.AccessStructure.User_ID#' 
	<cfelseif #GetGenericTypeID.Generic_Type_ID# eq "9">
		,Settings_Management_LumpAutoPay_Updated_Date = #Now()#
		,Settings_Management_LumpAutoPay_Updated_By = '#request.AccessStructure.User_ID#' 
	</cfif>		
</cfquery>
	<CFLOCATION URL="settings_management.cfm?Generic_Type=#Form.Generic_Type#">
</cfoutput>

