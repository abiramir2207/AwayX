<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
Name         :  \planners\include\select_operators.cfm
Created Date :  2017 October
Created By   :  Chris Nguyen
Description  :  Select operators for indirect planner

Remarks      :  Required parameters:
					- form.parent_planner_id
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfsavecontent variable="body_content">
<style>
	div.dataTables_filter { position: relative; top:3px; }
	div.dataTables_filter input { width: 225px; }
	div.actions { float: left; margin: 0 10px 10px 25px; }
</style>


<cfscript>
	param name="form.action" default="";
    param name="form.planner_category" default="";

	planner_obj = createObject("component", "mvc.models.planner.plannermanager");
	qOperators  = planner_obj.getPlannerOperators( form.planner_template_id );
	udf         = createObject( "component", "components.udf" );
</cfscript>

<cfif ( form.action eq "save" )>
	<cfset new_planner_ID = udf.is_planner_indirect_category( planner_category = form.planner_category )
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
	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<table class="dataTable row-border order-column hover" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;padding:8px 10px;cursor:pointer;">
								<input type="checkbox" id="checkall">
							</th>
				<!-- 2 --> <th style="text-align:left">Name</th>
				<!-- 3 --> <th style="text-align:left">ID</th>
				<!-- 4 --> <th style="text-align:left">Address</th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>
	<cfloop query="qOperators">
 		<cfscript>
			arrayAppend(dataset, [
									"<input type=checkbox class=hand name=operator value='#qOperators.bsa_operator_id#'>",
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

	<cfoutput>
	<div style="clear:both;"></div>

	<cfset actions = "">
	<cfsavecontent variable="actions"><a href='##' id='choose' class=primary>#application.util.string.linkFormat("create "
                                                                                                                    & ( udf.is_planner_indirect_category( planner_category = form.planner_category ) ? '' : request.planner_labels.indirect_singular )
                                                                                                                    & " planner")#</a></cfsavecontent>
	</cfoutput>
</cfsavecontent>
<cfoutput>#application.util.string.compress( body_content )#</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>pti",
															scrollY:        (window.innerHeight > 768 ? "58vh" : "54vh"),
															columns: [
																		/* 1 */ { orderable: false, className: "hand" },
																		/* 2 */ {},
																		/* 3 */ {},
																		/* 4 */ { orderable: false }
																	],
															order: [],
															scrollCollapse: true,
															paging:         true,
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
	</script>

</form>
