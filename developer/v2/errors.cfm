<cfprocessingdirective pageencoding="utf-8">
<!--- <cfset cookie.refresh_time = 999> --->
<!--- prevent ridiculous refresh times (e.g. under 9 seconds) --->
<cfset MIN_REFRESH_TIME = 15>
<!--- default to auto refresh in 1,800 seconds (30 mins) --->
<cfparam name="cookie.refresh_time" default="1800">
<cfif structKeyExists(url, "refresh_time") and isNumeric(url.refresh_time)>
    <!--- save custom auto refresh time for future visits --->
    <cfset cookie.refresh_time = max(MIN_REFRESH_TIME, url.refresh_time)>
</cfif>
<!--- retrieve previous custom auto refresh time --->
<cfset url.refresh_time = max(MIN_REFRESH_TIME, cookie.refresh_time)>

<!---
  * ====================================================================================================
  *    @File: \developer\v2\errors.cfm
  *  @Author: Chris Nguyen
  *    @Date: April 2020
  *
  * @Remarks: Display event error reports
  *
  * ====================================================================================================
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Errors @ <cfoutput>#replaceNoCase( replaceNoCase(cgi.SERVER_NAME, ".com", ''), "stage.awayx", "stage" )#</cfoutput></title>
    <!--- auto refresh in miliseconds --->
    <cfoutput><meta http-equiv="refresh" content="#url.refresh_time#"></cfoutput>
</head>
<body>
    <cfmodule template="/customTags/include.cfm" files="/common_files/main_style.css, default.css">

    <style>
        body {
            display: flex;
        }
        section#sidebar {
            width: 275px;
            /* height: 96.5vh; */
            /* min-height: 96.5vh; */
            height: 100vh;
            min-height: 100vh;
        }
        section#ag-grid {
            /* overflow: hidden; */
        }
        iframe.report {
            background-color: #F9F9F9;
            height: 100vh;
            flex-grow: 1;
        }
        button.refresh {
            margin-top: 10px;
        }
        label.refresh {
            color: white;
            position: relative;
            top: -1px;
        }
        .hamburger {
            width: 30px;
            height: 100vh;
            min-height: 100vh;
            background-color: white;
            border-right: 1px solid #ccc;
        }
        button#btn, button#toggle {
            font-size: 1rem;
            padding: 3px;
            margin: 5px 1px 1px 3px;
            cursor: pointer;
        }
        span.vertical {
            cursor: pointer;
            font-size: 0.8rem;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
            padding: 10px 7px;
            letter-spacing: 1px;
            writing-mode: vertical-lr;
            user-select: none;
            transform: rotate(180deg);
        }
        .yesterday {
            background-color: #F0F8FF !important;
        }
        .monday, .odd {
            background-color: #FAEBD7 !important;
        }
        .tuesday {
            background-color: #F8F8FF !important;
        }
        .wednesday {
            background-color: #7FFFD4 !important;
        }
        .thursday {
            background-color: #F0FFFF !important;
        }
        .friday {
            background-color: #F5F5DC !important;
        }
        .saturday {
            background-color: #FFF8DC !important;
        }
        .today {
            background-color: #FFFAF0 !important;
        }
    </style>

    <section class="hamburger">
        <button id="btn">↻</button>
        <span class="vertical refresh">Refresh &nbsp; Errors</span>
        <button id="toggle">☰</button>
        <span class="vertical toggle">Toggle &nbsp; List</span>
    </section>

    <section id="sidebar">
        <cfset list_errors()>
    </section>

    <iframe name="report" class="report" frameborder="0"></iframe>

    <script>
        var rowNode = gridOptions.api.getDisplayedRowAtIndex(0);
        $("iframe.report").attr("src", "/scheduled//getDocument.cfm?filepath=/common_documents/Data_Files/Created/error_files/" + rowNode.data[0]);

        $("button.refresh").click(function(){
            window.location = "errors.cfm?refresh_time=" + $("input[name=refresh_time]").val();
        });
    </script>
