<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\view_offinvoice_item_details.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  offinvoice item list
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<cfparam name="form.plannerID" default="0">
<HTML>
<HEAD>
<TITLE>Payment History Items</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		h2 {
			background-color: #FFCE84;
			height: 26px;
			line-height: 26px;
			border-top:1px solid black;
			border-bottom:1px solid black;
			padding-left: 7px;
			font-size: 1.3em;
		}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }
		.header { width:100%; border-bottom:1px solid #000000;border-top:1px solid #000000;border-left:1px solid #000000;border-right:1px solid #000000;background-color: #ffe083;}
		div.export {float:right;}
		div#commands a { margin:5px;}
		div#commands div { margin:5px;}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }
		.dollar { text-align: right; }
		.center{text-align:center !important;}
		.right{text-align:right !important;}
		div#header { width:100%; border-bottom:1px solid #B4886B; 
			<cfif val(plannerId) eq 0>
			background-color: #FFE083;
			<cfelse>
			background-color: #C4DCF1;
			</cfif>
		}
		.both { clear:both; }
		div#header label { width: 90px; font-weight: bold; }
		div#lefthdr, div#middlehdr, div#righthdr { line-height:16px; padding:7px; }
		div#lefthdr { width:46%;}
		<cfif not val(plannerID)>
			div#middlehdr { width:23%; position:absolute; left:48%; top:10px;}
			div#righthdr { width:23%; position:absolute; left:73%; top:10px;}
		<cfelse>
			div#middlehdr { width:50%;}
			div#righthdr { width:50%; position:absolute; left:50%; top:10px; }
		</cfif>
		div#content { margin:1%; width:98%; }
		body { overflow: hidden; }
		<cfif val(plannerId) neq 0>
		table.dataTable thead th{background-color: #9BC2E6;}
		</cfif>
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/dataTables.cfm">

<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/datatable_resize.js, /Script/javascript/numeral.min.js">

<cfparam name="form.payee" default="">
<cfparam name="form.offinvoice_number" default="">
<cfparam name="form.item_number" default="">

<cfparam name="form.yearMonthList" default="">
<cfparam name="paymentMonth" default="">
<cfparam name="paymentYear" default="">
<cfparam name="productID" default="">
<!--- If the user searches for data for only 1 payment period (1 month and not multiple months), find out the Month and Year. --->
<cfif ListLen(form.yearMonthList,",") eq 1>
	<cfset paymentYear = ListFirst(form.yearMonthList, "-")>
	<cfset paymentMonth = ListLast(form.yearMonthList, "-")>
</cfif>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset getdateInfo = PaymentHistoryManager.getdateInfo(getcontractInfo.contract_number,ContractId)>

<BODY>

<cfoutput>
		<div id="header">
			<cfif not val(plannerID)>
			<div id="lefthdr">
					<b>#getcontractInfo.Contract_Number#</b> - &nbsp; #left(getcontractInfo.Contract_Title,75)#<br>
					<cfif len(getcontractInfo.contract_reference_number)>
						<b>Reference Number:</b> &nbsp; #getcontractInfo.contract_reference_number#<br>
					</cfif>
					<b>Status:</b> &nbsp; #getcontractInfo.contract_status_type_desc#<br>
					<!--- D32973:Dates on Payment History --->
					<b>Contract Start Date:</b> &nbsp; #Dateformat(getdateInfo.start_date,"mm/dd/yyyy")# &nbsp; <b>Contract End Date:</b> &nbsp; #Dateformat(getdateInfo.end_date,"mm/dd/yyyy")# <br>
					<b>Template Type:</b> &nbsp; #getcontractInfo.created_type#
			</div>  <!--- id="lefthdr"--->
			</cfif>
			
			<div id="middlehdr">
				<label>Total Products:</label> &nbsp; <span id="headertotalrecords"></span><br>
				<label>Total #Application.UOMPoundPlural#:</label> &nbsp; <span id="headertotalPounds"></span><br>
				<label>Total #Application.UOMCasePlural#:</label> &nbsp; <span id="headertotalCases"></span>
			</div> <!--- id="middlehdr" --->
			<div id="righthdr">
				<label>Total Dollars:</label> &nbsp; <span id="headertotalAmount"></span><br>
				<label>Avg Rate/#Application.UOMPoundAbrSingular#:</label> &nbsp; <span id="headerAVGRateLB"></span><br>
				<label>Avg Rate/#Application.UOMCaseAbrSingular#:</label> &nbsp; <span id="headerAVGRateCS"></span>
			</div>   <!--- id="righthdr" --->
		</div>  <!--- id="header" --->

<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="12%"> <col width="10%"> <col width="10%"> <col width="17%"> <col width="8%">  <col width="8%">  <col width="8%">  <col width="10%">  <col width="17%">
  <thead>
  <tr>
	<th>Invoice Number</th>
	<th>Invoice Date</th>
	<th>#application.returned_customer_setting.item_label#</th>
	<th>Description</th>
	<th class="right">Dollars&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Pounds&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th>#application.returned_customer_setting.distributor_label_singular# ID</th>
	<th>#application.returned_customer_setting.distributor_label_singular# Name</th>
  </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
	  <tr>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
			<th colspan="2" align="right"><b>Total (All pages):</b></th>
			<th id="totalAmount"></th>
			<th id="totalCases"></th>
			<th id="totalPounds"></th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
	  </tr>
  </tfoot>
</table>

</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 41;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js">

<script>
var jTable = $(".datagrid");
mydatagrid = jTable.dataTable({
	aaSorting: [ [0, 'asc'] ]
	,"aoColumns": [ { "bSortable": true }
				,{ "bSortable": true }
				,{ "bSortable": true }
				,{ "bSortable": true }
				,{ "bSortable": true, "sClass" : "right" }
				,{ "bSortable": true, "sClass" : "right" }
				,{ "bSortable": true, "sClass" : "right" }
				,{ "bSortable": true }
				,{ "bSortable": true }
				]
	,"bAutoWidth": false
	,"bProcessing": true
	,"bServerSide": true
	,"bSortClasses": false
	,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
	,"iDisplayLength": 100
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sAjaxSource": "../ajax/offinvoice_item_details.cfm"
	,"sDom": 'fp<"export">tir'
	,"sServerMethod": "POST"
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	//,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
	,"sScrollY" : Math.floor(jQuery(window).height()) - 200
	,"fnServerParams": function ( aoData ) {
		 <cfoutput>
		aoData.push( { "name": "contract_number", "value": '#form.Contract_Number#' } );
		aoData.push( { "name": "ContractId", "value": '#form.ContractId#' } );
		aoData.push( { "name": "plannerID", "value": '#plannerID#' } );
		aoData.push( { "name": "yearMonthList", "value": '#form.yearMonthList#' } );
		aoData.push( { "name": "payee", "value":'#form.payee#' } );
		aoData.push( { "name": "offinvoice_number", "value": '#form.offinvoice_number#' } );
		aoData.push( { "name": "item_number", "value": '#form.item_number#' } );
		 </cfoutput>
		}
	/* THIS TECHNIQUE OF TOTALLING IS USED WHEN WE THE DATA CALL IS AN AJAX CALL */
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
										 $tfoot.find('#totalAmount').text(numeral(json.TOTALAMOUNT).format( "$0,0.00" ) );
										 $tfoot.find('#totalCases').text(numeral(json.TOTALCASESINVOICED).format( "0,0" ) );
										 $tfoot.find('#totalPounds').text(numeral(json.TOTALPOUNDSINVOICED).format( "0,0" ) );
										 $('#headertotalrecords').replaceWith(numeral(json.iTotalRecords).format( "0,0" ));
										 $('#headertotalAmount').replaceWith(numeral(json.TOTALAMOUNT).format( "$0,0.00" ));
										 $('#headertotalCases').replaceWith(numeral(json.TOTALCASESINVOICED).format( "0,0" )+' <cfoutput>#Application.UOMPoundAbrPlural#</cfoutput>');
										 $('#headertotalPounds').replaceWith(numeral(json.TOTALPOUNDSINVOICED).format( "0,0" )+' <cfoutput>#Application.UOMCaseAbrPlural#</cfoutput>');
										 $('#headerAVGRateLB').replaceWith(numeral(json.TOTALAMOUNT/json.TOTALPOUNDSINVOICED).format( "$_,.__" )+'/<cfoutput>#Application.UOMPoundAbrSingular#</cfoutput>');
										 $('#headerAVGRateCS').replaceWith(numeral(json.TOTALAMOUNT/json.TOTALCASESINVOICED).format( "$_,.__" )+'/<cfoutput>#Application.UOMCaseAbrSingular#</cfoutput>');
										 fnCallback(json); }
		 } );
		}
    }).fnSetFilteringDelay();

	exportAll = function() {
	window.open( "/Common_Files/exportAll.cfm?" + "type=getOperatorOffInvoiceDataDetails"
									+ "&contract_number=<cfoutput>#form.contract_number#</cfoutput>"
									+ "&contractMainID=<cfoutput>#form.ContractId#</cfoutput>"
									+ "&plannerID=<cfoutput>#form.plannerID#</cfoutput>"
									+ "&yearMonthList=<cfoutput>#form.yearMonthList#</cfoutput>"
									+ "&payee=<cfoutput>#form.payee#</cfoutput>"
									+ "&offinvoice_number=<cfoutput>#form.offinvoice_number#</cfoutput>"
									+ "&item_number=<cfoutput>#form.item_number#</cfoutput>"
									+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('OI_#form.contract_number#_')#</cfoutput>"
		,"_blank"
		,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
	}

	function viewDetails(orderNumber,invoiceDate)
	{
		popupCenterByPercentages('/search_Screens/invoice/invoice_detail.cfm?Order_Number='+orderNumber+'&Invoice_Date='+invoiceDate,'paymentdetails','85','85','Yes', 'Yes');
	}

	<cfoutput>
	$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export all to csv')#</a> &nbsp;");
	</cfoutput>

	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');
</script>
</BODY>
</HTML>