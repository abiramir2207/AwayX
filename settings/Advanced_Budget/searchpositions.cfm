<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\searchpositions.cfm
      Date:     May 31 2012
      Author:   Chris Nguyen
      Purpose:  Allow users to select positions

----------------------------------------------------------------------------------------------------------------------->
<!---gather positions in the budget--->
<cfscript>
  spos = StructNew();
</cfscript>
<cfinvoke component="mvc.Models.AdvancedBudget.BudgetAdjustmentManager"
    		     method="getPositions"
     returnVariable="spos.qPositions">
	<cfinvokeargument name="budget_ID" value="#form.budget_ID#">
</cfinvoke>

<!--------------------------------------------------------------------------------------------------------------------->
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style type="text/css">
 div.datagridwrapper {
 	margin-left:0px;
 	width:80%;
 }
</style>

<div class="datagridwrapper">
<table id="datagrid" class="datagrid">
<thead>
	<tr>
	  <th style="text-align:left;"><input type="checkbox" name="toggle_all" id="toggle_all"/></th>
	  <th>Position</th>
	  <th>Number</th>
  </tr>
</thead>
<tbody>
	<cfsetting enablecfoutputonly=true>
	<cfloop query="spos.qPositions">
    <cfoutput><tr></cfoutput>
      <cfoutput><td><input type="checkbox" id="#spos.qPositions.User_Positions_ID#" class="toggle_one"/></td></cfoutput>
      <cfoutput><td>#trim(spos.qPositions.Position_Label)#</td></cfoutput>
      <cfoutput><td>#trim(spos.qPositions.Position_Number)#</td></cfoutput>
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
    ,"oLanguage": { "sSearch": "Search:&nbsp;&nbsp;" }
    ,"aoColumns": [   {"sWidth": "5%", "bSortable":false, "bSearchable":false}
                    , {"sWidth": "70%"}
                    , {"sWidth": "25%"}
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

<cfif spos.qPositions.recordcount eq 1>
	$('#toggle_all, .toggle_one').prop('checked', true);
</cfif>
</script>
