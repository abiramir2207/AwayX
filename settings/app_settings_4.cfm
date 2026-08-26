<!---
***********************************************************************
Created By: Kalyan Vangapalli
Modification: Moved and created additional password settings - D7916
Filename: app_settings_4.cfm
Created Date: 08/22/2004
Purpose: For controlling the password/application settings
Modified By: Clarence Morse 3/24/2006
Purpose: enhancements to allow faxing of user information and default 
		 password.
***********************************************************************
--->
<!------ settings.cfm ----->
<cfoutput>

<cfinvoke component="components.settings.encryption" method="getPasswordKey" returnvariable="cryp_key" />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfif form.state>
	<!--- Start --->
	<!--- Here "0" means "send Email" --->
	<cfparam name="form.TempPassword" 				default="0">
	<cfparam name="form.Newpassword" 				default="0">
	<cfparam name="form.Adminpassword" 				default="0">
	<!--- Here "0" means "send Email"--->
	<!--- End --->
	<cfparam name="form.PasswordChangeDays" 		default="0">
	<cfparam name="form.PasswordMinLen" 			default="0">
	<cfparam name="form.PasswordHistory" 			default="0">
	<cfparam name="form.PasswordUpperChar" 			default="0">
	<cfparam name="form.PasswordLowerChar" 			default="0">
	<cfparam name="form.PasswordNumChar" 			default="0">
	<cfparam name="form.PasswordSpecialChar"		default="0">	
	<!--- Dev Note: Clay 9254 New Default Password for Users --->
	<cfparam name="form.defaultPasswordOn"		default="0">
	<cfparam name="form.defaultPasswordForNewUsers"		default="">
	<!--- Dev Note: Milan 8979 --->
	<cfparam name="form.LoginAndPasswordMsgChange"		default="">
	<cfparam name="form.changePasswordScreenMsg"	default="">
	<cfparam name="form.separateIdPasswordEmail"	default="0">

	<cfset appSettings = genSettingsManager.get(0)>
	<cfset appSettings.setTempPassword(form.TempPassword)>
	<cfset appSettings.setNewPassword(form.NewPassword)>
	<cfset appSettings.setAdminPassword(form.AdminPassword)>
	<cfset appSettings.setPasswordChangeDays(form.PasswordChangeDays)>
	<cfset appSettings.setPasswordUpperChar(form.PasswordUpperChar)>
	<cfset appSettings.setPasswordLowerChar(form.PasswordLowerChar)>
	<cfset appSettings.setPasswordNumChar(form.PasswordNumChar)>
	<cfset appSettings.setPasswordSpecialChar(form.PasswordSpecialChar)>
	<cfset appSettings.setPasswordMinLen(form.PasswordMinLen)>
	<cfset appSettings.setPasswordHistory(form.PasswordHistory)>
	<cfset appSettings.setLoginAndPasswordChangeMsg(form.LoginAndPasswordMsgChange)>
	<cfset appSettings.setChangePasswordScreenMsg(form.changePasswordScreenMsg)>
	<cfset appSettings.setSeparateIdPasswordEmail(form.separateIdPasswordEmail)>

	<!--- Dev Note: Clay 9254 New Default Password for Users --->
	<cfset appSettings.setDefaultPasswordOn(form.defaultPasswordOn)>
	<cf_cryp string="#form.defaultPasswordForNewUsers#" type="en" key="#cryp_key#">
	<cfparam name="cryp.value" default=""/>
	<cfset appSettings.setDefaultPasswordForNewUsers(cryp.value)>
	<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID)>	
	<cfset genSettingsManager.save(4)>
	
	<cflocation addtoken="No" url="#thisPage#">
	
	<cfabort>
</cfif>

<cfset appSettings = genSettingsManager.get(1, 4, 1)>

<style>
	.appSettingsInput
	{
		text-align:right;
		width:50px;
	}
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">

function validateAndSubmit(thisForm)
	{

		var pass_options = 0
		ErrorCount = 0
		
		
			if (document.all.PasswordChangeDays.value < 30 && document.all.PasswordChangeDays.value != 0)
			{
				ErrorCount++;
				queueMessage("No. of days for changing user password cannot be less than 30 days", document.all.err_sp_PasswordChangeDays);
			}
			else
			{
				clearQueue(document.all.error_err_sp_PasswordChangeDays);
			}

			if (document.all.PasswordMinLen.value < 1 || document.all.PasswordMinLen.length == 0)
			{
				ErrorCount++;
				queueMessage("Minimum length of Password should at least be 1 character", document.all.err_sp_PasswordMinLen);
			}
			else
			{
				clearQueue(document.all.error_err_sp_PasswordMinLen);
			}
			
			if (document.all.PasswordHistory.value < 1 || document.all.PasswordHistory.length == 0)
			{
				ErrorCount++;
				queueMessage("Number of previous Passwords to avoid should at least be 1", document.all.err_sp_PasswordHistory);
			}
			else
			{
				clearQueue(document.all.error_err_sp_PasswordHistory);
			}			
		
			if(ErrorCount == 0) {
				
			    	show_loader("SAVING CHANGES, PLEASE WAIT...");
					zeroCheckBoxes();
					submitForm(thisForm, "Settings4");

			}
			else {
				showMessageWindow()
			}	

	}
	
