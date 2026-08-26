<cfsilent>
<!---
	Name: bus_con_reminders.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
	 	Tools to manage business consideration instructions (evaluation notes, also).
--->	
<cfparam name="form.Business_Considerations_Reminders_Txt" type="string" default="">
<cfparam name="form.business_considerations_reminders_on" type="numeric" default="0">
<cfparam name="form.mode" type="numeric" default="0" />
<cfparam name="pagetitle" default="Business Consideration Reminders">

<!--- Set the Business Consideration Data --->
<cfif form.mode EQ '1'>
	<cfinvoke component="components.settings.BusinessConsiderationsReminder" method="set">
		<cfinvokeargument name="business_considerations_reminders_on" value="#form.business_considerations_reminders_on#">
		<cfinvokeargument name="business_considerations_reminders_txt" value="#rereplace(rereplace(form.business_considerations_reminders_txt,'<p>','','ALL'),'</p>','','ALL')#">
		<cfinvokeargument name="last_saved_by" value="#request.accessstructure.user_id#">
	</cfinvoke>
</cfif>

<!--- Get Business Consideration Reminder Data --->
<cfinvoke component="components.settings.BusinessConsiderationsReminder" method="get" returnvariable="qBizConReminders">
<cfif isdefined("qBizConReminders.last_saved_by")>
	<cfinvoke component="components.user.usermanager" method="getusername" userid="#qBizConReminders.last_saved_by#" returnvariable="SettingsUpdateUser">
</cfif>
</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Business Considerations Reminder</title>
</head>
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
What  I did: Added New Jquery Text Editor WYUIWYG--->
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg.js"></script>
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg-settings.js"></script>
		<script type="text/javascript">
			WYSIWYG.attach('textarea', full);
		</script>
<!--- End Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  --->
<body>

<cfinclude template="/settings/settings_title.cfm">

<!--- Output Last Updated Information --->
<cfif isdefined("qBizConReminders.last_saved_by")>
	<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD align="left" width="600px" style="font-size:12px;">
		<B>Business Consideration Reminders were last updated on <CFOUTPUT>#dateformat(qBizConReminders.last_updated_on, 'm/d/yyy')# #timeformat(qBizConReminders.last_updated_on, 'h:mm:ss TT')# by #SettingsUpdateUser#</CFOUTPUT></B></TD>
	</TD>
	</TR>
	</TABLE>
	<br>
</cfif>

<form id="frmBusConReminder" name="MyForm" action="bus_con_reminders.cfm" method="post">
	<div style="font-weight:600;font-size:13px">Business Considerations - Reminder: 
	<input type="radio" name="business_considerations_reminders_on" value="1" <cfif qBizConReminders.business_considerations_reminders_on EQ 1>CHECKED</cfif>> ON
	<input type="radio" name="business_considerations_reminders_on" value="0" <cfif qBizConReminders.business_considerations_reminders_on EQ 0>CHECKED</cfif>> OFF
	<br /><br />
	<cfif 0 eq 0>
		Business Consideration Reminders Preview:(<A href="javascript:showPreview();"><span style="color:##660033;font-weight:bold;text-decoration:none">preview</span></A>)
		<br /><br />
		<span style="font-weight:600;font-size:13px">Characters Remaining &nbsp;</span>
		<input type="text" SIZE="1" name="CountChars_Login" value="<cfif len(form.Business_Considerations_Reminders_Txt) GT 0><cfoutput>#1200  - len(form.Business_Considerations_Reminders_Txt)#</cfoutput><cfelse>1200</cfif>" disabled="yes">
		<br /><br />
     	<!--- 
    				Dev Notes: D24468/Anand Rao/17-Aug-10
    				URL on email notifications
    	--->  
      <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
    
		<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
		   
			<!---<CF_ACTIVEDIT FIELDNAME="Business_Considerations_Reminders_Txt"
				TOOLBAR="cut,copy,paste,|,undo,redo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers,|,help"
				IMAGEPATH="#REQUEST.APPLICATIONPATH#/images/"
				IMAGEURL="/images/"
				BASEURL="#siteURL#/"
				INC="/Customtags/ActiveEdit/activedit/inc/"
				DEFAULTFONT="10pt Times New Roman"
				QUICKSTYLES="title,header"
				TABVIEW="0"
				ACTIVSCAN="0"
				HEIGHT="280"
				WIDTH="600"
				TYPE="form"
				FIELDLENGTHALLOWED="1200"
				FRMNAME="frmBusConReminder"
				NAMEOFFIELD="CountChars_Login"
				BREAKONENTER="No" >			
					<cfoutput><cfif len(form.business_considerations_reminders_txt) GT 0>#form.business_considerations_reminders_txt#<cfelseif len(qBizConReminders.business_considerations_reminders_txt) GT 0>#qBizConReminders.business_considerations_reminders_txt#</cfif></cfoutput>
				</CF_ACTIVEDIT>--->
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START                
What  I did: Comment out CF_ACTIVEEDIT and replace it with TEXTAREA for WYSIWYG tool--->
<textarea id="textarea" name="Business_Considerations_Reminders_Txt" style="width:610px;height:200px;">
<cfoutput><cfif len(form.business_considerations_reminders_txt) GT 0>#form.business_considerations_reminders_txt#<cfelseif len(qBizConReminders.business_considerations_reminders_txt) GT 0>#qBizConReminders.business_considerations_reminders_txt#</cfif></cfoutput>
</textarea>
<!--- End Dev Note: drachala; D28078:Text Editor tools in Forge not working with Windows 7 END  --->
	
	<cfelse>
		<CFOUTPUT>
		<input type="hidden" name="Business_Considerations_Reminders_Txt" value="#form.business_considerations_reminders_txt#">
		</CFOUTPUT>
	</cfif>
			<!--- Used this to mimic the submission of a form through the clicking of a submit button.
						ActiveEdit works only by clicking on the submit button --->
			<input type="hidden" name="mode" value="1">
			<input type="submit" name="save" value="Save" style="visibility:hidden;" />
			<!--- End Note: Milan; 9879 ---> 
			<div align="center">
			
			 	<CF_button
						button_name		=	""
						button_caption	=	"Save"
						button_action	=	"javascript:document.all.frmBusConReminder.save.click()"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Save"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						>
			</div>
			
			<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
			<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
			<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
		
		<script type="text/javascript" language="JavaScript">
			function showPreview(){
				NewWindow('bus_con_reminders_preview.cfm','login_Page',900,600,'yes','yes');
			}
		</script>
	</div>
</form>
</body>
</html>
