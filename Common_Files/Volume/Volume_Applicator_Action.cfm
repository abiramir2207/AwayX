<!------ Volume_Applicator_Action.cfm ----->

<CFPARAM NAME="FORM.packetId" 	DEFAULT="">

<CFIF FORM.packetId NEQ "">
	<CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>
	<CFSET D_Temp = objVolumeApplicator.loadBasicInformation(FORM.packetId)>
	<CFSET D_Temp = objVolumeApplicator.saveProductVolume()>
</CFIF>