<tr class="claimSumHeader">
	<td colspan="<cfoutput>#ListGetAt(thisReportUOMFieldList, 1) - 1#</cfoutput>">
		<cfoutput>Total for #preSumFieldV#</cfoutput>
	</td>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
	<cfloop list="#thisReportUOMFieldList#" index="thisUOMIndex">
		<cfset UOM_Field = ListGetAt(cmpHandle.getReportFields(),thisUOMIndex) > 
		<cfif UOM_Field EQ "ClaimCS">
			<td nowrap><cfoutput>#NumberFormat(round(claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "PaidCS">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Paid_Amount">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Claim_Amount">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "PD_VS_RD_Days">
			<td><cfoutput>#claimSummaryHandle.getProgramAvg_PD_VS_RD_Days(preSumFieldV)#</cfoutput></td>
		<cfelseif UOM_Field EQ "RD_VS_ED_Days">
			<td><cfoutput>#claimSummaryHandle.getProgramAvg_RD_VS_ED_Days(preSumFieldV)#</cfoutput></td>
		<cfelseif UOM_Field EQ "ED_VS_CD_Days">
			<td><cfoutput>#claimSummaryHandle.getProgramAvg_ED_VS_CD_Days(preSumFieldV)#</cfoutput></td>
		<cfelseif UOM_Field EQ "CD_VS_PD_Days">
			<td><cfoutput>#claimSummaryHandle.getProgramAvg_CD_VS_PD_Days(preSumFieldV)#</cfoutput></td>
			<!----- particularly for participation ---->
		<cfelseif UOM_Field EQ "Field_Execution_Cases">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Bid_Request_Cases">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestCases(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Cases">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Cases">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Cases">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "total_cases">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalCases(preSumFieldV), "_,___,___")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Field_Execution_Dollars">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Bid_Request_Dollars">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Dollars">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Dollars">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Dollars">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "total_dollars">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<!--- for cost saving --->
		<cfelseif UOM_Field EQ "Variation$">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimVariation$(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
		<cfelseif UOM_Field EQ "VariationCS">
			<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimVariationCS(preSumFieldV), "_,___,___")#</cfoutput></td>
		</cfif>
		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
	</cfloop>
	<td colspan="<cfoutput>#ListLen(cmpHandle.getReportFields()) - ListGetAt(thisReportUOMFieldList, 1) - ListLen(thisReportUOMFieldList) + 1#</cfoutput>">&nbsp;</td>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
</tr>
<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>

