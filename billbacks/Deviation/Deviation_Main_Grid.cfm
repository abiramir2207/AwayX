<cfsilent>
    <!---
    * ====================================================================================================
    *    @File: billbacks\Deviation\Deviation_Main_Grid.cfm
    *  @Author: Sharon Harris
    *    @Date: 01-May-2019
    *
    * @Remarks: Billback Deviation Main page Grid
    *			See old FlexDev\BillbackDevApp\src\com\views\BBMainPanel.mxml
    *
    * ====================================================================================================
    --->
</cfsilent>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<style>
	.green-check {
		background: url(/Images/yes.gif) no-repeat center;
		background-size: 14px 14px;
		font-size: 1px;
  		color: white;
		background-size:12px 12px;
	}
	.red-x {
		background: url(/Images/no.gif) no-repeat center;
		background-size: 14px 14px;
		font-size: 1px;
  		color: white;
	}
	.yes-big {
		background: url(/Images/yes_big.gif) no-repeat center;
		background-size: 22px 22px;
		font-size: 1px;
  		color: white;
		/* top: -30px;	 */	/* with default groupHeaderHeight */
		top: -40px;
		height: 52px;
		z-index: 2;
	}
	.x-center-cell {	/* horizontally center cell contents */
		left:0;
		right:0;
		margin-left: auto;
		margin-right: auto;
		width: 100%
	}

	.boldBorders {
		height: 18px;
		top: 1px;
		border-radius: 2px;
		border: 1px solid transparent !important;
		border-top: none !important;
		border-bottom: 1px solid #d8d9dd !important;
		box-shadow: inset 0 1px 2px rgba(0,0,0,.39);
		background-color: #ffffff;
		padding: 2px 0 0 2px;
	}
	.boldBorders:focus {
		outline: 1px solid #0091ea !important;
	}
	.disabledInput {
		background-color: #d8d9dd;
		color: #afb0b2;
	}
	.appendAmount {}	/* used (like an id) to "find" the Total Deviation header text */

</style>
<!---  Header & Cell Component code --->
<cfinclude template="/billbacks/Deviation/Deviation_Main_Header_Components.cfm">
<cfinclude template="/billbacks/Deviation/Deviation_Main_Cell_Components.cfm">

<cfinclude template="deviation_columns.cfm">

<script>
const popups = [];
var editableGrid = false;
<cfif qryBillbackHeader.Billback_Status_ID eq 2 OR (qryBillbackHeader.Billback_Status_ID eq 3 AND appSettings.getUpdate_BB_Approve_Amt() EQ 1)>
editableGrid = true;
</cfif>

	/* Radio button values for Expected (E), Less tolerance (LT), Claimed (C) and Manual (M) values - For "Rate" and "Volume".
	 Less tolerance (LT) is applicable for "Rate" only. */
	const TYPE_E  = '2';
	const TYPE_LT = '6';
	const TYPE_C  = '1';
	const TYPE_M  = '3';

// return true if the deviation should have a link associated with it
function isLink(params) {
	let isLink=false;
	if
	(
		(params.data.THIRD_PARTY_BB_UPLOAD == '3' && params.data.DUMMY_PROGRAM =='0' && params.data.UNKNOWN_ITEM =='0')
		||
		(params.data.THIRD_PARTY_BB_UPLOAD != '3' && params.data.UNKNOWN_ITEM =='0')
	)
	{
		isLink = true;
	}
	return isLink;
}

function isEditableData(params){
	let isEditable = false;

	if(((params.data.THIRD_PARTY_BB_UPLOAD == '3' && params.data.DUMMY_PROGRAM == '0' && params.data.UNKNOWN_ITEM =='0')
		||
		params.data.THIRD_PARTY_BB_UPLOAD != '3'
		)
		&& params.data.DENIED != '1'){

		isEditable = true;
	}
	return isEditable;
}

function isEditableRate(params) {
	let isEditable = false;
	if(params.data.EDITABLE_RATE =='1' && editableGrid == true && isEditableData(params)){
		isEditable = true;
	}
	return isEditable;
}

function isEditableInvoicePriceORProgramPrice(params) {
	let isEditable = false;
	if(params.data.EDITABLE_RATE =='0' && editableGrid == true && isEditableData(params)){
		isEditable = true;
	}
	return isEditable;
}

function isEditableVolume(params) {
	let isEditable = false;
	if(editableGrid == true && isEditableData(params)){
		isEditable = true;
	}
	return isEditable;
}

function isEditableCheckbox(params) {
	let isEditable = false;
	if(editableGrid == true && isEditableData(params)){
		isEditable = true;
	}
	return isEditable;
}

// return the css class style(s) for the deviation - either green check or red x, or blank, and pointer if a link
function deviationStyle(params, deviationType) {
	let cellClasses = [];
	let iconClass = "";	// could be blank, green check, or red x

	switch (deviationType) {
		case "UP":		// Unauthorized Payee
			if (params.data.DEVIATION_UNAUTHORIZED_PAYEE == 1) {
				iconClass = "red-x";
			} else if (params.data.DEVIATION_UNAUTHORIZED_PAYEE == 0) {
				iconClass = "green-check";
			}
		break;
		case "DT":		// Date match validation
			if (params.data.DEVIATION_PROGRAM_DATES == 1) {
				iconClass = "red-x";
			} else if (params.data.DEVIATION_PROGRAM_DATES == 0) {
				iconClass = "green-check";
			}
		break;
		case "OL":		// Date overlap validation
			if ((params.data.BB_PRODUCT_TYPE_ID == '1' || params.data.BB_PRODUCT_TYPE_ID == '2')) {
				if (params.data.DEVIATION_BILLBACK_OVERLAP == 1) {
					iconClass = "red-x";
				}
				else if (params.data.DEVIATION_BILLBACK_OVERLAP == 0) {
					iconClass = "green-check";
				}
			}
		break;
		case "AU":		// Authorization validation
			if ((params.data.BB_PRODUCT_TYPE_ID == '1' || params.data.BB_PRODUCT_TYPE_ID == '2')) {
				if (params.data.DEVIATION_UNAUTHORIZED_PRODUCT == 1) {
					iconClass = "red-x";
				}
				else if (params.data.DEVIATION_UNAUTHORIZED_PRODUCT == 0) {
					iconClass = "green-check";
				}
			}
		break;
		case "VL":		// Volume validation
			if ((params.data.BB_PRODUCT_TYPE_ID == '1' || params.data.BB_PRODUCT_TYPE_ID == '2')) {
				if (params.data.DEVIATION_VOLUME == 1) {
					iconClass = "red-x";
				}
				else if (params.data.DEVIATION_VOLUME == 0) {
					iconClass = "green-check";
				}
			}
		break;
		case "RT":		// Rate validation
			if (params.data.DEVIATION_RATE == 1) {
				iconClass = "red-x";
			}
			else if (params.data.DEVIATION_RATE == 0) {
				iconClass = "green-check";
			}
		break;
	}
	cellClasses.push(iconClass);

	if (isLink(params)) {
			cellClasses.push("cursor-pointer");
	}
	return cellClasses;
}
// renderer for cell (not row) checkbox, used for "idone" flag
function checkboxCellRenderer (params) {
	let value = params.data.IDONE == 0 ? '' : ' checked';
	let disabledCheckBox =  isEditableCheckbox(params) == false ? "disabled=disabled" : "";

	return "<input type='checkbox' class='x-center-cell' " +value + " " + disabledCheckBox + " />";
}

// renderer for "count" cell checkbox
function checkboxCountCellRenderer (params) {
	let value = params.data.COUNT_FLAG == 0 ? '' : ' checked';
	let disabledCheckBox =  isEditableCheckbox(params) == false ? "disabled=disabled" : "";

	return "<input type='checkbox' class='x-center-cell' " + value + " " + disabledCheckBox +  " />";
}

// renderer for cell radio button
// each button is a member of a group (ex: rate, volume), and the value is which member
function radioCellRenderer (params, group, value) {
	let checked = '';
	let retData = '';
	let showRadioButton;
	let disableRadioButton = "";

	// decide if this should be On or off
	switch (group) {
		case 'rate':
			checked = params.data.SELECTED_RATE_TYPE == value ? "checked" : "";
			showRadioButton = params.data.EDITABLE_RATE;
			disableRadioButton = isEditableRate(params) == false ? "disabled=disabled" : "";
			break;
		case 'volume':
			checked = params.data.SELECTED_VOL_TYPE == value ? "checked" : "";
			showRadioButton = true;
			disableRadioButton = isEditableVolume(params) == false ? "disabled=disabled" : "";
			break;
		case 'invoice_price':
			checked = params.data.SELECTED_INVOICE_PRICE_TYPE == value ? "checked" : "";
			showRadioButton = params.data.EDITABLE_RATE == 0;
			disableRadioButton = isEditableInvoicePriceORProgramPrice(params) == false ? "disabled=disabled" : "";
			break;
		case 'program_price':
			checked = params.data.SELECTED_PROGRAM_PRICE_TYPE == value ? "checked" : "";
			showRadioButton = params.data.EDITABLE_RATE == 0;
			disableRadioButton = isEditableInvoicePriceORProgramPrice(params) == false ? "disabled=disabled" : "";
			break;
		default:
			break;
	}

	// The radio button "name" should be name=vol-row-number or something - the ROW is the set of radio buttons, not the column
	if(showRadioButton == true){
		retData = '<input type="radio" class="x-center-cell" name='+group+'-row-'+params.node.id+' value="'+value+'" '+checked+' '+disableRadioButton+' />';
	}

	return retData;
}

