<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
	


<CFQUERY NAME="GetLog" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback_Upload_Log WHERE Script_Log = 0 OR Script_Log IS NULL
</CFQUERY>


<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>
<BR><BR>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="UnderLine" WIDTH="400">
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:None"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="index.cfm">back to upload</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:None">&nbsp;</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" STYLE="border-bottom:None"><B><FONT SIZE="2" COLOR="Navy">Log Info Of Latest Upload</FONT></B></TD>
	</TR>
	<TR BGCOLOR="FFE083">
		<TD><B>INVOICE NUMBER</B></TD>
		<TD><B>INVALID REASON</B></TD>
	</TR>
	 <CFOUTPUT QUERY="GetLog">
	 	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD>&nbsp;&nbsp;<B>#Distributor_invoice_Number#</B></TD>
			<TD>#InvalidReason#</TD>
		</TR>
	 </CFOUTPUT>
</TABLE>
</body>
</html>
