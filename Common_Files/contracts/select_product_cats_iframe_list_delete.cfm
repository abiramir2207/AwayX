<cfset useLakebaseFordeleteCoategory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_categories")>
<cfif useLakebaseFordeleteCoategory>
	<cftry>
		<cfset application.oLakebase.updateRows("program_product_categories",
			{
				"program_product_category_id" = "eq.#FORM.Program_Product_Category_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteCoategory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteCoategory>
<cfquery name="deleteCoategory" datasource="#application.datasource#">
	UPDATE Program_Product_Categories
	SET deleted = 1
	WHERE Program_Product_Category_ID = '#FORM.Program_Product_Category_ID#'
</cfquery>
</cfif>

<cflocation url="select_product_cats_iframe_list.cfm?Program_ID=#FORM.Program_ID#">