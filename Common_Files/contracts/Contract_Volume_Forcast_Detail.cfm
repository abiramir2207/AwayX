<!------Contract_Volume_Forcast_Detail.cfm----->

<CFPARAM NAME="URL.CID" 	DEFAULT="">
<CFPARAM NAME="URL.PID" 	DEFAULT="">
<CFIF Len(URL.CID) EQ 0 OR Len(URL.PID) EQ 0>
	<CENTER><FONT COLOR="Red" SIZE="+2"><B>Invalid information</B></FONT></CENTER>
</CFIF>
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET Program_ID = cryp.value>

<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ContractVolume")>
<CFSET D_Temp = Program_Volume.Load_Basic_Information(Program_ID)>


<HTML>
<HEAD>
<TITLE>Forecast Detail</TITLE>
</HEAD>

<BODY>
<CFSET D_Temp = Program_Volume.Show_Program_Info()>
<CFSET D_Temp = Program_Volume.Load_Forecast_Summary(1)>
<CFSET D_Temp = Program_Volume.Load_Forecast_Detail(URL.PID)>

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