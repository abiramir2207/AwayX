<!---
  * ==================================================================================================== 
  * 	@File: \Common_Files\contracts\payment_history\payment_history.cfm
  *  	@Modified by Deepa Kunnath on 2/23/2021
  * 
  *
  * ==================================================================================================== 
--->
<cfparam name="url.ContractId" default="0">
<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset IsAccrualExist = PaymentHistoryManager.getAccrualExist(contract_number=getcontractInfo.contract_Number,contractMainID=contractId)>
	
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Payment History</title>
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
                padding-top: 15px;
                /* border: 5px solid yellow; */
            }
            .hidden {
                display: none;
            }
            div#planner{
                display: none;
            }
			.addPadding {
                 padding-bottom: 5px;
				 padding-left: 5px;
				 padding-right: 5px;
            }
        </style>
    </cfsavecontent>
    <cfhtmlhead text="#application.util.string.compress( styles )#">
        
    <!--- Tabs Navigation --->
    <nav>  
        <ul>
			<li name="tabBillback" class="nav">Spent</li>
			<cfif IsAccrualExist>
				<li name="tabAccrual" class="nav">Accruals</li>
			</cfif>
            <li name="tabResearch" class="nav">Research</li>
        </ul>
    </nav>
    
    <!--- iframes --->
	<cfoutput>
    <main>
		<iframe name="tabBillback" src="/Common_Files/contracts/view_contract_payment_history.cfm?DisplayData=1&ContractId=#url.ContractId#"></iframe>
		<iframe name="tabAccrual" class="hidden"></iframe>
		<iframe name="tabResearch" class="hidden addPadding"></iframe>
    </main>
	</cfoutput>

    <div id="planner"></div>

    <cfinclude template="/common_files/jQuery.cfm">
    <cf_include files="/script/javascript/loglevel/1.6.8/loglevel.min.js">

	
	<script>
        log.disableAll();

        <!--- ~~~~~~~~~~ global variables defined inside 'glob' object ~~~~~~~~~~ --->
        let glob = { tab_counter: $("li.nav").length };

        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        function set_iframe_height( name ) {
            glob.iframe_height = $(window).innerHeight() - $("iframe:first-child")[0].offsetTop - 10;
            log.debug($(window).innerHeight(), $("iframe:first-child")[0].offsetTop, glob.iframe_height);
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
        // $("nav").on("click", "li.nav", function(event){
        $("li.nav").click(function(event){
            let clicked_tab = $(event.target);
            if ( !clicked_tab.hasClass("active") ) {
                make_tabs_inactive();   
                clicked_tab.addClass("active");

                let iframe = get_iframe( clicked_tab.attr("name") );
				
				
				if (iframe.attr("src")) {
                    // do nothing
                }
                else {
                    <cfoutput>
                    if (iframe.attr("name") === 'tabAccrual') {
                        iframe.attr("src", "/common_files/contracts/payment_history/accrual_info_fiscal_period_details.cfm?ContractNumber=#getcontractInfo.Contract_Number#&ContractId=#url.ContractId#&showType=ProgramAccrual").removeClass("hidden");
                    }
					else if (iframe.attr("name") === 'tabResearch') {
                        iframe.attr("src", "/common_files/contracts/payment_history/trend_analysis.cfm?ContractNumber=#getcontractInfo.Contract_Number#&ContractId=#url.ContractId#").removeClass("hidden");
                    }
                    </cfoutput>
                }
				
                iframe.show();
            }
        });


        <!--- ~~~~~~ make home tab active ~~~~~~ --->
        get_navli( "tabBillback" ).click();
        <!--- ~~~~~~ adjust iframe height ~~~~~~ --->
        set_iframe_height();

        $(window).resize(function(){ 
            // console.log("search_billbacks.cfm");
            set_iframe_height(); 
        });


    </script>
	
		
    <cfset request.focusHiLightOff = 1>
</body>
</html>