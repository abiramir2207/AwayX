<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\budgetFormVars.cfm
      Date:     June 13, 2011
      Author:   Chris Nguyen
      Purpose:  Common form elements for variable, fixed & accrual budgets
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.command"       default="listbudget">
<cfparam name="form.budget_id"     default="0">
<cfparam name="form.read_only"     default="">
<cfparam name="form.clicked_save"  default="0">
<cfparam name="form.load_fromdb"   default="0">

<!---general info--->
<cfparam name="form.Budget_Code"         default="">
<cfparam name="form.Budget_Desc"         default="">
<cfparam name="form.Budget_Class_ID"     default="0">
<cfparam name="form.Budget_Group_ID"     default="0">
<cfparam name="form.Business_Segment_ID" default="0">
<cfparam name="form.Budget_Contribution_Factor_Type_ID" default="">
<cfparam name="form.Is_Perpetual" default="0">

<!---fixed/accrual--->
<cfparam name="form.Notification_Threshold_Commitments"   default="100">
<cfparam name="form.notification_threshold_actuals"       default="100">
<cfparam name="form.Allocation_Position_Level"            default="">
<cfparam name="form.Budget_Dollar"                        default="0">
<cfparam name="form.Notification_Emails"                  default="">

<cfparam name="form.budget_class_id" default="0">
<cfparam name="form.budget_group_id" default="0">
<cfparam name="form.business_segment_id" default="0">
<cfparam name="form.Deleteable_Budget_Ids" default="">
<cfparam name="form.Deactivate_Budget_Ids" default="">
<cfparam name="form.selActions2" default="">

<cfif form.command eq "addbudget"
   or form.command eq "listbudget">
  <cfscript>
    form.budget_id = 0;
  </cfscript>
</cfif>

<cfoutput>
<!---hidden form fields that are passed between CF templates--->
<input type="hidden" name="command"          value="#form.command#">
<input type="hidden" name="budget_id"        value="#form.budget_id#">
<input type="hidden" name="load_fromdb"      value="">
<input type="hidden" name="clicked_save"     value="">
<input type="hidden" name="Deleteable_Budget_Ids" value="">
<input type="hidden" name="Deactivate_Budget_Ids" value="">
<input type="hidden" name="selActions2" value="">



<cfif (form.command contains "group") or (form.command contains "class")>
 <input type="hidden" name="budget_class_id"  value="#form.budget_class_id#">
 <input type="hidden" name="budget_group_id"  value="#form.budget_group_id#">
</cfif>
</cfoutput>

<!---user-defined labels are loaded here--->
<cfscript>
  formlabels = {};

  formlabels.code  = "Code:";
  formlabels.desc  = "Description:";
  formlabels.class = "Class:";
  formlabels.group = "Group:";
  formlabels.segment = "Segment:";
  formlabels.contribution_factor_type = "Budget Type:";
  formlabels.budget_type = "Is Perpetual:";
</cfscript>