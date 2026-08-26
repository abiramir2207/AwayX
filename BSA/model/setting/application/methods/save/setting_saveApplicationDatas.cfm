<!---
Name: 			setting_saveApplicationDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for saving application setting datas.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	saveApplicationDatas() --->
<cffunction name="saveApplicationDatas" access="public" returntype="boolean" output="no" hint="I am responsible for saving application setting datas.">

	<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
	<cfargument name="request_data_structure" type="struct" required="yes">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = "" />
			
	<!--- Attempt to run the function call to the database --->
	<cftry>
	
		<cfset var_returnVal = createObject("component", "BSA.database.setting.SettingDatabase").updateApplicationDatas(arguments.request_data_structure) />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnVal = 0 />
			
		</cfcatch>
				
	</cftry>
	
	<cfreturn var_returnVal />	
	
</cffunction>
