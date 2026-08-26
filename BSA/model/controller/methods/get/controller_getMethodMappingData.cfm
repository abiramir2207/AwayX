<!---
Name: 			controller_get_method_mapping_data.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting application mapping data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	getMethodMappingData() --->
<cffunction name="getMethodMappingData" access="public" returntype="any" output="no" hint="I am responsible for getting application mapping data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnObject						= "" />
	<cfset var var_mappingQuery 					= "" />
	<cfset var var_returnBSAMappingDataStructure 	= structNew() />
			
	<!--- Attempt to run the function code --->
	<cftry>
	
		<cfset var_mappingQuery = createObject("component", "BSA.database.controller.ControllerDatabase").selectMethodMappingData() />
		
		<cfloop query="var_mappingQuery">
			
			<cfset "#BSA_Event#" = structNew() />
					
			<cfset structInsert("#evaluate(BSA_Event)#", "bsaEvent",			BSA_Event) />
			<cfset structInsert("#evaluate(BSA_Event)#", "component",			Component) />
			<cfset structInsert("#evaluate(BSA_Event)#", "method", 				Method) />	
			<cfset structInsert("#evaluate(BSA_Event)#", "bsaEventAction",		BSA_Event_Action) />
			<cfset structInsert("#evaluate(BSA_Event)#", "viewPage",			View_Page) />
			<cfset structInsert("#evaluate(BSA_Event)#", "viewPageMethod",		View_Page_Method) />	
			
			<cfset structInsert(var_returnBSAMappingDataStructure, "#BSA_Event#", "#evaluate(BSA_Event)#") />
			
		</cfloop>
		
		<cfset var_returnObject =  var_returnBSAMappingDataStructure />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnObject = 0 />
			
		</cfcatch>
				
	</cftry>	
	
	<cfreturn var_returnObject />
	
</cffunction>
