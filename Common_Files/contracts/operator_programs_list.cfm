<!---Redone just to submit a search and use search logic --->

<HEAD>
	<TITLE>Operator Programs</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<cfset FORM.Operator_Number = OID>
<Cfset FORM.DOSEARCH = 1>
<cfset form.Use_BSA_Operator_ID = 1>
<cfset FORM.readOnlyCatalogSearch = 2>
<cfset UseCatalogView = 1>
<Br>&nbsp; 
<div align="Center">
<table width="90%" border="0"><Tr><td>
<cfinclude template="/scorecard/program_Search_Result.cfm">
</td></TR></table>
</div>

<!---BJF D9634: I needed all the search validation, so I just submitted this as though it was a search and got the results in this page. --->

<!--- <cfsilent><cfset OperatorPrograms= CreateObject("component", "components.programs.ProgramManager").getoperatorprograms(url.OID) />	
</cfsilent>
<cfif OperatorPrograms.recordcount GT 0>
<table width="90%" cellpadding="2" cellspacing="0" border="0" class="maintable" align="center">
<tr>
	<td bgcolor="orange"><strong>Contract Number</strong></td>
	<td bgcolor="orange"><strong>Contract Title</strong></td>
	<td bgcolor="orange"><strong>Start Date</strong></td>
	<td bgcolor="orange"><strong>End Date</strong></td>
	<td bgcolor="orange"><strong>Status</strong></td>
	<td bgcolor="orange"><strong>Responsible Sales Person</strong></td>
</tr>
<cfoutput query="OperatorPrograms">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<cf_cryp type="en" string ="#OperatorPrograms.contract_main_id#" key="#request.key#">
<cfset ContractID = cryp.value>
	<td><A STYLE="cursor:pointer;"
ONCLICK="viewContract('#ContractID#')">#Contract_Number#</A></td>
	<td>#Contract_Title#</td>
	<td>#dateformat(contract_start_date, "mm/dd/yyyy")#</td>
	<td>#dateformat(contract_end_date, "mm/dd/yyyy")#</td>
	<td>#contract_status_type_desc#</td>
	<td>#name_last#&nbsp;#name_first#</td>
</tr>
</cfoutput>
</table>
<cfelse>
<div align="center">
<SPAN CLASS="Title4">
NO PROGRAMS FOUND</SPAN></div>
</cfif>

<script>
function viewContract(program_id)
{
NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id,'ViewProgram','800','600','Yes', 'Yes');
}
</script>

 --->