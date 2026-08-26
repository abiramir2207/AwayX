<!---
Name: 			setting_getCategoryApplicationDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting setting category data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	getCategoryApplicationDatas() --->
<cffunction name="getCategoryApplicationDatas" access="public" returntype="any" output="no" hint="I am responsible for getting setting category data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal = "" />
			
	<!--- Attempt to run the function call to the database --->
	<cftry>
	
		<cfset var_returnVal = createObject("component", "BSA.database.setting.SettingDatabase").selectCategoryApplicationDatas() />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnVal = 0 />
			
		</cfcatch>
				
	</cftry>
	
	<cfreturn var_returnVal />	
	
</cffunction>
