<!----- include those rows for claimHeader ---->
<tr class="claimSumSecondaryHeader">
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		<td colspan="<cfoutput>#ListGetAt(thisReportUOMFieldList, 1) - 1#</cfoutput>" nowrap>
	</cfif>
	<cfoutput>Total for #preSecondLevelFV#</cfoutput>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		</td>
	</cfif>
	 <cfset preIndex = 1 >
	<cfloop list="#thisReportUOMFieldList#" index="thisUOMIndex">
		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV">
			<cfloop from="1" to="#thisUOMIndex-preIndex#" index = "i" step="1"><cfoutput>,</cfoutput></cfloop>
			<cfset preIndex = thisUOMIndex+1 />
		</cfif>
		<cfset UOM_Field = ListGetAt(cmpHandle.getReportFields(),thisUOMIndex) > 
		<cfif UOM_Field EQ "ClaimCS">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td><cfoutput>#NumberFormat(round(claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td><cfoutput>#NumberFormat(round(claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "PaidCS">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Paid_Amount">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Claim_Amount">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td><cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
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
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV,trim(preSecondLevelFV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Bid_Request_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestCases(preSumFieldV,trim(preSecondLevelFV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV,trim(preSecondLevelFV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV,trim(preSecondLevelFV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">	
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV,trim(preSecondLevelFV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "total_cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalCases(preSumFieldV,trim(preSecondLevelFV)), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalCases(preSumFieldV,trim(preSecondLevelFV)), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Field_Execution_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV,trim(preSecondLevelFV)), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Bid_Request_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV,trim(preSecondLevelFV)), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV,trim(preSecondLevelFV)), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV,trim(preSecondLevelFV)), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV,trim(preSecondLevelFV)), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "total_dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalDollars(preSumFieldV,trim(preSecondLevelFV)), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalDollars(preSumFieldV,trim(preSecondLevelFV)), "$_______.__")#</cfoutput></td>
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
<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
</tr>
