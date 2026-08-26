

<table align="center" cellpadding="2" cellspacing="2" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">

<!--- Formula credit--->

<cfset FormulaPriceCredit = 0>
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
	<cfquery name="FormulaMaster" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Items_Master.Description AS ItemName, Invoice_Header.Shared_Invoice_Number, Invoice_Detail.CS_Unit_Price, Invoice_Detail.LB_Unit_Price, Accrual_Log.Cases_Invoiced, Accrual_Log.Pounds_Invoiced, Accrual_Log.Sales_Dollars, Accrual_Log.Discount_Offered, Accrual_Log.Discount_UOM, Accrual_Log.Amount_Earned, Accrual_Log.Invoice_Date
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
	AND Accrual_Log.Discount_Type_ID = 5 
	AND Accrual_Log.Invoice_Date >= '#RevisionStart#'
	AND Accrual_Log.Invoice_Date <= '#RevisionEnd#'
	AND Accrual_Log.Program_ID = #RevisionID#
	AND Accrual_Log.Distributor_ID_Earned = '#DistributorNumber#'
	GROUP BY BSA_Foodservice_Items_Master.Description, Invoice_Header.Shared_Invoice_Number, Invoice_Detail.CS_Unit_Price, Invoice_Detail.LB_Unit_Price, Accrual_Log.Cases_Invoiced, Accrual_Log.Pounds_Invoiced, Accrual_Log.Sales_Dollars, Accrual_Log.Discount_Offered, Accrual_Log.Discount_UOM, Accrual_Log.Amount_Earned, Accrual_Log.Invoice_Date
	</cfquery>
	
	</cfsilent>


	
<table width="99%" cellpadding="0" cellspacing="0" border="0">
	<cfoutput><div align="center"><strong>#DateFormat(RevisionStart, 'MMMM D, YYYY')# - #DateFormat(RevisionEnd, 'MMMM D, YYYY')#</strong></div> </cfoutput><br>
	</table>
	
	<cfoutput query="FormulaMaster" group="ItemName">

<table border="0" CLASS="SubTable" cellspacing="0" cellpadding="1"  width="100%">

<tr>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;" width="80%">Item: </td>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;" align="right">Item&nbsp;$:</td>
</tr>
<tr><td colspan="2"><em>* Program rates calculated nightly</em></td></tr>
</table>

