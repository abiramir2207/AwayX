
<cfset pagebreak = "<div style='page-break-after: always; '> </div>">
<cfoutput>
<cfset useLakebaseForGetDistinctTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_type")>
<cfif useLakebaseForGetDistinctTypes>
	<cftry>
		<cfset GetDistinctTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_type", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistinctTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistinctTypes>
<cfquery name="GetDistinctTypes" datasource="#application.datasource#">
SELECT DISTINCT * FROM RP_Type
WHERE Deleted = 0
</cfquery>
</cfif>

<cfloop query="GetDistinctTypes">
	<CFFILE 
				ACTION = "Write" 
				FILE   = "#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#\#GetDistinctTypes.One_Word_Desc#_summary_#Filepath#.html" 
				OUTPUT = " " 
				ADDNEWLINE = "Yes"
				nameconflict = "overwrite"
	> 
</cfloop>

<cfquery name="GetDistributorSummary" datasource="#application.datasource#">
SELECT RP_Distributor_Summary.*, BSA_Foodservice_Customers.Name AS Distributor_Name,  BSA_Foodservice_Customers.Address_1, BSA_Foodservice_Customers.Address_2, BSA_Foodservice_Customers.City, BSA_Foodservice_Customers.ZipCode, BSA_Foodservice_Customers.State, RP_Type.One_Word_Desc, RP_Type.Type_Desc
FROM RP_Distributor_Summary
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = RP_Distributor_Summary.Distributor_ID
	INNER JOIN RP_Type
	ON RP_Type.RP_Type_ID = RP_Distributor_Summary.Type
WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'  
</cfquery>

<!---  <cfdump var="#GetDistributorSummary#">  --->

<!---Start viewable content--->
 <cfloop query="GetDistributorSummary"> 

<cfsavecontent variable="Report">
<style>
TABLE.Maintable TD 
{
	border-bottom:solid ##93BEE2 1px; 
	font-family : Arial;
	font-size : 10px;
}
##header 
{
	font-size: 12px;
	font-family : Arial;
}
Table.Maintable TD.tableheaders
{
	font-size:12px;
	font-weight:bold;
	font-family : Arial;
	border-bottom:none; 
}
</style>

<table border="0" class="maintable" cellpadding="2" cellspacing="0" width="800">

<!---Company name--->

<tr>
	<td colspan="100%" class="tableheaders"><font face="Arial" size="5" color="##330099">#application.returned_customer_setting.Company_Name# </font><br><strong>Fernandos</strong></td>

</tr>
<tr>
	<cfset DistributorName = GetDistributorSummary.Distributor_Name>
	<cfset Shared_Ship_To = GetDistributorSummary.Shared_Ship_To>
	<cfset Address_1 = GetDistributorSummary.Address_1>
	<cfset Address_2 = GetDistributorSummary.Address_2>
	<cfset City = GetDistributorSummary.City>
	<cfset State = GetDistributorSummary.State>
	<cfset ZipCode = GetDistributorSummary.ZipCode>
	
	<td colspan="3" nowrap class="header">
		#Shared_Ship_To#<br>
		#trim(DistributorName)#<br>
		#trim(Address_1)#<br>
		<cfif len(trim(Address_2)) GT 0>#trim(Address_2)#<Br></cfif>
		#City#,&nbsp;#State#&nbsp;&nbsp;&nbsp;#ZipCode#
	</td>
	<td colspan="1">&nbsp; </td>
	<td valign="top" colspan="4" align="Right"class="header">Trade Allowances for #dateformat(Fiscal_Period_Start_Date, 'MM/DD/YYYY')# to #dateformat(Fiscal_Period_End_Date, 'MM/DD/YYYY')#</td>
</tr>

<!---Distributor Summary--->
<tr><th colspan="100%" style="border-bottom: solid navy 1px">#GetDistributorSummary.Type_Desc# Summary</th>
	<cfset useLakebaseForDistributorSummary = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_distributor_summary")>
<cfif useLakebaseForDistributorSummary>
	<cftry>
		<cfset DistributorSummary = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_distributor_summary", {
				"distributor_id" = "eq.#Distributor_ID#",
				"fiscal_period_start_date" = "eq.#Fiscal_Period_Start_Date#",
				"fiscal_period_end_date" = "eq.#Fiscal_Period_End_Date#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDistributorSummary = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDistributorSummary>
