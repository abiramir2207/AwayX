<!----------------------------------------------------------------------------------------------------
	  Template:  planners/consumer_events/events/calendar.cfm
		  Date:  2017 December
		Author:  Kal
	   Purpose:  This page lists consumer events in calendar view
------------------------------------------------------------------------------------------------------>

<cfset request.script_name = "/planners/consumer_events/events/">
<cfparam name="url.fromPlanner"      default="0" />
<cfparam name="form.fiscalYear"      default="0" />
<cfparam name="form.fiscalStartDate" default="0" />
<cfparam name="form.fiscalEndDate"   default="0" />

<cfif url.fromPlanner eq 0>
	<cf_layout_planner_event>
	</cf_layout_planner_event>
<cfelse>
	<!DOCTYPE html>
</cfif>

<!----------------->
<!---  queries  --->
<!------------------------------------------------------------------------------------------------------------------------->
<cfscript>
	queries                       = {};
	vars                          = {};

	vars.cf_date_format           = "m/d/yyyy";
	vars.weeks_per_view           = 26;

	labelManager                  = createObject( "component", "components.settings.Labels.Labels" ).init();
	vars.product_label            = ( application.appSettingsGet.get_Setting('Retail_Consumer_Events_Group') eq ""
									? application.returned_customer_setting.item_label
									: labelManager.getProductLabelByGroupLevelID( application.appSettingsGet.get_Setting('Retail_Consumer_Events_Group') ) );

	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}

	queries.eventTypes            = request.planner_event_obj.getEventTypes();
	queries.allFiscalYears        = request.planner_event_obj.getFiscalYear();

	if (form.fiscalYear eq 0) {
		queries.fiscalYear   	  = request.planner_event_obj.getFiscalYear( fiscalYear = "", fiscalDate = now() );
		form.fiscalYear      	  = queries.fiscalYear.fiscal_year;
		form.fiscalStartDate 	  = queries.fiscalYear.start_date;
		form.fiscalEndDate   	  = queries.fiscalYear.end_date;
	}

	queries.productGroups         = request.planner_event_obj.getEventsCalendarProducts( form.fiscalYear, application.appSettingsGet.get_Setting('Retail_Consumer_Events_Group') );
	queries.eventsCalendar        = request.planner_event_obj.getEventsCalendar( form.fiscalYear,  application.appSettingsGet.get_Setting('Retail_Consumer_Events_Group') );
	// weeks in the fiscal year
	vars.totalWeeks               = DateDiff("w", form.fiscalStartDate, form.fiscalEndDate)+1;
</cfscript>

<!--- create event type classes and use a 'event_type_' prefix --->
<style>
<cfoutput query="queries.eventTypes">
 <cfset event_type_color = replace( color, "##", "", "all" )>
 .event_type_#planner_event_type_id# {
	color: #application.util.string.foregroundColor( event_type_color )#;
	background-color: ###event_type_color#;
	font-style: normal;
 }
</cfoutput>
</style>

<cfset include_files = [     "/script/javascript/dhtmlx/scheduler/codebase/dhtmlxscheduler.js"
							,"/script/javascript/dhtmlx/scheduler/codebase/ext/dhtmlxscheduler_collision.js"
							,"/script/javascript/dhtmlx/scheduler/codebase/ext/dhtmlxscheduler_multisection.js"
							,"/script/javascript/dhtmlx/scheduler/codebase/ext/dhtmlxscheduler_multiselect.js"
							,"/script/javascript/dhtmlx/scheduler/codebase/ext/dhtmlxscheduler_timeline.js"
							,"/script/javascript/dhtmlx/scheduler/codebase/ext/dhtmlxscheduler_tooltip.js"
							,"/script/javascript/dhx_message.js"
							,"/script/javascript/numeral.min.js"
							,"/script/javascript/moment.min.js"
							,"/script/javascript/jquery.numeric.min.js"
							,"/script/javascript/dhtmlx/scheduler/codebase/dhtmlxscheduler_flat.css"
							,"/styles/css-loader.css"
							,"/script/javascript/jquery.noty.packaged.min.js"
							,"/common_files/dhx_windows.cfm"
						]>
<cf_include files=#arrayToList( include_files )#>

