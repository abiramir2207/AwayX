<!---
  * ====================================================================================================
  *    @File: \settings\planners\targets\index.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  *
  * @Remarks: Planner Targets Setting Main Page
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfsavecontent variable="styles">
        <cf_include files="/styles/tabnav-2020.css">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            html, body {
                height: 100%;
            }
            nav {
                position: relative;
                top: 0;
                left: 0;
                height: auto;
                z-index: 99999999;
            }
            iframe {
                border: 0;
                width: 100%;
                position: absolute;
                top: 0;
                bottom: 0;
                padding-top: 60px;
                /* border: 5px solid yellow; */
            }
            .hidden {
                display: none;
            }
            div#planner{
                display: none;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">

    <cfset pagetitle = "#Application.PlannerLabel# TARGETS">
    <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
    <cfinclude template="/settings/settings_title.cfm">

    <!--- Tabs Navigation --->
    <nav>
        <ul>
			<li name="list" class="nav">Targets</li>
            <li name="edit" class="nav hidden"></li>
            <li name="new" class="nav hidden"></li>
        </ul>
    </nav>

    <!--- iframes --->
    <main>
		<iframe name="list" src="target_list.cfm"></iframe>
		<iframe name="edit" class="hidden"></iframe>
		<iframe name="new" class="hidden"></iframe>
    </main>

    <div id="planner"></div>

    <cfinclude template="/common_files/jQuery.cfm">
    <cf_include files="/script/javascript/loglevel/1.6.8/loglevel.min.js">

    <script>
        log.disableAll();

        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 10;
            log.debug($(window).innerHeight(), $("iframe:first-child")[0].offsetTop, glob.iframe_height);
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

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ makes edit iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function edit_tab( target_id, target_label ) {
            get_iframe( "edit" ).attr("src", "target_edit.cfm?id=" + target_id ).removeClass("hidden");
            set_iframe_height( "edit" );
            get_navli( "edit" ).removeClass("hidden").text(target_label).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ makes create new iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function create_new_tab() {
            get_iframe( "new" ).attr("src", "target_new.cfm").removeClass("hidden");
            set_iframe_height( "new" );
            get_navli( "new" ).removeClass("hidden").text("Create New Target").click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ remove create new iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function delete_new_tab() {
            get_iframe( "new" ).attr("src", "").addClass("hidden");
            get_navli( "new" ).addClass("hidden").text("");
            get_navli( "list" ).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        // $("nav").on("click", "li.nav", function(event){
        $("li.nav").click(function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                make_tabs_inactive();
                clicked_tab.addClass("active");

                let iframe = get_iframe( clicked_tab.attr("name") );
                iframe.show();
            }
        });

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ x click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("nav").on("click", "i.closetab", function(e){
            e.preventDefault();
            e.stopPropagation();
            let clicked_tab = $(this).parent("li.nav");
            $("iframe[name='" + clicked_tab.attr("name") + "']").remove();
            clicked_tab.remove();
            <!--- ~~~~~~ make home tab active ~~~~~~ --->
            get_navli( "home" ).click();
        });

        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "list" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){
            // console.log("search_billbacks.cfm");
            set_iframe_height();
        });

        function load_target(target_title, targetID, url) {
            $("li[name=search]").removeClass("active");
            // populate 2nd tab title with selected target ID
            $("li[name=edit]").text( target_title ).show().addClass("active");

            // remove previous form and iframe to get rid of previous content
            $("#target form").remove();
            $("main iframe[name=edit]").remove();

            // add new iframe
            $("main").append( $("<iframe/>", {name:"edit"}) );

            // add new form
            $("#target").append(
                $("<form/>", { name:"load_target", action:"/common_files/processing.cfm", method:"post", target:"edit" }).append(
                    $("<input/>", { type:"hidden", name:"targetID", value:targetID })
                )
            );

            $("iframe[name=list]").hide();
            $("iframe[name=edit]").show();
            $("form[name=load_target]").submit();
        }
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>