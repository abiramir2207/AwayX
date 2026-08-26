<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\view_items_claimed_not_on_program.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  Items that have been claimed, but are not on the program
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Payment history items claimed not on program</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset qryItemDetails = PaymentHistoryManager.getPaymentHistoryItemsClaimedNotOnProgram(ContractNumber,ContractId)>

<BODY>

<cfoutput>
<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="24%"> <col width="40%"> <col width="12%"> <col width="12%"> <col width="12%">
  <thead>
  <tr>
	<th>#application.util.string.fcase(application.returned_customer_setting.item_label)#</th>
	<th>Description</th>
	<th class="right">Dollars&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Pounds&nbsp;&nbsp;&nbsp;&nbsp;</th>
  </tr>
  </thead>
  <tbody>
	<cfloop query="qryItemDetails">
	<tr>
		<td><a href="##" onclick="viewBillbackHistory('#ContractNumber#','#ContractId#','#bsa_foodservice_Items_Master_ID#');return false;" border="0">#Item#</a></td>
		<td>#Description#</td>
		<td class="dollars">#DollarFormat(Sales_Dollars)#</td>
		<td class="cases">#NumberFormat(Volume_Cs,"(___,___,___,___)")#</td>
		<td class="pounds">#NumberFormat(Volume_Lb,"(___,___,___,___)")#</td>
	</tr>
	</cfloop>
  </tbody>
  <tfoot>
	<th>&nbsp;</th>
	<th align="right"><b>Total (All pages):</b></th>
	<th id="totalDollars">&nbsp;</th>
  	<th id="totalCases">&nbsp;</th>
	<th id="totalPounds">&nbsp;</th>
  </tfoot>
</table>
</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 75;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<script type="text/javascript">
/* Just add a default value for "previousSearchString". This will  make sure that the "totals" are calculated,
when the page loads for the first time.
*/
var previousSearchString ="initial";
var jTable = $(".datagrid");
mydatagrid = jTable.dataTable({
	"aaSorting": []
	,"aoColumns": [	{"bSortable":true}/* Item */
					,{"bSortable":true}	/* Description */
					,{"bSortable":true, "sClass" : "right", "bSearchable":false,"sType":"dollar"} /* Dollars */
					,{"bSortable":true, "sClass" : "right", "bSearchable":false,"sType":"dollar"} /* Cases */
					,{"bSortable":true, "sClass" : "right", "bSearchable":false,"sType":"dollar"} /* Pounds */
				]
	,"bAutoWidth": false            /* false for quicker rendering */
	,"bDeferRender": true           /* true for quicker rendering */
	,"bProcessing": true            /* true to show processing message in sorting large table */
	,"bScrollCollapse": true        /* true to put the footer of the grid just below the records, when there are a few records only */
	,"bSortCellsTop": true          /* true to inform sorting on first row in thead */
	,"bSortClasses": false
	/* For pagination use, add "p" in "sDom". We not have a "p" below, as we do not need pagination.
	"f" is for the "search" box .
	*/
	,"sDom": 'fp<"export">tir'
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	/* For pagination, set "bPaginate" to true */
	,"bPaginate": true
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	//,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
	,"sScrollY" : Math.floor(jQuery(window).height()) - 150
	,"iDisplayLength": 100
	/* calculate "total" */
	,"fnDrawCallback": function() {

	/* Calculate totals:
		Note:This technique of totalling is useful when totalling needs to be done on the client-side, when there is paging involved.
		Need to use "bUnique= false". Without it, only unique values will be totalled.
	*/
	var dollarArray = this.fnGetColumnData( iColumn=2,bUnique=false );
	var casesArray = this.fnGetColumnData( iColumn=3,bUnique=false );
	var poundsArray = this.fnGetColumnData( iColumn=4,bUnique=false );

	var total_Dollars = totalColumn(dollarArray);
	var total_Cases = totalColumn(casesArray);
	var total_Pounds = totalColumn(poundsArray);

		var currentSearchString = $('input:text').val();

		/* Only if the data has changed, do the total. Do not do total again, otherwise. It is useful in scenarios, where the user just
		sorts data.In that case, we do not need to do total again.
		The logic looks for filter string. If the filter string (search string) is a new one, then do the total.
		*/
		if(currentSearchString != previousSearchString){
			var $tfoot = $('div.dataTables_scrollFootInner');

			$tfoot.find('th#totalDollars').text( numeral(total_Dollars).format( "($0,0.00)" ) );
			$tfoot.find('th#totalPounds').text( numeral(total_Pounds).format( "0,0" ) );
			$tfoot.find('th#totalCases').text( numeral(total_Cases).format( "0,0" ) );
		}

		previousSearchString = currentSearchString;
	}


}).fnSetFilteringDelay();

$(window).resize(function(){
		jTable.fnAdjustColumnSizing();
});

function viewBillbackHistory(contractNumber,ContractId,productID){
	window.open("view_billback_payment_history.cfm?ContractNumber=" + contractNumber + "&ContractId=" + ContractId + "&productID=" + productID,"billbackPaymentHistory","toolbars=no,scrollbars=yes,resizable=yes,left=0,top=0,width=1000,height=650");
}

function totalColumn(arr){
	var columnTotal = 0;

	for(i=0;i<=arr.length;i++){
		columnTotal = columnTotal + numeral(arr[i]);
	}
return columnTotal;
}

exportAll = function() {
	window.open( "/Common_Files/exportAll.cfm?" + "type=getPaymentHistoryItemsClaimedNotOnProgram"
								+ "&contract_number=<cfoutput>#ContractNumber#</cfoutput>"
								+ "&contractId=<cfoutput>#contractId#</cfoutput>"
								+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('items_claimed_not_on_program_#ContractNumber#_')#</cfoutput>"

		,"_blank"
		,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}


/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');

<cfoutput>
$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export all to csv')#</a> &nbsp;");
</cfoutput>
</script>

</BODY>
</HTML>