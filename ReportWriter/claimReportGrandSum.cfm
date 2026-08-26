<tr class="claimSumHeader">
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		<td colspan="<cfoutput>#ListGetAt(thisReportUOMFieldList, 1) - 1#</cfoutput>">
	</cfif>
		<cfoutput>Grand Total:</cfoutput>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		</td>
	</cfif>
		<cfset preIndex = 0 >
 	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
	<cfloop list="#thisReportUOMFieldList#" index="thisUOMIndex">
		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV">
			<cfloop from="1" to="#thisUOMIndex-preIndex-2#" index = "i" step="1"><cfoutput>,</cfoutput></cfloop>
			<cfset preIndex = thisUOMIndex />
		</cfif>
		<cfset UOM_Field = ListGetAt(cmpHandle.getReportFields(),thisUOMIndex) > 
		<cfif UOM_Field EQ "ClaimCS">
			<td nowrap>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(round(grandClaimCSTotal), "_,___,___")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(round(grandClaimCSTotal), "_______")#</cfoutput>
				</cfif>
			</td>
		<cfelseif UOM_Field EQ "PaidCS">
			<td nowrap>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(round(grandPaidCSTotal), "_,___,___")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(round(grandPaidCSTotal), "_______")#</cfoutput>
				</cfif>
			</td>
		<cfelseif UOM_Field EQ "Paid_Amount">
			<td nowrap>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(grandPaidAmountTotal, "$_,___,___.__")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(grandPaidAmountTotal, "$_______.__")#</cfoutput>
				</cfif>
			</td>
 		<cfelseif UOM_Field EQ "Claim_Amount">
			<td nowrap>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(grandClaimAmountTotal, "$_,___,___.__")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(grandClaimAmountTotal, "$_______.__")#</cfoutput>
				</cfif>
			</td>
		<cfelseif UOM_Field EQ "PD_VS_RD_Days">
			<td>&nbsp;</td>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
		<cfelseif UOM_Field EQ "RD_VS_ED_Days">
			<td>&nbsp;</td>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
		<cfelseif UOM_Field EQ "ED_VS_CD_Days">
			<td>&nbsp;</td>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
		<cfelseif UOM_Field EQ "CD_VS_PD_Days">
			<td>&nbsp;</td>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
		<cfelseif UOM_Field EQ "Field_Execution_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandFieldExecutionCases, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandFieldExecutionCases, "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Bid_Request_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandBidRequestCases, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandBidRequestCases, "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDirectOrHqProgramsCases, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDirectOrHqProgramsCases, "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDeviatedPricingCases, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDeviatedPricingCases, "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandDistributorTradeShelterCases, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandDistributorTradeShelterCases, "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "total_cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandTotalCases, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandTotalCases, "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Field_Execution_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandFieldExecutionDollars, "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandFieldExecutionDollars, "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Bid_Request_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandBidRequestDollars, "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandBidRequestDollars, "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDirectOrHqProgramsDollars, "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDirectOrHqProgramsDollars, "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDeviatedPricingDollars, "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandOperatorDeviatedPricingDollars, "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandDistributorTradeShelterDollars, "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandDistributorTradeShelterDollars, "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "total_dollars">
			<td nowrap>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(grandTotalDollars, "$_,___,___.__")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(grandTotalDollars, "$_______.__")#</cfoutput>
				</cfif>
			</td>
		<!--- for cost saving --->
		<cfelseif UOM_Field EQ "Variation$">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandClaimVariationDollars, "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandClaimVariationDollars, "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "VariationCS">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(grandClaimVariationCS, "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(grandClaimVariationCS, "_______")#</cfoutput></td>
			</cfif>
		<cfelse>
			<td>&nbsp;</td>
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
		</cfif>
		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
	</cfloop>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		<td colspan="<cfoutput>#ListLen(cmpHandle.getReportFields()) - ListGetAt(thisReportUOMFieldList, 1) - ListLen(thisReportUOMFieldList) + 1#</cfoutput>">
	</cfif>
		&nbsp;
		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		</td>
	</cfif>
</tr>
<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
