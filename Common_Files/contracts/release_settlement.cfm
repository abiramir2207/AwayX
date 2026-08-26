<cfparam name="URL.CID" default="0">
<cfparam name="Form.ListContractMainID" default="">
<cfparam name="Form.FromFlex" default="0">
<cfparam name="Form.FromAGGrid" default="0">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">

<cfif isdefined("cryp.value") AND len(cryp.value) NEQ 0>
	<cfset url.cid = cryp.value />
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Release Settlement</title>
</head>

<body>
<div style="font-size:14px;font-weight:bold;">Release Settlement</div>
<hr style="width:350px;color:orange;" align="left">
<table style="min-width:300px;width:300px;">
<tr><td>Release program(s) and set release date = today (<cfoutput>#dateformat(now(),"MM/DD/YYYY")#</cfoutput>)?</td></tr>
<tr>
	<td align="center">
	<CF_button  button_name		=	"releaseProgram"
				button_caption	=	"release program(s)"
				button_action	=	"document.releaseSettlementForm.submit();"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Release Program(s) for Final Settlement"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold" >
	</td>
</tr>
</table>
<p>
<form name="releaseSettlementForm" action="release_settlement_action.cfm" method="post">
	<cfif Form.ListContractMainID neq "">
	<input type="hidden" name="ListContractMainID" value="<cfoutput>#Form.ListContractMainID#</cfoutput>">
	<input type="Hidden" name="FromFlex" value="<cfoutput>#Form.FromFlex#</cfoutput>" />
	<input type="Hidden" name="FromAGGrid" value="<cfoutput>#Form.FromAGGrid#</cfoutput>" />
	<cfelse>
	<input type="hidden" name="CID" value="<cfoutput>#URL.CID#</cfoutput>">
	</cfif>
	<input type="submit" style="display:none;">
</form>
</p>
</body>
</html>
