<cfset ShowDedLink = 0>


<cfif isDefined("url.Billback_ID")>
	<cfset labelSettings         = Createobject("component", "mvc.Models.SettingsService")>
	<cfset variables.VendorLabel = labelSettings.getBBLabels().vendor>
	<cfset url.BBID              = url.Billback_ID>
	<cfset url.byPassCache       = 1>

    <cfinclude template="/billbacks/capture/bb_preview.cfm">
<cfelse>
You have not defined a billback.
</cfif>