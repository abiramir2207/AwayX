<!---
  * ====================================================================================================
  *    @File: \billbacks\gm\settlement.cfm
  *  @Author: Sharon Harris
  *    @Date: July 2020
  *
  * @Remarks: Editing billbacks - settlements tab (under open billback tab)
  *				see: FlexDev\Forge\src\com\Billback\Edit\views\BBSettlementView.mxml
  *				and: FlexDev\Forge\src\com\Billback\Edit\views\pm\BBSettlementPModel.as
  *				grid: AwayX\FlexDev\Forge\src\com\Billback\Edit\models\BBClosingDetailGridManager.as
  * ====================================================================================================
--->
<cfprocessingdirective pageencoding = "utf-8">
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
</head>
<body onload="show_loader('Loading Data...');">
    <cfsavecontent variable="styles">
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
            iframe {
                border: 0;
                box-sizing: border-box;
                width: 100%;
                padding: 0;
            }
            header {
                margin: 0;
                padding: 0;
            }
            .hoverButton{
			  border: none;
			  /*width: 32px;*/
			  height: 32px;
			  background-color: #eee;
			  transition: all ease-in-out 0.2s;
			  cursor: pointer;
			}
			.hoverButton:hover{
			  border: 1px solid #888;
			  background-color: #ddd;
			}
        </style>
        <cf_include files="shared_styles.css, settlement.css">
		</cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    <cfparam name="URL.billbackIDInt" default="0">

    <cfset objSettings = createObject("component","mvc.Models.SettingsService") />
	<cfset oSettings = objSettings.getSettingsObject()/>


	<!--- SAH While Testing new hidden code --->
	<cfset WORK_IN_PROGRESS = false>
    <!--- ~~~~~~~~~~ top section ~~~~~~~~~~~ --->
	<main id="settlement_top">
	<cfif WORK_IN_PROGRESS>
		<p style="margin: 50px; color: gray; font-size: 26px;">Settlement - coming soon...</p>

	<cfelse><cfoutput>
		<div class="hdr-top">
			CTM ID ##: <span id="hdr_bbcode"></span> <!--- bb Code --->
			<span id="hdr_title"></span><br> <!--- bbheader title --->
			[<span id="hdr_bbtype"></span>] <!--- type descr --->
			<span id="hdr_status"></span> <!--- status descr --->
			<span id="hdr_upload_id"></span> <!--- bb Upload ID num --->
			Created by: <span id="hdr_creator"></span> <!--- creator --->
		</div>
		</cfoutput>

		<fieldset style="width: 850px">
			<div class="flex-container">
				<cfoutput>
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~ first column ~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<div class="flex-column">
					<div class="detail-row">
						<label>Account</label>
						<cfoutput><span class="label" style="max-width: 160px;" id="account_info"></span></cfoutput>
					</div>

					<div class="detail-row">
						<label>Reference</label>
						<cfoutput><span class="label" style="max-width: 160px;" id="reference"></span></cfoutput>
					</div>
					<!---

					<s:FormItem label="Budget" includeInLayout="{this.oSettings.appSettings.BudgetsFunctionalityOn}" visible="{this.oSettings.appSettings.BudgetsFunctionalityOn}">
						<mx:LinkButton label="{this.pModel.budgetLabel}"
									click="this.pModel.showBudget();"
									height="{this.pModel.iFrmHeight}" />
					</s:FormItem>
					--->

						<div class="detail-row">
							<label>Budget</label>
							<cfoutput><a href="##" id="budgetLabel" onClick="showWithinBudget();"></a></cfoutput>
						</div>


					<!---
					// AwayX\FlexDev\Forge\src\com\Billback\Edit\views\BBSettlementView.mxml
					<s:FormItem label="{this.pModel.oSettings.appFlex.billToLabel} #:" includeInLayout="{this.pModel.oSettings.appSettings.Multiple_BillTos_For_ShipTo &amp;&amp; this.pModel.acBillTo.length}" visible="{this.pModel.oSettings.appSettings.Multiple_BillTos_For_ShipTo &amp;&amp; this.pModel.acBillTo.length}">
						<rndr:BaDropDownList
							id="drpBillTo"
							change="this.pModel.drpBillToHandler(this.drpBillTo.selectedItem)"
							currentSelection="{this.pModel.billback.bbHeader.billTo}"
							dataProvider="{this.pModel.acBillTo}" labelField="billTo"
							enabled="{pModel.objBBToolsLock.bEditScreenEnabled &amp;&amp; this.pModel.bDrpBillToEnabled}"
							defaultSingle="true" />
					</s:FormItem>
					--->
					<cfoutput>
					<cfif '#oSettings.APPSETTINGS.Multiple_BillTos_For_ShipTo#' <!---&amp;&amp; this.pModel.acBillTo.length---> >
						<div class="detail-row">
							<label>Bill To:</label>
							<select name="drpBillTo" id="drpBillTo">
							</select>
						</div>
					</cfif>
					</cfoutput>
				</div>

				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~ second column ~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<div class="flex-column">
					<div class="detail-row">
						<label>Inv Date</label>
						<cfoutput><span id="invDate"></span></cfoutput>
					</div>
					<div class="detail-row"></div>

					<div class="detail-row">
						<label>Claimed</label>
						<cfoutput><span id="claimedAmount"></span></cfoutput>
					</div>
					<div class="detail-row"></div>
					<div class="detail-row">
						<label>Settlement ID</label>
						<cfoutput><span id="checknumber"></span></cfoutput>
					</div>
				</div>

				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~ third column ~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<div class="flex-column">
					<div class="detail-row">
						<label>Delivery Start</label>
						<cfoutput><span id="startDate"></span></cfoutput>
					</div>
					<div class="detail-row"></div>

					<div class="detail-row">
						<label>Expected</label>
						<cfoutput><span id="expectedAmount"></span></cfoutput>
					</div>
				</div>

				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~ fourth column ~~~~~~~~~~~ --->
				<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<div class="flex-column">
					<div class="detail-row">
						<label>Delivery End</label>
						<cfoutput><span id="endDate"></span></cfoutput>
					</div>
					<div class="detail-row"></div>

					<div class="detail-row">
						<label>Discrepancy</label>
						<cfoutput><span id="variedAmount"></span></cfoutput>
					</div>
				</div>
				</cfoutput>
			</div>
		</fieldset>
	</main>


	<section class="split">
		<!--- ~~~~~~~~~~ bottom Left section ~~~~~~~~~~~ --->
		<div class="details-card" id="ded_area">
			<div class="card-header">Deductions</div>
			<div class="card-main comp-container">
				<div class="detail-row">
					<input type="text" id="txtKeyWord">
					<button class="button" id="getdedButton">Search</button>
				</div>
				<div style="margin-bottom: 5px;">
					<label>Total
						<input type="checkbox" id="ckAmount"></input>
					</label>
					<label style="margin-left: 10px;">Account
						<input type="checkbox" id="ckDistributor"></input>
					</label>
					<label style="margin-left: 10px;">Balance
						<input type="checkbox" id="ckBalance"></input>
					</label>
				</div>

				<!---  bottom Left grid   --->
				<div id="ded_grid" style="height:300px;" class="ag-theme-balham">
				</div>
			</div>
		</div>

		<!--- ~~~~~~~~~~ bottom Right section ~~~~~~~~~~~ --->
		<div class="details-card" id="closing_area">
			<div class="card-header">Closing Details</div>
			<div class="card-main comp-container">
				<div>
					<label>Approved </label><span id="finalSelectedAmount">$0.00</span>
					<label>Balance </label><span id="nClosingRemainder">$0.00</span>
				</div>
				<div class="hidden">
					<label>Error </label><span id="sEditClosingDetailResult" style="color:red"></span>
				</div>

				<!---  bottom Right grid  --->
				<div id="closing_grid" style="height:200px; margin-top: 5px;" class="ag-theme-balham">
				</div>

				<div class="horiz-aligner">
					<label>Special Handling
						<input type="checkbox" id="ckSpecialHandle"></input>
					</label>
					<label style="margin-left:10px;">Remittance</label>
					<textarea id="taRemit" rows="2" cols="1" maxlength="45">
					</textarea>
				</div>
				<div style="margin-top: 20px; margin-bottom:10px;">
					<button class="button" id="deviationButton">Deviation</button>
					<button class="button" id="closeSettlement">Close</button>
					<span style="margin-right:40px;"> </span>

					<button class="button" id="disagreeButton">Disagree</button>
					<button class="button" id="submitButton">Agree</button>
				</div>

				<button class="button hoverButton" onclick="showDiscrepancyReport();">Discrepancy report</button>

			</div>
		</div>
	</section>
	</cfif>

