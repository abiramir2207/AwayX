<!---------------------------------------------------------------------------------------------------------------------
	  Template: \common_files\contracts\payment_history\trend_analysis.cfm
		  Date:  2016 September
		Author:  Milan Mushran
	   Purpose:  It has the "menu" code. It also includes other files.
---------------------------------------------------------------------------------------------------------------------->


<cf_cryp type="en" string ="#ContractId#" key="#request.key#">
<cfset EncContractID = cryp.value>
<cfparam name="plannerId" default="0">

	
<!DOCTYPE html>
	<html>
	<head>
	<style>
		<cfif plannerId eq 0>
			ul, li,body, div,a
			{
				font-size: 100%;
				font: inherit;
				vertical-align: baseline;	
			}	
			header {
				background-color: #FFE083;
				height:100px !important;
				margin-bottom:4px;
			}
		<cfelse>
			/* Use Planner color */
			header {
				background-color: #C4DCF1;
				height:100px !important;
				margin-bottom:4px;
			}

			li,body, div,a
			{
				vertical-align: baseline;	
			}
		</cfif>

		#hdr1 { 
			display: flex;
			margin-left:10px; 
			padding-top: 5px;
			width: 80%;
		}

		section:not(:last-child) {
			margin-right: 80px;
		}

		#sectionDollars {
            margin-left: 40px;
        }

		/* Progress bar layout */
		#dollarsProgress,
		#daysProgress  {
			margin-bottom: 7px;
			width:150px;
		}

		.val-right {
			float: right;
			padding-right: 30px;
		}


		table.datagrid {  font-size: 1.05em; table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; font-weight: normal;}		
		div.export {float:right;}
		div.itemDetails {float:right}
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		.drpDownWidth{width:auto}

		span.neg { 
			color: #FF0000; 
		}


	</style>
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/script/javascript/modernizr.js, /script/javascript/jquery.menu-aim.js, /script/css/smoothness/jquery-ui-1.11.4.custom.min.css">
		<cf_include files="/script/javascript/progress-bar/progress-bar.css, /script/javascript/progress-bar/progress-bar.js">
		<cf_include files="/Script/javascript/numeral.min.js">
		
	<style>
		/* NOTE: The progress-bar override styles must be defined AFTER the progress-bar.css, to take priority */
		.dollars {
			background-color: #228b22;
		}
		.days {
			/* background-color: #3498db; */
			background-color: #2079b4;
		}
		.dollars-gone {
			background-color: #CCCCCC
		}
	</style>

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
	<cfset IsAccrualExist = PaymentHistoryManager.getAccrualExist(contract_number=contractNumber,contractMainID=contractId, plannerID=plannerID)>
	<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
	<cfset getdateInfo = PaymentHistoryManager.getdateInfo(contractNumber, ContractId, plannerID)>
	<cfset getTotalAccruedAndSpentDollars = PaymentHistoryManager.getTotalAccruedAndSpentDollars(contractNumber, ContractId, plannerID)>
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

	<cfif Business_Segments_On eq 1 and plannerId eq 0>
		<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(contractId) />
		<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
	</cfif>					


	<cfset headerText = "#contractNumber#: ACCRUAL DATA">


	<!------------------------------->
	<!---  get the required data  --->
	<!------------------------------->
	<body>
	
	<!----------------------------->
	<!--- display menu + header --->
	<!----------------------------->
	<cfsavecontent variable="variables.uncompressed">
	<cfoutput>
	<header>		
		<div id="hdr1">				
			<!--- For "program accrual", we show below on the header --->
			<cfif plannerId eq 0>
				<section style="margin-top: 4px;">
					<a href='##' onClick="viewContract('#EncContractID#')">#getcontractInfo.Contract_Number#</a>
					&nbsp;&nbsp;#getcontractInfo.contract_title#<br/>
					<b>Template:</b>&nbsp;&nbsp;#getcontractInfo.created_type#<br/>
					<b>RSP:</b>&nbsp;&nbsp;#getcontractInfo.RSP#<br/>
					<b>Delivery Period</b>:&nbsp;&nbsp;#Dateformat(getdateInfo.start_date,"mm/dd/yyyy")# - #Dateformat(getdateInfo.end_date,"mm/dd/yyyy")#<br/>
					<b>Approved Date:</b>&nbsp;&nbsp;#getcontractInfo.Approval_Date#<br/>
					<cfif Business_Segments_On eq 1 and plannerId eq 0>
					<b>Segment:</b>&nbsp;&nbsp;#qGetThisBusSegment.Business_Unit_Desc#<br/>
					</cfif>
					<cfif appSettings.getReleaseSettlement()>
						<cfif getcontractInfo.Released eq 1 or getcontractInfo.Released eq 2>
						<b>Released Date:</b>&nbsp;&nbsp;#getcontractInfo.Released_Date#<br/>
						<b>Released By:</b>&nbsp;&nbsp;#getcontractInfo.ReleasedBy#
						</cfif>
					</cfif>		
				</section>

				<cfif qgetEffectiveDates.Start_Date eq "" AND qgetEffectiveDates.End_Date eq "" AND qgetEffectiveDates.cancelled_by neq "">
					<section style="font-weight:bold;">
						This program was cancelled by #qgetEffectiveDates.cancelled_by# on #qgetEffectiveDates.cancelled_Date#
					</section>
				</cfif>
			</cfif>
			<section id="sectionDollars">
				<div style="line-height:1.6em; text-align:center">Dollars Remaining:</div>
				<div id="dollarsProgress"></div>	<!--- Progress bar --->

				<!--- Values set via ids --->
				<div>Accrued:
					<span id="Accrued_Amt" class="val-right"></span>
				</div>
				<div>Spent:
					<span id="Spent_Amt" class="val-right"></span>
				</div>
				<div>Remaining:
					<span id="Remaining_Amt" class="val-right"></span>
				</div>
			</section>

			<section id="sectionDays">
				<div style="line-height:1.6em; text-align:center">Days Remaining:</div>
				<div id="daysProgress" style="width:150px;"></div>	<!--- Progress bar --->

				<!--- Values set via ids --->
				<div>Total Days:
					<span id="Days_Num" class="val-right"></span>
				</div>
				<div>Elapsed:
					<span span id="Days_Elapsed_Num" class="val-right"></span>
				</div>
				<div>Remaining:
					<span id="Days_Remaining_Num" class="val-right"></span>
				</div>
			</section>

		</div>
	</header>
	</cfoutput>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
		<script>

		var paramsDollars = {id: "dollarsProgress", barStyle: "dollars", bIndicate: true};
		var paramsDays = {id: "daysProgress", barStyle: "days", bIndicate: true};
		var dollarsProgress, daysProgress;
		
		jQuery(document).ready(function($) {
			
			// If no remaining dollars, show progress in red
			if(TotalRemainingDollars < 0) {
				paramsDollars.barStyle = "dollars-gone";
			}
			// Setup progress bars
			dollarsProgress = progressBar(paramsDollars);
			daysProgress = progressBar(paramsDays);
			
			// Set percentage value to show
			dollarsProgress.set(total_remaining_percent, total_remaining_percent_text);
			daysProgress.set(days_remaining_percent, days_remaining_percent_text);
			
		});
	
	
	
	/* HEADER CODE (START) */
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

		$('#Accrued_Amt').text( numeral(TotalAccruedDollars).format( "($0,0.00)" ) );
		$('#Spent_Amt').text( numeral(TotalSpentDollars).format( "($0,0.00)" ) );
		$('#Remaining_Amt').text( numeral(TotalRemainingDollars).format( "($0,0.00)" ) );

		$('#Days_Num').text( numeral(TotalDays).format( "(0,0)" ) );
		$('#Days_Elapsed_Num').text( numeral(DaysElapsed).format( "(0,0)" ) );
		$('#Days_Remaining_Num').text( numeral(DaysRemaining).format( "(0,0)" ) );

		var total_remaining_percent = numeral(TotalRemainingPercent).format('0.00');

			total_remaining_percent_text = total_remaining_percent + '%'
			/* If "total_remaining_percent" is a negative number, then the progress bar should show 100% color, but the text should should display 0% */
			if(total_remaining_percent < 0){
				total_remaining_percent = Math.abs(total_remaining_percent);
				total_remaining_percent_text = '(' + numeral(total_remaining_percent) + '%)';
				$('#Remaining_Amt').addClass("neg");
			}

		var days_remaining_percent = DaysReminingPercent;
			days_remaining_percent_text = days_remaining_percent + '%'
			/* If "days_remaining_percent" is a negative number, then the progress bar should show 100% color, but the text should should display 0% */
			if(days_remaining_percent < 0){
				days_remaining_percent = Math.abs(days_remaining_percent);
				days_remaining_percent_text = '0%';
			}



	/* HEADER CODE (END) */
		
		</script>

		
		<cfinclude template="accrual_info.cfm">
		
	</body>
	</html>

