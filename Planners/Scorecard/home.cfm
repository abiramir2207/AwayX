<cfsetting showDebugOutput="No">
<!---------------------------------------------------------------------------------------------------------------------
	  Template:  \planners\scorecard\home.cfm
		  Date:  2016 November
		Author:  Chris Nguyen
	   Purpose:  Planner scorecard on home page
---------------------------------------------------------------------------------------------------------------------->
<!doctype html>
<html>
<head>
</head>
<body>
<style>
	body {
		margin-top: 2px;
	}
	table.normal-home tr {
		height: 20px;
	}
	table.normal-home td {
		font-size: 13px;
		border-bottom: 1px dotted #7575FF;
		padding: 0 5px;
	}
	table.normal-home td.count {
		font-weight: bold;
		color: red;
	}
	.subtle {
		color:#7c7c7c;
		font-size:11px;
		margin-bottom: 3px;
	}
	.scorecardFooter {
		position: absolute;
		text-align: center;
		left: 0;
		right: 0;
		margin: auto;
		bottom: 6px;
	}
	.highlight {
		background-color: #E5E5E5;
		cursor:pointer;
	}
	table.normal-home td.medium {
		width: 55%;
	}
	table.normal-home td.program {
		color: #6FA0DB;
		font-size: 12px;
		padding-left: 13px;
	}
	table.normal-home thead tr {
		background-color2: #D5DDF7;
	}
	table.normal-home th {
		border-bottom2: 1px dotted #7575FF;
		color: #000;
		font-size: 12px;
		font-weight: 500;
		letter-spacing: 0.25px;
		height: 22px;
		padding2: 2px 1px 0 1px;
		text-decoration: underline;
		text-decoration-color: #7575FF;
	}
	table.normal-home td.count {
		text-align: right;
		font-weight: bold;
		color: red;
	}
</style>
<cfparam name="url.useCache" default="1">
<!---Tim Ford - 3/25/2020: WR D96222 - Incorrect Visibility to Planner Scorecard on Home Page: Request to not display planner scorecard content on home page if user profile Planner - None is on --->
<cfinclude template="/get_access_profile.cfm">
<cfif Get_Profile_Settings.planner_create neq 0>

	<cfset qPlannerScorecardCount = createObject("component", "mvc.Models.Planner.PlannerSearchManager").getPlannerScorecardCount()>
	<table class="normal-home" border="0" cellpadding="0" cellspacing="0" width="100%">
		<thead>
			<tr>
				<th class="medium"></th>
				<th><cfoutput>#Application.PlannerLabel_Plural#</cfoutput></th>
				<th><cfoutput>#Application.PlannerPrgLabel_Plural#</cfoutput></th>
			</tr>
		</thead>
		<tbody>
		<cfoutput query="qPlannerScorecardCount">
			<tr>
				<td class="medium #lcase(qPlannerScorecardCount.record_type)# planner"
					cfm="/planners/search/planner_search.cfm?display_scorecard_result=1&include_indirect=1&planner_status_id=#qPlannerScorecardCount.status_id#-#qPlannerScorecardCount.sub_status_id#">
					#qPlannerScorecardCount.Sub_Status_Desc#
				</td>
				<td class="count">
					<cfif qPlannerScorecardCount.Record_type eq "Program">&nbsp;<cfelse>#qPlannerScorecardCount.Planner_Count#</cfif>
				</td>
				<td class="count">
					<cfif qPlannerScorecardCount.Record_type neq "Program">&nbsp;<cfelse>#numberFormat(qPlannerScorecardCount.Program_Count, ",9")#</cfif>
				</td>
			</tr>
		</cfoutput>
		</tbody>
	</table>

	<cfoutput>
	<div class="scorecardFooter">
		<div class="subtle">
			<cfset scorecardTime = now()>
			Last refreshed #DateFormat(Now(), "d mmm yyyy")# <cfif URL.useCache neq 1>#TimeFormat(scorecardTime, "h:mm tt")#</cfif>
		</div>
		<a href="##" onclick="return refreshView();" style="font-style:normal;">#application.util.string.linkFormat("refresh view")#</a>
	</div>
	</cfoutput>

	<cf_include files="/common_files/jQuery.cfm, /styles/css-loader.css">

	<script>
		$("td.planner").click(function(){
			window.parent.show_loader();
			window.parent.location.href = $(this).attr( "cfm" );
		})

		$("tbody tr").hover(function(){ $(this).toggleClass("highlight"); })

		function refreshView() {
			show_loader();
			window.location = "home.cfm?useCache=0";
		}
	</script>

</cfif>

</body>
</html>