<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\Planners\Planner_Output\delete.cfm
			Date:     2017 September
			Author:   Deepa Kunnath (Copied from Settings/Programs/Claim Rates)
			Purpose:  Delete planner output settings
			
			Parameter: 
					URL.Config_ID - required, numeric.
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
		vars = {};
		vars.plannerSettingCFC = createObject("component", "mvc.models.planner.PlannerSettingsManager");
		vars.plannerSettingCFC.deletePlannerOutputConfig( url.config_id );
</cfscript>

<cflocation url="list.cfm" addtoken="false">
