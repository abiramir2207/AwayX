<CFQUERY NAME = "Glossary_Status" DATASOURCE = "#Application.Datasource#">
	SELECT * from PM_status WHERE PM_Status_deleted = 0 ORDER BY PM_Status_Description 
</CFQUERY>
<CFQUERY NAME = "Glossary_Phase" DATASOURCE = "#Application.Datasource#">
	SELECT * from PM_Phase WHERE PM_Phase_deleted = 0 ORDER BY PM_Phase_Description
</CFQUERY>
<CFQUERY NAME = "Glossary_Priority" DATASOURCE = "#Application.Datasource#">
	SELECT * from PM_Priority WHERE PM_Priority_deleted = 0 ORDER BY PM_Priority_Description
</CFQUERY>
<STYLE>
.bottomThin TD
{
	border-bottom:1px Navy solid;
}
TABLE.Maintable TD 
{
	border-bottom: solid #93BEE2 1px; font-size : 10px;
}
</STYLE>

<HTML>
	<HEAD>
		<TITLE>Glossary</TITLE>
	</HEAD>
</HTML>
<BODY>

<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="98%" ALIGN="center">
	 <TR>
		<TD COLSPAN="100%" ALIGN="right">
		<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="##" onClick="javaScript: hideGlossaryDiv();">close</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
		</TD>
	</TR> 
	<TR>
		<TD COLSPAN="100%" ID="oDiv_Move_Glossary" STYLE=" border-bottom:1px Navy solid;font-size:12px;font-weight:bold;">
			<FONT SIZE="3" COLOR="Red">Glossary</FONT>
		</TD>		
	</TR>
</table>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- PHASE																							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="98%" ALIGN="center">
	<TR>
		<TD COLSPAN="100%" ALIGN="left">&nbsp;</TD>
	</TR>
	<TR CLASS="bottomThin">
		<TD><FONT SIZE="2" COLOR="Navy"><B>Phase</B></FONT></TD>
		<TD>&nbsp;</TD>
	</TR>
</table>

<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="90%" ALIGN="center" CLASS="maintable">
	<TR>&nbsp;</TR>
	<TR BGCOLOR="#FFCE84" HEIGHT="10">
		<TD><FONT SIZE="2"><B>Description</B></FONT></TD>
		<TD><FONT SIZE="2"><B>Definition</B></FONT></TD>
	</TR>
	<CFOUTPUT QUERY = "Glossary_Phase"><!--- DE('FFFFFF'),DE('DDFFDD') --->

	<TR BGCOLOR="#IIF(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<TD WIDTH="239">#Glossary_Phase.PM_Phase_Description#&nbsp;</TD>
		<TD>#Glossary_Phase.PM_Phase_Definition#&nbsp;</TD>
	</TR>
	</CFOUTPUT>
</table>

<BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- PRIORITY																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="98%" ALIGN="center">
	<TR CLASS="bottomThin">
		<TD><FONT SIZE="2" COLOR="Navy"><B>Priority</B></FONT></TD>
		<TD>&nbsp;</TD>
	</TR>
</table>

<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="90%" ALIGN="center" CLASS="maintable">
	<TR>&nbsp;</TR>
	<TR BGCOLOR="#FFCE84" HEIGHT="10">
		<TD><FONT SIZE="2"><B>Description</B></FONT></TD>
		<TD><FONT SIZE="2"><B>Definition</B></FONT></TD>
	</TR>
	<CFOUTPUT QUERY = "Glossary_Priority"><!--- DE('FFFFFF'),DE('DDFFDD') --->
	<TR BGCOLOR="#IIF(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<TD WIDTH="239">#Glossary_Priority.PM_Priority_Description#&nbsp;</TD>
		<TD>#Glossary_Priority.PM_Priority_Definition#&nbsp;</TD>
	</TR>
	</CFOUTPUT>
</table>

<BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- STATUS																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="98%" ALIGN="center">
	<TR CLASS="bottomThin">
		<TD><FONT SIZE="2" COLOR="Navy"><B>Status</B></FONT></TD>
		<TD>&nbsp;</TD>
	</TR>
</table>

<TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="90%" ALIGN="center" CLASS="maintable">
	<TR>&nbsp;</TR>
	<TR BGCOLOR="#FFCE84" HEIGHT="10">
		<TD><FONT SIZE="2"><B>Description</B></FONT></TD>
		<TD><FONT SIZE="2"><B>Definition</B></FONT></TD>
	</TR>
	<CFOUTPUT QUERY = "Glossary_Status"><!--- DE('FFFFFF'),DE('DDFFDD') --->
	<TR BGCOLOR="#IIF(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<TD WIDTH="239">#Glossary_Status.PM_Status_Description#&nbsp;</TD>
		<TD>#Glossary_Status.PM_Status_Definition#&nbsp;</TD>
	</TR>
	</CFOUTPUT>
</TABLE>

<BR>


 <TABLE border="0" cellpadding="2" cellspacing="0" WIDTH="98%" ALIGN="center">
	<TR>
		<TD COLSPAN="100%" ALIGN="left">
		<B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="##" onClick="javaScript: hideGlossaryDiv();">close</A>&nbsp;<FONT COLOR="Red">]</FONT></B>
		</TD>
	</TR>
</table> 

<SCRIPT SRC="/Billbacks/common/common_js_functions.js"></SCRIPT>
<SCRIPT>
	
	function hideGlossaryDiv()
	{  
		window.close();
	}
</SCRIPT>
</BODY>
