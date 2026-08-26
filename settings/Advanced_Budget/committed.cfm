<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\committed.cfm
      Date:     Aug 16 2011
      Author:   Chris Nguyen
      Purpose:  List all committed programs for a budget

      Required parameters:
        - url.budget_id: integer

----------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title></title>
 <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
 <link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
 <style type="text/css">
 .dollar { text-align:right; }
 .mid { text-align:center; }
 .cancelled { text-decoration:line-through; }
 </style>
</head>
<body>
<cfset pagetitle = "PROGRAMS: Budgets">
<cfinclude template="/settings/settings_title.cfm">
<cfscript>
 main = {};
 const = {};
 const.variable_budget = 3;
 const.customers = 4;
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="main.qBudget" datasource="#application.datasource#">
	SELECT	Budget_desc,
			Budget_Code,
			Budget_Id,
			Budget_Contribution_Factor_Type_ID,
			Allocation_Position_Level,
			Budget_Class_Desc
	FROM 	Budget
	   		INNER JOIN Budget_Class ON Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
     WHERE Budget.Budget_Id = <cfqueryparam value="#url.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfoutput>
<fieldset id="mainfieldset" style="padding:0px; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Committed Report</legend>

<!---display heading--->
<div style="margin:10px" >
<table border=0 cellspacing=0 cellpadding=0 width="100%">
	<tr>
    	<td><font size=2>Code: <b>#main.qBudget.budget_code#</b></font></td>
	</tr>
	<tr>
    	<td><font size=2>Budget Description: <b>#main.qBudget.budget_desc#</b></font></td>
	</tr>
	<tr>
    	<td><font size=2>Class: <b>#main.qBudget.Budget_Class_Desc#</b></font></td>
	</tr>
</table>
<hr width="100%"/>
</div>

<!----- action links ----->
 <div style="margin-left:10px;float:left;">
 <a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';">#application.util.string.actionLinkFormat('return to budgets list')#</a>
 </div>
 <div style="float:right;margin:0 15px;">
 <a href="javascript:exportAll();">#application.util.string.actionLinkFormat('export all')#</a>  <!--- 35750 --->
 </div>
 <div id="cancel" style="float:right;display:none;">
 <span class="cancelled">Strikethrough</span> are cancelled programs&nbsp;&nbsp;<select name="displayOption" id="displayOption"><option value="all">Show all programs</option><option value="cancelOff">Hide cancelled programs</option><option value="cancelOnly">Show only cancelled programs</option></select>
 </div>
<div style="clear:both"></div>

<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1.5, 2.5, 2, 1.25, 1.25, 2, 3, 1.5, 1.5] )>

<div style="width:98%;margin:1%;clear:both;">
<table class="datagrid" id="datagrid" style='table-layout:fixed'>
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
 <thead>
 <tr>
   <th>Program</th>
   <th>Title</th>
   <th>Template</th>
   <th>Start</th>
   <th>End</th>
   <th>RSP</th>
   <cfif (main.qBudget.Budget_Contribution_Factor_Type_ID neq const.variable_budget)
       and (main.qBudget.Allocation_Position_Level eq const.customers)>
    <th>Customer</th>
   <cfelse>
    <th>Position</th>
   </cfif>
   <th class="mid">Committed</th>
   <th class="mid">Actual</th>
 </tr>
 </thead>
 <tfoot>
 <tr>
   <th>&nbsp;</th>
   <th>&nbsp;</th>
   <th>&nbsp;</th>
   <th>&nbsp;</th>
   <th>&nbsp;</th>
   <th>&nbsp;</th>
   <th id="total">&nbsp;</th>
   <th class="dollar" id="committed_total"></th>
   <th class="dollar" id="actual_total">&nbsp;</th>
 </tr>
 </tfoot>
 <tbody>
    <cfset getdata_message = '<tr><td colspan="8">Gathering data from server, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    #getdata_message#
 </tbody>
