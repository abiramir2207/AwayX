<table align="center" cellpadding="3" cellspacing="3" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">

<!---Rebate credit--->

<cfset FixedPriceCredit = 0>
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
		FROM 		Program_Fixed_Price_Product_Data 
					INNER JOIN Contract_Products
					ON Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					INNER JOIN BSA_Foodservice_Items_Master 
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
		WHERE 
						Contract_Products.Contract_Main_ID = #RevisionID#
				AND 	Contract_Products.Deleted = 0
				AND 	Program_Fixed_Price_Product_Data.Deleted = 0
				AND 	Program_Fixed_Price_Product_Data.Fixed_Price_Value IS NOT null
	</cfquery>
	
	<!------ Find if any products is 'All products' ----->
	<cfquery name="qCheckGroupProducts" dbtype="query">
		SELECT		BSA_Foodservice_Items_Master_ID, Product_Group_ID, Contract_Products_ID
		FROM		GetItemNumbers
		WHERE
					Product_Group_Level_ID = 1
	</cfquery>		
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
		SELECT Program_Fixed_Component_Name.Program_Fixed_Component_Name, Contract_Products.BSA_Foodservice_Items_Master_ID,  Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID, Program_Fixed_Price_Product_Data.Fixed_Price_Value, Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID, Program_Fixed_Price_Product_Data.Volume, TC_Fixed_Price_Product.Rate
		FROM Program_Fixed_Component_Name
			INNER JOIN Program_Fixed_Component
			ON Program_Fixed_Component.Program_Fixed_Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
			INNER JOIN Program_Fixed_Price_Product_Data 
			ON Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = Program_Fixed_Component.Program_Fixed_Component_ID
			INNER JOIN Contract_Products
			ON Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
			LEFT JOIN TC_Fixed_Price_Product
			ON TC_Fixed_Price_Product.Contract_Main_ID = '#RevisionID#'
				AND TC_Fixed_Price_Product.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				AND TC_Fixed_Price_Product.Unit_Of_Measure_ID IS NOT NULL
		WHERE Program_Fixed_Component.Program_ID = #RevisionID#
		AND Program_Fixed_Price_Product_Data.Program_ID = #RevisionID#
		AND Program_Fixed_Price_Product_Data.Contract_Products_ID = '#GetItemNumbers.Contract_Products_ID#'
		AND Program_Fixed_Component.Deleted = 0
		AND Program_Fixed_Component_Name.Deleted = 0
		AND Program_Fixed_Price_Product_Data.Deleted = 0
		<!---Only components paid to Distributors--->
		AND Program_Fixed_Component.Fixed_Component_Paid_To = 1
		</cfquery>
		 <!--- <cfdump var="#GetAllComponents#"> --->
	
	
		<!---Get all invoices for each item--->
		<cfquery name="InvoicesforFixedComponents" datasource="#application.datasource#">
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
				
		<!---  <cfdump var="#InvoicesForRebateComponents#">  --->
	
	<cfif InvoicesforFixedComponents.Recordcount GT 0>
	
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
				<cfquery name="InvoicesforItems" dbtype="query">
				SELECT * FROM InvoicesForFixedComponents
				WHERE BSA_Foodservice_Items_Master_ID = '#InvoicesforFixedComponents.BSA_Foodservice_Items_Master_ID#'
				</cfquery>
							<!--- <cfdump var="#InvoicesforItems#"> --->
				<cfif InvoicesForItems.Recordcount GT 0>
				
			<div align="Center">
			
				<table width="95%" border="0" cellspacing="0" cellpadding="0" class="maintable" align="center">
				<tr>
					<td colspan="100%"  bgcolor="<cfoutput>#color3#</cfoutput>"><cfoutput>#GetAllComponents.Program_Fixed_Component_Name#</cfoutput></td></tr>				
				<tr>
		<td style="border-bottom:solid #93BEE2 1px;">&nbsp; </td>
		<td style="border-bottom:solid #93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Invoice&nbsp;#:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Volume:</td>
		<td align="right" style="border-bottom:solid #93BEE2 1px;">$&nbsp;Amount:</td>
		</tr>
			<cfset counter = 0>		
				<cfloop query="InvoicesForItems">
				<cfset counter = counter + 1>
				
				<!---Sets rate to 0 if it is null--->
				<cfif len(trim(GetAllComponents.Rate)) GT 0>
					<cfset Rate = GetAllComponents.Rate>
				<cfelse>
					<cfset Rate = 0>
				</cfif>
		
				<cfset ThisCredit = 0>
	
				<!---Multiplies the rate by the appropriate unit of measure's volume in the invoice--->
				<cfif GetAllComponents.Unit_Of_Measure_ID IS 1>
					<cfset RateDifference = CS_Unit_Price - Rate>
					<cfset ThisCredit = (RateDifference * Cases_Invoiced)>
				<cfelseif GetAllComponents.Unit_of_Measure_ID IS 2>
					<cfset RateDifference = LB_Unit_Price - Rate>
					<cfset ThisCredit = (RateDifference * Pounds_Invoiced)>
				<cfelse>
					<cfset RateDifference = 0>
					<cfset ThisCredit = 0>
				</cfif>
				
				<cfset ItemCredit = ThisCredit>
				
				<cfoutput>
					<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF>>
					 <td>#counter#.</td>
				 	<td valign="top" >#DateFormat(Invoice_Date, 'MM/DD/YYYY')#</td>
					<td valign="top"> #Shared_Invoice_Number#</td>
					<td valign="top" ><cfif GetAllComponents.Unit_Of_Measure_ID IS 1>#NumberFormat(Cases_Invoiced, '___,___,___')# CS<cfelse>#NumberFormat(Pounds_Invoiced, '___,___,___')# LBS</cfif></td>
					<td valign="top" align="right" > #LSCurrencyFormat(ThisCredit)#</td>
					</tr>
					
					<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF>>
					<td style="border-bottom:solid ##93BEE2 1px;" >&nbsp; </td>
					<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Invoice: <cfif GetAllComponents.Unit_Of_Measure_ID IS 1>#LSCurrencyFormat(CS_Unit_Price)#<cfelse>#LSCurrencyFormat(LB_Unit_Price)#</cfif></td>
					<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Program: #LSCurrencyFormat(Rate)#</td>
				<td valign="top" style="border-bottom:solid ##93BEE2 1px;">&##916; 
				<cfif left(RateDifference, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif>
				#LSCurrencyFormat(RateDifference)#
				</font>
				</td><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
					</tr> 
		
					<cfset ItemComponentCS = ItemComponentCS + InvoicesforItems.Cases_Invoiced>
					<cfset ItemComponentLB = ItemComponentLB + InvoicesForItems.Pounds_Invoiced>
											
						<cfset WeightedLB = WeightedLB + (InvoicesforItems.Pounds_Invoiced * InvoicesforItems.LB_Unit_Price)> 
						<cfset WeightedCS = WeightedCS + (InvoicesforItems.Cases_Invoiced * InvoicesforItems.CS_Unit_Price)>
					
				<cfset FixedPriceCredit = FixedPriceCredit + ThisCredit>
				<!---Items for component--->
				</cfoutput>
				</cfloop>
			
				
				<tr>
		<td>Component Total:</td>
		<td >&nbsp; </td>
		<td >&nbsp; </td>
		<td >
		<cfoutput>
		<cfif GetAllComponents.Unit_Of_Measure_ID IS 1> 
			#ItemComponentCS# CS
		<cfelse> 
			#ItemComponentLB# LBS
		</cfif>
		</cfoutput>
		</td>
		
			
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

<!---Fixed price debit--->
</td><td valign="top" width="50%">
<cfset Billback_Type = 1>

<cfinclude template="billback_inc.cfm">

<cfset FixedPriceDebit = Debit>
<cfset Debit = 0>

</table>

</td></tr>
</table>
