<!--- <cfif request.AccessStructure.user_id NEQ "8F4E2CFD-C6AB-4172-BCFCD050F39EF729">
<cfabort>
</cfif>
 --->

 
 
<cfquery name="isUSDANOI_enabled" datasource="#application.datasource#">
	SELECT usdanoi_enabled
	FROM _Application_Settings
</cfquery>
<cfset usdanoi_on = 0>
<cfset usdanoi_component_id = "0">
<cfif isUSDANOI_enabled.recordcount GT 0>
	<cfif isUSDANOI_enabled.usdanoi_enabled EQ 1>
		<cfquery name="getusdanoicomponentid" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component_Name
			WHERE Is_USDA_NOI_Comp = 1 AND Deleted = 0
		</cfquery>
		
		<cfif getusdanoicomponentid.recordcount GT 0>
			<cfset usdanoi_on = 1>
			<cfset usdanoi_component_id = getusdanoicomponentid.Program_Rebates_Component_Name_ID>
		</cfif>
	</cfif>
</cfif>

<cfquery name="GetStates" datasource="#application.datasource#">
select _states.state_id as StateFIPS,State_Code as StateCode,
state_name as state
  from
_states
where state_id not in (73,75,69,72,74,70,78,77,79,80,82,83,56,84,85,75,81)
order by state_id,state_name
</cfquery>

<cfparam name="url.filter_state" default="0">
<cfparam name="url.filter_county" default="0">

<cfparam name="url.state" default="0">
<cfparam name="url.county" default="0">
<cfparam name="url.operator" default="0">
<cfparam name="Distributor_ID" default="">
<cfparam name="AllOperators" default="">
<cfparam name="url.ReportUOM" default="rm">
<cfparam name="url.ReportBBDetail" default="1">
<cfparam name="url.ReportType" default="operator">

<cfparam name="url.selReportUOM" default="rm">
<cfparam name="url.selReportBBDetail" default="1">
<cfparam name="url.selReportType" default="operator">

<cfparam name="GoToDistributorSearch" default="0">

<!--- is this user a USDA exclusive user...if so limit their selection --->
 <cfquery name="getUSDAUserStatus" datasource="#application.datasource#">
 	SELECT Is_USDA_User, user_usda_state_id, user_usda_county_id, user_usda_operator_id, user_usda_distributor_id, user_usda_distributor_id_list, user_usda_broker_id_list, user_usda_operator_id_list
	FROM _Users
	WHERE User_ID = '#request.AccessStructure.User_ID#'
  </cfquery>
  
  
  
  <cfif len(trim(getUSDAUserStatus.user_usda_distributor_ID)) GT 0 AND  getUSDAUserStatus.user_usda_distributor_ID IS NOT 0>
	<cfset GoToDistributorSearch = 1>
	<cfelseif len(trim(getUSDAUserStatus.user_usda_distributor_id_list)) GT 0 AND getUSDAUserStatus.user_usda_distributor_id_list IS NOT 0>
	<cfset GoToDistributorSearch = 1>
	<cfelseif len(trim(getUSDAUserStatus.user_usda_operator_id_list)) GT 0 AND getUSDAUserStatus.user_usda_operator_id_list IS NOT 0>
	<cfset GoToDistributorSearch = 1>
	<cfelseif len(trim(getUSDAUserStatus.user_usda_broker_id_list)) GT 0 AND getUSDAUserStatus.user_usda_broker_id_list IS NOT 0>
	<cfset GoToDistributorSearch = 1>
	</cfif>
	
	<Cfif GoToDistributorSearch IS 1>
	<cfoutput>
		<cflocation url="distributor_search.cfm">
	</cfoutput>
	</CFIF>
  
  <cfscript>
  	disabled_state = "";
    disabled_county = "";
    disabled_operator = "";
  	if(getUSDAUserStatus.Is_USDA_User EQ 1) {
		url.state = getUSDAUserStatus.user_usda_state_id;
		if(url.state NEQ 0)	{
			disabled_state = "disabled";
		}
	
		url.county = getUSDAUserStatus.user_usda_county_id;
		if(url.county NEQ 0)	{
			disabled_county = "disabled";
		}

		url.operator = getUSDAUserStatus.user_usda_operator_id;
		if(url.operator NEQ 0)	{
			disabled_operator = "disabled";
		}
	}  
  </cfscript>

