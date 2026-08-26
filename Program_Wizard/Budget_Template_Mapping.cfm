<!---------------------------------------------------------------------------------------------------------------------
      Template: \Program_Wizard\Budget_Template_Mapping.cfm
      Date:     June 22, 2011
      Author:   Chris Nguyen
      Purpose:  Assign budgets to a template
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title></title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style type="text/css" media=screen>
.action { font-size: 8pt; font-weight:bold; margin:10px 0 10px 0; }
.action label { margin:0 10px 0 30px; }
.action select { position:relative; top:2px; }
.dollar { text-align:right; }
.mid { text-align: center; }
.moveup { margin-top:-5px; }
#budget_form { margin:15px; }
#datatable { margin-top:10px; width:100%; }
#mainfieldset { margin:0px 0; padding:0 1em .5em; border:0 none; border-top:#cccccc 1px solid; }
#mainfieldset legend { margin:0.5em; padding:0 1.5em; background:transparent; color:#003366; font-size:1.1em; font-weight:bold; }
div.save { clear:both;width:120px; margin:5px auto; }
.hidden { display:none; }
</style>
</head>
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<body>
<cfparam name="form.clicked_save" default="0">
<cfparam name="form.load_fromdb"  default="1">
<cfparam name="url.id" 	          default="0">

<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
    		     method="isEnabledForBudget"
     returnVariable="busSegMgr.isEnabled">
</cfinvoke>

<cfscript>
  templateManager = CreateObject("component","components.programs.template.TemplateManager").init();
  template = templateManager.get(url.id);
  Action = "edit";
  pageName = "budget";
  Created_Type = template.getCreatedType();
  Generic_Type = template.getGenericType();
  Active = template.getActive();

  vars = StructNew();
  if ( busSegMgr.isEnabled ) {
   appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
  }
  formlabels = {};
  formlabels.code  = "Code:";
  formlabels.desc  = "Description:";
  formlabels.class = "Class:";
  formlabels.group = "Group:";
  formlabels.segment = "Segment:";
  formlabels.contribution_factor_type = "Budget Type:";
  pagetitle = "PROGRAM WIZARD: BUDGET";
	pageName = "budget";
</cfscript>

<cfif form.clicked_save eq "1">
	<cfset saveBudgets()>
	<!------ Redirect to next page ----->
	<cfinclude template="Next_Page.cfm" />
	<cfabort>
</cfif>

<cfinclude template="/helpsystem/help_link.cfm">
<cfinclude template="/settings/settings_title.cfm">
<cfinclude template="header.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<cfquery name="vars.qBudgets" datasource="#application.datasource#">
 <cfif LockedBy_Current_User eq 1>            <!---edit mode--->
  SELECT b.Budget_ID
         , b.Budget_Code
         , b.Budget_Desc
         , b.Active
         , b.Budget_Status
         , b.Budget_Dollar
         , b.Committed_Dollar
         , b.Actual_Dollar
         , bcft.Contribution_Factor_Type
         , bcft.Budget_Contribution_Factor_Type_ID
         , bc.Budget_Class_Desc
         , bg.Budget_Group_Desc
         , bs.Business_Unit_Desc
    FROM Budget b
    INNER JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
    LEFT JOIN Budget_Contribution_Factor_Type bcft ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
    LEFT JOIN Budget_Group bg ON b.Budget_Group_ID = bg.Budget_Group_ID
    LEFT JOIN Business_Segment bs ON b.business_segment_id = bs.business_segment_id
   WHERE b.Deleted = 0
         AND b.Active = 1
         <cfif busSegMgr.isEnabled and appSettings.getFilterBusinessSegments()>
         AND b.Business_Segment_Id IN ( SELECT Business_Segment_Id
                                        FROM Template_Business_Segment
                                       WHERE Template_Id = <cfqueryparam value="#template.getID()#" cfsqltype="cf_sql_integer">
                                             AND Deleted = 0 )
         </cfif>
 <cfelse>                                     <!---read only mode--->
  SELECT b.Budget_ID
         , b.Budget_Code
         , b.Budget_Desc
         , b.Active
         , b.Budget_Status
         , b.Budget_Dollar
         , b.Committed_Dollar
         , b.Actual_Dollar
         , bcft.Contribution_Factor_Type
         , bcft.Budget_Contribution_Factor_Type_ID
         , bc.Budget_Class_Desc
         , bg.Budget_Group_Desc
         , bs.Business_Unit_Desc
    FROM Budget_Template_Mappings btm
         INNER JOIN Budget b ON b.Budget_ID = btm.Budget_ID AND b.Deleted = 0 AND b.Active = 1
		         <cfif busSegMgr.isEnabled and appSettings.getFilterBusinessSegments()>
			         AND b.Business_Segment_Id IN ( SELECT Business_Segment_Id
			                                        FROM Template_Business_Segment
			                                       WHERE Template_Id = <cfqueryparam value="#template.getID()#" cfsqltype="cf_sql_integer">
			                                             AND Deleted = 0 )
		         </cfif>
            LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
            LEFT JOIN Budget_Contribution_Factor_Type bcft ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
            LEFT JOIN Budget_Group bg ON b.Budget_Group_ID = bg.Budget_Group_ID
            LEFT JOIN Business_Segment bs ON b.business_segment_id = bs.business_segment_id
   WHERE Template_First_Parent_ID = <cfqueryparam value="#template.getFirstParentID()#" cfsqltype="cf_sql_integer">
 </cfif>
