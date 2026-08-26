<!------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_copy_programs.cfm
	Created Date:  2017 July
	  Created By:  kal
	 Description:  copy programs from another planner
------------------------------------------------------------------------------------------------------------------------------------------->
<!doctype html>
<html>
<head></head>
<body>
	<style>
		fieldset {
			border: 2px solid #ddd;
			border-radius: 8px;
			box-sizing: border-box;
			margin: 0;
			height: 400px;
			height: 70vh;
			width: 100%;
		}
		.msg {
			border:1px dotted #CCC;
			color: #333;
			line-height: 26px;
			text-align: center;
			font-style: bold;
			font-size: 16px;
			margin: 10px;
			padding: 15px;
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
			background-color: #82A9CD;
			color: white;
			font-style: normal;
			margin-right: 5px;
			padding: 6px;
		}
	</style>

	<cfparam name="form.current_step" default=0>
	<cfparam name="form.parent_action" default="import">
	<cfparam name="form.planner_import_type" default=0>

	<cfset steps = [	{ title="<i>1</i> Search Target <cfoutput>#Application.PlannerLabel#</cfoutput>", content="/planners/include/search_planners.cfm" },
						{ title="<i>2</i> Select Target <cfoutput>#Application.PlannerLabel#</cfoutput>", content="/planners/include/select_planners.cfm" },
						{ title="<i>3</i> Search Source <cfoutput>#Application.PlannerLabel#</cfoutput>", content="/planners/include/search_planners.cfm" },
						{ title="<i>4</i> Select Source <cfoutput>#Application.PlannerLabel#</cfoutput>", content="/planners/include/select_planners.cfm" },
						{ title="<i>5</i> Choose Missing Products", content="/planners/include/select_products.cfm" },
						{ title="<i>6</i> Choose <cfoutput>#Application.PlannerPrgLabel_Plural#</cfoutput>", content="/planners/include/select_programs.cfm" }
					]>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/jQuery.cfm, /common_files/jQueryUI.cfm, /styles/css-loader.css">

	<script>
		if (window.innerHeight <= 768) {
			$("fieldset").css("height", "60vh");
		}
	</script>

	<cfoutput>

	<!--- 88795 - copy planner to new year --->
	<cfif form.current_step eq 0>
		<cfinclude template="/planners/import/select_planner_import_type.cfm" >
	</cfif>

	<cfset step_counter = 0>
	<cfloop array="#steps#" index="step">
		<cfset step_counter = step_counter + 1>

		<!--- set target planner_ID --->
		<cfif form.current_step eq 3>
			<cfset form.target_planner_Id = form.chosen_planners >
			<cfset form.target_planner_info = form.chosen_planner_info >
		</cfif>
		<!--- set source planner_ID --->
		<cfif form.current_step eq 5>
			<cfset form.source_planner_Id = form.chosen_planners >
			<cfset form.source_planner_info = form.chosen_planner_info >
		</cfif>

		<!--- additional info in heading  --->
		<cfset more_info = "">
		<cfif step_counter eq 2 and form.current_step gte 3>
			<cfset planners_count = listLen( form.target_planner_Id )>
			<cfset more_info = "( " & form.target_planner_info & " )">
		</cfif>

		<cfif step_counter eq 4 and form.current_step gte 5>
			<cfset planners_count = listLen( form.source_planner_Id )>
			<cfset more_info = "( " & form.source_planner_info & " )">
		</cfif>

		<cfif step_counter eq 5 and form.current_step gte 6>
			<cfset product_count = listLen( form.chosen_products )>
			<cfset more_info = "( " & product_count & " selected )">
		</cfif>

		<cfif step_counter eq 6 and form.current_step gte 7>
			<cfset program_count = listLen( form.chosen_programs )>
			<cfset more_info = "( " & program_count & " selected )">
		</cfif>

		<!---  step heading  --->
		<h3 class=#(form.current_step eq step_counter ? "active" : "inactive")#>#step.title# #more_info#</h3>

		<!--- 88795 - copy planner to new year; skip step 3 and go to step 4. populate customer for step 4 --->
		<cfif (form.current_step eq 3) AND (form.planner_import_type eq 2) >
            <cfset form.current_step = form.current_step + 1>
			<cfcontinue>
		</cfif>

		<!---  display content of the current step  --->
		<cfif form.current_step eq step_counter>
			<fieldset>
				<cfinclude template="#step.content#">
			</fieldset>
		</cfif>
	</cfloop>
	</cfoutput>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>

<cfif step_counter eq 6 and CURRENT_STEP eq 7>
	<!--- process import programs  --->
	<cfinclude template="/planners/import/process_planner_import.cfm">
	<div class="msg">
		<cfoutput>
			You are importing #program_count# #Application.PlannerPrgLabel_Plural#. It may take a significant amount of time to process the import of these programs.<br>
			You will receive an email when the process completes. You can <a href="##" onclick="parent.window.location = '#request.AccessStructure.User_Directory#/home.cfm'" id='home'>#application.util.string.linkFormat("click here")#</a> to continue to work in the application.
		</cfoutput>
	</div>
</cfif>

<cffunction name="saveHiddenValues" output="true" hint="Save input elements needed on all pages">
	<!---  store persisted + hidden elements in all pages in this array --->
	<cfset local.hidden_inputs = [	"current_step",
									"parent_action",
									"chosen_planners",
									"chosen_planner_info",
									"chosen_products",
									"chosen_programs",
                                    "chosen_bus_segment",
									"target_planner_Id",
									"target_planner_info",
									"source_planner_Id",
									"source_planner_info",
									"planner_template_id",
									"planner_import_type"
								]>
	<cfloop array="#local.hidden_inputs#" index="local.hidden_entry">
		<cfif local.hidden_entry eq "current_step">
			<!---  increment next step by one  --->
			<input type="hidden" name="#local.hidden_entry#" value="#(form[ local.hidden_entry ] + 1)#">
		<cfelse>
			<cfparam name="form.#local.hidden_entry#" default="">
			<input type="hidden" name="#local.hidden_entry#" value="#form[ local.hidden_entry ]#">
		</cfif>
	</cfloop>
</cffunction>
