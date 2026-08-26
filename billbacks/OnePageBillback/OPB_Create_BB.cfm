<!---
* ====================================================================================================
* @File: \billbacks\OnePageBillback\programs.cfm
* @Author: Dinesh Rachala
* @Date: June 2019
* @Remarks: OnePageBillback Settlements page - Programs search results tab content
* ====================================================================================================
--->
<cfscript>
	param name="form.BB_Date"	default="#dateformat(now(),'m/d/yyyy')#";
	param name="form.Del_Start"	default="";
	param name="form.Del_End"	default="";

	/*TOP FILTER FIELDS */
	param name="form.customer_search" default="" ;
	param name="form.customer_group_search" default="" ;
	param name="form.operator_search" default="" ;
	param name="form.program_search" default="" ;
	param name="form.item_search" default="" ;
	param name="form.item_group_search" default="" ;

	/*BOTTOM  FILTER FIELDS */
	param name="form.template_list" default="" ;
	param name="form.planner_template_list" default="" ;
	param name="form.paid_to" default="" ;
	param name="form.discount_type" default="" ;
	param name="form.component_list" default="" ;

	/*DATE SEARCH FIELDS */
	param name="form.startDate" default="" ;
	param name="form.startDateCondition" default=">=" ;
	param name="form.endDate" default="" ;
	param name="form.endDateCondition" default="<=" ;
	param name="form.BBCreateProcess" default="0" ;
</cfscript>

	<cfset userID = replace(request.AccessStructure.user_id,'-','_','ALL')>
	<cfset tableName= '####tmp_OPB_Program_Details_'&userID>

<cfoutput>

<div class="create m-1">
	<!--- Information cards at the top --->
	<div class="card-header">
		Billback Header Information
		<span style="padding: 0 0 0 5px">
			<i class="fa fa-info-circle" title="This information will be used to generate Billback(s)." style="font-size:11px"></i>
		</span>
		<span style="float:right">
			<span id="DedID" style="padding-right:10px;"></span>
			<span id="DedAmount"></span>
		</span>
	</div>

	<form name="BBCreate" id="BBCreate" method="post">
	<div class="cardmain">
		<div class="leftcardmain">
				<div style="width:120px;padding-top: 2px;">
					Billback Ref ##
					<input type="text" name="BB_Ref" id="BB_Ref" >
				</div>

				<div style="width:120px;padding-top: 2px;">
					Billback Date
					<input name="BB_Date" id="BB_Date" type="text" class="date-info " value="#form.BB_Date#" >
				</div>

				<div style="width:120px;padding-top: 2px;">
					Payee Type
					<select name="Payee_Type" id="Payee_Type" class="card-input" >
						<option value="0" id="0"> </option>
						<cfif val(appSettings.get_Setting('BB_display_distributor_payee'))>
							<option value="1">Distributor</option>
						</cfif>
						<cfif val(appSettings.get_Setting('BB_display_operator_payee'))>
							<option value="2">Operator</option>
						</cfif>
					</select>
				</div>

				<div style="width:120px;padding-top: 2px;">
					Closing Method
					<select id="Closing_Method" name="Closing_Method" class="card-input" >
						<option value="0" id="0" vendorRequired ="0"> </option>
						<cfloop query="qGetClosingMethods">
							<option value="#iBillback_Closing_Method_ID#" vendorRequired = #Vendor_Required#>#vchBillback_Closing_Method_Desc#</option>
						</cfloop>
					</select>
				</div>

				<div style="width:120px; padding-top: 2px">
					Vendor  <a id="vendorSearch"><cfoutput>#application.util.string.actionLinkFormat2('search')#</cfoutput></a> &nbsp;<img src="/images/i.gif" id="vendordetails" title="" style="display: none;">
					<input type="text" name="Vendor" id="Vendor" class="card-input" value=""  onkeyup="vendorInfo()">
					<input type="hidden" name="Vendor_Master_ID" id="Vendor_Master_ID"  value="" >
				</div>
<!---
				<div style="width:120px; padding-top: 2px;<cfif ! form.searchDD>display:none;</cfif>"  id="VarianceBox">
					Variance
					<input type="text" name="Variance" id="Variance"  value="">
				</div>
			--->
				<div style="width:120px; padding-top: 2px;">
					Notes<br>
					<textarea rows="2" cols="18"  name="BB_Creator_Notes" id="BB_Creator_Notes"></textarea>
				</div>
			<div style="width:240px; padding-top:2px;padding-bottom:2px">
				<div style="width:120px;float:left;">
					Delivery Start
					<input name="Del_Start" id="Del_Start" type="text" class="date-info " value="#form.Del_Start#" >
				</div>

				<div style="width:120px;float:right;">
					Delivery End
					<input name="Del_End" id="Del_End" type="text" class="date-info " value="#form.Del_End#" >
				</div>
			</div>
			<div style="width:260px; background-color:##82CAFF; padding-left:4px;padding-bottom:2px">
				<div style="width:120px; padding-top: 2px; float:left;">
				Claimed Amt
				<input type="text" name="Claimed_Amt_display" id="Claimed_Amt_display"  value=""  disabled>
				<input type="hidden" name="Claimed_Amt" id="Claimed_Amt"  value=""  disabled>
				</div>