<!------- & st.ClosingMethod.description & '", amount:"' & st.Amount & '", deductionNumber:"' & st.Deduction.deductionNumber & '", id:"' & st.ClosingMethod.id &'"}'    ---->

   		<!---  <cfloop index="i" from="1" to="#arrayLen(arrDetail)#">
   		 	<cfdump var="#st#">
   		 	-- <cfset sDetail = sDetail & '{"description":"' & st.ClosingMethod.description & '"},' >	----
		</cfloop>
		<cfabort>
 --->
  	<cfset request.ag_grid_version = "23">
	<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
									"/common_files/jQueryUI.cfm",
									"/common_files/ag-grid.cfm",
									"/styles/css-loader.css",
									"/script/javascript/moment.min.js"
									] )#>
	<style>
		.ag-theme-balham .ag-header-group-text,
		.ag-header-cell-text {
			margin: 0px auto 0px auto;		/* Center the header text */
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
<!--- 	<cfset arrDetail = bbheader.BBSettlement.bbClosingDetail> --->


	<cfset stProfileSettings = StructNew()/>
	<cfset obj = createObject("component","components.user.Profile") />
	<cfset tmp = obj.getProfileSettings(request.AccessStructure.Profiles_ID)>
	<cfloop list="#tmp.columnlist#" index="i">
		<cfset s = "tmp." & i>
		<cfset structinsert(stProfileSettings,i,evaluate(s),true)>
	</cfloop>

    <script>
    	<!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        var glob = {};
        var bb = {};
        var rowData_Closing = [];
        var bEditable = false;
        var bbSettlementAction = {};
        var nClosingRemainder = 0;
<cfoutput>let bbIdInt = #URL.billbackIDInt#;
		var #ToScript(stProfileSettings, "stProfileSettings")#;
		var #ToScript(oSettings.APPSETTINGS, "appSettings")#;
</cfoutput>
		//let this = {};
		//Called any time a closing method is Modified.  recalc the remainder and decide if things are in an approvable state

		const fmt_dt = 'MMMM DD YYYY hh:mm:ss';
		let DEDUCTION_ID = 2;
		let DESCRIPTION = 'Deduction';

		let PAYMENT_ID = 1;
		let PAYMENT_EFT_ID = 8;
		let WRITEOFF_ID = 9;
		let REINSTATE_ID = 10;
		let DEBIT_ID = 6;
		let CREDIT_ID = 4;
		let CLOSING_METHOD_ORDER = [1,8,2,10,9,5,6,4,7];
		/* Closing method list for Operator Payee */
		let CLOSING_METHOD_ORDER_OPERATOR = [1,8,4,7,5,6];
    	// Closing Details Grid setup
		  ///{description:"Payment", amount:"$0.00"}, {description:"Credit Memo", amount:"$0.00", deductionNumber:"1"}
		'use strict';

		// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
		// document.addEventListener("DOMContentLoaded", function () {
		// 	$( ".button" ).prop("disabled", true);
		// 	buildDeductionGrid();
		// 	buildClosingGrid();
		// 	get_billback(bbIdInt);
		// });

		function buildDeductionGrid() {
			ag_grid_default( glob.ded_grid );
        	init_ag_grid( glob.ded_grid, "#ded_grid" );
		}
		function buildClosingGrid() {
			ag_grid_default( glob.closing_grid );
        	init_ag_grid( glob.closing_grid, "#closing_grid" );
		}

		$('#taRemit').change(function(){
		    var sText = $(this).val();
		    bb.bbheader.bbsettlement.paymentnotes = sText;
		});

		$('#ckSpecialHandle').change(function(){
		    var bCheck = $(this).prop("checked");
		    bb.bbheader.bbsettlement.bspecialhandling = bCheck;
		});

		var start = Date.now();

		function get_billback(bbIdInt,bRefreshSearch = 0){
			show_loader_settle('Loading Data...');
			start = Date.now();
				$.ajax({
					url: "/mvc/models/Billback/BillbackManager.cfc"
					,type: "POST"
					,async: false
					,dataType: "json"
					,data: {
						method: "getBillbackJSON"
						,billbackIDInt: bbIdInt
						,copyAction: 0
					}
					,success: function (response) {
						bb = response;
						displayBB();
						if(bRefreshSearch){
							if (typeof window.parent.parent.refreshSearchRow !== "undefined") {
			                	window.parent.parent.refreshSearchRow(bb);
			                }
						}
					// getLock calls  -> tallyClosingRemainder();
					//$("div.loader").hide();
					}
					,error: function (data) {
						alert('An error occurred.  ' + data.toString() );
					}

				});
		}

		function displayBB(){
			show_loader_settle('Re-Loading Data...');
			var bcd = bb.bbheader.bbsettlement.bbclosingdetail;
			var a = [];
			//loop over the operator closing methods if the payee type is operator
			//payye type is operator
			if(bb.bbheader.payee.payeetypeid == 2){
				for (var x in CLOSING_METHOD_ORDER_OPERATOR){
					var n = 0;
					for (var i in bcd){
						if(CLOSING_METHOD_ORDER_OPERATOR[x] == bcd[i].closingmethod.id){
							if(n == 0){
								a.push(bcd[i]);
							}
							n++;
						}
					}
				}
			}
			//payye type is distributor
			else{
				for (var x in CLOSING_METHOD_ORDER){
					var n = 0;
					for (var i in bcd){
						if(CLOSING_METHOD_ORDER[x] == bcd[i].closingmethod.id){
							if(n == 0){ //Deduction can have 2 records
								a.push(bcd[i]);
							}
							n++;
						}
					}
				}
			}
			bb.bbheader.bbsettlement.bbclosingdetail = a;
			rowData_Closing = JSON.parse(JSON.stringify(bb.bbheader.bbsettlement.bbclosingdetail));
			glob.closing_grid.api.setRowData(rowData_Closing);
			glob.closing_grid.api.doLayout();

			$('#account_info').html(bb.bbheader.payee.name + '<br>' + bb.bbheader.payee.payeeid + '<br>' + bb.bbheader.payee.address.addressline1 + '<br>' + bb.bbheader.payee.address.city + '<br>' + bb.bbheader.payee.address.state +', ' + bb.bbheader.payee.address.zipcode);
			$('#reference').html(bb.bbheader.referencenumber);
			$('#checknumber').html(bb.bbheader.checknumber);
			$('#finalSelectedAmount').html(dollarFormat(bb.bbheader.finalselectedamount));
			$('#invDate').html(moment(bb.bbheader.bbdate, fmt_dt).format('L'));
			$('#claimedAmount').html(dollarFormat(bb.claimedamount));
			$('#startDate').html(moment(bb.bbheader.startdate, fmt_dt).format('L'));
			$('#expectedAmount').html(dollarFormat(bb.bbheader.expectedamt));
			$('#endDate').html(moment(bb.bbheader.enddate, fmt_dt).format('L'));
			$('#variedAmount').html(dollarFormat(bb.claimedamount - bb.bbheader.expectedamt));
			$('#hdr_bbcode').html(bb.bbheader.bbcode);
			$('#hdr_title').html(bb.bbheader.title);
			$('#hdr_bbtype').html(bb.bbheader.bbtype.description);
			$('#hdr_status').html(bb.bbheader.uploadid);
			$('#hdr_upload_id').html(bb.bbheader.status.description);
			$('#hdr_creator').html(bb.bbheader.creator.fullname);
			$('#budgetLabel').html(bb.bbheader.bbsettlement.bisbillbackwithinbudget ? 'within budget' : 'over budget');
			$('#ckSpecialHandle').prop( "checked", bb.bbheader.bbsettlement.bspecialhandling );
			$('#taRemit').val(bb.bbheader.bbsettlement.paymentnotes);
			//$('#finalSelectedAmount').html();
			//  moment().format('L')

			getLockUnlockBB();
        }

		function dollarFormat(value) {
			if (value == '0' || value == ''){
				return '$0.00';
			}
			else {
				return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
			}
		}

		function get_Deductions(){
			var bbdf = {};
			bbdf.iBillbackId 		= bbIdInt;
			bbdf.bAmount 			= $('#ckAmount').prop("checked");
			bbdf.bDistributor 		= $('#ckDistributor').prop("checked");
			bbdf.bBalance			= $('#ckBalance').prop("checked");
			bbdf.sKeyword 			= $('#txtKeyWord').val();
			bbdf.nBalance			= nClosingRemainder;
			bbdf.strDistributorId	= "";
			var s = JSON.stringify(bbdf);
			show_loader('Loading Deductions...');
				$.ajax({
					url: "/mvc/models/Deduction/DeductionManager.cfc"
					,type: "POST"
					,async: true
					,dataType: "json"
					,data: {
						method: "getDeductionsJSON"
						,bbDeductionFilterParms: s
					}
				})
				.then( (response) => {
					var dd = response;
					rowData_Ded = dd;
					glob.ded_grid.api.setRowData(rowData_Ded);
					glob.ded_grid.api.doLayout();
					$("div.loader").hide();
				})
		}

		function lockDeduction(dd,bLock){
			show_loader('Locking Deduction...');
				$.ajax({
					url: "/mvc/Models/Billback/BillbackSettlementManager.cfc"
					,type: "POST"
					,async: true
					,dataType: "json"
					,data: {
						method: "lockDeductionJSON"
						,arrDeduction: JSON.stringify([dd])
						,bLock: bLock
					}
				})
				.then( (response) => {
					var newdd = response;
					applyDeductions(newdd,bLock);
				})
				.then($("div.loader").hide());
		}

		function approveSettlement(){
			show_loader('Approving...');
			cleanBBClosingDetail();
				$.ajax({
					url: "/mvc/Models/Billback/BillbackSettlementManager.cfc"
					,type: "POST"
					,async: true
					,dataType: "json"
					,data: {
						method: "approveBillbackSettlementJSON"
						,bbHeader: JSON.stringify(bb.bbheader)
						,argAction: JSON.stringify(bbSettlementAction)
					}
					,success: function (data) {
						if(typeof data.STRERRORMESSAGE !== 'undefined'){
							if(data.STRERRORMESSAGE != ''){
								alert(data.STRERRORMESSAGE);
								$('#sEditClosingDetailResult').html(data.STRERRORMESSAGE + '\n');// + sEditClosingDetailResult
								$('#sEditClosingDetailResult').show( "fast" );
								$('.hidden').show( "fast" );
							}
						}
						get_billback(bb.bbheader.billbackidint,1);
						if (typeof window.parent.refreshBBEdit() !== "undefined") {
		                	window.parent.refreshBBEdit();
		                }
						$("div.loader").hide()
					}
					,error: function (data) {
						//console.log(' ------ ERROR ON APPROVE  -------');
						//console.log(data);
		                //alert('An error occurred.  ' + data.toString() );
		                get_billback(bb.bbheader.billbackidint,1);
						$("div.loader").hide()
		            }

				});

		}

		function getLockUnlockBB(){
			//show_loader('Checking Permissions...');
			if( !(Number.isInteger(bb.bbheader.billbackidint) && (bb.bbheader.billbackidint > 0) ) ) {
				return;
			}

			bEditable = false;

			$.ajax({
					async: true
					,dataType: 'json'
					,data: { 	billbackIDInt : bb.bbheader.billbackidint,
								unlockExistingLockedByUser:  false,
								method: "getLockUnlockBBJSON" }
					//,dataType: "json"
					,success: function (data) {
						var objLock = data;
						//$("#editToggleBtn").addClass("recommended");
						//Not Locked
						$( ".button" ).addClass("recommended");
						$( ".button" ).prop("disabled", false);
						 if(data.objidlocked === data.objid && data.userlocked.id === <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput> && bb.bbheader.status.substatus != 3){
							// if(data.objidlocked != '' && data.objidlocked != data.objid){
							// 		alert("Please unlock this billback that is locked by you: (" + data.objidlockeddesc + ") .");
							// 	}
							bEditable = true;
							$('#deviationButton').click(function() {
									showDeviations();
								});
						}
						else{
							$('#deviationButton').off( "click" );
							$('#deviationButton').removeClass("recommended");

						}
						tallyClosingRemainder();
						getBillTo();
						$("div.loader").hide();
		            }
		            ,error: function (data) {
		                alert('An error occurred.  ' + data.toString() );
		            }
					,type: "post"
					,url: "/mvc/Models/Billback/BillbackManager.cfc"
				});
		}



		function EditCellRenderer() {
		}

		EditCellRenderer.prototype.init = function (params) {
		    this.eGui = document.createElement('span');

		        var jsCode = "JavaScript: openPopup('/deductions/inc_deduction_details.cfm?Display=Preview&Deduction_ID="+params.value+"', 800, 800)";
		        this.eGui.innerHTML = '<a onClick="'+jsCode+'" title="View Deduction '+'" STYLE="cursor: pointer;">view</a>';
		};

		EditCellRenderer.prototype.getGui = function () {
		    return this.eGui;
		};
		// gets called whenever the user gets the cell to refresh
		EditCellRenderer.prototype.refresh = function(params) {
		    this.eGui = document.createElement('span');
		    var jsCode = "JavaScript: openPopup('/deductions/inc_deduction_details.cfm?Display=Preview&Deduction_ID="+params.value+"', 800, 800)";
		    this.eGui.innerHTML = '<a onClick="'+jsCode+'" title="View Deduction '+'" STYLE="cursor: pointer;">view</a>';
		    return true;
		};


		// Deductions Grid setup
		var rowData_Ded = [];

		glob.ded_grid = {
			defaultColDef: {     editable:         false
								, filter:          'agTextColumnFilter'
								, floatingFilterComponentParams: { suppressFilterButton: true }
								, floatingFilter:  true
								, resizable:       true
								, sortable:        true
								, suppressMenu:    true
								, suppressMovable: false
								, unSortIcon:      false
			}
			,columnDefs: [
				{headerName: "Deduction #",  field: 'deductionNumber', width:150},
				{headerName: "Amount",  field: 'amount', type:'numericColumn', width:100, valueFormatter: currencyFormatter, filter: 'agNumberColumnFilter'},
				{headerName: "",  field: 'deductionID', filter:false, width:65,
						cellRendererSelector:function (params) {
							            var editFormullaLink = { component: 'editCellRenderer' };
							            return editFormullaLink;
						}
				}
			]
			,enableRangeSelection:      false
			,pagination:                false
			,rowData: 					rowData_Ded
			,rowModelType:              "clientSide"
			,suppressContextMenu:       true
			,suppressRowClickSelection: true
			,statusBar: footerbar("filtered_and_total")
			,components:{
			        editCellRenderer: EditCellRenderer,
			    }
			,onRowDoubleClicked: function (params) {
					if(bb.bbheader.status.id == 2 && bb.bbheader.finalselectedamount != 0 && bEditable === true){ ///rfa
						lockDeduction(params.data,true);
						$('#sEditClosingDetailResult').hide();
						$('.hidden').hide();
					}
					else if( bb.bbheader.finalselectedamount == 0 ){
						//return;
						$('#sEditClosingDetailResult').html('Please choose a closing amount (run deviations).');
						$('#sEditClosingDetailResult').show( "fast" );
						$('.hidden').show( "fast" );
					}
					else if(bb.bbheader.status.id != 2){
						//return;
						$('#sEditClosingDetailResult').html('Applying deductions after approval not allowed.');
						$('#sEditClosingDetailResult').show( "fast" );
						$('.hidden').show( "fast" );
					}
			    }
		}


		glob.closing_grid = {
			defaultColDef: {     editable:         false
								, filter:          false
								, floatingFilter:  false
								, resizable:       true
								, sortable:        true
								, suppressMenu:    true
								, suppressMovable: false
								, unSortIcon:      false
			}
			,columnDefs: [
				{width:40, filter:false,
					cellRenderer: function(params) {
						let delCel =
							'<div style="margin-left:9px; margin-top:3px;">' +
								'<img alt="delete row" title="delete this row" src="/Images/delete2.png">'+
							'</div>';
						return delCel;
					},
					onCellClicked: function(params) {
						deleteRow(params);
					}
				},
				{headerName: "Closing Method",  field: 'closingmethod', width:150,
						valueFormatter: function (params) {
		    			if (typeof params.value !== 'undefined'){
				   			return params.value.description;
				   		}
					    return '';
		    		}
		    	},
				{headerName: "Amount",  field: 'amount', type:'numericColumn', width:80, valueFormatter: currencyFormatter, cellClass: ['twoDecimalPlacesDollar','textRight','editable'], filter: 'agNumberColumnFilter',
					editable:function(params) {
								if(bEditable === true && params.node.data.closingmethod.id !== DEDUCTION_ID && bb.bbheader.status.id === 2){
									return true;
								}
					            return false;   //params.node.data.item_bracket === 3
						   	},
					cellClass: function(params) {
								if(bEditable === true && params.node.data.closingmethod.id !== DEDUCTION_ID && bb.bbheader.status.id === 2){
									return ['twoDecimalPlacesDollar','textRight','editable'];
								}
						            return ['twoDecimalPlacesDollar','textRight'];
						    }
				},
				{headerName: "Deduction",  field: 'deduction', width:180,
					valueFormatter: function (params) {
		    			if (typeof params.value !== 'undefined' &&  params.value !== null ){
				   			return params.value.deductionnumber;
				   		}
					    return '';
		    		}
				}
			]
			,enableRangeSelection:      false
			,pagination:                false
			,rowData: 					rowData_Closing
			,rowModelType:              "clientSide"
			,suppressContextMenu:       true
			,suppressRowClickSelection: true
			,onCellValueChanged: function(event) {
		        if(event.oldValue != event.newValue){
		        	var s = event.colDef.field;
		        	saveAmount(event, event.colDef.field);
				}
	        }
	    }

	    //result handler for remote call BBEditEvent.LOCK_DEDUCTION
		function applyDeductions(arr,bLockAction){
			/*set var to be used after we try to lock deductions*/
			var arrNotLockedDeductions = [];
			var s = '';
			var cmDeduction;
			//get deduction closing method
			for (var i in rowData_Closing){
				var closeDetail = rowData_Closing[i];
				var cm = closeDetail.closingmethod;
				if (cm.id == 2){
					for (var x in arr){
							//dd = arr[x];
							var loopdd = arr[x];
							//if the deduction is locked and it is locked by me
							if(loopdd.lockObj.BLOCKED){											/// && dd.lockObj.userLocked.id == this.oSettings.userId     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      TODO     TODO   TODO
								//addClosingMethod(cmDeduction,false);
								//this.bbClosingdetail = closeDetail;//from loop above		LOOP IN A LOOP    *************
								//rowData_Closing[i].deduction = arr[x];
								rowData_Closing[i].deduction.deductionnumber = arr[x].deductionNumber;
								rowData_Closing[i].deduction.amount = arr[x].amount;
								rowData_Closing[i].deduction.deductionid = arr[x].deductionID;
								rowData_Closing[i].amount = arr[x].amount;
								//saveDeduction(dd);   TODO :: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX			DO WE NEED
							}
							else{
								arrNotLockedDeductions.push(loopdd.deductionNumber);
								s = s + loopdd.deductionNumber + ': locked (' + loopdd.lockObj.BLOCKED + ') ' + 'user (' + loopdd.lockObj.USERLOCKED.FULLNAME + ')' + '\n';
							}
						}
					break;
				}
			}
			if(cmDeduction){
				//insert each ded that is selected
				// for (var x in arr){
				// 	dd = arr[x];
				// 	//if the deduction is locked and it is locked by me
				// 	if(dd.lockObj.BLOCKED){											/// && dd.lockObj.userLocked.id == this.oSettings.userId     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      TODO     TODO   TODO
				// 		//addClosingMethod(cmDeduction,false);
				// 		//this.bbClosingdetail = closeDetail;//from loop above		LOOP IN A LOOP    **************
				// 		//saveDeduction(dd);   TODO :: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX			DO WE NEED
				// 	}
				// 	else{
				// 		arrNotLockedDeductions.push(dd.deductionNumber);
				// 		s = s + dd.deductionNumber + ': locked (' + dd.lockObj.BLOCKED + ') ' + 'user (' + dd.lockObj.USERLOCKED.FULLNAME + ')' + '\n';
				// 	}
				// }
			}
			//if we are trying to lock a deduction but it fails (already locked etc) show a message
			if(arrNotLockedDeductions.length && bLockAction){
				alert(s);
			}
			tallyClosingRemainder();
		}

	/*	function saveDeduction(dd){   		TODO  TODO TODO  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX DO WE NEED THIS
			var bSave = true;

			if(!this.oSettings.appSettings.Allow_Multiple_Deduction_Settlement && (this.bbClosingdetail.deduction && this.bbClosingdetail.deduction.deductionID != '')){
				//this.unLockDeductions(new Array(this.bbClosingdetail.deduction));
				var event:MainEvent = new MainEvent(MainEvent.CLEAR_ROW);
				event.objRowData = this.bbClosingdetail;
				this.clearRow(event);
			}

			bbClosingdetail.deduction = dd;
			bbClosingdetail.amount = dd.amount;
			tallyClosingRemainder();

		}*/



		function saveAmount(event, field){ // Save a single rows'
			var data = event.data;
			var nAmount = data.amount;
			var bError = false;
			var sColName = field;
			var sError = 'please enter a valid ' + sColName;
			sEditClosingDetailResult = '';
			//sEditClosingDetailResult = 'event: ' + event.reason + ' :: ' + event.rowIndex.toString() + ' :: ' + event.target.id + '\n' + sEditClosingDetailResult ;
			//switch event.dataField and run validations

			var bDeductionExists = false;

			/* Loop over the closing methods and check whether the deduction amount is not zero. */
			for (var i in rowData_Closing){
				var closeDetail = rowData_Closing[i];
				var cm = closeDetail.closingmethod;
				var cmAmt = closeDetail.amount;
				if (cm.id == 2 && cmAmt != 0){
					bDeductionExists = true;
					break;
				}
			}

			switch(field)
			{
				case 'amount':
					//var data:BBClosingDetail = event.itemRenderer.data as BBClosingDetail;

					//adjust the sign
					nAmount = cleanAmountBasedOnClosingMethod(data.closingmethod.id,nAmount);

					if(nAmount == 0 || isNaN(nAmount)){
						//error
						bError = true;
						sError = 'please enter a valid number';
					}
					else if(nAmount > bb.bbheader.finalselectedamount && (data.closingmethod.id == PAYMENT_ID || data.closingmethod.id == PAYMENT_EFT_ID )){
						//error
						bError = true;
						sError = 'please enter a number less than the approved amount: ' + bb.bbheader.finalselectedamount;
					}
					else if(data.closingmethod.id == REINSTATE_ID && bDeductionExists == false){
						//error
						bError = true;
						//sError = 'please enter a positive number for deduction before entering an amount for reinstate';
						/* Reinstate goes with deduction only */
						sError = 'please enter a value for deduction before entering an amount for reinstate';

					}
						/*else if(data.closingMethod.id == ClosingMethod.REINSTATE_ID || data.closingMethod.id == ClosingMethod.WRITEOFF_ID){
						//make negative
						nAmount = Math.abs(nAmount) * -1;
						s = nAmount.toString();
						this.bbClosingdetail.amount = Number(s);
						ti.text = s;
						}
						else if(Number(s) < 0 ){
						//error
						bError = true;
						sError = 'please enter a positive number.';
						}*/
					else{
						data.amount = nAmount;
						//ti.text = nAmount.toString();
					}
					break;
				/*	case 'specialHandling':
				if(s.length < 4){
				//error
				bError = true;
				}
				break;*/
				default:
					//trace("Out of range");
					break;
			}
			//update the ui
			if(bError){
				//error
				//re-set the data
				nAmount = 0;
				data.amount = 0;
				event.node.setData(data);
				//UI
				$('#sEditClosingDetailResult').html(sError + '\n');// + sEditClosingDetailResult
				$('#sEditClosingDetailResult').show( "fast" );
				$('.hidden').show( "fast" );
				//	highlightError(event.currentTarget.itemEditorInstance as TextInput);
			}
			else{
				//ok
				$('#sEditClosingDetailResult').hide();
				$('.hidden').hide();
			}
			tallyClosingRemainder();
		}

		//Set values to appropriate sign ( + or - )
		function cleanBBClosingDetail(){
			var arr = [];
			var cmId = 0;
			var amount;

			for (var i in rowData_Closing){
				var closeDetail = rowData_Closing[i];
				cmId = closeDetail.closingmethod.id;
				if(closeDetail.amount != 0){
					closeDetail.amount = cleanAmountBasedOnClosingMethod(cmId,closeDetail.amount);
					arr.push(closeDetail);
				}
			}
			//rowData_Closing = arr;
			bb.bbheader.bbsettlement.bbclosingdetail = arr;
		}

		//Set values to appropriate sign ( + or - )
		function cleanAmountBasedOnClosingMethod(cmId,amount){
			//POSITIVE
			if(cmId ==PAYMENT_ID || cmId == PAYMENT_EFT_ID || cmId == CREDIT_ID){
				amount = Math.abs(amount);
			}
			//NEGATIVE
			if(cmId == REINSTATE_ID || cmId == DEBIT_ID){
				amount = (Math.abs(amount) * -1);
			}
			// EITHER WAY: cmId == ClosingMethod.WRITEOFF_ID ||
			return amount;
		}

		var arrBillTo = [];

		$('#drpBillTo').change(function(){
		    var billto = JSON.parse(decodeURIComponent($(this).find(":selected").data("value") ) );
		    bb.bbheader.billto = billto;
		    $("#drpBillTo option[value='']").remove();

		});
		// populate bill to drop down
		function getBillTo(){
				arrBillTo = [];
				$('#drpBillTo').empty();
				$('#drpBillTo').prop('disabled', 'disabled');
				if (bb.bbheader.payee.payeetypeid != 1){
					return;
				}
				$.ajax({
					url: "/mvc/Models/Billback/BillbackEditSearchManager.cfc"
					,type: "POST"
					,async: true
					,dataType: "json"
					,data: {
						method: "getBillToDataJSON"
						,distributorId: bb.bbheader.payee.payeeid
					}
				})
				.then( (response) => {
					arrBillTo = response;
					if(bb.bbheader.billto.billtoid == ''){
						$('#drpBillTo').append('<option value=""  data-value= ""></option>');
					}
					for (var i = 0; i < arrBillTo.length; i++) {
				        $('#drpBillTo').append("<option value='" + arrBillTo[i].billtoid + "'  data-value= '" + encodeURIComponent(JSON.stringify(arrBillTo[i])) + "'>" + arrBillTo[i].billto + "</option>");
				    }
				    if(bb.bbheader.billto.billtoid != ''){
				    	 $('#drpBillTo').val(bb.bbheader.billto.billtoid);
				    }
				    if(bEditable && bb.bbheader.status.id == 2){
			        	$('#drpBillTo').prop('disabled', false);
			        }
				})
		}

		function tallyClosingRemainder(){
			var nAmount = 0;
			var dedAmount = 0;
			var nonCloseMethAmount = 0;
			var ded;
			var dedRemainder = 0;
			var cmId = 0;
			// by default the user can approve the DD write off we will check and set it to false so the use can only agree.
			var isDDWriteOffApprovable= true;
			var ddWriteOffAmount = 0;
			//var stProfileSettings = this.oSettings.user.stProfileSettings;
			var	strDDWriteOffAmt = stProfileSettings.dd_match_central_write_off_amount;
			//determine Save Button text.  Save method will also check
			var deviAmount = bb.bbheader.finalselectedamount - bb.bbheader.expectedamt;
			var approveAmount = stProfileSettings.bb_tot_approve_amount;
			var approveDeviAmount = stProfileSettings.bb_approve_amount;
			$('#submitButton').prop('text', 'agree');
			$('#submitButton').html("Agree");
			bbSettlementAction.action = 'agree';
			//sEditClosingDetailResult = '';
			//check if it is in list and get remainder

			// CLEAR UI
			$('#submitButton').off( "click" );
			$('#submitButton').removeClass("recommended");
			$('#disagreeButton').off( "click" );
			$('#disagreeButton').removeClass("recommended");
			//$('#getdedButton').off( "click" );
			//$('#getdedButton').removeClass("recommended");
			$('#getdedButton').click(function() {
								get_Deductions();
							});
			$( "#taRemit" ).prop("disabled", true);
			$( "#ckSpecialHandle" ).prop("disabled", true);

			if (strDDWriteOffAmt == '*')
			{
				// do nothing as isDDWriteOffApprovable is already true

			}
			else if(strDDWriteOffAmt == '0' || strDDWriteOffAmt == '')
			{
				// isDDWriteOffApprovable = false;
				ddWriteOffAmount = 0;
			}
			else
			{
				//isDDWriteOffApprovable = false;
				// ddWriteOffAmount = 	stProfileSettings.dd_match_central_write_off_amount;
				ddWriteOffAmount = 	parseFloat(stProfileSettings.dd_match_central_write_off_amount);
			}
			//Loop over Closing Detailsl to sum up Amounts. nAmount = real closing methods.  Not reinstate or writeoff.  dedAmount = deduction Amount.
			//nonCloseMethAmount = writeoff  + Reinstate amounts
			for (var i in rowData_Closing){
				var closeDetail = rowData_Closing[i];
				cmId = closeDetail.closingmethod.id;
				//closeDetail.amount = closeDetail.amount;
				/*	Tim Ford 02/13/2012 - Label 30371: BB Settlement - Cannot approve after save as balance does not add up
				Put the code below in place to handle for Re-Instate and Write-Off Split Deductions that have been saved to the DB.
				We don't want to calculate these deductions into the amount because they will cause the balance to not
				add up correctly.
				*/
				if (closeDetail.amount !== 0
						&&
						(
							(	cmId != WRITEOFF_ID && cmId != REINSTATE_ID) 
							||
							(	
								closeDetail.deduction == null  
								||
								(
									typeof(closeDetail.deduction.spnumber) !== "undefined" 
									&&
									closeDetail.deduction.spnumber === ''
								)
							)
						)
					)
				{
					nAmount = Number(nAmount) + Number(closeDetail.amount);
				}

				//get deduction info
				if(cmId == DEDUCTION_ID && closeDetail.amount != 0){
					dedAmount = Number(closeDetail.amount);
					ded = closeDetail.deduction;
				}
				//sum non closing method amounts writeoff + re-instate
				if((cmId == WRITEOFF_ID || cmId == REINSTATE_ID) && closeDetail.amount != 0){
					nonCloseMethAmount = Number(nonCloseMethAmount) + Number(closeDetail.amount);
				}
			}
			//closing Remainder is the Balance of This BB that is not accounted for.
			nClosingRemainder = Number(bb.bbheader.finalselectedamount) - Number(nAmount);
			nClosingRemainder = Number(nClosingRemainder.toFixed(2));
			//nClosingRemainder = nClosingRemainder.trimNum(2,'round');
			$('#nClosingRemainder').html(dollarFormat(nClosingRemainder));
			//bbDeductionFilterParm.nBalance = nClosingRemainder;			******************************   TODO: IMPLEMENT IN js 9/9/2020
			bbSettlementAction.balance = nClosingRemainder;
			///dedRemainder = dedAmount - bb.bbHeader.finalselectedamount;   ****** Not used I think 9/9/2020

			/* now set writeoff or reinstate deduction properties
			if the Total Amounts selected [not write off or reinstate] > selectedAmount and a ded exists, then
			write off or reinstate gets applied to the deduction else to the BB
			....Only update if it is editable 		&& bb.bbheader.status.id == 2		*/
			if(bEditable && bb.bbheader.status.id == 2){
				for (var x in rowData_Closing){
					var closeDetail2 = rowData_Closing[x];
					var i2 = closeDetail2.closingmethod.id;
					//reinstate is always associated to deduction
					if(i2 == REINSTATE_ID){

						closeDetail2.deduction = ded;
					}
					//Handle for Write OFF -> writeoff swings both ways
					if(i2 == WRITEOFF_ID){
						//see if we can approve agree based on stProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT
						if(strDDWriteOffAmt != '*' && Math.abs(closeDetail2.amount) > ddWriteOffAmount){
							isDDWriteOffApprovable = false;
						}

						//Auto Select the deduction if appropriate
						if(ded && ((nAmount - nonCloseMethAmount) >= bb.bbheader.finalselectedamount)){
							closeDetail2.deduction = ded;
						}
						else{
							closeDetail2.deduction = null;
							// closeDetail2.deduction.amount = 0;
							// closeDetail2.deduction.deduction.deductionnumber = '';
							// closeDetail2.deduction.deduction.amount = 0;
							// closeDetail2.deduction.deduction.deductionid = '';
						}
					}
					//now set appropriate
				}
			}

			if(stProfileSettings.bb_approve && bEditable && bb.bbheader.status.id == 2 ){
				$( "#taRemit" ).prop("disabled", false);
				$( "#ckSpecialHandle" ).prop("disabled", false);
			}

			//Check Profile and Template settings to see if User can Approve or Agree.  They Must have BB APPROVE to even Consider this.
			if(stProfileSettings.bb_approve){			
				
				if(		// set above -> writeoff amount < DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT
					isDDWriteOffApprovable
					&&
					(//Profile Approval Amount
						(approveAmount && approveAmount >= bb.bbheader.finalselectedamount) ||
						(stProfileSettings.bb_tot_approve_amount.toString() == '*')
					)
					&&
					(//Profile setting BB_APPROVE_AMOUNT // removed (approveDeviAmount &&)
						(approveDeviAmount >= (deviAmount)) ||
						(stProfileSettings.bb_approve_amount.toString() == '*' )
					)
					&&
					(//Profile can approve Last date to Claim or it is NOT BEYOND LAST DATE To CLAIM
						stProfileSettings.approve_last_date_to_claim ||
						!bb.bbheader.bbsettlement.lastdatetoclaim
					)
					&&
					(	//Profile can approve Beyond Budget or BB is Within Budget
						appSettings.Budgets_Functionality_On == 0
						||
						(
							stProfileSettings.approve_bb_beyond_budget ||
							bb.bbheader.bbsettlement.bisbillbackwithinbudget
						)
					)
					&& //The user has approval rights for this template
					(
						bb.bbheader.bbsettlement.templateapproval
					)
				){
					$('#submitButton').html("Approve");
					if( bEditable && nClosingRemainder === 0 && bb.bbheader.status.id == 2 && bb.bbheader.finalselectedamount != 0){    ///   nClosingRemainder === 0 &&
						$('#submitButton').click(function() {
								//alert('approve');
								approveSettlement();
							});
						$('#disagreeButton').click(function() {
								showDisagree();
							});
						$('#getdedButton').click(function() {
								get_Deductions();
							});
						$('#submitButton').addClass("recommended");
						$('#disagreeButton').addClass("recommended");
						$('#getdedButton').addClass("recommended");
						bbSettlementAction.action = 'approve';
					}
					else if(bEditable && bb.bbheader.status.id == 2 && bb.bbheader.finalselectedamount != 0){
						$('#getdedButton').off( "click" ); //clear it before setting it
						$('#getdedButton').addClass("recommended");
						$('#getdedButton').click(function() {
								get_Deductions();
							});
						$('#submitButton').off( "click" );
						$('#submitButton').removeClass("recommended");
						$('#disagreeButton').off( "click" );
						$('#disagreeButton').removeClass("recommended");
					}
					else{
						$('#submitButton').off( "click" );
						$('#submitButton').removeClass("recommended");
						$('#disagreeButton').off( "click" );
						$('#disagreeButton').removeClass("recommended");
						$('#getdedButton').off( "click" );
						$('#getdedButton').click(function() {
							 if(bb.bbheader.status.id == 2){
								alert('Please run deviations and select an amount to approve before selecting deductions.');
							}
						});
						$('#getdedButton').removeClass("recommended")
					}
					//INNER ELSE AGREE
				} else if( bEditable && nClosingRemainder === 0 && bb.bbheader.status.id == 2 && bb.bbheader.finalselectedamount != 0){
					$('#submitButton').click(function() {
							//alert('approve');
							approveSettlement();
						});
					$('#disagreeButton').click(function() {
							showDisagree();
						});
					$('#getdedButton').click(function() {
							get_Deductions();
						});
					$('#submitButton').addClass("recommended");
					$('#disagreeButton').addClass("recommended");
					$('#getdedButton').addClass("recommended");
				}
				// else{
				// 	$('#submitButton').off( "click" );
				// 	$('#submitButton').removeClass("recommended");
				// 	$('#disagreeButton').off( "click" );
				// 	$('#disagreeButton').removeClass("recommended");
				// 	$('#getdedButton').off( "click" );
				// 	$('#getdedButton').removeClass("recommended");
				// }
				//OUTER ELSE IF AGREE
			}	else if( bEditable && nClosingRemainder === 0 && bb.bbheader.status.id == 2 && bb.bbheader.finalselectedamount != 0){
				$('#submitButton').click(function() {
						//alert('approve');
						agree();
					});
				$('#disagreeButton').click(function() {
						showDisagree();
					});
				$('#getdedButton').click(function() {
						get_Deductions();
					});
				$('#submitButton').addClass("recommended");
				$('#disagreeButton').addClass("recommended");
				$('#getdedButton').addClass("recommended");
			}
			glob.closing_grid.api.redrawRows();
			// leave the staggered formatting below.  It is necessary for proper display
			var strBBApprove = stProfileSettings.bb_approve == true ? 'True' : 'False';
			var strTmplApprove = bb.bbheader.bbsettlement.templateapproval == true ? 'True' : 'False';
			var strTotApproveAmt = stProfileSettings.bb_tot_approve_amount.toString() == '*' ? '*' : stProfileSettings.bb_tot_approve_amount;
			var strApproveAmt = stProfileSettings.bb_approve_amount.toString() == '*' ? '*' : stProfileSettings.bb_approve_amount;
			var strWriteOffAmt = stProfileSettings.dd_match_central_write_off_amount.toString() == '*' ? '*' : stProfileSettings.dd_match_central_write_off_amount;
			var strAppBeyBudgt =  stProfileSettings.approve_bb_beyond_budget == true ? 'True' : 'False';
			var strAppLstDtClm = stProfileSettings.approve_last_date_to_claim == true ? 'True' : 'False';
			var sTitle = 'User has billback approval rights:								'+strBBApprove+
				'\nUser has approval rights for program template:					'+strTmplApprove+
				'\nTotal billback amount user can approve:						'+strTotApproveAmt+
				'\nTotal deviation amount user can approve:						'+strApproveAmt+
				'\nTotal write off amount user can approve:						'+strWriteOffAmt+
				'\nUser has rights to approve billback beyond budget:				'+strAppBeyBudgt+
				'\nUser has rights to approve billback beyond last date to claim:	'+strAppLstDtClm;
			 $('#submitButton').prop('title', sTitle);

			// '\nBB Last Date To Claim:          ' + this.billback.bbHeader.bbSettlement.lastDateToClaim.toString() + ')';
			// this.acBBClosingDetail.refresh();
			// dispatchEvent(new Event('acBBClosingDetailChanged'));
			// //let the ui know that things might have changed
			// dispatchEvent(new Event('bApprovableChanged'));
			// dispatchEvent(new Event('bEditableChanged'));
		}

				// Delete Closing Detail row
		function deleteRow(params) {
			let data = params.node.data;
			data.amount = 0;
			if(data.deduction){
				data.deduction.deductionnumber = '';
				data.deduction.amount = 0;
				data.deduction.deductionid = '';
				data.deduction.ddchecknumber = '';
				data.deduction.ddreference = '';
			}
			params.node.setData(data);
			tallyClosingRemainder();
			//  var rowNode = glob.closing_grid.api.getRowNode('bb');
			//rowNode.setData(newData);
		}

		<!------------- deviation ------------->
		function showDeviations() {
			// TBD Need bbid
			NewWindow("/billbacks/Deviation/Deviation_Main.cfm?bbid="+ bb.bbheader.billbackidguid +"&caller=BBSettlement&source=BBSettlement","Billback Deviations", 1300, 640, "yes", "yes", "0", "no");
															//	?bbid=26C883BC-66EC-49B5-B48E-00336F284739&caller=BBAgGridScoreCard&source=BBAgGridScoreCard
		}

		<!------------- discrepancy report ------------->
		function showDiscrepancyReport() {
			NewWindow("/billbacks/xls_Statement.cfm?Billback_id="+ bb.bbheader.billbackidguid,"Billback Discrepancy", 1300, 640, "yes", "yes", "0", "no");
		}

		<!------------- within budget ------------->
		function showWithinBudget() {
			NewWindow("/billbacks/APPROVAL/advanced_budget_billback.cfm?Billback_ID="+ bb.bbheader.billbackidguid,"Within Budget", 1300, 640, "yes", "yes", "0", "no");
			return false;
		}

		<!------------- disagree ------------->
		function showDisagree() {
			NewWindow("/Billbacks/common/BB_Business_Consideration.cfm?MODE=9&BBID=" + bb.bbheader.billbackidguid + "&source=AgGridBB","bizConWindow", 900, 600, "yes", "yes", "0", "no");
		}

		<!------------- agree ------------->
		function agree() {
			alert('Agree');
			//NewWindow("/Billbacks/common/BB_Business_Consideration.cfm?MODE=9&BBID=" + bb.bbheader.billbackidguid + "&source=AgGridBB","bizConWindow", 900, 600, "yes", "yes", "0", "no");
		}
		 //close settlements
		$( "#closeSettlement" ).click(function() {
			//trigger edit tab selection
			let fName = "edit_" + bb.bbheader.billbackidint;
			parent.$("li.nav[name=" + fName + "]").click();

		});

		function currencyFormatter(params) {
			if(params.value == 0){
				return '';
			}
			else{
				return Number(params.value).toLocaleString("en-US", {style:"currency", currency:"USD", minimumFractionDigits: 2});
			}
		}

		function openPopup(url, winW, winH, winN)
		{
			var windowWidth = 640;
			var windowHeight = 480;
			var windowName = 'popupWindow';

			if(winW)
			{
				windowWidth = winW;
			}
			if(winH)
			{
				windowHeight = winH;
			}
			if(winN)
			{
				windowName = winN;
			}
			var w = 640/3;
			var h = 480/3;
			var cw = w/2;
			var ch = h/2;

			if (window.screen)
			{
				w = Math.floor(screen.availWidth/3);
	    		h = Math.floor(screen.availHeight/3);
	    		cw = Math.floor((screen.availWidth-windowWidth)/2);
	    		ch = Math.floor((screen.availHeight-windowHeight)/2);
			}

	    	myPopup = window.open(url,windowName,'resizable=yes,scrollbars=yes,,width='+windowWidth+',height='+windowHeight+',top='+ch+',left='+cw);
	    	if (!myPopup.opener)
	        	myPopup.opener = self;
		}
		document.addEventListener("DOMContentLoaded", function () {
			$( ".button" ).prop("disabled", true);
			buildDeductionGrid();
			buildClosingGrid();
			get_billback(bbIdInt);
		});

		function show_loader_settle(message, delay) {
		    message = message || " ";
		    var loader_div = '<div class="loader loader-default is-active" half data-text="' + message + '"></div>';
		    /* /styles/css-loader.css must be preloaded in order to use this */
		    jQuery("body").append(loader_div);
		}
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>