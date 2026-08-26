/**
 *
 *  \script\javascript\ag-grid\ag-grid.js
 *
 *  Custom JavaScript functions utilized on Ag-grid pages
 *
 *  Chris Nguyen
 *  2019 December
 *
 */
const ag_debug = 0;

agGrid.LicenseManager.setLicenseKey( cf_settings.ag_grid_license );

// default features for FORGE
function ag_grid_default(gridOptions) {
    // get the optional hidden setting value for cacheBlockSize - this unique setting should be based on client environment
    let default_cacheBlockSize = cf_settings.ag_grid_cacheBlockSize;
    // optional setting does not exist provide a default
    if (default_cacheBlockSize == 0)
        default_cacheBlockSize = 5000;

    gridOptions.suppressPropertyNamesCheck = true;                  // disable warning message on custom properties
    if (typeof gridOptions.blackSmith == "undefined")
        gridOptions.blackSmith = {};                                // Black Smith custom property structure
    if (typeof gridOptions.blackSmith.fullHeight == "undefined")
        gridOptions.blackSmith.fullHeight = false;                  // set it to true to adjust grid height to extent to the bottom of a page
    if (typeof gridOptions.blackSmith.pleaseWait == "undefined")
        gridOptions.blackSmith.pleaseWaitSpinner = true;            // set it to false to exclude the spinner from "Please wait..." overlay message
    if (typeof gridOptions.blackSmith.height_offset == "undefined")
        gridOptions.blackSmith.height_offset = -8;

    // use either the parameter value passed from parent .cfm file or a default cache block size
    gridOptions.cacheBlockSize = gridOptions.cacheBlockSize || default_cacheBlockSize;		// how many rows each block in the cache should contain. Each call to web server will be for one block.

    // if defaultColDef is defined do not change it otherwise assign default settings for columns
    if (typeof gridOptions.defaultColDef == "undefined")
        gridOptions.defaultColDef = {     editable:        false
                                        , filter:          "agTextColumnFilter"
                                        , filterParams:    { applyButton: true }
                                        , suppressMenu:    true
                                        , suppressMovable: ( cf_settings.script_name.indexOf("program_search.cfm") > -1 ? false : true )
                                        , unSortIcon:      false
                                        , sortable:        true
                                        , resizable:       true
                                    };

    gridOptions.floatingFilter      	= gridOptions.floatingFilter || false;
    gridOptions.groupHideOpenParents	= gridOptions.groupHideOpenParents || false;
    if (gridOptions.rowDeselection === undefined) {
        gridOptions.rowDeselection = true;
    }
    if (gridOptions.suppressContextMenu === undefined) {
        gridOptions.suppressContextMenu = true;
    }
    if (gridOptions.suppressRowClickSelection === undefined) {
        gridOptions.suppressRowClickSelection = true;
    }
    if (parseFloat(cf_settings.ag_grid_version) < 20) {
        if (gridOptions.enableColResize === undefined) {
            gridOptions.enableColResize = true;
        }
        if (gridOptions.enableFilter === undefined) {
            gridOptions.enableFilter = true;
        }
        if (gridOptions.enableSorting === undefined) {
            gridOptions.enableSorting = true;
        }
    }

    // this setting fixes Chrome's ResizeObserver loop exceed limit JS error
    gridOptions.suppressBrowserResizeObserver = true;

    // default message displayed when the grid is loading data
    if (gridOptions.overlayLoadingTemplate === undefined)
        gridOptions.overlayLoadingTemplate = "<span class='ag-overlay-loading-center'>"
                                                + ( gridOptions.blackSmith.pleaseWaitSpinner
                                                        ? "<img src='/images/prettyPhoto/default/loader.gif'> <span style='display:inline-block;position:relative;top:-5px;padding-left:7px;'>"
                                                        : "" )
                                                + "Please wait while we are processing your request...</span>"
                                                + ( gridOptions.blackSmith.pleaseWaitSpinner ? "</span>" : "" )
                                                ;
    // default message displayed when loading has complete but no rows to show
    if (gridOptions.overlayNoRowsTemplate === undefined)
        gridOptions.overlayNoRowsTemplate = "<span style='padding:10px; border:1px solid #444; background:lightgoldenrodyellow'>No data available</span>";

    if (gridOptions.excelStyles === undefined)
        gridOptions.excelStyles = [
                                    { id: 'stringType', dataType:"string" }
                                    ,{ id: 'header', font:{bold:true, color:"#FFFFFF"}, interior:{color: '#000000', pattern: 'Solid'} }
                                ];

    gridOptions.headerHeight = 25;
    gridOptions.rowHeight    = 25;
    gridOptions.floatingFiltersHeight = 25;

    if (cf_settings.ag_grid_theme === "ba-ag-theme-balham" && cf_settings.ag_grid_dense == 1) {
        ag_grid_dense(gridOptions);
    }

    // stop columns getting removed from the grid if they are dragged outside of the grid
    gridOptions.suppressDragLeaveHidesColumns = true;
};

