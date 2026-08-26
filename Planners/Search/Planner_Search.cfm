<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title></title>
    </head>
    <body>
        <cfsavecontent variable="styles">
            <style>
                body {
                    overflow: hidden;
                    padding: 0px;
                    margin: 0;
                }
                iframe {
                    border: 0;
                    box-sizing: border-box;
                    width: 100%;
                    padding: 0;
                    height: 90vh;
                }
                header {
                    margin: 0;
                    padding: 0;
                }
                li.hidden {
                    display: none;
                }
                div#planner{
                    display:none;
                }
            </style>
            <cf_include files="/styles/tabnav-2020.css, /styles/css-loader.css">
        </cfsavecontent>
        <cfhtmlhead text="#application.util.string.compress( styles )#">

        <!--- Tabs Navigation --->
        <nav>
            <ul>
                <cfoutput><li name="search" class="nav" src="planner_search_result.cfm?#application.util.list.queryString(url)#">Search #Application.PlannerLabel_Plural#</li></cfoutput>
                <li name="edit" class="nav hidden"></li>
            </ul>
        </nav>

        <main>
            <iframe name="search"></iframe>
        </main>

        <div id="planner"></div>

        <cfinclude template="/common_files/jQuery.cfm">

        <script>
            function load_planner(planner_title, plannerID, url) {
                $("li[name=search]").removeClass("active");
                // populate 2nd tab title with selected planner ID
                $("li[name=edit]").text( planner_title ).show().addClass("active");

                // remove previous form and iframe to get rid of previous content
                $("#planner form").remove();
                $("main iframe[name=edit]").remove();

                // add new iframe
                $("main").append( $("<iframe/>", {name:"edit"}) );

                // add new form
                $("#planner").append(
                    $("<form/>", { name:"load_planner", action:"/common_files/processing.cfm", method:"post", target:"edit" }).append(
                        $("<input/>", { type:"hidden", name:"plannerID", value:plannerID }),
                        $("<input/>", { type:"hidden", name:"mode", value:'' }),
                        $("<input/>", { type:"hidden", name:"actualpage", value:url }),
                        $("<input/>", { type:"hidden", name:"page_creating", value:'1' })
                    )
                );

                $("iframe[name=search]").hide();
                $("iframe[name=edit]").show();
                $("form[name=load_planner]").submit();
            }

            <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
            let glob = { tab_counter: $("li.nav").length };

            <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
            function set_iframe_height( name ) {
                glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 0;
                $("iframe" + (name ? "[name='" + name + "']" : '')).css("height", glob.iframe_height + "px");
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
            get_navli( "search" ).click();
            <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
            set_iframe_height();


            $(window).resize(function(){
                set_iframe_height();
            });
        </script>
    </body>
    </html>