<!--- NOTE: I found 3 Options for rendering the green check and red X for the deviation columns:
	https://www.ag-grid.com/javascript-grid-cell-styles/
	Option 1: cellClassRules
		Pro- simple, performant, Con: can only add a single class.
		Use with class that has a background image replacing the content
		Example:
			cellClassRules: {
				'green-check': 'x>0',		// checkmark for ok
				'red-x': 'x<=0'				// red x for deviation issue
			}
	Option 2: cellClass
		Pro- simple, performant, can add multiple classes, Con: don't know how to replace cell value with fa via css (could do image)
		Example:
			cellClass: function(params) { return params.value > 0 ? ['fa','fa-check','green-check'] : ['fa','fa-times','red-x']; }

	https://www.ag-grid.com/javascript-grid-cell-rendering-components/
	Option 3: cell Renderer
		Pro- full control code renderer, Cons: more code, warned by ag-grid that this will be slower

--->
var columnDefs_deviations = [
	{headerName: "Program", pinned:'left', width:75, headerClass:'custom-header', autoHeight: true
		,cellClass: "cursor-pointer"
		,tooltipValueGetter: function(params){
			return params.data.PROGRAM.replace(/<BR>/gi, "\n") + "\n" + "[Click to view Program]";
		}
		,field: 'PROGRAM'
		// cellRenderer is needed to handle the BR for a two-line render
		,cellRenderer: function(params){
			return params.data.PROGRAM;
		}
		,onCellClicked: function(params) {
			let contract_main_id = params.data.PROGRAM_ID;
			let win_name = 'winSummary';
			 popups.push( NewWindowTopLeft("/CID_Wrapper.cfm?Program_ID="+contract_main_id+"&Page_Relocate=/scorecard/program_display.cfm",win_name,"800","710","yes","yes") );
		}
		// because we have a cellRenderer, we have to supply our own sort fn
		,comparator: compareStringCells
		,filter: 'agTextColumnFilter'
		,filterParams:
		{
			filterOptions:['contains','startsWith','endsWith']
			,applyButton:true
			,suppressAndOrCondition:true
			,newRowsAction:'keep'
		}
	},
	{headerName: "Distributor", pinned:'left', width:75, headerClass:'custom-header',autoHeight: true
		,tooltipValueGetter: function(params){
			return params.data.DISTRIBUTOR.replace(/<BR>/gi, "\n");
		}
		,field: 'DISTRIBUTOR'
		// cellRenderer is needed to handle the BR for a two-line render
		,cellRenderer: function(params){
			return params.data.DISTRIBUTOR;
		}
		// because we have a cellRenderer, we have to supply our own sort fn
		,comparator: compareStringCells
		,filter: 'agTextColumnFilter'
		,filterParams:
		{
			filterOptions:['contains','startsWith','endsWith']
			,applyButton:true
			,suppressAndOrCondition:true
			,newRowsAction:'keep'
		}
	},
    {headerName: "Item", pinned:'left', width:90, headerClass:'custom-header',autoHeight: true
		,tooltipValueGetter: function(params){
			return params.data.ITEM.replace(/<BR>/gi, "\n");
		}
		,field: 'ITEM'
		// cellRenderer is needed to handle the BR for a two-line render
		,cellRenderer: function(params){
			return params.data.ITEM;
		}
		// because we have a cellRenderer, we have to supply our own sort fn
		,comparator: compareStringCells
		,filter: 'agTextColumnFilter'
		,filterParams:
		{
			filterOptions:['contains','startsWith','endsWith']
			,applyButton:true
			,suppressAndOrCondition:true
			,newRowsAction:'keep'
		}
	},
	<cfif appSettings.getViewOperatorinBillbackDeviation() eq 1>
	{headerName: "Operator", pinned:'left', width:75, headerClass:'custom-header',autoHeight: true
		,tooltipValueGetter: function(params){
			return params.data.OPERATOR_ADDRESS.replace(/<BR>/gi, "\n");
		}
		,field: 'OPERATOR_DETAILS'
		// cellRenderer is needed to handle the BR for a two-line render
		,cellRenderer: function(params){
			return params.data.OPERATOR_DETAILS;
		}
		// because we have a cellRenderer, we have to supply our own sort fn
		,comparator: compareStringCells
		,filter: 'agTextColumnFilter'
		,filterParams:
		{
			filterOptions:['contains','startsWith','endsWith']
			,applyButton:true
			,suppressAndOrCondition:true
			,newRowsAction:'keep'
		}
	},
	</cfif>
	{headerName: "Type", field: 'DISCOUNT_TYPE_DESC', width:70, headerClass:'custom-header',autoHeight: true
		,tooltipValueGetter: function(params){
			let aComps = params.data.COMPONENT_NAMES.split(',');
			let aLen = aComps.length;
			let compList = '';

			for(let i=0; i<aLen; i++){
				compList = compList + (i+1).toString() + '. ' + aComps[i] + '\n';
			}
			return compList;
		}
		,suppressNavigable: true
		,filter: 'agTextColumnFilter'
		,filterParams:
		{
			filterOptions:['contains','startsWith','endsWith']
			,applyButton:true
			,suppressAndOrCondition:true
			,newRowsAction:'keep'
		}
	},

	/* DEVIATIONS */
	{headerName: "Deviations", children: [
		{headerName: "UP", width:25, headerTooltip:"Unauthorized Payee"
			,headerClass: "cursor-default"
			,cellClass: function(params){ return (deviationStyle(params, "UP")); }
			,comparator: function(valueA, valueB, nodeA, nodeB, isInverted) {
				return nodeA.data.DEVIATION_UNAUTHORIZED_PAYEE - nodeB.data.DEVIATION_UNAUTHORIZED_PAYEE;
			}
			,tooltipValueGetter: function(params){
				return params.data.DEVIATION_UNAUTHORIZED_PAYEE_PERCENT + '%';
			}
			,onCellClicked: function(params) {
				if (isLink(params)) {
					popups.push( NewWindowTopLeft("/billbacks/Deviation/Authorized_Payee_List.cfm?Billback_Program_ID="+params.data.BILLBACK_PROGRAM_ID+"&Billback_ID="+params.data.BILLBACK_ID,'payee_list',"780","650","yes","yes") );
				}
			}
			,filter:false
		},
		{headerName: "DT", width:25, headerTooltip:"Date match validation"
			,headerClass: "cursor-default"
			,cellClass: function(params){ return deviationStyle(params, "DT"); }
			,comparator: function(valueA, valueB, nodeA, nodeB, isInverted) {
				return nodeA.data.DEVIATION_PROGRAM_DATES - nodeB.data.DEVIATION_PROGRAM_DATES;
			}
			,tooltipValueGetter: function(params){
				return params.data.DEVIATION_PROGRAM_DATES_PERCENT + '%';
			}
			,onCellClicked: function(params) {
				if (isLink(params)) {
				popups.push( NewWindowTopLeft("/billbacks/Deviation/Deviation_Program_Date_Mismatch.cfm?Billback_Program_ID="+params.data.BILLBACK_PROGRAM_ID,'program_dates_list',"780","650","yes","yes") );
				}
			}
			,filter:false
		},
		{headerName: "OL", width:25, headerTooltip:"Date overlap validation"
			,headerClass: "cursor-default"
			,cellClass: function(params){
				return deviationStyle (params,"OL");
			}
			,comparator: function(valueA, valueB, nodeA, nodeB, isInverted) {
				return nodeA.data.DEVIATION_BILLBACK_OVERLAP - nodeB.data.DEVIATION_BILLBACK_OVERLAP;
			}
			,tooltipValueGetter: function(params){
				return params.data.DEVIATION_BILLBACK_OVERLAP_PERCENT + '%';
			}
			,onCellClicked: function(params) {
				addLink = isLink(params);

				<cfif application.appSettingsget.getBBOverlapDeviationBasedOnOperator() eq 1>
					popups.push( NewWindowTopLeft("/billbacks/common/overLapReport.cfm?BBID="+params.data.BILLBACK_ID+"&Product_ID="+params.data.PRODUCT_ID,'overlap_list',"780","650","yes","yes") );
				<cfelse>
				if (addLink == 1){
					popups.push( NewWindowTopLeft("/billbacks/Deviation/Deviation_Product_Date_Overlap.cfm?Billback_Product_Detail_ID="+params.data.BILLBACK_PRODUCT_DETAIL_ID,'overlap_list',"780","650","yes","yes") );
				}
				</cfif>
			}
			,filter:false
		},
		{headerName: "AU", width:25, headerTooltip:"Authorization validation"
			,headerClass: "cursor-default"
			,cellClass: function(params){ return deviationStyle(params, "AU"); }
			,comparator: function(valueA, valueB, nodeA, nodeB, isInverted) {
				return nodeA.data.DEVIATION_UNAUTHORIZED_PRODUCT - nodeB.data.DEVIATION_UNAUTHORIZED_PRODUCT;
			}
			,tooltipValueGetter: function(params){
				return params.data.DEVIATION_UNAUTHORIZED_PRODUCT_PERCENT + '%';
			}
			,onCellClicked: function(params) {
				if (isLink(params)) {
					popups.push( NewWindowTopLeft("/billbacks/Deviation/Authorized_Product_List.cfm?Billback_Product_Detail_ID="+params.data.BILLBACK_PRODUCT_DETAIL_ID,'program_dates_list',"780","650","yes","yes") );
				}
			}
			,filter:false
		},
		{headerName: "VL", width:25, headerTooltip:"Volume validation"
			,headerClass: "cursor-default"
			,cellClass: function(params){ return deviationStyle(params, "VL"); }
			,comparator: function(valueA, valueB, nodeA, nodeB, isInverted) {
				return nodeA.data.DEVIATION_VOLUME - nodeB.data.DEVIATION_VOLUME;
			}
			,tooltipValueGetter: function(params){
				return params.data.DEVIATION_VOLUME_PERCENT + '%';
			}
			,onCellClicked: function(params) {
				if (isLink(params)) {
					popups.push( NewWindowTopLeft("/billbacks/Deviation/Deviation_Product_Volume.cfm?Billback_Product_Detail_ID="+params.data.BILLBACK_PRODUCT_DETAIL_ID+"&BB_Product_Type_ID="+params.data.BB_PRODUCT_TYPE_ID,'volume_list',"780","650","yes","yes") );
				}
			}
			,filter:false
		},
		{headerName: "RT", width:25, headerTooltip:"Rate validation"
			,headerClass: "cursor-default"
			,cellClass: function(params){ return deviationStyle(params, "RT"); }

			,comparator: function(valueA, valueB, nodeA, nodeB, isInverted) {
				return nodeA.data.DEVIATION_RATE - nodeB.data.DEVIATION_RATE;
			}
			,tooltipValueGetter: function(params){
				return params.data.DEVIATION_RATE_PERCENT + '%';
			}
			,onCellClicked: function(params) {
				if (isLink(params)) {
					if(params.data.BB_PRODUCT_TYPE_ID == '4'){
						popups.push( NewWindowTopLeft("/billbacks/Deviation/Deviation_Growth_New.cfm?Billback_Program_ID="+params.data.BILLBACK_PROGRAM_ID,'rate_list',"780","650","yes","yes") );
					}
					else if(params.data.BB_PRODUCT_TYPE_ID == '3'){
						popups.push( NewWindowTopLeft("/billbacks/Deviation/Deviation_Lumpsum.cfm?Billback_Program_ID="+params.data.BILLBACK_PROGRAM_ID,'rate_list',"780","650","yes","yes") );
					}
					else{
						popups.push( NewWindowTopLeft("/billbacks/Deviation/Deviation_Product_Rate.cfm?Billback_Product_Detail_ID="+params.data.BILLBACK_PRODUCT_DETAIL_ID+"&BB_Product_Type_ID="+params.data.BB_PRODUCT_TYPE_ID,'rate_list',"780","650","yes","yes") );
					}
				}
			}
			,filter:false
		}
	]},
	{headerName: "Total Deviation:", type: 'numericColumn', width:80, headerClass: ['custom-header', 'appendAmount']
		,field: 'VARIATION_CLAIM_EXPECTED'
		,valueFormatter: currencyFormatter	// use this instead of cellRenderer to a) preserve sorting, and b) it's faster
		,suppressNavigable: true
		,filter:false
	},

	/* RATE */
	{headerName: "Rate",
	 headerGroupComponent: InfoHeaderGroup,
	 headerGroupComponentParams: {
		 title: "Rate deviation is calculated with a greater precision than the display. While the display shows rate up to 4 decimal places the rate deviation is calculated with a greater precision. As a result, even though the Expected and Claim Rates look identical on the display, there could be differences beyond the 4th decimal point that cause a rate deviation."
	 },
	 children: [
		{headerName: "E", field: 'SELECTED_RATE_TYPE', width:25
			,headerComponent: RadioButtonHeader
			,headerComponentParams: { action: "fnRateExpClicked" }
			/* Rule - If data.EDITABLE_RATE == 1, then show, else hide the radio option */
			/* Rule - If "isEditableRate" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "rate", TYPE_E); }
			,onCellClicked: function(params) {
				if(isEditableRate(params) ==  true){
					fnRecalculate(params,'fnRateChange',TYPE_E);
				}
			}
			,filter:false
		},
		{headerName: "Exp.", type:'numericColumn', width:70, headerTooltip:"Expected Rate"
			,field: 'E_RATE'
			,valueFormatter: CurrencyUOMFormatter
			,suppressNavigable: true
			,filter:false
		},
		<cfif iBBDevOverridePrice eq 0 AND appSettings.getBB_Approve_Expected_Rate_Less_Tolerance() eq 1>
		{headerName: "LT", field: 'SELECTED_RATE_TYPE', width:24
			,headerComponent: RadioButtonHeader
			,headerComponentParams: { action: "fnRateELTClicked" }
			/* Rule - If data.EDITABLE_RATE == 1, then show, else hide the radio option */
			/* Rule - If "isEditableRate" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "rate", TYPE_LT); }
			,onCellClicked: function(params) {
				if(isEditableRate(params) ==  true){
					fnRecalculate(params,'fnRateChange',TYPE_LT);
				}
			}
			,filter:false
		},
		{headerName: "Exp. LT", type:'numericColumn', width:70
			,field: 'ELT_RATE'
			,valueFormatter: CurrencyUOMFormatter
			,suppressNavigable: true
			,filter:false
		},
		</cfif>
		{headerName: "C", field: 'SELECTED_RATE_TYPE', width:22
			,headerComponent: RadioButtonHeader
			,headerComponentParams: { action: "fnRateClaimClicked" }
			/* Rule - If data.EDITABLE_RATE == 1, then show, else hide the radio option */
			/* Rule - If "isEditableRate" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "rate", TYPE_C); }
			,onCellClicked: function(params) {
				if(isEditableRate(params) ==  true){
					fnRecalculate(params,'fnRateChange',TYPE_C);
				}
			}
			,filter:false
		},
		{headerName: "Claimed", type:'numericColumn', width:90
			,field: 'CLAIMED_RATE'
			,valueFormatter: CurrencyUOMFormatter
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "M", field: 'SELECTED_RATE_TYPE', width:28
			/* Rule - If data.EDITABLE_RATE == 1, then show, else hide the radio option */
			/* Rule - If "isEditableRate" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "rate", TYPE_M); }
			,onCellClicked: function(params) {
				if(isEditableRate(params) ==  true){
					fnRecalculate(params,'fnRateChange',TYPE_M);
				}
			}
			,filter:false
		},
		{headerName: "Manual", field:'MANUAL_RATE', type:'numericColumn', width:90
			,valueFormatter: CurrencyUOMFormatter
			/* Rule - Only if this radio button is selected, will the manual textbox be editable */
			,editable: function(params) {
				return params.data.SELECTED_RATE_TYPE == TYPE_M;
			}
			,cellClassRules: {
				'boldBorders':  function(params) { return true; },
				/* Rule - Only 3 decimal places allowed. Do a JS alert when the data exceeds 3 decimal places. */
				/* Rule - Always set the value to 3 decimal places, when the user removes the focus. */
				/* Rule - Show an alert, if the value exceeds the claimed amount. */
				/* Rule - If the "BB Deviations Grid - Allow Manual values Greater than Claimed" app setting is ON, then the value can exceed the claimed amount. */
				// Rule - Maximum characters are 9 (Not sure about this rule)
				'disabledInput': function(params) { return params.data.SELECTED_RATE_TYPE != TYPE_M; },
			}
			,tooltipValueGetter: function(params){
				return "Press Enter or Tab after entering value"
			}
			,cellEditor: maxLengthCellEditor
			,cellEditorParams: {
				maxLength: 9,
			}
			,onCellValueChanged: function(params) {
				if((params.oldValue != params.newValue) && params.newValue != ''){
					if(numberValueSetter(params) ==  true){		// Continue if numeric, if not alert user
						if(fnChkDecPlaces(params,'rate') ==  true){
							if(checkManualData(params,'rate') ==  true){
								fnRecalculate(params,"fnSetRateManual",0);
							}
						}
					}
				}
			}

			,filter:false
		}
	]},

	/* VOLUME */
	{headerName: "Volume", children: [
		{headerName: "E", field: 'SELECTED_VOL_TYPE', width:25
			,headerComponent: RadioButtonHeader
			,headerComponentParams: { action: "fnExpectedVolumeClicked"}
			/* Rule - If "isEditableVolume" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "volume", TYPE_E); }
			,onCellClicked: function(params) {
				if(isEditableVolume(params) ==  true){
					fnRecalculate(params,'fnRdoVolChange',TYPE_E);
				}
			}
			,filter:false
		},
		{headerName: "Exp.", type:'numericColumn', width:70, headerTooltip:"Expected Volume"
			,field: 'E_VOLUME'
			,valueFormatter: UOMFormatter
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "C", field: 'SELECTED_VOL_TYPE', width:22
			,headerComponent: RadioButtonHeader
			,headerComponentParams: { action: "fnClaimedVolumeClicked" }
			/* Rule - If "isEditableVolume" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "volume", TYPE_C); }

			,onCellClicked: function(params) {
				if(isEditableVolume(params) ==  true){
					 fnRecalculate(params,'fnRdoVolChange',TYPE_C);
				}
			}
			,filter:false
		},
		{headerName: "Claimed", type:'numericColumn', width:70
			,field: 'CLAIMED_VOLUME'
			,valueFormatter: UOMFormatter
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "M", field: 'SELECTED_VOL_TYPE', width:28
			/* Rule - If "isEditableVolume" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "volume", TYPE_M); }

			,onCellClicked: function(params) {
				if(isEditableVolume(params) ==  true){
					fnRecalculate(params,'fnRdoVolChange',TYPE_M);
				}
			}
			,filter:false
		},
		{headerName: "Manual", field: 'MANUAL_VOL', type:'numericColumn', width:90
			,valueFormatter: numberFormatter
			,editable: function(params) {
				return params.data.SELECTED_VOL_TYPE == TYPE_M;
			}
			,cellClassRules: {
				'boldBorders':  function(params) { return true; },
				/* Rule - If "Billback - Allow Fractional Volume" app setting is ON, allow decimals upto 3 decimal places. */
				/* Rule - If "Billback - Allow Fractional Volume" app setting is OFF, then no decimal places are allowed. */
				/* Rule - only 3 decimal places allowed. Do a JS alert when the data exceeds 3 decimal places. */
				/* Rule - Always set the value to 3 decimal places, when the user removes the focus from the volume text box. */
				/* Rule - Show a JS alert, if the value exceeds the claimed volume. */
				/* Rule - Maximum characters are 9 (Not sure about this rule) */
				'disabledInput': function(params) { return params.data.SELECTED_VOL_TYPE != TYPE_M; }
			}
			,tooltipValueGetter: function(params){
				return "Press Enter or Tab after entering value"
			}
			,cellEditor: maxLengthCellEditor
			,cellEditorParams: {
				maxLength: 9,
			}
			,onCellValueChanged: function(params) {
				if((params.oldValue != params.newValue) && params.newValue != ''){
					if(numberValueSetter(params) ==  true){
						if(fnChkDecPlaces(params,'volume') ==  true){
							if(checkManualData(params,'volume') ==  true){
								fnRecalculate(params,"fnSetVolManual",0);
							}
						}
					}
				}
			}
			,filter:false
		}
	]},
	<cfif iBBDevOverridePrice eq 1>
	/* INVOICE PRICE */
	{headerName: "Invoice Price", children: [
		{headerName: "E", field: 'SELECTED_INVOICE_PRICE_TYPE', width:25
			/* Rule - If data.EDITABLE_RATE == 0, then show, else hide the radio option */
			/* Rule - If "isEditableInvoicePriceORProgramPrice" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "invoice_price", TYPE_E); }
			,onCellClicked: function(params) {
				if(isEditableInvoicePriceORProgramPrice(params) ==  true){
					fnRecalculate(params,'fnRdoInvChange',TYPE_E);
				}
			}
			,filter:false
		},
		{headerName: "Exp.", type:'numericColumn', width:70, headerTooltip:"Expected Invoice Price"
			,field: 'EXPECTED_INVOICE_PRICE'
			,valueFormatter: currencyFormatter
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "C", field: 'SELECTED_INVOICE_PRICE_TYPE', width:22
			/* Rule - If data.EDITABLE_RATE == 0, then show, else hide the radio option */
			/* Rule - If "isEditableInvoicePriceORProgramPrice" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "invoice_price", TYPE_C); }
			,onCellClicked: function(params) {
				if(isEditableInvoicePriceORProgramPrice(params) ==  true){
					fnRecalculate(params,'fnRdoInvChange',TYPE_C);
				}
			}
			,filter:false
		},
		{headerName: "Claimed", type:'numericColumn', width:90
			,field: 'CLAIM_INVOICE_PRICE'
			,valueFormatter: currencyFormatterFour
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "M", field: 'SELECTED_INVOICE_PRICE_TYPE', width:28
			/* Rule - If data.EDITABLE_RATE == 0, then show, else hide the radio option */
			/* Rule - If "isEditableInvoicePriceORProgramPrice" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "invoice_price", TYPE_M); }
			,onCellClicked: function(params) {
				if(isEditableInvoicePriceORProgramPrice(params) ==  true){
					fnRecalculate(params,'fnRdoInvChange',TYPE_M);
				}
			}
			,filter:false
		},
		{headerName: "Manual", field: 'MANUAL_INVOICE_PRICE', type:'numericColumn', width:90
			,valueFormatter: currencyFormatter
			/* Rule - Only if this radio button is selected, will the manual textbox be editable */
			,editable: function(params) {
				return params.data.SELECTED_INVOICE_PRICE_TYPE == TYPE_M;
			}
			,cellClassRules: {
				'boldBorders':  function(params) { return true; },
				'disabledInput': function(params) { return params.data.SELECTED_INVOICE_PRICE_TYPE != TYPE_M; }
			}
			/* Rule - Maximum characters are 9 (Not sure about this rule */
			/* Rule - Only 2 decimal places allowed */
			,tooltipValueGetter: function(params){
				return "Press Enter or Tab after entering value"
			}
			,cellEditor: maxLengthCellEditor
			,cellEditorParams: {
				maxLength: 9,
			}
			,onCellValueChanged: function(params) {
				if((params.oldValue != params.newValue) && params.newValue != ''){
					if(numberValueSetter(params) ==  true){
						if(fnChkDecPlaces(params,'invoicePrice') ==  true){
							fnRecalculate(params,"fnSetInvManual",0);
						}
					}
				}
			}
			,filter:false
		}
	]},
	/* PROGRAM PRICE */
	{headerName: "Program Price", children: [
		{headerName: "E", field: 'SELECTED_PROGRAM_PRICE_TYPE', width:25
			/* Rule - If data.EDITABLE_RATE == 0, then show, else hide the radio option */
			/* Rule - If "isEditableInvoicePriceORProgramPrice" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "program_price", TYPE_E); }
			,onCellClicked: function(params) {
				if(isEditableInvoicePriceORProgramPrice(params) ==  true){
					fnRecalculate(params,'fnRdoPgmChange',TYPE_E);
				}
			}
			,filter:false
		},
		{headerName: "Exp.", type:'numericColumn', width:70, headerTooltip:"Expected Program Price"
			,field: 'EXPECTED_PROGRAM_PRICE'
			,valueFormatter: currencyFormatterFour
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "C", field: 'SELECTED_PROGRAM_PRICE_TYPE', width:22
			/* Rule - If data.EDITABLE_RATE == 0, then show, else hide the radio option */
			/* Rule - If "isEditableInvoicePriceORProgramPrice" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "program_price", TYPE_C); }
			,onCellClicked: function(params) {
				if(isEditableInvoicePriceORProgramPrice(params) ==  true){
					fnRecalculate(params,'fnRdoPgmChange',TYPE_C);
				}
			}
			,filter:false
		},
		{headerName: "Claimed", type:'numericColumn', width:70
			,field: 'CLAIMED_PROGRAM_PRICE'
			,valueFormatter: currencyFormatterFour
			,suppressNavigable: true
			,filter:false
		},
		{headerName: "M", field: 'SELECTED_PROGRAM_PRICE_TYPE', width:28
			/* Rule - If data.EDITABLE_RATE == 0, then show, else hide the radio option */
			/* Rule - If "isEditableInvoicePriceORProgramPrice" function returns true, then enable, else disable the radio button */
			,cellRenderer: function(params) { return radioCellRenderer(params, "program_price", TYPE_M); }
			,onCellClicked: function(params) {
				if(isEditableInvoicePriceORProgramPrice(params) ==  true){
					fnRecalculate(params,'fnRdoPgmChange',TYPE_M);
				}
			}
			,filter:false
		},
		{headerName: "Manual", field: 'MANUAL_PROGRAM_PRICE', type:'numericColumn', width:90
			,valueFormatter: currencyFormatter
			/* Rule - Only if this radio button is selected, will the manual textbox be editable */
			,editable: function(params) {
				return params.data.SELECTED_PROGRAM_PRICE_TYPE == TYPE_M;
			}
			,cellClassRules: {
				'boldBorders':  function(params) { return true; },
				/* Rule - Maximum characters are 9 (Not sure about this rule */
				/* Rule - Only 2 decimal places allowed */
				'disabledInput': function(params) { return params.data.SELECTED_PROGRAM_PRICE_TYPE != TYPE_M; }
			}
			,tooltipValueGetter: function(params){
				return "Press Enter or Tab after entering value"
			}
			,cellEditor: maxLengthCellEditor
			,cellEditorParams: {
				maxLength: 9,
			}
			,onCellValueChanged: function(params) {
				if((params.oldValue != params.newValue) && params.newValue != ''){
					if(numberValueSetter(params) ==  true){
						if(fnChkDecPlaces(params,'programPrice') ==  true){
							fnRecalculate(params,"fnSetPrgManual",0);
						}
					}
				}
			}
			,filter:false
		}
	]},
	</cfif>
	{headerName:"Expected Amt.", type:'numericColumn', width:90, headerClass:'custom-header'
		,field: 'EXPECTED_AMOUNT'
		,valueFormatter: currencyFormatter
		,suppressNavigable: true
		,filter:false
	},
	{headerName:"Claimed Amt.", type:'numericColumn', width:90, headerClass:'custom-header'
		,field: 'CLAIMED_AMOUNT'
		,valueFormatter: currencyFormatter
		,suppressNavigable: true
		,filter:false
	},
	<!---
		{headerName:"Exp. Rate", field:'E_Rate'},		// hidden
		{headerName:"Claimed Rate", field:'Claimed_Rate'},		// hidden
		{headerName:"Exp. Volume", field:'E_Volume'},		// hidden
		{headerName:"Claimed Volume", field:'Claimed_Volume'},		// hidden
		{headerName:"Claimed Volume UOM", field:'Claimed_Volume_UOM'},		// hidden
	--->

	{headerName:"Final Payment $", type:'numericColumn', width:90, headerClass:'custom-header'
		,field: 'FINAL_PAYMENT'
		,valueFormatter: currencyFormatter
		,suppressNavigable: true
		,filter:false
	},
	/* Rule - If "isEditableCheckbox" function returns true, then enable, else disable the check box */
	{headerName:"X", field:'IDONE', width:30, headerClass:'yes-big', cellRenderer: checkboxCellRenderer,
		onCellClicked: function(params) {
			if(isEditableCheckbox(params) == true){
				fnRecalculate(params,'fniDoneChanged',0);
				Deviations_GridOptions.api.redrawRows(params.node);	// This is known to be SLOW - https://www.ag-grid.com/javascript-grid-refresh/
			}
		}
		,filter:false
	},
	<cfif Get_Profile_Settings.View_Count_Column_In_Deviation_Grid eq 1>
	{headerName:"Count Volume", field:'COUNT_FLAG', type:'numericColumn', width:55, headerClass:'custom-header',
		headerComponent: CheckboxHeaderComponent,
		/* Rule - If "isEditableCheckbox" function returns true, then enable, else disable the check box */
		cellRenderer: checkboxCountCellRenderer,
		onCellClicked: function(params) {
			if(isEditableCheckbox(params) == true){
				fnRecalculate(params,'fnCountChange',0);
				synchHeaderCheckbox (isAllChecked ());
			}
		}
		,filter:false
	},
	</cfif>

];

