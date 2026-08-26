<cf_Cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset useLakebaseForunlockProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForunlockProgram>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#cryp.value#"
			},
			{
				"contract_is_locked" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunlockProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunlockProgram>
<cfquery name="unlockProgram" datasource="#application.datasource#">	
	UPDATE Contract_Main
	SET Contract_Is_Locked = 0
	WHERE Contract_Main_ID = #cryp.value#
</cfquery>
</cfif>

<script>
	window.close();
</script>
