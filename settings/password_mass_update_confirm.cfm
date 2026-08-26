<!-----------------------------------------------------------------------------

FILE NAME:		autoRenewalHelp.cfm
DESCRIPTION:	Help text display page called from contract_crate_1_form.cfm file
				from the Auto Renewal section.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	15-Apr-2015	

------------------------------------------------------------------------------> 

<html>
<head>
	<title>Password Mass Update to "password"</title>
</head>

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
 
<CFSET pagetitle = "Password Mass update to ">
<CFPARAM NAME="PageTitle" DEFAULT="">
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="100%" HEIGHT="25"><SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#'password'</CFOUTPUT></SPAN></TD>
</TR>
</TABLE>
<br><br> 
<cfif isDefined("FORM.bSubmit") AND FORM.bSubmit EQ "1">
	<cfquery name="UpdateUser" datasource="#application.datasource#">
		UPDATE _Users
		SET User_Password = '#hash("password")#', 
			-- User_PasswordHistory = <!---  '#PasswordHistoryList#',  --->
			Is_First_Time = 0, 
			Is_Locked = 0,
			LoginTries = 0,
			Password_Update_date = getdate(),
			Updated_By = '#request.AccessStructure.User_ID#'	 
		WHERE 
			Deleted = 0
	</cfquery>
	<div align="center"> 
		All user Passwords have been updated to 'password'.<br>
		<br>
		<input type="button" value="Close Window" OnClick="javascript:window.close();">
	</div>
					
<cfelse>
<form name="frmMassChange" method="post" action="password_mass_update_confirm.cfm">
	<strong><img src="/images/i.gif"> <u>Password Update Confirmation:</u></strong>
	This action will update all the user passwords to 'password' and cannot be reversed. <br>
	Are you sure?
	<br>
	<br>
	<div align="center">
		<input type="submit" value="Yes, Continue" name="Yes, Continue" >
		<input type="button" value="        No        " OnClick="javascript:window.close();">
		<input type="hidden" value="1" name="bSubmit" Id="bSubmit">
	</div>
</form>
</cfif>


</body>
</html>