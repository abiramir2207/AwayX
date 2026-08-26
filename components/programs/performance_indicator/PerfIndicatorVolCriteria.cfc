<!---
	Description:
		Component used for Program Performance Indicators
	Package List:
--->

<cfcomponent>
	<cffunction name="ListContractStatusTypes" output="false" returntype="query">
		<CFQUERY NAME="getGenericTypes" datasource="#application.datasource#">
			select 	distinct *
			from 	contract_status_types
			where 	Contract_Status_Type_ID >=3 
			and 	Contract_Status_Type_ID < 8
		</CFQUERY>
		<cfreturn getGenericTypes  />
	</cffunction>
</cfcomponent>