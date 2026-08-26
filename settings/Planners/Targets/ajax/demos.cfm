<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\ajax\demos.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Demos Backend Data
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
        queryData = targets_cfc.getDemos(url.id);
    </cfscript>
</cfsilent>
<cfoutput>#serializeJSON(queryData, "struct")#</cfoutput>