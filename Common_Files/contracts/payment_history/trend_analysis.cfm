<!---------------------------------------------------------------------------------------------------------------------
	  Template: \common_files\contracts\payment_history\trend_analysis.cfm
		  Date:  2016 September
		Author:  Milan Mushran
	   Purpose:  It has the "menu" code. It also includes other files.
---------------------------------------------------------------------------------------------------------------------->
<cfparam name="showType" default="ProgramVolume">

<cf_cryp type="en" string ="#ContractId#" key="#request.key#">
<cfset EncContractID = cryp.value>

<!DOCTYPE html>
	<html>
	<head>
	<style>
		ul, li,body, div,a
		 {
			margin: 0;
			padding: 0;
			border: 0;
			font-size: 100%;
			font: inherit;
			vertical-align: baseline;	
		}
		#hdr1 { width: 80%; padding-top: 5px; }
		header div { float: left; margin-top:-12px; margin-left:10px; margin-bottom:7px;}
		
		/* The actual color of he header comes from mega-dropdpwn.css. The color is being overridden for Chrome. This wont work for IE 9.
		For IE 9, "<header style="background-color:##FFCE84;">" is being used below.
		*/		
		header {
			<cfif showType eq "ProgramAccrual">
			background-image:linear-gradient(#FFE083,#FFE083) !important;
			height:140px !important;
			<cfelse>
			background-image:linear-gradient(#FFCE84,#FFCE84) !important;
			</cfif>
		}
		h2 {
			background-color: #FFCE84;
			height: 26px;
			line-height: 26px;
			padding-left: 7px;
			font-size: 1.3em;
		}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }		
		div.export {float:right;}
		div.itemDetails {float:right}
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		.drpDownWidth{width:95%}
		table.dataTable thead th{ font-weight: normal; font-family: "Arial"}
	</style>
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/styles/mega-dropdown.css, /script/javascript/modernizr.js, /script/javascript/jquery.menu-aim.js, /script/css/smoothness/jquery-ui-1.11.4.custom.min.css">
		<cf_include files="/script/javascript/circliful-master/js/jquery.circliful.min.js,/script/javascript/circliful-master/css/jquery.circliful.css">
		<cf_include files="/Script/javascript/numeral.min.js">

	<script>
		function viewContract(program_id)
		{
		NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id, 'ViewProgram','800','600','Yes', 'Yes');
		}
	</script>	
	</head>
	
	<cfset Business_Segments_On = 0 />
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfif businessSegManager.isEnabled()>
		<cfset Business_Segments_On = 1 />
	</cfif>
	
	<cfset appSettings = application.appsettingsGet />
	<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
	<cfset IsAccrualExist = PaymentHistoryManager.getAccrualExist(contract_number=contractNumber,contractMainID=contractId)>
	<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
	<cfset getdateInfo = PaymentHistoryManager.getdateInfo(contractNumber, ContractId)>
	<cfset getTotalAccruedAndSpentDollars = PaymentHistoryManager.getTotalAccruedAndSpentDollars(contractNumber, ContractId)>
	<cfset qgetEffectiveDates = PaymentHistoryManager.getEffectiveDateInfo(contractNumber, ContractId)>

	<!--- DAYS --->
	<cfset TotalDays = getdateInfo.TotalDays>
	<cfset DaysElapsed = getdateInfo.DaysElapsed>
	<cfset DaysRemaining = getdateInfo.DaysRemaining>
	<cfset DaysReminingPercent = getdateInfo.DaysReminingPercent>

	<!--- DOLLARS --->
	<cfset TotalAccruedDollars =  getTotalAccruedAndSpentDollars.Total_Accrued_Dollars>
	<cfset TotalSpentDollars =  getTotalAccruedAndSpentDollars.Total_Spent_Dollars>
	<cfset TotalRemainingDollars =  getTotalAccruedAndSpentDollars.Total_Remaining_Dollars>
	<cfset TotalRemainingPercent =  getTotalAccruedAndSpentDollars.Total_Remaining_Percent>

	<cfif Business_Segments_On eq 1>
		<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(contractId) />
		<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
	</cfif>					

	<cfset headerText = "">
	
	<cfif showType eq "ItemsClaimedNotOnProgram">
		<cfset headerText = "#ContractNumber#: #UCASE(application.returned_customer_setting.item_label)# CLAIMED NOT ON PROGRAM">
	<cfelseif showType eq "ProgramItemsNotClaimed">
		<cfset headerText = "#ContractNumber#: #UCASE(application.returned_customer_setting.item_label)# NOT BEING PURCHASED OR CLAIMED">
	<cfelseif showType eq "ProgramPayeesNotClaiming">
		<cfset headerText = "#ContractNumber#: PAYEES NOT PURCHASING OR CLAIMING">
	<cfelseif showType eq "ProgramVolume">
		<cfset headerText = "#contractNumber#: VOLUME / TRADE SPEND SUMMARY">
	<cfelseif showType eq "ProgramAccrual">
		<cfset headerText = "#contractNumber#: ACCRUAL DATA">
	</cfif>

	<!------------------------------->
	<!---  get the required data  --->
	<!------------------------------->
	<body>
	<br>
	<!----------------------------->
	<!--- display menu + header --->
	<!----------------------------->
	<cfsavecontent variable="variables.uncompressed">
	<cfoutput>
	<!--- The actual color of he header comes from mega-dropdpwn.css. The color is being overridden for IE 9.  Tis wont work for Chrome. 
	For chrome, "background-image" had to be used (code above)
	--->
	<header style="background-color:##FFCE84;">
			<div class="cd-dropdown-wrapper">
				<a class="cd-dropdown-trigger" href="##0">menu</a>
				<nav class="cd-dropdown">
					<!--- <h2>Title</h2>
					<a href="#0" class="cd-close">Close</a> --->
					<ul class="cd-dropdown-content" style="width:250px;background-color:##FAFAFA;"><!--- F6F6F6 --->
						<li><a href="##" onClick="viewData('#contractNumber#','#ContractId#','ItemsClaimedNotOnProgram');">#lcase(application.returned_customer_setting.item_label)# claimed not on the program</a></li>
						<li><a href="##" onClick="viewData('#contractNumber#','#ContractId#','ProgramItemsNotClaimed');">#lcase(application.returned_customer_setting.item_label)# not being purchased or claimed</a></li>
						<li><a href="##" onClick="viewData('#contractNumber#','#ContractId#','ProgramPayeesNotClaiming');">payees not purchasing or claiming</a></li>
						<li><a href="##" onClick="viewData('#contractNumber#','#ContractId#','ProgramVolume');">volume / trade spend</a></li>
					</ul> <!--- .cd-dropdown-content --->
				</nav> <!--- .cd-dropdown --->
			</div> <!--- .cd-dropdown-wrapper --->
			<div class="header" id="hdr1">				
					<cfif showType neq "ProgramAccrual">
						<h2>#headerText#</h2>
					<cfelse><br/>
					<!--- For "program accrual", we show below on the header --->
					<span style="width:47%;float:left">
						<a href='##' onClick="viewContract('#EncContractID#')">#getcontractInfo.Contract_Number#</a>
						&nbsp;&nbsp;#getcontractInfo.contract_title#<br/>
						<b>Template:</b>&nbsp;&nbsp;#getcontractInfo.created_type#<br/>
						<b>RSP:</b>&nbsp;&nbsp;#getcontractInfo.RSP#<br/>
						<b>Delivery Period</b>:&nbsp;&nbsp;#Dateformat(getdateInfo.start_date,"mm/dd/yyyy")# - #Dateformat(getdateInfo.end_date,"mm/dd/yyyy")#<br/>
						<b>Approved Date:</b>&nbsp;&nbsp;#getcontractInfo.Approval_Date#<br/>
						<cfif Business_Segments_On eq 1>
						<b>Segment:</b>&nbsp;&nbsp;#qGetThisBusSegment.Business_Unit_Desc#<br/>
						</cfif>
						<cfif appSettings.getReleaseSettlement()>
							<cfif getcontractInfo.Released eq 1 or getcontractInfo.Released eq 2>
							<b>Released Date:</b>&nbsp;&nbsp;#getcontractInfo.Released_Date#<br/>
							<b>Released By:</b>&nbsp;&nbsp;#getcontractInfo.ReleasedBy#
							</cfif>
						</cfif>		
					</span>
					<div id="bar1" style="width:20%;margin:auto;float:left;position:relative;"></div>
					<div id="bar2" style="width:20%;margin:auto;float:right;position:relative;"></div>
					<span style="width:13%;vertical-align: middle;text-align: center;font-weight:bold;">
					Accrual Overview
					<cfif qgetEffectiveDates.Start_Date eq "" AND qgetEffectiveDates.End_Date eq "" AND qgetEffectiveDates.cancelled_by neq "">
					<br/> <br/> This program was cancelled by #qgetEffectiveDates.cancelled_by# on #qgetEffectiveDates.cancelled_Date#
					</cfif>
					</span>
				</cfif>
			</div>
	</header>
	</cfoutput>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
		<script>
		jQuery(document).ready(function($){
			$(document).mouseup(function (e) {
				var container = $(".cd-dropdown-content, .cd-dropdown .cd-close, .cd-dropdown-trigger");
				if (!container.is(e.target) // if the target of the click isn't the container...
					&& container.has(e.target).length === 0) // ... nor a descendant of the container
				{
					var navIsVisible = ( !$('.cd-dropdown').hasClass('dropdown-is-active') ) ? true : false;
					if( !navIsVisible ) {
						toggleNav();
					}
				}
			});

			//open/close mega-navigation
			$('.cd-dropdown-trigger').on('click', function(event){
				event.preventDefault();
				toggleNav();
			});

			//close meganavigation
			$('.cd-dropdown .cd-close').on('click', function(event){
				event.preventDefault();
				toggleNav();
			});

			//on desktop - differentiate between a user trying to hover over a dropdown item vs trying to navigate into a submenu's contents
			var submenuDirection = ( !$('.cd-dropdown-wrapper').hasClass('open-to-left') ) ? 'right' : 'left';
			$('.cd-dropdown-content').menuAim({
				activate: function(row) {
					$(row).children().addClass('is-active').removeClass('fade-out');
					if( $('.cd-dropdown-content .fade-in').length == 0 ) $(row).children('ul').addClass('fade-in');
				},
				deactivate: function(row) {
					$(row).children().removeClass('is-active');
					if( $('li.has-children:hover').length == 0 || $('li.has-children:hover').is($(row)) ) {
						$('.cd-dropdown-content').find('.fade-in').removeClass('fade-in');
						$(row).children('ul').addClass('fade-out')
					}
				},
				exitMenu: function() {
					$('.cd-dropdown-content').find('.is-active').removeClass('is-active');
					return true;
				},
				submenuDirection: submenuDirection,
			});

			//submenu items - go back link
			$('.go-back').on('click', function(){
				var selected = $(this),
					visibleNav = $(this).parent('ul').parent('.has-children').parent('ul');
				selected.parent('ul').addClass('is-hidden').parent('.has-children').parent('ul').removeClass('move-out');
			});

			function toggleNav(){
				var navIsVisible = ( !$('.cd-dropdown').hasClass('dropdown-is-active') ) ? true : false;
				$('.cd-dropdown').toggleClass('dropdown-is-active', navIsVisible);
				$('.cd-dropdown-trigger').toggleClass('dropdown-is-active', navIsVisible);
				if( !navIsVisible ) {
					$('.cd-dropdown').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',function(){
						$('.has-children ul').addClass('is-hidden');
						$('.move-out').removeClass('move-out');
						$('.is-active').removeClass('is-active');
					});
				}
			}

		});

		function viewData(contractNumber,ContractId,type)
		{
			window.location = "trend_analysis.cfm?showType=" + type + "&contractNumber=" + contractNumber+"&ContractId=" + ContractId;
		}
	
	/* HEADER CODE (START) */
	<cfif showType eq "ProgramAccrual">
		var TotalDays = '<cfoutput>#TotalDays#</cfoutput>'
		var DaysElapsed = '<cfoutput>#DaysElapsed#</cfoutput>'
		var DaysRemaining = '<cfoutput>#DaysRemaining#</cfoutput>'
		var TotalAccruedDollars =  '<cfoutput>#TotalAccruedDollars#</cfoutput>'
		var TotalSpentDollars =  '<cfoutput>#TotalSpentDollars#</cfoutput>'
		var TotalRemainingDollars =  '<cfoutput>#TotalRemainingDollars#</cfoutput>'
		var TotalRemainingPercent =  '<cfoutput>#TotalRemainingPercent#</cfoutput>'
		var DaysReminingPercent = '<cfoutput>#DaysReminingPercent#</cfoutput>'

		if(DaysRemaining < 0){
			DaysRemaining = 0;
		}

		var dollar_foregroundColor = '#228B22';

		if(TotalRemainingDollars < 0){
			dollar_foregroundColor = '#FF0000';
		}

		var Accrued_Heading = '<tspan  style="font-weight: bold;">Dollars Remaining</tspan><tspan  y="133" x="65" style="font-weight: bold;">Accrued $: </tspan>'
		var Accrued_Amt =  '<tspan  y="133" x="145">' + numeral(TotalAccruedDollars).format( "(0,0.00)" ) + '</tspan>'
		var Spent_Heading = '<tspan  y="143" x="57" style="font-weight: bold;">Spent $: </tspan>'
		var Spent_Amt =  '<tspan  y="143" x="145">' + numeral(TotalSpentDollars).format( "(0,0.00)" ) + '</tspan>'
		var Remaining_Heading = '<tspan  y="153" x="70" style="font-weight: bold;">Remaining $: </tspan>'
		var Remaining_Amt =  '<tspan  y="153" x="145">' + numeral(TotalRemainingDollars).format( "(0,0.00)" ) + '</tspan>'

		var Days_Heading = '<tspan  style="font-weight: bold;">Days Remaining</tspan><tspan  y="133" x="65" style="font-weight: bold;">Total Days: </tspan>'
		var Days_Num =  '<tspan  y="133" x="145">' + TotalDays + '</tspan>'
		var Days_Elapsed_Heading = '<tspan  y="143" x="58" style="font-weight: bold;">Elapsed: </tspan>'
		var Days_Elapsed_Num =  '<tspan  y="143" x="145">' + DaysElapsed + '</tspan>'
		var Days_Remaining_Heading = '<tspan  y="153" x="65" style="font-weight: bold;">Remaining: </tspan>'
		var Days_Remaining_Num =  '<tspan  y="153" x="145">' + DaysRemaining + '</tspan>'

		var total_remaining_percent = numeral(TotalRemainingPercent).format('0.00');

			total_remaining_percent_text = total_remaining_percent + '%'
			/* If "total_remaining_percent" is a negative number, then the progress bar should show 100% color, but the text should should display 0% */
			if(total_remaining_percent < 0){
				total_remaining_percent = 100;
				total_remaining_percent_text = numeral(TotalRemainingPercent) + '%';
			}

		var days_remaining_percent = DaysReminingPercent;
			days_remaining_percent_text = days_remaining_percent + '%'
			/* If "days_remaining_percent" is a negative number, then the progress bar should show 100% color, but the text should should display 0% */
			if(days_remaining_percent < 0){
				days_remaining_percent = 100;
				days_remaining_percent_text = '0%';
			}

		$("#bar1").circliful({
			animationStep: 5,
			foregroundBorderWidth: 5,
			backgroundBorderWidth: 15,
			percent: total_remaining_percent,
			foregroundColor: dollar_foregroundColor,
			halfCircle: 1,
			/*"replacePercentageByText" is needed because of the following -
			When the number is negative, we need to show 100% color,but the text should display 0%.
			*/
			replacePercentageByText:total_remaining_percent_text,
			text: Accrued_Heading + Accrued_Amt + Spent_Heading + Spent_Amt + Remaining_Heading + Remaining_Amt
		});
		$("#bar2").circliful({
			animationStep: 5,
			foregroundBorderWidth: 5,
			backgroundBorderWidth: 15,
			percent: days_remaining_percent,
			halfCircle: 1,
			/*"replacePercentageByText" is needed because of the following -
			When the number is negative, we need to show 100% color,but the text should display 0%.
			*/
			replacePercentageByText:days_remaining_percent_text,
			text: Days_Heading + Days_Num + Days_Elapsed_Heading + Days_Elapsed_Num + Days_Remaining_Heading + Days_Remaining_Num
		});
	</cfif>
	/* HEADER CODE (END) */
		
		</script>

		<cfif showType eq "ItemsClaimedNotOnProgram">
			<cfinclude template="view_items_claimed_not_on_program.cfm">
		<cfelseif showType eq "ProgramItemsNotClaimed">
			<cfinclude template="view_program_items_not_claimed.cfm">
		<cfelseif showType eq "ProgramPayeesNotClaiming">
			<cfinclude template="view_program_payees_not_claiming.cfm">
		<cfelseif showType eq "ProgramVolume">
			<cfinclude template="volume_and_trade_spend_analysis.cfm">
		<cfelseif showType eq "ProgramAccrual">
			<cfinclude template="accrual_info.cfm">
		</cfif>
	</body>
	</html>

