<!----
/settings/Settings_Management/Settings_ProgramTemplate_Exception.cfm
Created By: Jianxiu
Created On: Sep 10, 2010
Modified By: 
Last Modified On: 
--->

<cfset Generic_Type = URL.Generic_Type>
<cfset Setting_ID = URL.Setting_ID>
<cfset Setting_Name = URL.Setting_Name>
<cfparam name="URL.SettingDisplayValueInTable" default="" />
<cfparam name="URL.SettingDisplayValueInTableID" default="0" />
<cfset Form.StatusSave ="0">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfset PAGE_TITLE = "Program Template Exception">

<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
	.showOptions { display: ; }
	.hideOptions { display: none; }
	.requiredFieldsIndicator {font-size: 22px;color:red;font-weight:bold;}
	.retroFieldsIndicator {font-size: 22px;color:green;font-weight:bold;vertical-align:middle;}
</style>
	
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/format_functions.js"></SCRIPT>
	<!---<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>

	<script type='text/javascript'>
		_ajaxConfig = {'_cfscriptLocation':'/components/programs/template/TemplateManagerAJAX.cfc', '_jsscriptFolder':'/Script/javascript/Ajax_JS','debug':false};
	</script>
	<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
--->
<script type='text/javascript'>
function validate()
{
	var strIDs = MyForm.Setting_ID.value;
	if (strIDs > 0) {
	window.opener.ShowException(strIDs);
	}
	document.MyForm.submit();	
}
</script>

<cfoutput>
<center><strong><font color="navy" size="2"> #Generic_Type# Template<br>Exception On "#Setting_Name#" Setting</font></strong></center>
</cfoutput>

<br>
<cfset templateSettingsManager = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").init() />
<cfset qTemplateList = templateSettingsManager.getTemplates(Generic_Type)>
<cfif Setting_ID GT 0>
	<cfset qGetSettingsException = templateSettingsManager.getSettingsException(Generic_Type,Setting_ID)>
<cfelse>
	<cfset qGetSettingsException = templateSettingsManager.getSettingsExceptionTBL(Generic_Type,Setting_ID,SettingDisplayValueInTable,SettingDisplayValueInTableID)>
</cfif>
<cfset ExclusionTemplateList = ValueList(qGetSettingsException.Excluded_First_Parent_ID) />

<FORM ACTION="Settings_ProgramTemplate_Exception_Save.cfm" METHOD="post" NAME="MyForm" ENCTYPE="multipart/form-data">
<table align="center" cellpadding="0" cellspacing="0" border="0" class="maintable">
	<tr>
		<td align="left" bgcolor="E6E6FA" height="20"><strong><div class="header">Exception</div></strong></td>
		<td align="center" bgcolor="E6E6FA" height="20"><strong><div class="header">&nbsp;&nbsp;Program Template&nbsp;&nbsp;</div></strong></td>
	</tr>

	<CFOUTPUT query = "qTemplateList">
		<TR VALIGN="top" >
			<TD align="center" ><input type="checkbox" name="Exception_First_Parent_ID_List" value="#First_Parent_ID#" id="#First_Parent_ID#" <cfif ListFind(ExclusionTemplateList, First_Parent_ID)>checked</cfif>></td>
			<TD nowrap>#Created_Type#</TD>
		</TR>	
	</CFOUTPUT>
</table>
<cfoutput>
<INPUT TYPE="hidden" NAME="Generic_Type"  VALUE="#Generic_Type#">
<INPUT TYPE="hidden" NAME="Setting_ID"  VALUE="#Setting_ID#">
<INPUT TYPE="hidden" NAME="StatusSave"  VALUE="1">
<INPUT TYPE="hidden" NAME="Setting_Name"  VALUE="#Setting_Name#">
<INPUT TYPE="hidden" NAME="SettingDisplayValueInTable"  VALUE="#SettingDisplayValueInTable#">
<INPUT TYPE="hidden" NAME="SettingDisplayValueInTableID"  VALUE="#SettingDisplayValueInTableID#">
</cfoutput>
<center>
<FONT COLOR="#FF0000" SIZE="2"><B>[</B></FONT><A HREF="javascript: validate();"><B>save data</B></A><FONT COLOR="#FF0000" SIZE="2"><B>]</B></FONT>&nbsp;&nbsp;
<FONT COLOR="#FF0000" SIZE="2"><B>[</B></FONT><a href="JavaScript:window.close()"><B>close</B></a><FONT COLOR="#FF0000" SIZE="2"><B>]</B></FONT>
</center>
</FORM>