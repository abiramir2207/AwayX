<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\allocation_edit.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks: Edit planner indirect allocation
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfscript>
        request.ag_grid_dense = 0;
        request.forge_module  = "planners";
        allocation_cfc        = createObject("component", "mvc.models.planner.IndirectAllocation");
    </cfscript>

    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /styles/ag-grid-ba.css, /script/javascript/numeral.min.js">

    <style>
        div#header {
            width: 300px;
            margin-left: 1%;
        }
        div#header {
            margin: 15px 10px 10px 10px;
            display: flex;
            align-content: space-evenly;
            justify-content: space-around;
        }
        button.download, button.upload, button.downloadMaster {
            width: 100px;
        }
        button.downloadMaster {
            width: 140px;
        }
        p {
            margin-bottom: 5px;
        }
		div.ag-grid {
            padding-top: 50px;
        }
    </style>
	<cfscript>
        request.ag_grid_dense = 0;
        allocation_cfc        = createObject("component", "mvc.models.planner.IndirectAllocation");
        qallocation           = allocation_cfc.getHeaders( 'WHERE Planner_Indirect_Allocation_Header_ID       = #URL.id#' );
		iFiscalYear           = qallocation.Fiscal_year;
        labels                = allocation_cfc.getLabels( qallocation.Planner_Indirect_Allocation_Header_ID );
    </cfscript>

	 <div id="header" class="header">
        <button class="button download"> Download </button>
        <button class="button upload"> Upload </button>
	</div>

    <div id="allocation_edit" class="ag-theme-balham ag-grid"></div>



    <script>
        'use strict';
         log.disableAll();
         log.enableAll();

        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#allocation_edit" };

        <!--- ~~ define ag-grid configuration ~~ --->
        <cfoutput>
        glob.my_grid = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: false
                                    ,unSortIcon:      false
                                    ,sortable:        true
                                    ,resizable:       true
                                    ,filter: false
                                }
                ,columnDefs: [
                                 { headerName:"#labels.distributors# ##", field:"direct_number" }
                                ,{ headerName:"#labels.distributors# Name", field:"direct_name" }
                                ,{ headerName:"#labels.operators# ##", field:"indirect_number" }
                                ,{ headerName:"#labels.operators# Name", field:"indirect_name" }
                                ,{ headerName:"#labels.products#", field:"product" }
                                ,{ headerName:"#labels.products# Name", field:"product_name" }
                                ,{ headerName:"Allocation %", field:"allocation_percentage", valueFormatter:function( p ){ return numberFormat( p.data.allocation_percentage ) }, type:'numericColumn', filter:false  }
                            ]
                ,enableRangeSelection:      false
                ,floatingFilter:            false
                ,pagination:                false
                ,rowData:                   #application.util.query.toAgGridJSON( allocation_cfc.getDetail( url.id ), 'Direct_Number, Direct_Name, Indirect_Number, Indirect_Name, Product, Product_Name, Allocation_Percentage' )#
                ,rowModelType:              "clientSide"
                ,rowSelection:              false
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
            };
        </cfoutput>

        ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, glob.grid_id );

        glob.my_grid.api.sizeColumnsToFit();

		$("button.upload").click(function(){
		   	<cfoutput>
               parent.create_upload_tab( '#iFiscalYear#', #url.id# );
            </cfoutput>
        });

		 $("button.download").click(function(e){
            <cfoutput>
            let file_title  = "Indirect Allocations " + "#iFiscalYear#";
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of #dateFormat( now(), 'dddd mmm d yyyy' )#", sheetName: file_title } );
            </cfoutput>
        });
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>