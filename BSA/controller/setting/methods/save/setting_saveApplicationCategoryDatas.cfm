<!---
Name: 			setting_saveApplicationCategoryDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for saving application category data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	saveApplicationCategoryDatas() --->
<cffunction name="saveApplicationCategoryDatas" access="public" returntype="boolean" output="no" hint="I am responsible for saving application category data.">

	<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
	<cfargument name="request_data_structure" type="struct" required="yes">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = "" />
			
	<!--- Attempt to run the function call to the model... --->
	<cftry>
	
		<cfset var_returnVal = createObject("component", "BSA.model.setting.Setting").saveApplicationCategoryDatas(arguments.request_data_structure) />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnVal = 0 />
			
		</cfcatch>
				
	</cftry>	
	
	<cfreturn var_returnVal />
	
</cffunction>
