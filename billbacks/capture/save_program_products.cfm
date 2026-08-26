
<CFIF form.is_unknown_product EQ "0">
	<cfloop index="Product_ID" list="#FORM.PRODUCT_LIST#" delimiters=",">
		<cfset useLakebaseForsaveProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForsaveProducts>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_product", {
			"billback_id" = "#Form.Billback_ID#",
			"billback_program_id" = "#Form.BILLBACK_PROGRAM_ID#",
			"bb_product_category_id" = "#Form.PRODUCT_IS_ON_PROGRAM#",
			"product_id" = "#Product_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveProducts>
<cfquery name="saveProducts" datasource="#Application.Datasource#">
			INSERT INTO Billback_Product
			(Billback_ID, Billback_Program_ID, BB_Product_Category_ID, Product_ID)
			VALUES
			('#Form.Billback_ID#', '#Form.BILLBACK_PROGRAM_ID#', '#Form.PRODUCT_IS_ON_PROGRAM#', '#Product_ID#')
		</cfquery>
</cfif>
	</CFLOOP>

<CFELSE>
	<cfquery name="saveProducts" datasource="#Application.Datasource#">
		INSERT INTO Billback_Product
		(Billback_ID, Billback_Program_ID, BB_Product_Category_ID, BB_Unknown_Product_Item_Number, BB_Unknown_Product_Description, BB_Unknown_Product_Notes)
		VALUES
		('#Form.Billback_ID#', '#Form.BILLBACK_PROGRAM_ID#', 3, '#FORM.UNKNOWN_ITEM_NUMBER#', '#replace(replace(FORM.UNKNOWN_DESCRIPTION,chr(39),"&##39","ALL"), chr(34), "&##34", "ALL")#', '#FORM.UNKNOWN_NOTES#')
	</cfquery>
</CFIF>



<CFLOCATION url="program_form.cfm?BBID=#FORM.Billback_ID#">