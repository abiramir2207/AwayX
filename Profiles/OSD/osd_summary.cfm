<cf_cryp type="de" string="#url.OID#"key="#request.key#">
<cfquery name="getOSD" datasource="#application.datasource#">
SELECT     dbo.OSD_Log.order_date, dbo.OSD_Log.ship_date, dbo.OSD_Log.request_number, dbo.OSD_Log.request_date, dbo.OSD_Log.invoice_number, 
                      dbo.OSD_Log.Customer_Number, dbo.OSD_Log.dollar_amount_authorized, dbo.OSD_Log.authorization_date, dbo.OSD_Log.authorization_number, 
                      dbo.Invoices.invoice_date, dbo.Invoices.invoice_total_dollars, dbo.Invoices.invoice_number AS Expr1, 
                      dbo.Invoices.order_date AS Invoice_Order_Date, dbo.OSD_Log.warehouse, dbo.BSA_Foodservice_Customers.Name, 
                      dbo.BSA_Foodservice_Customers.Address_1, dbo.BSA_Foodservice_Customers.City, dbo.BSA_Foodservice_Customers.State, 
                      dbo.BSA_Foodservice_Customers.ZipCode, dbo.OSD_Log.request_type, dbo.OSD_Types_And_Codes.OSD_type, 
                      dbo.OSD_Log.dollar_amount_requested, dbo.BSA_Foodservice_Customers.Ship_To, dbo.OSD_Warehouse_Detail.warehouse_name, 
                      dbo.BSA_Foodservice_Brokers.Region_Legcy_Shard, dbo.BSA_Foodservice_Brokers.Region_Shard, 
                      dbo.BSA_Foodservice_Brokers.Broker_Name
FROM         dbo.OSD_Log INNER JOIN
                      dbo.Invoices ON dbo.OSD_Log.invoice_number = dbo.Invoices.invoice_number INNER JOIN
                      dbo.BSA_Foodservice_Customers ON dbo.OSD_Log.distributor_ship_to = dbo.BSA_Foodservice_Customers.Ship_To INNER JOIN
                      dbo.OSD_Types_And_Codes ON dbo.OSD_Log.request_type = dbo.OSD_Types_And_Codes.OSD_code INNER JOIN
                      dbo.OSD_Warehouse_Detail ON dbo.OSD_Log.warehouse = dbo.OSD_Warehouse_Detail.warehouse_id INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON dbo.BSA_Foodservice_Customers.Std_Broker = dbo.BSA_Foodservice_Brokers.Broker_Legcy_Shard
WHERE  dbo.OSD_log.OSD_LOG_ID = '#cryp.value#'
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>OS&D Claim</B></FONT></TD>
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
    <TD align="right" nowrap valign="top"><B>OS&D Request ##:</B></TD>
    <TD width="100%" valign="top">#getOSD.request_number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Request Type:</B></TD>
    <TD width="100%" valign="top">#getOSD.osd_type#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Amount Requested:</B></TD>
    <TD width="100%" valign="top">$#trim(numberformat(getOSD.dollar_amount_requested,'________.__'))#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Request Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getOSD.request_date, 'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Authorization ##:</B></TD>
    <TD width="100%" valign="top">#getosd.authorization_number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Amount Authorized:</B></TD>
    <TD width="100%" valign="top">$#trim(numberformat(getosd.dollar_amount_authorized,'________.__'))#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Authorization Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getOSD.authorization_date, 'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.shard_ship_to_label#:</B></TD>
    <TD width="100%" valign="top">#getOSD.ship_to#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.distributor_label_singular#:</B></TD>
    <TD width="100%" valign="top">#getOSD.Name#<br>#getOSD.City#, #getOSD.State#&nbsp;#getOSD.ZipCode#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Invoice Number:</B></TD>
    <TD width="100%" valign="top">#getOSD.invoice_number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Invoice Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getOSD.invoice_date,'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Invoice Amount:</B></TD>
    <TD width="100%" valign="top">$#trim(numberformat(getosd.invoice_total_dollars,'________.__'))#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Order Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getOSD.Invoice_Order_Date,'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Customer Order ##:</B></TD>
    <TD width="100%" valign="top">#getosd.Customer_number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Ship Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getOSD.ship_date,'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Warehouse:</B></TD>
    <TD width="100%" valign="top">#getosd.warehouse_name#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Broker:</B></TD>
    <TD width="100%" valign="top">#getosd.broker_name#</TD>
  </TR>
<!--- 
  <cfquery name="getSalesRep" datasource="#application.datasource#">
	SELECT     dbo.Sales_Reps.sales_rep_first_name, dbo.Sales_Reps.sales_rep_last_name, dbo.Sales_Reps.sales_rep_title, 
	                      dbo.Sales_Rep_Market_Assignments.region_shared_number, dbo.Sales_Rep_Market_Assignments.market_area_name
	FROM         dbo.Sales_Rep_Market_Assignments INNER JOIN
	                      dbo.Sales_Reps ON dbo.Sales_Rep_Market_Assignments.sales_rep_id_code = dbo.Sales_Reps.sales_rep_ID_code
	WHERE     (dbo.Sales_Rep_Market_Assignments.region_shared_number = '#getOSD.region_legcy_shard#')
  </cfquery>
  
  <TR>
    <TD align="right" nowrap valign="top"><B>Sales Rep:</B></TD>
    <TD width="100%" valign="top"><CFIF getSalesRep.recordcount EQ 0>No Sales Rep. On Record<cfelse>#getSalesRep.sales_rep_first_name# #getSalesRep.sales_rep_last_name#</CFIF></TD>
  </TR>
 --->
</TABLE>

</cfoutput>

</body>
</html>
