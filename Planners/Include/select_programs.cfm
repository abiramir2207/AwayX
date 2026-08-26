<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Include/select_programs.cfm
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
	local.getPlanner               = oPlanner.getPlanner( form.target_planner_Id );
	local.defaultProductFilterAttr = oPlanner.productFilterAttributes( local.getPlanner.Planner_Template_ID, 1 );
	if (len(form.chosen_products)){
		local.saveProducts 		   = oPlanner.savePlannerProducts(form.target_planner_Id, form.chosen_products, local.defaultProductFilterAttr.product_group_level_id );
	}
	local.target_products          = oPlanner.getPlannerProducts(form.target_planner_Id, local.defaultProductFilterAttr.product_group_level_id );
	local.qPlannerImportPrograms   = oPlanner.getPlannerImportPrograms( source_planner = form.source_planner_Id, products_list = ValueList(local.target_products.item_key), target_planner = form.target_planner_id );
</cfscript>

<form id="select_programs" method="post">
	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<table class="dataTable row-border order-column hover" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;padding:8px 10px;cursor:pointer;"><input type="checkbox" id="checkall"></th>
				<!-- 2 --> <th style="text-align:left">Program</th>
				<!-- 3 --> <th style="text-align:left">Program Title</th>
				<!-- 4 --> <th style="text-align:left">Template</th>
				<!-- 5 --> <th style="text-align:left">Start Date</th>
				<!-- 6 --> <th style="text-align:left">End Date (* = Adjusted)</th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>

	<cfloop query="local.qPlannerImportPrograms">
		<!---
		<!-- 1 --> "<input type=checkbox class=hand>",
		<!-- 2 --> local.qPlannerImportPrograms.contract_number,
		<!-- 3 --> local.qPlannerImportPrograms.contract_title,
		<!-- 4 --> local.qPlannerImportPrograms.created_type,
		<!-- 5 --> local.qPlannerImportPrograms.contract_start_date,
		<!-- 6 --> local.qPlannerImportPrograms.contract_end_date
 		--->
 		<cfscript>
 			arrayAppend(dataset, [	"<input type=checkbox class=hand value='#local.qPlannerImportPrograms.contract_main_id#'>",
									local.qPlannerImportPrograms.contract_number,
									local.qPlannerImportPrograms.contract_title,
                                    local.qPlannerImportPrograms.created_type,
									dateFormat(local.qPlannerImportPrograms.contract_start_date, "mmm dd, yyyy"),
									dateFormat(local.qPlannerImportPrograms.contract_end_date, "mmm dd, yyyy")
                                        & ( local.qPlannerImportPrograms.program_end_adjusted ? " *" : '' )
								]);
 		</cfscript>
	</cfloop>

	<cfoutput>
	<div style="clear:both;"></div>

	<cfset actions = "">
	<cfsavecontent variable="actions"><a href='##' id='choose'>#application.util.string.linkFormat("start copy")#</a></cfsavecontent>
	</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>ti",
															columns: [
																		/* 1 */ { orderable: false, className: "hand" },
																		/* 2 */ {},
																		/* 3 */ {},
																		/* 4 */ {},
																		/* 5 */ { searchable: false },
																		/* 6 */ { searchable: false }
                                                                        ],
															order: [ [1, "desc"] ],
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
				dhx_alert( "Please select a <cfoutput>#Application.PlannerPrgLabel#</cfoutput>." );
				return false;
			};
            show_loader();
			$("input[name=chosen_programs]").val( selected.join(",") );
			$("#select_programs").submit();
		});
	</script>

    <cfquery name="qAdjusted" dbtype="query">
        SELECT *
          FROM [local].qPlannerImportPrograms
         WHERE program_end_adjusted = 1
    </cfquery>

    <cfif qAdjusted.RecordCount>
        <cfset request.noty_version = "3">

        <cfinclude template="/common_files/noty.cfm">
        <script>
            new Noty({ layout:"center", type:"alert", text: noty_message("Ending dates will be adjusted (programs end with *)") }).show();
        </script>
    </cfif>
</form>
