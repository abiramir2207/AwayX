<!------ 
File: Application_AppSettingsMan.cfm
Purpose: load application settings into the application scope
To use the application variable always use : <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
----->
<cfset application.oApplicationAppSettingsManager.loadApplicationAppSettings() />
