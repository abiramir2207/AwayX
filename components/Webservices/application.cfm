	<cfinclude template="/Application_Datasource.cfm">
		
	<cfscript>
		request.app_general_functions = CreateObject("component","components.general.General_Functions");
	</cfscript>
	
	<CFINCLUDE TEMPLATE="/get_App_Path.cfm">
	
	<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
	<cfset key = request.app_general_functions.GenerateKey() />