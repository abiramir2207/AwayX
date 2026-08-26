<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :  \planners\include\select_operators.cfm
Created Date :  2021 October
Created By   :  Chris Nguyen
Description  :  Select operators for indirect planner
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Planner Operators</title>
</head>
<body>
<style>
	div.dataTables_filter { position: relative; top:3px; }
	div.dataTables_filter input { width: 225px; }
	div.actions { float: left; margin: 0 10px 10px 25px; }
</style>


<cfscript>
	param name="form.action" default="";
    param name="form.planner_category" default="";

    labelManager           = createObject( "component", "components.settings.Labels.Labels" ).init();
    planner_labels         = labelManager.plannerLabels();
    request.planner_labels = planner_labels;
    plannerManager         = createObject( "component", "mvc.Models.Planner.PlannerManager" );

	planner_obj = createObject("component", "mvc.models.planner.plannermanager");
	qOperators  = planner_obj.getPlannerOperators( form.template_id );
</cfscript>

<cfif ( form.action eq "save" )>
	<cfset new_planner_ID = form.planner_category is "MSA"
                                ? planner_obj.createMSAPlanner( form )
                                : planner_obj.createIndirectPlanner( form )>
	<form id="create_planner" method="post" action="/planners/create/planner_profile.cfm">
		<input type="hidden" name="plannerID" value=<cfoutput>#new_planner_ID#</cfoutput>>
		<input type="hidden" name="mode" value="E">
		<input type="hidden" name="page_creating" value="1">
	</form>
	<script>
		show_loader();
		document.getElementById("create_planner").submit();
	</script>
</cfif>

<form id="select_operators" method="post">
	<input type="hidden" name="action" value="save">

	<cfset jQueryUI.widgets = "tooltip">
    <cfinclude template="/common_files/jQuery.cfm">

	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<table class="dataTable row-border order-column hover" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;padding:8px 10px;cursor:pointer;">
								<input type="checkbox" id="checkall">
							</th>
				<!-- 2 --> <th style="text-align:left"><cfoutput>#request.planner_labels.operator_singular#</cfoutput> Name</th>
				<!-- 3 --> <th style="text-align:left">ID</th>
				<!-- 4 --> <th style="text-align:left">Address</th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>
	<cfloop query="qOperators">
 		<cfscript>
 			checked = ( form.selected_operators gt ''
 							and listFindNoCase(form.selected_operators, qOperators.bsa_operator_id) )
 						? "checked=checked"
 						: '';
			arrayAppend(dataset, [
									"<input type=checkbox class=hand name=operator #checked# value='#qOperators.bsa_operator_id#'>",
									qOperators.Operator_Name,
									qOperators.Legacy_ID,
									qOperators.Operator_Address & " "
										& (len( qOperators.Operator_Address ) ? qOperators.Operator_Address & " " : "")
										& qOperators.Operator_City & " "
										& qOperators.Operator_State & " "
										& qOperators.Operator_Zip
								]);
 		</cfscript>
	</cfloop>

	<div style="clear:both;"></div>

    <cfoutput>
    	<a href="##" class="save">#application.util.string.linkFormat("save")#</a>

			<cfset actions = "">
			<cfsavecontent variable="actions"><a href='javascript: createList2()'  id='createlist13'>#application.util.string.actionLinkFormat2('create list')#</a></cfsavecontent>
			</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>pti",
															scrollY: (window.innerHeight - 125) + "px",
															columns: [
																		/* 1 */ { orderable: false, className: "hand" },
																		/* 2 */ {},
																		/* 3 */ {},
																		/* 4 */ { orderable: false }
																	],
															order: [],
															scrollCollapse: true,
															paging:         false,
															pageLength:     1000
		});
		$("div.actions").html( <cfoutput>"#actions#"</cfoutput> );
		$("th:first").click(function() {
			var checkall = $("#checkall");
			checkall.prop("checked", !checkall.prop("checked"));
			$("input[type=checkbox]").prop("checked", checkall.prop("checked"));
		});

		$("#checkall").click(function(e) {
			var checkall = $(this).prop("checked");
			$("input[type=checkbox]").prop("checked", checkall);
			e.stopPropagation();
		});

		$("tr td:nth-child(1)").click(function() {
			var checkbox = $(this).find("input[type=checkbox]");
			checkbox.prop("checked", !checkbox.prop("checked"));
		});

		$("input.hand").click(function(e) {
			e.stopPropagation();
		});

		$("#choose").click(function() {
			var selected = [];
			data_table.$("input.hand:checked").each(function() {
				selected.push( $(this).val() );
			});
			if ( selected.length == 0 ) {
				dhx_alert( "Please select at least one " + <cfoutput>"#lcase( request.planner_labels.operator_singular )#"</cfoutput> + " to continue." );
				return false;
			};
			show_loader();
			$("input[name=operator_ids]").val( selected.join(",") );
			$("#select_operators").submit();
		});

        $("a.save").click(function(){
            selected = [];

            data_table.$("input.hand:checked").each(function() {
                selected.push( $(this).val() );
			});

            <cfif form.operators_input gt ''>
                <cfoutput>opener.document.all.#form.operators_input#.value</cfoutput> = selected.join();
            </cfif>

            <cfif form.callback gt ''>
                <cfoutput>opener.#form.callback#();</cfoutput>
            </cfif>
            window.close();
        });
				function createList2(){
					NewWindow('/common_files/createListForm.cfm?passForm=planner_operators&<cfoutput>template_id=#form.template_id#&clientVariable=#request.planner_labels.operator_singular#</cfoutput>', 'planner_operators_list', 350, 425, 'yes', 'yes')
				}
	</script>
</form>
</body>
</html>