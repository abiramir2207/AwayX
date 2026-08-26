<!--- Delete all the entries for the program and insert the records --->
<cfset useLakebaseFordelete_retail_info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_group_merchant_info")>
<cfif useLakebaseFordelete_retail_info>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_group_merchant_info", {
			"program_id" = "eq.#Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_retail_info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_retail_info>
<cfquery name="delete_retail_info" datasource="#application.datasource#">
	 DELETE FROM Contract_Group_Merchant_Info
	 WHERE Program_ID = '#Program_ID#'
</cfquery>
</cfif>

<!--- For Groups --->
<cfif IsDefined("GroupCount")>
<cfloop from="1" to="#GroupCount#" index="i">

	<cfset ProductHierarchyFieldValue = Evaluate("Form.Product_Hierarchy_ID_#i#")>
	<cfset QtyFieldValue = Evaluate("Form.QTY_#i#")>
	<cfset PriceFieldValue = Evaluate("Form.PRICE_#i#")>
	<cfset InventoryUOMValue = Evaluate("Form.Inventory_UM_#i#")>

	<cfset useLakebaseForsave_retail_info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_group_merchant_info")>
<cfif useLakebaseForsave_retail_info>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_group_merchant_info", {
			"group_id" = "#ProductHierarchyFieldValue#",
			"program_id" = "#Program_ID#",
			"merchant_price" = "#PriceFieldValue#",
			"merchant_quantity" = "#QtyFieldValue#",
			"uom" = "#InventoryUOMValue#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsave_retail_info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsave_retail_info>
<cfquery name="save_retail_info" datasource="#application.datasource#">
	 INSERT INTO Contract_Group_Merchant_Info(Group_ID,Program_ID,Merchant_Price,Merchant_Quantity,UOM)
	 VALUES('#ProductHierarchyFieldValue#','#Program_ID#','#PriceFieldValue#',#QtyFieldValue#,'#InventoryUOMValue#')
	</cfquery>
</cfif>
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