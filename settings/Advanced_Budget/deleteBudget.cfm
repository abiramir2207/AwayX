<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:
----------------------------------------------------------------------------------------------------------------------->
<cfset vars = {}>

<cfquery name="vars.delete" datasource="#application.datasource#">
  UPDATE Budget
     SET Deleted = 1
   WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfoutput>
  <cflocation url="index.cfm?byClassIDs=#trim(url.byClassIDs)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&bySearch=#trim(url.bySearch)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#
" addtoken="no">
</cfoutput>

