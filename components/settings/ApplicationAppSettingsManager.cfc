<cfcomponent hint="Application AppSettings Manager" extends="components.Base">


	<cffunction name="init" output="false" returntype="components.settings.ApplicationAppSettingsManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="loadApplicationAppSettings" output="false" returnType="void">

		<cfset var GenSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>

		<cfset var appSettings = GenSettings.get(reload = 1) />

	    <cflock scope = "Application"  timeout = "15" type = "Exclusive">
				<cfset application.appSettingsGet = appSettings />
		</cflock>
		<!--- 
			Reload appsetting values that are stored in the application scope based on _Settings.input_name or _application_Settings.Column_Name 
				- components.util.query.cfc (application.util.query) uses these values in get_Setting() function.  using the application scope prevents unneeded trips to the DB
				- util.query.application_settings() reloads the struct application._app_settings which ill be used by furure calls to get_Setting()
		--->
		<cfscript>
			if (not structKeyExists(application, 'util')) {
                lock timeout="15" scope="Application" type="exclusive" throwontimeout="true" {
                    if (not structKeyExists(application, 'util')) {
                        application.util = CreateObject("component", "components.UtilManager").init();
                    }
                }
            }
            lock timeout="15" scope="Application" type="exclusive" throwontimeout="true" {
				application.util.query.application_settings();
			}
		</cfscript>

	</cffunction>

	<cffunction name="getApplicationAppSettings" output="false" returnType="components.settings.ApplicationSettings">

		<cfif NOT IsDefined("application.appSettingsGet")>
			<cfset loadApplicationAppSettings() />
		</cfif>

		<cfreturn application.appSettingsGet />

	</cffunction>


</cfcomponent>