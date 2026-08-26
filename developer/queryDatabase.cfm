<!---
  * ==================================================================================================== 
  *    @File: /developer/queryDatabase.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019-03-07 13:17:54
  * 
  * @Remarks: Development tool executes a db query and display the query result  
  *
  * ==================================================================================================== 
--->
<!DOCTYPE html>
<html>
<head>
    <title>Query Database | Developer Tools</title>
    
	<cfsavecontent variable="head_content">
	<link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/styles/tailwind/0.7/tailwind.min.css?v=080654236"> 
    <style>
        body { overflow: hidden; }
        * { box-sizing: border-box; }
		p { font-size:13px; }
		#query { display:block; font-family:"Lucida Console", "Arial"; font-size:11px; width:99%; height:14vh; margin:0 0.45%; }
	</style>
    </cfsavecontent>
    
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#head_content#">
    <cfinclude template="/common_files/jQuery.cfm">
        
</head>
<body>
    <!--- query parameter may be passed in the URL --->
    <cfif structKeyExists(url, "query") and !structKeyExists(form, "query")>
        <cfset form.query = url.query>
    </cfif>

    <cfparam name="form.query" default="">
    <!--- <div style="margin:1vh 5px;height:5vh;" class="flex items-center bg-blue-lightest text-blue-dark text-sm font-bold border-t border-b border-blue px-4 py-3" role="alert">
        <svg class="fill-current w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.432 0c1.34 0 2.01.912 2.01 1.957 0 1.305-1.164 2.512-2.679 2.512-1.269 0-2.009-.75-1.974-1.99C9.789 1.436 10.67 0 12.432 0zM8.309 20c-1.058 0-1.833-.652-1.093-3.524l1.214-5.092c.211-.814.246-1.141 0-1.141-.317 0-1.689.562-2.502 1.117l-.528-.88c2.572-2.186 5.531-3.467 6.801-3.467 1.057 0 1.233 1.273.705 3.23l-1.391 5.352c-.246.945-.141 1.271.106 1.271.317 0 1.357-.392 2.379-1.207l.6.814C12.098 19.02 9.365 20 8.309 20z"/></svg>
        <p class="opacity-100">Enter your SQL statements into this box below and click f5 to view the result.</p>
    </div> --->

    <div style="margin:1vh auto;width:99%;height:5vh;" class="flex items-center bg-blue text-white text-sm font-bold px-4 py-3" role="alert">
        <svg class="fill-current w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M12.432 0c1.34 0 2.01.912 2.01 1.957 0 1.305-1.164 2.512-2.679 2.512-1.269 0-2.009-.75-1.974-1.99C9.789 1.436 10.67 0 12.432 0zM8.309 20c-1.058 0-1.833-.652-1.093-3.524l1.214-5.092c.211-.814.246-1.141 0-1.141-.317 0-1.689.562-2.502 1.117l-.528-.88c2.572-2.186 5.531-3.467 6.801-3.467 1.057 0 1.233 1.273.705 3.23l-1.391 5.352c-.246.945-.141 1.271.106 1.271.317 0 1.357-.392 2.379-1.207l.6.814C12.098 19.02 9.365 20 8.309 20z"/></svg>
        <p class="opacity-75">Enter your SQL statements into this box below and click f5 to view the result.</p>
    </div>
    
    <div style="height:20vh;margin:0;padding:0;">
        <form method="post" id="querydatabase">
            <cfoutput><textarea name="query" id="query" class="border">#form.query#</textarea></cfoutput><br>
            <button class="button primary" style="margin:0 0.9%" id="execute_sql">execute (f5)</button>
            <button class="button secondary" onclick="window.open('https://www.freeformatter.com/sql-formatter.html', '_blank')">sql formattter</button>
            <button class="button secondary" onclick="resetQuery()">reset</button>
            <button class="button secondary" onclick="window.close()">close</button>
        </form>
    </div>
    
    <cfscript>
        adminObj = createObject("component", "cfide.adminapi.administrator");
        cf_admin = application.util.query.cf_admin();
        adminObj.login( cf_admin.password, cf_admin.username );
        datasource        = createObject("component", "cfide.adminapi.datasource");
        server.datasource = datasource.getDatasources( application.datasource );
        db_host = len(server.datasource.host) 
                                ? server.datasource.host 
                                : replaceNocase(server.datasource.url, 'jdbc:macromedia:sqlserver:', '');
        avoid_keywords    = application.util.io.isProduction()          // detect production by url
                                    or db_host contains "prod"          // dbprod*
                                    or db_host contains "occ00db"       // Simplot
                                    or db_host contains "cagdb"         // Conagra
                                ? [
                                            "ADD"
                                        , "ALTER"
                                        , "BACKUP"
                                        , "CHECK"
                                        , "COLUMN"
                                        , "COMMIT"
                                        , "DROP"
                                        , "CREATE"
                                        , "DELETE"
                                        , "EXEC"
                                        , "EXECUTE"
                                        , "GRANT"
                                        , "INSERT"
                                        , "ROLLBACK"
                                        , "TRAN"
                                        , "TRANSACTION"
                                        , "TRUNCATE"
                                        , "UPDATE"
                                    ]
                                : [];           // development or stage do not restrict anything
        query_failure = false;
    </cfscript>

    <!--- do not allow operations that change db schema/content in production --->
    <cfif form.query neq ''>
        <cfloop from="1" to="#arrayLen(avoid_keywords)#" index="keyword_counter">
            <cfif FindNoCase(avoid_keywords[keyword_counter] & ' ', form.query) 
                or FindNoCase(avoid_keywords[keyword_counter] & chr(13) & chr(10), form.query)>
                <p>Sorry! Your database query is not permitted.</p>
                <cfset query_failure = true>
            </cfif>
        </cfloop>
    </cfif>

    <cfif !query_failure and form.query neq ''>
        <cftry>
            <cfset max_rows = val(application.util.query.get_setting("queryDatabase_maxrows", 0))>
            <cfset max_rows = max_rows eq 0 ? 5000 : max_rows>
            <cfset max_rows = 1>
            <cfquery name="qData" datasource="#application.datasource#" maxrows="#max_rows#">
                #PreserveSingleQuotes(FORM.query)#
            </cfquery>
            <cfcatch>
                <cfset query_failure = true>
                <cfoutput>
                <p style="color:red"><b>#cfcatch.message#</b> - #replaceNoCase(cfcatch.Detail, "[Macromedia][SQLServer JDBC Driver][SQLServer]", '', "all")#</p>
                </cfoutput>
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfif !query_failure and form.query neq ''>
        <cfscript>
            columns                 = [];
        </cfscript>
        

        <cfif !isDefined("qData")>
            <p class="result" style="width:99%;margin:0 auto;">Done.</p>
        <cfelse>
            <cfset all_caps = [ 
                                 "bb"
                                ,"bsa"
                                ,"cp"
                                ,"cs"
                                ,"dd"
                                ,"forge"
                                ,"id"
                                ,"idx"
                                ,"lb"
                                ,"lbs"
                                ,"ldap"
                                ,"rfa"
                                ,"os"
                                ,"sp"
                                ,"upc"
                                ,"usda"
                                ,"wip"
                            ]>
            <cfset aColumns = qData.getColumnList()>
            <cfloop from="1" to="#arrayLen(aColumns)#" index="counter">
                <cfscript>
                    column = aColumns[counter];
                    // parse elements in the name separated by underscore character into an array
                    elements = listToArray(column, '_');
                    for (i=1; i lte arrayLen(elements); i++) {
                        if (arrayFindNoCase(all_caps, elements[i]))
                            elements[i] = ucase(elements[i]);
                        else    
                            // capitalize the first letter and lowercase the rest
                            elements[i] = ucase(left(elements[i],1)) & lcase(Mid(elements[i], 2, len(elements[i])-1));
                    }
                    // combine all elements back
                    headerName = arrayToList(elements, "_");
                    arrayAppend(columns, '{headerName:"#headerName#"' 
                                            & (counter eq 1 ? ',pinned:"left", suppressToolPanel:true' : '') 
                                            & ',valueGetter:function(p){return p.data[' & (counter - 1) & ']}}') ;
                </cfscript>
            </cfloop>
            <div style="height:2vh;width:99%;margin:0 auto 15px auto;padding:0;">
                <input type="text" id="filter-text-box" class="shadow appearance-none border rounded w-1/4 py-1 px-3 text-grey-darker leading-tight focus:outline-none focus:shadow-outline" placeholder="Filter..." oninput="onFilterTextBoxChanged()">
                <button class="button secondary" onclick="clearfilters();">clear filters</button>
                <button class="button secondary" onclick="onBtExport()" >export</button>
            </div>
            <div id="aggrid" style="width:99%;margin:0 auto;padding:0;" class="ag-theme-balham"></div>   

            <!--- <div id="actions" style="height:7vh;margin:0;padding:0;"></div> --->
            <!--- <div style="clear:both;"></div> --->

            <cfinclude template="/common_files/ag-grid.cfm">
            <cf_include files="/script/javascript/default.js">
            <cfset compressed_query = application.util.string.compress(FORM.query)>

            <style>
                /* restore sidebar buttons panel */
                div.ag-side-buttons {
                    display: block;
                }
            </style>
            <script>
                "use strict";

                set_grid_full_height("aggrid");
                function onFilterTextBoxChanged() {
                    gridoptions.api.setQuickFilter(document.getElementById('filter-text-box').value);
                }        

                let gridoptions = {
                                    columnDefs: [<cfoutput>#arrayToList(columns)#</cfoutput>]
                                    , floatingFilter: true
                                    , onFirstDataRendered: function() { autoSizeAllColumns(gridoptions) }
                                    , pagination: false
                                    , paginationPageSize: 500
                                    // , rowData: <cfoutput>#application.util.query.toDtJSON(qData, arrayToList(aColumns))#</cfoutput>
                                    , rowModelType: "clientSide"
                                    , sideBar: sidebar()
                                    , suppressRowClickSelection: false
                                    , suppressContextMenu: false
                                    , statusBar: footerbar("filtered_and_total")
                                };

                ag_grid_default(gridoptions);     // set up default features
                gridoptions.defaultColDef.suppressMenu = true;
                init_ag_grid( gridoptions, "#aggrid", false );  

                $.ajax({
                    url: "/developer/ajax/queryDatabase.cfm"
                    ,data: { returnFormat: "json", sql: <cfoutput>"#PreserveSingleQuotes(FORM.query)#"</cfoutput> }
                    ,success: function( result ) {
                                                    if (typeof result === 'string') { 
                                                        result = JSON.parse(result); 
                                                    }
                                                    gridoptions.api.setRowData( result.ROWS );
                                                }
                    ,type: "POST"
                    ,error: function(xhr, status, error) { error_handler(arguments) }
                });

                // adjust columns to fit when window is resized
                $(window).resize(function(){
                    set_grid_full_height("aggrid");
                    // gridoptions.api.sizeColumnsToFit();
                    // resize_all_columns();
                    autoSizeAllColumns(gridoptions);
                });

                // gridoptions.api.closeToolPanel();

                function clearfilters() {
                    gridoptions.api.setFilterModel(null);
                    gridoptions.api.onFilterChanged();
                    $("#filter-text-box").val('');
                    onFilterTextBoxChanged();
                };
                
                function onBtExport() {
                    gridoptions.api.exportDataAsExcel();
                };
            </script>           
        </cfif>
    </cfif>

    <!--- <script src="https://cdn.awayx.com/base/script/javascript/ajax_js/jquery-1.7.2-min.js?v=0153530" ></script>  --->

    <script>
        $("#execute_sql").click(function() {
            execute_sql();
        });

		function execute_sql() {
			let q = document.getElementById("query");
			if (q.value !== '') {
                $("#execute_sql").text("executing, please wait...");
                $("#aggrid, .result, #actions, #filter-text-box").fadeOut(1000);
                $("form#querydatabase").submit();
			}
		}

		function resetQuery() {
			document.getElementById("query").value = '';
        }
        
        document.onkeydown = function() {
            switch (event.keyCode) {
                case 116 : //F5 button
                    event.returnValue = false;
                    event.keyCode = 0;
                    execute_sql();
                    return false;
                case 82 : //R button
                    if (event.ctrlKey) {
                        return true;
                    }
            }
        }

        function get_col_ids() {
            let containers = [  "div.ag-pinned-left-header", "div.ag-header-container" ];
            for (let y = 0; y < containers.length; y++) {
                let ag_header_container = $(containers[y] + " div.ag-header-row");
                let col_ids = [];
                // find all col-id attributes in the first line of header & save them into an array
                $(ag_header_container[0]).find("div[col-id]").each(function(){ 
                    col_ids.push( $(this).attr("col-id"));
                });

                let i = 0;
                // assign col-id attribute to floating filter input element
                $(ag_header_container[1]).find("input.ag-floating-filter-input").each(function(){ 
                    $(this).attr("col-id", col_ids[i]); 
                    i++; 
                });
            };
            // gridoptions.columnApi.getAllColumns().forEach(function(column) {                console.log(column.colId);            });
        }

        get_col_ids();
    </script>

    <cfset request.focusHiLightOff = 1>

    <script>
        $("textarea").focus();
    </script>
</body>
</html>