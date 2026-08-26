<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Date:     June, 2011
      Author:   Chris Nguyen
      Purpose:  Activate / deactivate budget
----------------------------------------------------------------------------------------------------------------------->
<cfset vars = {}>
<cfset vars.error_cnt = 0>

<cfif form.command eq "deactivatebudget">
  <cfquery name="vars.deactivate" datasource="#application.datasource#">
    UPDATE Budget
       SET Active = 0
	   	   , Budget_DeActivated_By = '#request.AccessStructure.user_id#'
		   , Budget_DeActivated_Date = getdate()
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
<cfelseif form.command eq "activatebudget">
  <cfquery name="vars.activate" datasource="#application.datasource#">
    UPDATE Budget
       SET Active = 1
   	   	   , Budget_Activated_By = '#request.AccessStructure.user_id#'
		   , Budget_Activated_Date = getdate()
     WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
</cfif>

<cfoutput>
  <cflocation url="index.cfm?byClassIDs=#trim(url.byClassIDs)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&bySearch=#trim(url.bySearch)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#
" addtoken="no">
</cfoutput>

