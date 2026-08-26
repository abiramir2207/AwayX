<!-----------------------------------------------------------------------------------------------------------------------------------------
Name         :  /planners/include/select_planners.cfm
Created Date :  2017 July
Created By   :  Chris Nguyen
Description  :  Display planners based on search criteria & allow multiple selections

Remarks      :
----------------------------------------------------------------------------------------------------------------------------------------->
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
	param name="form.parent_action"       default="reassign";
	param name="form.broker"              default="0";
	param name="form.buying_group"        default="0";
	param name="form.customer_id"         default="0";
	param name="form.customer_name"       default="";
    param name="form.shr_ship_tos"        default="";
	param name="form.family_name"         default="0";
	param name="form.planner_number"      default="";
	param name="form.planner_status"      default="";
	param name="form.planner_template_id" default="";
	param name="form.planner_template"    default="";
	param name="form.region_id"           default="0";
	param name="form.responsible_user_id" default="";
	param name="form.rsp_id"              default="";
	param name="form.zone_id"             default="0";
	param name="form.line_of_biz"         default="0";
	param name="form.pending_my_approval" default="0";
	param name="form.indirect_customer"   default="";
	param name="form.target_planner_id"   default="";
	param name="form.user_position"       default="";
	param name="form.Planner_Type"   	  default="";
	param name="form.target_planner_Id"   default="";
	param name="form.planner_import_type" default="0";
	param name="form.chosen_bus_segment"  default="";
</cfscript>

<cfif (form.parent_action eq "import")>
    <cfparam name="form.chosen_planners" default="">

    <cfif form.chosen_planners neq ''>
		<cfset form.customer_name = ''>
		<cfset form.shr_ship_tos  = ''>

		<cfif val( form.planner_import_type ) neq 1>
			<cfquery name="qShr_Ship_To" datasource="#application.datasource#">
				SELECT BSAFC.Shr_Ship_To, pl.Distributor_Group_Level_ID
				FROM planners pl
						INNER JOIN BSA_Foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID = PL.Customer_ID
				WHERE pl.planner_id = '#form.chosen_planners#'
					AND pl.Distributor_Group_Level_ID != - 1

				UNION

				SELECT BSAFC.Shr_Ship_To, pl.Distributor_Group_Level_ID
				FROM planners pl
							INNER JOIN Planner_Customer_Group_Members pcgm ON pcgm.Planner_ID = pl.Planner_ID
							INNER JOIN BSA_Foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID = pcgm.Distributor_ID
				WHERE pl.planner_id = '#form.chosen_planners#' AND pl.Distributor_Group_Level_ID = - 1
			</cfquery>

			<cfif qShr_Ship_To.Distributor_Group_Level_ID eq -1>
				<cfset form.shr_ship_tos  = valueList( qShr_Ship_To.Shr_Ship_To )>
			<cfelse>
				<cfset form.customer_name = qShr_Ship_To.Shr_Ship_To>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfscript>
	oSearch = createObject("component", "mvc.Models.Planner.PlannerSearchManager");
	qPlanners = oSearch.searchPlanners(	broker = form.broker,
										buying_group = form.buying_group,
										Cust_Id = form.customer_id,
										customer = form.customer_name,
										family = form.family_name,
										line_of_biz = form.line_of_biz,
										indirect_customer = form.indirect_customer,
										planner = form.planner_number,
										planner_status = form.planner_status,
										planner_template = form.planner_template,
										region_id = form.region_id,
										rsp_id = form.responsible_user_id,
										zone_id = form.zone_id,
										pending_my_approval = form.pending_my_approval,
										exclude_plannerId = form.target_planner_id,
										User_Position = form.user_position,
										Planner_Type = form.Planner_Type,
										target_planner_Id = form.target_planner_Id,
										planner_import_type = form.planner_import_type,
                                        business_segement_id = form.chosen_bus_segment,
                                        shr_ship_tos = form.shr_ship_tos
									);
</cfscript>

