<!---
  * ==================================================================================================== 
  *    @File: \billbacks\2020\upload.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2020
  * 
  * @Remarks: Billbacks - upload tab (under home tab)
  *
  * ==================================================================================================== 
--->
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Upload</title>
</head>
<body>
	<cfsavecontent variable="upload_styles">
		<cf_include files="shared_styles.css, upload.css, /styles/tabnav-2020.css">
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( upload_styles )#">

	
	<!--- Tabs Navigation --->
	<nav style="background:#FFEDD2; padding-top:4px;">  
		<ul>
			<li name="uploadhistory" class="subnav" src="upload_and_history.cfm">Upload & History</li>
			<li name="corrections" class="subnav" src="corrections_main.cfm">Corrections</li>
			<li name="rawedi" class="subnav" src="/settings/EDI_Viewer/EDIViewer_Main.cfm">EDI</li>
		</ul>
	</nav>
	<!--- iframes for each sub-tab --->
	<main>
		<iframe name="uploadhistory"></iframe>
		<iframe name="corrections"></iframe>
		<iframe name="rawedi"></iframe>
	</main>	
    <cfinclude template="/common_files/jQuery.cfm">

	<script>

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            let iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 0;
            $("iframe" + (name ? "[name='" + name + "']" : '')).css("height", iframe_height + "px");
        }

        <!---  get navigation jQuery element based on name  --->
        function get_navli( name ) {
            return $("li.subnav[name='" + name + "']");
        }

        <!--- get iframe jQuery element based on name --->
        function get_iframe( name ) {
            return $("iframe[name='" + name + "']");
        }

        <!--- make active tab inactive, its iframe hidden --->
        function make_tabs_inactive() {
			$("li.subnav").each(function(){
                $(this).removeClass("active");
                get_iframe( $(this).attr("name") ).hide();
            });
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("nav").on("click", "li.subnav", function(event){
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

        <!--- ~~~~~~ make first tab active ~~~~~~ --->
        get_navli( "uploadhistory" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        
        $(window).resize(function(){ 
            set_iframe_height(); 
        });

	</script>
	<cfinclude template="/common_files/focus.cfm">
</body>
</html>