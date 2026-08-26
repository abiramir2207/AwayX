<!---
  * ====================================================================================================
  *    @File: \settings\planners\targets\sales_targets.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  *
  * @Remarks: Sales Targets
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
    <cfif form.action is "update_timeframe">
        <cfquery datasource="#application.datasource#">
            EXEC Planner_Target_Create
                        @fiscal_year = #form.fiscal_year#
                        ,@Main_Distributor_Group_ID = '#form.main_distributor_group_id#'
                        ,@Invoice_Start_Date = '#form.invoice_start_date#'
                        ,@Invoice_End_Date = '#form.invoice_end_date#'
                        ,@User_ID = '#request.AccessStructure.User_ID#'
                        ,@Overwrite = 1
        </cfquery>

    <cfelseif form.action is "save">
        <cfset targets_cfc.setSalesTargets( form )>

    <cfelseif form.action is "update_original">
        <cfset targets_cfc.setSalesTargets( form )>
        <cfset targets_cfc.updateOriginalTargetRevenue( form )>
    </cfif>
</cfif>
</cfsilent>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
                margin-left: 20px;
                user-select: none;
            }
            label.input {
                font-weight: bold;
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
            button {
                cursor: pointer;
            }
            input.cb {
                position: relative;
                top: 1.5px;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">

    <cfscript>
        qHeader = targets_cfc.getTargets(url.id);
    </cfscript>

    <cfoutput>
    <form name="sales_targets" method="post" action="sales_targets.cfm?id=#url.id#">
        <input type="hidden" name="id" value="#url.id#">
        <input type="hidden" name="action">
        <input type="hidden" name="fiscal_year" value="#qHeader.fiscal_year#">
        <input type="hidden" name="Main_Distributor_Group_ID" value='#qHeader.main_distributor_group_id#'>

        <p> <img class="toggle" src="/images/arrow-r-blue-12.png"> Timeframe to gather invoices for initial target values</p>

        <div id="timeframe" class="hidden">
            <label class="input">From</label> <input type="text" readonly="readonly" value="#dateFormat(qHeader.Invoice_Start_Date,'m/d/yyyy')#" class="date" name="invoice_start_date">
            <label class="input">To</label> <input type="text" readonly="readonly" value="#dateFormat(qHeader.Invoice_End_Date,'m/d/yyyy')#" class="date" name="invoice_end_date">
            <button class="button update_timeframe">Update</button>
            <span id="already_in_place">
                <b style="margin-left:20px;">Note:</b> Adjustments are already in place. Updating the timeframe will overwrite all existing values.
            </span>
            <!--- <hr class="two"> --->
        </div>

        <cfif qHeader.Sales_Target_Updated_Date neq ''>
            <p class="last_changed">Last updated on <b>#dateFormat(qHeader.Sales_Target_Updated_Date, "medium")#</b> at #timeFormat(qHeader.Sales_Target_Updated_Date, "short")# by <b>#qHeader.Sales_Target_Updated_by#</b>
                <span class="changes_made" style="display:none;float:right;padding-right:5px;color:red;"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Changes have been made. Remember to save them.</span>
            </p>
        </cfif>

        <div id="actions">
            <button class="button recommended save">Save</button>
            <button class="button export">Export</button>
            <button class="button update_original">Update Original Target Revenue</button>


            <span style="display:inline-block; float:right">
                <label><input type="checkbox" class="cb" checked name="hide_zero"> Hide $0 rows</label>
            </span>
        </div>

        <div id="aggrid" style="width:100%;margin:0px;padding:0;" class="ag-theme-balham"></div>
    </form>
    </cfoutput>

    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /styles/css-loader.css, /script/javascript/numeral.min.js, /styles/font-awesome.min.css">
    <cfset jQueryUI.widgets = "full">
    <cfinclude template="/common_files/jQueryUI.cfm">

    <style>
        input.dollar {
            width: 70%;
            text-align: right;
        }
        .rightA {
            text-align: right;
        }
        .ag-header-cell-label {
            justify-content: center;
        }
    </style>

    <cf_include files="hide_zeros.js">

    <script>
        'use strict';

        $("img.toggle").click(function(){
            let timeframe = $("#timeframe");
            timeframe.toggle();
            $(this).attr("src", timeframe.is(":visible") ? "/images/arrow-d-blue-12.png" : "/images/arrow-r-blue-12.png");
            adjust_grid_height();
        });


        <!--- ~~~~~~~~~~ glob   = global variables  ~~~~~~~~~~ --->
        let   glob              = { grid_id:"#aggrid", detail_exists:0, tab_name:"sales", totals:{} };
        const CURRENCY_FORMAT   = '($0,0)';
        const PERCENTAGE_FORMAT = '(0,0.0)';

        <!--- ~~~~~~ adjust grid height ~~~~~~ --->
        function adjust_grid_height( offset ) {
            offset = offset || 50;
            let grid_element = $(glob.grid_id);
            if (grid_element) {
                let grid_height  = $(window).innerHeight() - grid_element[0].offsetTop - offset;
                grid_element.css({ "height": grid_height + "px" } );
                // log.debug($(window).innerHeight(), $("html")[0].clientHeight, grid_element[0].offsetTop, offset, grid_height );
            }
        }
        adjust_grid_height();

        <!--- ~~ define ag-grid configuration ~~ --->
        glob.my_grid = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: true
                                    ,unSortIcon:      false
                                    ,sortable:        true
                                    ,resizable:       true
                                    ,cellStyle: function(p) { return ( (p.column.colDef.type !== "numericColumn") || isNaN(p.value) )
                                                                        ? null
                                                                        : Number(p.value) < 0
                                                                            ? {color: 'red'}
                                                                            : null }
                               }
                ,columnDefs: [
                                { headerName:<cfoutput>"#targets_cfc.getProductGroupLabel(qHeader.Main_Product_Group_Type)#"</cfoutput>, field:"MAIN_PRODUCT_GROUP_DESC", pinned:"left", filter: "agTextColumnFilter", filterParams: { apply: false }, floatingFilterComponentParams: { suppressFilterButton: true }, width:270, floatingFilter: true
                                    ,pinnedRowCellRendererParams: { style: { "text-align":"center", "font-weight":"bold" } }
                                }
                                ,{ headerName:"Original Target Revenue", field:"SALES_TARGET_ORIGINAL"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_ORIGINAL, CURRENCY_FORMAT) }
                                    ,type:'numericColumn', filter:false, width:150, floatingFilter: false, cellClass: ['rightA', 'dollar'] }
                                ,{ headerName:"Override Value", field:"SALES_TARGET_OVERRIDE"
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_OVERRIDE, CURRENCY_FORMAT) }
                                    ,sortable:true, width:125, floatingFilter:false
                                    ,cellClass:function(p) { return p.node.isRowPinned()
                                                                        ? ["rightA", "dollar"]
                                                                        : ["rightA", "editable", "dollar"] }
                                    ,valueParser: numberParser, filter:false, editable:function(p) { return p.node.isRowPinned() ? false : true }
                                    ,cellEditor: 'numericCellEditor'
                                    ,onCellValueChanged: changes_made
                                 }
                                ,{ headerName:"Absolute Variance", field:"SALES_TARGET_ABSOLUTE_VARIANCE"
                                        ,valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_ABSOLUTE_VARIANCE, CURRENCY_FORMAT) }
                                        ,type:'numericColumn', filter:false, width:125, floatingFilter: false, cellClass: ['rightA', 'dollar'] }
                                ,{ headerName:"Percentage Change", field:"SALES_TARGET_PERCENTAGE_CHANGE"
                                        , valueFormatter:function(p){ return excelPercentFormat(p.data.SALES_TARGET_PERCENTAGE_CHANGE, PERCENTAGE_FORMAT) }
                                        ,type:'numericColumn', filter:false, width:125, floatingFilter: false, cellClass: ['rightA', 'perc'] }
                                ,{ headerName:"Final Target Revenue", field:"SALES_TARGET_FINAL"
                                        , valueFormatter:function(p){ return currencyFormat(p.data.SALES_TARGET_FINAL, CURRENCY_FORMAT) }
                                        ,type:'numericColumn', filter:false, width:125, floatingFilter: false, cellClass: ['rightA', 'dollar'] }
                            ]
                ,components:{
                    numericCellEditor: NumericCellEditor
			    }
                ,enableRangeSelection:      false

                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              false
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
                ,floatingFilter:  true
                ,isExternalFilterPresent: isExternalFilterPresent
                ,doesExternalFilterPass: doesExternalFilterPass
                ,getRowStyle:               function(p) { if (p.node.rowPinned) { return { 'font-weight': 'bold' } } }
                ,onFilterChanged: function(e) { show_totals() }
                ,onCellValueChanged: function(e) { show_totals() }
                ,excelStyles: [
                                { id: "dollar", numberFormat: {format: '$#,###,##0;[Red]($#,###,##0)'} }
                                ,{ id: "perc", numberFormat: {format: '##,##0.0%;[Red](##,##0.0)%'} }
                            ]
            };

        function show_totals() {
            glob.totals.SALES_TARGET_ABSOLUTE_VARIANCE = 0;
            glob.totals.SALES_TARGET_FINAL             = 0;
            glob.totals.SALES_TARGET_ORIGINAL          = 0;
            glob.totals.SALES_TARGET_OVERRIDE          = 0;

            glob.my_grid.api.forEachNodeAfterFilter(function(rowNode, index) {
                glob.totals.SALES_TARGET_ABSOLUTE_VARIANCE += rowNode.data.SALES_TARGET_ABSOLUTE_VARIANCE !== null ? +rowNode.data.SALES_TARGET_ABSOLUTE_VARIANCE : 0;
                glob.totals.SALES_TARGET_FINAL             += rowNode.data.SALES_TARGET_FINAL !== null ? +rowNode.data.SALES_TARGET_FINAL : 0;
                glob.totals.SALES_TARGET_ORIGINAL          += rowNode.data.SALES_TARGET_ORIGINAL !== null ? +rowNode.data.SALES_TARGET_ORIGINAL : 0;
                glob.totals.SALES_TARGET_OVERRIDE          += rowNode.data.SALES_TARGET_OVERRIDE !== null ? +rowNode.data.SALES_TARGET_OVERRIDE : 0;
            });

            glob.totals.SALES_TARGET_PERCENTAGE_CHANGE = glob.totals.SALES_TARGET_ORIGINAL !== 0
                                                            ? (glob.totals.SALES_TARGET_FINAL - glob.totals.SALES_TARGET_ORIGINAL) / glob.totals.SALES_TARGET_ORIGINAL
                                                            : null;
            glob.my_grid.api.setPinnedBottomRowData( [glob.totals] );
        }

        ag_grid_default( glob.my_grid );
        init_ag_grid( glob.my_grid, glob.grid_id );

        $.ajax({    url: <cfoutput>"ajax/sales_targets.cfm?id=#url.id#"</cfoutput>
                    ,data: { returnFormat:"json" }
                    ,error: function(xhr, status, error) { error_handler(arguments) }
                    ,success: function( result ) {
                                                    if (typeof result === 'string') {
                                                        result = JSON.parse(result);
                                                        glob.my_grid.api.setRowData( result[0] );

                                                        glob.totals = result[1][0];
                                                        show_totals();
                                                        glob.detail_exists = result.length ? 1 : 0;
                                                        if (result.length == 0) {
                                                            $("#already_in_place").hide();
                                                        }
                                                    }
                                                }
        });

        $(window).resize(function(){
            adjust_grid_height();
        });

        $("form").bind("keypress", function(e) {
            if (e.keyCode == 13) {
                return false;
            }
        });

        $("button.update_timeframe").click(function(){
            let update = 1;
            if (glob.detail_exists) {
                // update = confirm("Please confirm that you wish to overwrite all existing values.");
            }
            if (update) {
                show_loader("This may take a while. Please wait...");
                $("input[name=action]").val("update_timeframe");
                $("form[name=sales_targets]").submit();
            }
        });

        $("button.save, button.update_original").click(function(){
            show_loader();
            let form = $("form[name=sales_targets]");

            glob.my_grid.api.forEachNode(function(rowNode, index) {
                <!--- ~~ select only the changed rates ~~ --->
                if (rowNode.data.MAIN_PRODUCT_GROUP_DESC !== "TOTAL" && rowNode.data.SALES_TARGET_OVERRIDE !== rowNode.data.X_SALES_TARGET_OVERRIDE) {
                    form.append("<input type=hidden name='ITEM-" + rowNode.data.MAIN_PRODUCT_GROUP_ID + "' value='" + rowNode.data.SALES_TARGET_OVERRIDE + "'>");
                    log.debug(rowNode.data);
                }
            });

            // return false;
            $("input[name=action]").val( $(this).hasClass("save") ? "save" : "update_original");

            parent.refresh_tab_name( glob.tab_name, 0 );
            form.submit();
        });

        $("button.export").click(function(){
            let d           = new Date();
            let date_string = (d.getMonth()+1) + '-' + d.getDate() + '-' + d.getFullYear();
            let file_title  = <cfoutput>"Sales Targets #qHeader.Fiscal_Year# #qHeader.Main_Distributor_Group_Number#"</cfoutput>;
            glob.my_grid.api.exportDataAsExcel( { fileName: file_title + " As Of " + date_string, sheetName: file_title } );
            return false;
        });

        $(".date").datepicker({
            changeMonth: true
			,changeYear: true
            ,showButtonPanel: false
            ,maxDate: '0'
            ,onClose: function(selectedDate) {
                if ($(this).attr("name") == "invoice_start_date") {
                    $("input[name=invoice_end_date]").datepicker( "option", "minDate", selectedDate );
                }
                else {
                    $("input[name=invoice_start_date]").datepicker( "option", "maxDate", selectedDate );
                }
            }
        });
    </script>

    <cfset request.focusHiLightOff = true>
</body>
</html>