<cfset GetOperatorMap = querynew("Operator_Name")>
<CFIF len(trim(url.state)) GT 0 >
<cfquery name="GetOperatorMap" datasource="#application.datasource#">
	SELECT	*
	FROM	Operator_ZipCode_Map
	WHERE 
	BSA_Operator_ID IN (SELECT BSA_Operator_ID FROM USDANOI_Operators)

	<cfif len(trim(url.state)) GT 0>
		<cfif trim(url.state) NEQ 0>
			AND
				StateFIPS	= '#url.state#'
		</cfif>
	</cfif>
	
	
	<cfif len(trim(url.county)) GT 0>
		<cfif trim(url.county) NEQ 0>
			AND
				CountyFIPS = '#url.county#'
		</cfif>
	</cfif>
</cfquery>
</CFIF>

<cfset GetCounties = QueryNew("County")>
<CFIF GetOperatorMap.recordcount GT 0 AND url.state NEQ 0>
	<cfquery name="GetCounties" dbtype="query">
		SELECT DISTINCT County, CountyFIPS
		FROM GetOperatorMap
		ORDER BY County
	</cfquery>
</CFIF>

<cfset GetOperators = QueryNew("Operator_Name")>
<CFIF GetCounties.recordcount GT 0 AND url.state NEQ 0>
<cfquery name="GetOperators" dbtype="query">
	SELECT DISTINCT BSA_operator_id, Operator_Name
	FROM GetOperatorMap

	<cfif getUSDAUserStatus.Is_USDA_User EQ 1 AND url.county neq 0 AND getUSDAUserStatus.USER_USDA_OPERATOR_ID NEQ 0>
	where BSA_operator_id = #getUSDAUserStatus.USER_USDA_OPERATOR_ID#
	</cfif>				
	
	ORDER BY Operator_Name
