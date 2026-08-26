<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_cra.cfm
	Created Date:  2017 June
	  Created By:  Chris Nguyen
	 Description:  Displays planner CRA/NRA information
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout-bare>
	<style>
		html,body {
		  height: 100%;
		  overflow: hidden;
		}
		div#hdr409 {
		  background-color: #c6e79c;
		  background-image: linear-gradient(#e9f6da,#c6e79c);
		  color: #333;
		  font-size: 11px;
		  font-weight: 700;
		  height: 28px;
		  margin: 0;
		  padding: 6px;
		  text-align: center;
		}
		div#hdr409 div {
		  float: left;
		}
		#hdr409 {
		  font-size: 11px;
		  margin: 0;
		}
		i.dim {
		  font-style: normal;
		  opacity: 0.5;
		}
		.panel {
		  width: 100%;
		}
		table#cra,table#nra {
		  overflow-x: hidden;
		  overflow-y: scroll;
		  table-layout: fixed;
		  width: 100%;
		}
		p {
		  font-size: 1.15em;
		  padding: 0;
		  margin: 5px;
		}
	</style>    

	<cf_include files="/common_files/datatable2.css, /common_files/jQuery.cfm, /common_files/dataTables2.cfm">

	<cfscript>
		plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" );
		getPlanner     = plannerManager.getPlanner( url.plannerID );
		qCRA           = plannerManager.getApprovableUsers( url.plannerID );
		qNRA           = plannerManager.getPlannerNextApprovableUsers( url.plannerId );
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfoutput>

	<div id="hdr409" class="clearfix">
		<div style="width:20%;letter-spacing:0.65px;font-size:13px;" class="shadow">
			<i class="dim">#getPlanner.Status_Description#</i> <br/> #getPlanner.Planner_Number#
		</div>
		<div style="width:23%;letter-spacing:0.5px;margin-top:1px;">
			<i class="dim">#getPlanner.Ship_To#</i> <br/> #getPlanner.Name#
		</div>
		<div style="width:23%;">
			<i class="dim">#getPlanner.Planner_Type#</i> <br/> #getPlanner.Planner_Description#
		</div>
		<div style="width:14%;margin-top:7px;">
			#application.util.datetime.DateSpanFormat( getPlanner.Planner_Start_Date, getPlanner.Planner_End_Date )#
		</div>
		<div style="width:20%;margin:7px 0 0 0;">
		</div>
	</div>

	<!--------------------->
	<!---  display CRA  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<div class="panel">
		<p><b>CRA</b> - currently responsible for approval</p>
		<table id="cra" class="datagrid dataTable row-border order-column hover material">
			<thead>
				<tr>
					<th>Name</th>
					<th>Position</th>
					<th>Authority Sequence</th>
					<th>Profile</th>
					<th>Program ##</th>
					<th>Title</th>
					<th>Template</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qCRA">
					<tr>
						<td>#qCRA.User_full_name#</td>				
						<td>#qCRA.Position_label#</td>				
						<td>#qCRA.Authority_sequence_name#</td>				
						<td>#qCRA.Profiles_desc#</td>				
						<td>#qCRA.Contract_number#</td>				
						<td>#qCRA.Contract_title#</td>				
						<td>#qCRA.Created_type#</td>				
					</tr>
				</cfloop>
			</tbody>
		</table>
	</div>

	<!--------------------->
	<!---  display NRA  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<div class="panel">
		<p><b>NRA</b> - after the above person(s) take action, below is a list of person(s) that may need to take approval action</p>
		<table id="nra" class="datagrid dataTable row-border order-column hover material">
			<thead>
				<tr>
					<th>Name</th>
					<th>Position</th>
					<th>Authority Sequence</th>
					<th>Profile</th>
					<th>Program ##</th>
					<th>Title</th>
					<th>Template</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qNRA">
					<tr>
						<td>#qNRA.User_full_name#</td>				
						<td>#qNRA.Position_label#</td>				
						<td>#qNRA.Authority_sequence_name#</td>				
						<td>#qNRA.Profiles_desc#</td>				
						<td>#qNRA.Contract_number#</td>				
						<td>#qNRA.Contract_title#</td>				
						<td>#qNRA.Created_type#</td>				
					</tr>
				</cfloop>
			</tbody>
		</table>
	</div>
	</cfoutput>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<script>
		/* adjust panel height based on actual browser height */
		// var panel_height = Math.floor( ($(window).height() - 150) / 2) + "px";
		// $(".panel").css("max-height", panel_height).css("height", panel_height);
		$("table.datagrid").DataTable({
			                               "aaSorting": [ [0, "asc"]]
			                              ,"bAutoWidth": false
			                              ,"bPaginate": false
			                              ,"bScrollCollapse": true
			                              ,"bSortClasses": false
			                              ,"oLanguage": { "sEmptyTable": "No data available" }
			                              ,"sDom": "t"
			                              ,"sScrollY": "26vh"
										});
	</script>
</cf_layout-bare>