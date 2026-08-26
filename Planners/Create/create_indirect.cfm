<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :  \planners\create\create_indirect.cfm
Created Date :  2017 October
Created By   :  Chris Nguyen
Description  :  Control steps in create indirect planner

Remarks      :  Required parameters:
					- form.parent_planner_id
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
</head>
<body>
	<style>
		#hdr {
			font-size: 14px;
			width: 100%;
			margin: 8px 15px 15px 8px;
			display: flex;
		}
		span.h22 {
			font-weight: bold;
			letter-spacing: 0.5px;
		}
		fieldset {
			border: 2px solid #ddd;
			border-radius: 8px;
			box-sizing: border-box;
			margin: 0;
			height: 430px;
			height: 72vh;
			width: 100%;
		}
		fieldset.fs1 {
			height: 70px;
			width: 100%;
		}
		h3 {
			border:1px dotted #CCC;
			color: #333;
			line-height: 26px;
			margin: 4px 0;
			padding: 0 15px;
		}
		h3.active {
			background-color: #9BC2E6;
		}
		h3.inactive {
			background-color: #DCEAF6;
			opacity: 0.75;
		}
		h3 > i {
			background-color: #202893;
			color: white;
			font-style: normal;
			margin-right: 5px;
			padding: 6px;
		}
		.filler {
			flex-grow: 10;
		}
		#cancel_return {
			font-size: 11px;
			margin-right: 10px;
		}
	</style>

	<cfscript>
		appSettings             = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		labels_obj             = createObject( "component", "components.settings.Labels.Labels" ).init();
		request.planner_labels = labels_obj.plannerLabels();
	</cfscript>

	<cfset steps = [	{ title="<i>1</i> Select a Responsible Sales Person", content="/planners/include/select_rsp.cfm" },
						{ title="<i>2</i> Select " & request.planner_labels.operator_plural, content="/planners/include/select_operators.cfm" }
					]>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/jQuery.cfm, /common_files/jQueryUI.cfm, /common_files/dhx_message.cfm, /styles/css-loader.css">

	<cfparam name="form.current_step" default=1>
	<cfparam name="form.creator_user_id" default=#request.AccessStructure.User_ID#>

	<script>
		if (window.innerHeight <= 768) {
			$("fieldset").css("height", "60vh");
		}
	</script>

	<cfquery name="qParent" datasource="#application.datasource#">
		SELECT Planner_Number, Planner_Title
		  FROM Planners
		 WHERE Planner_ID = <cfqueryparam value="#form.parent_planner_id#">
	</cfquery>

	<cfoutput>
	<div id="hdr">
		<span class="h22">For #request.planner_labels.wholesaler_singular# #Application.PlannerLabel#</span> &nbsp; #qParent.planner_number# #qParent.planner_title#
		<div class="filler"></div>
		<a id="cancel_return" class="secondary">#application.util.string.linkFormat("cancel & return to wholesale #Application.PlannerLabel#")#</a>
	</div>

	<cfset step_counter = 0>
	<cfloop array="#steps#" index="step">
		<cfset step_counter = step_counter + 1>

		<!--- additional info in heading  --->
		<cfset more_info = "">
		<cfif step_counter eq 1 and form.current_step gte 2>
			<cfset more_info = "( " & form.chosen_rsp & " )">
		</cfif>

		<!---  step heading  --->
		<h3 class=#(form.current_step eq step_counter ? "active" : "inactive")#>#step.title# #more_info#</h3>

		<!---  display content of the current step  --->
		<cfif form.current_step eq step_counter>
			<fieldset class="fs#step_counter#">
				<cfinclude template="#step.content#">
			</fieldset>
		</cfif>
	</cfloop>
	</cfoutput>

	<cfinclude template="/common_files/focus.cfm">

	<form name="load_planner" method="post" action="planner_indirect.cfm">
		<cfoutput>
		<input type="hidden" name="plannerID" value="#form.parent_planner_id#">
		<input type="hidden" name="mode" value="#form.mode#">
		</cfoutput>
		<input type="hidden" name="page_creating" value="1">
	</form>

	<script>
		$("#cancel_return").click(function(){
			$("form[name=load_planner]").submit();
		});
	</script>
</body>
</html>


<cffunction name="saveHiddenValues" output="true" hint="Save input elements needed on all pages">
	<!---  store persisted + hidden elements in all pages in this array --->
	<cfset local.hidden_inputs = [	"current_step",
									"parent_planner_id",
									"planner_template_id",
									"rsp_user_id",
									"rsp_position_id",
									"creator_user_id",
									"chosen_rsp",
									"operator_ids",
									"mode"
								]>
	<cfloop array="#local.hidden_inputs#" index="local.hidden_entry">
		<cfif local.hidden_entry eq "current_step">
			<!---  increment next step by one  --->
			<input type="hidden" name="#local.hidden_entry#" value="#min(2, form[ local.hidden_entry ] + 1)#">
		<cfelse>
			<cfparam name="form.#local.hidden_entry#" default="">
			<input type="hidden" name="#local.hidden_entry#" value="#form[ local.hidden_entry ]#">
		</cfif>
	</cfloop>
</cffunction>
