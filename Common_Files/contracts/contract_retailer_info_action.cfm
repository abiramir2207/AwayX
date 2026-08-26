<!--- Delete all the entries for the program and insert the records --->
<cfquery name="delete_retail_info" datasource="#application.datasource#">
	 DELETE FROM Contract_Group_Merchant_Info
	 WHERE Program_ID = '#Program_ID#'
</cfquery>

<!--- For Groups --->
<cfif IsDefined("GroupCount")>
<cfloop from="1" to="#GroupCount#" index="i">

	<cfset ProductHierarchyFieldValue = Evaluate("Form.Product_Hierarchy_ID_#i#")>
	<cfset QtyFieldValue = Evaluate("Form.QTY_#i#")>
	<cfset PriceFieldValue = Evaluate("Form.PRICE_#i#")>
	<cfset InventoryUOMValue = Evaluate("Form.Inventory_UM_#i#")>

	<cfquery name="save_retail_info" datasource="#application.datasource#">
	 INSERT INTO Contract_Group_Merchant_Info(Group_ID,Program_ID,Merchant_Price,Merchant_Quantity,UOM)
	 VALUES('#ProductHierarchyFieldValue#','#Program_ID#','#PriceFieldValue#',#QtyFieldValue#,'#InventoryUOMValue#')
	</cfquery>
</cfloop>

<!--- For Products --->
<cfelse>

<cfloop from="1" to="#ProductCount#" index="i">

	<cfset ProductFieldValue = Evaluate("Form.BSA_Foodservice_Items_Master_ID_#i#")>
	<cfset QtyFieldValue = Evaluate("Form.QTY_#i#")>
	<cfset PriceFieldValue = Evaluate("Form.PRICE_#i#")>
	<cfset InventoryUOMValue = Evaluate("Form.Inventory_UM_#i#")>

	<cfquery name="save_retail_info" datasource="#application.datasource#">
	 INSERT INTO Contract_Group_Merchant_Info(Group_ID,Program_ID,Merchant_Price,Merchant_Quantity,UOM)
	 VALUES('#ProductFieldValue#','#Program_ID#','#PriceFieldValue#',#QtyFieldValue#,'#InventoryUOMValue#')
	</cfquery>
</cfloop>

</cfif>

<cf_cryp	type = "en" string = "#Program_ID#" key = "#request.key#">
<cfset CID = cryp.value>

<cflocation url="contract_retailer_info.cfm?CID=#CID#">