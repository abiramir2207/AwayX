<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\allocation_list.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks: List Planner Indirect Allocations
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
        qallocation           = allocation_cfc.getHeaders();
    </cfscript>

    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /styles/ag-grid-ba.css">

    <style>
        div.ag-grid, div#header {
            width: 40%;
            margin-left: 1%;
        }
        div#header {
            margin: 15px 10px 10px 10px;
            display: flex;
            align-content: space-evenly;
            justify-content: space-around;
        }
        button.button {
            margin-right: 20px;
        }
        button.new, button.downloadMaster {
            width: 140px;
        }
        p {
            margin-bottom: 5px;
        }
        div.ag-grid {
            padding-top: 50px;
            width: 40%;
            margin-left: 1%;
        }
    </style>


    <div id="header" class="header">
		<button class="button new"> Create Fiscal Year </button>
		<button class="button downloadMaster"> Download Master Data </button>
    </div>

    <div id="aggrid" class="ag-theme-balham ag-grid"></div>

    <script>
        'use strict';
         log.disableAll();
         log.enableAll();

        const config = { starting_column: 1 };
        config.query = <cfoutput>#serializeJSON( qallocation )#</cfoutput>;

        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid" };

        <!--- ~~ define ag-grid configuration ~~ --->
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
                                { headerName:"Fiscal", valueGetter:function(p){ return p.data[1]}, width2:50 }
                                ,{ headerName:"", cellRenderer:function(p){ return '<div class="actions" rowlabel="' + p.data[1]
                                                                                                            + '"rowid=' + p.data[0] + '>'
                                                                                            + '<button class="button update">Edit</button>'
                                                                                        + '</div>' }, width2:300 }
                            ]
                ,enableRangeSelection:      false
                ,floatingFilter:            false
                ,pagination:                false
                ,rowData:                   config.query.DATA
                ,rowModelType:              "clientSide"
                ,rowSelection:              false
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
            };

        ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, glob.grid_id );

        $("button.new").click(function(){
            parent.create_new_tab();
        });

        $("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = "Indirect Allocations";
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
        });


        $( "button.downloadMaster" ).click(function() {
            generate_export( "master_data.cfm" );
        });

        // add click event to ag-grid grid
        $("#aggrid").click(function(e) {
            // grap the clicked button
            const button = $(e.target);

            // edit button was clicked
            if (button.hasClass("update")) {
                let actions = button.parent("div.actions");
                let allocation_id = actions.attr("rowid");
                let allocation_label = actions.attr("rowlabel");
                parent.edit_tab( allocation_id, allocation_label );
            }
        });
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>