</body>
</html>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!---  display errors on left side bar ~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="list_errors">
    <cfscript>
        qErrors = directoryList(expandPath("/common_documents/Data_Files/Created/error_files"), false, "query", "error_*.htm", "DateLastModified DESC");

        for (counter=1; counter <= qErrors.recordCount; counter++) {
            last_modified = listFirst(qErrors.DateLastModified[counter], ' ');
            day_diff      = dateDiff('d', last_modified, now());
            time_portion  = listGetAt(qErrors.DateLastModified[counter], 2, ' ') & ' ' & listGetAt(qErrors.DateLastModified[counter], 3, ' ');

            day_replacement = (day_diff eq 0)
                                ? "Today"
                                : (day_diff eq 1)
                                    ? "Yesterday "
                                    : (day_diff lt 7)
                                        ? DayOfWeekAsString(dayOfWeek( last_modified ))
                                        : '';
            if (len(day_replacement)) {
                qErrors.DateLastModified[counter] = day_replacement & '' &  dateFormat(last_modified, "mmm d") & ' ' & time_portion;
            }
        }

        request.ag_grid_theme = "ag-theme-balham";
    </cfscript>

    <section id="ag-grid" class="ag-theme-balham">
    </section>
    <cfmodule template="/customTags/include.cfm" files="/developer/default.js">
    <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
    <cfinclude template="ag-grid.cfm">

    <cfset MAX_ERRORS = 99>
    <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/css-loader.css">

    <script>
        let errors = <cfoutput>#serializeJSON(qErrors)#</cfoutput>;

        function get_day_of_week( param ) {
            var event_day = param.replace('day', 'day ').split(" ");
            return event_day[0];
        }

        let gridOptions = {
            defaultColDef: {     editable:        false
                                ,suppressMenu:    true
                                ,suppressMovable: true
                                ,unSortIcon:      false
                                ,sortable:        false
                                ,resizable:       false
                                ,filter:          false
                            }
            ,columnDefs: [
                            { headerName:'Error',
                                type:'numericColumn',
                                width: 65,
                                filter: 'agTextColumnFilter',
                                sortable: false,
                                floatingFilterComponentParams: {suppressFilterButton:true},
                                valueGetter:function(p){ return p.data[0].replace("error_", "").replace(".htm", "") }
                            }
                            ,{ headerName:'When', valueGetter:function(p){ return p.data[3].replace('day', 'day ') }, filter: false}
            ]
            ,rowData: errors.DATA
            ,rowClassRules: {
                                'today': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Today';
                                                    }
                                ,'yesterday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Yesterday';
                                                    }
                                ,'monday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Monday';
                                                    }
                                ,'tuesday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Tuesday';
                                                    }
                                ,'wednesday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Wednesday';
                                                    }
                                ,'thursday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Thursday';
                                                    }
                                ,'friday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Friday';
                                                    }
                                ,'saturday': function(params) {
                                                        return get_day_of_week( params.data[3] ) === 'Saturday';
                                                    }
                                ,'odd': function(params) {
                                                        var day_of_week = get_day_of_week( params.data[3] );
                                                        if (day_of_week.indexOf('day') == -1) {
                                                            var day_of_month = params.data[3].split(" ");
                                                            return ((day_of_month[1] % 2) !== 0);
                                                        }
                                                    }
                            }
            ,rowModelType: "clientSide"
            ,floatingFilter: true
            ,onCellClicked: function(event) { $("iframe.report").attr("src", "/scheduled/getDocument.cfm?filePath=/common_documents/Data_Files/Created/error_files/" + event.node.data[0]) }
        };

        ag_grid_default( gridOptions );
        init_ag_grid( gridOptions, "#ag-grid" );
        gridOptions.api.sizeColumnsToFit();

        $("#btn, span.refresh").click(function(){
            show_loader();
            window.location.reload();
        });

        $("#toggle, span.toggle").click(function(){
            $("#sidebar").toggle();
        });
    </script>
</cffunction>