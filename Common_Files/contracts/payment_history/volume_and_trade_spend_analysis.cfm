<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\volume_and_trade_spend_analysis.cfm
      Date:     2016 January
      Author:   Milan Mushran
      Purpose:  Volume and trade spend analysis
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Payment History - Volume and Trade Spend data</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		.tbl{
			border-top:1px solid black;
			border-bottom:1px solid black;
			border-left:1px solid black;
			border-right:1px solid black;
		}

		.tbl_2{
			border-bottom:1px solid black;
			border-left:1px solid black;
			border-right:1px solid black;
		}
		.tbl_3{
			border-top:1px solid black;
			border-bottom:1px solid black;
			border-right:1px solid black;
		}
		.tbl_4{
			border-bottom:1px solid black;
			border-right:1px solid black;
		}
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset ProgramManager = CreateObject("component","mvc.models.program.ProgramManager") />

<cfset getdateInfo = PaymentHistoryManager.getdateInfo(contractNumber,contractId)>

<!--- Get "volume" data (start)
We can get the "volume" data even from "getVolumeAndTradeSpendAndPaymentDollars" (below), but
"getTotalProgramEstimatedVolume" has the logic for budget and and so it is being used below.
--->
<cfset qGetTotalProgramEstimatedAndForecastedToGoVolume = PaymentHistoryManager.getTotalProgramEstimatedAndForecastedToGoVolume(contractNumber,contractId)>
<!--- Get "volume" data (end) --->

<cfset qGetTotalProgramActualVolume = PaymentHistoryManager.getTotalProgramActualVolume(contractNumber,contractId)>

<!--- Get "trade spend" data (start) --->
<cfset ProgramManager.getVolumeAndTradeSpendAndPaymentDollars(contractNumber,contractId)>

<cfquery name="qGetVolumeAndTradeSpendAndPaymentDollars" datasource="#application.datasource#">
	SELECT * FROM ##TotalPrgTradeSpendAndVolume
</cfquery>

<cfset qGetTotalProgramActualTradeSpend = PaymentHistoryManager.getTotalProgramActualTradeSpend(contractNumber,contractId)>
<!--- Get "trade spend" data (end) --->

<cfset qGetProgramUOM = PaymentHistoryManager.getProgramUOM(contractId)>

<!--- Actual dollars from the budget --->
<cfset actualTradeSpend = qGetVolumeAndTradeSpendAndPaymentDollars.actual_dollar>

<cfif actualTradeSpend eq "">
	<!--- Actual dollars from "payment history" --->
	<cfset actualTradeSpend = qGetTotalProgramActualTradeSpend.Total_Actual_TradeSpend>
</cfif>

<cfset varianceVolume = (val(qGetTotalProgramActualVolume.Total_Actual_Volume) + val(qGetTotalProgramEstimatedAndForecastedtoGoVolume.Total_Forecasted_To_Go_Volume))
 -
 val(qGetTotalProgramEstimatedAndForecastedToGoVolume.Total_Estimated_Volume)>

<cfset varianceTradeSpend = (val(actualTradeSpend) +  val(qGetVolumeAndTradeSpendAndPaymentDollars.forecasted_to_go_program_spend))
 -
 val(qGetVolumeAndTradeSpendAndPaymentDollars.estimated_program_spend) >

<cfset contractLengthDays = DateDiff('d', getdateInfo.start_date, getdateInfo.end_date) + 1>
<cfset contractToGoDays = DateDiff('d', now(), getdateInfo.end_date) + 1>

<BODY>
<cfoutput>

<table cellpadding="5" cellspacing="0" border="0" width="50%">
	<tr>
		<td width="10%">&nbsp;</td>
		<td><b>Estimated</b></td>
		<td><b>Actual</b></td>
		<td><b>Forecasted</b></td>
		<td title="Variance = (Actual + Forecasted) - Estimated"><b>Variance</b></td>
	</tr>
	<tr>
		<td><b>#qGetProgramUOM.Unit_Of_Measure_Desc#</b></td>
		<td class="tbl">#NumberFormat(qGetTotalProgramEstimatedAndForecastedToGoVolume.Total_Estimated_Volume, "_,___,___,___,___")#&nbsp;#qGetProgramUOM.program_uom#</td>
		<td class="tbl_3">#NumberFormat(qGetTotalProgramActualVolume.Total_Actual_Volume, "_,___,___,___,___")#&nbsp;#qGetProgramUOM.program_uom#</td>
		<td class="tbl_3">#NumberFormat(qGetTotalProgramEstimatedAndForecastedToGoVolume.Total_Forecasted_To_Go_Volume, "_,___,___,___,___")#&nbsp;#qGetProgramUOM.program_uom#</td>
		<td class="tbl_3">#NumberFormat(varianceVolume, "_,___,___,___,___")#&nbsp;#qGetProgramUOM.program_uom#</td>
	</tr>
	<tr>
		<td><b>Dollars</b></td>
		<td class="tbl_2">#dollarformat(qGetVolumeAndTradeSpendAndPaymentDollars.estimated_program_spend)#</td>
		<td class="tbl_4">#dollarformat(actualTradeSpend)#</td>
		<td class="tbl_4">#dollarformat(qGetVolumeAndTradeSpendAndPaymentDollars.forecasted_to_go_program_spend)#</td>
		<td class="tbl_4">#dollarformat(varianceTradeSpend)#</td>
	</tr>
