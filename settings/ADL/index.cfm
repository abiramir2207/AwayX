<!---
  * ==================================================================================================== 
  *    @File: /settings/ADL/index.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2021
  * 
  * @Remarks: Authorized Distribution Lists Main Page
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
			body {
				background-color: #EDEEF2;
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
            }
            .hidden {
                display: none;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    
    <cfset pagetitle = "AUTHORIZED DISTRIBUTION LISTS">
    <cfinclude template="/settings/settings_title.cfm">
        
    <!--- Tabs Navigation --->
    <nav>  
        <ul>
			<li name="list" class="nav">Lists</li>
            <li name="edit" class="nav hidden"></li>
            <li name="new" class="nav hidden"></li>
        </ul>
    </nav>
    
    <!--- iframes for each tab content --->
    <main>
		<iframe name="list" src="adl_list.cfm"></iframe>
		<iframe name="edit" class="hidden"></iframe>
		<iframe name="new" class="hidden"></iframe>
    </main>


    <cfinclude template="/common_files/jQuery.cfm">

    <script>
        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

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
        function edit_tab( adl_id, adl_label ) {
            get_iframe( "edit" ).attr("src", "adl_edit.cfm?id=" + adl_id ).removeClass("hidden");
            set_iframe_height( "edit" );
			// let label_with_close = adl_label +"<i title:'close tab'; class='closetab'>X</i>";
            // get_navli( "edit" ).append("Edit "+label_with_close);
            // get_navli( "edit" ).removeClass("hidden").click();
            get_navli( "edit" ).removeClass("hidden").text("Edit "+adl_label).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ makes create new iframe visible~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function create_new_tab() {
            get_iframe( "new" ).attr("src", "adl_new.cfm").removeClass("hidden");
            set_iframe_height( "new" );
            get_navli( "new" ).removeClass("hidden").text("New ADL").click();
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
			debugger;
            let clicked_tab = $(this).parent("li.nav");
            $("iframe[name='" + clicked_tab.attr("name") + "']").remove();
            clicked_tab.remove();
            <!--- ~~~~~~ make home tab active ~~~~~~ --->
            get_navli( "list" ).click();
        });

        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "list" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){ 
            set_iframe_height(); 
        });


		
        function load_adl(adl_title, adlID, url) {
            $("li[name=search]").removeClass("active");
            // populate 2nd tab title with selected ID
            $("li[name=edit]").text( adl_title ).show().addClass("active");

            // remove previous form and iframe to get rid of previous content
            $("#target form").remove();
            $("main iframe[name=edit]").remove();

            // add new iframe
            $("main").append( $("<iframe/>", {name:"edit"}) );

            // add new form
            $("#target").append(
                $("<form/>", { name:"load_adl", action:"/common_files/processing.cfm", method:"post", target:"edit" }).append(
                    $("<input/>", { type:"hidden", name:"adlID", value:adlID })
                )
            );

            $("iframe[name=list]").hide();
            $("iframe[name=edit]").show();
            $("form[name=load_adl]").submit();
        }
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>