var Deviations_GridOptions = {};	// Global so can access API later
function Build_DeviationsGrid() {
	// Init Billback Deviation grid
	Deviations_GridOptions = {
		columnDefs: columnDefs_deviations
		,rowModelType: "clientSide"
		,cacheBlockSize: 2000
		,enableBrowserTooltips: true
		// ,onGridReady: function () {
			 // this.api.sizeColumnsToFit();
		// }
		,groupHeaderHeight: 32
		,floatingFiltersHeight: 22
		,floatingFilter: true
		,getRowStyle: function(params) {
			if (params.data.IDONE == 0 && (params.data.DUMMY_PROGRAM == 1 || params.data.UNKNOWN_ITEM == 1)) {
				return { color: 'red',background: '#ffd3bd' } /* background is orange and font color is red (#ff0000) */
			}
			else if (params.data.DUMMY_PROGRAM == 1 || params.data.UNKNOWN_ITEM == 1) {
				return { background: '#ffd3bd'} /* background is orange and font color is the default color (black) */
			}
			else if (params.data.IDONE == 0 && params.data.VALIDATE_BB_UOM_FAILURE == 1) {
				return { color: 'red',background: '#ffeaa8' } /* background is yellow and font color is red (#ff0000) */
			}
			else if (params.data.VALIDATE_BB_UOM_FAILURE == 1) {
				return { background: '#ffeaa8' } /* background is yellow and font color is the default color (black) */
			}
			else if (params.data.IDONE == 0 || params.data.E_RATE > params.data.CLAIMED_RATE ) {
				return { color: 'red'} /* background is default and font color is red (#ff0000) */
			}
		}
		// ,suppressCellSelection: true		// leave as false to enable keyboard navigation, see https://www.ag-grid.com/javascript-grid-keyboard-navigation/
		,suppressClickEdit: !(editableGrid)
		,isExternalFilterPresent: isExternalFilterPresent
		,doesExternalFilterPass: showDeviatedRecordsOnly
		,singleClickEdit:true
		// Enable row click to highlight single row for WR 111043
		,rowSelection: 'single'
		,suppressRowClickSelection: false
		// 
		,getRowNodeId: function(data) { return data.SRNO }
		,suppressColumnVirtualisation: true			// so we don't lose the Total Deviation header amount (appendAmount) when scroll left/right SAH
    };
    ag_grid_default(Deviations_GridOptions);		// set up default features
	init_ag_grid( Deviations_GridOptions, "#Deviations_Grid", false );   // false=setup as client side
}

