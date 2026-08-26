<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Volume_Applicator.cfm
Arguments:
	URL.packetId
returns to calling page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFPARAM NAME="URL.packetId" 	DEFAULT="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Volume Applicator</title>
</head>

<body>

<CFIF URL.packetId NEQ ""><cfsilent>
	<CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>
	<CFSET D_Temp = objVolumeApplicator.loadBasicInformation(URL.packetId)>
	</cfsilent><CFSET D_Temp = objVolumeApplicator.gotoStepOne()>
</CFIF>


</body>
</html>
