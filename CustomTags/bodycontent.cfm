<cfif not thistag.HasEndTag>
	<cfset thistag.generatedcontent="">
	You must have an end Tag
	<cfabort>
</cfif>
<cfparam name="attributes.name" default="bodycontent">
<cfif thistag.executionmode is "end">
	<cfset "request.#attributes.name#"=thistag.generatedcontent>
	<cfset thistag.generatedcontent="">
</cfif>