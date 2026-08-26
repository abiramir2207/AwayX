<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\assign_budgets.cfm
      Date:     Nov 29 2012
      Author:   Chris Nguyen
      Purpose:  This is a user-defined function which can be used to assign budgets to a program
      
      Called from:  1. \Common_Files\contracts\contract_approve_broker_action.cfm
                    2. \Scheduled\Auto_Renew_Programs.cfm

			Return values:
					"" (empty string) = found budget, select it and assigned to program
					"stop" = budget is expected but not found
					"prompt" = multiple budgets were found, require users to make selection
----------------------------------------------------------------------------------------------------------------------->

  <!--- contains fn save_budgets_all_versions() --->
  <cfinclude template="budget_save_functions.cfm" />

<cffunction name="Assign_Budgets" output="false" returntype="string">
<cfargument name="Program_Id" required="true">
<cfargument name="Template_First_Parent_ID" required="true">

<cfscript>
   var vars = StructNew();
   vars.next_action = "";
   vars.insert_count = 0;
</cfscript>

<!---gather all available budgets for this program--->
<cfstoredproc procedure="Adv_Budget_Get_Pgm_Budget_List"
    dataSource="#application.datasource#"
    returnCode="Yes"
    debug="Yes">
   <cfprocresult name=vars.qProgram_Budgets>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="#arguments.Program_Id#" dbVarName = @program_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @user_position_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_template_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="0" dbVarName = @new_business_segment_id>
   <cfprocparam type="in" cfsqltype = cf_sql_integer value="#application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetSelectionRequired()#" dbVarName = @budget_required_complete_span>
</cfstoredproc>

<cfif ( vars.qProgram_Budgets.recordCount eq 0 )>

  <cfif appSettings.getBudgetSelectionRequired()>
    <!---no budgets for program, but app setting Budget Selection Required is ON! stop RFA--->
    <cfreturn "stop">
  </cfif>

  <!---gather all available budgets for this program template--->
	<!--- Comment out below section for label D49955 :: Error message despite Budget selection required is Off
	<cfquery name="vars.qTemplate_Budgets" datasource="#application.datasource#">
		SELECT COUNT(1) AS Result
		FROM Budget_Template_Mappings
		WHERE Template_First_Parent_ID = <cfqueryparam value="#arguments.Template_First_Parent_ID#" cfsqltype="cf_sql_integer">
	</cfquery>
	
	<cfif ( vars.qTemplate_Budgets.Result gt 0 )>
		<!---no budgets for program, but there is budgets for template! stop RFA--->
		<cfreturn "stop">
	</cfif>
	--->

  <!---delete selected budgets that are no longer qualified for program--->
  <cfquery name="vars.qRemovals" datasource="#application.datasource#">
	DELETE Budget_Program_Selection
	WHERE Program_ID = <cfqueryparam value="#arguments.Program_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfreturn "">
</cfif>

<cfquery name="vars.qYearType" datasource="#application.datasource#">
  SELECT DISTINCT Is_Fiscal, Partial_Year
    FROM BUDGET_CLASS
   WHERE Budget_Class_Id IN ( <cfqueryparam value="#valueList(vars.qProgram_Budgets.Budget_Class_Id)#" cfsqltype="cf_sql_integer" list="true"> )
</cfquery>

<!--- 34049 - found both fiscal budget type & calendar budget type, return & ask user to select  --->
<cfif ( vars.qYearType.recordCount gt 1 )>
  <cfreturn "prompt">
</cfif>

<cfset vars.arBudgetList = ArrayNew(1) />
<!--- Loop over each class and see if there is a single budget per class that can be defaulted to --->
<cfoutput query="vars.qProgram_Budgets" group="Budget_Class_Desc">
  <!---collect all budgets for this class--->
  <cfset vars.class_budgets = []>
  <cfset vars.budget_id = "" />
  <cfoutput><!--- loop over each budget --->
    <cfset ArrayAppend(vars.class_budgets, vars.qProgram_Budgets.Budget_ID)>
	<cfset vars.budget_id = vars.qProgram_Budgets.Budget_ID />
  </cfoutput>

  <cfif ArrayLen(vars.class_budgets) eq 1 and vars.qProgram_Budgets.Budget_ID eq ""><!--- Budget is NULL --->
      <cfreturn "prompt">
  </cfif>

  <cfif ArrayLen(vars.class_budgets) gt 1>
    <!---are budgets assigned already?--->
    <cfquery name="vars.qExists" datasource="#application.datasource#">
      SELECT Budget_ID
        FROM Budget_Program_Selection
       WHERE Program_ID = <cfqueryparam value="#arguments.Program_Id#" cfsqltype="cf_sql_integer">
             AND Budget_Id IN ( <cfqueryparam value="#ArrayToList(vars.class_budgets)#" cfsqltype="cf_sql_integer" list=yes> )
    </cfquery>
    <!---found one class with budget not selected, bail out--->
    <cfif vars.qExists.recordCount eq 0>
      <cfreturn "prompt">
    </cfif>
	<cfset vars.budget_id = vars.qExists.Budget_ID />
  </cfif>  <!---ArrayLen(vars.class_budgets) gt 1--->

  <cfset vars.stBudgetSelection = StructNew() />
  <cfset vars.stBudgetSelection.BudgetClassID = Budget_Class_ID />
  <cfset vars.stBudgetSelection.BudgetID = vars.budget_id />
  <cfset ArrayAppend(vars.arBudgetList, vars.stBudgetSelection) />

</cfoutput>  <!---query="vars.qProgram_Budgets" group=--->

<!--- If code reached here that means there was a single budget per budget class and can be saved without asking user --->
<cfset save_budgets_all_versions(arguments.Program_Id, vars.arBudgetList)>

<cfreturn "">
</cffunction>
