<cfparam name="Distributor_ID" default="">
<cfparam name="url.Operator" default="">
<cfparam name="AllOperators" default="">

<cfparam name="url.Distributor" default="">
<cfparam name="AllDistributors" default="">

<cfparam name="url.ReportUOM" default="rm">
<cfparam name="url.ReportBBDetail" default="1">
<cfparam name="url.ReportType" default="operator">

<cfparam name="url.selReportUOM" default="rm">
<cfparam name="url.selReportBBDetail" default="1">
<cfparam name="url.selReportType" default="operator">

<!---Includes the GetOperators query--->
<cfinclude template="getOperatorList.cfm">
<table border="0" id="table1" cellspacing="0" cellpadding="8" width="500">
		<tr>
			<td align="right" colspan="4" style="border-bottom: 2px solid ##FF0000">
			<p align="left"><b><font size="3">USDA Schools Activity - Report Writer</font></b></td>
		</tr>

<cfif GetOperators.Recordcount GT 0>
	<cfset AllOperators = valuelist(GetOperators.BSA_Operator_ID)> 

	<cfoutput>
	
	<form action="generate_report.cfm?AllOperators=#AllOperators#" method="get" name="MyForm" id="MyForm">
	<input type="hidden" name="Distributor_ID" value="#Distributor_ID#">
	<!--- <input type="hidden" name="AllOperators" value="#AllOperators#"> --->
		
		
			<tr>
			
			
			<td align="left">
				<span style="font-weight:bold; font-size:10px;">#application.returned_customer_setting.operator_label_singular#</span><br>
				<select size="1" name="Operator" >
					<option value="0" >ALL #UCASE(application.returned_customer_setting.operator_label_plural)#</option>
					<cfoutput>
					<cfloop query="GetOperators">
						<option value="#GetOperators.BSA_Operator_ID#" <cfif url.operator EQ GetOperators.BSA_Operator_ID> SELECTED</cfif>>#GetOperators.Operator_Name#</option>
					</cfloop>
					</cfoutput>
				</select>
				
			</td>
		<cfif len(trim(getUSDAUserStatus.user_usda_broker_id_list)) GT 0>
		<td colspan="100%"> <span style="font-weight:bold; font-size:10px;">#application.returned_customer_setting.distributor_label_singular#</span><br>
				<select size="1" name="Distributor" >
					<option value="0" >ALL #UCASE(application.returned_customer_setting.distributor_label_plural)#</option>
					<cfoutput>
					<cfloop query="GetDistributors">
						<option value="#GetDistributors.BSA_Foodservice_Customers_id#" <cfif url.distributor EQ GetDistributors.BSA_Foodservice_Customers_id> SELECTED</cfif>>#GetDistributors.Name#</option>
					</cfloop>
					</cfoutput>
				</select></td>
	</cfif>
		</tr>
		 <tr>
			<td nowrap>
				<span style="font-weight:bold; font-size:10px;">Report Type: </span><br>
				<select name="selReportType"">
				<option value="operator" <cfif lcase(url.selReportType) EQ "operator"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#</option>
				<option value="item" <cfif lcase(url.selReportType) EQ "item"> SELECTED</cfif>>Item</option>
				<option value="operator-item" <cfif lcase(url.selReportType) EQ "operator-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Item</option>
				<option value="operator-month-item" <cfif lcase(url.selReportType) EQ "operator-month-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Month-Item</option>
				<option value="summary" <cfif lcase(url.selReportType) EQ "summary"> SELECTED</cfif>>Summary</option>
				<option id="verification-report" value="verification" <cfif lcase(url.selReportType) EQ "verification"> SELECTED</cfif>>Verification Report</option>
				<option id="Available_item_report" value="Available_item_report" <cfif lcase(url.selReportType) EQ "Available_item_report"> SELECTED</cfif>>Available Items</option>
				<option id="export_to_excel" value="export_to_excel" <cfif lcase(url.selReportType) EQ "export_to_excel"> SELECTED</cfif>>Export To Excel</option>
				</select>							
			</td>
			<td>
				<span style="font-weight:bold; font-size:10px;">Report Unit Of Measure:</span><br>
				<select name="selReportUOM" onchange="<cfif lcase(cgi.SCRIPT_NAME) NEQ "/settings/usdanoi/distributor_search.cfm">changeReportUOM();</cfif>">
					<option value="rm" <cfif url.selReportUOM EQ "rm"> SELECTED</cfif>>Raw Materials</option>
					<!--- <option value="1" <cfif url.selReportUOM EQ "1"> SELECTED</cfif>>Cases</option> --->
					<option value="2" <cfif url.selReportUOM EQ "2"> SELECTED</cfif>>Net Pounds</option>
				</select>
			</td>
			<td nowrap>
				<span style="font-weight:bold; font-size:10px;">Show #application.returned_customer_setting.distributor_label_singular#<br>Delivery Detail:</span><br>
				<select name="selReportBBDetail" <cfif lcase(cgi.SCRIPT_NAME) NEQ "/settings/usdanoi/distributor_search.cfm">onchange="changeReportUOM()"</cfif>>
					<option value="0" <cfif url.selReportBBDetail EQ "0"> SELECTED</cfif>>No</option>
					<option value="1" <cfif url.selReportBBDetail EQ "1"> SELECTED</cfif>>Yes</option>
				</select>			
			</td>
		</tr> 
	
		<tr>
			<td align="center" colspan="3" style="cursor: hand;" onclick="finalsubmit = 1; submitForm();"><b><font color="##FF0000">[</font> 
			<font color="##0000FF">run report</font>
			<font color="##FF0000">]</font></b></td>
			<td>&nbsp;</td>
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	
	<input type="Hidden" name="report_filename" value="/settings/usdanoi/program_search.cfm">
	<input type="Hidden" name="final_destination" value="/settings/usdanoi/show_report.cfm">
	<!--- <input type="Hidden" name="selReportBBDetail" value="1"> --->
	</form>
 </cfoutput>
 
 <!---The distributor has no operators--->
 <cfelse>
 <tr><td>
<font color="red"> <div align="center">There are no current USDA NOI programs that include you. If you believe you are getting this message in error, please contact your system administrator.</div></font>
</td></tr>
 </cfif>
 </table>
<script>
function submitForm() 
	{
			document.all.MyForm.submit();
	}
	
	function verificationReportUOMHandler(oSelect) {
		oOption = oSelect.options[oSelect.selectedIndex];
		if(oOption.id) {
			if(oOption.id == "verification-report")	{
				document.all.selReportUOM.selectedIndex = 0;
				document.all.selReportBBDetail.selectedIndex = 1;
			}
		}
	}
	
</script>