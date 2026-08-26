<cfparam name="url.table" default="" >
<cfparam name="url.Search" default="">
<cfparam name="url.start"  default="1">
<cfparam name="perpage" default="50">
<cfparam name="url.orderby" default="">
<cfparam name="url.ordertype" default="">
<cfparam name ="url.AM_or_PM"  default="">
<!---<cfdump var="#application.returned_customer_setting#"/> --->
	
	<!--- Get the log table for "invoice header" --->
	<cfset useLakebaseForGetInvoiceLogHeaderTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_upload")>
	<cfif useLakebaseForGetInvoiceLogHeaderTable>
		<cftry>
			<cfset getInvoiceLogHeaderTable = application.oLakebase.toQuery(
				application.oLakebase.selectRows("data_integration_upload", { "intra_id" = "eq.600", "select" = "log_tablename", "limit" = "1" })
			, "Log_TableName")>
			<cfcatch type="any">
				<cfset useLakebaseForGetInvoiceLogHeaderTable = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetInvoiceLogHeaderTable>
		<cfquery name="getInvoiceLogHeaderTable" datasource="#application.datasource#">
			SELECT TOP 1 Log_TableName
			FROM Data_Integration_Upload
			WHERE Intra_ID = '600'
		</cfquery>
	</cfif>

	<!--- Get the log table for "invoice detail" --->
	<cfset useLakebaseForGetInvoiceLogDetailTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_upload")>
	<cfif useLakebaseForGetInvoiceLogDetailTable>
		<cftry>
			<cfset getInvoiceLogDetailTable = application.oLakebase.toQuery(
				application.oLakebase.selectRows("data_integration_upload", { "intra_id" = "eq.610", "select" = "log_tablename", "limit" = "1" })
			, "Log_TableName")>
			<cfcatch type="any">
				<cfset useLakebaseForGetInvoiceLogDetailTable = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetInvoiceLogDetailTable>
		<cfquery name="getInvoiceLogDetailTable" datasource="#application.datasource#">
			SELECT TOP 1 Log_TableName
			FROM Data_Integration_Upload
			WHERE Intra_ID = '610'
		</cfquery>
	</cfif>

	<cfset Log_CF_Header_Table = getInvoiceLogHeaderTable.Log_TableName>
	<cfset Log_CF_Detail_Table = getInvoiceLogDetailTable.Log_TableName>
	
	<!--- For some clients, we only have one log table. They do not have separate tables for header and detail. 
	In that case, the detail table is the same as header table.	
	--->
	<cfif getInvoiceLogDetailTable.recordCount eq 0>
		<cfset Log_CF_Detail_Table = Log_CF_Header_Table>
	</cfif>
	
	<!--- We do not know what the column name might be and so we are checking from  a list of the usual column names --->
	<cfquery name="getInvoiceLogDistributorColumn" datasource="#application.datasource#">
		SELECT Column_Name FROM INFORMATION_SCHEMA.columns
		WHERE Table_Name = '#Log_CF_Header_Table#'
		AND Column_Name IN ('Customer_Number','ship_to','shipto','shr_ship_to','shr_shipto','customer_id')
	</cfquery>

	<cfset Log_Distributor_Column = getInvoiceLogDistributorColumn.Column_Name>

	<!--- We do not know what the column name might be and so we are checking from  a list of the usual column names --->
	<cfquery name="getInvoiceLogItemColumn" datasource="#application.datasource#">
		SELECT Column_Name FROM INFORMATION_SCHEMA.columns
		WHERE Table_Name = 'log_cf_Invoice'
		AND Column_Name in('item_number','item','item_id','material')
	</cfquery>

	<cfset Log_Item_Column = getInvoiceLogItemColumn.Column_Name>

<cfoutput>
<table>
				<tr>
						<td style="font-size:14px;">
								<font color="red" weight="bold">[</font>
										<a href="#ajaxLink('#cgi.script_name#?table=log_cf_invoice_header&datetime=#url.datetime#&AM_or_PM=#AM_or_PM#&orderby=#Log_Distributor_Column#&ordertype=desc')#">#application.returned_customer_setting.distributor_label_singular# Number </a>
								<font color="red" weight="bold">]</font>
						</td>
						<td style="font-size:14px;">
								<font color="red" weight="bold">[</font>
										<a href="#ajaxLink('#cgi.script_name#?table=log_cf_invoice_detail&datetime=#url.datetime#&AM_or_PM=#AM_or_PM#&orderby=#Log_Item_Column#&ordertype=desc')#">#application.returned_customer_setting.item_label#</a>
								<font color="red" weight="bold">]</font>
						</td>
				</tr>
