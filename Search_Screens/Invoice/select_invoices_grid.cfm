<!---------------------------------------------------------------------------------------------------------------------
      Template: \search_sreens\invoice\search_invoices_grid.cfm
      Date:     2016 August
      Author:   Milan Mushran
      Purpose:  import invoices for auto pay exception report
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Auto pay invoice selection</TITLE>
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
		.right{text-align:right}
		.center{text-align:center !important;}
		div.export {float:right;}
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</HEAD>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<cfparam name="distributorList" default="">
<cfparam name="Report_ID" default="0">
<cfparam name="FilterInvoices" default="">
<cfparam name="ContractMainID" default="">
<cfparam name="Contract_Number" default="">
<cfparam name="Start_Date" default="">
<cfparam name="End_Date" default="">
<cfparam name="form.submitFrm" default="0">
<cfparam name="form.dollar_operator" default="">
<cfparam name="form.dollar_amount" default="">
<cfparam name="form.distributor_name" default="">
<cfparam name="form.ship_to" default="">
<cfparam name="form.customerPO" default="">
<cfparam name="form.invoiceNumber" default="">
<cfparam name="form.orderNumber" default="">

<!---
NOTE:
"distributorList" is populated when a user visits this page from "select_distributors_grid,cfm" after selecting distributors, and we need to show
the users only those distributor's invoices. In this case, we need to use "opener.opener" and not just "opener". 

PLEASE ALSO NOTE "BODY ONLOAD" FUNCTIONS BELOW.
--->
<cfset variables.labelsObject = createObject("component", "components.settings.labels.labels").init()>
<cfset variables.orderNumberLabel = variables.labelsObject.GetGeneralLabels(labelDescription = "Order Number")>

<CFSET Dollar_Operator_Symbols=" ,>,=,<">

<BODY onLoad="disable_dollar_value(); setSelectedValues();">
<cfoutput>
<h2>#Contract_Number#: INVOICES FOR AUTO PAY (INVOICE DATE:  #Start_Date# - #End_Date#)</h2>

<form name="frmInvoiceSearch" action="select_invoices_grid.cfm" style="margin-top:2px;" method="post">
<table cellpadding="4" cellspacing="0" border="0" width="100%">
<tr>
	<cfif distributorList eq "">
	<td><b>#application.returned_customer_setting.distributor_label_singular# Name</b></td>
	<td><b>#application.returned_customer_setting.Shard_Ship_To_Label#</b></td>
	</cfif>
	<td><b>PO Number</b></td>
	<td><b>Invoice Number</b></td>
	<td><b>#variables.orderNumberLabel.General_Labels_Label#</b></td>
	<td><b>Dollar Value:</b></td>
</tr>
<tr>
	<cfif distributorList eq "">
	<td width="11%"><input type="text" name="distributor_name" id="distributor_name" size="17" value="#form.distributor_name#"></td>
	<td width="11%"><input type="text" name="ship_to" id="ship_to" size="17" value="#form.ship_to#"></td>
	</cfif>
	<td width="11%"><input type="text" name="customerPO" id="customerPO" size="17" value="#form.customerPO#"></td>
	<td width="11%"><input type="text" name="invoiceNumber" id="invoiceNumber" size="7" value="#form.invoiceNumber#"></td>
	<td width="11%"><input type="text" name="orderNumber" id="orderNumber" size="17" value="#form.orderNumber#"></td>
	<td width="15%">
		<SELECT OnChange="JavaScript: dollar_value(this);" NAME="dollar_operator" ID="dollar_operator" style="WIDTH:45px">
			<CFSET cnt=0>
			<CFLOOP LIST="#Dollar_Operator_Symbols#" INDEX="thisOperator">
				<CFSET cnt=cnt+1>
				<OPTION VALUE="#Trim(thisOperator)#" <CFIF TRIM(thisOperator) EQ FORM.Dollar_Operator>SELECTED</CFIF>>#Trim(ListGetAt(Dollar_Operator_Symbols,cnt))#</OPTION>
			</CFLOOP>
		</SELECT>
		<SPAN ID="SP_Dollar_Value">		
		<INPUT type="text" name="dollar_amount" id="dollar_amount" size="9" onKeyUp="clenseText(this, '0123456789.-'); ">
		</SPAN>
	</td>
	<td width="20%"><input type="checkbox" name="showCurrentlySelectedOnly" id="showCurrentlySelectedOnly" onClick="resetFields()"><b>Show selected invoices only</b></td>
	<td width="10%"><a href="javascript:void();" onClick="filterData();">#application.util.string.actionLinkFormat2("filter data")#</a></td>
</tr>
</table>
<input type="hidden" name="invoiceList" value="">
</form>

