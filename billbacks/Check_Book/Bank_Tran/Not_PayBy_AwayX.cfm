<!--- BJF D12141: Radically changed this page. 
	Instead of offering the user a chance to email some payment information, it redirects to the billback summary screen. --->


<CFQUERY name = "Email_details" datasource="#application.datasource#">
	SELECT * from payment_transaction where payment_trans_ID = '#URL.RID#'
</CFQUERY>

<cfset Billback_ID = Email_details.Billback_ID>

<CFINCLUDE TEMPLATE="bb_set_status_to_paid.cfm">
<cfoutput>
<cflocation url="/billbacks/capture/billback_summary.cfm?BBID=#Billback_ID#"></cfoutput>