<!---
				<div style="width:120px;display:none;">
				Allocated Amt
				<input type="text" name="Allocated" id="Allocated"  value="0.00" >
				</div>
			--->
				<div style="width:130px; padding-top: 2px; float:right;">
				Claimed Qty
				<input type="text" name="Claimed_Qty" id="Claimed_Qty"  value="" disabled>&nbsp;CS
				</div>
			</div>
			<div style="width:210px;float:left;margin-left:2px">
				<div id="myDropId" class="dropzone dz-clickable" style="height:auto;">
					<div class="dz-message">
						<span>Upload documents</span>&nbsp;&nbsp;<i class="fa fa-info-circle" title="No documents attached." style="font-size:11px" id="DocNames"></i><br>
					</div>
				</div>
			</div>
	</div>

<div class="rightcardmain">
	<div style="width:100%;margin-top:10px;">
		<button type="button" id="CreateBB" title="Generate Billback" class="button recommended" disabled>Create Billback</button>
		<button type="button" id="RunDeviation" title="Run Deviation" class="button recommended">Run Deviation</button>
		<button type="button" id="Reset" title="Clear Billback Form" class="button">Reset</button>
	</div>

	<div style="width:100%;margin-top:10px;">
		<button type="button" id="addProducts" title="Add Items To Billback" class="button" disabled>Add Products</button>
		<button type="button" id="download_data" class="button" style="display: none;"><i class="fa fa-arrow-down btn-icon"></i>&nbsp;Download Data</button>
		<button type="button" id="column_tool" title="Show Columns" class="button">Show Columns</button>
	</div>

	<input type="hidden" name="BBCreateProcess" id="BBCreateProcess" value="#form.BBCreateProcess#">
	<input type="hidden" name="ItemPaidTo" id="ItemPaidTo" value="">
	<input type="hidden" name="PaidToMatch" id="PaidToMatch" value="">
	<input type="hidden" name="Deduction_ID" id="DeductionID" value="">
	<input type="hidden" name="DDAmount" id="DDAmount" value="">
	<input type="hidden" name="Doc_ID" id="Doc_ID" value="">
	<input type="hidden" name="Allocated" id="Allocated"  value="0.00" >
</div>

</form>
</div>

<!------------- File list Results area ------------->
<div class="upl-table" id="previews">
	<!--- upload result gets put here via shared template --->
</div>
<script>
	setupDropzone(
	 "/billbacks/capture/ajax/attachments_form.cfm?BBID=0",	//upload url
	 getDocIDs,	//callback after acknowledging completion
	 20,		// max files
	 19);	// max size MiB

	 //$(".upl-table").css("display", "none");
	 function getDocIDs(docCount){
	 $.ajax( {
		 type: "POST"
		,url: "/mvc/models/OnePageBillback/OPBManager.cfc?method=getDocIds&ReturnFormat=JSON"
		,data: ({ count : docCount })
		,dataType: 'JSON'
		,success: function(response){
				//console.log(response[0])
				//console.log(response[1])
					$('##Doc_ID').val(response[0]);
					var fileNames = response[1];
								fileNames = fileNames.replace(/,/g, '\n');
					$('##DocNames').attr('title', 'Successfully uploaded below document(s)\n' + fileNames );
					$( '.upl-table').empty();
	}
		,error: function(xhr, textStatus, errorThrown){
			new Noty({ layout:"center", type:"error", text: noty_message("Request Failed.") }).show();
		}
	});
}
</script>
<!--- result count and action button area --->
<div id="detailsRecord">&nbsp;</div>
<!--- Program GRID --->
<div id="programGrid" class="ag-theme-balham"></div>

</div>
</cfoutput>

<script>
$("#Reset").click(function () {
  $("#BBCreate")[0].reset();
  $('#VendorInfo').empty();
  clearData(0);
  return false;
});

$("#download_data").click(function(){
	frmSettlements.submit();
});

$("#vendorSearch").click(function(){
			window.open('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=BBCreate&Settlements=1','vendorMaster','width=800,height=500,scrollbars=1');
})

$(".date-info").datepicker({
	dateFormat: "m/d/yy",
	changeMonth: true,
	changeYear: true,
	onSelect: function( selected ) {
		let dateName = jQuery(this).attr("name");
		// change date limit based on selected value (if start/end)
		if ( dateName === "Del_Start" )
			jQuery("input[name=Del_End]").datepicker("option", "minDate", selected);
		else if ( dateName === "Del_End" )
			jQuery("input[name=Del_Start]").datepicker("option", "maxDate", selected);
	}
});

// Toggle the column tool button
$("#column_tool").click(function(){
	if ( ProgramGridOptions.api.isSideBarVisible() ) {
		ProgramGridOptions.api.setSideBarVisible(false);
		$(this).text( "show columns" );
	}
	else {
		ProgramGridOptions.api.setSideBarVisible(true);
		ProgramGridOptions.api.openToolPanel('columns');
		$("div.ag-side-buttons").hide();
		$(this).text( "hide columns" );
	}
});
//ADD PRODUCTS POP-UP
$("#addProducts").click(function(){
		window.open('opb_add_products.cfm','add_products', 'status=0,toolbar=0,location=0,menubar=0,directories=0,resizable=0,scrollbars=0,height=700,width=750');
})

