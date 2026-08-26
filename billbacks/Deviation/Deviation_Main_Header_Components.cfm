<cfsilent>
    <!---
    * ==================================================================================================== 
    *    @File: billbacks\Deviation\Deviation_Main_Header_Components.cfm
    *  @Author: Sharon Harris
    *    @Date: 17-May-2019
    * 
    * @Remarks: Billback Deviation Main - Header components for the ag-Grid
    *			See https://www.ag-grid.com/javascript-grid-header-rendering/
    *           
    * ==================================================================================================== 
    --->
</cfsilent>
<style>

/* Special small buttons to use in header */
button.button-small {
	background-color: #edeef2;
	border-radius:3px;
	border: 1px solid #7c7c7c;
	box-sizing: border-box;
	box-shadow: 0px 2px 2px -1px rgba(86, 87, 96, 0.3);
	color: #343540;
	font-size: 11px;
	font-weight: 500;
	height: 16px;
	/* margin: 0 1px 0 -2px; */
	margin: 0px auto 0px auto;		/* Center the button in the cell */
	padding: 0px 2px 0 2px;
	white-space: nowrap;
	}
		button.button-small:hover { 
			color: #406be4;
			background-color: #fff;
		}
		button.button-small:focus {
			outline: 0;
		}

</style>
<script>
	function selectAllRadio(params,sCaller,sOptionalVal) {
		fnRecalculate(params,sCaller,sOptionalVal);
	}

	// --------------------------------------------
	// Define the Radio Button Header Component
	// 
	function RadioButtonHeader() {
	}
	RadioButtonHeader.prototype.init = function (agParams) {
		this.agParams = agParams;
		this.eGui = document.createElement('div');
		let name="radioHeader-"+this.agParams.action;

		this.eGui.innerHTML = '' +
		'<button type="button" class="button-small " name='+name+' title="Click to select all" onClick="selectAllRadio(\'\',\''+this.agParams.action+'\',0)">' + this.agParams.displayName +'</button>';
		};

	
	RadioButtonHeader.prototype.getGui = function () {
		return this.eGui;
	};
	
	RadioButtonHeader.prototype.onMenuClick = function () {
	};
	
	
	RadioButtonHeader.prototype.destroy = function () {

	};


	// --------------------------------------------
	// Define the Checkbox Header Component
	// 
	function CheckboxHeaderComponent() {}

	// init method for the checkbox header component, used to select all checkboxes in the cells below (not the typical select all rows)
	CheckboxHeaderComponent.prototype.init = function(params) {
		
		this.eGui = document.createElement('div');
		// var domString = '<input type="checkbox" onclick="onCheckboxHeaderClick()" id="checkall" class="ag-hidden"><label for="checkall" class="ba-select-all-checkbox"><span id="cb-checked" class="ag-icon ag-icon-checkbox-checked ag-hidden"></span><span id="cb-unchecked" class="ag-icon ag-icon-checkbox-unchecked"></span></label>';
		let value = isAllChecked() == false ? '' : ' checked';

		var domString = 
			'<div class="ag-cell-label-container ag-header-cell-sorted-none" role="presentation">'+    
				'<div ref="eLabel" class="ag-header-cell-label" role="presentation" unselectable="on"> '+  
					'<span ref="eText" class="ag-header-cell-text cursor-auto" role="columnheader" unselectable="on">'+  
						params.displayName + 
						'<input type="checkbox" onclick="onCheckboxHeaderClick()" id="checkall"' +value+ '>'+
					'</span>'+
				'</div></div>';

		this.eGui.innerHTML =  domString;
	};

	function onCheckboxHeaderClick($event) {
		let checkbox = document.getElementById('checkall');
		// if now checked, check all checkboxes below it
		if (checkbox.checked == true) {
			Deviations_GridOptions.api.forEachNode( function(rowNode, index) {
				if (isEditableCheckbox(rowNode)	) {			// Allow to change if not disabled
					rowNode.data.COUNT_FLAG = true;
				}
			});
		}
		else {
			Deviations_GridOptions.api.forEachNode( function(rowNode, index) {
				if (isEditableCheckbox(rowNode)	) {			// Allow to change if not disabled
					rowNode.data.COUNT_FLAG = false;
				}
			});
		}
		Deviations_GridOptions.api.refreshCells();
	};   
		

	CheckboxHeaderComponent.prototype.getGui = function() {
		return this.eGui;
	};

	// Return true if all the "count" checkbox cells are checked, false otherwise
	function isAllChecked() {
		let ret = true;
		Deviations_GridOptions.api.forEachNode( function(rowNode, index) {
			if (rowNode.data.COUNT_FLAG == false) {
				ret = false;	// BREAK NOT ALLOWED!! would like to get out at first one found
			}
		});
		return ret;
	}

	// Make sure the header checkbox reflects the state below.  Parameter "on" should be true for checked and false for off
	function synchHeaderCheckbox(on) {
		let state = on ? ' checked' : '';
		let checkbox = document.getElementById('checkall');
		checkbox.checked = state;
	}




	// --------------------------------------------
	// Define the Group Header Component
	// Used to show the i icon in the group header
	// 
	function InfoHeaderGroup() {
	}

// Append the "information" icon and show the title as the tooltip
	InfoHeaderGroup.prototype.init = function (params) {
		this.params = params;
		this.eGui = document.createElement('div');
		this.eGui.className = 'ag-header-group-cell-label';
		this.eGui.innerHTML = '' +
			'<div class="ag-header-group-text" ref="agLabel">' + this.params.displayName +
				'<i class="fa fa-info-circle btn-icon pl-1 pt-1" style="font-size:12px"' +
				'title="' + this.params.title + '"' +
			'</div>';	
	};

	InfoHeaderGroup.prototype.getGui = function () {
		return this.eGui;
	};
	InfoHeaderGroup.prototype.destroy = function () {
	};

</script>