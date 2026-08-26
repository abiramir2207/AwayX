
<CF_Cryp type="de" key="#request.key#" string="#FORM.PROGRAM_ID#">
<CFSET FORM.Program_ID = cryp.value>

<CFQUERY NAME="deactivateCurrentPeriods" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Periods
	SET 
		DELETED = 1,
		ACTIVE = 0
	WHERE 
		Program_ID = #FORM.Program_ID#
		AND Active  = 1
		AND DELETED  = 0
</CFQUERY>

<CFQUERY NAME="activateNewPeriods" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Periods
	SET 
		ACTIVE = 1
	WHERE 
		Program_ID = #FORM.Program_ID#
		AND Active  = 0
		AND DELETED  = 0
</CFQUERY>


<!--- <CFSET generateReleaseProgramID = FORM.Program_ID>
<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm"> --->

<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#cryp.string#">