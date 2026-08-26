<!---------------------------------------------------------------------------------------------------------------------
      Template:  \planners\create\volume_plan_config.cfm
          Date:  2015 July
        Author:  Chris Nguyen
       Purpose:  This page controls the volume plan content

    Parameters:  form.forecasts - comma-delimited list of forecasts to be included
                 form.week_month
                 form.product_group_level_id
                 form.uom
----------------------------------------------------------------------------------------------------------------------->
<cf_layout-bare jQueryUI_widgets='full' page_title="Volume Plan Options">

    <cfinclude template="planner_volume_constants.cfm">
    <cfset jqueryUI.widgets = 'full'>
    <cfset labelManager = createObject( "component", "components.settings.Labels.Labels" ).init()>

    <cfset structAppend(url, createObject( "component", "components.udf" ))>

    <cffunction name="displayForecast" output="true">
        <cfargument name="forecast" type="string" required="true">
        <cfargument name="checked" type="boolean" required="false" default=false>

    <cfif arguments.forecast eq constants.actual>
        <li class="ui-state-default">
            <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
            <input type="checkbox" class="forecast" id="fc_actual" <cfif arguments.checked> checked </cfif> value="#constants.actual#">
            <label for="fc_actual">Actual</label>
        </li>
    <cfelseif arguments.forecast eq constants.actual_percent_forecast>
        <li class="ui-state-default">
            <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
            <input type="checkbox" class="forecast" id="fc_actpc" <cfif arguments.checked> checked </cfif> value="#constants.actual_percent_forecast#">
            <label for="fc_actpc">Actual % FCST</label>
        </li>       
    <cfelseif arguments.forecast eq constants.aop>
            <li class="ui-state-default">
                <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
                <input type="checkbox" class="forecast" id="fc_aop" <cfif arguments.checked> checked </cfif> value="#constants.aop#">
                <label for="fc_aop">AOP</label>
            </li>
    <cfelseif arguments.forecast eq constants.demand_plan>
        <li class="ui-state-default">
            <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
            <input type="checkbox" class="forecast" id="fc_dmd_pln" <cfif arguments.checked> checked </cfif> value="#constants.demand_plan#">
            <label for="fc_dmd_pln">Demand</label>
        </li>
    <cfelseif arguments.forecast eq constants.forecast_percent_prior_year>
        <li class="ui-state-default">
            <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
            <input type="checkbox" class="forecast" id="fc_pcpy" <cfif arguments.checked> checked </cfif> value="#constants.forecast_percent_prior_year#">
            <label for="fc_pcpy">FCST % LY</label>
        </li>
    <cfelseif arguments.forecast eq constants.indirect_percent>
        <li class="ui-state-default">
            <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
            <input type="checkbox" class="forecast" id="fc_ind_perc" <cfif arguments.checked> checked </cfif> value="#constants.indirect_percent#">
            <label for="fc_ind_perc">Indirect % FCST</label>
        </li>
    <cfelseif arguments.forecast eq constants.indirect_volume>
        <li class="ui-state-default">
            <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
            <input type="checkbox" class="forecast" id="fc_ind_vol" <cfif arguments.checked> checked </cfif> value="#constants.indirect_volume#">
            <label for="fc_ind_vol">Indirect Volume</label>
        </li>
        <cfelseif arguments.forecast eq constants.prior_year>
            <li class="ui-state-default">
                <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
                <input type="checkbox" class="forecast" id="fc_py" <cfif arguments.checked> checked </cfif> value="#constants.prior_year#">
                <label for="fc_py">LY - Last Year</label>
            </li>
        <cfelseif arguments.forecast eq constants.latest_forecast>
            <li class="ui-state-default">
                <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
                <input type="checkbox" class="forecast" id="fc_latest" <cfif arguments.checked> checked </cfif> value="#constants.latest_forecast#">
                <label for="fc_latest">Latest FCST</label><br>
                &nbsp; &nbsp; &nbsp; &nbsp; <input type="checkbox" name="show_base_lift" id="show_base_lift" <cfif form.show_base_lift eq "1">checked=checked</cfif>>
                <label for="show_base_lift">Base & Lift</label>
            </li>
        <cfelseif arguments.forecast eq constants.locked_forecast>
            <li class="ui-state-default">
                <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
                <input type="checkbox" class="forecast" id="fc_lock" <cfif arguments.checked> checked </cfif> value="#constants.locked_forecast#">
                <label for="fc_lock">Locked FCST</label>
            </li>
        <cfelseif arguments.forecast eq constants.YTD>
            <li class="ui-state-default">
                <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>
                <input type="checkbox" class="forecast" id="fc_ytd" <cfif arguments.checked> checked </cfif> value="#constants.YTD#">
                <label for="fc_ytd">YTD</label>
            </li>
        </cfif>
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
    <cfsavecontent variable="variables.uncompressed">
        <cfoutput>
        <form>
            <style>
                h2 { border-bottom: 1px dotted ##CCC; font-size: 13px;  }
                ##actions { margin-top: 25px; }
                body { padding: 5px 15px; }
                div { margin-bottom: 20px; }
                a { margin-right: 20px; }
                ul { margin:0; padding:0; }
                li { list-style-type:none; padding:3px; margin:5px 0; width:150px; }
                li span { position: absolute; }
                li input { margin-left: 20px; }
                label { cursor: pointer; }
                input[type="checkbox"], input[type="radio"] {
                    /*-webkit-appearance: none;
                    appearance: none;*/
                    box-sizing: content-box;
                    cursor: pointer;
                    height: 1em;
                    position: relative;
                    top: 1px;
                    width: 1em;
                }
            </style>

            <cfscript>
                // retrieve previous selected forecasts for this planner
                saved_forecasts = getUserData( search_column = "Planner_ID", search_id = form.plannerID );

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

            <div id="include">
                <h2>Include Forecasts</h2>
                <p>Click the arrow & drag using the mouse to place it in a desired display sequence.</p>
                <ul>
                    <!--- process the selected forecasts first --->
                    <cfloop list="#form.forecasts#" index="variables.forecast">
                        <cfset displayForecast( variables.forecast, true )>
                    </cfloop>

                    <!--- now process the unselected forecasts --->
                    <cfloop list="#constants.template_forecasts#" index="variables.forecast">
                        <cfif listFind(form.forecasts, variables.forecast) eq 0>
                            <cfset displayForecast( variables.forecast, false )>
                        </cfif>
                    </cfloop>
                </ul>
                <!--- <input type="checkbox" name="show_base_lift" id="show_base_lift" <cfif form.show_base_lift eq "1">checked=checked</cfif>>
                <label for="show_base_lift">Show base & lift volume under Latest FCST</label> --->
            </div>

            <div>
                <h2>Show Totals</h2>
                <input type="checkbox" class=sm name="totals" id="show_totals" <cfif form.totals neq "">checked</cfif> value="1">
                <label for="show_totals">Display total rows</label>
            </div>

            <div>
                <h2>Show Forecasts By</h2>
                <input type="radio" name="period" id="period_w" <cfif form.period eq constants.by_week>checked</cfif> value="#constants.by_week#">
                <label for="period_w">Week</label> <br>
                <input type="radio" name="period" id="period_m" <cfif form.period neq constants.by_week>checked</cfif> value="#constants.by_month#">
                <label for="period_m">Month</label>
            </div>

            <div>
                <h2>Show Products By</h2>
                <cfset variables.productFilterAttributes = plannerManager.productFilterAttributes( getPlanner.Planner_Template_ID )>
                <cfloop query="variables.productFilterAttributes">
                    <cfif variables.productFilterAttributes.Product_Group_Level_ID eq constants.type_group>
                        <input type="radio" name="product_group_level_id" id="type_group"
                            <cfif form.product_group_level_id eq constants.type_group>checked</cfif>
                            default=#variables.productFilterAttributes.default_view# value="#constants.type_group#">
                        <label for="type_group">#labelManager.getProductLabelByGroupLevelID( 8 )#
                            <cfif variables.productFilterAttributes.default_view eq "1">(default)</cfif></label><br>

                    <cfelseif variables.productFilterAttributes.Product_Group_Level_ID eq constants.q_brand>
                        <input type="radio" name="product_group_level_id" id="q_brand"
                            <cfif form.product_group_level_id eq constants.q_brand>checked</cfif>
                            default=#variables.productFilterAttributes.default_view# value="#constants.q_brand#">
                        <label for="q_brand">#labelManager.getProductLabelByGroupLevelID( 11 )#
                            <cfif variables.productFilterAttributes.default_view eq "1">(default)</cfif></label><br>

                    <cfelseif variables.productFilterAttributes.Product_Group_Level_ID eq constants.type_code>
                        <input type="radio" name="product_group_level_id" id="type_code"
                            <cfif form.product_group_level_id eq constants.type_code>checked</cfif>
                            default=#variables.productFilterAttributes.default_view# value="#constants.type_code#">
                        <label for="type_code">#labelManager.getProductLabelByGroupLevelID( 12 )#
                            <cfif variables.productFilterAttributes.default_view eq "1">(default)</cfif></label><br>

                    <cfelseif variables.productFilterAttributes.Product_Group_Level_ID eq constants.brand>
                        <input type="radio" name="product_group_level_id" id="brand"
                            <cfif form.product_group_level_id eq constants.brand>checked</cfif>
                            default=#variables.productFilterAttributes.default_view# value="#constants.brand#">
                        <label for="brand">#labelManager.getProductLabelByGroupLevelID( 13 )#
                            <cfif variables.productFilterAttributes.default_view eq "1">(default)</cfif></label><br>

                    <cfelseif variables.productFilterAttributes.Product_Group_Level_ID eq constants.prod_var_a>
                        <input type="radio" name="product_group_level_id" id="prod_var_a"
                            <cfif form.product_group_level_id eq constants.prod_var_a>checked</cfif>
                            default=#variables.productFilterAttributes.default_view# value="#constants.prod_var_a#">
                        <label id="prod_var_a">#labelManager.getProductLabelByGroupLevelID( 15 )#
                            <cfif variables.productFilterAttributes.default_view eq "1">(default)</cfif></label><br>
                    </cfif>
                </cfloop>   <!--- query="variables.product_groups" --->
                <input type="radio" name="product_group_level_id" id="product_group_0"
                    <cfif form.product_group_level_id eq "">checked</cfif>
                    default=#(variables.productFilterAttributes.recordCount eq 0 ? 1 : 0)# value="">
                    <label for="product_group_0">#application.returned_customer_setting.item_label#</label> <br>
            </div>

            <!---<cfset parentPlanner = plannerManager.getPlanner( form.plannerID )>--->

            <cfset plannerUOMS= "">
            <cfif getPlanner.UOM_CS EQ "1">
                <cfset plannerUOMS= ListAppend(plannerUOMS, get_UOM(1).Unit_Of_Measure_Desc, ",")>
            </cfif>
            <cfif getPlanner.UOM_LB EQ "1">
                <cfset plannerUOMS= ListAppend(plannerUOMS, get_UOM(2).Unit_Of_Measure_Desc, ",")>
            </cfif>
            <!---
            Currently we do not have logic to display Eaches in volume plan tab.
            We can uncomment this code when we add logic to display Eaches in volume plan tab.
            <cfif getPlanner.UOM_EA EQ "1">
                <cfset plannerUOMS= ListAppend(plannerUOMS,"Eaches",",")>
            </cfif>
            --->

            <div>
                <h2>Select UOM</h2>
                <cfloop list="#plannerUOMS#" index="uoms">
                    <cfif uoms EQ get_UOM(1).Unit_Of_Measure_Desc>
                        <cfset id = "uom_cs">
                        <cfset values = "C">
                    </cfif>
                    <cfif uoms EQ get_UOM(2).Unit_Of_Measure_Desc>
                        <cfset id = "uom_lbs">
                        <cfset values = "L">
                    </cfif>
                    <cfif uoms EQ get_UOM(5).Unit_Of_Measure_Desc>
                        <cfset id = "uom_ea">
                        <cfset values = "E">
                    </cfif>
                    <input type="radio" name="uom" id="#id#" <cfif form.uom eq values>checked</cfif> value="#values#">
                    <label for="#id#">#uoms#</label>  <br>
                </cfloop>
            </div>

            <div id="actions">
                <a href="##" id="apply">#application.util.string.linkFormat("apply selections")#</a>
                <a href="##" id="restore">#application.util.string.linkFormat("restore default")#</a>
                <a href="##" id="cancel">#application.util.string.linkFormat("close window")#</a>
            </div>
        </form>
        </cfoutput>

        <cfinclude template="/common_files/dhx_message.cfm">

        <!----------------------------------------------------------------------------------------------------------------------------------------------------->
        <script>
            $("#cancel").click(function() {
                window.close();
            });
            $("#apply").click(function() {
                var forecasts = [];
                /* gather all checked forecasts */
                $('input.forecast:checked').each(function() {
                    forecasts.push( $(this).val() );
                });
                /* none of the forecasts was checked - stop */
                if (forecasts.length == 0) {
                    dhtmlx.alert( "Please check at least one checkbox under the include forecasts section." );
                    return false;
                }

                var show_base_lift = ($("input[name=show_base_lift]").is(":checked") ? "1" : "");

                $.ajax({
                        url: "/components/udf.cfc",
                        data: {
                                method: "saveUserData",
                                search_column: "Planner_ID",
                                search_id: <cfoutput>#form.plannerID#</cfoutput>,
                                json: JSON.stringify( { forecasts: forecasts.join(), show_base_lift: show_base_lift } )
                        },
                        type: "POST"
                });

                /* refresh parent page with new selections */
                $("input[name=forecasts]", opener.document).val( forecasts.join() );
                $("input[name=period]", opener.document).val( $("input[name=period]:checked").val() );
                $("input[name=product_group_level_id]", opener.document).val( $("input[name=product_group_level_id]:checked").val() );

                var volume_plan_uom = $("input[name=uom]:checked").val();
                $("input[name=uom]", opener.document).val( volume_plan_uom );
                $("input[name=totals]", opener.document).val( ($("input[name=totals]").is(":checked") ? "1" : "") );

                $("input[name=show_base_lift]", opener.document).val( show_base_lift );
                opener.show_loader();
                $("form[name=filter_products]", opener.document).submit();

                /* in edit mode when uom is changed save the uom's change into the database */
                <cfif (form.mode is constants.edit)>
                    if (volume_plan_uom !== <cfoutput>"#form.uom#"</cfoutput>) {
                         $.ajax({
                                asynch: false,
                                url: "/mvc/models/planner/plannerManager.cfc",
                                data: {
                                        method: "saveVolumePlanUOM",
                                        plannerID: <cfoutput>#form.plannerID#</cfoutput>,
                                        uom: volume_plan_uom
                                },
                                type: "POST"
                        });
                    }
                </cfif>


                window.close();
            });
            $("#restore").click(function() {
                opener.show_loader();
                opener.callback_restore_default();
                window.close();
            });
            $("#include ul").sortable({ axis: 'y' });
        </script>
    </cfsavecontent>
    <cfoutput>
        #variables.uncompressed#
    </cfoutput>
    <!--- <cfoutput>#( variables.uncompressed )#</cfoutput> --->
</cf_layout-bare>