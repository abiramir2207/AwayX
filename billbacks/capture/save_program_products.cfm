
<CFIF form.is_unknown_product EQ "0">
	<cfloop index="Product_ID" list="#FORM.PRODUCT_LIST#" delimiters=",">
		<cfquery name="saveProducts" datasource="#Application.Datasource#">
			INSERT INTO Billback_Product
			(Billback_ID, Billback_Program_ID, BB_Product_Category_ID, Product_ID)
			VALUES
			('#Form.Billback_ID#', '#Form.BILLBACK_PROGRAM_ID#', '#Form.PRODUCT_IS_ON_PROGRAM#', '#Product_ID#')
		</cfquery>
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