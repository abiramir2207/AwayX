<!--- <cfabort> --->
<!---
  * ====================================================================================================
  *    @File: \billbacks\2020\editing.cfm
  *  @Author: Sharon Harris
  *    @Date: July 2020
  *
  * @Remarks: Editing billback - open billback tab content
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
</head>

<body>
	<!--- bbIdInt default; if none passed create a new blank billback struck --->
	<cfparam name="url.billback_Id" type="integer" default="0" />
    <!--- TODO: REMOVE THIS ---- BB-4078837=1162514; BB-4081315=1165006 --->
	<cfset local.bbIdInt = url.billback_Id />

    <!--- Tabs Navigation --->
    <nav>
		<ul>
            <li name="edit_<cfoutput>#local.bbIdInt#</cfoutput>" class="nav" src="edit_billback.cfm?billback_Id=<cfoutput>#local.bbIdInt#</cfoutput>" >Edit</li>
            <li name="settlement" class="nav" src="settlement.cfm?billbackIDInt=<cfoutput>#local.bbIdInt#</cfoutput>">Settlement</li>
        </ul>
    </nav>

    <!--- iframes --->
    <main>
        <iframe name="edit_<cfoutput>#local.bbIdInt#</cfoutput>"></iframe>
        <iframe name="settlement"></iframe>
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
                if(clicked_tab.attr("name") == 'settlement'){
                    if (typeof get_iframe( "settlement" )[0].contentWindow.displayBB !== "undefined") { 
                       showSettlement();
                    }
                }
                
                iframe.show();
            }
        });

        function showSettlement(){
            get_iframe( "settlement" )[0].contentWindow.bb = get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.bb;
            //console.log(get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow);
            //console.log(get_iframe( "settlement" )[0].contentWindow);
            if (typeof get_iframe( "settlement" )[0].contentWindow.displayBB !== "undefined") { 
                get_iframe( "settlement" )[0].contentWindow.displayBB();
            }
        }

        function refreshBBEdit(){
            get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.bb = get_iframe( "settlement" )[0].contentWindow.bb;
            //console.log(get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow);
            //console.log(get_iframe( "settlement" )[0].contentWindow);
            if (typeof get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.show_billback !== "undefined") { 
                get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.show_billback();
                get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.getLockUnlockBB();
            }
        }

         function unlockOnClose(){
            get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.bb = get_iframe( "settlement" )[0].contentWindow.bb;
            //console.log(get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow);
            //console.log(get_iframe( "settlement" )[0].contentWindow);
            if (typeof get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.onWindowClose !== "undefined") { 
                get_iframe( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" )[0].contentWindow.onWindowClose();
            }
        }




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
            get_navli( "edit" ).click();
        });

        <!--- ~~~~~~ make Edit tab active ~~~~~~ --->
        get_navli( "edit_<cfoutput>#local.bbIdInt#</cfoutput>" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){
            set_iframe_height();
        });

        function reloadBBEdit() {
            this.location.reload();
		}
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>