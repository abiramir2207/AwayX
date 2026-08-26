<!--- 
/billbacks/BB_Auto_Report/create_pdf_report.cfm
Created By: Brenda Flynn
Created On: May 8, 2009

Expected Parameters:
	*Report_ID (BB_Auto_Report.BB_Auto_Report_ID)
	*Contract_Main_ID
	
Purpose:
This generates a formatted PDF report containing the backup for our auto pay calculations. 
This is intended to be printed out when needed and included with the check for the automatic payment.

Document Outline:
1) Set variables and parameters
2) Execute appropriate queries and database calls
3) Establish document location and name
4) Custom stylesheet for the PDF
5) Document information
	-Cfdocument tag
	-Document header
	-Summary information
	-Detailed information
	-Document footer
	
This document should pass back information on where the PDF has been stored.
--->

<!--- 1) Set variables and parameters --->
<cfparam name="Report_ID"				default="">
<cfparam name="Contract_Main_ID"		default="">
<cfparam name="BB_Auto_Program_Pay_Period_ID" default="0">
<cfparam name="PDFLocation"		 		default="">
<cfparam name="PDFPath"		 			default="">
<cfparam name="PDFFileName" 			default="">
<cfparam name="qAutoPayExtractHeader"	default="">
<cfparam name="qAutoPayExtractDetail"	default="">
<cfparam name="qgetProgramsDetails"		default="">
<cfparam name="qCustomersonReport"		default="">
<cfparam name="qReportByCustomer"		default="">
<cfparam name="qInvoiceLevelInfo"		default="">
<cfparam name="TotalRows" 				default="5"><!--- how many rows across is the table? --->
<!--- Totals --->
<cfparam name="SumGrossSales"			default=0>
<cfparam name="SumCases"				default=0>
<cfparam name="SumPounds"				default=0>
<cfparam name="SumTotalPayment"			default=0>
<cfparam name="SumOfInvoiceEarnings" 	default=0>
<cfparam name="SumInitialEarned"		default=0>
<cfparam name="SumAdjustments"			default=0>
<cfparam name="SumClawbacks"			default=0>
<cfparam name="SumPullbacks"			default=0>

<cfparam name="ShowPounds"				default=1>
<cfparam name="ShowCases"				default=1>
<cfif NOT structKeyExists(application,"oBBReportGet")>
	<cfset application.oBBReportAjaxCaller = CreateObject("component","components.Billback.BBAutoReportAjaxCaller").init() />
	<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
	<cfset application.oBBReportUpdate = CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
	<cfset application.oBBReportPeriod = CreateObject("component","components.Billback.BB_Auto_Report_Period") />
	<cfset application.oBBReportPeriodGateway = CreateObject("component","components.Billback.BB_Auto_Report_PeriodGateway") />
</cfif>

<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />

<!--- Sets variables based on appsetting --->
<cfif application.appSettingsget.getViewProgramVolumeUOM() IS 1>
	<!--- only show cases --->
	<cfset ShowPounds = 0>
</cfif>
<cfif application.appSettingsget.getViewProgramVolumeUOM() IS 2>
	<!--- only show cases --->
	<cfset ShowCases = 0>
</cfif>
<!--- If getViewProgramVolumeUOM is 3 then the defaults are appropriate --->


<!--- 2) Execute appropriate queries and database calls --->
<cfset qAutoPayExtractHeader =  application.oBBReportGet.getAutoPayExtractHeader(Report_ID,Contract_Main_ID,BB_Auto_Program_Pay_Period_ID)>
<!--- <cfset qAutoPayExtractDetail =  application.oBBReportGet.getAutoPayExtractDetail(Report_ID,Contract_Main_ID)> --->
<!--- <cfset qProgramsonReport 	 =  application.oBBReportGet.getProgramsonReport(Report_ID)> --->
<cfset qCustomersonReport 	 =  application.oBBReportGet.getCustomersonReport(Report_ID,Contract_Main_ID,BB_Auto_Program_Pay_Period_ID)>
<!---<cfdump var="#qCustomersonReport#" output="c:\dump.log" >--->
<cfset TotalRows = 1> <!--- Add a row per program --->

<!--- 3) Establish document location and name --->

<cfset PDFFileName		= "AutoPay_#Report_ID#_#BB_Auto_Program_Pay_Period_ID#.pdf">
<cfset PDFLocation = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\"  & PDFFileName>
<cfset PDFPath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/AutoPayReport/"  & PDFFileName>

<!--- Check to see if it exists before we go through all this again --->
<cfif NOT FileExists(PDFLocation)>

