<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Templates/planner_template_details.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	KAL
Description  : 	Planner Templates
---------------------------------------------------------------------------------->
<!--- TODO: LIST -------------------------
	- Validation
	- UI Cleanup
	- Add Select all
----------------------------------------->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#dataTable th, #segmentTable th  {font:bold 14px; text-align: left; color:3300cc; padding:7px 0 15px 0;}
	#dataTable tr { padding-bottom: 6px; height: 25px; }
</style>

<cfoutput>

<cfset qGetPlannerCalendarData = objPlannerTemplateManager.getPlannerCalendarConfig(form.id) />
<cfset qGetPlannerPerfTypes = objPlannerTemplateManager.getPlannerPerfTypes(form.id) />

<table border="0" cellpadding="0" cellspacing="0" id="dataTable" width="20%">
	<tr>
		<th class="h2">
			Calendar Info
		</th>
	</tr>
	<cfloop query="qGetPlannerCalendarData">
	<tr>
		<td>
			#ReplaceNoCase(Description, 'program', '#Application.PlannerPrgLabel#')#
		</td>
		<td>
			<INPUT NAME="Planner_Calendar_Config_ID" TYPE="checkbox" value="#Planner_Calendar_Config_ID#" <cfif Selected>checked</cfif>>
		</td>
	</tr>
	</cfloop>

	<tr>
		<th class="h2">Performance Types</th>
	</tr>
	<tr>
		<td>&nbsp;

		</td>
		<td>
			<b>Direct</b>
		</td>
        <cfif form.Wholesaler_Planner>
		<td>
			<b>#sIndirectLabel#</b>
		</td>
        </cfif>
	</tr>
	<cfloop query="qGetPlannerPerfTypes">
	<tr>
		<td>
			#Description#
		</td>
		<td>
			<INPUT NAME="Planner_Perf_Types_ID" TYPE="checkbox" value="#Planner_Perf_Types_ID#" <cfif Selected>checked</cfif>>
		</td>
        <cfif form.Wholesaler_Planner>
		<td>
			<INPUT NAME="Indirect_Planner_Perf_Types_ID" TYPE="checkbox" value="#Planner_Perf_Types_ID#" class="whlsPlannerSwith" <cfif Indirect_Selected>checked</cfif>>
		</td>
        </cfif>
	</tr>
	</cfloop>
	<!---
	<tr>
		<td colspan="100%">
			<BR>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"DataForm.submit();"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
	--->
</table>
<!---
<input name="command" type="hidden" value="svDetail" />
--->

</cfoutput>
