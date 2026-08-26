<!--- <cfabort> --->
<!---
  * ==================================================================================================== 
  *    @File: \billbacks\2020\home.cfm
  *  @Author: Chris Nguyen
  *    @Date: January 2020
  * 
  * @Remarks: Search billbacks - home tab content
  *
  * ==================================================================================================== 
--->
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
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
                overflow: hidden;
            }
            iframe {
                border: 0;
                box-sizing: border-box;
                width: 100%;
                padding: 0;
            }
            header {
                margin: 0;
                padding: 0;
            }
        </style>
        <cf_include files="/styles/tabnav-2020.css">
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    <cfparam name="URL.status" default="0">
    <!--- Tabs Navigation --->
    <nav>  
        <ul>
            <li name="search" class="nav" src="<cfoutput>search.cfm?status=#url.status#</cfoutput>">Search</li>
            <li name="upload" class="nav" src="upload.cfm">Upload</li>
            <li name="alias" class="nav" src="/settings/Alias_Management/AliasMain.cfm?page_title=false">Alias</li>
        </ul>
    </nav>
    
    <!--- iframes --->
    <!--- <main style="border:1px double;height:97vh;"> --->
    <main>
        <iframe name="search"></iframe>
        <iframe name="upload"></iframe>
        <iframe name="alias"></iframe>
    </main>
    <!--- <p>testing</p> --->
    <cfinclude template="/common_files/jQuery.cfm">

    <script>
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
            <!--- ~~~~~~ make first tab active ~~~~~~ --->
            get_navli( "search" ).click();
        });

        <!--- ~~~~~~ make search tab active ~~~~~~ --->
        get_navli( "search" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        
        $(window).resize(function(){ 
            set_iframe_height(); 
        });
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>