<cfquery name="DistributorSummary" datasource="#application.datasource#">
	SELECT DISTINCT * FROM RP_Distributor_Summary 
	WHERE Distributor_ID = '#Distributor_ID#'
	AND Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
	AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
	</cfquery>
</cfif>
	
	<tr>
		
		<Th>&nbsp; </TD>
		<Th>&nbsp; </TD>
		<Th>&nbsp; </TD>
		<Th>&nbsp; </TD>
		<Th align="right"><strong>Gross Eligible Sales </strong></TD>
	<!--- 	<Td align="right"><strong>Total Discount % </strong></TD> --->
		<Th align="right"><strong>Gross Trade Earned </strong></TD>
		<Th align="right"><strong>Total Billed Back </strong></TD>
		<Th align="right"><strong>Total Payment</strong></TD>
	</tr> 
	
	<cfloop query="DistributorSummary">
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>

		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td align="right">#lscurrencyformat(DistributorSummary.Gross_Sales)#</TD>
		<!--- <Td align="right">#lscurrencyformat(Total_Allowance)#%</TD> --->
		<Td align="right">#lscurrencyformat(Total_Dist_Earned)# </TD>
		<Td align="right">#lscurrencyformat(Total_Dist_Billed_Back)#</TD>
		<Td align="right">#lscurrencyformat(Payment_Amount)#</TD>
	</tr> 
	</cfloop>
	
	<!---Spacer--->
	<tr><td colspan="100%">&nbsp; </td></tr>
	
<!---Billback Summary--->
<cfset BillbackTotal = 0>
<tr><th colspan="100%" style="border-bottom: solid navy 1px">Billback Summary</th>
	<cfset useLakebaseForGetBillbackSummary = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_billback_summary")>
<cfif useLakebaseForGetBillbackSummary>
	<cftry>
		<cfset GetBillbackSummary = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_billback_summary", {
				"distributor_id" = "eq.#Distributor_ID#",
				"fiscal_period_start_date" = "eq.#Fiscal_Period_Start_Date#",
				"fiscal_period_end_date" = "eq.#Fiscal_Period_End_Date#",
				"bb_summary_type" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackSummary = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackSummary>
<cfquery name="GetBillbackSummary" datasource="#application.datasource#">
	SELECT * FROM RP_Billback_Summary 
	WHERE Distributor_ID = '#Distributor_ID#'
	AND Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
	AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#' 
	AND BB_Summary_Type = 1 
	</cfquery>
</cfif>

	<tr>
		
		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td align="right">&nbsp; </TD>
		<Td align="right">&nbsp; </TD>
		<Td align="right">&nbsp; </TD>
		<Td align="right"><strong>Item Number</strong></TD>
		<Td align="right"><strong>Total Billed Back</strong></TD>
	</tr> 
	
	<cfloop query="GetBillbackSummary">
	<cfset BillbackTotal = BillbackTotal + Total_Billed_Back>
	<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		
		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td>&nbsp; </TD>
		<Td align="right">&nbsp; </TD>
		<Td align="right">&nbsp; </TD>
		<Td align="right">&nbsp; </TD>
		<Td align="right">#Item_Number#</TD>
		<Td align="right">#lscurrencyformat(Total_Billed_Back)#</TD>
	</tr> 
	</cfloop>
	
	<!---Totals--->
	<tr>
		<Td colspan="6">&nbsp; </TD>
		<Td align="right"><strong>Billback total:</strong></TD>
		<Td align="right">#lscurrencyformat(BillbackTotal)#</TD>
	</tr> 

	<!---Spacer--->
	<tr><td colspan="100%">&nbsp; </td></tr>
	
<!---Invoice Summary--->
<cfset TotalInvoice = 0>
<cfset GrossSales = 0>
<tr><th colspan="100%"  style="border-bottom: solid navy 1px"><strong>Invoice Summary</strong></th>
	<cfset useLakebaseForGetInvoiceSummaries = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("rp_invoice_summary")>
