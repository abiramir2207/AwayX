
<!---Growth credit--->
<cfset GrowthCredit = 0>
<cfparam name="ComponentMoneyEarned" default="0">


<!---Gets the components for a particular growth program--->
<cfset useLakebaseForGetComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForGetComponents>
	<cftry>
		<cfset GetComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", {
				"program_id" = "eq.#ContractID#",
				"isparent" = "eq.1",
				"deleted" = "eq.0",
				"select" = "program_growth_component_id,component_uom,comparison_type,sample_period,rate_type,component_name,program_growth_component_type_id,isparent"
			}), "program_growth_component_id,component_uom,comparison_type,sample_period,rate_type,component_name,program_growth_component_type_id,isparent"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetComponents>
<cfquery name="GetComponents" datasource="#application.datasource#">
SELECT Program_Growth_Component_ID, component_uom, Comparison_Type, Sample_Period, Rate_Type, Component_Name, Program_Growth_Component_Type_ID, IsParent
FROM Program_Growth_Components 
WHERE Program_ID = '#ContractID#'
AND IsParent  = 1
AND Deleted = 0
</cfquery>
</cfif>

<table WIDTH="99%" align="center"  border="0"  cellspacing="0" cellpadding="2">

<tr><td width="50%" valign="top">

<!---If there are any growth components--->
<cfif GetComponents.recordcount GT 0>
<table class="maintable" cellpadding="0" cellspacing="0" width="100%"><Tr><td>Component:</TD><Td align="right">Total Volume:</td></TR></table>
<!--- 	<em>Before Get Components Loop</em><p></p> --->
	
	<cfloop query="GetComponents"> 
	<cfset ComponentUOM = GetComponents.Component_UOM>
	<cfset ComponentType = GetComponents.Program_Growth_Component_Type_ID>
	<cfset ComponentID = GetComponents.Program_Growth_Component_ID>
	
	<cfset TotalVolume=0>
	
	<cfset ComponentMoneyEarned = 0>
	<cfoutput>

	<table width="99%" border="0" class="maintable" cellpadding="0" cellspacing="0">
	<tr bgcolor="#color3#"><td valign="top" colspan="3">
#trim(GetComponents.Component_Name)# (<cfif GetComponents.Rate_Type IS 1>Single<cfelse>Multirate</cfif>)</td></tr>

	</cfoutput>
	<cfset LumpSumAmount = 0>
	<cfset Component_ID = GetComponents.Program_Growth_Component_ID>
	
		<!---Get rate and lump sums--->
		
		<cfset useLakebaseForGetItemsForComponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getitemsforgrowthcomponent")>
<cfif useLakebaseForGetItemsForComponent>
	<cftry>
		<cfset GetItemsForComponent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getitemsforgrowthcomponent", {
				"program_growth_component_id" = "eq.#Component_ID#",
				"select" = "bsa_foodservice_items_master_id,product_group_level_id,product_group_id,program_growth_component_product_data_id"
			}), "bsa_foodservice_items_master_id,product_group_level_id,product_group_id,program_growth_component_product_data_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetItemsForComponent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetItemsForComponent>
<cfquery name="GetItemsForComponent" datasource="#application.datasource#">
		SELECT 	BSA_Foodservice_Items_Master_ID, 
				Product_Group_Level_ID,
				Product_Group_ID,
				Program_Growth_Component_Product_Data_ID
		FROM 	GetItemsForGrowthComponent
		WHERE 	
				Program_Growth_Component_ID = '#Component_ID#'
		</cfquery>
</cfif>
		
		<!------ Find if any products is 'All products' ----->
		<cfset useLakebaseForqCheckGroupProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getitemsforcomponent")>
<cfif useLakebaseForqCheckGroupProducts>
	<cftry>
		<cfset qCheckGroupProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getitemsforcomponent", {
				"product_group_level_id" = "eq.1",
				"select" = "bsa_foodservice_items_master_id,product_group_id,program_growth_component_product_data_id"
			}), "bsa_foodservice_items_master_id,product_group_id,program_growth_component_product_data_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckGroupProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckGroupProducts>
