<cfparam name="url.ID" default="">

<cfset thisReferer = replacenocase(cgi.http_referer, cgi.http_host, "", "ALL")>
<cfif thisReferer EQ "http:///settings/index2.cfm" AND len(url.ID) GT 0>
	<cfset useLakebaseFordeleteRule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rules")>
<cfif useLakebaseFordeleteRule>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rules",
			{
				"bid_rule_id" = "eq.#url.ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteRule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteRule>
<cfquery name="deleteRule" datasource="#application.datasource#">
		UPDATE Bid_Rules
		SET Deleted = 1
		WHERE Bid_Rule_ID = '#url.ID#'
	</cfquery>
</cfif>
</cfif>

<cflocation url="index.cfm">