</cfquery>

<cfquery name="vars.qSelected" datasource="#application.datasource#">
  SELECT Budget_ID
    FROM Budget_Template_Mappings
   WHERE Template_First_Parent_ID = <cfqueryparam value="#template.getFirstParentID()#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset vars.selected_list = ValueList(vars.qSelected.Budget_ID)>

<cfquery name="vars.qSegments" datasource="#application.datasource#">
	SELECT Business_Segment.Business_Unit_desc
	  FROM Template_Business_Segment
	       LEFT JOIN Business_Segment
	         ON Business_Segment.Business_Segment_Id = Template_Business_Segment.Business_Segment_Id
	 WHERE Template_Business_Segment.Deleted = 0
	       AND Template_Id = <cfqueryparam value="#template.getID()#" cfsqltype="cf_sql_integer">
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<form id="budget_form" action="#cgi.script_name#?id=#url.id#" method="post">
<!---<fieldset id="mainfieldset"><legend>Budgets - List</legend>--->
<div style="width:100%;margin-top:-10px;">
<div style="float:left;" class="action">
<cfif busSegMgr.isEnabled> #appSettings.getbusiness_segment_label()#:&nbsp;&nbsp;</cfif><cfloop query="vars.qSegments">&nbsp;&diams; #vars.qSegments.Business_Unit_desc#&nbsp;</cfloop>
</div>
<div style="float:right;padding-top:14px;">
	<cfif LockedBy_Current_User eq 1>
	 <a href="##" class="save_budgets">#(ActionText("save and continue"))#</a>
	</cfif>
</div>
</div>
<div id="datatable">
<table id="budgets" class="datagrid">
<thead>
<tr>
 <cfif LockedBy_Current_User eq 1><th class="mid"> <input id="toggle_all" type="checkbox"><br/>View <select id="select-dd"><option>All</option><option>Selected</option><option>Not Selected</option></select></th> <th class="hidden"> </th><!--- invisible column ---></cfif>
 <th>#columnLabel(formlabels.code)#</th>
 <th>#columnLabel(formlabels.desc)#</th>
 <th>#columnLabel(formlabels.class)#</th>
 <th>#columnLabel(formlabels.group)#</th>
 <th>#columnLabel(formlabels.contribution_factor_type)#</th>
 <cfif busSegMgr.isEnabled><th>#appSettings.getbusiness_segment_label()#</th></cfif>
 <th class=mid>Budget</th>
 <th class=mid>Committed</th>
 <th class=mid>Actual</th>
