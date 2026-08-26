<cfquery name="deleteCoategory" datasource="#application.datasource#">
	UPDATE Program_Product_Categories
	SET deleted = 1
	WHERE Program_Product_Category_ID = '#FORM.Program_Product_Category_ID#'
</cfquery>

<cflocation url="select_product_cats_iframe_list.cfm?Program_ID=#FORM.Program_ID#">