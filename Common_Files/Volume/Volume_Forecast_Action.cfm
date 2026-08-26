
<CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>

<CFPARAM NAME="Form.packetId" 	DEFAULT="">

<CFIF Form.packetId NEQ "">
	<CFSET D_Temp = objVolumeApplicator.loadBasicInformation(Form.packetId)>
	<CFSET D_Temp = objVolumeApplicator.doForecast(request.AccessStructure)>
</CFIF>

<CFLOCATION ADDTOKEN="No" URL="Volume_Applicator.cfm?#objVolumeApplicator.pass_url#">