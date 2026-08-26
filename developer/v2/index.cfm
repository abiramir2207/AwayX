<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <cfset tools_title = cgi.server_name contains ".awayx.com"
                                ? application.util.string.capFirstTitle(replace(replace(cgi.server_name,".awayx.com",''), '.', ' ', 'all'))
                                : application.util.string.capFirstTitle(application.datasource)>
        <cfoutput><title>#tools_title# - Tools</title></cfoutput>
        <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
    </head>
    <body>
        <!--- <cf_include files="default.css"> --->
        <cfmodule template="/customTags/include.cfm" files="default.css">

        <cfsavecontent variable="styles">
            <style>
                body {
                    overflow: hidden;
                    padding: 10px;
                    background-color: #666666;
                }
                iframe {
                    border: 0;
                    box-sizing: border-box;
                    width: 98vw;
                    padding: 0;
                    min-height: calc(98vh - 25px);
                    height: calc(98vh - 25px);
                }
                header {
                    margin: 0;
                    padding: 0;
                }
                div.forge {
                    font-size: 0.8rem;
                    position: fixed;
                    top: 7px;
                    right: 12px;
                    color: white;
                }
            </style>

            <link rel="stylesheet" type="text/css" href="tabnav-2020.css">

            <style>
                nav li.nav {
                    min-width: 8vw;
                }

                button.button {
                    background-color: #edeef2;
                    border-radius: 50px;
                    border: 1px solid #d8d9dd;
                    box-sizing: border-box;
                    box-shadow: 0px 2px 4px -1px rgba(86, 87, 96, 0.3);
                    color: #343540;
                    font-size: 11px;
                    font-weight: 500;
                    height: 20px;
                    margin: 0 5px;
                    padding: 0px 8px 0 8px;
                    white-space: nowrap;
                }
                button.button:hover {
                    color: #406be4;
                    background-color: #fff;
                }
                button.button:focus {
                    outline: 0;
                }
                button.button:disabled,
                button.button[disabled] {
                    background-color: #edeef2;
                    border: 1px solid #edeef2;
                    color: #c4c5c7;
                }
                button.alt {
                    background-color: #ffffff;
                    border: 1px solid #d8d9dd;
                    color: #343540;
                }
                button.recommended {
                    background-color: #406be4;
                    border: 1px solid #406be4;
                    color: #ffffff;
                }
                button.recommended:enabled:hover,
                button.recommended[enabled]:hover {
                    background-color: #406be4;
                    color: #ffffff;
                    opacity: .9;
                }
                button.minor {
                    background-color: transparent !important;
                    border: none;
                    box-shadow: none;
                    color: #406be4;
                }
                    button.minor:hover {
                        text-decoration: underline;
                    }
                    button.minor:active {
                        color: #1e4dd3;
                    }
                    button.minor:disabled,
                    button.minor[disabled] {
                        border: none;
                        color: #c4c5c7;
                    }
                button.danger {
                    background-color: #bf1c36;
                    border: 1px solid #bf1c36;
                    color: #ffffff;
                }

                button.danger:hover {
                    background-color: #bf1c36;
                    color: #ffffff;
                    opacity: .9;
                }

                button.warning {
                border: 1px solid #bf1c36;
                color: #bf1c36;
                }

                button.warning:hover {
                    color: #406be4;
                }


                button.outline.danger {
                    background-color: #ffffff;
                    border: 1px solid #bf1c36;
                    color: #bf1c36;
                }

                button.outline.danger:hover {
                    background-color: #bf1c36;
                    color: #ffffff;
                    opacity: .9;
                }

                button.success {
                    background-color: #099c09;
                    border: 1px solid #099c09;
                    color: #fff;
                }
                button.success:hover {
                    background-color: #088908;
                    color: #fff;
                }
                button.outline.success {
                    background-color: #ffffff;
                    border: 1px solid #099c09;
                    color: #099c09;
                }
                button.outline.success:hover {
                background-color: #088908;
                color: #fff;
                }

            </style>
        </cfsavecontent>
        <cfhtmlhead text="#application.util.string.compress( styles )#">

        <!--- Tabs Navigation --->
        <nav>
            <ul>
                <!--- <li name="errors2" class="nav" src="errors2.cfm">Errors V2</li> --->
                <li name="errors" class="nav" src="errors.cfm">Errors</li>
                <li name="tables" class="nav" src="tables.cfm">DB Tables</li>
                <li name="procedures" class="nav" src="procedures.cfm">Stored Procs</li>
                <li name="settings" class="nav" src="_settings.cfm">Settings</li>
                <li name="debug" class="nav" src="debug_info.cfm">Debug</li>
                <li name="programs" class="nav" src="programs.cfm">Programs</li>
                <li name="billbacks" class="nav" src="billbacks.cfm">Billbacks</li>
                <li name="auditing" class="nav" src="_auditing.cfm">Auditing</li>
            </ul>
        </nav>

        <CFQUERY NAME="getReleaseVersion" datasource="#application.datasource#">
            SELECT TOP 1 LTRIM(RTRIM(Patch_Number)) As Release_Version
            FROM Application_Installation
            ORDER BY Release_Version DESC
        </CFQUERY>

        <div class="forge">
            <cfoutput>
                Data Source [ #application.datasource# ] -
                Forge #listFirst(getReleaseVersion.Release_Version,'.')#.#listGetAt(getReleaseVersion.Release_Version,2,'.')#
            </cfoutput>
            <button class="button upgrade" style="margin-left:30px; position:relative; top:-2px;">run upgrade</button>
        </div>

        <!--- iframes --->
        <!--- <main style="border:1px double;height:97vh;"> --->
        <main>
            <!--- <iframe name="errors2"></iframe> --->
            <iframe name="errors"></iframe>
            <iframe name="tables"></iframe>
            <iframe name="procedures"></iframe>
            <iframe name="settings"></iframe>
            <iframe name="debug"></iframe>
            <iframe name="programs"></iframe>
            <iframe name="billbacks"></iframe>
            <iframe name="auditing"></iframe>
        </main>

        <script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ajax_js/jquery-1.12.4.min.js"></script>

        <script>
            <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
            let glob = { tab_counter: $("li.nav").length };

            <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
            function set_iframe_height( name ) {
                // glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 0;
                // $("iframe" + (name ? "[name='" + name + "']" : '')).css("height", glob.iframe_height + "px");
            }

            <!---  get navigation jQuery element based on name  --->
            function get_navli( name ) {
                return $("li.nav[name='" + name + "']");
            }

            <!--- get iframe jQuery element based on name --->
            function get_iframe( name ) {
                return $("iframe[name='" + name + "']");
            }

            <!--- make active tab inactive, its iframe hidden --->
            function make_tabs_inactive() {
                // $("li.active").each(function(){
                $("li.nav").each(function(){
                    $(this).removeClass("active");
                    get_iframe( $(this).attr("name") ).hide();
                });
            }

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~ tab click event handler ~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            $("nav").on("click", "li.nav", function(event){
                let clicked_tab = $(event.target);
                if ( !clicked_tab.hasClass("active") ) {
                    make_tabs_inactive();

                    clicked_tab.addClass("active");

                    let iframe = get_iframe( clicked_tab.attr("name") );
                    <!--- ~~~ assign iframe src and load ~~~ --->
                    if ( iframe.attr("src" ) === undefined ) {
                        iframe.attr("src", clicked_tab.attr("src"));
                    }
                    iframe.show();
                }
                // allow to refresh iframe tab
                else {
                    let iframe = get_iframe( clicked_tab.attr("name") );
                    iframe.attr("src", clicked_tab.attr("src"));
                }
            });

            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- ~~~~ x click event handler ~~~~~ --->
            <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            $("nav").on("click", "i.close", function(e){
                e.preventDefault();
                e.stopPropagation();
                let clicked_tab = $(this).parent("li.nav");
                $("iframe[name='" + clicked_tab.attr("name") + "']").remove();
                clicked_tab.remove();
                <!--- ~~~~~~ make home tab active ~~~~~~ --->
                get_navli( "home" ).click();
            });

            <!--- ~~~~~~ make search tab active ~~~~~~ --->
            get_navli( "errors" ).click();
            <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
            // set_iframe_height();


            // $(window).resize(function(){ set_iframe_height(); });

            $( "button.upgrade" ).click( function(){
                popupCenter( "/scheduled/upgrade.cfm", "Upgrade Utility", "sm", "sm" );
            } );
        </script>

        <script src="default.js?v=092025405"></script>
    </body>


    </html>