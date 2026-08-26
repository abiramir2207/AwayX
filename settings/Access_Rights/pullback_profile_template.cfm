<!-----      
		Name: 			pullback_profile_template.cfm     
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/02/2006
						Deepa Kunnath
		Last Modified:
						03/02/2006   
						Deepa Kunnath  
		Description:
                       This page allows administrators to view and edit the list of templates each profile can approve
					   Will be called from inside the profile settings section.
		Parameters:
                       profileId - ID of the the current profile that is getting edited
		Usage:
                       pullback_profile_template.cfm?profileId=6
----->
<cfparam name="url.profileId" 	default="">
<cfif NOT isNumeric(url.profileId) OR url.profileId EQ 0>
	<cfabort>
</cfif>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset sProfileName = CreateObject("component", "components.user.Profile").getProfileName(url.profileId)>
<!------ get the list of profiles ----->
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset qGetProfileTemplates = templateManager.getProfileTemplates(
				profileId = url.profileId,
				forbidAccessType = 6,
				returnNewProfileEntry = 1
				) />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput><title>#appSettings.getPullbackLabel()# templates for #sProfileName#</title></cfoutput>
</head>

<body>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>	

<font COLOR="Navy" SIZE="+1">
<cfoutput>#appSettings.getPullbackLabel()# templates for #sProfileName#</cfoutput>
</font>
<HR COLOR="orange">
<table cellpadding="5" cellspacing="0" align="center">
<tr>
	<td><B>Approval</B> <input type="Checkbox" name="checkAll">
	<CF_smallLink 
		title = "apply all" 
		url = "##"
		parameters = "onClick=""javascript: CHSelectAll('pullbackApproveTemplateList', document.all.checkAll.checked);return false;"""
	>
	</td>
</tr>
</table>
<cfset maxCols = 2>
<form method="post" name="frmPullbackProfileTemplate" action="pullback_profile_template_action.cfm">
<table align="center" cellpadding="3" cellspacing="1" bgcolor="c0c0c0" width="80%" border="0">
	<thead bgcolor="c0c0c0">
		<cfloop index="i" from="1" to="#maxCols#">
		<td align="center" width="200"><B>Template</B></td>
		<td align="center"><B>Approve</B></td>
		</cfloop>
	</thead>
	
	<cfoutput query="qGetProfileTemplates" group="Generic_type">
		<tr bgcolor="91C0FB">
		<td colspan="100%"><strong>#Generic_Type#</strong></td>
		</tr>
		<cfset rowCounter = 0 />
		<tr bgcolor="FFFFFF">
		<cfoutput>
		<cfset rowCounter = rowCounter + 1 />
		<cfset bgColor = "">
		<cfif Approve EQ 1>
			<cfset bgColor = "ffdead">
		</cfif>
		<td bgcolor="#bgColor#">#created_type#</td>
		<td bgcolor="#bgColor#"><input type="checkbox" value="#Template_ID#" name="pullbackApproveTemplateList"<cfif Approve EQ 1> checked</cfif>>&nbsp;</td>
		<cfif not rowCounter mod maxCols and rowCounter neq recordCount></tr><tr bgcolor="FFFFFF"></cfif>		
		</cfoutput>
		<cfif Evaluate((rowCounter mod maxCols)) NEQ 0>
		<cfloop index="i" from="#Evaluate((rowCounter mod maxCols)+1)#" to="#maxCols#">
		<td bgcolor="">&nbsp;</td><td bgcolor="">&nbsp;</td>
		</cfloop>
		</cfif>
		</tr>
	</cfoutput>
	
	
</table>
<cfoutput><input type="Hidden" name="profileId" value="#url.profileId#" /></cfoutput>

</form>
<br>
<div align="center">
	<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"save"
		BUTTON_ACTION	=	"document.frmPullbackProfileTemplate.submit();"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
</div>

</body>
</html>
