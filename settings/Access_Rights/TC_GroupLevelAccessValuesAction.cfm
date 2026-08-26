<!-----------------------------------------------------------------------------

FILE NAME:		TC_GroupLevelAccessValuesAction.cfm
DESCRIPTION:		 
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	10-Sep-2015	 Created

------------------------------------------------------------------------------> 
<!--- <cfdump var="#form#">   --->

<!------ groupLevelAccessValuesAction.cfm ----->
<cfparam name="Form.Profile_ID_List" 	default="0">
<cfparam name="Form.Group_ID_List" 	default="">
<cfparam name="form.approvalGroupType_tableName" default= "type_code_desc">
<cfparam name="form.approvalGroupType_IDfield" default= "type_code_desc_id">

<!------ delete all   ----->

<cfquery name="qDeleteAll" datasource="#application.datasource#">
 	DELETE	FROM	Group_Approval_Rights
	WHERE	User_Profile_Id IN (#Form.Profile_ID_List#)
	AND	Group_Approval_Rights.Group_ID IN (#PreserveSingleQuotes(Form.Group_ID_List)#)
</cfquery>

<cfset Group_ID_List_No_Quotes = Replace(Form.Group_ID_List, "'", "", "ALL")>
<cfloop list="#Form.Profile_ID_List#" index="ProfileId">
	<cfloop list="#Group_ID_List_No_Quotes#" index="Group_ID">
		<cfset groupIdFieldName = ReplaceNoCase(Group_ID, "-", "_", "all") & "_pro_" & ProfileId >
		<cfparam name="Form.Group_Approve_#groupIdFieldName#" 	default="0">
		<cfparam name="Form.Group_Approve_Margin_#groupIdFieldName#" 	default="0">
		<cfparam name="Form.Group_Approve_Spend_#groupIdFieldName#" 	default="0">
	
		<cfset groupApprove = Evaluate("Form.Group_Approve_#groupIdFieldName#")>
		<cfset groupApproveMargin = Evaluate("Form.Group_Approve_Margin_#groupIdFieldName#")>
		<cfset groupApproveSpend = Evaluate("Form.Group_Approve_Spend_#groupIdFieldName#")>
		
		<cfif groupApprove EQ 1 AND NOT isNumeric(groupApproveMargin) AND groupApproveMargin NEQ "*">
			<cfset groupApproveMargin = 0>
		</cfif>
		
		<!------ Insert ----->
		<cfset useLakebaseForqInsertGroupAccessApprove = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_approval_rights")>
<cfif useLakebaseForqInsertGroupAccessApprove>
	<cftry>
		<cfset application.oLakebase.insertRow("group_approval_rights", {
			"user_profile_id" = "#ProfileID#",
			"group_id" = "#Group_ID#",
			"group_type" = "#application.returned_customer_setting.approval_on_type_code#",
			"group_id_approval" = "#groupApprove#",
			"group_id_margin" = "#groupApproveMargin#",
			"group_id_spend_dollar" = "#groupApproveSpend#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertGroupAccessApprove = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertGroupAccessApprove>
<cfquery name="qInsertGroupAccessApprove" datasource="#application.datasource#">
			INSERT INTO Group_Approval_Rights 
			(
				User_Profile_Id, 
				Group_ID, 
				Group_type, 
				Group_ID_Approval,
				Group_ID_Margin,
				Group_ID_Spend_Dollar
			)
			VALUES 
			(
				#ProfileID#, 
				'#Group_ID#', 
				#application.returned_customer_setting.approval_on_type_code#, 
				#groupApprove#,
				'#groupApproveMargin#',
				'#groupApproveSpend#'
			)
		</cfquery>
</cfif>

	</cfloop>
</cfloop>

<cfquery name="UpdateGeneralInformation" datasource="#application.datasource#">
		UPDATE Profiles_Settings
		SET Last_Changed_Date		= getdate(),
		    Last_Changed_User_ID	= '#request.accessStructure.User_ID#'		
</cfquery>

<script language="JavaScript">
	window.close();
</script>