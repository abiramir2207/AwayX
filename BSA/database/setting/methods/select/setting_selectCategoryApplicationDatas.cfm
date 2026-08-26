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
	
		<cfset useLakebaseForvar_selectQuery = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("application_setting_category")>
<cfif useLakebaseForvar_selectQuery>
	<cftry>
		<cfset var_selectQuery = application.oLakebase.toQuery(
			application.oLakebase.selectRows("application_setting_category", {
				"order" = "name.asc",
				"select" = "application_setting_category_id,name"
			}), "application_setting_category_id,name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvar_selectQuery = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvar_selectQuery>
<cfquery name="var_selectQuery" datasource="#application.datasource#">
			SELECT 	Application_Setting_Category_ID,
					Name
			FROM 	Application_Setting_Category
			ORDER BY Name
		</cfquery>
</cfif>
				
		<cfset var_returnQuery = var_selectQuery />
		
		<!--- If something went wrong with the function code... --->
		<cfcatch>

			<!--- Return "False" to caller --->
			<cfset var_returnQuery = 0 />
			
		</cfcatch>
				
	</cftry>	
	
	<cfreturn var_returnQuery />
	
</cffunction>
