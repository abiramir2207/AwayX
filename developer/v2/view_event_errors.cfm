        <cfsavecontent variable="head_content">
            <cfmodule template="/customTags/include.cfm" files="default.css">
            <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/styles/css-loader.css">
            <link rel="stylesheet" type="text/css" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/datatables/datatables-1.10.19/css/jquery.datatables.css?v=0951570">

            <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>
            <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/datatables/datatables-1.10.19/js/jquery.datatables.js?v=0952530" ></script>
            <!--- <script src="default.js?v=092025405"></script> --->

            <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">

            <style>
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
			    #footer { position: fixed; left: 0; bottom: 0; width: 100%; display:flex; justify-content: space-around; margin-bottom: 7px; }
            </style>
        </cfsavecontent>
        <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
        <cfhtmlhead text="#head_content#">


		<cfset qErrors = directoryList(expandPath("/common_documents/Data_Files/Created/error_files"), false, "query", "error_*.htm", "DateLastModified DESC")>

        <table id="db_schema" class="display" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th>Error</th>
                    <th>Created Date</th>
                </tr>
            </thead>
            <tbody>
                <cfsavecontent variable="tbody">
                    <cfoutput query="qErrors" maxRows=500>
                        <cfset error_number = replace(replace(qErrors.Name, "error_", ""), ".htm", "")>
                        <tr>
                            <td class="view">#error_number#</td>
                            <td>#(dateFormat(qErrors.DateLastModified, "mmm d yyyy"))# at #lcase(timeFormat(qErrors.DateLastModified, "short"))#</td>
                        </tr>
                    </cfoutput>
                </cfsavecontent>
                <cfoutput>#application.util.string.compress(tbody)#</cfoutput>
            </tbody>
        </table>

    	<div id="footer">
    	    <!--- <button class="btn btn-primary"   onclick="close_popups(); return false;">close popups</button> --->
    	    <button class="btn btn-primary"   onclick="refresh();">refresh</button>
    	</div>

        <cfset refresh_in_minutes = application.util.query.get_setting("event_errors_auto_refresh_in_minutes", 0)>
        <cfset refresh_in_minutes = refresh_in_minutes gt 0
                                        ? refresh_in_minutes
                                        : 5>

        <script>
            window.popups = [];
            $('#db_schema').DataTable({
                    fixedHeader: true
                    ,"aaSorting": []
                    ,"paging": false
                    ,"sDom": "ft"
                    ,"scrollY": "91vh"
                    ,"columns": [{"className": "dt-left"}, {"bSortable":false, "bSearchable":false, "className": "dt-left"}]
            });

            $("td.view").click(function(){
                // window.popups.push(popupCenter( "/common_documents/Data_Files/Created/error_files/error_" + $(this).text() + ".htm", "", "lg", "md"));
                $("iframe.report").attr("src", "/common_documents/Data_Files/Created/error_files/error_" + $(this).text() + ".htm");
            });
            // $(window).unload( close_popups );

            function refresh() {
                // do not close existing popups
                window.popups = [];
                window.location = location;
            }

            // auto refresh in 5 minutes
            setTimeout(function(){ refresh(); }, <cfoutput>#refresh_in_minutes#</cfoutput> * 60 * 1000);

            <cfoutput>$("title").text("Event Errors #refresh_in_minutes# min. auto refresh");</cfoutput>
        </script>
        <cfset request.focusHiLightOff = 1>
