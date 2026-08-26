<cfquery name="GetDist" datasource="#application.datasource#">
	SELECT Ship_To, Name
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID = '#Form.Distributor_List#' 
</cfquery>

<cfquery name="GetProd" datasource="#application.datasource#">
	SELECT Item, UPC, Description
	FROM BSA_Foodservice_Items_Master
	WHERE BSA_Foodservice_Items_Master_ID = '#Form.EXISTINGPRODUCTLIST#' 
</cfquery>

<cfquery name="getInvoiceData" datasource="#application.datasource#">
SELECT     dbo.Invoice_Detail.Invoice_Date, dbo.Invoice_Detail.Pounds_Invoiced, dbo.Invoice_Detail.Cases_Invoiced, dbo.Invoice_Detail.LB_Unit_Price, 
                      dbo.Invoice_Detail.CS_Unit_Price, dbo.Invoice_Header.Invoice_Version, dbo.Invoice_Header.Order_Number
FROM         dbo.Invoice_Detail INNER JOIN
                      dbo.Invoice_Header ON dbo.Invoice_Detail.Invoice_Header_ID = dbo.Invoice_Header.Invoice_Header_ID
WHERE     (dbo.Invoice_Detail.BSA_Foodservice_Items_Master_ID = '#FORM.ExistingProductList#') AND (dbo.Invoice_Header.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#') AND 
                      (dbo.Invoice_Detail.Deleted = 0) AND (dbo.Invoice_Header.Deleted = 0)
						AND (Invoice_Header.Order_Status = 'I')
ORDER BY dbo.Invoice_Detail.Invoice_Date
</cfquery>

<cfset RC = 1>
<CFSET Cases_Invoiced_Total 	= 0>
<CFSET CS_UNIT_PRICE_Total 		= 0>
<CFSET LB_UNIT_PRICE_Total 		= 0>
<CFSET POUNDS_INVOICED_Total	= 0>
<CFSET INVOICE_DATE_Total 		= 0>

<cfoutput>
<table>
	<TR>
		<TD style="font-weight:bold; font-size: 15px;"><b>Product</b></TD>
		<TD>:</TD>
		<TD style="font-size: 15px;">#GetProd.Description# - #GetProd.Item# - #GetProd.UPC#</TD>
	</TR>
	<TR>
		<TD style="font-weight:bold; font-size: 15px;"><b>#application.returned_customer_setting.distributor_label_singular#</b></TD>
		<td>:</td>
		<TD style="font-size: 15px;">#GetDist.Name# (#GetDist.Ship_To#)</TD>
	</TR>
</table>
<hr width="450" align="left">
</cfoutput>

<table width="450" border="0" cellspacing="0" cellpadding="2">
	<TR>
		<TD>&nbsp;</TD>
		<TD style="font-weight:bold;" align="right">Invoice Date</TD>
		<TD style="font-weight:bold;" align="right">LB Invoiced</TD>
		<TD style="font-weight:bold;" align="right">CS Invoiced</TD>
		<TD style="font-weight:bold;" align="right">LB Unit Price</TD>
		<TD style="font-weight:bold;" align="right">CS Unit Price</TD>
	</TR>
<cfloop query="getInvoiceData">

	<cfset temp = QuerySetCell(getInvoiceData, "Cases_Invoiced", trim(numberformat(getInvoiceData.Cases_Invoiced, '_-______________________.__')), RC)>
	<cfset temp = QuerySetCell(getInvoiceData, "CS_UNIT_PRICE", trim(numberformat(getInvoiceData.CS_UNIT_PRICE, '_-______________________.____')), RC)>
	<cfset temp = QuerySetCell(getInvoiceData, "LB_UNIT_PRICE", trim(numberformat(getInvoiceData.LB_UNIT_PRICE, '_-______________________.____')), RC)>
	<cfset temp = QuerySetCell(getInvoiceData, "POUNDS_INVOICED", trim(numberformat(getInvoiceData.POUNDS_INVOICED, '_-______________________.__')), RC)>
	<cfset temp = QuerySetCell(getInvoiceData, "INVOICE_DATE", dateformat(getInvoiceData.INVOICE_DATE, 'mm/dd/yyyy'), RC)>

	<cfset RC = RC + 1>
	<cfoutput>
	<TR <CFIF RC mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD bgcolor="white">&nbsp;</TD>
		<TD align="right">#INVOICE_DATE#</TD>
		<TD align="right">#POUNDS_INVOICED#</TD>
		<TD align="right">#Cases_Invoiced#</TD>
		<TD align="right">#LB_UNIT_PRICE#</TD>
		<TD align="right">#CS_UNIT_PRICE#</TD>
	</TR>
	</cfoutput>
	
	
	<CFSET Cases_Invoiced_Total 	= Cases_Invoiced_Total	+getInvoiceData.Cases_Invoiced>
	<CFSET CS_UNIT_PRICE_Total 		= CS_UNIT_PRICE_Total	+getInvoiceData.CS_UNIT_PRICE>
	<CFSET LB_UNIT_PRICE_Total 		= LB_UNIT_PRICE_Total	+getInvoiceData.LB_UNIT_PRICE>
	<CFSET POUNDS_INVOICED_Total	= POUNDS_INVOICED_Total	+getInvoiceData.POUNDS_INVOICED>
	
</cfloop>

<TR>
	<TD align="left"><b>Totals:</b>&nbsp;&nbsp;&nbsp;</TD>
	<TD colspan="99%"><hr color="black"></TD>
</TR>
<cfoutput>
<TR>
	<TD>&nbsp;</TD>
	<TD></TD>
	<TD align="right">#trim(numberformat(POUNDS_INVOICED_Total, '_-______________________.__'))#</TD>
	<TD align="right">#trim(numberformat(Cases_Invoiced_Total, '_-______________________.__'))#</TD>
	<TD align="right">#trim(numberformat(LB_UNIT_PRICE_Total, '_-______________________.____'))#</TD>
	<TD  align="right">#trim(numberformat(CS_UNIT_PRICE_Total, '_-______________________.____'))#</TD>	
</TR>
</cfoutput>
</table>

<cfset filename = "#createuuid()##createuuid()#.csv">
<CFSET Columns =  getInvoiceData.Columnlist>
<cffile action="WRITE" file="C:\inetpub\wwwroot\AwayX\Common_Files\contracts\contract_documents\#filename#" output="#Columns#" addnewline="Yes">

<CFSET Columns_2 = "">

<cfloop index="x" list="#Columns#" delimiters=",">
	<CFSET Columns_2 = listappend(Columns_2, "getInvoiceData.#x#")>
</cfloop>

<CFSET Columns_2 = listqualify(Columns_2, "##",",", "ALL")>
<cfloop query="getInvoiceData"> 
  <cffile action="APPEND" file="C:\inetpub\wwwroot\AwayX\Common_Files\contracts\contract_documents\#filename#" 
  output="#evaluate(DE(Columns_2))#" 
  addnewline="Yes"> 
</cfloop> 

<cffile action="READ" file="C:\inetpub\wwwroot\AwayX\Common_Files\contracts\contract_documents\#filename#" variable="abcd">

<BR><BR>
<a style="color: blue; cursor:pointer;" onclick="javascript:window.print()">Print</a>
&nbsp;
|
&nbsp;
<cfoutput><a href="http://web24.awayx.com\Common_Files\contracts\contract_documents\#filename#" id="thafile">Save as Excel File</a></cfoutput>
&nbsp;
|
&nbsp;
<a href="index_1.cfm">Search Again</a>

