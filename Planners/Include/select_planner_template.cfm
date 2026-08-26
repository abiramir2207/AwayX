<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Include/select_planner_template.cfm
	Created Date:  2016 Apr
	  Created By:  kal
	 Description:  displays products from source planner not in target planner during copy
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<style>
	th.left { text-align: left;}
	td.center { text-align: center; }
	td.hand { cursor: pointer; }
	td.numeric { text-align: right; }
	div.actions a { margin: 0 50px; position: relative; top: -2px; }
</style>

<cfscript>
	// get planner templates
	qGetAllPlannerTemplates = plannerTemplateManager.getAllowedPlannerTemplates( status=1 );
</cfscript>

<form id="select_template" method="post">
	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm">

	<table class="dataTable row-border order-column hover" id="datagrid" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;">ID</th>
				<!-- 2 --> <th style="text-align:left;">Type</th>
				<!-- 3 --> <th style="text-align:left;">Description</th>
				<!-- 4 --> <th style="text-align:left;">Start Date</th>
				<!-- 5 --> <th style="text-align:left;">End Date</th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>

	<cfloop query="qGetAllPlannerTemplates">
 		<cfscript>
 			arrayAppend(dataset, [
									#qGetAllPlannerTemplates.Planner_Template_ID#,
									#qGetAllPlannerTemplates.Planner_Type#,
									#qGetAllPlannerTemplates.Planner_Description#,
									#dateFormat(qGetAllPlannerTemplates.Planner_Start_Date, "medium")#,
									#dateFormat(qGetAllPlannerTemplates.Planner_End_Date, "medium")#,
									#qGetAllPlannerTemplates.Category#
								]);
 		</cfscript>
	</cfloop>

	<cfoutput>
		<div style="clear:both;"></div>
	</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>ti",
															columns: [
																		/* 1 */ { "visible": false},
																		/* 2 */ { orderable: true, className: "hand" },
																		/* 3 */ { orderable: true, className: "hand" },
																		/* 4 */ { orderable: true, className: "hand" },
																		/* 5 */ { orderable: true, className: "hand" },
																		/* 6 */ { "visible": false}
                                                                        ],
															order: [ [1, "asc"] ],
															scrollY:        (window.innerHeight > 768 ? "58vh" : "54vh"),
															scrollCollapse: true,
															paging:         false
		});

		$("table.dataTable").on('click', 'tr', function() {
			var data = (data_table.row(this).data());
			$("input[name=template_id]").val(data[0]);
			$("input[name=chosen_template]").val(data[1] + " [ " + data[2] + " ] ");
			$("input[name=planner_category]").val(data[5]);
			$("#select_template").submit();
		});
	</script>

</form>