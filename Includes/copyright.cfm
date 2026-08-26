<cfset yr = datepart("yyyy",now())>

<!--- Dev Note: Milan 8854: Query the App settings table, as this file is called on the login screen too --->
<CFQUERY NAME="CheckAppSetting" datasource="#application.datasource#">
SELECT App_Error_Add_To_Punchlist
FROM _Application_Settings
</CFQUERY>

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

