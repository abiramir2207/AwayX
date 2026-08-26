<!-----------------------------------------------------------------------------------------------------------------------------------------
	Name         :  AwayX/Planners/Create/program_volume_plan.cfm
	Created Date :  2016 Sep
	Created By   :  Chris Nguyen

	Parameters   :  programId = Contract_Main_ID
----------------------------------------------------------------------------------------------------------------------------------------->
 <cfsilent>
	<cfparam name="form.delivery_weeks_only" default=1>
	<cfquery name="qProgram" datasource="#application.datasource#">
		SELECT Contract_number, Contract_Title, ISNULL(Planner_ID, 0) AS Planner_ID
		  FROM Contract_Main
		  WHERE Contract_Main_ID = <cfqueryparam value="#form.programID#">
	</cfquery>
	<cfset form.plannerID = qProgram.Planner_ID>
	<cfinclude template="/planners/create/planner_volume_constants.cfm">
	<cfscript>
		udf = createObject( "component", "components.udf" );
		// retrieve previous selected forecasts for this planner
		saved_forecasts = udf.getUserData( search_column="Planner_ID", search_id=qProgram.planner_ID, template_name="volume_plan_config.cfm" );

		if ( saved_forecasts neq '' and isJSON( saved_forecasts ) ) {
			saved_forecasts = deserializeJSON( saved_forecasts );

			// restore previous saved forecasts
			if ( isDefined( "saved_forecasts.forecasts" ) ) {
				form.forecasts  = saved_forecasts.forecasts;
			}
			if ( isDefined( "saved_forecasts.show_base_lift" ) ) {
				form.show_base_lift = saved_forecasts.show_base_lift;
			}
		}
	</cfscript>
</cfsilent>

<!--- <cfdump var="#variables#"> --->

