<!---
Name: 			setting_selectCategoryApplicationDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for getting category application data.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	selectCategoryApplicationDatas() --->
<cffunction name="selectCategoryApplicationDatas" access="public" returntype="any" output="yes" hint="I am responsible for getting category application data.">
	
	<!--- Initialize variables --->
	<cfset var var_returnQuery 		= "" />
	<cfset var var_selectQuery 		= "" />
				
	<!--- Attempt to run the function code --->
	<cftry>
	
		<cfquery name="var_selectQuery" datasource="#application.datasource#">
			SELECT 	Application_Setting_Category_ID,
					Name
			FROM 	Application_Setting_Category
			ORDER BY Name
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
