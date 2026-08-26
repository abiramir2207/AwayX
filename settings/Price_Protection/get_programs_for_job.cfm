<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfif getPrograms.recordcount GT 0>
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable">
<TR><TD style="font-size:12px" colspan="100%"><b>Eligible Programs</b></TD></TR>
<tr>
	<td bgcolor="FFCE84"><strong>Contract Number</strong></td>
	<td bgcolor="FFCE84"><strong>Contract Title</strong></td>
	<td bgcolor="FFCE84"><strong>Start Date</strong></td>
	<td bgcolor="FFCE84"><strong>End Date</strong></td>
	<td bgcolor="FFCE84"><strong>Status</strong></td>
</tr>
<tr><td colspan="100%"><hr width="100%" color="navy"></td></tr>
<cfoutput query="getPrograms">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<cf_cryp type="en" string ="#getPrograms.contract_main_id#" key="#request.key#">
<cfset ContractID = cryp.value>
	<td><A STYLE="cursor:pointer;"
ONCLICK="viewContract('#ContractID#')">#Contract_Number#</A></td>
	<td>#Contract_Title#</td>
	<td>#dateformat(contract_start_date,"mm/dd/yyyy")#</td>
	<td>#dateformat(contract_end_date,"mm/dd/yyyy")#</td>
	<td>#contract_status_type_desc#</td>
</tr>
</cfoutput>
<cfelse>
<TR>
<td colspan="100%">No Eligible Programs Found.</td>
</TR>
</cfif></table>

<script>
function viewContract(program_id)
{
NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id,'ViewProgram','800','600','Yes', 'Yes');
}
</script>
</body>
</html>
