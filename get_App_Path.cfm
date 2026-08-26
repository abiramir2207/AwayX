
<cfif not isDefined("request.app_general_functions")>
	
	<!---initialize general functions to be used throuhout the application--->
	<cfset request.app_general_functions = CreateObject("component","components.general.General_Functions") />
	
</cfif>

<cfscript>
	param name="application.appPath" default=expandpath("/");

	variables.APPPATH = application.appPath;
	variables.APPLICATIONPATH = variables.APPPATH;
	request.APPLICATIONPATH = variables.APPPATH;
</cfscript>
