<cfsilent>
<!---
* ==================================================================================================== 
*    @File: Programs\product\Rate_Main_MarketPrice.cfm
*  @Author: Sharon Harris
*    @Date: Jan-2020
* 
* @Remarks: Market Program Rates page - replacing the Flex app
*           Accessed via Program Template Filters area
*
* ==================================================================================================== 
--->
</cfsilent>
<!doctype html>
<html lang="en">
<head>
	<title>Market Price Rates</title>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">

	<cfsavecontent variable="head_content">
		<cfset request.noty_version = "3">
		<cfset jQuery.version = "1.12.4">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/common_files/tailwind-css.cfm, /styles/fontawesome/5.8/all.css, /common_files/noty.cfm">
		<cf_include files="/Programs/product/rate_style.css">
    </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>

<cfparam name="url.programID" 	type="integer" default="0" />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="Rate_Header_MarketPrice.cfm">


<cfscript>
objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
//iMPId = objMarketPriceManager.getProgramActiveMPList(url.programID);
appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
statusFilterOn = appSettings.getSearchInactiveProductsInPrograms();
</cfscript>

	<cfset request.ag_grid_theme = "ba-ag-theme-balham">
	<cf_include files=#arrayToList( [	
									"/common_Files/ag-Grid.cfm",
									"/script/javascript/numeral.min.js",
									"/styles/css-loader.css"
									 ])#>
	<cfinclude template="/common_files/multiselect.cfm">

	<style>
	<!--- override the ag-grid styles included above --->
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
			text-align: center;
		}
		.ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
		.ag-theme-balham .ag-row-selected {
			border-top-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
			left: 1px; /* center the checkbox */
		}
		/* Make the resize lines bigger */
		.ag-header-cell-resize {
			content: '';
			position: absolute;
			top: 0;
			right: 0 !important;
			margin: 0 !important;
			width: 4px !important;			/* so make it wider, change the background color to match the hdr, and add a thin border */
			background: #ffce84;
			border-right: 1px solid #9b9b9c;
			z-index: 0;
		}
	</style>

	<!---------------------->
	<!--- Whole document --->
	<!---------------------->
	<!--- The "save_message" div will be used to show messages to the user --->
	<!--- <div class="save_message"></div> --->
	<div id="page-container" class="bg-grey-lightest">

		<!--------------------------------->
		<!------- TOOL CARDS SECTION ------>
		<!--------------------------------->
		<div id="tools" class="mx-1 text-black">
			<div class="md:flex md:flex-wrap">	<!--- for mid-sized screens, wrap into columns --->

			<!--- Card # 1   Manage Components --->
			<div class="details-card">
				<div class="card-header">Manage Components</div>
				<div class="card-main flex">
					<div>	<!--- First column --->
						<div id="componentStatus"></div>
						<div>
							<select name="cboCompName" id="cboCompName" style="width:150px; margin:2px 3px 8px 3px">
							</select>
						</div>
					</div>

					<div class="ml-3">	<!--- Third column --->
						<button type="button" id="downloadRatesTemplate" title='Export products and rates from the Price list' class="button" onClick="downloadRates()">Download Rates</button>
						<button type="button" id="uploadRatesTemplate" title="Import products and rates to the Price list" class="button" onClick="uploadCSV()">Upload Rates</button>
					</div>
				</div>
			</div>
			
			<!--- Card # 3 Mass Apply Rates --->
			<div class="details-card">
				<div class="card-header" title="Mass apply rates to items in the grid by selecting them (using the row level check boxes) and clicking 'apply rate'.">
					Mass Apply Rates
				</div>
				<div class="card-main">
					<div class="flex mb-2">
						<!---type="number" min="0" step="0.0001" (Not valid for IE) --->
						<input name="tiRate" id="tiRate" class="ml-1 mr-2" style="height:18px; width:75px;" value="" onkeyup="enableDisableMassApplyOptions()">
					
						<select name="cboUom" id="cboUom" class="border mr-2" style="width:40px;">
						</select>
					</div>
					<div class="mb-2 ml-1">
						<select name="apply_rdoUomActionGrp" id="apply_rdoUomActionGrp" class="border mr-1" onChange="enableDisableUOMOptions(); enableDisableMassApplyOptions();">
						</select>
					</div>
					<button type="button" id="setRateUomBtn" title="Mass apply an absolute, incremental, or % change rate to the currently selected (checked) products." class="button" onClick="massApplyRatesAndUOM();">Apply Rate</button>
				</div>
			</div>
		</div>

		<!---------------------------->
		<!--- Menus above the grid --->
		<!---------------------------->
		<div class="flex justify-between items-center">
			<div class="inline-field" >
				<button type="button" id="saveBtn" title='' class="button recommended" style="margin: 5px 15px 0px 10px" onClick="saveData()">Save</button>

				<!--- FILTERS  --->
				<span class="mt-1">Filters:</span>
				<fieldset class="mr-2 mt-1 filter-set">
					<form id="filterSet">
						<input type="checkbox" name="chFilterRates" id="chFilterRates" value="1" onClick="externalFilterChanged();" title="Show only the items with rates.  These are the items that get added to the program.">
						<label for="chFilterRates">Rates</label>
						<input type="checkbox" name="chFilterSelected" id="chFilterSelected" value="1" onClick="externalFilterChanged();" title="Show only the selected (checked) items">
						<label for="chFilterSelected">Selected</label>
						<input type="checkbox" name="chFilterGroup" id="chFilterGroup" value="1" onClick="externalFilterChanged();" title="Show group records in the grid">
						<label for="chFilterGroup">Groups</label>
						<input type="checkbox" name="chFilterItem" id="chFilterItem" value="1" onClick="externalFilterChanged();" title="Show item records in the grid">
						<label for="chFilterItem">Items</label>
						<input type="checkbox" name="chFilterVarianceMP" id="chFilterVarianceMP" value="1" onClick="externalFilterChanged();" title="Show only the items with a market price variance">
						<label for="chFilterVarianceMP">Price Variance</label>
						<input type="checkbox" name="chFilterMP" id="chFilterMP" value="1" onClick="externalFilterChanged();" title="Show only the items with a market price">
						<label for="chFilterMP">Price</label>
						<input type="checkbox" name="chFilterNone" id="chFilterNone" value="1" onClick="externalFilterChanged();" title="show items with Print Group 'None'">
						<label for="chFilterNone">none prt grp</label>
						<select name="cboProductStatus" id="cboProductStatus" onChange="externalFilterChanged();">
							<option value="All Status">All Status</option>
							<option value="Active">Active</option>
							<cfif statusFilterOn eq 1>
							<option value="In-Active">In-Active</option>
							</cfif>
						</select>

						<button type="button" id="btnClearFilters" title="Clear all filters including column header filters in the grid.  All available items will be displayed." class="button alt">Clear Filters</button>
					</form>
				</fieldset>
			</div>

				<button id="column_tool" class="button"></button>
		</div>

		<!----------------->
		<!--- MAIN GRID --->
		<!----------------->
		<div id="Rate_Grid" style="height:200px;" class="ag-theme-balham mx-1 mt-1"></div>
			<cfinclude template="/Programs/product/Rate_Grid_MarketPrice.cfm">
		</div>

    <!-------------------------------------------------------------------------------------->
    <!--------------------------------- SCRIPTS -------------------------------------------->
    <!-------------------------------------------------------------------------------------->
	<script>

		// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
		document.addEventListener("DOMContentLoaded", function () {
			loadRateData();
		});


		<!---  Column Tool toggle --->
		const show_column_tool = "show column tool";
		$("#column_tool").text( show_column_tool );
		$("#column_tool").click(function(){
			if ( Rate_GridOptions.api.isToolPanelShowing() ) {
				Rate_GridOptions.api.closeToolPanel();
				$(this).text( show_column_tool );
			}
			else {
				Rate_GridOptions.api.openToolPanel("columns");
				$(this).text( "hide column tool" );
			}
		});

	// Configure (optional) multi-select dropdown
	// override default setting
	config.multiselect.noneSelectedText = "Choose rates to show";
	config.multiselect.selectedList = 1;
	config.multiselect.menuWidth = "auto";
 
	// render multiselect widget
	$("#drpSelectedCustomers").multiselect( config.multiselect )

	$("#btnClearFilters").click(function(){
		document.getElementById("filterSet").reset();
		externalFilterChanged();
		Rate_GridOptions.api.setFilterModel(null);
	});	
    </script>

	<cfinclude template="/Common_Files/focus.cfm">
</body>
</html>