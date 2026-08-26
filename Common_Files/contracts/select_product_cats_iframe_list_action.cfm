<CFSET ArrayOfIds = ListToArray(FORM.Category_String, "_")>

<cfset useLakebaseForsaveCategories = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_categories")>
<cfif useLakebaseForsaveCategories>
	<cftry>
		<cfset application.oLakebase.insertRow("program_product_categories", {
			"program_id" = "#FORM.Program_ID#",
			"iscontract" = "1",
			"typegroup_desc_id" = "#ArrayOfIds[1]#",
			"qbrand_desc_id" = "#ArrayOfIds[2]#",
			"typecode_desc_id" = "#ArrayOfIds[3]#",
			"brand_id" = "#ArrayOfIds[4]#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveCategories = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveCategories>
<cfquery name="saveCategories" datasource="#application.datasource#">
	INSERT INTO Program_Product_Categories
	(Program_ID, isContract, TypeGroup_desc_ID, Qbrand_desc_ID, TypeCode_desc_ID,Brand_ID)
	VALUES
	(#FORM.Program_ID#, 1, #ArrayOfIds[1]#, #ArrayOfIds[2]#, #ArrayOfIds[3]#, #ArrayOfIds[4]#)
</cfquery>
</cfif>

<cflocation url="select_product_cats_iframe_list.cfm?Program_ID=#FORM.Program_ID#">