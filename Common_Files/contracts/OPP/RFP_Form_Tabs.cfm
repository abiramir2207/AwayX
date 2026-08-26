<!---
  * ==================================================================================================== 
  *    @File: 
  *  @Author: Chris Nguyen
  *    @Date: 2020 Oct
  * 
  * @Remarks: RFP Form Top Main Page with tabs support 
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
                display: flex;
                overflow: hidden;
            }
            aside {
                width: 141px;
                background-color: #f8fafc;
                height: 100vh;
                padding-left: 7px;
            }
            main {
                width: 100%;
            }
            nav {
                margin-top: 5px;
            }
            iframe {
                border: 0;
                width: 100%;
                height: 100vh;
            }
            .hidden {
                display: none;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
    
    <cfinclude template="/get_access_profile.cfm">

    <cf_cryp type="de" string="#trim(url.cid)#" key="#request.key#">

    <cfquery name="qComponents" datasource="#application.datasource#">
        SELECT 1
          FROM Program_Fixed_Component
         WHERE Deleted = 0 AND Program_ID = <cfoutput>#cryp.value#</cfoutput>
    </cfquery>
        

    <cfscript>
        variables.ContractMainID = cryp.value ;
        Contract_Main_ID         = cryp.value ;
        CSL_Contract_Main_ID     = Contract_Main_ID;
        CSL_CallingPageCode      = "gi"     ;
        form.contract_main_id    = cryp.value;

        request.already_had_components = qComponents.recordCount gt 0;
    </cfscript>

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~ Page Elements ~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <!--- left-hand side bar --->
    <aside>
        <cfinclude template="/common_files/contracts/contract_status_legend.cfm">
    </aside>

    <main>
        <!--- program header --->
        <cfset request.style = "2020">  
        <cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">

        <!--- navigation tabs --->
        <nav>  
            <ul>
                <li name="rfp_form" class="nav active">RFP Form</li>
                <!--- shows freight tab when user has freight view/create permission and component exist --->
                <cfif Get_Profile_Settings.RFP_Freight_View_Create>
                    <cfset freight_class = request.already_had_components ? '' : "hidden">                    
                    <cfoutput><li name="freight" class="nav"  #freight_class#>Freight</li></cfoutput>   <!--- #freight_class# --->
                </cfif>
            </ul>
        </nav>
        
        <!--- page body --->
        <cfoutput>
            <iframe name="rfp_form" src="rfp_form.cfm?#cgi.query_string#"></iframe>
            <iframe name="freight"  class="hidden"></iframe> <!--- class="hidden" src="rfp_Freight_form.cfm?cid=#trim(url.cid)#"--->
        </cfoutput>
    </main>



<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~ JavaScript ~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cfinclude template="/common_files/jQuery.cfm">
    <cf_include files="/script/javascript/loglevel/1.6.8/loglevel.min.js">

    <script>
        <cfif isDefined("request.is_developer") and request.is_developer>
            log.enableAll();
        </cfif>        

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
        $("li.nav").click(function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                make_tabs_inactive();   
                clicked_tab.addClass("active");

                let iframe = get_iframe( clicked_tab.attr("name") );
                iframe.show();
                if( clicked_tab.attr("name") == 'freight' ) {
                    // load freight content when it is empty
                    iframe[0].src = <cfoutput>"rfp_Freight_form.cfm?cid=#trim(url.cid)#"</cfoutput>
                }
            }
        });

        <!--- ~~~~~~ select default tab ~~~~~~ --->
        get_navli( "rfp_form" ).click();
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>