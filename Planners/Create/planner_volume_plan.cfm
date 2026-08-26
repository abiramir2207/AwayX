<!------------------------------------------------------------------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/planner_volume_plan.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  04/01/2016
Created By   :  KAL
Description  :  Planner Edit; Dispays Planner Volume Plan

Remarks      :  1st product guid value is saved into hidden variable p1 (input type=hidden name=p1 value=<25 chars guid>)

				forecast input is named as 'lfc_p' + product_sequential_record_number + '_' + planner_week_id
				forecast input has a class of 'lfc'

				week checkbox has a custom attribute 'week' with a value of 'w' + week_sequential_number
				product checkbox has a custom attribute 'prod' with a value of 'p' + product_sequential_record_number
------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner>
	<cfinclude template="/planners/create/planner_volume_constants.cfm">

	<cf_include files="/styles/ui.jqgrid.css, /script/javascript/jqGrid/grid.locale-en.js, /styles/css-loader.css, /common_files/dhx_message.cfm">
	<cfoutput>
	<cfscript>
		// retrieve previous selected forecasts for this planner
		saved_forecasts = getUserData( search_column="Planner_ID", search_id=request.plannerID, template_name="volume_plan_config.cfm" );

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

		param name="form.filter_product_group_level_id" default="";
		param name="form.filter_product_list"           default="";

        structAppend(url, createObject( "component", "components.udf" ));
		queries    = {};
		components = {};


		components.datamanager = createObject( "component", "components.products.Group.DataManager" );
		queries.product_groups = components.datamanager.getProductGroupsData();

		if ( form.period eq constants.by_week )
			queries.periods = plannerManager.getPlannerWeeks( request.plannerID );
		else
			queries.periods = plannerManager.getPlannerMonths( request.plannerID );

		if ( structKeyExists(form, "page_creating") eq false ) {
			if (form.action eq "save_volume") {
				plannerManager.savePlannerVolume( form );
			}
			else if (form.action eq "delete_products") {
				plannermanager.deletePlannerProducts( form );
			}
			else if (form.action eq "filter_products") {
			}
		}

		variables.readonly = ( form.mode neq constants.edit
								or form.period neq constants.by_week );
		queries.product_filters = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager").getPlannerFilters(form.planner_template_id, 1, 1);
		lProductFilters = valueList(queries.product_filters.Group_Level_ID);

		oProfiles = CreateObject("component","components.settings.profiles.profile");
		getProfileSettings = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID);
        userManager = CreateObject("component", "components.user.UserManager");
        createProgramAccess = getProfileSettings.Cont_Prog_View_Create_Program eq 1 and (application.appsettingsget.userNumberRestrict EQ 0 OR userManager.getUserNumberExists(request.AccessStructure.user_id) EQ 1);
	</cfscript>

	<cfif (cgi.request_method is "post")>
		<cfloop collection="#form#" item="form_item">
			<cfif left(form_item,2) eq "i.">
				<cfset structDelete(form, form_item)>
			</cfif>
		</cfloop>
	</cfif>
	</cfoutput>

	<style>
		#hdr409 { margin-bottom:6px; font-size:10px; }
		#hdr409 > a { cursor: pointer; margin: 0 5px 0 5px; }
		#hdr407 { float:right; margin-top:0px; }
		#hdr407 > span, #hdr407 > a { margin-left: 7px; }
		#hdr407 > a { cursor: pointer; }
		#filter_products > a { cursor: pointer; margin: 0 0 0 5px; }
		label { font-weight: bold; padding-left: 10px; }
		#apply2 { padding-left: 15px; padding-right: 35px; }
		#config2 { float: right; margin-left: 10px; }
		.right { text-align: right !important; }
		.sub { text-align: right !important; color: #7F5252 !important; padding-right: 8px !important; }
		.center { text-align: center !important; }
		.inactive{color:red;font-style:normal;font-weight:700;}
		.inactive:after{content:" "}
		input.lfc, input.py { width: 90% !important; text-align: right; font-size: 10px !important; padding-right: 2px;}
		input.lfc:disabled, input.py {
			border: none;
		}
		#vp_grid tr, #vp_grid td, #vp_grid_frozen tr, #vp_grid_frozen td { border:none; border-bottom: 1px dotted #CCC; }
		#vp_grid_frozen td, #vp_grid td { vertical-align: middle; }
		#vp_grid td > input { height: 10px; line-height: 10px; vertical-align: middle; }
		tbody td:nth-child(2) { overflow:hidden; }

		.ui-th-column { border: none !important; }
		.2ui-th-div { margin: 0 !important; }
		.2ui-jqgrid-btable .ui-state-highlight { background-color: white !important; }

		#jqGridPager, th.ui-th-column {
							background-color: #9BC2E6 !important;
							background-image: -webkit-linear-gradient(#9BC2E6, #d8e7f5) !important;
							background-image: -o-linear-gradient(#9BC2E6, #d8e7f5) !important;
							background-image: linear-gradient(#9BC2E6, #d8e7f5) !important;
		}
		th.ui-th-column { text-align: right !important; background-color: #9BC2E6 !important; }

		.frozen-div th { text-align: left !important; }

		tr.divider { border-bottom: 1px solid #A9A9A9 !important; }
		tr.totals { background-color: #f5f8ee !important; }
		tr.totals td { color: #7F5252 !important; }
		#vp_grid_frozen tr { background-color: #F0F0F0; }

		input[type=checkbox] { position:relative; top:1px; }
		.wait { letter-spacing: 0.85px; font-weight: bold; }
		.disabled { visibility: hidden; }
		/*a.action, #add_products, #add_groups { margin-left2:15px; }*/
		.changed { background-color2:#FFFE9D; }
		input::-ms-clear { display: none; }
		input[type="checkbox"] {
			border-radius: 1px;
			border-width: 0;
			box-sizing: border-box;
			box-sizing: content-box ;
			cursor: pointer;
			height: 10px;
			position: relative;
			transition: all .3s linear;
			width: 10px;
		}
		#vp_grid_SubTotal, #jqgh_vp_grid_Subtotal { text-align: right !important; }
		span.py { width: 76%; display: inline-block; border2: 1px solid #CCC; }
		div.ui-tooltip { max-width: 400px; }
		#hdr409 > a.command {
			margin-left: 11px;
		}
	</style>

	<cfoutput>
	<!----------------------->
	<!--- heading section --->
	<!--- ----------------------------------------------------------------------------------------------------------------->
	<div id="hdr409">
		<!------------------------->
		<!--- left side options --->
		<!--- ----------------------------------------------------------------------------------------------------------------->
		<cfif not variables.readonly>
			<a id="save" class="primary command" title="click to save changes">#application.util.string.linkFormat("save")#</a>
            <a id=export class="secondary command" title="click to export #Application.PlannerLabel# in csv format">#application.util.string.linkFormat("export to csv")#</a>
            <cfif len(form.product_group_level_id) eq 0>
				<a class="command" id="add_products" title="click to add products">#application.util.string.linkFormat("add products", "opaque-h")#</a>
				<a class="command" id="delete_products" title="click to delete products">#application.util.string.linkFormat("delete products", "opaque-h")#</a>
			<cfelse>
				<a class="command" id="add_groups" title="click to add groups">#application.util.string.linkFormat("add groups", "opaque-h")#</a>
				<a class="command" id="delete_groups" title="click to delete groups">#application.util.string.linkFormat("delete groups", "opaque-h")#</a>
			</cfif>
            <cfif createProgramAccess>
				<a class="command" id="create" title="click to create a program based on selected products">#application.util.string.linkFormat("create #lcase(Application.PlannerPrgLabel)#")#</a>
            </cfif>
			<cfif getProfileSettings.Planner_Product_Calendar>
				<a class="command" id="events" title="consumer events">#application.util.string.linkFormat("view events")#</a>
			</cfif>
		</cfif>
		<cfif not variables.readonly>
			<label id="gf_lbl" for="grow_factor">growth factor </label><input name="grow_factor" id="grow_factor" type="text" size="5">%
			<a class="command" id="apply" title="click to apply growth percentage to checked entries">#application.util.string.linkFormat("apply growth", "opaque-h")#</a>
		</cfif>
		<!-------------------------->
		<!--- right side options --->
		<!--- ----------------------------------------------------------------------------------------------------------------->
		<div id="hdr407">
            <span style="color:red"><b style="color:##333">uom</b>: <b>#(form.uom eq constants.cases ? get_UOM(1).Unit_Of_Measure_Desc : get_UOM(2).Unit_Of_Measure_Desc)#</b></span>
			<a id="config" title="click to modify the options for this page" class="secondary command">#application.util.string.linkFormat("options")#</a>
		</div>
	</div>
	<div style="clear:both"></div>

	<!-----------------------------------------------------------------------------------------------------------------
	NOTE: The same input may be used in more than one form (e.g. filter_product_list, product_list). The reason is we need to pass
	the same piece of information to different parts of the page. Popup page has a small form. And submit page has a larger form.
 	---------------------------------------------------------------------------------------------------------------->

	<!-------------------------------------------------->
	<!--- this form is used in "reset filter" option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="filter_products" method="post">
		<input type="hidden" name="filter_product_list" value="#form.filter_product_list#">
		<input type="hidden" name="action" value="filter_products">
		<cfset application.util.struct.convertToHiddenInput( form, "filter_product_list,action" )>
	</form>

	<!------------------------------------------------>
	<!--- this form is used in "add filter" option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="add_filter" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_filter', 900, 800)">
		<input type="hidden" name="product_group_level_id" value="#form.filter_product_group_level_id#">
		<input type="hidden" name="parent_call_back" value="callback_filter_products()">
		<input type="hidden" name="selection_input_name" value="filter_product_list">
		<input type="hidden" name="filter_product_list" value="#form.filter_product_list#">
	</form>

	<!---------------------------------------------->
	<!--- this form is used in "settings" option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="settings" method="post" action="volume_plan_config.cfm" onsubmit="popup_form(this, 'settings', 900, 800)">
		<input type="hidden" name="action" value="settings">
		<cfset application.util.struct.convertToHiddenInput( form, "action" )>
	</form>

	<!---------------------------------------------------->
	<!--- this form is used in "create program" option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="create_program" method="post" action="/common_files/select_new_program_type.cfm" onsubmit="popup2022_form(this, 'create_program', 'XL', 'XL')">
		<input type="hidden" name="bypassRSPSelect" value="1">
		<input type="hidden" name="fromRetailPlanner" value="1">
		<input type="hidden" name="plannerID" value="#form.plannerID#">
		<input type="hidden" name="product_list" value="">
		<input type="hidden" name="product_list_type" value="#form.product_group_level_id#">
		<input type="hidden" name="customerID" value="#getPlanner.BSA_FoodService_Customers_ID#">
	</form>

	<!-------------------------------------------------->
	<!--- this form is used in "add groups" option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="add_groups" method="post" action="/Planners/Templates/ProductGroup_Search.cfm" onsubmit="popup_form(this, 'add_groups', 900, 800)">
        <cfset qProducts = plannerManager.getPlannerProducts( request.plannerID, request.defaultProductFilterAttr.product_group_level_id )>
		<input type="hidden" name="product_group_level_id" value="#request.defaultProductFilterAttr.product_group_level_id#">
		<input type="hidden" name="selection_input_name" value="product_list">
        <input type="hidden" name="product_list" value="#valueList(qProducts.Item_Key)#">
        <input type="hidden" name="ExistingProductList" value="#valueList(qProducts.Item_Key)#">
		<input type="hidden" name="parent_call_back" value="callback_add_groups()">
        <input type="hidden" name="plannerID" value="#form.plannerID#">
	</form>

	<!-------------------------------------------------->
	<!--- this form is used in "add products" option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="vp_add_items" method="post" id="vp_add_items" action="/Planners/Create/planner_add_product.cfm" onsubmit="popup_form(this, 'vp_add_items', 900, 800);">
		<!--- <cfset application.util.struct.convertToHiddenInput( form, "product_list,action,page_creating,plannerID,ExistingProductList" )> --->
		<input type="hidden" name="ExistingProductList" value="#valueList(qProducts.Item_Key)#">   	<!--- this is used in "add groups" & "add products" --->
		<input type="hidden" name="product_list" value="">   <!--- this is used in "add groups" & "add products" --->
		<input type="hidden" name="action" value="select_products">
		<input type="hidden" name="plannerID" value="#form.plannerID#">
		<input type="hidden" name="parent_call_back" value="callback_add_products()">
	</form>

	<!---------------------------------------->
	<!--- this form is used in save option --->
 	<!--- ----------------------------------------------------------------------------------------------------------------->
	<form name="volume_plan" method="post" id="vp_form">
		<cfset application.util.struct.convertToHiddenInput( form, "action,product_list,page_creating,product_list_type" )>
		<input type="hidden" name="product_list" value="">   <!--- this is used in "add groups" & "add products" --->
		<input type="hidden" name="product_list_type" value="#form.product_group_level_id#">
		<input type="hidden" name="action" value="save_volume">

		<table id="vp_grid" class="gTable" style="width:100%;border-collapse:collapse;">
		</table>
		<div id="jqGridPager"></div>
	</form>
	</cfoutput>

    <!--- export to csv form --->
    <form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
        <input type="hidden" name="csv_text" id="csv_text">
        <input type="hidden" name="csv_file_name">
    </form>

	<cfinclude template="/planners/create/topnav_form.cfm">
	<cfinclude template="/common_files/dhx_windows.cfm">

	<cfset files_to_include = [ "/Script/javascript/jqGrid/grid.base.js"
								,"/script/javascript/numeral.min.js"
								,"/script/javascript/jquery.noty.packaged.min.js"
                                ,"/script/javascript/table2csv.js"
								,"/script/javascript/jquery.cfjs.min.js"
							  ]>
	<cf_include files=#arrayToList( files_to_include )#>

	<!--- ----------------------------------------------------------------------------------------------------------------->
	<script>
	var currency_with_decimal    = "$0,.00";
	var currency_without_decimal = "$0,";
	var integer_format           = "0,";
	var percent_format           = '0,%';

	// on load get summary
	//get_summary('<cfoutput>#form.plannerID#</cfoutput>');

	(function($){
		numeral.defaultFormat('0,0');     <!--- default to integer format --->

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

	function checkBox(e)  {
		e = e || event;/* get IE event ( not passed ) */
		e.stopPropagation ? e.stopPropagation() : e.cancelBubble = true;
	};

	//Takes css classes assigned to each column in the jqGrid colModel
	//and applies them to the associated header.
	var applyClassesToHeaders = function (grid) {
		// Use the passed in grid as context,
		// in case we have more than one table on the page.
		var trHead = jQuery("thead:first tr", grid.hdiv);
		var colModel = grid.getGridParam("colModel");

		for (var iCol = 0; iCol < colModel.length; iCol++) {
			var columnInfo = colModel[iCol];
			if (columnInfo.classes) {
				var headDiv = jQuery("th:eq(" + iCol + ")", trHead);
				headDiv.addClass(columnInfo.classes);
			}
		}
	};

	function ignore_changes() {
		/* no changes made? */
		if ( $("input[dirty='1']").length == 0 ) {
			return true;
		}
		/* ignore changes made? */
		else if ( confirm("You have made changes that are not saved.\n\n"
							+ "Click Cancel to return to save your changes.\n"
							+ "Click OK to ignore your changes and continue.") ) {
			return true;
		}
		return false;
	};

	$("#config").click(function() {
		if ( ignore_changes() ) {
			$("form[name=settings]").submit();
		}
	});
	$("input[name=grow_factor]").forceNumeric();

	var periods_count = <cfoutput>#queries.periods.recordCount#</cfoutput>,
		cols          = { 	item_key        : 0,
							prod_description: 1,
							prod_seq_number : 2,
							category        : 3,
							row_type        : (periods_count + 5),
							prod_tooltip    : (periods_count + 6),
							program_count   : (periods_count + 7)
						};

	function productFormat(cellvalue, options, rowObject) {
		<cfif len(form.product_group_level_id) eq 0>   /* individual product - not a product group */
            return cellvalue;
		<cfelse>
		    if ( cellvalue == "<b>TOTAL</b>" )
		    	return cellvalue;
		    else
				return (	cellvalue == ""
								? ""
								: "<a class='product' item_key='" + rowObject[cols.item_key] + "'>" + cellvalue + "</a>" );
		</cfif>
	}

	function cbFormat(cellvalue, options, rowObject) {
		return (rowObject[ cols.prod_description ] == "" || rowObject[ cols.prod_description ] == "<b>TOTAL</b>"
					? ""
					: "<input type=checkbox class='product csvExclude'"
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ " data=" + cellvalue
						+ ">");
	}

	function dirty( element ) {
		element.setAttribute( "dirty", '1' );
	}

	function volumeFormat(cellvalue, options, rowObject) {
		var result = cellvalue;

		if (rowObject[cols.category] == "LY") {
			result = "<input class=py week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ " style='" + $.ListGetAt(cellvalue, 2, "|") + "'"
						+ " disabled"
                        + " type='text'"
						+ " value=" + $.ListGetAt(cellvalue, 1, "|") + ">";
		}
		else if (rowObject[cols.category] == "FC % LY") {
			result = "<span class=fc_pct_py week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		else if (rowObject[cols.category] == "Actual") {
			result = "<span class=actual week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		else if (rowObject[cols.category] == "Actual % FC") {
			result = "<span class=act_pct_fc week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		else if (rowObject[cols.category] == "Latest FCST") {
			result = "<input type=text class=lfc week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ " dirty=0"
						+ " onfocusout='dirty( this )'"
						+ " " + $.ListGetAt(cellvalue, 2, "|")
						+ " value='" + $.ListGetAt(cellvalue, 1, "|") + "'"
						<cfif variables.readonly>
							+ "disabled"
						<cfelse>
							// in total section - do not allow to edit
							+ (rowObject[cols.row_type] ? "disabled" : "")
						</cfif>
						+ " style='" + $.ListGetAt(cellvalue, 3, "|") + "'>";
		}
		else if (rowObject[cols.category] == "Actual") {
			result = "<span class=actual week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		else if (rowObject[cols.category].toLowerCase().indexOf("lift") !== -1) {
			result = "<span class=lift week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		else if (rowObject[cols.category].toLowerCase().indexOf("base") !== -1) {
			result = "<span class=base week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		return result;
    }

	function subtotalFormat(cellvalue, options, rowObject) {
		var result = cellvalue;
		if (rowObject[cols.category].toLowerCase().indexOf("lift") !== -1) {
			result = "<span class=lift_sum week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		else if (rowObject[cols.category] == "Latest FCST") {
			result = "<span class=fc_sum week=w" + options.pos
						+ " prod=" + rowObject[ cols.prod_seq_number ]
						+ ">" + cellvalue + "</span>";
		}
		return result;
    }

	var grid = $("#vp_grid");
    var volume_table = grid.offset();
	var filtered = $( "input[name=filter_product_list]" ).val()
						? " ( filtered ) "
						: "";

	<cfsavecontent variable="variables.uncompressed">
	grid.jqGrid({
		beforeSelectRow: function(rowid, e) { return false; },   /* disable the selecting a row functionality */
		datatype: 'json',
		cmTemplate: { title:false, search:false, sortable:false, resizable:false },
		colModel: [  <cfoutput>
					 <cfif form.period eq constants.by_week and not variables.readonly>
						/*01*/ { label:"<input type=checkbox onclick='checkBox(event)' class='all_products csvExclude'>", width:20
										,frozen:true, formatter: cbFormat, name:"all_products" },
					 <cfelse>
					 		{ label:"&nbsp;", name:"hidden1", frozen:true, hidden:true },
					 </cfif>
					 /*02*/ { label:"#request.product_label#" + filtered, width:220, frozen:true, title:false, formatter: productFormat, name:"product" },
					 /*03*/ { label:"&nbsp;", name:"hidden2", hidden:true, frozen:true },
					 /*04*/ { label:<cfif form.period eq constants.by_week and not variables.readonly>
					 					"<input type=checkbox onclick='checkBox(event)' class=all_periods> all periods"
									<cfelse>
										"&nbsp;"
									</cfif>
					 				,name:"all_periods", width:90, frozen:true  },
					 /*05*/ { label:"Subtotal &nbsp;", name:"Subtotal", width:70, classes:'sub', formatter:subtotalFormat, frozen:true },
					 </cfoutput>
					 <cfset variables.width = ( form.period eq constants.by_week ? 60 : 130 )>
					 <cfoutput query="queries.periods">
						{
						  label:
							<cfif form.period eq constants.by_week>
								<cfif not variables.readonly>
									'<input type=checkbox class=week week="w#(queries.periods.currentRow + 4)#" onclick="checkBox(event)">' +
								</cfif>
								'#dateFormat( queries.periods.Planner_Week_Start_Date, "m/d" )#'
							<cfelse>
								'#replace( queries.periods.period_id, "_", " " )#'
							</cfif>
						  ,name: "week_#queries.periods.currentRow#"
						  ,width: #variables.width#
						  ,classes: "right"
						  ,formatter: volumeFormat
						},
					 </cfoutput>
					 { label:"", name:"row_type", hidden:true },
					 { label:"", name:"prod_tooltip", hidden:true },
					 { label:"", name:"program_count", hidden:true }
				  ],
		fixed: true,
		jsonReader: {
				id: "",
				root: "ROWS",
				page: "PAGE",
				total: "TOTAL",
				records: "RECORDS",
				cell:""
			},
		gridComplete: function(){
			if (grid.getGridParam("records") == 0) {
				noty({ text: "<span class=wait>There are no products matching the selected criteria.</span>", layout: "center", type: 'alert', killer: true });
			}
			else {
			 var lfc = $("input.lfc");
			 lfc.forceNumeric()
				.focus(function() { $(this).addClass("hilight").select(); })
				.blur(function() { $(this).removeClass("hilight"); })
			 	.change(function() {
					refresh_lfc( $(this) );
				});    /* change() */
			}
			$("[title]").tooltip();
			$("a.product").click(function(){
				dhx_popupInCenter( "/Common_Files/contracts/Groups/group_items.cfm"
								+ "?Group_ID=" + $(this).attr("item_key")
								+ "&Group_Level_ID=" + <cfoutput>"#form.product_group_level_id#"</cfoutput>,
								"Group Items", 715, 600);
			});
		},
		mtype: "POST",
		rowNum: 5000,
		rowattr: function(data) {
			if (data.prod_tooltip) {
				return { "title": data.prod_tooltip };
			}
		},
		pagerpos: "center",
		postData: { <cfoutput>#application.util.list.jsKeysValues( form )#</cfoutput> },
		shrinkToFit: false,  /* must be set with frozen columns, otherwise columns will be shrank to fit the grid width */
		url:'/mvc/Models/Planner/PlannerManager.cfc?method=getPlannerVolume',
		viewrecords: false, /* show the current page, data rang and total records on the toolbar */
		height: window.innerHeight - volume_table.top - 60,
		width: $(window).width() - 14
	});
	</cfsavecontent>

    <cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
	$( window ).resize(function() {
	    grid.setGridWidth( $(window).width() - 14 );
	    grid.setGridHeight( $(window).height() - 150 );
	});

	/* mass apply */
	$(".all_periods").click(function() {
		$(".week").prop("checked", $(this).prop("checked"));
	});
	$(".all_products").click(function() {
		$("#vp_grid_frozen input.product").prop("checked", $(this).prop("checked"));
	});

	$("#apply").click(function(){
		var grow_factor = $("input[name='grow_factor']").val()
			,entries    = 0;
		if (grow_factor == "") {
			dhx_alert( "Please enter the growth factor percentage." );
			$("input[name=grow_factor]").focus();
			return false;
		}
		/* prepare to run multiple small tasks in browser queue to avoid locking up the browser */
        var loadChain = new LoadChain();
        var checked_products = $("table#vp_grid_frozen .product:checked");
        if (checked_products.length > 6) {
	        loadChain.push(function() { show_loader("APPLYING GROWTH, PLEASE WAIT..."); });
        }
		/* scan thru all checked products inside the frozen table*/
		checked_products.each(function() {
			/* each product checkbox has a unique "prod" attribute (e.g prod="p1"),
			   all forecast inputs for the product have a 'prod' attribute (e.g. prod="p1") */
			var prod_attr = $(this).attr("prod")
				,new_val  = 0
				,old_val  = 0;


			/* each week checkbox has a unique "week" attribute (e.g. week="w1")
			   all forecast inputs under the same week have a 'week' attribute (e.g. week="w1") */
			/* push the update into the browser queue to allow UI update */
			loadChain.push(function() {
						$("input.week:checked").each(function(){
							var prod_week = "[prod=" + prod_attr + "][week=" + $(this).attr("week") + "]";
							/* process all inputs with both prod and week */
							$("input.lfc" + prod_week).each(function() {
								if ( !$(this).is(":disabled") ) {
									entries  = entries + 1;
									old_val  = numeral().unformat( $(this).val() );
									new_val  = old_val + ( old_val * grow_factor / 100 );
									/* value is changed: flag it as changed, change background color & apply new value */
									if (old_val !== new_val) {
										$(this).attr("dirty", 1).addClass( "changed" ).val( numeral( new_val ).format() );
                                        // alert(new_val)
                                        global.changes_count++;
										refresh_lfc( $(this) );
									}
								}
							});
						});
					});

		});
        loadChain.push(function() { $("div.loader").hide(); });
        loadChain.push(function() { if (entries == 0) {
										dhx_alert( "Please check at least one " + <cfoutput>"#lcase(application.returned_customer_setting.item_label)#"</cfoutput>
												+ " and at least one period\n to apply the growth factor percentage." );
								  }});
        loadChain.start();
	});

	$("#save").click(function() {
		show_loader("SAVING CHANGES, PLEASE WAIT...");
		/* remove unchanged inputs to save time quicker */
		$("input.lfc").each(function(){
		 	if ( $(this).attr("dirty") == "0" ) {
		 		$(this)[0].removeAttribute("name");
		 	}
		});
		$("input[name=action]").val( "save_volume" );
		$("#vp_form").submit();
	});

	$("#events").click(function() {
		popupInCenter("/planners/consumer_events/events/calendar.cfm?fromPlanner=1", "ConsumerEvents");
	});

	$("#add_products").click(function() {
		if ( ignore_changes() ) {
			popupInCenter("/Common_Files/contracts/product_Select_V1.cfm?Formname=vp_add_items&Return_Value_Field_Name=product_list", "ProductSelectWindow");
		}
	});

	$("#delete_products, #delete_groups").click(function() {
		if ( ignore_changes() ) {
			var products          = [],
				selected_rows     = [],
				parent_tr         = null,
				rowid             = null,
				program_count     = null,
				allowed_to_delete = true;
			/* gather all checked products */
			$('#vp_grid_frozen input.product:checked').each(function() {
				products.push( $(this).attr("data") );
				parent_tr = $(this).parents("tr");
				if (parent_tr) {
					rowid = parent_tr.attr("id"),
					program_count = grid.jqGrid('getCell', rowid, 'program_count');
					// console.log(program_count);
					if (parseInt(program_count) > 0) {
						allowed_to_delete = false;
						dhx_alert( "Selected product[s] have programs created in this <cfoutput>#Application.PlannerLabel#</cfoutput>. These product[s] cannot be removed from the <cfoutput>#Application.PlannerLabel#</cfoutput>." );
		            	for (var i=0; i<selected_rows.length; i++) {
		            		selected_rows[i].removeClass("ui-state-hover");
		            	}
						return false;
					}
					if (allowed_to_delete) {
						// console.log(grid.jqGrid('getRowData', rowid));
						selected_rows.push( parent_tr );
						parent_tr.addClass("ui-state-hover");
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
					            if ( !ok_to_delete ) {
					            	for (var i=0; i<selected_rows.length; i++) {
					            		selected_rows[i].removeClass("ui-state-hover");
					            	}
					            }
					            else {
					                // $("input[name=rowid]").val( rowid );
									show_loader("DELETING IN PROGRESS, PLEASE WAIT...");
									/* remove ALL inputs to save time quicker */
									$("input.lfc").removeAttr("name");
					                $("input[name=product_list]").val( products.join(",") );
					                $("input[name=action]").val( "delete_products" );
					                $("#vp_form").submit();
					            };
	        				}
	    		});
			}
		}
	});

	$("#add_groups").click(function() {
		if ( ignore_changes() ) {
			$("form[name=add_groups]").submit();
		}
	});

	$("#create").click(function() {
		var products = [];
		/* gather all checked products */
		$('#vp_grid_frozen input.product:checked').each(function() {
			products.push( $(this).attr("data") );
		});
		/* none of the products was checked - stop */
		if (products.length == 0) {
			dhx_alert( "Please check at least one product." );
			return false;
		}
		$("input[name=product_list]").val( products.join() );
		$("form[name=create_program]").submit();
	});

	/* applies the classes to the headers once the grid configuration is complete. */
	applyClassesToHeaders(grid);
	grid.jqGrid("setFrozenColumns");

	/* this function recalculate values related to latest forecast (e.g. latest fc total) */
	function refresh_lfc( jqObj ) {
        jqObj.attr("dirty", 1).addClass( "changed" );
        global.changes_count++;

		var  lfc         = numeral().unformat( jqObj.val() )
		    ,prod_attr   = "[prod=" + jqObj.attr("prod") + "]"
		    ,week_attr   = "[week=" + jqObj.attr("week") + "]"
		    ,prod_week   = prod_attr + week_attr
		    ,$act_pct_fc = $("span.act_pct_fc" + prod_week);

		/* calculate act % fc */
		if ( $act_pct_fc.length ) {
			/* actual % fc exists */
			var $actual = $("span.actual" + prod_week);
			if ( $actual.length ) {
				/* actual value exists perform calculation */
				var actual      = numeral().unformat( $actual.text() )
				    ,act_pct_fc = ( lfc == 0 ? 0 : actual / lfc );
				$act_pct_fc.text( numeral( act_pct_fc ).format( "0,%" ) ).addClass( "changed" );
			}
			else {
				/* missing actual value calculation cannot be done */
				$act_pct_fc.text("");
			}
		}

		var $fc_pct_py = $("span.fc_pct_py" + prod_week);
		/* calculate fc % py */
		if ( $fc_pct_py.length ) {
			/* fc % py exists */
			var $py = $("span.py" + prod_week);
			if ( $py.length ) {
				/* py exists */
				var py = numeral().unformat( $py.text() )
				    ,fc_pct_py = ( py == 0 ? 0 : lfc / py );
				$fc_pct_py.text( numeral( fc_pct_py ).format( "0,%" ) ).addClass( "changed" );
			}
			else {
				/* missing py value calculation cannot be done */
				$fc_pct_py.text("");
			}
		}

		/* calculate fc total */
		var $fc_sum = $("span.fc_sum" + prod_attr);
		if ( $fc_sum.length ) {
			/* fc sum exists */
			var fc_sum = 0;
			$("input.lfc" + prod_attr).each(function(){
				fc_sum += numeral().unformat( $(this).val() );
			});
			$fc_sum.text( numeral( fc_sum ).format() ).addClass("changed") ;
		}

		/* calculate fc total by week */
		var $fc_week = $("span.fc_week" + week_attr);
		if ( $fc_week.length ) {
			/* fc week exists */
			var fc_sum = 0;
			$("input.lfc" + week_attr).each(function(){
				fc_sum += numeral().unformat( $(this).val() );
			});
			$fc_week.text( numeral( fc_sum ).format() ).addClass("changed") ;
		}

		/* calculate fc overall total */
		var $fc_total = $("span.fc_total");
		if ( $fc_total.length ) {
			/* fc total exists */
			var fc_sum = 0;
			$("input.lfc").each(function(){
				fc_sum += numeral().unformat( $(this).val() );
			});
			$fc_total.text( numeral( fc_sum ).format() ).addClass("changed") ;
		}

		/* calculate lift */
		var $lift = $("span.lift" + prod_week);
		if ( $lift.length ) {
			var $base = $("span.base" + prod_week);
			if ( $base.length ) {
				var base     = numeral().unformat( $base.text() )
				var lift_amt = lfc - base;
				$lift.text( numeral( lift_amt ).format() ).addClass("changed") ;
			}
			else {
				/* missing base value calculation cannot be done */
				$lift.text("");
			}
		}

		/* calculate lift total */
		var $lift_sum = $("span.lift_sum" + prod_attr);
		if ( $lift_sum.length ) {
			/* lift sum exists */
			var lift_sum = 0;
			$("span.lift" + prod_attr).each(function(){
				lift_sum += numeral().unformat( $(this).text() );
			});
			$lift_sum.text( numeral( lift_sum ).format() ).addClass("changed") ;
		}
	}

	$("#add_filter").click(function(){
		if ( ignore_changes() ) {
			var filter = $("select[name=filter_product_group_level_id]");
			if ( filter.val() === "" ) {
				dhx_alert( "Please select a group option in the filter products dropdown first." );
				filter.focus();
			}
			else {
				$("input[name=filter_product_group_level_id]").val( filter.val() );
				/* update the product group level id used in add filter popup */
				$("form[name=add_filter] input[name=product_group_level_id]").val( filter.val() );
				$("form[name=add_filter]").submit();
			}
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

		$( "#save_filter" ).click( function() {
			show_loader( "Saving filter...", -1000 );
			save_filter();
		});


	$("#reset_filter").click(function(){
		if ( ignore_changes() ) {
			$("input[name=filter_product_list]").val( "" );
            $("input[name=filter_product_group_level_id]").val( "" );
            show_loader();
			save_filter();
			$("form[name=filter_products]").submit();
		}
	});

	$("select[name=filter_product_group_level_id]").change(function(){
		/* clear out the previous selected list used in add filter popup */
		$("input[name=filter_product_list]").val( "" );
	});

	/***********************************/
	/* call back functions from popups */
	/***********************************/
	function callback_filter_products() {
        show_loader();
		$("form[name=filter_products]").submit();
	}

	function callback_add_groups() {
		$("form[name=vp_add_items]").submit();
	}

	function callback_add_products() {
		$("form[name=vp_add_items]").submit();
	}

	function callback_restore_default() {
		$("input[name=show_base_lift]").val( "" );
		$("input[name=filter_product_list]").val( "" );
		$("input[name=filter_product_group_level_id]").val( "" );
		$("input[name=forecasts]").attr("disabled", "disabled");
		$("form[name=filter_products]").submit();
	}

	/* disable hovering columns on th */
	$(".ui-jqgrid-labels th.ui-th-column").unbind("mouseenter").unbind("mouseleave");

	$("th:has(:checkbox)").click(function(){
		var cb = $(this).find("input[type=checkbox]");
		cb.attr("checked", !cb.attr("checked"));

		if ( cb.hasClass("all_periods") ) {
			$(".week").attr("checked", cb.attr("checked") ? true : false);
		}
	});

	<!---  click: refresh summary  --->
	function get_summary( plannerID ) {
		$.ajax({
		  async: true
		 ,data: {
		 			method: "getPlannerSummaryStruct"
		 			,plannerID: plannerID
		 			,returnFormat: "JSON"
				}
		 ,dataType: "json"
		 ,success: function( response )
		 	{
				if ( response.status == "success" ) {
					refresh_summary( response );
				}
			}
		 ,type: "post"
		 ,url: "/mvc/models/planner/plannermanager.cfc"
		});
	}

	<!---  refresh summary  --->
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

    $("#export").click(function() {
			$('input[name=csv_file_name]').val( "planner-volume-plan-"
												+ <cfoutput>"#getPlanner.Planner_Number#-"</cfoutput>
			                                    + Math.random().toString(36).substring(7)    // append an arbitrary unique substring
												+ ".csv");
			// exclude rows with GROUP class, PLANNER class
			var body_rows = $("#vp_grid tbody tr").filter(function() { return $(this).hasClass("GROUP") || $(this).hasClass("PLANNER")
																					? 0
																					: 1 }),
				// pull headers from table created by jqGrid
				header_row = $("div.ui-jqgrid-hbox thead tr"),
				// needs to expand to parent 'gview_vp_grid' div created by jqGrid to get header and body content in 'vp_grid' table
				csv_text   = $("#gview_vp_grid").table2CSV( { findTHEAD:header_row, findTBODY:body_rows, csvExclude: 'csvExclude', delivery:"value" } );
			$("#csv_text").val(csv_text);
			$("#csv_form").submit();
		});

	</script>

    <cfinclude template="\common_files\popup2022.cfm">
</cf_layout_planner>
