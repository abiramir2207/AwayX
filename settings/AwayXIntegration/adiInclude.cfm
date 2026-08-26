<!-----adiInclude.cfm------->

<CFIF NOT isDefined("DICommon_IncludeFile")>
	<CFINCLUDE template="../dataintegration/diCommon.cfm">
</CFIF>

<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif getSPA.dataintegration EQ 0>
	<CFLOCATION addtoken="No" url="/">
	<CFABORT>
</CFIF>

<CFPARAM NAME="ADI_IncludeFile" DEFAULT="true">
<CFPARAM NAME="URL.pageTitle" DEFAULT="Personal Settings: #application.CompanyName# Data Integration">

<CFSCRIPT>
mainPage="index.cfm";
</CFSCRIPT>