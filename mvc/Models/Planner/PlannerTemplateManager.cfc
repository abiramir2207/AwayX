<!----------------------------------------------------------------------------------
Name         :  PlannerTemplateManager.cfc
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  03/01/2016
Created By   :  KAL
Description  :  Manager for Planner Templates
---------------------------------------------------------------------------------->


<cfcomponent name="PlannerTemplateManager" displayname="PlannerTemplateManager" hint="Manager for Planner Settings">

	<cfscript>
		this.udf = createObject( "component", "components.udf" );
	</cfscript>

	<!--- get the list of planner templates --->
	<cffunction name="getAllowedPlannerTemplates" access="public" returntype="query" output="false" >
		<cfargument name="status" required="false" default="" type="string" />

		<cfquery name="qGetAllowedPlannerTemplates" datasource="#application.datasource#">
			SELECT *
			FROM Planner_Template
			WHERE Deleted = 0
			<cfif len(arguments.status)>
				AND Active = '#arguments.status#' <!--- active filed is bit, so skipping queryparm --->
			</cfif>
			AND Planner_Template_ID IN ( <cfqueryparam value="#allowedTemplates()#" list="true"> )
		</cfquery>

		<cfreturn qGetAllowedPlannerTemplates />
	</cffunction>


	<cffunction name="getPlannerTemplates" access="public" returntype="query" output="false" >

		<cfargument name="status"   required="false" default="" type="string" />
		<cfargument name="id"     required="false" default="0" type="string" />

		<cfscript>
			//set local variables
			var strStatus = "";
			var nId     = 0;

			//assign local variables
			strStatus = arguments.status;
			nId     = arguments.id;
		</cfscript>

		<cfquery name="qGetPlannerTemplates" datasource="#application.datasource#">
			SELECT  *
			FROM  Planner_Template
			WHERE   Deleted = 0
			<cfif len(strStatus)>
				AND   Active = '#strStatus#' <!--- active field is bit, so skipping queryparm --->
			</cfif>
			<cfif nId neq 0>
				AND   Planner_Template_ID = '#nId#'
			</cfif>
		</cfquery>

		<cfreturn qGetPlannerTemplates />

	</cffunction>

	<!--- get the list of planner templates calendar settings --->
	<cffunction name="getPlannerCalendarConfig" access="public" returntype="query" output="false" >

		<cfargument name="id"     required="false" default="0" type="string" />
		<cfargument name="selected"     required="false" default="0" type="boolean" />

		<cfscript>
			//set local variables
			var nId     = 0;
			var bSelected     = 0;

			//assign local variables
			nId     = arguments.id;
			bSelected = arguments.selected;
		</cfscript>

		<cfquery name="qPlannerCalendarConfig" datasource="#application.datasource#">
			SELECT Pcc.Description,
				   Pcc.Name,
				   Pcc.Planner_Calendar_ConFig_Id,
				   format(Pcc.Sort_Order, '0##') as Sort_Order,
				   Isnull(Ptc.Planner_Template_Calendar_Id, 0) AS Selected
			FROM   Planner_Calendar_ConFig Pcc
				   LEFT JOIN Planner_Template_Calendar Ptc
						  ON Ptc.Planner_Calendar_ConFig_Id = Pcc.Planner_Calendar_ConFig_Id
							 AND Ptc.Planner_Template_Id =  '#nId#'
							 AND Ptc.Deleted = 0

			WHERE  Pcc.Active             = 1
			   AND Pcc.Deleted            = 0
			   AND Pcc.Include_In_Planner = 1
			<cfif bSelected eq 1>
			   AND Ptc.Planner_Calendar_ConFig_Id IS NOT NULL
			</cfif>
			ORDER  BY Pcc.Sort_Order
		</cfquery>

		<cfreturn qPlannerCalendarConfig />

	</cffunction>

	<!--- get the list of planner templates calendar settings --->
	<cffunction name="getPlannerPerfTypes" access="public" returntype="query" output="false" >

		<cfargument name="id"     required="false" default="0" type="string" />

		<cfscript>
			//set local variables
			var nId     = 0;

			//assign local variables
			nId     = arguments.id;
		</cfscript>

		<cfquery name="qPlannerPerfTypes" datasource="#application.datasource#">
			SELECT  ppt.Description, ppt.Planner_Perf_Types_ID,
			ISNULL(ptp.Selected, 0) AS Selected,
			ISNULL(ptp.Indirect_Selected, 0) AS Indirect_Selected
			FROM  Planner_Perf_Types ppt
				LEFT JOIN Planner_Template_Perf_Types ptp on ptp.Planner_Perf_Types_ID = ppt.Planner_Perf_Types_ID
				AND ptp.Planner_Template_ID = '#nId#'
				AND ptp.Deleted = 0
			WHERE ppt.Active = 1
			ORDER BY ppt.Sort_Order
		</cfquery>

		<cfreturn qPlannerPerfTypes />

	</cffunction>

	<cffunction name="getPlannerFields" access="public" returntype="query" output="false" >
		<cfargument name="id" required="false" default="0" type="string" />

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT
					Actual_Display,
					Actual_Default,
					Actual_Percent_Forecast_Display,
					Actual_Percent_Forecast_Default,
					AOP_Display,
					AOP_Default,
					Forecast_Display,
					Forecast_Default,
					Forecast_Percent_PY_Display,
					Forecast_Percent_PY_Default,
					Margin_Display,
					Net_Sales_Display,
					NUC_Display,
					PY_Summary_Display,
					Prior_Yr_Display,
					Prior_Yr_Default,
					Trade_Display,
					UOM_Default,
					UOM_EA,
					UOM_LB,
					UOM_CS,
					Locked_Forecast_Display,
					Locked_Forecast_Default,
					Program_Default_UOM
			FROM  	Planner_Template
			WHERE 	Planner_Template_ID = <cfqueryparam value='#arguments.id#'>
		</cfquery>

		<cfreturn local.query />
	</cffunction>

	<cffunction name="getPlannerFilters" access="public" returntype="query" output="false">

		<cfargument name="id"     required="false" default="0" type="string" />
		<cfargument name="allowInSearch"     required="false" default="" type="string" />
		<cfargument name="groupType"     required="false" default="0" type="numeric" />

		<cfscript>
			//set local variables
			var nId     			= 0;
			var strAllowInSearch	= "";
			var nGroupType			= 0;

			//assign local variables
			nId     			= arguments.id;
			strAllowInSearch	= arguments.allowInSearch;
			nGroupType			= arguments.groupType;
		</cfscript>


		<cfquery name="qPlannerFilters" datasource="#application.datasource#">

			SELECT  Planner_Template_ID,
					Group_Level_ID,
					PG_Group_Type,
					Allow_In_Search,
					Allow_In_Group_Search,
					Allow_Filter,
					Default_View
			FROM  	Planner_Template_Filters
			WHERE 	Planner_Template_ID = '#nId#'
			<cfif len(trim(strAllowInSearch))>
			and Allow_In_Search = 1
			</cfif>
			<cfif nGroupType neq 0>
			and PG_Group_Type = <cfqueryparam value='#nGroupType#'>
			</cfif>

		</cfquery>

		<cfreturn qPlannerFilters />

	</cffunction>

	<cffunction name="getPlannerFiltersCustomers" access="public" returntype="query" output="false">

		<cfargument name="id"       required="false" default="0" type="string" />

		<cfscript>
			//set local variables
			var nId     = 0;

			//assign local variables
			nId       = arguments.id;
		</cfscript>

		<cfset useLakebaseForqPlannerFiltersCustomers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters_customers")>