<cfif application.returned_customer_setting.shared_invoice IS 1>
	<cfset columnWidth_CheckBox = '3%'>
	<cfset columnWidth_InvoiceNumber = '12%'>
	<cfset columnWidth_PONumber = '12%'>
	<cfset columnWidth_OrderNumber = '12%'>
	<cfset columnWidth_Distributor = '15%'>
	<cfset columnWidth_InvoiceDate = '10%'>
	<cfset columnWidth_LegacyInvoiceNumber = '12%'>
	<cfset columnWidth_TotalDollars = '12%'>
	<cfset columnWidth_TotalCases= '12%'>
<cfelse>
	<cfset columnWidth_CheckBox = '3%'>
	<cfset columnWidth_InvoiceNumber = '14%'>
	<cfset columnWidth_PONumber = '14%'>
	<cfset columnWidth_OrderNumber = '14%'>
	<cfset columnWidth_Distributor = '21%'>
	<cfset columnWidth_InvoiceDate = '10%'>
	<cfset columnWidth_TotalDollars = '12%'>
	<cfset columnWidth_TotalCases= '12%'>
</cfif>

<form name="frmInvoiceList" method="post">
<table id="datagrid" class="datagrid" style="table-layout:fixed;">
	  <col width="#columnWidth_CheckBox#">
	  <col width="#columnWidth_InvoiceNumber#"> 
	  <col width="#columnWidth_PONumber#">
	  <col width="#columnWidth_OrderNumber#">
	  <col width="#columnWidth_Distributor#">
	  <col width="#columnWidth_InvoiceDate#">
	<cfif application.returned_customer_setting.shared_invoice IS 1>
	  <col width="#columnWidth_LegacyInvoiceNumber#">
	</cfif>
	  <col width="#columnWidth_TotalDollars#">
	  <col width="#columnWidth_TotalCases#">

  <thead>
  <tr>
	<th><input name="check_all_invoices" class="checkall" type="checkbox"></th>
	<th>Invoice Number</th>
	<th>PO Number</th>
	<th>#variables.orderNumberLabel.General_Labels_Label#</th>
	<th>#application.returned_customer_setting.distributor_label_singular#</th>
	<th>Invoice Date</th>
	<!--- Include "shared invoice" --->
	<cfif application.returned_customer_setting.shared_invoice IS 1>
	<th>Legacy Invoice ##</th>
	</cfif>
	<th class="center">Total $</th>
	<th class="center">Total Cases</th>
  </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
  </tfoot>
</table>
</form>

<table align="center" width="700">
	<tr>
		<td align="right"><a href="##" onclick="importInvoices()">#application.util.string.actionLinkFormat2(lcase("import selected invoices"))#</a></td>
		<td align="right"><a href="##" onclick="removeAllSelected()">#application.util.string.actionLinkFormat2(lcase("remove all selected invoices"))#</a></td>
	</tr>
</table>

</cfoutput>

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/dataTables.cfm">

<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js" />

<script type="text/javascript">
var gridHeightAdjustment =  105;
var jTable = $("#datagrid");
/* "Math.floor($(window).height())" is height of the page.
Math.floor(jTable.offset().top)" is the height from the top of the page to the top of the grid.
*/
var heightDiff = (Math.floor($(window).height()) - Math.floor(jTable.offset().top))

