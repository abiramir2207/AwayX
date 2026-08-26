
<cfparam name="user_id" default="">
<cfparam name="autorenew" default="0">

<!------ Get application settings ----->
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<cfif isdefined("request.AccessStructure.user_id") and request.AccessStructure.user_id NEQ "">
	<cfset user_id = #request.AccessStructure.user_id#>
	 
 <div align="center"><font size="2" color="red"> SENDING DATA TO SAP, PLEASE CHECK LATER!!!!.</font> </div>
</cfif>

<cfset PathToExe 	= ExpandPath("\Utils\BSA_HTTP.exe")>
<cfset outputpath 	= ExpandPath("\Utils\Output\#program_id#.html")>
<cfset InputFile="url=http://#appSettings.getWebserverInternalIPAddress()#/Scheduled/send_scheduled_data_to_sap.cfm?program_id=#program_id#&user_id=#user_id#&is_autorenew=#autorenew#&SMPROFILE=NO outputpath=#outputpath#">

<cfexecute
      name="#PathToExe#"
      arguments="#InputFile#">
</cfexecute>
<!--- <cfabort> --->