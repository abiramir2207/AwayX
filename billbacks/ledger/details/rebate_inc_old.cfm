<table align="center" cellpadding="3" cellspacing="3" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">

<!---Rebate credit--->

<cfset RebateCredit = 0>
<cfset ComponentEarned = 0>

<cfloop query="GetContractMain">
	<cfset RevisionStart = GetContractMain.Approval_Start_Date>
	<cfset RevisionEnd =  GetContractMain.Approval_End_Date>
	<cfset RevisionID =  GetContractMain.Contract_Main_ID>

	<table width="99%" cellpadding="0" cellspacing="0" border="0">
	<cfoutput><div align="center"><strong>#DateFormat(RevisionStart, 'MMMM D, YYYY')# - #DateFormat(RevisionEnd, 'MMMM D, YYYY')#</strong></div> </cfoutput><br>
	</table>
	
	<!---Get all items--->
	<cfquery name="GetItemNumbers" datasource="#application.datasource#">
		SELECT 		DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID,
					Contract_Products.BSA_Foodservice_Items_Master_ID AS RateProductID,
					Contract_Products.Contract_Products_ID, 
					Contract_Products.Product_Group_Level_ID,
					Contract_Products.Product_Group_ID,
					BSA_Foodservice_Items_Master.Description as ItemName
		FROM 		Program_Rebates_Product_Data 
					INNER JOIN Contract_Products
					ON Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					INNER JOIN BSA_Foodservice_Items_Master 
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
		WHERE 
						Contract_Products.Contract_Main_ID = #RevisionID#
				AND 	Contract_Products.Deleted = 0
				AND 	Program_Rebates_Product_Data.Deleted = 0
				<!--- AND 	Program_Rebates_Product_Data.Rebate_Value IS NOT null--->
	</cfquery>
	
	<!------ Find if any products is 'All products' ----->
	<cfset useLakebaseForqCheckGroupProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getitemnumbers")>
<cfif useLakebaseForqCheckGroupProducts>
	<cftry>
		<cfset qCheckGroupProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getitemnumbers", {
				"product_group_level_id" = "eq.1",
				"select" = "bsa_foodservice_items_master_id,product_group_id,contract_products_id"
			}), "bsa_foodservice_items_master_id,product_group_id,contract_products_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckGroupProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckGroupProducts>
<cfquery name="qCheckGroupProducts" dbtype="query">
		SELECT		BSA_Foodservice_Items_Master_ID, Product_Group_ID, Contract_Products_ID
		FROM		GetItemNumbers
		WHERE
					Product_Group_Level_ID = 1
	</cfquery>
