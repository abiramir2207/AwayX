<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\searchcustomers.cfm
      Date:     May 30 2012
      Author:   Chris Nguyen
      Purpose:  Allow users to select distributors

----------------------------------------------------------------------------------------------------------------------->
<!---gather distributors in the budget--->
<cfscript>
  scust = StructNew();
</cfscript>
<cfinvoke component="mvc.Models.AdvancedBudget.BudgetAdjustmentManager"
    		     method="getDistributors"
     returnVariable="scust.qDistributors">
	<cfinvokeargument name="budget_ID" value="#form.budget_ID#">
</cfinvoke>

<!--------------------------------------------------------------------------------------------------------------------->
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style type="text/css">
 div.datagridwrapper {
 	margin:0 5px;
 }
</style>

<div class="datagridwrapper">
<table id="datagrid" class="datagrid">
<thead>
	<tr>
	  <th style="text-align:left;"><input type="checkbox" name="toggle_all" id="toggle_all"/></th>
	  <th>Name</th>
	  <th>Account</th>
	  <th>Address</th>
  </tr>
</thead>
<tbody>
	<cfsetting enablecfoutputonly=true>
	<cfloop query="scust.qDistributors">
    <cfoutput><tr></cfoutput>
      <cfoutput><td><input type="checkbox" id="#scust.qDistributors.Bsa_Foodservice_Customers_Id#" class="toggle_one"/></td></cfoutput>
      <cfoutput><td>#trim(scust.qDistributors.Name)#</td></cfoutput>
      <cfoutput><td>#trim(scust.qDistributors.Shr_Ship_To)#</td></cfoutput>
      <cfoutput><td>#trim(scust.qDistributors.Address_1)# #trim(scust.qDistributors.City)# #trim(scust.qDistributors.State)# #trim(scust.qDistributors.ZipCode)#</td></cfoutput>
    <cfoutput></tr></cfoutput>
  </cfloop>
  <cfsetting enablecfoutputonly=false>
</tbody>
</table>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/script/javascript/jquery.datatables-api.js"></script>

<script>
<!---refresh the main toggle all check box--->
function refresh_toggle_all() {
  /*console.log( 'checked count = ', $('.toggle_one:checked').length, ' | total elements = ', $('.toggle_one').length );*/
  $('#toggle_all').prop('checked', $('.toggle_one:checked').length === $('.toggle_one').length );
}
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .40 : .25) * windowHeight;
mydatagrid = $('#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": true
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fpti'
    ,"fnDrawCallback": function( oSettings ) {
      refresh_toggle_all();
    }
    ,"sScrollY": sScrollY         <!--- data grid height --->
    ,"aaSorting": [[ 1, "asc" ]] <!--- sort on name column --->
    ,"iDisplayLength": 250
    ,"oLanguage": { "sSearch": "Search Distributors:&nbsp;&nbsp;" }
    ,"aoColumns": [   {"sWidth": "4%", "bSortable":false, "bSearchable":false}
                    , {"sWidth": "37%"}
                    , {"sWidth": "22%"}
                    , {"sWidth": "37%"}
                  ]

  }).fnSetFilteringDelay();
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('#toggle_all').click(function(e){      <!---listen for click event on toggle all--->
  e.stopPropagation();
  $('.toggle_one').prop('checked', this.checked );
});

$('table#datagrid tbody').on('click', 'td', function(e) {
  if ( $(e.target).prop('checked') ) {
    refresh_toggle_all();
  }
  else {
    $('#toggle_all').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
  }
});

<cfif scust.qDistributors.recordcount eq 1>
	$('#toggle_all, .toggle_one').prop('checked', true);
</cfif>
</script>