<cfif useLakebaseForqPlannerFiltersCustomers>
	<cftry>
		<cfset qPlannerFiltersCustomers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_template_filters_customers", {
				"planner_template_id" = "eq.#nId#",
				"select" = "planner_template_id,distributor_group_level_id,distributor_group_id"
			}), "planner_template_id,distributor_group_level_id,distributor_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPlannerFiltersCustomers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPlannerFiltersCustomers>
<cfquery name="qPlannerFiltersCustomers" datasource="#application.datasource#">

			SELECT  Planner_Template_ID,
					Distributor_Group_Level_ID,
					Distributor_Group_ID
			FROM  	Planner_Template_Filters_Customers
			WHERE 	Planner_Template_ID = '#nId#'

		</cfquery>
</cfif>

		<cfreturn qPlannerFiltersCustomers />

	</cffunction>

	<cffunction name="getPlannerFiltersProducts" access="public" returntype="query" output="false">

		<cfargument name="id"       required="false" default="0" type="string" />

		<cfscript>
			//set local variables
			var nId     = 0;

			//assign local variables
			nId       = arguments.id;
		</cfscript>

		<cfset useLakebaseForqPlannerFiltersProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters_products")>
<cfif useLakebaseForqPlannerFiltersProducts>
	<cftry>
		<cfset qPlannerFiltersProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_template_filters_products", {
				"planner_template_id" = "eq.#nId#",
				"select" = "planner_template_id,product_group_level_id,product_group_id"
			}), "planner_template_id,product_group_level_id,product_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPlannerFiltersProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPlannerFiltersProducts>
<cfquery name="qPlannerFiltersProducts" datasource="#application.datasource#">

			SELECT  Planner_Template_ID,
					Product_Group_Level_ID,
					Product_Group_ID
			FROM  	Planner_Template_Filters_Products
			WHERE 	Planner_Template_ID = '#nId#'

		</cfquery>
</cfif>

		<cfreturn qPlannerFiltersProducts />

	</cffunction>

	<cffunction name="getPlannerFiltersOperators" access="public" returntype="query" output="false">

		<cfargument name="id"       required="false" default="0" type="string" />

		<cfscript>
			//set local variables
			var nId     = 0;

			//assign local variables
			nId       = arguments.id;
		</cfscript>

		<cfset useLakebaseForqPlannerFiltersOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters_operators")>
<cfif useLakebaseForqPlannerFiltersOperators>
	<cftry>
		<cfset qPlannerFiltersOperators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_template_filters_operators", {
				"planner_template_id" = "eq.#nId#",
				"select" = "planner_template_id,operator_group_level_id,operator_group_id"
			}), "planner_template_id,operator_group_level_id,operator_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPlannerFiltersOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPlannerFiltersOperators>
<cfquery name="qPlannerFiltersOperators" datasource="#application.datasource#">

			SELECT  Planner_Template_ID,
					Operator_Group_Level_ID,
					Operator_Group_ID
			FROM  	Planner_Template_Filters_Operators
			WHERE 	Planner_Template_ID = '#nId#'

		</cfquery>
