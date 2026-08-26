<tr class="claimSumHeader">
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		<td colspan="<cfoutput>#ListGetAt(thisReportUOMFieldList, 1) - 1#</cfoutput>" nowrap>
	</cfif>
		<cfoutput>Total for #preSumFieldV# </cfoutput><cfif CountProcessedClaims EQ true><cfoutput>( Claims Processed: #claimSummaryHandle.getProgramTotalProcessed(preSumFieldV)# )</cfoutput></cfif>
	 <cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		</td>
	</cfif>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
 	<cfset preIndex = 2 >
	<cfloop list="#thisReportUOMFieldList#" index="thisUOMIndex">
  		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV">
			<cfloop from="1" to="#thisUOMIndex-preIndex#" index = "i" step="1"><cfoutput>,</cfoutput></cfloop>
			<cfset preIndex = thisUOMIndex+1 />
		</cfif>
		<cfset UOM_Field = ListGetAt(cmpHandle.getReportFields(),thisUOMIndex) > 
		<cfif UOM_Field EQ "ClaimCS">
			<td>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(round(claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)), "_,___,___")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(round(claimSummaryHandle.getProgramTotalClaimCS(preSumFieldV)), "_______")#</cfoutput>
				</cfif>
			</td>
		<cfelseif UOM_Field EQ "PaidCS">
			<td>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV), "_,___,___")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidCS(preSumFieldV), "_______")#</cfoutput>
				</cfif>
			</td>
		<cfelseif UOM_Field EQ "Paid_Amount">
			<td>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV), "$_,___,___.__")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalPaidAmount(preSumFieldV), "$_______.__")#</cfoutput>
				</cfif>
			</td>
		<cfelseif UOM_Field EQ "Claim_Amount">
			<td>
				<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
					<cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV), "$_,___,___.__")#</cfoutput>
				<cfelse>
					<cfoutput>#NumberFormat(claimSummaryHandle.getProgramTotalClaimAmount(preSumFieldV), "$_______.__")#</cfoutput>
				</cfif>
			</td>
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
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionCases(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Bid_Request_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestCases(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestCases(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsCases(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingCases(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterCases(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "total_cases">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalCases(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalCases(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Field_Execution_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimFieldExecutionDollars(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Bid_Request_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimBidRequestDollars(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Direct_or_HQ_Programs_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDirectOrHqProgramsDollars(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Operator_Deviated_Pricing_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimOperatorDeviatedPricingDollars(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "Distributor_Trade_Shelter_Dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimDistributorTradeShelterDollars(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "total_dollars">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalDollars(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimTotalDollars(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<!--- for cost saving --->
		<cfelseif UOM_Field EQ "Variation$">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimVariation$(preSumFieldV), "$_,___,___.__")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimVariation$(preSumFieldV), "$_______.__")#</cfoutput></td>
			</cfif>
		<cfelseif UOM_Field EQ "VariationCS">
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimVariationCS(preSumFieldV), "_,___,___")#</cfoutput></td>
			<cfelse>
				<td nowrap><cfoutput>#NumberFormat(claimSummaryHandle.getClaimVariationCS(preSumFieldV), "_______")#</cfoutput></td>
			</cfif>
		<cfelse>
			<td>&nbsp;</td>	
		</cfif>
 		<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
	</cfloop>
	<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) NEQ "CSV">
		<td colspan="<cfoutput>#ListLen(cmpHandle.getReportFields()) - ListGetAt(thisReportUOMFieldList, 1) - ListLen(thisReportUOMFieldList) + 1#</cfoutput>">&nbsp;
			<cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>,</cfoutput></cfif>
		</td>
	</cfif>  
</tr>
 <cfif isDefined("form.reportType") and UCase(trim(form.reportType)) EQ "CSV"><cfoutput>#newLine#</cfoutput></cfif>
