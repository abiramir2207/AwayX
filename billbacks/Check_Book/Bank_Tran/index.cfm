<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>

<BODY BGCOLOR="White" LINK="Blue" VLINK="Blue" ALINK="Red"  LEFTMARGIN="12" TOPMARGIN="12" RIGHTMARGIN="12">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<STYLE>

	 .underline
		{
			border-bottom: 1px solid silver
		} 

	 .sectiontitle
		{
			font: 14px Arial;
			font-weight: bold;
			border-bottom: 1px solid silver
		}
		
</STYLE>


<CFSET titlewidth=150>



<TABLE WIDTH="100%" HEIGHT="100%" BORDER="1" CELLSPACING="0" CELLPADDING="10" BGCOLOR="Silver">
<TR>
	<TD HEIGHT="100%" BGCOLOR="White" VALIGN="top">
	
	<!--- 
	<IMG SRC="awayx_logo.gif" WIDTH="180" HEIGHT="65" ALT="" BORDER="0">
	 --->
	
	<CENTER><B><H3>PAY ORDER FORM</H3><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></B></CENTER>
	
<CFOUTPUT>	
<BLOCKQUOTE><DIV CLASS="sectiontitle">Pay From:</DIV></BLOCKQUOTE>
<BR>	
<TABLE WIDTH="75%" ALIGN="center" CELLPADDING="5">
	<TR>
		<TD NOWRAP WIDTH="#titlewidth#"><B>Account Number</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B>Amount in dollars:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B>Authorization Number:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
</TABLE>


<BR><BR>
	
<BLOCKQUOTE><DIV CLASS="sectiontitle">Pay To:</DIV></BLOCKQUOTE>
<BR>	
<TABLE WIDTH="75%" ALIGN="center" CELLPADDING="5">
	<TR>
		<TD NOWRAP WIDTH="#titlewidth#"><B>Account Number:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B>Account Name:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B>Bank Name:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>

</TABLE>


<TABLE WIDTH="75%" ALIGN="center" CELLPADDING="5">
	<TR>
		<TD NOWRAP WIDTH="#titlewidth#"><B>Payee Name:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B>Payee Address:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B></B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B></B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><B></B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>

</TABLE>




<BR><BR><BR><BR>
	

<TABLE WIDTH="75%" ALIGN="center" CELLPADDING="5">
	<TR>
		<TD NOWRAP WIDTH="#titlewidth#"><B><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Ref. Number:</B></TD>
		<TD WIDTH="100%"><DIV CLASS="underline">&nbsp;</DIV></TD>
	</TR>
	<TR>
		<TD NOWRAP><BR><BR><BR><B>Signature:</B></TD>
		<TD WIDTH="100%"><BR><BR><BR><DIV CLASS="underline"><IMG SRC="signature.jpg" WIDTH="135" HEIGHT="60" ALT="" BORDER="0"></DIV></TD>
	</TR>

</TABLE>

</CFOUTPUT>
	
	
	</TD>
</TR>
</TABLE>





























<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>




<!--- 

<HR>

<CFLOOP INDEX="i" FROM="1" TO="10">
	<CFSET sigW=evaluate(randrange(85,115)*135/100)>
	<CFSET sigH=evaluate(randrange(85,115)*60/100)>
	<CFOUTPUT>
		<IMG SRC="signature.jpg" WIDTH="#sigW#" HEIGHT="#sigH#"><BR>
	</CFOUTPUT>
</CFLOOP>


 --->