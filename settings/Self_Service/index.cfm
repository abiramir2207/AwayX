<!---
  * ====================================================================================================
  *    @File:   AwayX\settings\Self_Service\index.cfm
  *    @Author: Anand Rao
  *    @Date:   16 Sep 2024
  *
  *    @Remarks: Planner Volume Upload Main Page
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
        <cf_include files="/styles/reset2.css, /styles/tabnav-2020.css">
        <style>
            * {
                margin: 0;
                padding: 0;
            }
            iframe {
                border: 0;
                width: 100%;
                height: calc(100vh - 70px);
            }
            .hidden {
                display: none;
            }
            nav li.uploadFile {
                padding: 0 2rem;
            }
        </style>
    </cfsavecontent> 
    <cfhtmlhead text="#application.util.string.compress( styles )#"> 

    <cfset pagetitle = "SYSTEM ADMINISTRATION: Self Service Update/Delete Page">
    <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
    <cfinclude template="/settings/settings_title.cfm">
    <cfparam name="url.fromPlanner" default="0">
    <cfparam name="url.plannerID" default="0">
    <cfparam name="url.plannerTemplateID" default="0">
    <cfparam name="url.customerType" default="Direct">
    <cfparam name="url.customerLevel" default="0">
    <cfparam name="url.segment" default="0">
    <cfparam name="url.startDate" default="0">
    <cfparam name="url.endDate" default="0">

    <!--- Tabs Navigation --->
    <nav>
        <ul>
            <li name="uploadFile" class="nav uploadFile active">Self Serve</li>
            <li name="selfServeHistory" class="nav">Upload History</li>
            <!--- li name="current" class="nav">Current Volume Plan</li --->
        </ul>
    </nav>

    <main>
    <cfoutput><iframe name="uploadFile" class="active" src="Self_Serve.cfm?fromPlanner=#url.fromPlanner#&plannerID=#url.plannerID#&plannerTemplateID=#url.plannerTemplateID#"></iframe></cfoutput>
        <iframe name="selfServeHistory" src="" class="hidden"></iframe>
       
    </main>
 
    <cfinclude template="/common_files/jQuery.cfm">

    <script>
        <!---  get navigation jQuery element based on name  --->
        function get_navli( name ) {
            return $("li.nav[name='" + name + "']");
        }

        <!--- get iframe jQuery element based on name --->
        function get_iframe( name ) {
            return $("iframe[name='" + name + "']");
        }

        function click_upload() {
            $( "li[name=upload]" ).click();
        }

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $( "li.nav" ).click( function( event ){
            const clicked_tab = $( event.target );
            // tab already active, bail out
            if ( clicked_tab.hasClass( "active" ) )
                return;

            const clicked_name = clicked_tab.attr( "name" );
            // hide inactive iframes
            $( "li.nav" ).each( function() {
                const tab_name = $( this ).attr( "name" );
                if ( tab_name !== clicked_name ) {
                    get_iframe( tab_name ).hide();
                    $( this ).removeClass( "active" );
                }
            });

            clicked_tab.addClass( "active" );

            // display clicked iframe
            const iframe = get_iframe( clicked_name );
            if ( iframe.attr( "src" ) === '' ) {
                    if ( clicked_name === "selfServeHistory" ) {
                        iframe.attr( "src", "Self_Serve_History.cfm?<cfoutput>fromPlanner=#url.fromPlanner#&plannerID=#url.plannerID#&plannerTemplateID=#url.plannerTemplateID#</cfoutput>" );
                    }
                    /* else{
                        iframe.attr( "src", "current.cfm?<cfoutput>fromPlanner=#url.fromPlanner#&plannerID=#url.plannerID#&plannerTemplateID=#url.plannerTemplateID#&customerType=#url.customerType#&customerLevel=#url.customerLevel#&Bsegment=#url.segment#&startdate=#url.startdate#&enddate=#url.enddate#</cfoutput>" );
                    } */

                }

            iframe.show();
        });
    </script>

    <!--- skipping jQuery input focusing logic --->
    <cfset request.focusHiLightOff = 1>
</body>
</html>