<table align="center" cellpadding="3" cellspacing="3" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">
<cfoutput>#DistributorNumber#</cfoutput>
<!---Rebate credit--->

<cfset FixedPriceCredit = 0>
<cfset ComponentEarned = 0>
<cfset ItemEarned = 0>
<cfset ItemVolumeLB = 0>
<cfset ItemVolumeCS = 0>
<cfset InvoicesFound = 0>

<cfloop query="GetContractMain">
	<cfset RevisionStart = GetContractMain.Approval_Start_Date>
	<cfset RevisionEnd =  GetContractMain.Approval_End_Date>
	<cfset RevisionID =  GetContractMain.Contract_Main_ID>
	
	<cfsilent>
	<!---Master query --->
	<cfquery name="FixedMaster" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Items_Master.Description AS ItemName, Program_Fixed_Component_Name.Program_Fixed_Component_Name, Accrual_Log.Program_Component_ID, Invoice_Header.Shared_Invoice_Number, Invoice_Detail.CS_Unit_Price, Invoice_Detail.LB_Unit_Price, Accrual_Log.Cases_Invoiced, Accrual_Log.Pounds_Invoiced, Accrual_Log.Sales_Dollars, Accrual_Log.Discount_Offered, Accrual_Log.Discount_UOM, Accrual_Log.Amount_Earned, Accrual_Log.Invoice_Date
	FROM Accrual_Log
		INNER JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Accrual_Log.Product_ID
		LEFT JOIN Program_Fixed_Component
		ON Program_Fixed_Component.Program_Fixed_Component_ID = Accrual_Log.Program_Component_ID
			LEFT JOIN Program_Fixed_Component_Name
			ON Program_Fixed_Component.Program_Fixed_Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
		INNER JOIN Invoice_Detail
		ON Invoice_Detail.Invoice_Detail_ID = Accrual_Log.Invoice_Detail_ID
		INNER JOIN Invoice_Header
		ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
	WHERE Accrual_Log.Deleted = 0
	AND Accrual_Log.Discount_Type_ID = 1 
	AND Accrual_Log.Invoice_Date >= '#RevisionStart#'
	AND Accrual_Log.Invoice_Date <= '#RevisionEnd#'
	AND Accrual_Log.Program_ID = #RevisionID#
	AND Accrual_Log.Distributor_ID_Earned = '#DistributorNumber#'
	GROUP BY BSA_Foodservice_Items_Master.Description, Program_Fixed_Component_Name.Program_Fixed_Component_Name, Accrual_Log.Program_Component_ID, Invoice_Header.Shared_Invoice_Number, Invoice_Detail.CS_Unit_Price, Invoice_Detail.LB_Unit_Price, Accrual_Log.Cases_Invoiced, Accrual_Log.Pounds_Invoiced, Accrual_Log.Sales_Dollars, Accrual_Log.Discount_Offered, Accrual_Log.Discount_UOM, Accrual_Log.Amount_Earned, Accrual_Log.Invoice_Date
	</cfquery>
	
	</cfsilent>
	
	<table width="99%" cellpadding="0" cellspacing="0" border="0">
	<cfoutput><div align="center"><strong>#DateFormat(RevisionStart, 'MMMM D, YYYY')# - #DateFormat(RevisionEnd, 'MMMM D, YYYY')#</strong></div> </cfoutput><br>
	</table>
	
	<cfoutput query="FixedMaster" group="ItemName">

	 <!--- <cfdump var="#GetItemNumbers#"> --->
	
	<cfset ItemEarned = 0>
	<cfset ItemVolumeLB = 0>
	<cfset ItemVolumeCS = 0>
	<cfset InvoicesFound = 1>
	
	<table width="99%" bgcolor="white" border="0">
	<tr><td  bgcolor="#color1#"><strong>#ItemName#</strong></td></tr>
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
			
			<cfquery name="GetAllComponents" dbtype="query">
			SELECT DISTINCT Program_Fixed_Component_Name, Program_Component_ID, Discount_Offered, Discount_UOM 
			FROM FixedMaster
			WHERE ItemName = '#trim(FixedMaster.ItemName)#'
			</cfquery>
	
			<!---Loop through components--->
			<cfloop query="GetAllComponents">
							
			 <div align="Center">
			
				<table width="95%" border="0" cellspacing="0" cellpadding="0" class="maintable" align="center">
				<tr>
					<td colspan="100%"  bgcolor="#color3#">#GetAllComponents.Program_Fixed_Component_Name#</td></tr>				
				<tr>
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
		<td style="border-bottom:solid ##93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid ##93BEE2 1px;">Invoice&nbsp;##:</td>
		<td style="border-bottom:solid ##93BEE2 1px;">Volume:</td>
		<td align="right" style="border-bottom:solid ##93BEE2 1px;">$&nbsp;Amount:</td>
		</tr>
		
				<cfquery name="InvoicesForItems" dbtype="query">
				SELECT Shared_Invoice_Number, Cases_Invoiced, Pounds_Invoiced, Discount_UOM, Invoice_Date, Discount_Offered, Amount_Earned, LB_Unit_Price, CS_Unit_Price
				FROM FixedMaster
				WHERE ItemName = '#trim(FixedMaster.ItemName)#'
				AND Program_Component_ID = '#trim(GetAllComponents.Program_Component_ID)#'
				</cfquery>
				
				  <cfset counter = 0>		
				  
				
				<cfloop query="InvoicesForItems">
				<cfset counter = counter + 1>
				
				<!---Multiplies the rate by the appropriate unit of measure's volume in the invoice--->
				<cfif InvoicesForItems.Discount_UOM IS 1>
					<cfset RateDifference = InvoicesForItems.CS_Unit_Price - InvoicesForItems.Discount_Offered>
					
				<cfelseif InvoicesForItems.Discount_UOM IS 2>
					<cfset RateDifference = InvoicesForItems.LB_Unit_Price - InvoicesForItems.Discount_Offered>
					
				<cfelse>
					<cfset RateDifference = 0>
					
				</cfif>
				
					<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF>>
					 <td>#counter#.</td>
				 	<td valign="top" >#DateFormat(InvoicesForItems.Invoice_Date, 'MM/DD/YYYY')#</td>
					<td valign="top"> #InvoicesForItems.Shared_Invoice_Number#</td>
					<td valign="top" ><cfif GetAllComponents.Discount_UOM IS 1>#NumberFormat(InvoicesForItems.Cases_Invoiced, '___,___,___')# CS<cfelse>#NumberFormat(InvoicesForItems.Pounds_Invoiced, '___,___,___')# LBS</cfif></td>
					<td valign="top" align="right" > #LSCurrencyFormat(InvoicesForItems.Amount_Earned)#</td>
					</tr>
					
					 <tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#Color4#"</CFIF>>
					<td style="border-bottom:solid ##93BEE2 1px;" >&nbsp; </td>
					<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Invoice: <cfif InvoicesForItems.Discount_UOM IS 1>#LSCurrencyFormat(InvoicesForItems.CS_Unit_Price)#<cfelse>#LSCurrencyFormat(InvoicesForItems.LB_Unit_Price)#</cfif></td>
					<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Program: #LSCurrencyFormat(InvoicesForItems.Discount_Offered)#</td>
				<td valign="top" style="border-bottom:solid ##93BEE2 1px;">&##916; 
				<cfif left(RateDifference, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif>
				#LSCurrencyFormat(RateDifference)#
				</font>
				</td><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
					</tr> 
		
					<cfset ItemComponentCS = ItemComponentCS + InvoicesforItems.Cases_Invoiced>
					<cfset ItemComponentLB = ItemComponentLB + InvoicesForItems.Pounds_Invoiced>
					<!--- 						
						<cfset WeightedLB = WeightedLB + (InvoicesforItems.Pounds_Invoiced * InvoicesforItems.LB_Unit_Price)> 
						<cfset WeightedCS = WeightedCS + (InvoicesforItems.Cases_Invoiced * InvoicesforItems.CS_Unit_Price)> --->
					
				<cfset FixedPriceCredit = FixedPriceCredit + Amount_Earned> 
				
				</cfloop>
			
				
				<tr>
		<td>Component Total:</td>
		<td >&nbsp; </td>
		<td >&nbsp; </td>
		<td >
	
		<cfif GetAllComponents.Discount_UOM IS 1> 
			#ItemComponentCS# CS
		<cfelse> 
			#ItemComponentLB# LBS
		</cfif>
	
		</td>
		<td> &nbsp; </td>
		
			
			</table>
			</div>

				
				<cfset ItemVolumeLB = ItemVolumeLB + round(ItemComponentLB)>
				<cfset ItemVolumeCS = ItemVolumeCS + round(ItemComponentCS)>
				<cfset ItemEarned = ItemEarned + ComponentEarned>
		
	
		<!---Components loop--->
			</cfloop> 
	
			<!---Sum total dollars and volume for component--->
		<!---Sum total dollars and volume for all components -- don't double count volume!!!!--->
			</CF_openLayer> 

		
		
	<!---Item number loop--->
	</cfoutput>	
	
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
