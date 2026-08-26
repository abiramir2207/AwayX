

<cfloop query="GetItemsForComponent">
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
				<cfif BB_Tolerance_TET IS 1>
				(	Invoice_Date >= '#dateformat(StartDate)#'
					AND
					Invoice_Date <= '#dateformat(EndDate)#'
				)
				<cfelse>
				(	Ship_Date >= '#dateformat(StartDate)#'
					AND
					Ship_Date <= '#dateformat(EndDate)#'
				)
				</cfif>
				ORDER BY Invoice_Date Desc
				</cfquery>

					
				
					<cfset TotalItemVolume = 0>
					<cfset WeightedLB = 0>
					<cfset WeightedCS = 0>
										
					<Cfoutput><Cfif GetInvoices2.recordcount GT 0> <hr color="#Color1#"><table width="95%" cellpadding="0" cellspacing="0" border="0"><tr><td bgcolor="#color3#">#GetInvoices2.Recordcount#&nbsp; invoices for #left(GetItemName.Description, 45)# (#GetItemName.Item#)</td></tr></table></CFIF> </CFOUTPUT>
					<cfif GetInvoices2.Recordcount GT 0><br>
					<table width="95%" border="0" cellspacing="0" cellpadding="0">
					<tr>
					<Td colspan="2"><strong>Invoice #:</strong></TD><Td align="right">Cases:</td><td align="Right">Pounds:</TD><td align="right">Price Paid:</td><td align="right">Date:</td></tr>
					<cfset RecordNumber =0>
					<cfoutput query="GetInvoices2">
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
	
					</cfoutput>
					</table>
					</cfif>
				
		<!---If it is a single rate component--->
		
		<cfif TotalItemVolume GT 0 >
		<cfif HasSeperateVolume IS 0 OR ComponentUOM IS 4>
		<!---Get first tier start--->
			<cfquery name="EligibleVolume" datasource="#application.datasource#">
			SELECT MIN(Range_Start) AS Range_Start, MAX(Range_End) AS Range_End
			FROM Program_Growth_Component_Tiers
			WHERE Program_Growth_Component_ID = '#Component_ID#'
			</cfquery>
			
			<cfquery name="IsStar" datasource="#application.datasource#">
			SELECT Range_END
			FROM Program_Growth_Component_Tiers
			WHERE Program_Growth_Component_ID = '#Component_ID#'
			AND Range_End LIKE '%*%'
			</cfquery>
			
	
		<!---In case it's percent--->
		<cfif ComponentUOM IS 3>
			
			<cfif IsStar.RecordCount EQ 1 OR (EligibleVolume.Range_End * Same_Period_Volume_Percent) GT TotalVolume>		
					<cfset TotalRangeEnd = TotalVolume>
			<cfelse>
					<Cfset TotalRangeEnd = EligibleVolume.Range_End * Same_Period_Volume_Percent>
			</cfif>
		
			<cfset TotalEligibleVolume = TotalRangeEnd - (EligibleVolume.Range_Start * Same_Period_Volume_Percent)>
			<cfset StartingPoint = (EligibleVolume.Range_Start * Same_Period_Volume_Percent)>
		
		<!---Not a percent--->
		<cfelse>
		
			<cfif IsStar.RecordCount EQ 1 OR EligibleVolume.Range_End GT TotalVolume>		
					<cfset TotalRangeEnd = TotalVolume>
			<cfelse>
					<Cfset TotalRangeEnd = EligibleVolume.Range_End>
			</cfif>
		
			<cfset TotalEligibleVolume = TotalRangeEnd - EligibleVolume.Range_Start>
			<cfset StartingPoint = EligibleVolume.Range_Start>
		
		</cfif>
		
		<cfelse>
			<!---All volume is eligible if the program has a seperate volume pool--->
			<cfset TotalEligibleVolume = TotalVolume>
			<cfset StartingPoint = 1>
			
		<!---It has a seperate volume pool--->
		</cfif>
			
				<cfquery name="GetRateForTierItem" datasource="#application.datasource#">
				SELECT Rate, Unit_of_Measure_ID
				FROM Program_Growth_Component_Product_Tier_Data
				WHERE Program_Growth_Component_Tier_ID = '#Tier#'
				AND Program_Growth_Component_Product_Data_ID = '#Program_Growth_Component_Product_Data_ID#'
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

		<cfif RateType IS 1>		
				<cfoutput>
											
					<!---Figure out what percentage of each item makes of the whole.---->
					<cfset ItemPercent = TotalItemVolume / TotalVolume>
					<cfset ItemPercentileVolume = TotalEligibleVolume * ItemPercent>
					 <cfset ItemMoneyEarned = (NewRate * ItemPercentileVolume)>
					 <cfset GrowthCredit = GrowthCredit + ItemMoneyEarned> 
					
					<table width="95%" border="0" cellpadding="0" cellspacing="0">
					<tr>
					<td>Tier Attained:</td>
					<td align="Right">Item Volume in <cfif UOM IS 1>Cases<cfelse>Pounds</cfif>:</td>
					<td align="Right">Rate:</td>
					<td align="Right">Item Total:</td>
					</tr>
					<tr>
					<td valign="top">#TierNumber#</td>
					<td align="Right" valign="top">#NumberFormat(ItemPercentileVolume, '___,___,___')#</td>
					<td align="Right" valign="top">#LSCurrencyFormat(NewRate)#/<cfif UOM IS 1>Cs<cfelse>Lb</cfif>
					
					<cfif GetRateForTierItem.Unit_of_Measure_ID IS 3><br>
					(#LSCurrencyFormat(AverageCost)# * #round(GetRateForTierItem.Rate)#%)
					</cfif>
				</td>
					<td align="Right" valign="top">#LSCurrencyFormat(ItemMoneyEarned)#</td>
					</tr>
					</table>
				<cfset ComponentMoneyEarned = ComponentMoneyEarned + ItemMoneyEarned>
			
				</cfoutput>			
				
		<!---If it is a multi rate component--->
		<cfelse>
 		
		<cfset Program_Growth_Component_Product_Data_ID = #Program_Growth_Component_Product_Data_ID#>
		
			<table width="95%" border="0" cellpadding="0" cellspacing="0">	
			<tr>
			<Td>Tier Number:</TD>
			<td align="right">Volume in <cfif UOM IS 1>Cases<cfelse>Pounds</cfif></td>
			<td align="right">Rate:</td>
			<td align="right">Total:</td>
			</tr>	

			<cfloop query="GetTier">
				<cfset ItemVolume = TotalItemVolume>	
			
			<cfif ComponentUOM IS 3>
			
				<cfquery name="GetRateForTiers" datasource="#application.datasource#">
				SELECT Program_Growth_Component_Product_Tier_Data.Rate,
				Program_Growth_Component_Product_Tier_Data.Unit_of_Measure_ID, 
				Program_Growth_Component_Tiers.Tier_Number,
				(cast(Program_Growth_Component_Tiers.Range_Start as float) * #Same_Period_Volume_Percent#) AS Range_Start,
				CASE 
				WHEN Program_Growth_Component_Tiers.Range_End LIKE '*'
				THEN
				Program_Growth_Component_Tiers.Range_End
				ELSE
				CAST((cast(Program_Growth_Component_Tiers.Range_End as float) * #Same_Period_Volume_Percent#) AS NVARCHAR(50))
				END AS Range_End
				FROM Program_Growth_Component_Product_Tier_Data
					 INNER JOIN Program_Growth_Component_Tiers ON
					Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Program_Growth_Component_PRoduct_Tier_Data.Program_Growth_Component_Tier_ID
				WHERE Program_Growth_Component_Product_Data_ID = '#Program_Growth_Component_Product_Data_ID#'
	AND Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = '#Program_Growth_Component_Tier_ID#'
				AND Program_Growth_Component_Product_Tier_Data.Deleted = 0
				ORDER BY Program_Growth_Component_Tiers.Tier_Number
				</cfquery> 
			
			<cfelse>
			
				<cfquery name="GetRateForTiers" datasource="#application.datasource#">
				SELECT Program_Growth_Component_Product_Tier_Data.Rate,
				Program_Growth_Component_Product_Tier_Data.Unit_of_Measure_ID, 
				Program_Growth_Component_Tiers.Tier_Number,
				Program_Growth_Component_Tiers.Range_Start,
				Program_Growth_Component_Tiers.Range_End
				FROM Program_Growth_Component_Product_Tier_Data
					 INNER JOIN Program_Growth_Component_Tiers ON
					Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Program_Growth_Component_PRoduct_Tier_Data.Program_Growth_Component_Tier_ID
				WHERE Program_Growth_Component_Product_Data_ID = '#Program_Growth_Component_Product_Data_ID#'
	AND Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = '#Program_Growth_Component_Tier_ID#'
				AND Program_Growth_Component_Product_Tier_Data.Deleted = 0
				ORDER BY Program_Growth_Component_Tiers.Tier_Number
				</cfquery> 
			
			</cfif>						
			
		
			<cfset TotalVolume2 = TotalVolume>
	
			<cfoutput query="GetRateForTiers"> 
			
				<cfif  GetRateForTiers.Unit_of_Measure_ID NEQ UOM>
				<cfif GetRateForTiers.Unit_of_Measure_ID IS 1>
				<cfset NewRate = GetRateForTiers.Rate / Item_Net_Weight>	
					<!---Convert cases to pounds--->
				<cfelseif GetRateForTiers.Unit_of_Measure_ID IS 2>
					<!---Convert pounds to cases--->
					<cfset NewRate = GetRateForTiers.Rate * Item_Net_Weight>
				<cfelseif GetRateForTiers.Unit_of_Measure_ID IS 3>
				<!---Convert to percentage--->
				
					<cfif UOM IS 1>
							<cfset AverageCost = WeightedCS / TotalItemVolume>
						<cfelse>
							<cfset AverageCost = WeightedLB / TotalItemVolume>
						</cfif>
						
						<cfset NewRate = AverageCost * (GetRateForTiers.Rate/100)>
				</cfif>
			<cfelse>
				<Cfset NewRate = Rate>
			</cfif>
		
			<cfset NumberofTiers = GetRateForTiers.Recordcount>
			
				<cfif Range_End IS "*" OR Range_End GT TotalVolume>		
					<cfset Range_End_Amended = TotalVolume>
				<cfelse>
					<Cfset Range_End_Amended = Range_End>
				</cfif>
				
				<cfset VolumePerTier = Range_End_Amended - Range_Start + 1>
					
				<cfif TotalVolume2 GT TotalEligibleVolume>
					<cfset VolumeOverflow = TotalVolume2 - TotalEligibleVolume>
					<cfset TotalVolume2 = TotalVolume2 - VolumeOverflow> 
				<cfelse>
					<cfset TotalVolume2 = TotalVolume2>
				</cfif>

				<cfset ItemPercentPerTier = TotalItemVolume/TotalVolume>
				<cfset ItemVolumePerTier = ItemPercentPerTier*VolumePerTier>
				
				<cfset MoneyEarned = NewRate * ItemVolumePerTier>
				<cfset GrowthCredit = GrowthCredit + MoneyEarned>
				<cfset ComponentMoneyEarned = ComponentMoneyEarned + MoneyEarned>
						
				<tr><td valign="top"><strong>#Tier_Number#:</strong></td><td align="right" valign="top"> #NumberFormat(ItemVolumePerTier, '___,___,___,___')#<!---  #UOMUsed# ---></td>
				
			<td align="Right" valign="top">#LSCurrencyFormat(NewRate)#/<cfif UOM IS 1>Cs<cfelse>Lb</cfif>
			
					<cfif GetRateForTierItem.Unit_of_Measure_ID IS 3><br>
					(#LSCurrencyFormat(AverageCost)# * #round(GetRateForTiers.Rate)#%)
					</cfif>
				</td>
	
				<td align="right">
				<cfif left(MoneyEarned, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif>#LSCurrencyFormat(MoneyEarned)#</font></td></tr>

			
			</cfoutput>
			<!---If there's actually an item to get a rate for--->
			
			<!---Get Tier Query--->
			</cfloop>
			</table>
		<!---Component rate type--->
		</cfif>
		<!---If the volume of the items is greater than 0--->
		</cfif>
				<!---End for each item--->

			</cfloop>
			