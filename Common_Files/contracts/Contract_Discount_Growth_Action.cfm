<cf_cryp type="de" key="#request.key#" string="#FORM.Contract_Main_ID#">
<CFSET FORM.Contract_Main_ID = cryp.value>

<!--- REDIRECTOR --->
<cfset useLakebaseForgetContractProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractProgramID>
	<cftry>
		<cfset getContractProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractProgramID>
<cfquery name="getContractProgramID" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main
	WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
</cfquery>
</cfif>
<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>

<CFSET redirector_FromPage_ID = 8>
<cfinclude template="internal_redirector_based_on_settings.cfm">
<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.string#">
<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
<CFLOCATION url= "#redirectURL#" />
