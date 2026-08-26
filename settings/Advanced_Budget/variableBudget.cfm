<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\variableBudget.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Add/Edit variable budget
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="edit" default="1" >
<cfparam name="form.bySearch"      default="">
<cfset url.bySearch = form.bySearch>

<cfif form.clicked_save eq "1">
  <cfset saveVariableBudget()>
  <script type="text/javascript">
    <!---place the new budget id into the form element when applicable--->
    if ( document.forms[budget_form].budget_id.value == "0" ) {
      document.forms[budget_form].budget_id.value = "<cfoutput>#form.budget_id#</cfoutput>";
    }
    document.forms[budget_form].command.value = "templates";
    document.forms[budget_form].submit();
  </script>
</cfif>

<cfif form.load_fromdb eq "1">
  <cfset loadVariableBudget()>
</cfif>

<div style="margin:0px">
<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;">Budget - <cfif form.budget_id eq 0>Add<cfelse>Edit</cfif></legend>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->


<cfinclude template="budgetgeneral.cfm">

<CF_MessageWindow>

<div style="clear:both;float:left;margin:15px 0 0 115px">
	<cfoutput>
		<cfif qGetCreateBudget.Create_Budget>
			<a href="javascript:savevariable()">#LCase(ActionText("save"))#</a>
		</cfif>
			<a href="javascript:window.location='index.cfm?bySearch=#form.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#'" style="margin:30px">#LCase(ActionText("return to budgets list"))#</a>
	</cfoutput>
</div>
</div>
</fieldset>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="loadVariableBudget" output="false">
  <cfquery name="vars.budget" datasource="#application.datasource#">
      SELECT Budget_desc
             , Budget_Group_Id
             , Budget_Class_Id
             , Budget_Contribution_Factor_Type_Id
             , Budget_Code
             , Business_Segment_Id
             , Is_Perpetual<!---D64149 --->
        FROM Budget
       WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfscript>
     form.Budget_desc      = vars.budget.Budget_desc;
     form.Budget_Group_Id  = vars.budget.Budget_Group_Id;
     form.Budget_Class_Id  = vars.budget.Budget_Class_Id;
     form.Budget_Code      = vars.budget.Budget_Code;
     form.Business_Segment_Id = vars.budget.Business_Segment_Id;
     form.Budget_Contribution_Factor_Type_Id = vars.budget.Budget_Contribution_Factor_Type_Id;
     form.Is_Perpetual = vars.budget.Is_Perpetual;//D64149
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveVariableBudget" output="false">
  <cfset var vars = {}>
  <cfquery name="vars.budget" datasource="#application.datasource#">
      <cfif form.budget_id eq 0>
    	  SET NOCOUNT ON
        INSERT INTO BUDGET
            ( Budget_Desc
            , Budget_Group_ID
            , Budget_Class_ID
            , Budget_Contribution_Factor_Type_ID
            , Active
            , Deleted
            , Created_Date
            , Budget_Code
            , Business_Segment_Id
            , Is_Perpetual<!---D64149 --->
            , Last_Updated_By
            )
        VALUES
            ( <cfqueryparam value="#form.Budget_Desc#" cfsqltype="cf_sql_varchar">
            , <cfqueryparam value="#form.Budget_Group_ID#" cfsqltype="cf_sql_integer">
            , <cfqueryparam value="#form.Budget_Class_ID#" cfsqltype="cf_sql_integer">
            , <cfqueryparam value="3" cfsqltype="cf_sql_integer">
            , 0
            , 0
            , GetDate()
            , <cfqueryparam value="#form.Budget_Code#" cfsqltype="cf_sql_varchar">
            , <cfqueryparam value="#Val(form.Business_Segment_Id)#" cfsqltype="cf_sql_integer">
			, <cfqueryparam value="#form.Is_Perpetual#" cfsqltype="cf_sql_bit"><!---D64149 --->
            , <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
            )
        <!---get the new Budget_Id--->
      	SELECT Budget_Id = @@IDENTITY
      	SET NOCOUNT OFF
      <cfelse>
        UPDATE Budget
           SET   Budget_Code = <cfqueryparam value="#form.Budget_Code#" cfsqltype="cf_sql_varchar">
               , Budget_Desc = <cfqueryparam value="#form.Budget_Desc#" cfsqltype="cf_sql_varchar">
               , Budget_Group_Id = <cfqueryparam value="#form.Budget_Group_ID#" cfsqltype="cf_sql_integer">
               , Budget_Class_Id = <cfqueryparam value="#form.Budget_Class_ID#" cfsqltype="cf_sql_integer">
               , Budget_Contribution_Factor_Type_ID = <cfqueryparam value="3" cfsqltype="cf_sql_integer">
               , Business_Segment_Id = <cfqueryparam value="#Val(form.Business_Segment_Id)#" cfsqltype="cf_sql_integer">
			   , Is_Perpetual = <cfqueryparam value="#form.Is_Perpetual#" cfsqltype="cf_sql_bit"><!---D64149 --->
         WHERE Budget.Budget_ID = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
        <cfinclude template="last_update.cfm">       <!--- 36874 --->
      </cfif>
  </cfquery>
  <cfif form.Budget_Id eq 0>
    <!---get the new Budget_Id--->
    <cfset form.Budget_Id = vars.Budget.Budget_Id>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="labelInMessage" output="false">
  <cfargument name="label" required="true">
  <cfreturn Lcase(Replace(arguments.label, ":", ""))>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/string_functions.min.js"></script>

