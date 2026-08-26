<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\
      Date:     June 19, 2011
      Author:   Chris Nguyen
      Purpose:  List budget classes
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

<!--- <cfset oBudgetClassManager = createObject('component','mvc.Models.AdvancedBudget.BudgetClassManager') /> --->
<cfset qGetBudgetClass = oBudgetClassManager.getBudgetClass() />

<cfoutput>
<div style="margin-top:10px">
<fieldset style="padding:0px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget Classes - List</legend>
<div style="margin:10px">
<cfif qGetCreateBudget.Create_Budget eq 0>
 #LCase(ActionTextGrayedOut("create new budget class"))#
<cfelse>
 <a href="javascript:add_budget_class()">#LCase(ActionText("create new budget class"))#</a>
</cfif>
</div>
<div style="margin:10px">
<table id="budgets" class="datagrid">
<thead>
<tr>
    <th>Code</th>
    <th>Description</th>
    <th>Year Type</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<cfloop query="qGetBudgetClass">
<tr>
 <td>#qGetBudgetClass.Budget_Class_Number#</td>
 <td>#qGetBudgetClass.Budget_Class_Desc#</td>
 <td><!--- Dev Note: drachala; D30041: Budgets - for fiscal year show dates for reference  START
     Added/Changed: IMG with title value for Start Date and End date--->
 	<cfif qGetBudgetClass.Is_Fiscal>Fiscal &nbsp;&nbsp;
 		<img src="/images/help_small.gif" height="12" width="12" title="#dateformat(qGetBudgetClass.Start_Date, "mmm dd, yyyy")# - #dateformat(qGetBudgetClass.End_Date, "mmm dd, yyyy")#"/>
<!--- End Dev Note: drachala; Budgets - for fiscal year show dates for reference:   --->
 <cfelse>
 	 Calendar
	 </cfif>
</td>
<td>
<cfif qGetCreateBudget.Create_Budget eq 0>
      <a href="javascript:view_budget_class(#qGetBudgetClass.Budget_Class_ID#)" class="action">#ActionText("view")#</a>
<cfelse>
     <a href="javascript:edit_budget_class(#qGetBudgetClass.Budget_Class_ID#)" class="action">#ActionText("edit")#</a>
     <a href="javascript:delete_budget_class(#qGetBudgetClass.Budget_Class_ID#)" class="action">#ActionText("delete")#</a>
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
                  , {"sWidth": "45%"}
                  , {"sWidth": "15%", "bSortable":true,  "bSearchable":false}
                  , {"sWidth": "20%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
$('table#budgets tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
<!---$(window).resize(function(){ grid.fnAdjustColumnSizing(); });--->
<!--------------------------------------------------------------------------------------------------------------------->
function add_budget_class() {
  document.forms[budget_form].budget_class_id.value = "0";
  document.forms[budget_form].command.value = 'addBudgetclass';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function edit_budget_class( Budget_class_ID ) {
  document.forms[budget_form].budget_class_id.value = Budget_class_ID;
  document.forms[budget_form].command.value = 'editBudgetclass';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function view_budget_class( Budget_class_ID ) {
  document.forms[budget_form].budget_class_id.value = Budget_class_ID;
  document.forms[budget_form].command.value = 'viewBudgetclass';
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
function delete_budget_class( Budget_class_ID ) {
  if ( confirm( 'Do you really want to delete the selected budget class?' ) ) {
    document.forms[budget_form].budget_class_id.value = Budget_class_ID;
    document.forms[budget_form].command.value = 'deleteBudgetclass';
    document.forms[budget_form].submit();
  }
}
<!---new FixedHeader ( grid );--->
</script>


