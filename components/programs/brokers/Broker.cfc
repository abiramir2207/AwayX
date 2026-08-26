<!---
	Description:
		Component used for Brokers

--->

<cfcomponent>

	<!--- brokers --->
	<cfproperty name="AUTO_SELECTION" type="any">
	<cfproperty name="BSA_FOODSERVICE_BROKERS_ID" type="any">
	<cfproperty name="CONTRACT_BROKERS_ID" type="any">
	<cfproperty name="CONTRACT_MAIN_ID" type="any">
	<cfproperty name="DELETED" type="any">
	
	<!---set constructor--->
	<cfset "this.AUTO_SELECTION" = "" />
	<cfset "this.BSA_FOODSERVICE_BROKERS_ID" = "" />
	<cfset "this.CONTRACT_BROKERS_ID" = "" />
	<cfset "this.CONTRACT_MAIN_ID" = "" />
	<cfset "this.DELETED" = "" />

<!--- 	<CFQUERY NAME="qGetContractBrokers" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Brokers
		WHERE	0<>0
	</CFQUERY>
	
	<cfloop index="index" list="#qGetContractBrokers.columnList#">
		<cfset "this.#index#" = "" />
	</cfloop> --->
	
	<cffunction name="new" output="false">
    
		<cfargument name="foodServiceBrokerId" type="string" required="false" default="">
		<cfargument name="autoSelection" type="string" required="false" default="">
		<cfargument name="recordCount" type="string" required="false" default="">

    	<cfset this.BSA_FOODSERVICE_BROKERS_ID = arguments.foodServiceBrokerId>
		<cfset this.AUTO_SELECTION = arguments.autoSelection>
		<cfset this.RECORDCOUNT = arguments.recordCount>

		
  	</cffunction>
	
</cfcomponent>