</cfif>

		<cfreturn qPlannerFiltersOperators />

	</cffunction>

	<!--- save planner template basic info --->
	<cffunction name="savePlannerTemplateData" access="public" returntype="any" output="true">
		<cfargument name="id"             required="false"  type="string"   default="0" />
		<cfargument name="dataStruct"         required="true"   type="struct" />

		<cfscript>
			nRetId = 0;
            param name="arguments.datastruct.Wholesaler_Planner" default="0";
		</cfscript>

		<!--- If id is 0 then its a new entry so insert. Otherwise we update --->
		<cfif arguments.id eq -1>
			<cfquery name="local.query" datasource="#application.datasource#">
				INSERT INTO Planner_Template
					(
					Planner_Type, Planner_Description, Planner_Start_Date, Planner_End_Date,
					Retroactive_Planner, Retroactive_Planner_Days, Retroactive_Revision, Retroactive_Revision_Days,
					UOM_CS , UOM_LB, UOM_EA, UOM_Default, Net_Sales_Display, Trade_Display, Margin_Display, NUC_Display, PY_Summary_Display,
					AOP_Display, Prior_Yr_Display, Forecast_Display, Forecast_Percent_PY_Display, Actual_Display, Actual_Percent_Forecast_Display,
					AOP_Default, Prior_Yr_Default, Forecast_Default, Forecast_Percent_PY_Default, Actual_Default, Actual_Percent_Forecast_Default,
					Locked_Forecast_Display, Locked_Forecast_Default, Demand_Plan_Display, Demand_Plan_Default,
					Business_Segment_ID, Price_List_Header_ID, Program_Default_UOM, Category,
					Indirect_Volume_Display, Indirect_Volume_Default,
					Indirect_Volume_Percent_Forecast_Display, Indirect_Volume_Percent_Forecast_Default,
					Indirect_Product_Source, Check_Duplicate_Planner, Check_Duplicate_Planner_Action,
					Include_In_Catalog, Auto_Generate_Accrual_Program,
					Alert_RFA_Programs, Alert_RFA_Programs_Days, Alert_Pending_Accept_Programs, Alert_Pending_Accept_Programs_Days,
					Output_Before_Approval,
          Wholesaler_Planner, Program_Volume_Default_UOM,
					Allow_Individual_Distributors,
					Inc_all_Accrual_Prgs_in_Planner
					,YTD_Default ,YTD_Display
				  )

				VALUES
					(
					'#arguments.dataStruct.Planner_Type#', '#arguments.dataStruct.Planner_Description#', '#arguments.dataStruct.Planner_Start_Date#', '#arguments.dataStruct.Planner_End_Date#',
					'#arguments.dataStruct.Retroactive_Planner#', '#arguments.dataStruct.Retroactive_Planner_Days#', '#arguments.dataStruct.Retroactive_Revision#', '#arguments.dataStruct.Retroactive_Revision_Days#',
					'#arguments.dataStruct.UOM_CS#','#arguments.dataStruct.UOM_LB#','#arguments.dataStruct.UOM_EA#','#arguments.dataStruct.UOM_Default#','#arguments.dataStruct.Net_Sales_Display#', '#arguments.dataStruct.Trade_Display#', '#arguments.dataStruct.Margin_Display#', '#arguments.dataStruct.NUC_Display#', '#arguments.dataStruct.PY_Summary_Display#',
					'#arguments.dataStruct.AOP_Display#', '#arguments.dataStruct.Prior_Yr_Display#', '#arguments.dataStruct.Forecast_Display#', '#arguments.dataStruct.Forecast_Percent_PY_Display#', '#arguments.dataStruct.Actual_Display#', '#arguments.dataStruct.Actual_Percent_Forecast_Display#',
					#arguments.datastruct.AOP_Default#, #arguments.datastruct.Prior_Yr_Default#, #arguments.datastruct.Forecast_Default#, #arguments.datastruct.Forecast_Percent_PY_Default#, #arguments.datastruct.Actual_Default#, #arguments.datastruct.Actual_Percent_Forecast_Default#,
					'#arguments.datastruct.Locked_Forecast_Display#', #arguments.datastruct.Locked_Forecast_Default#,
					'#arguments.datastruct.Demand_Plan_Display#', #arguments.datastruct.Demand_Plan_Default#,
					'#arguments.datastruct.Business_Segment_ID#',
					<cfif arguments.datastruct.Price_List_Header_ID neq "" and arguments.datastruct.Price_List_Header_ID neq "0">'#arguments.datastruct.Price_List_Header_ID#'<cfelse>NULL</cfif>,
					'#arguments.datastruct.Program_Default_UOM#', '#arguments.datastruct.planner_category#',
					'#arguments.datastruct.Indirect_Volume_Display#', '#arguments.datastruct.Indirect_Volume_Default#',
					'#arguments.datastruct.Indirect_Volume_Percent_Forecast_Display#', '#arguments.datastruct.Indirect_Volume_Percent_Forecast_Default#',
					'#arguments.datastruct.Indirect_Product_Source#', '#arguments.datastruct.Check_Duplicate_Planner#', '#arguments.datastruct.Check_Duplicate_Planner_Action#', '#arguments.datastruct.Include_In_Catalog#', '#arguments.datastruct.Auto_Generate_Accrual_Program#',
					'#arguments.datastruct.Alert_RFA_Programs#', '#arguments.datastruct.Alert_RFA_Programs_Days#', '#arguments.datastruct.Alert_Pending_Accept_Programs#', '#arguments.datastruct.Alert_Pending_Accept_Programs_Days#',
					'#arguments.datastruct.Output_Before_Approval#',
          '#( arguments.datastruct.planner_category eq "Wholesaler" ? 1 : 0 )#',
					'#arguments.datastruct.Program_Volume_Default_UOM#',
					#(arguments.datastruct.Allow_Individual_Distributors eq "on" ? 1 : 0)#,
					#arguments.datastruct.Inc_all_Accrual_Prgs_in_Planner#
					,'#arguments.datastruct.YTD_Default#', '#arguments.datastruct.YTD_Display#'
				  )

				SELECT Planner_Template_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>

			<cfquery datasource="#application.datasource#">
				-- grant access permissions to all profiles
				INSERT INTO Profile_Forbidden_Planner
					(
						Profile_ID
						,Access_is_forbidden
						,Planner_Template_ID
					)
					SELECT   Profiles_ID
							,0
							,#local.query.Planner_Template_ID#
					FROM dbo.Profiles
						INNER JOIN dbo.Planner_Template
							ON 1 = 1
					WHERE Profiles.Deleted = 0
						AND Planner_Template.Deleted = 0

					UNION

					SELECT  0, 0, #local.query.Planner_Template_ID# <!--- for any profile --->

			</cfquery>

			<cfset nRetId = local.query.Planner_Template_ID />

		<cfelse>
			<!--- AUDITING - CAPTURE ORIGINAL --->
			<cfset useLakebaseForvariables_qOriginal = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template")>
<cfif useLakebaseForvariables_qOriginal>
	<cftry>
		<cfset variables.qOriginal = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_template", {
				"planner_template_id" = "eq.#arguments.id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qOriginal = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qOriginal>
<cfquery name="variables.qOriginal" datasource="#application.datasource#">
				SELECT *
				FROM Planner_Template
				WHERE Planner_Template_ID = '#arguments.id#'
			</cfquery>
