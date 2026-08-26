<cfparam name="form.RedirectPath" default="" />
<cf_cryp type="de" key="#request.key#" string="#FORM.Contract_Main_ID#">
<CFSET FORM.Contract_Main_ID = cryp.value>

<!--- REDIRECTOR --->
<cfquery name="getContractProgramID" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main
	WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
</cfquery>
<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>

<CFSET redirector_FromPage_ID = 7>
<cfinclude template="internal_redirector_based_on_settings.cfm">

<cfif form.RedirectPath EQ "">
	<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.string#">
	<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
	<CFLOCATION url= "#redirectURL#" />
<cfelse>
	<CFLOCATION URL="contract_discount_lump_sums_margin.cfm?CID=#enc.value#&marginedit_saved=1"/>
</cfif>