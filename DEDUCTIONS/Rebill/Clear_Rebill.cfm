 <!-----------------------------------------------------------------------------

FILE NAME:		Clear_Rebill.cfm
DESCRIPTION:	Editing page for the Rebill Pakcage	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	15-Apr-10 Added the edit page for the Rebill Package
------------------------------------------------------------------------------> 

<cfset compRebill = CreateObject("component", "components.deduction.rebill.Rebill").clearRebill(Deduction_ID,request.AccessStructure.User_ID) />
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Rebill has been Cleared.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
</SCRIPT>
