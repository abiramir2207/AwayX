<!---
Name: 			setting_updateApplicationCategoryDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for updating setting application category data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	updateApplicationCategoryDatas() --->
<cffunction name="updateApplicationCategoryDatas" access="public" returntype="boolean" output="yes" hint="I am responsible for updating setting application category data.">

	<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
	<cfargument name="request_data_structure" type="struct" required="yes">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal 		= "" />
	<cfset var var_categoryId 		= "" />
	<cfset var var_settingsIdArray 	= "" />
	<cfset var settingIdIndex 		= "" />
				
	<!--- Attempt to run the function code --->
	<cftry>
	
		<!---set values passed in from arguments--->
		<cfset var_categoryId 		= arguments.request_data_structure.application_setting_category_id />
		<cfset var_settingsIdArray 	= arguments.request_data_structure.applicationsettings.original.application_setting_id />
		
		<!---loop over the settings id and update for each one--->
		<cfloop from="1" to="#arrayLen(var_settingsIdArray)#" index="settingIdIndex">
		

 			<cfquery name="qUpdateApplicationSetting" datasource="#application.datasource#">
				
				UPDATE	Application_Setting
				SET		Application_Setting_Category_ID = <cfqueryparam value="#trim(var_categoryId)#" cfsqltype="CF_SQL_INTEGER" />
				WHERE	Application_Setting_ID = <cfqueryparam value="#trim(var_settingsIdArray[settingIdIndex])#" cfsqltype="CF_SQL_INTEGER" />
			
			</cfquery>
		
		</cfloop>
		
		<cfset var_returnVal = 1 />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnVal = 0 />
			
		</cfcatch>
				
	</cftry>	
	
	<cfreturn var_returnVal />
	
</cffunction>