<cfset variables.labelsObject = createObject("component", "components.settings.labels.labels").init() />
<cfset variables.orderNumberLabel = variables.labelsObject.GetGeneralLabels(labelDescription = "Order Number") />

<!---5) Document goes here --->

<CFDOCUMENT FORMAT="PDF"
	FILENAME="#PDFLocation#"	
	OVERWRITE="Yes"
	ORIENTATION="landscape"
	>

<!--- 4) Custom stylesheet for the PDF (must be within cfdocument tags) --->
<style type="text/css">
.larger
{
	font-size: 11px;
	font-family: arial;
}


.normal
{
	font-size: 12px;
	font-family: arial;
	padding-top:5px;
	/*border-bottom: 1px dashed;*/
}

.normalheader
{
	font-size: 12px;
	font-family: arial;
	font-weight: bold;
	background-color: #cccccc;
	padding-top:4px;
}

.normalStrong
{
	font-size: 11px;
	font-family: arial;
	font-weight: bold;
	text-align: right;
	border-bottom: 2px solid;
}

.normalStrongLeft
{
	font-size: 11px;
	font-family: arial;
	font-weight: bold;
	text-align: left;
	border-bottom: 2px solid;
}
.SummaryHeader
{
	font-size: 13px;
	font-family: arial;
	font-weight: bold;
	text-align: right;
	background-color: #cccccc;
	margin-bottom:10px;
}
.space{
	padding-top:5px;
	padding-bottom:5px;
}
.subTotal
{
	font-size: 13px;
	font-family: arial;
	font-weight: bold;
	text-align: right;
	/*border-bottom: 2px solid;*/
	background-color: #cccccc;
}

.regular
{
	font-size: 10px;
	font-family: arial;
}

.reallySmall
{
	font-size: 8px;
	font-family: arial;
	padding-top:5px;
}

.tiny
{
	font-size: 10px;
	font-family: arial;
	font-weight:bold;
	background-color: #cccccc;
	padding-top:4px;
}


.strong
{
	font-weight: bold;
	font-size: 10px;
	font-family: arial;
}

.box
{
	border-top: 1px solid;
	border-bottom: 1px solid;
	border-right: 1px solid;
	border-left: 1px solid;
	font-size: 10px;
	font-family: arial;
}

.BigAndStrong
{
	font-weight: bold;
	font-size: 12px;
	font-family: arial;
}
</style>

<!--- HEADER --->
<cfdocumentitem type="header">
	
<style type="text/css">
.header
{
	font-size: 10px;
	font-family: arial;
}
</style>

<cfoutput>
	<table border="0" cellpadding="2" cellspacing="0" width="100%">
	<tr>
		<td class="header">#application.returned_customer_setting.Company_Name# Incentive Report</td>
		<td width="400" class="header" align="right">
			#qAutoPayExtractHeader.Contract_Number# -- #qAutoPayExtractHeader.Contract_Title# <br>
			For activity between #dateformat(qAutoPayExtractHeader.Start_Date, 'mm/dd/yyyy')# and #dateformat(qAutoPayExtractHeader.End_Date, 'mm/dd/yyyy')#
		</td>
	</tr>
	</table>
</cfoutput>

</cfdocumentitem> 

<cfset InvoiceSubTotalColSpan = 3 />
<cfif application.appSettingsget.get_Setting('Display_Item_No') eq "1">
    <cfset InvoiceSubTotalColSpan = InvoiceSubTotalColSpan + 1 />
</cfif>
<cfif application.returned_customer_setting.UPC_Switch>
    <cfset InvoiceSubTotalColSpan = InvoiceSubTotalColSpan + 1 />
