<!---
  * ====================================================================================================
  *    @File: \settings\planners\targets\target_list.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  *
  * @Remarks: List Planner Targets with edit option and activate/deactivate option
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
        targets_cfc           = createObject("component", "mvc.models.planner.plannerTargets");
        qTargets              = targets_cfc.getTargets();
    </cfscript>

    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /styles/ag-grid-ba.css">
    <!--- <cf_include files="/styles/ag-grid-ba.css"> --->

    <style>
        div#header {
            margin: 10px;
        }
        button.button {
            margin-right: 20px;
        }
        p {
            margin-bottom: 5px;
        }
        div.header {
            height: 60px;
        }
        div.ag-grid {
            padding-top: 60px;
            width: 98%;
            margin-left: 1%;
        }
    </style>


    <div id="header" class="header">
        <p>Target List - create a new Target or edit an existing one</p>
        <button class="button new">Create New Target</button>
        <button class="button export">Export</button>
    </div>

    <div id="aggrid" class="ag-theme-balham ag-grid"></div>

    <script>
        'use strict';
         log.disableAll();
         log.enableAll();

        const config = { starting_column: 1 };
        config.query = <cfoutput>#serializeJSON( qTargets )#</cfoutput>;

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
                                { headerName:"Fiscal", valueGetter:function(p){ return p.data[1]}, width:50 }
                                ,{ headerName:<cfoutput>"#targets_cfc.getDistributorGroupLabel()#"</cfoutput>, valueGetter:function(p){ return p.data[2] + ' ( ' + p.data[3]+ ' )'  } }
                                ,{ headerName:"", cellRenderer:function(p){ return '<div class="actions" rowlabel="' + p.data[1] + ' - ' + p.data[2]
                                                                                                            + '"rowid=' + p.data[0] + '>'
                                                                                            + '<button class="button update">Edit</button>'
                                                                                            + '<button class="button toggle">'
                                                                                                + ( p.data[4] ? 'Deactivate' : 'Activate' )
                                                                                                + '</button>'
                                                                                        + '</div>' }, width:300 }
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
            let file_title  = <cfoutput>"Targets List"</cfoutput>;
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
        });


        // add click event to ag-grid grid
        $("#aggrid").click(function(e) {
            // grap the clicked button
            const button = $(e.target);

            // edit button was clicked
            if (button.hasClass("update")) {
                let actions = button.parent("div.actions");
                let target_id = actions.attr("rowid");
                let target_label = actions.attr("rowlabel");
                parent.edit_tab( target_id, target_label );
            }
            // activate button was clicked
            else if (button.hasClass("toggle")) {
                let toggle_element = button;
                let toggle_action  = toggle_element.text();
                let target_id      = toggle_element.parent("div.actions").attr("rowid");
                if (confirm("Please confirm that you wish to " + toggle_action.toLowerCase() + " the selected target.")) {
                    alert(toggle_action + "d successfully.");
                    let new_active_status = (toggle_action.toLowerCase() == "activate" ? 1 : 0);
                    $.ajax({
                                url: "/mvc/models/planner/plannerTargets.cfc?method=setTargetStatus&id=" + target_id + "&active=" + new_active_status
                            });
                    log.debug(new_active_status);
                    toggle_element.text( toggle_action == "Activate" ? "Deactivate" : "Activate");
                }
            };
        });
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>