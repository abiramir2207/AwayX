<!----
/Program_Wizard/index.cfm

Created By: Brenda Flynn
			bflynn@awayx.com
Created On: May 7, 2003
Modified By:
Last Modified On:
-----------------------------
Shows all the details for a program. 
--->

<cfif IsDefined("url.ID")>
	<cfset ID = url.ID>
<cfelse>
	<cfset ID = 0>
</cfif>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif getSPA.Program_Wizard_Index EQ 0>
	<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="yes">
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cfset PAGE_TITLE = "Delete Program Template">

<!--- <html>
<head> --->
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
	
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>
	
</head>

<!---Get all information on a program template--->
<cfquery name="GetAllInfo" datasource="#application.datasource#">
SELECT	Generic_Type,
	Created_Type,
	Program_Description
FROM Program_Control_Panel_Options
WHERE ProgramControl_Panel_Options_ID = #ID#
</cfquery>

<!--- <body leftmargin="0" topmargin="0" bottommargin="0" rightmargin="0">

<cfinclude template="/includes/header.cfm"> --->

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<center>
<BR>

	
<TABLE CELLPADDING="4" CELLSPACING="0" border="0">
<cfoutput query="GetAllInfo">
<tr><td align="center">

<strong>#Created_Type# -- #ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label)#</strong>
<br>
#Program_Description#<br><br>
<hr width="75%" color="orange">

<strong>Are you sure you want to delete this template?</strong><br>
Once you delete a template, users can no longer create programs using it. <br>Existing programs are not affected, and will continue to work correctly.

<form action="delete_action.cfm" method="Post" name="DeleteTemplate">
<input type="hidden" name="ID" value="#ID#">
</form>

<CF_button
			button_name		=	""
			button_caption	=	"Delete This Template Permanently"
			button_action	=	"DeleteTemplate.submit();"
			button_type		=	"javascript_link"
			button_width	=	"450"
			button_color	=	"Navy"
			button_tip		=	"This will PERMANENTLY delete the template"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>	

	</td>
	
	</tr>

</cfoutput>
</TABLE>
<p></p>
<!--- <cfinclude template="/includes/footer.cfm">

</body>
</html> --->