</cfif>
<cfoutput>

	<!---Summary data --->
	<table width="100%" border="0" cellpadding="0" cellspacing="0" valign="top">
				<tr >
					<td class="SummaryHeader" style="text-align:left;">Billback</td>
					<td  class="SummaryHeader">	Gross Invoice</td>
					<cfif ShowCases IS 1>
					<td class="SummaryHeader">Cases</td>
					</cfif>
					<cfif ShowPounds IS 1>
					<td class="SummaryHeader">Pounds</td>
					</cfif>
					<td class="SummaryHeader">#qAutoPayExtractHeader.Contract_Number#<!---<br>#qAutoPayExtractHeader.Contract_Title#--->	</td>
					<td class="SummaryHeader">Adjustments</td>
					<cfif application.appSettingsGet.getPullbacksOn()>
					<td class="SummaryHeader">#application.appSettingsGet.getPullbackLabel()#</td>
					</cfif>
					<td class="SummaryHeader">Total	</td>
				</tr>

	<cfloop query="qAutoPayExtractHeader">
	
	<cfset qGetAdjustments		 = 	application.oBBReportGet.getSumDistAppliedAdjustments(qAutoPayExtractHeader.Billback_ID,qAutoPayExtractHeader.Payee_ID)>
	<cfset qGetTotalEarned		 = 	application.oBBReportGet.getTotalEarned(qAutoPayExtractHeader.Billback_ID)>
	<cfset qGetProgramsDistributorDetails = application.oBBReportGet.getProgramsDistributorDetails(qAutoPayExtractHeader.Billback_ID,qAutoPayExtractHeader.Shr_Ship_To)>
	<cfset qGetTotalEarned 		= application.oBBReportGet.getTotalEarned(qAutoPayExtractHeader.Billback_ID)>

	
	<!--- Increments totals --->
	<cfset SumGrossSales 	= SumGrossSales + numberformat(qGetProgramsDistributorDetails.Total_Sales_Dollars, '.__')>
	<cfset SumCases 		= SumCases + numberformat(qGetProgramsDistributorDetails.Total_Cases, '.')>
	<cfset SumPounds 		= SumPounds + numberformat(qGetProgramsDistributorDetails.Total_Pounds, '.')>
	
	<cfset SumAdjustments 	= SumAdjustments + numberformat(qGetAdjustments.Sum_Adjustment_Amount, '.__')>	
	
	<cfif len(trim(qGetAdjustments.Sum_Adjustment_Amount)) GT 0>	
		<cfset TotalEarned = qGetProgramsDistributorDetails.Initial_Earned - qGetAdjustments.Sum_Adjustment_Amount>
		<cfset InitialEarned 	= qGetProgramsDistributorDetails.Initial_Earned>
	<cfelseif qGetProgramsDistributorDetails.Initial_Earned NEQ 0>
		<cfset TotalEarned 	= qGetProgramsDistributorDetails.Initial_Earned>
		<cfset InitialEarned 	= qGetProgramsDistributorDetails.Initial_Earned>
	<cfelse>
		<cfset TotalEarned 	= qGetProgramsDistributorDetails.Initial_Earned>
		<cfset InitialEarned 	= qGetProgramsDistributorDetails.Initial_Earned>
	<!---	<cfset TotalEarned 	= qGetTotalEarned.Total_Earned>
		<cfset InitialEarned 	= qGetTotalEarned.Total_Earned>--->
	</cfif>
	
	<cfif application.appSettingsGet.getPullbacksOn()>
		<cfset DistPullback = 0 />
		<cfset qgetExportPullbackDistSum = application.oBBReportGet.getExportPullbackDistSum(Report_ID,qAutoPayExtractHeader.Billback_ID,0,qAutoPayExtractHeader.Payee_ID) />
		<cfif isNumeric(qgetExportPullbackDistSum.Sum_Pullback_Amount)>
			<cfset DistPullback = qgetExportPullbackDistSum.Sum_Pullback_Amount />
		</cfif>
		<cfset SumPullbacks 	= SumPullbacks + numberformat(DistPullback, '.__')>
		<cfset TotalEarned = TotalEarned - DistPullback />
	</cfif>
		
	<cfset SumInitialEarned	= SumInitialEarned + numberformat(InitialEarned, '.__')>
	<cfset SumTotalPayment 	= SumTotalPayment + TotalEarned>
	<tr <cfif #qAutoPayExtractHeader.currentRow#MOD 2 EQ 0>style="background-color:##C3FDB8;"</cfif>>
		<td class="normal"style="padding-top:8px;">#Shr_Ship_To_Name# (#Display_Distributor_ID#) (#BB_Code#)</td>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">#lscurrencyformat(qGetProgramsDistributorDetails.Total_Sales_Dollars)#</td>
		<cfif ShowCases IS 1>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">#numberformat(qGetProgramsDistributorDetails.Total_Cases, '___,___,___,___')#</td>
		</cfif>
		<cfif ShowPounds IS 1>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">#numberformat(qGetProgramsDistributorDetails.Total_Pounds, '___,___,___,___')#</td>
		</cfif>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">#lscurrencyformat(InitialEarned)#</td>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">-#lscurrencyformat(qGetAdjustments.Sum_Adjustment_Amount)#</td>
		<cfif application.appSettingsGet.getPullbacksOn()>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">-#lscurrencyformat(DistPullback)#</td>
		</cfif>
		<td align="right" class="normal" style="padding-top:5px;padding-bottom:2px;">#lscurrencyformat(TotalEarned)#</td>
	</tr>
	</cfloop>


	<!--- Totals --->
	<tr>
		<td class="subtotal">Totals:</td>
		<td align="right" class="subtotal">#lscurrencyformat(SumGrossSales)#</td>
		<cfif ShowCases IS 1>
		<td align="right" class="subtotal">#numberformat(SumCases, '___,___,___,___')#</td>
		</cfif>
		<cfif ShowPounds IS 1>
		<td align="right" class="subtotal">#numberformat(SumPounds, '___,___,___,___')#</td>
		</cfif>
		<td align="right" class="subtotal">#lscurrencyformat(SumInitialEarned)#</td>
		<td align="right" class="subtotal">-#lscurrencyformat(SumAdjustments)#</td>
		<cfif application.appSettingsGet.getPullbacksOn()>
		<td align="right" class="subtotal">-#lscurrencyformat(SumPullbacks)#</td>
		</cfif>
		<td align="right" class="subtotal">#lscurrencyformat(SumTotalPayment)#</td>
	</tr>
	
	</table>

