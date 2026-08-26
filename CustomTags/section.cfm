<cfif compareNoCase(thisTag.executionMode,"start") eq 0>
	<cfsilent>
	<!--- 
		Template: section.cfm
	 --->
	
	<cfparam name="attributes.name" type="string">
	<cfif isDefined("attributes.parameters")>
		<cfparam name="attributes.parameters" type="struct">
		<cfset request.parameters = attributes.parameters />
	</cfif>
	
	<cfset sectionURL = replace(attributes.name,".","/","ALL") & ".cfm">

	</cfsilent>
	
	<!--- Output section content --->
 	<cfinclude template="/#sectionURL#">
	
</cfif>