</tr>
</thead>
<tbody>
</cfoutput>
<cfsetting enablecfoutputonly="true">
<cfloop query="vars.qBudgets">
<cfoutput><tr id="tr_#vars.qBudgets.Budget_ID#"></cfoutput>
 <cfoutput><cfif LockedBy_Current_User eq 1>
              <td class="mid"><input name=B_#vars.qBudgets.Budget_ID# type=checkbox class="cb" tr-id="tr_#vars.qBudgets.Budget_ID#" <cfif ListFind(vars.selected_list, vars.qBudgets.Budget_ID)>checked=checked</cfif>></td>
              <td class="hidden"><cfif ListFind(vars.selected_list, vars.qBudgets.Budget_ID)>1<cfelse>0</cfif></td>
           </cfif></cfoutput>
 <cfoutput><td>#vars.qBudgets.budget_code#</td><td>#vars.qBudgets.budget_desc#</td></cfoutput>
 <cfoutput><td>#vars.qBudgets.Budget_Class_Desc#</td><td>#vars.qBudgets.Budget_Group_Desc#&nbsp;</td></cfoutput>
 <cfoutput><td>#vars.qBudgets.Contribution_Factor_Type#</td></cfoutput>
 <cfoutput><cfif busSegMgr.isEnabled><td>#vars.qBudgets.Business_Unit_Desc#</td></cfif></cfoutput>
 <cfoutput><td class=dollar>#DollarFormat(vars.qBudgets.Budget_Dollar)#</td></cfoutput>
 <cfoutput><td class=dollar>#DollarFormat(vars.qBudgets.Committed_Dollar)#</td></cfoutput>
 <cfoutput><td class=dollar>#DollarFormat(vars.qBudgets.Actual_Dollar)#</td></cfoutput>
<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
</tbody>
</table>
</div>   <!---datatable--->
<cfif LockedBy_Current_User eq 1>
	<div class="save">
		<a href='##' class='save_budgets'><cfoutput>#(ActionText('save and continue'))#</cfoutput></a>
	</div>
</cfif>

<input type="hidden" name="clicked_save" id="clicked_save" value="0">
<input type="hidden" name="load_fromdb"  value="0">
</form>
<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="columnLabel" output="false">
  <cfargument name="customLabel" required="true">

  <cfreturn Replace(arguments.customLabel, ':', '')>
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="saveBudgets" output="false">
  <cfset var vars = {}>
  <cfset vars.budgets = []>

  <!---gather all selected budgets--->
  <cfloop collection="#form#" item="vars.item">
    <cfif Left(vars.item, 2) eq "B_">
      <!---extract budget_id from form element name--->
      <cfset ArrayAppend(vars.budgets, Right(vars.item, Len(vars.item) - 2))>
    </cfif>
  </cfloop>

  <cftransaction>
  <!---remove budgets no longer needed--->
  <cfquery name="vars.removals" datasource="#application.datasource#">
    DELETE Budget_Template_Mappings
     WHERE Template_First_Parent_ID = <cfqueryparam value="#template.getFirstParentID()#" cfsqltype="cf_sql_integer">
            AND NOT Budget_Id IN ( <cfqueryparam cfsqltype="cf_sql_varchar" value="#ArrayToList(vars.budgets)#" list="true"> )
  </cfquery>

  <cfloop array="#vars.budgets#" index="vars.item">
    <!---does the row exist?--->
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT 1
        FROM Budget_Template_Mappings
       WHERE Budget_Id = <cfqueryparam value="#vars.item#" cfsqltype="cf_sql_integer">
             AND Template_First_Parent_ID = <cfqueryparam value="#template.getFirstParentID()#" cfsqltype="cf_sql_integer">
    </cfquery>
    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0>
      <cfquery name="vars.save" datasource="#application.datasource#">
          INSERT INTO Budget_Template_Mappings
            ( Budget_Id
              , Template_First_Parent_ID
            )
            VALUES
            (   <cfqueryparam value="#vars.item#" cfsqltype="cf_sql_integer">
              , <cfqueryparam value="#template.getFirstParentID()#"   cfsqltype="cf_sql_integer">
            )
      </cfquery>
    </cfif>
  </cfloop>
  </cftransaction>
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
var budget_form = "budget_form";
<!---adjust main fieldset width when user's resolution is too low--->
$('#mainfieldset').css('width', ($(window).width() <= 700) ? "800px" : "98%");
<cfif busSegMgr.isEnabled>
  var column_sizes = ["4%", "8%", "30%", "8%", "8%", "8%", "10%", "8%", "8%", "8%"];
