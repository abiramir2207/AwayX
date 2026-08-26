<!---
Document Name:	password_form.cfm
Directory:		/settings
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	February 5, 2002
This is a major revision of a previous version of the password change function 
-- amended to include requiring the user to enter their old password.
Modified By: 	Milan Mushran
Modified Date: 9/8/2004
Modifications: Added checking functionalty for password entered - No Spaces and at Least one numeric character. 
							 Also Added "Password Expiry" messages.
			   
Modified By: 	Milan Mushran
Modified Date: 8/16/2005 
Modifications: Added the user agreement

Modified By:	Kal
Modified Date:	08/22/05
Modifications:	D7916 Additional Settings 

Modified By: 	Milan Mushran
Modified Date: 10/05/2005 
Modifications: 8469 View Confidentiality Agreement or not based on app setting

Modified By: Milan Mushran
Modified Date: 5/25/2006
Modifications: 9879. Added the two ActiveEdit textarea boxes for the user to enter data for the "Change Password" page
--->

<cfset error="">
<cfif isDefined("url.error")><cfset error = url.error></cfif>

<!---End submitted code--->

<CFPARAM NAME="URL.FromHome" DEFAULT="0">
<CFPARAM NAME="PasswordMinLen" DEFAULT="7">
<CFPARAM NAME="PasswordHistory" DEFAULT="10">
<CFPARAM NAME="PasswordUpperChar" DEFAULT="0">
<CFPARAM NAME="PasswordLowerChar" DEFAULT="0">
<CFPARAM NAME="PasswordNumChar" DEFAULT="0">
<CFPARAM NAME="PasswordSpecialChar" DEFAULT="0">

<cfset genSettings = CreateObject("component","components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettings.get() />
<cfset PasswordMinLen = appSettings.getPasswordMinLen()>
<cfset PasswordHistory = appSettings.getPasswordHistory()>
<cfset PasswordUpperChar = appSettings.getPasswordUpperChar()>
<cfset PasswordLowerChar = appSettings.getPasswordLowerChar()>
<cfset PasswordNumChar = appSettings.getPasswordNumChar()>
<cfset PasswordSpecialChar = appSettings.getPasswordSpecialChar()>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Change Password</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET pagetitle = "Personal Settings: Change Password">

<CFPARAM NAME="PageTitle" DEFAULT="">
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="<CFIF URL.FROMHOME>100%<CFELSE>715</CFIF>">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="<CFIF URL.FROMHOME>100%<CFELSE>715</CFIF>" HEIGHT="25"><SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN></TD>
</TR>
</TABLE>

<SCRIPT>
	function checkData (){
	
			var err_count = 0;
			var err_msg = "Please check the below messages! \n";
			var NumberCheck = /[0-9]/;
			var UpperCheck = /[A-Z]/;
			var LowerCheck = /[a-z]/;
			var SpecialCharCheck = /[\~\`\!\@\#\$\^\(\)\_\-\+\?\.\>\<\[\]\/\:\;]/;
			
 			//if (document.MyForm.OldPassword.value == "") {
			if (document.forms['MyForm'].elements['OldPassword'].value== "") {
					err_msg = err_msg + "\n - Please enter your old password...";
	                document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}

	        if (document.forms['MyForm'].elements['NewPassword'].value == "") {
					err_msg = err_msg + "\n - Please enter your new password...";
	                document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}

	        if (document.forms['MyForm'].elements['NewPassword2'].value == "") {
					err_msg = err_msg + "\n - Please re-enter your new password confirmation...";
	                document.forms['MyForm'].elements['NewPassword2'].focus()
					err_count++;
					}
					
			if (document.forms['MyForm'].elements['NewPassword'].value.indexOf(" ") != -1)
  			 {
      				err_msg = err_msg + "\n - Your new password should not contain spaces";
	  				document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}

	        if (document.forms['MyForm'].elements['NewPassword'].value != document.forms['MyForm'].elements['NewPassword2'].value) {
	        		err_msg = err_msg + "\n - Your new passwords don't match...";
	                document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}

			if(document.forms['MyForm'].elements['NewPassword'].value.length < <CFOUTPUT>#PasswordMinLen#</CFOUTPUT>) {
				err_msg = err_msg + "\n - Your new password must be at least <CFOUTPUT>#PasswordMinLen#</CFOUTPUT> characters long";
				err_count++;
				}
			
	   		if (<CFOUTPUT>#PasswordNumChar#</CFOUTPUT> == 1){
				if ( NumberCheck.test(document.forms['MyForm'].elements['NewPassword'].value) == false ){
	      				err_msg = err_msg + "\n - Your new password should contain at least one number (0-9)";
		  				document.forms['MyForm'].elements['NewPassword'].focus()
						err_count++;
		  				}
				}
		
			if (<CFOUTPUT>#PasswordUpperChar#</CFOUTPUT> == 1){
				if ( UpperCheck.test(document.forms['MyForm'].elements['NewPassword'].value) == false ){
					err_msg = err_msg + "\n - Your new password must have at least one UPPERCASE character";
	  				document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}
				}
		
			if (<CFOUTPUT>#PasswordLowerChar#</CFOUTPUT> == 1){
				if ( LowerCheck.test(document.forms['MyForm'].elements['NewPassword'].value) == false ){
					err_msg = err_msg + "\n - Your new password must have at least one 'lowercase' character";
	  				document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}
				}
		
			if (<CFOUTPUT>#PasswordSpecialChar#</CFOUTPUT> == 1){
				if ( SpecialCharCheck.test(document.forms['MyForm'].elements['NewPassword'].value) == false ){
					err_msg = err_msg + "\n - Your new password must have at least one Special character (\~`!@#$^()_-+?.:;><[]/)";
	  				document.forms['MyForm'].elements['NewPassword'].focus()
					err_count++;
					}
				}
	 
			if (err_count == 0){
				MyForm.submit();
			}
			else{
				alert(err_msg);
			}
		
}
</SCRIPT>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!--- If the customer wants to see the Confidentiality Agreement --->
<cfif appSettings.getConfidentialityAgreementStatus() eq 0 AND (appsettings.getLoginAndPasswordChangeMsg() neq "" OR appsettings.getChangePasswordScreenMsg() neq "")>
<div STYLE="font-size:1Opx; text-align: center; color:red; font-weight:bold;  margin-top:5px;">PLEASE READ THE AGREEMENT CAREFULLY BEFORE UPDATING YOUR PASSWORD</div> 
</cfif>
<cfif appSettings.getConfidentialityAgreementStatus() eq 0 AND appsettings.getLoginAndPasswordChangeMsg() neq "">
<table width="800"> 
	<tr>
		<td><CFOUTPUT>#appsettings.getLoginAndPasswordChangeMsg()#</CFOUTPUT></td>
	</tr>
