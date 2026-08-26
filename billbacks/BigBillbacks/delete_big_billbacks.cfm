
<cfquery name="DeleteBigBillbacks" datasource="#application.datasource#">
DELETE FROM Big_Billback WHERE Billback_ID = '#Billback_ID#' <cfif isDefined("Big_Billback_Summary_ID")>AND Big_Billback_Summary_ID = '#Big_Billback_Summary_ID#'</cfif>
</cfquery>

<cflocation url="enter_bulk_information.cfm?Billback_ID=#Billback_ID#">
