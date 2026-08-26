<!-----------------------------------------------------------------------------------------------------------------------------------------
Name         :  /planners/include/select_reassign_rsp.cfm
Created Date :  2017 July
Created By   :  Chris Nguyen
Description  :  Assign rsp to planners in reassign planners

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
	th > select, td > select {
		width: 98%;
	}
</style>

<cfscript>
	param name="form.action" default="";

	oSearch   = createObject("component", "mvc.Models.Planner.PlannerSearchManager");
	oUser     = createObject("component", "components.user.UserManager");
	oPlanner  = createObject("component", "mvc.Models.Planner.PlannerManager");

	if ( form.action eq "save" ) {
		// writedump(form);
		oPlanner.reassign( form );
		location("/Manufacturers/home.cfm", "false");
	}
	qPlanners = oSearch.getPlanners( form.chosen_planners );
	qRSPs     = oUser.getRSPbyPosition( form.chosen_position_id );
</cfscript>

<form method="post" name="select_rsp" id="select_rsp" action="/planners/include/select_reassign_rsp.cfm">
	<input type="hidden" name="action" value="save">

	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<cfoutput>
	<table class="dataTable row-border order-column hover" width="100%">
		<thead>
			<tr>
				<!-- 1 --> <th style="text-align:left;padding:8px 10px;cursor:pointer;">
								<cfif form.parent_action eq "reassign">
									<input type="checkbox" id="checkall">
								</cfif>
							</th>
				<!-- 2 --> <th style="text-align:left">#Application.PlannerLabel# ID</th>
				<!-- 3 --> <th style="text-align:left">Title [Customer]</th>
				<!-- 4 --> <th style="text-align:left">Type</th>
				<!-- 5 --> <th style="text-align:left">Start Date</th>
				<!-- 6 --> <th style="text-align:left">End Date</th>
				<!-- 7 --> <th>Group?</th>
				<!-- 8 --> <th>Status</th>
				<!-- 9 --> <th style="text-align:left">New Responsible Sales Person &nbsp; &nbsp;
								<a href='##' id='mass_apply'>#application.util.string.linkFormat("apply")#</a><br>
								<select name=rsp_for_all id=rsp_for_all class=rsp>
									<option value=""></option>
									<cfloop query="qRSPs">
										<option value="#qRSPs.User_ID#">#qRSPs.User_Full_Name#</option>
									</cfloop>
								</select>
							</th>
			</tr>
		</thead>
	</table>

	<cfset planner_dataset = []>
	<cfloop query="qPlanners" startrow="1" endrow="1000">
<!---
		<!-- 1 --> "<input type=checkbox class=hand>",
		<!-- 2 --> qPlanners.Planner_Number,
		<!-- 3 --> qPlanners.Planner_Title,
		<!-- 4 --> qPlanners.Planner_Type,
		<!-- 5 --> qPlanners.Planner_Start_Date,
		<!-- 6 --> qPlanners.Planner_End_Date,
		<!-- 7 --> qPlanners.Customer_Group,
		<!-- 8 --> qPlanners.Status_Abbreviation,
		<!-- 9 --> qPlanners.RSP_ID ( lookup value in select dropdown )
		<!--10 --> qPlanners.Planner_ID ( hidden )
 --->
 		<cfscript>
			arrayAppend(planner_dataset, [	( form.parent_action eq "reassign"
												? "<input type=checkbox class=hand value='#qPlanners.Planner_ID#'>"
												: "" ),
											qPlanners.Planner_Number,
											qPlanners.Name & " [" & qPlanners.Shr_Ship_To & "]",
											qPlanners.Planner_Type,
											qPlanners.Planner_Start_Date,
											qPlanners.Planner_End_Date,
											qPlanners.Customer_Group,
											qPlanners.Status_Abbreviation,
											qPlanners.RSP_ID,
											qPlanners.Planner_ID
										]);
 		</cfscript>
	</cfloop>

	<cfset rsp_dataset = []>
	<cfloop query="qRSPs">
		<cfset arrayAppend(rsp_dataset, [ qRSPs.User_ID, qRSPs.User_Full_Name ])>
	</cfloop>

	<div style="clear:both;"></div>

	<cfset actions = "">
	<cfif form.parent_action eq "reassign">
		<cfsavecontent variable="actions"><a href='##' id='save'>#application.util.string.linkFormat("reassign")#</a></cfsavecontent>
	</cfif>
	</cfoutput>

	<script>
		// create rsp dropdown options dynamically
		function rsp_options( rsp_id ) {
			var rsps = <cfoutput>#serializeJSON( rsp_dataset )#</cfoutput>;
			var options = [ "<option value=''></option>" ];
			for (var i = 0; i < rsps.length; i++) {
				options.push( "<option value='"
								+ rsps[i][0]
								+ "' "
								+ (rsp_id == rsps[i][0] ? "selected" : "")
								+ ">"
								+ rsps[i][1]
								+ "</option>" );
			}
			return options.join("");
		}
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( planner_dataset )#</cfoutput>,
															dom: "f<'actions'>ti",
															columns: [
																		/* 1 */ { orderable: false, className: "hand" },
																		/* 2 */ {},
																		/* 3 */ {},
																		/* 4 */ {},
																		/* 5 */ { searchable: false, className: "center" },
																		/* 6 */ { searchable: false, className: "center" },
																		/* 7 */ { searchable: false, orderable: false, className: "center" },
																		/* 8 */ { className: "center" },
																		/* 9 */ { orderable: false, searchable: false,
																					render: function(data, type, row) {
																								/* rsp dropdown */
																								return "<select name='rsp_"
																										+ row[9]   /* planner_id */
																										+ "' class=rsp>"
																										+ rsp_options( row[8] /* rsp_id */ )
																										+ "</select>";
																							}
																				},
																		        { visible: false }
																	],
															order: [ [1, "desc"] ],
															scrollY:        "57vh",
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

		$("#mass_apply").click(function() {
			var mass_value = $("#rsp_for_all").val();
			$("input.hand:checked").each(function() {
				var planner_id = $(this).val();
				$("select[name=rsp_" + planner_id + "]").val( mass_value );
			});
		});

		$("#save").click(function() {
			var selectedCount = 0;
			// reset search string to show hidden rows
			data_table.search( '' ).draw( false );
			 // check if there is a rsp assigned to atleast 1 planner
			data_table.$("select.rsp").each(function() {
				if ( $(this).val() != '' )
					selectedCount++;
			});
			if (selectedCount == 0){
				dhx_alert( "Please select atleast one RSP." );
				return false;
			}
			else{
				 // do not submit rows without rsp assignment
				data_table.$("select.rsp").each(function() {
					if ( $(this).val() == '' )
						$(this).prop("disabled", "disabled");
				});
				show_loader( "SAVING CHANGES, PLEASE WAIT..." );
				$("#select_rsp").submit();
			}
		});
	</script>

</form>
