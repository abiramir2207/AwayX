<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Include/select_products.cfm
	Created Date:  2017 July
	  Created By:  kal
	 Description:  displays products from source planner not in target planner during copy
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<style>
	th.left {
		text-align: left;
	}
	td.center {
		text-align: center;
	}
	td.hand {
		cursor: pointer;
	}
	td.numeric {
		text-align: right;
	}
	div.actions a {
		margin: 0 50px;
		position: relative;
		top: -2px;
	}
</style>

<cfscript>
	oPlanner = createObject("component", "mvc.Models.Planner.PlannerManager");
	qPlannerMissingItems = oPlanner.getPlannerMissingItems ( source_planner_Id =  form.source_planner_Id, target_planner_Id =  form.target_planner_Id );
</cfscript>

<form id="select_products" method="post">
	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<table class="dataTable row-border order-column hover" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;padding:8px 10px;cursor:pointer;"><input type="checkbox" id="checkall"></th>
				<!-- 2 --> <th style="text-align:left"><cfoutput>#application.returned_customer_setting.item_label#</cfoutput></th>
				<!-- 3 --> <th style="text-align:left"><cfoutput>#application.returned_customer_setting.item_label# Description</cfoutput></th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>

	<cfloop query="qPlannerMissingItems" startrow="1" endrow="1000">
		<!---
		<!-- 1 --> "<input type=checkbox class=hand>",
		<!-- 2 --> qPlannerMissingItems.Item,
		<!-- 3 --> qPlannerMissingItems.Description,
 		--->
 		<cfscript>
 			arrayAppend(dataset, [	"<input type=checkbox class=hand value='#qPlannerMissingItems.Item_Key#'>",
									qPlannerMissingItems.Item,
									qPlannerMissingItems.Description
								]);
 		</cfscript>
	</cfloop>

	<cfoutput>
	<div style="clear:both;"></div>

	<cfset actions = "">
	<cfsavecontent variable="actions"><a href='##' id='choose'>#application.util.string.linkFormat("choose selected products")#</a></cfsavecontent>
	</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>ti",
															columns: [
																		/* 1 */ { orderable: false, className: "hand" },
																		/* 2 */ {},
																		/* 3 */ {}
																	],
															order: [ [2, "asc"] ],
															scrollY:        (window.innerHeight > 768 ? "58vh" : "54vh"),
															scrollCollapse: true,
															paging:         false
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

		$("*[title]").tooltip();

		$("#choose").click(function() {
			var selected = [];
			data_table.$("input.hand:checked").each(function() {
				selected.push( $(this).val() );
			});
			if ( selected.length == 0 ) {
				dhtmlx.message({
								text: 	"products not selected will not be added to the <cfoutput>#Application.PlannerLabel#</cfoutput>",
								expire: 2000
							});
			};
            show_loader();
			$("input[name=chosen_products]").val( selected.join(",") );
			$("#select_products").submit();
		});
	</script>

</form>
