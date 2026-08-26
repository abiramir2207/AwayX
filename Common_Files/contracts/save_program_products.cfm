<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<cfabort>
<CFIF len(trim(FORM.Product_List)) EQ 0 OR len(trim(FORM.Program_ID)) EQ 0>
	<CFOUTPUT>#len(trim(FORM.Product_List))# - #len(trim(FORM.Program_ID))#</CFOUTPUT>
	<script>
		history.back()
	</script>
	<cfabort>
</CFIF>

<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>
<cfset useLakebaseFordeleteCurrentProgramProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseFordeleteCurrentProgramProducts>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"contract_main_id" = "eq.#FORM.Program_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteCurrentProgramProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteCurrentProgramProducts>
<CFQUERY NAME="deleteCurrentProgramProducts" datasource="#application.datasource#">
	UPDATE Contract_Products
	SET Deleted = 1
	WHERE Contract_Main_ID = '#FORM.Program_ID#'
</CFQUERY>
</cfif>

<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#" DELIMITERS=",">
	<cfset useLakebaseForsaveContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForsaveContractProducts>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_products", {
			"bsa_foodservice_items_master_id" = "#Product_ID#",
			"contract_main_id" = "#FORM.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveContractProducts>
<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
		INSERT INTO Contract_Products
		(BSA_Foodservice_Items_Master_ID, Contract_Main_ID)
		VALUES
		('#Product_ID#', '#FORM.Program_ID#')
	</CFQUERY>
</cfif>
	
	<cfset useLakebaseForInsertNewProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForInsertNewProduct>
	<cftry>
		<cfset application.oLakebase.insertRow("program_fixed_price_product_data", {
			"program_id" = "#FORM.Program_ID#",
			"contract_products_id" = "#saveContractProducts.Contract_Products_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertNewProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertNewProduct>
<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
		INSERT INTO Program_Fixed_Price_Product_Data
		(Program_ID, Contract_Products_ID)
		VALUES
		('#FORM.Program_ID#', '#saveContractProducts.Contract_Products_ID#')
	</CFQUERY>
</cfif>
</CFLOOP>

<CFLOCATION URL="#CGI.HTTP_REFERER#" addtoken="No">