<cfquery name="qCheckGroupProducts" dbtype="query">
			SELECT		BSA_Foodservice_Items_Master_ID, Product_Group_ID, Program_Growth_Component_Product_Data_ID
			FROM		GetItemsForComponent
			WHERE
						Product_Group_Level_ID = 1
		</cfquery>
</cfif>
		
		<cfif qCheckGroupProducts.recordCount>
		
			<cfset Product_Group_ID = qCheckGroupProducts.Product_Group_ID />
			<cfset ProductID = qCheckGroupProducts.BSA_Foodservice_Items_Master_ID />
			<cfset Original_Program_Growth_Component_Product_Data_ID = qCheckGroupProducts.Program_Growth_Component_Product_Data_ID />
			<!------ Go and get all products bought by this distributor during the concerned dates ----->
			<cfquery name="GetItemsForComponent" datasource="#application.datasource#">
				SELECT		DISTINCT
							Invoice_Detail.BSA_Foodservice_Items_Master_ID,
							BSA_Foodservice_Items_Master.Description as ItemName,
							'#ProductID#' As RateProductID,
							'#Original_Program_Growth_Component_Product_Data_ID#' As Program_Growth_Component_Product_Data_ID
				FROM		Invoice_Header
							INNER JOIN Invoice_Detail
							ON
							Invoice_Detail.Deleted = 0
							AND
							Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
							INNER JOIN BSA_Foodservice_Items_Master
							ON
							BSA_Foodservice_Items_Master.Deleted = 0
							AND
							BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Invoice_Detail.BSA_Foodservice_Items_Master_ID
				WHERE
							Invoice_Header.Deleted = 0
							AND
							Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#'
							AND
							<cfif BB_Tolerance_TET IS 1>
							(	Invoice_Header.Invoice_Date >= #createODBCDate(StartDate)#
								AND
								Invoice_Header.Invoice_Date <= #createODBCDate(EndDate)#
							)
							<cfelse>
							(	Invoice_Header.Ship_Date >= #createODBCDate(StartDate)#
								AND
								Invoice_Header.Ship_Date <= #createODBCDate(EndDate)#
							)
							</cfif>
			</cfquery>
		</cfif>
		
		
		<!---If there is at least one Product returned--->
		<cfif GetItemsForComponent.recordcount GT 0>
		
		<cfinclude template="/billbacks/ledger/details/growth_tier_inc.cfm">
		
		<!---If it's normal--->
		<cfif ComponentType IS 1>
		<!---If it made the bottom tier--->
			<cfif TierCount GT 0>

			<cfif ComponentUOM IS 1>
					<cfset CUOMDesc = " CS">
				<cfelseif ComponentUOM IS 2>
					<cfset CUOMDesc = " LB">
				<cfelseif ComponentUOM IS 3>
					<cfset CUOMDesc = "%">
				<cfelseif ComponentUOM IS 4>
					<cfset CUOMDesc = "$">
			</cfif>
			
			<cfif UOM IS 1>
				<cfset ProgramUOM = " CS">
			<cfelse>
				<cfset ProgramUOM = " LB">
			</cfif>
				
			<cfloop query="GetTier">
						
				<cfoutput> 
					
					<!---Calculates range end for cases and pounds--->
					<!---Adds lump sum earned to growth credit--->
					<!--- <cfif ComponentUOM IS NOT 3> --->
					<cfset GrowthCredit = GrowthCredit + Growth_Amount>
					
					<cfif ComponentUOM IS 3>
					
					<!---Shows both ranges if it's %--->
					<tr><td valign="top">Tier #Tier_Number# (#RS_Detail##CUOMDesc# - #RE_Detail##CUOMDesc#) </td><td><cfif Range_Start IS 0>
	<cfset Starting = RS_Detail * Same_Period_Volume_Percent>(#NumberFormat(Starting, '___,___,___,___')#
<cfelse>(#NumberFormat(Range_Start, '___,___,___,___')#</cfif> - <cfif isNumeric(Range_End)>#NumberFormat(Range_End, '___,___,___,___')#<cfelse>#Range_End#</cfif>)</td><td align="right" valign="top">#Application.BonusLabel#:&nbsp; &nbsp; &nbsp;   #LSCurrencyFormat(Growth_Amount)#</td></tr>
					<cfelseif ComponentUOM IS 4>
					<tr><td valign="top">Tier #Tier_Number# (#CUOMDesc##Range_Start# - #CUOMDesc##Range_End#)</td><td align="right" valign="top" colspan="2"> #Application.LumpsumLabel#:  &nbsp; &nbsp; &nbsp; #LSCurrencyFormat(Growth_Amount)#</td></tr>
					<cfelse>
<tr><td valign="top">Tier #Tier_Number# (#Range_Start##CUOMDesc# - #Range_End##CUOMDesc#)</td><td align="right" valign="top" colspan="2"> #Application.LumpsumLabel#:  &nbsp; &nbsp; &nbsp; #LSCurrencyFormat(Growth_Amount)#</td></tr>
					</cfif>
						<cfif GetTier.Range_End IS "*">
							<cfset Range_End2 = TotalVolume + 1>
						<cfelse>
							<cfset Range_End2 = GetTier.Range_End>
						</cfif>
						 	 <cfset Tier = GetTier.Program_Growth_Component_Tier_ID>
						<cfset Range_Start = GetTier.Range_Start>
								 
					<cfset LumpSumAmount = LumpSumAmount + Growth_Amount>
					<Cfset TierNumber = Tier_Number>
					
				</cfoutput>
			</cfloop>
		
			<!---Now that I have the tier, I get the rate for the tier for the item. I have to loop through the items a second time.--->
			<tr><td colspan="3" align="Center" >
			
			<cfif ShowDetails IS 0>
			<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image=""
			ImageOpen=""
			Title="Details for this Component"  
			TitleClosed="Details for this Component"  
			TitleTooltip="Click here to toggle the view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="99%">	
			
			<cfinclude template="growth_item_inc.cfm">
			</CF_openLayer> 
			<cfelse>
			<cfinclude template="growth_item_inc.cfm">
			</cfif>	
			<!--- <em>After Items for Component</em> --->
		
		<!---If it was enough to make the tier--->
		<cfelse>
		<td valign="top" align="right" colspan="3">This component did not  reach the first tier</td>
		</cfif>
		
			
			<!---It's a component with a target--->
			<cfelse>
			
			<cfquery name="GetCompletedTargetInformation" dbtype="query">
			SELECT Component_Name, Target_Order, Growth_Amount
			FROM GetTargetComponents
			<cfif ListOfHitTargets neq "">
				WHERE Target_ID IN (#preservesinglequotes(ListOfHitTargets)#)
			</cfif>
			ORDER BY Target_Order
			</cfquery>				
			
			<cfloop query="GetCompletedTargetInformation">
			
			<cfoutput> 
					
					<!---Calculates range end for cases and pounds--->
					<!---Adds lump sum earned to growth credit--->
					<!--- <cfif ComponentUOM IS NOT 3> --->
					
				<cfset GrowthCredit = GrowthCredit + Growth_Amount>			 
					<cfset LumpSumAmount = LumpSumAmount + Growth_Amount>
					
					<tr><td valign="top">Target #Target_Order#:  </td><td>#GetCompletedTargetInformation.Component_Name# </td><td align="right" valign="top">#Application.BonusLabel#:&nbsp; &nbsp; &nbsp;   #LSCurrencyFormat(Growth_Amount)#</td></tr>
					
				</cfoutput>
			
			</cfloop>
			
			<tr><td colspan="3" align="Center" >
			
			<cfif ShowDetails IS 0>
			<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image=""
			ImageOpen=""
			Title="Details for this Component"  
			TitleClosed="Details for this Component"  
			TitleTooltip="Click here to toggle the view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="99%">	
			
			<cfinclude template="growth_item_for_tier_inc.cfm">
			</CF_openLayer> 
			<cfelse>
			<cfinclude template="growth_item_for_tier_inc.cfm">
			</cfif>	
			
			<!---What type of component it is--->
			</cfif>
		
		
		<!---One or more products returned--->
		<cfelse>
		<td valign="top" align="right" width="70" colspan="3"><p>&nbsp; </p>0 invoices</td>
		</cfif>
			</td></tr>
		<cfoutput>		<tr><td>&nbsp; </td><td>Earnings for rate:</td><td align="right"> #LSCurrencyFormat(ComponentMoneyEarned)#</td></tr>

	<cfset ComponentTotal = LumpSumAmount + ComponentMoneyEarned>
	<tr><td>&nbsp; </td><td valign="top">Total for Component:</td><td align="right" colspan="2">#LSCurrencyFormat(ComponentTotal)#</td></tr></cfoutput>
		</table>
		<table width="95%" ><tr><td>&nbsp; </td></tr></table>
		</cfloop>

<!---If there are any growth components--->
<cfelse>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; No growth components
</cfif>
</td>

<td valign="top" width="50%">
 <cfset GrowthDebit = 0>
<cfquery name="GetAllBillbacks" datasource="#application.datasource#">
SELECT DISTINCT Billback.Billback_ID, Billback.BB_Date, BB_Growth_Program.Paid_Amount
FROM Billback
	INNER JOIN	Billback_Program
	ON
	(
		(Billback_Program.Billback_ID = Billback.Billback_ID)
		AND
		(Billback_Program.Deleted = 0)
		AND Billback_Program.Program_ID IN (#preservesinglequotes(ProgramNumber)#)
	)
	INNER JOIN	BB_Growth_Program
	ON	
	(
		(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND
		(BB_Growth_Program.Deleted = 0)
	)	 
	INNER JOIN	Billback_Distributor			
	ON
	(
		(Billback_Distributor.Distributor_ID = '#DistributorNumber#')
		AND
		(Billback_Distributor.Billback_ID = Billback.Billback_ID)
		AND
		(Billback_Distributor.Deleted = 0)
	)
WHERE
Billback.Deleted = 0		
 AND
Billback.Billback_Status_ID >= 3  
AND BB_Growth_Program.Paid_Amount IS NOT NULL
</cfquery>

<table border="0"  CLASS="SubTable" cellpadding="0" cellspacing="0" width="100%">


<tr>
<td valign="top" style="border-bottom:solid #93BEE2 1px;">Date: </td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Payable Number:</td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" nowrap>Billback Number:</td>
<td valign="top" align="right" style="border-bottom:solid #93BEE2 1px;" nowrap>Billback Amount:</td>
</tr>

<cfoutput query="GetAllBillbacks">
<cfif Paid_Amount GT 0>
<cfset GrowthDebit = GrowthDebit + Paid_Amount>
		
	<cfquery name="GetBBInfo" datasource="#application.datasource#">
	SELECT BB_Title, BB_Date, BB_Code, BB_Reference FROM Billback
	WHERE Billback_ID = '#Billback_ID#'
	</cfquery>
	
	<cfset BB_Reference = GetBBInfo.BB_Reference>
	
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#DateFormat(GetBBInfo.BB_Date, 'MM/DD/YYYY')# </td>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;" nowrap>#GetBBInfo.BB_Reference#</td>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;" nowrap>#GetBBInfo.BB_Code#</td>
<td valign="top" align="right" style="border-bottom:solid ##93BEE2 1px;" nowrap> #LSCurrencyFormat(Paid_Amount)#</td>
</tr>
</cfif>		
</cfoutput>

<cfif GetAllBillbacks.recordcount EQ 0>
<Tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="Right" colspan="2">No billbacks found</td>
</TR>
</cfif> 

<tr><td colspan="4"><p>&nbsp; </p><blockquote><strong>NOTE:</strong> The <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s earned in growth programs are shown as debits in the <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> section.</blockquote></td></tr>

</table> 

</td></tr>
</table>

