<cfparam name="url.user_id" default="">

<cfif len(trim(url.user_id)) GT 0>
	<cfset useLakebaseForsaveAgreement = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usdanoi_agreements")>
<cfif useLakebaseForsaveAgreement>
	<cftry>
		<cfset application.oLakebase.insertRow("usdanoi_agreements", {
			"user_id" = "#url.user_id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveAgreement = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveAgreement>
<cfquery name="saveAgreement" datasource="#application.datasource#">
		INSERT INTO usdanoi_agreements
		(user_id)
		VALUES
		('#url.user_id#')
	</cfquery>
</cfif>
</cfif>
<cflocation url="search.cfm">
