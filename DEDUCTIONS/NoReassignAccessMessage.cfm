<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
test
<CFOUTPUT>
<BR><BR><BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="3">You do not have the authority to change the owner of this deduction.  The #application.returned_customer_setting.distributor_label_singular# will remain the same.</FONT></B></TD>
	</TR>
</TABLE>
</CFOUTPUT>
<SCRIPT language="JavaScript">
function relocateThis()
{
	window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#URL.Deduction_ID#</CFOUTPUT>"
}
window.setTimeout('relocateThis()', 5000);	
</SCRIPT>
</body>
</html>
