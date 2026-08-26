<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/index.cfm
	Created Date:  2016 Apr
	  Created By:  kal
	 Description:  copy programs from another planner
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!doctype html>
<html>
<head></head>
<body>
	<style>
		fieldset{border:2px solid #ddd;border-radius:8px;box-sizing:border-box;margin:0;min-height:100px;min-width:60vw;}
		.msg{border:1px dotted #CCC;color:#333;line-height:26px;text-align:center;font-style:bold;font-size:16px;margin:10px;padding:15px;}
		h3{border:1px dotted #CCC;color:#333;line-height:26px;margin:4px 0;padding:0 15px;}
		h3.active{background-color:#9BC2E6;}
		h3.inactive{background-color:#DCEAF6;opacity:.75;}
		h3>i{background-color:#82A9CD;color:white;font-style:normal;margin-right:5px;padding:6px;}
	</style>

	<cfset jQueryUI.widgets = "tooltip">
	<cfset include_files = [    "/common_files/jQuery.cfm"
								,"/common_files/jQueryUI.cfm"
								,"/styles/css-loader.css"
								,"/common_files/dhx_message.cfm"
							]>
	<cf_include files=#arrayToList( include_files )#>


	<cfscript>
		appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		labelManager = createObject( "component", "components.settings.Labels.Labels" ).init();
		planner_labels = labelManager.plannerLabels();
        request.planner_labels = planner_labels;
		plannerTemplateManager  = createObject("component", "mvc.Models.Planner.PlannerTemplateManager");
		plannerManager  = createObject("component", "mvc.Models.Planner.PlannerManager");
	</cfscript>

    <cfparam name="form.current_step"     default=1>
	<cfparam name="form.parent_action"    default="create">
	<cfparam name="form.planner_category" default=''>
    <cfparam name="form.operator_ids"     default=''>

	<cfset steps = [	{ title="<i>1</i> Select Responsible Sales Person", content="/planners/include/select_rsp.cfm" },
						{ title="<i>2</i> Select #Application.PlannerLabel# Template", content="/planners/include/select_planner_template.cfm" },
						{ title="<i>3</i> Select #planner_labels.distributor_plural#", content="/planners/include/select_planner_distributors.cfm" }
					]>

	<cfset udf = createObject( "component", "components.udf" )>
	<cfif udf.is_planner_indirect_category( planner_category = form.planner_category )>
        <cfset form.planner_template_id = form.template_id>
        <cfset steps[3] = { title="<i>3</i> Select #planner_labels.operator_plural#", content="/planners/include/select_operators.cfm"}>
    </cfif>

	<script>
		if (window.innerHeight <= 768) {
			$("fieldset").css("height", "60vh");
		}
	</script>

	<cfoutput>
		<cfset step_counter = 0>
		<cfloop array="#steps#" index="step">
			<cfset step_counter = step_counter + 1>

			<!--- additional info in heading  --->
			<cfset more_info = "">
			<cfif step_counter eq 1 and form.current_step gte 2>
				<cfset more_info = "( " & form.chosen_rsp & " )">
			</cfif>

			<cfif step_counter eq 2 and form.current_step gte 3>
				<cfset more_info = "( " & form.chosen_template & " )">
			</cfif>

			<cfif step_counter eq 3 and form.current_step gte 4>
                <!--- <cfif form.planner_category is "MSA"> --->
				<cfif request.is_planner_indirect_category>
                    <cfinclude template="#step.content#">
                <cfelse>
                    <cfset qryDuplicatePlanner = plannerManager.checkForDuplicatePlanner(templateID = template_id, groupLevelId = group_level_id, customerIdList = distributor_list) />
                    <cfset customer_count = listLen( form.distributor_list )>
                    <cfset more_info = "( " & customer_count & " selected )">
                    <form name="main_form" method="post">
                        <cfset saveHiddenValues() />
                    </form>
                    <cfset startCreatePlanner(qryDuplicatePlanner) />
                </cfif>
			</cfif>

			<!---  step heading  --->
			<h3 class=#(form.current_step eq step_counter ? "active" : "inactive")#>#step.title# #more_info#</h3>

			<!---  display content of the current step  --->
			<cfif form.current_step eq step_counter>
				<fieldset>
					<cfinclude template="#step.content#">
				</fieldset>
			</cfif>
		</cfloop>
	</cfoutput>

	<cfinclude template="/common_files/focus.cfm">

	<form name="create_planner" method="post" action="/planners/create/planner_profile.cfm">
		<input type="hidden" name="plannerID">
		<input type="hidden" name="mode" value="E">
		<input type="hidden" name="page_creating" value="1">
	</form>


</body>
</html>

<cffunction name="saveHiddenValues" output="true" hint="Save input elements needed on all pages">
	<!---  store persisted + hidden elements in all pages in this array --->
	<cfset local.hidden_inputs = [	"current_step",
									"parent_action",
									"rsp_position_id",
									"rsp_user_id",
									"chosen_rsp",
									"template_id",
									"chosen_template",
									"distributor_list",
									"group_level_id",
                                    "planner_category",
                                    "operator_ids"
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


<cffunction name="startCreatePlanner" output="true" hint="fn to handle start create planner ">
	<cfargument name="qryDuplicatePlanner" type="query" />
	<script>

		<cfif arguments.qryDuplicatePlanner.recordCount>
			<cfset distributorLabel = LCase(planner_labels.distributor_singular) />

			<cfif arguments.qryDuplicatePlanner.recordCount eq 1>
				<cfset dupMessage = "A #Application.PlannerLabel# already exists for the same #distributorLabel#<br><br>" />
				<cfset dupMessage = dupMessage & "Existing #Application.PlannerLabel#: #arguments.qryDuplicatePlanner.Planner_Number# #arguments.qryDuplicatePlanner.Planner_Title#<br>" />
			<cfelse>
				<cfset dupMessage = "#arguments.qryDuplicatePlanner.recordCount# planners already exist for the same #distributorLabel#<br><br>" />
				<cfloop query="arguments.qryDuplicatePlanner" endRow="5">
					<cfset dupMessage = dupMessage & "#Planner_Number# #Planner_Title#<br>" />
				</cfloop>
				<cfif arguments.qryDuplicatePlanner.recordCount GT 5>
					<cfset dupMessage = dupMessage & "(Not all records are displayed)<br>" />
				</cfif>
			</cfif>

			<cfif arguments.qryDuplicatePlanner.Check_Duplicate_Planner_Action eq 1> <!--- Allow duplicate planners --->
				var msg = "#dupMessage#.<br>Do you want to create a duplicate #Application.PlannerLabel#?"
				displayDuplicatePlannerWarning(msg);
			<cfelse> <!--- Prevent duplication of planners --->
				var msg = "#dupMessage#.<br>Cannot create a duplicate #Application.PlannerLabel#.<br>Please select a different #distributorLabel#."
				displayDuplicatePlannerError(msg);
			</cfif>
		<cfelse>
			startCreatePlanner();
		</cfif>

		function displayDuplicatePlannerWarning(msg){
			dhtmlx.confirm({
				title:"Duplicate #Application.PlannerLabel#",
				type:"confirm-error",
				text: msg,
				width: "500px",
				ok: "Create #Application.PlannerLabel#",
				callback:function(response){
					if(response){
						startCreatePlanner();
					} // if(response)
					else{ // Cancel - go back to select distributor
						goBackToSelectDistributors();
					}
				} // callback function
			}); // dhtmlx.confirm
		}

		function displayDuplicatePlannerError(msg){
			dhtmlx.alert({
				title:"Duplicate #Application.PlannerLabel#",
				type:"alert-error",
				text: msg,
				width: "500px",
				callback:function(response){
					if(response){
						goBackToSelectDistributors();
					} // if(response)
				} // callback function
			}); // dhtmlx.confirm
		}

		function goBackToSelectDistributors(){
			$('input[name=current_step]').val("3");
			$("form[name=main_form]").submit();
		}

		function startCreatePlanner(){
			show_loader("CREATING #Application.PlannerLabel#, PLEASE WAIT..");
			//click create
			$.getJSON(
				'/mvc/Models/Planner/PlannerManager.cfc',
				{
					method         : "createPlanner",
					userID         : '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>',
					positionID     : $('input[name=rsp_position_id]').val(),
					rspID          : $('input[name=rsp_user_id]').val(),
					templateID     : $('input[name=template_id]').val(),
					groupLevelId   : $('input[name=group_level_id]').val(),
					customerIdList : $('input[name=distributor_list]').val(),
					returnFormat   : "json"
				},
				// success
				function(mydata){
					$("input[name=plannerID]").val( mydata );
					$("input[name=mode]").val( 'E' );
					$("form[name=create_planner]").submit();
				}
			); // $.getJSON
		}

	</script>

</cffunction>
