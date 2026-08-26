<!---bid_request_apply_status.cfm--->
<cfoutput>
<!--- rare scenario where form.program_id is the actual contract_main_id --->
<cfif isNumeric( form.program_id )>
    <cfset cryp.value = form.program_id>
<cfelse>    
    <cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
</cfif>

<!---initialize the BidRequestManager--->
<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />

<!---apply status for bid request--->
<cfset bidRequestManager.applyStatus(cryp.value, form.Bid_Request_Status_ID) />

<cfscript>
		objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
		getSettings = objProgramTemplateManager.getSettings(cryp.value);
</cfscript>

<cfif getSettings.Custom_Fixed_Price_Options EQ 1>
	<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#cryp.value#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "0" null="no">
	</cfstoredproc>
</cfif>

<cfset useLakebaseForqCheckProgramApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqCheckProgramApproved>
	<cftry>
		<cfset qCheckProgramApproved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "approved"
			}), "approved"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckProgramApproved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckProgramApproved>
<cfquery name="qCheckProgramApproved" datasource="#application.datasource#">
	SELECT	Approved
	FROM	Contract_Main
	WHERE	contract_main_id = #cryp.value#
</cfquery>
</cfif>
<!---if the status is lost then relocate to home page--->
<cfif qCheckProgramApproved.approved eq 1>
	<cfif form.Bid_Request_Status_ID eq 4 or form.Bid_Request_Status_ID eq 2 or form.Bid_Request_Status_ID eq 3>
		<CFLOCATION url="../Contract_Edit_Menu.cfm?CID=#form.Program_ID#" ADDTOKEN="No">
	</cfif>
<cfelse>
	<CFLOCATION url="../Contract_Edit_Menu.cfm?CID=#form.Program_ID#" ADDTOKEN="No">
</cfif>

</cfoutput>