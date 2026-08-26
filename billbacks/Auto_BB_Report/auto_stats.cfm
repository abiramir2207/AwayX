<!---------------------------------------------------------------------------------------------------------------------
      File Name:  \billbacks\Auto_BB_Report\auto_stats.cfm
   Created Date:  2016 April
         Author:  Chris Nguyen
        Purpose:  Display auto pay summary auto stats WR 48219

        Remarks:
----------------------------------------------------------------------------------------------------------------------->
    <cfsavecontent variable="variables.uncompressed">
        <cfparam name="form.program_number" default="">
        <cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css"/>
        <style>
            form[name=search], form[name=csv] {
                margin: 0;
                padding: 0;
            }
            #search_criteria {
				padding:10px;
                text-align: left;
                width: 89.95%;
            }
            a.search {
                margin: 0 0 0 25px;
            }
            .label {
                font-weight: bold;
                letter-spacing: 0.5px;
                margin-right: 10px;
            }
            #data_table {
                width: 60%;
                padding:10px;
            }
            #data_table th {
                vertical-align: top;
            }
            .lg {
                width: 24.90%;
            }
            .med {
                width: 17.5%;
            }
            .left {
                text-align: left !important;
            }
            .right {
                text-align: right !important;
            }
            tr.header {
                height: 23px;
            }
            tr.row {
                height: 17px;
            }
            div.dataTables_scrollHeadInner {
                padding-left: 0px !important;
            }
            tr.group2 {
                background-color: #ccffcc;
                height: 19px;
            }
            td.group2 {
                font-weight: bold;
                letter-spacing: 0.25px;
            }
            .indent_left {
                padding-left: 10px !important;
            }
        </style>

        <cfoutput>
        <!--- gather current auto pay & prior 12 months for selected program --->
        <cfquery name="variables.stats" datasource="#application.datasource#">
            SELECT  Contract_Main.Contract_Number
                   ,BB_Auto_Program_Pay_Period.Payment_Start_Date
                   ,BB_Auto_Program_Pay_Period.Payment_End_Date
                   ,Contract_Main.Contract_Title
                   ,Contract_Main.Contract_Start_Date
                   ,Contract_Main.Contract_End_Date
                   ,Sum(BB_Approved.Paid_Amount) AS Autopay_Amount
                   ,IsNull(Sum(BB_Approved.Pullback_applied_Amount), 0) AS Recapture_Amount
                   ,BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID
            FROM    Contract_Main
            INNER JOIN BB_Auto_Program_Pay_Period
                    ON BB_Auto_Program_Pay_Period.Program_ID = Contract_Main.Contract_Main_ID
                       AND BB_Auto_Program_Pay_Period.Deleted = 0
            INNER JOIN BB_Auto_Pay_Period_Billback
                    ON BB_Auto_Pay_Period_Billback.BB_Auto_Program_Pay_Period_Id = BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID
            INNER JOIN Billback
                    ON Billback.Billback_ID = BB_Auto_Pay_Period_Billback.Billback_Id
                       AND Billback.Deleted = 0
            INNER JOIN BB_Approved
                    ON BB_Approved.Billback_ID = Billback.Billback_ID
            WHERE   <cfif form.program_number eq ''>
                        1 = 0
                    <cfelse>
                        Contract_Main.Contract_Number LIKE <cfqueryparam value="%#trim(form.program_number)#%">
                    </cfif>
                    AND CAST(BB_Auto_Program_Pay_Period.Payment_End_Date AS DATE) >= CAST(DateAdd(month, -12, GetDate()) AS DATE)
                    AND CAST(BB_Auto_Program_Pay_Period.Payment_End_Date AS DATE) <= CAST(GetDate() AS DATE)
            GROUP BY Contract_Main.Contract_Number
                   ,BB_Auto_Program_Pay_Period.Payment_Start_Date
                   ,BB_Auto_Program_Pay_Period.Payment_End_Date
                   ,Contract_Main.Contract_Title
                   ,Contract_Main.Contract_Start_Date
                   ,Contract_Main.Contract_End_Date
                   ,BB_Auto_Program_Pay_Period.BB_Auto_Program_Pay_Period_ID
            ORDER BY Contract_Main.Contract_Number, BB_Auto_Program_Pay_Period.Payment_End_Date DESC
        </cfquery>

        <div id="search_criteria">
            <form name="search" method="post">
                <label class="label" for="program_number">#application.returned_customer_setting.Program_Number_Label#:</label>
                <input type="text" name="program_number" id="program_number" value="#form.program_number#">
                <a href="##" class="search" onclick="search_data()">#application.util.string.actionLinkFormat2( "search" )#</a>
                <cfif form.program_number neq "">
                    <a href="##" class="search" onclick="export_to_csv()">#application.util.string.actionLinkFormat2( "export" )#</a>
                </cfif>
            </form>  <!--- name="search" --->
            <!--- export to csv form --->
            <form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
                <input type="hidden" name="csv_text" id="csv_text">
                <input type="hidden" name="csv_file_name">
            </form>
        </div>       <!--- id="search_criteria" --->

		<div id="data_table">
        <table id="stat_table" class="datagrid">
            <thead>
                <tr class="header">
                    <!--- <th class="lg">Program Number</th> --->
                    <th class="lg left" colspan="4">#application.returned_customer_setting.Program_Number_Label# | Title | Start/End Date Range</th>
                </tr>
                <tr class="header">
                    <th class="lg left"> * Auto Pay Start Date</th>
                    <th class="lg left">Auto Pay End Date</th>
                    <th class="lg right">Amount</th>
                    <th class="lg right">Recapture</th>
                </tr>
            </thead>
            <tbody>
                <cfset variables.grid_data = []>
                <!--- program number input is blank - display empty rows --->
                <cfif form.program_number eq ''>
                    <cfloop from="1" to="10" index="variables.counter">
                        <tr class="row">
                            <!--- <td>&nbsp;</td> --->
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                        </tr>
                    </cfloop>
                <cfelse>
                    <cfloop query="variables.stats">
                        <cfset arrayAppend(variables.grid_data, [  "* " & dateFormat(variables.stats.Payment_Start_Date, "mmm d, yyyy")
                                                                  ,dateFormat(variables.stats.Payment_End_Date, "mmm d, yyyy")
                                                                  ,'<a href="javascript:void()" OnClick="popupCenterByPercentages(''/billbacks/Auto_BB_Report/auto_stats_billback_list.cfm?BBAutoProgramPayPeriodID=#BB_Auto_Program_Pay_Period_ID#'',''bbList'',''80'',''80'',''Yes'', ''Yes'')" return false;>' & dollarFormat(variables.stats.Autopay_amount) &'</a>'
                                                                  ,dollarFormat(variables.stats.Recapture_amount)
                                                                  <!--- hidden column, used as a group by --->
                                                                  ,variables.stats.contract_number & " &nbsp;| &nbsp;" & variables.stats.contract_title & " &nbsp;| &nbsp;" & application.util.datetime.dateSpanFormat(variables.stats.contract_start_date, variables.stats.contract_end_date, "mmm")
                                                                ])>
                    </cfloop>
                </cfif>    <!--- form.program_number eq '' --->
            </tbody>
        </table>
        </div>   <!--- id="data_table"> --->
        </cfoutput>

        <cfinclude template="/common_files/jQuery.cfm">
        <cfinclude template="/common_files/dataTables2.cfm">
        <cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/table2csv.js, /script/javascript/jquery.noty.packaged.min.js"/>

        <script>
        <cfif form.program_number neq ''>
            var myDataGrid = jQuery('table.datagrid').DataTable({
                                  "autoWidth": false
                                  ,"columns": [  {"orderable":false,  "searchable":false, "className": 'indent_left'  }
                                                ,{"orderable":false,  "searchable":false, "className": '' }
                                                ,{"orderable":false,  "searchable":false, "className": 'right' }
                                                ,{"orderable":false,  "searchable":false, "className": 'right' }
                                                ,{"orderable":false,  "searchable":true, "visible":false }
                                                ]
                                  ,data: <cfoutput>#serializeJSON(variables.grid_data)#</cfoutput>
                                  ,"dom": "t"
                                  ,"language": { "search": "Find" }
                                  ,"paging": false
                                  ,"order": []
                                  ,"orderClasses": false
                                  ,"scrollCollapse": true
                                  ,"scrollY": Math.floor(jQuery(window).height()) - 175
                                  ,"sScrollXInner": "100%"

                                   /* add group row */
                                  ,"drawCallback": function ( settings ) {
                                    var api = this.api();
                                    var rows = api.rows( {page:'current'} ).nodes();
                                    var last=null;
                                    /* group by is based on hidden column #5 */
                                    api.column(4, {page:'current'} ).data().each( function ( group, i ) {
                                        if ( last !== group ) {
                                            $(rows).eq( i ).before(
                                                '<tr class="group2"><td colspan="4" class="group2">'+group+'</td></tr>'
                                            );
                                            last = group;
                                        }
                                    } );
                                    }
                                });
            jQuery('table.datagrid tr[class!=group2]').hover(function() { jQuery(this).toggleClass("over"); } );
        </cfif>
        function search_data() {
            if (!jQuery("#program_number").val()) {
                alert( <cfoutput>"Please enter a #application.returned_customer_setting.Program_Number_Label#."</cfoutput> );
                return false;
            }
            please_wait( "Searching for information, please wait..." );
            jQuery("form[name=search]").submit();
        };
        function please_wait( msg ) {
            noty( {    text: msg
                    ,layout: 'bottom'
                      ,type: 'information'
                    ,killer: true
                  });
            /* disable onclick event on a tags */
            jQuery("#search_criteria a").prop("onclick", null);
        };
        function export_to_csv() {
            jQuery('input[name=csv_file_name]').val( "auto_stats_"
                                                     + Math.random().toString(36).slice(2)
                                                     + ".csv" );
            jQuery("#csv_text").val( jQuery('#stat_table').table2CSV() );
            jQuery("#csv_form").submit();
        };
        </script>
    </cfsavecontent>

    <cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>