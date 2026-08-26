<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/planner_program_delete.cfm
Date:  		11/17/2016
Author:		Tim Ford
Purpose:  	Single Page Planner Program Delete
----------------------------------------------------------------------------------------------------------------------->

<cfset deleteProgramId = url.Program_ID>
<cfset plannerProgram = 1 />
<cfinclude template="/scorecard/delete_program_common.cfm">
<script>
	window.close();
</script>