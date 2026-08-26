<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: planner_targets.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Planner Targets Backend Data
  *
  * ==================================================================================================== 
--->
<cfscript>
    targets_cfc = createObject("component", "mvc.models.planner.plannerManager");
    queryData   = targets_cfc.getTargets(url.id);
</cfscript>
<cfoutput>#serializeJSON(queryData, "struct")#</cfoutput>