</table>
</div>
</fieldset>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<cfset jQueryui.version = "1.8.23">     <!---  36506  --->
<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>

<script type="text/javascript">
$.prompt.setDefaults( { opacity:'0.3', prefix:'cleanblue', top:'35%' } );
cancel_display = 0;

var foo = 0;


var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var total_committed_dollar = 0, total_actual_dollar = 0, grand_total = 0;
var grid = $('table#datagrid').dataTable({
   "bAutoWidth": false
  ,"bPaginate": true<!---D35005 Budget committed detail - long running javascript warning --->
  ,"bSortClasses": false
  ,"bScrollCollapse": false
  ,"bServerSide": true
  ,"sAjaxSource": "ajax/committed.cfm"
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
  ,"iDisplayLength": 200<!---D35005 Budget committed detail - long running javascript warning --->
  ,"sDom": "fprtip"
  ,"aaSorting": [[ 0, "asc" ]] <!---sort on 1st column--->
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"aoColumns": [   {}
                  , {}
                  , {}
                  , {}
                  , {}
                  , {}
                  , {}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false, "sType":"currency" }
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false, "sType":"currency" }
                  , {"bVisible":false}    // row class
                  ]
  ,"fnRowCallback": function( nRow, aData, iDisplayIndex ) {
    var manualCancel = grid.fnGetData(nRow)[9];
    if ( manualCancel == '1' ) {
    	$(nRow).addClass('cancelled');
    	// if cancel div is not displayed display it
    	if (!cancel_display) {
    		cancel_display = 1;
    		$('#cancel').show();
    	}
    }
    return nRow;
  }
  ,"fnServerData": function ( sSource, aoData, fnCallback ) {
      <!---display a gathering data message--->
      //$('table#datagrid tbody tr').eq(0).html('<cfoutput>#getdata_message#</cfoutput>');
      <!---pass budget_id, budget type, allocation type to ajax template to process--->
      aoData.push( { "name":"budget_id", "value":"<cfoutput>#main.qBudget.budget_id#</cfoutput>" } );
      aoData.push( { "name":"Budget_Contribution_Factor_Type_ID", "value":"<cfoutput>#main.qBudget.Budget_Contribution_Factor_Type_ID#</cfoutput>" } );
      aoData.push( { "name":"Allocation_Position_Level", "value":"<cfoutput>#main.qBudget.Allocation_Position_Level#</cfoutput>" } );
      aoData.push( { "name":"displayOption", "value":$('#displayOption').val() } );
      $.ajax( {   "dataType": 'json'
                , "type": "POST"
                , "url": sSource
                , "data": aoData
                , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
                                              $tfoot.find('#committed_total').text( json.committed_dollar );
                                              $tfoot.find('#actual_total').text( json.actual_dollar );

                                              $('#total').text(json.total);
                                              fnCallback(json); }
                , "error": function(jqXHR, textStatus, errorThrown) {
                              <!---email error to admin--->
                              $.post("/common_files/jsError.cfm", {cf_template:"<cfoutput>#Replace(GetCurrentTemplatePath(),'\','/','all')#</cfoutput>", ajax_url:sSource, detail:errorThrown, aoData:aoData });
                              $.prompt('System is busy, please try again later.');
                              $('#datagrid tbody').hide();
                           }
      } );
  }
}).fnSetFilteringDelay();

$('#displayOption').change( function() {
	grid.fnDraw();
});

$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); foo++; $('#total').hide(); });

exportAll = function() {
  window.open( "/Common_Files/exportAll.cfm?" + "type=budgetCommitted"
                                              + "&budget_id=<cfoutput>#main.qBudget.budget_id#</cfoutput>"
                                              + "&friendlyFileName=<cfoutput>#urlEncodedFormat('Budget Committed Report')#</cfoutput>"
              ,"_blank"
              ,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}
<!--------------------------------------------------------------------------------------------------------------------->
</script>
</body>
</html>
