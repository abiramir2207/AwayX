<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_indirect.cfm
	Created Date:  2017 Oct
	  Created By:  Chris Nguyen
	 Description:  Displays indirect planners
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>
<style>
	table.dataTable tbody td { padding-left: 15px; padding-right: 15px; }
	div.actions { float: left; margin: 0 10px 10px 10px; position2: relative; top2: -2px; }
	div.actions a { margin-right: 50px; }
	div#DataTables_Table_0_filter input { width: 230px; }
</style>

<cfinclude template="topnav_form.cfm">

<!--- get both default setting and planner template setting, order them by default_setting & pick the top row --->
<cfquery name="qPlanners" datasource="#application.datasource#">
	SELECT p.Planner_ID,
	       p.Planner_Number,
	       p.Planner_Title,
	       (   SELECT COUNT(*)
	             FROM Contract_Main cm
	            WHERE cm.Planner_ID          = p.Planner_ID
	              AND cm.Deleted             = 0
	              AND cm.Manual_Cancel       = 0
	              AND cm.Contract_Start_Date >= PT.Planner_Start_Date
	              AND cm.Contract_End_Date   <= PT.Planner_End_Date) AS Program_Count,
	       PS.Status_Abbreviation,
	       ISNULL(rspUser.Name_First + ' ' + rspUser.Name_Last, '') AS RSP_User_Name,
	       ISNULL(rspUserPositions.Position_Label, ' ') AS RSP_Position,
	       ISNULL(l.Is_Locked, 0) AS Is_Locked,
	       ISNULL(luser.Name_First + ' ' + luser.Name_Last, '') AS Locked_By_User_Name,
	       ISNULL(l.Locked_By_User_Id, '') AS Locked_By_User_ID,
		   BSAFC.Name,
		   BSAFC.Shr_Ship_To
	  FROM Planners p
	 INNER JOIN Planner_Template PT
	    ON PT.Planner_Template_ID             = p.Planner_Template_ID
	 LEFT JOIN BSA_Foodservice_Customers BSAFC
	    ON BSAFC.BSA_Foodservice_Customers_ID = p.Customer_ID
	  LEFT JOIN Planner_Status PS
	    ON PS.Status_ID                       = p.Status_ID
	  LEFT JOIN User_Positions rspUserPositions
	    ON rspUserPositions.User_Positions_ID = p.Creator_Position_ID
	  LEFT JOIN _Users rspUser
	    ON rspUser.User_ID                    = p.RSP_ID
	  LEFT JOIN Lock l
	    ON l.Main_Id                          = 'Planner'
	   AND l.Secondary_ID                     = p.Planner_ID
	  LEFT JOIN _Users luser
	    ON l.Locked_By_User_Id                = luser.User_ID
	 WHERE p.Parent_Planner_ID = <cfqueryparam value=#form.parent_planner_id#>
	   AND p.Deleted           = 0
	 ORDER BY Planner_ID DESC;
</cfquery>

<!--- <cfdump var="#qPlanners#" abort="true"> --->

<cf_include files=#arrayToList( [ "/common_files/datatable2.css"
								 ,"/common_files/dataTables2.cfm"
								 ,"/common_files/dhx_message.cfm"
								 ,"/common_files/jQueryUI.cfm"
								 ,"/script/javascript/table2csv.js"
								 ,"/styles/css-loader.css"
								])#>



<cfset table_width = "100%">
<table class="dataTable row-border order-column hover" width="<cfoutput>#table_width#</cfoutput>">
	<thead>
		<tr>
			<th style="text-align:left;padding:8px 10px;cursor:pointer;"> <input type="checkbox" id="checkall"> </th>
			<th style="text-align:left"><cfoutput>#Application.PlannerLabel#</cfoutput> ID</th>
			<th style="text-align:left">Title [Customer]</th>
			<th><cfoutput>#Application.PlannerPrgLabel#</cfoutput> Count</th>
			<th>Status</th>
			<th style="text-align:left">RSP</th>
			<th style="text-align:left">RSP Position</th>
		</tr>
	</thead>
	<tbody>
	</tbody>
