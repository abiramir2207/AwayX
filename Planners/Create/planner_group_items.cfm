<!----------------------------------------------------------------------------------------------------------------------------------
	  Template: \Planners\Create\planner_group_items.cfm
		Author: Chris Nguyen
		  Date: 2020 August
       Purpose: 

       Parameters: 
                    program_id
                    group_id
                    group_Level_ID

----------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Current & Program Group Items</title>
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
        <cf_include files="/styles/tabnav-2020.css">
        <style>
            nav li.nav {
                padding-left: 20px;
                padding-right: 20px;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">

    <!--- Tabs Navigation --->
    <nav>  
        <ul>
			<li name="current" class="nav active">Current Group Items</li>
            <li name="program" class="nav">Program Group Items</li>
        </ul>
    </nav>
    
    <!--- iframes --->
    <main>
        <cfoutput>
            <cfset current_src = "/Common_Files/contracts/Groups/group_items.cfm"
                                        & "?group_ID=#url.group_id#"
                                        & "&group_Level_ID=#url.group_Level_ID#"
                                        & "&tabs=1"
                                        & "&title=Current Group Items">
            <iframe name="current" class="" src="#current_src#"></iframe>
            <iframe name="program" class="hidden"></iframe>
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

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("nav").on("click", "li.nav", function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                let active_tab = $("li.active");
                let iframe = null;

                make_tabs_inactive();
                clicked_tab.addClass("active");

                iframe = get_iframe( clicked_tab.attr("name") );

                if (iframe.attr("src")) {
                }
                else {
                    <cfoutput>
                    if (iframe.attr("name") === 'program') {
                        iframe.attr("src", "/Common_Files/contracts/Groups/group_items.cfm"
                                                + "?Group_ID=#url.group_id#"
                                                + "&program_ID=#url.program_id#"
                                                + "&showProgramItems=1"
                                                + "&tabs=1"
                                                + "&title=Program Group Items").removeClass("hidden");
                    }
                    </cfoutput>
                }
                iframe.show();
            }
        });

        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "current" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){ 
            set_iframe_height(); 
        });
    </script>

    <cfset request.focusHiLightOff = 1>    
</body>
</html>