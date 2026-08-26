
<!---
  * ==================================================================================================== 
  *    @File: /settings/ADL/adl_detail_grid.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2021
  * 
  * @Remarks: Edit or View the Authorized Distribution List Details
  *				Included by both the detail viewer and the Editor
  *
  * ==================================================================================================== 
--->

	<!--- Update the ag-grid styles --->
    <style>
        .ag-header-cell-label .ag-header-cell-text {
            white-space: pre;
        }        
        .ag-header-cell-label {
            justify-content: center;
        }
		/* Make the grid resize lines bigger */
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

		.rightA { text-align: right; }
    </style>
	    <cf_include files="/script/javascript/dayjs/1.8/dayjs.min.js, /common_files/dhx_message.cfm">


    <script>
        'use strict';
        const PERCENTAGE_FORMAT = '(0.0)';

		var rowData = <cfoutput>#serializeJSON( qADLDetail )#</cfoutput>;
		var gbEditable = false;

		function create_detail_grid (grid_id, bEditable) {
			gbEditable = bEditable;	//isExternalFilterPresent needs a global param

			let my_grid = {
				defaultColDef: {     
					editable:        false
					,suppressMenu:    true
					,suppressMovable: true
					,unSortIcon:      false
					,sortable:        true
					,resizable:       true
				},
				onCellValueChanged(event) {
					// if(event.oldValue != event.newValue){
			        	updateADLValues(event);
			        // }
			  	}
				,columnDefs: [
					{hide: !bEditable, width:24, checkboxSelection:true, headerCheckboxSelection:true, resizable:false, sortable:false, pinned:"left", lockPosition:true},
					{hide: !bEditable, width:40, sortable:false,
						headerComponentParams: {
							// This is the (Delete row(s)) column
							template: customize_column_header(
							'<div><a id="colDelSel" href="javascript:deleteSelectedRows();">' +
								'<img alt="delete rows" title="delete selected rows" src="/Images/delete2.png" style="padding-bottom:3px; padding-top:2px;">'+
							'</a></div>') },
						cellRenderer: function(params) {
							let delCel =
								'<div style="margin-left:10px; margin-top:3px;">' +
									'<img alt="delete row" title="delete this row" src="/Images/delete2.png">'+
								'</div>';
							return delCel;
						},
						onCellClicked: function(params) { deleteRow(params); }
					}
					,{ headerName:"Row_ID", field:"ROW_ID", hide: true }
					,{ headerName:"Product_ID", field:"PRODUCT_ID", hide: true }
					,{ headerName:"Like_Product_ID", field:"LIKE_PRODUCT_ID", hide: true }
					,{ headerName:"Active", field:"ACTIVE", hide: true }
					,{ headerName:"Item", field:"ITEM", width:70, editable: bEditable }
					,{ headerName:"Description", field:"DESCRIPTION", width:200 }
					,{ headerName:"Include / Exclude", field:"INC_EXC", width: 140
						,cellClass: 'booleanType'
						,cellRenderer: function(p){
							let included = p.data.INC_EXC ?'checked ':' ';
							let excluded = p.data.INC_EXC ?' ':'checked ';
							let disabledRadio =  bEditable == false ? "disabled=disabled" : "";
							let val = '<input type="radio" value=1 name="include-row-'+p.node.id+'" ' +included+ disabledRadio+ ' >'+ ' Include ' +
									'  <input type="radio" value=0 name="include-row-'+p.node.id+'" ' +excluded+ disabledRadio+ ' >'+ ' Exclude';
							return val;
						}
						,onCellClicked: function(p) {
							if(bEditable) {
								if (p.event.target.value != p.data.INC_EXC) {
									// console.log("Value changed to "+p.event.target.value);
									p.data.INC_EXC = p.event.target.value;
									p.event.newValue = p.event.target.value;
									p.node.setDataValue("INC_EXC", p.event.target.value);
									return true;
								}
							}
							return false;
						}
					 }
					,{ headerName:"Start Date", field:"START_DATE", width:90, editable: bEditable, cellEditor: DateEditor
						,tooltipValueGetter: function (params) { return "Start Date should be today or after today" }
						,cellEditorParams: {field:"START_DATE"}
						,cellClass: function () { return bEditable ?  ['editable', 'rightA', 'mmddyy']  : ['rightA', 'mmddyy']; }
						,valueFormatter: function (p) { return format_date(p.data.START_DATE); }
					}
					,{ headerName:"End Date", field:"END_DATE", width:90, editable: bEditable, cellEditor: DateEditor
						,tooltipValueGetter: function (params) { return "End Date should be the same or after the Start Date"}
						,cellEditorParams: {field:"END_DATE"}
						,cellClass: function () { return bEditable ?  ['editable', 'rightA', 'mmddyy']  : ['rightA', 'mmddyy']; }
						,valueFormatter: function (p) { return format_date(p.data.END_DATE); }
					 }
					,{ headerName:"Like Item #", field:"LIKE_ITEM", width:100
						,cellClass: function () { return 'rightA'; }
						,cellRenderer: function(p){
							let val = p.data.LIKE_ITEM;
							if (bEditable) {
								// val = p.data.LIKE_ITEM + '  <button class="button">Choose</button>';
								val = p.data.LIKE_ITEM + '  <a href="#" name="like-row-'+p.node.id+'" title="Optionally choose an Item to model the amount" class="">[Choose]</a>';
							}
							return val;
						}
						,onCellClicked: function(p) { if (bEditable) pickLikeItem(p); }
					 }
					,{ headerName:"Like Item Desc", field:"LIKE_ITEM_DESC", width:140 }
					,{ headerName:"%", field:"LIKE_PRODUCT_PERCENT", width:60, editable: bEditable 
						,cellClass: function () {
							return bEditable ?  ['editable', 'rightA', 'perc']  : ['rightA', 'perc'];
						}
						,valueFormatter:function(p){ return  (p.data.LIKE_PRODUCT_PERCENT == "" ? "" : percentFormat(p.data.LIKE_PRODUCT_PERCENT, PERCENTAGE_FORMAT)) } 
					}
				]
				,rowData: rowData
				,enableRangeSelection:  false
				,floatingFilter:  		false
				,pagination:            false
				,rowModelType:          "clientSide"
				,rowSelection:          "multiple"
				,suppressContextMenu:       true
				,suppressRowClickSelection: true
				// ,blackSmith: 			{ fullHeight: true, height_offset: -50 }
				,domLayout:					'autoHeight'
				,isExternalFilterPresent: isExternalFilterPresent
				,doesExternalFilterPass: doesExternalFilterPass
				,excelStyles: [
					{ id: 'stringType', dataType:"string" }
					// ,{ id: 'mmddyy', dataType: "dateTime", numberFormat: {format: 'MM/DD/YY'} }
					,{ id: 'header', font:{bold:true, color:"#FFFFFF"}, interior:{color: '#000000', pattern: 'Solid'} }
					,{ id: 'booleanType', dataType: 'boolean' }
					,{ id: "perc", numberFormat: {format: '##,##0.0%;[Red](##,##0.0)%'} }
				]
			};


			ag_grid_default( my_grid );
			init_ag_grid (my_grid, grid_id);			
			return (my_grid);
		}


		// if not editing (if just viewing details), then we are filtering
		function isExternalFilterPresent() {
			// console.log("Is Filter: "+(bEditable == false));
			if (gbEditable == false) 
				return true;
			else 
				return false;
		}
		// if not editing (if viewing details), hide the inactive rows by filtering based on the "include" bit
		function doesExternalFilterPass(node) {
			// console.log("filter: "+node.data.ACTIVE);
			return (node.data.ACTIVE);
		}

		// change date to a simple format MM/DD/YYYY
		function format_date( mm_dd_yyyy ) {
			return mm_dd_yyyy
                    ? dayjs( mm_dd_yyyy.toString(), "YYYYMMDD" ).format("MM/DD/YYYY")
                    : '';
        }
		
		// change date to a format needed for html input date YYYY-MM-DD
		function format_date_for_input( yyyy_mm_dd ) {
			return yyyy_mm_dd
                    ? dayjs( yyyy_mm_dd.toString(), "YYYYMMDD" ).format("YYYY-MM-DD")
                    : '';
        }

		// Delete the current row
		function deleteRow(params) {
			let popup = dhtmlx.modalbox( {
				text: "Delete row?",
				title: "Confirm Delete",
				buttons: ["Yes", "No"],
				callback: function(res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						let arrRow = [];
						arrRow.push(params.node.data);
						deleteADLDetail(params.node.data);

						res = glob.my_grid.api.applyTransaction({ remove: arrRow });
					}
				}
			});
		}

		// Delete all the selected rows
		function deleteSelectedRows() {
			let popup = dhtmlx.modalbox( {
				text: "Do you want to delete the selected rows?",
				title: "Confirm Delete",
				buttons: ["Yes", "No"],
				callback: function(res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						let selectedData = glob.my_grid.api.getSelectedRows();
						selectedData.forEach( element => {
							deleteADLDetail(element);
						});
						res = glob.my_grid.api.applyTransaction({ remove: selectedData });
					}
				}
			});
		}


		function deleteADLDetail(data){
			$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	headerId: <cfoutput>#url.id#</cfoutput>,
									rowId: data.ROW_ID,
									method:  "deleteADLDetail" }  //rate or uom update
						,success: function (data) {
							changeLastUpdatedInfo(data);
						}
						,error: function (data) {
							alert('An error occurred (deleteADLDetail).  ' + JSON.stringify(data) );
						}
						,type: "post"
						,url: "/mvc/Models/Settings/ADLManager.cfc"
			});
		}

		function pickLikeItem(p) {
			$("input[name=rowId]").val(p.data.ROW_ID);
			//set ExistingProductList = current like item, so that product search tool can show that record as selected by default
			$("input[name=ExistingProductList]").val(p.data.LIKE_PRODUCT_ID);
			$("input[name=action]").val("likeProd");
			NewWindow("/Common_Files/contracts/product_Select_V1.cfm?Formname=adl_edit&SelectSingleSearchResultOnly=1", 
							 "productwindow_old", 
							 1000, 700, "yes", "yes");
		}


		
		function updateADLValues(e){
			let columns = ["INC_EXC", "START_DATE", "END_DATE", "LIKE_PRODUCT_PERCENT"];
			if($.inArray(e.colDef.field, columns) >= 0){// Only for limited list of fields
				$.ajax({
							async: true
							,dataType: 'json'
							,data: { 	headerId: <cfoutput>#url.id#</cfoutput>,
										rowId: e.data.ROW_ID,
										inc_exc:e.data.INC_EXC,
										start_date:e.data.START_DATE,
										end_date:e.data.END_DATE,
										like_product_percent:e.data.LIKE_PRODUCT_PERCENT,
										method:  "updateADLValues" }  //rate or uom update
							,success: function (data) {
								changeLastUpdatedInfo(data);
				            }
				            ,error: function (data) {
				            	alert('An error occurred (updateADLValues).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Settings/ADLManager.cfc"
				});
			}
		}
		
		function changeLastUpdatedInfo(data) {
			$( ".last_changed_d" ).text(data.LASTUPDATEDDATE);
			$( ".last_changed_t" ).text(data.LASTUPDATEDTIME);
			$( ".last_changed_by" ).text(data.LASTUPDATEDBY);
		}

		function getToday() {
			let today = new Date();
			let dd = String(today.getDate()).padStart(2, '0');
			let mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
			let yyyy = today.getFullYear();

			today = yyyy + '-' + mm + '-' + dd;
			// console.log("Today is: "+today);
			return today;
		}

		function noty_warning (sMsg) {
			noty({
				text: sMsg,
				layout: "center", type: "warning", timeout: 3000, killer: true,
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
		}


		// Date Picker component for ag-grid cell
		// ----------------------------------------------------
		function DateEditor() {}

		// gets called once before the renderer is used
		DateEditor.prototype.init = function (params) {
			// create the cell
			this.eInput = document.createElement('input');

			// <input type="date"
    		//    value="2018-07-22"
    		//    min="2018-01-01" max="2018-12-31">
			// Use html date instead of jquery due to click edit issue
			this.eInput.type = "date";
			this.eInput.min = getToday();

			if (params.value =="") { this.eInput.value = params.value; }
			else { this.eInput.value = format_date_for_input (params.value); }
			
			this.field = params.field;
			this.api = params.api;
			this.rowIndex = params.rowIndex;
			this.eInput.classList.add('ag-input');
			this.eInput.style.height = '100%';
		};

		// gets called once when grid ready to insert the element
		DateEditor.prototype.getGui = function () {
			return this.eInput;
		};

		// focus and select can be done after the gui is attached
		DateEditor.prototype.afterGuiAttached = function () {
			this.eInput.focus();
			this.eInput.select();
		};

		// returns the new value after editing
		DateEditor.prototype.getValue = function () {
			var curr_row = this.api.getRowNode(this.rowIndex);

			if (this.field == "END_DATE") {
				// Compare dates, make sure end is not before the start
				let sd = dayjs (curr_row.data.START_DATE);
				let ed = dayjs (this.eInput.value);
				if ( ed.isBefore(sd) ) {
					// console.log("User Error: New End date is before start date: "+ed.isBefore(sd));
					this.eInput.value = curr_row.data.END_DATE;	// ignore the bad date
					noty_warning ("The End Date cannot be before the Start Date.")
				}
			}
			// when using html date, can check for validity (within min max setting)
			if ( ! this.eInput.checkValidity() )  {
				// console.log("INvalid: "+this.eInput.value);

				// if the new date is html invalid (before today min), then just restore the old date
				this.eInput.value = (this.field == "END_DATE") ? format_date_for_input (curr_row.data.END_DATE) : format_date_for_input (curr_row.data.START_DATE);
				noty_warning ("New Start and End Dates must be today or after today.")

			}
			return this.eInput.value;
		};

		// any cleanup we need to be done here
		DateEditor.prototype.destroy = function () {
			// but this example is simple, no cleanup, we could
			// even leave this method out as it's optional
		};

		// if true, then this editor will appear in a popup
		DateEditor.prototype.isPopup = function () {
			return true;	// true shows the popup picker, false will not show that option
			// return false;
		};

	</script>

