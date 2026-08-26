<!---Sets datasource name--->
<cfinclude template="/application_datasource.cfm">

<!---initialize general functions to be used throuhout the application--->
<cfscript>
	request.app_general_functions = CreateObject("component","components.general.General_Functions");
</cfscript>

<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
<cfset key = request.app_general_functions.GenerateKey() />
<cfset request.key = key />