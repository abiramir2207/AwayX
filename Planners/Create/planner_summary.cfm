<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/planner_summary.cfm
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  7/2/2016
Created By   :  KAL
Description  :  Displays Planner Summary on the planner_scorecard.cfm page. This is an include.
---------------------------------------------------------------------------------->
    <cfsavecontent variable="head_content">
    <style>
		#wrapperSummary { display: table; width:100%; min-width: 950px; min-height: 1px; border: 0px solid green; font-size:11px; }
		/* Override layout_planner.cfm */
		#scorecard_summary {
			float: none;
			display: table-cell;
		}
	<cfif form.indirect_planner>
		#summary_table { width: 500px;}
	<cfelse>
		#summary_table { min-width: 700px;}
	</cfif>
		.colSummary {display: table-cell; width: auto; min-width: 20px; padding:5px; border-spacing:5px;}
		.txtCtr {text-align: center;}
		.txtLeft {text-align:left;}
		.txtRight {text-align:right; }
		#summary_table { font-size:11px;}
		#summary_table td { font-size:11px;}
		hr {border: 1px solid #666; width:100px;}
		p {color:white;}
		td.py, th.py { <cfif getPlanner.PY_Summary_Display neq 1> display:none !important; </cfif> }
		label.cursor { cursor: pointer; font-weight: bold; }
	</style>
	</cfsavecontent>
	<cfhtmlhead text="#head_content#">

	<!--- <cfdump var="#form#"> --->
	<cfparam name="form.include_slotting" default="1">

	<cfset summaryCol1    = "">
    <cfset qParentPlanner = queryNew( "Planner_Number, Planner_ID", "varchar, integer" )>

	<cfif form.indirect_planner>
        <cfset summaryCol1 = "lastCol" />

        <cfset useLakebaseForqParentPlanner = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planners")>
<cfif useLakebaseForqParentPlanner>
	<cftry>
		<cfset qParentPlanner = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planners", {
				"planner_id" = "eq.#getPlanner.parent_planner_id#",
				"limit" = "1",
				"select" = "planner_number,planner_id"
			}), "planner_number,planner_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqParentPlanner = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqParentPlanner>
<cfquery name="qParentPlanner" datasource="#application.datasource#">
            SELECT TOP 1 Planner_Number, Planner_ID
              FROM Planners
             WHERE Planner_ID = #getPlanner.parent_planner_id#
        </cfquery>
</cfif>
	</cfif>


    <cfset structAppend(url, createObject( "component", "components.udf" ))>
    <div id="wrapperSummary">
		<!--- headings --->
		<div>
			<!----------------->
			<!---  summary  --->
			<!--------------------------------------------------------------------------------------------------------------------------------------------->
			<cfoutput>
            <cfsavecontent variable="scorecard_summary">
                <cfif val(request.planner_targets_enabled) eq 0>
                    <div id="scorecard_summary">
                        <table id="summary_table">
                            <thead>
                                <tr>
                                    <th style="text-align:left;width:12%" class="lastCol">SUMMARY</th>
                                    <!--- cases --->
                                    <th class="medium #summaryCol1#">#get_UOM(1).Unit_Of_Measure_Desc#</th>
                                <cfif not form.indirect_planner>
                                    <th class="small">LY</th>
                                    <th class="small lastCol">Plan</th>
                                </cfif>
                                    <!--- pounds --->
                                    <th class="medium #summaryCol1#">#get_UOM(2).Unit_Of_Measure_Desc#</th>
                                <cfif not form.indirect_planner>
                                    <th class="small">LY</th>
                                    <th class="small lastCol">Plan</th>
                                </cfif>
                                    <!--- sales $ --->
                                <cfif not form.indirect_planner>
                                    <th class="medium #summaryCol1#">Sales $</th>
                                    <th class="small py" id="sales_ly">LY</th>
                                    <th class="small lastCol">Plan</th>
                                </cfif>
                                    <!--- trade $ --->
                                    <th class="medium #summaryCol1#">Trade $</th>
                                <cfif not form.indirect_planner>
                                    <th class="small py" id="trade_ly">LY</th>
                                    <th class="small">Plan</th>
                                </cfif>
                                </tr>
                            </thead>
                            <tbody>

                            <!--- six possible summary rows: aop, ly, locked_plan, ytd, actual, latest_plan --->
                            <cfset sc_summary = [ '', '', '', '', '', '', '' ]>

                            <cfif not form.indirect_planner>
                                <!--- gather setting for TO GO --->
                                <cfset useLakebaseForqSettingLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_scorecard_settings")>
<cfif useLakebaseForqSettingLabel>
	<cftry>
		<cfset qSettingLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_scorecard_settings", {
				"blacksmith_label" = "eq.To Go"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSettingLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSettingLabel>
<cfquery name="qSettingLabel" datasource="#application.datasource#">
                                    SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'To Go'
                                </cfquery>