</table>
</cfoutput>
<cfif len(url.table)>

	<cfset enddate = DateAdd("N", 6, url.datetime)>
	<cfset enddate = #dateFormat(enddate,"yyyy-mm-dd")# &' '&#TimeFormat(enddate, "HH:mm:ss")#>
	<cfset startdate = DateAdd("N", -1, url.datetime)>
	<cfset startdate = #dateFormat(startdate,"yyyy-mm-dd")# &' '&#TimeFormat(startdate, "HH:mm:ss")#>
	
	<!--- Normally clients run the 600 process nightly and so the create_date in the db will have "AM". For some clients, that might not be the case as they
	might run the process during the day as well and so we need to pass "AM" or "PM" to the query to get the appropriate records.
	--->
	<cfif url.AM_or_PM neq "">
		<cfset startdate = startdate & ' '  & url.AM_or_PM> 
		<cfset enddate = enddate & ' '  & url.AM_or_PM>
	</cfif> 

<cfoutput>	
		<cfif url.table EQ 'log_cf_invoice_header' >
							<cfquery name="details" datasource="#application.datasource#">
									SELECT DISTINCT LOGS.#Log_Distributor_Column# AS #Log_Distributor_Column#, isnull(BSA.Name,'N/A') AS Name, LOGS.Err_Message
									FROM #Log_CF_Header_Table# LOGS
									LEFT JOIN BSA_Foodservice_Customers BSA
									ON BSA.Ship_To = LOGS.#Log_Distributor_Column#
									WHERE LOGS.Created_Date BETWEEN '#startdate#' AND '#enddate#'
									<cfif len(url.Search)>
									AND (#Log_Distributor_Column# LIKE '%#trim(url.Search)#%' OR BSA.Name LIKE '%#trim(url.Search)#%' OR Err_Message LIKE '%#trim(url.Search)#%' )
									</cfif>
									<cfif len(url.orderby) AND len(url.ordertype)>
									ORDER BY  #url.orderby# #url.ordertype#
									</cfif>
						</cfquery>	
							<cfset columnslist ="#application.returned_customer_setting.distributor_label_singular# Number, #application.returned_customer_setting.distributor_label_singular# Name, Error Message,View">
							<cfset columnsvalue ="#Log_Distributor_Column#, Name, Err_Message,View">
							<cfset dispaycolumns = "#Log_Distributor_Column#,Name,Err_Message,View">

				<cfelseif url.table EQ 'log_cf_invoice_detail'>
							<cfquery name="details" datasource="#application.datasource#">
									SELECT DISTINCT LOGS.#Log_Item_Column# AS #Log_Item_Column#, ISNULL(BSA.Description,'N/A') AS Description, LOGS.Err_Message 
									FROM #Log_CF_Detail_Table# LOGS
									LEFT JOIN BSA_Foodservice_Items_Master BSA
									ON BSA.Item = LOGS.#Log_Item_Column#
									WHERE LOGS.Created_Date BETWEEN '#startdate#' AND '#enddate#'
									<cfif len(url.Search)>
									AND (#Log_Item_Column# LIKE '%#trim(url.Search)#%' OR BSA.Name LIKE '%#trim(url.Search)#%' OR Err_Message LIKE '%#trim(url.Search)#%' )
									</cfif>
									AND LOGS.Err_Message != 'The Invoice Header Data does not Exist'
									<cfif len(url.orderby) AND len(url.ordertype)>
									ORDER BY  #url.orderby# #url.ordertype#
									</cfif>
						</cfquery>			
							<cfset columnslist ="#application.returned_customer_setting.item_label#, Description, Error Message,View">
							<cfset columnsvalue ="#Log_Item_Column#, Description, Err_Message,View">
							<cfset dispaycolumns = "#Log_Item_Column#,Description,Err_Message,View">

		</cfif>


<!---<cfdump var="#details#">--->

	<div style="width:800px; background-color:white;position:fixed;">
	<table border="0">
		<tr>
			<td width="25">
				<cfif url.start gt 1>
					<a href="#ajaxLink('#cgi.script_name#?table=#url.table#&start=#url.start-perpage#&Search=#url.Search#&datetime=#url.datetime#&orderby=#url.orderby#&ordertype=#url.ordertype#')#" onclick="loading();"><img src="/images/previous.png" border="0"></a>
				<cfelse>
					<img src="/images/previous_inactive.png" border="0">
				</cfif>
			</td>
			<td align="left">
				<cfif (url.start+perpage-1) lt details.recordcount>
					<a href="#ajaxLink('#cgi.script_name#?table=#url.table#&start=#url.start+perpage#&Search=#url.Search#&datetime=#url.datetime#&orderby=#url.orderby#&ordertype=#url.ordertype#')#" onclick="loading();"><img src="/images/next.png" border="0"></a>
				<cfelse>
					<img src="/images/next_inactive.png" border="0">
				</cfif>
			</td>
		</tr>
	</table>
	<table border="0">
		<tr>
			<td colspan="100" style="font-size:12px;color:green;">
				<cfset to = (#url.start#+#perpage#) - 1>
				Showing #url.start# to <cfif details.recordcount GT 50 AND to LT details.recordcount > #to#<cfelse>#details.recordcount#</cfif> of #details.recordcount# entries.
			</td>
		</tr>
	</table>
	</div>
</cfoutput>
<style>
	.header{
		border:solid;
		border-width:1px;
		border-color:white;
		height:20px;
		font-size:12px;
		font-weight:bold;
		width:195px;
		text-align:center;
		background-color:#A5BAFF;
		}
	.data{
		height:20px;
		font-size:12px;
		width:195px;
		text-align:center;
		}
</style>
<div style="width:800px;clear:both;height:45px;">&nbsp;</div>
<cfoutput>
<table style="width: 800px" cellpadding="0" cellspacing="0">
		<tr>
			<cfset i = 0>
			<cfloop list="#columnslist#" index="columnname">
			<cfset i = i + 1>		
					<td class="header">
						<div style="width:88%;float:left;text-align:center;">#columnname#</div>
						<cfif columnname NEQ 'View'>
								<div style="width:5%;float:right;text-align:center;">								
										<cfif (url.orderby EQ #listgetat(columnsvalue, i)#) AND (url.ordertype EQ 'asc')>
												<img src="/images/asc_inactive.png" border="0">
										<cfelse>
												<a href="#ajaxLink('#cgi.script_name#?table=#url.table#&start=#url.start#&Search=#url.Search#&orderby=#listgetat(columnsvalue, i)#&ordertype=asc&datetime=#url.datetime#')#" onclick="loading();"><img src="/images/asc.png" border="0"></a>	
										</cfif>
								</div>													
								<div style="width:5%;float:right;text-align:center;">								
										<cfif (url.orderby EQ #listgetat(columnsvalue, i)#) AND (url.ordertype EQ 'desc')>
												<img src="/images/desc_inactive.png" border="0">
										<cfelse>
												<a href="#ajaxLink('#cgi.script_name#?table=#url.table#&start=#url.start#&Search=#url.Search#&orderby=#listgetat(columnsvalue, i)#&ordertype=desc&datetime=#url.datetime#')#" onclick="loading();"><img src="/images/desc.png" border="0"></a>
										</cfif>
								</div>
						</cfif>
					</td>
			</cfloop>
		</tr> 
</table>
</cfoutput>

<div style="overflow-y: scroll;height: 500px; width: 820px;">
  <table style="width: 800px;" cellpadding="0" cellspacing="0">
  	<cfif details.recordcount>
	  		<cfoutput query="details" startrow="#url.start#" maxrows="#min(50, details.recordcount)#">
  <tr>
	    			<cfloop from="1" to="4" index="i">
						<cfif listgetat(dispaycolumns, i) NEQ 'View'>
	    					<td class="data">#Evaluate("details.#listgetat(dispaycolumns, i)#")#</td>
						<cfelse>
							<td class="data">
										<cfif url.table EQ 'log_cf_invoice_header' >
												<a href="javascript:(void);" 
												onClick="javascript:window.open('view.cfm?CustomerNumber=#Evaluate("details.#listgetat(dispaycolumns, 1)#")#&from=invoice&startdate=#startdate#&enddate=#enddate#&Log_CF_Header_Table=#Log_CF_Header_Table#&Log_CF_Detail_Table=#Log_CF_Detail_Table#&Log_Distributor_Column=#Log_Distributor_Column#','viewInvoices',
												'toolbar=no,width=510,height=510,location=no,menubar=no,resizable=no,scrollbars=no');return false">
												View</a>	
										<cfelseif url.table EQ 'log_cf_invoice_detail' >
												<a href="javascript:(void);" 
												onClick="javascript:window.open('view.cfm?ItemNumber=#Evaluate("details.#listgetat(dispaycolumns, 1)#")#&from=item&startdate=#startdate#&enddate=#enddate#&Log_CF_Header_Table=#Log_CF_Header_Table#&Log_CF_Detail_Table=#Log_CF_Detail_Table#&Log_Item_Column=#Log_Item_Column#','viewItems',
												'toolbar=no,width=510,height=510,location=no,menubar=no,resizable=no,scrollbars=no');return false">
												View</a>	
										</cfif>							
							</td>
						</cfif>
					</cfloop>
			</cfoutput>
</tr>
  	<cfelse>
<tr>
		  				<td colspan="4">No Records!!</td>
	  </cfif>
	</tr>
  </table>
</div>
</cfif>
<script>
	document.getElementById("loading").style.display = "none";
</script>
