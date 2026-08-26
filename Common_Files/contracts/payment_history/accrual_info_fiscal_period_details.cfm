<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\accrual_info_fiscal_period_details.cfm
      Date:     2017 November
      Author:   Milan Mushran
      Purpose:  Accrual data Fiscal period details viewer
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Accrual detail data viewer</TITLE>

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

	<cfparam name="plannerId" default="0" />

	<!--- multiselect dependencies (start) --->
	<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css" />
	<!--- multiselect dependencies (end) --->

	<style>
		<cfif plannerId eq 0>
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

		table.datagrid { font-size: 1.05em; width: 100%; }
		thead th { text-align:left !important; }

		div.export {float:right;}
		div.otherSearch {float:right;}
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		.drpDownWidth{width:auto}
		.ui-multiselect { margin-bottom:3px;}

		table.dataTable thead th{ font-weight: normal;font-family: "Arial";<cfif plannerId neq 0>background-color:#9BC2E6</cfif>}

	</style>

	<cf_include files="/script/javascript/progress-bar/progress-bar.css, /script/javascript/progress-bar/progress-bar.js">

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

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>

<script>
	function viewContract(program_id)
	{
	NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id, 'ViewProgram','800','600','Yes', 'Yes');
	}
</script>
</HEAD>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<!--- multiselect dependencies (start) --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
<!--- multiselect dependencies (end) --->

<cfparam name="form.distributorComponentList" default="">
<cfparam name="form.Product_Group_Level_ID" default="0">
<cfparam name="form.Fiscal_Period" default="">
<cfparam name="form.distributorId" default="">
<cfparam name="plannerId" default="0">
<cfparam name="form.Component_Name" default="">

<cf_cryp type="en" string ="#ContractId#" key="#request.key#">

<cfset EncContractID = cryp.value>
	<cfset Business_Segments_On = 0 />
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfif businessSegManager.isEnabled()>
		<cfset Business_Segments_On = 1 />
	</cfif>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />

<cfset appSettings = application.appsettingsGet />
<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset getdateInfo = PaymentHistoryManager.getdateInfo(contractNumber, ContractId, plannerId)>
<cfset getFiscalDateInfo = PaymentHistoryManager.getFiscalDateInfo(contractNumber, ContractId, plannerId)>
<cfset getTotalAccruedAndSpentDollars = PaymentHistoryManager.getTotalAccruedAndSpentDollars(contractNumber, ContractId, plannerId)>

<!--- Component data from qGetProgramAccrualData will not exists when coming from program payment history so we need to call it --->
<cfif not IsDefined("qGetProgramAccrualData")>
	<cfset qGetProgramAccrualData = PaymentHistoryManager.getProgramAccrualData(contractNumber=contractNumber,contractMainID=ContractId, plannerID=plannerID) />
</cfif>

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

<BODY>
<cfoutput>
<header>
	<div id="hdr1">
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
					<cfif getcontractInfo.Released eq 1>
					<b>Released Date:</b>&nbsp;&nbsp;#getcontractInfo.ReleasedBy#<br/>
					<b>Released By:</b>&nbsp;&nbsp;#getcontractInfo.Released_Date#
					</cfif>
				</cfif>
			</section>
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