<table border="0" cellspacing="0" cellpadding="1"  width="100%">
	
	<!---Only do the open layer if you're viewing it, not for email, etc.--->
	<cfif ShowDetails IS 0>
		<cfset ShowDetailParam = "Yes">
	<cfelse>
		<cfset ShowDetailParam = "No">
	</cfif>
	<tr>
	<td>
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image=""
			ImageOpen=""
			Title="<table width=100% bgcolor=#color3# cellpadding=0 cellspacing=0><tr><td>#ReplaceList(FormulaMaster.ItemName, "#chr(34)#,\", "&quot;,\")#</td> </tr></table>"   
			TitleClosed="<table width=100% cellpadding=0 cellspacing=0 bgcolor=#color3#><tr><td>#ReplaceList(FormulaMaster.ItemName, "#chr(34)#,\", "&quot;,\")#</td></tr></table>" 
			TitleTooltip="Click here to toggle the view"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="100%"
			Color=""
			AddScript="#ShowDetailParam#">	
				<table class="Subtable" border="0" cellpadding="1" cellspacing="0" bgcolor="white" width="95%">
		<tr>
		<Td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </TD>
		<td style="border-bottom:solid ##93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid ##93BEE2 1px;">Invoice&nbsp;##:</td>
		<td style="border-bottom:solid ##93BEE2 1px;">Volume:</td>
		<td align="right" style="border-bottom:solid ##93BEE2 1px;">$&nbsp;Amount:</td>
		</tr>
		
	<cfset ItemCredit = 0>
	<cfset counter = 0>	
	<cfset ItemTotalEarned = 0>
	<cfset ItemTotalVolume = 0>
	
	<cfquery name="GetInvoices" dbtype="query">
	SELECT Shared_Invoice_Number, Cases_Invoiced, Pounds_Invoiced, Discount_UOM, Invoice_Date, Discount_Offered, Amount_Earned, LB_Unit_Price, CS_Unit_Price
	FROM FixedMaster
	WHERE ItemName = '#trim(FormulaMaster.ItemName)#'
	
	</cfquery>
	
	<cfloop query="GetInvoices">
	
	<!---Multiplies the rate by the appropriate unit of measure's volume in the invoice--->
	<cfif GetInvoices.Discount_UOM IS 1>
		<cfset RateDifference = GetInvoices.CS_Unit_Price - GetInvoices.Discount_Offered>
		<cfset ThisCredit = (RateDifference * GetInvoices.Cases_Invoiced)>
	<cfelseif GetInvoices.Discount_UOM IS 2>
		<cfset RateDifference = GetInvoices.LB_Unit_Price - GetInvoices.Discount_Offered>
		<cfset ThisCredit = (RateDifference * GetInvoices.Pounds_Invoiced)>
	<cfelse>
		<cfset RateDifference = 0>
		<cfset ThisCredit = 0>
	</cfif>
	
	<cfset ItemCredit = ThisCredit>
	<cfif GetInvoices.Discount_UOM IS 1>
		<cfset ItemTotalVolume = ItemTotalVolume + Cases_Invoiced>
	<cfelse>
		<cfset ItemTotalVolume = ItemTotalVolume + Pounds_Invoiced>
	</cfif> 
	
		 <tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
		 <td>#counter#.</td>
	 	<td valign="top" >#DateFormat(GetInvoices.Invoice_Date, 'MM/DD/YY')#</td>
		<td valign="top"> #GetInvoices.Shared_Invoice_Number#</td>
		<td valign="top" ><cfif GetInvoices.Discount_UOM IS 1>#NumberFormat(GetInvoices.Cases_Invoiced, '___,___,___')# Cs<cfelse>#NumberFormat(GetInvoices.Pounds_Invoiced, '___,___,___')# Lbs</cfif></td>
		<td valign="top" align="right" > #LSCurrencyFormat(GetInvoices.Amount_Earned)#</td>
		</tr>
		
		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
		<td valign="top" style="border-bottom:solid ##93BEE2 1px;" >&nbsp; </td>
		<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Invoice: <cfif GetInvoices.Discount_UOM IS 1>#LSCurrencyFormat(GetInvoices.CS_Unit_Price)#<cfelse>#LSCurrencyFormat(GetInvoices.LB_Unit_Price)#</cfif></td>
		<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Program: #LSCurrencyFormat(GetInvoices.Discount_Offered)#</td>
		<td valign="top" style="border-bottom:solid ##93BEE2 1px;">&##916; 
		<cfif left(RateDifference, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif>
		#LSCurrencyFormat(RateDifference)#
		</font>
		</td><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
		</tr>
		
		<cfset FormulaPriceCredit = FormulaPriceCredit + ThisCredit>
	
	</cfloop>

<!--- <tr>
		<td>Item Total:</td>
		<td >&nbsp; </td>
		<td >&nbsp; </td>
		<td >&nbsp; <cfoutput>#ItemTotalVolume#</cfoutput>
		<cfif GetRate.Unit_Of_Measure_ID IS 1> 
			CS
		<cfelse> 
			LBS
		</cfif></td>
		<td align="right">#LSCurrencyFormat(ItemTotalEarned)#</td></tr>	--->
	</table>	
		</cf_openlayer>

	</td></tr>	  
	
	
</table>
<!---Item loop --->
</cfoutput>


<!---Program number loop--->
</cfloop>

</td>
<!---Fixed Price debit--->
</td><td valign="top" width="50%">
<cfset Billback_Type = 5>

<cfinclude template="billback_inc.cfm">

<cfset FormulaPriceDebit = Debit>
<cfset Debit = 0>

</table>
</td></tr></table>
