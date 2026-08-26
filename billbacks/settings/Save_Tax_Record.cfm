<CFIF Form.BB_Tax_Main_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_main")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_tax_main", {
			"taxcode_id" = "0",
			"tax_allowance_code" = "#FORM.Tax_Allowance_Code#",
			"description" = "#Form.Description#",
			"gl_number" = "0",
			"tax_rate_date" = "#now()#",
			"tax_rate" = "0.00"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		BB_Tax_Main (Taxcode_ID, Tax_Allowance_Code, Description, GL_Number, Tax_Rate_Date, Tax_Rate)
		Values			(0, '#FORM.Tax_Allowance_Code#','#Form.Description#', '0', getdate(), '0.00' )
		SELECT SCOPE_IDENTITY() AS BB_TaxMainID
	</CFQUERY>
</cfif>
	<cfset BB_TaxMainID = Save_Data.BB_TaxMainID>
	<cfset useLakebaseForUpdateSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_main")>
<cfif useLakebaseForUpdateSave_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_tax_main",
			{
				"bb_tax_main_id" = "eq.#BB_TaxMainID#"
			},
			{
				"taxcode_id" = "#BB_TaxMainID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateSave_Data>
<CFQUERY NAME="UpdateSave_Data" datasource="#application.datasource#">
		UPDATE BB_Tax_Main
		SET Taxcode_ID = #BB_TaxMainID#
		WHERE BB_Tax_Main_ID = #BB_TaxMainID#
</CFQUERY>
</cfif>
<CFELSE>
<!--- Update the record --->	
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		BB_Tax_Main
		SET Tax_Allowance_Code				=	'#FORM.Tax_Allowance_Code#',
					Description 	=	'#Form.Description#',
					Deleted =	#Form.Deleted# 
		WHERE		BB_Tax_Main_ID			=	'#Form.BB_Tax_Main_ID#'
	</CFQUERY>
</CFIF>

<CFLOCATION URL="create_tax_record.cfm" ADDTOKEN="No">