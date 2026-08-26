<!--- BJF D12141: Radically changed this page. 
	Instead of offering the user a chance to email some payment information, it redirects to the billback summary screen. --->


<cfset useLakebaseForEmail_details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_transaction")>
<cfif useLakebaseForEmail_details>
	<cftry>
		<cfset Email_details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_transaction", {
				"payment_trans_id" = "eq.#URL.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForEmail_details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEmail_details>
<CFQUERY name = "Email_details" datasource="#application.datasource#">
	SELECT * from payment_transaction where payment_trans_ID = '#URL.RID#'
</CFQUERY>
</cfif>

<cfset Billback_ID = Email_details.Billback_ID>

<CFINCLUDE TEMPLATE="bb_set_status_to_paid.cfm">
<cfoutput>
<cflocation url="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#"></cfoutput>