<cfif useLakebaseForGetInvoiceSummaries>
	<cftry>
		<cfset GetInvoiceSummaries = application.oLakebase.toQuery(
			application.oLakebase.selectRows("rp_invoice_summary", {
				"fiscal_period_start_date" = "eq.#Fiscal_Period_Start_Date#",
				"fiscal_period_end_date" = "eq.#Fiscal_Period_End_Date#",
				"distributor_id" = "eq.#Distributor_ID#",
				"order" = "invoice_date.desc",
				"select" = "invoice_number,invoice_date,purchase_order,dist_sales,total_dist_dollars"
			}), "invoice_number,invoice_date,purchase_order,dist_sales,total_dist_dollars"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetInvoiceSummaries = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetInvoiceSummaries>
<cfquery name="GetInvoiceSummaries" datasource="#application.datasource#">
	SELECT DISTINCT Invoice_Number, Invoice_Date, Purchase_Order, Dist_Sales, Total_Dist_Dollars 
	FROM RP_Invoice_Summary
	WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
	AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
	AND Distributor_ID = '#Distributor_ID#'
	ORDER BY Invoice_Date DESC
	</cfquery>
</cfif>
	<tr>
		
		<th colspan="2"><strong>#application.returned_customer_setting.distributor_label_singular# Name</strong></td>
		<th><strong>#application.returned_customer_setting.shard_ship_to_label#</strong></td>
		<th><strong>Invoice Number</strong></td>
		<th><strong>Invoice Date</strong></td>
		<th><strong>Customer PO</strong></td>
		<th align="right"><strong>Gross Eligible Sales</strong></td>
		<th align="right"><strong>Trade Dollars</strong></td>
	</tr>
	
	<cfloop query="GetInvoiceSummaries">
		<cfset TotalInvoice = TotalInvoice + Total_Dist_Dollars>
		<cfset GrossSales = GrossSales + Dist_Sales>
		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
			
			<Td colspan="2">#DistributorName# </TD>
			<Td>#Shared_Ship_To# </TD>
			<Td>#Invoice_Number# </TD>
			<Td>#Dateformat(Invoice_Date, 'MM/DD/YYYY')# </TD>
			<td>#Purchase_Order# </TD>
			<Td align="right">#lscurrencyformat(Dist_Sales)# <!--- - #GrossSales# ---></TD>
			<Td align="right">#lscurrencyformat(Total_Dist_Dollars)# </TD>
		</tr>
	</cfloop>
	
	<!---Totals--->
	<tr>
		<Td colspan="4">&nbsp; </TD>
		<td><strong>Gross Eligible Sales:</strong></td>
		<td>#lscurrencyformat(GrossSales)#</td>
		<Td align="right"><strong>Invoice total:</strong></TD>
		<Td align="right">#lscurrencyformat(TotalInvoice)#</TD>
	</tr> 
</table>		
</cfsavecontent>

<!---Second page--->


<cfsavecontent variable="Details">
<style>
TABLE.Maintable TD 
{
	border-bottom:solid ##93BEE2 1px; 
	font-family : Arial;
	font-size : 10px;
}
##header 
{
	font-size: 12px;
	font-family : Arial;
}
Table.Maintable TD.tableheaders
{
	font-size:12px;
	font-weight:bold;
	font-family : Arial;
	border-bottom:none; 
}
</style>
<table border="0" class="maintable" cellpadding="2" cellspacing="0"  width="800">	
	<tr>
	<td colspan="100%" class="tableheaders"><font face="Arial" size="5" color="##330099">#application.returned_customer_setting.Company_Name# </font><br><strong>Fernandos</strong></td>
</tr>
<tr>
	
	<td colspan="4" nowrap  style="tableheaders">
		#Shared_Ship_To#<br>
		#trim(Distributor_Name)#<br>
		#trim(Address_1)#<br>
		<cfif len(trim(Address_2)) GT 0>#trim(Address_2)#<Br></cfif>
		#City#,&nbsp;#State#&nbsp;&nbsp;&nbsp;#ZipCode#
	</td>
	<td colspan="1">&nbsp; </td>
	<td valign="top" colspan="3" align="Right"  style="tableheaders">Trade Allowances for #dateformat(Fiscal_Period_Start_Date, 'MM/DD/YYYY')# to #dateformat(Fiscal_Period_End_Date, 'MM/DD/YYYY')#</td>
</tr>
	
	<!---Invoice Detail--->
<tr><th colspan="100%" style="border-bottom: solid navy 1px"><strong>Invoice Detail</strong></th>
	<cfquery name="GetInvoiceDetail" datasource="#application.datasource#">
	SELECT DISTINCT RP_Invoice_Detail.*, BSA_Foodservice_Items_Master.Description
	FROM RP_Invoice_Detail
		INNER JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.Item = 
		RP_Invoice_Detail.Item_Number
	WHERE Fiscal_Period_Start_Date = '#Fiscal_Period_Start_Date#'
	AND Fiscal_Period_End_Date = '#Fiscal_Period_End_Date#'
	AND Distributor_ID = '#Distributor_ID#'
	AND D_Trade_Rate > 0
	ORDER BY Invoice_Number
	</cfquery>
		
	<tr>
		
		<th><strong>#application.returned_customer_setting.distributor_label_singular# Name</strong></td>
		<th><strong>#application.returned_customer_setting.shard_ship_to_label#</strong></td>
		<th><strong>Invoice Number</strong></td>
		<th><strong>Invoice Date</strong></td>
		<th><strong>Product</strong></td>
		<th align="center"><strong>Trade Rate</strong></td>
		<th align="right"><strong>Gross Sales</strong></td>
		<th align="right"><strong>Trade Dollars</strong></td>
	</tr>
	
	<!--- <cfset Invoice_Detail_Trade = 0>
	<cfset Invoice_Detail_Dist_Dollars = 0>
	<cfset Invoice_Detail_Sum_Dollars = 0> --->
	
	<cfloop query="GetInvoiceDetail">
	<!--- 	<cfset Invoice_Detail_Trade = Invoice_Detail_Trade + D_Item_Earned>
		<cfset Invoice_Detail_Dist_Dollars = Invoice_Detail_Dist_Dollars + D_Item_Earned>
		<cfset Invoice_Detail_Sum_Dollars = Invoice_Detail_Sum_Dollars + GetInvoiceDetail.Gross_Sales> --->
		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
			
			<Td>#DistributorName# </TD>
			<Td>#Shared_Ship_To# </TD>
			<Td>#Invoice_Number# </TD>
			<Td>#Dateformat(Invoice_Date, 'MM/DD/YYYY')# </TD>
			<Td>#Description# (#Item_Number#) </TD>
			<Td align="center">#D_Trade_Rate#% </TD>
			<Td align="right">#lscurrencyformat(GetInvoiceDetail.Gross_Sales)# <!--- - #Invoice_Detail_Sum_Dollars# ---></TD>
			<Td align="right">#lscurrencyformat(D_Item_Earned)# <!---  - #Invoice_Detail_Trade# ---></TD>
		</tr>
		
		
	</cfloop>
	
	<!---Totals--->
	<tr>
		<Td colspan="4">&nbsp; </TD>
		<td><strong>Gross Eligible Sales:</strong></td>
		<td>#lscurrencyformat(DistributorSummary.Gross_Sales)#</td>
		<Td align="right"><strong>Detail total:</strong></TD>
		<Td align="right">#lscurrencyformat(TotalInvoice)#</TD>
	</tr> 
		
	<!---Spacer--->
	<tr><td colspan="100%">&nbsp; </td></tr>
	
	
	</cfsavecontent>

	<CFFILE 
			ACTION = "Write" 
			FILE   = "#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#\#GetDistributorSummary.One_Word_Desc#_#shared_ship_To#_#Filepath#.html" 
			OUTPUT = "#Report#" 
			ADDNEWLINE = "Yes"
			nameconflict = "overwrite"
		> 
		<CFFILE 
			ACTION = "Write" 
			FILE   = "#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#\#GetDistributorSummary.One_Word_Desc#_#shared_ship_To#_#Filepath#_details.html" 
			OUTPUT = "#Details#" 
			ADDNEWLINE = "Yes"
			nameconflict = "overwrite"
		> 
		
		<cffile action = "append"
  file = "#Application.Doc_Path#\data_files\created\ReportWriter\Fiscal_Period_Reports\report\#FilePath#\#GetDistributorSummary.One_Word_Desc#_summary_#Filepath#.html"
  output = "#Report# #pagebreak#"
	> 


</table>
</cfloop>
</cfoutput>

Report has compiled. Return to <a href="/reportwriter/fiscal_period_reports/index.cfm">report main page</a> to view results.