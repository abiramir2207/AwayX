<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\listAdjustmentTypes.cfm
      Date:     May 24, 2012
      Author:   Chris Nguyen
      Purpose:  List budget adjustment types
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
</style>
</cfsavecontent>

<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = StructNew();
</cfscript>

<cfset vars.oBudgetAdjustmentManager = createObject('component','mvc.Models.AdvancedBudget.BudgetAdjustmentManager') />
<cfset vars.qAdjustmentTypes = vars.oBudgetAdjustmentManager.getBudgetAdjustmentTypes() />


<cfoutput>
<div style="margin:0px">
<fieldset style="padding:1%; width: 98%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget Adjustment Types - List</legend>
<div style="margin:10px">
<cfif qGetCreateBudget.Create_Budget eq 0>
  #LCase(application.util.string.actionTextGrayedOut("create new budget adjustment type"))#
<cfelse>
 <a href="javascript:add_adjustment_type()">#LCase(application.util.string.actionLinkFormat("create new budget adjustment type"))#</a>
</cfif>
</div>
<table id="budgets" class="datagrid" style="table-layout:fixed;">
<col width="25%">
<col width="10%">
<col width="35%">
<col width="10%">
<col width="20%">
<thead>
<tr>
    <th>Code</th>
    <th>ID</th>
    <th>Description</th>
    <th>Active?</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<cfloop query="vars.qAdjustmentTypes">
<tr>
 <td>#vars.qAdjustmentTypes.Code#</td>
 <td>#vars.qAdjustmentTypes.Budget_Adjustment_Type_Id#</td>
 <td>#vars.qAdjustmentTypes.Description#</td>
 <td><cfif vars.qAdjustmentTypes.Active>yes<cfelse>&nbsp;</cfif></td>
 <td>
	<cfif qGetCreateBudget.Create_Budget eq 0>
		<a href="javascript:view_adjustment_type(#vars.qAdjustmentTypes.Budget_Adjustment_Type_Id#)" class="action">#application.util.string.actionLinkFormat("view")#</a>		
	<cfelse>
		<a href="javascript:edit_adjustment_type(#vars.qAdjustmentTypes.Budget_Adjustment_Type_Id#)" class="action">#application.util.string.actionLinkFormat("edit")#</a>
     	<a href="javascript:delete_adjustment_type(#vars.qAdjustmentTypes.Budget_Adjustment_Type_Id#, #vars.qAdjustmentTypes.is_in_use#)" class="action">#application.util.string.actionLinkFormat("delete")#</a>
	</cfif>
</td>
</tr></cfloop>
</tbody>
</table>
</fieldset>
</div>
<input type="hidden" name="Budget_Adjustment_Type_Id" id="budget_adjustment_type_id"/>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
 $('#budgets').dataTable({
	 "bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"bAutoWidth": false
  ,"sDom": 'fti'
  ,"sScrollY": $(window).height()*40/100         <!--- data grid height --->
  ,"aaSorting": [[ 0, "asc" ]] <!---default sorting on code column--->
  ,"aoColumnDefs": [ {"aTargets":[4], "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
$('table#budgets tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
<!--------------------------------------------------------------------------------------------------------------------->
function add_adjustment_type() {
  $('#budget_adjustment_type_id').val( "0" );
  document.forms[budget_form].command.value = 'addAdjustmentType';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function edit_adjustment_type( Budget_Adjustment_Type_Id ) {
  $('#budget_adjustment_type_id').val( Budget_Adjustment_Type_Id );
  document.forms[budget_form].command.value = 'editAdjustmentType';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function view_adjustment_type( Budget_Adjustment_Type_Id ) {
  $('#budget_adjustment_type_id').val( Budget_Adjustment_Type_Id );
  document.forms[budget_form].command.value = 'viewAdjustmentType';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function delete_adjustment_type( Budget_Adjustment_Type_Id, Is_In_Use ) {
	if ( Is_In_Use ) {
		alert( 'Adjustment type is in use, it cannot be deleted.' );
	}
  else if ( confirm( 'Do you wish to delete the selected budget adjustment type?' ) ) {
    $('#budget_adjustment_type_id').val( Budget_Adjustment_Type_Id );
    document.forms[budget_form].command.value = 'deleteAdjustmentType';
    document.forms[budget_form].submit();
  }
}
</script>

