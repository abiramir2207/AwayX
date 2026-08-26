<CF_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">

<cfset useLakebaseForupdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdateStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#cryp.value#"
			},
			{
				"on_release_contract_status_type_idx" = "#FORM.ON_RELEASE_CONTRACT_STATUS_TYPE_IDX#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateStatus>
<CFQUERY NAME="updateStatus" datasource="#application.datasource#">
	UPDATE Contract_Main
	SET On_Release_Contract_Status_Type_IDX = '#FORM.ON_RELEASE_CONTRACT_STATUS_TYPE_IDX#'
	WHERE Contract_Main_ID = '#cryp.value#'
</CFQUERY>
</cfif>

<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.Program_ID#">