<!---
  * ====================================================================================================
  *    @File: settings\Planners\Indirect_Allocation\index.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2022 May
  *
  * @Remarks: Planner Indirect Allocation Main Page
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
                z-index: 999;
            }
            iframe {
                border: 0;
                width: 100%;
                position: absolute;
                top: 0;
                bottom: 0;
                padding-top: 60px;
                height: 98vh;
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

    <cfset pagetitle = "#Application.PlannerLabel# INDIRECT ALLOCATION">
    <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
    <cfinclude template="/settings/settings_title.cfm">

    <!--- Tabs Navigation --->
    <nav>
        <ul>
            <li name="list" class="nav">Allocation</li>
            <li name="edit" class="nav hidden"></li>
            <li name="new" class="nav hidden"></li>
            <li name="upload" class="nav hidden">Upload</li>
        </ul>
    </nav>

    <!--- iframes --->
    <main>
        <iframe name="list" src="allocation_list.cfm"></iframe>
        <iframe name="edit" class="hidden"></iframe>
        <iframe name="new" class="hidden"></iframe>
        <iframe name="upload" class="hidden"></iframe>
    </main>

    <div id="planner"></div>

    <cfinclude template="/common_files/jQuery.cfm">
    <cf_include files="/script/javascript/loglevel/1.6.8/loglevel.min.js">

    <script>
        log.disableAll();

        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

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
            $("li.nav").each(function(){
                $(this).removeClass("active");
                get_iframe( $(this).attr("name") ).hide();
            });
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ makes edit iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function edit_tab( allocation_id, allocation_label ) {
            get_iframe( "edit" ).attr("src", "allocation_edit.cfm?id=" + allocation_id ).removeClass("hidden");

            get_navli( "upload" ).addClass("hidden");
            get_navli( "edit" ).removeClass("hidden").text(allocation_label).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ makes create new iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function create_new_tab() {
            get_iframe( "new" ).attr("src", "allocation_new.cfm").removeClass("hidden");
            get_navli( "new" ).removeClass("hidden").text("Create New Allocation").click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ remove create new iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function delete_new_tab() {
            get_iframe( "new" ).attr("src", "").addClass("hidden");
            get_navli( "new" ).addClass("hidden").text("");
            get_navli( "list" ).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ makes upload iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function create_upload_tab( fiscalYear, id ) {
            get_iframe( "upload" ).attr( "src", "allocation_upload.cfm?fiscalYear=" + fiscalYear + "&id=" + id ).removeClass( "hidden" );
            get_navli( "upload" ).removeClass("hidden").text( "Upload" ).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ remove upload iframe ~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function delete_upload_tab() {
            get_iframe( "upload" ).attr("src", "").addClass("hidden");
            get_navli( "upload" ).addClass("hidden").text("");
            get_navli( "edit" ).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
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
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>