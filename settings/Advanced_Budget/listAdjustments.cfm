<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\adjustments.cfm
      Date:     May 25, 2012
      Author:   Chris Nguyen
      Purpose:  List budget adjustments
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.clicked_save" default="0">
<input type="hidden" name="clicked_save" id="clicked_save" value="0">

<cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabledForBudget()/>

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.dollar { text-align:right; }
#mainfieldset { width:98%; padding:1%; border:1px solid blue; }
#actions { margin-bottom:10px; }
#actions a { margin:0 30px 0 0;}
.even { width:<cfif busSegMgr.isEnabled>33%<cfelse>50%</cfif>; }
.mid { text-align: center; }
div.save { margin-top:10px; }
table.datagrid {
	table-layout:fixed;
}
th {
  text-align:left;
}
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Overlays
           , Overlay_Recapture
           , Recapture
           , Budget.Business_Segment_Id
           , bs.Business_Unit_Desc
           , Position_Control_Type
           , Allocation_Position_Level
           , Budget_Owner_Position_ID
      FROM Budget
     INNER JOIN Budget_Class bc ON Budget.Budget_Class_ID = bc.Budget_Class_ID
      LEFT JOIN Business_Segment bs ON Budget.Business_Segment_Id = bs.Business_Segment_Id
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Fixed Adjustments</legend>

<!---display heading--->
<cfinclude template="displayBudgetHeading.cfm">
<cfset displayBudgetHeading( form.Budget_Id )>

<div id="actions">
  <CFIF Get_Profile_Settings.Create_Budget eq 0 > 
    #application.util.string.actionLinkFormat("create accrual adjustment")#
  <CFELSE> 
    <a href="##" id="create">#application.util.string.actionLinkFormat("create accrual adjustment")#</a><!---D34797 :Rename: Budget - Fixed Adjustments --->
  </CFIF>
<a href="##" id="upload">#application.util.string.actionLinkFormat("import from excel")#</a>
<a href="##" id="download">#application.util.string.actionLinkFormat("export")#</a>
<a href="##" id="cancel">#application.util.string.actionLinkFormat("return to budgets list")#</a>
</div>

<!--------------------------------------------------------------------------------------------------------------------->
<cfset labels = structnew()>
<cfif qBudget.Position_Control_Type neq "1">
	<cfset labels.customer_position = "Position">
<cfelse>
	<cfswitch expression="#qBudget.Allocation_Position_Level#">
		<cfcase value="0">
			<cfscript>
			  positionManager = CreateObject("component", "components.geography.position").init();
			  qGetHQPosition  = positionManager.getHQPosition();
			  labels.customer_position = qGetHQPosition.Position_Label;
			</cfscript>
		</cfcase>
		<cfcase value="1">
			<cfset labels.customer_position = application.returned_customer_setting.zone_label_plural>
		</cfcase>
		<cfcase value="2">
			<cfset labels.customer_position = application.returned_customer_setting.region_label_singular>
		</cfcase>
		<cfcase value="3">
			<cfset labels.customer_position = application.returned_customer_setting.market_label_singular>
		</cfcase>
		<cfcase value="4">
			<cfset labels.customer_position = "Customer">
		</cfcase>
		<cfdefaultcase>
			<cfset labels.customer_position = "">
		</cfdefaultcase>
	</cfswitch>
</cfif>

<div>  <!---templates--->
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [2.5, 1, 2, 0.7, 0.7, 2, 1.3, 2] )>
<table class="datagrid" style='table-layout:fixed'>
<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
</cfloop>
<thead>
<tr>
 <th>#labels.customer_position#</th>
 <th style="text-align:left;">Amount</th>
 <th>Type</th>
 <th>Start</th>
 <th>End</th>
 <th>Created By</th>
 <th>Created Date</th>
 <th>Notes</th>
</tr>
</thead>
<tbody>
  <!--- <td colspan="8">Gathering data from server, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td> --->
</tbody>
</table>
</div>  <!---templates--->
</fieldset>
</cfoutput>

<input type="hidden" name="uploadedFileName" id="uploadedFileName">

<!--------------------------------------------------------------------------------------------------------------------->
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
<!---event for import-------------------------------------------------------------------------------------------------->
function import_handler( uploadedFileName ) {
  $('#uploadedFileName').val( uploadedFileName );
  document.forms[budget_form].command.value = "importAdjustments";
  document.forms[budget_form].submit();
  return false;
}
<!---turn off loading from db flag--->
document.forms[budget_form].load_fromdb.value  = "0";
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
$('table.datagrid').dataTable({
	 "bAutoWidth": false
	,"bPaginate": true
  ,"bProcessing": true
  ,"bServerSide": true
  ,"iDisplayLength": 100
  ,"sAjaxSource": <cfoutput>"ajax/listAdjustments.cfm?budget_id=#form.budget_id#"</cfoutput>
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fptipr'
  ,"aaSorting": []
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"aoColumns": [ { }
                 ,{ "sClass":"dollar" }
                 ,{ }
                 ,{ }
                 ,{ }
                 ,{ }
                 ,{ }
                 ,{"bSortable":false}
  							]
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
}).fnSetFilteringDelay();
$('table.datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
<!---event for cancel-------------------------------------------------------------------------------------------------->
$('#cancel').click(function(){
  <cfoutput>
  window.location = 'index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';
  </cfoutput>
  return false;
});
<!---event for create-------------------------------------------------------------------------------------------------->
$('#create').click(function(){
  document.forms[budget_form].command.value = "addAdjustment";
  document.forms[budget_form].submit();
  return false;
});
$('#upload').click(function(){
	var height = 520, width = 550;
	<cfoutput>
		NewWindow("/settings/advanced_budget/uploadadjustment.cfm?data_handler=import_handler&budget_id=#form.budget_id#&height=" + height + "&width=" + width, "importwindow", width, height, "no", "no");
  </cfoutput>
});
<!--------------------------------------------------------------------------------------------------------------------->
$('#download').click(function(){
	var height = 520, width = 550;
	<cfoutput>
		NewWindow("/settings/advanced_budget/downloadadjustment.cfm?budget_id=#form.budget_id#&height=" + height + "&width=" + width, "importwindow", width, height, "no", "no");
  </cfoutput>
});

</script>



