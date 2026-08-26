<!--- 
THIS FILE WAS BEING CALLED BY "PAYMENT_HISTORY_DETAILS.CFM", BUT IS NOT BEING USED ANYMORE, AS WE ARE NOW USING THE DATA TABLES GRID CODE.
--->

<!--- payment_history_operator_offinvoice_details.cfm --->

<cfparam name="form.contractId" default="" >
<cfparam name="URL.PRINT" default="0">
<cfparam name="form.generatexlsreport" default="0">
<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">

<cfif IsNumeric(form.contractId)>
	<cfset url.contractId = form.contractId />
</cfif>

<cfif isDefined("url.contractId") and IsNumeric(url.contractId)>


<cfif form.generatexlsreport EQ 1>
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=PaymentHistoryOffInvoiceDetail.xls">
</cfif>

<html>
<head>
	<title>Payment History - Direct Shipment Details</title>
</head>

<body>
	
<cfset table_Width = 800 />
<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset qGetOperatorOffInvoiceInvoiceDetails = PaymentHistoryManager.getOperatorOffInvoiceInvoiceDetails(contract_number = getcontractInfo.contract_number,contractMainID=ContractId) />

<cfif url.PRINT EQ 0 and form.generatexlsreport EQ 0>
<cf_Number_of_Rows maxrows=100>
<cfelse>
<cf_Number_of_Rows maxrows= #qGetOperatorOffInvoiceInvoiceDetails.recordcount#>
</cfif>

<cfoutput>
<TABLE CELLPADDING="2" CELLSPACING="0" border="0" WIDTH="#table_Width#" BGCOLOR="FFE083" CLASS="Maintable">
	<tr>
	<td valign= "top" CLASS="tableheaders" style="border-bottom:1px solid Gray;"><B>
	#getcontractInfo.Contract_Number# - #left(getcontractInfo.Contract_Title,75)#<br>
	Reference Number: #getcontractInfo.contract_reference_number#<br>
	Status: #getcontractInfo.contract_status_type_desc#
	<br> Contract Start Date: #Dateformat(getcontractInfo.contract_start_date,"mm/dd/yyyy")# - Contract End Date: #Dateformat(getcontractInfo.contract_end_date,"mm/dd/yyyy")# <br>
	Template Type: #getcontractInfo.created_type#
	</td>
	</tr>
</TABLE>
</cfoutput>
	
<cfoutput>
<table cellspacing="0" cellpadding="2" CLASS="Maintable" BGCOLOR="FFE083" WIDTH="#table_Width#">
</cfoutput>
	<THEAD>
	<tr>
		<td CLASS="tableheaders">Invoice Number</td>
		<td CLASS="tableheaders">Invoice Date</td>
		<td CLASS="tableheaders">Ship To</td>
		<td CLASS="tableheaders">Name</td>
		<td CLASS="tableheaders">Item</td>
		<td CLASS="tableheaders">Description</td>
		<td CLASS="tableheaders">Cases Invoiced</td>
		<td CLASS="tableheaders">Pounds Invoiced</td>
		<td CLASS="tableheaders">Sales Dollars</td>
	</tr>
	</THEAD>
<cfoutput query="qGetOperatorOffInvoiceInvoiceDetails" startrow="#StartRow#" maxrows="#MaxRows#">
	<CFIF currentrow mod 2>
		<CFSET BG_COLOR = "white">
	<CFELSE>
		<CFSET BG_COLOR = "ccffcc">
	</CFIF>
	<tr BGCOLOR="#BG_COLOR#" valign="top">
		<td>#Invoice_Number#</td>
		<td>#DateFormat(Invoice_Date, "mm/dd/yyyy")#</td>
		<td>#Shr_Ship_To#</td>
		<td>#Name#</td>
		<td>#Item#</td>
		<td>#Description#</td>
		<td>#NumberFormat(Cases_Invoiced, "_,___,___,___,___")#</td>
		<td>#NumberFormat(Pounds_Invoiced, "_,___,___,___,___")#</td>
		<td>#DollarFormat(Sales_Dollars)#</td>
	</tr>
</cfoutput>
</table>

<cfif URL.PRINT EQ 0 and form.generatexlsreport EQ 0>
	
<script language="javascript">

function printform()
{
	NewWindow('print_payment_history.cfm','PrintEmailWin','760','600','Yes', 'Yes');
	document.all.PrintForm.printonly.value=1;
	document.all.PrintForm.FAX_EMAIL.value="";
	document.all.PrintForm.submit();	
}

function emailform(type)
{
	NewWindow('print_payment_history.cfm','PrintEmailWin','720','600','Yes', 'Yes');
	document.all.PrintForm.printonly.value=0;
	document.all.PrintForm.FAX_EMAIL.value=type;
	document.all.PrintForm.submit();	
}
function ExcelFormsubmit()
{
	ExcelForm.submit();
}
</script>

<cfoutput>
<FORM ACTION="/common_files/contracts/payment_history_operator_offinvoice_details.cfm" METHOD="post" NAME="payment_history_offinvoice_details_form">
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
	<input type="hidden" name="ContractId" value="#ContractId#">
</FORM>
</cfoutput>

<FORM ACTION="/common_files/contracts/print_payment_history.cfm" METHOD="post" NAME="PrintForm" Target="PrintEmailWin">
<cfoutput> 
 <input type="hidden" name="ContractId" value="#ContractId#">
 <input type="hidden" name="generatexlsreport" value="0">
 <input type="hidden" name="printonly" value="1">
 <input type="hidden" name="FAX_EMAIL" value="">
 <input type="hidden" name="Include_File_path" value="/common_files/contracts/payment_history_operator_offinvoice_details.cfm">
</cfoutput>
</form>

<FORM ACTION="/common_files/contracts/payment_history_operator_offinvoice_details.cfm" METHOD="post" NAME="ExcelForm">
<cfoutput> 
 <input type="hidden" name="ContractId" value="#ContractId#">
 <input type="hidden" name="generatexlsreport" value="1">
 </cfoutput>
</FORM>


<table>
<tr>
	<td align="left" colspan="100%">
		<CF_Next_Previous_For_Forms
		formname="payment_history_offinvoice_details_form"
		query="qGetOperatorOffInvoiceInvoiceDetails"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">	
	</td>	
</tr>
<tr>
	<td>
		<CF_button
				button_name		=	""
				button_caption	=	"Print"
				button_action	=	"javascript:printform();"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Print"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>	
	</td>
	<td>
		<CF_button
			button_name		=	""
			button_caption	=	"Email"
			button_action	=	"javascript:emailform('email');"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Email"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	
</td>
	<td>
		<CF_button
			button_name		=	""
			button_caption	=	"Export to Excel"
			button_action	=	"javascript:ExcelFormsubmit();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Aggregate item level detail for those selected"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	
	
	</td>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"close"
			button_action	=	"top.close();"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</td>
	<td colspan="100%">&nbsp;</td>
</tr>

</table>
</cfif>
</body>

</cfif>