</cfif>
                                <!--- AOP is enabled --->
                                <cfif qSettingLabel.enabled eq '1'>
                                    <cfsavecontent variable="summary_content">
                                        <tr> <!--- To Go --->
                                            <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                            <!--- cases :: clst class stands for case, lbs, sale & trade --->
                                            <cfset togo = {}>
                                            <cfset togo.cases = request.queries.planner_summary.YTD_CS - request.queries.planner_summary.Actual_CS>
                                            <td class="last #summaryCol1# clst"> #numberFormat( togo.cases, "," )# </td>
                                            <td class="secondary last"> #percentFormat( togo.cases, request.queries.planner_summary.LY_CS )# </td>
                                            <td class="secondary lastCol"> #percentFormat( togo.cases, request.queries.planner_summary.Locked_CS )# </td>
                                            <!--- pounds --->
                                            <cfset togo.pounds = request.queries.planner_summary.YTD_LBS - request.queries.planner_summary.Actual_LBS>
                                            <td class="last #summaryCol1# clst"> #numberFormat( togo.pounds, "," )# </td>
                                            <td class="secondary last"> #percentFormat( togo.pounds, request.queries.planner_summary.LY_LBS )# </td>
                                            <td class="secondary lastCol"> #percentFormat( togo.pounds, request.queries.planner_summary.Locked_LBS )# </td>

                                            <!--- sales $ --->
                                            <cfset togo.sales = request.queries.planner_summary.YTD_Sales - request.queries.planner_summary.Actual_Sales>
                                            <td class="last #summaryCol1# clst"> #numberFormat( togo.sales, "$," )#  </td>
                                            <td class="secondary last py"> #percentFormat( togo.sales, request.queries.planner_summary.LY_Sales )# </td>
                                            <td class="secondary lastCol"> #percentFormat( togo.sales, request.queries.planner_summary.Locked_Sales )# </td>

                                            <!--- trade $ --->
                                            <cfset togo.trades = request.queries.planner_summary.YTD_Trade - request.queries.planner_summary.Actual_Trade>
                                            <td class="last #summaryCol1# clst" > #numberFormat( togo.trades, "$," )#  </td>
                                            <td class="secondary last py" > #percentFormat( togo.trades, request.queries.planner_summary.LY_Trade )# </td>
                                            <td class="secondary lastCol"> #percentFormat( togo.trades, request.queries.planner_summary.Locked_Trade )# </td>
                                        </tr>
                                    </cfsavecontent>
                                    <!--- save result to local array based on custom order--->
                                    <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                                </cfif>

                                <!--- gather setting for AOP --->
                                <cfquery name="qSettingLabel" datasource="#application.datasource#">
                                    SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'AOP'
                                </cfquery>
                                <!--- AOP is enabled --->
                                <cfif qSettingLabel.enabled eq '1'>
                                    <cfsavecontent variable="summary_content">
                                        <tr> <!--- AOP --->
                                            <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                            <!--- cases :: clst class stands for case, lbs, sale & trade --->
                                            <td class="last #summaryCol1# clst"> #numberFormat( request.queries.planner_summary.AOP_CS, "," )# </td>
                                            <td class="secondary last">&nbsp;</td>
                                            <td class="secondary lastCol">&nbsp;</td>
                                            <!--- pounds --->
                                            <td class="last #summaryCol1# clst"> #numberFormat( request.queries.planner_summary.AOP_LBS, "," )# </td>
                                            <td class="secondary last">&nbsp;</td>
                                            <td class="secondary lastCol">&nbsp;</td>

                                            <!--- sales $ --->
                                            <td class="last #summaryCol1# clst"> &nbsp; </td>
                                            <td class="secondary last py">&nbsp;</td>
                                            <td class="secondary lastCol">&nbsp;</td>

                                            <!--- trade $ --->
                                            <td class="last #summaryCol1# clst" > &nbsp; </td>
                                            <td class="secondary last py" >&nbsp;</td>
                                            <td class="secondary lastCol">&nbsp;</td>
                                        </tr>
                                    </cfsavecontent>
                                    <!--- save result to local array based on custom order--->
                                    <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                                </cfif>



                                <!--- gather setting for LY --->
                                <cfquery name="qSettingLabel" datasource="#application.datasource#">
                                    SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'LY'
                                </cfquery>
                                <!--- LY is enabled --->
                                <cfif qSettingLabel.enabled eq '1'>
                                    <cfsavecontent variable="summary_content">
                                            <tr> <!--- LY --->
                                            <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                            <!--- cases --->
                                            <td class="last #summaryCol1#" id="ly_cs"> #numberFormat( request.queries.planner_summary.LY_CS, "," )# </td>
                                            <td class="secondary last" id="ly_cs_ly"> &nbsp; </td>
                                            <td class="secondary lastCol" id="ly_cs_locked"> #percentFormat( request.queries.planner_summary.LY_CS, request.queries.planner_summary.Locked_CS )# </td>

                                            <!--- pounds --->
                                            <td class="last #summaryCol1#" id="ly_lbs"> #numberFormat( request.queries.planner_summary.LY_LBS, "," )# </td>
                                            <td class="secondary last" id="ly_lbs_ly"> &nbsp; </td>
                                            <td class="secondary lastCol" id="ly_lbs_locked"> #percentFormat( request.queries.planner_summary.LY_LBS, request.queries.planner_summary.Locked_LBS )# </td>

                                            <!--- sales $ --->
                                            <td class="last #summaryCol1#" id="ly_sales">  <cfif getPlanner.PY_Summary_Display> #numberFormat( request.queries.planner_summary.LY_Sales, "$," )# </cfif> </td>
                                            <td class="secondary last py" id="ly_sales_ly"> &nbsp; </td>
                                            <td class="secondary lastCol" id="ly_sales_locked"> <cfif getPlanner.PY_Summary_Display>#percentFormat( request.queries.planner_summary.LY_Sales, request.queries.planner_summary.Locked_Sales )# </cfif> </td>

                                            <!--- trade $ --->
                                            <td class="last #summaryCol1#" id="ly_trade"> <cfif getPlanner.PY_Summary_Display > #numberFormat( request.queries.planner_summary.LY_Trade, "$," )# </cfif> </td>
                                            <td class="secondary last py" id="ly_trade_ly"> &nbsp; </td>
                                            <td class="secondary lastCol" id="ly_trade_locked"> <cfif getPlanner.PY_Summary_Display> #percentFormat( request.queries.planner_summary.LY_Trade, request.queries.planner_summary.Locked_Trade )# </cfif> </td>
                                        </tr>
                                    </cfsavecontent>
                                    <!--- save result to local array based on custom order--->
                                    <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                                </cfif>

                                <!--- gather setting for Locked_Plan --->
                                <cfquery name="qSettingLabel" datasource="#application.datasource#">
                                    SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'Locked Plan'
                                </cfquery>
                                <!--- Locked_plan is enabled --->
                                <cfif qSettingLabel.enabled eq '1'>
                                    <cfsavecontent variable="summary_content">
                                        <tr> <!--- Locked Plan --->
                                            <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                            <!--- cases --->
                                            <td class="last #summaryCol1#" id="locked_cs"> #numberFormat( request.queries.planner_summary.Locked_CS, "," )# </td>
                                            <td class="secondary last" id="locked_cs_ly"> #percentFormat( request.queries.planner_summary.Locked_CS, request.queries.planner_summary.LY_CS )# </td>
                                            <td class="secondary lastCol" id="locked_cs_locked"> &nbsp; </td>

                                            <!--- pounds --->
                                            <td class="last #summaryCol1#" id="locked_lbs"> #numberFormat( request.queries.planner_summary.Locked_LBS, "," )# </td>
                                            <td class="secondary last" id="locked_lbs_ly"> #percentFormat( request.queries.planner_summary.Locked_LBS, request.queries.planner_summary.LY_LBS )# </td>
                                            <td class="secondary lastCol" id="locked_lbs_locked"> &nbsp; </td>

                                            <!--- sales $ --->
                                            <td class="last #summaryCol1#" id="locked_sales"> #numberFormat( request.queries.planner_summary.Locked_Sales, "$," )# </td>
                                            <td class="secondary last py" id="locked_sales_ly"> #percentFormat( request.queries.planner_summary.Locked_Sales, request.queries.planner_summary.LY_Sales )# </td>
                                            <td class="secondary lastCol" id="locked_sales_locked"> &nbsp; </td>

                                            <!--- trade $ --->
                                            <td class="last #summaryCol1#" id="locked_trade"> #numberFormat( request.queries.planner_summary.Locked_Trade, "$," )# </td>
                                            <td class="secondary last py" id="locked_trade_ly"> #percentFormat( request.queries.planner_summary.Locked_Trade, request.queries.planner_summary.LY_Trade )# </td>
                                            <td class="secondary lastCol" id="locked_trade_locked"> &nbsp; </td>
                                        </tr>
                                    </cfsavecontent>
                                    <!--- save result to local array based on custom order--->
                                    <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                                </cfif>
                            </cfif>

                            <!--- gather setting for Latest_Plan --->
                            <cfquery name="qSettingLabel" datasource="#application.datasource#">
                                SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'Latest Plan'
                            </cfquery>
                            <!--- Latest_Plan is enabled --->
                            <cfif qSettingLabel.enabled eq '1'>
                                <cfsavecontent variable="summary_content">
                                    <tr> <!--- Latest Plan --->
                                        <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                        <!--- cases --->
                                        <td class="last #summaryCol1#" id="latest_cs">  #numberFormat( request.queries.planner_summary.Latest_CS, "," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last" id="latest_cs_ly"> #percentFormat( request.queries.planner_summary.Latest_CS, request.queries.planner_summary.LY_CS )# </td>
                                            <td class="secondary lastCol" id="latest_cs_locked"> #percentFormat( request.queries.planner_summary.Latest_CS, request.queries.planner_summary.Locked_CS )# </td>
                                        </cfif>

                                        <!--- pounds --->
                                        <td class="last #summaryCol1#" id="latest_lbs"> #numberFormat( request.queries.planner_summary.Latest_LBS, "," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last" id="latest_lbs_ly"> #percentFormat( request.queries.planner_summary.Latest_LBS, request.queries.planner_summary.LY_LBS )# </td>
                                            <td class="secondary lastCol" id="latest_lbs_locked"> #percentFormat( request.queries.planner_summary.Latest_LBS, request.queries.planner_summary.Locked_LBS )# </td>
                                        </cfif>

                                        <!--- sales $ --->
                                        <cfif not form.indirect_planner>
                                            <td class="last #summaryCol1#" id="latest_sales"> #numberFormat( request.queries.planner_summary.Latest_Sales, "$," )# </td>
                                            <td class="secondary last py" id="latest_sales_ly"> #percentFormat( request.queries.planner_summary.Latest_Sales, request.queries.planner_summary.LY_Sales )# </td>
                                            <td class="secondary lastCol" id="latest_sales_locked"> #percentFormat( request.queries.planner_summary.Latest_Sales, request.queries.planner_summary.Locked_Sales )# </td>
                                        </cfif>

                                        <!--- trade $ --->
                                        <td class="last #summaryCol1#" id="latest_trade"> #numberFormat( request.queries.planner_summary.Latest_Trade, "$," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last py" id="latest_trade_ly"> #percentFormat( request.queries.planner_summary.Latest_Trade, request.queries.planner_summary.LY_Trade )# </td>
                                            <td class="secondary lastCol" id="latest_trade_locked"> #percentFormat( request.queries.planner_summary.Latest_Trade, request.queries.planner_summary.Locked_Trade )# </td>
                                        </cfif>
                                    </tr>
                                </cfsavecontent>
                                <!--- save result to local array based on custom order--->
                                <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                            </cfif>

                            <cfif not form.indirect_planner>
                                <!--- gather setting for YTD --->
                                <cfquery name="qSettingLabel" datasource="#application.datasource#">
                                    SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'YTD'
                                </cfquery>
                                <!--- YTD is enabled --->
                                <cfif qSettingLabel.enabled eq '1'>
                                    <cfsavecontent variable="summary_content">
                                        <tr> <!--- YTD --->
                                            <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                            <!--- cases :: clst class stands for case, lbs, sale & trade --->
                                            <td class="last #summaryCol1# clst"> #numberFormat( request.queries.planner_summary.YTD_CS, "," )# </td>
                                            <cfif not form.indirect_planner>
                                                <td class="secondary last"> #percentFormat( request.queries.planner_summary.YTD_CS, request.queries.planner_summary.LY_CS )# </td>
                                                <td class="secondary lastCol"> #percentFormat( request.queries.planner_summary.YTD_CS, request.queries.planner_summary.Locked_CS )# </td>
                                            </cfif>
                                            <!--- pounds --->
                                            <td class="last #summaryCol1# clst"> #numberFormat( request.queries.planner_summary.YTD_LBS, "," )# </td>
                                            <cfif not form.indirect_planner>
                                                <td class="secondary last"> #percentFormat( request.queries.planner_summary.YTD_LBS, request.queries.planner_summary.LY_LBS )# </td>
                                                <td class="secondary lastCol"> #percentFormat( request.queries.planner_summary.YTD_LBS, request.queries.planner_summary.Locked_LBS )# </td>
                                            </cfif>

                                            <!--- sales $ --->
                                            <cfif not form.indirect_planner>
                                                <td class="last #summaryCol1# clst"> #numberFormat( request.queries.planner_summary.YTD_Sales, "$," )# </td>
                                                <td class="secondary last py"> #percentFormat( request.queries.planner_summary.YTD_Sales, request.queries.planner_summary.LY_Sales )# </td>
                                                <td class="secondary lastCol"> #percentFormat( request.queries.planner_summary.YTD_Sales, request.queries.planner_summary.Locked_Sales )# </td>
                                            </cfif>

                                            <!--- trade $ --->
                                            <td class="last #summaryCol1# clst" > #numberFormat( request.queries.planner_summary.YTD_Trade, "$," )# </td>
                                            <cfif not form.indirect_planner>
                                                <td class="secondary last py"> #percentFormat( request.queries.planner_summary.YTD_Trade, request.queries.planner_summary.LY_Trade )# </td>
                                                <td class="secondary lastCol"> #percentFormat( request.queries.planner_summary.YTD_Trade, request.queries.planner_summary.Locked_Trade )# </td>
                                            </cfif>
                                        </tr>
                                    </cfsavecontent>
                                    <!--- save result to local array based on custom order--->
                                    <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                                </cfif>
                            </cfif>


                            <!--- gather setting for Actual --->
                            <cfquery name="qSettingLabel" datasource="#application.datasource#">
                                SELECT * FROM Planner_Scorecard_Settings WHERE Blacksmith_Label = 'Actual'
                            </cfquery>
                            <!--- Actual is enabled --->
                            <cfif qSettingLabel.enabled eq '1'>
                                <cfsavecontent variable="summary_content">
                                    <tr> <!--- Actual --->
                                        <td class="label lastCol">#qSettingLabel.User_Label#</td>
                                        <!--- cases --->
                                        <td class="last #summaryCol1#" id="actual_cs"> #numberFormat( request.queries.planner_summary.Actual_CS, "," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last" id="actual_cs_ly"> #percentFormat( request.queries.planner_summary.Actual_CS, request.queries.planner_summary.LY_CS )# </td>
                                            <td class="secondary lastCol" id="actual_cs_locked"> #percentFormat( request.queries.planner_summary.Actual_CS, request.queries.planner_summary.Locked_CS )# </td>
                                        </cfif>
                                            <!--- pounds --->
                                            <td class="last #summaryCol1#" id="actual_lbs"> #numberFormat( request.queries.planner_summary.Actual_LBS, "," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last" id="actual_lbs_ly"> #percentFormat( request.queries.planner_summary.Actual_LBS, request.queries.planner_summary.LY_LBS )# </td>
                                            <td class="secondary lastCol" id="actual_lbs_locked"> #percentFormat( request.queries.planner_summary.Actual_LBS, request.queries.planner_summary.Locked_LBS )# </td>
                                        </cfif>

                                            <!--- sales $ --->
                                        <cfif not form.indirect_planner>
                                            <td class="last #summaryCol1#" id="actual_sales"> #numberFormat( request.queries.planner_summary.Actual_Sales, "$," )# </td>
                                            <td class="secondary last py" id="actual_sales_ly"> #percentFormat( request.queries.planner_summary.Actual_Sales, request.queries.planner_summary.LY_Sales )# </td>
                                            <td class="secondary lastCol" id="actual_sales_locked"> #percentFormat( request.queries.planner_summary.Actual_Sales, request.queries.planner_summary.Locked_Sales )# </td>
                                        </cfif>

                                        <!--- trade $ --->
                                        <td class="last #summaryCol1#" id="actual_trade"> #numberFormat( request.queries.planner_summary.Actual_Trade, "$," )# </td>
                                        <cfif not form.indirect_planner>
                                            <td class="secondary last py" id="actual_trade_ly"> #percentFormat( request.queries.planner_summary.Actual_Trade, request.queries.planner_summary.LY_Trade )# </td>
                                            <td class="secondary lastCol" id="actual_trade_locked"> #percentFormat( request.queries.planner_summary.Actual_Trade, request.queries.planner_summary.Locked_Trade )# </td>
                                        </cfif>
                                    </tr>
                                </cfsavecontent>
                                <!--- save result to local array based on custom order--->
                                <cfset sc_summary[ qSettingLabel.Sequence ] = summary_content>
                            </cfif>

                            <!--- output the selected summaries --->
                            <cfloop from="1" to="#arrayLen(sc_summary)#" index="counter">
                                <!--- summary exists --->
                                <cfif sc_summary[ counter ] neq ''>
                                    #sc_summary[ counter ]#
                                </cfif>
                            </cfloop>

                            </tbody>
                        </table>	<!--- id="summary_table" --->
                    </div>		<!--- id="planner_summary" --->
                </cfif>     <!--- <cfif val(request.planner_targets_enabled) eq 0> --->
            </cfsavecontent>

            <cfset br_element = " &nbsp; &nbsp; ">
            <cfif val(request.planner_targets_enabled) eq 0>
                #application.util.string.compress(scorecard_summary)#
                <cfset br_element = "<br>">
            </cfif>
			</cfoutput>
			<!--- <cfdump var="#request.queries.planner_summary#" abort="true"> --->
			<div class="txtCtr colSummary"> &nbsp; </div>
			<!--- Include Accrual Summary table --->
            <cfif val(request.planner_targets_enabled) eq 0>
                <div id="accrual_summary" class="colSummary" >
                    <cfinclude template="/planners/include/view_accruals.cfm"/>
                </div>
            </cfif>
			<div class="txtLeft colSummary">
				<cfoutput>
					<cfset approval_link = "">
                    <!---------------------------->
					<!--- page is in edit mode --->
                    <!---------------------------->
					<cfif form.mode eq 'E'>
	                    <!------------------------------>
	                    <!--- planner has wip status --->
	                    <!------------------------------>
	                    <cfif getPlanner.status_id eq 1>
	                        <cfscript>
		                        tool_tip      = "";
		                        link_id       = "foo_bar";
		                        link_class    = "opaque-l";		// default to disabled status
		                        approval_link = application.util.string.linkFormat("submit to rfa");
	                        </cfscript>

	                        <!--- When targets is enabled: we will show rfa when atleast one rfa program exists --->
	                        <cfif val(request.planner_targets_enabled) eq 1 and getPlanner.rfa_programs>
	                            <cfset link_id    = "rfa">
	                            <cfset link_class = "default hand">
	                            <cfset tool_tip   = "click to rfa #Application.PlannerLabel#">
	                        <!--- wip indirects exist? --->
	                        <cfelseif getPlanner.indirect_wip gt 0>
	                            <cfset tool_tip = "please rfa all #request.planner_labels.indirect_singular# planners first">
	                        <!--- programs exist? --->
	                        <cfelseif getPlanner.programs_count eq 0 and getPlanner.indirect_count eq 0>
	                            <cfset tool_tip = "please create #Application.PlannerLabel# programs first">
	                        <!--- all programs have rfa status? --->
	                        <cfelseif getPlanner.rfa_programs lt getPlanner.programs_count>
	                            <cfset tool_tip = "please rfa all programs in #Application.PlannerLabel# first">
	                        <!--- everything looks good at this point - allow to rfa --->
	                        <cfelse>
	                            <cfset link_id    = "rfa">
	                            <cfset link_class = "default hand">
	                            <cfset tool_tip   = "click to rfa #Application.PlannerLabel#">
	                        </cfif>

	                        <a class="#link_class#" id="#link_id#" title="#tool_tip#">#approval_link#</a>
	                    <!------------------------------>
	                    <!--- planner has rfa status --->
	                    <!------------------------------>
	                    <cfelseif getPlanner.status_id eq 2 and profileSettings.Planner_approval_rights eq "1" and not form.indirect_planner>
	                        <cfset approval_link = application.util.string.linkFormat("approve #Application.PlannerLabel#")>
							<cfif val(request.planner_targets_enabled) eq 1> <!--- When targets is enabled: we will show approve --->
								<cfset approval_link = application.util.string.linkFormat("approve")>
							</cfif>
	                        <a id="approve" class="default hand" title="click to approve #Application.PlannerLabel#">#approval_link#</a>
	                    </cfif>		<!--- <cfif getPlanner.status_id eq 1> --->
                        #br_element#

						<!-------------------------------------------------------------------------->
						<!---  no approval link exists yet & user has permission to view margin  --->
						<!-------------------------------------------------------------------------->
						<cfif len(approval_link) eq 0 and profileSettings.Planner_Margin_View eq "1">
                            <cfif form.indirect_planner>
								<a id="indirect_approve" class="hand" title="">#application.util.string.linkFormat("click here to approve")#</a>
								#br_element#

							<cfelseif val(request.planner_targets_enabled) eq 1> <!--- When targets is enabled: we will show approve --->
								<cfif getPlanner.rfa_programs or getPlanner.indirect_rfa_programs>
									<a id="approve" class="default hand" title="click to approve">#application.util.string.linkFormat("approve")#</a>
									#br_element#
								</cfif>

							<cfelse>
								<a id="approve" class="default hand" title="click to view margin">#application.util.string.linkFormat("view margin")#</a>
								#br_element#
							</cfif>
						</cfif>
					</cfif>		<!--- <cfif form.mode eq 'E'> --->

	                <cfif getPlanner.status_id gt 1 and not form.indirect_planner and (getPlanner.rfa_programs or getPlanner.indirect_rfa_programs)> <!--- Don't show cra in wip status --->
						#br_element#<a id="cra" class="hand opaque-m" title="click to view CRA information">#application.util.string.linkFormat("view cra")#</a>#br_element#
                    </cfif>

                    <cfif val(request.planner_targets_enabled) eq 0>
                        #br_element#<a id="refresh" class="hand opaque-m" title="click to refresh summary">#application.util.string.linkFormat("refresh summary")#</a>
                    </cfif>

					<cfset useLakebaseForqSlotting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qplannerprograms")>