</script>
<br>
<cfif Len(appSettings.getUpdatedBy()) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(appSettings.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #appSettings.getUpdatedByUserName()#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>
<br> 
</cfif>
<table cellpadding="2" cellspacing="0" border="0" width="500">

	<tr>
		<td>Do not email password to the new users:</td>
		<td>&nbsp; </td>
		<td align="left"><input type="checkbox" value="1" name="TempPassword" <Cfif appSettings.getTempPassword() IS 1>checked</CFIF>></td>
	</tr>
	<tr>
		<td>Do not email Self-Updated password to the users:</td>
		<td>&nbsp; </td>
		<td align="left"><input type="checkbox" value="1" name="NewPassword" <Cfif appSettings.getNewPassword() IS 1>checked</CFIF>></td>
	</tr>
	<tr>
		<td>Do not email Administrator-Updated password to the users:</td>
		<td>&nbsp; </td>
		<td align="left"><input type="checkbox" value="1" name="AdminPassword" <Cfif appSettings.getAdminPassword() IS 1>checked</CFIF>></td>
	</tr>
	<tr>
		<td>Separate email to Users for User Id and Password:</td>
		<td>&nbsp; </td>
		<td align="left"><input type="checkbox" value="1" name="separateIdPasswordEmail" <Cfif appSettings.getSeparateIdPasswordEmail() IS 1>checked</CFIF>></td>
	</tr>
	<tr valign="top">
		<td>No. of days for changing user password:<br /> <span style="font-family: verdana,arial,helvetica; font-size:10px;color:red;">Note: 0 (Zero) days means that the users will not be required to change their password</span></td>
		<td><span id="err_sp_PasswordChangeDays">&nbsp;&nbsp;</span></td>
		<td align="left"><input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="appSettingsInput" type="Text" name="PasswordChangeDays" value="#appSettings.getPasswordChangeDays()#"> days</td>
	</tr>
<!--- Dev Note: KAL; 7916 --->
	<tr valign="top">
		<td>Minimum length of Password:
		<br><font color="red">Default Value is 7</font>
		</td>
		<td><span id="err_sp_PasswordMinLen">&nbsp;&nbsp;</span></td>
		<td align="left"><input maxlength="3" size="3" onkeypress="return Allow_Key_List('0123456789');" type="Text" class="appSettingsInput" name="PasswordMinLen" value="#appSettings.getPasswordMinLen()#"></td>
	</tr>
	<tr valign="top">
		<td>Password History: Number of previous passwords user cannot choose
		<br><font color="red">Default password history is 10</font>
		</td>
		<td><span id="err_sp_PasswordHistory">&nbsp;&nbsp;</span></td>
		<td align="left"><input maxlength="3" size="3" onkeypress="return Allow_Key_List('0123456789');" type="Text" class="appSettingsInput" name="PasswordHistory" value="#appSettings.getPasswordHistory()#"></td>
	</tr>
	<tr valign="top">
		<td><font color="black" size="2"><b>Password Restrictions :</b></font></td>
		<td><span id="err_sp_PasswordRestrictions">&nbsp;&nbsp;</span></td>
		<td align="left">&nbsp;</td>
	</tr>
	
	<tr valign="top">
		<td>Uppercase Characters:
		</td>
		<td>&nbsp;</td>
		<td align="left"><input type="Checkbox" value="1" name="PasswordUpperChar" <cfif appSettings.getPasswordUpperChar() IS 1>checked</CFIF>></td>
	</tr>
	<tr valign="top">
		<td>Lowercase Characters
		</td>
		<td>&nbsp;</td>
		<td align="left"><input type="Checkbox" value="1" name="PasswordLowerChar" <cfif appSettings.getPasswordLowerChar() IS 1>checked</CFIF>></td>
	</tr>
	<tr valign="top">
		<td>Numerical Characters
		</td>
		<td>&nbsp;</td>
		<td align="left"><input type="Checkbox" value="1" name="PasswordNumChar" <cfif appSettings.getPasswordNumChar() IS 1>checked</CFIF>></td>
	</tr>
	<tr valign="top">
		<td>Special Characters
		</td>
		<td>&nbsp;</td>
		<td align="left"><input type="Checkbox" value="1" name="PasswordSpecialChar" <cfif appSettings.getPasswordSpecialChar() IS 1>checked</CFIF>></td>
	</tr>
	<tr valign="top">
		<td>Default Password On
		</td>
		<td>&nbsp;</td>
		<td align="left"><input type="Checkbox" value="1" name="defaultPasswordOn" <cfif appSettings.getDefaultPasswordOn() IS 1>checked</CFIF>></td>
	</tr>
	
	<!--- Dev Note: Clay 9254 --->
	<cf_cryp string="#appSettings.getDefaultPasswordForNewUsers()#" type="de" key="#cryp_key#">
	<cfparam name="cryp.value" default=""/>
	
	<tr valign="top">
		<td>Default Password For New Users
		</td>
		<td>&nbsp;</td>
		<td align="left"><input type="text" MAXLENGTH="50" SIZE="12" value="<cfif len(cryp.value) GT 0>#cryp.value#</cfif>" name="defaultPasswordForNewUsers"></td>
	</tr>
<!--- End Note: KAL; 7916 --->

<!--- Start: D49376: New setting - update all user passwords to 'password'--->
	<tr valign="top">
		<td>Update all user passwords to 'password'
		</td>
		<td>&nbsp;</td>
		<td align="left">
		 <font size="1" color="Red">[</font> <font size="1" color="Blue"><a onClick="javaScript: NewWindow(this.href,'Password_update',460,210,'yes','yes'); return false;" target="_blank" HREF="password_mass_update_confirm.cfm"  TITLE="Password mass update" style="cursor: pointer;"><strong>Click here</strong></a></font> <font size="1" color="Red">]</font>
		</td>
	</tr>
<!--- End: D49376: New setting - update all user passwords to 'password'--->

</table>
<!--- Dev Note: Milan; 9879. Add the two Active Edit boxes --->
<cfif appSettings.getConfidentialityAgreementStatus() eq 0>
<p>
<span style="font-weight:bold;font-size:13px">Login & Password Change Message</span>&nbsp;(&nbsp;<A onClick="javaScript: NewWindow(this.href,'login_Page',900,600,'yes','yes'); return false;" target="_blank" HREF="print_preview_login_page.cfm"  TITLE="Preview the Login Page"><span style="color:##660033;font-weight:bold;text-decoration:none">preview</span></A>&nbsp;)
<br /><span style="font-weight:bold;text-decoration:none;">Characters Remaining &nbsp;</span><input type="text" SIZE="1" name="CountChars_Login" value="1200" disabled="yes">

<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />

</p>
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START                
What  I did: Comment out CF_ACTIVEEDIT and replace it with TEXTAREA for WYSIWYG tool--->
<textarea id="textarea" name="LoginAndPasswordMsgChange" style="width:610px;height:200px;">
<cfif appsettings.getLoginAndPasswordChangeMsg() neq "">
	<CFOUTPUT>#appsettings.getLoginAndPasswordChangeMsg()#</CFOUTPUT>
</cfif>
</textarea>
<!--- End Dev Note: drachala; D28078:Text Editor tools in Forge not working with Windows 7 END  --->
<cfelse>
<CFOUTPUT>
<input type="hidden" name="LoginAndPasswordMsgChange" value="#HTMLEditFormat(appsettings.getLoginAndPasswordChangeMsg())#">
</CFOUTPUT>
</cfif>

<cfif appsettings.getPasswordRequirementsStatus() eq 0>
<p>
<span style="font-weight:bold;font-size:13px">Password Requirements Message</span>&nbsp;(&nbsp;<A onClick="javaScript: NewWindow(this.href,'change_password_Page',900,600,'yes','yes'); return false;" target="_blank" HREF="print_preview_change_password_Page.cfm"  TITLE="Preview the Change Password Page"><span style="color:##660033;font-weight:bold;text-decoration:none">preview</span></A>&nbsp;)
<br /><span style="font-weight:bold;text-decoration:none;">Characters Remaining &nbsp;</span><input type="text" SIZE="1" name="CountChars_Password" value="500" disabled="yes">

<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />

</p>
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START                
What  I did: Comment out CF_ACTIVEEDIT and replace it with TEXTAREA for WYSIWYG tool--->
<textarea id="textarea1" name="changePasswordScreenMsg" style="width:610px;height:200px;">
	<CFOUTPUT>#appsettings.getChangePasswordScreenMsg()#</CFOUTPUT>
</textarea>
<!--- End Dev Note: drachala; D28078:Text Editor tools in Forge not working with Windows 7 END  --->
<cfelse>
<CFOUTPUT>
<input type="hidden" name="changePasswordScreenMsg" value="#HTMLEditFormat(appsettings.getChangePasswordScreenMsg())#">
</CFOUTPUT>
</cfif>
<!--- Used this to mimic the submission of a form through the clicking of a submit button.
			ActiveEdit works only by clicking on the submit button --->
<input type="submit" name="save" value="Save" style="visibility:hidden;" />
<!--- End Note: Milan; 9879 ---> 
<div align="center">

 	<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"validateAndSubmit(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
</div>
</cfoutput>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<!--- End Note: KAL; 7916 --->