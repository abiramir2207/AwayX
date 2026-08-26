<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\listComponent.cfm
      Date:     June 19, 2011
      Author:   Chris Nguyen
      Purpose:  List components
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.mid {
  text-align: center;
}
td.mid {
  align: center;
}
.action {
  font-weight:bold;
}
</style>
</cfsavecontent>

<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = {};
  cfvars = {};
  busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
  busSegMgr.isEnabled = busSegMgr.obj.isEnabledForBudget();
  appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="vars.qComponents" datasource="#application.datasource#">
  SELECT DISTINCT v_Program_Component_Name.*
                  , Discount_Type.Discount_Type_desc
                  , Business_Segment.Business_Unit_desc
                  , Sum( CASE
                           WHEN Budget_Class_Component_Mapping.Budget_Id IS NULL THEN 1
                           ELSE 0
                         END ) OVER (Partition BY v_Program_Component_Name.Discount_Type_Id, v_Program_Component_Name.Component_Name_Id) AS Class_Gap
    FROM v_Program_Component_Name
         INNER JOIN Discount_Type
           ON Discount_Type.Discount_Type_Id = v_Program_Component_Name.Discount_Type_Id
         LEFT JOIN Business_Segment
           ON Business_Segment.Business_Segment_Id = v_Program_Component_Name.Business_Segment_Id
         LEFT JOIN Budget_Class
           ON Budget_Class.Deleted = 0
              AND Budget_Class.Active = 1
              AND Budget_Class.Is_Fiscal = v_Program_Component_Name.Is_Fiscal
         LEFT JOIN Budget_Class_Component_Mapping
           ON Budget_Class_Component_Mapping.Budget_Class_Id = Budget_Class.Budget_Class_Id
              AND Budget_Class_Component_Mapping.Discount_Type_Id = v_Program_Component_Name.Discount_Type_Id
              AND Budget_Class_Component_Mapping.Component_Name_Id = v_Program_Component_Name.Component_Name_Id
   WHERE v_Program_Component_Name.Deleted = 0
</cfquery>

<cfoutput>
<cfif busSegMgr.isEnabled>
 <cfset busSegMgr.qSegments = busSegMgr.obj.getActive()>
 <cfsavecontent variable="segment_dropdown"><select name="business_segment_id" onchange="segment(this)" style="width=90%"><option value="0">select</option><cfloop query="busSegMgr.qSegments"><option value="#busSegMgr.qSegments.business_segment_id#">#busSegMgr.qSegments.Business_Unit_Desc#</option></cfloop></select></cfsavecontent>
 <!---<cfdump var="#segment_dropdown#" label="">--->
<cfelse>
  <cfset segment_dropdown = "">
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Components - List</legend>
<div style="margin:5px">
<table id="datagrid" class="datagrid" style="width:100%">
<thead>
<tr>
    <th class="mid">Select</th>
    <th>Description</th>
    <th>ID</th>
    <th>Type</th>
    <cfif busSegMgr.isEnabled><th>#appSettings.getbusiness_segment_label()#</th></cfif>
    <th class="mid">Year Type</th>
    <!---<th class="mid">In Use?</th>--->
    <th class="mid">Class Gap?</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<cfloop query="vars.qComponents">
<input name="row_#vars.qComponents.currentRow#" type="hidden" value="">
<input name="comp_#vars.qComponents.currentRow#" type="hidden" value="">
<tr>
 <td class="mid"><input name="check" id="rd_#vars.qComponents.currentRow#" onclick="checkit(this)" type="radio"></td>
 <td class="component_name">#vars.qComponents.component_name#</td>
 <td class="component_name_id" id="#vars.qComponents.component_name_id#">#vars.qComponents.external_id#</td>
 <td class="discount_type" id="#vars.qComponents.Discount_Type_Id#">#vars.qComponents.Discount_Type_desc#</td>
 <cfif busSegMgr.isEnabled><td class="segment">#vars.qComponents.Business_Unit_desc#</td></cfif>
 <td class="year mid"><cfif vars.qComponents.is_fiscal>Fiscal<cfelse>Calendar</cfif></td>
 <!---<td></td>--->
 <td class="mid"><cfif vars.qComponents.Class_Gap gt 0>yes</cfif></td>
 <td class="action"></td>
</tr></cfloop>
</tbody>
</table>
</div>
</fieldset>

<!---these hidden vars will be passed to the next page--->
<input name="component_id"        type="hidden">
<input name="external_id"         type="hidden">
<input name="component_name"      type="hidden">
<input name="discount_type_id"    type="hidden">
<input name="discount_type_desc"  type="hidden">
<input name="bussegmgr_isenabled" type="hidden" value="#busSegMgr.isEnabled#">
<cfif not busSegMgr.isEnabled>
  <input name="business_segment_id"  type="hidden" value="0">
