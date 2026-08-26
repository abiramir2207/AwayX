<!--- <cfif request.AccessStructure.user_id NEQ "8F4E2CFD-C6AB-4172-BCFCD050F39EF729">
<cfabort>
</cfif>
 --->

<cfset useLakebaseForisUSDANOI_enabled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForisUSDANOI_enabled>
	<cftry>
		<cfset isUSDANOI_enabled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "usdanoi_enabled"
			}), "usdanoi_enabled"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisUSDANOI_enabled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisUSDANOI_enabled>
<cfquery name="isUSDANOI_enabled" datasource="#application.datasource#">
	SELECT usdanoi_enabled
	FROM _Application_Settings
</cfquery>
</cfif>
<cfset usdanoi_on = 0>
<cfset usdanoi_component_id = "0">
<cfif isUSDANOI_enabled.recordcount GT 0>
	<cfif isUSDANOI_enabled.usdanoi_enabled EQ 1>
		<cfset useLakebaseForgetusdanoicomponentid = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForgetusdanoicomponentid>
	<cftry>
		<cfset getusdanoicomponentid = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_name", {
				"is_usda_noi_comp" = "eq.1",
				"deleted" = "eq.0",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetusdanoicomponentid = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetusdanoicomponentid>
<cfquery name="getusdanoicomponentid" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component_Name
			WHERE Is_USDA_NOI_Comp = 1 AND Deleted = 0
		</cfquery>
</cfif>
		
		<cfif getusdanoicomponentid.recordcount GT 0>
			<cfset usdanoi_on = 1>
			<cfset usdanoi_component_id = getusdanoicomponentid.Program_Rebates_Component_Name_ID>
		</cfif>
	</cfif>
</cfif>

<cfquery name="GetStates" datasource="#application.datasource#">
SELECT DISTINCT StateCode, State, StateFIPS
	FROM ZipCodes
	WHERE StateFIPS NOT IN('00','64','60','69','78','66','68','72','70')
	ORDER By StateCode, State, StateFIPS
</cfquery>

<cfparam name="url.filter_state" default="0">
<cfparam name="url.filter_county" default="0">

<cfparam name="url.state" default="0">
<cfparam name="url.county" default="0">
<cfparam name="url.operator" default="0">
<cfparam name="url.ReportUOM" default="0">
<cfparam name="url.ReportBBDetail" default="0">
<cfparam name="url.ReportType" default="0">

<cfparam name="url.selReportUOM" default="0">
<cfparam name="url.selReportBBDetail" default="0">
<cfparam name="url.selReportType" default="0">

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
<cfset useLakebaseForGetOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getoperatormap")>
<cfif useLakebaseForGetOperators>
	<cftry>
		<cfset GetOperators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getoperatormap", {
				"order" = "operator_name.asc",
				"select" = "bsa_operator_id,operator_name"
			}), "bsa_operator_id,operator_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOperators>
<cfquery name="GetOperators" dbtype="query">
	SELECT DISTINCT BSA_operator_id, Operator_Name
	FROM GetOperatorMap
	ORDER BY Operator_Name
</cfquery>
</cfif>
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
			<select size="1" name="State" onchange="finalsubmit = 0;submitForm();" helpboxid=1>
				<option value="" <cfif url.State EQ ""> SELECTED</cfif>>Select A State...</option>
				<cfoutput>
				<cfloop query="GetStates">
					<option value="#GetStates.StateFIPS#" <cfif url.State EQ GetStates.StateFIPS> SELECTED</cfif>>#GetStates.StateCode# - 							#GetStates.State#</option>
				</cfloop>
				</cfoutput>
			</select>
		</td>
		
		<td>
			<span style="font-weight:bold; font-size:10px;">County</span><br>
			<select size="1" name="County" onchange="finalsubmit = 0;submitForm();">
				<option value="0" <cfif url.County EQ "0"> SELECTED</cfif>>ALL COUNTIES</option>
				<cfoutput>
				<cfloop query="GetCounties">
					<option value="#GetCounties.CountyFIPS#" <cfif url.County EQ GetCounties.CountyFIPS> SELECTED</cfif>>#GetCounties.County#</option>
				</cfloop>
				</cfoutput>
			</select>
		</td>
		
		<td>
			<span style="font-weight:bold; font-size:10px;"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></span><br>
			<select size="1" name="Operator">
				<option value="0" <cfif url.operator EQ 0>SELECTED</cfif>>ALL <cfoutput>#UCASE(application.returned_customer_setting.operator_label_plural)#</cfoutput></option>
				<cfoutput>
				<cfloop query="GetOperators">
					<option value="#GetOperators.BSA_Operator_ID#">#GetOperators.Operator_Name#</option>
				</cfloop>
				</cfoutput>
			</select>
		</td>
	</tr>
	<tr>
		<td nowrap>
			<span style="font-weight:bold; font-size:10px;">Report Type:</span><br>
			<select name="selReportType" onchange="changeReportUOM()">
			<option value="operator" <cfif lcase(url.selReportType) EQ "operator"> SELECTED</cfif>><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></option>
			<option value="item" <cfif lcase(url.selReportType) EQ "item"> SELECTED</cfif>>Item</option>
			<option value="operator-item" <cfif lcase(url.selReportType) EQ "operator-item"> SELECTED</cfif>><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>-Item</option>
			<option value="operator-month-item" <cfif lcase(url.selReportType) EQ "operator-month-item"> SELECTED</cfif>><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>-Month-Item</option>
			</select>							
		</td>
		<td colspan="">
			<span style="font-weight:bold; font-size:10px;">Report Unit Of Measure:</span><br>
			<select name="selReportUOM" onchange="changeReportUOM()">
				<option value="1" <cfif url.selReportUOM EQ "1"> SELECTED</cfif>>Cases</option>
				<option value="2" <cfif url.selReportUOM EQ "2"> SELECTED</cfif>>Pounds</option>
				<option value="rm" <cfif url.selReportUOM EQ "rm"> SELECTED</cfif>>Raw Materials</option>
			</select>
		</td>
		<td>
			<span style="font-weight:bold; font-size:10px;">Show <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput><br>Delivery Detail:</span><br>
			<select name="selReportBBDetail" onchange="changeReportUOM()">
				<option value="0" <cfif url.selReportBBDetail EQ "0"> SELECTED</cfif>>No</option>
				<option value="1" <cfif url.selReportBBDetail EQ "1"> SELECTED</cfif>>Yes</option>
			</select>			
		</td>
	</tr>

	<tr>
		<td align="center" colspan="3" style="cursor: pointer;" onclick="finalsubmit = 1; submitForm();"><b><font color="#FF0000">[</font> 
		<font color="#0000FF">run report</font>
		<font color="#FF0000">]</font></b></td>
		<td>&nbsp;</td>
		<td align="right">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
</table>
<input type="Hidden" name="report_filename" value="/settings/usdanoi/program_search.cfm">
<input type="Hidden" name="final_destination" value="/settings/usdanoi/show_report.cfm">
</form>
</div>
<p>&nbsp;</p>

</body>

</html>