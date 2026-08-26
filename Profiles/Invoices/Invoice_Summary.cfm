<cf_cryp type="de" string="#url.IID#"key="#request.key#">

<cfquery name="getInvoice" datasource="#application.datasource#">
SELECT     dbo.Invoices.order_date, dbo.Invoices.invoice_date, dbo.Invoices.customer_number, dbo.Invoices.invoice_number, dbo.Invoices.invoice_total_dollars, 
                      dbo.Invoices.invoice_total_pounds, dbo.BSA_Foodservice_Customers.Name, dbo.BSA_Foodservice_Customers.Ship_To, 
                      dbo.BSA_Foodservice_Customers.Address_1, dbo.BSA_Foodservice_Customers.City, dbo.BSA_Foodservice_Customers.State, 
                      dbo.BSA_Foodservice_Customers.ZipCode, dbo.BSA_Foodservice_Brokers.Broker_Name, 
                      dbo.Sales_Rep_Market_Assignments.market_area_name, dbo.Sales_Reps.sales_rep_first_name, dbo.Sales_Reps.sales_rep_last_name, 
                      dbo.Sales_Reps.sales_rep_title
FROM         dbo.Invoices INNER JOIN
                      dbo.BSA_Foodservice_Customers ON dbo.Invoices.distributor_ship_to = dbo.BSA_Foodservice_Customers.Ship_To INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.BSA_Foodservice_Customers.Std_Broker = dbo.BSA_Foodservice_Brokers.Broker_Legcy_Shard INNER JOIN
                      dbo.Sales_Rep_Market_Assignments ON 
                      dbo.BSA_Foodservice_Brokers.Region_Shard = dbo.Sales_Rep_Market_Assignments.region_shared_number INNER JOIN
                      dbo.Sales_Reps ON dbo.Sales_Rep_Market_Assignments.sales_rep_id_code = dbo.Sales_Reps.sales_rep_ID_code
WHERE dbo.Invoices.Invoices_ID = '#cryp.value#'
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>Invoice</B></FONT></TD>
</TR>
</TABLE>

<BR>

<cfoutput>

<TABLE border="0" cellpadding="0" cellspacing="5" WIDTH="350" ALIGN="center">
  <TR>
    <TD colspan="2" nowrap valign="top">
      <DIV class="title2">
        Summary
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Invoice Number:</B></TD>
    <TD width="100%" valign="top">#getInvoice.invoice_number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Customer ##:</B></TD>
    <TD width="100%" valign="top">#getInvoice.customer_number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.shard_ship_to_label#:</B></TD>
    <TD width="100%" valign="top">#getInvoice.ship_to#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Sold To:</B></TD>
    <TD width="100%" valign="top">#getInvoice.Name#<br>#getInvoice.City#&nbsp;#getInvoice.State#&nbsp;#getInvoice.ZipCode#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Date Ordered:</B></TD>
    <TD width="100%" valign="top">#dateformat(getInvoice.order_date, 'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Invoice Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getInvoice.invoice_date, 'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Invoice Amount:</B></TD>
    <TD width="100%" valign="top">$#trim(numberformat(getInvoice.invoice_total_dollars, '_____________.__'))#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Total Weight:</B></TD>
    <TD width="100%" valign="top">#getInvoice.invoice_total_pounds# lbs</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Broker:</B></TD>
    <TD width="100%" valign="top">#getInvoice.Broker_name#</TD>
  </TR>
<!--- 
  <TR>
    <TD align="right" nowrap valign="top"><B>Sales Rep:</B></TD>
    <TD width="100%" valign="top">#getInvoice.sales_rep_first_name# #getInvoice.sales_rep_last_name# (#getInvoice.sales_rep_title#)</TD>
  </TR>
 --->
</TABLE>

</cfoutput>
</body>
</html>
