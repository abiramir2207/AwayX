<cfoutput query="GetItemsForComponent">
	<cfquery name="GetItemName" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.Net_Weight, Invoice_Detail.LB_Unit_Price, Invoice_Detail.CS_Unit_Price, BSA_Foodservice_Items_Master.Item
	FROM BSA_Foodservice_Items_Master
		INNER JOIN Invoice_Detail 
		ON Invoice_Detail.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
	</cfquery>
	
	<cfset Item_Net_Weight = GetItemName.Net_Weight>
	<!---Gets the unit price for %--->
	<cfif UOM IS 1>
		<cfset Item_Unit_Price = GetItemName.CS_Unit_Price>
	<cfelseif UOM IS 2>
		<cfset Item_Unit_Price = GetItemName.LB_Unit_Price>
	<cfelse>
		<cfset Item_Unit_Price = 0>
	</cfif>
			
	<!---Get invoices for those items, that also match distributor and date range--->
	<cfquery name="GetInvoices2" datasource="#application.datasource#">
	SELECT Pounds_Invoiced, Cases_Invoiced, Invoice_Date, BSA_Foodservice_Items_Master_ID, Shared_Invoice_Number, CS_Unit_Price, LB_Unit_Price
	FROM GetInvoicesForLedger
	WHERE BSA_Foodservice_Items_Master_ID = '#GetItemsForComponent.BSA_Foodservice_Items_Master_ID#'
	AND BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
	AND 
	(	Invoice_Date >= '#dateformat(StartDate)#'
		AND
		Invoice_Date <= '#dateformat(EndDate)#'
	)
	ORDER BY Invoice_Date Desc
	</cfquery>

	<cfset TotalItemVolume = 0>
	<cfset WeightedLB = 0>
	<cfset WeightedCS = 0>
															
	<Cfif GetInvoices2.recordcount GT 0> 
					
					
		<hr color="#Color1#"><table width="95%" cellpadding="0" cellspacing="0" border="0"><tr><td bgcolor="#color3#">#GetInvoices2.Recordcount#&nbsp; invoices for #left(GetItemName.Description, 45)# (#GetItemName.Item#)</td></tr></table>
		<br>
		<table width="95%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		<Td colspan="2"><strong>Invoice ##:</strong></TD><Td align="right">Cases:</td><td align="Right">Pounds:</TD><td align="right">Price Paid:</td><td align="right">Date:</td></tr>
		<cfset RecordNumber =0>
		
		<cfloop query="GetInvoices2">
			<Cfset RecordNumber = RecordNumber + 1>
			<Tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
			<td>#RecordNumber#.&nbsp; </td>
			<td>#Shared_Invoice_Number#</td>

			<td align="right">#numberformat(Cases_Invoiced, '___,___,___,___')#</td>   
			
			<td align="right"> #numberformat(Pounds_Invoiced, '___,___,___,___')# </td> 
			<!---Display Case price--->
			<cfif UOM IS 1>
				<td align="right"> #LSCurrencyFormat(CS_Unit_Price)#/CS </td>  
			<!---Display Pound price--->
			<cfelse>
				<td align="right"> #LSCurrencyFormat(LB_Unit_Price)#/LB </td>  
			</cfif>	
			 <td align="right">#DateFormat(Invoice_Date, 'MM/DD/YY')# </td>
			
			</TR>
				
			<!---Gets average price for % rate--->		
			 <cfset WeightedLB = WeightedLB + (Cases_Invoiced * CS_Unit_Price)> 
			 <cfset WeightedCS = WeightedCS + (Pounds_Invoiced * LB_Unit_Price)>
			

			<cfif UOM IS 1>
				<cfset TotalItemVolume = trim(GetInvoices2.Cases_Invoiced) + TotalItemVolume>
			<cfelse>
				<cfset TotalItemVolume = trim(GetInvoices2.Pounds_Invoiced) + TotalItemVolume>
			</cfif>
			<cfif len(TotalItemVolume) IS 0>
				<cfset TotalItemVolume = 0>
			</cfif>
				
		<!---Get Invoices 2--->
		</cfloop>
		</table>
		
		<!---If it is a single rate component--->
		<cfif TotalItemVolume GT 0 >
						
			<cfquery name="GetRateForTierItem" datasource="#application.datasource#">
			SELECT Rate, Unit_of_Measure_ID
			FROM Program_Growth_Component_Product_Tier_Data
				INNER JOIN Program_Growth_Component_Tiers ON Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID
				AND Program_Growth_Component_Tiers.Deleted = 0
				AND Program_Growth_Component_Tiers.Tier_Number = #TierAttained#
				AND Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#Component_ID#'
			WHERE Program_Growth_Component_Product_Tier_Data.Deleted = 0 
			</cfquery> 
							
			<cfif  GetRateForTierItem.Unit_of_Measure_ID NEQ UOM>
				<cfif GetRateForTierItem.Unit_of_Measure_ID IS 1>
					<cfset NewRate = GetRateForTierItem.Rate / Item_Net_Weight>	
					<!---Convert cases to pounds--->
				<cfelseif GetRateForTierItem.Unit_of_Measure_ID IS 2>
					<!---Convert pounds to cases--->
					<cfset NewRate = GetRateForTierItem.Rate * Item_Net_Weight>
				<!---Percent--->
				<cfelseif GetRateForTierItem.Unit_of_Measure_ID IS 3>
				
				<!---Get Price * Volume for all, then sum amounts and volumes. Divide sum amount by sum volume to arrive at average weighted price --->
					<cfif UOM IS 1>
						<cfset AverageCost = WeightedCS / TotalItemVolume>
					<cfelse>
						<cfset AverageCost = WeightedLB / TotalItemVolume>
					</cfif>
					
					<cfset NewRate = AverageCost * (GetRateForTierItem.Rate/100)>
				</cfif>
					
			<!---Get time the percentage--->
			<cfelse>
				<Cfset NewRate = GetRateForTierItem.Rate>
			</cfif>
					
			<!---Figure out what percentage of each item makes of the whole.---->
			 <cfset ItemMoneyEarned = (NewRate * TotalItemVolume)>
			 <cfset GrowthCredit = GrowthCredit + ItemMoneyEarned> 
			
			<table width="95%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			<td>Tier Attained:</td>
			<td align="Right">Item Volume in <cfif UOM IS 1>Cases<cfelse>Pounds</cfif>:</td>
			<td align="Right">Rate:</td>
			<td align="Right">Item Total:</td>
			</tr>
			<tr>
			<td valign="top">#TierAttained#</td>
			<td align="Right" valign="top">#NumberFormat(TotalItemVolume, '___,___,___')#</td>
			<td align="Right" valign="top">#LSCurrencyFormat(NewRate)#/<cfif UOM IS 1>Cs<cfelse>Lb</cfif>
			
			<cfif GetRateForTierItem.Unit_of_Measure_ID IS 3><br>
			(#LSCurrencyFormat(AverageCost)# * #round(GetRateForTierItem.Rate)#%)
			</cfif>
			</td>
			<td align="Right" valign="top">#LSCurrencyFormat(ItemMoneyEarned)#</td>
			</tr>
			</table>
			<cfset ComponentMoneyEarned = ComponentMoneyEarned + ItemMoneyEarned>
		<!---Item volume greater than 0--->	
		</cfif>
	<!---If there are invoices in invoices 2--->
	</cfif>
<!---Loop through items--->	
</cfoutput>			
		