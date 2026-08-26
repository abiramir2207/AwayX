<cfsilent>
<!---
* ==================================================================================================== 
*    @File: Programs\product\Rate_Main.cfm
*  @Author: Sharon Harris
*    @Date: 03-Oct-2019
* 
* @Remarks: Main entrance to the Program Rates page - replacing the Flex app
*           
*			See old FlexDev\Forge\src\com\ContractProds\ContractProds.mxml
*
* ==================================================================================================== 
--->
</cfsilent>
<!doctype html>
<html lang="en">
<head>
	<title>Program Rates</title>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">

	<cfsavecontent variable="head_content">
		<cfset request.noty_version = "3">
		<cfset jQuery.version = "1.12.4">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/common_files/tailwind-css.cfm, /styles/fontawesome/5.8/all.css, /common_files/noty.cfm, /Programs/product/rate_style.css">
    </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>

<cfparam name="url.programID" 	type="integer" default="0" />

<!--- (Start) - Below code is needed for integrating this page with the Left NAV program links --->
<cfparam name="url.cid" default="">
<cfif url.cid NEQ "" >
	<CF_Cryp type="de" key="#request.key#" string="#url.cid#">
	<cfset url.programID = cryp.value />
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- "CSL_Contract_Main_ID" is nseed for "/common_files/contracts/contract_status_legend.cfm" --->

<CFSET CSL_Contract_Main_ID = url.programID>

<CFSET CSL_CallingPageCode = "fixed_rebate_grid">
<!--- "contract_status_legend.cfm" is needed for the left NAV. --->
<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 130px; height: 400px; z-index: 5; left: 10px; top: 0px">
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
	</div>
<cfelse>
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
</cfif>

<CFINCLUDE TEMPLATE="/common_files/contracts/commonqueries.cfm">

<cfif application.programlayout EQ 1>
	<!--- Below div is needed, so that the content of the screen does not overlap the left NAV. --->
	<div id="Layer1" style="position:relative; width:calc(100% - 155px); z-index:1; left:150px; top: 10px; height:calc(100% - 50px);">
</cfif>

<!--- "form.contract_main_id" and "width" is needed for "/common_files/contracts/minimal_contract_info.cfm" --->
<cfset width = '1250'>
<cfset form.contract_main_id = url.programID>
<cfinclude template="/common_files/contracts/minimal_contract_info.cfm">
<!--- (End) - Above code is needed for integrating this page with the Left NAV program links --->

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT Contract_Main.Template_Filters_Id
	FROM Contract_Main
	WHERE Contract_Main_ID = <cfqueryparam value="#url.programID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset variables.TemplateFiltersID = 0 />
<cfif GetSettings.RecordCount>
	<cfset variables.TemplateFiltersID = GetSettings.Template_Filters_Id />
</cfif>

<cfparam name="url.TemplateFiltersID" 	type="integer" 	default="#variables.TemplateFiltersID#" />

<cfquery name="GetCurrency" datasource="#application.datasource#">
	SELECT Currency_Code
	FROM Currency
	<!--- Not all clients have Currency_ID of 2 set as Canadian. e.g.- "Simplot" and maybe others. So, we need to use the 
	keyword "Canad". Clients could have curency name like "Canadian", "Canadian Dollars", "Canadian Dollar" "Canada", "CN Dollars" etc. --->
	WHERE Currency_Name like '%Canad%' OR Currency_Code like '%CAD%' OR Currency_Code like '%CDN%'
</cfquery>

