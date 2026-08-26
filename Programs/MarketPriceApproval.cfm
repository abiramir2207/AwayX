<!---
  * ====================================================================================================
  *    @File: \Programs\MP\MarketPrice.cfm
  *  @Author: Sharon Harris
  *    @Date: January 2021
  *
  * @Remarks: Market Price approval
  *				adapted from: FlexDev\Forge\src\com\Program\MarketPrice\MarketPrice.mxml

  * ====================================================================================================
--->
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<cfparam name="url.duplicateprogram" type="string" 	default="false" />
<cfscript>
	Program_ID = cryp.value;
	obj = createobject("component", "mvc.Models.SettingsService");
	user = StructNew();
	user = obj.getUserObject(request.AccessStructure.User_ID);
	location = "/Common_Files/Contracts/contract_profit_analysis.cfm?CID=#URL.CID#&duplicateprogram=#url.duplicateprogram#";
</cfscript>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
</head>
<body>
	<style>
		* {
			box-sizing: border-box;
			margin-top: 0;
			margin-bottom: 0;
			padding: 0;
		}
		body {
			overflow: hidden;
		}
		label {
			font-size: 12px;
		}
		input[type=checkbox] {
			position: relative;
			top: 2px;
			margin: 3px 3px 3px 4px;
		}
		/* Two columns below the grid */
		.actionArea {
			display: flex;
			margin-top: 10px;
		}
		.actionArea .leftCol {
			width: 180px;
		}
		.actionArea .rightCol {
			flex: 0.7;
		}

		#actionMessage { 
			font-style: italic;
			color: red
		}
	</style>

	<!--- ~~~~~ Controls above the grid ~~~~~~ --->
	<div style="margin-top: 10px;">
		<label title="Filter to display only the items that require approval">
			<input type="checkbox" id="chbxFilter" checked onclick="filterApproval();"></input>
			View Approvals
		</label>
		<label style="margin-left: 20px;">Approval Threshold:
			<input type="text" id="tiApprovalPerc" size="15" readonly></input>
			<!--- text="{pModel.sMarketPriceVariance}" --->
		</label>
		<label style="margin-left: 10px;">Max Variance:
			<input type="text" id="tiMaxVariance" size="15" readonly></input>
			<!--- text="{percentFormat(pModel.maxVariancePercent, DEC2_PERCENTAGE_FMT)" --->
		</label>
	</div>

	<!--- ~~~~~ GRID ~~~~~~ --->
	<div id="price_grid" style="height:400px; margin-top: 8px;" class="ag-theme-balham">
	</div>


	<!--- ~~~~~ Action buttons below the grid ~~~~~~ --->
	<div class="actionArea">
		<div class="leftCol">
			<!--- Button text set by javaScript --->
			<button class="button recommended" id="actionButton" onclick="actionClick()"></button>
			<button class="button" id="cancelButton" title="Quit the approval process" onclick="cancelClick();">Cancel</button>
		</div>
		<div class="rightCol">
			<div id="actionMessage">

			</div>
		</div>
	</div>

	<cfset request.ag_grid_version = 24>
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
									"/common_files/jQueryUI.cfm",
									"/common_files/ag-grid.cfm",
									"/styles/css-loader.css"
									,"/script/javascript/numeral.min.js"
									,"/script/javascript/moment.min.js"
									] )#>
	<style>
		.ag-theme-balham .ag-header-group-text, 
		.ag-header-cell-text {
			/* margin: 0px auto 0px auto;		Center the header text */
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

	<!--- ----------------------------------------------------------------------- --->
	<script>
	<!--- ~~~~~~~ glob = global variables  ~~~~~~ --->
	var glob = {};
	const DEC2_PERCENTAGE_FMT = '(0,0.00)';
	var rowData_Price = [];
	glob.maxVariancePercent = 0.00;


	glob.price_grid = {
		defaultColDef: {
				  editable:         false
				, filter:          false
				, floatingFilter:  false
				, resizable:       true
				, sortable:        true
				, suppressMenu:    true
				, suppressMovable: false
				, unSortIcon:      false
		}
		,columnDefs: [
			{headerName: "Item",  field: 'itemNumber', width:70},
			{headerName: "Description",  field: 'description', width:450},
			{headerName: "UOM",  field: 'uomAbbreviation', width:60},
			{headerName: "Rate",  field: 'rate', type:'numericColumn', width:80, valueFormatter: currencyFormatter, filter: 'agNumberColumnFilter'},
			{headerName: "MP / CS",  field: 'rateMPCS', type:'numericColumn', width:80, valueFormatter: currencyFormatter},
			{headerName: "MP / LB",  field: 'rateMPLB', type:'numericColumn', width:80, valueFormatter: currencyFormatter},
			{headerName: "MP var",  field: 'varianceMP', type:'numericColumn', width:80, valueFormatter: currencyFormatter},
			{headerName: "MP % var",  field: 'variancePercMP', type:'numericColumn', width:80, valueFormatter: percentageFormatter, filter: 'agNumberColumnFilter'},
			{headerName: "",  field: 'rateMP', type:'numericColumn', width:80, valueFormatter: percentageFormatter, filter: 'agNumberColumnFilter', hide: true}
		]
		,enableRangeSelection:      false
		,pagination:                false
		,rowData: 					rowData_Price
		,rowModelType:              "clientSide"
		,suppressContextMenu:       true
		,suppressRowClickSelection: true
	}


	// Format currency (to 4 decimal pts)
	function currencyFormatter(params) {
		if(params.value == 0) {
			return '';
		}
		else{
			return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: 4});
		}
	}

	// Format percentage
	function percentageFormatter(params) {
		<!---
		// See FlexDev\Forge\src\com\Program\MarketPrice\models\MPGridManager.as, copied here
		// Where would rateMP come from? Do we need a hidden column to store it? Why not just use the value variancePercMP?
		//
		if(item.rateMP){
			return _decTwoFormat.format((item.rateMP - item.rate)/item.rateMP*100).toString() + '%';
		}
		else{
			return _decTwoFormat.format(0).toString() + '%';
		}
		--->
		return percentFormat(params.value, DEC2_PERCENTAGE_FMT);
	}

	function checkApprovalPermissions() {
		return false;
	}
	function hasOwnProperty(str) {
		return true;
	}

	function setActionLabel() {
		if (checkApprovalPermissions()) {
			$('#actionButton').html('Approve');
			$('#actionMessage').html(''); //Approve Market Price variances and continue with approval process.
		}
		else {
			$('#actionButton').html('Agree');
			$('#actionMessage').html('Current Market Price approval threshold (Profile <cfoutput>#user.stProfileSettings.PROFILES_DESC#</cfoutput>) does not allow Market Price approval.  You may "Agree" to Market Price and Continue with approval process.  Depending on Template and Profile settings, additional approval may be required.');
		}
	}

	function setsMarketPriceVariance(n){
		if(n == 99999){
			glob.sMarketPriceVariance = '*' ;
		}
		else{
			glob.sMarketPriceVariance = n.toFixed(2) + '%';
		}
		$('#tiApprovalPerc').val(glob.sMarketPriceVariance);
		$('#tiMaxVariance').val(glob.maxVariancePercent.toString() + '%');
		
	}
	function checkApprovalPermissions(){
		var bAllow = false;
		console.log(glob.maxVariancePercent);
		if(<cfoutput>#user.stProfileSettings.MARKET_PRICE_VARIANCE#.toFixed(2)</cfoutput> >= glob.maxVariancePercent){
			bAllow = true;
		}
		return bAllow;
	}

	function filterApproval() {
		var f = null;
		if($('#chbxFilter').prop("checked") == true){
			f = {
					variancePercMP: { type: 'notEqual', filter: '0.00' },
				    rateMP: { type: 'notEqual', filter: '0.00' }
				};
		}
		glob.price_grid.api.setFilterModel(f);
		glob.price_grid.api.onFilterChanged();
	}
		
	function actionClick(){
		if(checkApprovalPermissions()){
			approve();
		}
		else{
			continueClick();
		}
	}

	function cancelClick(){
		window.close();
	}
	
	function continueClick(){
		window.location.href = <cfoutput>'#location#'</cfoutput>;
	}

	function get_pricing() {
		$.ajax({
			url: "/mvc/models/Program/ProgramManager.cfc"
			,type: "POST"
			,async: true
			,dataType: "json"
			,data: {
					programId: <cfoutput>#cryp.value#</cfoutput>,
					bMarketPrice: 0,
					bProdRateItemDesc:1,
					includeGroupMembers:0,
					payeeType:'',
					fromBillback:0,
					bNewRateMP:1,
					method: "getProgramJSON"
			}
			,success: function (response) {
				var prg = JSON.parse(JSON.stringify(response));
				console.log(prg);
				prg.components.forEach(function(c){
				    console.log(c);
				    //if fixed
					if(c.type == 1){
						rowData_Price = rowData_Price.concat(c.prodRate)
					}

					rowData_Price.forEach(function(pr){
						if(pr.rateMP != 0){
							pr.varianceMP = pr.rateMP - pr.rate;
							pr.variancePercMP = (pr.rateMP - pr.rate)/pr.rateMP *100;
							if(pr.variancePercMP > glob.maxVariancePercent){
								glob.maxVariancePercent = Number(pr.variancePercMP.toFixed(2));
							}
						}
						else{
							pr.varianceMP = 0;
							pr.variancePercMP = 0;
						}
						if(!pr.MPApprovalVariance){
							//trace(pr.MPApprovalVariance.toString() + ' :: mpApprovalVar');
						}
						//If it is a group
						if(pr.itemNumber == pr.itemGuid){
							pr.itemNumber = 'Group';
						}
					});
				});
				console.log(rowData_Price)
				glob.price_grid.api.setRowData(rowData_Price);
				setsMarketPriceVariance(<cfoutput>#user.stProfileSettings.MARKET_PRICE_VARIANCE#</cfoutput>);
				setActionLabel();
				filterApproval();
			}
			,error: function (data) {
				alert('An error occurred.  ' + data.toString() );
			}
		});

	}

	function approve() {
		$.ajax({
			url: "/mvc/models/Template/MarketPriceManager.cfc"
			,type: "POST"
			,async: true
			,dataType: "json"
			,data: {
					programId: <cfoutput>#cryp.value#</cfoutput>,
					method: "approveMarketPriceProgram"
			}
			,success: function (response) {
				var oApproved = JSON.parse(JSON.stringify(response));
				console.log(oApproved);
				if(oApproved.BAPPROVED){
					continueClick();
				}
				else{
					alert('Approval failed: ' + oApproved.MESSAGE);
				}
			}
			,error: function (data) {
				alert('An error occurred.  ' + data.toString() );
			}
		});

	}

	// Once the page is loaded, 
	// Init the grid, load data, setup actions
	document.addEventListener("DOMContentLoaded", function () {
		ag_grid_default( glob.price_grid );
		init_ag_grid( glob.price_grid, "#price_grid" );
		get_pricing();
	});
	
	</script>
</body>
</html>