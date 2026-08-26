<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<html>
<head>
	<title>View Growth <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Details</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>

<cfinclude template="/get_access_profile.cfm">

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<cfparam name="url.dis_BB_id" default="">
<cfparam name="url.opr_BB_id" default="">
<cfparam name="url.Growthpullbackamount" default="0">
<cfparam name="url.Growthpullbackvolume" default="0">
<cfparam name="url.appliedpullback" default="0">


<cfif url.dis_BB_id NEQ "" and url.opr_BB_id NEQ "">
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<cfset GetBillbacksDetails = PullbackManager.GetBillbacksDetails(url.opr_BB_id)>
<!--- Get individual product details on Growth for a given Opr or Local Dis BB --->
<cfset GetGrowthDetails = PullbackManager.GetGrowthDetails(url.dis_BB_id,url.opr_BB_id,url.Growthpullbackamount,url.appliedpullback)>
<cfoutput>
<TABLE BGCOLOR="FFE083" CLASS="Maintable" width="770">
<TR>
<TD ID="header"><strong>Billback Id</strong>:#GetBillbacksDetails.BB_Code#
<br>
<strong>Billback Reference</strong>:#GetBillbacksDetails.bb_reference# <br>
<strong>Billback Title</strong>: #GetBillbacksDetails.BB_Title#
</TD>
<TD ID="header" valign="top"><strong>Total #appsettings.getPullbackLabel()# Volume</strong>::#url.Growthpullbackvolume# LBS
<BR><strong>Total #appsettings.getPullbackLabel()# Amount</strong>: #dollarformat(url.Growthpullbackamount)#</TD>
</TR>
</TABLE>
</cfoutput>
 <table width="770" class="maintable" CELLPADDING="0" CELLSPACING="0">
 <tr  bgcolor="C6FFC6">
  <TD id="header" style="font-size: 12px;" valign="top"> <strong>Contract Number</strong>
</td>
 <TD id="header" style="font-size: 12px;" valign="top"> <strong>Item</strong>
</td>
 <TD id="header" style="font-size: 12px;" valign="top"> <strong>Description</strong>
</td>
 <TD id="header" style="font-size: 12px;" valign="top"> <strong>Volume in LB</strong>
</td>
<TD id="header" style="font-size: 12px;" valign="top"> <strong>Pullback Percent</strong>
</td>
 <TD id="header" style="font-size: 12px;" valign="top"> <strong>Pullback Amount</strong>
</td>
 </TR>
 <cfif GetGrowthDetails.recordcount GT 0>
 <cfoutput query="GetGrowthDetails">
 <TR>
  <TD>#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></TD>
 <TD>#Item#</TD>
 <TD>#Description#</TD>
 <TD>#Product_BB_Volume_LB#</TD>
 <TD>#pullback_percent#</TD>
 <TD>#DollarFormat(pullbackamountperproduct)#</TD>
</TR>
</cfoutput>
<cfelse>
<TR><TD>No details available.</TD></TR>
</TABLE>
</cfif>
<cfif GetGrowthDetails.recordcount GT 0>
 <table align="center">
 <tr>
 <td>&nbsp;</td>
 </tr>
 <tr>
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Close"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Close Window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		</tr>
</table>
</cfif>
<cfelse>
 <TR>
 <TD><strong>Invalid Billback Number</strong></TD>
 </TR>
</cfif>
