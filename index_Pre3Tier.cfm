<CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = '/index2.cfm';</SCRIPT>
</CFOUTPUT>

<CFABORT>

<HTML>

<HEAD>
<TITLE><CFOUTPUT>#application.CompanyName#</CFOUTPUT></TITLE>
</HEAD>

<BODY>

<TABLE border="0" width="100%" cellspacing="0" cellpadding="0" height="100%">
	<TR>
		<TD></TD>
		<TD></TD>
		<TD></TD>
		<TD></TD>
	</TR>
	<TR>
		<TD></TD>
		<TD><IMG border="0" src="/Images/logo_2.gif" width="180" height="86"></TD>
		<TD background="/Images/logo_4.gif">&nbsp;</TD>
		<TD></TD>
	</TR>
	<TR>
		<TD></TD>
		<TD background="/Images/logo_3.gif">&nbsp;</TD>
		<TD width="100%" height="100%" valign="top">
			<CFSET web24_var = "https://web24.#application.CompanyOtherSuffix#/index2.cfm">
			<CFOUTPUT><a href="#web24_var#">click here to logon</a></CFOUTPUT>
			
			
		<TD></TD>
	</TR>
	<TR>
		<TD></TD>
		<TD align="center"><IMG border="0" src="/Images/logo_1.gif" width="106" height="37"></TD>
		<TD></TD>
		<TD></TD>
	</TR>
</TABLE>

</BODY>

</HTML>