</cfif>

			<cfquery name="local.query" datasource="#application.datasource#">
				UPDATE  Planner_Template
				SET   Planner_Type                           = '#arguments.dataStruct.Planner_Type#',
					Planner_Description                      = '#arguments.dataStruct.Planner_Description#',
					Planner_Start_Date                       = '#arguments.dataStruct.Planner_Start_Date#',
					Planner_End_Date                         = '#arguments.dataStruct.Planner_End_Date#',
					Retroactive_Planner                      = '#arguments.dataStruct.Retroactive_Planner#',
					Retroactive_Planner_Days                 = '#arguments.dataStruct.Retroactive_Planner_Days#',
					Retroactive_Revision                     = '#arguments.dataStruct.Retroactive_Revision#',
					Retroactive_Revision_Days                = '#arguments.dataStruct.Retroactive_Revision_Days#',
					UOM_CS                                   = '#arguments.dataStruct.UOM_CS#',
					UOM_LB                                   = '#arguments.dataStruct.UOM_LB#',
					UOM_EA                                   = '#arguments.dataStruct.UOM_EA#',
					UOM_Default                              = '#arguments.dataStruct.UOM_Default#',
					Net_Sales_Display                        = '#arguments.dataStruct.Net_Sales_Display#',
					Trade_Display                            = '#arguments.dataStruct.Trade_Display#',
					Margin_Display                           = '#arguments.dataStruct.Margin_Display#',
					NUC_Display                              = '#arguments.dataStruct.NUC_Display#',
					PY_Summary_Display                       = '#arguments.dataStruct.PY_Summary_Display#',
					AOP_Display                              = '#arguments.dataStruct.AOP_Display#',
					Prior_Yr_Display                         = '#arguments.dataStruct.Prior_Yr_Display#',
					Forecast_Display                         = '#arguments.dataStruct.Forecast_Display#',
					Forecast_Percent_PY_Display              = '#arguments.dataStruct.Forecast_Percent_PY_Display#',
					Actual_Display                           = '#arguments.dataStruct.Actual_Display#',
					Actual_Percent_Forecast_Display          = '#arguments.dataStruct.Actual_Percent_Forecast_Display#',
					AOP_Default                              = #arguments.datastruct.AOP_Default#,
					Prior_Yr_Default                         = #arguments.datastruct.Prior_Yr_Default#,
					Forecast_Default                         = #arguments.datastruct.Forecast_Default#,
					Forecast_Percent_PY_Default              = #arguments.datastruct.Forecast_Percent_PY_Default#,
					Actual_Default                           = #arguments.datastruct.Actual_Default#,
					Actual_Percent_Forecast_Default          = #arguments.datastruct.Actual_Percent_Forecast_Default#,
					Locked_Forecast_Default                  = #arguments.datastruct.Locked_Forecast_Default#,
					Locked_Forecast_Display                  = '#arguments.datastruct.Locked_Forecast_Display#',
					Demand_Plan_Default                      = #arguments.datastruct.Demand_Plan_Default#,
					Demand_Plan_Display                      = '#arguments.datastruct.Demand_Plan_Display#',
					Business_Segment_ID                      = '#arguments.datastruct.Business_Segment_ID#',
					Price_List_Header_ID                     = <cfif arguments.datastruct.Price_List_Header_ID neq "" and arguments.datastruct.Price_List_Header_ID neq "0">'#arguments.datastruct.Price_List_Header_ID#'<cfelse>NULL</cfif>,
					Program_Default_UOM                      = '#arguments.datastruct.Program_Default_UOM#',
					Category                                 = '#arguments.datastruct.planner_category#',
					Indirect_Volume_Display                  = '#arguments.datastruct.Indirect_Volume_Display#',
					Indirect_Volume_Default                  = '#arguments.datastruct.Indirect_Volume_Default#',
					Indirect_Volume_Percent_Forecast_Display = '#arguments.datastruct.Indirect_Volume_Percent_Forecast_Display#',
					Indirect_Volume_Percent_Forecast_Default = '#arguments.datastruct.Indirect_Volume_Percent_Forecast_Default#',
					Indirect_Product_Source                  = '#arguments.datastruct.Indirect_Product_Source#',
					Check_Duplicate_Planner                  = #arguments.datastruct.Check_Duplicate_Planner#,
					Check_Duplicate_Planner_Action           = #arguments.datastruct.Check_Duplicate_Planner_Action#,
					Include_In_Catalog                       = #arguments.datastruct.Include_In_Catalog#,
					Auto_Generate_Accrual_Program            = #arguments.datastruct.Auto_Generate_Accrual_Program#,
					Alert_RFA_Programs                       = #arguments.datastruct.Alert_RFA_Programs#,
					Alert_RFA_Programs_Days	                 = '#arguments.datastruct.Alert_RFA_Programs_Days#',
					Alert_Pending_Accept_Programs            = #arguments.datastruct.Alert_Pending_Accept_Programs#,
					Alert_Pending_Accept_Programs_Days       = '#arguments.datastruct.Alert_Pending_Accept_Programs_Days#',
					Output_Before_Approval                   = '#arguments.datastruct.Output_Before_Approval#',
          Wholesaler_Planner                       = '#( arguments.datastruct.planner_category eq "Wholesaler" ? 1 : 0 )#',
					Program_Volume_Default_UOM 				 = '#arguments.datastruct.Program_Volume_Default_UOM#',
					Allow_Individual_Distributors            = #(arguments.datastruct.Allow_Individual_Distributors eq "on" ? 1 : 0)#,
					Inc_all_Accrual_Prgs_in_Planner			 = #arguments.datastruct.Inc_all_Accrual_Prgs_in_Planner#
					,YTD_Default = #arguments.datastruct.YTD_Default#
					,YTD_Display = #arguments.datastruct.YTD_Display#
				WHERE Planner_Template_ID = '#arguments.id#'
			</cfquery>
			<!--- AUDITING - CAPTURE CHANGES --->
			<cfset useLakebaseForvariables_qUpdated = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template")>
<cfif useLakebaseForvariables_qUpdated>
	<cftry>
		<cfset variables.qUpdated = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_template", {
				"planner_template_id" = "eq.#arguments.id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qUpdated = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qUpdated>
<cfquery name="variables.qUpdated" datasource="#application.datasource#">
				SELECT *
				FROM Planner_Template
				WHERE Planner_Template_ID = '#arguments.id#'
			</cfquery>
