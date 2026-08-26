<!------ clause_library_delete.cfm ----->
<cfoutput>
<cfset bCanDelete = false>
<cfset formName = "frmClauseDelete">
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">

<cfif form.id>
	<cfset clauseLibraryManager = CreateObject("component","components.clause_library.ClauseLibraryManager").init() />
	
  <cfset referer = "#cgi.http_referer#">
	<cfset command = "#form.command#">

		<cfset clauseLib = clauseLibraryManager.getClause(form.id) />
		<!------ delete from template and program ----->
		<cfset clauseLibraryManager.delete(1, 1)>
		
		<cflocation addtoken="No" url="#referer#">
</cfif>
</cfoutput>