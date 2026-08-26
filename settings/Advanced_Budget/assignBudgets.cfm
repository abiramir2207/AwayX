<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\assignBudgets.cfm
      Date:     June 19, 2011
      Author:   Chris Nguyen
      Purpose:  Assign budgets for a component

      Notes:    These are the required form elements to be passed into this template:

                . form.business_segment_id: numeric, pass 0 if business segment is disabled
                . form.business_segment_desc: string
                . form.year_type: 'Fiscal' | 'Calendar'

                . form.component_id: numeric, index key to locate the row in the component table
                . form.component_name: string
                . form.discount_type_id: 1 | 2 | 3 | 4
                . form.discount_type_desc: string

----------------------------------------------------------------------------------------------------------------------->

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<cfscript>
  main = {};
  main.grid_cnt = 0;
  main.component_table = "";
  main.component_key   = "";
  main.class_prefix    = "CLASS_";
  if ( form.discount_type_id eq "1" ) {
    main.component_table = "Program_Fixed_Component_Name";
    main.component_key   = "Program_Fixed_Component_Name_Id";
  }
  else if ( form.discount_type_id eq "2" ) {
    main.component_table = "Program_Rebates_Component_Name";
    main.component_key   = "Program_Rebates_Component_Name_Id";
  }
  else if ( form.discount_type_id eq "3" ) {
    main.component_table = "Program_Lump_Sum_Name";
    main.component_key   = "Program_Lump_Sum_Name_id";
  }
  else if ( form.discount_type_id eq "4" ) {
    main.component_table = "Program_Growth_Components_Name";
    main.component_key   = "Program_Growth_Components_Name_Id";
  }
  main.year_type = ( (form.year_type eq "fiscal") ? 1 : 0 );
  appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
</cfscript>

<!---posting action - trigger multiple updates to the db--->
<cfif form.clicked_save eq "1">
  <cfset save()>
  <!---redirect back to components list--->
  <cflocation url="index.cfm?command=listComponent" addtoken=false>
</cfif>

<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.5.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.cfjs.min.js"></script>

<style>
.info {
  position:relative;
  top:5px;
  left:10px;
}
.budgetclass {
  font-size:13px;
  margin-bottom:10px;
  float:left;
}
.mid {
  text-align: center;
}
td.mid {
  align: center;
}
.action {
  font-weight:bold;
}
.header {
  font-size:13px;
}
</style>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="main.qBudgetClass" datasource="#application.datasource#">
  SELECT Budget_Class_Id
       , Budget_Class_Number
       , Budget_Class_desc
       , Is_Fiscal
       , Year_Selection
       , Start_Date
       , End_Date
       , Active
    FROM Budget_Class
   WHERE Deleted = 0
          AND Active = 1
          AND Is_Fiscal = <cfqueryparam value="#main.year_type#" cfsqltype="cf_sql_bit">
</cfquery>
<cfquery name="main.qComponent" datasource="#application.datasource#">
  SELECT   u.Name_First
         , u.Name_Last
         , c.Last_Edited_Date
    FROM #main.component_table# c
         LEFT JOIN _Users u ON u.User_ID = c.Last_Edited_By
   WHERE #main.component_key# = <cfqueryparam value="#form.component_id#" cfsqltype="cf_sql_integer">
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->

<cfoutput>
<!---include these form elements in the form submission--->
<input name="business_segment_id" type="hidden" value="#form.business_segment_id#">
<input name="year_type"           type="hidden" value="#form.year_type#">
<input name="component_id"        type="hidden" value="#form.component_id#">
<input name="component_name"      type="hidden" value="#form.component_name#">
<input name="discount_type_id"    type="hidden" value="#form.discount_type_id#">

<div style="margin:0px">

<cfif form.Business_Segment_Id neq "0">
  <cfset main.tdWidth = "25%">
<cfelse>
  <cfset main.tdWidth = "33%">
</cfif>

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Component - Assign Budgets</legend>

#ComponentHeader()#
<cfif main.qComponent.Last_Edited_Date neq "">
<div style="text-align:center;font:bold;color:navy">Settings were last updated on #DateFormat(main.qComponent.Last_Edited_Date, "m/d/yyyy")# #LCase(TimeFormat(main.qComponent.Last_Edited_Date, "h:mmtt"))# by #CapFirst(main.qComponent.Name_First)# #CapFirst(main.qComponent.Name_Last)#</div>
</cfif>

