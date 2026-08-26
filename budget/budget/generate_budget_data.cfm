<!---  
       Name:          generate_budget_data.cfm
       Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
       Created Date:  <date>
       Created By:    Deepa Kunnath
       Description:   
--->

<!------ insert into the queue ----->
<cfquery name="qInsertIntoQueue" datasource="#application.datasource#">
	if not exists
	(
		SELECT	*
		FROM	Budget_Populate_Queue
		WHERE	Deleted = 0
		AND		Budget_ID = <cfqueryparam value="#form.id#" cfsqltype="CF_SQL_INTEGER">
		AND		Budget_Populate_Status_ID = 0
	)
	INSERT INTO Budget_Populate_Queue (Budget_ID) VALUES (<cfqueryparam value="#form.id#" cfsqltype="CF_SQL_INTEGER">)
</cfquery>

<!------ 
Call the stored proc which will check if the job is not already running and then start it
----->
<cfstoredproc procedure="CALL_BUDGET_RUN_POPULATE_JOB" datasource="#application.datasource#" />

<!------ if we want to call the populate stored proc directly, call the sp below ----->
<!--- 
<cfstoredproc procedure="POPULATE_BUDGET_VALUES" datasource="#application.datasource#">
	<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" variable="Budget_ID" dbvarname="@@Budget_ID" value="#form.id#" null="No">
</cfstoredproc>
--->

<!------ <cflocation addtoken="no" url="index.cfm?command=editBudgetAllocation&id=#form.id#" /> ----->
<cflocation addtoken="no" url="index.cfm?command=listActiveBudgetGroup" /><!------ for now go back to budget list page after generate, as the generate might take some time ----->