// some FORGE grids are dense and have shorter row heights
function ag_grid_dense(gridOptions) {
    gridOptions.headerHeight          = 22;    // set to 22 for the dense grid
    gridOptions.rowHeight             = 20;    // set to 20 for the dense grid
    gridOptions.floatingFiltersHeight = 22;    // 85971
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

// ===============================================================
// assign column information to all floating filter input elements
// ===============================================================
function set_floating_filter_col_ids() {
    const col_ids             = [];
    const ag_header_container = $("div.ag-header-container div.ag-header-row");
    // find all col-id attributes on 1st header line & save them into an array
    $(ag_header_container[0]).find("div[col-id]").each(function(){
        col_ids.push( $(this).attr("col-id") );
    });

    let i = 0;
    // assign col-id attribute to all floating filter input elements defined on 2nd header line
    $(ag_header_container[1]).find("input.ag-floating-filter-input").each(function(){
        $(this).attr("col-id", col_ids[i]);
        i++;
    });
}

// ===========================================================================
// enable reload automatically grid content when floating filter becomes blank
// ===========================================================================
function on_clear_floating_filter( my_grid, grid_id ) {
    // cancel all existing input events - due to reusage of grid on multiple tabs (e.g. alias management tabs)
    $(grid_id).off("input", "input.ag-floating-filter-input");
    $(grid_id).on("input", "input.ag-floating-filter-input", function(e){
        const input       = $(this);
        const current_val = input.val();

        // current value is not the same as previous value
        if (input.data("lastval") !== current_val) {
            // keep track of previous value
            input.data("lastval", current_val);

            // current floating filter becomes empty (from non-blank)
            if (current_val === '') {
                // col-id attribute is missing from floating filter element - populate it from the div row above
                if ( input[0].hasAttribute("col-id") == false ) {
                    set_floating_filter_col_ids();
                }
                // when column information is available, remove current floating filter and apply other filters
                if ( input[0].hasAttribute("col-id") ) {
                    try {
                        // gather existing filters
                        const existing_filters = my_grid.api.getFilterModel();
                        // remove current floating filter parameter
                        if (existing_filters[ input[0].getAttribute("col-id") ])
                            delete existing_filters[ input[0].getAttribute("col-id") ];
                        // refresh filters
                        my_grid.api.setFilterModel( existing_filters );
                        // apply filters
                        my_grid.api.onFilterChanged();
                    }
                    catch (error) {
                    }
                }
            }   // current_val === ''
        }   // !== current_val
    });
}

// is_server_side: boolean. true for serveSide grid, false for clientSide grid data (default)
function init_ag_grid( grid_options, grid_selector, is_server_side ) {
    grid_selector  = grid_selector || "#myGrid";
    is_server_side = is_server_side || false;

    if (grid_options.blackSmith.fullHeight) {
        // automatically adjust grid height to extent to the bottom of a page
        set_grid_full_height( grid_selector, grid_options.blackSmith.height_offset
                                                ? grid_options.blackSmith.height_offset
                                                : -8 );
        window.onresize = function() {
            set_grid_full_height( grid_selector, grid_options.blackSmith.height_offset
                                                    ? grid_options.blackSmith.height_offset
                                                    : -8 );
        }
    }

    grid_options.enterMovesDownAfterEdit       = true;
    grid_options.singleClickEdit               = true;
    grid_options.stopEditingWhenGridLosesFocus = true;

    new agGrid.Grid(document.querySelector( grid_selector ), grid_options);

    // server vs client grid model
    if (is_server_side) {
        const datasource = new AjaxDatasource();
        grid_options.api.setServerSideDatasource(datasource);
        // enable automatic reloading grid content without using Enter key when floating filter becomes blank (from non-blank)
        on_clear_floating_filter( grid_options, grid_selector );
    }
};

// this function stopped working, removed its content & leave declaration alone due to references in other files
function filterResultsOnFilterRemove(grid_options) {}

function convertToArrayOfObjects(arr,columnList)
{
    let item;
    let result =  [];

    for (let i = 0; i < arr.length; i++)
    {
        item = new Object();
        for (let j = 0; j < arr[i].length; j++)
        {
            item[columnList[j]] = arr[i][j];
        }
        result.push(item);
    }

    return result;
}

// dollar column formatter :: requires numeral js plugin
// parameters: 1) amount = required, numeric  2) fmt = optional, string numeral format
function currencyFormat(amount, fmt) {
    fmt = fmt || '($0,0.00)';
    return ((amount == null) || isNaN(amount))
            ? ''
            : numeral( amount.toString() ).format( fmt );
}

// number formatter :: requires numeral js plugin
// parameters: 1) num = required, numeric  2) fmt = optional, string numeral format
function numberFormat(num, fmt) {
    fmt = fmt || '(0,0.00)';
    return ((num == null) || isNaN( num ))
            ? ''
            : numeral( num ).format( fmt );
}

function percentFormat(num, fmt) {
    return ((num == null) || isNaN( num ))
            ? ''
            : numberFormat(num, fmt) + '%';
}

function excelPercentFormat(num, fmt) {
    return ((num == null) || isNaN( num ))
            ? ''
            : numberFormat(num * 100, fmt) + '%';
}

// date column formatter :: requires moment js plugin
// parameters: 1) date = required  2) fmt = optional, string moment format
// date parameter can be passed as yyyymmdd (e.g. 20190531) :: other formats require custom date sorting functions
function dateFormat( date, fmt ) {
    fmt = fmt || "MMM D, YYYY";
    return date
            ? moment( date.toString() ).format( fmt )
            : '';
}

// auto size columns based on column contents
function autoSizeAllColumns( grid ) {
    // grid.api.sizeColumnsToFit();
    let allColumnIds = [];
    grid.columnApi.getAllColumns().forEach(function(column) {
        if (column.colDef.suppressSizeToFit) {
        }
        else {
            allColumnIds.push(column.colId);
        }
        // console.log(column);
    });
    grid.columnApi.autoSizeColumns(allColumnIds);
}

// return sidebar on the right
function sidebar ( tools ) {
    tools = tools || "columns, filters";               // default = columns and filters
    tools = tools.toLowerCase().replace(/\s+/g,"");    // remove white spaces

    let options = [];
    let elements = tools.split(",");

    for (let i = 0; i < elements.length; i++) {
        if (elements[i].indexOf("columns") > -1)
            options.push({
                            id:              'columns',
                            labelDefault:    'Columns',
                            labelKey:        'columns',
                            iconKey:         'columns',
                            toolPanel:       'agColumnsToolPanel',
                            toolPanelParams: {
                                suppressRowGroups:       true,
                                suppressValues:          true,
                                suppressPivots:          true,
                                suppressPivotMode:       true,
                                suppressSideButtons:     true,
                                suppressColumnFilter:    false,
                                suppressColumnSelectAll: false,
                                suppressColumnExpandAll: false
                            }
                        });
        else if (elements[i].indexOf("filters") > -1)
            options.push({
                            id:           'filters',
                            labelDefault: 'Filters',
                            labelKey:     'filters',
                            iconKey:      'filter',
                            toolPanel:    'agFiltersToolPanel'
                        });
    }
    return { toolPanels: options, defaultToolPanel: tools.split(",")[0] };
}

// ============================ //
// partial word= search - begin //
// =========================== //
function PartialFilter() {
}

PartialFilter.prototype.init = function (params) {
    this.valueGetter = params.valueGetter;
    this.filterText = null;
    this.params = params;
    this.setupGui();
};

// not called by ag-Grid, just for us to help setup
PartialFilter.prototype.setupGui = function () {
    this.gui = document.createElement('div');
    this.gui.innerHTML =
        '<div style="padding: 4px;">' +
        '<div style="font-weight: bold;">Custom Partial Words Filter</div>' +
        '<div class="ag-input-wrapper"><input style="margin: 4px 0px 4px 0px;" type="text" id="filterText" placeholder="Full name search..."/></div>' +
        '<div style="margin-top: 20px; width: 200px;">This filter does partial word search on multiple words, e.g. "mich phel" still brings back Michael Phelps.</div>' +
        '</div>';

    this.eFilterText = this.gui.querySelector('#filterText');
    this.eFilterText.addEventListener("input", this.onFilterChanged.bind(this));
};

PartialFilter.prototype.setFromFloatingFilter = function (filter) {
    this.eFilterText.value = filter;
    this.onFilterChanged();
};

PartialFilter.prototype.onFilterChanged = function () {
    this.extractFilterText();
    this.params.filterChangedCallback();
};

PartialFilter.prototype.extractFilterText = function () {
    this.filterText = this.eFilterText.value;
};

PartialFilter.prototype.getGui = function () {
    return this.gui;
};

PartialFilter.prototype.doesFilterPass = function (params) {
    // make sure each word passes separately, ie search for firstname, lastname
    let passed = true;
    let valueGetter = this.valueGetter;
    this.filterText.toLowerCase().split(" ").forEach(function (filterWord) {
        let value = valueGetter(params);
        if (value.toString().toLowerCase().indexOf(filterWord) < 0) {
            passed = false;
        }
    });

    return passed;
};

PartialFilter.prototype.isFilterActive = function () {
    let isActive = this.filterText !== null && this.filterText !== undefined && this.filterText !== '';
    return isActive;
};

PartialFilter.prototype.getModelAsString = function (model) {
    return model ? model : '';
};

PartialFilter.prototype.getModel = function () {
    return this.eFilterText.value;
};

// lazy, the example doesn't use setModel()
PartialFilter.prototype.setModel = function (model) {
    this.eFilterText.value = model;
    this.extractFilterText();
};

PartialFilter.prototype.destroy = function () {
    this.eFilterText.removeEventListener("input", this.onFilterChanged);
};


function PartialFloatingFilterComponent() {
}

PartialFloatingFilterComponent.prototype.init = function (params) {
    this.params = params;
    let eGui = this.eGui = document.createElement('div');
    eGui.className = 'ag-input-wrapper';
    let input = this.input = document.createElement('input');
    input.className = 'ag-floating-filter-input';
    eGui.appendChild(input);
    this.changeEventListener = function () {
        params.parentFilterInstance(function(instance) {
            instance.setFromFloatingFilter(input.value);
        });
    };
    input.addEventListener('input', this.changeEventListener);
};

PartialFloatingFilterComponent.prototype.getGui = function () {
    return this.eGui;
};

PartialFloatingFilterComponent.prototype.onParentModelChanged = function (model) {
    // add in child, one for each flat
    this.input.value = model != null ? model : '';
};

PartialFloatingFilterComponent.prototype.destroy = function () {
    this.input.removeEventListener('input', this.changeEventListener);
};
// ========================== //
// partial words search - end //
// ========================== //


// =================== //
//  Custom Pinned Row  //
// =================== //
function CustomPinnedRowRenderer() {}
function setStyle(element, propertyObject) {
  for (var property in propertyObject) {
    element.style[property] = propertyObject[property];
  }
}
CustomPinnedRowRenderer.prototype.init = function(params) {
  this.eGui = document.createElement('div');
  setStyle(this.eGui, params.style);
  this.eGui.innerHTML = params.value;
};
CustomPinnedRowRenderer.prototype.getGui = function() {
  return this.eGui;
};

function footerbar(element, alignment) {
    alignment = alignment || "center";
    let component = element.toLowerCase().trim();

    if (component === "total")
        return { statusPanels: [ { statusPanel: 'agTotalRowCountComponent', align: alignment } ] };
    else if (component === "filtered")
        return { statusPanels: [ { statusPanel: 'agFilteredRowCountComponent', align: alignment } ] };
    else if (component === "selected")
        return { statusPanels: [ { statusPanel: 'agSelectedRowCountComponent', align: alignment } ] };
    else if (component === "filtered_and_total")
        return { statusPanels: [ { statusPanel: 'agTotalAndFilteredRowCountComponent', align: alignment } ] };
    else
        return {};
}


function ClickableStatusBarComponent() {}
    ClickableStatusBarComponent.prototype.init = function (params) {
        this.params         = params;
        this.visible        = true;
        this.eGui           = document.createElement(params.element_tag);
        this.eGui.innerHTML = params.element_html;
    };
    ClickableStatusBarComponent.prototype.getGui          = function () { return this.eGui; };
    ClickableStatusBarComponent.prototype.destroy         = function () {};
    ClickableStatusBarComponent.prototype.onButtonClicked = function () {};
    ClickableStatusBarComponent.prototype.isVisible       = function () { return this.visible; };
    ClickableStatusBarComponent.prototype.setVisible      = function (visible) {
        this.visible            = visible;
        this.eGui.style.display = this.visible ? 'block' : 'none';
};

function no_data_available( grid, visibility ) {
    visibility = visibility || "visible";
    grid.overlayNoRowsTemplate = visibility !== "visible"
                                    ? "<span></span>"
                                    : "<span style='padding:10px; border:1px solid #444; background:lightgoldenrodyellow'>No data available</span>";
}




// NumericCellEditor is used to edit numeric cells.  Optionally pass in the min, max, and step values/
// Can set the CSS styling based on valid/invalid input by:
// input:invalid {
// 		border: 1px solid red;
// }
// input:valid {
// 		border: 1px solid #c4c5c7;
// }
// Should also validate the input using a ValueSetter
//
function NumericCellEditor() { }

NumericCellEditor.prototype.init = function (params) {
    this.eInput = document.createElement('input');
    this.eInput.type = 'text';
    this.eInput.classList.add('ag-cell-edit-input');
    if (params.charPress) {
        this.eInput.value = params.charPress;
        this.eInput.charPress = params.charPress;
    } else if (params.value) {
        this.eInput.value = params.value;
    }
    else {
        this.eInput.value = '';
    }

    this.eInput.addEventListener('keydown', function (e) {
        const deltaY = e.key === 'ArrowUp' || e.key === 'Up'
                        ? -1
                        : e.key === 'ArrowDown' || e.key === 'Down' || e.key === 'Enter'
                            ? +1
                            : null;
        if (deltaY) {
            let newRowIndex = params.node.rowIndex + deltaY;
            if (newRowIndex >= 0 && newRowIndex < params.api.getDisplayedRowCount()) {
                params.api.setFocusedCell(newRowIndex, params.column);
                params.api.startEditingCell({
                                                rowIndex: newRowIndex,
                                                colKey: params.column
                                            });
                return true;
            }
        }

        if ( !e.shiftKey && !e.altKey && !e.ctrlKey
            && e.keyCode == 190 || e.keyCode == 110 ) {    <!--- decimal point --->
            if (params.colDef.cellEditorParams
                && params.colDef.cellEditorParams.type
                && params.colDef.cellEditorParams.type.toLowerCase() === 'integer') {
                e.preventDefault();
                return;
            }
        }

        if ( !e.shiftKey && !e.altKey && !e.ctrlKey
            && ( e.keyCode >= 48 && e.keyCode <= 57 )    <!--- numbers--->
            || ( e.keyCode >= 96 && e.keyCode <= 105 )   <!--- numeric keypad--->
            || e.keyCode == 188
            || e.keyCode == 109 ||  e.keyCode == 189     <!--- comma, period and minus--->
            || e.keyCode == 8 || e.keyCode == 9          <!--- backspace and tab --->
            || e.keyCode == 35 || e.keyCode == 36        <!--- home and end--->
            || ( e.keyCode >= 37 && e.keyCode <= 40 )    <!--- left, up and right, down arrows--->
            || e.keyCode == 190 || e.keyCode == 110      <!--- decimal point --->
            || e.keyCode == 46 || e.keyCode == 45 ) {    <!--- del and ins--->
            // the above keys are valid, allow to continue (do not suppress)
        }
        else {
            // suppress other keys
            e.preventDefault();
        }
    });
};

NumericCellEditor.prototype.getGui = function () {
    return this.eInput;
};

// focus and select can be done after the gui is attached
NumericCellEditor.prototype.afterGuiAttached = function () {
	this.eInput.focus();
	this.eInput.select();
};

NumericCellEditor.prototype.getValue = function () {
    return this.eInput.value;
};

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~ save grid state into database ~~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
function ag_save( grid, storage_name ) {
    let settings = { columns: grid.columnApi.getColumnState() };
    if ( ag_debug ) {
        log.debug("==[ ag_save() ]== on", new Date());
        log.debug(settings);
    }

    $.ajax({
             url: "/components/util/query.cfc?method=save_ui_settings"
            ,type: "POST"
            ,data: { setting_name: storage_name
                     ,setting_value: JSON.stringify(settings)
                     ,user: cf_settings.user_id
                     ,returnFormat: "json"
                    }
            ,async: !is_ie()
            ,success: function(result) { if (ag_debug) log.debug("ag_save() status is", result) }
            ,error: function(xhr, status, error) {
                                                    log.debug("===== Failure in ag_save() =====");
                                                    log.debug("XHR", xhr);
                                                    log.debug("STATUS", status);
                                                    log.debug("ERROR", error);
                                            }
        });
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~ restore grid state from database ~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
function ag_restore( grid, storage, callback, exclude ) {
    exclude    = exclude || '';
    let params = { user: cf_settings.user_id, setting_name: storage, returnFormat:"json" };

    if ( ag_debug ) {
        log.debug("==[ ag_restore() ]==", new Date());
        params.column_name = "last_modified";
        // retrieve last modified date and display
        $.ajax({
             url:     "/components/util/query.cfc?method=get_ui_settings&t=" + $.now()
            ,data:    params
            ,success: function( result ) { log.debug("Last_Modified =", result) }
        });
    }

    params.column_name = "value";
    $.ajax({
             url:     "/components/util/query.cfc?method=get_ui_settings&t=" + $.now()
            ,data:    params
            ,error: function(xhr, status, error) {
                                                    log.debug("XHR", xhr);
                                                    log.debug("STATUS", status);
                                                    log.debug("ERROR", error);
         }
            ,success: function( result ) {
                                            try {
                                                let ag_settings = JSON.parse(result);
                                                // no previously saved state
                                                if (ag_settings === null) {
                                                    autoSizeAllColumns(grid);
                                                }
                                                else {
                                                    if ( ag_debug ) {
                                                        log.debug(ag_settings.columns);
													}
                                                    /* restore only when number of columns is the same (it may change due to new requirements) */
                                                    if (grid.columnApi.getColumnState().length == grid.columnDefs.length) {
                                                        grid.columnApi.setColumnState(ag_settings.columns);
                                                    }
												}
												if (callback) callback();	// optional callback after success
                                            }
                                            catch (error) {
                                                log.debug("Unexpected errors in ag_restore() on", new Date());
                                                log.debug(error);
                                            }
                                        }
        });
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~ add elements before/after column header text ~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
function customize_column_header (prepend_element, append_element, is_mass_apply) {
    prepend_element = prepend_element || '';
    append_element  = append_element || '';
    is_mass_apply   = is_mass_apply || 0;

    return     '<div class="ag-cell-label-container" role="presentation">' +
                '  <span ref="eMenu" class="ag-header-icon ag-header-cell-menu-button"></span>' +
                '  <div ref="eLabel" class="ag-header-cell-label" role="presentation"' + (is_mass_apply ? 'style="flex-direction:column"' : '') + '>' +
                (is_mass_apply
                    ? ''
                    :   '    <span ref="eSortOrder" class="ag-header-icon ag-sort-order" ></span>' +
                        '    <span ref="eSortAsc" class="ag-header-icon ag-sort-ascending-icon" ></span>' +
                        '    <span ref="eSortDesc" class="ag-header-icon ag-sort-descending-icon" ></span>' +
                        '    <span ref="eSortNone" class="ag-header-icon ag-sort-none-icon" ></span>'
                    ) +
                prepend_element +
                '   <span ref="eText" class="ag-header-cell-text" role="columnheader"></span>' +
                append_element +
                '    <span ref="eFilter" class="ag-header-icon ag-filter-icon"></span>' +
                '  </div>' +
                '</div>'
}

function columnsForExport( gridOptions ) {
    let result = [];
    const allColumns = gridOptions.columnApi.getAllDisplayedColumns();

    for (let i = 0; i < allColumns.length; i++) {
        let element = allColumns[i];
        // skip this column
        if ( element.colDef.bsaSupressExcel ) { }
        else {
            result.push( element.colId );
        }
    };
    return result;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~ convert grid into read-only mode ~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
function disable_editing( grid ) {
    if (grid.columnDefs) {
        /* disable all editable cells and header checkboxes */
        for (var i = 0; i < grid.columnDefs.length; i++) {
            grid.columnDefs[i].editable                = false;
            grid.columnDefs[i].headerCheckboxSelection = false;
        }

        /* disable checkbox icons selection */
        let style = document.createElement('style');
        style.innerHTML = ".ag-icon { pointer-events: none } .ag-theme-balham .ag-ltr .ag-cell { opacity: 0.75 }";
        document.head.appendChild(style);
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~ adjust line-height of rows in grid body ~~~~~~~~~~~~~~~~~~ //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
function set_grid_line_height( grid_id, lh ) {
    if (grid_id && lh) {
        let style = document.createElement('style');
        style.innerHTML = grid_id + " .ag-cell { line-height: " + lh + " } "
                          + grid_id + " div.editable { height: " + lh + " } "
                          + grid_id + " .ag-cell-inline-editing { height: " + lh + " }";
        document.body.appendChild(style);
    }
}