var mydatagrid = jTable.show().dataTable({
 /*Default of "2" below is "ORDER_NUJMBER", the second column on the grid. Default column
is also set on the CFFunction which populates this grid. "Shared_Invoice_Number" is not populated correctly 
for Kraft and so we cannot make  "Shared_invoice_number" as the default column to sort on.
*/
	"aaSorting": [ [2, 'asc'] ] 
	,"aoColumns": [ 
				 {"bSortable":false}
				 ,{ "bSortable": true }
				,{ "bSortable": true }
				,{ "bSortable": true }
				,{ "bSortable": true } 
				,{ "bSortable": true }
				<cfif application.returned_customer_setting.shared_invoice IS 1>
				,{ "bSortable": true}
				</cfif>
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" }
				,{ "bSortable": true, "sClass" : "right"}
				]
	,"bAutoWidth": false
	,"bDeferRender": true	// true for quicker rendering
	,"bPaginate": true
	,"bProcessing": true
	,"bServerSide": true
	,"bScrollCollapse": true		/* true to put the footer of the grid just below the records, when there are a few records only */
	/* Keep the The "sort" option is at the top, next to column header. (When we have column filters, the sort options can sometimes 
	go to the line, where we have filters) */
	,"bSortCellsTop": true			
	,"bSortClasses": false
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sAjaxSource": "../ajax/invoice_info_data.cfm"
	,"sDom": 'ptir'
	,"iDisplayLength": 100
	,"sServerMethod": "POST"
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	,"sScrollY" : (heightDiff - gridHeightAdjustment)<!--- data grid height --->
	,"fnServerParams": function ( aoData ) {	
		<cfoutput>
		<!--- varibles passed from parent page --->
		aoData.push( { "name": "ContractMainID", "value": '#ContractMainID#' } );
		aoData.push( { "name": "Contract_Number", "value": '#Contract_Number#' } );
		aoData.push( { "name": "Start_Date", "value": '#Start_Date#' } );
		aoData.push( { "name": "End_Date", "value": '#End_Date#' } );
		aoData.push( { "name": "Report_ID", "value": '#Report_ID#' } );		
		aoData.push( { "name": "distributorList", "value": '#distributorList#' } );
		
		<!--- varibles set on this page. --->
		aoData.push( { "name": "dollar_operator", "value": $('select[name=dollar_operator]').val() } );
		aoData.push( { "name": "dollar_amount", "value": $('input[name=dollar_amount]').val() } );
		<cfif distributorList eq "">
		aoData.push( { "name": "distributor_name", "value": $('input[name=distributor_name]').val() } );
		aoData.push( { "name": "ship_to", "value": $('input[name=ship_to]').val() } );
		</cfif>
		aoData.push( { "name": "customerPO", "value": $('input[name=customerPO]').val() } );
		aoData.push( { "name": "invoiceNumber", "value": $('input[name=invoiceNumber]').val() } );
		aoData.push( { "name": "orderNumber", "value": $('input[name=orderNumber]').val() } );
		aoData.push( { "name": "showCurrentlySelectedOnly", "value": $("##showCurrentlySelectedOnly").is(':checked') } );

		 <!---SINCE WE MAY HAVE RECORDS ON MULTIPLE PAGES, WE NEED TO PASS "invoiceList" TO THE AJAX PROCESSING PAGE, SO THAT IF A USER FILTERS
		RECORDS ON THIS PAGE, AND THEN SELECTS RECORDS AND THEN FILTERS AGAIN, THE PREVIOUS SELECTED RECORDS ARE NOT LOST.--->
		<cfif distributorList eq "">
		aoData.push( { "name": "invoiceList", "value": window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value } );
		<cfelse>
		aoData.push( { "name": "invoiceList", "value": window.opener.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value } );
		</cfif>
		 </cfoutput>
		}
	})

/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that 
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');


// "Check/Uncheck all" checkboxes
$('input[name=check_all_invoices]').change(function() {
	$("input.cb").attr("checked", (this.checked ? true : false));
	 addRemoveInvoices();
});

function addRemoveInvoices()
{
	/* The hidden variable on the opener. This variable is always updated. It is especially useful, when
	a user selects a few records, closes the popup, then closes it and then reopens it. In this case, we need
	to know the list of selected records.
	It is also being used to keep track of all the selections, even when a user is paging through
	this popup page.
	*/
	<cfoutput>
	/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
	<cfif distributorList eq "">
	var hiddenCBoxes = window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value.toLowerCase();
	<cfelse>
	var hiddenCBoxes = window.opener.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value.toLowerCase();
	</cfif>
	</cfoutput>

	/************** convert the list into an array for easy manipulation ************** */
	if (hiddenCBoxes.length == 0)
		var aInvoiceList = [];
	else
		var aInvoiceList = hiddenCBoxes.split(",");

	/* scan thru all checkboxes on the page */
	$('input.cb').each( function() {
		/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
		var invoiceHeaderID = $(this).val().toLowerCase();

		if ( $(this).prop('checked') ) {
			 /* checked box is not in the array, add it */
			if($.inArray(invoiceHeaderID , aInvoiceList) == -1)
				aInvoiceList.push( invoiceHeaderID );
		}
		else {
			 /* box is not checked so we need to remove it */
			while($.inArray(invoiceHeaderID , aInvoiceList) != -1) {
				aInvoiceList.splice($.inArray(invoiceHeaderID , aInvoiceList),1);
			}
		}
	});
	
	if(aInvoiceList.length > 1 && aInvoiceList[0] == '-1'){
		/* Remove first element which has value of "-1" */
		aInvoiceList.shift();
	}

	/* convert array back to a list for usage in form action */
	hiddenCBoxes = aInvoiceList.join(",");

	/* Refresh the hidden input with ALL selected rows. 
	All checked rows are saved in a hidden input with a name of 'invoiceList'
	*/ 
	$('input[name=invoiceList]').val( hiddenCBoxes );

	<cfoutput>
	/* update the temporary hidden variable on the opener page. This variable stores the set of invoices selected and is primarily
	used to keep track of selected entries while paging.
	*/
	<cfif distributorList eq "">
	window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value  = $('input[name=invoiceList]').val();
	<cfelse>
	window.opener.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value  = $('input[name=invoiceList]').val();
	</cfif>
	</cfoutput>
}

