<cfif NOT isDefined("appSettings")>
	<!---Gets application settings--->
	<cfset appSettings = application.appsettingsGet />
</cfif>


<cfif appSettings.getlettersavailable() eq 4 or appSettings.getlettersavailable() eq 5>   <!---Kraft--->
	<cfset includeLettersFilename = "show_opr_dis_letters_custom3.cfm">
<cfelse>
	<cfset includeLettersFilename = "/common_files/contracts/Letters/show_opr_dis_letters.cfm">
</cfif>