<!--- Below column widths expects the following to be ON -
- deduction Account (When it is ON, we will show the  "deduction Account" column.
- Distributor selection (When one or more distributors are selected, we will show the "Distributor" and "Distributor Name" columns
--->
<cfset fiscalYear_columnWidth = 8>
<cfset distributor_columnWidth = 9>
<cfset distributorName_columnWidth = 17>
<cfset deductionAccount_columnWidth = 6>
<cfset paymentAccount_columnWidth = 8>
<cfset GLAccount_columnWidth = 9>
<cfset componentID_columnWidth = 8>
<cfset componentName_columnWidth = 11>
<cfset cases_columnWidth = 8>
<cfset accrual_columnWidth = 8>
<cfset rate_columnWidth = 5>
<cfset rateUOM_columnWidth = 3>

<cfset missingColumns = 0 />
<cfset missingColumnsLen = 0 />

<cfset fiscalYear_columnWidth = fiscalYear_columnWidth + (2 * missingColumns)>
<cfset cases_columnWidth = cases_columnWidth + (2 * missingColumns)>
<cfset accrual_columnWidth = accrual_columnWidth + (2 * missingColumns)>
<cfset rate_columnWidth = rate_columnWidth + (2 * missingColumns)>

<table id="datagridAccrual" class="datagrid">
  <col width="#fiscalYear_columnWidth#%">
  <col width="#cases_columnWidth#%">
  <col width="#accrual_columnWidth#%">
  <col width="#rate_columnWidth#%">
  <col width="#rateUOM_columnWidth#%">
  <thead>
  <tr>
	<th>Fiscal Period</th>
	<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Accrual $&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Rate &nbsp;&nbsp;&nbsp;</th>
	<th class="right">Rate UOM</th>
  </tr>
  <!--- column filters --->
  <tr id="filter">
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th class="csvExclude right">
		<select name="filter_rateUOM" class="drpDownWidth"></select>
	</th>
  </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
	<th>&nbsp;</th>
	<th id="totalCases">&nbsp;</th>
  	<th id="totalAmount">&nbsp;</th>
	<th id="totalRate">&nbsp;</th>
	<th>&nbsp;</th>

  </tfoot>
</table>
</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 60;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<script>
var jTable = $(".datagrid");
mydatagrid = jTable.dataTable({
	/* column index to sort on */
	aaSorting: [ [0, 'asc'] ]
	,"aoColumns": [
				{ "bSortable": true }
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
				,{ "bSortable": false,  "sClass" : "right"}
				]
	,"bAutoWidth": false
	,"bProcessing": true
	,"bServerSide": true
	,"bSortClasses": false
	,"bScrollCollapse": true	/* true to put the footer of the grid just below the records, when there are a few records only */
	,"iDisplayLength": 100
	/* Keep the The "sort" option is at the top, next to column header. (When we have column filters, the sort options can sometimes
	go to the line, where we have filters) */
	,"bSortCellsTop": true
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sAjaxSource": "/Common_Files/contracts/ajax/accrual_info_fiscal_period_details_data.cfm"
	,"sDom": 'p<"export"><"otherSearch"><"DrpDowns">tir'
	,"sServerMethod": "POST"
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	//,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
	<cfif plannerId eq 0>
	,"sScrollY" : Math.floor(jQuery(window).height()) - 240
	<cfelse>
	,"sScrollY" : Math.floor(jQuery(window).height()) - 400
	</cfif>
	,"fnServerParams": function ( aoData ) {
		 <cfoutput>
		aoData.push( { "name": "contractNumber", "value": '#contractNumber#' } );
		aoData.push( { "name": "contractId", "value": '#contractId#' } );
		aoData.push( { "name": "distributorComponentList", "value": '#form.distributorComponentList#' } );
		aoData.push( { "name": "distributorId", "value": '#form.distributorId#' } );
		aoData.push( { "name": "Fiscal_Period", "value": '#form.Fiscal_Period#' } );
		aoData.push( { "name": "plannerId", "value": '#plannerId#' } );
		aoData.push( { "name": "Component_Name", "value": '#form.Component_Name#' } );
		 </cfoutput>
		}
	/* THIS TECHNIQUE OF TOTALLING IS USED WHEN WE THE DATA CALL IS AN AJAX CALL */
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
								$tfoot.find('#totalCases').text(numeral(json.TOTALCASESINVOICED).format( "0,0" ) );
								$tfoot.find('#totalAmount').text(numeral(json.TOTALAMOUNT).format( "($0,0.00)" ) );
								$tfoot.find('#totalRate').text(numeral(json.TOTALRATE).format( "($0,0.00)" ) );


								/* POPULATE THE FILTER DROPDOWNS */
								/* UOM */
								var selectedRateUOM = $('select[name=filter_rateUOM]').val();
								$('select[name=filter_rateUOM]').empty();
								$('select[name=filter_rateUOM]').append('<option value="">All</option>');
								for(var i = 0; i <json.ALLUOM.length; i++) {
										$('select[name=filter_rateUOM]').append('<option value="'+json.ALLUOM[i]+'">'+json.ALLUOM[i]+'</option>');
								}
								/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
								$('select[name=filter_rateUOM]').val(selectedRateUOM);

							fnCallback(json);}
		 } );
		}
	}).fnSetFilteringDelay();

	$(window).resize(function(){
		jTable.fnAdjustColumnSizing();
  	});

	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');

/* set up column filter */
$("#filter th").each( function ( i ) {
    $('select', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });
});

/* Normally the "exportAll" function passes data through the URL, but below function passes data through the form instead of the URL,
as the data passed to the URL may sometimes exceed the limit. */
exportAll = function() {
	window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=no,resizable=no,left=1,top=10000,width=1,height=1');
	frmExportAll.target = 'formpopup';
	frmExportAll.submit();
}

