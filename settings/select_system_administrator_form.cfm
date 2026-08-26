<CFQUERY NAME="getCurrentAdmin" datasource="#application.datasource#">
	SELECT *
	FROm _Users
	WHERE Is_System_Administrator = 1
</CFQUERY>

<CFQUERY NAME="getAllUsers" datasource="#application.datasource#">
	SELECT *
	FROM _Users
	WHERE Deleted = 0
	ORDER BY NAME_FIRST
</CFQUERY>

<CFQUERY name="GetOperatorAdmin" datasource="#application.datasource#">
	SELECT 	Operator_Admin_ID, Pricing_Admin_ID
	FROM 	General_Settings
</CFQUERY>

<cfset Operator_Admin_ID 	= GetOperatorAdmin.Operator_Admin_ID>
<cfset Pricing_Admin_ID 	= GetOperatorAdmin.Pricing_Admin_ID>

<CFQUERY NAME="Get_Editor_Info" DATASOURCE="#application.datasource#">
	SELECT	_Users.Name_First + ' ' + _Users.Name_Last AS Editor_Name, System_Admin_Edited_Date
	FROM	System_Admin_Settings
			INNER JOIN _Users
			ON
			_Users.User_ID = System_Admin_Settings.System_Admin_Editor_ID
</CFQUERY>


<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFSET PAGE_TITLE= "">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script>
		function verifyData() {
			ErrorCount=0;
			
			if(document.all.Sysytem_Admin_ID.selectedIndex<0){
				ErrorCount++;
				queueMessage("Please select a system administrator", document.all.error_Admin);
			}
			else {
				clearQueue(document.all.error_Admin);
			}
			
			if(document.all.Contact_Admin_ID.selectedIndex<0){
				ErrorCount++;
				queueMessage("Please select a contact person", document.all.Contact_Email_Admin);
			}
			else {
				clearQueue(document.all.Contact_Email_Admin);
			}	
			
			if(ErrorCount == 0){
				document.all.MyForm.submit();
			}
			else {
				showMessageWindow()
			}
		}
	</script>
	
	<cf_messagewindow>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" ONLOAD="" ONBEFOREUNLOAD="">
<CFSET PageTitle="SELECT SYSTEM ADMINISTRATOR">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"><BR/><BR/><!--- Dev Note: KAL; D7432 --->
<!------------------
<cfif getCurrentAdmin.recordcount EQ 0>
	<CFSET SystemAdminName = "None Assigned">
<CFELSE>
	<CFSET SystemAdminName = getCurrentAdmin.Name_First & " " & getCurrentAdmin.Name_Last>
</cfif>

<FORM ACTION="select_system_administrator_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<TABLE>
	<TR>
		<TD ALIGN="right">Current System Administrator:</TD>
		<TD STYLE="color: red; font-weight: bold;"><CFOUTPUT>#SystemAdminName#</CFOUTPUT></TD>
	</TR>
	<TR>
		<TD ALIGN="right"><span ID="error_Admin"></span>&nbsp;Re-Assign:</TD>
		<TD>
			<SELECT NAME="Sysytem_Admin_ID">
				<OPTION VALUE="0">Select One...</OPTION>
				<CFOUTPUT QUERY="getAllUsers">
					<OPTION VALUE="#getAllUsers.User_ID#">#getAllUsers.Name_First#&nbsp;#getAllUsers.Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD>&nbsp;</TD>
		<TD>
		
		<BR>
		<BR>
		
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"save"
			BUTTON_ACTION	=	"javascript:verifyData();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	""
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">		
		</TD>
	</TR>
</TABLE>
</FORM>
----->

<cfif getCurrentAdmin.recordcount EQ 0>
	<CFSET SystemAdminName = "None Assigned">
<CFELSE>
	<CFSET SystemAdminName = getCurrentAdmin.Name_First & " " & getCurrentAdmin.Name_Last>
</cfif>
<CFIF Get_Editor_Info.RecordCount GT 0>
<CFOUTPUT>
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3" ALIGN="CENTER" STYLE="border:2px orange solid;">
	<TR>
	<TD STYLE="font-weight:bold;font-size:13px;">This setting was last updated on #DateFormat(Get_Editor_Info.System_Admin_Edited_Date, "mm/dd/yyyy")# #TimeFormat(Get_Editor_Info.System_Admin_Edited_Date, "hh:mm:ss tt")# by #Get_Editor_Info.Editor_Name#</TD>
	</TR>
