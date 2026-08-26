<!----
	Filename:	C:\Work\Code\base\AwayX\DEDUCTIONS\Closure\DD_Non_Trade_All_Items.cfm
	Created:	02/09/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		Display All items which are saved in DB when this deduction closed as NON_TRADE, DEDUCTION ID is passed as URL variable.
	Usage: DD NON TRADE
---->
<cfif NOT isDefined("Deduction_ID")>
	<cfset Deduction_ID = #url.Deduction_ID#>
</cfif>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfparam name="url.from" default="">
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<cfinclude template="/deductions/sql_Deduction_Info.cfm">
<cfset deduction_amount = #Deduction_Info.DD_Amount#>

<div style="background: url(/Images/gradient.jpg); background-color:#A7CAF2; background-repeat : no-repeat; width:100%; height:20px; padding:5px; color: White; font-weight: bold; font-size: 16px;">
		Items Info
</div>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<cfoutput>
	<table width="100%;">
			<tr style="font-weight: bold; font-size:20px;">
				<td valign="top">#Deduction_Info.DD_DedID_SP_Number#</td>
				<td valign="top" align=right>
					<CFIF Deduction_Info.ShipToName NEQ "">
							#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)
					<CFELSE>
						#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)
					</CFIF>
				</td>
			</tr>
	</table>
	
	
	<cfset ItemsInfo = CreateObject("component", "components.deduction.nontrade") />
	<cfset NonTradeItems = ItemsInfo.ItemsFromDDNonTradeproduct(#Deduction_ID#)><!---  D34163 : Deduction - unable to close  --->
	
	
	<cfsavecontent variable="vars.htmlHead">
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
	.action { font-weight:bold; margin:0 3px 0 3px; }
	</style>
	</cfsavecontent>
	<cfhtmlhead text="#vars.htmlHead#">
	
	<cfscript>
	  vars = StructNew();
	</cfscript>
	
	
	
	<table id="NonTrade" class="datagrid" border="0" width="100%">
		<thead>
						<tr>
		    				<th>Item</th>
							<th>Description</th>
		    				<th>Volume</th>
		    				<th>Sales <br>Dollars</th>
		    				<th>Average <br>Case Rate</th>
							<th>Cases</th>
							<th>Dollars</th>
							<th>Reason Code</th>
						</tr>
		</thead>
		<tbody>
			<cfloop query="NonTradeItems">
				
				<cfset NonTradeInfo = ItemsInfo.NonTradeItemInfo(deduction_id = #trim(Deduction_ID)#, bsa_id = #trim(BSA_Foodservice_Items_Master_ID)#)>
				<cfif len(NonTradeItems.sales_dollar) EQ 0><cfset NonTradeItems.sales_dollar = 0></cfif>
				<cfif len(NonTradeInfo.Volume) AND len(NonTradeInfo.Dollar)>
					
<cfset useLakebaseForAutoCloseReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_close")>
<cfif useLakebaseForAutoCloseReason>
<cftry>
<cfset AutoCloseReason = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_auto_close", {
"select" = "dd_reason_code_id"
}),
"dd_reason_code_id"
)>
<cfcatch type="any">
<cfset useLakebaseForAutoCloseReason = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForAutoCloseReason><cfquery name="AutoCloseReason" datasource="#application.datasource#">
		SELECT DD_Reason_Code_ID
		FROM DD_Auto_Close
</cfquery>
</cfif>

<cfset useLakebaseForGetReasonCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForGetReasonCodes>
<cftry>
<cfset grcParams = { "deleted" = "eq.0", "display_in" = "in.(1,3)", "order" = "dd_reason_code_description.asc" }>
<cfif AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
<cfset grcParams["dd_reason_code_id"] = "neq.#AutoCloseReason.DD_Reason_Code_ID#">
</cfif>
<cfif appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
<cfif len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 1>
<cfset grcParams["closing_method"] = "eq.1">
<cfelseif len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type EQ 5>
<cfset grcParams["closing_method"] = "eq.2">
<cfelseif Deduction_Info.Is_Last_Status_Rebill>
<cfset grcParams["closing_method"] = "eq.4">
<cfelseif Deduction_Info.Is_Write_Off>
<cfset grcParams["closing_method"] = "eq.3">
<cfelseif Deduction_Info.DD_Rejected>
<cfset grcParams["closing_method"] = "eq.5">
</cfif>
</cfif>
<cfset GetReasonCodes = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_reason_code", grcParams)
)>
<cfcatch type="any">
<cfset useLakebaseForGetReasonCodes = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetReasonCodes><cfquery name="GetReasonCodes" datasource="#application.datasource#">
		SELECT * 
		FROM DD_Reason_Code 
		WHERE Deleted = 0 
		AND Display_In IN (1,3)
		<CFIF AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
		AND DD_Reason_Code_ID != #AutoCloseReason.DD_Reason_Code_ID#
		</CFIF>
		<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
		<CFIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 1>
		AND Closing_Method = 1
		<CFELSEIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type EQ 5>
		AND Closing_Method = 2
		<CFELSEIF Deduction_Info.Is_Last_Status_Rebill>
		AND Closing_Method = 4
		<CFELSEIF Deduction_Info.Is_Write_Off>
		AND Closing_Method = 3
		<CFELSEIF Deduction_Info.DD_Rejected>
		AND Closing_Method = 5
		</CFIF>
		</CFIF>
		ORDER BY DD_Reason_Code_Description
</cfquery>
</cfif>
					
					
						<tr>
							<td style="width:50px">#item#</td>
						 	<td style="width:200px">#Description#</td>
						 	<td style="width:60px">#cases_invoiced#</td>
						 	<td style="width:60px">#LSCurrencyFormat(NonTradeItems.sales_dollar)#</td>
							<cfif cases_invoiced EQ 0>
								<cfset Average_Case_Rate = #NonTradeItems.sales_dollar#>
							<cfelse>
								<cfset Average_Case_Rate = #NonTradeItems.sales_dollar#/#cases_invoiced#>
							</cfif>
						 	<td style="width:75px">#LSCurrencyFormat(Average_Case_Rate)#</td>
							<td style="width:60px">#Round(NonTradeInfo.Volume)#</td>
							<td style="width:60px">#LSCurrencyFormat(NonTradeInfo.Dollar)#</td>
							<td style="width:250px">

				<cfloop query="GetReasonCodes">
					<cfif (len(NonTradeInfo.Reason_Code_Id) AND (NonTradeInfo.Reason_Code_Id EQ DD_Reason_Code_ID))>#trim(DD_Reason_Code_Description)#</cfif>
				</cfloop>

								
							</td>
						</tr>
				</cfif>
			</cfloop>
		</tbody>
	</table>
</cfoutput>


<script type="text/javascript" src="/Script/javascript/jquery.dataTables.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
	var grid = $('#NonTrade').dataTable({
			"bAutoWidth": true
			,"bPaginate": false<!--- D30009:More issues found  non-trade deduction feature REMOVED PAGGING TO FIX ISSUE2--->
			,"bSortClasses": false
			,"bScrollCollapse": true
			,"sDom": 'fti'
			,"sScrollXInner": "100%"
			,"aaSorting": [[ 0, "asc" ]]
			,"aoColumns": [   {"sWidth": ""}
							, {"sWidth": ""}
                  			, {"sWidth": "", "sType": "numeric"}
							, {"sWidth": "", "sType": "currency"}
							, {"sWidth": "", "sType": "currency"}
							, {"sWidth": "", "sType": "numeric"}
							, {"sWidth": "", "sType": "currency"}
							, {"sWidth": "", "bSortable":false, "bSearchable":false}] 
}).fnSetFilteringDelay();
<!--- adjust the grid when window is resized --->
$(window).resize(function(){
  grid.fnAdjustColumnSizing();
});

$('table#NonTrade tr').hover (
	function() { $(this).addClass("over"); },
	function() { $(this).removeClass("over"); }
);
</script>
