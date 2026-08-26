<!---
	Copyright (c)2014 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\Common_Files\contracts\ez_Rate_check.cfm
	Created:		9/10/2014
	Developer:		drachala
	Description:	This new UI will render before the margin analysis page that will display only those items where the spending rate is greater than the allowable max rate, 
							or, where the item[s] do not have a max rate value established in the template settings.  The new display will include:
										•	Item Number
										•	Item Description
										•	Max rate per case [from the template]
										•	Program spend per case
										•	Variance [program rate minus max rate]
--->
<!DOCTYPE HTML>

<html>
	<head>
		<title>Max Approval Rate Threshold Check</title>
	</head>
<body>
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<CFSET CSL_Contract_Main_ID = cryp.value>
<CFINCLUDE TEMPLATE="commonqueries.cfm">

<table width="100%">
<cfoutput>
		<tr>
			<td align="Left">
				<b>Program Number : #cslgetcontractinfo.contract_number#</b>
			</td>		
			<td>
				<b>Title : #trim(CSLGetContractInfo.Contract_Title)#</b>
			</td>		
			<td align="right">
				<b>Version Date : #dateformat(CSLGetContractInfo.Contract_Start_Date,'long')# to #dateformat(CSLGetContractInfo.Contract_End_Date,'long')#</b>
			</td>		
		</tr>
</cfoutput>
</table>
<br>

<table class="datagrid" >
	<thead>
<CFIF GetSettings.Discount_Fixed_Prices EQ 1 and GetSettings.Fixed_Rebate_Grid_Option neq 1>
	<cfset useLakebaseFordoesProgramHasFixedPrice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseFordoesProgramHasFixedPrice>
	<cftry>
		<cfset doesProgramHasFixedPrice = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component", {
				"program_id" = "eq.#cryp.value#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordoesProgramHasFixedPrice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordoesProgramHasFixedPrice>
<CFQUERY NAME="doesProgramHasFixedPrice" datasource="#application.datasource#">
		SELECT 	*
		FROM 		Program_Fixed_Component
		WHERE 	Program_ID = #cryp.value#
		AND 		Deleted = 0 			
	</CFQUERY>
</cfif>
	<tr>
		<th align="left">
			<input type="checkbox" name="fixedPrice"  value=" " <cfif doesProgramHasFixedPrice.recordcount>Checked</cfif> disabled> 
			Program has <cfoutput>#Application.FixedPriceLabel#</cfoutput> component.
		</th>
	</tr>
</CFIF>
<CFIF GetSettings.Discount_Lump_Sums EQ 1>
	<cfset useLakebaseFordoesProgramHasLumpSum = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseFordoesProgramHasLumpSum>
	<cftry>
		<cfset doesProgramHasLumpSum = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sums", {
				"program_id" = "eq.#cryp.value#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordoesProgramHasLumpSum = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordoesProgramHasLumpSum>
<CFQUERY NAME="doesProgramHasLumpSum" datasource="#application.datasource#">
		SELECT 	*
		FROM 		Program_Lump_Sums
		WHERE 	Program_ID = #cryp.value#
		AND 		Deleted = 0 	
	</CFQUERY>
</cfif>
	<tr><td style="height:4px;"></td></tr>
	<tr>
		<th align="left">
			<input type="checkbox" name="LumpSum" <cfif doesProgramHasLumpSum.recordcount>Checked</cfif> disabled> 
			Program has <cfoutput>#Application.LumpsumLabel#</cfoutput> component.
		</th>
	</tr>
</CFIF>
<CFIF GetSettings.Discount_Growth EQ 1>
	<cfset useLakebaseForDoesProgramHasGrowth = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
	<cfif useLakebaseForDoesProgramHasGrowth>
		<cftry>
			<cfset doesProgramHasGrowth = application.oLakebase.toQuery(
				application.oLakebase.selectRows("program_growth_components", { "program_id" = "eq.#cryp.value#", "deleted" = "eq.false" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDoesProgramHasGrowth = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDoesProgramHasGrowth>
	<CFQUERY NAME="doesProgramHasGrowth" datasource="#application.datasource#">
		SELECT 	*
		FROM 		Program_Growth_Components
		WHERE 	Program_ID = #cryp.value#
		AND 		Deleted = 0
	</CFQUERY>
	</cfif>
	<tr><td style="height:4px;"></td></tr>	
	<tr>
		<th align="left">
			<input type="checkbox" name="growth" <cfif doesProgramHasGrowth.recordcount>Checked</cfif> disabled> 
			Program has <cfoutput>#Application.GrowthLabel#</cfoutput> component.
		</th>
	</tr>
</CFIF>
	</thead>
</table>
<br>

	<!--- D45263 :: Create table to store max rates by template/profile --->
	<CFQUERY NAME="ProgramEZRates" datasource="#application.datasource#">
		SELECT	*
		FROM	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#cryp.value#, 'RETURN_ALL', #request.AccessStructure.Profiles_ID#) 
		ORDER BY item
	</CFQUERY>

	<CFQUERY NAME="qProgramEZRates" dbtype="query"> 
		SELECT  * 
		FROM ProgramEZRates
		WHERE EZ_Rate < Program_Rate
	</CFQUERY>

<cfif qProgramEZRates.recordcount>
<table class="datagrid" id="datagrid">
	<thead>
		<tr>
		    <th>Item</th>
		    <th>Description</th>
		    <th>Max Approval<br>Rate Threshold</th>
		    <th>Prg Rate</th>
			<th>Variance</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qProgramEZRates">
		<tr>
		  <td>#item#</td>
		  <td>#item_description#</td>
		  <td>#ez_rate#</td>
		  <td>#Program_rate#</td>
		  <td>#variance#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>
</cfif>
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
var grid = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"aaSorting": [[ 0, "asc" ]] 
    ,"aoColumns": [   
					  {"sWidth": "12%"}
                    , {"sWidth": "47%"}
                    , {"sWidth": "17%", "bSearchable":false}
					, {"sWidth": "12%", "bSearchable":false}
                    , {"sWidth": "12%", "bSearchable":false} 
					]
  }).fnSetFilteringDelay();

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

 function continueApproval() { 
		window.opener.confirmApproval(); 
		self.close();
	}
</script>

	<cfif cslgetcontractinfo.contract_status_type_idx LTE 1>
		<div align="center">
			<a href='javascript:continueApproval();'><cfoutput>#application.util.string.actionLinkFormat("Continue")#</cfoutput></a>
			<a href='javascript:window.opener.location.reload(false);self.close();'><cfoutput>#application.util.string.actionLinkFormat("Close")#</cfoutput></a>
		</div>
	</cfif>
<!--- LINKS START--->
<cfif cslgetcontractinfo.contract_status_type_idx GT 1>
	<cfinclude template="/common_files/contracts/layered_margin_calculation.cfm"/>
</cfif>
<!--- LINKS END--->
</body>
</html>