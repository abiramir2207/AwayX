<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\ajax\sales_target.cfm
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Sales Targets Backend Data
  *
  * ==================================================================================================== 
--->
<cfsilent>
    <cfscript>
        targets_cfc = createObject("component", "mvc.models.planner.plannerTargets");
        queryData = targets_cfc.getSalesTargets(url.id);
    </cfscript>
</cfsilent>
<cfoutput>#serializeJSON(queryData, "struct")#</cfoutput>
