<!---
  * ====================================================================================================
  *    @File: \planners\create\planner_targets_approval.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  *
  * @Remarks: Planner Targets Approval
  *
  * ====================================================================================================
--->

<cfsilent>
    <cfscript>
        NO_ACTION_NECESSARY = "No action necessary";
        plannerManager      = createObject( "component", "mvc.Models.Planner.PlannerManager" );
        targets_cfc         = createObject("component", "mvc.models.planner.plannerTargets");
        qPlanner            = plannerManager.getPlanner( url.id );

        CURRENCY_FORMAT   = "(_,)";
        PERCENTAGE_FORMAT = "(_,._)";
    </cfscript>
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ Backend posting logic ~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif cgi.request_method is "post">
        <cfif form.action is 'disagree'>
            <cfquery datasource="#application.datasource#">
                EXEC Planner_Approval_Process #form.id#, '#request.AccessStructure.User_ID#', '#form.action#'
            </cfquery>

			<cfset local.emailAction = "disagree" />
			<cfinclude template="planner_send_email.cfm" />

        <cfelseif form.action gt ''>
            <cfstoredproc procedure="Planner_Target_Approval_Save" datasource="#application.datasource#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.id#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.trade_action#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.demo_action#">
                <cfprocparam cfsqltype="cf_sql_varchar" value="#form.slotting_action#">

                <cfprocresult name="result_set_1" resultSet=1>
                <cfprocresult name="result_set_2" resultSet=2>
            </cfstoredproc>

            <cfscript>
                if (isDefined("result_set_1.contract_main_id")) {
                    plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" );
                    plannerManager.updateProgramLockType( result_set_1 );
                }
            </cfscript>

			<cfset local.emailAction = isDefined("result_set_1.final_action")
                                         ? result_set_1.final_action
                                         : isDefined("result_set_2.final_action")
                                            ? result_set_2.final_action
                                            : ''>

			<cfinclude template="planner_send_email.cfm" />
        </cfif>
    </cfif>
