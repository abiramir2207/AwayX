<!---
Name: 			setting_getCategoryApplicationCategoryDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting setting category and application category data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	getCategoryApplicationCategoryDatas() --->
<cffunction name="getCategoryApplicationCategoryDatas" access="public" returntype="any" output="no" hint="I am responsible for getting setting category and application category data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnStructure 	= structNew() />
	<cfset var var_settingModel 	= "" />
			
	<!--- Attempt to run the function call to the model --->
	<cftry>
	
		<cfset var_settingModel = createObject("component", "BSA.model.setting.application.ApplicationSetting") />
		
		<cfset structInsert(var_returnStructure, "application_category_data", 	var_settingModel.getApplicationCategoryDatas()) />
		<cfset structInsert(var_returnStructure, "category_data", 				var_settingModel.getCategoryApplicationDatas()) />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnStructure = 0 />
			
		</cfcatch>
				
	</cftry>
	
	<cfreturn var_returnStructure />	
	
</cffunction>
