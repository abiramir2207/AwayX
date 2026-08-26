<!---------------------------------------------------------------------------------------------------------------------
      File Name:  \billbacks\Auto_BB_Report\BB_Auto_Report_View.cfm
   Created Date:  unknown
         Author:  unknown
        Purpose:  Display auto pay report

        Remarks:
      Revisions: 2016 Mar ChrisN: Added datatables, page filters 48219
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.Lock"	default="" />

<cfset oBBReportUpdate	= CreateObject("component","components.Billback.BBAutoReportUpdate").init() />

<cfif form.Lock neq "">
	<cfset lockStatus = oBBReportUpdate.lock_auto_pay(request.AccessStructure.User_id,form.Lock)>
</cfif>

<cfsilent>
    <cfparam name="form.action" default="">

    <cfif cgi.request_method eq "post">
        <cfif form.action eq "deleteReport">
            <cfset deleteResult = application.oBBReportAjaxCaller.deleteReportCaller( [ form.reportID, form.periodId, form.userId ] )>
        <cfelseif form.action eq "approve">
            <cfset approveResult = application.oBBReportAjaxCaller.approveReportCaller( [ form.reportID, form.userId ] )>
        </cfif>
    </cfif>
    <cfparam name="URL.Del" default="0" />
    <cfif url.del eq '1'>
        <cfset variables.view_deleted  = 1>
        <cfset variables.selectedIndex = 1>
    <cfelse>
        <cfset variables.view_deleted  = 0>
        <cfset variables.selectedIndex = 0>
    </cfif>
</cfsilent>
<cfif NOT structKeyExists(application,"oBBReportGet")>
	<cfset application.oBBReportAjaxCaller = CreateObject("component","components.Billback.BBAutoReportAjaxCaller").init() />
	<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
	<cfset application.oBBReportUpdate = CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
	<cfset application.oBBReportPeriod = CreateObject("component","components.Billback.BB_Auto_Report_Period") />
	<cfset application.oBBReportPeriodGateway = CreateObject("component","components.Billback.BB_Auto_Report_PeriodGateway") />
