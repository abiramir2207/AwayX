<!---
Document		:	/Settings/Operating_group/index.cfm
Author			:	Deepa Kunnath
Date Created	:	Jan 17, 2005
Purpose			:	Entry point for Operating Group related settings
Arguments		:	
Called from		: 
					/Settings/settings_frame_toc.cfm
					/Settings/settings_frame_mainwindow.cfm
--->
<cfsetting enablecfoutputonly="Yes">
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////  Config information ///////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset operatingGroupManager = CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
<cfset operatingGroupLabels = operatingGroupManager.getOperatingGroupLevels()>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////  Command Variables ///////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<CFPARAM NAME="url.command" DEFAULT="displayList">
<CFPARAM NAME="form.command" DEFAULT="#url.command#">
<CFPARAM NAME="url.level" DEFAULT="#operatingGroupLabels.Operating_Group_Level_ID#">
<CFPARAM NAME="form.level" DEFAULT="#url.level#">
<CFPARAM NAME="form.id" DEFAULT="0">
<CFPARAM NAME="form.returnCommand" DEFAULT="">

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////  Temporary Variables ///////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset formName = "OperatingGroupDataForm" />
<cfset operatingGroupLabel = operatingGroupManager.getLabel(form.level)>
<CFSET PAGETITLE = "PROGRAMS: #operatingGroupLabel#">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" SRC="operating_group.js"></SCRIPT>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfinclude template="operating_group_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="#formName#">

<CF_smallLink 
	title = "add" 
	url = "##"
	parameters = "onClick=""javascript: return submitForm('#form.level#', 'ceForm', 0, 'displayList');"""
>
<HR COLOR="Orange">

	
				
<cfswitch expression="#form.command#">
	
	<cfcase value="ceForm">
		<cfinclude template="operating_group_create_edit.cfm" />
	</cfcase>
	
	<cfcase value="save">
		<cfinclude template="operating_group_save.cfm" />
	</cfcase>
	
	<cfcase value="dactivate">
		<!--- save operating group --->
		<cfset operatingGroupManager.activateDeactivate(form.id, 0) />
		<cflocation url="index.cfm?level=#form.level#&command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="activate">
		<!--- save operating group --->
		<cfset operatingGroupManager.activateDeactivate(form.id, 1) />
		<cflocation url="index.cfm?level=#form.level#&command=#form.returnCommand#" />
	</cfcase>
	
	<cfcase value="cancel">
		<cflocation addtoken="No" url="index.cfm?level=#form.level#&command=#form.returnCommand#">
	</cfcase>			
	
	<cfdefaultcase>
		<cfinclude template="operating_group_list.cfm" />
		<cfset form.id = 0 />
	</cfdefaultcase>
	
</cfswitch>			

	



<!---hidden form fields--->
<input name="level" type="hidden" value="#form.level#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="id" type="hidden" value="#form.id#" />
<input name="returnCommand" type="hidden" value="#form.returnCommand#" />

</FORM>

</BODY>
</HTML>
</cfoutput>