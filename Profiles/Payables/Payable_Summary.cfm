<cf_cryp type="de" string="#url.PID#"key="#request.key#">

<cfquery name="getPayableInfo" datasource="#application.datasource#">
SELECT     dbo.Payables.Billback_Num, dbo.Payables.Billback_Amt, dbo.Payables.From_Date, dbo.Payables.To_Date, dbo.Payables.Billback_Date, 
                      dbo.Payables.Paid_Amt, dbo.Payables.Paid_Date, dbo.Contract_Main.Contract_Number, dbo.Contract_Main.Contract_Main_ID, 
                      dbo.Contract_Main.Contract_Title, dbo.Contract_Main.Contract_Quantity_UOM_IDX, dbo.Payables.Payable_Reference_Number, 
                      dbo.BSA_Foodservice_Customers.Ship_To, dbo.BSA_Foodservice_Customers.Name, dbo.BSA_Foodservice_Customers.Address_1, 
                      dbo.BSA_Foodservice_Customers.City, dbo.BSA_Foodservice_Customers.State, dbo.BSA_Foodservice_Customers.ZipCode, 
                      dbo.Payables.Approved_Date, dbo.Payables.Payment_Reference_Number, dbo.BSA_Foodservice_Brokers.Broker_Name
FROM         dbo.Payables INNER JOIN
                      dbo.Contract_Main ON dbo.Payables.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.Payables.Distributor_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON dbo.BSA_Foodservice_Customers.Std_Broker = dbo.BSA_Foodservice_Brokers.Broker_Legcy_Shard
	WHERE dbo.Payables.Payable_ID = '#cryp.value#'
</cfquery>


<cfset useLakebaseForgetProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payable_products")>
<cfif useLakebaseForgetProducts>
	<cftry>
		<cfset getProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payable_products", {
				"payable_id" = "eq.#cryp.value#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProducts>
<cfquery name="getProducts" datasource="#application.datasource#">
	SELECT *
	FROM Payable_Products
	WHERE Payable_ID = '#cryp.value#'
	AND Deleted = 0
</cfquery>
</cfif>

<cfset adjustedmentTotal = getPayableInfo.Billback_Amt>
<cfset approvedAmount = 0>

<cfloop query="getProducts">
	<cfif isnumeric(getProducts.billback_amount) AND len(getProducts.billback_amount) GT 0>

		<CFSWITCH expression="#trim(getProducts.Product_Type)#">
			<!--- unknown product  --->
			<CFCASE value="3">
				<CFSWITCH expression="#approved#">
					<CFCASE value="0">
					
					</CFCASE>
					<!--- bb rate --->
					<CFCASE value="1">
						<cfset approvedAmount = approvedAmount + getProducts.billback_amount>
					</CFCASE>
					<!--- exp rate --->
					<CFCASE value="2">
					</CFCASE>
					<!--- no pay --->
					<CFCASE value="3">
					
					</CFCASE>
				</CFSWITCH>
			</CFCASE>
			<!--- known products ((un)authorized) --->
			<cfdefaultcase>
				<CFSWITCH expression="#approved#">
					<CFCASE value="0">
					
					</CFCASE>
					<!--- bb rate --->
					<CFCASE value="1">
						<cfset approvedAmount = approvedAmount + getProducts.billback_amount>
					</CFCASE>
					<!--- exp rate --->
					<CFCASE value="2">
						<CFSET erate_contract_main_id=getPayableInfo.Contract_Main_ID>
						<CFSET erate_product_upc=getProducts.product_upc>
						<CFSET erate_contract_UOM_IDX =getPayableInfo.Contract_Quantity_UOM_IDX>
						<CFSET erate_payable_id =cryp.value>
						<cfset erate_productQuantity = getProducts.Quantity_Shipped>
						<cfset erate_productUOM = getProducts.Unit_Of_Measure>
					
						<CFSET erate_showProcess ="0">

						<cfinclude template="/common_files/payables2/e-rate.cfm">
						
						<!--- <cfset approvedAmount = approvedAmount + erate.displayRate> --->
					</CFCASE>
					<!--- no pay --->
					<CFCASE value="3">
					
					</CFCASE>
				</CFSWITCH>
			</cfdefaultcase>
		</CFSWITCH>
	</cfif>
</cfloop>
<cfset adjustedmentTotal = adjustedmentTotal-approvedAmount>
<cfset approvedBillbackAmount = getPayableInfo.Billback_Amt - adjustedmentTotal>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>Payable</B></FONT></TD>
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
    <TD align="right" nowrap valign="top"><B>Payable Number:</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Billback_Num#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Ship_To#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.distributor_label_singular#:</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Name#<br>#getPayableInfo.City#,&nbsp;#getPayableInfo.State#  #getPayableInfo.ZipCode#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Broker:</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Broker_Name#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Contract ##:</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Contract_Number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Title:</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Contract_Title#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Billback ##:</B></TD>
    <TD width="100%" valign="top">#getPayableInfo.Payable_Reference_Number#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Billback Date:</B></TD>
    <TD width="100%" valign="top">#dateformat(getPayableInfo.Billback_Date, 'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Delivery Period:</B></TD>
    <TD width="100%" valign="top">#dateformat(getPayableInfo.From_Date, 'mm/dd/yyyy')# - #dateformat(getPayableInfo.To_Date, 'mm/dd/yyyy')#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Billback Amount:</B></TD>
    <TD width="100%" valign="top"><CFIF len(getPayableInfo.Billback_Amt) GT 0>$#trim(numberformat(getPayableInfo.Billback_Amt,'______________.__'))#<CFELSE>Not Entered Yet</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Adjustments:</B></TD>
    <TD width="100%" valign="top">$#trim(numberformat(adjustedmentTotal, '_______________.__'))#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Approved:</B></TD>
    <TD width="100%" valign="top">$#trim(numberformat(approvedBillbackAmount, '_______________.__'))#</TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Amount Paid:</B></TD>
    <TD width="100%" valign="top"><CFIF len(getPayableInfo.Paid_Amt) GT 0>$#trim(numberformat(getPayableInfo.Paid_Amt,'______________.__'))#<CFELSE>Not Paid Yet</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Payment Date:</B></TD>
    <TD width="100%" valign="top"><CFIF len(getPayableInfo.Paid_Date) GT 0>#dateformat(getPayableInfo.Paid_Date, 'mm/dd/yyyy')#<CFELSE>Not Paid Yet</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Payment Reference:</B></TD>
    <TD width="100%" valign="top"><CFIF len(getPayableInfo.Payment_Reference_Number) GT 0>#getPayableInfo.Payment_Reference_Number#<CFELSE>Not Paid Yet</CFIF></TD>
  </TR>

</TABLE>

</cfoutput>
</body>
</html>
