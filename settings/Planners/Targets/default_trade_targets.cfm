<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\default_trade_targets.cfm
  *  @Author: Deepa Kunnath
  *    @Date: July 2020
  * 
  * @Remarks: Default Trade Targets
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
    </cfscript>
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ Backend posting logic ~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif cgi.request_method is "post">
        <cfif form.action is "update">
        <cfelseif form.action is "save">
            <cfset targets_cfc.setDefaultTradeTargets( form )>
        </cfif>
    </cfif>
</cfsilent>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Default Trade Rates</title>
</head>
<body>
    <cfsavecontent variable="styles">
        <style>
            * { 
                box-sizing: border-box; 
                margin: 0;
                padding: 0;
            }
            .hidden {
                display: none;
            }
            #timeframe {
                margin: 10px;
                padding: 10px;
            }
            label {
                font-weight: bold;
                margin-left: 20px;
            }
            p {
                margin: 10px;
            }
            img.toggle {
                cursor: pointer;
            }
            div#actions {
                margin: 10px;            
            }
            .rightA {
                text-align: right;
            }
            button.right {
                float: right;
            }
            input.mass_apply {
                width: 70%;
                margin-left: 10px;
            }
            div.edit {
                padding-left: 20px;
            }
            i.mass_apply {
                cursor: pointer;
            }
            button {
                cursor: pointer;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">

    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
        qHeader     = targets_cfc.getTargets(url.id);
        qDetail     = targets_cfc.getDefaultTradeTargets(url.id);
    </cfscript>
    
    <cfoutput>       

        <cfif qDetail.Updated_Date neq ''>
            <p class="last_changed">Last updated on <b>#dateFormat(qDetail.Updated_Date, "medium")#</b> at #timeFormat(qDetail.Updated_Date, "short")# by <b>#qDetail.Updated_By#</b></p>
        </cfif>

        <div id="actions">
            <button class="button save recommended">Save</button>
            <button class="button export">Export</button>
        </div>
		
	<form name="trade_targets" method="post" action="default_trade_targets.cfm?id=#url.id#">
		<input type="hidden" name="id" value="#url.id#">
		<input type="hidden" name="action">
		<input type="hidden" name="fiscal_year" value="#qHeader.fiscal_year#">
		<input type="hidden" name="Main_Distributor_Group_ID" value='#qHeader.main_distributor_group_id#'>
    
    </cfoutput>

        <div id="aggrid" style="width:95%;margin:0 5px 0 15px;padding:0;" class="ag-theme-balham"></div>   
    </form>

    <cfset request.ag_grid_version = "23">
    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /script/javascript/numeral.min.js, /styles/css-loader.css, /styles/font-awesome.min.css">

    <style>
        .ag-header-cell-label .ag-header-cell-text {
            white-space: pre;
            text-align: right;
        }        
        input.rate, input.mass_rate {
            width: 70%;
            position: relative;
            top: -1px;
        }
    </style>

    <script>
        'use strict';

        const config = { starting_column: 1 };
        config.query = <cfoutput>#serializeJSON( qDetail, "struct" )#</cfoutput>;
 
        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid" };
 
        <!--- ~~~~~~ adjust grid height ~~~~~~ --->
        function adjust_grid_height() {
            let grid_element = $(glob.grid_id);
            if (grid_element) {
                let grid_height  = $(window).innerHeight() - grid_element[0].offsetTop - 20;
                grid_element.css({ "height": grid_height + "px" } );
            }
        }
        adjust_grid_height();
 
        <!--- ~~ define ag-grid configuration ~~ --->
        const CURRENCY_FORMAT = '($0,0)';
        const MASS_APPLY      = true;

        glob.my_grid = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: true
                                    ,unSortIcon:      false
                                    ,sortable:        true
                                    ,resizable:       true
                               }
                ,columnDefs: [
                                 { headerName:"PPG", field:"SUB_PRODUCT_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:250, floatingFilter: true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, checkboxSelection:true }
                                ,{ 	headerName:"Trade Rate", field:"TRADE_RATE_DEFAULT"
                                    ,headerComponentParams: { template: customize_column_header(''
                                                                                                ,'<div class=edit><input class="mass_rate" placeholder="mass apply" title="Enter a rate to mass apply to selected records" type=text>'
                                                                                                    + ' <i class="fa fa-pencil mass_apply" title="Click to apply rate"></i>'
                                                                                                    + '</div>'
                                                                                                ,MASS_APPLY) }
								  	,valueFormatter:function(p){ 
													return p.data.TRADE_RATE_DEFAULT
														   ? numberFormat(p.data.TRADE_RATE_DEFAULT, '(0,0.0)') + '%'
														   : ' ' }
                                    ,filter:false, floatingFilter: false, cellClass:"rightA editable", width:130, editable:true, sortable:false }
                                
                            ]
                ,enableRangeSelection:      false
                ,pagination:                false
                ,rowData:                   config.query
                ,rowModelType:              "clientSide"
                ,rowSelection:              "multiple"
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true

                ,enterMovesDownAfterEdit:   true
                ,stopEditingWhenGridLosesFocus: true
                ,singleClickEdit:           true

                ,onGridReady:               function(p) {
                                                <!--- ~~~~~~~~ mass apply logic ~~~~~~~~ --->
                                                $("i.mass_apply").click(function(){
                                                    let mass_rate = $("input.mass_rate").val();
                                                    <!---  apply to filtered (visible) rows only  --->
                                                    glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                                                        <!--- ~~ apply to selected rows only ~~~ --->
                                                        if (rowNode.selected) {
                                                            rowNode.setDataValue("TRADE_RATE_DEFAULT", mass_rate);
                                                        }
                                                    });
                                                });
                                            }
            };
 
        ag_grid_default( glob.my_grid );

        glob.my_grid.excelStyles.push({ id: "rightA", numberFormat: {format: '$#,###,##0'} });

        init_ag_grid( glob.my_grid, glob.grid_id );        
        glob.my_grid.api.setHeaderHeight(35);

        $(window).resize(function(){ 
            adjust_grid_height();
        });

        $("button.export").click(function(e){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = "Default Trade Targets";
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
        });
		
        $("button.save").click(function(){
            // alert(1)
            show_loader();
            let form = $("form[name=trade_targets]");
            
            glob.my_grid.api.forEachNode(function(rowNode, index) {
                <!--- ~~ select only rates with value ~~ --->
                if (rowNode.data.TRADE_RATE_DEFAULT && rowNode.data.TRADE_RATE_DEFAULT !== "") {
                    form.append("<input type=hidden name='ITEM-" + rowNode.data.SUB_PRODUCT_GROUP_ID + "' value='" + rowNode.data.TRADE_RATE_DEFAULT + "'>");
                }
            });
            // return false;

            $("input[name=action]").val("save");
            form.submit();
        });
    </script>
    
    <cfinclude template="/common_files/focus.cfm">
</body>
</html>