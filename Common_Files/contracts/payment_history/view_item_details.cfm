<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\view_item_details.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  payment history item list for the program.
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Payment History Items</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		h2 {
			<cfif val(plannerId) eq 0>background-color: #FFCE84;</cfif>
			height: 26px;
			line-height: 26px;
			border-top:1px solid black;
			border-bottom:1px solid black;
			padding-left: 7px;
			font-size: 1.3em;
		}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		table.dataTable thead th{ font-weight: normal; font-family: "Arial";<cfif plannerId neq 0>background-color:#9BC2E6</cfif>}
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfparam name="form.type_code_desc_id" default="">
<cfparam name="form.type" default="">
<cfparam name="form.payee" default="">
<cfparam name="form.settlement_id" default="">


<cfparam name="form.yearMonthList" default="">
<cfparam name="paymentMonth" default="">
<cfparam name="paymentYear" default="">
<cfparam name="form.plannerID"		default="0">


<!--- If the user searches for data for only 1 payment period (1 month and not multiple months), find out the Month and Year. --->
<cfif ListLen(form.yearMonthList,",") eq 1>
	<cfset paymentYear = ListFirst(form.yearMonthList, "-")>
	<cfset paymentMonth = ListLast(form.yearMonthList, "-")>
</cfif>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfset qryItemDetails = PaymentHistoryManager.getPaymentHistoryItemLevelData(
	   contract_number = form.contract_number, contractId = form.ContractId, yearMonthList = form.yearMonthList, 
	   type_code_desc_id = form.type_code_desc_id, type = form.type,payee = form.payee, settlement_id = form.settlement_id, 
	   plannerID = plannerID)>

<cfset variables.aaData = []>
<cfset variables.totalDollars = 0>
<cfset variables.totalCases = 0>
<cfset variables.totalPounds = 0>


<cfloop query="qryItemDetails">

<cfset variables.aTemp = []>

	<cfset variables.totalDollars = variables.totalDollars + qryItemDetails.Sales_Dollars>
	<cfset variables.totalCases = variables.totalCases + qryItemDetails.Volume_Cs>
	<cfset variables.totalPounds = variables.totalPounds + qryItemDetails.Volume_Lb>

	<!--- data column 1 - Item --->
	<cfset arrayAppend(variables.aTemp,Item)>

	<!--- data column 2 - Description --->
	<cfset arrayAppend(variables.aTemp,Description)>

	<!--- data column 3 - Rate --->
	<cfset arrayAppend(variables.aTemp, DollarFormat(Sales_Dollars))>
	<!---<cfset arrayAppend(variables.aTemp, Sales_Dollars)>--->

	<!--- data column 4 - Cases --->
	<cfset arrayAppend(variables.aTemp, NumberFormat(Volume_Cs,"(___,___,___,___)"))>
	<!---<cfset arrayAppend(variables.aTemp, Volume_Cs)>--->

	<!--- data column 5 - Pounds --->
	<cfset arrayAppend(variables.aTemp, NumberFormat(Volume_Lb,"(___,___,___,___)"))>
	<!---<cfset arrayAppend(variables.aTemp, Volume_Lb)>--->

	<!--- data column 6 - Item on program --->
	<cfif Item_not_On_program eq 0>
		<!--- Leave a space after 'Yes'. Without it, it will be displayed as 'true' --->
		<cfset arrayAppend(variables.aTemp,'Yes' & ' ')>

	<cfelseif Item_not_On_program eq 1>
		<!--- Leave a space after 'No'. Without it, it will be displayed as 'false' --->
		<cfset arrayAppend(variables.aTemp, 'No' & ' ')>

	<cfelseif Item_not_On_program eq "">
		<cfset arrayAppend(variables.aTemp, 'N/A')>
	</cfif>
	<!--- entire row data --->
	<cfset arrayAppend(variables.aaData, variables.aTemp)>
</cfloop>

<BODY>
<cfoutput>
<h2><cfif val(plannerId) eq 0>#form.contract_number#: </cfif>PAYMENT DETAILS HISTORY - <cfif paymentMonth neq "">#UCASE(MonthAsString(paymentMonth))# #paymentYear#<cfelse>MULTIPLE MONTHLY SEARCH PERIODS</cfif></h2>


	<div align="left">
		<a href="javascript:exportAll();" id="exportData">#application.util.string.actionLinkFormat2("export to csv")#</a>
	</div>
<br />

<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="22%"> <col width="38%"> <col width="10%"> <col width="10%"> <col width="10%"> <col width="10%">
  <thead>
	<tr>
		<th>#application.util.string.fcase(application.returned_customer_setting.item_label)#</th>
		<th>Description</th>
		<th class="right">Dollars&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th class="right">Pounds&nbsp;&nbsp;&nbsp;&nbsp;</th>
		<th class="center">#application.util.string.fcase(application.returned_customer_setting.item_label)# on program</th>
	</tr>
	<!--- column filters --->
	<tr id="filter">
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th class="csvExclude center">
			<select name="filter_product_on_program">
				<option value="">All</option>
				<option>Yes</option>
				<option>No</option>
			</select>
		</th>
	</tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
  </tfoot>
</table>

</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 35;
	var mydatagrid = '';
</script>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js">

<script type="text/javascript">
	var jTable = $(".datagrid");
	mydatagrid = jTable.dataTable({
	"aaData": <cfoutput>#serializeJSON(variables.aaData)#</cfoutput>
	,"aaSorting": []
	,"aoColumns": [	{"bSortable":true}/* Item */
					,{"bSortable":true}	/* Description */
					,{"bSortable":true, "sClass" : "right", "bSearchable":false,"sType":"dollar"} /* Dollars */
					,{"bSortable":true, "sClass" : "right", "bSearchable":false,"sType":"dollar"} /* Cases */
					,{"bSortable":true, "sClass" : "right", "bSearchable":false,"sType":"dollar"} /* Pounds */
					 /*,{"bSortable":true, "sClass" : "center", "sType":"alt-string"} Item Not On Program */
					 ,{"bSortable":true, "sClass" : "center", "bSearchable":false} /* Item Not On Program */
				]
	,"bAutoWidth": false            // false for quicker rendering
	,"bDeferRender": true           // true for quicker rendering
	,"bProcessing": true            // true to show processing message in sorting large table
	,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
	,"bSortCellsTop": true          // true to inform sorting on first row in thead
	,"bSortClasses": false
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sDom": 'pftir'
	,"iDisplayLength": 100
	,"bPaginate": true
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	//,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
	,"sScrollY" : Math.floor(jQuery(window).height()) - 200
	<!--- NOT SHOWING THE COLUMNS TOTAL AS THERE MIGHT BE DIFFERENCE IN THE TOTAL FROM THE MAIN SUMMARY PAGE DUE TO NUMBER FORMATTING. --->
}).fnSetFilteringDelay();

/* set up column filter */
$("#filter th").each( function ( i ) {
    $('select', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });
});

exportAll = function() {
window.open( "/Common_Files/exportAll.cfm?" + "type=getPaymentHistoryItemLevelData"
								+ "&contract_number=<cfoutput>#form.contract_number#</cfoutput>"
								+ "&contractId=<cfoutput>#form.contractId#</cfoutput>"
								+ "&plannerID=<cfoutput>#form.plannerID#</cfoutput>"
								+ "&yearMonthList=<cfoutput>#form.yearMonthList#</cfoutput>"
								+ "&type_code_desc_id=<cfoutput>#form.type_code_desc_id#</cfoutput>"
								+ "&payment_type=<cfoutput>#form.type#</cfoutput>"
								+ "&payee=<cfoutput>#form.payee#</cfoutput>"
								+ "&settlement_id=<cfoutput>#form.settlement_id#</cfoutput>"
								+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('All_#form.contract_number#_')#</cfoutput>"
	,"_blank"
	,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}

	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');
</script>
</BODY>
</HTML>