<cfset useLakebaseFordeleteCompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseFordeleteCompany>
	<cftry>
		<cfset application.oLakebase.updateRows("company_main",
			{
				"company_main_id" = "eq.#FORM.Company_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteCompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteCompany>
<CFQUERY NAME="deleteCompany" datasource="#application.datasource#">
	UPDATE Company_Main
	SET deleted = 1
	WHERE Company_Main_ID = '#FORM.Company_Main_ID#'
</CFQUERY>
</cfif>

<CFLOCATION URL="companies_search_form.cfm">