<cfloop query="main.qBudgetClass">
 <!---find all budgets that are in this class--->
 <cfquery name="main.qBudget" datasource="#application.datasource#">
   SELECT b.Budget_Id
          , b.Budget_desc
          , b.Budget_Code
          , b.Business_Segment_Id
          , bcft.Contribution_Factor_Type
          , bcft.Budget_Contribution_Factor_Type_ID
          , bc.Budget_Class_Desc
          , bg.Budget_Group_Desc
     FROM Budget b
           LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
           LEFT JOIN Budget_Contribution_Factor_Type bcft ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
           LEFT JOIN Budget_Group bg ON b.Budget_Group_ID = bg.Budget_Group_ID
    WHERE b.Deleted = 0
           AND b.Active = 1
           <cfif form.Business_Segment_Id neq "0">
             AND b.Business_Segment_Id = <cfqueryparam value="#Val(form.Business_Segment_Id)#" cfsqltype="cf_sql_integer">
           </cfif>
           AND b.Budget_Class_Id = <cfqueryparam value="#main.qBudgetClass.Budget_Class_Id#" cfsqltype="cf_sql_integer">
 </cfquery>

<cfif main.qBudget.recordCount gt 0>
 <cfset main.grid_cnt = main.grid_cnt + 1>
 <!---shows a divider and another component header if this is not a first budget class--->
 <cfif main.grid_cnt gt 1>
   <hr style="clear:both"/>
   #ComponentHeader()#
 </cfif>

 <!---pull previous assignment--->
 <cfquery name="main.qMapping" datasource="#application.datasource#">
   SELECT bccm.Budget_Id
          , b.Budget_desc
          , b.Budget_Code
     FROM Budget_Class_Component_Mapping bccm
          LEFT JOIN Budget b ON b.Budget_ID = bccm.Budget_ID
    WHERE Discount_Type_Id = <cfqueryparam value="#form.discount_type_id#" cfsqltype="cf_sql_integer">
          AND Component_Name_ID = <cfqueryparam value="#form.component_id#" cfsqltype="cf_sql_integer">
          AND bccm.Budget_Class_ID = <cfqueryparam value="#main.qBudgetClass.Budget_Class_ID#" cfsqltype="cf_sql_integer">
 </cfquery>

 <cfset main.previous_budget_id = 0>
 <!---budget critiria (class, segment) could be changed, validate previous assignment--->
 <cfif Val(main.qMapping.Budget_id) neq 0>
  <cfquery name="main.qoq" dbtype="query">
    SELECT 1 AS Valid
      FROM main.qBudget
     WHERE Budget_id = #main.qMapping.Budget_id#
  </cfquery>
  <cfif main.qoq.Valid eq "1">
    <cfset main.previous_budget_id = main.qMapping.Budget_id>
  </cfif>
 </cfif>
 <!---save the budget selection for each budget class into this hidden form field value (e.g. value=31)
      and append the budget class id into the element name (e.g. name=CLASS_45)--->
 <input name="#(main.class_prefix & main.qBudgetClass.Budget_Class_ID)#" type="hidden" value="#main.previous_budget_id#"/>

 <!---show budget class heading--->
 <div style="margin:5px">
 <div class="budgetclass">#DisplayField("Budget Class:", main.qBudgetClass.Budget_Class_desc)#
 </div>

 <!---show the budgets datagrid--->
 <table id="datagrid#main.qBudgetClass.currentRow#" class="datagrid">
 <thead>
 <tr>
     <th class="mid">Select</th>
     <th>Budget Description</th>
     <th>Code</th>
     <th>Group</th>
     <th>Type</th>
 </tr>
 </thead>
 <tbody>
 <cfloop query="main.qBudget">
 <tr><!---place budget class id, an underscore & budget id into the radio button id for tracking--->
  <td class="mid"><input name="check" id="#main.qBudgetClass.Budget_Class_ID#_#main.qBudget.Budget_Id#" onclick="assign(this)" <cfif main.qMapping.Budget_Id eq main.qBudget.Budget_id>checked</cfif> type="radio"></td>
  <td>#main.qBudget.Budget_desc#</td>
  <td>#main.qBudget.Budget_Code#</td>
  <td>#main.qBudget.Budget_Group_Desc#</td>
  <td>#main.qBudget.Contribution_Factor_Type#</td>
 </tr></cfloop>
 </tbody>
 </table>
 </div>

 <!----- action links ----->
 <div style="margin:10px 0 0 5px">
  		<a href="javascript:save()">#LCase(ActionText("save"))#</a>
  		<a href="javascript:clear(#main.qBudgetClass.Budget_Class_ID#)" style="margin:20px;">#LCase(ActionText("clear budget selection"))#</a>
  		<a href="javascript:window.location='index.cfm?command=listComponent'">#LCase(ActionText("return to components list"))#</a>
 </div>

 <cfif (main.qMapping.recordCount eq 0) or (main.qMapping.budget_desc eq "")>
   <cfset main.previous_selection = "">
 <cfelse>
   <cfif main.qMapping.Budget_Code eq "">
     <cfset main.Budget_Code = "">
   <cfelse>
     <cfset main.Budget_Code = " ( " & main.qMapping.Budget_Code & " )">
   </cfif>
   <cfset main.previous_selection = DisplayField("Previous selection:", main.qMapping.Budget_desc & main.Budget_code)>
 </cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript">
