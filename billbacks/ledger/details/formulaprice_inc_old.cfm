

<table align="center" cellpadding="2" cellspacing="2" border="0" width="95%" class="Subtable">

<tr><td width="50%" valign="top">

<!---Rebate credit--->

<cfset FormulaPriceCredit = 0>

<!---Get all items in program--->
<cfquery name="GetItemNumbers" datasource="#application.datasource#">
SELECT DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID
FROM Program_Formula_Pricing_Rule_Products 
	INNER JOIN Contract_Products
	ON Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
WHERE Program_Formula_Pricing_Rule_Products.Program_ID  IN (#preservesinglequotes(ProgramNumber)#)
AND Contract_Products.Deleted = 0
AND Program_Formula_Pricing_Rule_Products.Deleted = 0
</cfquery>

<!---Doesn't go through processing if there are no items that match--->
<cfif GetItemNumbers.Recordcount GT 0>

<table border="0" CLASS="SubTable" cellspacing="0" cellpadding="1"  width="100%">

<tr>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" width="80%">Item: </td>
<td valign="top" style="border-bottom:solid #93BEE2 1px;" align="right">Item&nbsp;$:</td>
</tr>
<tr><td colspan="2"><em>* Program rates calculated nightly</em></td></tr>
</table>

<cfloop query="GetItemNumbers">

<cfquery name="GetInvoices" datasource="#application.datasource#">
SELECT Invoice_Detail.Pounds_Invoiced, Invoice_Detail.Cases_Invoiced, Invoice_Header.Invoice_Date, Invoice_Header.Invoice_Header_ID, Invoice_Detail.BSA_Foodservice_Items_Master_ID, Invoice_Detail.LB_Unit_Price, Invoice_Detail.CS_Unit_Price, Invoice_Header.Shared_Invoice_Number, Invoice_Header.Ship_Date
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
<!--- AND Invoice_Header.Order_Status = 'I' --->
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

<table border="0" cellspacing="0" cellpadding="1"  width="100%">
	
	<!---Only do the open layer if you're viewing it, not for email, etc.--->
	<cfif ShowDetails IS 0>
	<tr>
	<td>
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
				<table class="Subtable" border="0" cellpadding="1" cellspacing="0" bgcolor="white" width="95%">
		<tr>
		<Td style="border-bottom:solid #93BEE2 1px;">&nbsp; </TD>
		<td style="border-bottom:solid #93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Invoice&nbsp;#:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Volume:</td>
		<td align="right" style="border-bottom:solid #93BEE2 1px;">$&nbsp;Amount:</td>
		</tr>
		
	<cfset ItemCredit = 0>
	<cfset counter = 0>	
	<cfset ItemTotalEarned = 0>
	<cfset ItemTotalVolume = 0>
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
	FROM TC_Formula_Product
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
		<cfset RateDifference = CS_Unit_Price - Rate>
		<cfset ThisCredit = (RateDifference * Cases_Invoiced)>
	<cfelseif GetRate.Unit_of_Measure_ID IS 2>
		<cfset RateDifference = LB_Unit_Price - Rate>
		<cfset ThisCredit = (RateDifference * Pounds_Invoiced)>
	<cfelse>
		<cfset RateDifference = 0>
		<cfset ThisCredit = 0>
	</cfif>
	
	<cfset ItemCredit = ThisCredit>
	<cfif GetRate.Unit_Of_Measure_ID IS 1>
		<cfset ItemTotalVolume = ItemTotalVolume + Cases_Invoiced>
	<cfelse>
		<cfset ItemTotalVolume = ItemTotalVolume + Pounds_Invoiced>
	</cfif>
<cfoutput>	
	<cfset ItemTotalEarned = ItemTotalEarned + ThisCredit>
	 <tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
	 <td>#counter#.</td>
 	<td valign="top" >#DateFormat(Invoice_Date, 'MM/DD/YY')#</td>
	<td valign="top"> #Shared_Invoice_Number#</td>
	<td valign="top" ><cfif GetRate.Unit_Of_Measure_ID IS 1>#NumberFormat(Cases_Invoiced, '___,___,___')# Cs<cfelse>#NumberFormat(Pounds_Invoiced, '___,___,___')# Lbs</cfif></td>
	<td valign="top" align="right" > #LSCurrencyFormat(ThisCredit)#</td>
	</tr>
	
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;" >&nbsp; </td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Invoice: <cfif GetRate.Unit_Of_Measure_ID IS 1>#LSCurrencyFormat(CS_Unit_Price)#<cfelse>#LSCurrencyFormat(LB_Unit_Price)#</cfif></td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Program: #LSCurrencyFormat(Rate)#</td>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;">&##916; 
<cfif left(RateDifference, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif>
#LSCurrencyFormat(RateDifference)#
</font>
</td><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
</tr>
	
		<cfset FormulaPriceCredit = FormulaPriceCredit + ThisCredit>
</cfoutput>
<!---GetInvoices--->
</cfloop>	
<tr>
		<td>Item Total:</td>
		<td >&nbsp; </td>
		<td >&nbsp; </td>
		<td >&nbsp; <cfoutput>#ItemTotalVolume#</cfoutput>
		<cfif GetRate.Unit_Of_Measure_ID IS 1> 
			CS
		<cfelse> 
			LBS
		</cfif></td>
		<td align="right"><cfoutput>#LSCurrencyFormat(ItemTotalEarned)#</cfoutput></td></tr>	
	</table>	
		</cf_openlayer>

	</td></tr>	 
	
	<!---Show details is true--->
	<cfelse>
		<tr><td>
		<cfoutput>
		<table width="100%" bgcolor="#color3#" cellpadding=0 cellspacing=0><tr><td>#GetItemName.Description#</td> </tr></table></cfoutput>
	<table class="Subtable" border="0" cellspacing="0" cellpadding="1"  bgcolor="white" width="95%">
		<tr>
		<td style="border-bottom:solid #93BEE2 1px;">Date:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Invoice&nbsp;#:</td>
		<td style="border-bottom:solid #93BEE2 1px;">Volume:</td>
		<td align="right" style="border-bottom:solid #93BEE2 1px;">$&nbsp;Amount:</td>
		</tr>
		
		<cfset ItemCredit = 0>
		<cfset ItemTotalEarned = 0>
		<cfset ItemTotalVolume = 0>
<cfloop query="GetInvoices">

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
	FROM TC_Formula_Product
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
		<cfset RateDifference = CS_Unit_Price - Rate>
		<cfset ThisCredit = (RateDifference * Cases_Invoiced)>
	<cfelse>
		<cfset RateDifference = LB_Unit_Price - Rate>
		<cfset ThisCredit = (RateDifference * Pounds_Invoiced)>
	</cfif>
	
	<cfset ItemCredit = ThisCredit>
	
<cfoutput>	
	<cfset ItemTotalEarned = ItemTotalEarned + ThisCredit>
	<cfif GetRate.Unit_Of_Measure_ID IS 1>
		<cfset ItemTotalVolume = ItemTotalVolume + Cases_Invoiced>
	<cfelse>
		<cfset ItemTotalVolume = ItemTotalVolume + Pounds_Invoiced>
	</cfif>
	 <tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
 	<td valign="top" >#DateFormat(Invoice_Date, 'MM/DD/YY')#</td>
	<td valign="top"> #Shared_Invoice_Number#</td>
	<td valign="top" ><cfif UOM IS 1>#NumberFormat(Cases_Invoiced, '___,___,___')# Cs<cfelse>#NumberFormat(Pounds_Invoiced, '___,___,___')# Lbs</cfif></td>
	<td valign="top" align="right" > #LSCurrencyFormat(ThisCredit)#</td>
	</tr>
	
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="#color4#"</CFIF>>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > 
		Invoice: <cfif UOM IS 1>#LSCurrencyFormat(CS_Unit_Price)#
		<cfelse>#LSCurrencyFormat(LB_Unit_Price)#</cfif></td>
	<td valign="top" style="border-bottom:solid ##93BEE2 1px;" > Program: #LSCurrencyFormat(Rate)#</td>
<td valign="top" style="border-bottom:solid ##93BEE2 1px;">&##916; 
<cfif left(RateDifference, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif>
#LSCurrencyFormat(RateDifference)#
</font>
</td><td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
	</tr> 
	
	
		<cfset FormulaPriceCredit = FormulaPriceCredit + ThisCredit>
</cfoutput>
<!---GetInvoices--->
</cfloop>		

<tr>
		<td>Item Total:</td>
		<td >&nbsp; </td>
		<td >
		&nbsp; 
		<cfoutput>#ItemTotalVolume#</cfoutput>
		<cfif GetRate.Unit_Of_Measure_ID IS 1> 
			CS
		<cfelse> 
			LBS
		</cfif>
		</td>

		<td align="right"><cfoutput>#LSCurrencyFormat(ItemTotalEarned)#</cfoutput></td></tr>	
</table>	
	</td></tr>	 
	
	
	</cfif>
	
	<!--- <tr><td align="right" style="border-bottom:solid #93BEE2 1px; "><cfoutput>
	<div class="bold">#LSCurrencyFormat(ItemCredit)#</div></cfoutput></td></tr> --->
</table>
<!---Get Invoices Recordcount GT 0--->
</cfif>

</cfloop>
<!---No items--->
<cfelse>
	No formula price
</cfif>

</td>
<!---Fixed Price debit--->
</td><td valign="top" width="50%">
<cfset Billback_Type = 5>

<cfinclude template="billback_inc.cfm">

<cfset FormulaPriceDebit = Debit>
<cfset Debit = 0>

</table>
</td></tr></table>
