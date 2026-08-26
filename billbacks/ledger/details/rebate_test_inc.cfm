<table align="center" cellpadding="3" cellspacing="3" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">

<!---Rebate credit--->

<cfsilent>
<cfset RebateCredit = 0>
<cfset ComponentEarned = 0>
<cfset ItemEarned = 0>
<cfset ItemVolumeLB = 0>
<cfset ItemVolumeCS = 0>
<cfset InvoicesFound = 0>


	<cfquery name="CreateRebateTable" datasource="#application.datasource#">
		CREATE TABLE ##RebateMaster
	(	
		ItemName nvarchar(255), 
		Program_Rebates_Component_Name nvarchar(255), 
		Program_Component_ID nvarchar(100), 
		Shared_Invoice_Number nvarchar(255), 
		Cases_Invoiced float, 
		Pounds_Invoiced float, 
		Sales_Dollars float, 
		Discount_Offered float, 
		Discount_UOM int, 
		Amount_Earned float, 
		Invoice_Date datetime
	)
	</cfquery>

</cfsilent>

<cfloop query="GetContractMain">
	<cfset RevisionStart = GetContractMain.Approval_Start_Date>
	<cfset RevisionEnd =  GetContractMain.Approval_End_Date>
	<cfset RevisionID =  GetContractMain.Contract_Main_ID>
	
	<cfsilent>
	
	<cfquery name="InsertIntoTemp" datasource="#application.datasource#">
	INSERT INTO ##RebateMaster
	(
		ItemName, 
		Program_Rebates_Component_Name, 
		Program_Component_ID , 
		Shared_Invoice_Number, 
		Cases_Invoiced, 
		Pounds_Invoiced, 
		Sales_Dollars, 
		Discount_Offered, 
		Discount_UOM, 
		Amount_Earned, 
		Invoice_Date 
	)
	(
	SELECT BSA_Foodservice_Items_Master.Description AS ItemName, Program_Rebates_Component_Name.Program_Rebates_Component_Name, Accrual_Log.Program_Component_ID, Invoice_Header.Shared_Invoice_Number, Accrual_Log.Cases_Invoiced, Accrual_Log.Pounds_Invoiced, Accrual_Log.Sales_Dollars, Accrual_Log.Discount_Offered, Accrual_Log.Discount_UOM, Accrual_Log.Amount_Earned, Accrual_Log.Invoice_Date 
	FROM Accrual_Log
		INNER JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Accrual_Log.Product_ID
		INNER JOIN Program_Rebates_Component
		ON Program_Rebates_Component.Program_Rebates_Component_ID = Accrual_Log.Program_Component_ID
			INNER JOIN Program_Rebates_Component_Name
			ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
		INNER JOIN Invoice_Header
		ON Accrual_Log.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
	WHERE Accrual_Log.Deleted = 0
	AND Accrual_Log.Discount_Type_ID = 2 
	AND Accrual_Log.Invoice_Date >= '#RevisionStart#'
	AND Accrual_Log.Invoice_Date <= '#RevisionEnd#'
	AND Accrual_Log.Program_ID = #RevisionID#
	AND Accrual_Log.Distributor_ID_Earned = '#DistributorNumber#'
	GROUP BY BSA_Foodservice_Items_Master.Description, Program_Rebates_Component_Name.Program_Rebates_Component_Name, Accrual_Log.Program_Component_ID, Invoice_Header.Shared_Invoice_Number, Accrual_Log.Cases_Invoiced, Accrual_Log.Pounds_Invoiced, Accrual_Log.Sales_Dollars, Accrual_Log.Discount_Offered, Accrual_Log.Discount_UOM, Accrual_Log.Amount_Earned, Accrual_Log.Invoice_Date 
	)
	</cfquery>
	
	
	</cfsilent>

	
	<!--- <cfdump var="#RebateComponentMaster#"> --->


	<table width="99%" cellpadding="0" cellspacing="0" border="0">
	<cfoutput><div align="center"><strong>#DateFormat(RevisionStart, 'MMMM D, YYYY')# - #DateFormat(RevisionEnd, 'MMMM D, YYYY')#</strong></div> </cfoutput><br>
	</table>
	
	<cfset ItemEarned = 0>
	<cfset ItemVolumeLB = 0>
	<cfset ItemVolumeCS = 0>
	
	<cfoutput query="RebateComponentMaster" group="ItemName">

	
	<!--- <table width="99%" bgcolor="<cfoutput>#color1#</cfoutput>"> --->
	<table width="99%" bgcolor="white" border="0">
	<tr><td  bgcolor="#color1#"><strong>#ItemName#<br></strong></td></tr>
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
			
			
			<cfquery name="GetAllComponents" datasource="#application.datasource#">
			SELECT DISTINCT Program_Rebates_Component_Name, Program_Component_ID, ItemName
			FROM ##RebateMaster
			WHERE ItemName = '#trim(ItemName)#'
			</cfquery>
						
			
			<!---Loop through components--->
			<cfloop query="GetAllComponents">
				
			<div align="Center">
			
				<table width="95%" border="0" cellspacing="0" cellpadding="0" class="maintable" align="center">
				<tr>
					<td colspan="100%"  bgcolor="#color3#">#GetAllComponents.Program_Rebates_Component_Name#</td></tr>
				<tr>
					<Td><strong>Invoice ##:</strong></TD>
					<td align="Right"><strong>Pounds:</strong></TD>
					<Td align="right"><strong>Cases:</strong></td>
					
					<td align="right"><strong>Price Paid:</strong></td>
					<td align="right"><strong>Date:</strong></td>
				</tr>
				
				<!---Get Invoices for items --->
				
				<cfquery name="GetInvoices" datasource="#application.datasource#">
				SELECT Shared_Invoice_Number, Cases_Invoiced, Pounds_Invoiced, Discount_UOM, Invoice_Date, Discount_Offered
				FROM ##RebateMaster
				WHERE ItemName = '#trim(ItemName)#'
				AND Program_Component_ID = '#GetAllComponents.Program_Component_ID#'
				</cfquery>
								
				<cfloop query="GetInvoices">
				
					<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
						<Td valign="top">#GetInvoices.Shared_Invoice_Number#</TD>
						<td valign="top" align="Right">#NumberFormat(GetInvoices.Pounds_Invoiced, '___,___,___.__')#</TD>
						<Td valign="top" align="right">#NumberFormat(GetInvoices.Cases_Invoiced, '___,___,___.__')#</td>
						
						<td valign="top" align="right">
						<cfif GetInvoices.Discount_UOM IS 1>
							#LSCurrencyFormat(GetInvoices.Discount_Offered)#/CS
						<cfelseif GetInvoices.Discount_UOM IS 2>
							#LSCurrencyFormat(GetInvoices.Discount_Offered)#/LB
						<cfelseif GetInvoices.Discount_UOM IS 3>
							#LSCurrencyFormat(GetInvoices.Discount_Offered)#/LB<Br>
							#LSCurrencyFormat(GetInvoices.Discount_Offered)#/CS
						</cfif></td>
						<td align="right">#Dateformat(Invoice_Date, 'MM/DD/YYYY')#</td>
					</tr>							
				
				<!---Items for component--->
				
				</cfloop> 
				
				<cfquery name="SumsForComp" datasource="#application.datasource#">
				SELECT Sum(Pounds_Invoiced) ItemComponentLB, sum(Cases_Invoiced) AS ItemComponentCS, sum(Sales_Dollars) AS Sales_Dollars, sum(Amount_Earned) AS ComponentEarned, Discount_Offered, Discount_UOM
				FROM ##RebateMaster
				WHERE ItemName = '#trim(ItemName)#'
				AND Program_Component_ID = '#GetAllComponents.Program_Component_ID#'
				GROUP BY Discount_Offered, Discount_UOM
				</cfquery>
				
				<tr>
					<td height="20"><strong>Component Total:</strong></td>
					<td align="right">Total LB:</td>
					<td align="right">Total CS:</td>
					<td align="right">#Application.RebateLabel#:</td>
					<td align="right" colspan="2">Total Earned:</td>
				</tr>
				<tr>
					
					<td height="20"><strong>&nbsp; </strong></td>
					<td align="right">#NumberFormat(SumsForComp.ItemComponentLB, '___,___,___')#</td>
					<td align="right">#NumberFormat(SumsForComp.ItemComponentCS, '___,___,___')#</td>
					<td align="right">
						<cfif SumsForComp.Discount_UOM IS 1>
							#NumberFormat(SumsForComp.Discount_Offered, '___,___,___.______')#/CS
						<cfelseif SumsForComp.Discount_UOM IS 2>
							#NumberFormat(SumsForComp.Discount_Offered, '___,___,___.______')#/LB
						<cfelseif SumsForComp.Discount_UOM IS 3>
							<br>#Round(SumsForComp.Discount_Offered)#% * #lscurrencyformat(SumsForComp.Sales_Dollars)#
						</cfif>
					</td>
					<td align="right" colspan="2">
							#LSCurrencyFormat(SumsForComp.ComponentEarned)#
												
						<cfset RebateCredit = RebateCredit + SumsForComp.ComponentEarned>
					</td>
				
				</tr>
		
			</table>
			</div>
				
				<cfset ItemVolumeLB = ItemVolumeLB + round(SumsForComp.ItemComponentLB)>
				<cfset ItemVolumeCS = ItemVolumeCS + round(SumsForComp.ItemComponentCS)>
				<cfset ItemEarned = ItemEarned + SumsForComp.ComponentEarned> 
				
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

</td>


<!---Rebate debit--->
</td><td valign="top" width="50%">
<cfset Billback_Type = 2>

<cfinclude template="billback_inc.cfm">

<cfset RebateDebit = Debit>
<cfset Debit = 0>

</table>

</td></tr>
</table>

<cfsilent>
	<cfquery name="TruncateRebateMasterTable" datasource="#application.datasource#">
	Truncate Table ##RebateMaster
	</cfquery>
</cfsilent>

<!---Per contract main --->
</cfloop>

<cfsilent>
	<cfquery name="DropRebateMasterTable" datasource="#application.datasource#">
	Drop Table ##RebateMaster
	</cfquery>
</cfsilent>

