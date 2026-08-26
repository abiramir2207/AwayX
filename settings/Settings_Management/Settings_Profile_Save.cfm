
<cfset useLakebaseForSetAllToShow = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("settings_list")>
<cfif useLakebaseForSetAllToShow>
	<cftry>
		<cfset application.oLakebase.updateRows("settings_list",
			{
				"setting_type" = "eq.Profile"
			},
			{
				"setting_display_value" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSetAllToShow = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSetAllToShow>
<cfquery name="SetAllToShow" datasource="#application.datasource#">
	update Settings_List
	set Setting_Display_Value = 1
	where Setting_Type = 'Profile'		
</cfquery>
</cfif>

<cfset useLakebaseForgetDefaultForm = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("settings_list")>
<cfif useLakebaseForgetDefaultForm>
	<cftry>
		<cfset getDefaultForm = application.oLakebase.toQuery(
			application.oLakebase.selectRows("settings_list", {
				"setting_type" = "eq.Profile",
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
	where Setting_Type = 'Profile'
	order by Setting_Name
</CFQUERY>
</cfif>

<cfoutput query = getDefaultForm>
	<cfparam name="Form.#getDefaultForm.Setting_Name#"  default="1">
</cfoutput>

<!---  reinsert settings with 0 (hide value) to Settings_Template_Display table---> 
<cfoutput>
<cfloop query = "getDefaultForm">
	<CFSET ValueFormField = evaluate("FORM.#getDefaultForm.Setting_Name#")>

	<cfif ValueFormField eq 0>
		<CFQUERY NAME="update_#getDefaultForm.Setting_Name#" datasource="#application.datasource#">
			update Settings_List
			set Setting_Display_Value = 0
			where Setting_Name = '#getDefaultForm.Setting_Name#'
			and Setting_Type = 'Profile'
		</CFQUERY>
	</cfif>
</cfloop>
</cfoutput>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!---Approval Method - #Approval_Method_Name# --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset AvailableApprovalOptions = genSettingsManager.getApprovalTypeList()>
<CFLOOP INDEX="ThisApprovalType" list="#AvailableApprovalOptions#">
	<CFIF ThisApprovalType NEQ 3 AND ThisApprovalType NEQ 5 AND ThisApprovalType NEQ 6 AND ThisApprovalType NEQ 7>
		<cfquery name="DeleteApprovalType" datasource="#application.datasource#">
			delete from Settings_List_Group_Approval_Type
			where ApprovalType = #ThisApprovalType#
		</cfquery>
		<CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">
			<cfparam name="Form.Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile" default="1">
			<cfset Approval_TypeFieldValue = Evaluate("Form.Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile")>
			<cfquery name="DeleteApprovalType" datasource="#application.datasource#">
				INSERT INTO Settings_List_Group_Approval_Type (ApprovalType,Group_Labels_Approval_Group_Count,Setting_Display_Value)
				VALUES(#ThisApprovalType#,#GroupCount#,#Approval_TypeFieldValue#)
			</cfquery>
		</CFLOOP>
	</CFIF>

	<CFIF ThisApprovalType EQ 4>
		<cfif appSettings.getApproveLSComponentByProfile() NEQ 1>
			<cfquery name="GetLumpSums" datasource="#application.datasource#">
				SELECT *
				FROM Program_Lump_Sum_Name
				WHERE Deleted = 0
				AND Active = 1
			</cfquery>
			<cfloop query="GetLumpSums">
				<cfset lsNameID = GetLumpSums.Program_Lump_Sum_Name_ID>
				<cfparam name="Form.Program_LSN_#lsNameID#" default="1">
 				<cfset FieldValue = Evaluate("Form.Program_LSN_#lsNameID#")>
				<cfset useLakebaseForUpdateLumpSums = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForUpdateLumpSums>
	<cftry>
		<cfset application.oLakebase.updateRows("program_lump_sum_name",
			{
				"program_lump_sum_name_id" = "eq.#GetLumpSums.Program_Lump_Sum_Name_ID#"
			},
			{
				"setting_display_value" = "#FieldValue#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateLumpSums = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateLumpSums>
<cfquery name="UpdateLumpSums" datasource="#application.datasource#">
					update Program_Lump_Sum_Name
					set Setting_Display_Value = #FieldValue#
					where 	Program_Lump_Sum_Name_ID = #GetLumpSums.Program_Lump_Sum_Name_ID#
				</cfquery>
</cfif>
			</cfloop>
		</cfif>
	</CFIF>
</CFLOOP>

<!------ Post Approval Status ----->
<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
	<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
	<cfset qGetProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getProgramPostApprovalStatus() />
	<cfloop query="qGetProgramPostApprovalStatus">
		<cfset ProgramPostApprovalStatusID = qGetProgramPostApprovalStatus.Program_Post_Approval_Status_ID>
		<cfparam name="Form.ProfileProgramPostApprovalStatus_#ProgramPostApprovalStatusID#" default="1">
		<cfset FieldValueProgramPostApprovalStatus = Evaluate("Form.ProfileProgramPostApprovalStatus_#ProgramPostApprovalStatusID#")>
		<cfset useLakebaseForUpdateProgramPostApprovalStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_post_approval_status")>
<cfif useLakebaseForUpdateProgramPostApprovalStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("program_post_approval_status",
			{
				"program_post_approval_status_id" = "eq.#qGetProgramPostApprovalStatus.Program_Post_Approval_Status_ID#"
			},
			{
				"setting_display_value" = "#FieldValueProgramPostApprovalStatus#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateProgramPostApprovalStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateProgramPostApprovalStatus>
<cfquery name="UpdateProgramPostApprovalStatus" datasource="#application.datasource#">
			update Program_Post_Approval_Status
			set Setting_Display_Value = #FieldValueProgramPostApprovalStatus#
			where 	Program_Post_Approval_Status_ID = #qGetProgramPostApprovalStatus.Program_Post_Approval_Status_ID#
		</cfquery>
</cfif>
	</cfloop>
</cfif>	

<cfset UseCustomerType = appSettings.getCustomertype()>
<cfif UseCustomerType IS 1>
	<cfset useLakebaseForGetCustomerTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_type")>
<cfif useLakebaseForGetCustomerTypes>
	<cftry>
		<cfset GetCustomerTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_type", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCustomerTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCustomerTypes>
<cfquery name="GetCustomerTypes" datasource="#application.datasource#">
		SELECT *
		FROM Customer_Type
		WHERE Deleted = 0
	</cfquery>
</cfif>
	<CFLOOP query="GetCustomerTypes">
		<cfset j = GetCustomerTypes.customer_type_id>
		<cfparam name="Form.Customer_Type_#j#" default="1">
		<cfset FieldValueGetCustomerTypes = Evaluate("Form.Customer_Type_#j#")>
		<cfset useLakebaseForUpdateCustomer_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_type")>
<cfif useLakebaseForUpdateCustomer_Type>
	<cftry>
		<cfset application.oLakebase.updateRows("customer_type",
			{
				"customer_type_id" = "eq.#j#"
			},
			{
				"setting_display_value" = "#FieldValueGetCustomerTypes#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateCustomer_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateCustomer_Type>
<cfquery name="UpdateCustomer_Type" datasource="#application.datasource#">
			update Customer_Type
			set Setting_Display_Value = #FieldValueGetCustomerTypes#
			where 	customer_type_id = #j#
		</cfquery>
</cfif>
	</CFLOOP>
</cfif>

<!---start :: update show/hide 'Hide #DD_Status_Description#' on deduction profile settings --->
<cfquery name="getDD_Status_list" datasource="#application.datasource#">
	Select DD_Status_ID, DD_Status_Description,Setting_Display_Value FROM DD_Status
	WHERE
	<CFIF application.returned_customer_setting.DD_Show_Rebill NEQ 1>
	DD_Status_ID <> 7 AND
	</CFIF>
	<CFIF appSettings.getDDAllowNegativeAmountCredits() NEQ 1>
	DD_Status_ID NOT IN (8,9) AND
	</CFIF>
	<cfif appSettings.getDD_Show_Delete() NEQ 1>
	DD_Status_ID <> 6 AND
	</cfif>
	1 = 1
	ORDER BY DD_Status_Order
</cfquery>
<cfloop query="getDD_Status_list">
	<cfset DD_Status_ID = getDD_Status_list.DD_Status_ID>
	<cfparam name="Form.DD_Status_#DD_Status_ID#" default="1">
	<cfset FieldValueDD_Status = Evaluate("Form.DD_Status_#DD_Status_ID#")>
	<cfquery name="UpdateDD_Status" datasource="#application.datasource#">
			update DD_Status
			set Setting_Display_Value = #FieldValueDD_Status#
			where 	DD_Status_ID = #DD_Status_ID#
	</cfquery>
</cfloop>
<!---end :: update show/hide 'Hide #DD_Status_Description#' on deduction profile settings --->

<cfquery name="UpdateGeneral_Settings" datasource="#application.datasource#">
	update general_Settings
	set 	Settings_Management_Updated_Date = #Now()#,
		Settings_Management_Profiles_Updated_Date = #Now()#,
		Settings_Management_Updated_By = '#request.AccessStructure.User_ID#', 
		Settings_Management_Profiles_Updated_By ='#request.AccessStructure.User_ID#'
</cfquery>

<!--- Operating Group
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset profileRestrictionLevel 			= operatingGroupManager.getProfileRestrictionLevel() />
	<cfset profileRestrictionLevelLabel 	= operatingGroupManager.getLabel(profileRestrictionLevel) />
	<cfset qOperatingGroupProfileSettings 	= operatingGroupManager.getOperatingGroupProfileSettings(profileRestrictionLevel)>
</cfif>
--->

<CFLOCATION URL="settings_management.cfm?Generic_Type=#Form.Generic_Type#">
