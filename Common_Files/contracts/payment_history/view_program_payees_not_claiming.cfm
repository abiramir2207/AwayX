<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\view_program_payees_not_claiming.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  program payees that have not claimed or purchased.
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>View program payees not claiming</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset objProgram = CreateObject("component", "components.programs.program") />

<cfset qProgramPaidToType = objProgram.getProgramPaidToType(ContractNumber)>

<!--- Dev Note(75544): For a cancelled program, "qProgramPaidToType" could be blank and we want to avoid an error --->
<cfif qProgramPaidToType neq "">
	<cfset qryPayeeDetails = PaymentHistoryManager.getProgramPayeesNotClaimingOrPurchasing(ContractNumber,ContractId)>
</cfif>

<cfset dist = application.util.string.fcase(application.returned_customer_setting.distributor_label_singular)>
<cfset opr = application.util.string.fcase(application.returned_customer_setting.operator_label_singular)>

<cfset variables.aaData = []>

<cfif qProgramPaidToType neq "">
	<cfloop query="qryPayeeDetails">

	<cfset variables.aTemp = []>

		<!--- data column 1 - payee type --->
		<cfset arrayAppend(variables.aTemp,payee_type)>

		<!--- data column 2 - payee id --->
		<cfset arrayAppend(variables.aTemp,payee_id)>

		<!--- data column 3 - payee name --->
		<cfset arrayAppend(variables.aTemp,payee_name)>

		<!--- entire row data --->
		<cfset arrayAppend(variables.aaData, variables.aTemp)>
	</cfloop>
</cfif>

<BODY>

<cfoutput>
<table id="datagrid" class="datagrid" style="table-layout:fixed;">
 <col width="20%"> <col width="30%"> <col width="50%">
<thead>
	<tr>
		<th>Payee Type</th>
		<th>Payee ID</th>
		<th>Payee Name</th>
	</tr>
	<!--- column filters --->
	<tr id="filter">
		<th class="csvExclude">
			<select name="filter_payee">
				<option value="">All</option>
				<option>#dist#</option>
				<option>#opr#</option>
			</select>
		</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
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
	var height_below_grid_to_bottom_page_in_pixels = 55;
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
	,"aoColumns": [	{"bSortable":true}/* payee type */
					,{"bSortable":true}	/* payee id */
					,{"bSortable":true}	/* payee name */
				]
	,"bAutoWidth": false	/* false for quicker rendering */
	,"bDeferRender": true	/* true for quicker rendering */
	,"bProcessing": true	/* true to show processing message in sorting large table */
	,"bScrollCollapse": true /* true to put the footer of the grid just below the records, when there are a few records only */
	,"bSortCellsTop": true	/* true to inform sorting on first row in thead */
	,"bSortClasses": false
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	/* For pagination use, add "p" in "sDom". We have a "p" below. */
	,"sDom": 'fp<"export">tir'
	/* For pagination, set "bPaginate" to true */
	,"bPaginate": true
	/* How many records will show on one page */
	,"iDisplayLength": 100
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
//	,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
	,"sScrollY" : Math.floor(jQuery(window).height()) - 150
}).fnSetFilteringDelay();

$(window).resize(function(){
	jTable.fnAdjustColumnSizing();
});

/* set up column filter */
$("#filter th").each( function ( i ) {
    $('select', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });
});

exportAll = function() {
	window.open( "/Common_Files/exportAll.cfm?" + "type=getProgramPayeesNotClaimingOrPurchasing"
								+ "&contract_number=<cfoutput>#ContractNumber#</cfoutput>"
								+ "&contractId=<cfoutput>#contractId#</cfoutput>"
								+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('Program_payees_not_claiming_#ContractNumber#_')#</cfoutput>"

		,"_blank"
		,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}
/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');

<cfoutput>
$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a> &nbsp;");
</cfoutput>

</script>
</BODY>
</HTML>