</cfif>
			<cfscript>
				variables.udf = createObject( "component", "components.udf" );
				variables.udf.WriteSettingsAudit( variables.qOriginal, variables.qUpdated, "Planner_Template", arguments.id, "#variables.qUpdated.Planner_Type# - #variables.qUpdated.Planner_Description#", "" );
			</cfscript>
			<cfset nRetId = arguments.id />

		</cfif>


		<cfreturn nRetId />

	</cffunction>

	<cffunction name="saveDetails" access="public" returntype="any" output="true" >

		<cfargument name="id"           required="true"   type="string" />
		<cfargument name="lPlannerCalendar"   required="true"   type="string" />
		<cfargument name="lPlannerPerfTypes"  required="true"   type="string" />
		<cfargument name="lIndirectPlannerPerfTypes"  required="true"   type="string" />

		<cfscript>
			//set local variables
			var nId           = 0;
			var strLPlannerCalendar   = "";
			var strLPlannerPerfTypes  = "";
			var idx           = "";
			var idx2          = "";


			//assign local variables
			nId             = arguments.id;
			strLPlannerCalendar     = arguments.lPlannerCalendar;
			strLPlannerPerfTypes    = arguments.lPlannerPerfTypes;
		</cfscript>

		<!--- TODO: Add logging --->
		<cfquery name="qInsertPlannerCalendar" datasource="#application.datasource#">
			UPDATE  Planner_Template_Calendar
			SET   Deleted = 1
			WHERE Planner_Template_ID = '#nId#'

			<cfloop list="#strLPlannerCalendar#" index="idx">
				INSERT INTO Planner_Template_Calendar
					(Planner_Template_ID, Planner_Calendar_Config_ID, Created_Date)
				VALUES
					('#nId#', '#idx#', getdate())
			</cfloop>

		</cfquery>

		<cfquery name="qInsertPlannerPerfTypes" datasource="#application.datasource#">

			UPDATE  Planner_Template_Perf_Types
			SET   Deleted = 1
			WHERE Planner_Template_ID = '#nId#'

			<cfloop list="#strLPlannerPerfTypes#" index="idx2">
				INSERT INTO Planner_Template_Perf_Types
					(Planner_Template_ID, Planner_Perf_Types_ID, Selected)
				VALUES
					('#nId#', '#idx2#', 1)
			</cfloop>

			<cfloop list="#lIndirectPlannerPerfTypes#" index="idx2">
				IF EXISTS (SELECT 1 FROM Planner_Template_Perf_Types WHERE Planner_Template_ID = '#nId#' AND Planner_Perf_Types_ID = '#idx2#' AND Deleted = 0)
				BEGIN
					UPDATE  Planner_Template_Perf_Types
					SET     Indirect_Selected = 1
					WHERE   Planner_Template_ID = '#nId#' AND Planner_Perf_Types_ID = '#idx2#'
				END
				ELSE
				BEGIN
					INSERT INTO Planner_Template_Perf_Types
					(Planner_Template_ID, Planner_Perf_Types_ID, Indirect_Selected)
					VALUES ('#nId#', '#idx2#', 1)
				END
			</cfloop>

		</cfquery>

	</cffunction>

	<cffunction name="saveFilters" access="public" returntype="any" output="false">

		<cfargument name="id"         			required="false"  type="string"   default="0" />
		<cfargument name="groupLevelID"     	required="false"  type="string"   default="0" />
		<cfargument name="groupType"      		required="false"  type="string"   default="0" />
		<cfargument name="allowInSearch"    	required="false"  type="string"   default="0" />
		<cfargument name="allowInGroupSearch"	required="false"  type="string"   default="0" />
		<cfargument name="allowFilter"      	required="false"  type="string"   default="0" />
		<cfargument name="filtersList"      	required="false"  type="string"   default="0" />
		<cfargument name="default_view"      	required="false"  type="string"   default="0" />
		<cfargument name="groupList"      		required="false"  type="string"   default="0" />



		<cfscript>
			//set local variables
			var nId                 = 0;
			var strGroupLevelID     = "";
			var strGroupType        = "";
			var bAllowInSearch      = "";
			var bAllowInGroupSearch = "";
			var bAllowFilter        = "";
			var lGroupList          = "";

			//assign local variables
			nId                 = arguments.id;
			strGroupLevelID     = arguments.groupLevelID;
			strGroupType        = arguments.groupType;
			bAllowInSearch      = arguments.allowInSearch;
			bAllowInGroupSearch = arguments.allowInGroupSearch;
			bAllowFilter        = arguments.allowFilter;
			strFiltersList      = arguments.filtersList;
			lGroupList          = arguments.groupList;
		</cfscript>


		<cfset useLakebaseForqCheckIfExists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters")>
<cfif useLakebaseForqCheckIfExists>
	<cftry>
		<cfset qCheckIfExists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_template_filters", {
				"planner_template_id" = "eq.#nId#",
				"group_level_id" = "eq.#strGroupLevelID#",
				"pg_group_type" = "eq.#strGroupType#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfExists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfExists>
<cfquery name="qCheckIfExists" datasource="#application.datasource#">
			SELECT  *
			FROM  Planner_Template_Filters
			WHERE Planner_Template_ID = '#nId#'
			AND   Group_Level_ID = '#strGroupLevelID#'
			AND   PG_Group_Type = '#strGroupType#'
		</cfquery>
</cfif>
		<!--- TODO: Add logging --->

		<cfif qCheckIfExists.RecordCount>
			<cfset useLakebaseForqUpdatePlannerTemplateFilters = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters")>
