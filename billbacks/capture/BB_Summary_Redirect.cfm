


<CFSET Status_Desc = "APPROVED">

<CFIF Billback_Status_ID EQ 4>
	<CFSET Status_Desc = "PAYMENT REQUEST">
<CFELSEIF Billback_Status_ID EQ 5>
	<CFSET Status_Desc = "PAID">
<CFELSEIF Billback_Status_ID EQ 6>
	<CFSET Status_Desc = "PENDING FUND UPDATE">
<CFELSEIF Billback_Status_ID EQ 7>
	<CFSET Status_Desc = "PENDING VENDOR ID">
<CFELSEIF Billback_Status_ID EQ 8>
	<CFSET Status_Desc = "APPROVED - VOID">
</CFIF>

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="CENTER">
	<TR>
		<TD STYLE="font-size: 15px; font-weight: bold; color: red"><BR><BR><BR>Billback is in "<CFOUTPUT>#Status_Desc#</CFOUTPUT>" Status. No modification allowed at this status.</TD>		
	</TR>
</TABLE>

<!---  <CFLOCATION URL="Billback_Summary.cfm?BBID=#BB_ID_TO_Redirect#" ADDTOKEN="NO"> --->

<SCRIPT language="JavaScript">
function relocateThis()
{
	window.location.href = "/Billbacks/Capture/Billback_Summary.cfm?BBID=<CFOUTPUT>#BB_ID_TO_Redirect#</CFOUTPUT>"
}
window.setTimeout('relocateThis()', 2000);	
</SCRIPT>
 