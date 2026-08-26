<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\budget_save_functions.cfm
      Date:     6/19/2014
      Author:   Deepa Kunnath
      Purpose:  Assign budgets for a program

      Notes:    Code in this page was moved from \Common_Files\contracts\budget_display.cfm to avoid duplication of code
	
				This page is called from 2 places:
                A. Left hand side budget link
                    \Common_Files\contracts\budget_display.cfm

                B. RFA process:
                    \Common_Files\contracts\assign_budgets.cfm
----------------------------------------------------------------------------------------------------------------------->


<cffunction name="save_budgets_all_versions" output="true">
  <cfargument name="program_id" type="numeric" required="true" />
  <cfargument name="arBudgetList" type="array" required="true" />
  <cfargument name="UpdateCommittedToActual" type="numeric" required="false" default="0" /><!---  D50326 --->
  <cfargument name="CommittedToActualChangeFromNoToYes" type="numeric" required="false" default="0" /><!---  D50326 --->
  <cfset var vars = {}>
  <!--- Get list of all versions --->
  <cfquery name="vars.GetProgramList" datasource="#application.datasource#">
	SELECT 	CM.Contract_Main_ID, CM.Contract_Status_Type_IDX
	FROM 	Contract_Main
	INNER JOIN Contract_Main CM
	ON		CM.Contract_Number = Contract_Main.Contract_Number
	AND		(CM.Approved = 1 OR CM.Deleted = 0) 
	WHERE 	Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
	UNION
	SELECT 	Contract_Main_ID, Contract_Status_Type_IDX
	FROM 	Contract_Main
	WHERE 	Contract_Main.Contract_Main_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <!--- 30902 gather old budget selection --->
  <cfquery name="vars.original" datasource="#application.datasource#">
    SELECT Budget_ID
      FROM Budget_Program_Selection
     WHERE Program_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfset vars.originalBudgets = valueList(vars.original.budget_id)>

  <cfset vars.bProgramApproved = 0 />
  <cfset vars.programIDForBudgetRefresh = 0 />

<!--- Loop over each program version and update budget --->
  <cfloop query="vars.GetProgramList">
	<cfif Contract_Status_Type_IDX GT 2>
		<cfset vars.bProgramApproved = 1 />
		<cfset vars.programIDForBudgetRefresh = Contract_Main_ID /> <!--- We will use contract_main_id of an approved progrm --->
	</cfif>
	<cfset save_budgets(Contract_Main_ID, arguments.arBudgetList) />
  </cfloop>

  <!--- 30902 perform additional processing when this is called from reassign option --->
  <cfif vars.bProgramApproved eq 1>
      <!--- count number of newly selected budgets --->
      <cfquery name="vars.isBudgetChanged" datasource="#application.datasource#">
        SELECT COUNT(1) AS rCount
          FROM Budget_Program_Selection
         WHERE Program_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
                <cfif len(trim(vars.originalBudgets))>
                  AND NOT Budget_ID IN (<cfqueryparam value="#vars.originalBudgets#" list="true"/>)
                </cfif>
      </cfquery>

      <!--- refresh dollar amounts when there is newly selected budget --->
      <cfif vars.isBudgetChanged.rCount gt 0 OR arguments.UpdateCommittedToActual><!---  D50326 --->
        <cfset vars.oBudgetManager = createObject('component','mvc.Models.AdvancedBudget.BudgetManager') />
        <cfset vars.oBudgetManager.refreshCommittedForProgram(programId = vars.programIDForBudgetRefresh) />
        <cfset vars.oBudgetManager.updateProgramBillbackBudget(programId = vars.programIDForBudgetRefresh) />
      </cfif>
      <!---  D50326 :: Tru-up to Actuals Button in Program START--->
      <cfif arguments.UpdateCommittedToActual AND arguments.CommittedToActualChangeFromNoToYes>
        <cfquery name="OffInvoiceActualDetail" datasource="#application.datasource#">
          SELECT TOP 1 1 FROM  Off_Invoice_Actual_Detail
        </cfquery>

        <cfset User_OI_Table =  OffInvoiceActualDetail.RecordCount>

        <cfloop query ="vars.GetProgramList">
          <cfstoredproc procedure="PROGRAM_AUTO_VOLUME_UPDATE"
              dataSource="#application.datasource#"
              returnCode="Yes"
              debug="Yes">
             <cfprocresult name=vars.AutoVolumeUpdate>
             <cfprocparam type="in" cfsqltype = cf_sql_integer value="#vars.GetProgramList.Contract_Main_ID#" dbVarName = @Contract_Main_ID>
             <cfprocparam type="in" cfsqltype = cf_sql_integer value="#User_OI_Table#" dbVarName = @User_OI_Table>
          </cfstoredproc>
        </cfloop>
      </cfif>
      <!---  D50326 :: Tru-up to Actuals Button in Program END--->
  </cfif>
</cffunction>

<cffunction name="save_budgets" output="false">
  <cfargument name="program_id" type="numeric" required="true" />
  <cfargument name="arBudgetList" type="array" required="true" />
  <cfset var vars = {}>

  <cfset vars.arLen = ArrayLen(arguments.arBudgetList) />
  <cftransaction>

  <cfquery name="vars.removal" datasource="#application.datasource#">
    DELETE Budget_Program_Selection
     WHERE Program_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <!---scan thru all selected budgets--->
  <cfloop from="1" to="#vars.arLen#" index="vars.index">
      <cfset vars.item = arguments.arBudgetList[vars.index] />
      <cfquery name="vars.saveBudget" datasource="#application.datasource#">
        INSERT INTO Budget_Program_Selection
          (   Program_ID
            , Budget_Class_ID
            , Budget_ID
          )
          VALUES (   <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
                   , <cfqueryparam value="#vars.item.BudgetClassID#" cfsqltype="cf_sql_integer">
                   , <cfqueryparam value="#vars.item.BudgetID#" cfsqltype="cf_sql_integer">
                 )
      </cfquery>
  </cfloop>

  <cfquery name="vars.saveBudget" datasource="#application.datasource#">
    INSERT INTO Budget_Program_Selection_History
          (   Budget_Program_Selection_ID
            , Program_ID
            , Budget_Class_ID
            , Budget_ID
            , Created_Date
          )
    SELECT    Budget_Program_Selection_ID
            , Program_ID
            , Budget_Class_ID
            , Budget_ID
            , Created_Date
      FROM  Budget_Program_Selection
     WHERE  Program_ID = <cfqueryparam value="#arguments.program_id#" cfsqltype="cf_sql_integer">
  </cfquery>
  </cftransaction>

</cffunction>
