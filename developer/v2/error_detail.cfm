<cfset useLakebaseForqError = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cfml_error_log")>
<cfif useLakebaseForqError>
	<cftry>
		<cfset qError = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cfml_error_log", {
				"cfml_error_log_id" = "eq.#url.id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqError = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqError>
<cfquery name="qError" datasource="#application.datasource#">
    SELECT *
      FROM Cfml_Error_Log 
     WHERE Cfml_Error_Log_ID = #url.id#
</cfquery>
</cfif>

<cfoutput>#qError.File_Structure#</cfoutput>