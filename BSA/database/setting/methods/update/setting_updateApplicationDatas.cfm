<!---
Name: 			setting_updateApplicationDatas.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	I am responsible for updating application setting datas.
Parameters:		N/A
Usage:			N/A
--->

<!--- METHOD:	updateApplicationDatas() --->
<cffunction name="updateApplicationDatas" access="public" returntype="boolean" output="yes" hint="I am responsible for updating setting application data.">

	<!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
	<cfargument name="request_data_structure" type="struct" required="yes">
	
	<!--- Initialize variables --->
	<cfset var var_returnVal 					= "" />
	<cfset var var_attributeCodeArray			= "" />
	<cfset var var_settingAttributeCodeIdx 		= "" />
	
	<!--- Attempt to run the function code --->
	<cftry>
	
		<!---set values passed in from arguments--->
		<cfset var_attributeCodeArray 	= arguments.request_data_structure.applicationSettings.attribute_code />
		
		<!---loop over the settings id and update for each one--->
		<cfloop from="1" to="#arrayLen(var_attributeCodeArray)#" index="var_settingAttributeCodeIdx">
		
 			<cfquery name="qUpdateApplicationSetting" datasource="#application.datasource#">
				
				UPDATE	Application_Setting
				SET		Label 			= <cfqueryparam value="#trim(arguments.request_data_structure.applicationSettings.label[var_settingAttributeCodeIdx])#" cfsqltype="CF_SQL_VARCHAR" />,
						Description 	= <cfqueryparam value="#trim(arguments.request_data_structure.applicationSettings.description[var_settingAttributeCodeIdx])#" cfsqltype="CF_SQL_VARCHAR" />,
						Form_Control_ID = <cfqueryparam value="#trim(arguments.request_data_structure.applicationSettings.form_control_id[var_settingAttributeCodeIdx])#" cfsqltype="CF_SQL_INTEGER" />
				WHERE	Attribute_Code	= <cfqueryparam value="#trim(var_attributeCodeArray[var_settingAttributeCodeIdx])#" cfsqltype="CF_SQL_VARCHAR" />
			
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