<cfoutput>
$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a> &nbsp;");
$('div.otherSearch').html("<a href='javascript:frmAccrualProducts.submit();show_loader();'>#application.util.string.actionLinkFormat2('view by product / component')#</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
$('div.DrpDowns').html("&nbsp;&nbsp;<select name='Fiscal_Period'><option value=''>Select Fiscal Period</option><cfloop query='getFiscalDateInfo'><option value='#getFiscalDateInfo.Start_Date# - #getFiscalDateInfo.End_Date#' #(form.Fiscal_Period eq getFiscalDateInfo.Start_Date &' - '& getFiscalDateInfo.End_Date ? 'selected' : '')#>#getFiscalDateInfo.Start_Date# - #getFiscalDateInfo.End_Date#</option></cfloop></select>&nbsp;&nbsp;&nbsp;&nbsp;<b>Component:</b>&nbsp;&nbsp;<select name='Component_Name'><option value=''>Select Component</option><cfloop query='qGetProgramAccrualData.qGetUniqueComponentName'><option value='#Component_Name#' #(form.Component_Name eq qGetProgramAccrualData.qGetUniqueComponentName.Component_Name ? 'selected' : '')#>#qGetProgramAccrualData.qGetUniqueComponentName.Component_Name#</option></cfloop></select>&nbsp;&nbsp;<a href='javascript:void(0)' onClick=FilterData();>#application.util.string.actionLinkFormat2('search')#</a>&nbsp;&nbsp;<a href='javascript:void(0)' onClick=resetData();>#application.util.string.actionLinkFormat2('reset')#</a>");
</cfoutput>



$("#distributorId").multiselect().multiselectfilter();

function FilterData()
{
	show_loader();
	//frmAccrualFiscalPeriod.distributorId.value= $('select[name=distributorId]').val();
	frmAccrualFiscalPeriod.Fiscal_Period.value= $('select[name=Fiscal_Period]').val();
	frmAccrualFiscalPeriod.Component_Name.value= $('select[name=Component_Name]').val();
	frmAccrualFiscalPeriod.submit();
}

function resetData()
{
	$('select').val('');
	FilterData();
	//	jQuery('form[name=topnav]').attr("action", "/planners/create/planner_accruals.cfm").submit();
}

/* HEADER CODE (START) */
<cfoutput>
var TotalDays             = #val( TotalDays )#;
var DaysElapsed           = #val( DaysElapsed )#;
var DaysRemaining         = #val( DaysRemaining )#;
var TotalAccruedDollars   = #val( TotalAccruedDollars )#;
var TotalSpentDollars     = #val( TotalSpentDollars )#;
var TotalRemainingDollars = #val( TotalRemainingDollars )#;
var TotalRemainingPercent = #val( TotalRemainingPercent )#;
var DaysReminingPercent   = #val( DaysReminingPercent )#;
</cfoutput>

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
		days_remaining_percent = 100;
		days_remaining_percent_text = '0%';
	}


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
/* HEADER CODE (END) */
</script>

<cfoutput>
<!---Param mode to handle for posting back to planner_accruals.cfm --->
<cfparam name="form.mode" default="">
<cfparam name="form.accrualDisplay" default="">
<cfparam name="form.plannerId" default="#plannerId#">

<!---Param frmAccrualProductsAction action--->
<cfparam name="frmAccrualProductsAction" default="/Common_Files/contracts/payment_history/accrual_info_details.cfm">

<!---If we're viewing within planner then set frmAccrualProductsAction action to planner_accruals.cfm--->
<cfif plannerId neq 0>
	<cfset frmAccrualProductsAction = "/Planners/Create/planner_accruals.cfm" />
	<cfset form.accrualDisplay = "/Common_Files/contracts/payment_history/accrual_info_details.cfm" />
</cfif>


<form name="frmAccrualProducts" action="#frmAccrualProductsAction#" method="post">
	<input type="hidden" name="contractnumber" value="#ContractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<input type="hidden" name="distributorComponentList" value="#form.distributorComponentList#">
	<input type="hidden" name="plannerId" value="#form.plannerId#">
	<input type="hidden" name="accrualDisplay" value="#form.accrualDisplay#">
	<input type="hidden" name="mode" value="#form.mode#">
</form>


<!---Param frmAccrualFiscalPeriod action--->
<cfparam name="frmAccrualFiscalPeriodAction" default="/Common_Files/contracts/payment_history/accrual_info_fiscal_period_details.cfm">

<!---If we're viewing within planner then set frmAccrualFiscalPeriod action to planner_accruals.cfm--->
<cfif plannerId neq 0>
	<cfset frmAccrualFiscalPeriodAction = "/Planners/Create/planner_accruals.cfm" />
</cfif>

<form name="frmAccrualFiscalPeriod" action="#frmAccrualFiscalPeriodAction#" method="post">
	<input type="hidden" name="contractnumber" value="#ContractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<input type="hidden" name="distributorComponentList" value="#form.distributorComponentList#">
	<input type="hidden" name="distributorId" value="#form.distributorId#">
	<input type="hidden" name="Fiscal_Period" value="#form.Fiscal_Period#">
	<input type="hidden" name="plannerId" value="#form.plannerId#">
	<input type="hidden" name="mode" value="#form.mode#">
	<input type="hidden" name="Component_Name" value="#form.Component_Name#">
</form>

<form name="frmExportAll" action="/Common_Files/exportAll.cfm" method="post">
	<input type="hidden" name="type" value="getProgramAccrualDistributorFiscalPeriodData">
	<input type="hidden" name="contract_number" value="#ContractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<input type="hidden" name="distributorComponentList" value="#form.distributorComponentList#">
	<input type="hidden" name="distributorIdList" value="#form.distributorId#">
	<input type="hidden" name="friendlyFileName" value="#urlEncodedFormat('AccrualByFiscalPeriod_#contractNumber#_')#">
	<input type="hidden" name="plannerId" value="#form.plannerId#">
</form>
</cfoutput>

</BODY>
</HTML>