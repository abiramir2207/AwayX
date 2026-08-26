<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 14-Dec-2018
  *  New Alias Management, configuring Grid
  *     Included as Template into AliasMain.cfm
  *     Ported from AliasGridManager.as
  *
  *
  * ====================================================================================================
--->
<cfinclude template="alias_columns.cfm">
<script>
        
    // Global option settings - one grid defined at a time
    var GridOptions = {};
	var selectedRows = {};
	var selectedRecordID = 0;
	var selectedRecordZip = "";
	/* We need to use this variable to make sure that when all the records are selected, the "onRowSelected" event does not call the related code for all the records, else the
	checking/unchecking the records becomes very slow.
	*/
	var allRecordsChecked = 0;

<!--- AG-GRID HEADER COMPONENT --->
	// header component class
	function CheckboxHeaderComponent() {}

	// init method for the checkbox header component, used to add select all functionality
	CheckboxHeaderComponent.prototype.init = function(params) {
		this.eGui = document.createElement('div');
		this.eGui.setAttribute('id', 'selectAllRecords');
		var domString = '<input type="checkbox" onclick="onCheckboxHeaderClick()" id="checkall" class="ag-hidden"><label for="checkall" style="position:relative; top:3px;"><span id="cb-checked" class="ag-icon ag-icon-checkbox-checked ag-hidden"></span><span id="cb-unchecked" class="ag-icon ag-icon-checkbox-unchecked"></span></label>';
		this.eGui.innerHTML =  domString;
	};
	CheckboxHeaderComponent.prototype.destroy = function() {};


	function onCheckboxHeaderClick($event) {

		let checkbox = document.getElementById('checkall');
		
		// if now checked, select all
		if (checkbox.checked == true) {
			allRecordsChecked = 1;
			<!--- GridOptions.api.selectAllFiltered(); ---> // Client Row model only
			<!--- GridOptions.api.selectAll(); ---> /* By using this, we also select the unfiltered records and so we cannot use it */
			event.stopPropagation();
			//let action = $(this).text();
			GridOptions.api.forEachNode(function(node){
				node.setSelected( true );
			});
		}
		else {
			<!--- GridOptions.api.deselectAllFiltered(); ---> // Client Row model only
			<!--- GridOptions.api.deselectAll(); ---> /* By using this, we also deselect the unfiltered records and so we cannot use it */
			GridOptions.api.forEachNode(function(node){
				node.setSelected( false );
			});
		}
		let el1 = document.getElementById('cb-checked');
		let el2 = document.getElementById('cb-unchecked');
		el1.classList.toggle('ag-hidden');
		el2.classList.toggle('ag-hidden');
	};   
		

	CheckboxHeaderComponent.prototype.getGui = function() {
		return this.eGui;
	};
	/*function selectAllRows() {
		GridOptions.api.selectAll();
	}*/
	
	/* Deselects all rows, including the ones which are not filtered. */
	function deSelectAllRows() {
		GridOptions.api.deselectAll();
	}
	
    //------------------------------------------------------------------------------------------------------
    // Define all the Grid columns
    //------------------------------------------------------------------------------------------------------
    let c_selectCol =
    {
            headerName: "", 
            field: "f_sel", 
            checkboxSelection: true,
            suppressMenu:true, 
            pinned:"left", lockPosition:true, suppressSizeToFit:true,
            resizable: false,    // v20 not v19
            filter: false,       // v20 not v19
			width:26,
			headerComponent: CheckboxHeaderComponent	// custom header component define below
    };
	/*newRowsAction:'keep' wil make sure thar the search criteria remains in the search box after the user hits the enter key and the grid refreshes. */
	let c_aliasID =     { headerName:"Alias ID", field: "ALIASID", width: 50,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_aliasDesc =   { headerName:"Alias Desc", field: "ALIASDESC", width: 100,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_aliasAddress= { headerName:"Alias Address", field: "ALIASADDRESS", width: 200, hide:true,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_entityID =    { headerName:"ID", field: "ENTITYID", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_entityDesc =  { headerName:"Desc", field: "ENTITYDESC", width: 120,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_payeeID =     { headerName:"Payee ID", field: "PAYEEID", width: 60, hide:true,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_entityAddress={ headerName:"Address", field: "ENTITYADDRESS", width: 110, hide: true,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
	let c_holdInvoiceCount =   { headerName:"Hold Invoice Count", field: "HOLDINVOICECOUNT", width: 50, hide: true, filter:false};
	/* This column has been added so that "rowNode.setDataValue" can work, i.e. when a user changes the "ignore" flag, 
	the change is recognized at the grid row level */
	let c_unknown =   { headerName:"", field: "UNKNOWN",hide: true};


// after a grid loads, update the text which shows the row count
function updateCount(countID, rowCount) {
   $(countID).text("("+rowCount +")");
}
function clearCount(countID) {
	$(countID).text(" ");
}


</script>

<!--- Include the code needed for each Grid type (Distributor, Item, Program, Operator) and also the special Unipro grid --->
<cfinclude template="/settings/Alias_Management/AliasGridDistributor.cfm">
<cfinclude template="/settings/Alias_Management/AliasGridItem.cfm">
<cfinclude template="/settings/Alias_Management/AliasGridProgram.cfm">
<cfinclude template="/settings/Alias_Management/AliasGridOperator.cfm">
<cfinclude template="/settings/Alias_Management/AliasGridUnipro.cfm">

<script>
    // create new grid
    function createGrid(tabIndex, aliasSourceType) {
        if(aliasSourceType == UNIPRO_SOURCE_TYPE){
            //  Unipro is so different that we handle it completely separately
            UniproBuildGridColsByID(0);
        }
        else{
            // All other source types have a lot in common, with some variations
            switch (tabIndex) {
                case 0:     /* distributor */
                    GridOptions = buildGrid_Distributor(aliasSourceType, GridOptions, tabIndex);
                    break;
                case 1:     /* item */
                    GridOptions = buildGrid_Item(aliasSourceType, GridOptions, tabIndex);
                    break;                
                case 2:     /* program */
                    GridOptions = buildGrid_Program(aliasSourceType, GridOptions, tabIndex);
                    break;                
                case 3:     /* operator */
                    GridOptions = buildGrid_Operator(aliasSourceType, GridOptions, tabIndex);
                    break;
            }
        }
    }




	// Common code to build any of the Alias grid types and then update the count
	function buildGridCols(gridOptions, cols, pageID, countID, tabIndex) {
		gridOptions = {
			floatingFilter: true
			,columnDefs: cols			
			//,enableFilter: false      // v19 not v20
			//,enableSorting: true     // v19 not v20
			,rowSelection: 'multiple'
			/* For some reason, when the user selects a row by clicking on it, the correct row's information did not always populate the assocaited textboxes - aliasID, aliasDesc etc.
			It worked correctly, when a user clicked on the checkbox for a row. That is why ",suppressRowClickSelection" is set to false.
			*/
			,suppressRowClickSelection:true
			,onRowSelected: onRowSelected
			,cacheBlockSize: 2500
			,debug: false
			,rowModelType: "serverSide"
			,getRowNodeId: function(data) { return data.RECORDID;}
			,onGridReady: function (params) {
				
				<!---  removed because it causes lots of warnings, as if called before grid is visible
				window.addEventListener('resize', function() {
					setTimeout(function() {
						params.api.sizeColumnsToFit();
					})
				});
				--->
				
			}
		};
		ag_grid_default (gridOptions);   // set up default features

		AjaxDatasource.prototype.getRows = function(params) {

			 switch (tabIndex) {
				case 0:     /* distributor */
					loadData_Distributor(countID,params,strSourceType,strSourceID,tabIndex);
					break;
				case 1:     /* item */
					loadData_Item(countID,params,strSourceType,strSourceID,tabIndex);
					break;                
				case 2:     /* program */
					loadData_Program(countID,params,strSourceType,strSourceID,tabIndex);
					break;                
				case 3:     /* operator */
					loadData_Operator(countID,params,strSourceType,strSourceID,tabIndex);
					break;
			}
			
		};


		init_ag_grid (gridOptions, pageID, true);
		return(gridOptions);
	}
            
    function sizeActiveGrid() {
            // size the active grid
            if (!$.isEmptyObject(GridOptions)) // check if grid created
            {
				GridOptions.api.sizeColumnsToFit();
				set_grid_full_height("myAliasGrid");

            }
        }

    // destroy grid
    function destroyGrid(){
        if (! $.isEmptyObject(GridOptions)) {
            if (GridOptions.api)
                GridOptions.api.destroy();
        }
    }

	function refreshGrid(){
		GridOptions.api.onFilterChanged();
		/*If a user filters the recordset and selects the filtered records and then removes the filter, we should reset allRecordsChecked to 0. */
		allRecordsChecked = 0;
	}

	/* For a single row only */
	function onRowSelected(event) {
		selectedRecordZip = "";
		if(allRecordsChecked == 0 && event.node.isSelected() == true){

			let selected_row = event.node.data;

			$('#alias_id').val(selected_row.ALIASID)
			$('#alias_desc').val(selected_row.ALIASDESC)
			$('#entity_id').val(selected_row.ENTITYID)
			$('#payee_id').val(selected_row.PAYEEID)
			$('#ignore_flag').prop('checked', selected_row.UNKNOWN)
			$('#unipro_num').val(selected_row.ALIASUNIPRONUM)
			$('#loc_id').val(selected_row.ALIASLOC)
			$('#e_entityDesc').html('<span style="font-weight:bold">'+selected_row.ENTITYDESC+'</span>')
			/*Actually "SOURCEID" property does not even exist. Adding it here, so that the code
			works fine with the existing alias code on AliasManager.cfc, where "AliasDef" object is used. for flex. */
			selected_row.SOURCEID = strSourceID;
			selected_row.SOURCETYPE = strSourceType;

			selectedRecordID = selected_row.RECORDID;
			selectedRecordZip = selected_row.ALIASZIP;
		}
		else{
			/* If the row is "unchecked" ;*/
			if(event.node.isSelected() == false) {
				clearEditSubSection();
				allRecordsChecked = 0;
			}
		}
	}
	
	/* UPDATE GRID DATA */
	function updateAliasData(element_id,updatedData) {

		let rowNode = GridOptions.api.getRowNode(selectedRecordID);

			if(rowNode != null){

				/* When "element_id* is defined, then we use the "pasted" data from the clipboard to update the specific row
				data,else we use the specific element's value.
				*/
				if(element_id == 'alias_id'){
					rowNode.setDataValue('ALIASID', updatedData);
				}

				if(element_id == 'alias_desc'){
					rowNode.setDataValue('ALIASDESC', updatedData);
				}

				if(element_id == 'entity_id'){
					rowNode.setDataValue('ENTITYID', updatedData);
				}

				if(element_id == 'payee_id'){
					rowNode.setDataValue('PAYEEID', updatedData);
				}

				if(element_id == 'unipro_num'){
					rowNode.setDataValue('ALIASUNIPRONUM', updatedData);
				}

				if(element_id == 'loc_id'){
					rowNode.setDataValue('ALIASLOC', updatedData);
				}
				
				/* "entity description" data cannot be pasted and is also not editable and so we do not need separate logic for "pasting"  */
				rowNode.setDataValue('ENTITYDESC', $('#e_entityDesc').text());		
				/* If the description does not exist, then set address to blank */
				if($('#e_entityDesc').text() == ''){
					rowNode.setDataValue('ENTITYADDRESS', '');
				}

				if(element_id == 'ignore_flag'){
					/* "ignore_flag" (ignore checbox) logic cannot be used for "pasting" as it is a checkbox, and so we do not need separate logic for "pasting"  */
					rowNode.setDataValue('UNKNOWN', $('#ignore_flag').is(':checked'));
				}
			}
	}

	function updateAliasDataMassApply(element_id,updatedData) {
		selectedRows = GridOptions.api.getSelectedRows();

		selectedRows.forEach( function(selectedRow, index) {
			let rowNode = GridOptions.api.getRowNode(selectedRow.RECORDID);

			/* Update the data for the row */
			rowNode.setDataValue(element_id,updatedData);

			if(element_id == 'ENTITYID'){
				/* "entity description" data cannot be pasted and is also not editable and so we do not need separate logic for "pasting"  */
				rowNode.setDataValue('ENTITYDESC', $('#e_entityDesc').text());		
				/* If the description does not exist, then set address to blank */
				if($('#e_entityDesc').text() == ''){
					rowNode.setDataValue('ENTITYADDRESS', '');
				}
			}

			/* Check or Uncheck the checkbox the "Ignore" checkbox */
			if(element_id == 'UNKNOWN'){
				$('#ignore_flag').prop('checked', updatedData)
			}

		});
	}
</script>