</cfoutput>
	<!--- end summary --->
	
	
	<!--- Page break --->
	<cfdocumentitem type = "pagebreak"/>
	<!--- Page break --->
	
	<!--- Detail data --->
	
	<!--- Loop through each customer --->
	<cfoutput>
		<cfloop query="qCustomersonReport">
		
	<!---	<cfset qDetailGetAdjustments		 	= 	application.oBBReportGet.getAdjustments(qCustomersonReport.Billback_ID)> --->
		<cfset qGetDistAmountEarned  			=  application.oBBReportGet.getDistAmountEarned(Report_ID,Shr_Ship_To,Contract_Main_ID,BSA_Foodservice_Customers_ID,BB_Auto_Program_Pay_Period_ID)>
		<cfset qSumDistAppliedAdjustments 	 	=  application.oBBReportGet.getSumDistAppliedAdjustments(qCustomersonReport.Billback_ID,qCustomersonReport.BSA_Foodservice_Customers_ID)>
				
		<!--- Payee table --->
		<table border="0" width="100%" class="box">
		
			<!--- Numbers --->
			<tr>
				<!--- Customer number --->
				<td align="right" class="regular">#application.returned_customer_setting.distributor_label_singular# ##:</td>
				<td  class="regular">#Ship_To#</td>
				<!--- Broker number --->
				<td align="right"  class="regular">#application.returned_customer_setting.broker_label_singular# ##:</td>
				<td class="regular">#Broker_Shard#</td>
			</tr>
			
			<!--- Names --->
			<tr>
				<!--- Customer name --->
				<td align="right" class="regular">#application.returned_customer_setting.distributor_label_singular# Name:</td>
				<td class="regular">#Shr_Ship_To_Name#</td>
				<!--- Broker name --->
				<td align="right" class="regular">#application.returned_customer_setting.broker_label_singular# Name:</td>
				<td class="regular">#Broker_Name#</td>
			</tr>
			
			<!--- Address 1 --->
			<tr>
				<!--- Customer  --->
				<td>&nbsp;</td>
				<td class="regular">#Dist_Address_1#</td>
				<!--- Broker --->
				<td>&nbsp;</td>
				<td class="regular">#Brok_Address_1#</td>
			</tr>
			
			<!--- Address 2 --->
			<tr>
				<!--- Customer  --->
				<td>&nbsp;</td>
				<td class="regular">#Dist_Address_2#</td>
				<!--- Broker --->
				<td>&nbsp;</td>
				<td class="regular">#Brok_Address_2#</td>
			</tr>
			
			<!--- City State Zip --->
			<tr>
				<!--- Customer  --->
				<td>&nbsp;</td>
				<td class="regular">#trim(Dist_City)#, #Dist_State# #Dist_Zip#</td>
				<!--- Broker --->
				<td>&nbsp;</td>
				<td class="regular">#trim(Brok_City)#, #Brok_State# #Brok_Zip#</td>
			</tr>
			
			<!--- Buying Group--->
			<tr>
				<!--- Customer  --->
				<td align="right" class="regular">Group:</td>
				<td class="regular">#Buying_Group_Name# (#Buying_Group#)</td>
				<!--- Broker --->
				<td align="right" class="regular">Number:</td>
				<td class="regular">#Shr_CustID#</td>
			</tr>
		
		<!--- Auto report info ---->
		<tr>
			<td align="Right" valign="top" class="regular">Report Information:</td>
			<td valign="top" class="regular">
					#Report_Title# (#BB_Auto_Report_ID#)<br>
					For activity from #dateformat(qAutoPayExtractHeader.Start_Date, 'mm/dd/yyyy')# and #dateformat(qAutoPayExtractHeader.End_Date, 'mm/dd/yyyy')#
			</td>
		
		
		<!--- Program info ---->
		
			<td align="Right" valign="top" class="regular">Program Information:</td>
			<td valign="top" class="regular">
					#Contract_Number# - #Contract_Title#<br>
					Deal active from #dateformat(Contract_Start_Date, 'mm/dd/yyyy')# to #dateformat(Contract_End_Date, 'mm/dd/yyyy')#
			</td>
		</tr>
		
		<tr>
			<td align="right" valign="top" class="strong">Amount Due:</td>
			<td class="box" align="center"><cfif isNumeric(qGetDistAmountEarned.Sum_Amount_Earned) >#lscurrencyformat(qGetDistAmountEarned.Sum_Amount_Earned)#<cfelse>#lscurrencyformat(TotalEarned)#</cfif></td>
			<td align="right" valign="top" class="strong">Adjustments Applied:</td>
			<td class="regular" align="left">
				-#lscurrencyformat(qSumDistAppliedAdjustments.Sum_Adjustment_Amount)#
			</td>
		</tr>
		
		</table>
				
		<!--- Query for invoice level information --->
		<cfset qInvoiceLevelInfo 	 =  application.oBBReportGet.getInvoiceLevelInfo(Report_ID,Shr_Ship_To,Contract_Main_ID)>		
		<cfset SumOfInvoiceEarnings = 0>
		<cfloop query="qInvoiceLevelInfo">
		<!--- Invoice level header --->
		<table border="0" width="100%" class="small">
			<tr>
				<td width="35%"><span class="strong">Invoice Number:</span> <span class="regular">#Shared_Invoice_Number#</span></td>
				<td width="25%"><span class="strong">Invoice Date:</span> <span class="regular">#dateformat(Invoice_Date, 'mm/dd/yyyy')#</span></td>
				<td width="40%"><span class="strong">Purchase Order:</span> <span class="regular">#Purchase_Order#</span></td>
				<td width="40%"><span class="strong">#variables.orderNumberLabel.General_Labels_Label#:</span> <span class="regular">#Pro_Number#</span></td>
			</tr>
			<!--- Only a small percentage of the invoices will have this populated. --->
			<cfif Credit_Program_Number neq "">
			<tr>
				<td colspan="100%"><span class="strong">Credit Program:</span> <span class="regular">#Credit_Program_Number# - #Credit_Program_Title#</span></td>
			</tr>
			</cfif>
		</table>
		
		<!--- Reset these for each invoice --->
		<cfset InvoiceTotalCases = 0>
		<cfset InvoiceTotalPounds = 0>
		<cfset InvoiceTotalPurchased = 0>
		<cfset InvoiceTotalPaid = 0>
		
		<!--- Finally the nitty gritty --->
		<cfset qInvoiceDetailInfo 	 =  application.oBBReportGet.getInvoiceDetailInfo(Report_ID,qCustomersonReport.Shr_Ship_To,qCustomersonReport.Contract_Main_ID,Shared_Invoice_Number,qCustomersonReport.BSA_Foodservice_Customers_ID,BB_Auto_Program_Pay_Period_ID)>

			<table border="0" width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<cfif application.appSettingsget.get_Setting('Display_Item_No') eq "1">
                <td class="tiny">#application.returned_customer_setting.item_label#</td>
                </cfif>
				<cfif application.returned_customer_setting.UPC_Switch>
                <td class="tiny">#application.returned_customer_setting.upc_label#</td>
                </cfif>
				<td class="tiny" colspan="2">#qInvoiceDetailInfo.Attribute_Description#</td>
				<td class="tiny" >Description</td>
				<cfif ShowCases IS 1>
				<td class="tiny" align="right">Cases Invoiced</td>
				</cfif>
				<cfif ShowPounds IS 1>
				<td class="tiny" align="right">Pounds Invoiced</td>
				</cfif>
				<td class="tiny" align="right">Unit Price</td>
				<td class="tiny" align="right">Ext $</td>
				<td class="tiny" align="right">Discount</td>
				<td class="tiny" align="right">Previous Paid</td>
				<td class="tiny" align="right">Amount Earned</td>
			</tr>
			<cfloop query="qInvoiceDetailInfo">
				
				<tr <cfif #qInvoiceDetailInfo.currentRow#MOD 2 EQ 0>style="background-color:##C3FDB8;"</cfif>>
					<cfif application.appSettingsget.get_Setting('Display_Item_No') eq "1">
                    <td  class="reallySmall">#Item#</td>
                    </cfif>
					<cfif application.returned_customer_setting.UPC_Switch>
                    <td class="reallySmall">#UPC#</td>
                    </cfif>
					<td class="reallySmall">#Attribute_Value#</td>
					<td class="reallySmall" align="left">#Attribute_Number#</td>
					<td class="reallySmall">#Item_Description#</td>
					<cfif ShowCases IS 1>
					<td class="reallySmall" align="right">#numberformat(Cases_Invoiced, '___,___,___')#</td>
					</cfif>
					<cfif ShowPounds IS 1>
					<td class="reallySmall" align="right">#numberformat(Pounds_Invoiced, '___,___,___')#</td>
					</cfif>
					<td class="reallySmall" align="right">#lscurrencyformat(Unit_Price)# #Price_Unit_of_Measure#</td>
					<td class="reallySmall" align="right">#lscurrencyformat(Sales_Dollars)#</td>
					<!--- Dev Note: (70149) 4 decimal places --->
					<td class="reallySmall" align="right"><cfif len(trim(Discount_UOM)) GT 1>$</cfif>#numberformat(Discount_Offered, '___,___.____')# #Discount_UOM#</td>
					<td class="reallySmall" align="right">#lscurrencyformat(Previous_Paid_Amount)#</td>
					<td class="reallySmall" align="right">#lscurrencyformat(Amount_Earned)#</td>
				</tr>			
				
				<!--- Add the values for this detail --->
				<cfset InvoiceTotalCases 	= InvoiceTotalCases + Cases_Invoiced>
				<cfset InvoiceTotalPounds 	= InvoiceTotalPounds + Pounds_Invoiced>
				<cfset InvoiceTotalPurchased = InvoiceTotalPurchased + Sales_Dollars>
				<cfset InvoiceTotalPaid 	= InvoiceTotalPaid + Amount_Earned>	
									
			</cfloop>
			<cfif qInvoiceDetailInfo.recordcount EQ 0>
				<tr><td colspan="11">There are no Items</td></tr>
			</cfif>	
			<tr>
				<td colspan="#InvoiceSubTotalColSpan#" class="subTotal">Totals for Invoice #Shared_Invoice_Number#:</td>
				<cfif ShowCases IS 1>
				<td align="right" class="subTotal">#numberformat(InvoiceTotalCases, '___,___,___')#</td>
				</cfif>
				<cfif ShowPounds IS 1>
				<td align="right" class="subTotal">#numberformat(InvoiceTotalPounds, '___,___,___')#</td>
				</cfif>
				<td class="subTotal">&nbsp;</td>
				<td align="right" class="subTotal">#lscurrencyformat(InvoiceTotalPurchased)#</td>
				<td class="subTotal">&nbsp;</td>
				<td class="subTotal">&nbsp;</td>
				<td align="right" class="subTotal">#lscurrencyformat(InvoiceTotalPaid)#</td>
			</tr>
			<tr><td colspan="100">&nbsp;</td></tr>
			<!--- Add to distributor sum --->
				<cfset SumOfInvoiceEarnings = SumOfInvoiceEarnings + InvoiceTotalPaid>
					
			</table>
		
		<!--- Invoice level query --->		
		</cfloop>
		<p></p>
		<div align="right" class="larger">Total Earned For #Shr_Ship_To_Name#: #lscurrencyformat(qGetDistAmountEarned.Sum_Amount_Earned)#</div>
		
		
		<!--- Display excluded invoices--->
		<cfset qExcludedInvoices	
			= 	application.oBBReportGet.getExcludedInvoices(qCustomersonReport.BSA_Foodservice_Customers_ID,
																				qCustomersonReport.Contract_Main_ID,
																				qAutoPayExtractHeader.Start_Date,
																				qAutoPayExtractHeader.End_Date	)>
		<cfif qExcludedInvoices.Recordcount GT 0>
		<p></p>

			<span class="strong">Excluded Off Invoice Transactions:</span>

			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td class="normalheader">Invoice Number</td>
					<td class="normalheader">Invoice Date</td>
					<td class="normalheader">Purchase Order</td>
					<td class="normalheader">Item</td>
					<cfif ShowCases IS 1>
					<td class="normalheader" align="right">Cases</td>
					</cfif>
					<cfif ShowPounds IS 1>
					<td class="normalheader" align="right">Pounds</td>
					</cfif>
					<td class="normalheader"  align="right">Exclusion Reasons</td>
				
					<td class="normalheader" align="right">$</td>
				</tr>
			<cfloop query="qExcludedInvoices">
				
				<!--- Rules for Exclusion Reasons:
				1) If we have a Blacksmith contract title (from join), use it and stop
				2) If we have a Blacksmith Operator name (from join) use it and stop
				3) Otherwise if we have entries in Operator_ID and/or Contract_Number, display them
				4) Otherwise leave it blank --->
				
				<cfset ExclusionReason="">
				<cfif len(trim(qExcludedInvoices.Contract_Title)) GT 0>
					<cfset ExclusionReason = qExcludedInvoices.BSA_Contract_Number & " " &  qExcludedInvoices.Contract_Title>
				<cfelseif len(trim(qExcludedInvoices.Operator_Name)) GT 0>
					<cfset ExclusionReason = qExcludedInvoices.BSA_Operator_ID & " " & qExcludedInvoices.Operator_Name>
				<cfelseif len(trim(qExcludedInvoices.Contract_Number)) GT 0 OR len(trim(qExcludedInvoices.Operator_ID)) GT 0>
					<cfif len(trim(qExcludedInvoices.Contract_Number)) GT 0>
						<cfset ExclusionReason = qExcludedInvoices.Contract_Number & " ">
					</cfif>	
					<cfif len(trim(qExcludedInvoices.Operator_ID)) GT 0>
						<cfset ExclusionReason = ExclusionReason & qExcludedInvoices.Operator_ID>
					</cfif>
				<cfelse>
					<cfset ExclusionReason = "None provided">
				</cfif>
				
				<tr <cfif #qExcludedInvoices.currentRow#MOD 2 EQ 0>style="background-color:##C3FDB8;"</cfif>>
					<td class="normal">#Order_Number#</td>
					<td class="normal">#dateformat(Invoice_Date, 'mm/dd/yyyy')#</td>
					<td class="normal">#Purchase_Order#</td>
					<td class="normal">#Item#</td>
					<cfif ShowCases IS 1>
					<td class="normal" align="right">#numberformat(Cases_Invoiced, '___,___,___')#</td>
					</cfif>
					<cfif ShowPounds IS 1>
					<td class="normal" align="right">#numberformat(Pounds_Invoiced, '___,___,___,___')#</td>
					</cfif>
					<td class="normal" align="right">#ExclusionReason#</td>
					<td class="normal" align="right">#lscurrencyformat(Sales_Dollars)#</td>
				</tr>
			</cfloop>
			</table>
		
		</cfif>
		<!--- End display excluded invoices --->
		
		
		
		<!--- Now go get clawbacks applied to this auto payment --->
		<cfset qExportPullDetails = application.oBBReportGet.getExportPullDetails(Report_ID,qCustomersonReport.Billback_ID,0,qCustomersonReport.BSA_Foodservice_Customers_ID) />

		<cfset Pullbacks = 0>

		<!--- Only display if there are applied adjustments --->
		<cfif qExportPullDetails.recordcount gt 0>
		<p></p>

			<span class="strong">Applied #application.appSettingsGet.getPullbackLabel()#s:</span>

			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td class="normalheader">#application.appSettingsGet.getPullbackLabel()# Claim</td>
					<td class="normalheader">Program</td>
					<td class="normalheader">Item ##</td>
					<td class="normalheader">Item Description</td>
					<!--- <td class="normalheader" align="right">Rate</td> --->
					<td class="normalheader" align="right">Volume</td>
					<td class="normalheader" align="right">Amt $</td>
				</tr>
			<cfloop query="qExportPullDetails">
				<tr <cfif #qExportPullDetails.currentRow#MOD 2 EQ 0>style="background-color:##C3FDB8;"</cfif>>
					<td class="normal">#Pullback_BB_Code#</td>
					<td class="normal">#Pullback_Contract_Number#</td>
					<td class="normal">#Item#</td>
					<td class="normal">#Item_Description#</td>
					<!--- <td class="normal" align="right">#numberformat(PB_From_Program_Rate, '___,___,__.__')# #Unit_Of_Measure_Desc#</td> --->
					<td class="normal" align="right">
						<cfif ShowCases IS 1>#numberformat(Product_BB_Volume_CS, '___,___,___')# CS </cfif>
						<cfif ShowPounds IS 1>#numberformat(Product_BB_Volume_LB, '___,___,___')# LB</cfif>
					</td>
					<td class="normal" align="right">#lscurrencyformat(Pullback_Amount)#</td>					
				</tr>
				<cfset Pullbacks = Pullbacks + Pullback_Amount>
			</cfloop>
			
			<tr>
				<td colspan="6" class="subTotal" align="right">#application.appSettingsGet.getPullbackLabel()# Total:</td>
				<td class="subTotal" align="right">#lscurrencyformat(Pullbacks)#</td>
			</tr>
			
			</table>
		
		<!--- qAppliedAdjustments.Recordcount GT 0 --->	
		</cfif>

		<!--- End applied adjustments --->
		<cfset Adjustments = 0>

		<!--- Now go get detailed adjustments applied to this auto pay --->
		<cfset qAppliedAdjustments 	 =  application.oBBReportGet.getAppliedAdjustments(qCustomersonReport.Billback_ID,qCustomersonReport.BSA_Foodservice_Customers_ID)>
		
		<!--- Only display if there are applied adjustments --->
		<cfif qAppliedAdjustments.Recordcount GT 0>
		<p></p>

			<span class="strong">Applied Adjustments:</span>

			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td class="normalheader">Billback Number</td>
					<td class="normalheader">Billback Code</td>
					<td class="normalheader">Title</td>
					<td class="normalheader">Start Date</td>
					<td class="normalheader">End Date</td>
					<td class="normalheader" align="right">Billback Amt $</td>
					<td class="normalheader" align="right">Applied $</td>
				</tr>
			<cfloop query="qAppliedAdjustments">
				<tr <cfif #qAppliedAdjustments.currentRow#MOD 2 EQ 0>style="background-color:##C3FDB8;"</cfif>>
					<td class="normal">#BB_Reference#</td>
					<td class="normal">#BB_Code#</td>
					<td class="normal">#BB_Title#</td>
					<td class="normal">#dateformat(BB_Start_Date, 'mm/dd/yyyy')#</td>
					<td class="normal">#dateformat(BB_End_Date, 'mm/dd/yyyy')#</td>
					<td class="normal" align="right">#lscurrencyformat(BB_Amount)#</td>
					<td class="normal" align="right">-#lscurrencyformat(Adjustment_Amount)#</td>
				</tr>
				<cfset Adjustments = Adjustments + Adjustment_Amount>
			</cfloop>
			
			<tr>
				<td colspan="6" class="subTotal" align="right">Adjustment Total:</td>
				<td class="subTotal" align="right">#lscurrencyformat(Adjustments)#</td>
			</tr>		
			</table>
		
		<!--- qAppliedAdjustments.Recordcount GT 0 --->	
		</cfif>

		<!--- End applied adjustments --->
		
		
		
		<!--- Now display total --->
