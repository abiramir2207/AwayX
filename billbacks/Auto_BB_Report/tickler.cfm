<!---------------------------------------------------------------------------------------------------------------------
		File Name:  \billbacks\Auto_BB_Report\tickler.cfm
		Created Date:	April 2016 
		Author:  Chris Nguyen
		Purpose:  Display auto pay tickler WR 48219

		Modification: We do not need to show all the pay periods, as the query will be slow.
		Modification Date:	March 2017
		Author: Milan Mushran
----------------------------------------------------------------------------------------------------------------------->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />

	<cfsavecontent variable="variables.uncompressed">
        <cfparam name="form.select_date1" default="">
        <cfparam name="form.select_date2" default="#dateFormat(now(),'m/d/yyyy')#">
		<cfparam name="form.select_year" default="0">
        <cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css"/>
        <style>
            form[name=searchFrm], form[name=csv] {
                margin: 0;
                padding: 0;
            }
            #search_criteria {
                padding:10px;
                text-align: left;
                width: 90.95%;
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
            .lg {
                width: 24.90%;
            }
            .med {
                width: 17.5%;
            }
            .right {
                text-align: right;
            }
            tr.header {
                height: 23px;
            }
            tr.row {
                height: 17px;
            }
            .indent_left {
                padding-left: 10px !important;
            }
            .datagrid th {
                text-align: left;
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
                padding-left: 15px;
            }
        </style>
 
		<cfquery name="FYDates" datasource="#application.datasource#">
			SELECT Min(fy.Start_Date) as FY_Year_Start, Max(fy.End_Date) as FY_Year_End
			FROM   Fiscal_Year fy
			WHERE  fy.Deleted = 0
			AND		Replace(fy. Fiscal_Year, 'FY_', '') =  '#form.select_year#'			
		</cfquery>
		
		<!--- Fiscal date OR Calendar date --->
		<cfif FYDates.recordcount eq 0>
			<cfset search_Start_Date = '1/1/#form.select_year#'>
			<cfset search_End_Date = '12/31/#form.select_year#'>
		<cfelse>
			<cfset search_Start_Date = '#FYDates.FY_Year_Start#'>
			<cfset search_End_Date = '#FYDates.FY_Year_End#'>
		</cfif>

		<cfset qGetOpenPayPeriods = oBBReportGet.getOpenPayPeriods(search_Start_Date,search_End_Date)>

		 <cfoutput>
        <div id="search_criteria">
            <form name="searchFrm" method="post" id="searchFrm">

                <label class="label" for="select_year1">Select a year :</label>
				<select name="select_year" id="select_year">
					<option value="0">Select a year</option>
					<cfloop from="#year(now())#" to="#year(now())-5#" index="year" step="-1">
					<option value="#year#" <cfif form.select_year eq year>selected</cfif>>#year#</option>
					</cfloop>
				</select>

                <a href="##" class="search" onclick="search_data()">#application.util.string.actionLinkFormat2( "search" )#</a>
                <cfif form.select_year neq 0>
                    <a href="##" class="search" onclick="exportAll()">#application.util.string.actionLinkFormat2( "export" )#</a>
                </cfif>
            </form>  <!--- name="search" --->
            <!--- export to csv form 
            <form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
                <input type="hidden" name="csv_text" id="csv_text">
                <input type="hidden" name="csv_file_name">
            </form>--->
        </div>       <!--- id="search_criteria" --->
        <div id="data_table">
        <table id="stat_table" class="datagrid">
            <thead>
                <tr class="header">
                    <th>
						#(application.returned_customer_setting.Program_Number_Label)# &nbsp;|&nbsp; Title &nbsp;|&nbsp; Start/End Date &nbsp;|&nbsp; Time Frame
					</th>
                </tr>
            </thead>
            <tbody>
                <cfset variables.grid_data = []>
                <!--- date range input is blank - display empty rows --->
                <cfif form.select_year neq 0>
                    <cfloop query="qGetOpenPayPeriods">
						<cfset pgNumber = "<A onClick='javaScript: NewWindow(this.href , 'Program_View' , 815 , 650 , 'yes' , 'yes'); return false;' target='_blank' HREF='/CID_Wrapper.cfm?Program_ID=#qGetOpenPayPeriods.contract_main_id#&Page_Relocate=/scorecard/program_display.cfm'  STYLE='FONT-SIZE:10PX;' TITLE='View the details for program #qGetOpenPayPeriods.Contract_Number#'>
								#qGetOpenPayPeriods.contract_number#
						</A>">
                         <cfset arrayAppend(variables.grid_data, [pgNumber & " &nbsp;|&nbsp; " & qGetOpenPayPeriods.contract_title & " &nbsp;|&nbsp; " & application.util.datetime.dateSpanFormat(qGetOpenPayPeriods.Effective_Start_Date, qGetOpenPayPeriods.Effective_End_Date, "mmm") & " &nbsp;|&nbsp; " & application.util.datetime.dateSpanFormat(qGetOpenPayPeriods.start_date, qGetOpenPayPeriods.end_date, "mmm")])>							  
                    </cfloop>
                </cfif>    <!--- form.select_date1 eq '' --->
            </tbody>
        </table>
        </div>   <!--- id="data_table"> --->
        </cfoutput>

        <cfinclude template="/common_files/jQuery.cfm">
        <cfinclude template="/common_files/dataTables2.cfm">
        <cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/table2csv.js, /styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js, /script/javascript/jquery.noty.packaged.min.js"/>

        <script>
        <cfif form.select_year neq 0>
            var myDataGrid = jQuery('table.datagrid').DataTable({
                                  "autoWidth": false
                                  ,"columns": [  {"orderable":false, "searchable":true, "className": 'indent_left'  } ]
                                  ,data: <cfoutput>#serializeJSON(variables.grid_data)#</cfoutput>
                                  ,"dom": "ft"
                                  ,"language": { "search": "Find program:" }
                                  ,"paging": false
                                  ,"order": []
                                  ,"orderClasses": false 
                                  ,"scrollCollapse": true
                                  ,"scrollY": Math.floor(jQuery(window).height()) - 205
                                  ,"sScrollXInner": "100%"

                                   /* add group row */
                                  ,"drawCallback": function ( settings ) {
                                    var api = this.api();
                                    var rows = api.rows( {page:'current'} ).nodes();
                                    var last=null;
                                    /* group by is based on hidden column #2 */
                                    api.column(1, {page:'current'} ).data().each( function ( group, i ) {
                                        if ( last !== group ) {
                                            $(rows).eq( i ).before(
                                                '<tr class="group2"><td colspan="1" class="group2">'+group+'</td></tr>'
                                            );
                                            last = group;
                                        }
                                    } );
                                    }
                                });
            jQuery('table.datagrid tr[class!=group2]').hover(function() { jQuery(this).toggleClass("over"); } );
        </cfif>
        function search_data() { 
           if (jQuery("#select_year").val() == 0) {
                alert( "Please select a year to search for." );
                jQuery("#select_year1").focus();
                return false;
            }
            please_wait( "Searching for information, please wait..." );
            jQuery("#searchFrm").submit();
        };
        function please_wait( msg ) {
            noty( {  text: msg
                    	,layout: 'bottom'
                      	,type: 'information'
                    	,killer: true
                  });
            /* disable onclick event on a tags */
            jQuery("#search_criteria a").prop("onclick", null);
        };
		function exportAll()
		{
		window.open( "/Common_Files/exportAll.cfm?" + "type=getOpenPayPeriods"
									+ "&search_Start_Date=<cfoutput>#search_Start_Date#</cfoutput>"
									+ "&search_End_Date=<cfoutput>#search_End_Date#</cfoutput>"
									+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('OpenPayPeriods_')#</cfoutput>"

			,"_blank"
			,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
		}
        </script>
    </cfsavecontent>

    <cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>