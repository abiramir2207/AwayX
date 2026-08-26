<CF_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">

<CFIF FORM.UPDATE EQ 0>
	<cfset useLakebaseFordeleteExistingRules = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rules")>
<cfif useLakebaseFordeleteExistingRules>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rules",
			{
				"program_id" = "eq.#cryp.value#",
				"active" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteExistingRules = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteExistingRules>
<CFQUERY NAME="deleteExistingRules" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rules
		SET DELETED = 1
		WHERE Program_ID = #cryp.value#
		AND Active  = 0
	</CFQUERY>
</cfif>
	
	<CFQUERY NAME="saveNewRule" datasource="#application.datasource#">
		INSERT INTO Program_Formula_Pricing_Rules
		(
			Program_ID,
			Rule_Name,
			Number_Of_Comms
		)
		VALUES
		(
			#cryp.value#,
			'#FORM.Rule_Name#',
			'#FORM.Number_Of_Comms#'
		)
	</CFQUERY>
	<CFSET Rule_ID=saveNewRule.Program_Formula_Pricing_Rule_ID>	
	<CF_Cryp type="en" key="#request.key#" string="#Rule_ID#">
	<CFSET Rule_ID=cryp.value>
<CFELSE>

	<CF_cryp type="de" key="#request.key#" string="#FORM.Rule_ID#">
	<!------<cfset useLakebaseForupdateRules = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rules")>
<cfif useLakebaseForupdateRules>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rules",
			{
				"program_formula_pricing_rule_id" = "eq.#cryp.value#"
			},
			{
				"rule_name" = "#FORM.Rule_Name#",
				"number_of_comms" = "#FORM.Number_Of_Comms#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateRules = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateRules>
<CFQUERY NAME="updateRules" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rules
		SET 
			Rule_Name = '#FORM.Rule_Name#',
			Number_Of_Comms = '#FORM.Number_Of_Comms#'
		WHERE Program_Formula_Pricing_Rule_ID = '#cryp.value#'
	</CFQUERY>
</cfif>----->
	<CFQUERY NAME="updateRules" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rules
		SET 
			Rule_Name = '#FORM.Rule_Name#'			
		WHERE Program_Formula_Pricing_Rule_ID = '#cryp.value#'
	</CFQUERY>
	
	<CFIF FORM.Number_OF_Comms NEQ FORM.Original_Comm_Count>

		<CFOUTPUT>
		<FORM ACTION="Contract_Formula_Rule_Step_2.cfm?CID=#FORM.Program_ID#" METHOD="post" NAME="MyForm" ID="MyForm">
			<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
			<INPUT TYPE="Hidden" NAME="RULE_ID" VALUE="#FORM.Rule_ID#">
			<INPUT TYPE="Hidden" NAME="Number_Of_Comms" VALUE="#FORM.Number_Of_Comms#">
		</FORM>
		</CFOUTPUT>

		<script>
			document.all.MyForm.submit();
		</script>
		<CFABORT>		
	<CFELSE>
		<!------<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.Program_ID#">----->
		<CFLOCATION URL="Formula_Pricing_Index_Rule_Summary.cfm?CID=#FORM.Program_ID#&RID=#FORM.Rule_ID#">
	</CFIF>
</CFIF>


<CFLOCATION URL="Contract_Formula_Rule_Step_2.cfm?CID=#FORM.Program_ID#&Rule_ID=#Rule_ID#">


