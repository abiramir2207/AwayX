<!--- <cfabort> --->
<!---
  * ====================================================================================================
  *    @File: \billbacks\search_billbacks.cfm
  *  @Author: Chris Nguyen
  *    @Date: January 2020
  *
  * @Remarks: Search billbacks - multiple iframe tabs
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
            iframe {
                border: 0;
                width: 100%;
            }
        </style>
        <cf_include files="/styles/tabnav-2020.css">
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    <cfparam name="URL.status" default="0">

    <!--- Tabs Navigation --->
    <nav>
        <ul>
			<li name="home" class="nav home">Home</li>
        </ul>
    </nav>

    <!--- iframes --->
    <main>
		<iframe name="home" id="home" src="<cfoutput>home.cfm?status=#url.status#</cfoutput>"></iframe>
    </main>
    <!--- <p style="position:absolute;bottom:0">eop - searchbillbacks.cfm</p> --->
    <cfset jQuery.version = '1.12.4'>
    <cfinclude template="/common_files/jQuery.cfm">
    <cf_include files="/common_files/noty.cfm">

	<script>
        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
		let glob = { tab_counter: $("li.nav").length };
		
		// get the window of the iframe - allow the search iframe to call the create_tab function
		var innerWindow = document.getElementById('home').contentWindow;
		innerWindow.create_tab= create_tab;

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
        <!--- ~~~~~ create tab and iframe ~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function create_tab( bb_int_id, bb_code ) {
            if ($("li.nav").length > 6)
                noty( { text: "A maximum number of opened tabs<br>has been reached. Please select an existing tab<br> and click on 'x' to make room first."
                    ,type: 'information'
                    ,layout: 'center'
                    ,killer: true
                    ,timeout: 5000
            } );
            else {
                glob.tab_counter++;
                const new_tab_name = 'tab' + bb_code;
                // create a new tab when it does not exist
                if ($("li[name=" + new_tab_name + "]").length == 0) {
                    <!--- ~~~~~~ create tab with 'x' ~~~~~~~ --->
                    $("nav ul").append( $("<li></li>", { "class": "nav"
                                                            ,"text": bb_code
                                                            ,"name": new_tab_name
                                                        }).append( $("<i></i>", { "title": "close tab"
                                                                                    ,"class": "closetab "
                                                                                    ,"text": "X" 
                                                                                } ) ) );

                    <!--- ~~ create iframe with same name ~~ --->
                    // $("main").append( $("<iframe></iframe>", { src: 'edit_billback.cfm?billback_Id=' + bb_int_id, name: new_tab_name }) );
                    $("main").append( $("<iframe></iframe>", { src: 'editing.cfm?billback_Id=' + bb_int_id, name: new_tab_name }) );
                    set_iframe_height( new_tab_name );
                }

                <!--- ~~~~~~~~~ select new tab ~~~~~~~~~ --->
                get_navli( new_tab_name ).click();
            }
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
            console.log('onCLOSE');
            get_iframe( clicked_tab.attr("name") )[0].contentWindow.unlockOnClose();
            $("iframe[name='" + clicked_tab.attr("name") + "']").remove();
            clicked_tab.remove();
            <!--- ~~~~~~ make home tab active ~~~~~~ --->
            get_navli( "home" ).click();
        });

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ close from edit_billback.cfm COPY ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function closeIFrame(name){
            //remove iframe and tab
             $("iframe[name='" + name + "']").remove();
             $("li[name='" + name + "']").remove();
             <!--- ~~~~~~ make home tab active ~~~~~~ --->
            get_navli( "home" ).click();
        }

        //function  to reload search in search page
        function reloadSearch() {
            let searchFrame = innerWindow.$("iframe[name=search]")[0].contentWindow;
            searchFrame.get_grid_content();
           
        }

         function refreshSearchRow(bb) {
            let searchFrame = innerWindow.$("iframe[name=search]")[0].contentWindow;
            searchFrame.refreshRow(bb);
           
        }
        
        function refreshSearchRowFromEdit(bb) {
            let searchFrame = innerWindow.$("iframe[name=search]")[0].contentWindow;
            searchFrame.refreshRowFromEdit(bb);
           
        }

        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "home" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){
            set_iframe_height();
        });
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>