function loadDeviationData(){
	$.ajax({
		url: "ajax/deviation_data.cfm"
		,type: "POST"
		//,async: true
		,dataType: "json"
		,data: {BBID:<cfoutput>'#url.bbid#'</cfoutput>}
		,success: function( response ) {
			var arr_columns = [];
			/* We need the list of columns in javascript, but the columns are defined in CF (deviation_columns_arr).
			To get the list of columns in javascrpt, we need to loop through the data in CF and create an array
			in javascript. THis way we can get the same column list in javascript. No need to hardcdde the
			array in javascript.
			*/
			<cfoutput>
			<cfloop from="1" to="#ArrayLen(deviation_columns_arr)#" index="i">
				arr_columns.push('#deviation_columns_arr[i]#');
			</cfloop>
			</cfoutput>
			<!--- "response" does not have column names defined, but it has the array indexes defined.
			"convertToArrayOfObjects" function will assign column names, so that AG grid can load the
			data in appropriate columns. --->
			var data_to_load = convertToArrayOfObjects(response,arr_columns);

			Deviations_GridOptions.api.setRowData(data_to_load);
			onDataLoad();
			showDeviatedItems();
		}
	});
}


function isExternalFilterPresent() {
	return $('#cbShowDeviated').is(":checked");
}

function showDeviatedRecordsOnly(node) {
	let retValue = node.data.VARIATION_CLAIM_EXPECTED !=0;
	return retValue;
}

