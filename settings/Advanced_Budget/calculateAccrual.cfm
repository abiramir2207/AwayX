<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\calculateAccrual.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Accrual Budget Report with ability to calculate via URL.calculate
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
<style type="text/css">
.dollar { text-align:right; }
.mid { text-align: center; }
.total { text-align:right; }
.uom { width: 63px; margin-left:4px; }
td.mid { align: center; }
.lbl { color:black; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->
<!--- <cfinclude template="actionFormat.cfm"> --->
<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Overlays
           , Overlay_Recapture
           , Recapture
           , Budget_Status
           , Allocation_Position_Level
      FROM Budget
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
  form.Budget_Code  = qBudget.Budget_Code;
  form.Budget_desc  = qBudget.Budget_desc;
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset" style="padding-top:10px; border:1px solid blue; width:100%;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Report</legend>

<cfinclude template="displayBudgetHeading.cfm">
<cfset displayBudgetHeading( form.Budget_Id )>

<!----- action links ----->
<div style="margin-left:10px;float:left;">
 <a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';">#application.util.string.actionLinkFormat("return to budgets list")#</a>
</div>
<div style="float:right;margin:0 15px;">
 <a href="javascript:getCSVData();">#application.util.string.actionLinkFormat("export")#</a>  <!--- 35750 --->
</div>
<div style="clear:both"></div>
<!--------------------------------------------------------------------------------------------------------------------->

<div style="width:98%;margin-top:5px;padding:1%;">
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [2, 1, 1, 1, 1, 1, 1, 1] )>
<table class="datagrid" id="datagrid" style='table-layout:fixed'>
 <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <col width="#variables.columnPercentage#%">
 </cfloop>
 <thead>
 <tr>
     <th>#((qBudget.Allocation_Position_Level eq "4") ? "Customer" : "Position")#</th>
     <th class="mid">Original</th>
     <th class="mid">Adjustment</th>
     <th class="mid">Budget</th>
     <th class="mid">Committed</th>
     <th class="mid">Balance</th>
     <th class="mid">Actual</th>
     <th class="mid">Balance</th>
 </tr>
 </thead>
 <tfoot>
 <tr>
     <th class="total" id="total"></th>
     <th class="total" id="original_total"></th>
     <th class="total" id="adjustment_total"></th>
     <th class="total" id="budget_total"></th>
     <th class="total" id="committed_total"></th>
     <th class="total" id="committed_balance"></th>
     <th class="total" id="actual_total"></th>
     <th class="total" id="actual_balance"></th>
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
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>

<script type="text/javascript">
$.prompt.setDefaults( { opacity:'0.3', prefix:'cleanblue', top:'35%' } );
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var grid = $('table#datagrid').dataTable({
	 "bAutoWidth": false
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
	,"bServerSide": true
	,"sAjaxSource": "ajax/calculateAccrual.cfm"
  ,"sDom": 'ftir'
  ,"aaSorting": [[ 0, "asc" ]] <!---sort on 1st column--->
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"aoColumns": [   {}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false}
                  , {"sClass":"dollar", "bSortable":true, "bSearchable":false} ]
  ,"fnServerData": function ( sSource, aoData, fnCallback ) {
  		<!---pass budget_id and calculation indicator (optional) to ajax template to process--->
			aoData.push( { "name":"budget_id", "value":"<cfoutput>#form.budget_id#</cfoutput>" } );
      aoData.push( { "name":"allocation_position_level", "value":"<cfoutput>#qBudget.Allocation_Position_Level#</cfoutput>" } );
			<cfif StructKeyExists(url, 'calculate')>
			  aoData.push( { "name":"calculate", "value":"1" } );
			</cfif>
			$.ajax( {   "dataType": 'json'
			          , "type": "POST"
			          , "url": sSource
			          , "data": aoData
			          , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
                                              $tfoot.find('#budget_total').text(json.budget_dollar);
                                              $tfoot.find('#original_total').text(json.original_budget_dollar);
                                              $tfoot.find('#adjustment_total').text(json.adjustment_dollar);
                                              $tfoot.find('#committed_total').text(json.committed_dollar);
                                              $tfoot.find('#committed_balance').text(json.committed_balance);
                                              $tfoot.find('#actual_total').text(json.actual_dollar);
                                              $tfoot.find('#actual_balance').text(json.actual_balance);
                                              $tfoot.find('#total').text('Total:');
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
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

<!--------------------------------------------------------------------------------------------------------------------->
<!--- 35750 --->
getCSVData = function() {
 var csv_value = $('table#datagrid').table2CSV({
			                                            csvExclude: 'csvExclude'         // filter out elements with csvExclude class
			                                         });
 $("#csv_file_name").val("Accrual Budget Report " + ' ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv');
 $("#csv_text").val(csv_value);
 $("#csv_form").submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
</script>