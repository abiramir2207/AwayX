
<cfif isDefined("Auto_Checkbook_ID")>

	<cfset useLakebaseForUpdateAutoCheckbooks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_checkbook")>
<cfif useLakebaseForUpdateAutoCheckbooks>
	<cftry>
		<cfset application.oLakebase.updateRows("auto_checkbook",
			{
				"auto_checkbook_id" = "eq.#Auto_Checkbook_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAutoCheckbooks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAutoCheckbooks>
<cfquery name="UpdateAutoCheckbooks" datasource="#application.datasource#">
	UPDATE Auto_Checkbook
	SET Deleted = 1
	WHERE Auto_Checkbook_ID = '#Auto_Checkbook_ID#'
	</cfquery>
</cfif>

</cfif>

<cflocation url="/billbacks/ledger/auto_checkbook/index.cfm">