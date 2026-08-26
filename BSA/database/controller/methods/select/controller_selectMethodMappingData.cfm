<!---
Name: 			setting_select_method_mapping_data.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting method mapping data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	selectMethodMappingData() --->
<cffunction name="selectMethodMappingData" access="public" returntype="any" output="yes" hint="I am responsible for getting method mapping data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnQuery 		= "" />
	<cfset var var_selectQuery 		= "" />
				
	<!--- Attempt to run the function code --->
	<cftry>
	
		<cfquery name="var_selectQuery" datasource="#application.datasource#">
		
			SELECT	*
			FROM	BSA_Mapping
		
		</cfquery>
		
		<cfset var_returnQuery = var_selectQuery />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnQuery = 0 />
			
		</cfcatch>
				
	</cftry>	
	
	<cfreturn var_returnQuery />
	
</cffunction>
