<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title></title>
</head>

<body LEFTMARGIN="0" TOPMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">

<cfparam name="URL.IMG" 	default="">
<CFIF Len(URL.IMG) GT 0>
	<BR><BR>
	<TABLE ALIGN="CENTER" VALIGN="MIDDLE" WIDTH="100%" BORDER="0" CELLPADDING="5">
	<TR>
		<TD ALIGN="CENTER" VALIGN="MIDDLE">
			<CFOUTPUT><IMG SRC="\images\BrowserSettings\#URL.IMG#.gif"></CFOUTPUT>
		</TD>
	</TR>
	</TABLE>
</CFIF>
</body>
</html>