</cfif>
<input name="business_segment_desc"  type="hidden" value="">
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.5.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.cfjs.min.js"></script>
<!---<script type="text/javascript" src="/script/javascript/fixedheader.min.js"></script>--->

<script type="text/javascript">
var checked_row = null, checked_segment = null, checked_year = null;
var dgrid = $('#datagrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti'
  ,"sScrollXInner": "100%"
  <!---,"sScrollY": "1000px"--->
  ,"aaSorting": [[ 1, "asc" ]] <!---default sorting on code column--->
  ,"aoColumns": [   {"sWidth": "5%", "bSortable":false, "bSearchable":false}
                  , {"sWidth": "20%"}
                  , {"sWidth": "9%"}
                  , {"sWidth": "9%"}
                  <cfif busSegMgr.isEnabled> ,{"sWidth": "20%", "bSortable":true, "bSearchable":true} </cfif>
                  , {"sWidth": "11%", "bSortable":true, "bSearchable":false}
                  <!---, {"sWidth": "9%", "bSortable":false, "bSearchable":false}--->
                  , {"sWidth": "9%", "bSortable":true, "bSearchable":false}
                  , {"sWidth": "17%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
<!---$(window).resize(function(){ dgrid.fnAdjustColumnSizing(); });--->
$('table#datagrid tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
<!--------------------------------------------------------------------------------------------------------------------->
function assign_budgets( obj ) {
  var error_msg = "";
  <!---make sure required fields are entered--->
  <cfif busSegMgr.isEnabled>
    if ( document.forms[budget_form].business_segment_id.selectedIndex == 0 )
      error_msg = error_msg + (error_msg ? "\n" : "") + "Please select a business segment.";
  </cfif>
  if ( document.forms[budget_form].year_type.selectedIndex == 0 )
    error_msg = error_msg + (error_msg ? "\n" : "") + "Please select a year type.";
  <!---if required fields are missing stop--->
  if ( error_msg ) {
    alert( error_msg );
  }
  else {
    document.forms[budget_form].command.value = 'assignbudgets';
    document.forms[budget_form].submit();
  }
  return false;
}
<!--------------------------------------------------------------------------------------------------------------------->
function checkit( radio_button ) {
 var curr_row = null;
 <!---disable the current checked row--->
 if ( checked_row != null ) {
   curr_row = $( '#' + checked_row ).parents('tr');
   <!---restore the previous values for segment & year--->
   curr_row.find('.segment').html( checked_segment );
   curr_row.find('.year').html( checked_year );
   curr_row.find('.action').html( "" );
 }

 <!---enable the new checked_row--->
 checked_row = radio_button.id;
 curr_row = $( '#' + radio_button.id ).parents('tr');
 <!--------------------------------------------------------------------------------------------------------------------->
 <!---save the current values for segment & year in case users select a different row we can restore the old values--->
 checked_segment = curr_row.find('.segment').html();
 document.forms[budget_form].business_segment_desc.value = checked_segment;
 checked_year    = curr_row.find('.year').html();
 <!--------------------------------------------------------------------------------------------------------------------->
 <!---insert drop-downs to the new checked row--->
 curr_row.find('.year').html( "<select name='year_type'><option>select</option><option>Calendar</option><option>Fiscal</option></select>" );
 <!---find the appropriate selected option--->
 curr_row.find('.year option').each(function() {
   if ( $.CompareNoCase(checked_year, $(this).text()) == 0 ) {
     $(this).attr('selected', true);
   }
 });
 <!--------------------------------------------------------------------------------------------------------------------->
 curr_row.find('.action').html( "<a href='#' onclick='javascript:return assign_budgets();' class='action'><font color=red>[</font> assign budgets <font color=red>]</font> </a>" );
 curr_row.find('.segment').html( '<cfoutput>#segment_dropdown#</cfoutput>');
 <!---find the appropriate selected option--->
 curr_row.find('.segment option').each(function() {
   if ( $.CompareNoCase(checked_segment, $(this).text()) == 0 ) {
     $(this).attr('selected', true);
   }
 });
 document.forms[budget_form].external_id.value    = curr_row.find('.component_name_id').text();
 document.forms[budget_form].component_id.value   = curr_row.find('.component_name_id')[0].id;
 document.forms[budget_form].component_name.value = curr_row.find('.component_name').text();
 document.forms[budget_form].discount_type_id.value   = curr_row.find('.discount_type')[0].id;
 document.forms[budget_form].discount_type_desc.value = curr_row.find('.discount_type').text();;
 dgrid.fnAdjustColumnSizing();
}
<!--------------------------------------------------------------------------------------------------------------------->
function segment( obj ) {
 //alert( obj.options[obj.selectedIndex].text );
 document.forms[budget_form].business_segment_desc.value = obj.options[obj.selectedIndex].text;
}
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
<!---new FixedHeader ( dgrid );--->
</script>

