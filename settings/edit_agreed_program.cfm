<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
	<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "PROGRAMS: MODIFY AGREE PROGRAM">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset ThisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmEditAgreedProgram">
<cfparam name="form.command" 	default="">
<cfparam name="form.edit_basic_info" default="0">
<cfparam name="form.edit_operators" default="0">
<cfparam name="form.edit_opr_basinfo" default="0">
  <cfset ProgramManager = CreateObject("component","components.programs.programmanager") />
<cfif form.command EQ "save">
		<cfset ProgramManager.saveEditAgreedProgramSettings(form)>
</cfif>


 <cfset getagreedtprogramsettings = ProgramManager.getagreedtprogramsettings()>

<cfoutput><form name="#formName#" method="post" action="#ThisPage#" style="display:inline;">
<cfset otherChkDisabled = "">
<cfif getagreedtprogramsettings.edit_opr_basinfo EQ 1>
	<cfset otherChkDisabled = " DISABLED">
</cfif>
<table cellpadding="4" cellspacing="0" border="0" class="MainTable" width="100%">
		<tr bgcolor="FFCE84" valign="bottom">
		<td style="font-size: 12px;" align="Left"><span id="error_Approval_Metrics"></span><B>Edit Mode </B></td>
		<td style="font-size: 12px;" align="center"><div align="left"><B>Program Pages</B></div></td>
		</tr>
		<tr>
		<td align="left" style="font-size: 12px;"> <input type="checkbox" name="edit_basic_info" value="1" <cfif getagreedtprogramsettings.edit_basic_info EQ 1>checked</cfif> #otherChkDisabled#></td>
		<td style="font-size: 12px;">Basic Info
		<br><span style="font-style:italic;color:green;">Place a check mark to make Basic Info page available after RFA</span>
		</td>
		</tr>
		<tr>
		<td align="left" style="font-size: 12px;"> <input type="checkbox" name="edit_operators" value="1" <cfif getagreedtprogramsettings.edit_operators EQ 1>checked</cfif> #otherChkDisabled#></td>
		<td style="font-size: 12px;">#application.returned_customer_setting.operator_label_plural#
		<br><span style="font-style:italic;color:green;">Place a check mark to make #application.returned_customer_setting.operator_label_plural# page available after RFA</span>
		</td>
		</tr>
		<tr>
		<td align="left" style="font-size: 12px;"> <input type="checkbox" name="edit_opr_basinfo" value="1" <cfif getagreedtprogramsettings.edit_opr_basinfo EQ 1>checked</cfif>  onClick="changeDisableOtherCheckBoxes(this,this.form.edit_basic_info);changeDisableOtherCheckBoxes(this,this.form.edit_operators);"></td>
		<td style="font-size: 12px;">No changes to Basic Info and #application.returned_customer_setting.operator_label_plural# in RFA status
		<br><span style="font-style:italic;color:green;">Place a check mark to make Basic Info and #application.returned_customer_setting.operator_label_plural# pages disabled after RFA</span>
		</td>
		</tr>
</TABLE>
<input type="hidden" name="command" value="#form.command#">
</form></cfoutput>

<table align="left" width ="100%" id="oTableButton" border="0" cellpadding="4" cellspacing="0">
		<tr>
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Save and Continue"
			button_action	=	"submitForm(document.#formName#, 'save');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save and Continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
	</tr>
<TR><TD>&nbsp;</TD></TR>
<TR>
<TD style="font-style:italic;color:green;font-size: 12px;">
<cfoutput>
 If all the settings are not checked, a user cannot make changes to either the Basic Info or #application.returned_customer_setting.operator_label_plural# pages after the program has been submitted for approval, requires a user to click on the ‘Modify Agree’ link in the margin page in order to make changes to the pages.
</cfoutput>
</TD>
</TR></table>
<SCRIPT SRC="/common_files/scripts/demenu.js"></SCRIPT>
		<script>
function changeDisableOtherCheckBoxes(thisObj, OtherObj)
{
	OtherObj.disabled = (thisObj.checked);
}
function submitForm(thisForm, sCommand)
	{
thisForm.command.value = sCommand;
thisForm.submit();
return false;
	}
findselectboxes();
</script>