function showDeviatedItems(){
	let totalNumOfRows = 0;
	let deviatedCount = 0;
	totalNumOfRows = Deviations_GridOptions.api.getDisplayedRowCount();

	Deviations_GridOptions.api.forEachNode(function(node){
		if(node.data.VARIATION_CLAIM_EXPECTED != 0){
				deviatedCount = deviatedCount + 1;
		}
	});

	/* If the number of records is 20 or greater and there is at least one deviated record */
	<cfif Get_Profile_Settings.View_Deviated_Items_Only_OnLoad eq 1>
		if(totalNumOfRows >= 20 && deviatedCount >= 1){
			$('#cbShowDeviated').prop("checked", true).change();
            /* Notify the user that this checkbox is checked */
            new Noty({
                text: 'Showing only Deviated items',
                type: 'info', theme: 'relax',
                layout: 'topRight',
                timeout: 2500,
            }).show();
		}
	</cfif>
}

function onDataLoad(params){
	let claimedTotal = 0.0;
	let deniedTotal = 0.0;
	let expectedTotal = 0.0;
	let expectedLTTotal = 0.0;
	let acceptedTotal = 0.0;
	let approvedTotal = 0.0;
	let totalDeviation = 0.0;
	let selectedRate;
	let selectedVolume;
	let selectedInvoicePrice;
	let selectedProgramPrice;
	let finalPayment;
	let bExecNextIf = 1;
	let invoiceMinusProgramPrice = 0;

	Deviations_GridOptions.api.forEachNode(function(node){
		<cfif appSettings.getBB_LS_Claimed_Rebate_Expected() >
			if (node.data.BB_PRODUCT_TYPE_ID == 3){
					  node.data.SELECTED_RATE_TYPE = '1';
					  node.data.SELECTED_VOL_TYPE = '1';
			}
		</cfif>

		finalPayment =  node.data.FINAL_PAYMENT;

		if(node.data.SELECTED_VOL_TYPE == '3'){
			selectedVolume = node.data.MANUAL_VOL;
		}
		else if(node.data.SELECTED_VOL_TYPE == '2'){
			selectedVolume = node.data.E_VOLUME;
		}
		else{
			selectedVolume = node.data.CLAIMED_VOLUME;
		}


		if (node.data.BB_PRODUCT_TYPE_ID == 1 && node.data.EDITABLE_RATE == 0){
			if(
				(
					(node.data.SELECTED_INVOICE_PRICE_TYPE ==1) || (node.data.SELECTED_INVOICE_PRICE_TYPE ==2)
					||
					(node.data.SELECTED_INVOICE_PRICE_TYPE ==3)
				)
				&&
				(
					(node.data.SELECTED_PROGRAM_PRICE_TYPE == 1) || (node.data.SELECTED_PROGRAM_PRICE_TYPE ==2) || (node.data.SELECTED_PROGRAM_PRICE_TYPE ==3)
				)
			){
				if (node.data.SELECTED_INVOICE_PRICE_TYPE ==1){
					selectedInvoicePrice = node.data.CLAIM_INVOICE_PRICE;
				}
				else if(node.data.SELECTED_INVOICE_PRICE_TYPE == 2){
					selectedInvoicePrice = node.data.EXPECTED_INVOICE_PRICE;
				}
				else if (node.data.SELECTED_INVOICE_PRICE_TYPE == 3){
					selectedInvoicePrice = node.data.MANUAL_INVOICE_PRICE;
				}

				if (node.data.SELECTED_PROGRAM_PRICE_TYPE == 1){
					selectedProgramPrice = node.data.CLAIMED_PROGRAM_PRICE;
				}
				else if (node.data.SELECTED_PROGRAM_PRICE_TYPE == 2){
					selectedProgramPrice = node.data.EXPECTED_PROGRAM_PRICE;
				}
				else if (node.data.SELECTED_PROGRAM_PRICE_TYPE == 3){
					selectedProgramPrice = node.data.MANUAL_PROGRAM_PRICE;
				}

				/*
					21598:Solo - Final payment amount not being calculated correctly
					if Final Payment happens to be a negative value then change it
					to 0 [after discussion with Paul on 11-Dec-09]
				*/
				invoiceMinusProgramPrice = selectedInvoicePrice - selectedProgramPrice;
				if (invoiceMinusProgramPrice < 0){
					invoiceMinusProgramPrice = 0;
				}
				 finalPayment = RoundDecimals(invoiceMinusProgramPrice * selectedVolume);
				bExecNextIf = 0;
			}
		}

		if(bExecNextIf == 1){
			if(node.data.SELECTED_RATE_TYPE == '1'){
				selectedRate = parseFloat(node.data.CLAIMED_RATE);
			}
			else if(node.data.SELECTED_RATE_TYPE == '2'){
				selectedRate = parseFloat(node.data.E_RATE);
			}
			else if(node.data.SELECTED_RATE_TYPE == '6'){
				selectedRate = parseFloat(node.data.ELT_RATE);
			}
			else{
				selectedRate = parseFloat(node.data.MANUAL_RATE);
			}

			finalPayment = RoundDecimals(selectedRate * selectedVolume);
		}

			node.data.FINAL_PAYMENT = parseFloat(finalPayment.toString());

			expectedTotal = expectedTotal + parseFloat(node.data.EXPECTED_AMOUNT);
			<cfif iBBDevOverridePrice eq 0 AND appSettings.getBB_Approve_Expected_Rate_Less_Tolerance() eq 1>
			expectedLTTotal = expectedLTTotal + parseFloat(node.data.EXPECTEDLT_AMOUNT);
			</cfif>
			approvedTotal = approvedTotal + parseFloat(node.data.FINAL_PAYMENT);

			if(!isNaN(parseFloat(node.data.VARIATION_CLAIM_EXPECTED))){
				totalDeviation = parseFloat(totalDeviation.toString()) + parseFloat(node.data.VARIATION_CLAIM_EXPECTED);
			}

			if(node.data.DENIED == 1){
				deniedTotal = deniedTotal + parseFloat(node.data.CLAIMED_AMOUNT);
			}
			else{
				claimedTotal = claimedTotal + parseFloat(node.data.CLAIMED_AMOUNT);
			}

			acceptedTotal = parseFloat(acceptedTotal.toString()) +  parseFloat(node.data.CLAIMED_AMOUNT);
	});

	if (expectedTotal == '0' || expectedTotal == '')
	{
		expectedTotal = '$0.00';
	}
	if (approvedTotal == '0' || approvedTotal == '')
	{
		approvedTotal = '$0.00';
	}

	$("#actualDollars").html(currencyFormat(claimedTotal));
	$("#deniedDollars").html(currencyFormat(deniedTotal));
	// Expected $
	if(expectedTotal == '$0.00')
	{
		$("#expectedDollars").html('$0.00');
	}
	else
	{
		$("#expectedDollars").html(currencyFormat(expectedTotal));
	}
	<cfif iBBDevOverridePrice eq 0 AND appSettings.getBB_Approve_Expected_Rate_Less_Tolerance() eq 1>
	$("#expectedLTDollars").html(currencyFormat(expectedLTTotal));
	</cfif>
	// Claimed $
	if(claimedTotal == '$0.00')
	{
		$("#claimedDollars").html('$0.00');
	}
	else
	{
		$("#claimedDollars").html(currencyFormat(claimedTotal));
	}
	// Selected $
	if(approvedTotal == '$0.00')
	{
		$("#approvedDollars").html('$0.00');
	}
	else
	{
		$("#approvedDollars").html(currencyFormat(approvedTotal));
	}
	// find the eText element that should have the "Total Deviation" text in it, and append the amount
	$(".appendAmount span[ref='eText']").append("<br>"+currencyFormat(totalDeviation));

	/* Refresh grid */
	if($.type(params) === "undefined"){
		Deviations_GridOptions.api.refreshCells();
	}
	else{
		Deviations_GridOptions.api.refreshCells(params);
	}
}

