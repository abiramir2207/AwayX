<!------Contract_Formula_Add_Rule_Action.cfm----->

<CFPARAM NAME="FORM.New_Formula_Pricing_Rule_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.CID" 	DEFAULT="">
<cf_cryp type="de" key="#request.key#" string="#FORM.CID#">
<CFIF FORM.CID NEQ ""> 
	<CFSET Program_ID = cryp.value>
<CFELSE>
	<CFOUTPUT>
	Invalid Program ID
	</CFOUTPUT>
	<CFABORT>
</CFIF>

<CFIF FORM.New_Formula_Pricing_Rule_ID NEQ "">
	<CFSET Insert_Rule = true>
	<CFIF IsDefined("FORM.Rule_ID")>
		<CFIF FORM.Rule_ID NEQ "">
			<CFSET Insert_Rule = false>
		</CFIF>
	</CFIF>
	<CFIF NOT Insert_Rule>
		<!---- update ---->
		<CFQUERY NAME="Update_Rule" DATASOURCE="#application.datasource#">
			UPDATE	Program_Formula_Pricing_Rule_Mapped
			SET		Formula_Pricing_Rule_ID = '#FORM.New_Formula_Pricing_Rule_ID#'
			WHERE
					Program_Formula_Pricing_Rule_Mapped_ID = '#FORM.Rule_ID#'
		</CFQUERY>
		
		<CFSET generateReleaseProgramID = Program_ID>
		<CFSET generateRelease_GeneratePrices = 1>
		<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">

		<CF_Cryp type="en" key="#request.key#" string="#FORM.Rule_ID#">
		<CFLOCATION URL="Formula_Pricing_Index_Rule_Summary.cfm?CID=#FORM.CID#&RID=#cryp.value#">
	<CFELSE>
		<!---- insert ---->
		<CFQUERY NAME="Get_Rule_ID" DATASOURCE="#application.datasource#">
			SELECT	Program_Formula_Pricing_Rule_Mapped_ID
			FROM	Program_Formula_Pricing_Rule_Mapped
			WHERE
					Program_Formula_Pricing_Rule_Mapped.Program_ID = #Program_ID#
					AND
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					AND
					Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = '#FORM.New_Formula_Pricing_Rule_ID#'
		</CFQUERY>
		<CFIF Get_Rule_ID.RecordCount GT 0>
			<CFSET FORM.Program_Formula_Pricing_Rule_ID = Get_Rule_ID.Program_Formula_Pricing_Rule_Mapped_ID>
		<CFELSE>
			<CFQUERY NAME="Save_Rule" DATASOURCE="#application.datasource#">
				INSERT INTO
				Program_Formula_Pricing_Rule_Mapped(Program_ID, Formula_Pricing_Rule_ID)
				VALUES (#Program_ID#, '#FORM.New_Formula_Pricing_Rule_ID#')
			</CFQUERY>
			<CFSET FORM.Program_Formula_Pricing_Rule_ID = Save_Rule.Program_Formula_Pricing_Rule_Mapped_ID>
		</CFIF>
	</CFIF>
</CFIF>
