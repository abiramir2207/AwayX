<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\recaptures.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Add/Edit template recaptures & attained rates/uoms
----------------------------------------------------------------------------------------------------------------------->

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.mid { text-align: center; }
td.mid { align: center; }
.uom { width: 63px; margin-left:4px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfif form.clicked_save eq "1">
  <cfset saveRecaptures()>
  <!---redirect to budgets list--->
  <!---<cflocation url="index.cfm" addtoken="no">--->
  <script>
  document.forms[budget_form].command.value = "listAdjustments";   /*32147*/
  document.forms[budget_form].submit();
  </script>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabledForBudget()/>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="qBudget" datasource="#application.datasource#">
    SELECT Budget_desc
           , Budget_Code
           , Overlays
           , Overlay_Recapture
           , Recapture
           , Business_Segment_Id
      FROM Budget
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>
<!---get all templates--->
<cfquery name="qTemplates" datasource="#application.datasource#">
    SELECT distinct Created_Type
           , First_Parent_ID
           , Program_Description
      FROM Program_Control_Panel_Options
           <cfif busSegMgr.isEnabled>
           INNER JOIN Template_Business_Segment
             ON Template_Business_Segment.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
            AND Template_Business_Segment.Business_Segment_ID = <cfqueryparam value="#Val(qBudget.Business_Segment_ID)#" cfsqltype="cf_sql_integer">
            AND Template_Business_Segment.Deleted = 0
           </cfif>
     WHERE
           <cfif ( qBudget.Recapture eq 1 )
               or (qBudget.Overlay_Recapture eq 1) >
                 Program_Control_Panel_Options.Deleted = 0
             AND IsDominant = 1
             AND Generic_Type in ('Operator-Deviated Pricing', 'Operator Direct or HQ Programs')
           <cfelse>
             0 = 1
           </cfif>
</cfquery>
<!---get previously entered recaptures--->
<cfquery name="qRecaptures" datasource="#application.datasource#">
    SELECT Template_First_Parent_ID
           , Budget_Recapture
           , Overlay_Recapture
      FROM Budget_Recapture_Template
     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>
<!---get previously entered inclusion on products tab--->
<cfquery name="qInclusions" datasource="#application.datasource#">
    SELECT COUNT(*) AS Count
      FROM Budget_Product_Rate
     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
           AND Inclusion_In_Overlay = 1
</cfquery>
<!---get previously entered attained rates on this tab--->
<cfquery name="qOverlayRates" datasource="#application.datasource#">
    SELECT Count_Attained
           , Overlay_Rate
           , Overlay_Rate_UOM
      FROM Budget_Overlay_Rate
     WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>
<cfquery name="qUOM" datasource="#application.datasource#">
    SELECT   Budget_Units_of_Measure_ID
           , Unit_Of_Measure_Abbreviation
      FROM Budget_Units_of_Measure
     WHERE Deleted = 0
           AND Budget_Units_of_Measure_ID < 40
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
  template_elements = {};
  attained_elements = {};
  form.Budget_Code  = qBudget.Budget_Code;
  form.Budget_desc  = qBudget.Budget_desc;
</cfscript>

<!---load previously entered template recaptures into form--->
<cfloop query="qTemplates">
  <cfset set_template_elements( qTemplates.First_Parent_ID )>
  <cfquery name="qData" dbtype="query">
    SELECT *
      FROM qRecaptures
     WHERE Template_First_Parent_ID = #qTemplates.First_Parent_ID#
  </cfquery>
  <cfif qData.RecordCount>
    <cfset form['#template_elements.recapture#'] = qData.Budget_Recapture>
    <cfset form['#template_elements.overlay#']   = qData.Overlay_Recapture>
  </cfif>
</cfloop>

<!---load previously entered attained rates into form--->
<cfloop query="qOverlayRates">
  <cfset set_attained_elements( qOverlayRates.Count_Attained )>
  <cfset form['#attained_elements.overlay#'] = qOverlayRates.Overlay_Rate>
  <cfset form['#attained_elements.overlay_uom#'] = qOverlayRates.Overlay_Rate_UOM>
</cfloop>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<div style="margin:0px">
<fieldset id="mainfieldset" style="padding:1%; width:98%; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - Advanced</legend>

<CF_MessageWindow>

<!---display heading--->
<!--- <div style="margin-top:5px" >
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td><font size=2>Code: <b>#form.budget_code#</b></font></td>
    <td align=right><font size=2>Budget Description: <b>#form.budget_desc#</b></font></td>
  </tr>
</table>
<hr width=100%/>
</div> --->
<cfinclude template="displayBudgetHeading.cfm">
<cfset displayBudgetHeading( form.Budget_Id, true )>


<div style="margin:5px 0 5px 0">
 <a href="javascript:savePage()">#LCase(ActionText("save"))#</a>
 <a href="javascript:window.location='index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#
'" style="margin:30px">#LCase(ActionText("return to budgets list"))#</a>
</div>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<!---do not show templates data grid when recapture & overlay recapture are all disabled--->
<cfif ( ( qBudget.Recapture eq 0 ) and ( qBudget.Overlay_Recapture eq 0) )>
 <div style="clear:both"></div>
 <cfset attained_style = "float:left;">
 <cfset form.template_list = "">
<cfelse>
 <cfset attained_style = "float:right;margin-top:35px;">
 <cfset form.template_list = ValueList(qTemplates.First_Parent_ID)>
 <div style="float:left;width:<cfif qBudget.Overlays eq 1>70%<cfelse>100%</cfif>;margin-top:5px;clear:both">  <!---templates--->
 <table class="datagrid" id="tempgrid">
   <thead>
   <tr>
       <th>Template Program Type</th>
       <th>Template Description</th>
       <cfsetting enablecfoutputonly="true" >
       <cfoutput><cfif qBudget.Recapture eq 1><th class="mid">Recapture Base?<br/><input name="recapbase_all" type="checkbox" onclick="process_all( this, '.recapbase' );"></th></cfif></cfoutput>
       <cfoutput><cfif qBudget.Overlay_Recapture eq 1><th class="mid">Recapture Overlay?<br/><input name="overlay_all" type="checkbox" onclick="process_all( this, '.overlay' );"></th></cfif></cfoutput>
       <cfsetting enablecfoutputonly="false" >
   </tr>
   </thead>
   <tbody>
 <cfsetting enablecfoutputonly="true" >
 <cfloop query="qTemplates">
 <cfset set_template_elements( qTemplates.First_Parent_ID )>
 <cfoutput><tr></cfoutput>
  <cfoutput><td>#qTemplates.Created_Type#</td></cfoutput>
  <cfoutput><td>#qTemplates.Program_Description#</td></cfoutput>
  <!---initial values for form elements--->
  <cfparam name="form['#template_elements.recapture#']" default='off'>
  <cfparam name="form['#template_elements.overlay#']"   default='off'>
  <cfoutput><cfif qBudget.Recapture eq 1><td class="mid"><input name="#template_elements.recapture#" type="checkbox" class="recapbase" <cfif form['#template_elements.recapture#'] eq '1'>checked=yes</cfif>/></td></cfif></cfoutput>
  <cfoutput><cfif qBudget.Overlay_Recapture eq 1><td class="mid"><input name="#template_elements.overlay#" type="checkbox" class="overlay" <cfif form['#template_elements.overlay#'] eq '1'>checked=checked</cfif>/></td></cfif></cfoutput>
 <cfoutput></tr></cfoutput>
 </cfloop>
 <cfsetting enablecfoutputonly="false" >
   </tbody>
 </table>
 </div>  <!---templates--->
</cfif>

<cfoutput><input name="template_list" type="hidden" value="#form.template_list#"></cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cfset form.attained_list = "">
<!---display attained data grid--->
<cfif qBudget.Overlays eq 1>
 <div style="<cfoutput>#attained_style#</cfoutput>;width:28%;">  <!---attained--->
 <table class="datagrid" id="attainedgrid">
   <thead>
   <tr>
       <th class="mid"># Attained</th>
       <th class="mid">Overlay Rate<br>/ UOM</th>
   </tr>
   </thead>
 <tbody>
 <cfsetting enablecfoutputonly="true" >
 <cfoutput><cfloop from="1" to="#max(qInclusions.Count, qOverlayRates.RecordCount)#" index="row_cnt"></cfoutput>
 <cfset set_attained_elements( row_cnt )>
 <cfset form.attained_list = ListAppend(form.attained_list, row_cnt)>
 <!---initial values for form elements--->
 <cfparam name="form['#attained_elements.overlay#']" default="0.00">
 <cfparam name="form['#attained_elements.overlay_uom#']" default="0">
 <cfoutput><tr></cfoutput>
 <cfoutput><td class="mid attained">#row_cnt#</td></cfoutput>
 <cfoutput><td class="mid"><input name="#attained_elements.overlay#" value="#form[attained_elements.overlay]#" class="rate" type="text" size="7">  <select name="#attained_elements.overlay_UOM#" class="uom">#uom_options(form[attained_elements.overlay_UOM])#</select></td></cfoutput>
 <cfoutput></tr></cfoutput>
 </cfloop>
 <cfsetting enablecfoutputonly="false" >
 </tbody>
 </table>
 </div>  <!---attained--->
</cfif>
</fieldset>
</div>
<input name="attained_list" type="hidden" value="<cfoutput>#form.attained_list#</cfoutput>">

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="NumericValue" output="false" hint="I return the numeric value of a string.">
  <cfargument name="numericString" required="true" hint="I am the numeric string.">
  <cfif Len(Trim( arguments.numericString )) eq 0>
    <cfreturn 0>
  <cfelseif IsNumeric( arguments.numericString )>
    <cfreturn arguments.numericString>
  <cfelse>
    <cfreturn 0>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveRecaptures" output="false">
  <cfset var vars = {}>

  <cftransaction>
  <cfloop list="#form.template_list#" index="vars.entry">
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT 1
        FROM Budget_Recapture_Template
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
         AND Template_First_Parent_ID = <cfqueryparam value="#vars.entry#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!---determine the form element names for this row--->
    <cfset set_template_elements( vars.entry )>
    <!---assign default values to inputs in case they don't exist--->
    <cfparam name="form['#template_elements.recapture#']" default ="off">
    <cfparam name="form['#template_elements.overlay#']"   default ="off">

    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        INSERT INTO Budget_Recapture_Template
          ( Budget_ID
            , Template_First_Parent_ID
            , Budget_Recapture
            , Overlay_Recapture
          )
        VALUES
          ( <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#vars.entry#"   cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#form[template_elements.recapture] eq 'on'#"  cfsqltype="cf_sql_bit">
            , <cfqueryparam value="#form[template_elements.overlay]   eq 'on'#"  cfsqltype="cf_sql_bit">
          )
      </cfquery>
    <!---row exists already, update it--->
    <cfelse>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        UPDATE Budget_Recapture_Template
           SET   Budget_Recapture  = <cfqueryparam value="#form[template_elements.recapture] eq 'on'#"  cfsqltype="cf_sql_bit">
               , Overlay_Recapture = <cfqueryparam value="#form[template_elements.overlay]   eq 'on'#"  cfsqltype="cf_sql_bit">
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
         AND Template_First_Parent_ID = <cfqueryparam value="#vars.entry#" cfsqltype="cf_sql_integer">
      </cfquery>
    </cfif>
  </cfloop>

  <!--------------------------------------------------------------------------------------------------------------------->

  <cfloop list="#form.attained_list#" index="vars.entry">
    <cfquery name="vars.rowExists" datasource="#application.datasource#">
      SELECT 1
        FROM Budget_Overlay_Rate
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
         AND Count_Attained = <cfqueryparam value="#vars.entry#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!---determine the form element names for this row--->
    <cfset set_attained_elements( vars.entry )>
    <!---assign default values to inputs in case they don't exist--->
    <cfparam name="form['#attained_elements.overlay#']"     default ="0">
    <cfparam name="form['#attained_elements.overlay_uom#']" default ="0">

    <!---row does not exist, create one--->
    <cfif vars.rowExists.recordCount eq 0>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        INSERT INTO Budget_Overlay_Rate
          ( Budget_ID
            , Count_Attained
            , Overlay_Rate
            , Overlay_Rate_UOM
          )
        VALUES
          ( <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#vars.entry#"   cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#NumericValue(form[attained_elements.overlay])#" cfsqltype="cf_sql_decimal" scale="4">
            , <cfqueryparam value="#form[attained_elements.overlay_uom]#"           cfsqltype="cf_sql_integer">
          )
      </cfquery>
    <!---row exists already, update it--->
    <cfelse>
      <cfquery name="vars.saveRow" datasource="#application.datasource#">
        UPDATE Budget_Overlay_Rate
           SET   Overlay_Rate     = <cfqueryparam value="#NumericValue(form[attained_elements.overlay])#" cfsqltype="cf_sql_decimal" scale="4">
               , Overlay_Rate_UOM = <cfqueryparam value="#form[attained_elements.overlay_uom]#"           cfsqltype="cf_sql_integer">
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
         AND Count_Attained = <cfqueryparam value="#vars.entry#" cfsqltype="cf_sql_integer">
      </cfquery>
    </cfif>
  </cfloop>
  <cfinclude template="validateAccrual.cfm">

  <cfquery name="vars.saveRow" datasource="#application.datasource#">
    <cfinclude template="last_update.cfm">       <!--- 36874 --->
  </cfquery>
  </cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="set_attained_elements" output="false" hint="I determine the form element names for elements on the attained data grid.">
  <cfargument name="Count_Attained" required="true">
  <!---the prefix should be capitalized & unique so form element can be identified correctly--->
  <cfscript>
      attained_elements.overlay     = "A_"  & arguments.Count_Attained;
      attained_elements.overlay_uom = "AU_" & arguments.Count_Attained;  // form element names for overlay rate & UOM
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="set_template_elements" output="false" hint="I determine the form element names for inputs on the templates data grid.">
  <cfargument name="First_Parent_ID" required="true" hint="I am the unique key for the template.">
  <!---the prefix should be capitalized & unique so form element can be identified correctly--->
  <cfscript>
      template_elements.recapture = "R_" & arguments.First_Parent_ID;
      template_elements.overlay   = "O_" & arguments.First_Parent_ID;  // form element names for recapture rate & UOM
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="uom_options" output="false" hint="I return the options for UOM drop-down">
  <cfargument name="selected" type="string" required="true" hint="I am the current selected option.">
  <cfsavecontent variable="result"><option value=0></option><cfoutput query="qUOM"><option value=#qUOM.Budget_Units_of_Measure_ID# <cfif arguments.selected eq qUOM.Budget_Units_of_Measure_ID>selected</cfif>>#qUOM.Unit_Of_Measure_Abbreviation#</option></cfoutput>
  </cfsavecontent>
  <cfreturn result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<!---<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>--->

<script type="text/javascript">
<!---turn off loading from db flag--->
document.forms[budget_form].load_fromdb.value  = "0";
var templates = $('table#tempgrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti'
  <!---,"sScrollY": "300px"             <!--- datagrid height --->--->
  ,"aaSorting": [[ 0, "asc" ]]     <!--- sort on product planning group column --->
  ,"aoColumns": [   null
			            , null
			            <cfif qBudget.Recapture eq 1>,{ "bSortable":false, "bSearchable":false }</cfif>
                  <cfif qBudget.Overlay_Recapture eq 1>,{ "bSortable":false, "bSearchable":false }</cfif> ]
}).fnSetFilteringDelay();
<cfif qBudget.Overlays eq 1>
var attained = $('table#attainedgrid').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 't'
  <!---,"sScrollY": "300px"             <!--- datagrid height --->--->
  ,"aaSorting": []
  ,"aoColumns": [ { "bSortable":false, "bSearchable":false }
                , { "bSortable":false, "bSearchable":false } ]
});
<!---forceNumeric() plug-in implementation--->
$.fn.forceNumeric = function () {
 return this.each(function () {
    $(this).keydown(function (e) {
        var key = e.which || e.keyCode;
        if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
         ( key >= 48 && key <= 57 ) ||    <!---numbers--->
         ( key >= 96 && key <= 105 ) ||   <!---Numeric keypad--->
         key == 190 || key == 188 || key == 109 ||  <!---comma, period and minus--->
         key == 8 || key == 9 || key == 13 ||  <!---Backspace and Tab and Enter--->
         key == 35 || key == 36 ||             <!---Home and End--->
         ( key >= 37 && key <= 40 ) ||         <!---left, up and right, down arrows--->
         key == 110 ||                         <!---Decimal point on numeric keypad--->
         key == 46 || key == 45) {             <!---Del and Ins--->
          return true;
        }
        return false;
    });
 });
}
$(".rate").forceNumeric();
$("input,select").focus( function() { $(this).parents('tr').addClass( 'over' ); } )
                 .blur( function()  { $(this).parents('tr').removeClass( 'over' ); });
</cfif>
<!--------------------------------------------------------------------------------------------------------------------->
function process_all( element, individualClass ) {
  $(individualClass).attr('checked', element.checked);
}
<!--------------------------------------------------------------------------------------------------------------------->
function savePage() {
  var vars = {};
  vars.errors = 0;

  if ( vars.errors > 0 )
    showMessageWindow();
  else {
  	<cfoutput>
    document.forms[budget_form].action = 'index.cfm?bySearch=#url.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';
  	</cfoutput>
    document.forms[budget_form].clicked_save.value = "1";
    document.forms[budget_form].submit();
  }
}
</script>