function importInvoices()
{
	var selectedRecords = 0;
	<cfoutput>
	<cfif distributorList eq "">
		var invList = window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value;
	<cfelse>
		var invList = window.opener.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value;
	</cfif>
	</cfoutput>

	/* Only if invoices are selected */
	if(invList != "-1" && invList != ''){
		selectedRecords = invList.split(",").length;
	}

	<cfoutput>
	<cfif distributorList eq "">
	/* Update the hidden variable  on the opener page. This variable stores the set of invoices selected. */
	window.opener.frmInsPayPeriod.FilterInvoices_#contractMainID#.value  = invList;

	/* update the number of invoices on the parent page.*/
	window.opener.document.getElementById('invCount_#contractMainID#').innerHTML = selectedRecords;
	<cfelse>

	var distList = '#distributorList#';

	/* Update the hidden variable  on the opener page. This variable stores the set of invoices selected. */
	window.opener.opener.frmInsPayPeriod.FilterInvoices_#contractMainID#.value  = invList;
	
	/* update the number of invoices on the parent page.*/
	window.opener.opener.document.getElementById('invCount_#contractMainID#').innerHTML = selectedRecords;

	/* Update the hidden variable  on the opener page. This variable stores the set of distributors selected. */
	window.opener.opener.frmInsPayPeriod.FilterDistributors_#contractMainID#.value  = '#distributorList#';

	/* update the number of distributors on the parent page.*/
	window.opener.opener.document.getElementById('distCount_#contractMainID#').innerHTML = distList.split(",").length;
	</cfif>
	</cfoutput>

	window.close();

	<cfif distributorList neq "">
	window.opener.close();
	</cfif>
}

/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that 
the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
rather than there being a big gap between the two, when there are one or just a few records.
*/
$('.dataTables_scrollBody').css('min-height', '30px');

function disable_dollar_value()
{
	dollar_value(document.getElementById('dollar_operator'));
}

function dollar_value(thisObj)
{
	var bDis = (thisObj.selectedIndex == 0)? true: false;
	disableDiv("SP_Dollar_Value",bDis,false);
}

function setSelectedValues()
{
	/* "Temp_FilterInvoices_#URL.ContractMainID#" is used to keep track of entries while the user is on the popup. The user may close the popup without importing the selected
	entries. In that case, when the popup opens again, the value of "Temp_FilterInvoices_#URL.ContractMainID#" variable should be the value of 
	"FilterInvoices_#URL.ContractMainID#" as "FilterInvoices_#URL.ContractMainID#" is the list of invoices whch the user has (imported or saved).
	*/
	<cfoutput>
	<cfif distributorList eq "">
	window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value = window.opener.frmInsPayPeriod.FilterInvoices_#contractMainID#.value;
	</cfif>
	</cfoutput>
}

this.filterData = function()
{	
/* Reload the grid using ajax. This way if a user has already selected billback(s) using the checkbox, the new search will still retain
the previously selected billbacks. Normally this would already happen if the filters are a part of the grid, but since the filters are
not a part of the grid, below code is needed.
*/
	mydatagrid.fnReloadAjax();
}

function removeAllSelected()
{
	$("input.cb").attr("checked", false);
	$("input.checkall").attr("checked", false);
	
	/* Only reset the "Temp_FilterInvoices_#contractMainID#" variable. Only when the user imports rhe selections, 
	will the selection list update the "FilterInvoices_#contractMainID#" variable.
	*/
	<cfoutput>
	<cfif distributorList eq "">
	window.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value = '';
	<cfelse>
	window.opener.opener.frmInsPayPeriod.Temp_FilterInvoices_#contractMainID#.value = '';
	</cfif>
	</cfoutput>
}

function resetFields()
{
	if(document.getElementById('showCurrentlySelectedOnly').checked == true)
	{
		document.frmInvoiceSearch.distributor_name.value= '';
		document.frmInvoiceSearch.ship_to.value= '';
		document.frmInvoiceSearch.customerPO.value= '';
		document.frmInvoiceSearch.invoiceNumber.value= '';
		document.frmInvoiceSearch.orderNumber.value= '';
		document.frmInvoiceSearch.dollar_operator.selectedIndex = 0;
		document.frmInvoiceSearch.dollar_amount.value= '';
	}
}

</script>

</BODY>
</HTML>