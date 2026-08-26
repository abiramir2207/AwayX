<cf_cryp type="de" key="#request.key#" string="#FORM.Contract_Main_ID#">
<CFSET FORM.Contract_Main_ID = cryp.value>

<!--- REDIRECTOR --->
<cfquery name="getContractProgramID" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main
	WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
</cfquery>
<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>

<CFSET redirector_FromPage_ID = 8>
<cfinclude template="internal_redirector_based_on_settings.cfm">
<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.string#">
<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
<CFLOCATION url= "#redirectURL#" />
