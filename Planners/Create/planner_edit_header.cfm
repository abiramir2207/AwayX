<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/planner_edit_header.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  5/2/2016
Created By   :  KAL
Description  :  Displays Planner for edit and other tabs
---------------------------------------------------------------------------------->
<cf_layout-bare jQueryUI='1.11.4'>
    <script>
        /* disable appending timestamp url parameter in jQuery ajax */
        $.ajaxSetup( { cache: 1 } );
    </script>
	<cfinclude template="/planners/create/planner_volume_constants.cfm">

	<link rel="stylesheet" href="/script/css/smoothness/jquery-ui-1.11.4.custom.min.css">
	<link rel="stylesheet" type="text/css" href="/common_files/viewmodes.css">

	<style>
		body { margin:0; padding:0; }
		#feedback { font-size: 1.4em; }
		.ui-state-focus { background: #FECA40; }
		.ui-state-hover { background: #F39814; color: white; }
		/*.ui-tabs .ui-tabs-nav { text-align:left; font-weight:bold; font-size:12px; background-color2:#FFE083; border:1px solid #A5A5A5; }*/
		.plannerHeader { text-align:center; font-weight:bold; font-size:11px; padding:1px; margin-top: 1px; height:28px; color:white; }
		.ui-helper-reset { line-height: 0.85; }
		.megamenu_blue {
			background: #014464;
			background-image: -webkit-gradient(linear, left top, left bottom, from(#0272a7), to(#013953));
			background: -webkit-linear-gradient(top, #0272a7, #013953);
			background: -moz-linear-gradient(top, #0272a7, #013953);
			background: -o-linear-gradient(top, #0272a7, #013953);
			background: -ms-linear-gradient(top, #0272a7, #013953);
			background: linear-gradient(top, #0272a7, #013953);
			border: 1px solid #015b86;
			border-top: 1px solid #029feb;
			background-color:#9BC2E6;
		}
		div.plannerHeader div { float: left; /*vertical-align: middle; text-align: center; line-height: 28px; margin: 0; padding: 0;*/ }
	</style>

	<cfoutput>
	<div class="plannerHeader megamenu_blue" width="100%">
		<div style="width:10%;" id="mode">
			<cfif url.mode eq constants.edit>
				<button class="edit" title="click for read only" style="height:24px;margin-top:3px;">Edit #Application.PlannerLabel#</button><br>
			<cfelse>
				<button class="readonly" title="click for read only" style="height:24px;margin-top:3px;">Read Only</button><br>
			</cfif>
		</div>
		<div style="width:15%;letter-spacing:0.5px;">
			#getPlanner.Status_Abbreviation# <br/> [ <span style="color:yellow;">#getPlanner.Planner_Number#</span> ]
		</div>
		<div style="width:20%;letter-spacing:0.5px">
			 #getPlanner.Ship_To# <br/> #getPlanner.Name#
		</div>
		<div style="width:25%;">
			#getPlanner.Planner_Type# <br/> #getPlanner.Planner_Description#
		</div>
		<div style="width:10%;margin-top:7px;">
			#application.util.datetime.DateSpanFormat( getPlanner.Planner_Start_Date, getPlanner.Planner_End_Date )#
		</div>
		<div style="width:20%;margin-top:5px;color:yellow;letter-spacing:0.5px;font-size:13px;">
			Ready for Approval
		</div>
	</div>
	</cfoutput>

	<!--- *************************** tabs *************************** --->
	<div id="tabs" class="tab">
		<cfset variables.query_string = application.util.list.queryString( url )>
		<cfoutput>
		<ul>
			<li><a href="planner_scorecard.cfm?#variables.query_string#">scorecard</a></li>
			<li><a href="planner_calendar.cfm?#variables.query_string#">#Application.PlannerLabel# calendar</a></li>
			<li><a href="planner_volume_plan.cfm?#variables.query_string#">volume plan</a></li>
			<li><a href="planner_profile.cfm?#variables.query_string#">profile</a></li>
			<li><a href="planner_alerts.cfm?#variables.query_string#">alerts</a></li>
		</ul>
		</cfoutput>
	</div>

	<script>
		$(function() {
			// $("#accordion").accordion({ heightStyle: "content" });
			$( "#tabs" ).tabs({
								active: <cfoutput>#url.active_tab#</cfoutput>,
								beforeLoad: function( event, ui ) { ui.panel.html(""); }
			});
			$( "#mode" ).click(function() {
				<cfoutput>
				window.location.href = window.location.pathname
										+ "?" + '#application.util.list.queryString( url, 'mode,active_tab' )#'
										+ "&active_tab=" + $("##tabs").tabs("option", "active")
										+ "&mode=" + "#(url.mode eq constants.edit ? '' : constants.edit)#";
				</cfoutput>
			});
		}); // function
	</script>
  	<cfset request.focusHiLightOff = true>
</cf_layout-bare>