<p></p>
	
		<div align="right" class="BigAndStrong">Total Paid for #Shr_Ship_To_Name#: <cfif isNumeric(qGetDistAmountEarned.Sum_Amount_Earned) >#lscurrencyformat(qGetDistAmountEarned.Sum_Amount_Earned - Adjustments - Pullbacks)#<cfelse>#lscurrencyformat(TotalEarned)#</cfif> </div>
	

		<cfif qCustomersonReport.Recordcount NEQ qCustomersonReport.CurrentRow>
		<!--- Page break --->
		<cfdocumentitem type = "pagebreak"/>
		<!--- Page break --->
		</cfif>
		
		<!--- qCustomersonReport --->
		</cfloop>
	</cfoutput>

<!--- Footer --->
<cfdocumentitem type="footer">
<style>
.ProvidedBy
{
	background-color: #cccccc;
	font-size: 10px;
	font-family: arial;
	border-top: 2px solid;
}

.regularStyle
{
	font-size: 10px;
	font-family: arial;
}
</style>
<cfoutput>
	<table border="0" cellpadding="2" cellspacing="0" width="100%">
	<!--- Provided by --->
	<tr>
		<td colspan="3" class="ProvidedBy" align="center">
			Provided by Blacksmith Applications FORGE Suite
		</td>
	</tr>
	
	<!--- Basic info --->
	<tr>
		<td width="200" class="footer" align="left" >
			#Dateformat(now(), 'mmm dd, yyyy')#
		</td>
		<td class="footer" align="center">
			#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#
		</td>
		<td width="200" class="footer" align="right">
			#application.returned_customer_setting.Company_Name#
		</td>
		
	</tr>

	</table>
</cfoutput>
 </cfdocumentitem >

</CFDOCUMENT>

<!--- Check to see if it exists before we go through all this again --->
</cfif>
