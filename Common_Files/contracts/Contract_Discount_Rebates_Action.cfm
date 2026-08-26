<cf_cryp type="de" key="#request.key#" string="#FORM.Contract_Main_ID#">
<!--- lock checker --->
<CFSET LockChecker_CID  = cryp.value>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
<!--- lock checker --->
<CFLOOP INDEX="FormField" LIST="#FORM.FIELDNAMES#">
	<CFIF find("REBATE_UOM_", FormField) NEQ 0>
		<CFSET ProductNameArray = listtoarray(FormField, "_")>
		
		<cfset useLakebaseForupdateRebateData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForupdateRebateData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_rebates_product_data",
			{
				"program_rebates_product_data_id" = "eq.#ProductNameArray[3]#"
			},
			{
				"rebate_value" = "#evaluate("FORM.REBATE_VALUE_#ProductNameArray[3]#")#",
				"unit_of_measure_id" = "#evaluate("FORM.REBATE_UOM_#ProductNameArray[3]#")#",
				"volume" = "#evaluate("FORM.REBATE_PRODUCT_VOLUME_#ProductNameArray[3]#")#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateRebateData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateRebateData>
<CFQUERY NAME="updateRebateData" datasource="#application.datasource#">
			UPDATE Program_Rebates_Product_Data
			SET 
				Rebate_Value 	= '#evaluate("FORM.REBATE_VALUE_#ProductNameArray[3]#")#',
				Unit_Of_Measure_ID	= '#evaluate("FORM.REBATE_UOM_#ProductNameArray[3]#")#',
				Volume				= '#evaluate("FORM.REBATE_PRODUCT_VOLUME_#ProductNameArray[3]#")#'
			WHERE Program_Rebates_Product_Data_ID = '#ProductNameArray[3]#'
		</CFQUERY>
</cfif>
	</CFIF>
</CFLOOP>

<cfset useLakebaseForgetProgramType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetProgramType>
	<cftry>
		<cfset getProgramType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramType>
<CFQUERY NAME="getProgramType" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main 
	WHERE Contract_Main_ID = '#cryp.value#'
</CFQUERY>
</cfif>

<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
<CFSET redirector_FromPage_ID = 6>
<cfinclude template="internal_redirector_based_on_settings.cfm">
<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#FORM.Contract_Main_ID#">
<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
<CFLOCATION url= "#redirectURL#" />
