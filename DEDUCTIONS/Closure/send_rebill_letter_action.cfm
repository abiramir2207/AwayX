<!--- Save as file --->

<cfinclude template="/deductions/closure/rebill_content_save.cfm">

<cfoutput>

<!--- Email --->
<cfif Submit_Method IS "Email">
	<cfinclude template="/deductions/closure/rebill_email_create.cfm">
</cfif>
<!--- Fax --->
<cfif Submit_Method IS "Fax">
	<cfinclude template="/deductions/closure/rebill_fax_create.cfm">
</cfif>

<!--- Print --->
<!--- Fax --->
<cfif Submit_Method IS "Print">

	<Cfinclude template="/deductions/closure/print_rebill.cfm">
</cfif>

</cfoutput>