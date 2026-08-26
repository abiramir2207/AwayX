 <div align="center"><font size="2" color="red"> SENDING DATA TO SAP, PLEASE CHECK LATER!!!!.</font> </div>

<!------ Get application settings ----->
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<cfset PathToExe 	= ExpandPath("\Utils\BSA_HTTP.exe")>
<cfset outputpath 	= ExpandPath("\Utils\Output\#url.bsa_program_id#.html")>
<cfset InputFile="url=http://#appSettings.getWebserverInternalIPAddress()#/Scheduled/automated_rebate_children.cfm?bsa_program_id=#url.bsa_program_id#&SMPROFILE=NO outputpath=#outputpath#">

<cfexecute
      name="#PathToExe#"
      arguments="#InputFile#">
</cfexecute>

<script>
window.setTimeout('window.close();', 5000);
</script>