</cfif>		
	<cfif qCheckGroupProducts.recordCount>
		<cfset Product_Group_ID = qCheckGroupProducts.Product_Group_ID />
		<cfset ProductID = qCheckGroupProducts.BSA_Foodservice_Items_Master_ID />
		<cfset Original_Contract_Products_ID = qCheckGroupProducts.Contract_Products_ID />
		<!------ #DistributorNumber# ----->
		<!------ Go and get all products bought by this distributor during the concerned dates ----->
		<cfquery name="GetItemNumbers" datasource="#application.datasource#">
			SELECT		DISTINCT
						Invoice_Detail.BSA_Foodservice_Items_Master_ID,
						BSA_Foodservice_Items_Master.Description as ItemName,
						'#ProductID#' As RateProductID,
						#Original_Contract_Products_ID# As Contract_Products_ID
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
						(	Invoice_Header.Invoice_Date >= #createODBCDate(RevisionStart)#
							AND
							Invoice_Header.Invoice_Date <= #createODBCDate(RevisionEnd)#
						)
						<cfelse>
						(	Invoice_Header.Ship_Date >= #createODBCDate(RevisionStart)#
							AND
							Invoice_Header.Ship_Date <= #createODBCDate(RevisionEnd)#
						)
						</cfif>
		</cfquery>
	</cfif>

	<!--- <cfdump var="#GetItemNumbers#"> --->
	
	<cfset ItemEarned = 0>
	<cfset ItemVolumeLB = 0>
	<cfset ItemVolumeCS = 0>
	<cfset InvoicesFound = 1>
	<cfloop query="GetItemNumbers">
	
		<!---Get all components for each item--->
		<cfquery name="GetAllComponents" datasource="#application.datasource#">
		SELECT Program_Rebates_Component_Name.Program_Rebates_Component_Name, Contract_Products.BSA_Foodservice_Items_Master_ID, Program_Rebates_Component_Data.Rate, Program_Rebates_Component_Data.Unit_Of_Measure_ID, Program_Rebates_Product_Data.Rebate_Value, Program_Rebates_Component_Data.Program_Rebates_Component_Data_ID, Program_Rebates_Product_Data.Volume
		FROM Program_Rebates_Component_Name
			INNER JOIN Program_Rebates_Component
			ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			INNER JOIN Program_Rebates_Component_Data 
			ON Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
			INNER JOIN Program_Rebates_Product_Data 
			ON Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Rebates_Product_Data.Contract_Products_ID
		WHERE Program_Rebates_Component.Program_ID = #RevisionID#
		AND Program_Rebates_Product_Data.Program_ID = #RevisionID#
		AND Program_Rebates_Product_Data.Contract_Products_ID = '#GetItemNumbers.Contract_Products_ID#'
		AND Program_Rebates_Component.Deleted = 0
		AND Program_Rebates_Component_Name.Deleted = 0
		AND Program_Rebates_Product_Data.Deleted = 0
		AND Program_Rebates_Component_Data.Deleted = 0
		<!---Only components paid to Distributors--->
		AND Program_Rebates_Component.Component_Paid_To = 1
		</cfquery>
		<!--- <cfdump var="#GetAllComponents#"> --->
	
		<!---Get all invoices for each item--->
		<cfquery name="InvoicesforRebateComponents" datasource="#application.datasource#">
		SELECT Invoice_Detail.Pounds_Invoiced, Invoice_Detail.Cases_Invoiced,
		 Invoice_Header.Invoice_Date, Invoice_Header.Ship_Date, Invoice_Header.Invoice_Header_ID,
		 Invoice_Detail.BSA_Foodservice_Items_Master_ID, Invoice_Header.Shared_Invoice_Number, Invoice_Detail.CS_Unit_Price, Invoice_Detail.LB_Unit_Price
		FROM Invoice_Header
			INNER JOIN Invoice_Detail ON 
			Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
		WHERE Invoice_Detail.BSA_Foodservice_Items_Master_ID =
		'#GetItemNumbers.BSA_Foodservice_Items_Master_ID#'
		AND Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
		AND 
		<cfif BB_Tolerance_TET IS 1>
		(	Invoice_Header.Invoice_Date >= '#dateformat(RevisionStart)#'
			AND
			Invoice_Header.Invoice_Date <= '#dateformat(RevisionEnd)#'
		)
		<cfelse>
		(	Invoice_Header.Ship_Date >= '#dateformat(RevisionStart)#'
			AND
			Invoice_Header.Ship_Date <= '#dateformat(RevisionEnd)#'
		)
		</cfif>
		AND Invoice_Header.Deleted = 0
		AND Invoice_Detail.Deleted = 0
		<!--- AND Invoice_Header.Order_Status = 'I' --->
		ORDER BY Invoice_Header.Invoice_Date DESC
		</cfquery>
				
		 <!--- <cfdump var="#InvoicesForRebateComponents#"> ---> 
	
	<cfif InvoicesforRebateComponents.Recordcount GT 0>
	
	<!--- <table width="99%" bgcolor="<cfoutput>#color1#</cfoutput>"> --->
	<table width="99%" bgcolor="white" border="0">
	<tr><td  bgcolor="<cfoutput>#color1#</cfoutput>"><cfoutput><strong>#ItemName#</strong></cfoutput></td></tr>
	</table>
	
		<cfif ShowDetails IS 0>
			<cfset ShowDetailParam = "Yes">
		<cfelse>
			<cfset ShowDetailParam = "No">
		</cfif>

		<CF_openLayer
		Border="#Border#"
		BorderSize="#BorderSize#"  
		BorderColor="#BorderColor#"  
		Image=""
		ImageOpen=""
		Title="Details for this Item"  
		TitleClosed="Details for this Item"  
		TitleTooltip="Click here to toggle the view"  
		TitleColor="#TitleColor#"  
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="99%"
		AddScript="#ShowDetailParam#">	
		<cfset ShowClose=1>
			
			<!---Multiply the volume in the invoice times the rate available in the component on the date of the invoice--->
			<cfset ItemComponentCS = 0>
			<cfset ItemComponentLB = 0>
			<cfset WeightedLB = 0>
			<cfset WeightedCS = 0>
	
			<!---Loop through components--->
			<cfloop query="GetAllComponents">
	
			<!---Query InvoicesforRebateComponents for only items in the component--->
				<cfset useLakebaseForInvoicesforItems = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("invoicesforrebatecomponents")>
