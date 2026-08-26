<!---------------------------------------------------------------------------------------------------------------------
	  Template: \CustomTags\Layout_Planner.cfm
		  Date:  2016 August
		Author:  Chris Nguyen
	   Purpose:  Layout template for planner

	Parameters:  form.Mode = required, blank (read-only) | 'E' (edit)
				 form.plannerID = required, numeric value represents the planner ID
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start"><!DOCTYPE html>
	<html>
	<head>

		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<cfinclude template="/common_files/jQuery.cfm">

		<cfinclude template="/planners/create/planner_volume_constants.cfm">

		<cfsavecontent variable="head_content">
			<cf_include files="/common_files/tabnav.css, /styles/ionicons.min.css, /styles/css-loader.css">

			<cfset jQueryUI.widgets = "tooltip,datepicker,effect-highlight">
			<cfinclude template="/common_files/jQueryUI.cfm">
			<style>
				body {
					margin: 0;
					padding: 1px 4px;
                    /* border: 1px solid gray; overflow: hidden; */
				}
				#topHeader {
					width: 100%;
				}
				#planner_overview {
					color: #333;
					float: left;
					font-size: 11px;
					font-weight: bold;
					padding-top: 5px;
					line-height: 15px;
					text-align: center;
					width: <cfif form.indirect_planner> 64% <cfelse> 54% </cfif>;
				}
				#planner_overview div {
					float: left;
				}
				i.dim {
					font-style: normal;
					opacity: 0.75;
				}
				i.link {
					cursor: pointer;
					padding: 0 0 0 5px;
				}
				div.status {
					font-size: 12px;
					margin-top: 7px;
					opacity: 0.75;
				}
				div.planner_number {
					<cfif not form.indirect_planner>
						margin-top: 7px;
					</cfif>
				}
				a#parent_planner {
					font-size2: 10px;
				}

				#planner_summary {
					float: right;
					<cfoutput>
					width: #IIf(form.indirect_planner is 0, DE("45%"), DE("25%"))#;
					</cfoutput>
				}
				#scorecard_summary {
					float: left;
					<cfoutput>
					min-width: #IIf(form.indirect_planner is 0, DE("80%"), DE("40%"))#;
					</cfoutput>
					padding:5px;
				}
				#summary_table {
					background-color: white;
					border-collapse: collapse;
					border-spacing: 0px;
					border: 2px solid #b2b2b2;
					color: #333;
					font-size: 10px;
					padding: 0;
					width: 100%;
				}
				#summary_table th {
					background-color: #C4DCF1;
					border-bottom: 1px solid #666;
					padding: 4px 10px 4px 4px;
					text-align: right;
					font-weight: normal;
				}
				#summary_table td {
					border-bottom: 1px dotted #666;
					font-size: 9px;
					padding: 4px 10px 4px 4px;
					text-align: right;
				}
				#summary_table td.label {
					font-weight: bold;
					text-align: left;
				}
				#summary_table th.last, #summary_table td.last {
					border-right: 1px dotted #666;
				}
				#summary_table th.lastCol, #summary_table td.lastCol {
					border-right: 1px solid #666;
				}

				#ly_cs, #ly_lbs, #ly_sales, #ly_trade,
				#locked_cs, #locked_lbs, #locked_sales, #locked_trade,
				#latest_cs, #latest_lbs, #latest_sales, #latest_trade,
				#actual_cs, #actual_lbs, #actual_sales, #actual_trade, td.clst {
					font-weight: bold; color: #333;
				}
				#ly_cs_ly, #ly_lbs_ly, #ly_sales_ly, #ly_trade_ly,
				#locked_cs_ly, #locked_lbs_ly, #locked_sales_ly, #locked_trade_ly,
				#latest_cs_ly, #latest_lbs_ly, #latest_sales_ly, #latest_trade_ly,
				#actual_cs_ly, #actual_lbs_ly, #actual_sales_ly, #actual_trade_ly,
				#ly_cs_locked, #ly_lbs_locked, #ly_sales_locked, #ly_trade_locked,
				#locked_cs_locked, #locked_lbs_locked, #locked_sales_locked, #locked_trade_locked,
				#latest_cs_locked, #latest_lbs_locked, #latest_sales_locked, #latest_trade_locked,
				#actual_cs_locked, #actual_lbs_locked, #actual_sales_locked, #actual_trade_locked {
					font-style: normal;
					-ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=75)";
					opacity: 0.75;
				}
				th.medium {
					width: 10%;
				}
				th.small {
					width: 6%;
				}
			</style>
		</cfsavecontent>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
		<cfhtmlhead text="#application.util.string.compress( head_content )#">
	</head><!--------------------------------------------------------------------------------------------------------------------->
	<body>
	<cfscript>
		param name="form.include_slotting" default="1";

		request.queries                 = {};
		request.components              = {};

		request.components.planner      = createobject( "component", "mvc.models.planner.plannermanager" );
		request.components.lock         = createObject("component", "components.general.lock");
		request.components.paymenthistory = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager");

		cacheSecs = val(application.util.query.get_setting("Planner_Cache_Seconds", 0));
		if(isdefined("url.clearCache") && url.clearCache eq "1") cacheSecs = 0; // Do not use cached query
		request.queries.planner_summary = request.components.planner.getPlannerSummaryData( form.plannerID, form.include_slotting, cacheSecs );
		request.queries.planner_accrual_summary = request.components.planner.getPlannerAccrualSummaryData( form.plannerID);

		request.lock_status             = request.components.lock.getStatus("Planner", form.plannerID);
		request.accrual_exist			= request.components.paymenthistory.getAccrualExist(0, '', form.plannerID);
		request.payment_history_exist	= request.components.paymenthistory.getPaymentHistoryExist('', form.plannerID);
		request.ezrate_exist			= request.components.planner.plannerEZRatesExists(form.plannerID);

	</cfscript>

	<!---------------------------------------->
	<!--- display header + horizontal menu --->
	<!---------------------------------------->
	<cfsavecontent variable="variables.uncompressed">
		<cffunction name="unlock_program">
			<cfquery name="unlock" datasource="#application.datasource#">
				EXEC USP_Contract_Lock_Unlock @User_ID = '#request.accessStructure.User_ID#', @Unlock = 1
			</cfquery>
		</cffunction>
		<cfquery name="qPlanner_Position_Below_Me" datasource="#application.datasource#">
			SELECT 1
			  FROM Planners
			 WHERE Planner_ID = <cfqueryparam value="#form.plannerID#">
			   AND Creator_Position_ID IN (
			   								SELECT DISTINCT Below_User_Positions_Id
											  FROM Positions_Below_Me
											 WHERE User_Positions_Id IN (
											 								SELECT DISTINCT User_Position_Holders.User_Positions_ID
																			  FROM User_Position_Holders
																					INNER JOIN User_Positions
																						ON User_Positions.User_Positions_ID	= User_Position_Holders.User_Positions_ID
																							AND User_Positions.Deleted = 0
																			 WHERE User_ID = <cfqueryparam value="#request.AccessStructure.user_id#">
																					AND	User_Position_Holders.Deleted = 0
																					AND User_Position_Holders.User_Positions_ID <> 0
											 							)
										  )
		</cfquery>
		<cfscript>
			if (qplanner_position_below_me.recordCount gt 0) {
				readonly_title = ( request.lock_status.Locked_By_Other || getPlanner.System_Locked )
									? "This <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT> is currently locked by "
											& (getPlanner.System_Locked ? "System" : request.lock_status.Locked_By_User_Name )
											& ".<br>Click to attempt to lock it for edit or try this option again later."
									: "click to edit this plan";
			}
			else {
				readonly_title = "Your positions do not allow you to edit this <CFOUTPUT>#Application.PlannerLabel#.</CFOUTPUT>";
			}
			// switch to read-only mode when planner is locked by other
			if (form.mode eq constants.edit) {
				if (request.lock_status.Locked_By_Other || getPlanner.System_Locked ) {
					form.mode = '';
				}
				/*else if (request.lock_status.is_locked neq 1) {
					
					if (qplanner_position_below_me.recordCount gt 0) {
						// attemp to lock :: if fail reset form to read only
						form.mode = (request.components.lock.lock("Planner", form.plannerID) ? form.mode : '');
					}
					else {
						form.mode = '';
					}
				}*/
			}
			// in read only mode and locked by current user - need to unlock
			else if (request.lock_status.Locked_By_Other eq 0 and request.lock_status.is_locked eq 1) {
				unlock_program();
				request.components.lock.unlockByID("Planner", form.plannerID);
			}
			parentPlanner = plannerManager.getPlanner( form.indirect_planner ? form.parent_planner_id : -1 );
		</cfscript>

        <cfoutput>
		<div id="top_header">
			<div id="planner_overview">
				<div style="width:15%;" id="mode">
					<cfif form.mode eq constants.edit>
						<i title="click for read-only" class="link"><img src="/images/edit_mode.gif"><br>#application.util.string.linkFormat("Click for Read Only")#</i>
					<cfelseif request.lock_status.Locked_By_Other>
						<i title="#readonly_title#" class="link"><img src="/images/iconmonstr-lock-1-24.png" width="20" height="20"></i>
					<cfelse>
						<i title="#readonly_title#" class="link"><img src="/images/readonly_mode.gif"><br>#application.util.string.linkFormat("Click to Edit")#</i>
					</cfif>
				</div>
				<div style="width:20%;" class="status">
					#getPlanner.Status_Description# &nbsp;&nbsp; <a name="btnPlannerDetail" id="btnPlannerDetail">#application.util.string.linkFormat("detail")#</a>
				</div>
				<div style="width:28%;" class="planner_number">
					#application.util.string.fullLeft(getPlanner.Planner_Number & " " & getPlanner.Planner_Title, 39)#
					<cfif parentPlanner.recordCount>
						<form name="parent_planner" method="post" action="/planners/create/planner_scorecard.cfm" style="display:none;">
							<input type="hidden" name="plannerID" value=<cfoutput>#parentPlanner.planner_ID#</cfoutput>>
							<input type="hidden" name="mode" value="">
							<input type="hidden" name="page_creating" value="1">
						</form>
						<br><a id="parent_planner">#application.util.string.fullLeft("Parent: " & parentPlanner.Planner_Number & " " & parentPlanner.Planner_Title, 39)#</a>
					</cfif>
				</div>
				<div style="width:20%;" class="span">
					#application.util.datetime.DateSpanFormat( getPlanner.Planner_Start_Date, getPlanner.Planner_End_Date, "mmm" )#<br>
					<i class="dim">#application.util.string.fullLeft(getPlanner.Planner_Description, 27)#</i>
				</div>
				<div style="width:15%;">
					<i class="dim">#getPlanner.RSP_User_Name#<br />#getPlanner.RSP_Position#</i>
				</div>
			</div>

			<!----------------->
			<!---  summary  --->
			<!--------------------------------------------------------------------------------------------------------------------------------------------->
			<cfset summaryCol1 = "" />
			<cfif form.indirect_planner>
				<cfset summaryCol1 = "lastCol" />
            </cfif>

            <cfset structAppend(url, createObject( "component", "components.udf" ))>

            <cfif val(request.planner_targets_enabled) eq 0>
                <div id="planner_summary">
                    <cfif not cgi.script_name contains "scorecard.cfm">
                        <table id="summary_table">
                            <thead>
                                <tr>
                                    <th style="text-align:left;width:12%" class="lastCol">SUMMARY</th>

                                    <th class="medium #summaryCol1#">#get_UOM(1).Unit_Of_Measure_Desc#</th>
                                <cfif not form.indirect_planner>
                                    <th class="small">LY</th>
                                    <th class="small lastCol">Plan</th>
                                </cfif>

                                    <th class="medium #summaryCol1#">#get_UOM(2).Unit_Of_Measure_Desc#</th>
                                <cfif not form.indirect_planner>
                                    <th class="small">LY</th>
                                    <th class="small lastCol">Plan</th>
                                </cfif>

                                <cfif not form.indirect_planner>
                                    <th class="medium #summaryCol1#">Sales $</th>
                                    <cfif getPlanner.PY_Summary_Display> <th class="small">LY</th> </cfif>
                                    <th class="small lastCol">Plan</th>
                                </cfif>

                                    <th class="medium #summaryCol1#">Trade $</th>
                                <cfif not form.indirect_planner>
                                    <cfif getPlanner.PY_Summary_Display> <th class="small">LY</th> </cfif>
                                    <th class="small">Plan</th>
                                </cfif>
                                </tr>
                            </thead>
                            <tbody>
                                <tr> <!--- Latest Plan --->
                                    <td class="label lastCol">Latest Plan</td>
                                    <!--- try to load summary data & avoid errors due to invalid data (null value or divide by zero) --->
                                    <cftry>
                                        <cfsavecontent variable="latest_summary_body">
                                            <!--- cases --->
                                            <td class="last #summaryCol1#" id="latest_cs">  #numberFormat( request.queries.planner_summary.Latest_CS, "," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last" id="latest_cs_ly"> <cfif request.queries.planner_summary.LY_CS> #numberFormat( ( request.queries.planner_summary.Latest_CS * 100 / request.queries.planner_summary.LY_CS ), "---" )#% </cfif> </td>
                                            <td class="secondary lastCol" id="latest_cs_locked"> <cfif request.queries.planner_summary.Locked_CS> #numberFormat( ( request.queries.planner_summary.Latest_CS * 100 / request.queries.planner_summary.Locked_CS ), "---" )#% </cfif> </td>
                                        </cfif>

                                            <!--- pounds --->
                                            <td class="last #summaryCol1#" id="latest_lbs"> #numberFormat( request.queries.planner_summary.Latest_LBS, "," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last" id="latest_lbs_ly"> <cfif request.queries.planner_summary.LY_LBS> #numberFormat( ( request.queries.planner_summary.Latest_LBS * 100 / request.queries.planner_summary.LY_LBS ), "---" )#% </cfif> </td>
                                            <td class="secondary lastCol" id="latest_lbs_locked"> <cfif request.queries.planner_summary.Locked_LBS> #numberFormat( ( request.queries.planner_summary.Latest_LBS * 100 / request.queries.planner_summary.Locked_LBS ), "---" )#% </cfif> </td>
                                        </cfif>

                                            <!--- sales $ --->
                                        <cfif not form.indirect_planner>
                                            <td class="last #summaryCol1#" id="latest_sales"> #numberFormat( request.queries.planner_summary.Latest_Sales, "$," )# </td>
                                            <cfif getPlanner.PY_Summary_Display> <td class="secondary last" id="latest_sales_ly"> <cfif request.queries.planner_summary.LY_Sales> #numberFormat( ( request.queries.planner_summary.Latest_Sales * 100 / request.queries.planner_summary.LY_Sales ), "---" )#% </cfif> </td> </cfif>
                                            <td class="secondary lastCol" id="latest_sales_locked"> <cfif request.queries.planner_summary.Locked_Sales> #numberFormat( ( request.queries.planner_summary.Latest_Sales * 100 / request.queries.planner_summary.Locked_Sales ), "---" )#% </cfif> </td>
                                        </cfif>

                                            <!--- trade $ --->
                                            <td class="last #summaryCol1#" id="latest_trade"> #numberFormat( request.queries.planner_summary.Latest_Trade, "$," )# </td>
                                        <cfif not form.indirect_planner>
                                            <cfif getPlanner.PY_Summary_Display> <td class="secondary last" id="latest_trade_ly"> <cfif request.queries.planner_summary.LY_Trade> #numberFormat( ( request.queries.planner_summary.Latest_Trade * 100 / request.queries.planner_summary.LY_Trade ), "---" )#% </cfif> </td> </cfif>
                                            <td class="secondary lastCol" id="latest_trade_locked"> <cfif request.queries.planner_summary.Locked_Trade> #numberFormat( ( request.queries.planner_summary.Latest_Trade * 100 / request.queries.planner_summary.Locked_Trade ), "---" )#% </cfif> </td>
                                        </cfif>
                                        </cfsavecontent>
                                        #latest_summary_body#
                                    <cfcatch>
                                        <!--- ran into invalid summary data (null value or divide by zero) just show blank td --->
                                        <cfloop from="1" to="12" index="counter">
                                            <td>&nbsp;</td>
                                        </cfloop>
                                    </cfcatch>
                                    </cftry>
                                </tr>
                            </tbody>
                        </table>	<!--- id="summary_table" --->
                    </cfif>		<!--- not cgi.script_name contains "scorecard.cfm" --->
                </div>		<!--- id="planner_summary" --->
            </cfif>
		</div>
		<div style="clear:both">
			&nbsp;
		</div>
		<div class="nav">
			<ul class="nav">
				<cfset nav_script = "/planners/create/planner_profile.cfm">
				<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
					<a class="topnav hand" data-script="#nav_script#">profile</a>
				</li>

				<cfset nav_script = "/planners/create/planner_calendar.cfm">
				<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
					<a class="topnav hand" data-script="#nav_script#">calendar</a>
				</li>

				<cfif getPlanner.Wholesaler_Planner eq 1 and val(getPlanner.parent_planner_id) eq 0>
					<cfset nav_script = "/planners/create/planner_indirect.cfm">
					<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
						<a class="topnav hand" data-script="#nav_script#">#lcase(request.planner_labels.Indirect_Plural)#</a>
					</li>
				</cfif>

				<cfif not form.indirect_planner>
					<cfset nav_script = "/planners/create/planner_volume_plan.cfm">
					<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
						<a class="topnav hand" data-script="#nav_script#">volume plan</a>
					</li>
				</cfif>

				<cfset nav_script = "/planners/create/planner_scorecard.cfm">
				<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
					<a class="topnav hand" data-script="#nav_script#">scorecard</a>
				</li>

				<cfset nav_script = "/planners/create/planner_output.cfm">
				<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
					<a class="topnav hand" data-script="#nav_script#">output</a>
				</li>

				<cfif not form.indirect_planner>
					<cfset nav_script = "/planners/create/planner_alerts.cfm">
					<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
						<a class="topnav hand" data-script="#nav_script#">alerts</a>
					</li>
                </cfif>

				<cfif not form.indirect_planner and request.accrual_exist>
					<cfset nav_script = "/planners/create/planner_accruals.cfm">
					<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
						<a class="topnav hand" data-script="#nav_script#">accruals</a>
					</li>
                </cfif>

				<cfif not form.indirect_planner and request.payment_history_exist>
					<cfset nav_script = "/planners/create/planner_spent.cfm">
					<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
						<a class="topnav hand" data-script="#nav_script#">spent</a>
					</li>
                </cfif>

                <cfif val(request.planner_targets_enabled) neq 0>
                    <cfif form.indirect_planner>
                        <!--- do not show spending progress for indirect planners --->
                    <cfelse>
                        <cfset nav_script = "/planners/create/planner_targets.cfm">
                        <li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
                            <a class="topnav hand" data-script="#nav_script#">spending progress</a>
                        </li>
                    </cfif>
                </cfif>

				<cfif request.ezrate_exist eq 1>
					<cfset nav_script = "/planners/create/planner_ez_rates.cfm">
					<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
						<a class="topnav hand" data-script="#nav_script#">ez rates</a>
					</li>
				</cfif>
			</ul>

			<cfif ( cgi.script_name contains "planner_volume" or cgi.script_name contains "planner_calendar" )>
				<cfscript>
					components.datamanager = createObject( "component", "components.products.Group.DataManager" );
					queries.product_groups = components.datamanager.getProductGroupsData();

					queries.product_filters = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager").getPlannerFilters(form.planner_template_id, 1, 1);
					lProductFilters = valueList(queries.product_filters.Group_Level_ID);
					// parent caller is not the page itself
					if ( not cgi.http_referer contains cgi.script_name ) {
						udf = new components.udf();

						// retrieve previous products filter for this planner
						saved_filter = udf.getUserData( search_column="Planner_ID", search_id=form.plannerID, template_name: "planner_volume_calendar", user_id: "Everyone" );
						try {
							saved_object = deserializeJSON( saved_filter );

							if ( isDefined( "saved_object.filter_product_group_level_id" ) ) {
								form.filter_product_group_level_id = saved_object.filter_product_group_level_id;
							}

							if ( isDefined( "saved_object.filter_product_list" ) ) {
								form.filter_product_list = saved_object.filter_product_list;
							}
						}
						catch ( any e ) {
						};
					}
				</cfscript>

				<span id="filter_products" style="float:right;margin-top:-2px;">
					<label class="opaque-h">filter products</label>
					<select name="filter_product_group_level_id" style="width:150px;">
						<option value="">none</option>
						<cfloop query="queries.product_groups">
							<cfif listFindNoCase(lProductFilters, queries.product_groups.product_group_level_id)>
								<option <cfif form.filter_product_group_level_id eq queries.product_groups.product_group_level_id>selected</cfif>
									value="#queries.product_groups.product_group_level_id#">#queries.product_groups.group_level_desc#</option>
							</cfif>
						</cfloop>
					</select>
					<a id="add_filter" title="click to add filter products" style="margin-left:11px;">#application.util.string.linkFormat("add")#</a>
					<a id="save_filter" title="click to save products filter for this planner <br> and apply automatically to all future visits" style="margin-left:11px;">#application.util.string.linkFormat("save")#</a>
					<a id="reset_filter" title="click to reset products filter now and in all future visits" class="secondary" style="margin-left:11px;">#application.util.string.linkFormat("reset")#</a>
				</span>
			</cfif>

		</div>
		<div style="clear:both"></div>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
	<!-------------------------------->
	<!---  layout body starts here --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<div id="layoutBody">
	<!--------------------------------------------------------------------------------------------------------------------->
    <script>
        const global = { changes_count:0 };
				function PlannerLock(a){ 
					$.ajax({
                       url: "/components/general/lock.cfc"
                        , data: { method: "Lock"
																			,main_id:'Planner'
																			,secondary_id:'<cfoutput>#form.plannerID#</cfoutput>'
																			,one_per_user:1
                        					}
												, success: function(mydata){
													//alert('DONE')
												}
												, error: function(XMLHttpRequest, textStatus, errorThrown) {
														alert("Error: " + errorThrown);
												}
					});
				}
    </script>

