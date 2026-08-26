<!---
	Copyright (c)2009	Blacksmith Applications, Inc.       
	
	Developer:		KVangapalli             
	Description:	This form is used to reset the user's pin for the auto approve via email 
	Usage:			This is a stripped down version password_from.cfm. 
					Right now we are not using most of the password change logic for this page.
					When the pin change also needs same validations as password, we could the same code from password_from.cfm
--->

<!---Begin submitted code--->
<cfset error="">
<cfif isDefined("url.error")><cfset error = url.error></cfif>
<!---End submitted code--->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Change Pin</TITLE>
	<SCRIPT>
		function checkData (){
		
				var err_count = 0;
				var err_msg = "Please check the below error messages! \n";
				var pinMinLength = <CFOUTPUT>#appsettings.getPinMinLength()#</CFOUTPUT>
				
				if (document.MyForm.OldPin.value == "") {
						err_msg = err_msg + "\n - Please enter your old pin...";
		                document.MyForm.NewPin.focus()
						err_count++;
						}
	
		        if (document.MyForm.NewPin.value == "") {
						err_msg = err_msg + "\n - Please enter your new pin...";
		                document.MyForm.NewPin.focus()
						err_count++;
						}
	
				if (document.MyForm.NewPin.value.indexOf(" ") != -1)
	  			 {
	      				err_msg = err_msg + "\n - Your new pin should not contain spaces";
		  				document.MyForm.NewPin.focus()
						err_count++;
						}
	
		        if (document.MyForm.NewPin.value != document.MyForm.NewPin2.value) {
		        		err_msg = err_msg + "\n - Your new pins don't match...";
		                document.MyForm.NewPin.focus()
						err_count++;
						}
				
				
				if(document.MyForm.NewPin.value.length < pinMinLength) {
					err_msg = err_msg + "\n - Your new pin must be at least " + pinMinLength + " characters long";
					err_count++;
					}
				
				
				if (document.MyForm.NewPin.value != parseInt(document.MyForm.NewPin.value, 10)){
	      				err_msg = err_msg + "\n - Your new pin should contain numbers only (0-9)";
		  				document.MyForm.NewPin.focus()
						err_count++;
		  				}			
		
				if (err_count == 0){
					MyForm.submit();
				}
				else{
					alert(err_msg);
				}
			
	}
	</SCRIPT>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
	
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
	<CFSET pagetitle = "Personal Settings: Change Pin">
	
	<CFPARAM NAME="PageTitle" DEFAULT="">
	<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="715">
	<TR>
		<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="715" HEIGHT="25">
			<SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN>
		</TD>
	</TR>
	</TABLE>
	
	
	
	<!--- If the customer wants to see the Confidentiality Agreement --->
	<cfif appSettings.getConfidentialityAgreementStatus() eq 0 AND (appsettings.getLoginAndPasswordChangeMsg() neq "" OR appsettings.getChangePasswordScreenMsg() neq "")>
		<div STYLE="font-size:10px; text-align: center; color:red; font-weight:bold;  margin-top:5px;">PLEASE READ THE AGREEMENT CAREFULLY BEFORE UPDATING YOUR PIN</div> 
	</cfif>
	
	<cfif appSettings.getConfidentialityAgreementStatus() eq 0 AND appsettings.getLoginAndPasswordChangeMsg() neq "">
	<table width="715"> 
		<tr>
			<td><CFOUTPUT>#appsettings.getLoginAndPasswordChangeMsg()#</CFOUTPUT></td>
		</tr>
	</table>
	</cfif>	
	
	<cfif len(Error) GT 0>
		<font color="red"><cfoutput>#Error#</cfoutput></font>
		<BR>
	</cfif>


	
	<FORM ACTION="pin_action.cfm" METHOD="post" NAME="ChangePin" ID="MyForm" onSubmit="return checkData()">
		<TABLE>
			<TR>
				<TD ALIGN="right">Old Pin:</TD>
				<TD><INPUT TYPE="password" NAME="OldPin"></TD>
			</TR>
			<TR>
				<TD ALIGN="right">New Pin:</TD>
				<TD><INPUT TYPE="password" NAME="NewPin"></TD>
			</TR>
			<TR>
				<TD ALIGN="right">Re-enter New Pin:</TD>
				<TD><INPUT TYPE="password" NAME="NewPin2"></TD>
			</TR>
			<TR>
				<TD></TD>
				<TD></TD>
			</TR>
		</TABLE>
	
		<BR>
		<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"checkData();"
			button_type		=	"javascript_link"
			button_width	=	"175"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	
	</FORM>


	<CFIF CGI.HTTP_REFERER EQ "#application.HTTPVar##CGI.HTTP_HOST#/settings/control_panel.cfm">
		<CENTER><H4>Your Pin has been changed</H4></CENTER>
	</CFIF>

</BODY>
</HTML>