<cfif useLakebaseForInvoicesforItems>
	<cftry>
		<cfset InvoicesforItems = application.oLakebase.toQuery(
			application.oLakebase.selectRows("invoicesforrebatecomponents", {
				"bsa_foodservice_items_master_id" = "eq.#InvoicesforRebateComponents.BSA_Foodservice_Items_Master_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForInvoicesforItems = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInvoicesforItems>
<cfquery name="InvoicesforItems" dbtype="query">
				SELECT * FROM InvoicesForRebateComponents
				WHERE BSA_Foodservice_Items_Master_ID = '#InvoicesforRebateComponents.BSA_Foodservice_Items_Master_ID#'
				</cfquery>
</cfif>
							
				<cfif InvoicesForItems.Recordcount GT 0>
				
			<div align="Center">
			
				<table width="95%" border="0" cellspacing="0" cellpadding="0" class="maintable" align="center">
				<tr>
					<td colspan="100%"  bgcolor="<cfoutput>#color3#</cfoutput>"><cfoutput>#GetAllComponents.Program_Rebates_Component_Name#</cfoutput></td></tr>
				<tr>
					<Td><strong>Invoice #:</strong></TD>
					<Td align="right"><strong>Cases:</strong></td>
					<td align="Right"><strong>Pounds:</strong></TD>
					<td align="right"><strong>Price Paid:</strong></td>
					<td align="right"><strong>Date:</strong></td>
				</tr>
				
				<cfloop query="InvoicesForItems">
				<cfoutput>
					<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
						<Td valign="top">#Shared_Invoice_Number#</TD>
						<Td valign="top" align="right">#NumberFormat(Cases_Invoiced, '___,___,___.__')#</td>
						<td valign="top" align="Right">#NumberFormat(Pounds_Invoiced, '___,___,___.__')#</TD>
						<td valign="top" align="right">
						<cfif GetAllComponents.Unit_Of_Measure_ID IS 1>
							#LSCurrencyFormat(CS_Unit_Price)#/CS
						<cfelseif GetAllComponents.Unit_of_Measure_ID IS 2>
							#LSCurrencyFormat(LB_Unit_Price)#/LB
						<cfelseif GetAllComponents.Unit_of_Measure_ID IS 3>
							#LSCurrencyFormat(LB_Unit_Price)#/LB<Br>
							#LSCurrencyFormat(CS_Unit_Price)#/CS
						</cfif></td>
						<td align="right">#Dateformat(Invoice_Date, 'MM/DD/YYYY')#</td>
					</tr>	
		
					<cfset ItemComponentCS = ItemComponentCS + InvoicesforItems.Cases_Invoiced>
					<cfset ItemComponentLB = ItemComponentLB + InvoicesForItems.Pounds_Invoiced>
											
						<cfset WeightedLB = WeightedLB + (InvoicesforItems.Pounds_Invoiced * InvoicesforItems.LB_Unit_Price)> 
						<cfset WeightedCS = WeightedCS + (InvoicesforItems.Cases_Invoiced * InvoicesforItems.CS_Unit_Price)>
					
				
				<!---Items for component--->
				</cfoutput>
				</cfloop>
				<tr>
					<td height="20"><strong>Component Total:</strong></td>
					<td align="right">Total LB:</td>
					<td align="right">Total CS:</td>
					<td align="right"><CFOUTPUT>#Application.RebateLabel#:</CFOUTPUT></td>
					<td align="right" colspan="2">Total Earned:</td>
				</tr>
				<tr>
					<cfoutput>
					<td height="20"><strong>&nbsp; </strong></td>
					<td align="right">#NumberFormat(ItemComponentLB, '___,___,___')#</td>
					<td align="right">#NumberFormat(ItemComponentCS, '___,___,___')#</td>
					<td align="right">
						<cfif GetAllComponents.Unit_Of_Measure_ID IS 1>
							#NumberFormat(Rate, '___,___,___.______')#/CS
						<cfelseif GetAllComponents.Unit_of_Measure_ID IS 2>
							#NumberFormat(Rate, '___,___,___.______')#/LB
						<cfelseif GetAllComponents.Unit_of_Measure_ID IS 3>
						<cfif ItemComponentLB eq 0>
							<cfset AverageCost = 0 >
						<cfelse>
							<cfset AverageCost = WeightedLB / ItemComponentLB>
						</cfif>
						<cfset NewRate = AverageCost * (Rate/100)>
							#NumberFormat(NewRate, '___,___,___.______')#/LB
						<br>#Round(Rate)#% * #NumberFormat(AverageCost, '___,___,___.______')#/LB
						</cfif>
					</td>
					<td align="right" colspan="2">
						<cfif GetAllComponents.Unit_Of_Measure_ID IS 1>
							<cfset ComponentEarned = Rate * round(ItemComponentCS)>
							#LSCurrencyFormat(ComponentEarned)#
						<cfelseif GetAllComponents.Unit_of_Measure_ID IS 2>
							<cfset ComponentEarned = Rate * round(ItemComponentLB)>
							#LSCurrencyFormat(ComponentEarned)#
						<cfelseif GetAllComponents.Unit_of_Measure_ID IS 3>
							<cfset ComponentEarned = NewRate * ItemComponentLB>
							#LSCurrencyFormat(ComponentEarned)#
						</cfif>
						
						<cfset RebateCredit = RebateCredit + ComponentEarned>
					</td>
					</cfoutput>
				</tr>
			
			</table>
			</div>
				
				<cfset ItemVolumeLB = ItemVolumeLB + round(ItemComponentLB)>
				<cfset ItemVolumeCS = ItemVolumeCS + round(ItemComponentCS)>
				<cfset ItemEarned = ItemEarned + ComponentEarned>
			<!---There actually were records--->
			<cfelse>
				<cfset InvoicesFound = 0>
			</cfif>
			<!---Components loop--->
			</cfloop>
	
			<!---Sum total dollars and volume for component--->
		<!---Sum total dollars and volume for all components -- don't double count volume!!!!--->
			</CF_openLayer> 


	</cfif>
	<!---Recordcoutn GT 0 for invoices--->
		
	<!---Item number loop--->
	</cfloop>	
	
			<cfoutput>
		<table width="99%" cellpadding="2" cellspacing="0" border="0">
		<tr>
			<td align="left"  bgcolor="<cfoutput>#color3#</cfoutput>"><strong>Total:</strong></td>
			<td align="right" bgcolor="<cfoutput>#color3#</cfoutput>"><strong>#NumberFormat(ItemVolumeLB, '___,___,___,___')# LBS</strong></td>
			<td align="right" bgcolor="<cfoutput>#color3#</cfoutput>"><strong>#NumberFormat(ItemVolumeCS, '___,___,___,___')# CS</strong></td>
			<td align="right" bgcolor="<cfoutput>#color3#</cfoutput>"> <strong>#LSCurrencyFormat(ItemEarned)#</strong></td>
		</tr>
		<tr>
			<td bgcolor="white" colspan="4">&nbsp; </td>
		</tr>
		</table>
		</cfoutput>
	
<!---Program number loop--->
</cfloop>

</td>
<!--- <table align="center" cellpadding="3" cellspacing="3" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">

<!---Rebate credit--->

<cfset RebateCredit = 0>

<!---Get all items in program--->
<cfquery name="GetItemNumbers" datasource="#application.datasource#">
SELECT DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
FROM Program_Rebates_Product_Data 
	INNER JOIN Contract_Products
	ON Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
WHERE Contract_Products.Contract_Main_ID IN (#preservesinglequotes(ProgramNumber)#)
AND Contract_Products.Deleted = 0
AND Program_Rebates_Product_Data.Deleted = 0
AND Program_Rebates_Product_Data.Rebate_Value IS NOT null
</cfquery>


<!---Doesn't go through processing if there are no items that match--->
<cfif GetItemNumbers.Recordcount GT 0>

<table border="0"  CLASS="SubTable" cellspacing="0" cellpadding="2" width="100%">

<tr>
<td valign="top" style="border-bottom:solid #93BEE2 1px;">Item: </td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" align="right">Item $:</td>
</tr>
<tr><td colspan="2"><em>* Program rates calculated nightly</em></td></tr>

</table>

<cfloop query="GetItemNumbers">

<cfquery name="GetInvoices" datasource="#application.datasource#">
SELECT Invoice_Detail.Pounds_Invoiced, Invoice_Detail.Cases_Invoiced, Invoice_Header.Invoice_Date, Invoice_Header.Ship_Date, Invoice_Header.Invoice_Header_ID, Invoice_Detail.BSA_Foodservice_Items_Master_ID, Invoice_Header.Shared_Invoice_Number
FROM Invoice_Header
	INNER JOIN Invoice_Detail ON 
		Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
WHERE Invoice_Detail.BSA_Foodservice_Items_Master_ID = '#GetItemNumbers.BSA_Foodservice_Items_Master_ID#'
AND Invoice_Header.BSA_Foodservice_Customers_ID = '#DistributorNumber#' 
AND 
<cfif BB_Tolerance_TET IS 1>
(	Invoice_Header.Invoice_Date >= '#dateformat(StartDate)#'
	AND
	Invoice_Header.Invoice_Date <= '#dateformat(EndDate)#'
)
<cfelse>
(	Invoice_Header.Ship_Date >= '#dateformat(StartDate)#'
	AND
	Invoice_Header.Ship_Date <= '#dateformat(EndDate)#'
)
</cfif>
AND Invoice_Header.Deleted = 0
AND Invoice_Detail.Deleted = 0
AND Invoice_Header.Order_Status = 'I'
ORDER BY Invoice_Header.Invoice_Date DESC
</cfquery>

<cfif GetInvoices.Recordcount GT 0>
<cfset useLakebaseForGetItemName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetItemName>
	<cftry>
		<cfset GetItemName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"select" = "description"
			}), "description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetItemName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetItemName>
<cfquery name="GetItemName" datasource="#application.datasource#">
	SELECT Description
	FROM BSA_Foodservice_Items_Master
	WHERE BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
</cfquery>
</cfif>
<cfoutput>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr onclick="NewWindow('/profiles/Products/Product_profile.cfm?PID=#BSA_Foodservice_Items_Master_ID#','name','400','450','Yes', 'No');return false;" NOWRAP style="cursor:pointer;">
	</tr>
	</cfoutput>

	<!---Only do the open layer if you're viewing it, not for email, etc.--->
	<cfif ShowDetails IS 0>
	<tr><td>
	
	<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image=""
			ImageOpen=""
			Title="<table width=100% bgcolor=#color3# cellpadding=0 cellspacing=0><tr><td>#ReplaceList(GetItemName.Description, "#chr(34)#,\", "&quot;,\")#</td> </tr></table>"   
			TitleClosed="<table width=100% cellpadding=0 cellspacing=0 bgcolor=#color3#><tr><td>#ReplaceList(GetItemName.Description, "#chr(34)#,\", "&quot;,\")#</td></tr></table>" 
			TitleTooltip="Click here to toggle the view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="100%"
			Color="">	
				
				<table class="Maintable" border="0" cellpadding="1" cellspacing="0" bgcolor="white" width="95%">

		<tr>
		<td>&nbsp; </td>
		<td style="border-bottom:solid #93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Invoice&nbsp;#:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Volume:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Rate:</td>
		<td align="right" style="border-bottom:solid #93BEE2 1px;">$&nbsp;Amount:</td></tr>
		
		<cfset ItemCredit = 0>
		<cfset counter = 0>	
		<cfset ItemTotalEarned = 0>
<cfloop query="GetInvoices">
<cfset counter = counter + 1>

	<!---Getting Contract Number--->
	<cfset useLakebaseForGetContractNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_program_info")>
<cfif useLakebaseForGetContractNumber>
	<cftry>
		<cfset GetContractNumber = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_program_info", {
				"contract_main_id" = "eq.#ContractID#",
				"select" = "contract_number"
			}), "contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractNumber = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractNumber>
