<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Create/planner_calendar.cfm
	Created Date:  2017 May
	  Created By:  Chris Nguyen
	 Description:  Displays a planner calendar with dragging, resizing support
------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>
	<cfparam name="form.filter_product_group_level_id" default="">
	<cfparam name="form.filter_product_list"           default="">
	<cfparam name="form.calendar_init_date"            default="">

	<cfinclude template="/planners/create/planner_volume_constants.cfm">

	<!----------------->
	<!---  queries  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<cfscript>

		queries                 = {};
		vars                    = {};

		vars.cf_date_format     = "m/d/yyyy";
		weeks_per_view			= 26;

		if ( structKeyExists(form, "page_creating") eq false ) {
			if (form.action eq "save_volume") {
			}
			else if (form.action eq "filter_products") {
			}
			else if (form.action eq "delete_products") {
				request.components.planner.deletePlannerProducts( form );
			}
		}

		queries.perf_types             = request.components.planner.getPlannerProfile( form.plannerID );
		queries.products               = request.components.planner.getPlannerProducts( form.plannerID, form.product_group_level_id,
																					"timeline", form.filter_product_group_level_id, form.filter_product_list );

		request.components.datamanager = createObject( "component", "components.products.Group.DataManager" );
		queries.product_groups         = request.components.datamanager.getProductGroupsData();
		queries.periods                = form.period eq constants.by_week
										? request.components.planner.getPlannerWeeks( request.plannerID )
										: request.components.planner.getPlannerMonths( request.plannerID );

		queries.calendar_info          = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager").getPlannerCalendarConfig(id=form.planner_template_id, selected=1);
		queries.product_filters        = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager").getPlannerFilters(form.planner_template_id, 1, 1);
		vars.lProductFilters           = valueList(queries.product_filters.Group_Level_ID);

		oProfiles                      = CreateObject("component","components.settings.profiles.profile");
		getProfileSettings             = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID);

		// set the initial start date for the calendar
		if (form.calendar_init_date eq "") form.calendar_init_date = queries.periods.planner_week_start_date;

        userManager = CreateObject("component", "components.user.UserManager");
        createProgramAccess = getProfileSettings.Cont_Prog_View_Create_Program eq 1 and (application.appsettingsget.userNumberRestrict EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.user_id) EQ 1);
	</cfscript>

	<!------------------------------------------------------------->
	<!---  store body content in a variable to compress later   --->
	<!------------------------------------------------------------------------------------------------------------------------->
    <cfsavecontent variable="vars.body_content">

    <cfset scheduler_version = "5.3.9">
	<cfset include_files = [     "/script/javascript/dhtmlx/scheduler/#scheduler_version#/dhtmlxscheduler.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/ext/dhtmlxscheduler_collision.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/ext/dhtmlxscheduler_multisection.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/ext/dhtmlxscheduler_key_nav.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/ext/dhtmlxscheduler_multiselect.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/ext/dhtmlxscheduler_timeline.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/ext/dhtmlxscheduler_tooltip.js"
								,"/script/javascript/dhx_message.js"
								,"/script/javascript/numeral.min.js"
								,"/script/javascript/moment.min.js"
								,"/script/javascript/jquery.numeric.min.js"
								,"/script/javascript/dhtmlx/scheduler/#scheduler_version#/dhtmlxscheduler_flat.css"
								,"/styles/css-loader.css"
								,"/script/javascript/jquery.noty.packaged.min.js"
								,"/common_files/dhx_windows.cfm"
							]>
	<cf_include files=#arrayToList( include_files )#>

	<!------------------------------------------------------------------------------------------------------------------------->

	<style>
		body{overflow:hidden}
		#timeline_header{height:26px}
		select[name="filter_product_group_level_id"]{background-color:#FFFE9D}
		#timeline_actions{float:left;}
		#timeline_actions > a {margin-right:5px}
		i.legend{font-size:10px;font-style:normal;font-weight:400;letter-spacing:.35px;margin-top2:10px}
		span.legend{-ms-filter:progid:DXImageTransform.Microsoft.Alpha(Opacity=85);color:#333;display:inline-block;font-size:10px;letter-spacing:.35px;margin:5px;opacity:.85;padding:5px;text-align:center;width:100px}
		span.uom{border:1px solid #CCC;margin-left:30px}
		i.uom_label{color:#000;font-style:normal;font-weight:700}
		i.uom_value{font-style:normal;font-weight:400}
		.dhx_cal_navline .dhx_cal_date,.dhx_cal_navline .dhx_cal_today_button{display:none}
		<cfif queries.periods.recordCount lte weeks_per_view>
		.dhx_cal_prev_button, .dhx_cal_next_button { opacity: 0; }
		</cfif>
		.dhx_cal_event_line{padding-left:1px;padding-right:9px}
		.dhx_cal_data label{cursor:pointer}
		i.prod,a.prod{cursor:pointer;font-style:normal;opacity:.75;}
		i.tip{color:#000;display:inline-block;font-style:normal;font-weight:400;margin-right:10px;text-align:right;width:105px}
		i.tip:after{content:": "}
		i.detail{color:#000;display:inline-block;font-style:normal;text-align:center;width:100%}
		.inactive{color:red;font-style:normal;font-weight:700;}
		.inactive:after{content:" "}
		<cfif queries.periods.recordCount gt weeks_per_view>
		div.dhx_scale_bar { font-size: 11px !important; line-height: 14px; }
		</cfif>
		/* on copy change border*/
		.copied_event { box-sizing: border-box; border: 1px solid gray !important; }
		/* create perform type classes and use a 'perf_type_' prefix */
		<cfoutput query="queries.perf_types">
			<cfset perf_color = replace( queries.perf_types.color, "##", "", "all" )>
			.perf_type_#queries.perf_types.planner_perf_types_id# {
				/* determine foreground color automatically based on background color */
				color: #application.util.string.foregroundColor( perf_color )#;
				background-color: ###perf_color#;
				font-style: normal;
			}
		</cfoutput>
		.ui-state-hover {
			background:#e6bf9b !important;
		}
		#quick_add{background-color:#fff;border:2px outset gray;display:none;left:200px;padding:20px;position:absolute;top:100px;z-index:10001}
		#quick_add label{color:#333;display:inline-block;font-weight:700;margin:6px 16px}
		#quick_add label:first-child{margin-left:0}
		#quick_add a{margin-right:25px}
		.perf_type{display:inline-block;cursor:pointer;padding:7px 7px 7px 0;margin-right:4px}
		input[type="radio"]{vertical-align:-2px}
		#perf_types{margin:10px 0}
		input[type="checkbox"]{box-sizing:content-box;cursor:pointer;height:1em;position:relative;top:1px;left2:-2px;width:1em}
		div.check_all{padding-left:5px;padding-top:6px}
		.ui-tooltip{z-index:11000}
		.wait{letter-spacing:.85px;font-weight:700}
        a.prod {
            display: inline;
            padding-left: 0;
        }
        div.dhx_matrix_scell {
            background-color: #EDEEF2;
            text-align: left;
			line-height: normal;
            white-space: normal;
			overflow: visible !important;
			padding: 3px 5px;
        }
        .dhx_timeline_scale_header, .dhx_scale_bar {
            background-color: #EDEEF2;
        }
        .dhx_cal_navline div {
            top: 0;
        }
        .dhx_matrix_scell, .dhx_timeline_scale_header {
            font-weight: normal;
        }
        .dhxwins_vp_dhx_skyblue {
            /* overflow: show; */
        }
		a.command {
			margin-left: 11px;
			font-size: 10px;
		}
    </style>

	<cfoutput>
	<!----------------------->
	<!---  timeline body  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="calendar" method="post">
		<input type="hidden" name="action">
		<input type="hidden" name="product_list" value="">
		<cfset application.util.struct.convertToHiddenInput( form, "product_list,action,page_creating" )>

		<div class="dhx_cal_container" id="timeline_body">
			<div class="dhx_cal_navline" style="background-color:white;">

				<div id="timeline_actions">
					<cfif form.mode eq constants.edit>
						<input type=checkbox id=check_all style="margin-left:11px;"> <label for=check_all style='cursor:pointer'>All</label>
						<cfif form.product_group_level_id eq "">
							<a class="command" id="add_products" style="margin-left:35px" title="click to add products">#application.util.string.linkFormat("add products")#</a>
							<a class="command" id="delete_products" title="click to delete products">#application.util.string.linkFormat("delete products", "opaque-h")#</a>
						<cfelse>
							<a class="command" id="add_groups" style="margin-left:35px" title="click to add groups">#application.util.string.linkFormat("add groups")#</a>
							<a class="command" id="delete_groups" title="click to delete groups">#application.util.string.linkFormat("delete groups", "opaque-h")#</a>
						</cfif>
                        <cfif createProgramAccess>
                            <a class="command" id="create" title="click to create a #Application.PlannerPrgLabel# based on selected products">#application.util.string.linkFormat("create #lcase(Application.PlannerPrgLabel)#")#</a>
                            <a class="command" id="import" title="import programs from another #Application.PlannerLabel#">#application.util.string.linkFormat("import #lcase(Application.PlannerPrgLabel)#")#</a>
                        </cfif>
						<cfif getProfileSettings.Planner_Product_Calendar>
							<a class="command" id="events" title="consumer events">#application.util.string.linkFormat("view events")#</a>
						</cfif>
					</cfif>
				</div>	<!--- id="timeline_actions" --->

				<div class="dhx_cal_prev_button"></div>
				<div class="dhx_cal_next_button"></div>
				<div class="dhx_cal_today_button"></div>
				<div class="dhx_cal_date"></div>
			</div>

			<div class="dhx_cal_header"></div>
			<div class="dhx_cal_data">
			</div>
		</div>
	</form>

	<!------------------------->
	<!---  add groups form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="add_groups" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_groups', 900, 800)">
		<cfset queries.qProducts = plannerManager.getPlannerProducts( request.plannerID, request.defaultProductFilterAttr.product_group_level_id )>

		<input type="hidden" name="product_group_level_id" value="#request.defaultProductFilterAttr.product_group_level_id#">
		<input type="hidden" name="selection_input_name" value="product_list">
		<input type="hidden" name="product_list" value="#valueList(queries.qProducts.Item_Key)#">
		<input type="hidden" name="ExistingProductList" value="#valueList(queries.qProducts.Item_Key)#">
		<input type="hidden" name="parent_call_back" value="callback_add_groups()">
		<input type="hidden" name="plannerID" value="#form.plannerID#">
	</form>

	<!------------------------->
	<!---  add filter form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="add_filter" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_filter', 900, 800)">
		<input type="hidden" name="product_group_level_id" value="#form.filter_product_group_level_id#">
		<input type="hidden" name="parent_call_back" value="callback_filter_products()">
		<input type="hidden" name="selection_input_name" value="filter_product_list">
		<input type="hidden" name="filter_product_list" value="#form.filter_product_list#">
	</form>
	<!--------------------------------------------------------------------------------------------------------------------------
	NOTE: The same input may be used in more than one form (e.g. filter_product_list, product_list). The reason is we need to pass
	the same piece of information to different parts of the page. Popup page has a small form. And submit page has a larger form.
	--------------------------------------------------------------------------------------------------------------------------->
	<!--------------------------->
	<!---  reset filter form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="filter_products" method="post">
		<input type="hidden" name="filter_product_list" value="#form.filter_product_list#">
		<input type="hidden" name="action" value="filter_products">
		<cfset application.util.struct.convertToHiddenInput( form, "filter_product_list,action" )>
	</form>

	<!-------------------------------------------------->
	<!--- this form is used in "add products" option --->
	<form name="cal_add_items" method="post" id="cal_add_items" action="/Planners/Create/planner_add_product.cfm" onsubmit="popup_form(this, 'cal_add_items', 900, 800)">
		<!--- <cfset application.util.struct.convertToHiddenInput( form, "product_list,action,page_creating,plannerID,ExistingProductList" )> --->
		<input type="hidden" name="ExistingProductList" value="#valueList(queries.qProducts.Item_Key)#">   	<!--- this is used in "add groups" & "add products" --->
		<input type="hidden" name="product_list" value="">   <!--- this is used in "add groups" & "add products" --->
		<input type="hidden" name="action" value="select_products">
		<input type="hidden" name="plannerID" value="#form.plannerID#">
		<input type="hidden" name="mode" value="#form.mode#">
		<input type="hidden" name="parent_call_back" value="callback_add_products()">
	</form>

	<!----------------------------->
	<!---  create program form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="create_program" method="post" action="/common_files/select_new_program_type.cfm" onsubmit="popup2022_form(this, 'create_program', 'XL', 'XL')">
		<cfoutput>
		<input type="hidden" name="bypassRSPSelect" value="1">
		<input type="hidden" name="fromRetailPlanner" value="1">
		<input type="hidden" name="plannerID" value="#form.plannerID#">
		<input type="hidden" name="product_list" value="">
		<input type="hidden" name="product_list_type" value="#form.product_group_level_id#">
		<input type="hidden" name="customerID" value="#getPlanner.BSA_FoodService_Customers_ID#">
		</cfoutput>
	</form>

	<!----------------------------->
	<!---  import programs form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form name="import_programs" method="post" action="/planners/import/planner_import_programs.cfm?action=import">
		<cfoutput>
		<input type="hidden" name="current_step" value="3">
		<input type="hidden" name="planner_import_type" value="">
		<input type="hidden" name="chosen_planners" value="#form.plannerID#">
		<input type="hidden" name="chosen_planner_info" value="#getPlanner.Planner_Number#-#getPlanner.Name# [#getPlanner.Ship_To#]-#getPlanner.Planner_Type#">
		<input type="hidden" name="planner_template_id" value="">
		</cfoutput>
	</form>

	<!-------------------->
	<!---  email form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<form action="/planners/email.cfm" method ="post" name="email" onsubmit="popup_form(this, 'email', 900, 800)">
		<input type="hidden" name="senderSubject" value=<cfoutput>"#Application.PlannerLabel# Calendar #getPlanner.Planner_Number# #getPlanner.Name#"</cfoutput>>
		<input type="hidden" name="attachments">
		<input type="hidden" name="attachment_content">
	</form>
	</cfoutput>

	<!----------------------------->
	<!---  top navigation form  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<cfinclude template="/planners/create/topnav_form.cfm">

	<!--------------------------->
	<!---  quick add program  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<div id="quick_add">
		<form name="quick_add">
			<div id="date_range">
				<label>Rate</label> <input type="text" name="rate" value="" id="rate">
				<label>From</label> <input type="text" class="date" name="start_date" value="" id="start_date">
				<label>To</label>  <input type="text" class="date" name="end_date" value="" id="end_date">
			</div>

			<div id="perf_types">
				<label>Performance Type</label>
				<cfoutput query="queries.perf_types">
					<i class="perf_type perf_type_#queries.perf_types.planner_perf_types_id#">
						<input type="radio" name="perf_type" value="#queries.perf_types.planner_perf_types_id#"> #queries.perf_types.Description#
					</i>
				</cfoutput>
			</div>

			<cfoutput>
			<a class="primary" href="##" onclick="save_quick_add()">#application.util.string.linkFormat("save")#</a>
			<a class="secondary" href="##" onclick="close_quick_add()">#application.util.string.linkFormat("cancel")#</a>
			</cfoutput>
		</form>
	</div>
	</cfsavecontent>	<!--- <variable="vars.body_content"> --->

	<!--------------------------------------------->
	<!---  remove extra white spaces & display  --->
	<!------------------------------------------------------------------------------------------------------------------------->
	<cfoutput>#application.util.string.compress( vars.body_content )#</cfoutput>

    <!--- standard 7 days per week indicator --->
	<cfset seven_days_in_week = true>

    <cfset planner_weeks = []>
	<!--- ngt - pull planner weeks into an array for JS scheduler to based on --->
    <cfoutput query="queries.periods">
        <cfscript>
            pw.date  = queries.periods.PLANNER_WEEK_START_DATE;

            pw.year  = year( pw.date );
            pw.month = month( pw.date );
            pw.day   = day( pw.date );

            // strip off the time portion from database data
            planner_weeks.append( createDate( pw.year, pw.month, pw.day ) );

            pw.length = planner_weeks.len();

            // detect for non-standard weeks (not 7 days apart)
			if ( ( pw.length gt 1 )
				and seven_days_in_week
				and dateDiff( "d", planner_weeks[ pw.length - 1 ], planner_weeks[ pw.length ] ) neq 7 ) {
                seven_days_in_week = false;
            }
        </cfscript>
    </cfoutput>

	<!------------------------------------------------------------------------------------------------------------------------->
	<script>
        let begin = performance.now();
        <!--- ngt - store planner weeks into a JS array --->
        <cfoutput>
            var #toScript( planner_weeks, "planner_weeks" )#
            var seven_days_in_week = #(seven_days_in_week ? 1 : 0)#;
            <!--- ngt - convert planner week dates into integers for comparison purposes --->
            for (var i = 0; i < planner_weeks.length; i++) {
                planner_weeks[ i ] = planner_weeks[ i ].getTime();
            }
        </cfoutput>

		function addDays( theDate, days ) {
		    theDate = theDate || new Date();
		    days    = days || 0;
		    return new Date( theDate.getTime() + days * 24 * 60 * 60 * 1000 );
		}
		function adjust_size() {
			var timeline_header = $( "ul.nav" );
			$( "#timeline_body" ).css( "height", Math.floor( $( window ).height() - timeline_header.offset().top - timeline_header.height() - 50 ) );
		}
		<!------------------------->
		<!---  refresh summary  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		function refresh_summary( response ) {
			if ( response ) {
				try {
					$( '#latest_cs' ).text( numeral( response.latest_cs[0] ).format( integer_format ));
					$( '#latest_cs_ly' ).text( response.ly_cs[0] == 0 ? '' : numeral( response.latest_cs[0]/response.ly_cs[0] ).format( percent_format ));
					$( '#latest_cs_locked' ).text( response.locked_cs[0] == 0 ? '' : numeral( response.latest_cs[0]/response.locked_cs[0] ).format( percent_format ));
					$( '#latest_lbs' ).text( numeral( response.latest_lbs[0] ).format( integer_format ));
					$( '#latest_lbs_ly' ).text( response.ly_lbs[0] == 0 ? '' : numeral( response.latest_lbs[0]/response.ly_lbs[0] ).format( percent_format ));
					$( '#latest_lbs_locked' ).text( response.locked_lbs[0] == 0 ? '' : numeral( response.latest_lbs[0]/response.locked_lbs[0] ).format( percent_format ));
					$( '#latest_sales' ).text( numeral( response.latest_sales[0] ).format( currency_without_decimal ));
					$( '#latest_sales_ly' ).text( response.ly_sales[0] == 0 ? '' : numeral( response.latest_sales[0]/response.ly_sales[0] ).format( percent_format ));
					$( '#latest_sales_locked' ).text( response.locked_sales[0] == 0 ? '' : numeral( response.latest_sales[0]/response.locked_sales[0] ).format( percent_format ));
					$( '#latest_trade' ).text( numeral( response.latest_trade[0] ).format( currency_without_decimal ));
					$( '#latest_trade_ly' ).text( response.ly_trade[0] == 0 ? '' : numeral( response.latest_trade[0]/response.ly_trade[0] ).format( percent_format ));
					$( '#latest_trade_locked' ).text( response.locked_trade[0] == 0 ? '' : numeral( response.latest_trade[0]/response.locked_trade[0] ).format( percent_format ));
				}
				catch( error ) {
					console.log( error );
					console.log( response );
				};
			}
			$( "#summary_table td" ).effect( "highlight", 500 ); //timeline_summary - highlight
		}
		<!----------------------------------->
		<!---  refresh new program event  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		function refresh_program_event( program_event, response ) {
			try {
				program_event.contract_main_id    = response.contract_main_id[0];
				program_event.contract_number     = response.contract_number[0];
				program_event.contract_status     = response.contract_status[0];
				program_event.contract_title      = response.contract_title[0];
				program_event.delivery_end_date   = moment( response.delivery_end_date[0] ).format( moment_format );
				program_event.delivery_start_date = moment( response.delivery_start_date[0] ).format( moment_format );

				// program_event.planner_perf_desc   = response.planner_perf_desc[0];
				// program_event.planner_perf_id     = response.planner_perf_id[0];
				// program_event.rate                = response.rate[0];
				// program_event.target_nuc_blended  = response.target_nuc_blended[0];
				// program_event.target_nuc_promoted = response.target_nuc_promoted[0];
				// program_event.volume              = response.volume[0];
				// scheduler.updateEvent(program_event.id);
			}
			catch( error ) {
				console.log( error );
				console.log( response );
			}
		}

		<!------------------------------------------------------------>
		<!---  update the event for other products on the program  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		update_program_on_other_products = function (modified_program_event, original_program_event) {
			var other_program_events = scheduler.getEvents( original_program_event.start_date, original_program_event.end_date );
			for (var i = 0; i < other_program_events.length; i++ ) {
				// search for other program events with the same program id
				if ( other_program_events[i].contract_main_id === original_program_event.contract_main_id ) {
					// update info in other program event with the same program id
					if ( other_program_events[i].id !== modified_program_event.id ) {
						var update_program_event                 = scheduler.getEvent( other_program_events[i].id );
						update_program_event.contract_status     = modified_program_event.contract_status;
						update_program_event.contract_number     = modified_program_event.contract_number;
						update_program_event.contract_main_id    = modified_program_event.contract_main_id;
						update_program_event.contract_title      = modified_program_event.contract_title;
						update_program_event.planner_perf_id     = modified_program_event.planner_perf_id;
						update_program_event.start_date          = modified_program_event.start_date;
						update_program_event.end_date            = modified_program_event.end_date;
						update_program_event.delivery_start_date = modified_program_event.delivery_start_date;
						update_program_event.delivery_end_date   = modified_program_event.delivery_end_date;
						scheduler.updateEvent(update_program_event.id);
					}
				}
			}
		}

		<!------------------------------------------------------------------------>
		<!---  update pasted program for other products on the copied program  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		update_program_paste = function(modified_program_event, original_program_event) {
			var other_program_events = scheduler.getEvents( original_program_event.start_date, original_program_event.end_date );
			for (var i = 0; i < other_program_events.length; i++ ) {
				// search for other program events with the same program id
				if ( other_program_events[i].contract_main_id === original_program_event.contract_main_id ) {
					// create a new program event for other products in the original program event
					if ( other_program_events[i].item_key !== modified_program_event.item_key ) {
						var other_program_event = scheduler.getEvent( other_program_events[i].id );
						var new_id              = scheduler.addEvent({
													item_key            : other_program_event.item_key,
													group_number        : other_program_event.group_number,
													description         : other_program_event.description,
													contract_main_id    : modified_program_event.contract_main_id,		// update from modified_program_event
													contract_number     : modified_program_event.contract_number,		// update from modified_program_event
													start_date          : moment( modified_program_event.start_date ).format( "DD/MM/YYYY" ),			// update from modified_program_event
													end_date            : moment( modified_program_event.end_date ).format( "DD/MM/YYYY" ),				// update from modified_program_event
													delivery_start_date : modified_program_event.delivery_start_date,	// update from modified_program_event
													delivery_end_date   : modified_program_event.delivery_end_date,		// update from modified_program_event
													contract_title      : modified_program_event.contract_title,		// update from modified_program_event
													target_nuc_promoted : other_program_event.target_nuc_promoted,
													target_nuc_blended  : other_program_event.target_nuc_blended,
													retailer_unit_cost  : other_program_event.retailer_unit_cost,
													volume              : other_program_event.volume,
													rate                : other_program_event.rate,
													contract_status     : other_program_event.contract_status,
													planner_perf_id     : other_program_event.planner_perf_id,
													planner_perf_desc   : other_program_event.planner_perf_desc,
													perf_sort_order     : other_program_event.perf_sort_order
												});
						scheduler.updateEvent(new_id);
					}
				}
			}
		}
		adjust_size();

		<!------------------->
		<!---  constants  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		var currency_with_decimal    = "$0,.00";
		var currency_without_decimal = "$0,";
		var integer_format           = "0,";
		var percent_format           = '0,%';
		var moment_format            = "MM/DD/YYYY";
		var fake_main_id             = -999;

		<!------------------->
		<!---  variables  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		var copied_event_id          = null;
		var fire_before_event_change = true;


        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~ disable the delete key, we do not allow programs to be deleted ~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        scheduler._click.buttons["delete"] = function(){
            return false;
        };
		scheduler.attachEvent("onBeforeDrag", function( id, mode, e ) {
    		//your code here
			var program_event  = scheduler.getEvent( id ),
				program_status = program_event.contract_status.toLowerCase();
    		if ( program_status == "work in progress" || program_status == "wip"
    				|| program_status == "ready for approval" || program_status == "rfa" ) {
    			return true;
    		}
			dhtmlx.message( "<b>Note:</b> Dragging is only allowed on WIP programs and RFA programs.");
    		return false;
		});

		scheduler.attachEvent( "onBeforeEventChanged", function( revised_program_event, native_event, is_new, original_program_event ) {
			if ( is_new ) {
				return true;
			}
			else {
				// revert changes in dragging to a different product
				if ( !fire_before_event_change || ( revised_program_event.item_key !== original_program_event.item_key )) {
					var error_msg =  'Moving to a different product is not supported.';
					if ( !fire_before_event_change && ( revised_program_event.item_key == original_program_event.item_key ))
						var error_msg =  'Use drag & drop to move a <cfoutput>#Application.PlannerPrgLabel#</cfoutput>.';
					dhtmlx.message( "<b>Note:</b> " + error_msg);
					fire_before_event_change = true
					return false;
				}

				if ( revised_program_event.contract_main_id == fake_main_id ) {
					refresh_summary( null );
				}
				else {
					// adjust ending date so it would not fall onto next week starting date
					// revised_program_event.end_date = addDays(revised_program_event.end_date, 6);

					// calculate duration between old date and new date in days
					var original_date = moment( original_program_event.start_date );
					var revised_date  = moment( revised_program_event.start_date );
					var duration      = moment.duration( revised_date.diff( original_date ) );
					var days_diff     = duration.asDays();

					// adjust delivery dates based on duration difference in days
					revised_program_event.delivery_start_date = moment( original_program_event.delivery_start_date )
																	.add( days_diff, 'days' )
																	.format( moment_format );
					revised_program_event.delivery_end_date = moment( original_program_event.delivery_end_date )
																	.add( days_diff, 'days' )
																	.format( moment_format );
					update_program_on_other_products(revised_program_event, original_program_event);
					// save changes to db, refresh summary information
					$.ajax({
								async: true
								,data: {
										contract_main_id     : revised_program_event.contract_main_id
										,delivery_end_date   : revised_program_event.delivery_end_date
										,delivery_start_date : revised_program_event.delivery_start_date
										,end_date            : revised_program_event.end_date
										,indirect_planner    : <cfoutput>#form.indirect_planner#</cfoutput>
										,method              : "saveTimeLineEntry"
										,parent_planner_id   : <cfoutput>#form.parent_planner_id#</cfoutput>
										,plannerid           : <cfoutput>#form.plannerID#</cfoutput>
										,returnFormat        : "json"
										,start_date          : revised_program_event.start_date
									}
								,dataType: "json"
								,success: function( response )  { if ( response.status == "success" ) refresh_summary( response ); }
								,type: "post"
								,url: "/mvc/models/planner/plannermanager.cfc"
					});
				}
				return true;
			}   // ( is_new )
		});		// onBeforeEventChanged

		<cfoutput>
		var min_date = new Date( "#dateFormat( queries.periods[ 'planner_week_start_date' ][ 1 ], vars.cf_date_format )#" );
		<cfif ( queries.periods.recordCount lte weeks_per_view )>
			var last_starting_date = min_date;
		<cfelse>
			var last_starting_date = new Date( "#dateFormat( queries.periods[ 'planner_week_start_date' ][ queries.periods.recordCount - weeks_per_view + 1 ], vars.cf_date_format )#" );
		</cfif>
		var max_date = new Date( "#dateFormat( queries.periods[ 'planner_week_start_date' ][ queries.periods.recordCount ], vars.cf_date_format )#" );

		</cfoutput>

		scheduler.attachEvent("onBeforeViewChange", function(old_mode, old_start_date, new_mode, new_start_date) {
			// do not go beyond first date and last date
			var new_ending_date = moment( new_start_date ).add(<cfoutput>#(min(weeks_per_view, queries.periods.recordCount) - 1)#</cfoutput>, 'w');
			// to open at current start date on reload
			$('input[name=calendar_init_date]').val( new_start_date );

			// try to go beyond last page - starts from last starting date
			if ( new_ending_date > moment( max_date ) ) {
				scheduler.setCurrentView( last_starting_date );
				return false;
			}
			// try to go beyond first page - starts from mininum date
			if ( new_start_date < moment( min_date ) ) {
				scheduler.setCurrentView( min_date );
				$('input[name=calendar_init_date]').val( min_date );
				return false;
			}
			return true;
		});

		<cfif ( queries.periods.recordCount lte weeks_per_view )>
			// when there is only one page disable prev button, next button and clicks
	    	$("div.dhx_cal_next_button, div.dhx_cal_prev_button").css("cursor", "default").off( "click" );
		<cfelse>
			// multiple pages exist - control prev/next button display conditionally
			scheduler.attachEvent("onViewChange", function (new_mode , new_start_date) {
				var new_ending_date = moment( new_start_date ).add(<cfoutput>#(min(weeks_per_view, queries.periods.recordCount) - 1)#</cfoutput>, 'w');
				// disable next button when it is beyond the middle date
		    	$("div.dhx_cal_next_button").css( "opacity", moment( new_ending_date ) >= moment( max_date )
		    														? "0.5"
		    														: "1" );
				// disable prev button when it is beyond the first date
		    	$("div.dhx_cal_prev_button").css( "opacity", moment( new_start_date ) <= moment( min_date )
		    														? "0.5"
		    														: "1" );
			});
		</cfif>

		<cfif form.mode neq constants.edit>
			scheduler.attachEvent("onClick", function( id ) {
																// get the data in the clicked event, native_event does not have data in it
																<cfoutput>
																var clicked_program_event = scheduler.getEvent( id );
																if ( clicked_program_event.contract_main_id !== fake_main_id ) {
																	var new_popup = popupCenter2022( "planner_program_create.cfm"
																					+ "?programId=" + clicked_program_event.contract_main_id
																					+ "&numb="
																					+ "&plannerID=#form.plannerID#"
																					+ "&bInit=1", "winEdit", "XL", "XL" );
																	new_popup.focus();
																}
																</cfoutput>
																return false;
			});
		<cfelse>
			scheduler.attachEvent( "onDblClick", function( id, native_event ) {
																				// get the data in the clicked event, native_event does not have data in it
																				<cfoutput>
																				var clicked_program_event = scheduler.getEvent( id );
																				if ( clicked_program_event.contract_main_id !== fake_main_id )
																					popupCenter2022( "planner_program_create.cfm"
																									+ "?programId=" + clicked_program_event.contract_main_id
																									+ "&block=1"
																									+ "&plannerID=#form.plannerID#"
																									+ "&bInit=1", "winEdit", "XL", "XL" );
																				</cfoutput>
			});
		</cfif>

		<!------------------------>
		<!---  configurations  --->
        <!--------------------------------------------------------------------------------------------------------------------->


		dhtmlx.message.position                  = "bottom";
		scheduler.config.collision_limit         = 99;
		scheduler.config.details_on_dblclick     = true;
		scheduler.config.multisection            = false;
		scheduler.config.multisection_shift_all  = false;
		scheduler.config.readonly 				 = <cfif form.mode eq constants.edit> false <cfelse> true </cfif>;
		scheduler.config.show_loading            = true;
		scheduler.config.xml_date                = "%n/%j/%Y";    // date format specified in programs array
		scheduler.xy.nav_height                  = 30;            // hide entire navigation header
		scheduler.config.start_on_monday 		 = <cfif constants.planner_week_start eq 2 > true <cfelse> false </cfif>;	// false = sunday

		//workaround touchscreen bug - tooltip and D&D break, see https://forum.dhtmlx.com/viewtopic.php?f=15&t=50731
		scheduler.config.touch 	 		= false;
		// scheduler.config.touch_tooltip 	= true;

		// turn off dragging, copying, pasting
		if ( 1 ) {
			scheduler.config.dblclick_create = false;
			scheduler.config.drag_create     = false;
			scheduler.config.drag_in         = false;
			scheduler.config.drag_move       = true;
			scheduler.config.drag_resize     = false;
			scheduler.config.drag_out        = false;
			scheduler.config.edit_on_create  = false;
		}

        scheduler.config.date_format        = "%m/%d/%Y %H:%i";
        scheduler.config.parse_exact_format = true;
        scheduler.config.drag_event_body    = false;
        scheduler.config.touch_swipe_dates  = true;

		<!---  cut: event --->
		scheduler.attachEvent("onEventCut", function(ev) {
			dhtmlx.message("<b>Note:</b> <b>Ctrl + X</b> is not supported.");
			fire_before_event_change = false;
			copied_event_id = null;
			return false;
		});
		<!---  copy: event --->
		scheduler.attachEvent("onEventCopied", function(ev) {
			fire_before_event_change = true;
			copied_event_id = ev.id;
			scheduler.updateEvent(copied_event_id);
			dhtmlx.message("Copied <cfoutput>#Application.PlannerPrgLabel#</cfoutput>: <b>" + ev.contract_number  + "</b><br/> <b> Ctrl + V </b> - copy/paste event.");
		});
		<!---  paste: event --->
		scheduler.attachEvent("onEventPasted", function(isCopy, new_event, original_event) {
			if ( ( !isCopy || new_event.item_key != original_event.item_key ) ) {
				if (isCopy) {
					// copy operation, need to delete new event
					dhtmlx.message("<b>Note:</b> Copying to a different product is not supported.");
					scheduler.deleteEvent(new_event.id);
					return false;
				}
			}
			if (isCopy) {
				// send to db to create only if copy
				var plnr_start = new Date('<cfoutput>#dateformat(getPlanner.Planner_Start_Date, vars.cf_date_format)#</cfoutput>');
				var plnr_end   = new Date('<cfoutput>#dateformat(getPlanner.Planner_End_Date, vars.cf_date_format)#</cfoutput>');
				show_loader();
				if ( moment( new_event.start_date ).isBefore( plnr_start ))
					new_event.start_date = plnr_start;
				if ( moment( plnr_end ).isBefore( new_event.end_date ))
					new_event.end_date = plnr_end;

				var source = {	start_date: moment( original_event.start_date ),
								end_date: moment( original_event.end_date ),
								start_week: moment( scheduler.date.week_start( new Date( original_event.start_date ) ) )
							};
				// calculate program duration in days
				source.program_duration = moment.duration( source.end_date.diff( source.start_date ) ).asDays();
				// calculate the difference in days between start date and start week
				source.start_days_diff = moment.duration( source.start_date.diff( source.start_week ) ).asDays();

				// adjust new program start date because original start date may start in mid-week and scheduler rounds the new starting date
				new_event.start_date = moment( new_event.start_date ).add( source.start_days_diff, "days" ).format( moment_format );
				// adjust new program end date based on adjusted starting date
				new_event.end_date  = moment( new_event.start_date ).add( source.program_duration, "days" ).format( moment_format );

				// calculate duration between old date and new date in days
				var original_date = moment( original_event.start_date );
				var revised_date  = moment( new_event.start_date );
				var duration      = moment.duration( revised_date.diff( original_date ) );
				var days_diff     = duration.asDays();

				// adjust delivery dates based on duration difference in days
				new_event.delivery_start_date = moment( original_event.delivery_start_date )
																.add( days_diff, 'days' )
																.format( moment_format );
				new_event.delivery_end_date = moment( original_event.delivery_end_date )
																.add( days_diff, 'days' )
																.format( moment_format );
				$.ajax({
					  async: true
					 ,data: {
								contract_main_id     : original_event.contract_main_id
								,delivery_end_date   : new_event.delivery_end_date
								,delivery_start_date : new_event.delivery_start_date
								,end_date            : new_event.end_date
								,indirect_planner    : <cfoutput>#form.indirect_planner#</cfoutput>
								,method              : "copyTimeLineProgram"
								,parent_planner_id   : <cfoutput>#form.parent_planner_id#</cfoutput>
								,plannerid           : <cfoutput>#form.plannerID#</cfoutput>
								,planner_perf_id     : new_event.planner_perf_id
								,start_date          : new_event.start_date
								,returnFormat        : "json"
								,user_id             : <cfoutput>"#request.accessstructure.user_id#"</cfoutput>
							}
					 ,dataType: "json"
					 ,error: function(r, status) {  /* errors in the saving changes to the database (remote backend call),
					 									need to check the event errors created around the time this alert popped up */
					 								dhx_alert( 	"An unexpected error has occurred on "
					 											+ moment().format( "MMMM Do YYYY, h:mm:ss a" ) + ".<br>"
					 											+ "Please take a screenshot & email it to us." ); }
					 ,success: function( response ) {
				 									if ( response.status == "success" ) {
				 										refresh_summary( response );
				 										refresh_program_event( new_event, response );
				 										display_program_inactives(response.contract_main_id[0]);
				 										// create pasted program for other products of the copied program
				 										// update_program_paste(new_event, original_event);
				 										$("form[name=topnav]").submit();
				 									}
				 								}
					 ,timeout: 60000
					 ,type: "post"
					 ,url: "/mvc/models/planner/plannermanager.cfc"
				});
			} // if (isCopy)
		});


		<!------------------------->
		<!---  quick add popup  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		var quick_add = $("#quick_add")[0];
		scheduler.showLightbox = function( id ) {
			var program_event = scheduler.getEvent( id );
			// stop editing an existing program event
			if ( program_event.text !== "New event" ) {
				return false;
			}
			scheduler.startLightbox( id, quick_add );

            // assign default values to new program
            $("#rate").val( "" ).numeric({ negative: false, decimal: true }).focus();    // empty rate input
            $("input[name=perf_type]:checked").attr("checked", false);                   // reset performance type to none
            // put selected date range into the form elements
			$("#start_date").val( moment( program_event.start_date ).format( moment_format ) );
			$("#end_date").val( moment( program_event.end_date ).format( moment_format ) );
		};
		$(".date").datepicker( {
								 changeMonth: true
								,changeYear: false
								,minDate: <cfoutput>"#dateFormat( queries.periods['planner_week_start_date'][1], vars.cf_date_format )#"</cfoutput>
								,maxDate: <cfoutput>"#dateFormat( queries.periods['planner_week_end_date'][ queries.periods.recordCount ], vars.cf_date_format )#"</cfoutput>
								,onSelect: function( selected ) {
															    // change date limit based on selected value
															    if ( $(this).attr("name") === "start_date" ) {
															        $("input[name=end_date]").datepicker("option", "minDate", selected );
															    }
															    else {
															        $("input[name=start_date]").datepicker("option", "maxDate", selected);
															    }
								}
		});
		function close_quick_add() {
			scheduler.endLightbox(false, quick_add);
		}
		function save_quick_add() {
			var errors = [];

			if ( $("input[name=rate]").val() == "" ) {
				errors.push( "Please enter a rate." );
			}
			var start_date = $("input[name=start_date]").val();
			if ( start_date == "" ) {
				errors.push( "Please enter a starting date." );
			}
			else if ( moment( start_date ).isValid() == false ) {
				errors.push( "Please enter a valid starting date." );
			}
			var end_date = $("input[name=end_date]").val();
			if ( end_date == "" ) {
				errors.push( "Please enter an ending date." );
			}
			else if ( moment( end_date ).isValid() == false ) {
				errors.push( "Please enter a valid ending date." );
			}
			if ( moment( end_date ).isBefore( start_date ) ) {
				errors.push( "Please enter a valid date range." );
			}
			if ( $("input[name=perf_type]:checked").length == 0 ) {
				errors.push( "Please choose a performance type." );
			}
			if ( errors.length ) {
				dhx_alert( errors.join("<br>") );
				return false;
			}
			var program_event               = scheduler.getEvent( scheduler.getState().lightbox_id );
			program_event.rate              = $("#rate").val();
			program_event.start_date        = new Date( $("#start_date").val() );
			program_event.end_date          = new Date( $("#end_date").val() );
			program_event.planner_perf_id   = $("input[name=perf_type]:checked").val();
			program_event.planner_perf_desc = $("input[name=perf_type]:checked").parent("i").text();

			// save changes to db, refresh summary information
			$.ajax({
				  async: true
				 ,data: {
							end_date         : program_event.end_date
							,method          : "createTimeLineEntry"
							,planner_perf_id : program_event.planner_perf_id
							,plannerid       : <cfoutput>#form.plannerID#</cfoutput>
							,rate            : program_event.rate
							,returnFormat    : "json"
							,start_date      : program_event.start_date
						}
				 ,dataType: "json"
				 ,success: function( response ) {
				 									if ( response.status == "success" ) {
				 										response.contract_main_id[0] = fake_main_id;    // TODO: replace this line
				 										refresh_summary( response );
				 										refresh_program_event( program_event, response );
				 									}
				 								}
				 ,type: "post"
				 ,url: "/mvc/models/planner/plannermanager.cfc"
			});
			scheduler.endLightbox(true, quick_add);
		}	// function save_quick_add()
		// expand checkbox click area to include the description & paddings
		$("i.perf_type").click(function() {
			$(this).find("input[type=radio]").attr("checked", "checked");
		});

		<!--------------------------->
		<!---  timeline creation  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		<cfsavecontent variable="vars.y_unit">
			<cfoutput query="queries.products">
				<cfscript>
					product_description = EncodeForHTML(queries.products.description);
					product_key = "<div style='display:flex'>"
									&
									( form.mode eq constants.edit
										? "<input type='checkbox' class='cb' id='#queries.products.item_key#'>"
										: "" )
									& "<span style='text-align:left'>"
									& ( queries.products.Active_Code eq 'N'
										? "<i class='inactive' title='In-Active #request.product_label#'>&##1138;</i>"
										: "" )
									& "<label for='#queries.products.item_key#'>#queries.products.item#</label>";
				</cfscript>
				<cfif queries.products.currentRow gt 1>
					,
				</cfif>


				{   key:"#queries.products.item_key#"
				 ,label:"#product_key#
							<cfif form.product_group_level_id eq "">
								<i class='prod' title='#product_description#'>#product_description#</i>
							<cfelse>
								<a class='prod'
									onclick='view_members( &quot;#queries.products.item_key#&quot; )'
									title='#product_description# - click to view members'>#product_description#
								</a>
							</cfif></span></div>"
				}
			</cfoutput>
		</cfsavecontent>

        // ngt
        <cfoutput>
        let view = { x_length: 4, x_size: #( min( weeks_per_view, queries.periods.recordCount ) )# };

        // all planner weeks have 7 days apart
        if ( seven_days_in_week ) {
            view.x_step = 7;
        }
        // some planner weeks do not have 7 days apart
        else {
            view.x_step   = 1;
            view.x_length = view.x_length * 7;
            view.x_size   = view.x_size * 7;
        }
        </cfoutput>

		scheduler.createTimelineView( {
										name: "timeline",
										render: "bar",
										round_position: true,
										x_date: <cfif queries.periods.recordCount gt weeks_per_view> "%M<br>%j" <cfelse> "%M %j" </cfif>,

                                        // ngt
                                        x_length: view.x_length,
                                        x_size: view.x_size,
										x_step: view.x_step,

										x_start: 0,
										x_unit: "day",
										y_property: "item_key",
										dx: 300,                // first column width in pixels
										section_autoheight : false,
										y_unit: [ <cfoutput>#application.util.string.compress( vars.y_unit )#</cfoutput> ]
									});

        if ( seven_days_in_week ) {
        }
        else {
		    <!--- ngt - skip date not defined as a planner week --->
            scheduler.ignore_timeline = function( date ) {
                                                            return ! planner_weeks.includes( date.getTime() );
                                                        }
        }

		<!------------------->
		<!---  templates  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		// text to display on event
		scheduler.templates.event_bar_text = function( start, end, event ) {
			/* Show "alt cust" label in the band only if program is atleast 3 weeks */
			var timeDifference = event.end_date - event.start_date;
			var dayDifference = timeDifference / (1000 * 3600 * 24);
			var strAltText = "";
			 if (event.alternate_customer_on == 1 && dayDifference >= 18 ){
				strAltText = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + '<i>alt cust</i>';
			}
			//	return (numeral( event.rate ).format( currency_with_decimal ));
			return (numeral( event.rate ).format( currency_with_decimal )) + strAltText;
		};
		scheduler.templates.event_class = function( start, end, event ) {
			var css = "perf_type_" + event.planner_perf_id; //default
			if ( event.id == copied_event_id && scheduler.getState().select_id == copied_event_id ) {
				css += " copied_event"; // on copy
			}
			return css;
		};

		scheduler.templates.tooltip_text = function( start_date, end_date, current_event ) {
			if ( typeof(current_event.Unit) === "undefined" ) {
				current_event.Unit = '';
			}
			return <cfoutput query="queries.calendar_info">
				<cfswitch expression="#Name#">
					<cfcase value="program_status"> "<br> <i class=tip>#description#</i>" + current_event.contract_status </cfcase>
					<cfcase value="program_number"> "<br> <i class=tip>#description#</i>" + current_event.contract_number </cfcase>
					<cfcase value="program_title"> "<br> <i class=tip>#description#</i>" + current_event.contract_title </cfcase>
					<cfcase value="performance_type"> "<br> <i class=tip>#description#</i>" + "<i class='perf_type_" + current_event.planner_perf_id + "'> " + current_event.planner_perf_desc + "&nbsp;</i>" </cfcase>
					<cfcase value="performance_dates"> "<br> <i class=tip>#description#</i>" + moment( start_date ).format( moment_format ) + " - " + moment( end_date ).format( moment_format ) </cfcase>
					<cfcase value="retailer_unit_cost"> (current_event.template_ruc == 0
						? ""
						: "<br> <i class=tip>#description#</i>" + (current_event.price == 0 ? "N/A" : numeral( current_event.retailer_unit_cost ).format( currency_with_decimal ) + " " + current_event.Unit))
					</cfcase>
					<cfcase value="volume"> "<br> <i class=tip>#description#</i>" + numeral( current_event.volume ).format( integer_format ) + " " + current_event.uom </cfcase>
					<cfcase value="target_promoted_nuc"> (current_event.template_nuc_target == 0
						? ""
						: "<br> <i class=tip>#description#</i>" + numeral( current_event.target_nuc_promoted ).format( currency_with_decimal ) + " " + current_event.Unit)
					</cfcase>
					<cfcase value="planned_nuc"> "<br> <i class=tip>#description#</i>" + numeral( current_event.target_nuc_blended ).format( currency_with_decimal ) + " " + current_event.Unit </cfcase>
					<cfcase value="retail_price"> "<br> <i class=tip>#description#</i>" + numeral( current_event.rate ).format( currency_with_decimal ) + " " + current_event.Unit </cfcase>
					<cfcase value="retailer_margin"> (current_event.template_retailer_margin == 0
						? ""
						: "<br> <i class=tip>#description#</i>" + (current_event.price == 0 ? "N/A" : numeral( current_event.retailer_margin / 100).format(percent_format)))
					</cfcase>
					<cfcase value="delivery_dates"> "<br> <i class=tip>#description#</i>" + moment( current_event.delivery_start_date ).format( moment_format ) + " - " + moment( current_event.delivery_end_date ).format( moment_format ) </cfcase>
					<cfcase value="retailer_profit"> "<br> <i class=tip>#description#</i>" + (current_event.price == 0 ? "N/A" : numeral( current_event.retailer_profit ).format( currency_with_decimal ) + " " + current_event.Unit) </cfcase>
					<cfcase value="everyday_price"> "<br> <i class=tip>#description#</i>" + numeral( current_event.everyday_unit_price ).format( currency_with_decimal ) + " " + current_event.Unit </cfcase>
					<cfdefaultcase>""</cfdefaultcase>
				</cfswitch>
				 +
			</cfoutput>
				(current_event.alternate_customer_on == 0 ? "" : "<br><i class=tip>Alternate Customers</i>" + (current_event.distributor_group_count == 0 ? + current_event.distributor_count + (current_event.distributor_group_count == 0 ? "" :  " members" ) : + current_event.distributor_group_count + " groups / " + current_event.distributor_count +  " members" )) +
			"<hr><i class=detail><b>" + <cfif form.mode eq constants.edit> "Double" <cfelse> "Single" </cfif> + " click</b> to view more detailed information</i>"
			;
		};

		<!---------------------------------------------->
		<!---  Dirty hack to fix key_nav bug in 4.4  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		/*
        scheduler.$keyboardNavigation.dispatcher._old_getActiveNode = scheduler.$keyboardNavigation.dispatcher.getActiveNode;
        scheduler.$keyboardNavigation.dispatcher.getActiveNode = function() {
            var node = this._old_getActiveNode();
            if ( !node ){
                this.setDefaultNode();
                return this.getDefaultNode();
            }
            return node;
        };
		*/

		<!------------------------------->
		<!---  initialize, load data  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		scheduler.init( "timeline_body",
						new Date( <cfoutput>"#dateFormat( form.calendar_init_date, vars.cf_date_format )#"</cfoutput> ),
						"timeline" );
		scheduler.parse( <cfoutput>#serializeJSON( request.components.planner.getTimelinePrograms( form.plannerID ) )#</cfoutput>, "json" );

		<!----------------------->
		<!---  miscellaneous  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		$( window ).resize(function() { adjust_size(); });
		<cfif form.mode neq constants.edit>
			dhtmlx.message( { text:"<b>Note:</b> Calendar is read-only, click the pencil icon to switch to edit mode.", expire:9000 } );
		</cfif>
		<cfif queries.products.recordCount eq 0>
			/* for consistency purpose - use the same noty message as in volume plan */
			noty({ text: "<span class=wait>There are no products matching the selected criteria.</span>", layout: "center", type: 'alert', killer: true });
		</cfif>

		<!--------------->
		<!---  links  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		$("#events").click(function() {
			popupInCenter("/planners/consumer_events/events/calendar.cfm?fromPlanner=1", "ConsumerEvents");
		});

		$("#add_products").click(function() {
			popupInCenter("/Common_Files/contracts/product_Select_V1.cfm?Formname=cal_add_items&Return_Value_Field_Name=product_list", "ProductSelectWindow");
		});

		// display inactive products removed on copy
		display_program_inactives = function(new_prg_id){
			$.ajax({
				async: true
				,data: {
							programId     : new_prg_id
							,method       : "checkProgramInactives"
							,returnFormat : "JSON"
						}
				,dataType: "json"
				,success: function( response ) {
						if ( response == "1" ) {
							popupInCenter("/Common_Files/contracts/view_contract_inactive_products.cfm?ContractID="+new_prg_id,"InactiveRemoved","650","400","Yes", "Yes");
						}
					}
				,type: "post"
				,url: "/mvc/models/planner/plannerprogrammanager.cfc"
			});
		}

		$("#add_groups").click(function() {
			$("form[name=add_groups]").submit();
		});

		$("#create").click(function() {
			var products = [];
			/* gather all checked products */
			$( "input.cb:checked" ).each(function () {
				products.push( $(this).attr("id") );
			});
			$("input[name=product_list]").val( products.join() );
			$("form[name=create_program]").submit();
		});

		$("#import").click(function() {
			// $("form[name=import_programs]").submit();
			// Select an import type:

			dhx_popupInCenter( "/planners/import/select_planner_import_type.cfm"
								+ "?popup=1"
								+ "&templateId=<cfoutput>#getPlanner.Planner_Template_Id#</cfoutput>"
								,"Import Type"
								,500
								,200
							);
		});

		// this fn is called from popup select_planner_import_type.cfm
		function import_programs(){
			show_loader("LOADING <cfoutput>#UCASE(Application.PlannerPrgLabel)#</cfoutput> IMPORT, PLEASE WAIT...");
			$("form[name=import_programs]").submit();
		}

		$("#add_filter").click(function(){
			var filter = $("select[name=filter_product_group_level_id]");
			if ( filter.val() === "" ) {
				filter.focus();
				dhx_alert( "Please select an option in the filter products dropdown first." );
			}
			else {
				$("input[name=filter_product_group_level_id]").val( filter.val() );
				/* update the product group level id used in add filter popup */
				$("form[name=add_filter] input[name=product_group_level_id]").val( filter.val() );
				$("form[name=add_filter]").submit();
			}
		});

		// save selected filters to the backend
		function save_filter() {
			$.ajax( {
						url: "/components/udf.cfc",
						data: {
								method: "saveUserData",
								search_column: "Planner_ID",
								search_id: <cfoutput> #form.plannerID# </cfoutput>,
								template_name: "planner_volume_calendar",
								user_id: "Everyone",
								json: JSON.stringify( { filter_product_list: $( "input[name=filter_product_list]" ).val(),
														filter_product_group_level_id: $( "input[name=filter_product_group_level_id]" ).val() } )
							},
						type: "POST"
					});
		}

		$("#reset_filter").click(function(){
			$("input[name=filter_product_list]").val( "" );
			$("input[name=filter_product_group_level_id]").val( "" );
			show_loader();
			save_filter();
			$("form[name=filter_products]").submit();
		});

		$( "#save_filter" ).click( function() {
			show_loader( "Saving filter...", -1000 );
			save_filter();
		});

		$("select[name=filter_product_group_level_id]").change(function(){
			/* clear out the previous selected list used in add filter popup */
			$("input[name=filter_product_list]").val( "" );
		});

		<!--------------------->
		<!---  dhx windows  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		function view_members( group_id ){
			dhx_popupInCenter( "/Common_Files/contracts/Groups/group_items.cfm"
											+ "?Group_ID=" + group_id
											+ "&Group_Level_ID=" + <cfoutput>"#form.product_group_level_id#"</cfoutput>
										    ,"Group Items"
										    ,600
										    ,715
										);
		}

		<!---------------------------->
		<!---  all checkbox input  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		$("#check_all").click(function(){
			$("input[type=checkbox]").prop("checked", $(this).prop("checked"));
		});
		$(".cb").click(function(){
			$("input#check_all").prop("checked", $("input.cb").length == $("input.cb:checked").length ? "checked" : "")
		});

		$("#delete_products, #delete_groups").click(function() {
			var products          = [],
				selected_rows     = [],
				parent_tr         = null,
				rowid             = null,
				program_count     = null,
				allowed_to_delete = true;
			/* gather all checked products */
			$('input.cb:checked').each(function() {
				products.push( $(this).attr("id") );
				parent_tr = $(this).parents("tr");
				if (parent_tr) {
					// console.log(program_count);
					if (parent_tr.find("div.dhx_cal_event_line").length > 0) {
						allowed_to_delete = false;
						dhx_alert( "Selected product[s] have programs created in this <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT>. These product[s] cannot be removed from the <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT>." );
						return false;
					}
				}
			});
			if (allowed_to_delete) {
				/* none of the products was checked - stop */
				if (products.length == 0) {
					dhx_alert( "Please select at least one product." );
					return false;
				}
				dhtmlx.confirm({
	        					type:"confirm",
 	        					text: "This deletion will zero out the volume for this customer product combination. Are you sure you want to delete?",
	        					ok: "DELETE",
	        					callback: function( ok_to_delete ){
					            if ( ok_to_delete ) {
									show_loader("DELETING IN PROGRESS, PLEASE WAIT...");
					                $("input[name=product_list]").val( products.join(",") );
					                $("input[name=action]").val( "delete_products" );
					                $("form[name=calendar]").submit();
					            };
	        				}
	    		});
			};
		});

		<!----------------------------------------->
		<!---  call back functions from popups  --->
		<!--------------------------------------------------------------------------------------------------------------------->
		function callback_filter_products() {
			show_loader();
			$("form[name=filter_products]").submit();
		}
		function callback_add_groups() {
			$("form[name=cal_add_items]").submit();
		}

		function callback_add_products() {
			$("form[name=cal_add_items]").submit();
		}

		(function () {
			var top               = scheduler.xy.nav_height + 1 + 1;// first +1 -- blank space upper border, second +1 -- hardcoded border length
			var height            = scheduler.xy.scale_height;
			var width             = scheduler.matrix.timeline.dx;

			var header            = document.createElement("div");
			header.style.cssText  = "position:absolute; z-index:99999; font-size:12px; margin:10px 0 0 20px;"
									+ "top:" + top + "px;"
									+ "width:" + width + "px;"
									+ "height:" + height + "px;"
			var filtered          = $( "input[name=filter_product_list]" ).val()
										? " ( filtered ) "
										: "";
			header.innerHTML 	  = <cfoutput>"<div class='timeline_item_cell'>#request.product_label#"</cfoutput> + filtered + "</div>";

			var element = document.getElementById("timeline_body");
			element.appendChild(header);
		})();
	</script>

    <cfinclude template="\common_files\popup2022.cfm">

</cf_layout_planner>
