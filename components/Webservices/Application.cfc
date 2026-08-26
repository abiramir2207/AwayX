<cfcomponent>

<!--- extends="Application" --->

<!---include the app_name.cfm so we can update this file once for all env's
		app_name sets application name, session, and client management	--->
<cfinclude template="/AppName.cfm" />

<!---no need to use cflock inside onApplicationStart--->

<cffunction name="onApplicationStart">
   <cftry>
         <!---We need the datasource first!  It is in first line of Application_Vars.cfm --->
		<cfinclude template="/Application_Vars.cfm">
      <cfcatch type="database">
         <cfoutput>
            This application encountered an error.<br>
            Application startup has failed
         </cfoutput>
         <cflog file="#This.Name#" type="error" 
            text=	"Sub app in **  Scheduled  ** startup failed. message: #cfcatch.message# 
            		Detail: #cfcatch.detail# Native Error: #cfcatch.NativeErrorCode#">
         <cfreturn False>
      </cfcatch>
   </cftry>
   <cflog file="#This.Name#" type="Information" text="Application Started">

   <!--- You do not need to return True if you don't set the cffunction returntype attribute. --->
 </cffunction>

<!---<cffunction name="onApplicationEnd">
   <cfargument name="ApplicationScope" required=true/>
   <cflog file="#This.Name#" type="Information" 
      text="Application #ApplicationScope.applicationname# Ended">
</cffunction>--->

<cffunction name="onSessionStart">
	<CFPARAM NAME="Session.DoNotRunThisApplicationCFM" DEFAULT="0">
</cffunction>

<cffunction name="onRequestStart" access="public"> 
	<cfset application.oApplicationAppSettingsManager = CreateObject("component", "components.settings.ApplicationAppSettingsManager").init() />
	<!---initialize general functions to be used throuhout the application--->
	<cfscript>
		request.app_general_functions = CreateObject("component","components.general.General_Functions");
	</cfscript>
	
	<CFINCLUDE TEMPLATE="/get_App_Path.cfm">
	
	<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
	<cfset key = request.app_general_functions.GenerateKey() />
</cffunction>

</cfcomponent>
