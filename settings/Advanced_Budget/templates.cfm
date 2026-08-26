<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\templates.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Assigned templates to a budget
----------------------------------------------------------------------------------------------------------------------->
<input type="hidden" name="clicked_save" id="clicked_save" value="0">

<cfif form.clicked_save eq "1">
  <cfset saveTemplates()>
  <!---redirect to budgets list--->
  <cflocation url="index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#" addtoken="no">
</cfif>

<cfinvoke  component="components.settings.internalSettings"  method="get_Setting"  returnvariable="variables.Filter_Business_Segments">
  <cfinvokeargument  name="setting_input_name"  value="Filter_Business_Segments">
</cfinvoke>

<cfif Filter_Business_Segments eq 1>
	<!--- No need to filter on segment if segment is not enabled for budget --->
	<cfset Filter_Business_Segments = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").isEnabledForBudget() />	
</cfif>
	
<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { margin-bottom:10px; }
#actions a { margin:0 30px 0 0;}
.even { width:<cfif variables.Filter_Business_Segments>33%<cfelse>50%</cfif>; }
.mid { text-align: center; }
div.save { margin-top:10px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Overlays
           , Overlay_Recapture
           , Recapture
           , Budget.Business_Segment_Id
           , bs.Business_Unit_Desc
      FROM Budget
     INNER JOIN Budget_Class bc ON Budget.Budget_Class_ID = bc.Budget_Class_ID
      LEFT JOIN Business_Segment bs ON Budget.Business_Segment_Id = bs.Business_Segment_Id
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>
<!---get all templates--->
<cfquery name="qTemplates" datasource="#application.datasource#">
    SELECT distinct Created_Type
           , First_Parent_ID
           , Program_Description
      FROM Program_Control_Panel_Options
           <cfif variables.Filter_Business_Segments>
           INNER JOIN Template_Business_Segment
             ON Template_Business_Segment.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
            AND Template_Business_Segment.Business_Segment_ID = <cfqueryparam value="#Val(qBudget.Business_Segment_ID)#" cfsqltype="cf_sql_integer">
            AND Template_Business_Segment.Deleted = 0
           </cfif>
     WHERE Program_Control_Panel_Options.Deleted = 0
             AND IsDominant = 1
</cfquery>
<cfquery name="vars.qSelected" datasource="#application.datasource#">
  SELECT Template_First_Parent_ID
    FROM Budget_Template_Mappings
   WHERE Budget_ID = <cfqueryparam value="#form.Budget_ID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset vars.selected_list = ValueList(vars.qSelected.Template_First_Parent_ID)>

<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
  template_elements = {};
  attained_elements = {};
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<fieldset id="mainfieldset" style="padding:1%; width:98%; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Templates</legend>

<!---display heading--->
<cfinclude template="displayBudgetHeading.cfm">
<cfset displayBudgetHeading( form.Budget_Id )>

<div id="actions">
<CFIF qGetCreateBudget.Create_Budget eq 0>
 #application.util.string.actionTextGrayedOut("save")#
<CFELSE>
 <a href="##" class="save">#LCase(ActionText("save"))#</a>
</CFIF>
 <a href="##" id="cancel">#LCase(ActionText("return to budgets list"))#</a>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<div>  <!---templates--->
<table class="datagrid">
<thead>
<tr>
 <th class="mid"><input id="toggle_all" type="checkbox"></th>
 <th>Template Program Type</th>
 <th>Template Description</th>
</tr>
</thead>
<tbody>
<cfsetting enablecfoutputonly="true">
<cfloop query="qTemplates">
<cfoutput><tr></cfoutput>
<cfoutput><td class="mid"><input name=T_#qTemplates.First_Parent_ID# type=checkbox class="cb" <cfif ListFind(vars.selected_list, qTemplates.First_Parent_ID)>checked=checked</cfif>></td></cfoutput>
<cfoutput><td>#qTemplates.Created_Type#</td></cfoutput>
<cfoutput><td>#qTemplates.Program_Description#</td></cfoutput>
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
</tbody>
</table>
</div>  <!---templates--->
</fieldset>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveTemplates" output="false">
  <cfset var vars = {}>
  <cfset vars.templates = []>

  <!---gather all selected templates--->
  <cfloop collection="#form#" item="vars.item">
    <cfif Left(vars.item, 2) eq "T_">
      <!---extract template_id from form element name--->
      <cfset ArrayAppend(vars.templates, Right(vars.item, Len(vars.item) - 2))>
    </cfif>
  </cfloop>

  <cftransaction>
  <!---remove templates no longer needed--->
  <cfquery name="vars.removals" datasource="#application.datasource#">
    DELETE Budget_Template_Mappings
     WHERE Budget_ID = <cfqueryparam value="#form.Budget_ID#" cfsqltype="cf_sql_integer">
            AND NOT Template_First_Parent_ID IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#ArrayToList(vars.templates)#" list="true"> )
  </cfquery>

  <cfloop array="#vars.templates#" index="vars.item">
    <!---does the row exist?--->
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT 1
        FROM Budget_Template_Mappings
       WHERE Template_First_Parent_ID = <cfqueryparam value="#vars.item#" cfsqltype="cf_sql_integer">
             AND Budget_ID = <cfqueryparam value="#form.budget_ID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0>
      <cfquery name="vars.savePosition" datasource="#application.datasource#">
          INSERT INTO Budget_Template_Mappings
            ( Budget_Id
              , Template_First_Parent_ID
            )
            VALUES
            (   <cfqueryparam value="#form.budget_ID#" cfsqltype="cf_sql_integer">
              , <cfqueryparam value="#vars.item#"      cfsqltype="cf_sql_integer">
            )
      </cfquery>
    </cfif>
  </cfloop>

  <cfquery name="vars.lastUpdate" datasource="#application.datasource#">
    <cfinclude template="last_update.cfm">       <!--- 36874 --->
  </cfquery>
  </cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
<!---turn off loading from db flag--->
document.forms[budget_form].load_fromdb.value  = "0";
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .45) * windowHeight;
var templates = $('table.datagrid').dataTable({
	 "bAutoWidth": false
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti<"save">'
  ,"aaSorting": [[ 1, "asc" ]]
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"aoColumns": [ {"bSortable":true, "bSearchable":false, "sSortDataType":"dom-checkbox", "sWidth": "9%"}
                  , null
			            , null
                ]
}).fnSetFilteringDelay();
$('table.datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('div.save').html("<CFIF qGetCreateBudget.Create_Budget neq 0><a href=''##' class='save'><cfoutput>#LCase(ActionText('save'))#</cfoutput></a></CFIF>");
var cb_count = $('.cb').length;    // count number of checkboxes
<!---events for toggle all checkbox------------------------------------------------------------------------------------>
$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 $('.cb').prop('checked', ( this.checked ) ? true : false );
 e.stopPropagation();
});
<!---event for individual checkbox------------------------------------------------------------------------------------>
$('.cb').change(function(e){      <!---listen for the change event on the toggle--->
  toggle_all();
});
<!---refresh toggle all state----------------------------------------------------------------------------------------->
toggle_all = function() {
  // toggle all is enabled when # of checkboxes equals to # of checked checkboxes otherwise make it disabled
  $('#toggle_all').prop('checked', ( $('.cb:checked').length == cb_count ) ? true : false );
}
<!---event for cancel-------------------------------------------------------------------------------------------------->
$('#cancel').click(function(){
  <cfoutput>
  window.location = 'index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';
  </cfoutput>
  return false;
});
<!---event for save---------------------------------------------------------------------------------------------------->
$('.save').click(function(){
 templates.fnFilter( '' );  // 33261 - redisplay hidden rows to prevent loosing selected data
 $('#clicked_save').val("1");
 $('form[name=' + budget_form + ']').submit();
  return false;
});
<!--------------------------------------------------------------------------------------------------------------------->
toggle_all();
</script>