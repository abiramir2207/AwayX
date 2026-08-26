<!------ Next_Page.cfm ----->
<cfparam name="pageName" 	default="">
<cfif pageName NEQ "">
	<cfinclude template="Page_List.cfm" />
	<cfset bCurrentPage = 0 />
	<CFSET F_Counter = 1>
	<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
		<CFSET ThisPageName = ListGetAt(PAGE_NAMES, F_Counter, ",")>
		<cfif bCurrentPage>
			<CFSET ThisURL = ListGetAt(PAGE_URLS, F_Counter, ",")>
			<cflocation addtoken="No" url="#ThisURL#" />
		</cfif>
		<CFIF ThisPageName EQ pageName>
			<cfset bCurrentPage = 1 />
		</CFIF>
		<CFSET F_Counter = F_Counter + 1>
	</CFLOOP>
	<cfinclude template="program_wizard_complete.cfm">
	<cflocation addtoken="No" url="summary.cfm?id=#url.id#">
</cfif>