<cfscript>
objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
iMPId = objMarketPriceManager.getProgramActiveMPList(url.programID);
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
	<cfinclude template="/Programs/product/Rate_Main_Header_Components.cfm">
	<cfinclude template="/Programs/product/Rate_Items_Popup.cfm">


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
            top: -3px;
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
        .ag-theme-balham .ag-cell {
            padding-top: 3px;
        }
        .ag-theme-balham div.editable {
            padding-top: 0;
            margin-top: 3px;
        }
        label {
            user-select: none;
        }
	</style>

	<!---------------------->
	<!--- Whole document --->
	<!---------------------->
	<div id="page-container" class="bg-grey-lightest">

		<!--------------------------------->
		<!------- TOOL CARDS SECTION ------>
		<!--------------------------------->
		<!--- <div id="tools" class="xl:flex mx-1 text-sm text-black"> --->
		<div id="tools" class="mx-1 text-black">
				<div class="md:flex md:flex-wrap">	<!--- for mid-sized screens, wrap into columns --->

				<!--- Card # 1   Manage Components --->
				<div class="details-card">
					<div class="card-header">Manage Components</div>
					<div class="card-main flex">
						<div>	<!--- First column --->
							<div>
								<input type="radio" class="ml-1 mr-1" name="rdoCompGroup" id="REBATE_TYPE_ID" value="2" title="Select Rebate discount type components" onChange="loadComponentData(2)" /><label for="REBATE_TYPE_ID">Rebate</label>
								<input type="radio" class="ml-2 mr-1" name="rdoCompGroup" id="FIXED_TYPE_ID" value="1" title="Select Fixed Price discount type components" onChange="loadComponentData(1)" /><label for="FIXED_TYPE_ID">Fixed</label>			
							</div>

							<div id="componentStatus"></div>
							<div>
								<select name="cboCompName" id="cboCompName" style="width:150px; margin:2px 3px 8px 3px">
								</select>
							</div>

							<div>
								<button type="button" id="submitLabel" title="" class="button hidden" onClick="addNewComponent(arrObjSelectedComponent);">Add</button>
							</div>
						</div>
						
						<div class="ml-2">	<!--- Second column --->
							<div>Paid To</div>
							<select name="cboPaidTo" id="cboPaidTo" class="mb-2" style="margin-top:2px; width:120px;" onChange="updatePaidTo();">
							</select>

							<div>Payment Cycle</div>
							<div>
								<select name="cboPaymentCycle" id="cboPaymentCycle" class="mb-2" style="margin-top:2px; width:120px;" onChange="updatePaymentCycle();">
								</select>
							</div>
							<button type="button" id="uploadRates" title="Import products and rates to the currently selected Component" class="button" onClick="uploadCSV()">Upload Rates</button>
						</div>

						<div class="ml-3">	<!--- Third column --->
							<div>Claim Mechanic</div>
							<select name="cboClaimMechanic" id="cboClaimMechanic" class="mb-2" style="margin-top:2px; width:120px;" onChange="updateClaimMechanic();">
							</select>
							
							<div>GL Account</div>
							<div>
								<select name="cboGlAccount" id="cboGlAccount" class="mb-2" style="margin-top:2px; width:120px;" onChange="updateGlAccount()">
								</select>
							</div>
							<button type="button" id="downloadRates" title='Export the currently visible products and rates.  If there are multiple components, the rates from the "Editing" component will get exported.' class="button"  onClick="downloadRates()">Download Rates</button>
						</div>
					</div>
				</div>
				
				<!--- Card # 2 (OPTIONAL)  Select Payee --->
				<div class="details-card hidden" id="payeeOption">
					<form name="frmSelectedPayee">
					<!---  NOTE: The popup which populates the hidden variable "Vendor_ID", requires the name of the variable to be "Vendor_ID" (case sensitive).
					Hidden variable is only needed for "Vendor Search". For Distributor Search, The "getDistributorInfo" is called automatcally from the distributor
					popup page. --->
					<input type="hidden" name="Vendor_ID" id="Vendor_ID" class="mb-1" onChange="getVendorInfo(this.value);">
					<div class="card-header">Payee Option</div>
					<div class="card-main">
							<div id="selectedPayeeName" class="m-1">
							</div>
							<div>
								<input type="radio" class="ml-1 mr-1" name="rdoPayeeOptGroup" id="rdoPayeeSingle" value="1" title="" onClick="updatePayeeType()" /><label for="rdoPayeeSingle">Select a Single</label>
							</div>
							<div class="mb-1">
								<input type="radio" class="mb-1 ml-1 mr-1" name="rdoPayeeOptGroup" id="rdoPayeeEach" value="0" title="" onClick="updatePayeeType()" /><label for="rdoPayeeEach">Pay Each</label>			
							</div>

							<button type="button" id="selectPayee" title="" class="button" onClick="showPayeeSearch();">Select Payee</button>
						</div>
					</form>
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
				
			<!--- </div>  SAH Restore for 2 lines --->
			<!--- <div class="md:flex">	SAH Restore for 2 lines --->	<!---second row of cards if screen isn't large --->

				<!--- Card # 4  Optional - Distributor Rates --->
				<div id="selectedCustomers" class="details-card hidden">
					<div class="card-header" title="">
						Show / Hide Distributor Rates
					</div>
					<div class="card-main">
						<select name="drpSelectedCustomers" id="drpSelectedCustomers" multiple="multiple" class="border mr-2" onChange="showHideCustRates()">
						</select>
					</div>
				</div>
	
				<!--- Card # 5   (Conditional, for International Paper) Options --->
				<div id="custOptions" class="details-card hidden">
					<div class="card-header">Options</div>
					<div class="card-main">
						<div class="flex">
							<div class="ml-2">	<!--- First column --->
								<div># Colors</div>
								<select name="cboColors" id="cboColors" class="mb-2" style="margin-top:2px; width:40px;">
									<option value="0">#</option>
									<cfoutput>
										<cfloop from="1" to="9" index="i">
										<option value="#i#">#i#</option>
										</cfloop>
									</cfoutput>
								</select>
							</div>

							<div class="ml-3">	<!--- Second column --->
								<div>Graphics Complexity</div>
								<select name="cboGraphics" id="cboGraphics" class="mb-2" style="margin-top:2px; width:80px;">
									<option value="0">graphics</option>
									<option value="A">A</option>
									<option value="B">B</option>
									<option value="C">C</option>
								</select>
							</div>	
						</div>
						<div class="mb-2 ml-2 mt-1">
							<span>Digital Art:</span>
							<input type="radio" class="ml-1 mr-1" name="rdoComplexGrp" id="rdoComplexTrue" value="1" title="Include Complex Digital Art" /><label for="rdoComplexTrue">Yes</label>
							<input type="radio" class="ml-2 mr-1" name="rdoComplexGrp" id="rdoComplexFalse" value="0" title="No Complex Digital Art" checked /><label for="rdoComplexFalse">No</label>			
						</div>	

						<button type="button" id="updatePrintCharge" title='' class="button" onClick="updatePrintCharge()">Calculate</button>
				
					</div>
				</div>
			
				<!--- Card # 6   (Conditional, for International Paper) Convert --->
				<div id="convert" class="details-card hidden">
					<div class="card-header">Convert</div>
					<div class="card-main">
						<div class="mb-1 ml-2">from Print Group: NONE</div>
						<button type="button" id="getPrint" title='Get a list of possible Print Groups' class="button" onClick="getPrintGroups()">Get Print Groups</button>

						<div class="ml-2 mt-2">to</div>
						<select name="cboToPrinGroup" id="cboToPrinGroup" class="ml-2" style="margin-top:2px; width:180px;" onChange="convertItems(this.value)">
							<option value="0" id="0" >Print Group</option>
						</select>
					</div>
				</div>

			<!--- </div> SAH Restore for 2 lines --->
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

			<div>
				<span id="cadSection" style="display:none;">
					<input type="checkbox" name="chCAD" id="chCAD" value="1" onClick="showHideCurrencyConversion();" title="Show/Hide all the Canadian currency columns">
					<label for="chCAD" class="mr-3">show <cfoutput>#GetCurrency.Currency_Code#</cfoutput></label>
				</span>

				<button id="column_tool" class="button"></button>
			</div>
		</div>

		<!----------------->
		<!--- MAIN GRID --->
		<!----------------->
		<div id="Rate_Grid" style="height:200px;" class="ag-theme-balham mx-1 mt-1"></div>
			<cfinclude template="/Programs/product/Rate_Main_Grid.cfm">
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