<cfquery name="GetContractNumber" datasource="#application.datasource#">
	SELECT Contract_Number
	FROM BB_Program_Info
	WHERE Contract_Main_ID = #ContractID#
	</cfquery>
</cfif>
	
	<cfset Contract_Number = GetContractNumber.Contract_Number>
	
	<!---Get the rates on the date on the invoice--->
	<cfquery name="GetContractMain" datasource="#application.datasource#">
	SELECT Contract_Main_ID 
	FROM BB_Program_Info
	WHERE Contract_Number = '#Contract_Number#'
	AND Approval_Start_Date <= '#dateformat(Invoice_Date)#'
	AND Approval_End_Date >= '#dateformat(Invoice_Date)#'
	</cfquery>
	<cfset DatedContractMain = GetContractMain.Contract_Main_ID>
	
	<!---Calculate the rate * the volume in the--->
	<cfquery name="GetRate" datasource="#application.datasource#">
	SELECT Rate, Unit_of_Measure_ID
	FROM TC_Rebate_Product
	WHERE Contract_Main_ID = '#DatedContractMain#'
	AND Product_ID = '#BSA_Foodservice_Items_Master_ID#'
	</cfquery>
	
	<!---Sets rate to 0 if it is null--->
	<cfif len(trim(GetRate.Rate)) GT 0>
		<cfset Rate = GetRate.Rate>
	<cfelse>
		<cfset Rate = 0>
	</cfif>
	<cfset ThisCredit = 0>
	
	
	<!---Multiplies the rate by the appropriate unit of measure's volume in the invoice--->

	<cfif GetRate.Unit_Of_Measure_ID IS 1>
	<cfset ThisCredit = Rate * Cases_Invoiced>
	</cfif>
	
	<cfif GetRate.Unit_of_Measure_ID IS 2>
	<cfset ThisCredit = Rate * Pounds_Invoiced>
	</cfif>
	
	<cfset RebateCredit = RebateCredit + ThisCredit>
	
	<cfset ItemCredit = ItemCredit + ThisCredit>
	

