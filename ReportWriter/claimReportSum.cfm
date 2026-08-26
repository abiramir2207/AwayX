<!----- include those rows for claimHeader ---->
<cfoutput>
<tr class="claimSumSecondaryHeader">
	<td colspan="#ListGetAt(thisReportUOMFieldList, 1) - 1#" nowrap>Total for #preSecondLevelFV#</td>
	<cfloop list="#thisReportUOMFieldList#" index="thisUOMIndex">
		<cfset UOM_Field = ListGetAt(cmpHandle.getReportFields(),thisUOMIndex) > 
		<cfif UOM_Field EQ "ClaimCS">
			<td>#NumberFormat(round(claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "PaidCS">
			<td>#NumberFormat(claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "Paid_Amount">
			<td>#NumberFormat(claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "Claim_Amount">
			<td>#NumberFormat(claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "PD_VS_RD_Days">
			<td>#claimSummaryHandle.getProgramAvg_PD_VS_RD_Days(preSumFieldV)#</td>
		<cfelseif UOM_Field EQ "RD_VS_ED_Days">
			<td>#claimSummaryHandle.getProgramAvg_RD_VS_ED_Days(preSumFieldV)#</td>
		<cfelseif UOM_Field EQ "ED_VS_CD_Days">
			<td>#claimSummaryHandle.getProgramAvg_ED_VS_CD_Days(preSumFieldV)#</td>
		<cfelseif UOM_Field EQ "CD_VS_PD_Days">
			<td>#claimSummaryHandle.getProgramAvg_CD_VS_PD_Days(preSumFieldV)#</td>
		<!----- particularly for participation ---->
		<cfelseif UOM_Field EQ "Field_Execution_Cases">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "Bid_Request_Cases">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimBidRequestCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Cases">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Cases">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Cases">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "total_cases">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimTotalCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</td>
		<cfelseif UOM_Field EQ "Field_Execution_Dollars">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "Bid_Request_Dollars">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Dollars">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Dollars">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Dollars">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</td>
		<cfelseif UOM_Field EQ "total_dollars">
			<td nowrap>#NumberFormat(claimSummaryHandle.getClaimTotalDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</td>
		<cfelse>
			<td>&nbsp;</td>
		</cfif>
	</cfloop>
	<td colspan="#ListLen(cmpHandle.getReportFields()) - ListGetAt(thisReportUOMFieldList, 1) - ListLen(thisReportUOMFieldList) + 1#">&nbsp;</td>
</tr>
</cfoutput>