</TABLE>
<br />
</CFOUTPUT>
</CFIF>
<FORM ACTION="select_system_administrator_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" ALIGN="center">
	<TR>
		<TD ALIGN="right" STYLE="font-weight: bold;">Current System Administrators:</TD>
		<TD ROWSPAN="2">&nbsp;&nbsp;</TD>
		<TD ROWSPAN="2" BGCOLOR="Navy"><IMG SRC="/Images/fill.gif" WIDTH="1"></TD>
		<TD ROWSPAN="2">&nbsp;&nbsp;</TD>
		<TD ALIGN="right" STYLE="font-weight: bold;" WIDTH="200"><span ID="error_Admin"></span>&nbsp;Re-Assign System Administrators:</TD>
		<TD ROWSPAN="2">&nbsp;&nbsp;</TD>
		<TD ROWSPAN="2" BGCOLOR="Navy"><IMG SRC="/Images/fill.gif" WIDTH="1"></TD>
		<TD ROWSPAN="2">&nbsp;&nbsp;</TD>
		<TD ALIGN="right" STYLE="font-weight: bold;" WIDTH="200"><span ID="Contact_Email_Admin"></span>&nbsp;Contact Person:</TD>
		
	</TR>
	<TR VALIGN="top">
		<TD>
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
		<CFOUTPUT QUERY="getCurrentAdmin">
		<TR>
			<TD STYLE="color: blue; font-weight: bold;">#Name_First# #Name_Last#</TD>
		</TR>
		</CFOUTPUT>
		</TABLE>
		</TD>
		<TD>
			<SELECT NAME="Sysytem_Admin_ID" SIZE="15" MULTIPLE STYLE="width:200px;">
				<CFOUTPUT QUERY="getAllUsers">
					<OPTION VALUE="#getAllUsers.User_ID#"<CFIF Is_System_Administrator EQ 1> SELECTED</CFIF>>#getAllUsers.Name_First#&nbsp;#getAllUsers.Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
		<TD>
			<SELECT NAME="Contact_Admin_ID" STYLE="width:200px;">
				<OPTION VALUE="0">Select One...</OPTION>
				<CFOUTPUT QUERY="getAllUsers">					
					<OPTION VALUE="#getAllUsers.User_ID#"<CFIF Contact_Administrator EQ 1> SELECTED</CFIF>>#getAllUsers.Name_First#&nbsp;#getAllUsers.Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>
			
		
			<cfif appSettings.getAllowed_To_Add_Operator() IS 0 OR appSettings.getAllowed_To_Add_Operator() IS 2>
			<BR>
			<b><div align="right">Operator Administrator:</div></b>
			<SELECT NAME="Operator_Admin_ID" STYLE="width:200px;">
				<OPTION VALUE="0">Select One...</OPTION>
				<CFOUTPUT QUERY="getAllUsers">					
					<OPTION VALUE="#getAllUsers.User_ID#"<CFIF Operator_Admin_ID EQ getAllUsers.User_ID> SELECTED</CFIF>>#getAllUsers.Name_First#&nbsp;#getAllUsers.Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>
			
			<cfelse>
				<input type="hidden" name="Operator_Admin_ID" value="">
			</cfif>
			
			<cfif appSettings.getPgmEmailPricingAdmin() EQ 1>
			<BR>
			<b><div align="right">Pricing Administrator:</div></b>
			<SELECT NAME="Pricing_Admin_ID" STYLE="width:200px;">
				<OPTION VALUE="">Select One...</OPTION>
				<CFOUTPUT QUERY="getAllUsers">					
					<OPTION VALUE="#getAllUsers.User_ID#"<CFIF Pricing_Admin_ID EQ getAllUsers.User_ID> SELECTED</CFIF>>#getAllUsers.Name_First#&nbsp;#getAllUsers.Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>			
			</cfif>
			
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="4"></TD>
		<TD><font COLOR="red">Press ctrl and click to select multiple items</font></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="center">		
		<BR>
		<BR>
		
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"save"
			BUTTON_ACTION	=	"javascript:verifyData();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	""
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">		
		</TD>
	</TR>
</TABLE>
</FORM>

</BODY>
</HTML>
