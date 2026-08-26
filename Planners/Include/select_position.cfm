<!-----------------------------------------------------------------------------------------------------------------------------------------
Name         :  /planners/include/search_position.cfm
Created Date :  2017 July
Created By   :  Chris Nguyen
Description  :  Display search positions result and allow a selection

Remarks      :
----------------------------------------------------------------------------------------------------------------------------------------->
<style>
	td.hand {
		cursor: pointer;
	}
	div.actions a {
		margin: 0 50px;
		position: relative;
		top: -2px;
	}
</style>

<cfscript>
	param name="form.parent_action"     default="reassign";
	param name="form.position_select_type"     default="";

	param name="form.service_zone_id"   default="";
	param name="form.service_region_id" default="";
	param name="form.service_market_id" default="";
	param name="form.search_level"      default=-1;
	param name="form.user_positions_id" default="";
	param name="form.label"             default="";
	param name="form.include_deleted"   default="0";
	param name="form.chosen_position_id"   default="";

	ignore_deleted = (form.include_deleted eq "1");

	oPosition = createObject("component", "components.geography.position").init();
	qPositions = oPosition.getPositions(ignoreDeletedFlag = ignore_deleted);

	ListOfPositionsUnderSearchPosition = "";
	
	if(form.parent_action eq "reassign"){
		form.position_select_type = "radio";
	}
</cfscript>

<cfif form.user_positions_id neq "">
	<cfset GP_Supplied_Position = form.user_positions_id>
	<cfset getIDList = 1>
	<cfinclude template="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
	<!--- list of positions underneath supplied --->
	<cfset ListOfPositionsUnderSearchPosition = GP_Position_List_From_My_Position_Down>	
</cfif>

<cfquery name="qqPositions" dbtype="query">
	SELECT Position_Label,
			User_Positions_ID,
			Zone_Name,
			Region_Name,
			Market_Name,
			Deleted
	  FROM qPositions
	 WHERE 1 = 1
			<cfif form.service_zone_id neq "">
				AND (service_zone_id IN (<cfqueryparam value="#form.service_zone_id#" cfsqltype="CF_SQL_VARCHAR" list="Yes">))
			</cfif>
			<cfif form.service_region_id neq "">
				AND (service_region_id IN (<cfqueryparam value="#form.service_region_id#" cfsqltype="CF_SQL_VARCHAR" list="Yes">))
			</cfif>
			<cfif form.service_market_id neq "">
				AND (service_market_id IN (<cfqueryparam value="#form.service_market_id#" cfsqltype="CF_SQL_INTEGER" list="Yes">))
			</cfif>
			<cfif form.label neq "">
				AND UPPER(Position_Label) LIKE '%#ucase(form.label)#%'
			</cfif>
			<cfif ListOfPositionsUnderSearchPosition neq "">
				AND User_Positions_ID IN (#ListOfPositionsUnderSearchPosition#)
			</cfif>
			<cfif len(form.search_level) and form.search_level neq "-1">
                AND (Position_Level IN (<cfqueryparam value="#form.search_level#" cfsqltype="CF_SQL_INTEGER" list="Yes">))
			</cfif>
</cfquery>

<form name="select_position" id="select_position" method="post">
	<cfset saveHiddenValues()>

	<cfset jQueryUI.widgets = "tooltip">
	<cf_include files="/common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm, /common_files/jQueryUI.cfm">

	<cfoutput>
	<div style="width:90%;margin:0 auto;float:left;">
		<table class="dataTable row-border order-column hover" width="100%">
			<thead>
				<tr>
					<!-- 1 --> 	<th style="text-align:left"><cfif form.position_select_type eq "checkbox">
									<input type="checkbox" id="checkall">
									</cfif>
								</th>
					<!-- 2 --> <th style="text-align:left">Label</th>
					<!-- 4 --> <th  style="text-align:left">#application.returned_customer_setting.zone_label_singular#</th>
					<!-- 3 --> <th  style="text-align:left">#application.returned_customer_setting.region_label_singular#</th>
					<!-- 5 --> <th  style="text-align:left">#application.returned_customer_setting.market_label_singular#</th>
				</tr>
			</thead>
		</table>
	</div>

	<cfset dataset = []>
	<cfloop query="qqPositions" startrow="1" endrow="2000">
		<cfset isChecked = "" />		
		<cfif ListFind(form.chosen_position_id, qqPositions.user_positions_id)>
			<cfset isChecked = " checked" />
		</cfif>
 		<cfscript>
			arrayAppend(dataset, [	( form.position_select_type neq ""
										? "<input type=#form.position_select_type# name=selected_position class=hand value='#qqPositions.user_positions_id#' #isChecked#>" 
										: "" ),
									qqPositions.Position_Label,
									qqPositions.Zone_Name,
									qqPositions.Region_Name,
									qqPositions.Market_Name
								]);
 		</cfscript>
	</cfloop>
	
	<div style="clear:both;"></div>

	<cfset actions = "">
	<cfif form.position_select_type neq "">
		<cfsavecontent variable="actions"><a href='##' id='choose'>#application.util.string.linkFormat("choose selected position" & (form.position_select_type eq "checkbox" ? "(s)" : "" ))#</a></cfsavecontent>
	</cfif>
	</cfoutput>

	<script>
		var data_table = $("table.dataTable").DataTable({	data: <cfoutput>#serializeJSON( dataset )#</cfoutput>,
															dom: "f<'actions'>ti",
															columns: [
																		/* 1 */ { orderable: false, className: "hand", width: "50px" },
																		/* 2 */ {},
																		/* 3 */ {},
																		/* 4 */ {},
																		/* 5 */ {}
																	],
															order: [ [1, "asc"] ],
															scrollY:        "60vh",
															scrollCollapse: true,
															paging:         false        
		});
		$("div.actions").html( <cfoutput>"#actions#"</cfoutput> );

		$("tr td:nth-child(1)").click(function() {
			var checkbox = $(this).find("input[type=radio]");
			checkbox.prop("checked", !checkbox.prop("checked"));
		});

		$("input.hand").click(function(e) {
			e.stopPropagation();
		});

		$("*[title]").tooltip();

		$("#choose").click(function() {
			var selected = [];
			var position_label = "";
			data_table.$("input.hand:checked").each(function() {
				selected.push( $(this).val() );
				position_label = $(this).closest("td").next("td").text();
			});
			if ( selected.length == 0 ) {
				dhx_alert( "Please select a position." );
				return false;
			};
			$("input[name=chosen_position_id]").val( selected.join(",") );
			$("input[name=chosen_position_name]").val( position_label );
			$("#select_position").submit();
		});
		
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
	</script>

</form>