</table>

<br />

<h2 id="headerVolume">VOLUME DETAILS</h2>

<table id="datagridVolume" class="datagrid" style="table-layout:fixed;">
  <col width="15%"> <col width="25%"> <col width="15%"> <col width="15%"> <col width="15%"> <col width="15%">
  <thead>
  <tr>
	<th>#application.returned_customer_setting.item_label#</th>
	<th>Description</th>
	<th class="right">Original estimated&nbsp;(#trim(qGetProgramUOM.program_uom)#)&nbsp;&nbsp;&nbsp;&nbsp;<br />(#contractLengthDays# days)&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Actual&nbsp;(#trim(qGetProgramUOM.program_uom)#)&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Forecasted to go&nbsp;(#trim(qGetProgramUOM.program_uom)#)&nbsp;&nbsp;&nbsp;&nbsp;<br />(<cfif contractToGoDays GT 0>#contractToGoDays#<cfelse>0</cfif> days)&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Variance&nbsp;(#trim(qGetProgramUOM.program_uom)#)&nbsp;&nbsp;&nbsp;&nbsp;</th>
  </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
	<th>&nbsp;</th>
	<th align="right"><b>Total (All pages):</b></th>
	<th id="totalEstimatedVolume">&nbsp;</th>
  	<th id="totalActualVolume">&nbsp;</th>
	<th id="totalForecastedToGoVolume">&nbsp;</th>
	<th id="totalVarianceVolume">&nbsp;</th>
  </tfoot>
</table>
</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 70;
	var mydatagrid = '';
</script>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js" />

<script>
	var jTable = $(".datagrid");
	mydatagrid = jTable.dataTable({
		aaSorting: [ [2, 'desc'] ]
		,"aoColumns": [ { "bSortable": true }
					,{ "bSortable": true }
					,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
					,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
					,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
					,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
					]
		,"bAutoWidth": false
		,"bProcessing": true
		,"bServerSide": true
		,"bSortClasses": false
		,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
		,"iDisplayLength": 100
		,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
		,"sAjaxSource": "../ajax/volume_item_details.cfm?<cfoutput>contractNumber=#contractNumber#&contractId=#contractId#</cfoutput>&random="+Math.random().toString(36).slice(2)
		,"sDom": 'fp<"export">tir'
		<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
		IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
		THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET "bScrollCollapse" TO "TRUE ON THE GRID.
		--->
		//,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
		,"sScrollY" : Math.floor(jQuery(window).height()) - 300
		/* THIS TECHNIQUE OF TOTALLING IS USED WHEN WE THE DATA CALL IS AN AJAX CALL */
		,"fnServerData": function ( sSource, aoData, fnCallback ) {
			 $.ajax( {   "dataType": 'json'
					 , "type": "GET"
					 , "url": sSource
					 , "data": aoData
					 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
											 $tfoot.find('#totalEstimatedVolume').text(numeral(json.TOTALESTIMATEDVOLUME).format( "0,0" ) );
											 $tfoot.find('#totalActualVolume').text(numeral(json.TOTALACTUALVOLUME).format( "0,0" ) );
											 $tfoot.find('#totalForecastedToGoVolume').text(numeral(json.TOTALFORECASTEDTOGOVOLUME).format( "0,0" ) );
											 $tfoot.find('#totalVarianceVolume').text(numeral(json.TOTALVARIANCEVOLUME).format( "0,0" ) );
											 fnCallback(json); }

			 } );
			}
		}).fnSetFilteringDelay();

		$(window).resize(function(){
			jTable.fnAdjustColumnSizing();
		});

<cfoutput>
$('div.export').html("<a href='javascript:exportAllVolume();'>#application.util.string.actionLinkFormat2('export volume details to csv')#</a> &nbsp;");
</cfoutput>

/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');

exportAllVolume = function() {
window.open( "/Common_Files/exportAll.cfm?" + "type=getProgramEstimatedAndForecastedToGoAndActualVolumeItems"
						+ "&contract_number=<cfoutput>#contractNumber#</cfoutput>"
						+ "&contractId=<cfoutput>#contractId#</cfoutput>"
						+ "&program_uom=<cfoutput>#qGetProgramUOM.program_uom#</cfoutput>"
						+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('Volume_#contractNumber#_')#</cfoutput>"
	,"_blank"
	,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}
</script>
</BODY>
</HTML>