<form id="select_planners" method="post">
	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<table class="dataTable row-border order-column hover" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;padding:8px 10px;cursor:pointer;">
								<cfif form.parent_action eq "reassign">
									<input type="checkbox" id="checkall">
								</cfif>
							</th>
				<!-- 2 --> <th style="text-align:left"><cfoutput>#Application.PlannerLabel#</cfoutput> ID</th>
				<!-- 3 --> <th style="text-align:left">Title [Customer]</th>
				<!-- 4 --> <th style="text-align:left">Type</th>
				<!-- 4 --> <th style="text-align:left">D/I</th>
				<!-- 5 --> <th style="text-align:left">Start Date</th>
				<!-- 6 --> <th style="text-align:left">End Date</th>
				<!-- 7 --> <th>Group?</th>
				<!-- 8 --> <th><cfoutput>#Application.PlannerPrgLabel#</cfoutput> Count</th>
				<!-- 9 --> <th>Status</th>
				<!--10 --> <th style="text-align:left">RSP</th>
				<!--11 --> <th style="text-align:left">RSP Position</th>
				<!--12 --> <th style="text-align:left">RSPID</th>
			</tr>
		</thead>
	</table>

	<cfset dataset = []>
	<cfloop query="qPlanners">
	<!---
		<!-- 1 --> "<input type=checkbox class=hand>",
		<!-- 2 --> qPlanners.Planner_Number,
		<!-- 3 --> qPlanners.Planner_Title,
		<!-- 4 --> qPlanners.Planner_Type,
		<!-- 5 --> qPlanners.Planner_Start_Date,
		<!-- 6 --> qPlanners.Planner_End_Date,
		<!-- 7 --> qPlanners.Customer_Group,
		<!-- 8 --> qPlanners.Program_Count,
		<!-- 9 --> qPlanners.Status_Abbreviation,
		<!--10 --> qPlanners.RSP_User_Name,
		<!--11 --> qPlanners.RSP_Position
		<!--12 --> qPlanners.RSP_ID
 	--->
 		<cfscript>
 			local.lockedByCurrentUser = 0;
 			local.imgSrc = "/Images/iconmonstr-lock-1-24.png";
 			if ( qPlanners.is_locked && ( qPlanners.Locked_By_User_ID == request.AccessStructure.User_ID )) {
 				local.imgSrc = "/Images/iconmonstr-pencil-10-24.png";
 				local.lockedByCurrentUser = 1;
 			}

 			locked_info = qPlanners.is_locked
 							? "<span title='Locked by #qPlanners.Locked_By_User_Name#'>"
 								& "<img style='width:10px;height:10px;' src='" & local.imgSrc & "'></span>"
 							: "";

 			input_type = form.parent_action eq "import"
 							? "radio"
 							: "checkbox";

			arrayAppend(dataset, [	(qPlanners.is_locked && !local.lockedByCurrentUser)
										? ""
										: "<input type=#input_type# class=hand name=plnr value='#qPlanners.Planner_ID#'>",
									qPlanners.Planner_Number & ( qPlanners.is_locked
																	? " #locked_info#"
																	: "" ),
                                    qPlanners.Shr_Ship_To eq ''
                                        ? qPlanners.Planner_Title
									    : qPlanners.Name & " [" & qPlanners.Shr_Ship_To & "]",
									qPlanners.Planner_Type,
									qPlanners.Direct_Indirect,
									qPlanners.Planner_Start_Date,
									qPlanners.Planner_End_Date,
									qPlanners.Customer_Group,
									qPlanners.Program_Count,
									qPlanners.Status_Abbreviation,
									qPlanners.RSP_User_Name,
									qPlanners.RSP_Position,
									qPlanners.RSP_ID,
                                    qPlanners.business_segment_id
								]);
 		</cfscript>
	</cfloop>

    <!--- <cfinclude template="/developer/dev_tools.cfm"> --->

	<cfoutput>

	<div style="clear:both;"></div>
	<cfset actions = "">
	<cfsavecontent variable="actions"><a href='##' id='choose'>#application.util.string.linkFormat("choose selected <cfoutput>#Application.PlannerLabel_Plural#</cfoutput>")#</a></cfsavecontent>
	</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>ti",
															columns: [
																		/* 1 */ { orderable: false, className: "hand" },
																		/* 2 */ {},
																		/* 3 */ {},
																		/* 4 */ {},
																		/* 4 */ {},
																		/* 5 */ { searchable: false, className: "center" },
																		/* 6 */ { searchable: false, className: "center" },
																		/* 7 */ { searchable: false, orderable: false, className: "center" },
																		/* 8 */ { searchable: false, className: "numeric" },
																		/* 9 */ { className: "center" },
																		/*10 */ {},
																		/*11 */ {},
																		/*12 */ {visible:false},
																		/*13 */ {visible:false}
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
				<cfif form.parent_action eq "import">
					var data = data_table.row( $(this).parents('tr') ).data();
					$("input[name=chosen_planner_info]").val( data[1] + "-" + data[2] + "-" + data[3] );
                    $("input[name=chosen_bus_segment]").val( data[13] );
				</cfif>
			});
			if ( selected.length == 0 ) {
				dhx_alert( "Please select a <cfoutput>#Application.PlannerLabel#</cfoutput> to continue." );
				return false;
			};
            show_loader();
			$("input[name=chosen_planners]").val( selected.join(",") );
			$("#select_planners").submit();
		});
	</script>

</form>

