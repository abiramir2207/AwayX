<!---
	Description:
		Component used for Distributors

--->

<cfcomponent>

	<!--- Distributors --->
	<cfproperty name="BSA_FOODSERVICE_CUSTOMERS_ID" type="any">
	<cfproperty name="CONTRACT_DISTRIBUTORS_ID" type="any">
	<cfproperty name="CONTRACT_MAIN_ID" type="any">
	<cfproperty name="DELETED" type="any">
	<cfproperty name="PROGRAM_WEIGHT" type="any">
	
	<!---set constructor--->
	<cfset "this.BSA_FOODSERVICE_CUSTOMERS_ID" = "" />
	<cfset "this.CONTRACT_DISTRIBUTORS_ID" = "" />
	<cfset "this.CONTRACT_MAIN_ID" = "" />
	<cfset "this.DELETED" = "" />
	<cfset "this.PROGRAM_WEIGHT" = "" />
	
	<!--- 
	<CFQUERY NAME="qGetContractDistributors" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Distributors
		WHERE 0<>0
	</CFQUERY>
	
	<cfloop index="index" list="#qGetContractDistributors.columnList#">
		<cfset "this.#index#" = "" />
	</cfloop> --->
	
	<cffunction name="new" output="false">
    
		<cfargument name="FoodServiceCustomersId" type="string" required="false" default="">
		<cfargument name="programWeight" type="string" required="false" default="">
		<cfargument name="recordCount" type="string" required="false" default="">
		
    	<cfset this.BSA_FOODSERVICE_CUSTOMERS_ID = arguments.FoodServiceCustomersId>
		<cfset this.PROGRAM_WEIGHT = arguments.programWeight>
		<cfset this.RECORDCOUNT = arguments.recordCount>
		
  	</cffunction>
	
	<cffunction name="getDistributor" output="false" returntype="query">
    
		<cfargument name="distributorID" type="string" required="false" default="">

		<cfquery name="qGetDistributor" datasource="#application.datasource#">
			
			SELECT 	*
			FROM 	BSA_Foodservice_Customers
			<cfif arguments.distributorID neq "">
			WHERE 	BSA_Foodservice_Customers_ID = '#arguments.distributorID#' 
			<cfelse>
			WHERE 	1= 0
			</cfif>
			AND 	deleted = 0
			
		</cfquery>
		
		<cfreturn qGetDistributor />
		
  	</cffunction>
	
</cfcomponent>