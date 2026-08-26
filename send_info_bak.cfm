<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyName#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>
<BR><BR>


<TABLE border="0" cellspacing="0" cellpadding="0">
	<TR>
		<TD><A HREF="/index.cfm"><IMG border="0" src="/images/logo_medium.gif" width="185" height="65" BORDER="0"></A></TD>
		<TD width="100%">
			
			<FONT color="#21008C"><B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<CFLOOP INDEX="dots" FROM="1" TO="30">
				<CFOUTPUT>&nbsp;&nbsp; .</CFOUTPUT>
			</CFLOOP>
			</B></FONT>
		</TD>
	</TR>
	<TR>
		<TD>
			<P align="center"><FONT color="#21008C"><B><BR>
			.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>
			</B></FONT>
		</TD>
		<TD width="100%" valign="top"><BR>
			If you have forgotten your user logon and/or password, please enter
			the following information.<BR>
			We will email you in 2 separate messages, the required information to logon to the system
			<BR><BR><BR><BR>
			
			
			<FORM ACTION="sendmail.cfm" METHOD="post">
			<TABLE border="0" cellspacing="0" cellpadding="4">
<!--- 				<TR>
					<TD align="right">First Name:</TD>
					<TD><INPUT type="text" name="name_first" size="20"></TD>
				</TR>
				<TR>
					<TD align="right">Last Name:</TD>
					<TD><INPUT type="text" name="Name_Last" size="20"></TD>
				</TR>
 --->				<TR>
					<TD align="right">Email address:</TD>
					<TD><INPUT type="text" name="User_Email" size="20"></TD>
				</TR>
<!--- 				<TR>
					<TD align="right">Answer to the key question:</TD>
					<TD><INPUT type="text" name="Password_Answer" size="20"></TD>
				</TR>
 --->				<TR>
					<TD align="right"></TD>
					<TD><INPUT TYPE="submit" VALUE="Send Information"></TD>
				</TR>
			</TABLE>
			</FORM>
			
			
		</TD>
	</TR>
</TABLE>


</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CENTER><FONT COLOR="Gray">Copyright© 2000-2001, <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT> All Rights Reserved</FONT></CENTER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

