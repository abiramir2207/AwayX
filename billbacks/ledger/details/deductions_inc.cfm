
<cfset DeductionDebit = 0>
<table border="0"  CLASS="SubTable" cellspacing="0" cellpadding="1" width="100%">

<tr>
<td valign="top" style="border-bottom:solid #93BEE2 1px;">Deduction: </td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Reference:</td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Reason Code:</td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Date:</td>
<td valign="top" align="right" style="border-bottom:solid #93BEE2 1px;" nowrap> Amount:</td>
</tr>

<cfoutput query="GetDeductions">

<!---Use cleared amount?--->
	<cfset useLakebaseForDeductionSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForDeductionSettings>
	<cftry>
		<cfset DeductionSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {
				"select" = "use_cleared_amount"
			}), "use_cleared_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeductionSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionSettings>
<cfquery name="DeductionSettings" datasource="#application.datasource#">
	SELECT Use_Cleared_Amount FROM Deduction_Settings
	</cfquery>
</cfif>

<cfset DeductionAmount = DD_Amount>
<cfif DeductionSettings.Use_Cleared_Amount IS 1>
	<cfif Cleared_Amount NEQ 0 AND len(trim(Cleared_Amount)) GT 0 AND Cleared_Amount NEQ DD_Amount>
		<cfset DeductionAmount = Cleared_Amount>
	</cfif>
</cfif>

<cfset DeductionDebit = DeductionDebit + DeductionAmount>
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF> <cfif CalledFrom IS NOT "Scheduled">onclick="NewWindow('/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#','deduction_window','800','600','Yes', 'No');return false;" NOWRAP style="cursor:pointer;"</cfif> >
	<td valign="top">#DD_DedID# - #DD_DedID_Line#</td>
	<td valign="top" >#DD_Reference#</td>
	<td valign="top">#DD_Reason_Code# (#left(DD_Reason_Code_Description, 50)#)</td>
	<td valign="top" >#dateformat(DD_Date, 'mmmm dd, yyyy')#</td>
	<td valign="top" align="right" >#lscurrencyformat(DeductionAmount)#</td>
	</tr>
</cfoutput>
<tr><td colspan="5">&nbsp; </td></tr>

<cfoutput><tr >
	<td valign="top" bgcolor="#color3#" colspan="3">&nbsp; </td>
	<td bgcolor="#color3#"><strong>Deduction Total:</strong></td>
	<td valign="top" bgcolor="#color3#"  align="right" ><strong>#lscurrencyformat(DeductionDebit)#</strong></td>
	</tr></cfoutput>

<cfif GetDeductions.recordcount EQ 0>
<Tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="Right" colspan="2">No deductions found</td>
</TR>
</cfif> 
</table>

