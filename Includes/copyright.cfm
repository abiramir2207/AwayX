<cfset yr = datepart("yyyy",now())>

<!--- Dev Note: Milan 8854: Query the App settings table, as this file is called on the login screen too --->
<cfset useLakebaseForCheckAppSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForCheckAppSetting>
	<cftry>
		<cfset CheckAppSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "app_error_add_to_punchlist"
			}), "app_error_add_to_punchlist"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckAppSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckAppSetting>
<CFQUERY NAME="CheckAppSetting" datasource="#application.datasource#">
SELECT App_Error_Add_To_Punchlist
FROM _Application_Settings
</CFQUERY>
</cfif>

<!--- Get the patch information from "Application_Installation" table --->
		<CFQUERY NAME="getReleaseVersion" datasource="#application.datasource#">
		SELECT TOP 1 LTRIM(RTRIM(Patch_Number)) As Release_Version
		FROM Application_Installation
		ORDER BY Release_Version DESC
		</CFQUERY>

<!--- Add the release info, only if it exists --->
<CFOUTPUT><cfif getReleaseVersion.Release_Version neq "">Version: #getReleaseVersion.Release_Version#.</cfif> Copyright 2000-#yr#, #Application.CompanyNameFull# All Rights Reserved</CFOUTPUT><br><br>
<!--- <CFOUTPUT><cfif getReleaseVersion.Release_Version neq "">Version: #getReleaseVersion.Release_Version#.</cfif> Copyright� 2000-#yr#, #Application.CompanyNameFull# All Rights Reserved.</CFOUTPUT><br><br> --->
<!--- <img src="/images/Logon_Blacksmith/BlacksmithLogoHorizontal.jpg"> --->
<!--- <img src="/images/Logon_Blacksmith/BlacksmithForgeLogo.jpg" hspace="20"> --->