<cfelse>

	<!--------------------------------------------------->
	<!--- main body content from parent displays here --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<!------------------------------>
	<!---  layout body ends here --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	</div>   <!---id="layoutBody"--->
	<cfsavecontent variable="variables.uncompressed">
		<div id="layoutFoot" style='padding:5px;font-weight: normal;'></div>
		<!----------------------------------------------------------------------------------------------------------------------------------------------------->
		<script>
			jQuery('.topnav').click( function() {
                if (global.changes_count) {
                    if ( confirm("You have unsaved changes on this page. Please click OK to go back to save your changes.\n\nClick Cancel only if you want to discard your changes.") ) {
                        return;
                    }
                }
				show_loader();
				/* assign action attribute to topnav form based on clicked element address and then submit the form */
				jQuery('form[name=topnav]').attr("action", $(this).data("script")).submit();
			});
			/* allow to click on edit/read-only button only when planner position is below me */
			<cfif (qplanner_position_below_me.recordCount gt 0)>
				jQuery( "#mode" ).click(function() {
					<cfoutput>
						
					show_loader();
					/* toggle the mode */
					var new_mode = "#(form.mode eq constants.edit ? '' : constants.edit)#"; 
					jQuery("input[name=mode]").val( new_mode );
					/* assign action attribute to topnav form and then submit the form */
					jQuery('form[name=topnav]').attr("action", window.location.pathname).submit();
					PlannerLock(window.location.pathname);
					</cfoutput>
				});
			</cfif>
			jQuery("a#parent_planner").click(function(){
				show_loader( "LOADING PARENT <CFOUTPUT>#Application.PlannerLabel#</CFOUTPUT>, PLEASE WAIT..." );
				jQuery("form[name=parent_planner]").submit();
			});

			$(function() {
				$("#btnPlannerDetail").click(function() {
					popupInCenter("/Planners/Create/planner_details.cfm?plannerId=<cfoutput>#form.plannerID#</cfoutput>", "Planner_Details");
				});
			});
		</script>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
	<!--- injects style for focused element here instead of using Application.cfc which places the same code oustide of </html> tag --->
	<cfinclude template="/common_files/focus.cfm">     <!--- 47143 --->
	</body>
	</html>
</cfif>     <!--- if thisTag.executionMode is "start" --->
