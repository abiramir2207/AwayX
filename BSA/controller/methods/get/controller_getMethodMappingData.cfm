<!---
Name: 			setting_get_method_mapping_data.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting method mapping application data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	getMethodMappingData() --->
<cffunction name="getMethodMappingData" access="public" returntype="any" output="no" hint="I am responsible for getting method mapping application data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnObject = "" />
			
	<!--- Attempt to run the function code --->
	<cftry>
	
		<cfset var_returnObject = createObject("component", "BSA.model.controller.Controller").getMethodMappingData() />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnObject = 0 />
			
		</cfcatch>
				
	</cftry>	
	
	<cfreturn var_returnObject />
	
</cffunction>
