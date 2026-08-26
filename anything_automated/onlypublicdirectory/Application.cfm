<!---Sets datasource name--->
<cfinclude template="/application_datasource.cfm">

<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

<cfset application.oApplicationAppSettingsManager = CreateObject("component", "components.settings.ApplicationAppSettingsManager").init() />

<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
<cfset key = request.app_general_functions.GenerateKey() />
<cfset request.key = key />

<!--- 
	47557: Util.String event error on automated backend task/Anand Rao/20-Jan-2015 
		   Error was thrown as application.util was not initialized earlier	
 --->
<cfif StructKeyExists(URL, 'resetUtil') or not StructKeyExists(application, 'util')>
	<cflock timeout="20" scope="Application" type="exclusive" throwontimeout="true">
		<cfset application.util = CreateObject("component", "components.UtilManager").init()>
	</cflock>
</cfif>