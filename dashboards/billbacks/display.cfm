<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />

<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />

<!--- the style sheet used everywhere --------------------------------------------------------- --->
<link rel="stylesheet" type="text/css" href="_styles.css"/>

<title>blacksmith applications :: dashboards</title>
</head>


<body>

<!--- ----------------------------------------------------------------------------------------- --->
<CFPARAM NAME="content" DEFAULT='nodata.cfm'>
<CFPARAM NAME="page_name" DEFAULT=''>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the correct terms from the db for this customer and convert them to local variables - --->
<!--- ----------------------------------------------------------------------------------------- --->
	<cfinclude template="../terminology.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="bb_summary_data_content_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<cfswitch expression="#content#">

    <cfcase value="80237186">
		<cfset page_name="Total Invoices Processed">
		<cfset data_month=monthly.invoices_processed_count>
		<cfset data_quarter=quarterly.invoices_processed_count>
		<cfset data_year=yearly.invoices_processed_count>
	</cfcase>

    <cfcase value="13048838">
		<cfset page_name="Dollars processed: Total">
		<cfset data_month=monthly.dollars_processed_total/1000>
		<cfset data_quarter=quarterly.dollars_processed_total/1000>
		<cfset data_year=yearly.dollars_processed_total/1000>
	</cfcase>

    <cfcase value="63324230">
		<cfset page_name="Dollars processed:  Off Invoice">
		<cfset data_month=monthly.dollars_processed_off_invoice/1000>
		<cfset data_quarter=quarterly.dollars_processed_off_invoice/1000>
		<cfset data_year=yearly.dollars_processed_off_invoice/1000>
	</cfcase>

    <cfcase value="19392811">
		<cfset page_name="Dollars processed: Billback">
		<cfset data_month=monthly.dollars_processed_billback/1000>
		<cfset data_quarter=quarterly.dollars_processed_billback/1000>
		<cfset data_year=yearly.dollars_processed_billback/1000>
	</cfcase>

    <cfcase value="21426439">
		<cfset page_name="Dollars processed:  Average dollars per billback">
		<cfset data_month=monthly.dollars_processed_billback/1000>
		<cfset data_quarter=quarterly.dollars_processed_billback/1000>
		<cfset data_year=yearly.dollars_processed_billback/1000>
	</cfcase>

    <cfcase value="46718543">
		<cfset page_name="Discrepancy:  Invoices with disprepancy > 0">
		<cfset data_month=monthly.discrepancy_invoices>
		<cfset data_quarter=quarterly.discrepancy_invoices>
		<cfset data_year=yearly.discrepancy_invoices>
	</cfcase>

    <cfcase value="84084061">
		<cfset page_name="Total discrepancy dollars">
		<cfset data_month=monthly.discrepancy_total_dollars/1000>
		<cfset data_quarter=quarterly.discrepancy_total_dollars/1000>
		<cfset data_year=yearly.discrepancy_total_dollars/1000>
	</cfcase>

    <cfcase value="12441663">
		<cfset page_name="Discrepancy dollars as a percentage of total billback dollars">
		<cfset data_month=monthly.discrepancy_dollars_as_percent>
		<cfset data_quarter=quarterly.discrepancy_dollars_as_percent>
		<cfset data_year=yearly.discrepancy_dollars_as_percent>
	</cfcase>

    <cfcase value="11507173">
		<cfset page_name="Deduction days outstanding">
		<cfset data_month=monthly.deduction_days_outstanding>
		<cfset data_quarter=quarterly.deduction_days_outstanding>
		<cfset data_year=yearly.deduction_days_outstanding>
	</cfcase>

    <cfcase value="58244118">
		<cfset page_name="Cycle Time - Created to Paid">
		<cfset data_month=monthly.cycle_time_created_to_paid>
		<cfset data_quarter=quarterly.cycle_time_created_to_paid>
		<cfset data_year=yearly.cycle_time_created_to_paid>
	</cfcase>

    <cfcase value="29833828">
		<cfset page_name="Cycle Time - Performance End to Paid">
		<cfset data_month=monthly.cycle_time_end_to_paid>
		<cfset data_quarter=quarterly.cycle_time_end_to_paid>
		<cfset data_year=yearly.cycle_time_end_to_paid>
	</cfcase>

    <cfcase value="58986677">
		<cfset page_name="Payment Type - Check">
		<cfset data_month=monthly.payment_type_check>
		<cfset data_quarter=quarterly.payment_type_check>
		<cfset data_year=yearly.payment_type_check>
	</cfcase>

    <cfcase value="97220806">
		<cfset page_name="Payment Type - Deduction">
		<cfset data_month=monthly.payment_type_deduction>
		<cfset data_quarter=quarterly.payment_type_deduction>
		<cfset data_year=yearly.payment_type_deduction>
	</cfcase>

    <cfcase value="34309355">
		<cfset page_name="Payment Type - AT">
		<cfset data_month=monthly.payment_type_at>
		<cfset data_quarter=quarterly.payment_type_at>
		<cfset data_year=yearly.payment_type_at>
	</cfcase>

    <cfcase value="99833999">
		<cfset page_name="Entry Type - EDI">
		<cfset data_month=monthly.entry_type_edi>
		<cfset data_quarter=quarterly.entry_type_edi>
		<cfset data_year=yearly.entry_type_edi>
	</cfcase>

    <cfcase value="67481702">
		<cfset page_name="Entry Type - eInvoice">
		<cfset data_month=monthly.entry_type_einvoice>
		<cfset data_quarter=quarterly.entry_type_einvoice>
		<cfset data_year=yearly.entry_type_einvoice>
	</cfcase>

    <cfcase value="82909819">
		<cfset page_name="Entry Type - Manual">
		<cfset data_month=monthly.entry_type_manual>
		<cfset data_quarter=quarterly.entry_type_manual>
		<cfset data_year=yearly.entry_type_manual>
	</cfcase>

    <cfcase value="11726525">
		<cfset page_name="Average line items per invoice">
		<cfset data_month=monthly.avg_count_items_per_invoice>
		<cfset data_quarter=quarterly.avg_count_items_per_invoice>
		<cfset data_year=yearly.avg_count_items_per_invoice>
	</cfcase>

    <cfdefaultcase>
		<cfset page_name="select dashboard">
	</cfdefaultcase>

</cfswitch>


<!--- ----------------------------------------------------------------------------------------- --->
<cfset page_name="#page_name#">
<!--- ----------------------------------------------------------------------------------------- --->


<DIV align="center">

<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="header gradient_fix">
	<cfinclude template="_header.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container gradient_fix ">
<cfinclude template="display_detail.cfm">	
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer gradient_fix">
	<cfinclude template="_footer.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

</DIV>

</body>
</html>