</cfsilent>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <cfoutput><title>Target Approval #qPlanner.Planner_Number#</title></cfoutput>
</head>
<body>
    <cf_include files="planner_targets_approval.css, /common_files/jQuery.cfm, /script/javascript/loglevel/1.6.8/loglevel.min.js">

    <cfif cgi.request_method is "post">
        <cfif form.action gt ''>
            <script>
                // refresh the tab on parent page
                $("form[name=topnav]", opener.document).submit();

                window.close();
            </script>
        </cfif>
    </cfif>

    <cfinclude template="/common_files/jQueryUI.cfm">

    <cfset qSummary = targets_cfc.getApprovalSummaries( url.id )>

    <cfoutput>
    <form method="post" name="planner_targets_approval">
        <input type="hidden" name="action">
        <input type="hidden" name="id" value="#url.id#">
        <input type="hidden" name="trade_action" value="#qSummary.Action_Label_Trade#">
        <input type="hidden" name="demo_action" value="#qSummary.Action_Label_Demo#">
        <input type="hidden" name="slotting_action" value="#qSummary.Action_Label_Slotting#">
    </form>
    <div class="headers">
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~ top header ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <div class="header">
            <cfif (qSummary.Action_Label_Trade is NO_ACTION_NECESSARY
                and qSummary.Action_Label_Demo is NO_ACTION_NECESSARY
                and qSummary.Action_Label_Slotting is NO_ACTION_NECESSARY)
                or qSummary.Target_Exists eq 0>
                <!--- hide RFA and disagree action --->
            <style>
                div.planner {
                    width: 100%;
                }
            </style>
        <cfelse>
            <div class="rfa">
                <span class="rfa">Ready for approval</span>
                <span class="actions">
                    <cfif qSummary.Action_Label_Planner gt ''>
                        <a class="rfa" action="#qSummary.Action_Label_Planner#">#application.util.string.linkFormat(qSummary.Action_Label_Planner)#</a>
                    </cfif>
                    <a class="rfa" action="disagree">#application.util.string.linkFormat("Disagree")#</a>
                </span>
            </div>
        </cfif>
            <div class="planner">
                <div class="blk" style="width:10%">
                    #qPlanner.Planner_Number#
                </div>
                <div class="blk" style="width:35%">
                    #qPlanner.Ship_To#<br>
                    <b>#qPlanner.Name#</b>
                </div>
                <div class="blk" style="width:35%">
                    #qPlanner.Planner_Type#<br>
                    <b>#qPlanner.Planner_Description#</b>
                </div>
                <div class="blk" style="width:20%">
                    #dateFormat(qPlanner.Planner_Start_Date, "m/d/yyyy")# to #dateFormat(qPlanner.Planner_End_Date, "m/d/yyyy")#
                </div>
            </div>
        </div>

        <div class="summaries">
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~ summary trade ~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <div class="summary trade border-right">
                <h3>Trade Rate Summary</h3>
                <div class="summary toggle">
                    <img class="toggle" name="trade" src="/images/arrow-r-blue-12.png"> <span class="toggle ppg">Show Details</span>
                </div>
                <div class="summary_container">
                    <div class="column_1">
                        <div class="summary_header">&nbsp;</div>
                        <div>Trade Rate</div>
                        <div class="summary_footer pl5">Trade $</div>
                    </div>
                    <div>
                        <div class="summary_header">Target</div>
                        <div class="amt"> #application.util.string.pctFormat(qSummary.Target_Trade_Rate, PERCENTAGE_FORMAT)# </div>
                        <div class="summary_footer amt"> #application.util.string.usdFormat(qSummary.Target_Trade_Dollar, CURRENCY_FORMAT)# </div>
                    </div>
                    <div>
                        <div class="summary_header border-right">Plan</div>
                        <div class="border-right amt"> #application.util.string.pctFormat(qSummary.Planner_Trade_Rate, PERCENTAGE_FORMAT)# </div>
                        <div class="summary_footer border-right amt"> #application.util.string.usdFormat(qSummary.Planner_Trade_Dollar, CURRENCY_FORMAT)# </div>
                    </div>
                    <div>
                        <div class="summary_header">Variance &nbsp;</div>
                        <div class="amt"> #application.util.string.pctFormat(qSummary.Variance_Trade_Rate, PERCENTAGE_FORMAT)# &nbsp;</div>
                        <div class="summary_footer amt"> #application.util.string.usdFormat(qSummary.Variance_Trade_Dollar, CURRENCY_FORMAT)# &nbsp;</div>
                    </div>
                </div>
                <div class="trade_status">
                    <cfif qSummary.Target_Exists neq 0>
                        #summary_status(qSummary.Action_Label_Trade)#
                    </cfif>
                    <input type="hidden" name="trade_action" value="#qSummary.Action_Label_Trade#">
                </div>
            </div>

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~ summary demo ~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <div class="summary demo border-right">
                <h3>Demo Summary</h3>
                <div class="summary_container summary_container4">
                    <div class="column_1">
                        <div class="summary_header">&nbsp;</div>
                        <div class="border_bottom pl5">Demo</div>
                    </div>
                    <div>
                        <div class="summary_header">Target</div>
                        <div class="border_bottom amt"> #application.util.string.usdFormat(qSummary.Target_Demo, CURRENCY_FORMAT)# </div>
                    </div>
                    <div>
                        <div class="summary_header border-right">Plan</div>
                        <div class="border-right border_bottom amt"> #application.util.string.usdFormat(qSummary.Planner_Demo, CURRENCY_FORMAT)# </div>
                    </div>
                    <div>
                        <div class="summary_header pr5">Variance</div>
                        <div class="border_bottom pr5 amt"> #application.util.string.usdFormat(qSummary.Variance_Demo, CURRENCY_FORMAT)# </div>
                    </div>
                </div>
                <div class="demo_status">
                    <cfif qSummary.Target_Exists neq 0>
                        #summary_status(qSummary.Action_Label_Demo)#
                    </cfif>
                </div>
            </div>

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~~~~~ summary slotting ~~~~~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <div class="summary slotting">
                <h3>Slotting Summary</h3>
                <div class="summary_container summary_container4">
                    <div class="column_1">
                        <div class="summary_header">&nbsp;</div>
                        <div class="border_bottom pl5">Slotting</div>
                    </div>
                    <div>
                        <div class="summary_header">Target</div>
                        <div class="border_bottom amt"> #application.util.string.usdFormat(qSummary.Target_Slotting, CURRENCY_FORMAT)# </div>
                    </div>
                    <div>
                        <div class="summary_header border-right">Plan</div>
                        <div class="border-right border_bottom amt"> #application.util.string.usdFormat(qSummary.Planner_Slotting_All, CURRENCY_FORMAT)# </div>
                    </div>
                    <div>
                        <div class="summary_header pr5">Variance</div>
                        <div class="border_bottom pr5 amt"> #application.util.string.usdFormat(qSummary.Variance_Slotting, CURRENCY_FORMAT)# </div>
                    </div>
                </div>
                <div class="slotting_status">
                    <cfif qSummary.Target_Exists neq 0>
                        #summary_status(qSummary.Action_Label_Slotting)#
                    </cfif>
                </div>
            </div>
        </div>
    </div>

    <div class="details">
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~ detail trade ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <div class="detail trade border-right">
            <div id="trade_detail" style="margin-top:7px;width:100%;height:97%" class="ag-theme-balham ag-grid">
            </div>
        </div>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~ detail demo ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <div class="detail demo border-right">
            <div id="demo_detail" style="margin-top:7px;width:100%;height:97%" class="ag-theme-balham ag-grid">
            </div>
        </div>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~ detail slotting ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <div class="detail slotting">
            <div class="summary_header detail_header">#qSummary.Slotting_Position_Label#</div>
            <div class="detail_container" style="height:91%;border-bottom:1px solid ##9B9B9C;">
                <!--- <div class="summary_header">&nbsp;</div> --->
                <div  class="column_1" style="width:55%">
                    <div>Target</div>
                    <div>Committed $ <img src="/images/i.gif" title="Committed $ (from other planners)"> </div>
                    <div>Remaining Balance</div>
                    <div>This Request <img src="/images/i.gif" title="This Request (from this #Application.PlannerLabel#)"> </div>
                    <div class="border_bottom2">Variance</div>
                </div>
                <div style="width:45%;text-align:right;">
                    <div class="amt pr5">#application.util.string.usdFormat(qSummary.Target_Slotting, CURRENCY_FORMAT)#</div>
                    <div class="amt pr5">#application.util.string.usdFormat(qSummary.Prior_Approved_Slotting, CURRENCY_FORMAT)#</div>
                    <div class="amt pr5">#application.util.string.usdFormat(qSummary.Remaining_Balance_Slotting, CURRENCY_FORMAT)#</div>
                    <div class="amt pr5">#application.util.string.usdFormat(qSummary.Planner_Slotting, CURRENCY_FORMAT)#</div>
                    <div class="border_bottom2 amt pr5">#application.util.string.usdFormat(qSummary.Variance_Slotting, CURRENCY_FORMAT)#</div>
                </div>
            </div>
        </div>
    </div>

    <cfset rfa_no_member = 0>

    <div class="messages" style="width:1050px;margin:0 auto;">
        <cfset text_align = "text-align:center">
        <cfif qSummary.Action_Label_Trade is NO_ACTION_NECESSARY
            and qSummary.Action_Label_Demo is NO_ACTION_NECESSARY
            and qSummary.Action_Label_Slotting is NO_ACTION_NECESSARY>
            <cfset text_align = "text-align:left">
            <p>Target and Plan values are displaying as $0 as all programs associated to this #Application.PlannerLabel# have already been approved.</p><br>
        <cfelseif qSummary.Target_Exists eq 0>
            <cfset text_align = "text-align:left">
            <p>Targets do not exist. Please contact your System Admin to activate the Targets in order for the #Application.PlannerLabel# to be approved.</p><br>
        </cfif>
        <div class="rfa_no_member" style="display:none;">
            <p style="#text_align#">RFA programs with product groups that have no members.</p><br>
            <div id="rfa_no_member" style="width:40%;height:330px;margin:10px auto 0" class="ag-theme-balham ag-grid">
            </div>
        </div>
    </div>

    <div class="actions" style="right:5px">
        <a class="action close">#application.util.string.linkFormat("Close Window")#</a>
    </div>
    </cfoutput>




    <cffunction name="summary_status">
        <cfargument name="status" required="true">

        <cfswitch expression="#arguments.status#">
            <cfcase value="agree,approve">
                <cfset local.color = "##009739">
            </cfcase>
            <!--- <cfcase value="approve">
                <cfset local.color = "##009739">
            </cfcase> --->
            <cfcase value="agreed,approved">
                <cfset local.color = "##343540">
            </cfcase>
            <!--- <cfcase value="approved">
                <cfset local.color = "##343540">
            </cfcase> --->
            <cfdefaultcase>
                <cfset local.color = "black">
            </cfdefaultcase>
        </cfswitch>

        <cfoutput><span style="color:#local.color#">#arguments.status#</span></cfoutput>
    </cffunction>


    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /script/javascript/numeral.min.js, /styles/css-loader.css">

    <style>
        .ag-theme-balham .ag-root {
            border: 0;
        }
        div.ag-body-horizontal-scroll-viewport {
            display: none;
        }
        .rightA {
            text-align: right;
        }
        .cell-span {
            /* background-color: #00e5ff; */
        }
        .pr1 {
            padding-right: 1px !important;
        }
        .ag-theme-balham .even-row {
            /* background-color: #D5D8DC; */
            /* background-color: #EDEEF2; */
            background-color: #D7DBDD;
        }
        .ag-theme-balham .odd-row {
            background-color: white;
        }
        div.autowidth {
            width: auto !important;
        }
    </style>

    <script>
        'use strict';

        $("img.toggle").click(function(){
            let action_element = $(this).next("span");
            let action_text    = action_element.text();
            let is_showing     = (action_text.toLowerCase().indexOf("show") !== -1);

            $(this).attr("src", is_showing ? "/images/arrow-d-blue-12.png" : "/images/arrow-r-blue-12.png");

            if (is_showing) {
                $("div.details").css("opacity", "1");
                action_element.text( action_text.replace("Show", "Hide") );
                autoSizeAllColumns( glob.demo );
                $("div.messages").hide();
            }
            else {
                $("div.details").css("opacity", "0");
                action_element.text( action_text.replace("Hide", "Show") );
                $("div.messages").show();
            }
        });

        $("a.close").click(function(){
            window.close();
        });

        function formatNegative() {
            $("div.amt").each(function(){
                if ($(this).text().indexOf("(") >= 0) {
                    $(this).css({"color": "red", "background-color": "yellow"});
                }
            })
        }

        formatNegative();

        function splitString(str, maxWords){
            maxWords = maxWords || 2;
            const words = str.trim().split(" ");

            let result = [];
            for (let i = 0; i < words.length; i = i + maxWords) {
                let line = [ words[i] ];

                for (let j = 1; j < maxWords; j++) {
                    if ((i + j) < words.length) {
                        line.push(words[i + j]);
                    }
                }
                result.push(line.join(" "));
            }
            return result;
        }

        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { };

        const CURRENCY_FORMAT = '($0,0)';
        const PERCENTAGE_FORMAT = '(0,0.0)';

        glob.demo = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: true
                                    ,unSortIcon:      false
                                    ,sortable:        true
                                    ,resizable:       false
                                    ,cellStyle: function(p) { return isNaN(p.value)
                                                                    ? null
                                                                    : (Number(p.value) < 0)
                                                                        ? {color: 'red'}
                                                                        : null }
                                }
                ,columnDefs: [
                                { headerName:"PPG", field:"GROUP_DESC" }
                                ,{ headerName:"Target", field:"TARGET_DEMO", type: 'numericColumn'
                                    ,valueFormatter:function(p){ return currencyFormat(p.data.TARGET_DEMO, CURRENCY_FORMAT) } }
                                ,{ headerName:"Plan", field:"PLANNER_DEMO"
                                        ,type: 'numericColumn'
                                        ,valueFormatter:function(p){ return currencyFormat(p.data.PLANNER_DEMO, CURRENCY_FORMAT) }
                                    }
                                ,{ headerName:"Variance", field:"VARIANCE_DEMO"
                                        ,type:'numericColumn'
                                        ,valueFormatter:function(p){ return currencyFormat(p.data.VARIANCE_DEMO, CURRENCY_FORMAT) }
                                    }
                            ]
                ,enableRangeSelection:      false
                ,floatingFilter:  false
                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              "single"
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
            };

            glob.trade = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: true
                                    ,unSortIcon:      false
                                    ,sortable:        false
                                    ,resizable:       true
                                    ,cellStyle: function(p) { return isNaN(p.value)
                                                                    ? null
                                                                    : (Number(p.value) < 0)
                                                                        ? {color: 'red'}
                                                                        : null }
                                }
                ,columnDefs: [
                                { headerName:"PPG", field:"GROUP_DESC", rowSpan:function(p){ return 4 }, width:215, suppressSizeToFit:true
                                    ,cellStyle: function(p) { return p.data.KIND_ID == 1
                                                                    ? null
                                                                    : {"border-bottom": '0'}
                                                                        }
                                    ,cellRenderer:function(p){ return p.data.KIND_ID == 1
                                                                        ? '<b>' + p.data.GROUP_DESC + '</b>'
                                                                        : '';
                                                            } }
                                ,{ headerName:"", field:"KIND", cellRenderer:function(p){ return p.data.KIND } }
                                ,{ headerName:"Target", field:"TARGET", type:'numericColumn'
                                    ,valueFormatter:function(p){ return p.data.KIND === 'Trade Rate'
                                                                            ? percentFormat(p.data.TARGET, PERCENTAGE_FORMAT)
                                                                            : currencyFormat(p.data.TARGET, CURRENCY_FORMAT) } }
                                ,{ headerName:"Plan", field:"PLANNER", type:'numericColumn'
                                    ,valueFormatter:function(p){ return p.data.KIND === 'Trade Rate'
                                                                            ? percentFormat(p.data.PLANNER, PERCENTAGE_FORMAT)
                                                                            : currencyFormat(p.data.PLANNER, CURRENCY_FORMAT) } }
                                ,{ headerName:"Variance", field:"VARIANCE", type:'numericColumn'
                                    ,valueFormatter:function(p){ return p.data.KIND === 'Trade Rate'
                                                                            ? percentFormat(p.data.VARIANCE, PERCENTAGE_FORMAT)
                                                                            : currencyFormat(p.data.VARIANCE, CURRENCY_FORMAT) }
                                    ,cellStyle: function(p) { return variance_format(p) }
                                }
                                ,{ headerName:"", field:"VARIANCE_PCT", type:'numericColumn'
                                    ,cellStyle: function(p) { return variance_format(p) }
                                    ,valueFormatter:function(p){ return percentFormat(p.data.VARIANCE_PCT, PERCENTAGE_FORMAT) } }

                            ]
                ,enableRangeSelection:      false
                ,floatingFilter:  false
                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              "single"
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
                ,suppressRowTransform: true
                ,rowClassRules: {
                    'even-row': function(params) { return params.data.ROWID % 2 == 0; },
                    'odd-row': function(params) { return params.data.ROWID % 2 !== 0; }
                }
            };

            function variance_format(p) {
                return p.data.KIND !== 'Revenue'
                        ? null
                        : p.data.PLANNER > p.data.TARGET
                            ? {"color": 'black'}
                            :  p.data.PLANNER < p.data.TARGET
                                ?  {"color": 'red'}
                                : null;
            }

            ag_grid_default( glob.trade );
            init_ag_grid( glob.trade, "#trade_detail" );
            glob.trade.api.setHeaderHeight(30);

            ag_grid_default( glob.demo );
            init_ag_grid( glob.demo, "#demo_detail" );
            glob.demo.api.setHeaderHeight(30);

            glob.rfa_no_member = {
                defaultColDef: {     editable:        false
                                    ,suppressMenu:    true
                                    ,suppressMovable: true
                                    ,unSortIcon:      false
                                    ,sortable:        true
                                    ,resizable:       true
                                    ,cellStyle: function(p) { return {width: "auto"} }
                                }
                ,columnDefs: [
                                { headerName:"#Application.PlannerPrgLabel#", field:"CONTRACT_NUMBER", width:90, suppressSizeToFit:true }
                                ,{ headerName:"Group", field:"GROUP_NUMBER", width:80, suppressSizeToFit:true }
                                ,{ headerName:"Description", field:"GROUP_DESC", cellClass: "autowidth" }
                ]
                ,enableRangeSelection:      false
                ,floatingFilter:  false
                ,pagination:                false
                ,rowModelType:              "clientSide"
                ,rowSelection:              "single"
                ,suppressContextMenu:       true
                ,suppressRowClickSelection: true
                ,suppressRowTransform: true
            };

            $.ajax({    url: <cfoutput>"ajax/planner_targets_approval.cfm?id=#url.id#"</cfoutput>
                        ,data: { returnFormat:"json" }
                        ,error: function(xhr, status, error) { error_handler(arguments) }
                        ,success: function( result ) {
                                                        if (typeof result === 'string') {
                                                            result = JSON.parse(result);
                                                            glob.trade.api.setRowData( result[0] );
                                                            glob.demo.api.setRowData( result[1] );
                                                            glob.trade.api.sizeColumnsToFit();
                                                            glob.demo.api.sizeColumnsToFit();

                                                            if (result[2].length) {
                                                                $("div.rfa_no_member").show();
                                                                ag_grid_default( glob.rfa_no_member );
                                                                init_ag_grid( glob.rfa_no_member, "#rfa_no_member" );
                                                                glob.rfa_no_member.api.setRowData( result[2] );
                                                                glob.rfa_no_member.api.sizeColumnsToFit();
                                                            }
                                                        }
                                                    }
            });

            $("a.rfa").click(function(){
                show_loader();
                $("input[name=action]").val($(this).attr("action"));
                $("form[name=planner_targets_approval]").submit();
            });
        </script>

    <cfset request.focusHiLightOff = true>
</body>
</html>