<cfset ReimbursementDebit = 0>
<table border="0"  CLASS="SubTable" cellspacing="0" cellpadding="1" width="100%">

<tr>
<td valign="top" style="border-bottom:solid #93BEE2 1px;">Reimbursement Date: </td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Reimbursement Number:</td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Reimbursement Type:</td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Reimbursement Comments:</td>
<td valign="top" align="right" style="border-bottom:solid #93BEE2 1px;" nowrap>Reimbursement Amount:</td>
</tr>

<cfoutput query="GetReimbursements">
<cfset ReimbursementDebit = ReimbursementDebit + Reimbursement_Amount>
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF> <cfif CalledFrom IS NOT "Scheduled">onclick="NewWindow('/billbacks/reimbursements/detail.cfm?BB_Reimbursement_ID=#BB_Reimbursement_ID#&source=trade','name','600','400','Yes', 'No');return false;" NOWRAP style="cursor:pointer;"</cfif> >
	<td valign="top">#dateformat(Reimbursement_Date, 'MM/DD/YYYY')#</td>
	<td valign="top" >#Reimbursement_Number#</td>
	<td valign="top">#Reimbursement_Type_Description#</td>
	<td valign="top" >#Reimbursement_Comments#</td>
	<td valign="top" align="right" >#lscurrencyformat(Reimbursement_Amount)#</td>
	</tr>
</cfoutput>
<tr><td colspan="5">&nbsp; </td></tr>

<cfoutput><tr >
	<td valign="top" bgcolor="#color3#" colspan="3">&nbsp; </td>
	<td bgcolor="#color3#"><strong>Reimbursement Total:</strong></td>
	<td valign="top" bgcolor="#color3#"  align="right" ><strong>#lscurrencyformat(ReimbursementDebit)#</strong></td>
	</tr></cfoutput>

<cfif GetReimbursements.recordcount EQ 0>
<Tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="Right" colspan="2">No reimbursements found</td>
</TR>
</cfif> 
</table>

