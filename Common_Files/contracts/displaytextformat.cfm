<!------ displaytextformat.cfm ----->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfset isTextFormat ="true" >
<cf_cryp type="de" string ="#url.CID#" key="#request.key#">
<CFSET CSL_Contract_Main_ID = #cryp.value#>	
	<CFINCLUDE template="commonqueries.cfm">
<cfoutput><pre></cfoutput>
<cfinclude template="thin_contract_general_display.cfm">
<cfoutput></pre></cfoutput>
