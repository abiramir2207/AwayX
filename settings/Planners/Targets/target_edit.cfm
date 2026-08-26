<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\target_edit.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Edit Planner Target
  *
  * ==================================================================================================== 
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <cfsavecontent variable="styles">
        <style>
            * { 
                box-sizing: border-box; 
                margin: 0;
                padding: 0;
            }
            body {
                padding: 10px;
                overflow: hidden;
            }
            iframe {
                border: 0;
                width: 100%;
            }
            .hidden {
                display: none;
            }
        </style>
        <cf_include files="/styles/tabnav-2020.css, /script/javascript/loglevel/1.6.8/loglevel.min.js">
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">

    <!--- Tabs Navigation --->
    <nav>  
        <ul>
			<li name="sales" class="nav active">Sales Targets</li>
            <li name="trades" class="nav">Trade Targets</li>
			<li name="adjustments" class="nav">Target Adjustments</li>
            <li name="demos" class="nav">Demos</li>
			<li name="slotting" class="nav">Slotting</li>
        </ul>
    </nav>
    
    <!--- iframes --->
    <main>
        <cfoutput>
            <iframe name="sales" class="" src="sales_targets.cfm?id=#url.id#"></iframe>
            <iframe name="trades" class="hidden"></iframe>
            <iframe name="adjustments" class="hidden"></iframe>
            <iframe name="demos" class="hidden"></iframe>
            <iframe name="slotting" class="hidden"></iframe>
        </cfoutput>
    </main>

    <cfinclude template="/common_files/jQuery.cfm">
    <cfinclude template="/common_files/noty.cfm">

    <script>
        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

        function refresh_tab_name ( tab_name, tab_content_changed ) {
            let tab = get_navli( tab_name );
            if ( tab ) {
                let tab_title = tab.text();
                // add tab content changed indicator
                if ( tab_content_changed !== 1) {
                    tab.text( tab_title.replace("*", "") );
                }
                // save button was clicked, reset tab title
                else if (tab_title.indexOf("*") == -1) {
                    tab.text( tab_title + " * ");
                }
            }
        }

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 10;
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

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("nav").on("click", "li.nav", function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                let active_tab = $("li.active");
                let iframe = null;
                // handle unsaved changes on the page
                if (active_tab.text().indexOf("*") !== -1) {
                    if ( confirm("You have unsaved changes on this page. Please click OK to go back to save your changes.\n\nClick Cancel only if you want to discard your changes.") ) {
                        // ignore switching to another tab
                        return;
                    }
                    else {
                        // discard unsaved changes, reload tab content
                        active_tab.text( active_tab.text().replace("*", "") );
                        iframe = $("iframe[name=" + active_tab.attr("name") + "]");
                        // empty iframe
                        iframe.contents().find("body").html("");
                        iframe[0].contentWindow.location.reload();
                    }
                }

                make_tabs_inactive();
                clicked_tab.addClass("active");

                iframe = get_iframe( clicked_tab.attr("name") );

                if (iframe.attr("src")) {
                    // empty iframe
                    iframe.contents().find("body").html("");
                    // reload tab content to prevent stale information due to changes from other tabs
                    iframe[0].contentWindow.location.reload();
                }
                else {
                    <cfoutput>
                    if (iframe.attr("name") === 'trades') {
                        iframe.attr("src", "trade_targets.cfm?id=#url.id#").removeClass("hidden");
                    }
                    else if (iframe.attr("name") === 'adjustments') {
                        iframe.attr("src", "target_adjustments.cfm?id=#url.id#").removeClass("hidden");
                    }
                    else if (iframe.attr("name") === 'demos') {
                        iframe.attr("src", "demos.cfm?id=#url.id#").removeClass("hidden");
                    }
                    else if (iframe.attr("name") === 'slotting') {
                        iframe.attr("src", "slotting.cfm?id=#url.id#").removeClass("hidden");
                    }
                    </cfoutput>
                }
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