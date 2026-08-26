<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Change Password</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET pagetitle = "Personal Settings: Change Password">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Password settings																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT>
	function checkData (){
	        if (document.MyForm.Old_Password.value == "") {
	                alert("Please enter your current password...")
	                document.MyForm.Old_Password.focus()
	                return false}

	        if (document.MyForm.New_Password.value == "") {
	                alert("Please enter your new password...")
	                document.MyForm.New_Password.focus()
	                return false}

	        if (document.MyForm.New_Password2.value == "") {
	                alert("Please re-enter your new password...")
	                document.MyForm.New_Password2.focus()
	                return false}

	        if (document.MyForm.New_Password.value != document.MyForm.New_Password2.value) {
	                alert("Your new passwords don't match...")
	                document.MyForm.New_Password.focus()
	                return false}

			if(document.MyForm.New_Password.value.length < 8) {
				alert("Your new password must be atleast 8 characters")
				return false}
				
		else MyForm.submit();
	}
</SCRIPT>


<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=25>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->
<BR><BR>

<B>
Choose a password that is at least 8 characters long.
It may contain numbers (0-9) and letters in upper and lower case (A-Z or a-z), but we don't recommend the use of spaces or other symbols.
Make sure it is difficult for others to guess!
</B>
<BR><BR>

<FORM ACTION="password_action.cfm" METHOD="post"  NAME="MyForm" ID="MyForm" onSubmit="return checkData()">

<TABLE>
<TR>
	<TD ALIGN="right">Old Password:</TD>
	<TD><INPUT TYPE="Password" NAME="Old_Password"></TD>
</TR>
<TR>
	<TD ALIGN="right">New Password:</TD>
	<TD><INPUT TYPE="Password" NAME="New_Password"></TD>
</TR>
<TR>
	<TD ALIGN="right">Re-enter New Password:</TD>
	<TD><INPUT TYPE="Password" NAME="New_Password2"></TD>
</TR>
<TR>
	<TD></TD>
	<TD></TD>
</TR>
</TABLE>


<BR><BR><BR><INPUT TYPE="Submit" VALUE="Save Password...">

</FORM>


<CFIF CGI.HTTP_REFERER EQ "http://#HOSTNAME#/settings/control_panel.cfm">
	<CENTER><H4>Your password has been changed</H4></CENTER>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



