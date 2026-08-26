<!----
/settings/Settings_Management/Settings_ProgramTemplate_SecPage_Save.cfm
Created By: Jianxiu
Created On: Sep 10, 2010
Modified By: 
Last Modified On: 
--->

<cfset SettingIDManager = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").init() />
<cfset SettingID = SettingIDManager.getSettingIDs(TemplatePageSequence=2)>

<cfparam name="Form.Generic_Type" 					default="0">
<cfparam name="Form.Generic_Type_ID" 					default="0">
<cfparam name="Form.Created_Type" 					default="1">
<cfparam name="Form.Program_Description" 				default="1">
<cfparam name="Form.Created_Type" 					default="">
<cfset sBasicInfo  ="">
<cfset SettingsInCFMPage  ="secondpage.cfm">


<CFQUERY NAME="getDefaultForm" datasource="#application.datasource#">
	select Setting_Name
	from settings_list
	where TemplatePageSequence = 2
	order by Setting_Name
</CFQUERY>

<cfoutput query = getDefaultForm>
	<cfparam name="Form.#getDefaultForm.Setting_Name#"  default="1">
</cfoutput>

<cfoutput>
<!--- Copy Settings_Template_Display to Settings_Template_Display_History  ---> 
<cfquery name="CopyOverToHistory" datasource="#application.datasource#">
	insert into  Settings_Template_Display_History(Settings_Template_Display_ID,Generic_Type,Generic_Type_ID,Setting_Display_Value,Deleted,Deleted_Date,Excluded_First_Parent_ID,Updated_Date,Updated_By,SettingsInCFMPage)
	select 	Settings_Template_Display_ID,Generic_Type,Generic_Type_ID,Settings_Template_Display.Setting_Display_Value,Settings_Template_Display.Deleted,Deleted_Date,Excluded_First_Parent_ID,Updated_Date,Updated_By,SettingsInCFMPage
	from 	Settings_Template_Display
	inner join Settings_List on Settings_Template_Display.Setting_ID = Settings_List.Setting_ID and TemplatePageSequence = 2
	where 	Generic_Type = '#Form.Generic_Type#'
</cfquery>

<!--- Keep the value of exceptions  ---> 
<cfquery name="ResetDeletedValue" datasource="#application.datasource#">
	delete from  Settings_Template_Display
	where	Generic_Type = '#Form.Generic_Type#'
	and	Excluded_First_Parent_ID IS NULL
	and 	Setting_ID in (select Setting_ID from Settings_List where TemplatePageSequence = 2)
</cfquery>

<!--- start:: reinsert settings with 0-hide value to Settings_Template_Display table---> 
<cfoutput>
<cfloop query = "getDefaultForm">
	<CFSET ValueFormField = evaluate("FORM.#getDefaultForm.Setting_Name#")>
	<cfif ValueFormField eq 0 >
		<CFSET ValueSettingID = evaluate("SettingID.#getDefaultForm.Setting_Name#")>
		<CFQUERY NAME="update_#getDefaultForm.Setting_Name#" datasource="#application.datasource#">
			INSERT INTO Settings_Template_Display
			(Generic_Type,Setting_ID,Setting_Display_Value,Updated_By,SettingsInCFMPage)
			VALUES
			('#Form.Generic_Type#',#ValueSettingID#,0,'#request.AccessStructure.User_ID#','secondpage.cfm')
		</CFQUERY>
	</cfif>
</cfloop>
</cfoutput>
<!--- end::reinsert settings with 0-hide value to Settings_Template_Display table---> 

<cfif Form.Generic_Type IS NOT "Distributor Off-Invoice" AND Form.Generic_Type NEQ "LSAutoPay">
	<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
		SELECT 	*
		FROM 	Payment_Paid_To_Types
		WHERE 	Deleted = 0
	</cfquery>
	<CFLOOP query="GetPaymentPaidToTypes">
		<cfparam name="Form.Payment_Paid_To_Type_#Payment_Paid_To_ID#" default="1">
		<cfset FieldValuePaymentPaidToTypes = Evaluate("Form.Payment_Paid_To_Type_#Payment_Paid_To_ID#")>
		<cfquery name="UpdatePaymentPaidToTypes" datasource="#application.datasource#">
			update 	Payment_Paid_To_Types
			set 	Setting_Display_Value = #FieldValuePaymentPaidToTypes#
			where 	Payment_Paid_To_ID= #Payment_Paid_To_ID#
		</cfquery>
	</CFLOOP>
</cfif>

<cfif NOT ListFindNoCase("Distributor Off-Invoice,Bid Request,USDA NOI", Form.Generic_Type)>
	<cfquery name="GetProgramPerfReq" datasource="#application.datasource#">
		SELECT 	*
		FROM 	Program_Perf_Req
		WHERE 	Deleted = 0
	</cfquery>
	<CFLOOP query="GetProgramPerfReq">
		<cfparam name="Requirement_#Program_Perf_Req_ID#" default="1">
		<cfset FieldValueProgramPerfReq = Evaluate("Form.Requirement_#Program_Perf_Req_ID#")>
		<cfquery name="UpdateProgramPerfReq" datasource="#application.datasource#">
			update 	Program_Perf_Req
			set 	Setting_Display_Value = #FieldValueProgramPerfReq#
			where 	Program_Perf_Req_ID= #GetProgramPerfReq.Program_Perf_Req_ID#
		</cfquery>
	</CFLOOP>
</cfif>

<cfquery name="GetProgramQualifications" datasource="#application.datasource#">
	SELECT  SettingsManagement_ID
	FROM Program_Qualifications
	WHERE 	Deleted = 0
	AND 	IsActive = 1
</cfquery>
<CFLOOP query="GetProgramQualifications">
	<cfparam name="Form.Program_Qualifications_#SettingsManagement_ID#" default="1">
	<cfset FieldValueProgramQualifications = Evaluate("Form.Program_Qualifications_#SettingsManagement_ID#")>
	<cfquery name="UpdatePQ_#SettingsManagement_ID#" datasource="#application.datasource#">
		update 	Program_Qualifications
		set 	Setting_Display_Value = #FieldValueProgramQualifications#
		where 	SettingsManagement_ID= #SettingsManagement_ID#
	</cfquery>
</CFLOOP>
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
	<CFLOCATION URL="settings_management.cfm?Generic_Type=#Form.Generic_Type#&tabHeader=2">
</cfoutput>

