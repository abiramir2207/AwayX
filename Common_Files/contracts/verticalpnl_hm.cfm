<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\verticalpnl_hm.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 January
  *
  * @Remarks: - This file supports vertical P&L for Huhtamaki
  *
  *
  * ====================================================================================================
-->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vertical P&L</title>
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
                overflow: hidden;
            }
            main {
                width: 100%;
            }
            nav {
                position: relative;
                top: 0;
                left: 0;
                height: auto;
                margin-top: 5px;
                z-index: 99;
            }
            iframe {
                border: 0;
                width: 100%;
                position: absolute;
                top: 0;
                height: 100vh;
                padding-top: 60px;
                z-index: 1;
            }
            .hidden {
                display: none;
            }
            div.prg-header2 {
                width: 99%;
                margin: 3px 0.5%;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
        
    <main>
        <CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
        <cfset form.contract_main_id = cryp.value>
            
        <!--- show program basic info in the header --->
        <cfset request.style = "2020">
        <div class="prg-header2">
            <cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">
            <style>
                .prg-header {
                    border: 1px solid blue;
                }
            </style>
        </div>
    
        <!--- Tabs Navigation --->
        <nav>  
            <ul>
                <li name="pnl" class="nav">Vertical P&L</li>
                <li name="summary" class="nav">P&L Summary</li>
            </ul>
        </nav>
        
        <!--- iframes --->
        <cfoutput>
            <main>
                <!--- load vertical p&l content right away --->
                <!--- <cfset cfm_file = "/common_files/processing.cfm"
                                    & "?actualPage=/common_files/contracts/contract_profit_analysis.cfm"
                                        & "&verticalPNL=1"
                                        & "&CID=#url.cid#"
                                        & "&displayPreviousVersionMargin=0"
                                        & "&margin_version=current"
                                        & "&bReset=0"> --->
                <!--- <cfset cfm_file = "/common_files/contracts/contract_profit_analysis.cfm"
                                        & "?verticalPNL=1"
                                        & "&CID=#url.cid#"
                                        & "&displayPreviousVersionMargin=0"
                                        & "&margin_version=current"
                                        & "&bReset=0"> --->

                <!--- if the contract is already approved, don't re-calc margin For "Custom RFP" logic.  Display Approved Margins from Contract_product_Margin_Approved table 
                                This same logic is also in /Common_Files/contracts/layered_program_approval_h.cfm  When the call to get Marginb data is made --->
                <cfif GetContractInfo.Approved EQ 1>
                    <cfset cfm_file = "/Common_Files/contracts/layered_approval_include_hm.cfm"
                                            & "?verticalPNL=1"
                                            & "&CID=#url.cid#"
                                            & "&displayPreviousVersionMargin=0"
                                            & "&margin_version=approved"
                                            & "&bReset=0">
                <cfelse>
                    <cfset cfm_file = "/common_files/contracts/contract_profit_analysis.cfm"
                                        & "?verticalPNL=1"
                                        & "&CID=#url.cid#"
                                        & "&displayPreviousVersionMargin=0"
                                        & "&margin_version=current"
                                        & "&bReset=0"> 
                </cfif>

                <iframe name="pnl" src="#cfm_file#"></iframe>
                <!--- hide p&l summary --->
                <iframe name="summary" class="hidden"></iframe>
            </main>
        </cfoutput>
    </main>

    <cfinclude template="/common_files/jQuery.cfm">

    <script>
        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            // glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 10;
            // $("iframe" + (name ? "[name='" + name + "']" : '')).css("height", glob.iframe_height + "px");
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
        <!--- ~~~~ tab click event handler ~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        $("li.nav").click(function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                make_tabs_inactive();   
                clicked_tab.addClass("active");

                let clicked_tab_name = clicked_tab.attr("name");
                let iframe = get_iframe( clicked_tab_name );

                if (clicked_tab_name === "summary" ) {  //&& !iframe.attr("src")
                    <cfoutput>iframe.attr("src", "/common_files/contracts/verticalpnl_summary_hm.cfm?CID=#URL.CID#&margin_version=#margin_version#");</cfoutput>
                }
                iframe.show();
            }
        });

        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "pnl" ).click();
    </script>

    <cfset request.focusHiLightOff = 1>
</body>
</html>