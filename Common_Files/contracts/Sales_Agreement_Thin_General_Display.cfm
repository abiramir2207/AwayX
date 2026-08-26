<cfparam name="isTextFormat"  default = "false">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfinclude template="sales_agreement_display_view.cfm">