<cfoutput>	
	<cfset ItemTotalEarned = ItemTotalEarned + ThisCredit>
	 <tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
	 <td style="border-bottom:solid ##93BEE2 1px;">&nbsp; #counter#.</td>
 	<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#DateFormat(Invoice_Date, 'MM/DD/YY')#</td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#Shared_Invoice_Number#</td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;"><cfif GetRate.Unit_of_Measure_ID IS 1>#NumberFormat(Cases_Invoiced, '___,___,___')# Cs<cfelse>#NumberFormat(Pounds_Invoiced, '___,___,___')# Lbs</cfif></td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#LSCurrencyFormat(Rate)#</td>
	<td valign="top" align="right" style="border-bottom:solid ##93BEE2 1px;"> #LSCurrencyFormat(ThisCredit)#</td>
	</tr>
	
</cfoutput>
<!---GetInvoices--->
</cfloop>		

<tr>
		<td>Item Total:</td>
		<td >&nbsp; </td>
		<td >&nbsp; </td>
		<td>&nbsp; </td>
		<td >&nbsp; </td>
		<td align="right"><cfoutput>#LSCurrencyFormat(ItemTotalEarned)#</cfoutput></td></tr>
</table>	
		</cf_openlayer>

	</td></tr>	 
	
	<!---Show details is true--->
	<cfelse>
	<tr><td>
	<cfoutput>
	<table width="100%" bgcolor="#color3#" cellpadding=0 cellspacing=0><tr><td>#GetItemName.Description#</td> </tr></table></cfoutput>
		<table class="Maintable" border="0" cellpadding="1" cellspacing="0" bgcolor="white" width="95%">
		<tr>
		<td style="border-bottom:solid #93BEE2 1px;">&nbsp; </td>
		<td style="border-bottom:solid #93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Invoice&nbsp;#:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Volume:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Rate:</td>
		<td align="right" style="border-bottom:solid #93BEE2 1px;">$&nbsp;Amount:</td>
	
		</tr>
		
	<cfset ItemCredit = 0>
	<cfset counter = 0>		
	<cfset ItemTotalEarned = 0>
