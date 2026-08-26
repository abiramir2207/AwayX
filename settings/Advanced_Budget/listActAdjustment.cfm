<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\listActAdjustment.cfm
      Date:     Aug 9 2012
      Author:   Chris Nguyen
      Purpose:  List budget actual adjustments
----------------------------------------------------------------------------------------------------------------------->
<!--- D36686 Actual Adjustment - Green $ Sign --->
<cfparam name="contractnumber"  default="" >
<cfparam name="contractMainID"  default="" >
<cfparam name="plannerID"  default="0" >
<cfparam name="PaymentHistory"  default="no">

<cfinclude template="/common_files/jQuery.cfm">
<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
.dollar { text-align:right; }
<cfif val(plannerId) eq 0>
.even { background-color:#efe; }
</cfif>
.ad { width:70px; }
form {
  margin: 0;
  padding: 0;
}
<cfif val(plannerId) neq 0>
table.dataTable thead th{background-color: #9BC2E6;}
</cfif>
</style>
</cfsavecontent>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = StructNew();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<cfset qGetBudgetActual = PaymentHistoryManager.getbudgetactual(contract_number=contractNumber,contractMainID=contractMainID,plannerID=plannerID)>

<cfoutput>
<fieldset style="padding:1%; width:98%; border:1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Actual Adjustments - List</legend>
<!--- D36686 Actual Adjustment - Green $ Sign --->
<cfif PaymentHistory NEQ "yes">
		<div style="margin:10px" id="actions">
		 <a href="javascript:add_row()">#application.util.string.actionLinkFormat("create new actual adjustment")#</a>
		 <a href="##" id="upload" style="margin-left:15px;">#application.util.string.actionLinkFormat("import from excel")#</a>
		</div>
</cfif>
<table id="budgets" class="datagrid" style="table-layout:fixed;">
<col width="8%"> <col width="8%"> <col width="12%"> <col width="20%"> <col width="19%"> <col width="8%"> <col width="25%">
<thead>
<tr>
 <!---  <th>Adj Date</th> --->
  <th>Start</th>
  <th>End</th>
  <th>Program</th>
  <th>Lump sum</th>
  <th>#application.returned_customer_setting.Shard_Ship_To_Label#</th>
  <th>Adj Amount</th>
  <th>Notes</th>
</tr>
</thead>
<tbody>
</tbody>
<cfif PaymentHistory EQ "yes">
  <tfoot>
    <tr>
	<th></th>
	<th></th>
	<th></th>
	<th></th>
	<th align="right"><b>Total:</b></th>
	<th>$#numberformat(qGetBudgetActual.paid_amount,'_,___,___,___,___.__')#</th>
	<th></th>
    </tr>
  </tfoot>
</cfif>
</table>
</fieldset>
</cfoutput>


<input type="hidden" name="uploadedFileName" id="uploadedFileName">

<!--------------------------------------------------------------------------------------------------------------------->
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script type="text/javascript">
var windowHeight = $(window).height();
var grid = $('#budgets').dataTable({
	 "bPaginate": true
  ,"bServerSide": true
  ,"bProcessing": true
  ,"iDisplayLength": 250
  ,"sAjaxSource": "/settings/Advanced_Budget/ajax/listActAdjustment.cfm<cfif PaymentHistory EQ "yes">?<cfoutput>PaymentHistory=#PaymentHistory#&contractMainID=#contractMainID#&contractnumber=#contractnumber#&plannerID=#plannerID#</cfoutput></cfif>"
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"bAutoWidth": false
  ,"sDom": 'fptipr'
  ,"aaSorting": []
  ,"sScrollY": ( windowHeight > 800 ? .65 : .45) * windowHeight         <!--- data grid height --->
  ,"aoColumnDefs": [ { "aTargets":[2], "fnCreatedCell":function(nTd, sData, oData, iRow, iCol) { $(nTd).attr("title", oData[8]); } }
                    ,{ "aTargets":[0], "bSortable":true }
                    ,{ "aTargets":[1], "bSortable":true }
                    ,{ "aTargets":[3], "bSortable":false }
                    ,{ "aTargets":[4], "bSortable":false }
                    ,{ "aTargets":[5], "bSortable":false, "sClass":"dollar" }
                    ,{ "aTargets":[6], "bSortable":false } ]
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
}).fnSetFilteringDelay();
<!--------------------------------------------------------------------------------------------------------------------->
function add_row() {
  document.forms[budget_form].command.value = 'addactadjustment';
  document.forms[budget_form].submit();
}
<!---event for import-------------------------------------------------------------------------------------------------->
var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
function import_handler( uploadedFileName ) {
  $('#actions').html('<b>Importing actual adjustments, please wait...</b> <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
	$('#uploadedFileName').val( uploadedFileName );
  document.forms[budget_form].command.value = "importActAdjustments";
  document.forms[budget_form].submit();
  return false;
}
$('#upload').click(function(){
	var height = 520, width = 550;
	<cfoutput>
		NewWindow("/settings/advanced_budget/uploadActAdjustment.cfm?data_handler=import_handler&budget_id=#form.budget_id#&height=" + height + "&width=" + width, "importwindow", width, height, "no", "no");
  </cfoutput>
});
$('#budgets tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>