<style type="text/css">
	html,body{margin:0;padding:0;height:100%;width:100%;overflow:hidden}
	#timeline_header{height:26px}
	.dhx_cal_navline .dhx_cal_date,.dhx_cal_navline .dhx_cal_today_button{display:none}
	.dhx_cal_data label{cursor:pointer}
	.dhx_cal_event_line{padding-left:1px;padding-right:9px}
	.dhx_cal_navline .section_header{border:0;color:#454544;font-weight:400;font-size:14px;text-align:center;top:2px;position:absolute;left:0;width:100%;z-index:-1}
	i.prod,a.prod{display:inline-block;cursor:pointer;font-style:normal;opacity:.75;padding-left:8px;padding-top:2px}
	i.tip{color:#000;display:inline-block;font-style:normal;font-weight:400;margin-right:10px;text-align:right;width:105px}
	i.tip:after{content:": "}
	.inactive{color:red;font-style:normal;font-weight:700;}
	.inactive:after{content:" "}
	select{margin:2px;padding-left:5px;width:250px;}
	<cfif vars.totalWeeks gte vars.weeks_per_view>
	div.dhx_scale_bar { font-size: 11px !important; line-height: 14px; }
	</cfif>
</style>

<!----------------------->
<!---  timeline body  --->
<!------------------------------------------------------------------------------------------------------------------------->
<body>
	<form name="event_calendar" method="post">
		<input type=hidden name=fiscalYear      value="#form.fiscalYear#">
		<input type=hidden name=fiscalStartDate value="#form.fiscalStartDate#">
		<input type=hidden name=fiscalEndDate   value="#form.fiscalEndDate#">
	</form>
	<div class="dhx_cal_container" id="timeline_body" style="width:100%; height:95%">
		<div class="dhx_cal_navline" style="background-color:white;">
			<div class="dhx_cal_prev_button">&nbsp;</div>
			<div class="dhx_cal_next_button">&nbsp;</div>
			<div class="section_header">
				<label>Fiscal Year: </label>
				<select name="fiscalYear" id="fiscalYear" class="input_textbox_input" >
					<cfoutput query="queries.allFiscalYears">
					<option
						value="#Fiscal_Year#"
						data-start="#dateformat(start_date, vars.cf_date_format)#"
						data-end="#dateformat(end_date, vars.cf_date_format)#"
						<cfif form.fiscalYear eq Fiscal_Year > selected </cfif>
						> #Fiscal_Year#
						( #dateformat(start_date, vars.cf_date_format)# - #dateformat(end_date, vars.cf_date_format)# )
					</option>
					</cfoutput>
				</select>
			</div>
			<div class="dhx_cal_date"></div>
		</div>
		<div class="dhx_cal_header"></div>
		<div class="dhx_cal_data"></div>
	</div>
</body>

<script type="text/javascript">
	<!------------------->
	<!---  constants  --->
	<!--------------------------------------------------------------------------------------------------------------------->
	var currency_with_decimal    = "$0,.00";
	var currency_without_decimal = "$0,";
	var integer_format           = "0,";
	var percent_format           = '0,%';
	var moment_format            = "MM/DD/YYYY";

	<!------------------------>
	<!---  configurations  --->
	<!--------------------------------------------------------------------------------------------------------------------->

	// turn off dragging, copying, pasting
	dhtmlx.message.position                 = "bottom";
	scheduler.config.collision_limit        = 99;
	scheduler.config.dblclick_create        = false;
	scheduler.config.details_on_dblclick    = false;
	scheduler.config.drag_create            = false;
	scheduler.config.drag_in                = false;
	scheduler.config.drag_move              = true;
	scheduler.config.drag_out               = false;
	scheduler.config.drag_resize            = false;
	scheduler.config.edit_on_create         = false;
	scheduler.config.multisection           = false;
	scheduler.config.multisection_shift_all = false;
	scheduler.config.show_loading           = true;
	scheduler.config.xml_date               = "%n/%j/%Y";    // date format specified in programs array
	scheduler.xy.nav_height                 = 30;            // hide entire navigation header

	<!--------------------------->
	<!---  timeline creation  --->
	<!--------------------------------------------------------------------------------------------------------------------->
	<cfsavecontent variable="vars.y_unit">
		<cfoutput query="queries.productGroups">

			<cfif queries.productGroups.currentRow gt 1>
				,
			</cfif>
			{   key:"#product_guid#"
				,label:"<cfif Active_Code eq "N"><i class='inactive' title='In-Active #vars.product_label#'>&##1138;</i></cfif>#product_number#
					<cfif product_guid eq "00000000-0000-0000-0000-000000000000">
						<i class='prod'>All #vars.product_label#</i>
					<cfelse>
						<br/><a class='prod'
							onclick='view_members( &quot;#product_guid#&quot;, &quot;#product_group_level_id#&quot; )'
							title='click to view members'>#product_desc#
						</a>
					</cfif>"
			}
		</cfoutput>
	</cfsavecontent>

	scheduler.createTimelineView( {
									name: "timeline",
									render: "bar",
									round_position: true,
									x_date: <cfif vars.totalWeeks gte vars.weeks_per_view > "%M<br>%j" <cfelse> "%M %j" </cfif>,
									x_length: 4,
									x_size: <cfoutput>#min(vars.weeks_per_view, vars.totalWeeks)#</cfoutput>, 			// number of columns to display
									x_start: 0,
									x_step: 7,              // next value: x_unit = week, then 1; day then 7
									x_unit: "day",
									y_property: "product_guid",
									dx: 200,                // first column width in pixels
									section_autoheight : false,
									y_unit: [ <cfoutput>#application.util.string.compress( vars.y_unit )#</cfoutput> ]
								});

	<!------------------------------->
	<!---  initialize, load data  --->
	<!--------------------------------------------------------------------------------------------------------------------->
	scheduler.init( "timeline_body",
					new Date( <cfoutput>"#dateFormat(form.fiscalStartDate, vars.cf_date_format )#"</cfoutput> ),
					"timeline" );
	scheduler.parse( <cfoutput>#serializeJSON( queries.eventsCalendar )#</cfoutput>, "json" );


	<!------------------------------->
	<!---  event handlers  --->
	<!--------------------------------------------------------------------------------------------------------------------->
	<cfoutput>
		var min_date = new Date( "#dateformat(form.fiscalStartDate, vars.cf_date_format)#" );
		var max_date = new Date( moment("#dateformat(form.fiscalEndDate, vars.cf_date_format)#").subtract(6, 'days') );
		var last_starting_date = new Date( moment(max_date).subtract( #min( vars.weeks_per_view, vars.totalWeeks )-1#,'w' ) );
	</cfoutput>

	scheduler.attachEvent("onBeforeViewChange", function(old_mode, old_start_date, new_mode, new_start_date) {
		// do not go beyond first date and last date
		var new_ending_date = moment( new_start_date ).add(<cfoutput>#(min(vars.weeks_per_view, vars.totalWeeks) - 1)#</cfoutput>, 'w');

		// try to go beyond last page - starts from last starting date
		if ( new_ending_date > moment( max_date ) ) {
			scheduler.setCurrentView( last_starting_date );
			return false;
		}
		// try to go beyond first page - starts from mininum date
		if ( new_start_date < moment( min_date ) ) {
			scheduler.setCurrentView( min_date );
			return false;
		}
		return true;
	});

	// multiple pages exist - control prev/next button display conditionally
	scheduler.attachEvent("onViewChange", function (new_mode , new_start_date) {
		var new_ending_date = moment( new_start_date ).add(<cfoutput>#(min(vars.weeks_per_view, vars.totalWeeks) - 1)#</cfoutput>, 'w');
		// disable next button when it is beyond the last date
		$("div.dhx_cal_next_button").css( "opacity", moment( new_ending_date ) >= moment( max_date )
															? "0.2"
															: "1" );
		// disable prev button when it is beyond the first date
		$("div.dhx_cal_prev_button").css( "opacity", moment( new_start_date ) <= moment( min_date )
															? "0.2"
															: "1" );
	});

	// disable edit on double click
	scheduler.attachEvent("onDblClick", function(){ return false });

	// text to display on event
	scheduler.templates.event_bar_text = function( start, end, event ) {
		return event.text;
	};

	scheduler.templates.tooltip_text = function( start_date, end_date, current_event ) {
		return  "<i class=tip>Event Type</i>" + "<i class='event_type_" + current_event.planner_event_type_id + "'> " + current_event.type + "&nbsp;</i>"
				+ "<br>" + "<i class=tip>Event Title</i>" + current_event.event_title
				+ "<br>" + "<i class=tip>Fiscal Year</i>" + current_event.fiscal_year
				+ "<br>" + "<i class=tip>Event Dates</i>" + moment( current_event.start_date ).format( moment_format ) + " - " + moment( current_event.end_date ).format( moment_format )
				+ "<br>" + "<i class=tip>Discount</i>" + current_event.discount_info ;
	}

	// Submit & Refresh data on Fiscal Yr change.
	$("#fiscalYear").change(function() {
		var fy = $("select[name=fiscalYear] option:selected").val();
		var sDate = $("select[name=fiscalYear] option:selected").attr("data-start");
		var eDate = $("select[name=fiscalYear] option:selected").attr("data-end");

		$("input[name=fiscalYear]").val(fy);
		$("input[name=fiscalStartDate]").val(sDate);
		$("input[name=fiscalEndDate]").val(eDate);
		$("form[name=event_calendar]").submit();
	 });

	<!--------------------->
	<!---  dhx windows  --->
	<!--------------------------------------------------------------------------------------------------------------------->
	function view_members( group_id, group_level_id ){
		dhx_popupInCenter( "/Common_Files/contracts/Groups/group_items.cfm"
										+ "?Group_ID=" + group_id
										+ "&Group_Level_ID=" + group_level_id
										,"Group Items"
										,600
										,715
									);
	}

	// add header to top top first row
	(function () {
		var top               = scheduler.xy.nav_height + 1 + 1;// first +1 -- blank space upper border, second +1 -- hardcoded border length
		var height            = scheduler.xy.scale_height;
		var width             = scheduler.matrix.timeline.dx;

		var header            = document.createElement("div");
		header.style.cssText  = "position:absolute; z-index:99999; font-size:12px; margin:10px 0 0 20px;"
								+ "top:" + top + "px;"
								+ "width:" + width + "px;"
								+ "height:" + height + "px;"
		header.innerHTML 	  = <cfoutput>"<div class='Title7'>#vars.product_label#</div>"</cfoutput>;

		var element = document.getElementById("timeline_body");
		element.appendChild(header);
	})();


</script>