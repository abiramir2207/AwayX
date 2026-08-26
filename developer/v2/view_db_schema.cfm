<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <cfif structkeyExists(url, "table_name")>
            <cfset url.table_name = listFirst(url.table_name, " ")>
            <cfoutput><title>#url.table_name# | View Database Schema</title></cfoutput>
        <cfelse>
            <title>View Database Tables</title>
        </cfif>
        <cfsavecontent variable="head_content">
            <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/common_files/main_style.css">
            <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/css-loader.css">
            <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/datatables/datatables-1.10.19/css/jquery.datatables.css?v=0951570"> 

            <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
            <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/datatables/datatables-1.10.19/js/jquery.datatables.js?v=0952530" ></script>
            <script src="default.js?v=092025405"></script>

            <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">

            <style>
                body {
                    overflow: hidden;
                }
                h2 { color:#2200CC; font-size:20px; letter-spacing:0.75px; height:16px; margin-top:0; padding-top:0; }
                td { font-size:13px; }
                <cfif structkeyExists(url, "table_name") eq false>
                    td:hover { cursor:pointer; }
                </cfif>
                .btn-secondary { color: #fff; background-color: #CB384A; margin2:0 42px 0 0;}
                td.right { text-align:right; }
                #return-to-top {
                    position: fixed;
                    bottom: 20px;
                    right: 20px;
                    background: rgb(0, 0, 0);
                    background: rgba(0, 0, 0, 0.7);
                    width: 50px;
                    height: 50px;
                    display: block;
                    text-decoration: none;
                    -webkit-border-radius: 35px;
                    -moz-border-radius: 35px;
                    border-radius: 35px;
                    display: none;
                    -webkit-transition: all 0.3s linear;
                    -moz-transition: all 0.3s ease;
                    -ms-transition: all 0.3s ease;
                    -o-transition: all 0.3s ease;
                    transition: all 0.3s ease;
                }
                #return-to-top i {
                    color: #fff;
                    margin: 0;
                    position: relative;
                    left: 16px;
                    top: 13px;
                    font-size: 19px;
                    -webkit-transition: all 0.3s ease;
                    -moz-transition: all 0.3s ease;
                    -ms-transition: all 0.3s ease;
                    -o-transition: all 0.3s ease;
                    transition: all 0.3s ease;
                }
                #return-to-top:hover {
                    background: rgba(0, 0, 0, 0.9);
                }
                #return-to-top:hover i {
                    color: #fff;
                    top: 5px;
                }
                .dataTables_wrapper .dataTables_filter { float:left; }
                i.table {
                    padding-right: 20px;
                    font-style: normal;
                }
                img.content {
                    float: right;
                    margin-right: 15px;
                }
			    #footer { position: fixed; left: 0; bottom: 0; width: 100%; display:flex; justify-content: space-around; margin-bottom: 7px; }
            </style>

        </cfsavecontent>
        <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
        <cfhtmlhead text="#head_content#">
    </head>
    <body>
    <cfif structkeyExists(url, "table_name")>
        <cfdbinfo datasource="#application.datasource#" name="qTables2" type="columns" table="#url.table_name#"/>
    <cfelse>
        <cfquery name="qTables" datasource="#application.datasource#">
            SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
        </cfquery>
        <!--- <cfdbinfo datasource="#application.datasource#" name="qTables" type="tables" /> --->
    </cfif>
    <cfif structkeyExists(url, "table_name")>
        <div style="height2:6vh;">
        <cfoutput><h2 style="height2:6vh;padding:2px 0 5px 0;">
        <!--- <img src="iconmonstr-arrow-72-16.png" style="cursor:pointer;" onclick="window.history.back();"> --->
        #url.table_name#
        <cfset query = "select * from #url.table_name# --where deleted = 0">
         <!--- <button class="button" style="float:right;" onclick="window.popups.push(popupCenter('queryDatabase.cfm?query=#query#', '', 'lg', 'lg'))">view content</button> --->
         <button class="button" style="float:right;" onclick="window.location = 'queryDatabase.cfm?query=#query#'">rows view content</button>
         <button class="button" style="float:right;" onclick="window.location = 'queryDatabase2.cfm?query=#query#'">columns view content</button>
        </h2>
        </cfoutput>
        <!--- <hr class="four"> --->
        <cfquery name="qTables" dbtype="query">
            select *
              from qTables2
              order by column_name
        </cfquery>
<!---         <cfdump var="#qTables2#"> --->            
        </div>
    </cfif>

    <table id="db_schema" class="display" cellspacing="0" width="100%">
        <thead>
            <tr>
                <cfif structkeyExists(url, "table_name")>
                    <th>Column Name</th>
                    <th>Data Type</th>
                    <th>Size</th>
                    <th>Misc.</th>
                <cfelse>
                    <th>Table Name</th>
                </cfif>
            </tr>
        </thead>
        <tbody>
            <cfsavecontent variable="tbody">
            <cfoutput query="qTables">
                <tr>
                    <cfif structkeyExists(url, "table_name")>
                        <td>#lcase( qTables.column_name )# #(qTables.is_primarykey ? "*" : "")#</td>
                        <td>#qTables.type_name#</td>
                        <td class="right">#qTables.column_size#</td>
                        <td>#(qTables2.is_nullable ? "null" : "")# #(len(qTables2.column_default_value) gt 0 ? "default=" & qTables2.column_default_value : "")#</td>
                    <cfelse>
                        <td><i class="table"> #lcase( qTables.table_name )# </i> <img class="content" title="view table content" src="/images/document_magnifier.gif" height="16" width="16"></td>
                    </cfif>
                </tr>
            </cfoutput>                
            </cfsavecontent>
            <cfoutput>#application.util.string.compress(tbody)#</cfoutput>
        </tbody>
    </table>

    <div id="footer">
        <!--- <button class="btn btn-primary"   onclick="close_popups(); return false;">close popups</button> --->
    </div>
        
    <script>
        window.popups = [];
        $('#db_schema').DataTable({
                fixedHeader: true
                ,"paging": false
                ,"sDom": "ft"
                <cfif structkeyExists(url, "table_name")>
                    ,"aoColumns": [{}, {"bSortable":false,  "bSearchable":false}, {"bSortable":false,  "bSearchable":false}, {"bSortable":false,  "bSearchable":false}]
                    ,"scrollY": "91vh"
                <cfelse>
                    ,"scrollY": "82vh"
                </cfif>
        });

        <cfif structkeyExists(url, "table_name") eq false>
            $("i.table").click(function() {
                let table_name = $(this).text().trim();
                window.popups.push(popupCenter("view_db_schema.cfm?table_name=" + table_name, "", "md", "lg"));
            })
            $("img.content").click(function(e) {
                e.stopPropagation();
                let table_name = $(this).parent().children("i.table").text();
                // window.popups.push(popupCenter("queryDatabase.cfm?query=select * from " + table_name + " --where deleted = 0", "", "lg", "lg"));
                window.href = "queryDatabase.cfm?query=select * from " + table_name + " --where deleted = 0";
            })
        </cfif>
    </script>

    <cfset request.focusHiLightOff = 1>
    </body>
</html>