// Comparator funtion, compares two strings, used for column sort
function compareStringCells(valueA, valueB, nodeA, nodeB, isInverted) {
	if (valueA === valueB) { return 0; }
	if (valueB > valueA) { return -1; }
	return valueA > valueB;
}

// Ex: $1,234.56
function currencyFormatter(params) {
	if (params.value == '0' || params.value == '')
	{
		return '$0.00';
	}
	else
	{
    return currencyFormat(parseFloat(params.value));
	}
}

// Ex: $1.2345/CS
function CurrencyUOMFormatter(params) {
	let fmt = '($0,0.0000)';
	if (params.value == '0' || params.value == '')
	{
		return '$0.00' + '/' + params.data.UOM_SHORT;
	}
	else
	{
		return currencyFormat(parseFloat(params.value), fmt) + '/' + params.data.UOM_SHORT;
	}
}

function currencyFormatterFour(params) {
	let fmt = '($0,0.0000)';
	return currencyFormat(parseFloat(params.value), fmt);
}

// Ex: 1,234.56
function numberFormatter(params) {
<cfif appSettings.getBB_Fractional_Volume() EQ 1>
	let fmt = '(0,0.000)';
	if (params.value == '0' || params.value == '')
	{
		return '0.000';
	}
<cfelse>
	let fmt = '(0,0)';
	if (params.value == '0' || params.value == '')
	{
		return '0';
	}
</cfif>
  return numberFormat(parseFloat(params.value),fmt);
}

// Ex: 1,234.00 CS
function UOMFormatter(params) {

	if (params.value == '0' || params.value == '')
	{
		return '0.00' + ' ' + params.data.UOM_SHORT;
	}
	else
	{
		return numberFormat(parseFloat(params.value)) + ' ' + params.data.UOM_SHORT;
	}
}

 /*
 * RoundDecimals() function handles the problem with rounding
 * Eg: when we had a value like xxx.905 instead of returning
 * xxx.91 the rounding function returned xxx.9 hence we had to handle
 * this scenario in this function.
 */
function RoundDecimals(theNumber){
	var strNumber = theNumber.toString();
	var nNumber = theNumber;
	var iPointPos = strNumber.indexOf("."); // or "," if the floating point is a coma
	var chrToCheck = strNumber.substr(iPointPos+3,1);
	var chrAfter3 = strNumber.substr(iPointPos+4,4);

	/*
		if the iPointPos is not -1 that means there is a decimal place in the number
		Process the number only then else return the number as it is.
	*/
	if (iPointPos != -1){
		// check to see if the character starting at 4th place and beyond are all 9
		// if so add a .001 if the value was .025 and got changed to .02499999999 then this will be corrected here.
		if (chrAfter3 == "9999"){
			nNumber = Number(strNumber) + .001;
		}
		strNumber = strNumber.substr(0, iPointPos + 4); // pickup till 3 places from the decimal
		// check to see if the third decimal after . is a 5 if so add 1
		if (chrToCheck == "5"){
			nNumber = Number(strNumber) + .001;
		}
		nNumber = Math.round((Number(nNumber))*Math.pow(10,2))/Math.pow(10,2);
	}
	return nNumber;
}

