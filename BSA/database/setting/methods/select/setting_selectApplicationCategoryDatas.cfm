<!---
Name: 			setting_selectApplicationCategoryDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting application category data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	selectApplicationCategoryDatas() --->
<cffunction name="selectApplicationCategoryDatas" access="public" returntype="any" output="yes" hint="I am responsible for getting application category data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnQuery 		= "" />
	<cfset var var_selectQuery 		= "" />
				
	<!--- Attempt to run the function code --->
	<cftry>
	
		<cfquery name="var_selectQuery" datasource="#application.datasource#">
		
			SELECT 	Application_Setting.Application_Setting_ID,
					Application_Setting.Attribute_Code,
					Application_Setting.Label,
					Application_Setting.Description,
					Application_Setting.Form_Control_ID,
					Application_Setting_Category.Name
			FROM 	Application_Setting
					INNER JOIN Application_Setting_Category ON 
					Application_Setting_Category.Application_Setting_Category_ID = Application_Setting.Application_Setting_Category_ID
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