<cfloop query="GetInvoices">
<cfset counter = counter + 1>

	<!---Getting Contract Number--->
	<cfquery name="GetContractNumber" datasource="#application.datasource#">
	SELECT Contract_Number
	FROM BB_Program_Info
	WHERE Contract_Main_ID = #ContractID#
	</cfquery>
	
	<cfset Contract_Number = GetContractNumber.Contract_Number>
	
	<!---Get the rates on the date on the invoice--->
	<cfquery name="GetContractMain" datasource="#application.datasource#">
	SELECT Contract_Main_ID 
	FROM BB_Program_Info
	WHERE Contract_Number = '#Contract_Number#'
	AND Approval_Start_Date <= '#dateformat(Invoice_Date)#'
	AND Approval_End_Date >= '#dateformat(Invoice_Date)#'
	</cfquery>
	<cfset DatedContractMain = GetContractMain.Contract_Main_ID>
	
	<!---Calculate the rate * the volume in the--->
	<cfquery name="GetRate" datasource="#application.datasource#">
	SELECT Rate, Unit_of_Measure_ID
	FROM TC_Rebate_Product
	WHERE Contract_Main_ID = '#DatedContractMain#'
	AND Product_ID = '#BSA_Foodservice_Items_Master_ID#'
	</cfquery>
	
	<cfif len(trim(GetRate.Rate)) GT 0>
		<cfset Rate = GetRate.Rate>
	<cfelse>
		<cfset Rate = 0>
	</cfif>
	
	<cfset ThisCredit = 0>
	
	<!---Multiplies the rate by the appropriate unit of measure's volume in the invoice--->
	<cfif GetRate.Unit_Of_Measure_ID IS 1>
	<cfset ThisCredit = Rate * Cases_Invoiced>
	</cfif>
	
	<cfif GetRate.Unit_of_Measure_ID IS 2>
	<cfset ThisCredit = Rate * Pounds_Invoiced>
	</cfif>
	
	<cfset RebateCredit = RebateCredit + ThisCredit>
	
	<cfset ItemCredit = ItemCredit + ThisCredit>
	