function fnRecalculateForAllRecords(params,sCaller,sOptionalVal){

	Deviations_GridOptions.api.forEachNode(function(node){

		switch(sCaller){
			/* BELOW ACTIONS DO NOT AFFECT ALL THE RECORDS. THEY ONLY AFFECT RECORDS WHICH HAVE THE SAME "BILLBACK_PRODUCT_ID". */

			/* When the "Count Volume" checkbox for individual records are checked or unchecked. */
			case "fnCountChange":
				if(node.data.BILLBACK_PRODUCT_ID == params.data.BILLBACK_PRODUCT_ID){
					node.data.COUNT_FLAG = !(node.data.COUNT_FLAG); // switch from ON to OFF and vice-versa.
				}
			break;
			/* When the "Volume" radio button for individual records are selected - Exp,Claimed or Manual. */
			case "fnRdoVolChange":
				if(node.data.BILLBACK_PRODUCT_ID == params.data.BILLBACK_PRODUCT_ID){
					node.data.SELECTED_VOL_TYPE = sOptionalVal;
				}
			break;

			/* BELOW ACTIONS AFFECT ALL THE RECORDS */

			/* When "Expected $" button gets clicked */
			case "fnExpectedAmountClicked":
				if(isEditableRate(node)){							// Check if editable
					node.data.SELECTED_VOL_TYPE = TYPE_E;
					node.data.SELECTED_RATE_TYPE = TYPE_E;
				}
				else if(isEditableInvoicePriceORProgramPrice(node)){
					node.data.SELECTED_VOL_TYPE = TYPE_E;
					node.data.SELECTED_INVOICE_PRICE_TYPE = TYPE_E;
					node.data.SELECTED_PROGRAM_PRICE_TYPE = TYPE_E;
				}
			break;
			/* When "Claimed $" button gets clicked */
			case "fnClaimedAmountClicked":
				if(isEditableRate(node)){							// Check if editable
					node.data.SELECTED_VOL_TYPE = TYPE_C;
					node.data.SELECTED_RATE_TYPE = TYPE_C;
				}
				else if(isEditableInvoicePriceORProgramPrice(node)){
					node.data.SELECTED_VOL_TYPE = TYPE_C;
					node.data.SELECTED_INVOICE_PRICE_TYPE = TYPE_C;
					node.data.SELECTED_PROGRAM_PRICE_TYPE = TYPE_C;
				}
			break;
			/* When "Expected $ LT" button gets clicked */
			case "fnExpectedAmountLTClicked":
				if(isEditableRate(node)){							// Check if editable

					/*Choose the Selected_Vol_Type to be "TYPE_E" which is Expected Volume
					and the Selected_Rate_Type to be "TYPE_LT" which is Expected Rate Less
					Tolerance. We are not setting the other values as they will not
					be available for display and only volume and rate will be visible.
					*/
					node.data.SELECTED_VOL_TYPE = TYPE_E;
					node.data.SELECTED_RATE_TYPE = TYPE_LT;
				}
			break;
			/* When "E" header button for "Rate" gets clicked */
			case "fnRateExpClicked":
				if ( (node.data.EDITABLE_RATE) && (isEditableRate (node)) ) {		// Check if shown & editable
					node.data.SELECTED_RATE_TYPE = TYPE_E;
				}
			break;
			/* When "C" header button for "Rate" gets clicked */
			case "fnRateClaimClicked":
				if ( (node.data.EDITABLE_RATE) && (isEditableRate (node)) ) {		// Check if shown & editable
					node.data.SELECTED_RATE_TYPE = TYPE_C;
				}
			break;
			/* When "LT" header button for "Rate" gets clicked */
			case "fnRateELTClicked":
				if ( (node.data.EDITABLE_RATE) && (isEditableRate (node)) ) {		// Check if shown & editable
					node.data.SELECTED_RATE_TYPE = TYPE_LT;
				}
			break;
			/* When "C" header button for "Volume" gets clicked */
			case "fnClaimedVolumeClicked":
				if ( isEditableVolume (node) ) {									// Check if editable
					node.data.SELECTED_VOL_TYPE = TYPE_C;
				}
			break;
			/* When "E" header button for "Volume" gets clicked */
			case "fnExpectedVolumeClicked":
				if ( isEditableVolume (node) ) {									// Check if editable
					node.data.SELECTED_VOL_TYPE = TYPE_E;
				}
			break;
			/* When "Volume Override" button gets clicked */
			case "fnVolOverride":
				if(isEditableVolume(node)){											// Check if editable
					node.data.E_VOLUME = node.data.CLAIMED_VOLUME;
					node.data.VOLUME_OVERRIDE = 1;
				}
			break;
			/* When "Rate Override" button gets clicked */
			case "fnRateOverride":
				if(isEditableRate(node)){											// Check if editable
					node.data.E_RATE = node.data.CLAIMED_RATE;
					node.data.RATE_OVERRIDE = 1;
				}
			break;
		}
	});
}


function fnRecalculate(params,sCaller,sOptionalVal){
	if(sCaller == 'fnSetRateManual' || sCaller == 'fnSetVolManual' || sCaller == 'fnSetInvManual' || sCaller == 'fnSetPrgManual'){
		var newCellValue = params.newValue;
		newCellValue = newCellValue.replace(",", "");
		newCellValue = newCellValue.replace("$", "");
	}

	switch(sCaller){
		case "fnSetRateManual":
			params.data.MANUAL_RATE = newCellValue;
			/* TO DO */
			/*evtObj.txtRateMan.setStyle("backgroundColor","#FFFFFF");// WHITE
			evtObj.txtRateMan.toolTip = "";
			*/
			if (parseFloat(newCellValue) > parseFloat(params.data.CLAIMED_RATE))
			{
				/* TO DO */
				/*evtObj.txtRateMan.setStyle("backgroundColor","#FFFF00");// YELLOW
				evtObj.txtRateMan.toolTip = "The Entered Manual Rate is Greater than Claim Rate";
				*/
			}
		break;
		case "fnSetVolManual":
			params.data.MANUAL_VOL = newCellValue;
			/* TO DO */
			/*evtObj.txtRateMan.setStyle("backgroundColor","#FFFFFF");// WHITE
			evtObj.txtRateMan.toolTip = "";
			*/
			if (parseFloat(newCellValue) > parseFloat(params.data.CLAIMED_VOLUME))
			{
				/* TO DO */
				/*evtObj.txtRateMan.setStyle("backgroundColor","#FFFF00");// YELLOW
				evtObj.txtRateMan.toolTip = "The Entered volume is Greater than Claimed volume";
				*/
			}
		break;
		case "fnSetInvManual":
			params.data.MANUAL_INVOICE_PRICE = newCellValue;
		break;
		case "fnSetPrgManual":
			params.data.MANUAL_PROGRAM_PRICE = newCellValue;
		break;
		/* When the "Invoice price" radio button for individual records are selected - Exp,Claimed or Manual. */
		case "fnRdoInvChange":
			params.data.SELECTED_INVOICE_PRICE_TYPE = sOptionalVal;
		break;
		/* When the "Program price" radio button for individual records are selected - Exp,Claimed or Manual. */
		case "fnRdoPgmChange":
			params.data.SELECTED_PROGRAM_PRICE_TYPE = sOptionalVal;
		break;
		/* When the "Rate" radio button for individual records are selected - Exp,Exp LT,Claimed or Manual. */
		case "fnRateChange":
			params.data.SELECTED_RATE_TYPE = sOptionalVal;
		break;
		case "fniDoneChanged":
			/* If it was unchecked */
			if(params.data.IDONE == "0"){
				/* User checked the option */
				params.data.IDONE = "2";
			}
			/* params.data.IDONE == "1", is when expected is greater than claimed. In that case, checkbox is checked. */
			else if (params.data.IDONE == "1" || params.data.IDONE == "2"){
				/* User unchecked the option */
				params.data.IDONE = "0";
			}
		break;
		default:
			fnRecalculateForAllRecords(params,sCaller,sOptionalVal);
	}

	onDataLoad(params);
}

function fnChkDecPlaces(params,type)
{
	let decimalPosition;
	let decimalPlaces;
	let decimalCount;

	/* For "volume" and "Rate" */
	if(type == 'volume'){
		decimalPosition = 4;
		decimalPlaces = 3;
		decimalCount = "three";
	}
	if(type == 'rate'){
		decimalPosition = 5;
		decimalPlaces = 4;
		decimalCount = "four";
	}

	/* For "Invoice Price" and "Program Price" */
	else if(type == 'invoicePrice' || type == 'programPrice'){
		decimalPosition = 3;
		decimalPlaces = 2;
		decimalCount = "two";
	}

	let newCellValue = params.newValue;
	let iPointPos = newCellValue.indexOf(".");
	let chrToCheck = newCellValue.substr(iPointPos+decimalPosition,1);
	let strWholePart = newCellValue.substr(0,iPointPos);
	let strDecimals = newCellValue.substr(iPointPos+1,decimalPlaces);
	let bSuccess = true;

	if(type == 'volume'){
		let allowBBFractionalVolume = <cfoutput>#appSettings.getBB_Fractional_Volume()#;</cfoutput>

		if(allowBBFractionalVolume == 0){
			if (iPointPos != -1){
				alert("Decimals not allowed!!");
				newValue = strWholePart;
				Deviations_GridOptions.api.setFocusedCell(params.node.rowIndex, params.colDef.field, null);	// Set focus on this cell
				bSuccess = false;
				var rowNode = Deviations_GridOptions.api.getRowNode(params.node.id);
				rowNode.setDataValue(params.colDef.field, newValue);
			}
		}
	}

	if(bSuccess == true){
		if (iPointPos != -1)
		{
			if (chrToCheck != ""){
				alert("Only " + decimalCount + " decimal places allowed!!");
				newValue = strWholePart + "." + strDecimals;
				bSuccess = false;
				Deviations_GridOptions.api.setFocusedCell(params.node.rowIndex, params.colDef.field, null);	// Set focus on this cell
				var rowNode = Deviations_GridOptions.api.getRowNode(params.node.id);
				rowNode.setDataValue(params.colDef.field, newValue);
			}
		}
	}

	return bSuccess;
}

