<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\budgetgeneral.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Common form elements at the top general section
----------------------------------------------------------------------------------------------------------------------->

<style>
td.label { text-align:right; padding-right:10px; font-weight:bold; }
#factor { margin:10 0 0 20; }
#factor span { margin:0 0 0 10; }
.labelg { text-align:left; width:72px; font-weight:bold; margin-right:10px; display:inline-block;}
.general { margin:7px; }
.input129 { width:270px; }
.input131 { width:275px; }
</style>

<!--- retrieve lookup data --->
<cfinvoke component="mvc.Models.AdvancedBudget.BudgetClassManager"
    		     method="getBudgetClass"
     returnVariable="qClass">
</cfinvoke>

<cfinvoke component="mvc.Models.AdvancedBudget.BudgetGroupManager"
    		     method="getBudgetGroup"
     returnVariable="qGroup">
</cfinvoke>

<cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabledForBudget()/>

<cfquery name="qFactor" datasource="#application.datasource#">
  SELECT Budget_Contribution_Factor_Type_Id
         , Contribution_Factor_Type
    FROM dbo.Budget_Contribution_Factor_Type
   WHERE Deleted = 0
         ORDER BY List_Order
</cfquery>

<cfoutput>
<div id="general" style="float:left">
<div class="general"><label class="labelg">#formlabels.code#<span id="error_budget_code"></span></label><input name="budget_code" value="#form.budget_code#" type="text" size=10 maxlength=10 <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/></div>
<div class="general"><label class="labelg">#formlabels.desc#<span id="error_budget_desc"></span></label><input name="budget_desc" value="#form.budget_desc#" type="text" class="input129" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/></div>
<div class="general"><label class="labelg">#formlabels.class#<span id="error_budget_class_id"></span></label><select name="budget_class_id" #form.read_only# class="input131" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>><option value="0">select</option>
            <cfloop query="qClass">
              <option <cfif form.budget_class_id eq qClass.Budget_Class_ID>selected</cfif> value="#qClass.Budget_Class_ID#">#qClass.Budget_Class_Number# #qClass.Budget_Class_Desc#</option>
            </cfloop>
          </select></div>
<div class="general"><label class="labelg">#formlabels.group#<span id="error_budget_group_id"></span></label><select name="budget_group_id" #form.read_only# class="input131" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>><option value="0">select</option>
            <cfloop query="qGroup"><option <cfif form.budget_group_id eq qGroup.Budget_Group_ID>selected</cfif> value="#qGroup.Budget_Group_ID#">#qGroup.Budget_Group_Number# #qGroup.Budget_Group_Desc#</option>
            </cfloop>
          </select></div>
<cfif busSegMgr.isEnabled>
  <cfset qSegments = busSegMgr.obj.getActive( userId = request.AccessStructure.User_ID )>
  <div class="general"><label class="labelg">#formlabels.segment#<span id="error_business_segment_id"></span></label><select name="business_segment_id" #form.read_only# class="input131" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>><option value="0">select</option>
  <cfset useLakebaseForqSortedSegments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qsegments")>
<cfif useLakebaseForqSortedSegments>
	<cftry>
		<cfset qSortedSegments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qsegments", {
				"order" = "business_unit_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSortedSegments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSortedSegments>
<cfquery name="qSortedSegments" dbtype="query">
    SELECT  *
    FROM  qSegments
    ORDER BY BUSINESS_UNIT_DESC
  </cfquery>
</cfif>
              <cfloop query="qSortedSegments"><option <cfif form.business_segment_id eq qSortedSegments.business_segment_id>selected</cfif> value="#qSortedSegments.business_segment_id#">#qSortedSegments.Business_Unit_Desc#<!--- #qSegments.Business_Unit_Id#---></option>
              </cfloop>
            </select></div>
</cfif>
<cfif appSettings.get_Setting('Accrual_Budgets_Calculation_By_Client') eq '1'>
<div class="general"><label class="labelg">#formlabels.budget_type#<span id="error_budget_budget_type"></span></label>&nbsp;<input name="Is_Perpetual" type="radio" value="1" <cfif form.Is_Perpetual>checked</cfif>/>Yes<input name="Is_Perpetual" type="radio" value="0" <cfif ! form.Is_Perpetual>checked</cfif>/>No</div>
</cfif>
<div class="general"><label class="labelg">#formlabels.Contribution_Factor_Type#<span id="error_budget_contribution_factor_type_id"></span></label>
      <cfloop query="qFactor">
        <input name="budget_contribution_factor_type_id" value="#qFactor.Budget_Contribution_Factor_Type_Id#" type="radio"
          <!---June 24 2011 - Paul decided to disable the budget type after it is created otherwise we would need
               remove the associated budget data for the old budget type (e.g. switching from fixed to variable would require
               removing all the assigned positions)--->
          <cfif form.budget_id neq "0" or qGetCreateBudget.Create_Budget EQ 0>disabled</cfif>
          <cfif form.Budget_Contribution_Factor_Type_ID eq qFactor.Budget_Contribution_Factor_Type_Id>checked</cfif>
          onclick="javascript:switchfactor(this)">#qFactor.Contribution_Factor_Type#
      </cfloop>
</div>
</div>
</cfoutput>
