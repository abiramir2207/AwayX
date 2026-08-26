<cf_cryp type="de" key="#request.key#" string="#FORM.Contract_Main_ID#">
<!--- lock checker --->
<CFSET LockChecker_CID  = cryp.value>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
<!--- lock checker --->
<CFLOOP INDEX="FormField" LIST="#FORM.FIELDNAMES#">
	<CFIF find("REBATE_UOM_", FormField) NEQ 0>
		<CFSET ProductNameArray = listtoarray(FormField, "_")>
		
		<CFQUERY NAME="updateRebateData" datasource="#application.datasource#">
			UPDATE Program_Rebates_Product_Data
			SET 
				Rebate_Value 	= '#evaluate("FORM.REBATE_VALUE_#ProductNameArray[3]#")#',
				Unit_Of_Measure_ID	= '#evaluate("FORM.REBATE_UOM_#ProductNameArray[3]#")#',
				Volume				= '#evaluate("FORM.REBATE_PRODUCT_VOLUME_#ProductNameArray[3]#")#'
			WHERE Program_Rebates_Product_Data_ID = '#ProductNameArray[3]#'
		</CFQUERY>
	</CFIF>
</CFLOOP>

<CFQUERY NAME="getProgramType" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main 
	WHERE Contract_Main_ID = '#cryp.value#'
</CFQUERY>

<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
<CFSET redirector_FromPage_ID = 6>
<cfinclude template="internal_redirector_based_on_settings.cfm">
<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#FORM.Contract_Main_ID#">
<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
<CFLOCATION url= "#redirectURL#" />
