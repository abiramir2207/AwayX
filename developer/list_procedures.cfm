<!---
  * ==================================================================================================== 
  *    @File: 
  *  @Author: Chris Nguyen
  *    @Date: 2019-03-11 08:28:11
  * 
  * @Remarks:   
  *
  *
  * 
  *  
  * ==================================================================================================== 
--->
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>View Database Procedures</title>
        <cfsavecontent variable="head_content">

            <link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/script/javascript/datatables/datatables-1.10.19/css/jquery.datatables.css?v=0951570">            
            <link rel="stylesheet" type="text/css" href="https://cdn.awayx.com/base/styles/css-loader.css">

            <script src="default.js?v=092025405"></script>

            <style>
                .dataTables_wrapper .dataTables_filter {
                    float: left;            
                }
                td:first-child {
                    cursor: pointer;
                }
                th {
                    text-align: left;
                }
			    #footer { position: fixed; left: 0; bottom: 0; width: 100%; display:flex; justify-content: space-around; margin-bottom: 7px; }
            </style>

        </cfsavecontent>
        <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
        <cfhtmlhead text="#head_content#">
    </head>
    <body>
    <cfquery name="qProcedure" datasource="#application.datasource#">
        SELECT name, modify_date
            -- CONVERT(VARCHAR(12), modify_date, 107) as modify_date
         FROM sys.procedures
                ORDER BY name
    </cfquery>

    <table class="dataTable hover row-border order-column" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>Stored Procedure Name</th>
                <th>Modified Date</th>
            </tr>
        </thead>
    </table>

    <div id="footer">
        <button class="btn btn-primary"   onclick="close_popups(); return false;">close popups</button>
    </div>

    <script src="https://cdn.awayx.com/base/script/javascript/ajax_js/jquery-1.7.2-min.js?v=0153530" ></script> 
    <script src="https://cdn.awayx.com/base/script/javascript/datatables/datatables-1.10.19/js/jquery.datatables.js?v=0952530" ></script>

    <script>
        window.popups = [];

        $('table.dataTable').DataTable({
                                         "autoWidth": false     // set it to false - for performance
                                        ,"columnDefs": [ { "type": "date", "targets": 1 }  ]
                                        ,"deferRender": true    // set it to true - for performance
                                        ,"data": <cfoutput>#application.util.query.toDtJSON(qProcedure, "name,modify_date")#</cfoutput>
                                        ,"dom": "ft"
                                        ,"orderClasses": false  // set it to false - for performance
                                        ,"order": []            // no order initially, use sql to control order - for performance
                                        ,"paging" : false
                                        ,"scrollY": "82vh"
                                });
        $("td:first-child").click(function(){
            window.popups.push(popupCenter("view_procedure.cfm?name=" + $(this).text() + "&date=" + $(this).next("td").text(), "", "lg", "lg"));
        });
        $(window).unload( close_popups );
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>