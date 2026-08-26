<div align="center">
<cfoutput>
<Table border="0" cellpadding="0" cellspacing="0" bgcolor="whitesmoke" style="border-bottom:solid navy 1px; border-right:solid navy 1px; border-left:solid navy 1px; border-top:solid navy 1px;">

<tr><Td align="Center" valign="top" width="50%" style="border-bottom:solid navy 1px; border-right:solid navy 1px; border-left:solid navy 1px; border-top:solid navy 1px;"><strong>#DistributorName#</strong>
<br>
<strong>#ProgramName# (#GetProgramNumber.Contract_Number#)</strong>


</td>

<td align="center" valign="top" style="border-bottom:solid navy 1px; border-right:solid navy 1px; border-left:solid navy 1px; border-top:solid navy 1px;">#GetProgramNumber.Contract_Status_Type_Desc#
<br>#DateFormat(StartDate, 'MMMM DD, YYYY')# - #DateFormat(EndDate, 'MMMM DD, YYYY')#
<cfset ProgramSpan = EndDate - StartDate>
<cfset AmountLeft = Now() - StartDate>
<cfif ProgramSpan LTE 0>
	<cfset PercentDone = 100>
<cfelseif AmountLeft GTE ProgramSpan>
	<cfset PercentDone = 100>
<cfelse>
	<cfset PercentDone = AmountLeft / ProgramSpan>
	<cfset PercentDone = PercentDone * 100>
</cfif>
<br>#int(PercentDone)#% complete
</td></tr>

</TABLE>
</cfoutput></div>
<Br>