<!---------------------------------------------------------------------------------------------------------------------
	  Template:  \planners\create\planner_volume_constants.cfm
		  Date:  2015 July
		Author:  Chris Nguyen
	   Purpose:  This page defines the default content on volume plan page by the use of url variables

	   Remarks:  These variables are populated in this file.

				 request.plannerID     :: planner ID
				 request.product_label :: product group level title

				 form.product     :: product group level
				 form.forecasts   :: comma-delimited list of forecasts to display
				 form.period      :: 'W' = by weeks | anything else is by months
				 form.mode        :: 'E' = edit mode | anything else is read only mode
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
	param name="form.plannerID"         	default="";
	plannerManager                        = createObject( "component", "mvc.Models.Planner.PlannerManager" );
	labelManager                          = createObject( "component", "components.settings.Labels.Labels" ).init();

	request.plannerID                     = form.plannerID;
	getPlanner                            = plannerManager.getPlanner( request.plannerID );
	request.defaultProductFilterAttr      = plannerManager.productFilterAttributes( getPlanner.Planner_Template_ID, 1 );

	constants.edit                        = 'E';
	constants.volume_plan_tab             = "2";    // tab position for volume plan ( note: position is based on JS, it starts from zero )
	constants.approved                    = 3;

	constants.by_week                     = "W";
	constants.by_month                    = "M";
	constants.by_description              = "D";
	constants.by_type_code                = "T";

	constants.cases                       = "C";
	constants.pounds                      = "L";

	constants.item                        = "9";
	constants.type_code                   = "12";
	constants.type_group                  = "8";
	constants.q_brand                     = "11";
	constants.brand                       = "13";
	constants.prod_var_a                  = "15";

	constants.aop                         = "AOP";
	constants.prior_year                  = "Prior_Yr";
	constants.locked_forecast             = "Locked_Forecast";
	constants.latest_forecast             = "Forecast";
	constants.latest_forecast_base        = "Forecast_base";
	constants.latest_forecast_lift        = "Forecast_lift";
	constants.forecast_percent_prior_year = "Forecast_Percent_PY";
	constants.actual                      = "Actual";
	constants.actual_percent_forecast     = "Actual_Percent_Forecast";
	constants.indirect_volume             = "Indirect_Volume";
	constants.indirect_percent            = "Indirect_Volume_Percent_Forecast";
	constants.demand_plan                 = "Demand_Plan";
	constants.YTD																		= "YTD";
	constants.planner_week_start		  = application.appsettingsget.get_Setting('Retail_Planner_Week_Start');
	Retail_Demand_Plan_Enabled			  = application.appsettingsget.get_Setting('Retail_Demand_Plan_Enabled');

	constants.template_forecasts          = [];
	constants.default_forecasts           = [];

	// determine which forecasts are available based on planner template settings
	for ( variables.column_prefix in [ constants.actual,constants.actual_percent_forecast, constants.aop, constants.demand_plan, constants.forecast_percent_prior_year, 
																													constants.indirect_volume, constants.indirect_percent, constants.latest_forecast , constants.locked_forecast, constants.prior_year, constants.YTD ] ) {
		// gather available forecasts
		if ( getPlanner[ variables.column_prefix & "_Display" ][1] eq '1' ) {
			// locked forecast is available only for approved planner
			// if ( variables.column_prefix neq constants.locked_forecast or getPlanner.status_ID eq constants.approved ) {
			if ( variables.column_prefix neq constants.demand_plan or Retail_Demand_Plan_Enabled eq '1' ) {
				arrayAppend(constants.template_forecasts, variables.column_prefix );

				// gather default forecasts
				if ( getPlanner[ variables.column_prefix & "_Default" ][1] eq '1' ) {
					arrayAppend(constants.default_forecasts, variables.column_prefix );
				}
			}
		}
	}

	constants.template_forecasts               = arrayToList(constants.template_forecasts);
	constants.default_forecasts                = arrayToList(constants.default_forecasts);

	// default settings for volume plan page

	param name="form.forecasts"              default=constants.default_forecasts;       // forecasts to display based on template setting
	param name="form.period"                 default=constants.by_week;                 // week | month
	param name="form.mode"                   default="";                                // edit | read only
	param name="form.totals"                 default="";                                // display totals indicator
	param name="form.filter_product_group_level_id" default="";
	param name="form.show_base_lift"         default="";
	param name="form.parent_planner_id"      default="";
	param name="form.indirect_planner"       default="0";

	if ( not structKeyExists(form, "uom") ) {
		form.uom = ( getPlanner.volume_plan_uom eq '2' ? constants.pounds : constants.cases );  // uom based on template setting
	}

	if ( not structKeyExists(form, "product_group_level_id") ) {
		form.product_group_level_id = "";
		// product group level (brand, q_brand, type code, type brand, etc...) when it is empty display the actual product description
		if ( request.defaultProductFilterAttr.recordCount ) {

			if ( request.defaultProductFilterAttr.lookupTable eq "Brand" ) {
				form.product_group_level_id = constants.brand;
			}
			else if ( request.defaultProductFilterAttr.lookupTable eq "Q_Brand_Desc" ) {
				form.product_group_level_id = constants.q_brand;
			}
			else if ( request.defaultProductFilterAttr.lookupTable eq "Type_Code_Desc" ) {
				form.product_group_level_id = constants.type_code;
			}
			else if ( request.defaultProductFilterAttr.lookupTable eq "Type_Group_Desc" ) {
				form.product_group_level_id = constants.type_group;
			}
			else if ( request.defaultProductFilterAttr.lookupTable eq "Prod_Var_A" ) {
				form.product_group_level_id = constants.prod_var_a;
			}
			else {
				form.product_group_level_id = constants.item;
			}
		}
	}

	request.product_label = ( form.product_group_level_id eq ""
								? application.returned_customer_setting.item_label
								: labelManager.getProductLabelByGroupLevelID( form.product_group_level_id ) );

	request.planner_labels   = labelManager.plannerLabels();
	form.parent_planner_id   = ( val( getPlanner.parent_planner_id ) ? getPlanner.parent_planner_id : getPlanner.Planner_ID );
	form.planner_template_id = getPlanner.Planner_Template_ID;
    form.indirect_planner    = ( val( getPlanner.parent_planner_id ) ? 1 : 0 );

    request.planner_targets_enabled = application.util.query.get_Setting("planner_targets_enabled", 0);


	request.planner_category = getPlanner.Category;

	udf = createObject( "component", "components.udf" );

	// define/populate request shared variables for planner indirect categories
	udf.is_planner_indirect_category( planner_category = getPlanner.Category );
</cfscript>
