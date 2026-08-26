<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\ajax\target_adjustments.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Target Adjustments Backend Data
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
        queryData = targets_cfc.getTradeTargets(url.id);
    </cfscript>
</cfsilent>
<cfoutput>#serializeJSON(queryData, "struct")#</cfoutput>