// Create the sideBarDef object
function setup_sidebar(gridOptions) {
	gridOptions.sideBar = {
		hiddenByDefault: true,
		toolPanels: [ {
			id: 'columns',
			labelDefault: 'Columns',
			labelKey: 'columns',
			iconKey: 'columns',
			toolPanel: 'agColumnsToolPanel',
			toolPanelParams: {
				suppressColumnExpandAll: true,
				suppressColumnFilter: true,
				suppressColumnSelectAll: true,
				suppressPivotMode: true,
				suppressPivots: true,
				suppressRowGroups: true,
				suppressValues: true,
			}
		}]
	};
}

var ProgramGridOptions = {
	columnDefs: [
			{headerName: "<cfoutput>#Application.PlannerLabel#</cfoutput> #", hide:"true", sortable: "true", field: "Planner_Number",  width:85, valueGetter:function(p){return p.data[ 0 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Program", field: "Program_Number",  width:85, filter: 'text', valueGetter:function(p){return p.data[ 1 ]}
			,cellRenderer: function(p) {
										let prg_link = "<a onclick=javascript:openPRG('"+p.data[32]+"') title='Click here to view/edit program'>"+p.data[ 1 ]+ "</a>";
										return prg_link;
				}
				,floatingFilter:"true"
			},
			{headerName: "Template", hide:"true", field: "Template",  width:150, valueGetter:function(p){return p.data[ 35 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Segment", hide:"<cfoutput>#businessSegmentsOn#</cfoutput>", field: "Segment",  width:85, valueGetter:function(p){return p.data[ 36 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Title", hide:"true", field: "Program_Title",  width:150, valueGetter:function(p){return p.data[ 2 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Customer ID", field: "Customer_ID",  width:85, valueGetter:function(p){return p.data[ 3 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Customer Name", field: "Customer_Name",  width:150, valueGetter:function(p){return p.data[ 4 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Start Date", field: "Delivery_Start_Date",  width:135, valueGetter:function(p){return dateFormat(p.data[ 5 ],  'MM/DD/YYYY')}, filter: 'date',floatingFilter:"true"},
			{headerName: "End Date", field: "Delivery_End_Date",  width:135, valueGetter:function(p){return dateFormat(p.data[ 6 ],  'MM/DD/YYYY')}, filter: 'date',floatingFilter:"true"},
			{headerName: "Item", field: "Item_Number",  width:100, valueGetter:function(p){return p.data[ 7 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Description", hide:"true",  field: "Item_Description",  width:150, valueGetter:function(p){return p.data[ 8 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Discount", field: "Discount_Type",  width:85, valueGetter:function(p){return p.data[ 9 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Component", field: "Component_Name",  width:125, valueGetter:function(p){return p.data[ 10 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Paid To", field: "Paid_To",  width:85
				, valueGetter:function(p){
					 if(p.data[23] ==1) {
					 		return 'Distributor';
					 }  else{
					 		return 'Operator';
					 }
					}
				, filter: 'text',floatingFilter:"true"},
			{headerName: "Rate", field: "Program_Rate",  width:85, valueGetter:function(p){return p.data[11]}, valueFormatter:function (p){return currencyFormat(p.data[11],  '$(0,0.00)');}, cellStyle: function(p) {if (p.data[ 11 ] < 0) {return {color: 'red'};}}, filter: 'number',floatingFilter:"true"},
			{headerName: "UOM", field: "Rebate_UOM",  width:40, valueGetter:function(p){return p.data[ 12 ]}, filter: 'text',floatingFilter:"true"},
			{headerName: "Volume", field: "Volume", type: "numericColumn",  width:85, editable: true, filter: 'number', cellStyle: function() { return { backgroundColor: '#e5ffe5'} }
				, valueGetter:function(p){ 	return p.data[ 13 ]	}
				, valueSetter: function(p) {
	            if (p.data[ 13 ] !== p.newValue) {
	                p.data[ 13 ] = p.newValue;
	                if(p.data[22] == 2){//REBATE
	                	 p.data[ 15 ] = p.data[11] * p.data[13];
	              	}
	              	 if(p.data[22] ==1){//FIXED
	              	 	p.data[ 15 ] = '0.00';//p.data[13];
	              	 }
	              	 if(p.data[22] ==3){//LUMPSUM
	              	 	p.data[ 15 ] = p.data[11];
	              	 	p.data[ 13 ] = 'X';
	              	 }
	                return true;
	            } else {
	                return false;
	            }
					}
					,floatingFilter:"true"
			},
			{headerName: "UOM", field: "Volume_UOM", editable: true, filter: 'text', width:40, cellStyle: function() { return {backgroundColor: '#e5ffe5'} }
				, cellEditor: 'agRichSelectCellEditor'
				,	cellEditorParams: function (params) {
						var defaultUOM = volUOM(params.data[ 12 ]);
						return { values: defaultUOM };
					}
		 		, valueGetter:function(p){  return p.data[ 14 ];	}
		    , valueSetter: function(p) {

	if(p.data[12] != p.newValue ){//PROGRAM RATE UOM AND VOLUME UOM NOT MATCH
			/*
				p.data[11] = PROGRAM RATE
				p.date[12] = PROGRAM UOM
				p.data[13] = VOLUME
				p.data[15] = EXTENDED AMOUNT
				p.data[31] = PRICE CS
			*/
			var Rate_CS = 0;
			var Rate = p.data[11];
			var Net_Weight = p.data[28];
			var Sleeves_Per_Case = p.data[29];
			var Case_Count = p.data[30];

			if(p.data[12] == 'EA'){
				Rate_CS = (Rate * Case_Count);
			}
			if(p.data[12] == 'CWT'){
			var RateLB = Rate/100 ;
			     	Rate_CS = (RateLB * Net_Weight);
			}
			if(p.data[12] == 'SL'){
				Rate_CS = (Rate * Sleeves_Per_Case);
			}
			if(p.data[12] == 'LB'){
			 	Rate_CS = (Rate * Net_Weight);
			}
			if(p.data[12] == 'CS'){
				Rate_CS = Rate;
			}
			if(p.data[12] == '%'){
				Rate_CS = Rate * 0.01*p.data[31];
			}
			if(p.newValue == 'LB'){
					var RateCS = (Rate_CS / Net_Weight);
					if(p.data[12] == '%'){
						RateCS = Rate * 0.01*(p.data[31] / Net_Weight);
					}
						p.data[ 15 ] = RateCS  *  p.data[13];
			}
			if(p.newValue == 'CS'){
				p.data[ 15 ] = Rate_CS *  p.data[13];
			}
		}else{//PROGRAM RATE UOM AND VOLUME UOM IS MATCH
			if(p.data[9] == 'Rebate'){
				p.data[ 15 ] = p.data[11] * p.data[13];
			}
			if(p.data[9] == 'Fixed'){
				p.data[ 15 ] = '0.00';//p.data[13];
			}
		}
		if(p.data[9] != 'Lump Sum'){
				if (p.data[ 14 ] !== p.newValue) {
						p.data[ 14 ] = p.newValue;
						return true;
				} else {
						return false;
				}
		}
			}
			,floatingFilter:"true"
			},
			{headerName: "Ext Amount", field: "Extended_Amount",  width:85, editable: true, filter: 'number', cellStyle: function(p) {
				 if (p.data[ 15 ] < 0) {
	            return {color: 'red', backgroundColor: '#e5ffe5'};
	        } else{
			 			return { backgroundColor: '#e5ffe5'}
						 }
			}
				, valueSetter: function(p) {
					      if (p.data[ 15 ] !== p.newValue) {
	                p.data[ 15 ] = p.newValue;
	                return true;
	            } else {
	                return false;
							}
					 }
					 , valueGetter:function(p){return p.data[15]}, valueFormatter:function (p){return  currencyFormat(p.data[15],  '$(0,0.00)'); }
					 ,floatingFilter:"true"
			},
			{headerName: "Indirect",  field: "Operator_ID", width:125
			, valueGetter:function(p){
				if(p.data[ 33 ] !='' || p.data[ 16 ] !=''){
					return p.data[ 33 ] + ' ( '+p.data[ 16 ]+' )'
				}else{
					return;
				}
				}
			, valueSetter: function(p) {
          if (p.data[ 16 ] !== p.newValue) {
              p.data[ 16 ] = p.newValue;
              return true;
          } else {
              return false;
          }
      }
			, editable: true
			, cellStyle: function() { return { backgroundColor: '#e5ffe5'} }
			, filter: 'number',floatingFilter:"true"},
			{headerName:"", width:30, headerComponent: CheckboxHeaderComponent, cellRenderer: 'iconCellRenderer', filter:false, suppressMenu:true,floatingFilter:"true"},
			{headerName: "Accrued", hide:"true", field: "Accrued", width:85, valueGetter:function(p){return p.data[17]}, valueFormatter:function (p){return currencyFormat(p.data[17],  '$(0,0.00)');}, filter: 'number',floatingFilter:"true"},
			{headerName: "Settled",  hide:"true", field: "Settled", width:85, valueGetter:function(p){return p.data[18]}, valueFormatter:function (p){return currencyFormat(p.data[18],  '$(0,0.00)');}, filter: 'number',floatingFilter:"true"},
			{headerName: "Balance", hide:"true", field: "Balance", width:85, valueGetter:function(p){return p.data[19]}, valueFormatter:function (p){return currencyFormat(p.data[19],  '$(0,0.00)');}, filter: 'number',floatingFilter:"true"},
		]
		,rowModelType:   "clientSide"
		//,floatingFilter:"true"
		,enableBrowserTooltips: true
		,defaultColDef: {
				 sortable: true
				,filter: true
				,floatingFilterComponentParams:{suppressFilterButton:true}
				,resizable: true
    }
		,onCellValueChanged: function(event) {
			if(event.column.colId == 'Operator_ID'){
					getOperators(event);
				}
					saveDetailsInfo(event);
	    }
	    ,enableCellChangeFlash: "true"
			,enterMovesDownAfterEdit: true
			,undoRedoCellEditing: true
	    ,components: {
	    	 iconCellRenderer: IconCellRenderer
    }
	};

//CLEAR USER ENTERED DATA IN DETAILS SECTION
function clearData(id){
	var claimedAmt = $('#Claimed_Amt').val();
	var Claimed_Amt_display = $('#Claimed_Amt_display').val();
	var claimedQty = $('#Claimed_Qty').val();

	$.ajax( {
		 type: "POST"
		,url: "/mvc/models/OnePageBillback/OPBManager.cfc?method=ClearValues&ReturnFormat=JSON"
		,data: ({ ID 	: id })
		,dataType: 'JSON'
		,success: function(response){
					$('#Claimed_Amt').val(numberFormat(response.DATA[0][1],  '(0,0.00)'));
					$('#Claimed_Amt_display').val(currencyFormat(response.DATA[0][1],  '($0,0.00)'));
					$('#Claimed_Qty').val(response.DATA[0][0]);
				ProgramGridOptions.api.forEachNode(function(node){
					if(id == node.data[34]  || id == 0){
						node.data[13] = 0;
						node.data[14] = node.data[12];
						node.data[15] = '0.00';
						ProgramGridOptions.api.refreshCells();
					}
				})
				new Noty({ layout:"topRight", type:"info", text: noty_message('Data Cleared'), timeout:1000 }).show();
	}
		,error: function(xhr, textStatus, errorThrown){
			new Noty({ layout:"center", type:"error", text: noty_message("Request Failed.") }).show();
		}
	});
}

//FUNCTION TO ADD ICON IN HEADER
function CheckboxHeaderComponent() {}
	CheckboxHeaderComponent.prototype.init = function (params) {
		this.params = params;
		this.eGui = document.createElement('div');
		var domString = '<div class="ag-cell-label-container ag-header-cell-sorted-none" role="presentation">'+
																'<div ref="eLabel" class="ag-header-cell-label" role="presentation" unselectable="on"> '+
																'<span ref="eText" class="ag-header-cell-text cursor-auto" role="columnheader" unselectable="on">'+
																'<img src="/Images/delete.gif" onclick="clearData(0)">'+
																'</span>'+
																'</div></div>';
		this.eGui.innerHTML = domString;
	}
CheckboxHeaderComponent.prototype.getGui = function () { return this.eGui; };

//FUNCTION TO ADD ICON IN DETAILSSECTION
function IconCellRenderer(){ }
	IconCellRenderer.prototype.init = function(params) {
		this.eGui = document.createElement('div');
		this.eGui.innerHTML = '<div class="customHeaderMenuButton"  onclick="clearData( ' +params.data[34] + ' );"><img src="/Images/delete.gif"></div>';
	};

	IconCellRenderer.prototype.getGui = function() {
		return this.eGui;
	};

//FUNCTION TO BUILD DETAILS GRID
function Build_ProgramsGrid() {
	set_grid_full_height ("programGrid");
	jsonLoad();
	setup_sidebar(ProgramGridOptions);
	ag_grid_default (ProgramGridOptions);
  no_data_available(ProgramGridOptions, "hidden");   // suppress no data available message
	init_ag_grid( ProgramGridOptions, "#programGrid", false );
}

//FUNCTION TO VALIDATES IF USER ENTERED OPERATOR ID IS VALID
function getOperators(event){
	$.ajax( {
		 type: "POST"
		,url: "/mvc/models/OnePageBillback/OPBManager.cfc?method=getOperators&ReturnFormat=JSON"
		,data: ({
			 contract_main_id 	: event.data[32]
			,search_string	: event.data[16]
		})
		,dataType: 'JSON'
		,success: function(response){
			if(response.DATA.length){
				ProgramGridOptions.api.forEachNode(function(node){
					if(event.data[32] == node.data[32]){//UPDATE OPERATOR ID FOR ALL RECORDS WITH SAME  CONTRACT MAIN ID
	    				node.data[16] = response.DATA[0][1];
	    				node.data[33] = response.DATA[0][0];
	    				ProgramGridOptions.api.refreshCells();
					}
				})
			}else{
				new Noty({ layout:"center", type:"error", text: noty_message("Invalid Operator.") }).show();
			}
		}
		,error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
	});
}
//FUNCTION TO POPULATE UOM DROP DOWN VALUES
function volUOM(prgUOM){
	var UOM =[ 'LB', 'CS'];
	if(prgUOM !='CS'  &&  prgUOM !='LB' ){
		UOM.push(prgUOM);
	}
	return UOM;
}
//FUNCTION TO UPDATE TEMP TABLE WITH VOLUME, UOM,EXTENDED AMOUNT
function saveDetailsInfo(event){
	if(event.data[13].length){
			$.ajax( {
						type: "POST"
						, url: "ajax/OPB_Program_Details.cfm"
						, data: {
										 Program_Number	: event.data[1]
										,Program_Rate	: event.data[11]
										,Volume	: event.data[13]
										,Volume_UOM	: event.data[14]
										,Extended_Amount : event.data[15]
										,Operator_ID : event.data[16]
										,Accrued	: event.data[17]
										,Settled : event.data[18]
										,Balance : event.data[19]
										,BSA_Foodservice_Customers_ID	: event.data[20]
										,BSA_Foodservice_Items_Master_ID	: event.data[21]
										,Discount_Type_ID		: event.data[22]
										,Component_Paid_To	: event.data[23]
										,Rebate_UOM_ID	: event.data[24]
										,Component_Name_ID	: event.data[25]
										,TableName : <cfoutput>'#tableName#'</cfoutput>
									  ,saveDetailsInfo : 1
						}
						, dataType: 'JSON'
						, success: function(response){
								$('#Claimed_Amt').val(response.ROWS[0][1]);
								$('#Claimed_Amt_display').val(currencyFormat(response.ROWS[0][1],  '($0,0.00)'));
								$('#Claimed_Qty').val(response.ROWS[0][0]);

								var cAmount = response.ROWS[0][1]; // CLAIMED AMOUNT
								var DDAmount = $('#DedAmount').text().replace('$', ''); // DD AMOUNT
								var vAmount = DDAmount - cAmount; //VARIANCE AMOUNT

								$("#Variance").val( vAmount );
								$("#PaidToMatch").val(response.ROWS[0][2]);
								$("#ItemPaidTo").val(response.ROWS[0][3]);

								var BPaidTo = $("#Payee_Type option:selected").val();
								if(BPaidTo && BPaidTo != response.ROWS[0][3])
									$("#PaidToMatch").val(0);
						},
				error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
			});
	}
}
//FUNCTION TO GET ITEMS BASED ON USER SEARCH
function jsonLoad(callback) {
	if (ProgramGridOptions) {
		if (ProgramGridOptions.api) {
			ProgramGridOptions.api.showLoadingOverlay();
      no_data_available(ProgramGridOptions, "visible");
		}
	}
		$.ajax({	 type    : "post"
						,url     : "ajax/OPB_Program_Details.cfm"
						,dataType: "json"
						,data    : { returnFormat: "json"
														,customer_search: $( "#customer_search" ).val()
														,customer_group_search: $( "#customer_group_search" ).val()
														,operator_search: $( "#operator_search" ).val()
														,program_search: $( "#program_search" ).val()
														,item_search: $( "#item_search" ).val()
														,item_group_search: $( "#item_group_search" ).val()
														,template_list: $("select[name=template_list]").multipleSelect('getSelects').toString()
														,planner_template_list: $("select[name=planner_list]").multipleSelect('getSelects').toString()
														,paid_to: $("select[name=paid_to]").multipleSelect('getSelects').toString()
														,discount_type: $("select[name=discount_type]").multipleSelect('getSelects').toString()
														,component_list: $("select[name=component_list]").multipleSelect('getSelects').toString()
														,startDate: $( "#startDate" ).val()
														,startDateCondition : $( "#startDateCondition" ).val()
														,endDate: $( "#endDate" ).val()
														,endDateCondition : $( "#endDateCondition" ).val()
														,search : $( "#search" ).val()
									}
						,success : function (response) {
							console.log(response.ROWS)
								ProgramGridOptions.api.hideOverlay();
									if (typeof response === 'string') {
										response = JSON.parse(response);
									}
									if( response.ROWS.length ){ //HIDE CONTROL PANEL(LEFT SIDE) IF SEARCH HAS ANY RESULTS
										$('#download_data').show();
										if(response.ROWS[0][27] > 10000){
												ProgramGridOptions.api.setRowData(  );
												ProgramGridOptions.api.hideOverlay();
												var errors = [];
															errors.push("Search criteria resulted in "+ response.ROWS[0][27] +" programs.<br>Please narrow the search criteria.");
															new Noty({ layout:"center", type:"error", text: noty_message(errors.join("<br>")) }).show();
										}else{
											if(response.ROWS[0][27] > 2000){
												$('#detailsRecord').text("Displaying top 2000 records out of  "+ response.ROWS[0][27] +" records. Please narrow the search criteria.")
												$('#detailsRecord').css("color", "red");
												}
											hideLeftPane();
											$('#BBAllocate').removeAttr("disabled");
											$('#CreateBB').removeAttr("disabled");
											$('#addProducts').removeAttr("disabled");
											ProgramGridOptions.api.setRowData( response.ROWS );
											autoSizeAllColumns( ProgramGridOptions )
										}
									}else{
										ProgramGridOptions.api.setRowData(  );
									}
							}
						,error: function(xhr, status, err) {
							new Noty({ layout:"center", type:"error", text: "Process Failed" }).show();
							}
		});

}

//FUNCTION TO GET VENDOR INFORMATION
function vendorInfo(){
	var vendor = $("#Vendor").val();
if(vendor.length >3){
	$.ajax( {
				type: "POST",
				url: "/components/Billback/Quick_Pay.cfc?method=getVendorInfo&ReturnFormat=JSON",
				data: ({	 vendorID: $("#Vendor").val(), type: 1 }),
				dataType: 'JSON',
				success: function(response){
					if(response.DATA.length){
						$("#Vendor").css("border", "black solid 1px");
						$('#VendorInfo').css("color", "black");
						$('#vendordetails').show();
						//$('#VendorInfo').empty();
						//$('#VendorInfo').append(response.DATA[0][0]);
								$('#vendordetails').attr('title', '');
								$('#vendordetails').attr('title', response.DATA[0][0]);
						$('#Vendor_Master_ID').val(response.DATA[0][1]);
					}else{
						$("#Vendor").css("border", "red solid 1px");
						$('#VendorInfo').empty();
						$('#vendordetails').show();

						$('#vendordetails').attr('title', 'Vendor ID is invalid');

						//$('#VendorInfo').append('Vendor ID is invalid');
						$('#VendorInfo').css("color", "red");
						$('#Vendor_Master_ID').val();
					}
				},
				error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
			});
}
}
$("#RunDeviation").click(function(){

	setActiveTab('processId')
	setActiveArea('process')
	activateTab( 'process' );

	new Noty({ layout:"center", type:"info", text:  "Processing....."}).show();
	$("#bb_customer_search").val('');//CLEAR THIS FILED IF TI'S CARRIED OVER FROM PROCESS TAB
	$('#dd_customer_search').val('');//CLEAR THIS FILED IF TI'S CARRIED OVER FROM PROCESS TAB
	$.ajax( {
		type: "POST",
		url: "/mvc/models/OnePageBillback/OPBManager.cfc?method=runDeviations&ReturnFormat=JSON",
		data: ({ }),
		dataType: 'JSON',
		success: function(response){
			$("#noty_layout__center").hide();
			$("#fromCreate").val(1);
			$("#payable_search").val(response);
			BBvalidate();
			$("#payable_search").val('');
		},
		error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
	});
});

//FUNCTION TO CHECK IF BB AND ITEMS HAVE SAME COMPONENT PAID TO
$("#Payee_Type").change(function() {
			var ICPaidTo =  $("#ItemPaidTo").val();
			var BPaidTo = $("#Payee_Type option:selected").val();
			var PaidToMatch = $("#PaidToMatch").val();

			if( ICPaidTo != BPaidTo && PaidToMatch){
				$("#PaidToMatch").val(0);
			}else{
				$("#PaidToMatch").val(1);
			}
});

$("#CreateBB").click(function(){
	$.ajax({
		type: "POST",
		url: "/mvc/models/OnePageBillback/OPBManager.cfc?method=CheckFixedPrice&ReturnFormat=JSON",
		data: ({}),
		dataType: 'JSON',
		success: function(response){
			secondaryValidation(response);
		},
		error: function(xhr, textStatus, errorThrown){
			new Noty({ layout:"center", type:"error", text: "Fixed Price Validation Process Failed" }).show();
		}
	});
});

//FUNCTION TO VALIDATE REQUIRED FIELDS
  function secondaryValidation(response){
  	/*BILLBACK HEADER VALIDATION*/
  	var BBRef  = $("input[name=BB_Ref]").val();
  	var BBDate  = $("input[name=BB_Date]").val();
  	var PayeeType = $("#Payee_Type option:selected").length;
  	var VendorID  = $("input[name=Vendor]").val();
  	var VendorReq  = $("#Closing_Method option:selected").attr("vendorrequired");
  	var DStartDate  = $("input[name=Del_Start]").val();
  	var DEndDate  = $("input[name=Del_End]").val();
  	var ClosingMethod = $("#Closing_Method option:selected").length;
  	var BBNotes =  $("#BB_Creator_Notes").val();

	/*SETTLEMENT DETAILS VALIDATION*/
  	var claimedAmt  = $("input[name=Claimed_Amt]").val();
  	var claimedQty  = $("input[name=Claimed_Qty]").val();
  	var ReasonCode = $("#Closure_Reason_Code option:selected").length;
  	var Variance  = $("input[name=Variance]").val();

  	var PaidToMatch = $("#PaidToMatch").val();

  	/*BILLBACK HEADER VALIDATION*/
		var errors = [];

  	  if (BBRef === ''){
	       errors.push("Please enter a value for Billback Reference.");
	    }
  	  if (BBDate === ''){
	       errors.push("Please select Billback Date.");
	    }
  	  if (PayeeType === ''){
	       errors.push("Please select payee type.");
	    }
  	  if (VendorReq == 1 && VendorID === ''){
	       errors.push("Please enter a value for Vendor ID.");
	    }
  	  if (DStartDate === ''){
	       errors.push("Please select Delivery Satrt Date.");
	    }
  	  if (DEndDate === ''){
	       errors.push("Please select Delivery End Date.");
	    }
  	  if (ClosingMethod === ''){
	       errors.push("Please select a closing method.");
	    }

	  /*SETTLEMENT DETAILS VALIDATION*/
  	  if (claimedAmt === ''){
	       errors.push("Please enter a value for Claimed Amount.");
	    }
  	  if (claimedQty === ''){
	       errors.push("Please enter a value for Claimed Quantity.");
	    }
  	  if (ReasonCode === ''){
	       errors.push("Please select a reason code.");
	    }
 	  if (PaidToMatch == '0'){
	       errors.push("Component paid to mismatch.");
	    }

	  if(response !=''){
		errors.push("Please enter Ext Amount for follwing items "+response);
	    }

        if (errors.length) {
		new Noty({ layout:"center", type:"error", text: noty_message(errors.join("<br>")) }).show();
        }else{
		if (BBNotes === ''){
			var notes = new Noty({ layout:"center", type:"info", text: 'Notes filed is empty, do you want to continue?'
			,buttons: [
			Noty.button('Yes', 'button recommended ', function () {
			$('#BBCreateProcess').val('1');
			createBB();
			notes.close();
			}),
			Noty.button('No', 'button recommended', function () { notes.close(); })
			]
			});
			notes.show();
		}else{
			$('#BBCreateProcess').val('1');
			$('#ddSearch').val('0');
			createBB();
		}
	}

  };
//FUNCTION TO INVOKE BB CREATION PROCESS
  function createBB(){
			$('#BBAllocate').attr('disabled', true);
			$('#CreateBB').attr('disabled', true);
			$('#addProducts').attr('disabled', true);
			new Noty({ layout:"center", type:"info", text:  "Processing....."}).show();
  		$.ajax( {
					type: "POST",
					url: "ajax/OPB_Program_Details.cfm",
					data: ({
								 BB_Ref : $( "#BB_Ref" ).val()
								,BB_Date : $( "#BB_Date" ).val()
								,Payee_Type : $( "#Payee_Type" ).val()
								,Closing_Method : $( "#Closing_Method" ).val()
								,Vendor : $( "#vendor" ).val()
								,Vendor_Master_ID : $( "#Vendor_Master_ID" ).val()
								,Del_Start : $( "#Del_Start" ).val()
								,Del_End : $( "#Del_End" ).val()
								,BBNotes : $( "#BB_Creator_Notes" ).val()
								,Claimed_Amt : $( "#Claimed_Amt" ).val()
								,Claimed_Qty : $( "#Claimed_Qty" ).val()
								,Variance : $( "#Variance" ).val()
								,Allocated :	$( "#Allocated" ).val()
								,Deduction_ID : $("#DeductionID").val()
								,BBCreate : $( "#BBCreateProcess" ).val()
								,Doc_ID : $("#Doc_ID").val()
						}),
					dataType: 'JSON',
					success: function(response){
						ProgramGridOptions.api.forEachNode(function(node){
							ProgramGridOptions.api.undoCellEditing();
						})
							var BB = response.ROWS.toString();
							if( response.ROWS.length == 1){
								var msg = BB+" is created successfully."
							}else if( response.ROWS.length <= 5){
								var msg = "Below Billbacks are created successfully.<br>"  +BB
							}else{
								var msg =  response.ROWS.length+ " Billbacks are created successfully.<br>"  +BB
							}

							$('#BBCreate').trigger("reset");
							$('#VendorInfo').empty();
							$('#Vendor_Master_ID').val();

							new Noty({ layout:"center", type:"success", text:  msg}).show();
							$( "#bb_customer_search" ).val( $( "#customer_search" ).val( ) );
						/*$( "#bb_program_search" ).val( $( "#program_search" ).val( ) );
						$( "#bb_item_search" ).val( $( "#item_search" ).val( ) );
						$( "#bb_item_group_search" ).val( $( "#item_group_search" ).val( ) );*/
							$('#BBAllocate').removeAttr("disabled");
							$('#CreateBB').removeAttr("disabled");
							$('#addProducts').removeAttr("disabled");

					},
					error: function(xhr, textStatus, errorThrown){
						new Noty({ layout:"center", type:"error", text: "Process Failed" }).show();

						$('#BBAllocate').removeAttr("disabled");
						$('#CreateBB').removeAttr("disabled");
						$('#addProducts').removeAttr("disabled");
					}
				});
  }
//FUNCTION TO ADD ITEMS TO GRID
function addItems(){
$.ajax( {
				type: "POST",
				url: "/mvc/models/OnePageBillback/OPBManager.cfc?method=getNewItems&ReturnFormat=JSON",
				dataType: 'JSON',
				success: function(response){
					ProgramGridOptions.api.updateRowData({add: response.DATA, addIndex: 0});
					ProgramGridOptions.api.refreshCells();
				},
				error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
			});
  }

		// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
		document.addEventListener("DOMContentLoaded", function () {
				Build_ProgramsGrid();
		});

		function openPRG(contract_main_id){
			let win_name = 'winSummary_' + contract_main_id;
			NewWindowTopLeft("/CID_Wrapper.cfm?Program_ID="+contract_main_id+"&Page_Relocate=/common_files/contracts/contract_edit_menu.cfm",win_name,"1345","710","yes","yes");
		}
 </script>