</cfif>
<cfmodule template="/customTags/layout.cfm"
                            layoutID = "autoPay"
                            selectedIndex = "#variables.selectedIndex#">
    <cfsavecontent variable="variables.uncompressed">
		<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
        <cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css"/>
        <style>
	#pop-up {
		display: none;
		position: absolute;
		padding: 2px;
		width: auto;
		background: #eeeeee;
		color: #000000;
		border: 1px solid #1a1a1a;
		z-index: 100;
	}
	#root {
                width: 100%;
                margin: 2px 0 0 0;
                padding: 0;
            }
            button.b036 {
                height: 20px;
                font-size: 11px;
                width: 100px;
            }
            form[name=filters], form[name=csv] {
                margin: 0;
                padding: 0;
            }
            a.search {
                margin-right: 15px;
            }
            .clear {
                clear: both;
            }
            .page-actions {
                height: 17px;
                width: 100%;
            }
                .primary_page_actions, .secondary_page_actions  {
                    float: left;
                    text-align: right;
                    margin: 0;
                    padding: 0;
                }
                .primary_page_actions  {
                    width: 54%;
                }
                .secondary_page_actions {
                    width: 45%;
                }
            div.dataTables_scrollHeadInner {
                padding-left: 0px !important;
            }
            span.message {
                color: red;
                font-weight: bold;
            }
            #datagrid {
                width: 100%;
            }
            table.datagrid {
                border: 0;
                table-layout: fixed;
            }
                table.datagrid td, table.datagrid th {
                    word-wrap: break-word;
                }
                table.datagrid th {
                    text-align: left;
                }
                table.datagrid td.right {
                    text-align: right;
                }
            .per_period_actions {
                float: left;
                width: 12.25%;
            }
                .per_period_actions img {
                    width: 13px;
                    height: 13px;
                    margin: 0;
                    padding: 0;
                }
                .per_period_actions img.small {
                    width: 10px;
                    height: 10px;
                    position: relative;
                    top: 1px;
                }
            div.filter {
                width: 24%;
                float: left;
                margin: 0;
                padding: 0;
                line-height: 26px;
            }
                div.filter label {
                    width: 33%;
                    display: inline-block;
                    text-align: right;
                    font-weight: bold;
                    padding-right: 4px;
                    position: relative;
                    top: -2px;
                }
                div.filter input, div.filter select {
                    width: 60%;
                }
                div.filter select optgroup {
                    font-weight: bold;
                    font-size: 13px;
                }
                div.filter input.date {
                    width: 27%;
                }
            div.center {
                text-align: center;
                width: 100%;
            }
        </style>
    </cfsavecontent>
    <cfoutput>#application.util.string.compress( variables.uncompressed )#
    <cfsilent>
        <cfscript>
            // default to show entries in the last 2 years
            variables.default = {  from_date= "#dateformat(dateAdd('m',-24,now()), 'm/d/yyyy')#",
                                     to_date= "#dateformat(now(), 'm/d/yyyy')#" };
        </cfscript>

        <cfparam name="URL.disp"           default="view" />
        <cfparam name="URL.Action"         default="" />
        <cfparam name="URL.runAll"         default="0" />
        <cfparam name="URL.Lck"            default="-1" />
        <!--- For Detail View Form Submits --->
        <cfparam name="FORM.Search_String" default="" />
        <!--- For Detail View Form Submits --->
        <!--- For View Form Submits --->
        <cfparam name="FORM.action"        default="" />
        <cfparam name="FORM.reportId"      default="" />
        <cfparam name="FORM.userId"        default="" />
        <cfparam name="approveResult"      default="" />
        <cfparam name="deleteResult"       default="" />
        <cfparam name="form.distributor"    default="" />
        <cfparam name="form.program_number" default="" />
        <cfparam name="form.operator"       default="" />
		<cfparam name="form.vendor"       default="" />
        <cfparam name="form.payable_number" default="" />
        <cfparam name="form.family"         default="" />
        <cfparam name="form.updated_by"     default="" />
        <cfparam name="form.autopay_status" default="" />
        <cfparam name="form.from_date"      default="#variables.default.from_date#" />
        <cfparam name="form.to_date"        default="#variables.default.to_date#"   />
		<cfparam name="form.showSearchForm"	default="0" />
		<cfparam name="form.report_search"	default="" />
		<cfparam name="form.invoice_number"	default="" />
		<cfparam name="form.invoice_number_exact_search"	default="1" />

        <cfif request.auto_pay.lock.processing>
            <cfset variables.report_message = "Auto pay report is processing, please wait... (this page will refresh automatically after a minute)">
        <cfelseif FORM.action EQ "Approve" AND isArray(approveResult)>
            <cfsavecontent variable="variables.report_message">Report: #approveResult[2]# #approveResult[4]# By #approveResult[3]#</cfsavecontent>
        <cfelseif FORM.action EQ "deleteReport" AND isArray(deleteResult)>
            <cfsavecontent variable="variables.report_message">Report: #deleteResult[2]# Deleted By #deleteResult[1].First# #deleteResult[1].Last#</cfsavecontent>
        <cfelse>
            <cfset variables.report_message = "">
        </cfif>
    </cfsilent>

	<form name="filters" method="post">
		<div id="root">
			<input type="hidden" name="process" value="#request.auto_pay.lock.processing#" />
			<input type="hidden" name="showSearchForm" value="1" />
			<input type="hidden" name="lock" value="" />
			<!--- request.auto_pay is initialized in layout.cfm --->
			<cfif request.auto_pay.lock.processing>
				<button class="readonly b036" onclick="location.href=location.href;">REFRESH</button>
			<cfelseif request.auto_pay.editing_by_me>
			<!--- Form will be submitted on "OnClick" --->
				<button class="edit b036" onClick="document.filters.lock.value=0">EDIT</button>
			<cfelse>
			<!--- Form will be submitted on "OnClick" --->
			<button class="readonly b036" onClick="document.filters.lock.value=1">READ ONLY</button>
				<cfif request.auto_pay.lock.locked>
					<cfsavecontent variable="variables.report_message">( locked by #request.auto_pay.lock.name_first# #request.auto_pay.lock.name_last# ) #variables.report_message#</cfsavecontent>
				</cfif>
			</cfif>&nbsp;<span class="message">#variables.report_message#</span>
		<div>
		<br />
<cfsavecontent variable="variables.uncompressed">    
<table cellpadding="5px;" border="0" width="100%" style="vertical-align:top;">
<tr>
	<td nowrap style="width:50px;" align="right">
		<b>#application.returned_customer_setting.Distributor_Label_Singular#:</b><img src="/images/help_small.gif" title="Keyword search on any of the fields:  Sold to ID ,Ship To, Name"/>
	</td>
	<td nowrap align="left">
		<input name="distributor" id="distributor" type="text" tabindex="1" value="#form.distributor#"  style="width:85px">
	</td>
	<td nowrap style="width:50px;" align="right">
		<b>Vendor:</b><img src="/images/help_small.gif" title="Keyword search on any of the fields:  Vendor ID, Name.">
	</td>
	<td nowrap align="left">
		<input name="vendor" id="vendor" type="text" tabindex="2" value="#form.vendor#"  style="width:85px">
	</td>
	<td nowrap style="width:50px;" align="right">
		<b>Status:</b><img src="/images/help_small.gif" title="Filter : Auto Pay Status.">
	</td>
	<td align="left">
		<select name="autopay_status" id="autopay_status" multiple="multiple" tabindex="4">
			<option value="-1" <cfif listfind(form.autopay_status, '-1')>selected</cfif>>New</option>
			<option value="1"  <cfif listfind(form.autopay_status, '1')>selected</cfif>>Scheduled</option>
			<option value="2"  <cfif listfind(form.autopay_status, '2')>selected</cfif>>Scheduled for recalc</option>
			<option value="3"  <cfif listfind(form.autopay_status, '3')>selected</cfif>>RFA</option>
			<option value="4"  <cfif listfind(form.autopay_status, '4')>selected</cfif>>Approved</option>
		</select>
	</td>
	<td  nowrap style="width:50px;" align="right">
		<b>Invoice ##:</b><img src="/images/help_small.gif" title="Filter : Invoice ##."/>
	</td>
	<td nowrap style="width:160px;">
		<table border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<input name="invoice_number" id="invoice_number" type="text" tabindex="1" value="#form.invoice_number#"  style="width:45px;">
				</td>
				<td>
					<input type="radio" name="invoice_number_exact_search" value="1" <cfif form.invoice_number_exact_search eq 1>checked</cfif>>Exact
					<br />
					<input type="radio" name="invoice_number_exact_search" value="0" <cfif form.invoice_number_exact_search eq 0>checked</cfif>>Like
				</td>
			</tr>
		</table>
	</td>
	<td  nowrap style="width:50px;" align="right">
		<b>Updated By:</b><img src="/images/help_small.gif" title="Filter : Auto Pay Updated by.">
	</td>
	<td nowrap align="left">
		<cfquery name="qUpdated_By" datasource="#application.datasource#">
			SELECT  _Users.User_Code
			FROM    dbo._Users
			WHERE   _Users.Deleted = <cfqueryparam value=0> AND _Users.User_Code <> <cfqueryparam value="">
			ORDER BY _Users.User_Code
		</cfquery>
		<select name="updated_by" id="updated_by" tabindex="3">
			<option value=""></option>
			<cfset variables.last_user_initial = "">
			<cfloop query="qUpdated_By">
				<cfset variables.this_user_initial = left(qUpdated_By.User_Code, 1)>
				<!--- detect last name initial change --->
				<cfif variables.this_user_initial neq variables.last_user_initial>
					<cfif variables.last_user_initial neq ""></optgroup></cfif>
					<optgroup label="- #ucase(variables.this_user_initial)# -">
				</cfif>
				<cfset variables.last_user_initial = variables.this_user_initial>
				<option <cfif form.updated_by eq qUpdated_By.User_Code>selected</cfif>>#qUpdated_By.User_Code#</option>
			</cfloop>
			</optgroup>
		</select>
	</td>
</tr>
<tr>
	<td nowrap style="width:50px;" align="right">
		<b>Payable:</b><img src="/images/help_small.gif" title="Keyword search on any of the fields:  ID, Title.">
	</td>
	<td align="left">
		<input name="payable_number" id="payable_number" type="text" tabindex="6" value="#form.payable_number#"  style="width:85px">
	</td>
	<td nowrap style="width:50px;" align="right">
		<b>Report:</b><img src="/images/help_small.gif" title="Keyword search on any of the fields:  ID, Title.">
	</td>
	<td align="left">
		<input name="report_search" id="report_search" type="text" tabindex="6" value="#form.report_search#"  style="width:85px">
	</td>
	<td nowrap style="width:50px;" align="right">
		<b>Created Date:</b><img src="/images/help_small.gif" title="Filter : Auto Pay Created Date.">
	</td>
	<td align="left">
		<input name="from_date" id="from_date" type="text" class="date" value="#form.from_date#" tabindex="7" style="width:75px"> <b>&mdash;</b>
		<input name="to_date"   type="text" class="date" tabindex="9" value="#form.to_date#" style="width:75px">
	</td>
	<td nowrap style="width:50px;" align="right">
		<b>Program:</b><img src="/images/help_small.gif" title="Keyword search on any of the fields:  ID, Title.">
	</td>
	<td nowrap align="left">
		<input name="program_number" id="program_number" type="text" tabindex="5" value="#form.program_number#"  style="width:85px">
	</td>
	<td nowrap align="left"><a href="##" class="search" onclick="search_auto_pay();">#application.util.string.actionLinkFormat2("search")#</a></td>
	<td nowrap><a href="##" onclick="reset_auto_pay();">#application.util.string.actionLinkFormat2("reset")#</a></td>
</tr>
<tr>
	<td colspan="8">&nbsp;</td>
	<td align="left">
	<cfif (not request.auto_pay.lock.processing) and request.auto_pay.editing_by_me and (not variables.view_deleted)>
		<a href="##" onclick="run_all_reports()">#application.util.string.actionLinkFormat2("run reports")#</a>
	</cfif>
	</td>
	<td> <a href="##" onclick="export_to_csv();">#application.util.string.actionLinkFormat2("export data")#</a></td>
</tr>
</table>
			<!---
                <div class="page-actions">
				
                    <div class="primary_page_actions">
                      <a href="##" class="search" onclick="search_auto_pay();">#application.util.string.actionLinkFormat2("search")#</a>
                        <a href="##" onclick="reset_auto_pay();">#application.util.string.actionLinkFormat2("reset")#</a>                       
                    </div>
					
                    <div class="secondary_page_actions">
                        <cfif (not request.auto_pay.lock.processing) and request.auto_pay.editing_by_me and (not variables.view_deleted)>
                                <a href="##" class="search" onclick="run_all_reports()">#application.util.string.actionLinkFormat2("run reports")#</a>
                        </cfif>
                        <a href="##" onclick="export_to_csv();">#application.util.string.actionLinkFormat2("export data")#</a>
                    </div>
				
                </div> 
				---> 
				<!--- <div class="page-actions"> --->
                </form>
                <!--- export to csv form --->
                <form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
                    <input type="hidden" name="csv_text" id="csv_text">
                    <input type="hidden" name="csv_file_name">
               </form>
            </cfsavecontent>     <!--- variable="variables.uncompressed" ---> 
			
			<fieldset style="padding:8px; width: 98%; border: 1px solid Blue;">
				<legend><span style="font: bold 14px sans-serif; color: Red;">Auto Pay Search</span>
					<!--- When the variable "showSearchForm" is 1, show the search form. --->
					<span style="font-weight:bold;color:red;">[</span><a href="##" id="AutoPaySearch" style="margin:2px;color:blue;font-weight:bold;" <cfif form.showSearchForm EQ 0>data-text-swap="hide"<cfelse>data-text-swap="show"</cfif>><cfif form.showSearchForm EQ 0>show<cfelse>hide</cfif></a><span style="font-weight:bold;color:red;">]</span>
				</legend>
				<div id="AutoPaySearchForm" <cfif form.showSearchForm EQ 0>style="display:none;"</cfif>>#application.util.string.compress( variables.uncompressed )#</div>
			</fieldset><br>
            </cfoutput>

        <cfset currMonth  = "" />
        <cfset mainAction = "" />
        <cfset currPeriod    = application.oBBReportGet.getCurrentPeriod() />
        <cfset qGetPeriods    = application.oBBReportGet.getPeriods(Del = URL.Del, filters = form) />

        <cfsavecontent variable="variables.uncompressed">
        <table id="tAutoReport" class="datagrid">
            <col width="3%">   <!--- id --->
            <col width="15%">  <!--- title --->
            <col width="5%">   <!--- start --->
            <col width="5%">   <!--- end --->
            <col width="5%">  <!--- status --->
            <col width="8%">  <!--- updated by --->
            <col width="5%">  <!--- no. of prog --->
            <col width="5%">  <!--- no. of bb --->
            <col width="8%">   <!--- amount --->
			<col width="8%">   <!--- amount --->
            <col width="10%">  <!--- action --->
            <thead>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Start</th>
                <th>End</th>
                <th>Status</th>
                <th>Updated By</th>
                <th>Programs</th>
                <th>BillBacks</th>
				<th>Gross Amount <span title="Gross Amount is the Claimed Amount, without recapture subtracted out."><img src="/images/help_small.gif"/></span></th>
				<th>Net Amount <span title="Net Amount is the Paid Amount, it has recapture subtracted out of it."><img src="/images/help_small.gif"/></span></th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <cfoutput query="qGetPeriods">
                <cfset ID = qGetPeriods.bb_auto_report_id />
                <cfset variables.status = qgetPeriods.Status />
                <cfif qgetPeriods.BBStatus GT qgetPeriods.Status>
                    <cfset variables.status = 3.5/>
                </cfif>
                <cfset statusDesc = application.oBBReportGet.getReportStatus(status = qgetPeriods.status,pause = 0,ID = ID) />
                <tr id="row#id#">
                    <!--- ID --->
                    <td class="right">
                            <cfif ID EQ 0>&nbsp;<cfelse>#ID#</cfif>
                    </td>
                    <!--- Title --->
                    <td>
                        #qGetPeriods.Report_Title#
                    </td>
                    <!--- Dates --->
                    <td>
                        #dateFormat(qGetPeriods.Start_Date, "mmm d yyyy")#
                    </td>
                    <td>
                        #dateFormat(qGetPeriods.End_Date, "mmm d yyyy")#
                    </td>
                    <!--- Status/Updated --->
                    <td>
                                #statusDesc#
                    </td>

                    <!--- Status/Updated --->
                    <td>
                        <cfif trim(qGetPeriods.updated_date) neq "">
                            #qGetPeriods.User_Code#: #application.oBBReportGet.formatDate(qGetPeriods.updated_date)#
                        </cfif>
                    </td>

                    <!--- # of progs --->
                    <td class="right">
                            #qGetPeriods.Program_Count#
                    </td>

                    <!--- # of bbs --->
                    <td class="right">
                            #qGetPeriods.Billback_Count#
                    </td>

                    <!--- $ gross amount --->
                    <td class="right">
                            #dollarformat(qGetPeriods.Gross_Amount)#
                    </td>

                    <!--- $ net amount --->
                    <td class="right">
                            #dollarformat(qGetPeriods.net_amount)#
                    </td>

                    <!--- Action --->
                    <td>
                        <cfset action = application.oBBReportGet.getAction(reportID = qgetPeriods.BB_Auto_Report_id,
                                                                           periodId = qgetPeriods.bb_auto_report_period_id,
                                                                             status = variables.status,
                                                                            endDate = qgetPeriods.end_date,
                                                                          startDate = qgetPeriods.start_date,
                                                                         currPeriod = currPeriod,
                                                                              pause = qGetPeriods.Pause_Schedule,
                                                                           isManual = qGetPeriods.Is_Manual) />
                        <div class="per_period_actions">#action[1]#</div>
                        <div class="per_period_actions">#action[2]#</div>
                        <div class="per_period_actions">#action[3]#</div>
                        <div class="per_period_actions">#action[4]#</div>
                        <div class="per_period_actions">#action[5]#</div>
						<!---
                        <cfif request.auto_pay.editing_by_me and url.del neq '1' and (not request.auto_pay.lock.processing)>
                            <cfif (application.appSettingsGet.getUNIPRO_450() IS 1)>
                                <div class="per_period_actions"><a title='Export Unipro 450' href="/billbacks/auto_bb_report/Unipro_450_Report.cfm?reportid=#qgetPeriods.BB_Auto_Report_id#" class="popup"><img src="/images/down.gif" border="0" alt="unipro" class="small"></a></div>
                            </cfif>
                            <cfif (application.appSettingsGet.getPullbacksOn())>
                                <div class="per_period_actions"><a title="Export #application.appSettingsGet.getPullbackLabel()#" href="/billbacks/auto_bb_report/BB_Auto_Report_Export_Pullback_Universal.cfm?reportid=#qgetPeriods.BB_Auto_Report_id#" class="popup"><img src="/images/down_1.gif" border="0" alt="export pullback" class="small"></a></div>
                            </cfif>
                            <cfif (application.oBBReportGet.getGrowthCalcExist(qgetPeriods.BB_Auto_Report_id))>
                                <div class="per_period_actions"><a title="Growth Calculation" href="/billbacks/auto_bb_report/BB_Auto_Report_Growth_Calc_Details.cfm?reportid=#qgetPeriods.BB_Auto_Report_id#" class="popup"><img src="/images/last_series.gif" border="0" alt="grow calculation" class="small"></a></div>
                            </cfif>
                        </cfif>   <!--- request.auto_pay.editing_by_me --->
						 --->
                    </td>
                </tr>
            </cfoutput>
            </tbody>
        </table>
        <form name="frm_BB_Auto_Report_View" method="post">
            <input type="hidden" name="action" id="action" value="" />
            <input type="hidden" name="userId" id="userId" value="" />
            <input type="hidden" name="reportId" id="reportId" value="0" />
            <input type="hidden" name="periodId" id="periodId" value="0" />
        </form>
        </cfsavecontent>
        <cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
    </div>   <!--<div id="root">-->

    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/common_files/dataTables2.cfm">
    <cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/table2csv.js, /styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js, /script/javascript/jquery.noty.packaged.min.js,/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"/>

<script>
    var myDataGrid = jQuery('#tAutoReport').DataTable({
                          "autoWidth": false
                          ,"columns": [  {"orderable":true,  "searchable":false , "type":"html-num" }   // id
                                        ,{"orderable":true,  "searchable":false }   // title
                                        ,{"orderable":true,  "searchable":false }   // start date
                                        ,{"orderable":true,  "searchable":false }   // start date
                                        ,{"orderable":true,  "searchable":false }   // status
                                        ,{"orderable":true,  "searchable":false }   // status
                                        ,{"orderable":true,  "searchable":false, "type":"html-num" }   // # of programs
                                        ,{"orderable":true,  "searchable":false, "type":"html-num" }   // # of bbs
                                        ,{"orderable":true,  "searchable":false, "type":"html-num-fmt"  }   // gross amount
									    ,{"orderable":true,  "searchable":false, "type":"html-num-fmt"  }   // net amount
                                        ,{"orderable":false, "searchable":false}   // action
                                        ]
                          ,"dom": "ti"
                          ,"language": { search: "Search auto pay on listing below:", paginate: { previous:"prev", next:" next" }  }
                          ,"paging": false
                          ,"order": []
                          ,"orderClasses": false
                          ,"scrollCollapse": true
                          ,"scrollY": Math.floor(jQuery(window).height()) - 220
                        });
     //ajBBReport = new autoPay();
     //myDataGrid.fixedHeader.adjust().columns.adjust();
<!---
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//XXXXXXXXXXXXXXXX        Response          xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
    function callReportResponse(response) {
        var theAction = 'spanAction' + response[1];
        var theLoad = 'spanLoading' + response[1];
        //var theLoad = 'createLoading';
        var theUpd = 'spanUpd' + response[1];
        var theStat = 'spanStatus' + response[1];
        var theID = 'spanID' + response[1];

      //hide loader image
      document.getElementById(theLoad).style.display = 'none';
      disabledImageZone.style.visibility = 'hidden';
      //update user and date
      document.getElementById(theUpd).innerHTML = response[2];
      //update status
      document.getElementById(theStat).innerHTML = response[3];
      //update ID
      document.getElementById(theID).innerHTML = response[1];
      //unlock Links
      unLockLinks();
      // Place the server-side generated html and place inside a span
      //must call this after the unlocklinks func since there are links in the return
      //alert(theAction+' :: '+response[0]);
     document.getElementById(theAction).innerHTML = response[0];
      }
function callCreateResponse(response) {
        var createLoading = 'createLoading';
        var create = 'create';
      //insert new row in admin table
        insRow(response);
        // Place the server-side generated html and place inside a span
      document.getElementById('createAction').innerHTML = response[5];
      //hide loader image
      //document.getElementById(createLoading).style.display = 'none';
      disabledImageZone.style.visibility = 'hidden';
      //unlock Links
       unLockLinks();
      }
function callCancelResponse(response) {
        var rowID = 'row' + response[1];
        var row = document.getElementById(rowID).sectionRowIndex

      // Place the server-side generated html and place inside a span
      document.getElementById('createAction').innerHTML = response[0];
      //delete row
      var delrow = document.getElementById('tAutoReport').deleteRow(row);
      //hide spinner
      //document.getElementById('createLoading').style.display = 'none';
      disabledImageZone.style.visibility = 'hidden';

      unLockLinks();
      }
function callDeleteResponse(response) {
    if(response[4] == "0")
    {
        alert("Delete was unsuccessful");
        document.getElementById('createLoading').style.display = 'none';
        // hide spinner
        var loaderId = 'spanLoading' + response[1];
        document.getElementById(loaderId).style.display = 'none';
    }
    else
    {
        var rowID = 'row' + response[1];
        var row = document.getElementById(rowID).sectionRowIndex

      // Place the server-side generated html and place inside a span
      document.getElementById('createAction').innerHTML = response[0];
      //delete row
      var delrow = document.getElementById('tAutoReport').deleteRow(row);
      //hide spinner
      //document.getElementById('createLoading').style.display = 'none';

    }
    disabledImageZone.style.visibility = 'hidden';
    unLockLinks();
}
function insRow(args)
      {
          var row=document.getElementById('tAutoReport').insertRow(1);
          var cId=row.insertCell(0);
          var cTitle=row.insertCell(1);
          var cDate=row.insertCell(2);
          var cUpdated=row.insertCell(3);
          var cNumProg=row.insertCell(4);
          var cNumBB=row.insertCell(5);
          var cAmount=row.insertCell(6);
          var cAction=row.insertCell(7);

          row.id="row"+args[1];
          //date
          cDate.innerHTML=args[4];
          cDate.className = 'colHead';
          //ID field
          cId.id="spanStatus"+args[1];
          cId.innerHTML= '<b>' + args[1] + '</b>';
          //Action
          cAction.id="spanAction"+args[1];
          cAction.innerHTML=args[0];
          //updated stats
          cUpdated.id="spanUpd"+args[1];
          cUpdated.innerHTML= "<b>" + args[3] + "</b><br>" + args[2];
          //report status
         // cStatus.id="spanStatus"+args[1];
          //cStatus.innerHTML=args[4];//+" "+args[3]

          cTitle.innerHTML="&nbsp;";
          cAmount.innerHTML="&nbsp;";
            cNumProg.innerHTML="&nbsp;";
            cNumBB.innerHTML="&nbsp;";

      }
<!---
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//XXXXXXXXXXXXXXXX        Actions          xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

function cancelReportAction(reportId,periodId,userId) {  //
      var argument = new Array();
      //var theId = 'spanLoading' + reportId;
      var theId = 'createLoading';
      var theAction = 'spanAction' + reportId;
      var createLoading = 'createLoading';
      argument[0]    = reportId;
      argument[1]    = userId;
      if (document.all.frm_BB_Auto_Report.process.value == '0')
        {
        lockLinks();
          // Show loader
        //document.getElementById(createLoading).style.display = '';
        disabledImageZone.style.visibility = 'visible';
          //call ajax
          ajBBReport.call('cancelReportCaller',callCancelResponse,argument);
      }
      else
          {
            alert("Another Process is currently running.  Please wait until it completes and try again.");
          }

      }
function createReportAction(periodId,userId) {
      // Calls remote method with string mask as argument
      var argument = new Array();
      var theId = 'createLoading';
      var theAction = 'create';
      argument[0]    = periodId;
      argument[1]    = userId;
      if (document.all.frm_BB_Auto_Report.process.value == '0')
        {
        lockLinks();
      // Show loader elementId = periodid + reportid...reportid is always 0 for create
      // document.getElementById(theId).style.display = '';
      disabledImageZone.style.visibility = 'visible';
       //Hide the Links
        //document.getElementById(theAction).innerHTML = '';
      //call ajax.  response goes to JS callReportResponse() in an array
      ajBBReport.call('createReportCaller',callCreateResponse,argument);
      }
      else
          {
            alert("Another Process is currently running.  Please wait until it completes and try again.");
          }
      }
function approveReportAction(reportId, periodId, userId) {
    please_wait("Approving the selected auto pay, please wait...");
    document.all.frm_BB_Auto_Report_View.action.value   = 'approve';
    document.all.frm_BB_Auto_Report_View.userId.value   = userId;
    document.all.frm_BB_Auto_Report_View.reportId.value = reportId;
    document.all.frm_BB_Auto_Report_View.submit();
}
function please_wait( msg ) {
    noty( {    text: msg
            ,layout: 'bottom'
              ,type: 'information'
            ,killer: true
          });
    /* disable onclick event on a tags */
    jQuery("#tAutoReport a").prop("onclick", null);
}
/* set the processing flag to 1 to prevent more changes */
function set_processing() {
    jQuery.ajax({
                    url: "/components/Billback/BBAutoReportUpdate.cfc",
                   data: {   method: "setReportProcess",
                             status: 1                   },
                  async: true
    });
}
function run_report(reportId) {
    please_wait("Running the selected auto pay, please wait...");
    jQuery.ajax({
                  url:"/components/Billback/BBAutoReportUpdate.cfc",
                  data: {   method: "runBBAutoCreate",
                          reportId: reportId           }
    });
    /*submit form to retain filters*/
    jQuery("form[name=filters]").submit();
}
function run_all_reports() {
    please_wait("Running all auto pay, please wait...");
    jQuery.ajax({
                  url:"/components/Billback/BBAutoReportUpdate.cfc",
                  data: {   method: "runBBAutoCreate",
                          reportId: ''                }
    });
    /*submit form to retain filters*/
    jQuery("form[name=filters]").submit();
}
function deleteReportAction(reportId, periodId, userId) {
    please_wait("Deleting the selected auto pay, please wait...");
    document.all.frm_BB_Auto_Report_View.action.value   = 'deleteReport';
    document.all.frm_BB_Auto_Report_View.userId.value   = userId;
    document.all.frm_BB_Auto_Report_View.reportId.value = reportId;
    document.all.frm_BB_Auto_Report_View.periodId.value = periodId;
    document.all.frm_BB_Auto_Report_View.submit();
}
function pauseReportAction(reportId,periodId,userId,pause) {
      /* Calls remote method with string mask as argument */
      var argument = new Array();
      var theId = 'spanLoading' + reportId;
      var theAction = 'spanAction' + reportId;
      argument[0]    = reportId;
      argument[1]    = periodId;
      argument[2]    = userId;
      argument[3]    = pause;
      if (document.all.frm_BB_Auto_Report.process.value == '0')
        {
            lockLinks();
              // Show loader elementId = periodid + reportid...reportid is always 0 for create
               document.getElementById(theId).style.display = '';
            disabledImageZone.style.visibility = 'visible';
              //Hide the Links
           document.getElementById(theAction).innerHTML = '';
              //call ajax.  response goes to JS callReportResponse() in an array
              ajBBReport.call('pauseReportCaller',callReportResponse,argument);
      }
      else
          {
            alert("Another Process is currently running.  Please wait until it completes and try again.");
          }
}
function saveProgramAction(){
          // Calls remote method with string mask as argument
      var argument = new Array();
      var reportId = document.all.frm_BB_Auto_Report.curentReport.value;
      var userId = <cfoutput>'#request.accessStructure.User_Id#'</cfoutput>;
      var theId = 'spanLoading' + reportId;
      //var theId = 'createLoading';
      var theAction = 'spanAction' + reportId;
      argument[0]    = reportId;
      argument[1]    = userId;
      argument[2]    = document.all.frm_BB_Auto_Report.Program_List.value;
     // alert(" :: " + document.all.frm_BB_Auto_Report.Program_List.value);
      if (document.all.frm_BB_Auto_Report.process.value == '0')
        {
            lockLinks();
              // Show loader elementId = periodid + reportid...reportid is always 0 for create
               document.getElementById(theId).style.display = '';
            disabledImageZone.style.visibility = 'visible';
              //Hide the Links
           document.getElementById(theAction).innerHTML = '';
              //call ajax.  response goes to JS callReportResponse() in an array
              ajBBReport.call('saveProgramCaller',callReportResponse,argument);
              //alert("call ajax" + argument[2]);
      }
      else
          {
            alert("Another Process is currently running.  Please wait until it completes and try again.");
          }
}

function SearchPrograms(Billback_ID,reportID) {
      //alert(Billback_ID + " :: " +reportID);
       document.all.frm_BB_Auto_Report.curentReport.value = reportID;
     NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=frm_BB_Auto_Report&fieldname=Program_List&selectMultiResultOverRide=1&Billback_ID=" + Billback_ID, "programswindow", 800, 600, "yes", "yes");
}
/////////////
/// 48219 ///
/////////////
function search_auto_pay() {
    if ((jQuery("input[name=from_date]").val() === "") || (jQuery("input[name=to_date]").val() === "")) {
        jQuery("input[name=from_date]").focus();
        alert("Please enter a created date range.");
        return false;
    }
    jQuery("div.primary_page_actions").html("Searching for information, please wait...");
    jQuery("form[name=filters]").submit();
}
function reset_auto_pay() {
    <cfoutput>
    jQuery("input[type=text], select").val("");
    jQuery("input[name=from_date]").val("#variables.default.from_date#");
    jQuery("input[name=to_date]").val("#variables.default.to_date#");
    jQuery("div.primary_page_actions").html("Resetting information, please wait...");
    jQuery("form[name=filters]").submit();
    </cfoutput>
}
jQuery('#tAutoReport tr').hover(function() { jQuery(this).toggleClass("over"); } );
jQuery(".date").datepicker({
    dateFormat: "m/d/yy",
    changeMonth: true,
    changeYear: true,
    onSelect: function( selected ) {
        // change date limit based on selected value
        if ( jQuery(this).attr("name") === "from_date" )
            jQuery("input[name=to_date]").datepicker("option", "minDate", selected);
        else
            jQuery("input[name=from_date]").datepicker("option", "maxDate", selected);
    }
});
jQuery("div.per_period_actions a.popup").click(function() {
    popupCenterByPercentages($(this).attr("href"), "auto_pay_report", 80, 80);
    return false;
} );
window.onresize = function(){
    jQuery("div.dataTables_scrollBody").height(Math.floor(jQuery(window).height()) - 220);
    myDataGrid.fixedHeader.adjust();
    myDataGrid.columns.adjust();
};
function export_to_csv() {
    jQuery('input[name=csv_file_name]').val( "auto_pay_report_"
                                             + Math.random().toString(36).slice(2)    // append an arbitrary unique substring
                                             + ".csv" );
    jQuery("#csv_text").val( jQuery('table#tAutoReport').table2CSV() );
    jQuery("#csv_form").submit();
};
/*
function lock_auto_pay( lock_request ) {
    jQuery.ajax({
          url:"/components/Billback/BBAutoReportUpdate.cfc",
          data: {
            method: "lock_auto_pay",
            userId: "<cfoutput>#request.AccessStructure.User_id#</cfoutput>",
            lock: lock_request
          },
          success: function(data) {
				var url_redirect_Path = "/billbacks/Auto_BB_Report/BB_Auto_Report_View.cfm?showSearchForm=1";
				location.href = url_redirect_Path;
          },
          error: function() {
          }
    });
}*/

<cfif request.auto_pay.lock.processing>
    /*refresh page every minute unless someone presses a key or mouse a mouse*/
     var time = new Date().getTime();
     jQuery(document.body).bind("mousemove keypress", function(e) {
         time = new Date().getTime();
     });

     function refresh_page() {
         if(new Date().getTime() - time >= 60000) {
            location.href = location.href;
         }
         else{
             setTimeout(refresh_page, 10000);
		}
     }

     setTimeout(refresh_page, 10000);
</cfif>
$( "#AutoPaySearch" ).click(function() {
  $( "#AutoPaySearchForm" ).toggle();
  var el = $(this);
  if (el.text() == el.data("text-swap")) {
    el.text(el.data("text-original"));
  } else {
    el.data("text-original", el.text());
    el.text(el.data("text-swap"));
  }
});
$("#autopay_status").multiselect();

$( "#trigger" ).live({
  mouseover: function() {
    $( '.'+this.name ).show();
  },
  mouseout: function() {
    $( '.'+this.name ).hide();
  }
});
</script>
</cfmodule>