</table>

	<cfset data_set = []>
	<cfloop query="qPlanners">
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

 			input_type = "checkbox";

			arrayAppend(data_set, [	(qPlanners.is_locked && !local.lockedByCurrentUser)
										? ""
										: "<input type=#input_type# class=hand name=plnr value='#qPlanners.Planner_ID#'>",
									qPlanners.Planner_Number & ( qPlanners.is_locked
																	? " #locked_info#"
																	: "" ),
									qPlanners.Planner_Title,
									qPlanners.Program_Count,
									qPlanners.Status_Abbreviation,
									qPlanners.RSP_User_Name,
									qPlanners.RSP_Position,
									qPlanners.Planner_ID
								]);
 		</cfscript>
	</cfloop>

	<cfoutput>
	<form action="create_indirect.cfm" method="post" name="create_indirect">
		<input type="hidden" name="parent_planner_id" value="#form.parent_planner_id#">
		<input type="hidden" name="planner_template_id" value="#form.planner_template_id#">
		<input type="hidden" name="mode" value="#form.mode#">
	</form>
	<!--- #application.util.io.dumpToPage(form)# --->
	<cfsavecontent variable="actions"><a class='create primary'>#application.util.string.linkFormat( 'create ' & lcase(request.planner_labels.indirect_singular) & ' #Application.PlannerLabel#' )#</a><a id=delete class=secondary>#application.util.string.linkFormat( 'delete ' & lcase(request.planner_labels.indirect_singular) & ' planners' )#</a></cfsavecontent>
	<cfsavecontent variable="no_data">No #lcase(request.planner_labels.indirect_singular)# planners, yet.  Click <a class=create><b>'create #lcase(request.planner_labels.indirect_singular)# #Application.PlannerLabel#'</b></a> to add the first one to this #lcase(request.planner_labels.wholesaler_singular)# #Application.PlannerLabel#.</cfsavecontent>
	</cfoutput>

	<form name="load_planner" method="post">
		<input type="hidden" name="plannerID">
		<input type="hidden" name="mode">
		<input type="hidden" name="page_creating" value="1">
	</form>

	<script>
		var table = $("table.dataTable").DataTable({	data          : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
														dom           : "<'actions'>ti",
														columns       : [ 	{ sortable: false },
																			null,
																			null,
																			{ className: "dt-body-right" },
																			{ className: "dt-body-right" },
																			null,
																			null,
																			{ visible: false }
																		],
														language      : { emptyTable: <cfoutput>"#no_data#"</cfoutput> },
														order         : [ ],
														scrollY       : "69vh",
														scrollX       : true,
														scrollCollapse: true,
														paging        : false
													});
		$("div.actions").html( <cfoutput>"#actions#"</cfoutput> );

		//click planner
		$("table.dataTable tbody")
			.on( 'click', 'tr', function(evt) {
					var $cell = $(evt.target).closest('td'); // if not first cell then launch
					if ($cell.index() > 0){
						var pid = table.row(this).data()[7];
						var pstatus = table.row(this).data()[4];
						if (pid){
							show_loader("LOADING <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT>, PLEASE WAIT..");
							$("input[name=plannerID]").val( pid );
							$("input[name=mode]").val( 'E' );
							<!--- load calendar page when planner is WIP otherwise load scorecard page --->
							var planner_default_action = "/planners/create/" + ( pstatus == "WIP"
																					? "planner_calendar.cfm"
																					: "planner_scorecard.cfm"  );
							$("form[name=load_planner]").attr("action", planner_default_action).submit();
						}
					}
				})
			.on( 'hover', 'tr', function() { $(this).toggleClass("over2").toggleClass("hand"); }); // hover

		$("#checkall").click(function(e) {
			var checkall = $(this).prop("checked");
			$("input[type=checkbox]").prop("checked", checkall);
			e.stopPropagation();
		});

		$("a.create").click(function(){
			pageTitle( "Create " + <cfoutput>"#request.planner_labels.indirect_singular#" + " #Application.PlannerLabel#</cfoutput>" );
			show_loader();
			$("form[name=create_indirect]").submit();
		});

		//delete planners
		$('#delete').on( 'click', function () {
			var selected = [];
			$('tbody input:checkbox:checked').each(function() {
				selected.push($(this).val());
			});
			if ( selected.length == 0 ) {
				dhtmlx.alert( "Please select at least one <cfoutput>#Application.PlannerLabel#</cfoutput> to delete." );
				return false;
			};

			dhtmlx.confirm(selected.length + " selected <cfoutput>#Application.PlannerLabel#</cfoutput>" + (selected.length > 1 ? "s" : "")
								+ " will be deleted.<br><br>Do you wish to proceed?", function( proceed ) {
				if ( proceed ) {
					$.getJSON(
						'/mvc/Models/Planner/PlannerSearchManager.cfc',
						{
							method       : "deletePlanners",
							plannerList  : selected.join(","),
							returnformat : "json"
						},
						function(mydata) {
							jQuery('form[name=topnav]').attr("action", "/planners/create/planner_indirect.cfm").submit();
						}
					);
				};
			});
		});
	</script>
</cf_layout_planner>