<cfelse>
  var column_sizes = ["4%", "8%", "40%", "8%", "8%", "8%", "0%",  "8%", "8%", "8%"];
</cfif>
var grid = $('#budgets').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti'
  ,"sScrollXInner": "100%"
  <!---,"sScrollY": "100%"--->
  <cfif LockedBy_Current_User eq 1>
    ,"aaSorting": [[ 2, "asc" ]]
  <cfelse>
    ,"aaSorting": [[ 1, "asc" ]]
  </cfif>
  ,"aoColumns": [
                  <cfif LockedBy_Current_User eq 1>{"sWidth": column_sizes[0], "bSortable":false, "bSearchable":false, "sSortDataType":"dom-checkbox" }, {}, </cfif>
                    {"sWidth": column_sizes[1]}
                  , {"sWidth": column_sizes[2]}
                  , {"sWidth": column_sizes[3]}
                  , {"sWidth": column_sizes[4]}
                  , {"sWidth": column_sizes[5]}
                  <cfif busSegMgr.isEnabled>, {"sWidth": column_sizes[6]}</cfif>
                  , {"sWidth": column_sizes[7], "sType":"currency", "bSearchable":false }
                  , {"sWidth": column_sizes[8], "sType":"currency", "bSearchable":false }
                  , {"sWidth": column_sizes[9], "sType":"currency", "bSearchable":false }
                  ]
,"aoColumnDefs": [
                   <cfif LockedBy_Current_User eq 1> { "bVisible": false, "aTargets": [ 1 ] } </cfif>
                 ]

}).fnSetFilteringDelay();
$('table#budgets tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
var cb_count = $('.cb').length;    // count number of checkboxes
<!---event for toggle all checkbox------------------------------------------------------------------------------------>
$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 var toggleChecked = this.checked;
 var rowCnt = 0;
 $('.cb').each( function() {
  $(this).prop('checked', ( toggleChecked ) ? true : false );
  // update invisible column in column #1 based on checked status
  grid.fnUpdate( ( toggleChecked ) ? 1 : 0, rowCnt, 1, 0, 0 );
  rowCnt++;
 });
 e.stopPropagation();
});
<!---event for individual checkbox------------------------------------------------------------------------------------>
$('.cb').change(function(e){      <!---listen for the change event on the toggle--->
  // update invisible column in column #1 based on checked status
  grid.fnUpdate( ( $(this).prop('checked') ) ? 1 : 0, grid.fnGetPosition( document.getElementById( $(this).prop('tr-id') ) ), 1, 0, 0 );
  toggle_all();
});
<!---refresh toggle all state----------------------------------------------------------------------------------------->
toggle_all = function() {
  // toggle all is enabled when # of checkboxes equals to # of checked checkboxes otherwise make it disabled
  $('#toggle_all').prop('checked', ( $('.cb:checked').length == cb_count ) ? true : false );
}
<!---event for save and continue link---------------------------------------------------------------------------------->
$('.save_budgets').click(function() {
 grid.fnFilter( '', 1 );
 grid.fnFilter( '' );   // 33261 - redisplay hidden rows to prevent loosing selected data
 $('#clicked_save').val("1");
 $('#budget_form').submit();
});
<!---event for selected dropdown--------------------------------------------------------------------------------------->
$('#select-dd').change(function(e) {
  var selectedVal = $(this).val();

  // filtering based on data under invisible column
  if ( selectedVal === 'All' ) {
    grid.fnFilter( '', 1 );
  }
  else if ( selectedVal === 'Selected' ) {
    grid.fnFilter( '1', 1 );
  }
  else if ( selectedVal === 'Not Selected' ) {
    grid.fnFilter( '0', 1 );
  }
});
// $('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
<!---initialize toggle all state--------------------------------------------------------------------------------------->
toggle_all();
</script>
</body>
</html>
