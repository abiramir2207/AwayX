<!------Contract_Volume_Forcast_Detail.cfm----->

<CFPARAM NAME="URL.packetID" 	DEFAULT="">
<CFPARAM NAME="URL.PID" 	DEFAULT="">
<CFIF Len(URL.packetID) EQ 0 OR Len(URL.PID) EQ 0>
	<CENTER><FONT COLOR="Red" SIZE="+2"><B>Invalid information</B></FONT></CENTER>
</CFIF>

<HTML>
<HEAD>
<TITLE>Forecast Detail</TITLE>
</HEAD>

<BODY>

<CFSET PW_Type = "volume_applicator">
<CFINCLUDE template="/includes/call_please_wait.cfm">

<CFSET objVolumeApplicator = CreateObject("component", "components.volume.VolumeApplicator")>
<CFSET objVolumeApplicator.loadBasicInformation(URL.packetID)>
<CFSET objVolumeApplicator.Window_Max_Width = "700">
<CFSET objVolumeApplicator.showAppAreaInfo()>
<CFSET objVolumeApplicator.showForecastBasicInfo()>
<CFSET objVolumeApplicator.showForecastDetail(URL.PID)>

<BR><BR>
<DIV ALIGN="center">
<CF_button
	button_name		=	""
	button_caption	=	"close this window"
	button_action	=	"window.close();"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"close this window"
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>
</DIV>	
<BR><BR>

</BODY>
</HTML>