<cfif useLakebaseForqSlotting>
	<cftry>
		<cfset qSlotting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qplannerprograms", {
				"slotting" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSlotting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSlotting>
<cfquery name="qSlotting" dbtype="query">
						SELECT * FROM qPlannerPrograms WHERE Slotting = 1
					</cfquery>
</cfif>

                    <cfif val(request.planner_targets_enabled) eq 0 and qSlotting.recordCount>
						<br><br><input type="checkbox" name="include_slotting" id="include_slotting" <cfif form.include_slotting neq "0">checked value="1"</cfif>> <label for="include_slotting" class="cursor">Include Slotting</label>
					</cfif>
				</cfoutput>
			</div>

		</div> <!--- empty div --->
	</div> <!--- id="wrapperSummary" --->

	<!--- <cfdump var="#form#"> --->

	<cffunction name="percentFormat" output="false">
		<cfargument name="numerator"   required="true">
		<cfargument name="denominator" required="true">

		<cfscript>
			return (arguments.denominator
						? numberFormat( ( arguments.numerator * 100 / arguments.denominator ), "---" ) & "%"
						: "&nbsp;");
		</cfscript>
	</cffunction>

	<cf_include files="/common_files/dhx_windows.cfm">

	<script>
		var currency_with_decimal    = "$0,.00";
		var currency_without_decimal = "$0,";
		var integer_format           = "0,";
		var percent_format           = '0,%';

		function update_slotting() {
			var include_slotting_element = $("input[name='include_slotting'][type='checkbox']"),
				include_slotting_value   = (include_slotting_element.length == 0
												? 1
												: (include_slotting_element.is(":checked")
													? 1
													: 0));
			// update all hidden element inside forms with the same name of 'include_slotting'
			$("input[name='include_slotting'][type='hidden']").each(function(){
				$(this).val( include_slotting_value ); });
		}

		$("a#approve").click(function(){
			update_slotting();
            show_loader( "PROCESSING YOUR REQUEST, PLEASE WAIT..." );
            hide_loader( 11000 );
            //check for planner program duplicates
            $.ajax({
			  async: true
			 ,data: {
			 			method: "getDuplicatePlannerProgramList"
			 			,plannerID: <cfoutput>#form.plannerID#</cfoutput>
			 			,returnFormat: "JSON"
					}
			 ,dataType: "json"
			 ,success: function( response ){
                if(response != 0){
                    NewWindow('/Planners/Create/planner_duplicate_check.cfm?plannerId=<cfoutput>#form.plannerID#</cfoutput>&plannerAction=approve&programList=' + response + '','Planner_Duplicate_Check','870','720','Yes','No');
                }
                else{
                    $("form[name=approval]").submit();
                }
			}
			 ,type: "post"
			 ,url: "/mvc/models/planner/plannerprogrammanager.cfc"
			});
		});

		$("a#cra").click(function(){
			dhx_popupInCenter( <cfoutput>"planner_cra.cfm?plannerID=#form.plannerID#"</cfoutput>, "View CRA", $(window).width()-100, $(window).height()-60 );
		});

		$("a#rfa").click(function(){
            show_loader( "PROCESSING YOUR REQUEST, PLEASE WAIT...");
			$("input[name=page_creating]").prop("disabled", true);   // page submitting :: get rid of page_creating element
			$("input[name=action]").val( "rfa" );
            //check for planner program duplicates
            $.ajax({
			  async: true
			 ,data: {
			 			method: "getDuplicatePlannerProgramList"
			 			,plannerID: <cfoutput>#form.plannerID#</cfoutput>
			 			,returnFormat: "JSON"
					}
			 ,dataType: "json"
			 ,success: function( response ){
                if(response != 0){
                    //show duplicates if we get a response not equal to 0
                    NewWindow('/Planners/Create/planner_duplicate_check.cfm?plannerId=<cfoutput>#form.plannerID#</cfoutput>&plannerAction=rfa&programList=' + response + '','Planner_Duplicate_Check','870','720','Yes','No');
                    $("div.loader").hide();
                }
                else{
                    $("form[name=rfa]").submit();
                }
			}
			 ,type: "post"
			 ,url: "/mvc/models/planner/plannerprogrammanager.cfc"
			});
		});

		$("#include_slotting").change(function(){
			show_loader( "REFRESHING DATA, PLEASE WAIT...");
			update_slotting();
			$("form[name=topnav]").submit();
		});

		<!---  click: refresh summary  --->
		$('#refresh').click(function () {
			$.ajax({
			  async: true
			 ,data: {
			 			method: "getPlannerSummaryStruct"
			 			,plannerID: <cfoutput>#form.plannerID#</cfoutput>
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
		}); // $('#refresh')

		<!---  refresh summary  --->
		function refresh_summary( response ) {
			if ( response ) {
				try {
					$( '#actual_cs' ).text( numeral( response.actual_cs[0] ).format( integer_format ));
					$( '#actual_cs_ly' ).text( response.ly_cs[0] == 0 ? '' : numeral( response.actual_cs[0]/response.ly_cs[0] ).format( percent_format ));
					$( '#actual_cs_locked' ).text( response.locked_cs[0] == 0 ? '' : numeral( response.actual_cs[0]/response.locked_cs[0] ).format( percent_format ));
					$( '#actual_lbs' ).text( numeral( response.actual_lbs[0] ).format( integer_format ));
					$( '#actual_lbs_ly' ).text( response.ly_lbs[0] == 0 ? '' : numeral( response.actual_lbs[0]/response.ly_lbs[0] ).format( percent_format ));
					$( '#actual_lbs_locked' ).text( response.locked_lbs[0] == 0 ? '' : numeral( response.actual_lbs[0]/response.locked_lbs[0] ).format( percent_format ));
					$( '#actual_sales' ).text( numeral( response.actual_sales[0] ).format( currency_without_decimal ));
					$( '#actual_sales_ly' ).text( response.ly_sales[0] == 0 ? '' : numeral( response.actual_sales[0]/response.ly_sales[0] ).format( percent_format ));
					$( '#actual_sales_locked' ).text( response.locked_sales[0] == 0 ? '' : numeral( response.actual_sales[0]/response.locked_sales[0] ).format( percent_format ));
					$( '#actual_trade' ).text( numeral( response.actual_trade[0] ).format( currency_without_decimal ));
					$( '#actual_trade_ly' ).text( response.ly_trade[0] == 0 ? '' : numeral( response.actual_trade[0]/response.ly_trade[0] ).format( percent_format ));
					$( '#actual_trade_locked' ).text( response.locked_trade[0] == 0 ? '' : numeral( response.actual_trade[0]/response.locked_trade[0] ).format( percent_format ));
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
					$( '#locked_cs' ).text( numeral( response.locked_cs[0] ).format( integer_format ));
					$( '#locked_cs_ly' ).text( response.ly_cs[0] == 0 ? '' : numeral( response.locked_cs[0]/response.ly_cs[0] ).format( percent_format ));
					$( '#locked_cs_locked' ).text( '' );
					$( '#locked_lbs' ).text( numeral( response.locked_lbs[0] ).format( integer_format ));
					$( '#locked_lbs_ly' ).text( response.ly_lbs[0] == 0 ? '' : numeral( response.locked_lbs[0]/response.ly_lbs[0] ).format( percent_format ));
					$( '#locked_lbs_locked' ).text( '' );
					$( '#locked_sales' ).text( numeral( response.locked_sales[0] ).format( currency_without_decimal ));
					$( '#locked_sales_ly' ).text( response.ly_sales[0] == 0 ? '' : numeral( response.locked_sales[0]/response.ly_sales[0] ).format( percent_format ));
					$( '#locked_sales_locked' ).text( '' );
					$( '#locked_trade' ).text( numeral( response.locked_trade[0] ).format( currency_without_decimal ));
					$( '#locked_trade_ly' ).text( response.ly_trade[0] == 0 ? '' : numeral( response.locked_trade[0]/response.ly_trade[0] ).format( percent_format ));
					$( '#locked_trade_locked' ).text( '' );
					$( '#ly_cs').text( numeral( response.ly_cs[0] ).format( integer_format ));
					$( '#ly_cs_ly' ).text( '' );
					$( '#ly_cs_locked' ).text( response.locked_cs[0] == 0 ? '' : numeral( response.ly_cs[0]/response.locked_cs[0] ).format( percent_format ));
					$( '#ly_lbs' ).text( numeral( response.ly_lbs[0] ).format( integer_format ));
					$( '#ly_lbs_ly' ).text( '' );
					$( '#ly_lbs_locked' ).text( response.locked_lbs[0] == 0 ? '' : numeral( response.ly_lbs[0]/response.locked_lbs[0] ).format( percent_format ));
					$( '#ly_sales' ).text( <cfoutput>#getPlanner.PY_Summary_Display#</cfoutput> == 0 ? '' : numeral( response.ly_sales[0] ).format( currency_without_decimal ));
					$( '#ly_sales_ly' ).text( '' );
					$( '#ly_sales_locked' ).text( ( <cfoutput>#getPlanner.PY_Summary_Display#</cfoutput> == 0 || response.locked_sales[0] == 0 ) ? '' : numeral( response.ly_sales[0]/response.locked_sales[0] ).format( percent_format ));
					$( '#ly_trade' ).text( <cfoutput>#getPlanner.PY_Summary_Display#</cfoutput> == 0 ? '' : numeral( response.ly_trade[0] ).format( currency_without_decimal ));
					$( '#ly_trade_ly' ).text( '' );
					$( '#ly_trade_locked' ).text( ( <cfoutput>#getPlanner.PY_Summary_Display#</cfoutput> == 0 || response.locked_trade[0] == 0 ) ? '' : numeral( response.ly_trade[0]/response.locked_trade[0] ).format( percent_format ));
				}
				catch( error ) {
					console.log( error );
					console.log( response );
				};
			}
			$( "#summary_table" ).effect( "highlight", 500 ); //timeline_summary - highlight
		}

        <cfif form.indirect_planner and qParentPlanner.recordCount>
            $( "#indirect_approve" )
                .click( function() {
                                        <cfoutput>
                                        parent.load_planner( "#qParentPlanner.Planner_Number#", #qParentPlanner.Planner_ID#, "/planners/create/planner_scorecard.cfm" );
                                        </cfoutput>
                                    } )
                .tooltip( {
                            items: "[title]"
                            ,content: function() { return "To approve the Indirect Plan, you must go<br> inside the Direct Plan to do the approval<br> steps. By clicking this link, you will be taken to<br> the Direct Plan."; }
                            } );
        </cfif>
	</script>