var grid#main.qBudgetClass.currentRow# = $('##datagrid#main.qBudgetClass.currentRow#').dataTable({
 "bAutoWidth": true
,"bPaginate": false
 ,"bSortClasses": false
 ,"bScrollCollapse": true
 ,"sDom": 'f<"info#main.qBudgetClass.currentRow#">ti'
 ,"sScrollXInner": "100%"
 ,"sScrollY": "400px"         <!---limit datagrid to 400px in height--->
 ,"aaSorting": [ [ 1, "asc" ] ]
 ,"aoColumns": [   {"sWidth": "5%", "bSortable":false, "bSearchable":false}
                 , {"sWidth": "20%"}
                 , {"sWidth": "10%"}
                 , {"sWidth": "10%"}
                 , {"sWidth": "15%", "bSortable":true, "bSearchable":true} ]
}).fnSetFilteringDelay();
$('.info#main.qBudgetClass.currentRow#').html( '#main.previous_selection#' ).addClass( "info" );
$('table##datagrid#main.qBudgetClass.currentRow# tr').hover (
 function() { $(this).addClass("over"); },
 function() { $(this).removeClass("over"); }
);
$(window).resize(function(){
 grid#main.qBudgetClass.currentRow#.fnAdjustColumnSizing();
});
</script>
<!--------------------------------------------------------------------------------------------------------------------->
</cfif>  <!---main.qBudget.recordCount--->
</cfloop>   <!---query="main.qBudgetClass"--->

<cfif main.grid_cnt eq 0>
<p style="text-align:center">There is no budget for the selected component and its criteria.</p>
<div style="margin:10px 0 0 5px">
	<a href="javascript:save()">#LCase(ActionText("save"))#</a>
	<a href="javascript:window.location='index.cfm?command=listComponent'" style="margin:20px">#LCase(ActionText("return to components list"))#</a>
</div>
</cfif>

</fieldset>
</div>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="DisplayField" output="false" hint="I format the display of field">
  <cfargument name="fieldLabel" required="true">
  <cfargument name="fieldValue" required="true">

  <cfreturn arguments.fieldLabel & " <b>" & arguments.fieldValue & "</b>">
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="ComponentHeader" output="true">
<div style="margin-top:5px" >
<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr >
 <td class="header" style="width=#main.tdWidth#">#DisplayField("Component:", form.component_name)#
 <cfif len(form.external_id)><span style="margin-left:0px">#DisplayField("", "(" & form.external_id & ")")#</span></cfif></td>
 <td class="header" style="width=#main.tdWidth#;text-align:center;">#DisplayField("Type:", form.discount_type_desc)#</td>
 <cfif form.Business_Segment_Id neq "0">
  <td class="header" style="width=#main.tdWidth#;text-align:center;">#DisplayField(appSettings.getbusiness_segment_label() & ":", form.business_segment_desc)#</td>
 </cfif>
 <td class="header" style="width=#main.tdWidth#" align=right>#DisplayField("Year Type:", form.year_type)#</td>