<script type="text/javascript">
// turn off loading from db flag
document.forms[budget_form].load_fromdb.value  = "0";
function savevariable() {
  var vars = {};
  vars.errors = 0;
  /* validate form fields */
  if ( trim(document.forms[budget_form].budget_code.value).length > 0 )
    clearQueue(document.all.error_budget_code);
  else {
    vars.errors++; queueMessage("Please enter the " + <cfoutput>"#labelInMessage(formlabels.code)#."</cfoutput>, document.all.error_budget_code);
  }
  if ( trim(document.forms[budget_form].budget_desc.value).length > 0 )
    clearQueue(document.all.error_budget_desc);
  else {
    vars.errors++; queueMessage("Please enter the " + <cfoutput>"#labelInMessage(formlabels.desc)#."</cfoutput>, document.all.error_budget_desc);
  }
  if ( document.forms[budget_form].budget_class_id.value != 0 )
    clearQueue(document.all.error_budget_class_id);
  else {
    vars.errors++; queueMessage("Please select the " + <cfoutput>"#labelInMessage(formlabels.class)#."</cfoutput>, document.all.error_budget_class_id);
  }
  if ( document.forms[budget_form].budget_group_id.value != 0 )
    clearQueue(document.all.error_budget_group_id);
  else {
    vars.errors++; queueMessage("Please select the " + <cfoutput>"#labelInMessage(formlabels.group)#."</cfoutput>, document.all.error_budget_group_id);
  }
  <cfif busSegMgr.isEnabled>
    if ( document.forms[budget_form].business_segment_id.value != 0 )
      clearQueue(document.all.error_business_segment_id);
    else {
      vars.errors++; queueMessage("Please select the " + <cfoutput>"#labelInMessage(formlabels.segment)#."</cfoutput>, document.all.error_business_segment_id);
    }
  </cfif>

  if ( vars.errors > 0 )
    showMessageWindow();
  else {
    document.forms[budget_form].clicked_save.value = "1";
    document.forms[budget_form].submit();
  }
}
<!--------------------------------------------------------------------------------------------------------------------->
function switchfactor( factor ) {
  if ( factor.value == 3)
    return false;
  if ( factor.value == 1)
    document.forms[budget_form].command.value = "editFixed";
  else if ( factor.value == 2)
    document.forms[budget_form].command.value = "editAccrual";
  document.forms[budget_form].submit();
}

$('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();

</script>