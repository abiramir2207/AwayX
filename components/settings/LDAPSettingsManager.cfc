
<cfcomponent displayname="LDAPSettingsManager" hint="Handles LADAP Methods" output="false">
	
	<!--- Init --->
	<cffunction name="init" output="false" returntype="components.settings.LDAPSettingsManager">
		<cfreturn this />		
	</cffunction>

	<!--- getLDAPSettings : Settings for userName, password and mailServer --->
	<cffunction name="getLDAPSettings" output="false" returntype="Query" >
		<cfset var qGetLDAPSettings = "" />
		<cfquery name="qGetLDAPSettings" datasource="#application.datasource#">
			SELECT	
						LDAP_Settings_ID,
						LDAP_Server,
						LDAP_Read_Username,
						LDAP_Read_Password,
						LDAP_Port,
						LDAP_SSL_Enabled,
						LDAP_SSL_Port,
						LDAP_Server_Win2003,
						LDAP_Org_Name,
						LDAP_Org_Unit_Name,
						LDAP_Issue_Message,
						LDAP_BSA_Issue_Message,
						LDAP_New_User_Message,
						LDAP_Settings_Updated_By,
						LDAP_Settings_Updated_Date,
						_Users.Name_First,
						_Users.Name_Last
			FROM		LDAP_Settings
			LEFT JOIN 	_Users 
				ON		_Users.Deleted = 0
				AND		_Users.User_ID = LDAP_Settings.LDAP_Settings_Updated_By
    	</cfquery>

		<cfreturn qGetLDAPSettings />
	</cffunction> 
	
	
	<!--- setAutoApproverSettings : Settings for userName, password and mailServer --->
	<cffunction name="setLDAPSettings" output="false" returntype="void">
		<cfargument name="LDAP_Server" required="false" default="" type="String" />
		<cfargument name="LDAP_Read_Username" required="false" default="" type="String" />
		<cfargument name="LDAP_Read_Password" required="false" default="" type="String" />
		<cfargument name="LDAP_Port" required="false" default="" type="String" />
		<cfargument name="LDAP_SSL_Enabled" required="false" default="0" type="String" />
		<cfargument name="LDAP_SSL_Port" required="false" default="" type="String" />
		<cfargument name="LDAP_Org_Name" required="false" default="" type="String" />
		<cfargument name="LDAP_Org_Unit_Name" required="false" default="" type="String" />
		<cfargument name="LDAP_Issue_Message" required="false" default="" type="String" />
		<cfargument name="LDAP_BSA_Issue_Message" required="false" default="" type="String" />
		<cfargument name="LDAP_New_User_Message" required="false" default="" type="String" />
		<cfargument name="LDAP_Settings_Updated_By" required = "false" default="" type="String" />

		<cfset var qSetLDAPSettings = "" />    
  
		<cfquery name="qSetLDAPSettings" datasource="#application.datasource#">
			UPDATE  LDAP_Settings
			SET		LDAP_Server					= <cfqueryparam value="#arguments.LDAP_Server#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_Read_Username       	= <cfqueryparam value="#arguments.LDAP_Read_Username#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_Read_Password        	= <cfqueryparam value="#arguments.LDAP_Read_Password#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_Port                 	= <cfqueryparam value="#arguments.LDAP_Port#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_SSL_Enabled          	= <cfqueryparam value="#arguments.LDAP_SSL_Enabled#" cfsqltype="cf_sql_bit"/>, 
					LDAP_SSL_Port            	= <cfqueryparam value="#arguments.LDAP_SSL_Port#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_Org_Name            	= <cfqueryparam value="#arguments.LDAP_Org_Name#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_Org_Unit_Name       	= <cfqueryparam value="#arguments.LDAP_Org_Unit_Name#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_Issue_Message      	= <cfqueryparam value="#arguments.LDAP_Issue_Message#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_BSA_Issue_Message    	= <cfqueryparam value="#arguments.LDAP_BSA_Issue_Message#" cfsqltype="cf_sql_varchar"/>, 
					LDAP_New_User_Message     	= <cfqueryparam value="#arguments.LDAP_New_User_Message#" cfsqltype="cf_sql_varchar"/>,
					LDAP_Settings_Updated_By  	= <cfqueryparam value="#arguments.LDAP_Settings_Updated_By#" cfsqltype="cf_sql_varchar"/>,
					LDAP_Settings_Updated_Date 	= GETDATE() 
		</cfquery>
		
	</cffunction> 
	

</cfcomponent>