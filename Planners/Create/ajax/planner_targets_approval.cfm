<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: planner_targets_approval.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Planner Targets Approval Backend Data
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
        queryData = targets_cfc.getApprovalDetails(url.id);
    </cfscript>
</cfsilent>
<cfoutput>#serializeJSON(queryData, "struct")#</cfoutput>