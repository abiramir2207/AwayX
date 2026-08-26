<CFIF Form.BB_Tax_Main_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		BB_Tax_Main (Taxcode_ID, Tax_Allowance_Code, Description, GL_Number, Tax_Rate_Date, Tax_Rate)
		Values			(0, '#FORM.Tax_Allowance_Code#','#Form.Description#', '0', getdate(), '0.00' )
		SELECT SCOPE_IDENTITY() AS BB_TaxMainID
	</CFQUERY>
	<cfset BB_TaxMainID = Save_Data.BB_TaxMainID>
	<CFQUERY NAME="UpdateSave_Data" datasource="#application.datasource#">
		UPDATE BB_Tax_Main
		SET Taxcode_ID = #BB_TaxMainID#
		WHERE BB_Tax_Main_ID = #BB_TaxMainID#
</CFQUERY>
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