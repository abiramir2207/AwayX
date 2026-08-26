<CFSET ArrayOfIds = ListToArray(FORM.Category_String, "_")>

<cfquery name="saveCategories" datasource="#application.datasource#">
	INSERT INTO Program_Product_Categories
	(Program_ID, isContract, TypeGroup_desc_ID, Qbrand_desc_ID, TypeCode_desc_ID,Brand_ID)
	VALUES
	(#FORM.Program_ID#, 1, #ArrayOfIds[1]#, #ArrayOfIds[2]#, #ArrayOfIds[3]#, #ArrayOfIds[4]#)
</cfquery>

<cflocation url="select_product_cats_iframe_list.cfm?Program_ID=#FORM.Program_ID#">