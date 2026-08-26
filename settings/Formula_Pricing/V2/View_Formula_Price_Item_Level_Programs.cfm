<!DOCTYPE html>
<!----------------------------------------------------------------------------------
Name         :  AwayX\Script\javascript\ag-grid\sample2.cfm
Copyright    :  (c) 2018 Blacksmith Applications, Inc.
Created Date :  2/Oct/2018
Created By   :  Sharon Harris
Description  :  Sample page with 3 ag-grid tables
                All 3 are simple, client-side tables.
                Client-side ag-grid requires row-data be provided in a javascript array
                - Example 1 is using hard-coded data to show a simple setup
                - Example 2 is getting data in from a CF array
                - Example 3 is getting data from a CF query
                See "REQUIRED" comments in code below
 
                To test this, add these 2 lines to your page:
                <cfset request.contractTestID="39010" />    // contract id for data, defaults to 39010
                <a href="/Script/javascript/ag-grid/sample2.cfm">TEST ag-grid examples</a><br>
 
---------------------------------------------------------------------------------->
 
<!--- Sample data --->
<cfparam name="request.contractTestID" default="39010"> <!--- there must be a better way to do this... Hard coding default program ID--->
<cfset searchManager  = CreateObject("component","mvc.Models.Program.Search_Program") />
 <!--- <cfset qTestProgramDetails = searchManager.getProgramDetails(request.contractTestID) />get query for data --->
<!---<cfset aTestWorkFlowData = searchManager.getWorkFlowData(request.contractTestID) />  get array of data --->
 <cfscript>
        oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
        q = queryNew('Contract_number, Contract_Title, Contract_Start_Date, Contract_End_Date, Created_Type, Program_Fixed_Component_Name, RSP, Ship_To, Name, Price_Day_Description, Effective_Day_Description, Price_Day_Frequency, Formula_Type_Description, Calc_Type, Item, Description, Commodity, Weight, Comm_Overage_Desc, Comm_Overage, Overage_Calc_Type, Start_Price, Calculated_Comm_Overage, Comm_Price, Total_Comm_Price, Overage_Desc, Modification_Overage, Formula_Overage, Final_Price');
       // q = oFormula.getFormulaProgramReport();
</cfscript>

