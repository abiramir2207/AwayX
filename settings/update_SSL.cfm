<!--- Update the setting to the opposite and set "last changed by --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get(1, 2, 1)>

<cfparam name="NewVariableValue" default = 0>

<Cfif appSettings.getSSL_on() IS 0>
	<cfset NewVariableValue = 1>
</CFIF>

		<!------ update ----->
		<cfquery name="qUpdateSettings" datasource="#application.datasource#">
			UPDATE	_Application_Settings
			SET		SSL_On = #NewVariableValue#,
					<!----- leave this blank space above ----->
					Internal_Settings_Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					Internal_Settings_Updated_On = GetDate()								
		</cfquery>

		<cfset useLakebaseForGetCurrentSSL = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetCurrentSSL>
	<cftry>
		<cfset GetCurrentSSL = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "ssl_on"
			}), "ssl_on"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrentSSL = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrentSSL>
<cfquery name="GetCurrentSSL" datasource="#application.datasource#">
		SELECT SSL_On
		FROM _Application_Settings
		</cfquery>
</cfif>

		
<!--- rewrite index.htm --->

<cfsavecontent variable="NewHTMLPage">
<!-- UPDATED FROM /settings/update_SSL.cfm -- do not modify this file -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"><HTML><HEAD><TITLE>Welcome To Blacksmith Applications, Inc.</TITLE></HEAD>
<BODY>
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
		function Is ()
		{   
			
			var checkFor = "MSIE";
			var MSIEIndex = navigator.appVersion.indexOf(checkFor);
			this.version = parseFloat(navigator.appVersion.substring(MSIEIndex + checkFor.length, (navigator.appVersion.length)));
		}
		var isHttps = <cfif NewVariableValue IS 1>true<cfelse>false</cfif>;
		function checkVersion()
		{
			var is = new Is();
			if(is.version < 5.5)
			{		
				window.location.href = '/getie.cfm';
			}
			else
			{
				//window.location.href = '/index2.htm';
				if(isHttps)
				{
					window.location.href = "https://" + location.hostname + "/index2.cfm"
				}
				else
				{
					window.location.href = "http://" + location.hostname + "/index2.cfm"
				}
			}
		}
		checkVersion();
	</SCRIPT>
</BODY>
</HTML>


</cfsavecontent>


<cfinvoke component="components.general.General_Functions" method="Get_Application_Path" returnVariable="AppPath">


<cffile action = "delete"
  file = "#appPath#\index.htm"> 


<cffile action="WRITE" 
		file="#appPath#\index.htm"
		nameconflict="OVERWRITE"
		output="#NewHTMLPage#"		
>


<!--- confirm to user action is complete --->
The SSL settings have beend updated. You can close this window.