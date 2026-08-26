<!------ groupLevelAccessValuesAction.cfm ----->
<cfparam name="Form.Profile_ID" 	default="0">
<cfparam name="Form.Group_ID_List" 	default="">
<cfparam name="form.approvalGroupType_tableName" default= "type_code_desc">
<cfparam name="form.approvalGroupType_IDfield" default= "type_code_desc_id">

<!------ delete all ----->

<cfquery name="qDeleteAll" datasource="#application.datasource#">
	DELETE
	FROM	Group_Approval_Rights
	WHERE	User_Profile_Id IN (#Form.Profile_ID#)
	AND	Group_Approval_Rights.Group_ID IN(
				SELECT	#form.approvalGroupType_tableName#.#form.approvalGroupType_IDfield#
				FROM	#form.approvalGroupType_tableName#
				WHERE	#form.approvalGroupType_tableName#.deleted = 0
			)
<!----- we do not want to delete entries for deleted = 1 groups,
because it is possible for products to belong to a deleted = 1 group, and we need the apporval rights for some one to agree/approve that product/group ----->
</cfquery>

<cfloop list="#Form.Profile_Id#" index="ProfileId">
<cfloop list="#Form.Group_ID_List#" index="Group_ID">
	<cfset groupIdFieldName = ReplaceNoCase(Group_ID, "-", "_", "all")>
	<cfparam name="Form.Group_Approve_#groupIdFieldName#" 	default="0">
	<cfparam name="Form.Group_Approve_Margin_#groupIdFieldName#" 	default="0">
	<cfparam name="Form.Group_Approve_Spend_#groupIdFieldName#" 	default="0">
	<cfparam name="Form.Group_Approve_Margin_Oper_#groupIdFieldName#" 	default="0">
	<cfparam name="Form.Group_Approve_List_Price_#groupIdFieldName#" 	default="0">

	<cfset groupApprove = Evaluate("Form.Group_Approve_#groupIdFieldName#")>
	<cfset groupApproveMargin = Evaluate("Form.Group_Approve_Margin_#groupIdFieldName#")>
	<cfset groupApproveMarginOper = Evaluate("Form.Group_Approve_Margin_Oper_#groupIdFieldName#")>
	<cfset groupApproveSpend = Evaluate("Form.Group_Approve_Spend_#groupIdFieldName#")>
	<cfset groupApproveListPrice = Evaluate("Form.Group_Approve_List_Price_#groupIdFieldName#")>

	<cfif groupApprove EQ 1 AND NOT isNumeric(groupApproveMargin) AND groupApproveMargin NEQ "*">
		<cfset groupApproveMargin = 0>
	</cfif>

	<!------ iNsert ----->
	<cfset useLakebaseForqInsertGroupAccessApprove = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_approval_rights")>
<cfif useLakebaseForqInsertGroupAccessApprove>
	<cftry>
		<cfset application.oLakebase.insertRow("group_approval_rights", {
			"user_profile_id" = "#ProfileID#",
			"group_id" = "#Group_ID#",
			"group_type" = "#application.returned_customer_setting.approval_on_type_code#",
			"group_id_approval" = "#groupApprove#",
			"group_id_margin" = "#groupApproveMargin#",
			"group_id_spend_dollar" = "#groupApproveSpend#",
			"group_id_margin_operator" = "#groupApproveMarginOper#",
			"group_id_list_price" = "#groupApproveListPrice#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertGroupAccessApprove = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertGroupAccessApprove>
<cfquery name="qInsertGroupAccessApprove" datasource="#application.datasource#">
		INSERT INTO Group_Approval_Rights(
			User_Profile_Id
			,Group_ID
			,Group_type
			,Group_ID_Approval
			,Group_ID_Margin
			,Group_ID_Spend_Dollar
			,Group_ID_Margin_Operator
			,Group_ID_List_Price
		)
		VALUES(
			#ProfileID#
			,'#Group_ID#'
			,#application.returned_customer_setting.approval_on_type_code#
			,#groupApprove#
			,'#groupApproveMargin#'
			,'#groupApproveSpend#'
			,'#groupApproveMarginOper#'
			,'#groupApproveListPrice#'
		)
	</cfquery>
</cfif>

</cfloop>
</cfloop>

<cfquery name="UpdateGeneralInformation" datasource="#application.datasource#">
		UPDATE Profiles_Settings
		SET Last_Changed_Date		= getdate()
			,Last_Changed_User_ID	= '#request.accessStructure.User_ID#'
</cfquery>

<!------ <cflocation addtoken="No" url="groupLevelAccessValues.cfm?profileId=#Form.Profile_ID#"> ----->
<script language="JavaScript">
window.close();
</script>