// Check for numeric values only
function numberValueSetter(params) {
	let bSuccess = true;

	if (isNaN(parseFloat(params.newValue)) || !isFinite(params.newValue)) {
		alert('Only numeric values are allowed');
		var rowNode = Deviations_GridOptions.api.getRowNode(params.node.id);
		rowNode.setDataValue(params.colDef.field, '0');
		Deviations_GridOptions.api.setFocusedCell(params.node.rowIndex, params.colDef.field, null);	// Set focus on this cell
		bSuccess = false;
	}
	return bSuccess;
}

function checkManualData(params,type){
	let sAllowValuesGTClaimed = <cfoutput>#appSettings.getDeviationGridAllowManualValuesGTClaimed()#;</cfoutput>
	let sProfileAllowManualRateOverride = <cfoutput>#Get_Profile_Settings.BB_Dev_Grid_Manual_Rate_Override_Check#;</cfoutput>
	let newCellValue = params.newValue;
	let bSuccess = true;

	newCellValue = newCellValue.replace(",", "");
	newCellValue = newCellValue.replace("$", "");

	switch(type){
		case "rate":
			if ((sProfileAllowManualRateOverride == 0) && (parseFloat(newCellValue) > parseFloat(params.data.CLAIMED_RATE)) && sAllowValuesGTClaimed == 0){
				alert("You are not allowed to enter a rate greater than the claimed rate.");

				var rowNode = Deviations_GridOptions.api.getRowNode(params.node.id);
				rowNode.setDataValue(params.colDef.field, '0');
				Deviations_GridOptions.api.setFocusedCell(params.node.rowIndex, params.colDef.field, null);	// Set focus on this cell
				bSuccess = false;
			}
		break;
		case "volume":
			if ((Number(newCellValue) > Number(params.data.CLAIMED_VOLUME)) && sAllowValuesGTClaimed == 0){
				alert("Enter a value Less than or equal to the Claimed Volume!!")
				var rowNode = Deviations_GridOptions.api.getRowNode(params.node.id);
				//rowNode.setDataValue(params.colDef.field, params.data.CLAIMED_VOLUME);
				rowNode.setDataValue(params.colDef.field, '0');
				Deviations_GridOptions.api.setFocusedCell(params.node.rowIndex, params.colDef.field, null);	// Set focus on this cell
				bSuccess = false;
			}
		break;
	}

	return bSuccess;
}

function fnDoActions(obj){
	let element_id = $(obj).attr('id');
	let strAction = "";
	let arrGridData =  [];
	
	let refresh_parent = <cfoutput>"#parentRefresh#"</cfoutput>;

	switch (element_id){
		/* "save changes" button */
		case "btnSave":
			show_loader( "PLEASE WAIT...");
			strAction = "doSave"
			break;

		/* The below cases are grouped together as
		they are called for different buttons.
		They are all one case statement.
		*/
		case "btnExpectedAmt": /* Expected $ button */
		case "btnApprove": /* Selected $ button */
		case"btnClaimedAmt": /* Claimed $ button */
		case "btnExpectedAmtLT":  /* Expected $ LT button */
			strAction = "doSaveApprove"
			break;

		/* "Recalc Deviations" button */
		case "btnRecalc":
			show_loader( "PLEASE WAIT...");
			strAction = "doSaveRecalc"
			break;
	}

	/* Loop over the grid data and assign the data to an array.
	THis array will store the updated (if changed) grid data.
	*/
	Deviations_GridOptions.api.forEachNode(function(node){
		arrGridData.push(node.data);
	});

	$.ajax({type: "post"
			,url: "/mvc/models/Billback/BillbackDevAppManager.cfc"
			,dataType: "json"
			,data: { method: "updateBBDeviationsJSON"
					,Billback_ID: <cfoutput>'#url.bbid#'</cfoutput>
					,userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>
					,updateBBDev: JSON.stringify(arrGridData)
					,strAction: strAction
					,ApprovalButton: element_id
					}
			,success : function (response) {
					if(strAction == 'doSaveRecalc'){
						/* If the deviation was recalculated in the db, then we need to
						reload the data  - loadDeviationData(). If it actually got reloaded,
						the "response.STRMESSAGE" will contain the word "complete".
						In some cases, recalculation cannot not be done on the db - In those
						cases,we will get a different message and so the deviation grid will
						not be reloaded.
						*/
						if(response.STRMESSAGE.indexOf("Complete") !=  -1){
							/* Reset grid filters */
							Deviations_GridOptions.api.setFilterModel(null);

							/* Load data */
							loadDeviationData();

							/* Hide the existing loader */
							show_loader( "PLEASE WAIT...",-100);

							/* message to the user (success) */
							showMessage(response.STRMESSAGE,'success');
						}
						else{
							/* Hide the existing loader */
							//show_loader( "PLEASE WAIT...",-100);
							/* message to the user (error) */
							showMessage(response.STRMESSAGE,'error','',60000);
						}
						/* We need to use "hideOverlay" omly when the grid does not get updated. When the grid gets updated, then there is no need to use "hideOverlay" */
						Deviations_GridOptions.api.hideOverlay();
					}
					else if(strAction == 'doSave'){
						/* Hide the existing loader */
						show_loader( "PLEASE WAIT...",-100);

						if(response.STRMESSAGE.indexOf("Complete") !=  -1){
							/* message to the user (success) */
							showMessage(response.STRMESSAGE,'success');
						}
						else{
							/* message to the user (error) */
							showMessage(response.STRMESSAGE,'error');
						}
					}
					else if(strAction == 'doSaveApprove'){
						if(<cfoutput>'#sCallerSource#'</cfoutput> != 'Settlements' && <cfoutput>'#sCallerSource#'</cfoutput> != 'BBAgGridScoreCard' && <cfoutput>'#sCallerSource#'</cfoutput> != "BBSettlement"){
							refreshParent();
						}
						else if(<cfoutput>'#sCallerSource#'</cfoutput> == "BBSettlement"){
							refreshParent();
							window.opener.parent.get_iframe( "settlement" )[0].contentWindow.bb = window.opener.parent.get_iframe( "edit_<cfoutput>#qryBillbackHeader.Billback_ID_Int#</cfoutput>" )[0].contentWindow.bb;
							window.opener.parent.showSettlement();
							window.opener.parent.get_navli( "settlement" ).click();
							window.close();
							return;
						}
						if(refresh_parent == 'REFRESH')
						{
							refreshParent();
						} 
						window.location.href='/Billbacks/Approval/payment.cfm?BBID=' + <cfoutput>'#url.bbid#' + "&source=AgGridBB";</cfoutput>
					}
				}
	});
}

function fnExpectedAmountLTClicked(obj){
	show_loader( "PLEASE WAIT...");
	fnRecalculate('','fnExpectedAmountLTClicked',0);
	fnDoActions(obj);
}

function fnClaimedAmountClicked(obj){
	show_loader( "PLEASE WAIT...");
	fnRecalculate('','fnClaimedAmountClicked',0);
	fnDoActions(obj);
}

function fnExpectedAmountClicked(obj){
	show_loader( "PLEASE WAIT...");
	fnRecalculate('','fnExpectedAmountClicked',0)
	fnDoActions(obj);
}

function fnSelectedAmountClicked(obj){
	show_loader( "PLEASE WAIT...");
	fnDoActions(obj);
}

function fnOverLapReport(bbid) {
	show_loader( "PLEASE WAIT...");
	NewWindowTopLeft("/Billbacks/common/overLapReport.cfm?BBID=" + bbid + "&source=#sCallerSource#", "overlapReport", 300, 200, "yes", "yes");
	/* Hide the existing loader */
	show_loader( "PLEASE WAIT...",-100);
}

function fnDownloadDeviation(bbid,user_id) {
	show_loader( "PLEASE WAIT...");
	NewWindowTopLeft("/Billbacks/common/downloadDeviation.cfm?BBID=" + bbid +"&userID=" + user_id + "&source=#sCallerSource#", "downloadDeviationData", 300, 200, "yes", "yes");
	/* Hide the existing loader */
	show_loader( "PLEASE WAIT...",-100);
}

function fnDisagreeClicked(){
	show_loader( "PLEASE WAIT...");
	window.location.href='/Billbacks/common/BB_DisagreeFlx.cfm?BBID=' + <cfoutput>'#url.bbid#' + "&source=#sCallerSource#";</cfoutput>
}

function fnBackToDDReport(){
	show_loader( "PLEASE WAIT...");
	window.location.href='/billbacks/Deviation/Deviation_Main.cfm?BBID=' + <cfoutput>'#url.bbid#' + "&source=#sCallerSource#&caller=#sCallerSource#";</cfoutput>
}

function showMessage(text,type,layout,timeout){
	text = text;
	layout = layout || 'center';
	type = type || 'information';
	timeout = timeout || 1000;

	noty({
		text: text,
		layout: layout,
		type: type,
		timeout: timeout
	});
}

<cfif qryBillbackHeader.Validate_BB_UOM EQ "1" AND qryBillbackHeader.Validate_BB_UOM_Failure EQ "1">
	/* message to the user (error) */
	<cfoutput>
	 new Noty({
		text: "Please review the #lcase(application.returned_customer_setting.item_label)#'s UOM to ensure it is correct.",
		type: "warning", theme: "relax",
		layout: "topRight"
	}).show();

	</cfoutput>
</cfif>
</script>