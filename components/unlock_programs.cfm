<!--- unlock this users contracts --->
<cfset useLakebaseForunlockTheirPrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForunlockTheirPrograms>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_is_locked" = "eq.1",
				"contract_locked_by_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0",
				"flagged_as_purged" = "eq.0"
			},
			{
				"contract_is_locked" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunlockTheirPrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunlockTheirPrograms>
<cfquery name="unlockTheirPrograms" datasource="#application.datasource#">
	UPDATE Contract_Main
	Set Contract_Is_Locked = 0 
	WHERE 
		Contract_Is_Locked = 1
		AND 
		Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#' 
		AND
		DELETED = 0 
		AND
		Flagged_As_Purged = 0
</cfquery>
</cfif>