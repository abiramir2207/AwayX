<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
  Template: /Common_Files/ag-Grid.cfm
  Date:     2017 December
  Author:   Chris Nguyen
  Purpose:  Set up ag-Grid using FORGE enterprise license key and provide default features

  Remark:   After include this file you need to call ag_grid_default() to assign default ag_grid.settings
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
	param name="request.ag_grid_theme"   default="ba-ag-theme-balham";
	param name="request.ag_grid_version" default="20";

	request.ag_grid_theme   = trim(request.ag_grid_theme);
	request.ag_grid_version = trim(request.ag_grid_version);

	source_path = "/script/javascript/ag-grid/"
					& ( 
						(request.ag_grid_version is "20")  or  (request.ag_grid_version is "19") 
							? request.ag_grid_version
							: "18" 
					);
</cfscript>

<cfoutput>
<cf_include files="#source_path#/ag-grid-enterprise.min.nostyle.js">	

<cfif request.ag_grid_theme is "ba-ag-theme-balham">
	<cf_include files="#source_path#/ba/ba-ag-theme-balham.css">    
<cfelse>
	<cf_include files="#source_path#/ag-grid.css, #source_path#/ag-theme-balham.css">
</cfif>
</cfoutput>

<cfsetting enableCFoutputOnly = "no">
<script>
	agGrid.LicenseManager.setLicenseKey( <cfoutput>'#application.util.query.get_setting("ag_grid17_license")#'</cfoutput> );

	// default features for FORGE
	function ag_grid_default() {
		gridOptions.cacheBlockSize = gridOptions.cacheBlockSize || 5000;		// how many rows each block in the cache should contain. Each call to web server will be for one block.
		gridOptions.defaultColDef = {    editable: false
										,filter: "agTextColumnFilter"
										,filterParams: { apply: true }
										,suppressFilter: true
										,suppressMenu: true
										,suppressMovable: false
										,unSortIcon: false
									};
		gridOptions.floatingFilter       = false;
		gridOptions.groupHideOpenParents = false;
		// gridOptions.maxBlocksInCache = gridOptions.maxBlocksInCache || 2;		// maximum blocks to keep in browser cache
		gridOptions.rowDeselection = true;
		// gridOptions.rowSelection = "single";
		gridOptions.suppressContextMenu = true;
		gridOptions.suppressRowClickSelection = true;
		
		<cfif request.ag_grid_version is "20">
			gridOptions.defaultColDef.sortable  = true;
			gridOptions.defaultColDef.filter    = true;
			gridOptions.defaultColDef.resizable = true;
		<cfelse>
			// options for version 19
			gridOptions.enableSorting        = true;
			gridOptions.enableFilter         = true;
			gridOptions.enableColResize      = true;

			<cfif request.ag_grid_version is "18">
				gridOptions.showToolPanel                    = false;
				gridOptions.toolPanelSuppressPivotMode       = true;
				gridOptions.toolPanelSuppressPivots          = true;
				gridOptions.toolPanelSuppressRowGroups       = true;
				gridOptions.toolPanelSuppressValues          = true;
				gridOptions.toolPanelSuppressSideButtons     = true;
				gridOptions.toolPanelSuppressColumnFilter    = true;
				gridOptions.toolPanelSuppressColumnSelectAll = true;
				gridOptions.toolPanelSuppressColumnExpandAll = true;
			</cfif>
		</cfif>

		<cfif request.ag_grid_theme is "ba-ag-theme-balham">
			ag_grid_dense();
		</cfif>
	};

	// some FORGE grids are dense and have shorter row heights
	function ag_grid_dense() {
		gridOptions.headerHeight = 22;    // set to 22 for the dense grid
		gridOptions.rowHeight    = 20;    // set to 20 for the dense grid
	};

	// format numeric values
	function numberCellRenderer(params) {
		if ( params.value ) {
			if (params.value < 0) {
				return '(' + (params.value*-1).toLocaleString() + ')';
			}
			else {
				return params.value.toLocaleString();
			}
		}
	}

	function AjaxDatasource() {};

	function init_ag_grid( gridOptions, grid_id ) {
		grid_id = grid_id.replace(/#/g, '') || "myGrid";		// remove the # characters in the grid_id element
		new agGrid.Grid( document.getElementById(grid_id), gridOptions );

		let datasource = new AjaxDatasource();
		gridOptions.api.setServerSideDatasource(datasource);
	};
</script>