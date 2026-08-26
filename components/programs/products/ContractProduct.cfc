<!---
	Description:
		Component used for Contract Products

--->

<cfcomponent>

	<!--- contract_products --->
	<cfproperty name="BSA_FOODSERVICE_ITEMS_MASTER_ID" type="any">
	<cfproperty name="CONTRACT_MAIN_ID" type="any">
	<cfproperty name="CONTRACT_PRODUCTS_ID" type="any">
	<cfproperty name="CREATOR_ID" type="any">
	<cfproperty name="DATE_CREATED" type="any">
	<cfproperty name="DELETED" type="any">
	<cfproperty name="DISCOUNT_VALUE" type="any">
	<cfproperty name="EDITOR_ID" type="any">
	<cfproperty name="PRICING_RULE" type="any">
	<cfproperty name="PRODUCT_PROCESS_FLAG" type="any">
	<cfproperty name="PRODUCT_TYPE_ID" type="any">
	<cfproperty name="PRODUCT_UPC" type="any">
	
	<!---set constructor--->
	<cfset "this.BSA_FOODSERVICE_ITEMS_MASTER_ID" = "" />
	<cfset "this.CONTRACT_MAIN_ID" = "" />
	<cfset "this.CONTRACT_PRODUCTS_ID" = "" />
	<cfset "this.CREATOR_ID" = "" />
	<cfset "this.DATE_CREATED" = "" />
	<cfset "this.DELETED" = "" />
	<cfset "this.DISCOUNT_VALUE" = "" />
	<cfset "this.EDITOR_ID" = "" />
	<cfset "this.PRICING_RULE" = "" />
	<cfset "this.PRODUCT_PROCESS_FLAG" = "" />
	<cfset "this.PRODUCT_TYPE_ID" = "" />
	<cfset "this.PRODUCT_UPC" = "" />
	
<!--- 	<CFQUERY NAME="qGetContractProducts" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Products
		WHERE 0<>0
	</CFQUERY>
	
	<cfloop index="index" list="#qGetContractProducts.columnList#">
		<cfset "this.#index#" = "" />
	</cfloop> --->
	
	<cffunction name="new" output="false">
    
		<cfargument name="foodServiceItemMasterID" type="string" required="false" default="">
		<cfargument name="contractProdId" type="string" required="false" default="">
		<cfargument name="prodTypeId" type="string" required="false" default="">
		<cfargument name="deleted" type="string" required="false" default="">
		<cfargument name="recordCount" type="string" required="false" default="">
		
		<cfset this.BSA_FOODSERVICE_ITEMS_MASTER_ID = arguments.foodServiceItemMasterID>
		<cfset this.CONTRACT_PRODUCTS_ID = arguments.contractProdId>
		<cfset this.PRODUCT_TYPE_ID = arguments.prodTypeId>
		<cfset this.DELETED = arguments.deleted>
		<cfset this.RECORDCOUNT = arguments.recordCount>

  	</cffunction>
	
</cfcomponent>