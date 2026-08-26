<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\accrual_info.cfm
      Date:     2016 Febriary
      Author:   Milan Mushran
      Purpose:  Accrual data viewer
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<cfparam name="plannerId" default="0">

<HTML>
<HEAD>
<TITLE>Accrual data viewer</TITLE>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<style>
	table.dataTable thead th{ font-weight: normal; font-family: "Arial";<cfif plannerId neq 0>background-color:#9BC2E6</cfif>}	
</style>
</HEAD>
<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset getDeductionAccountExist = PaymentHistoryManager.getDeductionAccountExist(contractNumber, ContractId, plannerId)>
<cfset getPaymentAccountExist = PaymentHistoryManager.getPaymentAccountExist(contractNumber, ContractId, plannerId)>
<cfset getGLAccountExist = PaymentHistoryManager.getGLAccountExist(contractNumber, ContractId, plannerId)>
	
<BODY>
<cfoutput>
<!--- The header code for this file is on "trend_anlysis.cfm" --->

<cfset extraPercent = 0 />
<cfset sortCol = 7 /> <!--- Default sort by Accrual $--->
<cfif getDeductionAccountExist eq 0>
	<cfset extraPercent = extraPercent + 2 />
	<cfset sortCol = sortCol + 1 />
</cfif>

<cfif getPaymentAccountExist eq 0>
	<cfset extraPercent = extraPercent + 2 />
	<cfset sortCol = sortCol + 1 />
</cfif>

<cfif getGLAccountExist eq 0>
	<cfset extraPercent = extraPercent + 2 />
	<cfset sortCol = sortCol + 1 />
</cfif>

	
<table id="datagridAccrual" class="datagrid" style="width:100%;">
	
	<col width="6%"> <!--- Contract Number --->
	
	<col width="#Evaluate("8+#extraPercent#")#%"> <!--- Distributor --->
	<col width="#Evaluate("11+#extraPercent#")#%"> <!--- Distributor Name --->
	<cfif getDeductionAccountExist eq 1>
		<col width="6%"> <!--- Deduction Account --->
	</cfif>
	<cfif getPaymentAccountExist eq 1>
		<col width="6%"> <!--- Payment Account --->
	</cfif>
	<cfif getGLAccountExist eq 1>
		<col width="9%"> <!--- GL Account --->
	</cfif>
		
	<col width="8%"> <!--- Component ID --->
	<col width="#Evaluate("10+#extraPercent#")#%"> <!--- Component --->
	<col width="7%">
	<col width="9%">
	<thead>
		<tr>
			<th>Program</th>
			<th>#application.returned_customer_setting.distributor_label_singular#</th>
			<th>#application.returned_customer_setting.distributor_label_singular# Name</th>
			<cfif getDeductionAccountExist eq 1>
				<th>Ded Acct</th>
			</cfif>
			<cfif getPaymentAccountExist eq 1>
				<th>Pymt Acct</th>
			</cfif>
			<cfif getGLAccountExist eq 1>
				<th>GL Acct</th>
			</cfif>
			<th>Comp ID</th>
			<th>Component</th>
			<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
			<th class="right">Accrual $&nbsp;&nbsp;&nbsp;&nbsp;</th>
		</tr>
		<!--- column filters --->
		<tr id="filter">
			
			<th class="csvExclude">
				<select name="filter_ContractNumber" class="drpDownWidth"></select>
			</th>
			
			<th class="csvExclude">
				<select name="filter_ShipTo" class="drpDownWidth"></select>
			</th>
			<th>
				<input type="text" name="filter_shipToText" value="">
			</th>
			<cfif getDeductionAccountExist eq 1>
				<th class="csvExclude">
					<select name="filter_deductionAccount" class="drpDownWidth"></select>
				</th>
			</cfif>
			<cfif getPaymentAccountExist eq 1>
				<th class="csvExclude">
					<select name="filter_paymentAccount" class="drpDownWidth"></select>
				</th>
			</cfif>
			<cfif getGLAccountExist eq 1>
				<th class="csvExclude">
					<select name="filter_GL_Account" class="drpDownWidth"></select>
				</th>
			</cfif>
			<th class="csvExclude">
				<select name="filter_externalID" class="drpDownWidth"></select>
			</th>
			<th class="csvExclude">
				<select name="filter_componentName" class="drpDownWidth"></select>
			</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</tr>
	</thead>

	<tbody>
	</tbody>
	
	<tfoot>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<cfif getDeductionAccountExist eq 1>
		<th>&nbsp;</th>
		</cfif>
		<cfif getPaymentAccountExist eq 1>
		<th>&nbsp;</th>
		</cfif>
		<cfif getGLAccountExist eq 1>
		<th>&nbsp;</th>
		</cfif>
		<th>&nbsp;</th>
		<th align="right"><b>Total:</b></th>
		<th id="totalCases"></th>
		<th id="totalAmount">&nbsp;</th>
	</tfoot>
</table>

<!--- These form values are exclusively used to pass values the from values to a popup page.
These form values (filters) are needed.
--->
<form name="frmSearchCriteria" action="/Common_Files/contracts/payment_history/accrual_info_details.cfm" method="post">
	<input type="hidden" name="contractNumber" value="#ContractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<!--- Stores the value of the checkboxes for the selected records. --->
	<input type="hidden" name="distributorComponentList" value="">
	<input type="hidden" name="plannerId" value="#plannerId#">
</form>

</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 80;
	var mydatagrid = '';
</script>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<script>
var jTable = $(".datagrid");
mydatagrid = jTable.dataTable({

	aaSorting: [ [<cfoutput>#sortCol#</cfoutput>, 'desc'] ]
	,"aoColumns": [
				
				{ "bSortable": true}
				,{ "bSortable": true }
				,{ "bSortable": true }
				<cfif getDeductionAccountExist eq 1>
				,{ "bSortable": false}
				</cfif>
				<cfif getPaymentAccountExist eq 1>
				,{ "bSortable": false}
				</cfif>
				<cfif getGLAccountExist eq 1>
				,{ "bSortable": false}
				</cfif>
				,{ "bSortable": false}
				,{ "bSortable": false}
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
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
	,"sAjaxSource": "/Common_Files/contracts/ajax/accrual_info_data.cfm"
	,"sDom": 'fp<"export"><"itemDetails"><"reset">tir'
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
		aoData.push( { "name": "contractMainID", "value": '#contractId#' } );
		aoData.push( { "name": "ContractId", "value": '#ContractId#' } );
		<!--- SINCE WE MAY HAVE RECORDS ON MULTIPLE PAGES FOR SOME PROGRAMS, WE NEED TO PASS "distributorComponentList" TO THE AJAX PROCESSING PAGE, SO THAT IF A USER FILTERS
		RECORDS ON THIS PAGE, AND THEN SELECTS RECORDS AND THEN FILTERS AGAIN, THE PREVIOUS SELECTED RECORDS ARE NOT LOST.
		--->
		aoData.push( { "name": "distributorComponentList", "value": $('input[name=distributorComponentList]').val() } );
		aoData.push( { "name": "plannerId", "value": '#plannerId#' } );
		 </cfoutput>
		}
	/* THIS TECHNIQUE OF TOTALLING IS USED WHEN WE THE DATA CALL IS AN AJAX CALL */
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
										 $tfoot.find('#totalCases').text(numeral(json.TOTALCASESINVOICED).format( "0,0" ) ).css( "color", json.TOTALCASESINVOICED <0 ? "red" : "");
										 $tfoot.find('#totalAmount').text(numeral(json.TOTALAMOUNT).format( "($0,0.00)" ) ).css( "color", json.TOTALAMOUNT <0 ? "red" : "");
										 $tfoot.find('#totalSpentDollars').text(numeral(json.TOTALSPENTDOLLARS).format( "($0,0.00)" ) ).css( "color", json.TOTALSPENTDOLLARS <0 ? "red" : "");
										 $tfoot.find('#totalRemaningDollars').text(numeral(json.TOTALREMAININGDOLLARS).format( "($0,0.00)" ) ).css( "color", json.TOTALREMAININGDOLLARS <0 ? "red" : "");
										 $tfoot.find('#totalRemaningPercent').text(numeral(json.TOTALREMAININGPERCENT).format( "(0,0)%" )).css( "color", json.TOTALREMAININGPERCENT <0 ? "red" : "");

										/* POPULATE THE FILTER DROPDOWNS */
										/* Deduction Acct */
										<cfif getDeductionAccountExist eq 1>
										var selectedDeductionAccount = $('select[name=filter_deductionAccount]').val();

										$('select[name=filter_deductionAccount]').empty();
										$('select[name=filter_deductionAccount]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLDEDUCTIONACCOUNT.length; i++) {
												$('select[name=filter_deductionAccount]').append('<option value="'+json.ALLDEDUCTIONACCOUNT[i]+'">'+json.ALLDEDUCTIONACCOUNT[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_deductionAccount]').val(selectedDeductionAccount);
										</cfif>

										/* Payment Acct */
										<cfif getPaymentAccountExist eq 1>
										var selectedPaymentAccount = $('select[name=filter_paymentAccount]').val();

										$('select[name=filter_paymentAccount]').empty();
										$('select[name=filter_paymentAccount]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLPAYMENTACCOUNT.length; i++) {
												$('select[name=filter_paymentAccount]').append('<option value="'+json.ALLPAYMENTACCOUNT[i]+'">'+json.ALLPAYMENTACCOUNT[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_paymentAccount]').val(selectedPaymentAccount);
										</cfif>

										/* GL Account */
										<cfif getGLAccountExist eq 1>
										var selectedGLAccount = $('select[name=filter_GL_Account]').val();

										$('select[name=filter_GL_Account]').empty();
										$('select[name=filter_GL_Account]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLGLACCOUNT.length; i++) {
												$('select[name=filter_GL_Account]').append('<option value="'+json.ALLGLACCOUNT[i]+'">'+json.ALLGLACCOUNT[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_GL_Account]').val(selectedGLAccount);
										</cfif>

										/* External ID */
										var selectedExternalID = $('select[name=filter_externalID]').val();

										$('select[name=filter_externalID]').empty();
										$('select[name=filter_externalID]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLEXTERNALID.length; i++) {
												$('select[name=filter_externalID]').append('<option value="'+json.ALLEXTERNALID[i]+'">'+json.ALLEXTERNALID[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_externalID]').val(selectedExternalID);

										/* Component Name */
										var selectedComponentName = $('select[name=filter_componentName]').val();

										$('select[name=filter_componentName]').empty();
										$('select[name=filter_componentName]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLCOMPONENTNAME.length; i++) {
												$('select[name=filter_componentName]').append('<option value="'+json.ALLCOMPONENTNAME[i]+'">'+json.ALLCOMPONENTNAME[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_componentName]').val(selectedComponentName);

										/* Contract Number */	
										var selectedContractNumber = $('select[name=filter_ContractNumber]').val();

										$('select[name=filter_ContractNumber]').empty();
										$('select[name=filter_ContractNumber]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLCONTRACTNUMBER.length; i++) {
												$('select[name=filter_ContractNumber]').append('<option value="'+json.ALLCONTRACTNUMBER[i]+'">'+json.ALLCONTRACTNUMBER[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_ContractNumber]').val(selectedContractNumber);
									

										/* Ship To */
										var selectedShipTo = $('select[name=filter_ShipTo]').val();

										$('select[name=filter_ShipTo]').empty();
										$('select[name=filter_ShipTo]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLSHIPTO.length; i++) {
												$('select[name=filter_ShipTo]').append('<option value="'+json.ALLSHIPTO[i]+'">'+json.ALLSHIPTO[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_ShipTo]').val(selectedShipTo);

									fnCallback(json); }
		 } );
		}
		
	}).fnSetFilteringDelay();

	$(window).resize(function(){
		jTable.fnAdjustColumnSizing();
  	});


	/* The default minimum scrollable height of a datagrid is around "300px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');

	/* The default minimum height of a datagrid is around "300px". We need to reduce the minimum height, so that
	the links (if any) at the bottom of the grid can can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_wrapper').css('min-height', '30px');


/* set up column filter */
$("#filter th").each( function ( i ) {
    $('select', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });

	 $('input', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });
});


exportAll = function() {
window.open( "/Common_Files/exportAll.cfm?" + "type=getProgramAccrualData"
						+ "&contract_number=<cfoutput>#contractNumber#</cfoutput>"
						+ "&contractId=<cfoutput>#contractId#</cfoutput>"
						+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('AccrualByDistributors_#contractNumber#_')#</cfoutput>"
						+ "&plannerId=<cfoutput>#plannerId#</cfoutput>"
	,"_blank"
	,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}

<cfoutput>
$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a> &nbsp;");
$('div.itemDetails').html("<a href='javascript:frmAccrualProducts.submit();show_loader();'>#application.util.string.actionLinkFormat2('view by product / component')#</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
$('div.reset').html("&nbsp;&nbsp;<a href='javascript:void(0)' onClick=resetData();>#application.util.string.actionLinkFormat2('reset')#</a>");

function resetData()
{
	
	$('input[name=filter_shipToText]').val('');
	$('select').val('');
	mydatagrid.fnFilterClear();mydatagrid.fnReloadAjax();
}
</cfoutput>
</script>


<cfoutput>
<!---Param mode to handle for posting back to planner_accruals.cfm --->
<cfparam name="form.mode" default="">
<cfparam name="form.accrualDisplay" default="">
<cfparam name="form.distributorComponentList" default="">
<cfparam name="form.plannerId" default="0">


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


</cfoutput>


</BODY>
</HTML>