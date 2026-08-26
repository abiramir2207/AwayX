<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Include/process_planner_import.cfm
	Created Date:  2017 July
	  Created By:  kal
	 Description:  copy programs from another planner
--------------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfscript>
	param name="form.user_id" default="";
	oPlanner                       = createObject("component", "mvc.Models.Planner.PlannerManager");
	oPlannerImport                 = createObject("component", "mvc.Models.Planner.PlannerImportManager");
	form.user_id			       = request.AccessStructure.User_ID;
	local.executePlannerPrograms   = oPlannerImport.executePlannerProgramImport(form);
</cfscript>
