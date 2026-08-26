<!---
  * ==================================================================================================== 
  *    @File: \billbacks\2020\corrections_main.cfm
  *  @Author: Sharon Harris
  *    @Date: August 2020
  * 
  * @Remarks: Billbacks - Corrections sub-tab (under Upload tab)
  *			  See FlexDev\Forge\src\com\Billback\Upload\views\BBCorrectionsGrid.mxml
  *				This manages the corrections tabs - the main corrections list and the dynamic details tabs
  * ==================================================================================================== 
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Corrections</title>
</head>
<body>
	<!--- <p style="margin: 50px; color: gray; font-size: 26px;">Updating - coming soon...</p> --->
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
		<cf_include files="shared_styles.css, upload.css, /styles/tabnav-2020.css">
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">


    <!--- Tabs Navigation --->
    <nav>
        <ul>
			<li name="corr_list" class="nav">List</li>
        </ul>
    </nav>

    <!--- iframes --->
    <main>
		<iframe name="corr_list" src="corrections_list.cfm"></iframe>
    </main>
    <cfinclude template="/common_files/jQuery.cfm">
    <cf_include files="/common_files/noty.cfm">

	<script>
        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            let iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 10;
            $("iframe" + (name ? "[name='" + name + "']" : '')).css("height", iframe_height + "px");
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
			$("li.nav").each(function(){
                $(this).removeClass("active");
                get_iframe( $(this).attr("name") ).hide();
            });
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ create tab and iframe ~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function create_tab( data ) {
            if ($("li.nav").length > 3)
                noty( { text: "A maximum number of opened tabs<br>has been reached. Please select an existing tab<br> and click on 'x' to make room first."
                    ,type: 'information'
                    ,layout: 'center'
                    ,killer: true
                    ,timeout: 5000
            } );
            else {
                //console.log(data);
                glob.tab_counter++;
                const new_tab_name = data.bbHeaderID;
                // create a new tab when it does not exist
                if ($("li[name=" + new_tab_name + "]").length == 0) {
                    <!--- ~~~~~~ create tab with 'x' ~~~~~~~ --->
                    $("nav ul").append( $("<li></li>", { "class": "nav"
                                                            ,"text": 'ID:' + data.uploadID + '-' + data.bbHdrCounter + ' / ' + data.uploadType + ': (' + data.BBReference + ')'
                                                            ,"name": new_tab_name
                                                        }).append( $("<i></i>", { "title": "close tab"
                                                                                    ,"class": "closetab "
                                                                                    ,"text": "X" 
                                                                                } ) ) );

                    <!--- ~~ create iframe with same name ~~ --->
                    $("main").append( $("<iframe></iframe>", { src: 'corrections_detail.cfm?data='+encodeURIComponent(encodeURI(JSON.stringify(data))), name: new_tab_name, id: data.bbHeaderID }) );
                    set_iframe_height( new_tab_name );
                }

                <!--- ~~~~~~~~~ select new tab ~~~~~~~~~ --->
                get_navli( new_tab_name ).click();
                    //var frame = document.getElementById(data.bbHeaderID);
                    //console.log(frame);
                    //frame.contentWindow.load(data);
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
            $("iframe[name='" + clicked_tab.attr("name") + "']").remove();
            clicked_tab.remove();
            <!--- ~~~~~~ make first tab active ~~~~~~ --->
            get_navli( "corr_list" ).click();
        });
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ delete from Corrections_detail.cfm ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        function closeIFrame(name){
            //remove iframe and tab
             $("iframe[name='" + name + "']").remove();
             $("li[name='" + name + "']").remove();
             <!--- ~~~~~~ make first tab active ~~~~~~ --->
            get_navli( "corr_list" ).click();
        }

        <!--- ~~~~~~ make first tab active ~~~~~~ --->
        get_navli( "corr_list" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){
            set_iframe_height();
        });
    </script>

    <cfset request.focusHiLightOff = 1>

</body>
</html>