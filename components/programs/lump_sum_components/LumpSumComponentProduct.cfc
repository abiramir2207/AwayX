<!---
	Description:
		Component used for Lump Sum Component Products

--->

<cfcomponent>

	<!--- lumpsum component Products --->
	<cfproperty name="CONTRACT_PRODUCTS_ID" type="any">
	<cfproperty name="CREATED_DATE" type="any">
	<cfproperty name="DELETED" type="any">
	<cfproperty name="PROGRAM_LUMP_SUM_ID" type="any">
	<cfproperty name="PROGRAM_LUMP_SUM_PRODUCT_DATA_ID" type="any">
	<cfproperty name="VOLUME" type="any">
	<cfproperty name="IS_GROUP" type="any">
	
	<!---set constructor--->
	<cfset "this.CONTRACT_PRODUCTS_ID" = "" />
	<cfset "this.CREATED_DATE" = "" />
	<cfset "this.DELETED" = "" />
	<cfset "this.PROGRAM_LUMP_SUM_ID" = "" />
	<cfset "this.PROGRAM_LUMP_SUM_PRODUCT_DATA_ID" = "" />
	<cfset "this.VOLUME" = "" />
	<cfset "this.IS_GROUP" = 0 />
	
<!--- 	<CFQUERY NAME="qGetLumpSumComponentProducts" datasource="#application.datasource#">
		SELECT *
		FROM Program_Lump_Sum_Product_Data
		WHERE 0<>0
	</CFQUERY>
	
	<cfloop index="index" list="#qGetLumpSumComponentProducts.columnList#">
		<cfset "this.#index#" = "" />
	</cfloop> --->
	
	<cffunction name="new" output="false">
    
		<cfargument name="contractProdId" type="string" required="false" default="">
		<cfargument name="deleted" type="string" required="false" default="">
		<cfargument name="lumpSumId" type="string" required="false" default="">
		<cfargument name="recordCount" type="string" required="false" default="">
		<cfargument name="volume" type="string" required="false" default="">
		<cfargument name="isGroup" type="string" required="false" default="">
		
		<cfset this.CONTRACT_PRODUCTS_ID = arguments.contractProdId>
		<cfset this.DELETED = arguments.deleted>
		<cfset this.PROGRAM_LUMP_SUM_ID = arguments.lumpSumId>
		<cfset this.RECORDCOUNT = arguments.recordCount>
		<cfset this.VOLUME = arguments.volume>
		<cfset this.IS_GROUP = arguments.isGroup>

  	</cffunction>
	
</cfcomponent>