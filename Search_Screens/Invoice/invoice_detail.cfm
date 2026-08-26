<!---Shows invoice details
/search_Screens/invoice/invoice_details.cfm
July 14, 2003
Brenda Flynn -- bflynn@awayx.com
--->
<!--- D30063: Javascript Error START--->
<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
<!--- D30063: Javascript Error END--->
<cfset genSettings = CreateObject("component","components.settings.ApplicationSettingsManager").init() />

<cfparam name="url.order_Number" default="">
<cfparam name="url.invoice_date" default="">

 <!--- WR 68986: show Invoice details from the payment history (offinvoice) page --->
 <cfif url.Order_Number neq "" AND url.invoice_date neq "">
	<cfquery name="qGetInvoiceHeader" datasource="#application.datasource#">
		SELECT Invoice_Header_ID
		FROM Invoice_Header
		WHERE Order_Number = '#url.order_Number#'
		AND Invoice_Date = '#url.invoice_date#'
		AND deleted = 0
	</cfquery>
	<cfif qGetInvoiceHeader.recordcount neq 0>
		<cfset url.Invoice_Header_ID = qGetInvoiceHeader.Invoice_Header_ID>
	<cfelse>
		<cfif find("_", "#url.order_Number#")>
			<cfset count = find("_", "#url.order_Number#")-1>
			<cfset invoiceNumber = Left("#url.order_Number#", #count#)>

		<cfquery name="qGetInvoiceHeader" datasource="#application.datasource#">
			SELECT Invoice_Header_ID
			FROM Invoice_Header
			WHERE Order_Number = '#invoiceNumber#'
			AND Invoice_Date = '#url.invoice_date#'
			AND deleted = 0
		</cfquery>
		<cfif qGetInvoiceHeader.recordcount neq 0>
			<cfset url.Invoice_Header_ID = qGetInvoiceHeader.Invoice_Header_ID>
		</cfif>
	</cfif>
	</cfif>
 </cfif>

<!---Set default information--->
<cfif NOT isDefined("url.Invoice_Header_ID")>
	<script>
		window.close();
	</script>
	<cfabort>
</cfif>

<cfset Invoice_Header_ID = url.Invoice_Header_ID>
<!---Print is automatically turned off--->
<cfparam name="Print" default="0">
	<cfif isDefined("url.Print")>
		<cfset Print = url.Print>
	</cfif>

<!---Includes right click code--->
<cfif Print IS 0><!---Only include if you're not printing--->
	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<cfinclude template="/includes/right_click_menu_code.cfm">
</cfif>

<!---Queries for details--->
<cfquery name="InvoiceDetails" datasource="#application.datasource#">
SELECT 	<!---Invoice Header--->
		Invoice_Header.Invoice_Header_ID, Invoice_Header.Order_Number, Invoice_Header.Invoice_Version,
		Invoice_Header.Current_Shared_Ship_To, Invoice_Header.Shared_Invoice_Number, Invoice_Header.Order_Date,
		Invoice_Header.Ship_Date, Invoice_Header.Invoice_Date, Invoice_Header.Delivery_Date,
		(Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS Invoice_Number,
		Invoice_Header.Purchase_Order,
		Invoice_Header.Notes, Invoice_Header.Reason_Code,
		<!---Invoice Details--->
		Invoice_Detail.Cases_Ordered, Invoice_Detail.Cases_Invoiced, Invoice_Detail.Pounds_Ordered,
		Invoice_Detail.Pounds_Invoiced, Invoice_Detail.Customer_Requested_Cases, Invoice_Detail.LB_Unit_Price,
		Invoice_Detail.Price_Unit_of_Measure, IsNull(Invoice_Detail.Unit_Price,0) As Unit_Price, IsNull(Invoice_Detail.Sales_Dollars,0) As Sales_Dollars,
		Invoice_Detail.BSA_Foodservice_Items_Master_ID, Invoice_Detail.CS_Unit_Price, Invoice_Detail.Invoice_Line_Number
		<cfif genSettings.get().getForInvoicesDisplayOI() IS 1>
		, IsNull(Invoice_Detail.Unit_List_Price,0) As Unit_List_Price
		 ,IsNull(Invoice_Detail.Unit_Allowance,0) As Unit_Allowance
		 </cfif>,
		<!---Item details--->
		BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.UPC,
		BSA_Foodservice_Items_Master.Item,
		<!---Distributor Information--->
		BSA_Foodservice_Customers.Name, BSA_Foodservice_Customers.Ship_To, Invoice_Detail.Line_Type,
		Invoice_Header.Pro_Number
FROM 	Invoice_Header
	INNER JOIN Invoice_Detail
	ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
	INNER JOIN BSA_Foodservice_Items_Master
	ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID =
	Invoice_Detail.BSA_Foodservice_Items_Master_ID
	INNER JOIN  BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID =
	Invoice_Header.BSA_Foodservice_Customers_ID
WHERE 	Invoice_Header.Invoice_Header_ID = '#Invoice_Header_ID#'
AND		Invoice_Header.Deleted = 0
AND		ISNULL(Invoice_Detail.Deleted,0) = 0

<cfif genSettings.get().getForInvoicesDisplayOI() IS 1>
UNION

SELECT 	<!---Invoice Header---> <!--- This Query is for Special Items --->
		Invoice_Header.Invoice_Header_ID, Invoice_Header.Order_Number, Invoice_Header.Invoice_Version,
		Invoice_Header.Current_Shared_Ship_To, Invoice_Header.Shared_Invoice_Number, Invoice_Header.Order_Date,
		Invoice_Header.Ship_Date, Invoice_Header.Invoice_Date, Invoice_Header.Delivery_Date,
		(Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number) AS Invoice_Number,
		Invoice_Header.Purchase_Order,
		Invoice_Header.Notes, Invoice_Header.Reason_Code,
		<!---Invoice Details--->
		Invoice_Detail.Cases_Ordered, Invoice_Detail.Cases_Invoiced, Invoice_Detail.Pounds_Ordered,
		Invoice_Detail.Pounds_Invoiced, Invoice_Detail.Customer_Requested_Cases, Invoice_Detail.LB_Unit_Price,
		Invoice_Detail.Price_Unit_of_Measure, IsNull(Invoice_Detail.Unit_Price,0) As Unit_Price, IsNull(Invoice_Detail.Sales_Dollars,0) As Sales_Dollars,
		Invoice_Detail.BSA_Foodservice_Items_Master_ID, Invoice_Detail.CS_Unit_Price, Invoice_Detail.Invoice_Line_Number
		,'0' As Unit_List_Price
		 ,'0' As Unit_Allowance,
		<!---Item details--->
		BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.UPC,
		BSA_Foodservice_Items_Master.Item,
		<!---Distributor Information--->
		BSA_Foodservice_Customers.Name, BSA_Foodservice_Customers.Ship_To, Invoice_Detail.Line_Type,
		Invoice_Header.Pro_Number
FROM 	Invoice_Header
	INNER JOIN Invoice_Detail
	ON Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
	LEFT OUTER JOIN BSA_Foodservice_Items_Master
	ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID =
	Invoice_Detail.BSA_Foodservice_Items_Master_ID
	INNER JOIN  BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID =
	Invoice_Header.BSA_Foodservice_Customers_ID
WHERE 	Invoice_Header.Invoice_Header_ID = '#Invoice_Header_ID#'
AND	Invoice_Header.Deleted = 0
AND	ISNULL(Invoice_Detail.Deleted,0) = 0
AND Invoice_Detail.Line_Type ='s'
 </cfif>
</cfquery>

<cfscript>
	variables.labelsObject = createObject("component", "components.settings.labels.labels").init();
	variables.orderNumberLabel = variables.labelsObject.GetGeneralLabels(labelDescription = "Order Number");
</cfscript>

<!---Display--->
<cfoutput>
	<html>
	<head>
	<title>Invoice  ###InvoiceDetails.Invoice_Number#  :: #InvoiceDetails.Name#</title>
</cfoutput>

<cfif InvoiceDetails.Recordcount GT 0>

	<!---Styles--->

<STYLE TYPE="text/css">
	BODY, TD, .normal
{
	font-family : Arial;
	font-size : 8pt;
	color : Black;
}

TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}

.normal
{
	font-family : Arial;
	font-size : 8pt;
	color : Black;
}

A, A:LINK, A:VISITED
{
	color : Blue;
	text-decoration : none;
}

A:FOCUS,A:HOVER
{
	color : Red;
	text-decoration : underline;
}

A.bold, A.bold:LINK, A.bold:VISITED
{
	color : Blue;
	font-size : 10pt;
	text-decoration : underline;
	font-weight : bold;
}

A.bold:FOCUS,A.bold:HOVER
{
	color : Red;
	font-size : 10pt;
	text-decoration : underline;
	font-weight : bold;
}

.biglink {
	text-decoration : none;
	font-size:10pt;
	font-weight:bold;
}

.pageheading
{
	color : Navy;
	font-size : 14pt;
	font-weight : bold;
	font-style : italic;
}

.textbox_input
{
	border: 1px solid rgb(192,192,192);
	font: 14px Arial, Arial;
	font-weight: bold;
	color: Navy;
	background-color: rgb(255, 255, 255);
	text-align: right;
}

.input_textbox_input
{
	border: 1px solid rgb(192,192,192);
	font: 14px Arial, Arial;
	font-weight: bold;
	color: Navy;
	background-color: rgb(255, 255, 255);
	text-align: left;
}

.button_typical
{
	cursor: pointer;
	border-bottom: 1 solid rgb(0,0,0);
	border-right: 1 solid rgb(0,0,0);
	border-left: 1 solid rgb(192,192,192);
	border-top: 1 solid rgb(192,192,192);
	background-color: rgb(255, 255, 255);
}

INPUT, SELECT, TEXTAREA
{
			font: 8pt Arial;
}

.pageBreakBefore
{
	page-break-before: always;
}
.pageBreakAfter
{
	page-break-after: always;
}

Span.navbarlinks, A.navbarlinks, A:LINK.navbarlinks, A:VISITED.navbarlinks
	{
	color: White;
	font-size: 12px;
	font-weight: bold;
	}

.navbarlinks
	{
	color: White;
	font-size: 12px;
	font-weight: bold;
	}

.navbarlinks2
	{
	color: Black;
	font-size: 12px;
	font-weight: bold;
	}

.Title
	{
	color: White;
	font-size: 19px;
	font-weight: bold;
	}

.Title2
	{
	color: Navy;
	font-size: 14px;
	font-weight: bold;
	}

.bold
	{
	font-size: 11px;
	font-weight: bold;
	}


</style>

	<!---End styles--->

<cfoutput>
	</head>
	<body BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
	<!--- &nbsp; <br> --->
<!---Display--->
<table border="0" cellpadding="0" cellspacing="0" width="98%" align="center" style="margin-top:5px;">

<!---Distributor and image--->
<tr>
	<td <cfif application.returned_customer_setting.shared_invoice IS 1>rowspan="7"<cfelse>rowspan="6"</cfif>style="border-bottom:solid ##330099 2px;">&nbsp; </td>
	<td class="navbarlinks2">#application.returned_customer_setting.distributor_label_singular#  </td>
	<td align="left" class="navbarlinks2">&nbsp; :&nbsp;</td>
	<td width="30%" class="navbarlinks2">&nbsp; #InvoiceDetails.Name# (#InvoiceDetails.Ship_To#)</td>
	<td style="border-bottom:solid ##330099 2px;" nowrap valign="center" align="right" <cfif application.returned_customer_setting.shared_invoice IS 1>rowspan="7"<cfelse>rowspan="6"</cfif>><cfoutput>  <b>
  <font face="Arial" size="5" color="##330099">#application.returned_customer_setting.Company_Name# </font></b> </cfoutput>&nbsp; &nbsp; &nbsp; </td>
<p></p>

</tr>
<!---Invoice number --->
<tr>
	<td class="navbarlinks2">Invoice ##</td>
	<td align="left" class="navbarlinks2"> &nbsp; :&nbsp; </td>
	<td  width="100%" class="navbarlinks2">&nbsp;  #InvoiceDetails.Shared_Invoice_Number#</td>
</tr>
<cfif application.returned_customer_setting.shared_invoice IS 1>
<!---Invoice number --->
<tr>
	<td class="navbarlinks2">Legacy Invoice ##</td>
	<td align="left" class="navbarlinks2"> &nbsp; :&nbsp; </td>
	<td  width="100%" class="navbarlinks2">&nbsp;  #InvoiceDetails.Invoice_Number#</td>
</tr>
</cfif>

<!--- order number --->
<tr>
	<td class="navbarlinks2" nowrap>#variables.orderNumberLabel.General_Labels_Label#</td>
	<td align="left" class="navbarlinks2" >&nbsp; :&nbsp;</td>
	<td width="100%" class="navbarlinks2" >&nbsp; #InvoiceDetails.Pro_Number#</td>
</tr>

<!---Invoice date --->
<tr>
	<td class="navbarlinks2" nowrap>Invoice Date </td>
	<td align="left" class="navbarlinks2" >&nbsp; :&nbsp;</td>
	<td width="100%" class="navbarlinks2" >&nbsp; #Dateformat(InvoiceDetails.Invoice_Date, 'MMMM DD, YYYY')#</td>
</tr>
<!---Purchase Order --->
<tr>
	<td class="navbarlinks2" nowrap>PO Number </td>
	<td align="left" class="navbarlinks2">&nbsp; :&nbsp;</td>
	<td width="100%" class="navbarlinks2" >&nbsp; #InvoiceDetails.Purchase_Order#</td>
</tr>
<!---Reason Code -- bottom border--->
<tr>
	<td  style="border-bottom:solid ##330099 2px;"  class="navbarlinks2" nowrap>Reason Code </td>
	<td align="left" class="navbarlinks2"  style="border-bottom:solid ##330099 2px;" >&nbsp; :&nbsp;</td>
	<td width="100%" class="navbarlinks2"  style="border-bottom:solid ##330099 2px;">&nbsp; #InvoiceDetails.Reason_Code#</td>
</tr>
</table>
<br>
<!---Date display--->

<table align="center" cellpadding="4" cellspacing="4" style="border-bottom:solid ##330099 1px;border-top:solid ##330099 1px;border-right:solid ##330099 1px;border-left:solid ##330099 1px;">
<tr>
	<td><strong>Order Date:</strong></td>

	<td><cfif isDate(InvoiceDetails.Order_Date)>#DateFormat(InvoiceDetails.Order_Date, 'MM/DD/YYYY')#<cfelse>--------</cfif></td>
	<td><strong>Invoice Date:</strong></td>
	<td><cfif isDate(InvoiceDetails.Invoice_Date)>#DateFormat(InvoiceDetails.Invoice_Date, 'MM/DD/YYYY')#<cfelse>--------</cfif></td>
	<td><strong>Ship Date:</strong></td>
	<td><cfif isDate(InvoiceDetails.Ship_Date)>#DateFormat(InvoiceDetails.Ship_Date, 'MM/DD/YYYY')#<cfelse>--------</cfif></td>
	<td><strong>Delivery Date:</strong></td>
	<td><cfif isDate(InvoiceDetails.Delivery_Date)>#DateFormat(InvoiceDetails.Delivery_Date, 'MM/DD/YYYY')#<cfelse>--------</cfif></td>
</tr>
</table>

<!---Actually show the invoice information--->

<table width="98%" cellpadding="3" cellspacing="0" border="0" align="Center"  CLASS="Maintable">
<tr>
	<td align="center" nowrap id="header"><strong>Line</strong></td>
	<td align="center" nowrap id="header"><strong>Item</strong></td>
	<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="center" nowrap id="header"><strong>UPC</strong></td></cfif></cfif>
	<td align="center" nowrap id="header"><strong>Product Description</strong></td>
	<cfif application.returned_customer_setting.invoice_order_Quantity IS 1>
	<td align="center" nowrap colspan="2" id="header"><strong>&nbsp; &nbsp; &nbsp; Order Quantity</strong></td>
	</cfif>
	<td align="center" nowrap colspan="2" id="header"><strong>&nbsp; &nbsp; &nbsp; Invoice Quantity</strong></td>
	<cfif genSettings.get().getForInvoicesDisplayOI() IS 1>
	<td nowrap id="header" align="right"><strong>List Price</strong></td>
	<td nowrap id="header" align="center"><strong>OI</strong></td>
	</cfif>
	<td nowrap id="header" align="center"><strong>Net Price</strong></td>
	<td nowrap id="header" align="center"><strong>Net Invoice $</strong></td>
</tr>

<!---Starts counters at 0--->
<cfset InvoiceTotal_Pounds = 0>
<cfset InvoiceTotal_Cases = 0>
<cfset OrderTotal_Pounds = 0>
<cfset OrderTotal_Cases = 0>
<cfset TotalSalesDollars = 0>
<cfif genSettings.get().getForInvoicesDisplayOI() IS 1>
	<cfif InvoiceDetails.Line_type eq 'S'>
	<tr>
	<td colspan="100%" align="center" style="border-bottom:solid navy 1px; font-size : 12px;"><strong><Font color="navy">Special Lines</FONT></strong></td>
	</tr>
	</cfif>
</cfif>
<cfloop query="InvoiceDetails">

<cfif len(trim(Pounds_Invoiced)) GT 0>
	<cfif NOT isnumeric(Pounds_Invoiced)>
		<cfset Pounds_Invoiced2 = 0>
	<cfelse>
		<cfset Pounds_Invoiced2 = Pounds_Invoiced>
	</cfif>
<cfelse>
	<cfset Pounds_Invoiced2 = 0>
</cfif>

<cfif len(trim(Cases_Invoiced)) GT 0>
	<cfif NOT isnumeric(Cases_Invoiced)>
		<cfset Cases_Invoiced2 = 0>
	<cfelse>
		<cfset Cases_Invoiced2 = Cases_Invoiced>
	</cfif>
<cfelse>
	<cfset Cases_Invoiced2 = 0>
</cfif>

<cfif len(trim(Pounds_Ordered)) GT 0>
	<cfif NOT isnumeric(Pounds_Ordered)>
		<cfset Pounds_Ordered2 = 0>
	<cfelse>
		<cfset Pounds_Ordered2 = Pounds_Ordered>
	</cfif>
<cfelse>
	<cfset Pounds_Ordered2 = 0>
</cfif>

<cfif len(trim(Pounds_Ordered)) GT 0>
	<cfif NOT isnumeric(Cases_Ordered)>
		<cfset Cases_Ordered2 = 0>
	<cfelse>
		<cfset Cases_Ordered2 = Cases_Ordered>
	</cfif>
<cfelse>
	<cfset Cases_Ordered2 = 0>
</cfif>

<cfif len(trim(Sales_Dollars)) GT 0>
	<cfif NOT isnumeric(Sales_Dollars)>
		<cfset Sales_Dollars2 = 0>
	<cfelse>
		<cfset Sales_Dollars2 = Sales_Dollars>
	</cfif>
<cfelse>
	<cfset Sales_Dollars2 = 0>
</cfif>

<!---Adds loop value to counters--->
<cfset InvoiceTotal_Pounds = InvoiceTotal_Pounds + Pounds_Invoiced2>
<cfset InvoiceTotal_Cases = InvoiceTotal_Cases + Cases_Invoiced2>
<cfset OrderTotal_Pounds = OrderTotal_Pounds + Pounds_Ordered2>
<cfset OrderTotal_Cases = OrderTotal_Cases + Cases_Ordered2>
<cfset TotalSalesDollars = TotalSalesDollars + Sales_Dollars2>

<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>  <cfif Print IS 0>ONMOUSEOVER="menuID=6;URLstring='';an_ID='#BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
	<td align="center" nowrap><cfif Invoice_Line_Number neq "">#Invoice_Line_Number#<cfelse>&nbsp;</cfif></td>
	<td align="center" nowrap>#Item#</td>
	<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="center" nowrap>#UPC#</td></cfif></cfif>
	<td align="left" nowrap>#Description#</td>
	<cfif application.returned_customer_setting.invoice_order_Quantity IS 1>
	<td nowrap align="right">#numberformat(Cases_Ordered, '___,___,___.__')# CS</td>
	<td nowrap align="right">#numberformat(Pounds_Ordered, '___,___,___.__')# LB</td>
	</cfif>
	<td nowrap align="right">#numberformat(Cases_Invoiced, '___,___,___.__')# CS</td>
	<td nowrap align="right">#numberformat(Pounds_Invoiced, '___,___,___.__')# LB</td>
	<cfif genSettings.get().getForInvoicesDisplayOI() IS 1>
	<!--- If Unit_List_Price is not null, show Unit_List_Price and Unit_Allowance --->
	<td nowrap align="right">
		<cfif Unit_List_Price neq 0>
				<!--- If It's Resers and the Unit_List_Price is less than Unit Price, show Unit price --->
				<cfif Unit_List_Price GTE Unit_Price>#lscurrencyformat(Unit_List_Price)#
					<cfelse>#lscurrencyformat(Unit_Price)#
				</cfif>
			<cfelse>
			&nbsp;
		</cfif>
	</td>
	<td nowrap align="center"><cfif Unit_List_Price neq 0><cfif Unit_List_Price GTE Unit_Price>#lscurrencyformat(Unit_Allowance)#<cfelse>&nbsp;</cfif><cfelse>&nbsp;</cfif></td>
	</cfif>
	<td nowrap align="center"><cfif Unit_Price neq 0>#lscurrencyformat(Unit_Price)# #Price_Unit_of_Measure#<cfelse>0.00</cfif></td>
	<td nowrap align="center"><cfif Sales_Dollars neq 0>#lscurrencyformat(Sales_Dollars)#<cfelse>0.00</cfif></td>
</tr>
</cfloop>
<tr>
	<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td  style="border-bottom:solid white 1px;" id="header" align="right">&nbsp;</td></cfif></cfif>
	<td colspan="3" style="border-bottom:solid white 1px;" id="header" align="right"> <strong>INVOICE TOTAL: </strong>&nbsp; </td>
<cfif application.returned_customer_setting.invoice_order_Quantity IS 1>
	<td nowrap style="border-bottom:solid white 1px;" id="header" align="right"><strong>#numberformat(OrderTotal_Cases, '___,___,___,___.__')# CS</strong></td>
	<td nowrap style="border-bottom:solid white 1px;" id="header" align="right"><strong>#numberformat(OrderTotal_Pounds, '___,___,___,___.__')# LB</strong></td>
</cfif>
	<td nowrap style="border-bottom:solid white 1px;" id="header" align="right"><strong>#numberformat(InvoiceTotal_Cases, '___,___,___,___.__')# CS</strong></td>
	<td nowrap style="border-bottom:solid white 1px;" id="header" align="right"><strong>#numberformat(InvoiceTotal_Pounds, '___,___,___,___.__')# LB</strong></td>
	<td style="border-bottom:solid white 1px;" >&nbsp; </td>
	<cfif genSettings.get().getForInvoicesDisplayOI() IS 1>
	<td style="border-bottom:solid white 1px;" >&nbsp; </td>
	<td style="border-bottom:solid white 1px;" >&nbsp; </td>
	</cfif>
	<td nowrap style="border-bottom:solid white 1px;" id="header" align="center"><strong>#lscurrencyformat(TotalSalesDollars)#</strong></td>
</tr>
</table>
<!--- display notes --->
<BR>
<table width="400" align="center">
  <!--DWLayoutTable-->
	<tr><td width="104" height="14" style="color:666666;font-size:10pt;"><strong>Notes</strong></td>
	  <td width="467"></td>
      <td width="2"></td>
	</tr>
	<tr>
		<td height="25" colspan="2" valign="top">
			<table cellpadding="2" cellspacing="2" style="border-bottom:solid ##330099 1px;border-top:solid ##330099 1px;border-right:solid ##330099 1px;border-left:solid ##330099 1px;">
			  <!--DWLayoutTable-->
				<tr>
				<td width="568" height="22" valign="middle">#InvoiceDetails.Notes#</td>
				</tr>
			</table>
		</td>
    <td>&nbsp;</td>
	</tr>
</table>
<p>&nbsp; </p>
<!---Print, email, fax--->
<cfif Print IS 0>
<table align="Center">
<tr>
<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"close"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Close this Window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
		<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('/search_screens/invoice/utilities/printer_friendly.cfm?Invoice_Header_ID=#Invoice_Header_ID#&Print=1','name','800','600','Yes', 'Yes')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Print this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>

	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='/search_screens/invoice/utilities/email_create.cfm?Invoice_Header_ID=#Invoice_Header_ID#&Print=1&Invoice_Number=#InvoiceDetails.Invoice_Number#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Email this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='/search_screens/invoice/utilities/fax_create.cfm?Invoice_Header_ID=#Invoice_Header_ID#&Print=1'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	  </td>
 --->
</tr>
</table>
</cfif>

&nbsp; <br>&nbsp; <p></p>
<table valign="bottom" width="100%" border="0" style="border-top:solid ##330099 2px;">
<tr><td width="100%" align="center">Contract management services provided by <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT> -- <a href="http://www.awayx.com">www.#application.CompanyOtherSuffix#</tr>
</table>
<!---End display--->
	</body>
	</html>
</cfoutput>

<!---THere were no details--->
<cfelse>
<p></p>
<div align="Center">
<strong>There are no details available for this invoice.</strong>
</div>
<p align="center">
&nbsp;

	<CF_button
			button_name		=	""
			button_caption	=	"close window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		></p>
</cfif>