</cfquery>
</CFIF>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>State</title>
<link rel="stylesheet" type="text/css" href="style.css">
<script>

	var finalsubmit = 0;
	function submitForm() {

		if(document.all.MyForm.State.selectedIndex == 0) {
			alert("Please select a state first.");
			finalsubmit = 0;
		}
		else {
			if(document.all.MyForm.Operator.length == 1 && finalsubmit == 1){
				alert("There is no data to run a report against. Please select another state.")
				finalsubmit = 0;
				return false;
			}
			if(finalsubmit == 1) {
				redirectForm();
			}
			
			document.all.MyForm.submit();
		}
	}
	
	function redirectForm() {
		document.MyForm.action ="generate_report.cfm";
		return true;
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


</head>

<body>


<p><br>
&nbsp;</p>
<div align="center">
	<form action="search.cfm" method="get" name="MyForm" id="MyForm">
	<table border="0" id="table1" cellspacing="0" cellpadding="8">
	<tr>
		<td align="right" colspan="4" style="border-bottom: 2px solid #FF0000">
		<p align="left"><b><font size="3">USDA Schools Activity - Report Writer</font></b></td>
	</tr>
	
		<tr>
		<td>
			<span style="font-weight:bold; font-size:10px;">State</span><br>
			<select size="1" name="State" onchange="finalsubmit = 0;submitForm();" helpboxid=1 <cfoutput>#disabled_state#</cfoutput>>
				<option value="" <cfif url.State EQ ""> SELECTED</cfif>>Select A State...</option>
				<cfoutput>
				<cfloop query="GetStates">
					<option value="#GetStates.StateFIPS#"  <cfif url.state EQ GetStates.StateFIPS> SELECTED</cfif>>#GetStates.StateCode# - 							#GetStates.State#</option>
				</cfloop>
				</cfoutput>
			</select>
			<cfif len(disabled_state) GT 0>
			 <cfoutput><input type="Hidden" name="State" value="#url.state#"></cfoutput>
			</cfif>
		</td>
		
		<td>
			<span style="font-weight:bold; font-size:10px;">County</span><br>
			<select size="1" name="County" onchange="finalsubmit = 0;submitForm();" <cfoutput>#disabled_county#</cfoutput>>
				<option value="0" <cfif url.County EQ "0"> SELECTED</cfif>>ALL COUNTIES</option>
				<cfoutput>
				<cfloop query="GetCounties">
					<option value="#GetCounties.CountyFIPS#" <cfif url.County EQ GetCounties.CountyFIPS> SELECTED</cfif>>#GetCounties.County#</option>
				</cfloop>
				</cfoutput>
			</select>
			<cfif len(disabled_county) GT 0>
			 <cfoutput><input type="Hidden" name="County" value="#url.county#"></cfoutput>
			</cfif>
		</td>
		
		<td>
			<span style="font-weight:bold; font-size:10px;">Operator</span><br>
			<select size="1" name="Operator" <cfoutput>#disabled_operator#</cfoutput>>
				<option value="0" <cfif url.operator EQ 0>SELECTED</cfif>>ALL OPERATORS</option>
				<cfoutput>
				<cfloop query="GetOperators">
					<option value="#GetOperators.BSA_Operator_ID#" <cfif url.operator EQ GetOperators.BSA_Operator_ID> SELECTED</cfif>>#GetOperators.Operator_Name#</option>
				</cfloop>
				</cfoutput>
			</select>
			<cfif len(disabled_operator) GT 0>
			 <cfoutput><input type="Hidden" name="Operator" value="#url.operator#"></cfoutput>
			</cfif>
		</td>
	</tr>
	<tr>
		<td nowrap>
			<span style="font-weight:bold; font-size:10px;">Report Type:</span><br>
			<cfoutput><select name="selReportType" >
			<option value="operator">#application.returned_customer_setting.operator_label_singular#</option>
			<option value="item" <cfif lcase(url.selReportType) EQ "item"> SELECTED</cfif>>Item</option>
			<option value="operator-item" <cfif lcase(url.selReportType) EQ "operator-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Item</option>
			<option value="operator-month-item" <cfif lcase(url.selReportType) EQ "operator-month-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Month-Item</option>
			<option value="summary" <cfif lcase(url.selReportType) EQ "summary"> SELECTED</cfif>>Summary</option>
			<option id="verification-report" value="verification" <cfif lcase(url.selReportType) EQ "verification"> SELECTED</cfif>>Verification Report</option>
			<option id="Available_item_report" value="Available_item_report" <cfif lcase(url.selReportType) EQ "Available_item_report"> SELECTED</cfif>>Available Items</option>
			<option id="export_to_excel" value="export_to_excel" <cfif lcase(url.selReportType) EQ "export_to_excel"> SELECTED</cfif>>Export To Excel</option>
			</select>		</cfoutput>					
		</td>
		<td colspan="">
			<span style="font-weight:bold; font-size:10px;">Report Unit Of Measure:</span><br>
			<select name="selReportUOM" onchange="<cfif lcase(cgi.SCRIPT_NAME) NEQ "/settings/usdanoi/search.cfm">changeReportUOM();</cfif>">
				<option value="rm" <cfif url.selReportUOM EQ "rm"> SELECTED</cfif>>Raw Materials</option>
				<!--- <option value="1" <cfif url.selReportUOM EQ "1"> SELECTED</cfif>>Cases</option> --->
				<option value="2" <cfif url.selReportUOM EQ "2"> SELECTED</cfif>>Net Pounds</option>
			</select>
		</td>
		<td>
			<span style="font-weight:bold; font-size:10px;">Show <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput><br>Delivery Detail:</span><br>
			<select name="selReportBBDetail" <cfif lcase(cgi.SCRIPT_NAME) NEQ "/settings/usdanoi/search.cfm">onchange="changeReportUOM()"</cfif>>
				<option value="0" <cfif url.selReportBBDetail EQ "0"> SELECTED</cfif>>No</option>
				<option value="1" <cfif url.selReportBBDetail EQ "1"> SELECTED</cfif>>Yes</option>
			</select>			
		</td>
	</tr>

	<tr>
		<td align="center" colspan="3" style="cursor: hand;" onclick="finalsubmit = 1; submitForm();"><b><font color="#FF0000">[</font> 
		<font color="#0000FF">run report</font>
		<font color="#FF0000">]</font></b></td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
</table>
<cfoutput><input type="hidden" name="distributor_ID" value="#Distributor_ID#">
<input type="hidden" name="AllOperators" value="#AllOperators#"></cfoutput>
<input type="Hidden" name="report_filename" value="/settings/usdanoi/program_search.cfm">
<input type="Hidden" name="final_destination" value="/settings/usdanoi/show_report.cfm">
</form>
</div>
<p>&nbsp;</p>

</body>

</html>