</table>
</cfif>


<cfif len(Error) GT 0>
<font color="red"><cfoutput>#Error#</cfoutput></font>
<BR>
</cfif>
<cfif appsettings.getPasswordRequirementsStatus() eq 0 AND appsettings.getLoginAndPasswordChangeMsg() neq "" AND appsettings.getChangePasswordScreenMsg() neq "">
<p>
</cfif>
<cfif isDefined("url.Message")>
	<cfif url.Message IS "New User">
You must select a new password.

	<cfelseif url.Message IS "PasswordExpiryWarning">
<p style="font-weight: bold; color:red;">Your Password will expire in <cfoutput>#Days#</cfoutput> Days. It is recommended that you change your password now.</p>

	<cfelseif url.Message IS "ExpiredPassword">
<p style="font-weight: bold; color:red;">Your Password has expired. You must change you password to gain access to the system</p>	

	</cfif>
</cfif>
<cfif appsettings.getPasswordRequirementsStatus() eq 0  AND appsettings.getChangePasswordScreenMsg() neq "">
<table width="800"> 
	<tr>
		<td><cfoutput>#appsettings.getChangePasswordScreenMsg()#</cfoutput></td>
	</tr>
</table>
</cfif>

<p style="font-weight: bold; color:red;">NOTE: You will need to re-login after you have changed your password
</p>


<FORM ACTION="password_form_action.cfm" METHOD="post"  NAME="ChangePassword" ID="MyForm" onSubmit="return checkData()">
<input type="Hidden" name="PasswordHistory" value="<cfoutput>#PasswordHistory#</cfoutput>">
<TABLE>
<TR>
	<TD ALIGN="right">Old Password:</TD>
	<TD><INPUT TYPE="password" NAME="OldPassword"></TD>
</TR>
<TR>
	<TD ALIGN="right">New Password:</TD>
	<TD><INPUT TYPE="password" NAME="NewPassword"></TD>
</TR>
<TR>
	<TD ALIGN="right">Re-enter New Password:</TD>
	<TD><INPUT TYPE="password" NAME="NewPassword2"></TD>
</TR>
<TR>
	<TD></TD>
	<TD></TD>
</TR>
</TABLE>

<INPUT TYPE="hidden" NAME="FROMHOME" VALUE="<CFOUTPUT>#URL.FROMHOME#</CFOUTPUT>">

<!--- If the customer wants to see the Confidentiality Agreement --->
<cfif appSettings.getConfidentialityAgreementStatus() eq 0>
	<cfset button_caption = "Accept and save">
<cfelse>
<!--- If the customer does not want to see the Confidentiality Agreement --->
	<cfset button_caption = "save">
</cfif>

<cfoutput>
<BR><CF_button
		button_name		=	""
		button_caption	=	"#button_caption#"
		button_action	=	"checkData();"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</cfoutput>

</FORM>


<CFIF CGI.HTTP_REFERER EQ "#application.HTTPVar##CGI.HTTP_HOST#/settings/control_panel.cfm">
	<CENTER><H4>Your password has been changed</H4></CENTER>
</CFIF>

</BODY>
</HTML>


