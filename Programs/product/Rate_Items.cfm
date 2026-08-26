<cfsilent>
<!---
* ==================================================================================================== 
*    @File: Programs\product\Rate_Items.cfm
*  @Author: Sharon Harris
*    @Date: Jan-2020
* 
* @Remarks: Display Contents of the popup window with Invalid Item IDs
*           
* ==================================================================================================== 
--->
</cfsilent>
<!doctype html>
<html lang="en">
<head>
	<title>Invalid Items</title>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
</head>
<body>

	<cfset request.ag_grid_theme = "ba-ag-theme-balham">
	<cf_include files=#arrayToList( [	
						"/common_Files/ag-Grid.cfm"
						])#>

	<!--- UI to display inside the popup --->

	<!--- Show/edit list of INVALID IDs --->
	<h2 style="margin: 15px 0 0; text-align:center;">Invalid Item IDs (<span id="invalidCount"></span>)</h2>
	<div id="Invalid_Item_Grid" style="height:200px; width:405px; margin:5px 0" class="ag-theme-balham"></div>



<script>
	// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
	document.addEventListener("DOMContentLoaded", function () {
		// Get the array of objects (invalid items) that was passed in url
		var arrItem = JSON.parse(sessionStorage.getItem("invalidItems"));
		// Display the count
		document.getElementById('invalidCount').innerHTML = arrItem.length;
		// Build the grid
		Build_Invalid_Grid(arrItem);
	});


	// --------------------------------
	// Invalid Grid data and functions:
	// --------------------------------

	var Invalid_GridOptions = {};	// Global so can access API later
	var columnDefs_InvalidGrid = [
		{headerName: "Item", field: 'itemNumber', width:120},
		{headerName: "Description", field: 'description', width:220},
		{headerName: "Rate", field: 'rate', type:'numericColumn', width:60}
		// ,{headerName: "Error", field: 'sError', width:100},
	]
	<!---
	var rowData_Invalid = [	// TEST data
		{itemNumber:"Test1", description: "Description 1", rate:"1.2"},
		{itemNumber:"Test2", description: "Description 2", rate:"2.9"},
		{itemNumber:"Test3", description: "Description 3", rate:"3.0"},
	]
	--->

	function Build_Invalid_Grid(arrItem) {
		Invalid_GridOptions = {
			columnDefs: columnDefs_InvalidGrid
			,floatingFilter: false
			// ,rowData: rowData_Invalid
			,rowData: arrItem
			,rowModelType: "clientSide"
			,rowSelection: "multiple"
			,suppressContextMenu: true
			,enableBrowserTooltips: true
			// ,getRowNodeId: function(data) { return data.itemGuid }
			,defaultColDef:	{
					editable:                      false
					,singleClickEdit:				false
					,suppressMenu:                  true
					,suppressMovable:               false
					,unSortIcon:                    false
					,sortable:                      true
					,resizable:                     true
					,suppressToolPanel:				true	// Default to no show/hide col, override per column
					,filter:                        'agTextColumnFilter'
			}
		};
		ag_grid_default(Invalid_GridOptions);		// set up default features
		init_ag_grid( Invalid_GridOptions, "#Invalid_Item_Grid", false );   // false=setup as client side
	}
</script>

</body>
</html>