<html lang="en">
    <head>
        <title>Formula Price Program Export</title>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
 
 
        <!--- Include ag-grid --->
        <!--- REQUIRED: Define the theme and include the ag-grid files --->
        <cfset request.ag_grid_theme = "ba-ag-theme-balham">   <!---  use the Blacksmith theme --->
        <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm">    <!--- jquery is needed for focus.cfm --->
 
        <style>
            <!--- REQUIRED: For now, need to update these "ag-" classes, may move to common file --->
            .ag-theme-balham { font-size: 11px; }
            .ag-header { font-size: 11px !important; }
            .ag-theme-balham .ag-cell {
                padding-left: 2px;
                padding-right: 0px;
            }
            .ag-theme-balham .ag-row-selected {
                border-bottom-color: #b5b5b5; /* don't hide lines when selected */
            }
            .ag-theme-balham .ag-selection-checkbox span {
                left: 2px; /* center the checkbox */
            }
        </style>
 
 
    </head>
    <body>

        <div style="margin:10px"><br>
            <div class="Title5"> View Formula Programs </div>
                 <label>
                    <button onclick="onBtExport()" style="height: 18px; cursor: pointer">Export to Excel</button>
                     <button onclick="onBtGetPrg()" style="height: 18px; cursor: pointer">Get Formula Programs</button>
                </label>
            <br>
            <!--- <cfif isDefined("q") AND (q.Recordcount NEQ 0)> --->
                <br>
                <div class="Title7"> Use column filters to narrow your results</div>
                <div id="viewFormulaProgramGrid" style="margin-left:25px; height:85%; width:95%" class="ag-theme-balham"></div>
        <!---     </cfif> --->
        </div>
 
        <!--- Setup Client-side Grids --->
        <script>
            // *************************************************************
            // *************************************************************
            // example 3: Getting data from a Query
            <!---   <cfif isDefined("q") AND (q.Recordcount NEQ 0)> --->

                    function setFormulaGridHeight(len) {
                        if (len > 0) {
                            setFixedHeight(FP_GridOptions, "#viewFormulaProgramGrid", "730px"); //// setAutoHeight(FP_GridOptions, "#viewFormulaProgramGrid");
                        } else {
                            setFixedHeight(FP_GridOptions, "#viewFormulaProgramGrid", "130px");
                        }
                    }
                    function setFixedHeight(gridOptions, gridID, height) {
                        height = height || '100px';
                        gridOptions.api.setDomLayout('normal');
                        // when auto height is off, the grid has a fixed height, and then the grid
                        // will provide scrollbars if the data does not fit into it.
                        document.querySelector(gridID).style.height = height;
                    }
                    function setAutoHeight(gridOptions, gridID) {
                        gridOptions.api.setDomLayout('autoHeight');
                        // auto height will get the grid to fill the height of the contents,
                        // so the grid div should have no height set, the height is dynamic.
                        document.querySelector(gridID).style.height = '';
                    }
     
                var FP_RowData = <cfoutput>#application.util.query.toAgGridJSON(q, 'Contract_number, Contract_Title, Contract_Start_Date, Contract_End_Date, Created_Type, Program_Fixed_Component_Name, RSP, Ship_To, Name, Price_Day_Description, Effective_Day_Description, Price_Day_Frequency, Formula_Type_Description, Calc_Type, Item, Description, Commodity, Comm_Overage_Desc, Comm_Overage, Overage_Calc_Type, Start_Price, Calculated_Comm_Overage, Comm_Price, Total_Comm_Price, Overage_Desc, Modification_Overage, Formula_Overage, Final_Price, Bracket_Price, Weight, UOM')#</cfoutput>
                var FP_ColumnDefs = [
                    {headerName: "Contract Number", field: "contract_number", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter', rowGroup: true, hide:true},
                    {headerName: "Contract Title", field: "contract_title", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter'},
                    {headerName: "Contract Start Date", field: "contract_start_date", width:120, suppressFilter: false, suppressMenu: false, filter: "agDateColumnFilter", hide:true
                             ,filterParams:{
                                         suppressAndOrCondition: true
                                     }
                        },
                    {headerName: "Contract End Date", field: "contract_end_date", width:120, suppressFilter: false, suppressMenu: false, filter: "agDateColumnFilter", hide:true,filterParams:{
                                         suppressAndOrCondition: true
                                     }},
                    {headerName: "Template", field: "created_type", width:120, suppressFilter: false, suppressMenu: false, hide:true},
                    {headerName: "Component Name", field: "program_fixed_component_name", width:120, suppressFilter: false, suppressMenu: false, rowGroup: true, hide:true},
                    {headerName: "RSP", field: "rsp", width:120, suppressFilter: false, suppressMenu: false, hide:true},
                    {headerName: "Distributor ID", field: "ship_to", width:120, suppressFilter: false, suppressMenu: false, hide:true},
                    {headerName: "Distributor Name", field: "name", width:120, suppressFilter: false, suppressMenu: false, hide:true},
                    {headerName: "Price Day Description", field: "price_day_description", width:120, suppressFilter: false, suppressMenu: false, filter: "agSetColumnFilter"},
                    {headerName: "Effective Day Description", field: "effective_day_description", width:120, suppressFilter: false, suppressMenu: false, filter: "agSetColumnFilter"},
                    {headerName: "Price Day Frequency", field: "price_day_frequency", width:120, suppressFilter: false, suppressMenu: false, filter: "agSetColumnFilter"},
                    {headerName: "Formula Type Description", field: "formula_type_description", width:120, suppressFilter: false, suppressMenu: false, filter: "agSetColumnFilter"},
                    {headerName: "Calc Type", field: "calc_type", width:120, suppressFilter: false, suppressMenu: false},
                    {headerName: "Item", field: "item", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter', rowGroup: true, hide:true},
                    {headerName: "Description", field: "description", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter'},
                    {headerName: "Commodity", field: "commodity", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter', rowGroup: true, hide:true},  
                    {headerName: "Comm Input Desc", field: "comm_overage_desc", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter'},
                    {headerName: "Comm Input Amt", field: "comm_overage", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Input Calc Type", field: "overage_calc_type", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter'},
                    {headerName: "Comm Start Price", field: "start_price", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                   // {headerName: "Calculated Comm Overage", field: "calculated_comm_overage", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Calculated Comm Price", field: "comm_price", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Total Comm Price", field: "total_comm_price", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Modification Desc", field: "overage_desc", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter'},
                    {headerName: "Modification Input Amt", field: "modification_overage", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Formula Input", field: "formula_overage", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Formula Price", field: "final_price", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Final Bracket Price", field: "bracket_price", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Net Weight", field: "weight", width:120, suppressFilter: false, suppressMenu: false, filter: 'agNumberColumnFilter'},
                    {headerName: "Bracket Price UOM", field: "uom", width:120, suppressFilter: false, suppressMenu: false, filter: 'agTextColumnFilter'}
                ];
                // Init Example 3 grid
                var FP_GridOptions = {
                    pivotMode: false,
                    defaultColDef: {
                        enableValue: true,
                        enableRowGroup: true,
                        enablePivot: false,
                        sortable: true,
                        filter: true
                    }
                    ,columnDefs: FP_ColumnDefs
                    //,sideBar: true
                    ,sideBar: {
                        toolPanels: [{
                            id: 'columns',
                            labelDefault: 'Columns',
                            labelKey: 'columns',
                            iconKey: 'columns',
                            toolPanel: 'agColumnsToolPanel',
                            toolPanelParams: {
                               // suppressRowGroups: true,
                                suppressValues: true,
                                suppressPivots: true,
                                suppressPivotMode: true
                                //suppressSideButtons: true,
                                //suppressColumnFilter: true,
                                //suppressColumnSelectAll: true,
                                //suppressColumnExpandAll: true
                            }
                        },
                        {
                            id: 'filters',
                            labelDefault: 'Filters',
                            labelKey: 'filters',
                            iconKey: 'filter',
                            toolPanel: 'agFiltersToolPanel'
                        }
                        ]
                       // ,defaultToolPanel: 'columns'
                    }
                    ,rowData: FP_RowData
                    ,rowModelType: "clientSide"
                    ,cacheBlockSize: 2000
                    ,debug: true
                    ,enableColResize: true
                    ,floatingFilter: true
                    ,suppressExcelExport: false
                    ,statusBar: {
                                    statusPanels: [
                                        { statusPanel: 'agTotalRowCountComponent', align: 'left' },
                                        { statusPanel: 'agFilteredRowCountComponent', align: 'left' },
                                        { statusPanel: 'agSelectedRowCountComponent' },
                                        { statusPanel: 'agAggregationComponent' }
                                    ]
                                }
                    // ,autoGroupColumnDef: {headerName: "Item Number",
                    //     field: "item",
                    //     width: 200,
                    //     cellRenderer:'agGroupCellRenderer',
                    //     cellRendererParams: {
                    //         footerValueGetter: '"Total (" + x + ")"'
                    //     }}
                };
              //  ag_grid_default(FP_GridOptions);     // set up default features
               // FP_GridOptions.floatingFilter = true;
                init_ag_grid( FP_GridOptions, "#viewFormulaProgramGrid", false );  // init example_3 client-side grid

                function onBtExport() {
                        var params = {
                            skipHeader: false,
                            skipFooters: true,
                            skipPinnedTop: true,
                            skipPinnedBottom: true,
                            allColumns: false,
                            onlySelected: false,
                            fileName: 'FormulaPricePrograms.xls',
                            sheetName: 'DATA'
                            ,exportMode: 'xml'  //or xlsx
                        };

                        FP_GridOptions.api.exportDataAsExcel(params);
                    }

            function onBtGetPrg(){
                //Make sure we have rates
                show_loader('Getting Formula Programs...');
                var stop = 0;
                $.ajax({
                                async: true
                                ,data: {    //contractId:  '',
                                            //Claim_Mechanics: $('#rebate_eligible').val(),
                                            method: "getFormulaProgramItemLevelReport" }
                                //,dataType: "json"
                                ,success: function (data) {
                                     FP_RowData = JSON.parse(data);
                                  console.log(FP_RowData);
                                  //Products_GridOptions.api.setRowData(rowData_Bracket_Products);
                                 // console.log(rowData_Bracket_Products);
                                  //console.log("getProducts "+rowData_Bracket_Products.length);
                                  
                                  setFormulaGridHeight(FP_RowData.length-1);
                                  FP_GridOptions.api.setRowData(FP_RowData);
                                  FP_GridOptions.api.doLayout();  
                                    //  XXXXXXXXXXXXXX     THIS IS ON THE GPO_PRODUCTS_FORM>CFM INCLUDE FILE     XXXXXXXXXXXXXXXXXXXXXXXX  
                                    $("div.loader").hide();
                                }
                                ,error: function (data) {
                                    //console.log('An error occurred.');
                                    console.log(data);
                                    alert('An error occurred (get formula programs).  ' + JSON.stringify(data));
                                }
                                ,type: "post"
                                ,url: "/mvc/Models/Program/Component/Formula.cfc"
                    });
            }
            // <!--- </cfif>  --->
        </script>
 
        <cfinclude template="/common_files/focus.cfm">  <!--- Standard BA --->
    </body>
</html>