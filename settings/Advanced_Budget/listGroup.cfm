<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\
      Date:     June 19, 2011
      Author:   Chris Nguyen
      Purpose:  List budget groups
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

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfset oBudgetGroupManager = createObject('component','mvc.Models.AdvancedBudget.BudgetGroupManager') />
<cfset qGetBudgetGroup = oBudgetGroupManager.getBudgetGroup() />

<cfoutput>
<div style="margin-top:10px">
<fieldset style="padding:0px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget Groups - List</legend>
<div style="margin:10px">
<cfif qGetCreateBudget.Create_Budget eq 0>
 #LCase(ActionTextGrayedOut("create new budget group"))#
<cfelse>
 <a href="javascript:add_budget_group()">#LCase(ActionText("create new budget group"))#</a>
</cfif>
</div>
<div style="margin-bottom:15px;padding:5px;">
<table id="budgets" class="datagrid">
<thead>
<tr>
    <th>Code</th>
    <th>Description</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<cfloop query="qGetBudgetGroup">
<tr>
 <td>#qGetBudgetGroup.Budget_Group_Number#</td>
 <td>#qGetBudgetGroup.Budget_Group_Desc#</td>
 <td>
	<cfif qGetCreateBudget.Create_Budget eq 0>
		 <a href="javascript:view_budget_group(#qGetBudgetGroup.Budget_Group_ID#)" class="action">#ActionText("view")#</a>
	<cfelse>
 		<a href="javascript:edit_budget_group(#qGetBudgetGroup.Budget_Group_ID#)" class="action">#ActionText("edit")#</a>
     	<a href="javascript:delete_budget_group(#qGetBudgetGroup.Budget_Group_ID#)" class="action">#ActionText("delete")#</a>
	</cfif>
 </td>
</tr></cfloop>
</tbody>
</table>
</div>
</fieldset>
</div>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="columnLabel" output="false">
  <cfargument name="customLabel" required="true">

  <cfreturn Replace(arguments.customLabel, ':', '')>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.5.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<!---<script type="text/javascript" src="/script/javascript/fixedheader.min.js"></script>--->
<script type="text/javascript">
var grid = $('#budgets').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti'
  ,"sScrollXInner": "100%"
  <!---,"sScrollY": "400px"         <!---limit datagrid to 400px in height--->--->
  ,"aaSorting": [[ 0, "asc" ]] <!---default sorting on code column--->
  ,"aoColumns": [   {"sWidth": "25%"}
                  , {"sWidth": "55%"}
                  , {"sWidth": "20%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
$('table#budgets tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
<!---$(window).resize(function(){ grid.fnAdjustColumnSizing(); });--->
<!--------------------------------------------------------------------------------------------------------------------->
function add_budget_group() {
  document.forms[budget_form].budget_group_id.value = "0";
  document.forms[budget_form].command.value = 'addBudgetGroup';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function edit_budget_group( Budget_Group_ID ) {
  document.forms[budget_form].budget_group_id.value = Budget_Group_ID;
  document.forms[budget_form].command.value = 'editBudgetGroup';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function view_budget_group( Budget_Group_ID ) {
  document.forms[budget_form].budget_group_id.value = Budget_Group_ID;
  document.forms[budget_form].command.value = 'viewBudgetGroup';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function delete_budget_group( Budget_Group_ID ) {
  if ( confirm( 'Do you really want to delete the selected budget group?' ) ) {
    document.forms[budget_form].budget_group_id.value = Budget_Group_ID;
    document.forms[budget_form].command.value = 'deleteBudgetGroup';
    document.forms[budget_form].submit();
  }
}
<!---new FixedHeader ( grid );--->
</script>

