<!--- This file gets called from mvc\models\Billback\BillbackSettlementManager.cfc --->
<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<!--- On "mvc\models\Billback\BillbackSettlementManager.cfc", we have the "approval" function which has "BBheader" passed to it --->
<cfoutput>
<cfsavecontent variable = "ApprovedAgreedList">
<table cellspacing="0" cellpadding="3" align="center" width="700">
	<tr BGCOLOR="FFE083">
		<td width="100"><span CLASS="tableheaders" valign="top">Billback</span></td>
		<td width="300"><span CLASS="tableheaders" valign="top">Title</span></td>
		<td><span CLASS="tableheaders" valign="top">Start</span></td>
		<td><span CLASS="tableheaders" valign="top">-</span></td>
		<td><span CLASS="tableheaders" valign="top">End</span></td>
		<td><span CLASS="tableheaders" valign="top">Approved/Agreed</span></td>
	</tr>
  <cfloop from="1" to="#ArrayLen(arguments.bbHeader)#" index="i">
	<tr>
		<td width="100" valign="top">#arguments.bbHeader[i].BBCode#</td>
		<td width="300" valign="top">#arguments.bbHeader[i].title#</td>
		<td valign="top">#DateFormat(arguments.bbHeader[i].startDate,'MM/DD/YYYY')#</td>
		<td valign="top">-</span></td>
		<td valign="top">#DateFormat(arguments.bbHeader[i].endDate,'MM/DD/YYYY')#</td>
		<td valign="top"><cfif arguments.bbHeader[i].status.id GTE 3>Approved<cfelse>Agreed</cfif></td>
	</tr>
  </cfloop>
 </table>
</cfsavecontent>

<!--- Send the approval email to the person who too the mass approval action --->
<cf_EmailWrapper 
	to="#request.AccessStructure.User_Email#"
	from="#Contact_Admin_Email_Address#" 
	subject="Billbacks Approved/Agreed in Mass Approval" 
	type="HTML"
	messagetype="1" 
	generatedby="1" 
	apparea="1">
	
#ApprovedAgreedList#
</cf_EmailWrapper>
</cfoutput>