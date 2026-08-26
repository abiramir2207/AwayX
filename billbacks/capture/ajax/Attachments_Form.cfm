<cfset strVersion = SERVER.ColdFusion.ProductVersion />
 
<cfif Left(strVersion,5) eq "9,0,0">
	<cfinclude template="attachments_form_2.cfm">
<cfelse>
	<cfinclude template="attachments_form_1.cfm">
</cfif>