<cfif useLakebaseForqUpdatePlannerTemplateFilters>
	<cftry>
		<cfset application.oLakebase.updateRows("planner_template_filters",
			{
				"planner_template_id" = "eq.#nId#",
				"group_level_id" = "eq.#strGroupLevelID#",
				"pg_group_type" = "eq.#strGroupType#"
			},
			{
				"allow_in_search" = "#bAllowInSearch#",
				"allow_in_group_search" = "#bAllowInGroupSearch#",
				"allow_filter" = "#bAllowFilter#",
				"default_view" = "#arguments.default_view#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdatePlannerTemplateFilters = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdatePlannerTemplateFilters>
<cfquery name="qUpdatePlannerTemplateFilters" datasource="#application.datasource#">

				UPDATE  Planner_Template_Filters
				SET 	Allow_In_Search = '#bAllowInSearch#',
						Allow_In_Group_Search = '#bAllowInGroupSearch#',
						Allow_Filter = '#bAllowFilter#',
						Default_View = '#arguments.default_view#'
				WHERE 	Planner_Template_ID = '#nId#'
				AND   	Group_Level_ID = '#strGroupLevelID#'
				AND		PG_Group_Type = '#strGroupType#'
			</cfquery>
</cfif>

		<cfelse>

			<cfset useLakebaseForqAddPlannerTemplateFilters = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters")>
<cfif useLakebaseForqAddPlannerTemplateFilters>
	<cftry>
		<cfset application.oLakebase.insertRow("planner_template_filters", {
			"planner_template_id" = "#nId#",
			"group_level_id" = "#strGroupLevelID#",
			"pg_group_type" = "#strGroupType#",
			"allow_in_search" = "#bAllowInSearch#",
			"allow_in_group_search" = "#bAllowInGroupSearch#",
			"allow_filter" = "#bAllowFilter#",
			"default_view" = "#arguments.default_view#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddPlannerTemplateFilters = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddPlannerTemplateFilters>
<cfquery name="qAddPlannerTemplateFilters" datasource="#application.datasource#">
					INSERT INTO Planner_Template_Filters
					(Planner_Template_ID, Group_Level_ID, PG_Group_Type, Allow_In_Search, Allow_In_Group_Search, Allow_Filter, default_view)
				VALUES
					('#nId#', '#strGroupLevelID#', '#strGroupType#', '#bAllowInSearch#', '#bAllowInGroupSearch#', '#bAllowFilter#', '#arguments.default_view#')
			</cfquery>
</cfif>

		</cfif>


		<cfif strGroupType eq 2>

			<cfloop index="idx" list="#lGroupList#">

			<cfset useLakebaseForqAddCustomerFilters = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters_customers")>
<cfif useLakebaseForqAddCustomerFilters>
	<cftry>
		<cfset application.oLakebase.insertRow("planner_template_filters_customers", {
			"planner_template_id" = "#nId#",
			"distributor_group_level_id" = "#strGroupLevelID#",
			"distributor_group_id" = "#idx#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddCustomerFilters = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddCustomerFilters>
<cfquery name="qAddCustomerFilters" datasource="#application.datasource#">
				INSERT INTO Planner_Template_Filters_Customers
					(Planner_Template_ID,Distributor_Group_Level_ID,Distributor_Group_ID)
				VALUES
					('#nId#', '#strGroupLevelID#', '#idx#')
			</cfquery>
</cfif>

			</cfloop>

		<cfelseif strGroupType eq 3>

			<cfloop index="idx" list="#lGroupList#">

			<cfset useLakebaseForqAddOperatorFilters = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_template_filters_operators")>
<cfif useLakebaseForqAddOperatorFilters>
	<cftry>
		<cfset application.oLakebase.insertRow("planner_template_filters_operators", {
			"planner_template_id" = "#nId#",
			"operator_group_level_id" = "#strGroupLevelID#",
			"operator_group_id" = "#idx#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddOperatorFilters = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddOperatorFilters>
<cfquery name="qAddOperatorFilters" datasource="#application.datasource#">
				INSERT INTO Planner_Template_Filters_Operators
					(Planner_Template_ID,Operator_Group_Level_ID,Operator_Group_ID)
				VALUES
					('#nId#', '#strGroupLevelID#', '#idx#')
			</cfquery>
</cfif>

			</cfloop>

		<cfelse>

			<cfloop index="idx" list="#lGroupList#">

			<cfquery name="qAddCustomerFilters" datasource="#application.datasource#">
				INSERT INTO Planner_Template_Filters_Products
					(Planner_Template_ID,Product_Group_Level_ID,Product_Group_ID)
				VALUES
					('#nId#', '#strGroupLevelID#', '#idx#')
			</cfquery>

			</cfloop>

		</cfif>

	</cffunction>

	<cffunction name="getPlannerTemplateCustomerTypes" output="false" access="remote" returnType="query">
		<cfargument name="id" required="false" type="string" default="0" /> <!--- planner template id --->

		<cfscript>
			local.getPlannerTemplate = queryExecute(	" SELECT Allow_Individual_Distributors
															FROM Planner_Template
															WHERE Planner_Template_ID = #arguments.id# "
																	, {}, { datasource: application.datasource } );

			local.getPlannerTemplateCustomerTypes = queryExecute(	" SELECT L.Distributor_group_level_ID,
																			cast(L.Is_pg as int) IS_PG,
																			L.Group_Level_Desc
																	FROM Planner_Template_Filters PTF
																	INNER JOIN Distributor_Group_Level L
																		ON L.Distributor_Group_Level_ID = PTF.Group_Level_ID
																	WHERE PTF.Planner_Template_ID = #arguments.id#
																		AND PTF.PG_Group_Type = 2
																		AND PTF.Allow_In_Group_Search = 1
																		ORDER BY Group_Level_Desc"
																	, {}, { datasource: application.datasource } );

			if ( local.getPlannerTemplate.Allow_Individual_Distributors eq 1 ) {
				// <!--- add distributors as an option --->
				local.sDistributorLabel = createObject("component", "components.settings.Labels.Labels").init().GetPlannerLabels('Distributor').Planner_Labels_Plural;
				local.temp =  queryAddRow(local.getPlannerTemplateCustomerTypes);
				local.temp =  querySetCell(local.getPlannerTemplateCustomerTypes, "Distributor_group_level_ID", "0" );
				local.temp =  querySetCell(local.getPlannerTemplateCustomerTypes, "IS_PG", "0");
				local.temp =  querySetCell(local.getPlannerTemplateCustomerTypes, "Group_Level_Desc", local.sDistributorLabel );
			}

			return local.getPlannerTemplateCustomerTypes;
		</cfscript>
	</cffunction>

	<cffunction name="getPlannerTemplateCustomers" output="false" access="remote" returnType="query">
		<cfargument name = "id"           required="false" type="string"  default="0" /> 	<!--- planner template id --->
		<cfargument name = "groupLevelId" required="false" type="numeric" default="0" /> 	<!--- distributors (0) --->
		<cfargument name = "isPG"         required="false" type="numeric" default="0" /> 	<!--- planning group --->

		<cfstoredproc procedure="Planner_Template_Customers" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" value="#arguments.id#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" value="#arguments.groupLevelId#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit"     value="#arguments.isPG#">
			<cfprocresult name="qryPopulatePlannerCalendar">
		</cfstoredproc>

		<cfreturn qryPopulatePlannerCalendar />
	</cffunction>

	<cffunction name="saveProgramPlannerTemplates" access="public" returntype="any" output="true">

		<cfargument name="id"         required="false"  type="string"   default="0" />
		<cfargument name="lProgramTemplateIds"  required="false"  type="string"   default="0" />
		<cfargument name="lProgramTemplateIdsAccrual"  required="false"  type="string"   default="0" />

		<cfscript>
			//set local variables
			var nId           = 0;
			var strprogramTemplateIds = "";
			var strFirstParentIds   = "";
			var idx           = "";
			var qCheckIfExists      = "";
			var qInsert         = "";

			//assign local variables
			nId           = arguments.id;
			strprogramTemplateIds = arguments.lProgramTemplateIds;
			strprogramTemplateIdsAccrual = arguments.lProgramTemplateIdsAccrual;

		</cfscript>


		<cfif trim(strprogramTemplateIds) neq "">
			<cfquery name="qGetFirstParentIds" datasource="#application.datasource#">
				SELECT  First_Parent_ID
				FROM  Program_Control_Panel_Options
				WHERE   ProgramControl_Panel_Options_ID in (#strprogramTemplateIds#)
			</cfquery>

			<cfset strFirstParentIds = ValueList(qGetFirstParentIds.First_Parent_ID) />
		</cfif>
		<!--- TODO: Add logging --->

		<cfquery name="qSetDeleted" datasource="#application.datasource#">
			UPDATE  Planner_Program_Templates
			SET   Deleted = 1
			WHERE Planner_Template_ID = '#nId#'
		</cfquery>

		<cfloop list="#strFirstParentIds#" index="idx">
			<cfset useLakebaseForqAddPlannerProgramTemplate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_program_templates")>
<cfif useLakebaseForqAddPlannerProgramTemplate>
	<cftry>
		<cfset application.oLakebase.insertRow("planner_program_templates", {
			"planner_template_id" = "#nId#",
			"first_parent_id" = "#idx#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddPlannerProgramTemplate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddPlannerProgramTemplate>
<cfquery name="qAddPlannerProgramTemplate" datasource="#application.datasource#">
				INSERT INTO Planner_Program_Templates
					(Planner_Template_ID, First_Parent_ID)
				VALUES
				('#nId#', '#idx#')
			</cfquery>
</cfif>

		</cfloop>

		<!--- Repeat the same as above for the accrual records:--->
		<cfset useLakebaseForqSetDeletedAccrual = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_program_templates_accrual")>
<cfif useLakebaseForqSetDeletedAccrual>
	<cftry>
		<cfset application.oLakebase.updateRows("planner_program_templates_accrual",
			{
				"planner_template_id" = "eq.#nId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSetDeletedAccrual = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSetDeletedAccrual>
<cfquery name="qSetDeletedAccrual" datasource="#application.datasource#">
			UPDATE  Planner_Program_Templates_Accrual
			SET   Deleted = 1
			WHERE Planner_Template_ID = '#nId#'
		</cfquery>
</cfif>
		<cfif trim(strprogramTemplateIdsAccrual) neq "">
			<cfquery name="qGetFirstParentIdsAccrual" datasource="#application.datasource#">
				SELECT  First_Parent_ID
				FROM  Program_Control_Panel_Options
				WHERE   ProgramControl_Panel_Options_ID in (#strprogramTemplateIdsAccrual#)
			</cfquery>

			<cfset strFirstParentIdsAccrual = ValueList(qGetFirstParentIdsAccrual.First_Parent_ID) />
		
			<!--- TODO: Add logging --->
			<cfloop list="#strFirstParentIdsAccrual#" index="idx">
				<cfquery name="qAddPlannerProgramTemplateAccrual" datasource="#application.datasource#">
					INSERT INTO Planner_Program_Templates_Accrual
						(Planner_Template_ID, First_Parent_ID, Selected, Deleted, created_by)
					VALUES
					('#nId#', '#idx#', 1, 0, '#request.accessStructure.User_Id#')
				</cfquery>
			</cfloop>
		</cfif>		
	</cffunction>

	<cffunction name="getPlannerProductGroups" output="false" returnType="query">
		<cfargument name="productGroupLevelId" required="true" type="numeric"  />
		<cfargument name="plannerId" required="false" type="numeric" default="0"  />
		<!--- This function is invoked from multiple places. 1) Planner template 2) planners --->
		<cfscript>
			local.planner_template_product_filter = 0;
			local.suppressGroupsZeroItems = 0;
			local.ADLEnabled = 0;

			if(arguments.plannerId) {
				local.PlannerManager = CreateObject("component", "mvc.Models.Planner.PlannerManager");
				//<!--- We should apply these filters only when called from inside planners --->
				local.planner_template_product_filter = local.PlannerManager.tmp_planner_template_filter_products(arguments.plannerId);
				local.suppressGroupsZeroItems         = application.appsettingsget.getSuppressGroupsZeroItems();
				local.Populate_180Day_From            = application.appsettingsget.getPopulate_180Day_From();
				local.FilterOnDistributor             = 0;

				if ( local.suppressGroupsZeroItems
						 AND local.Populate_180Day_From eq 0
						 AND this.udf.is_planner_indirect_category( arguments.plannerID ) eq false ) {
					local.PlannerManager.tmp_planner_distributors(arguments.plannerId);
					local.FilterOnDistributor = 1;
				}
				if ( application.util.query.get_Setting("Authorized_Distribution_List_Enabled", 0) == "1" ) {
					local.ADLEnabled = 1;
				}
			}
		</cfscript>

		<cfquery name="local.qDropTables" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_planner_ADL_list') IS NOT NULL
			DROP TABLE ##tmp_planner_ADL_list

			IF OBJECT_ID('tempdb..##tmp_Product_Customer_Group') IS NOT NULL
			DROP TABLE ##tmp_Product_Customer_Group
		</cfquery>

        <cfquery name="local.getPlannerProductGroups" datasource="#application.datasource#">
            <cfif arguments.plannerId and local.suppressGroupsZeroItems and local.ADLEnabled>
		<!--- Get list of products with ADL --->
		IF OBJECT_ID('tempdb..##tmp_planner_ADL_list') IS NOT NULL
		DROP TABLE ##tmp_planner_ADL_list

		create table ##tmp_planner_ADL_list (
			Product_ID uniqueidentifier,
			Include bit
		)
		INSERT INTO ##tmp_planner_ADL_list (Product_ID, Include)
		EXEC Planner_ADL_Products #arguments.plannerId#

                IF OBJECT_ID('tempdb..##tmp_Product_Customer_Group') IS NOT NULL
	    	DROP TABLE ##tmp_Product_Customer_Group

		-- Insert from 180 day table
		SELECT  DISTINCT Product_ID
                INTO    ##tmp_Product_Customer_Group
		FROM	Product_Customer_Group
		<cfif local.FilterOnDistributor>
                WHERE EXISTS (SELECT 1 FROM ##tmp_planner_distributors d WHERE d.BSA_Foodservice_Customers_ID = Product_Customer_Group.Customer_ID)
                </cfif>

		-- Insert when included in ADL
                INSERT INTO ##tmp_Product_Customer_Group (Product_ID)
                SELECT  Product_ID
                FROM    ##tmp_planner_ADL_list adl
                WHERE   Include = 1
                AND	NOT EXISTS (SELECT 1 FROM ##tmp_Product_Customer_Group t WHERE t.Product_ID = adl.Product_ID)

		-- Delete when excluded in ADL
                DELETE  ##tmp_Product_Customer_Group
                WHERE   Product_ID IN (SELECT Product_ID FROM ##tmp_planner_ADL_list WHERE Include = 0)

	    </cfif>

			SELECT   grp.Group_Desc as Group_Name,
					 grp.Group_GUID as Group_ID,
					 grp.Group_Number
			FROM     All_Product_Group_Types grp
			WHERE    grp.Product_Group_Level_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.productGroupLevelId#">
			AND      grp.Deleted = 0
			<cfif local.planner_template_product_filter>
			AND     EXISTS (
				SELECT  1
				FROM    All_product_Group_Type_Members m
				INNER JOIN ##tmp_planner_template_filter_products p
				ON 		p.Product_ID = m.BSA_Foodservice_Items_Master_ID
				<cfif local.suppressGroupsZeroItems>
		                    <cfif arguments.plannerId and local.suppressGroupsZeroItems and local.ADLEnabled>
		                        <!--- Include/Exclude products based on ADL entry --->
		                        INNER JOIN ##tmp_Product_Customer_Group Product_Customer_Group
		                        ON 		Product_Customer_Group.Product_ID = m.BSA_Foodservice_Items_Master_ID
				    <cfelse>
		                        INNER JOIN Product_Customer_Group
		                        ON 		Product_Customer_Group.Product_ID = m.BSA_Foodservice_Items_Master_ID
		                        <cfif local.FilterOnDistributor>
		                        AND		EXISTS (SELECT 1 FROM ##tmp_planner_distributors d WHERE d.BSA_Foodservice_Customers_ID = Product_Customer_Group.Customer_ID)
		                    	</cfif>
		                     </cfif>
				</cfif>
				WHERE   m.Product_Group_ID = grp.Group_GUID
			)
			<cfelseif local.suppressGroupsZeroItems>
			AND     EXISTS (
				SELECT  1
				FROM    All_product_Group_Type_Members m
		                <cfif arguments.plannerId and local.suppressGroupsZeroItems and local.ADLEnabled>
		                     <!--- Include/Exclude products based on ADL entry --->
		                    INNER JOIN ##tmp_Product_Customer_Group Product_Customer_Group
		                    ON 		Product_Customer_Group.Product_ID = m.BSA_Foodservice_Items_Master_ID
				<cfelse>
		                    INNER JOIN Product_Customer_Group
		                    ON 		Product_Customer_Group.Product_ID = m.BSA_Foodservice_Items_Master_ID
		                    WHERE   m.Product_Group_ID = grp.Group_GUID
		                    <cfif local.FilterOnDistributor>
		                    AND		EXISTS (SELECT 1 FROM ##tmp_planner_distributors d WHERE d.BSA_Foodservice_Customers_ID = Product_Customer_Group.Customer_ID)
		                    </cfif>
		                </cfif>
			)
			</cfif>
			ORDER BY grp.Group_Desc
		</cfquery>

		<cfreturn local.getPlannerProductGroups />

	</cffunction>


	<cffunction name="updateTemplateStatus" output="false">
		<cfargument name="templates_list" required="true">
		<cfargument name="active_status" required="true">

		<cfquery name="local.updateTemplateStatus" datasource="#application.datasource#">
			UPDATE Planner_Template
			   SET Active = #arguments.active_status#
			 WHERE Planner_Template_ID IN (<cfqueryparam value="#arguments.templates_list#" list="true">)
		</cfquery>
	</cffunction>


	<cffunction name="allowedTemplates" output="false" hint="Returns a list of allowed planner templates based on user's profile.">
		<cfargument name="user_profile_id" required="false" default="#request.accessStructure.profiles_id#">

		<!--- locate for a specific profile --->
		<cfset useLakebaseForlocal_qAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_forbidden_planner")>
<cfif useLakebaseForlocal_qAccess>
	<cftry>
		<cfset local.qAccess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_forbidden_planner", {
				"profile_id" = "eq.#arguments.user_profile_id#",
				"access_is_forbidden" = "eq.0",
				"deleted" = "eq.0",
				"select" = "planner_template_id"
			}), "planner_template_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qAccess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qAccess>
<cfquery name="local.qAccess" datasource="#application.datasource#">
			SELECT planner_template_id
			  FROM Profile_Forbidden_Planner
			 WHERE Profile_ID = #arguments.user_profile_id#
			 		AND Access_is_forbidden = 0
					AND Deleted = 0
		</cfquery>
</cfif>

		<!--- a specific profile does not exist (it may be new) so find "any new profiles" --->
		<cfif local.qAccess.recordCount eq 0>
			<cfquery name="local.qAccess" datasource="#application.datasource#">
				SELECT planner_template_id
				  FROM Profile_Forbidden_Planner
				 WHERE Profile_ID = 0
				 		AND Access_is_forbidden = 0
				 		AND Deleted = 0
			</cfquery>
		</cfif>

		<cfreturn valueList(local.qAccess.planner_template_id)>
	</cffunction>

		<!---
				115103: Retail Planner Template - updates / Anand Rao / 31-May-2022
				Lock/Unlock the Planner template
		--->
	<cffunction name="lockUnlockPlannerTemplate" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">
		<cfargument name="plannerId" type="numeric" required="false" default="0"  />
		<cfargument name="lockUnlock" type="numeric" required="true" default="0"  />

		<cfset var qLock = "" />
		<cfif (arguments.lockUnlock EQ 1)>
		<!--- 1 = Lock; 0 = Unlock --->
			<cfquery name="qLock" datasource="#application.datasource#">
				/* Unlock all the Planner Template locked by this user  */
				UPDATE Planner_Template
					SET Is_locked = 0,
						Locked_By_User_ID = NULL,
						Locked_Date = NULL
					WHERE
						Locked_By_User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">

				UPDATE Planner_Template
					SET Is_locked = 1,
						Locked_By_User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
						Locked_Date = GetDate()
				 	WHERE
						Planner_Template_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerId#">
			</cfquery>
		<cfelse>
			<cfquery name="qLock" datasource="#application.datasource#">
				UPDATE Planner_Template
					SET Is_locked = 0,
						Locked_By_User_ID = NULL,
						Locked_Date = NULL
				 	WHERE
						Locked_By_User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			</cfquery>

		</cfif>
		<cfreturn true />
	</cffunction>



</cfcomponent>