</tr>
</table>
<hr width=100%/>
</div>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="save" output="false">
  <cfscript>
    var vars   = {};
  </cfscript>
  <cftransaction>
  <cfquery name="vars.component" datasource="#application.datasource#">
      UPDATE #main.component_table#
         SET Is_Fiscal = <cfif form.year_type eq "Fiscal">1<cfelse>0</cfif>
             <cfif form.Business_Segment_Id neq "0">
              , Business_Segment_ID = <cfqueryparam value="#Val(form.Business_Segment_Id)#" cfsqltype="cf_sql_integer">
             </cfif>
             , Last_Edited_Date = GetDate()
             , Last_Edited_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
       WHERE #main.component_key# = <cfqueryparam value="#form.component_id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <!---update budget assignment for each budget class--->
  <cfloop collection="#form#" item="vars.element">
    <!---find all budget class elements (prefixed with 'CLASS_')--->
    <cfif FindNoCase(main.class_prefix, vars.element)>
      <cfset vars.budget_id = Val(form[vars.element])>
      <!---extract the class id from element name--->
      <cfset vars.class_id  = ListLast(vars.element,'_')>

      <cfquery name="vars.rowExists" datasource="#application.datasource#">
        SELECT 1
          FROM Budget_Class_Component_Mapping
           WHERE Discount_Type_Id = <cfqueryparam value="#form.discount_type_id#" cfsqltype="cf_sql_integer">
                   AND Component_Name_ID = <cfqueryparam value="#form.component_id#" cfsqltype="cf_sql_integer">
                   AND Budget_Class_ID = <cfqueryparam value="#vars.class_id#" cfsqltype="cf_sql_integer">
      </cfquery>

      <cfquery name="vars.mapping" datasource="#application.datasource#">
        <!---row is there, update it--->
        <cfif vars.rowExists.recordCount gt 0>
          UPDATE Budget_Class_Component_Mapping
             SET Budget_id = <cfif vars.budget_id eq 0>null<cfelse><cfqueryparam value="#vars.budget_id#" cfsqltype="cf_sql_integer"></cfif>
           WHERE Discount_Type_Id = <cfqueryparam value="#form.discount_type_id#" cfsqltype="cf_sql_integer">
                   AND Component_Name_ID = <cfqueryparam value="#form.component_id#" cfsqltype="cf_sql_integer">
                   AND Budget_Class_ID = <cfqueryparam value="#vars.class_id#" cfsqltype="cf_sql_integer">
        <cfelse>
          <!---row does not exist, create one--->
          INSERT INTO Budget_Class_Component_Mapping
            ( Budget_Id
            , Discount_Type_Id
            , Component_Name_ID
            , Budget_Class_ID
            )
            VALUES
            ( <cfif vars.budget_id eq 0>null<cfelse><cfqueryparam value="#vars.budget_id#" cfsqltype="cf_sql_integer"></cfif>
            , <cfqueryparam value="#form.discount_type_id#" cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#form.component_id#" cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#vars.class_id#" cfsqltype="cf_sql_integer">
            )
        </cfif>
      </cfquery>
    </cfif>   <!---findnocase--->
  </cfloop>  <!---collection--->
  </cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<script type="text/javascript">
function assign( obj ) {
  var class_id  = $.ListFirst(obj.id, '_'), <!---extract the class id from the first entry of the element id--->
      budget_id = $.ListLast(obj.id, '_');  <!---extract the class id from the second entry of the element id--->
  <!---save the selected budget--->
  document.forms[budget_form].elements[<cfoutput>'#main.class_prefix#'</cfoutput> + class_id].value = budget_id;
}
<!--------------------------------------------------------------------------------------------------------------------->
function clear( class_id ) {
  var budget_id = document.forms[budget_form].elements[<cfoutput>'#main.class_prefix#'</cfoutput> + class_id].value;
  $('#' + class_id + '_' + budget_id).attr('checked', false);
  document.forms[budget_form].elements[<cfoutput>'#main.class_prefix#'</cfoutput> + class_id].value = "";
}
<!--------------------------------------------------------------------------------------------------------------------->
function save() {
  document.forms[budget_form].action = <cfoutput>"#ListLast(GetCurrentTemplatePath(),'\')#"</cfoutput>;
  document.forms[budget_form].clicked_save.value = "1";
  document.forms[budget_form].submit();
}
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
</script>