<cfoutput>	
	<cfset ItemTotalEarned = ItemTotalEarned + ThisCredit>
	 <tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
	 <td style="border-bottom:solid ##93BEE2 1px;">#counter#.</td>
 	<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#DateFormat(Invoice_Date, 'MM/DD/YY')#</td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#Shared_Invoice_Number#</td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;"><cfif UOM IS 1>#NumberFormat(Cases_Invoiced, '___,___,___')# Cs<cfelse>#NumberFormat(Pounds_Invoiced, '___,___,___')# Lbs</cfif></td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;">#LSCurrencyFormat(Rate)#</td>
	<td valign="top" align="right" style="border-bottom:solid ##93BEE2 1px;"> #LSCurrencyFormat(ThisCredit)#</td>
	</tr>
	
</cfoutput>

<!---GetInvoices--->
</cfloop>
<tr>
		<td>Item Total:</td>
		<td >&nbsp; </td>
		<td >&nbsp; </td>
		<td>&nbsp; </td>
		<td >&nbsp; </td>
		<td align="right"><cfoutput>#LSCurrencyFormat(ItemTotalEarned)#</cfoutput></td></tr>		
		</table>
	</td></tr>	
	
	</cfif>

</table>
<!---Get Invoices Recordcount GT 0--->
</cfif>

</cfloop>
<!---No items--->
<cfelse>
No rebate
</cfif>



 --->

<!---Rebate debit--->
</td><td valign="top" width="50%">
<cfset Billback_Type = 2>

<cfinclude template="billback_inc.cfm">

<cfset RebateDebit = Debit>
<cfset Debit = 0>

</table>

</td></tr>
</table>