<!DOCTYPE html>
<html lang="en">
<head>
	<title><cfoutput>#qProgram.Contract_number#</cfoutput></title>
 	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <cfsavecontent variable="head_content">
		<cfset jQueryUI.widgets = "tooltip">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include file_to_include="/styles/ui.jqgrid.css, /script/javascript/jqGrid/grid.locale-en.js, /Script/javascript/jqGrid/grid.base.js, /Script/javascript/jqGrid/grid.filter.js, /Script/javascript/jqGrid/grid.formedit.js, /Script/javascript/jqGrid/grid.common.js, /script/javascript/numeral.min.js, /script/javascript/jquery.cfjs.min.js, /styles/css-loader.css"/>

		<style>
			#jqGridPager, th.ui-th-column {
								background-color: #9BC2E6 !important;
								background-image: -webkit-linear-gradient(#9BC2E6, #d8e7f5) !important;
								background-image: -o-linear-gradient(#9BC2E6, #d8e7f5) !important;
								background-image: linear-gradient(#9BC2E6, #d8e7f5) !important;
			}
			#jqGrid_frozen td, #jqGrid td { height:33px; vertical-align:middle; border:none; border-bottom: 1px dotted #CCC; }
			#jqGrid td { text-align:right; }
			th.ui-th-column { text-align: right !important; border:none !important; }
			.frozen-div th { text-align: left !important; }
			#jqGrid_frozen tr { background-color: #F0F0F0 !important; }
			td > input { height: 5px; line-height: 5px; vertical-align: middle; width:80%; }
			input::-ms-clear { display: none; }
			input.current { background-color:#FFFE9D; text-align: right; }
			input[type="checkbox"] {
				border-radius: 1px;
				border-width: 0;
				cursor: pointer;
				height: 10px;
				position: relative;
				transition: all .3s linear;
				width: 10px;
			}

			#t_jqGrid { text-align: center; }
				#t_jqGrid button { margin:3px 10px; font-weight: bold; letter-spacing: 0.25px; color:blue; height: 20px; background-color: white; }
			#t_jqGrid span.ui-button-text { padding:0px 20px; }
			tr.divider { border-bottom: 1px solid #A9A9A9 !important; }
			#delivery_weeks_only { letter-spacing2: 0.25px; margin-bottom: 6px; }
				#delivery_weeks_only a { margin:0 50px 0 0; }
			input.lfc { width: 75% !important; text-align: right; font-size: 10px !important; }
			.changed { background-color:#FFFE9D; }
			#t_jqGrid > a { margin:3px 15px; color: blue; }
			label { cursor: pointer; font-weight: bold; }
		</style>
	</cfsavecontent>
    <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
    <cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
	<!--- save data and bail out --->
	<cfif form.action eq "save">
		<cfscript>
			plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" );
			plannerManager.saveProgramVolume( form );
		</cfscript>
		<script>
			window.close();
		</script>
		<cfabort>
	</cfif>

	<!--- display and allow for editing --->
	<cfscript>
		numberFormat = ",";
		all_rows     = [];
		plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" );
		qWeeks         = plannerManager.getPlannerWeeks( 0, form.programID );
		qVolumes       = plannerManager.getProgramVolume( form.programID, form.product_list, form.product_list_type, form.forecasts, form.show_base_lift );
		qPlanner       = plannerManager.getPlanner( qProgram.Planner_ID );
		uom_abbr       = ( qPlanner.volume_plan_uom eq '2' ? "_LBS_" : "_CS_" );
	</cfscript>

	<!--- filter out delivery weeks --->
	<cfif form.delivery_weeks_only>
		<cfset period_ids = []>
		<!--- scanning thru all dates in the delivery date range to find the planner weeks that include the delivery dates --->
		<cfloop from="#form.delivery_start_date#" to="#form.delivery_end_date#" index="single_delivery_date" step="#CreateTimeSpan(1,0,0,0)#">
			<!--- search for planner weeks that cover the single delivery date and have not been selected --->
			<cfquery name="qWeeks2" dbtype="query">
				SELECT Period_ID
				  FROM qWeeks
				 WHERE (     '#single_delivery_date#' >= qWeeks.Planner_Week_Start_Date
				         AND '#single_delivery_date#' <= qWeeks.Planner_Week_End_Date  )
				 AND Period_ID NOT IN ( <cfloop array="#period_ids#" index="single_period">#single_period#,</cfloop> -1 )
			</cfquery>
			<!--- save the selected planner weeks into an array --->
			<cfloop query="qWeeks2">
				<cfset arrayAppend(period_ids, qWeeks2.Period_ID)>
			</cfloop>
		</cfloop>

		<!--- filter out planner weeks that do not cover the delivery dates --->
		<cfquery name="qWeeks" dbtype="query">
			SELECT *
			  FROM qWeeks
			 WHERE Period_ID IN ( <cfloop array="#period_ids#" index="single_period">#single_period#,</cfloop> -1 )
		</cfquery>
	</cfif>

	<cfoutput>
	<div class="h2">Program Volume Plan #(form.programID eq 0 ? "" : " - " & qProgram.Contract_number & " " & qProgram.Contract_Title)#</div>
    <!--- bring get_UOM() in from udf.cfc --->
    <cfset structAppend(url, createObject( "component", "components.udf" ))>
	<div id=delivery_weeks_only>
		<a id=save class="primary">#application.util.string.linkFormat('save')#</a> <a id=close class="secondary">#application.util.string.linkFormat('close window')#</a>
		<input type="checkbox" name="delivery_weeks_only" id="delivery_weeks_only_cb" <cfif form.delivery_weeks_only>checked</cfif>>
		<label for="delivery_weeks_only_cb">show delivery weeks only</label>
        <span style="color:red;margin-left: 50px;"><b style="color:##333">uom</b>: <b>#(qPlanner.volume_plan_uom eq '2' ? "#lCase(get_UOM( 2 ).Unit_Of_Measure_Desc)#" : "#lCase(get_UOM( 1 ).Unit_Of_Measure_Desc)#" )#</b></span>
	</div>

	<!--- page submitting form --->
	<form method="post" id="volume_plan">
		<input type="hidden" name="programID" value="#form.programID#">
		<input type="hidden" name="volume_plan_uom" value="#qPlanner.volume_plan_uom#">
		<input type="hidden" name="BSA_FoodService_Customers_ID" value="#qPlanner.BSA_FoodService_Customers_ID#">
		<input type="hidden" name="Product_List" value="#form.product_list#">
		<input type="hidden" name="Product_List_Type" value="#form.Product_List_Type#">
		<input type="hidden" name="delivery_start_date" value="#form.delivery_start_date#">
		<input type="hidden" name="delivery_end_date" value="#form.delivery_end_date#">
		<input type="hidden" name="plannerID" value="#qProgram.planner_ID#">
		<input type="hidden" name="action" value="save">
		<table id="jqGrid"></table>
		<div id="jqGridPager"></div>
	</form>

	<!--- page reloading form --->
	<form name="volume_plan_popup" method="post" onsubmit="popup_form(this, 'volume_plan_popup')">
		<input type="hidden" name="programID" value="#form.programID#">
		<input type="hidden" name="Product_List" id="product_list" value="#form.product_list#">
		<input type="hidden" name="Product_List_Type" value="#form.Product_List_Type#">
		<input type="hidden" name="delivery_start_date" value="#form.delivery_start_date#">
		<input type="hidden" name="delivery_end_date" value="#form.delivery_end_date#">
		<input type="hidden" name="action" value="show">
		<input type="hidden" name="delivery_weeks_only" value="#(form.delivery_weeks_only eq '1' ? 0 : 1)#">
	</form>
	</cfoutput>

	<!--- pull displaying data into all_rows array --->
	<cfset text_input = 0>

	<cfloop query="qVolumes">
		<cfscript>
			first_forecast = listFirst( form.forecasts );

			for ( forecast in form.forecasts ) {

				row_label     = '';
				prefix        = forecast;
				more_prefixes = [];
				more_labels   = [];

				if ( forecast eq constants.actual ) {
					prefix    = "Actual";
					row_label = "Actual";
				}
				else if ( forecast is constants.actual_percent_forecast ) {
					row_label = "Actual % FC";
				}
				else if ( forecast eq constants.aop ) {
					prefix    = "AOP";
					row_label = "AOP";
				}
				else if ( forecast eq constants.demand_plan ) {
					prefix    = "Demand_Plan";
					row_label = "Demand";
				}
				else if ( forecast eq constants.forecast_percent_prior_year ) {
					row_label = "FC % LY";
				}
				// Indirect Volume % FC
				else if ( forecast is constants.indirect_percent ) {
					row_label = "Indirect % FCST";
				}
				else if ( forecast eq constants.indirect_volume ) {
					prefix    = "Indirect";
					row_label = "Indirect Volume";
				}
				else if ( forecast is constants.latest_forecast ) {
					prefix    = "Forecast";
					row_label = "Latest FCST";

					// add additional rows to display
					if ( isDefined( "form.show_base_lift" ) and val( form.show_base_lift ) ) {
						more_prefixes = [ "Forecast_Base", "Forecast_Lift" ];
						more_labels   = [ "&nbsp; &rarr; Base", "&nbsp; &rarr; Lift" ];
					}
				}
				else if ( forecast eq constants.locked_forecast ) {
					prefix    = ( qPlanner.Approved ? "Locked" : "Forecast" );
					row_label = "Locked FCST";
				}
				else if ( forecast eq constants.prior_year ) {
					prefix    = "Prior_Year";
					row_label = "LY";
				}
				else if ( forecast eq constants.YTD ) {
					prefix    = "YTD";
					row_label = "YTD";
				}
				else {
					// unexpected forecast - skip it
					prefix = '';
				 	break;
				}

				// define storage for new row + additonal rows
				new_row   = [ ( forecast is first_forecast ? qVolumes.Group_ID & "<br>" & qVolumes.Description : '' ), row_label ];
				more_rows = more_prefixes.len() gt 0 ? arrayNew(  more_prefixes.len() ) : [ ];

				for ( i = 1; i lte more_prefixes.len(); i++ ) {
					more_rows[ i ] = [ '', more_labels[ i ] ];
				}

				for ( current_week = 1; current_week lte qWeeks.recordCount; current_week++ ) {

					uom_period   = uom_abbr & qWeeks.Period_ID[ current_week ];
					forecast_amt = qVolumes[ "Forecast" & uom_period ] [ qVolumes.currentRow ];

					if ( forecast is constants.latest_forecast ) {
						cell_value  = forecast_amt;
						ADL_Exclude = qVolumes[ 'ADL_Exclude_' & qWeeks.Period_ID[ current_week ] ] [ qVolumes.currentRow ];
						disabled    = ( now() gte qWeeks.Planner_Week_Start_Date[ current_week ] OR ADL_Exclude gt 0 ? "disabled" : "" );

						// keep track of # of text inputs for keeping the save option
						if ( disabled eq '' ) {
							text_input += 1;
						}

						new_row.append( "<input #disabled# type=text class=lfc prod=#qVolumes.currentRow# diff=0 name='i.#qVolumes.Item_Key#.#qWeeks.Period_ID[ current_week ]#' value='#numberFormat(cell_value, numberFormat)#'>" );
					}
					else {
						// -------------------------------------- //
						// calculate on-the-fly percentage values //
						// -------------------------------------- //
						if ( prefix is constants.forecast_percent_prior_year ) {
							prior_year  = qVolumes[ "Prior_Year" & uom_period ] [ qVolumes.currentRow ];
							cell_value = ( val( prior_year ) eq 0
												? 0
												: val( forecast_amt ) / val( prior_year ) * 100 );
						}
						else if ( prefix is constants.actual_percent_forecast ) {
							actual     = qVolumes[ "Actual" & uom_period ] [ qVolumes.currentRow ];
							cell_value = ( val( forecast_amt ) eq 0
												? 0
												: val( actual ) / val( forecast_amt ) * 100 );
						}
						else if ( prefix is constants.indirect_percent ) {
							indirect_amt = qVolumes[ "Indirect" & uom_period ] [ qVolumes.currentRow ];
							cell_value   = ( val( forecast_amt ) eq 0
												? 0
												: val( indirect_amt ) / val( forecast_amt ) * 100 );
						}
						else {
							cell_value = qVolumes[ prefix & uom_period ] [ qVolumes.currentRow ];
						}

						new_row.append( numberFormat( cell_value, numberFormat ) );
					}

					// gather data for addtional rows
					for ( i = 1; i lte more_prefixes.len(); i++ ) {
						cell_value = qVolumes[ more_prefixes[ i ] & uom_period ] [ qVolumes.currentRow ];
						more_rows[ i ].append( numberFormat( cell_value, numberFormat ) );
					}
				}

				new_row.append( qVolumes.Item_Key );
				all_rows.append( new_row );

				// add additional rows to display
				for ( i = 1; i lte more_prefixes.len(); i++ ) {
					more_rows[ i ].append( qVolumes.Item_Key );
					all_rows.append( more_rows[ i ] );
				}
			}
		</cfscript>
	</cfloop>

	<script type="text/javascript">
		(function($){

			<cfif text_input eq 0>
				// remove save option when # of text inputs is zero
				$( "#save" ).remove();
			</cfif>

			numeral.defaultFormat( '(0,0)' );     <!--- default to integer format --->

			$.fn.forceNumeric = function () {
				return this.each(function () {
				$(this).keydown(function (e) {
					var key = e.which || e.keyCode;
					/* navigate to the next forecast input on enter key */
					if (key == 13) {
						/* $(':input.lfc:eq(' + ($(':input.lfc').index(this) + 1) + ')').focus(); */
						return false;
					}
					if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
					 ( key >= 48 && key <= 57 ) ||    <!---numbers--->
					 ( key >= 96 && key <= 105 ) ||   <!---Numeric keypad--->
					 key == 190 || key == 188 || key == 109 ||  key == 189 || <!---comma, period and minus--->
					 key == 8 || key == 9 || key == 13 ||  <!---Backspace and Tab and Enter--->
					 key == 35 || key == 36 ||             <!---Home and End--->
					 ( key >= 37 && key <= 40 ) ||         <!---left, up and right, down arrows--->
					 key == 110 ||                         <!---Decimal point on numeric keypad--->
					 key == 46 || key == 45) {             <!---Del and Ins--->
					  return true;
					}
					return false;
				});
			 });
			}
		})(jQuery);

		var grid = $("#jqGrid");
		grid.jqGrid( {
            cmTemplate: { sortable:false, resizable:false, search:false, title:false },
			colModel: [
				{ label:'Product', name:'Product', width: 200, frozen:true },
				{ label:' ', name:'FC', width: 100, frozen:true },
				<cfoutput query="qWeeks"> { label:'#dateFormat( qWeeks.Planner_Week_Start_Date, "m/d" )#', name:'Week', width: 100, frozen:false }, </cfoutput>
				{ label:'ID', name:'Item_Key', hidden:true }
			],
			datastr:<cfoutput>#SerializeJSON({ ROWS=all_rows })#</cfoutput>,
			datatype: "jsonstring",
			height: $(window).height() - 100,
			loadonce: true,
			jsonReader: { cell:"", id:"", page:"", records:"", root:"ROWS", total:"" },
			rowNum: 9999,
			shrinkToFit: false,  /* must be set with frozen columns, otherwise columns will be shrank to fit the grid width */
			viewrecords: false, // show the current page, data rang and total records on the toolbar
			viewsortcols : [ true, 'vertical', true ],
			width: $(window).width() - 18
		} );
		grid.jqGrid("setFrozenColumns");

		$("a#close").click(function(){ window.close(); });
		$("a#save").click(function(){
			show_loader("PROCESSING PLEASE WAIT...");

			/* updating volumes in parent page */
			var processed = [];
			//$("input.lfc[diff=1]").each(function(){
			$("input.lfc").each(function(){
				var prod_attr = $(this).attr("prod");

				/* if this product is not processed */
				if ( processed.indexOf( prod_attr ) == -1 ) {
					/* insert it into processed array */
					processed.push( prod_attr );

					var fc_sum = 0
						,prod_attr = "[prod=" + prod_attr + "]"
						,input_name = $(this).attr("name")
						,prod_id = $.ListGetAt(input_name, 2, '.');

					/* sum up total on each product */
					$("input" + prod_attr).each(function(){
						fc_sum += $(this).val().replace(/,/g, "");
					});

					/* repopulate volumes on parent page */
					$("input[name='vol." + prod_id + "']", opener.document).val( numeral( fc_sum ).format() );
				}
			});

			/* remove unchanged inputs to save time */
			$("input.lfc[diff='0']").attr("name", "");
			var parentForm = opener.document.getElementById("MyForm");
			$("input[name='bSave']", opener.document).val(1);
			parentForm.submit();
			$("#volume_plan").submit();
		});

		$("input.lfc")
			.forceNumeric()
			.focus(function() { $(this).addClass("hilight").select(); })
			.blur(function() { $(this).removeClass("hilight"); })
			.change(function() {
				$(this).attr("diff", 1).addClass( "changed" ).val( numeral( $(this).val() ).format() );
			});    /* change() */

		$("input[name=delivery_weeks_only]").change(function() {
			if ( ignore_changes() ) {
    			$("form[name=volume_plan_popup]").submit();
			}
			else {
				$(this).attr("checked", true);
			}
		});

		function ignore_changes() {
			/* no changes made? */
			if ( $("input[diff='1']").length == 0 ) {
				return true;
			}
			/* ignore changes made? */
			else if ( confirm("You have made changes that are not saved.\n\nClick Cancel to return to save your changes.\nClick OK to ignore your changes and continue.") ) {
				return true;
			}
			return false;
		};
 	</script>
	<cfinclude template="/common_files/focus.cfm">

</body>
</html>

