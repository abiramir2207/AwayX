<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\ajax\slotting.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Slotting Backend Data
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
        queryData = targets_cfc.getSlotting(url.id);
    </cfscript>
</cfsilent>
<cfoutput>#serializeJSON(queryData, "struct")#</cfoutput>