<!----------------------------------------------------------------------------------
Name         :  PlannerManager.cfc
Copyright    :  (c) 2016 Blacksmith Applications, Inc.
Created Date :  03/01/2016
Created By   :  KAL
Description  :  Manager for Planners
---------------------------------------------------------------------------------->


<cfcomponent name="PlannerManager" displayname="PlannerManager" hint="Manager for Planner Settings">

	<cfscript>
		this.debug_log = 0;
		this.udf       = createObject( "component", "components.udf" );
	</cfscript>

	<!--- get the list of planners --->
	<cffunction name="getAllPlanners" access="public" returntype="query" output="false" >
		<cfargument name="status" required="false" default="" type="string" />

		<cfquery name="local.qGetAllPlanners" datasource="#application.datasource#">
			SELECT *
			FROM Planners
			WHERE Deleted = 0
			<cfif len(arguments.status)>
				AND Active = '#arguments.status#' <!--- active filed is bit, so skipping queryparm --->
			</cfif>
		</cfquery>

		<cfreturn   local.qGetAllPlanners />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- get a planner --->
	<cffunction name="getPlanner" access="public" returntype="query" output="false" >
		<cfargument name="plannerId" required="true" type="numeric" />

		<cfquery name="local.qGetPlanner" datasource="#application.datasource#">
			SELECT P.Planner_ID,
			       P.Planner_Number,
			       P.Planner_Title,
			       P.Planner_NickName,
			       P.Planner_Perf_Start_Day,
			       P.Planner_Expected_Margin,
			       PT.Planner_Template_ID,
			       PT.Planner_Type,
			       PT.Planner_Description,
			       PT.Planner_Start_Date,
			       PT.Planner_End_Date,
			       PT.PY_Summary_Display,
			       PT.Locked_Forecast_Display,
			       PT.Demand_Plan_Display,
			       PT.AOP_Display,
			       PT.Prior_Yr_Display,
			       PT.Forecast_Display,
			       PT.Forecast_Percent_PY_Display,
			       PT.Actual_Display,
			       PT.Actual_Percent_Forecast_Display,
			       PT.uom_default,
			       P.Volume_Plan_UOM,
			       PT.UOM_CS,
			       PT.UOM_LB,
						 PT.UOM_EA,
			       PT.Locked_Forecast_Default,
			       PT.Demand_Plan_Default,
			       PT.AOP_Default,
			       PT.Prior_Yr_Default,
			       PT.Forecast_Default,
			       PT.Forecast_Percent_PY_Default,
			       PT.Actual_Default,
			       PT.Actual_Percent_Forecast_Default,
			       PT.Indirect_Volume_Display,
			       PT.Indirect_Volume_Default,
			       PT.Indirect_Volume_Percent_Forecast_Display,
			       PT.Indirect_Volume_Percent_Forecast_Default,
			       C.BSA_Foodservice_Customers_ID,
			       C.Ship_To,
			       C.Name,
			       PS.Status_ID,
			       PS.Status_Description,
			       PS.Status_Abbreviation,
			       P.Active,
			       P.Deleted,
			       P.RSP_ID,
			       P.Creator_Position_ID,
			       P.Created_By,
			       P.Created_Date,
			       P.Approved,
			       P.Approver_ID,
			       P.Approved_Date,
			       P.AOP_CS,
			       P.AOP_LB,
			       P.AOP_Sales_Dollars,
			       P.Forecast_CS,
			       P.Forecast_LB,
			       P.Forecast_Sales_Dollars,
			       P.Actual_CS,
			       P.Actual_LB,
			       P.Actual_Sales_Dollars,
			       P.AOP_Trade_Dollars,
			       P.Planned_Trade_Dollars,
			       P.Approved_Trade_Dollars,
			       P.Committed_Trade_Dollars,
			       P.Actual_Trade_Dollars,
			       P.Updated_Date,
			       P.Updated_By,
			       PT.Program_Default_UOM,
			       ISNULL(rspUser.Name_First + ' ' + rspUser.Name_Last, '') AS RSP_User_Name,
			       ISNULL(rspUserPositions.Position_Label, ' ') AS RSP_Position,
			       System_Locked,
			       System_Locked_Date,
			       PT.Wholesaler_Planner,
			       P.Parent_Planner_ID,
			       (   SELECT COUNT(1)
			             FROM Planners ip
			            WHERE ip.Parent_Planner_ID = P.Planner_ID
			              AND ip.Deleted           = 0) AS Indirect_Count,
			       (   SELECT COUNT(1)
			             FROM Planners ip
			            WHERE ip.Parent_Planner_ID = P.Planner_ID
			              AND ip.Status_ID         = 1
			              AND ip.Deleted           = 0) AS Indirect_WIP,
			       (   SELECT COUNT(1)
			             FROM Planners ip
			            INNER JOIN Lock
			               ON Main_Id      = 'Planner'
			              AND Secondary_ID = ip.Planner_ID
						  AND Locked_By_User_Id > ''
			            WHERE ip.Parent_Planner_ID = P.Planner_ID
			              AND ip.Deleted           = 0) AS Indirect_Locks,
					ISNULL(PT.Business_Segment_ID, 0) as Business_Segment_ID,
					rspUser.User_Email as RSP_User_Email,
                    PT.Category,
					ISNULL(p.Distributor_Group_Level_ID, 0) as Distributor_Group_Level_ID,
					PT.Program_Volume_Default_UOM,
					PT.Allow_Individual_Distributors
					,PT.YTD_Display
					,PT.YTD_Default
			  FROM Planners P
			 INNER JOIN Planner_Template PT
			    ON PT.Planner_Template_ID             = P.Planner_Template_ID
			  LEFT JOIN BSA_Foodservice_Customers C
			    ON C.BSA_Foodservice_Customers_ID     = P.Customer_ID
			  LEFT JOIN Planner_Status PS
			    ON PS.Status_ID                       = P.Status_ID
			  LEFT JOIN _Users rspUser
			    ON rspUser.User_ID                    = P.RSP_ID
			  LEFT JOIN User_Positions rspUserPositions
			    ON rspUserPositions.User_Positions_ID = P.Creator_Position_ID
			 WHERE Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			   AND P.Deleted  = 0;
		</cfquery>

		<cfreturn   local.qGetPlanner />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- get a planner --->
	<cffunction name="getPlannerLite" access="public" returntype="query" output="false" >
		<cfargument name="plannerId" required="true" type="numeric" />

		<cfquery name="local.qGetPlanner" datasource="#application.datasource#">
			SELECT P.Planner_ID,
			       P.Planner_Number,
			       P.Planner_Title,
			       P.Parent_Planner_ID,
			       PT.Category
			 FROM Planners P
			 INNER JOIN Planner_Template PT
			    ON PT.Planner_Template_ID             = P.Planner_Template_ID
			 WHERE Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			   AND P.Deleted  = 0;
		</cfquery>

		<cfreturn   local.qGetPlanner />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- planner number generator --->
	<cffunction name="generatePlannerNumber" access="public" returntype="string" output="false" >

		<cfset var generatedPlannerNumber = "" />

		<cflock timeout = "15">
		<!--- Generate new planner number --->
		<cfstoredproc procedure="generate_planner_number" datasource="#application.datasource#">
			<cfprocparam variable="new_number" type="out" cfsqltype="cf_sql_varchar" />
		</cfstoredproc>

		<!------ Format the number  ----->
		<cfset generatedPlannerNumber = CreateObject("component", "components.settings.ApplicationNumberManager").getFormatedBANumber
				(
				number = new_number,
				prefix = application.oApplicationAppSettingsManager.getApplicationAppSettings().getPlannerNumberPrefix()
				) />
		</cflock>

		<cfreturn generatedPlannerNumber />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="generatePlannerTitle" access="remote" returntype="string"  output="false" >
		<cfargument name="customerIdList" type="string" required="true" > 	<!--- customer --->

		<cfquery name="local.qCreateTitle" datasource="#application.datasource#">
				SELECT Top 1 RTRIM(LTRIM(Ship_To)) as Ship_To, RTRIM(LTRIM(Name)) as Name
				  FROM BSA_Foodservice_Customers
				 WHERE BSA_Foodservice_Customers_ID IN (#listqualify(arguments.customerIdList,"'",",","all")#)
			  ORDER BY Name
		</cfquery>

		<cfscript>
			return local.qCreateTitle.Name & " (" & (listLen(arguments.customerIdList) gt 1 ? "et.al":local.qCreateTitle.Ship_To) & ") ";
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="generateIndirectPlannerTitle" access="remote" returntype="string"  output="false" >
		<cfargument name="operatorIdList" type="string" required="true" > 	<!--- operators --->

		<cfquery name="local.qCreateTitle" datasource="#application.datasource#">
				SELECT Top 1 RTRIM(LTRIM(BSA_Operator_ID)) as BSA_Operator_ID, RTRIM(LTRIM(Operator_Name)) as Name
				  FROM BSA_Operator
				 WHERE BSA_Operator_ID IN (#listqualify(arguments.operatorIdList,"'",",","all")#)
			  ORDER BY Operator_Name
		</cfquery>

		<cfscript>
			return local.qCreateTitle.Name;
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="generateMSAPlannerTitle" access="remote" returntype="string"  output="false" >
		<cfargument name="operatorIdList" type="string" required="true" > 	<!--- operators --->

		<cfquery name="local.qCreateTitle" datasource="#application.datasource#">
				SELECT Legacy_ID, RTRIM(LTRIM(Operator_Name)) as Name
				  FROM BSA_Operator
				 WHERE BSA_Operator_ID IN (#listqualify(arguments.operatorIdList,"'",",","all")#)
		</cfquery>

        <cfreturn local.qCreateTitle.Name & " (" & (listLen(arguments.operatorIdList) gt 1 ? "et.al":local.qCreateTitle.Legacy_ID) & ") ">
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- check for duplicates --->
	<cffunction name="checkForDuplicatePlanner" access="remote" returntype="query"  output="false" >
		<cfargument name="templateID" type="numeric" required="true" >              <!--- templateID --->
		<cfargument name="groupLevelId" type="numeric" required="true" >            <!--- dist group level id --->
		<cfargument name="customerIdList" type="string" required="true" >           <!--- customer --->

		<!--- handle for multiple customers --->
		<cfset local.nGroupId   = arguments.groupLevelId />
		<cfset local.customerId = arguments.customerIdList />


		<cfif arguments.groupLevelId eq 0 AND listlen(arguments.customerIdList) gt 1 >
			<cfset local.nGroupId   = "-1" />
			<cfset local.customerId = '00000000-0000-0000-0000-000000000000' />
		</cfif>

		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
			if object_id('tempdb..##Tmp_Create_Planner_Distributors') is not null
			drop table ##Tmp_Create_Planner_Distributors

			Create Table ##Tmp_Create_Planner_Distributors (Distributor_ID uniqueidentifier)
		</cfquery>

		<!--- insert multiple customers --->
		<cfif local.nGroupId eq "-1">
			<cfquery name="local.qInsertPlannerCustomers" datasource="#application.datasource#">
				<cfloop list="#arguments.customerIdList#" index="customer">
					insert into ##Tmp_Create_Planner_Distributors (Distributor_ID)
					select	'#customer#'
				</cfloop>
			</cfquery>
		</cfif>

		<!--- call procedure --->
		<cfstoredproc procedure="Planner_Check_Duplicate" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" value="#arguments.templateID#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" value="#local.nGroupId#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" value="#local.customerId#">
			<cfprocresult name="qryDupicatePlanner">
		</cfstoredproc>

		<cfreturn qryDupicatePlanner />

	</cffunction>


	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- create a planner --->
	<cffunction name="createPlanner" access="remote" returntype="string"  output="false" >
		<cfargument name="userID" type="string" required="true" >                   <!--- userID/creatorID --->
		<cfargument name="positionID" type="string" required="true" >               <!--- positionID --->
		<cfargument name="rspID" type="string" required="true" >               		<!--- rspID --->
		<cfargument name="templateID" type="numeric" required="true" >              <!--- templateID --->
		<cfargument name="customerIdList" type="string" required="true" >           <!--- customer --->
		<cfargument name="groupLevelId" type="numeric" required="true" >            <!--- dist group level id --->

		<cfset var newPlannerNumber = this.generatePlannerNumber() />
		<cfset var weekStart = application.oApplicationAppSettingsManager.getApplicationAppSettings().get_Setting('Retail_Planner_Week_Start') />

		<!--- generate a planner title --->
		<cfset local.planner_title = generatePlannerTitle(arguments.customerIdList) />

		<!--- handle for multiple customers --->
		<cfset local.nGroupId   = arguments.groupLevelId />
		<cfset local.customerId = arguments.customerIdList />

		<cfif arguments.groupLevelId eq 0 AND listlen(arguments.customerIdList) gt 1 >
			<cfset local.nGroupId   = "-1" />
			<cfset local.customerId = '00000000-0000-0000-0000-000000000000' />
		</cfif>

		<!--- insert --->
		<cfquery name="local.qCreatePlanner" datasource="#application.datasource#">
			INSERT INTO Planners
				(
					Planner_Template_ID,
					Planner_Number,
					Planner_Title,
					Customer_ID,
					Distributor_Group_Level_ID,
					Creator_Position_ID,
					RSP_ID,
					Status_ID,
					Planner_Perf_Start_Day,
					Created_By,
					Volume_Plan_UOM
				)
				Output Inserted.Planner_ID
			Values (
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.templateID#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#newPlannerNumber#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.planner_title#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.customerId#" >,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.nGroupId#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.positionID#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.rspID#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="1" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#weekStart#" >,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" >,
				(SELECT UOM_Default
				   FROM Planner_Template PT
				  WHERE PT.Planner_Template_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.templateID#">)
				)
		</cfquery>

		<!--- insert multiple customers --->
		<cfif local.nGroupId eq "-1">
			<cfquery name="local.qInsertPlannerCustomera" datasource="#application.datasource#">
				<cfloop list="#arguments.customerIdList#" index="customer">
					insert into Planner_Customer_Group_Members (Planner_ID, Distributor_ID)
					select	'#local.qCreatePlanner.Planner_ID#', '#customer#'
				</cfloop>
			</cfquery>
		</cfif>

		<!--- capture customer group members --->
		<cfset local.plannerCustGrpCapture = this.plannerCustomerGroupCapture(local.qCreatePlanner.Planner_ID) />

		<cfreturn	local.qCreatePlanner.Planner_ID />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="createIndirectPlanner" output="false">
		<cfargument name="form" required="true">

		<!--- generate indirect planner title --->
		<cfset local.indirect_planner_title = generateIndirectPlannerTitle(arguments.form.operator_ids) />

		<cftransaction>
			<cfquery name="local.qIndirectPlanner" datasource="#application.datasource#">
				DECLARE @distributor_group_level_id AS INT,
						@customer_id AS NVARCHAR(50)

				SELECT @distributor_group_level_id = Distributor_Group_Level_ID,
				       @customer_id = Customer_ID
				  FROM Planners
				 WHERE Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.form.parent_planner_id#" >

				INSERT INTO Planners
					(
						Created_By,
						Creator_Position_ID,
						Customer_ID,
						Distributor_Group_Level_ID,
						Parent_Planner_ID,
						Planner_Number,
						Planner_Perf_Start_Day,
						Planner_Template_ID,
						Planner_Title,
						RSP_ID,
						Status_ID
					)
					OUTPUT Inserted.Planner_ID
				VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.form.creator_user_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.form.rsp_position_id#" >,

						@customer_id,
						@distributor_group_level_id,

						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.form.parent_planner_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#generatePlannerNumber()#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.oApplicationAppSettingsManager.getApplicationAppSettings().get_Setting('Retail_Planner_Week_Start')#" >,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.form.planner_template_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.indirect_planner_title#" >,

						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.form.rsp_user_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="1" >
					)
			</cfquery>

			<cfquery name="local.qOperators" datasource="#application.datasource#">
				<cfloop list="#arguments.form.operator_ids#" index="local.operator_id">
					INSERT INTO Planner_Operators
						(
							BSA_Operator_ID,
							Created_By,
							Planner_ID
						)
					VALUES
						(
							<cfqueryparam value="#local.operator_id#">,
							<cfqueryparam value="#arguments.form.creator_user_id#">,
							<cfqueryparam value="#local.qIndirectPlanner.Planner_ID#">
						)
				</cfloop>

				INSERT INTO Planner_Customer_Group_Members
					(
						Planner_ID,
						Distributor_ID
					)
					SELECT #local.qIndirectPlanner.Planner_ID# as Planner_ID, Distributor_ID
					  FROM    Planner_Customer_Group_Members
					 WHERE   Planner_ID = <cfqueryparam value="#arguments.form.parent_planner_id#">
			</cfquery>
		</cftransaction>

		<cfreturn local.qIndirectPlanner.Planner_ID>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="createMSAPlanner" output="false">
		<cfargument name="form" required="true">

		<!--- generate MSA planner title --->
		<cfset local.planner_title = generateMSAPlannerTitle(arguments.form.operator_ids) />

		<cftransaction>
			<cfquery name="local.qMSAPlanner" datasource="#application.datasource#">
				DECLARE @distributor_group_level_id AS INT,
						@customer_id AS NVARCHAR(50)

				SET @distributor_group_level_id = -1
                SET @customer_id = '00000000-0000-0000-0000-000000000000'

				INSERT INTO Planners
					(
						Created_By,
						Creator_Position_ID,
						Customer_ID,
						Distributor_Group_Level_ID,
						Planner_Number,
						Planner_Perf_Start_Day,
						Planner_Template_ID,
						Planner_Title,
						RSP_ID,
						Status_ID
					)
					OUTPUT Inserted.Planner_ID
				VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.user_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.form.rsp_position_id#" >,

						@customer_id,
						@distributor_group_level_id,

						<cfqueryparam cfsqltype="cf_sql_varchar" value="#generatePlannerNumber()#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.oApplicationAppSettingsManager.getApplicationAppSettings().get_Setting('Retail_Planner_Week_Start')#" >,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.form.planner_template_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.planner_title#" >,

						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.form.rsp_user_id#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="1" >
					)
			</cfquery>

			<cfquery name="local.qOperators" datasource="#application.datasource#">
				<cfloop list="#arguments.form.operator_ids#" index="local.operator_id">
					INSERT INTO Planner_Operators
						(
							BSA_Operator_ID,
							Created_By,
							Planner_ID
						)
					VALUES
						(
							<cfqueryparam value="#local.operator_id#">,
							<cfqueryparam value="#request.AccessStructure.user_id#">,
							<cfqueryparam value="#local.qMSAPlanner.Planner_ID#">
						)
				</cfloop>
			</cfquery>
		</cftransaction>

		<cfreturn local.qMSAPlanner.Planner_ID>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="plannerCustomerGroupCapture" output="false" access="remote" returntype="void" hint="captures memeber of planner customer group for a given planner ID.">
		<cfargument name="plannerID" type="numeric" required="true">

		<cfstoredproc procedure="Planner_Customer_Group_Capture" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" value="#arguments.plannerID#">
		</cfstoredproc>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerWeeks" returntype="query" hint="Returns planner weeks based on a given planner ID.">
		<cfargument name="plannerID" type="numeric" required="true"> <!--- planner id --->
		<cfargument name="programID" required="false">

		<cfquery name="local.qPeriods" datasource="#application.datasource#">
			SELECT 	Planner_Week.Planner_Week_ID AS Period_ID
					,Planner_Week.Planner_Week_Number
					,Planner_Week.Planner_Week_Start_Date
					,Planner_Week.Planner_Week_End_Date
					,Planner_Week.PY_Week_Start_Date
					,Planner_Week.PY_Week_End_Date
			FROM    Planners
			INNER JOIN Planner_Template
					ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
					AND Planner_Template.Deleted = 0
			INNER JOIN Planner_Week
					ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
						 AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
						 AND Planner_Week.Deleted = 0
			<cfif isDefined("arguments.programID")>
				INNER JOIN Contract_Main ON Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			</cfif>
			WHERE   Planners.Planner_ID = 	<cfif not isDefined("arguments.programID")>
												<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerID#">
											<cfelse>
												Contract_Main.Planner_ID
											</cfif>
			ORDER BY Planner_Week.Planner_Week_Start_Date
		</cfquery>

		<cfreturn local.qPeriods />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerMonths" returntype="query" hint="Returns planner months based on a given planner ID.">
		<cfargument name="plannerID" type="numeric" required="true">

		<cfquery name="local.qPeriods" datasource="#application.datasource#">
            SELECT DISTINCT
                    REPLACE(RIGHT(CONVERT(VARCHAR, DATEFROMPARTS(Display_Year, Display_Month, 1), 106), 8), ' ', '_') AS Period_ID
                    , CONVERT(VARCHAR(7), DATEFROMPARTS(Display_Year, Display_Month, 1), 126) AS [YYYY-MM]
            FROM Planners
            INNER JOIN Planner_Template
                ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
                    AND Planner_Template.Deleted = 0
            INNER JOIN Planner_Week
                ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
                    AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
                    AND Planner_Week.Deleted = 0
            WHERE Planners.Planner_ID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerID#">
            ORDER BY CONVERT(VARCHAR(7), DATEFROMPARTS(Display_Year, Display_Month, 1), 126)
		</cfquery>

		<cfreturn local.qPeriods />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerProducts" hint="Returns products based on a given planner ID and product group level ID.">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="product_group_level_id" required="false" default="">
		<cfargument name="caller" required="false" default="">
		<cfargument name="filter_product_group_level_id" required="false" default="">
		<cfargument name="filter_product_list" required="false" default="">

		<cfscript>
			tmp_planner_distributors( arguments.plannerId );
			local.planner_template_product_filter = tmp_planner_template_filter_products(arguments.plannerID);

			local.product_group_level_id_aux = 0;
			local.product_mode = 0;
			if(arguments.product_group_level_id == 0 || arguments.product_group_level_id == 9 || arguments.product_group_level_id == ""){
				local.product_mode = 1;
			}


			if(arguments.caller == "timeline"){
				// If product, then order results based on group description so that products that belong to same group are together
				if(local.product_mode == 1){
					local.product_group_level_id_aux = application.appSettingsGet.get_Setting('Retail_Margin_Sub_Total_Group');
					if(local.product_group_level_id_aux == '')
						local.product_group_level_id_aux = 11;
				}
			}
		</cfscript>

		<cfquery datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_planner_items') IS NOT NULL
				DROP TABLE ##tmp_planner_items
		</cfquery>

		<cfquery name="local.create" datasource="#application.datasource#">
			CREATE TABLE ##tmp_planner_items (
				BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER,
				Item_key UNIQUEIDENTIFIER,
				Item varchar(100),
				Description varchar(100),
				Active_Code char(1),
				Group_GUID UNIQUEIDENTIFIER,
				Group_ID varchar(100),
				Group_Name varchar(100)
			)

            <cfif local.product_mode eq 1>
                select	 'BSA_Foodservice_Items_Master_ID' AS Product_Group_Attribute_Master_ID_Field,
                         'BSA_Foodservice_Items_Master' AS Product_Group_Attribute_Table,
                         'BSA_Foodservice_Items_Master_ID' AS Product_Group_Attribute_ID_Field,
                         'Description' AS Product_Group_Attribute_Name_Field,
                         'Item' AS Product_Group_Attribute_Number_Field
            <cfelse>
                select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
                         a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
                         a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
                         a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
                         a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
                from	Product_Group_Attribute a
                where	Product_Group_Level_ID = #arguments.product_group_level_id#
                        or Product_Group_Level_ID = #local.product_group_level_id_aux#
            </cfif>
		</cfquery>

        <cfif arguments.filter_product_group_level_id neq ''>
            <cfquery name="local.qFilter" datasource="#application.datasource#">
                    select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
                            a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
                            a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
                            a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
                            a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
                    from	Product_Group_Attribute a
                    where   Product_Group_Level_ID = #arguments.filter_product_group_level_id#
            </cfquery>
        </cfif>

		<cfset local.filterSegment = getSegmentFilter() />

        <cfscript>
            local.item_key    = "BSA_Foodservice_Items_Master." & local.create.Product_Group_Attribute_Master_ID_Field;
            local.item        = "grp." & local.create.Product_Group_Attribute_Number_Field;
            local.description = "grp." & local.create.Product_Group_Attribute_Name_Field;
            local.inner_join  = "INNER JOIN "
                                    & local.create.Product_Group_Attribute_Table & " grp "
                                    & " ON grp." & local.create.Product_Group_Attribute_ID_Field
                                    & " = BSA_Foodservice_Items_Master." & local.create.Product_Group_Attribute_Master_ID_Field;
        </cfscript>

        <cfquery name="local.qProducts" datasource="#application.datasource#">
            INSERT INTO ##tmp_planner_items (BSA_Foodservice_Customers_ID, Item_key, Item, Description
                    <cfif local.product_group_level_id_aux neq 0>
                        ,Active_Code
                    </cfif>
                )

			SELECT  Planners.Customer_ID as BSA_Foodservice_Customers_ID,
                    #local.item_key# AS Item_Key,
                    #local.item# AS Item,
                    #local.description# AS Description
                    <cfif local.product_group_level_id_aux neq 0>
                        ,BSA_Foodservice_Items_Master.Active_Code
                    </cfif>
			FROM    Planners
			INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
						ON 1=1
			INNER JOIN Planner_Template
					ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
						AND Planner_Template.Deleted = 0
			INNER JOIN Planner_Week
					ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
						AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
						AND Planner_Week.Deleted = 0
			INNER JOIN Planner_Volume_Plan
					ON Planner_Volume_Plan.Planner_Week_ID = Planner_Week.Planner_Week_ID
						AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
					<cfif this.udf.is_planner_indirect_category( arguments.plannerID )>
						AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
					<cfelse>
						AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
					</cfif>
					<cfif local.filterSegment>
						AND Planner_Volume_Plan.Business_Segment_ID = Planner_Template.Business_Segment_ID
					</cfif>
			INNER JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID

            #local.inner_join#

			WHERE   Planners.Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerId#">
				<cfif local.planner_template_product_filter>
						AND Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID IN (SELECT Product_ID FROM ##tmp_planner_template_filter_products)
				</cfif>

                <cfif arguments.filter_product_list neq "">
					<cfif local.qFilter.Product_Group_Attribute_ID_Field neq "PG_Product_Category_ID">
                    	AND BSA_Foodservice_Items_Master.#local.qFilter.Product_Group_Attribute_ID_Field# IN ( <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.filter_product_list#"> )
                    <cfelse>
                    	AND EXISTS (
									 SELECT TOP 1 1
                                       FROM PG_Product_Members m
                                      WHERE m.PG_Product_Category_ID IN ( <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.filter_product_list#"> )
                            				AND m.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
											AND m.Deleted = 0
                        			)
					</cfif>
				</cfif>

			GROUP BY Planners.Customer_ID,
                    BSA_Foodservice_Items_Master.#local.create.Product_Group_Attribute_ID_Field#,
                    grp.#local.create.Product_Group_Attribute_Number_Field#,
                    grp.#local.create.Product_Group_Attribute_Name_Field#
                    <cfif local.product_group_level_id_aux neq 0>
                        ,BSA_Foodservice_Items_Master.Active_Code
                    </cfif>

			Select   BSA_Foodservice_Customers_ID, Item_key, Item, Description, Active_Code
			from    ##tmp_planner_items
			<cfif application.util.query.get_setting( "Sort_Planner_Products_By", 0 ) is "Description">
					ORDER BY Description
			<cfelseif arguments.caller eq "timeline">
					<!---
					Calendar / Volume plan when displaying Items: Order = Group_Desc, Item #
					Calendar / Volume plan when displaying groups: Order = Group Desc
					---->
					ORDER BY Group_Name,
						<cfif local.product_mode >
							Item
						<cfelse>
							Description
						</cfif>
			<cfelseif arguments.product_group_level_id eq 999>
				ORDER BY Description
			<cfelse>
				ORDER BY Item, Description
			</cfif>
		</cfquery>

		<cfreturn local.qProducts />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerProducts" hint="Save products based on a list of products.">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="products_list" required="true" hint="The list of products.">
		<cfargument name="product_group_level_id" required="true">
		<cfargument name="data" required="false" type="struct" default="#StructNew()#" />

		<cfscript>
			//set local variables
			var stData 					= arguments.data;
			var dToday					= DateFormat(Now(), "mm/dd/yyyy");
			var itemMasterField			= "bsa_FoodService_Items_Master_ID";
		</cfscript>

		<cfset bIsGroup = 0 />
		<cfif arguments.product_group_level_id neq "">
			<cfset gGetAttr = getProdAttrData(arguments.product_group_level_id) />
			<cfif gGetAttr.RecordCount>
				<cfset bIsGroup = 1 />
				<cfset itemMasterField = gGetAttr.Product_Group_Attribute_Master_ID_Field />
			</cfif>
		</cfif>

		<cfset tmp_planner_distributors( arguments.plannerID)>

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Tmp_Add_Planner_products') IS NOT NULL
				DROP TABLE ##Tmp_Add_Planner_products

			IF OBJECT_ID('tempdb..##Tmp_Add_VP_Prod_Dist') IS NOT NULL
				DROP TABLE ##Tmp_Add_VP_Prod_Dist

			IF OBJECT_ID('tempdb..##Tmp_Add_VP_Prod_Dist_Week') IS NOT NULL
				DROP TABLE ##Tmp_Add_VP_Prod_Dist_Week

		</cfquery>

		<cfset local.filterSegment = getSegmentFilter() />

		<cfquery name="local.insert" datasource="#application.datasource#">
			CREATE TABLE ##Tmp_Add_Planner_products (
				Product_ID uniqueidentifier,
				Forecast_Value decimal(20, 2),
				Forecast_UOM int,
				Forecast_Start_Date DATE
			)
		 /*  Loop over the form and populate the products/groups into temp table */
			<cfloop index="iIndx" list="#arguments.products_list#">
				<cfscript>
					local.postfix = "#Replace(iIndx, "-", "_", "ALL")#";

					param name="stData.Forecast_Val_#local.postfix#"    default="0";
					param name="stData.Forecast_UOM_#local.postfix#" 	default="1";
					param name="stData.Forecast_Start_Date_#local.postfix#"    default="#dToday#";

					var local.forecastValue = Val(stData[ "Forecast_Val_" & local.postfix ]);
					var local.forecastUOM = stData[ "Forecast_UOM_" & local.postfix ];
					var local.forecastDate = stData[ "Forecast_Start_Date_" & local.postfix ];

					local.forecastDate = (local.forecastDate eq "") ? dToday : local.forecastDate;
				</cfscript>
				INSERT INTO ##Tmp_Add_Planner_products (Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date)
				VALUES (
					'#iIndx#',
					'#local.forecastValue#',
					'#local.forecastUOM#',
					'#local.forecastDate#'
				)
			</cfloop>

		 /*  Get distinct list of products and distributors */
			SELECT 	p.*,
					Dist.BSA_Foodservice_Customers_ID,
				<cfif this.udf.is_planner_indirect_category( arguments.plannerID )>
					o.BSA_Operator_ID,
				<cfelse>
					0 as BSA_Operator_ID,
				</cfif>
					IM.BSA_FoodService_Items_Master_ID,
					CAST(0 as float) as Forecast_Value_Per_Record,
					CAST(IM.Net_Weight as float) as Net_Weight,
					CAST(Count(*) OVER (Partition By IM.#itemMasterField#) as float) as Rec_Count,
					Row_Number() OVER (Order By IM.BSA_FoodService_Items_Master_ID) as Rec_Index
			INTO	##Tmp_Add_VP_Prod_Dist
			FROM   ##Tmp_Add_Planner_products P
			INNER JOIN BSA_FoodService_Items_Master IM
				ON IM.#itemMasterField# = p.Product_ID
					AND IM.Item IS NOT NULL
					AND IM.Deleted = 0
					AND IM.Active_Code = 'A'
			INNER JOIN ##tmp_planner_distributors Dist on 1=1
			<cfif this.udf.is_planner_indirect_category( arguments.plannerID )>
			INNER JOIN ##tmp_planner_operators o ON 1 = 1
			</cfif>

		 /*  If record count is less than volume, ok to divide by record count */
			UPDATE	##Tmp_Add_VP_Prod_Dist
			SET		Forecast_Value_Per_Record = Round(Forecast_Value / Rec_Count, 4)
			WHERE	Rec_Count <= Forecast_Value

		 /*  If record count is more than volume, divide volume amoung top x records */
			UPDATE	##Tmp_Add_VP_Prod_Dist
			SET		Forecast_Value_Per_Record = 1
			WHERE	Rec_Count > Forecast_Value
			AND		Rec_Index <= Forecast_Value

		 /*  Get distinct list of products, distributors and weeks */
			SELECT DISTINCT
					Planner_Week_Id,
					p.BSA_Foodservice_Customers_ID,
					p.bsa_FoodService_Items_Master_Id,
					p.BSA_Operator_ID,
				<cfif local.filterSegment>
					ISNULL(Planner_Template.Business_Segment_ID, 0) as Business_Segment_ID,
				<cfelse>
					0 as Business_Segment_ID,
				</cfif>
					CASE
					WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Forecast_Value_Per_Record / p.Net_Weight
					ELSE p.Forecast_Value_Per_Record
					END AS Forecast_cs,
					CASE
					WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Forecast_Value_Per_Record
					ELSE p.Forecast_Value_Per_Record * p.Net_Weight
					END AS Forecast_lbs
			INTO	##Tmp_Add_VP_Prod_Dist_Week
			FROM   Planners
					INNER JOIN Planner_Template
						ON Planner_Template.Planner_Template_Id = Planners.Planner_Template_Id
							AND Planner_Template.Deleted = 0
					INNER JOIN Planner_Week
						ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
							AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
							AND Planner_Week.Deleted = 0
					INNER JOIN ##Tmp_Add_VP_Prod_Dist p
						ON 1 = 1
			WHERE  Planners.Planner_Id  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.plannerID#" >

		 /*  Insert */
			INSERT Planner_Volume_Plan (
					Planner_Week_ID,
					BSA_Foodservice_Customers_ID,
					BSA_Foodservice_Items_Master_ID,
					BSA_Operator_ID,
					Business_Segment_ID,
					Prior_Year_CS,
					Prior_Year_LBS,
					Forecast_CS,
					Forecast_LBS,
					Forecast_Lift_CS,
					Forecast_Lift_LBS,
					Actual_CS,
					Actual_LBS,
					Forecast_Percent_Prior_Year_CS,
					Forecast_Percent_Prior_Year_LBS,
					Actual_Percent_Forecast_CS,
					Actual_Percent_Forecast_LBS,
					Forecast_Updated )
			SELECT	Planner_Week_Id,
					BSA_Foodservice_Customers_ID,
					bsa_FoodService_Items_Master_Id,
					BSA_Operator_ID,
					Business_Segment_ID,
					'0.00' AS Prior_year_cs,
					'0.00' AS Prior_year_lbs,
					Forecast_cs,
					Forecast_lbs,
					Forecast_cs,
					Forecast_lbs,
					'0.00' AS Actual_cs,
					'0.00' AS Actual_lbs,
					'100'  AS Forecast_percent_prior_year_cs,
					'100'  AS Forecast_percent_prior_year_lbs,
					'0'    AS Actual_percent_forecast_cs,
					'0'    AS Actual_percent_forecast_lbs,
					1 AS Forecast_Updated
			FROM	##Tmp_Add_VP_Prod_Dist_Week t
			WHERE 	NOT EXISTS (
				SELECT  1
				FROM    Planner_Volume_Plan v
				WHERE   v.Planner_Week_ID = t.Planner_Week_ID
				AND     v.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID
				AND     v.BSA_Foodservice_Items_Master_ID = t.bsa_FoodService_Items_Master_ID
				AND     v.BSA_Operator_ID = t.BSA_Operator_ID
				AND     v.Business_Segment_ID = t.Business_Segment_ID
			)

			DELETE	Planner_Volume_Plan_Deleted_Records
			WHERE	EXISTS (
				SELECT  1
				FROM    ##Tmp_Add_VP_Prod_Dist_Week t
				WHERE   t.Planner_Week_ID = Planner_Volume_Plan_Deleted_Records.Planner_Week_ID
				AND     t.BSA_Foodservice_Customers_ID = Planner_Volume_Plan_Deleted_Records.BSA_Foodservice_Customers_ID
				AND     t.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan_Deleted_Records.bsa_FoodService_Items_Master_ID
			<cfif this.udf.is_planner_indirect_category( arguments.plannerID )>
				AND     t.BSA_Operator_ID = Planner_Volume_Plan_Deleted_Records.BSA_Operator_ID
			<cfelse>
				AND     Planner_Volume_Plan_Deleted_Records.BSA_Operator_ID = 0
			</cfif>
			<cfif local.filterSegment>
				AND     t.Business_Segment_ID = Planner_Volume_Plan_Deleted_Records.Business_Segment_ID
			</cfif>
			)
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="saveProgramVolume" hint="Save volume plan.">
		<cfargument name="volumes" required="true">

		<cfscript>
			local.delimiter = ".";
			local.pounds    = "2";

			constants.item       = "9";
			constants.type_code  = "12";
			constants.type_group = "8";
			constants.q_brand    = "11";
			constants.brand      = "13";
			constants.prod_var_a = "15";

			tmp_planner_distributors( arguments.volumes.plannerID );
			tmp_vol_filter_products(); // Created temp table ##tmp_vol_filter_products_from_cf
			local.Authorized_Distribution_List_Enabled = tmp_ADL_Excludes(form.plannerID);

			getPlanner = getPlanner( arguments.volumes.plannerID );
		</cfscript>

		<cfset local.filterSegment = getSegmentFilter() />
		<cfset local.plannerSegment = Val(getPlanner.Business_Segment_ID) />

		<cfquery datasource="#application.datasource#">
			DROP TABLE IF EXISTS ##Tmp_Planner_Week
		</cfquery>
		<cfquery name="local.planner_weeks" datasource="#application.datasource#">
			SELECT	Planner_Week.*
			INTO	##Tmp_Planner_Week
			FROM   Planners
			INNER JOIN Planner_Template
				ON Planner_Template.Planner_Template_Id = Planners.Planner_Template_Id
				AND Planner_Template.Deleted = 0
			INNER JOIN Planner_Week
				ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
				AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
			AND Planner_Week.Deleted = 0
			WHERE  Planners.Planner_Id  = #arguments.volumes.plannerID#  /*Do not use cfqueryparam*/
		</cfquery>

		<cfloop collection="#arguments.volumes#" item="local.input_name">
			<cfif listFirst(local.input_name, local.delimiter) eq 'i' and listLen(local.input_name, local.delimiter) eq 3>
				<cfscript>
					// input name components = i.<customer_guid>.<product_guid>.<planner_week_id>
					//                              #1 = 'i'
					//                              #2 = product id
					//                              #3 = week id
					//                              delimiter = '.'
					local.product_key  = listGetAt( local.input_name, 2, local.delimiter );
					local.week_id      = listGetAt( local.input_name, 3, local.delimiter );
					// remove all commas to avoid SQL error
					local.entry_value  = ( trim( arguments.volumes[ local.input_name ] ) eq "" ? 0 : replace( arguments.volumes[ local.input_name ], ",", "", "all" ) );
				</cfscript>

				<!--- no product group is involved --->
				<cfif arguments.volumes.product_list_type eq "">
					<!--- look for volume plan in the given week --->
					<cfquery name="local.distributor_product" datasource="#application.datasource#">
						SELECT  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
								,Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
								,Planner_Volume_Plan.BSA_Operator_ID
							<cfelse>
								,0 as BSA_Operator_ID
							</cfif>
								,SUM(ISNULL( Forecast_CS, 0))  AS Forecast_CS
								,SUM(ISNULL( Forecast_LBS, 0)) AS Forecast_LBS
								,BSA_Foodservice_Items_Master.Net_Weight
								,BSA_Foodservice_Items_Master.Active_Code
							FROM Planner_Volume_Plan
						 INNER JOIN BSA_Foodservice_Items_Master
								ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
						INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
								ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
						 WHERE Planner_Volume_Plan.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								 AND Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
						<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
							AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
						<cfelse>
							AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
						</cfif>
						<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
						</cfif>
						<!--- Include records with some kind of volume --->
						AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
						<cfif Authorized_Distribution_List_Enabled eq "1">
							AND NOT EXISTS (
								SELECT 	1
								FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
								WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								AND		ex.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
							)
						</cfif>
								 GROUP BY BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID,
								BSA_Foodservice_Items_Master.Net_Weight, BSA_Foodservice_Items_Master.Active_Code
								<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>, Planner_Volume_Plan.BSA_Operator_ID</cfif>
					</cfquery>

					<!--- volume plan for the specific week are not there, get from other weeks within the planner --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
									,Planner_Volume_Plan.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
								FROM Planner_Volume_Plan
							INNER JOIN BSA_Foodservice_Items_Master
									ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
							INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
								ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							INNER JOIN ##Tmp_Planner_Week Planner_Week
								ON Planner_Week.Planner_Week_ID = Planner_Volume_Plan.Planner_Week_ID
							WHERE Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
							<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
								AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
							<cfelse>
								AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
							</cfif>
							<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
							</cfif>
							<!--- Include records with some kind of volume --->
							AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
							<cfif Authorized_Distribution_List_Enabled eq "1">
								AND NOT EXISTS (
									SELECT 	1
									FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
									WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
									AND		ex.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								)
							</cfif>
						</cfquery>
					</cfif>

					<!--- volume plan for other weeks are not there,  --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
									,o.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
							FROM BSA_Foodservice_Items_Master
							INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers ON 1 = 1
							<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
							INNER JOIN ##tmp_planner_operators o ON 1 = 1
							</cfif>
							WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
							<cfif Authorized_Distribution_List_Enabled eq "1">
								AND NOT EXISTS (
									SELECT 	1
									FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
									WHERE 	ex.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
									AND		ex.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								)
							</cfif>
						</cfquery>
					</cfif>

				<cfelse>  <!--- arguments.volumes.product_list_type eq "" --->

					<!--- handle product group - locate existing products with the same group level with volume plan entry in given week --->
					<cfquery name="local.distributor_product" datasource="#application.datasource#">
						SELECT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
								,Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
								,Planner_Volume_Plan.BSA_Operator_ID
							<cfelse>
								,0 as BSA_Operator_ID
							</cfif>
								,SUM(ISNULL( Forecast_CS, 0))  AS Forecast_CS
								,SUM(ISNULL( Forecast_LBS, 0)) AS Forecast_LBS
								,BSA_Foodservice_Items_Master.Net_Weight
								,BSA_Foodservice_Items_Master.Active_Code
							FROM Planner_Volume_Plan
						 INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
								ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
						 INNER JOIN BSA_Foodservice_Items_Master
								ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
								<cfif arguments.volumes.product_list_type eq constants.type_code>
									AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_list_type eq constants.type_group>
									AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_list_type eq constants.q_brand>
									AND BSA_Foodservice_Items_Master.Q_Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_list_type eq constants.brand>
									AND BSA_Foodservice_Items_Master.Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_list_type eq constants.prod_var_a>
									AND BSA_Foodservice_Items_Master.Prod_Var_A_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								</cfif>
						 WHERE Planner_Volume_Plan.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
						<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
							AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
						<cfelse>
							AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
						</cfif>
						<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
						</cfif>
						<!--- Include records with some kind of volume --->
						AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
						<cfif Authorized_Distribution_List_Enabled eq "1">
							AND NOT EXISTS (
								SELECT 	1
								FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
								WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								AND		ex.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
								AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
							)
						</cfif>
								 GROUP BY BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID,
									BSA_Foodservice_Items_Master.Net_Weight, BSA_Foodservice_Items_Master.Active_Code
									<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>, Planner_Volume_Plan.BSA_Operator_ID</cfif>
						ORDER BY CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END /*  We want inactive items to come first */
					</cfquery>

					<!--- volume plan for the specific week are not there, get from other weeks within the planner --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
									,Planner_Volume_Plan.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
                                    ,CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END x
								FROM Planner_Volume_Plan
							 INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
									ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							 INNER JOIN BSA_Foodservice_Items_Master
									ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
									<cfif arguments.volumes.product_list_type eq constants.type_code>
										AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.type_group>
										AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.q_brand>
										AND BSA_Foodservice_Items_Master.Q_Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.brand>
										AND BSA_Foodservice_Items_Master.Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.prod_var_a>
										AND BSA_Foodservice_Items_Master.Prod_Var_A_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									</cfif>
							INNER JOIN ##Tmp_Planner_Week Planner_Week
								ON Planner_Week.Planner_Week_ID = Planner_Volume_Plan.Planner_Week_ID
							<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
								WHERE EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
							<cfelse>
								WHERE ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
							</cfif>
							<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
							</cfif>
							<!--- Include records with some kind of volume --->
							AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
							<cfif Authorized_Distribution_List_Enabled eq "1">
								AND NOT EXISTS (
									SELECT 	1
									FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
									WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
									AND		ex.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
									AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								)
							</cfif>
							ORDER BY CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END /*  We want inactive items to come first */
						</cfquery>
					</cfif>

					<!--- volume plan for other weeks are not there,  --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
									BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
									,o.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
                                    ,CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END x
							FROM BSA_Foodservice_Items_Master
							INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers ON 1 = 1
							<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
							INNER JOIN ##tmp_planner_operators o ON 1 = 1
							</cfif>
							WHERE 1 = 1
									<cfif arguments.volumes.product_list_type eq constants.type_code>
										AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.type_group>
										AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.q_brand>
										AND BSA_Foodservice_Items_Master.Q_Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.brand>
										AND BSA_Foodservice_Items_Master.Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.prod_var_a>
										AND BSA_Foodservice_Items_Master.Prod_Var_A_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									</cfif>
								<cfif Authorized_Distribution_List_Enabled eq "1">
									AND NOT EXISTS (
										SELECT 	1
										FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
										WHERE 	ex.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
										AND		ex.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
										AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
									)
								</cfif>
							ORDER BY CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END /*  We want inactive items to come first */
						</cfquery>
					</cfif>

				</cfif>  <!--- arguments.volumes.product_list_type eq "" --->

				<cfif local.distributor_product.recordCount>
					<!--- sum up the previous totals --->
					<cfquery name="local.previous" dbtype="query">
						<cfif arguments.volumes.volume_plan_uom neq local.pounds>
							SELECT SUM(Forecast_CS) AS TotalValue FROM [local].distributor_product
						<cfelse>
							SELECT SUM(Forecast_LBS) AS TotalValue FROM [local].distributor_product
						</cfif>
					</cfquery>

					<cfset local.applied_value = 0>
					<cfset local.delta_value   = local.entry_value - local.previous.TotalValue>

					<cfif local.delta_value neq 0>
						<!--- update all products within the group --->
						<cfloop query="local.distributor_product">
							<cfscript>
								local.original_value = ( arguments.volumes.volume_plan_uom neq local.pounds ? local.distributor_product.Forecast_CS : local.distributor_product.Forecast_LBS );

								if ( local.entry_value eq 0 ) {
									// zero it out
									local.new_value = 0;
								}
								else if ( local.previous.TotalValue eq 0 ) {
									// split the delta value evenly based on number of products
									local.new_value = max( local.original_value + ( local.delta_value / local.distributor_product.recordCount ), 0 );
								}
								else {
									// split the delta value based on original value & original total
									local.new_value = max( local.original_value + ( local.delta_value / local.previous.TotalValue * local.original_value ), 0 );
								}

								if(local.distributor_product.active_code != 'A'){
									// when product is inactive set volume to 0
									local.new_value = 0;

								}

								// last row, just use the remaining amount and ignore the calculated value to avoid rounding problems
								if ( local.distributor_product.currentRow eq local.distributor_product.recordCount ) {
									 local.new_value = max( local.original_value + ( local.delta_value - local.applied_value ), 0 );
								}
								if(arguments.volumes.volume_plan_uom neq local.pounds) { //CS
									local.volume_cs = local.new_value;
									local.volume_lb = local.new_value * local.distributor_product.Net_Weight;
								}
								else { //LB
									local.volume_cs = local.new_value / local.distributor_product.Net_Weight;
									local.volume_lb = local.new_value;
								}
							</cfscript>

							<cfquery name="local.update" datasource="#application.datasource#" result="local.result">
								UPDATE Planner_Volume_Plan
										SET Forecast_CS = #local.volume_cs#
											,Forecast_Lift_CS = #local.volume_cs# - ISNULL(Forecast_Base_CS, 0)
											,Forecast_LBS = #local.volume_lb#
											,Forecast_Lift_LBS = #local.volume_lb# - ISNULL(Forecast_Base_LBS, 0)
											,Forecast_updated = 1
									/* wip and rfa - update locked forecast column */
									<cfif getPlanner.Status_ID lt 3>
											,Locked_CS = #local.volume_cs#
											,Locked_LBS = #local.volume_lb#
									</cfif>
								 WHERE Planner_Volume_Plan.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
										 AND Planner_Volume_Plan.BSA_Foodservice_Customers_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Customers_ID#">
										 AND Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">
										<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
											AND Planner_Volume_Plan.BSA_Operator_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.distributor_product.BSA_Operator_ID#">
										<cfelse>
											AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
										</cfif>
										<cfif local.filterSegment>
											AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
										</cfif>
							</cfquery>

							<cfif local.result.recordCount eq 0 and local.new_value neq 0>
								<cfquery name="local.insert" datasource="#application.datasource#">
									INSERT Planner_Volume_Plan ( Forecast_CS, Forecast_Lift_CS,
																 Forecast_LBS, Forecast_Lift_LBS,
																 /* wip and rfa - update locked forecast column */
																 <cfif getPlanner.Status_ID lt 3>
																		Locked_CS,
																		Locked_LBS,
																 </cfif>
																 Planner_Week_ID,
																 BSA_Foodservice_Customers_ID,
																 BSA_Foodservice_Items_Master_ID,
																 BSA_Operator_ID,
																 Business_Segment_ID,
																 Prior_Year_CS,
																 Prior_Year_LBS,
																 Forecast_Percent_Prior_Year_CS,
																 Forecast_Percent_Prior_Year_LBS,
																 Forecast_Updated   )
														VALUES ( #local.volume_cs#, #local.volume_cs#,
																 #local.volume_lb#, #local.volume_lb#,
																 /* wip and rfa - update locked forecast column */
																 <cfif getPlanner.Status_ID lt 3>
																	#local.volume_cs#,
																	#local.volume_lb#,
																 </cfif>
																 <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">,
																 <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Customers_ID#">,
																 <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">,
															<cfif this.udf.is_planner_indirect_category( arguments.volumes.plannerID )>
																<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.distributor_product.BSA_Operator_ID#">,
															<cfelse>
																0,
															</cfif>
															<cfif local.filterSegment>
																<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">,
															<cfelse>
																0,
															</cfif>
																 0,
																 0,
																 100,
																 100,
																 1 )
								</cfquery>
							</cfif>

							<cfquery name="local.insert" datasource="#application.datasource#">
								INSERT INTO ##tmp_vol_filter_products_from_cf (Product_ID)
								VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">)
							</cfquery>

							<!--- keep track of applied values total --->
							<cfset local.applied_value = local.applied_value + ( local.new_value - local.original_value )>

						</cfloop>  <!--- query="local.distributor_product" --->
					</cfif>     <!--- local.delta_value neq 0 --->
				</cfif>     <!--- local.distributor_product.recordCount --->
			</cfif>  <!--- listFirst(local.input_name, local.delimiter) eq 'i' and listLen(local.input_name, local.delimiter) eq 3> --->
		</cfloop>

		<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "0" null="yes" />
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@New_Product_ID" value = "" null="yes" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Planner_ID" value = "#arguments.volumes.plannerID#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Filter_On_Product" value = "1" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Include_New_Product_Members_Only" value = "0" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Volume_Plan_Updated" value = "1" null="no" />
		</cfstoredproc>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getProgramVolume" hint="Returns volume plan based on a given program ID.">

		<cfargument name="programID" type="numeric" required="true">
		<cfargument name="product_list" required="true">
		<cfargument name="product_list_type" required="true">
		<cfargument name="forecasts" required="false" default='Prior_Yr,local.forecast,Actual,Locked_Forecast,Forecast_Percent_PY,Actual_Percent_Forecast'>

		<cfquery name="local.qProgram" datasource="#application.datasource#">
			SELECT Contract_number, Contract_Title, ISNULL(Planner_ID, 0) AS Planner_ID
			  FROM Contract_Main
			  WHERE Contract_Main_ID = <cfqueryparam value="#arguments.programID#">
		</cfquery>

		<cfscript>
			local.plannerManager = createObject( "component", "mvc.Models.Planner.PlannerManager" );
			local.qPeriods       = local.plannerManager.getPlannerWeeks( 0, arguments.programID );

			constants.item       = "9";
			constants.type_code  = "12";
			constants.type_group = "8";
			constants.q_brand    = "11";
			constants.brand      = "13";
			constants.prod_var_a = "15";

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
			constants.YTD                 = "YTD";

			tmp_planner_distributors( local.qProgram.Planner_ID );
			local.Authorized_Distribution_List_Enabled = tmp_ADL_Excludes(local.qProgram.Planner_ID);

			local.product_group_level_id_aux = 0;
			local.group_desc_field_aux = "";

			// If product, then order results based on group description so that products that belong to same group are together
			if(arguments.product_list_type == 0 || arguments.product_list_type == 9 || arguments.product_list_type == ""){
				local.product_group_level_id_aux = application.appSettingsGet.get_Setting('Retail_Margin_Sub_Total_Group');
				if(local.product_group_level_id_aux == '')
					local.product_group_level_id_aux = 11;
			}
		</cfscript>

		<cfset local.filterSegment = getSegmentFilter() />

		<cfquery name="local.qProductGroup" datasource="#application.datasource#">
			<cfif (arguments.product_list_type eq 0 or arguments.product_list_type eq 9 or arguments.product_list_type eq "")>
                select	 'BSA_Foodservice_Items_Master_ID' AS Product_Group_Attribute_Master_ID_Field,
                            'BSA_Foodservice_Items_Master' AS Product_Group_Attribute_Table,
                            'BSA_Foodservice_Items_Master_ID' AS Product_Group_Attribute_ID_Field,
                            'Description' AS Product_Group_Attribute_Name_Field,
                            'Item' AS Product_Group_Attribute_Number_Field
            <cfelse>
                select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
                            a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
                            a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
                            a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
                            a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
                from	Product_Group_Attribute a
                where	Product_Group_Level_ID = #arguments.product_list_type#
            </cfif>
		</cfquery>

		<cfif Authorized_Distribution_List_Enabled eq "1">
			<cfquery name="local.qdrop" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##Tmp_ADL_Exclude_Item_Key') IS NOT NULL
				DROP TABLE ##Tmp_ADL_Exclude_Item_Key
				IF OBJECT_ID('tempdb..##Tmp_ADL_Excluded_Item_Key_List') IS NOT NULL
				DROP TABLE ##Tmp_ADL_Excluded_Item_Key_List
			</cfquery>

			<cfquery name="local.qADLExcludes" datasource="#application.datasource#">
				SELECT	DISTINCT i.#local.qProductGroup.Product_Group_Attribute_ID_Field# as Item_Key, ex.Planner_Week_ID
				INTO	##Tmp_ADL_Exclude_Item_Key
				FROM	##Tmp_ADL_Exclude_Products ex
				INNER JOIN BSA_Foodservice_Items_Master i
				ON		i.BSA_Foodservice_Items_Master_ID = ex.BSA_Foodservice_Items_Master_ID

				<!--- Find groups where all products are excluded
				Table Authorized_Distribution_List_Exclude
				If no entry exists in this table - ADL_Excluded = 0 (eg: 0,0=>ADL_Excluded=0)
				If some entry exists in this table - ADL_Excluded = 0 (eg: 0,1=>ADL_Excluded=0)
				If all entries exists in this table - ADL_Excluded = 1 (eg: 1,1=>ADL_Excluded=1)
				--->
				SELECT	tmp.Item_Key, tmp.Planner_Week_ID as Planner_Week_ID, CAST(1 as int) as ADL_Exlude
				INTO	##Tmp_ADL_Excluded_Item_Key_List
				FROM	##Tmp_ADL_Exclude_Item_Key tmp
				INNER JOIN BSA_Foodservice_Items_Master i
				ON		i.#local.qProductGroup.Product_Group_Attribute_ID_Field# = tmp.Item_Key
				AND		i.Deleted = 0
				AND		i.Active_Code = 'A'
				LEFT JOIN ##Tmp_ADL_Exclude_Products ex
				ON		ex.BSA_Foodservice_Items_Master_ID = i. BSA_Foodservice_Items_Master_ID
				ANd		ex.Planner_Week_ID = tmp.Planner_Week_ID
				GROUP BY tmp.Item_Key, tmp.Planner_Week_ID
				Having Min(CASE WHEN ex.BSA_Foodservice_Items_Master_ID IS NULL THEN 0 ELSE 1 END) = 1
			</cfquery>

		</cfif>

		<cfscript>
			local.columns = [];

			for ( local.forecast in arguments.forecasts ) {
				if ( local.forecast is constants.actual ) {
					local.columns.append ( "Actual" );
				}
				else if ( local.forecast is constants.actual_percent_forecast ) {
					local.columns.append ( "Actual" ).append( "Forecast" );
				}
				else if ( local.forecast is constants.aop ) {
					local.columns.append ( "AOP" );
				}
				else if ( local.forecast is constants.demand_plan ) {
					local.columns.append ( "Demand_Plan" );
				}
				else if ( local.forecast is constants.forecast_percent_prior_year ) {
					local.columns.append ( "Prior_Year" ).append( "Forecast" );
				}
				else if ( local.forecast is constants.indirect_percent ) {
					local.columns.append ( "Indirect" ).append( "Forecast" );
				}
				else if ( local.forecast is constants.indirect_volume ) {
					local.columns.append ( "Indirect" );
				}
				else if ( local.forecast is constants.latest_forecast ) {
					local.columns.append ( "Forecast" ).append ( "Forecast_Lift" ).append ( "Forecast_Base" );
				}
				else if ( local.forecast is constants.locked_forecast ) {
					local.columns.append ( "Locked" );
				}
				else if ( local.forecast is constants.prior_year ) {
					local.columns.append ( "Prior_Year" );
				}
				else if ( local.forecast is constants.YTD ) {
					local.columns.append ( "YTD" );
				}
			}

			local.columns_list = listRemoveDuplicates( local.columns.toList(), ',', true );
			local.columns      = local.columns_list.listToArray();
		</cfscript>
		<cfset DateToCompare = dateFormat(now(), 'mm/dd/yyyy')>

		<cfquery name="local.qVolumes" datasource="#application.datasource#">
			SELECT
					<cfif arguments.product_list_type eq constants.type_code>
						Type_Code_Desc.Type_Code_Desc_ID AS Item_Key, Type_Code_Desc.Type_Code_Desc AS Description
						,Type_Code_Desc.Type_Code_Legacy AS Group_ID
					<cfelseif arguments.product_list_type eq constants.type_group>
						Type_Group_Desc.Type_Group_Desc_ID AS Item_Key, Type_Group_Desc.Type_Group_Desc AS Description
						,Type_Group_Desc.Type_Group_Legacy AS Group_ID
					<cfelseif arguments.product_list_type eq constants.q_brand>
						Q_Brand_Desc.Q_Brand_ID AS Item_Key, Q_Brand_Desc.Q_Brand AS Description
						,Q_Brand_Desc.Q_Brand_Legacy AS Group_ID
					<cfelseif arguments.product_list_type eq constants.brand>
						Brand.Brand_ID AS Item_Key, Brand.Brand_Name AS Description
						,Brand.Brand AS Group_ID
					<cfelseif arguments.product_list_type eq constants.prod_var_a>
						Prod_Var_A.Prod_Var_A_ID AS Item_Key, Prod_Var_A.Prod_Var_A_Desc AS Description
						,Prod_Var_A.Prod_Var_A AS Group_ID
					<cfelse>
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AS Item_Key, BSA_Foodservice_Items_Master.Description
						,BSA_Foodservice_Items_Master.Item AS Group_ID
					</cfif>

					/* combine multiple rows with the same product master id into one row by creating virtual local.columns based on planner_week_id */
					<cfloop query="local.qPeriods">
						<cfloop array="#local.columns#" item="column">
							<cfif column EQ 'YTD'>
								,SUM(
									CASE WHEN  Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN
												CASE WHEN Planner_Volume_Plan.Planner_Week_ID = #local.qPeriods.Period_ID#
															THEN ISNULL( CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Inventory_UM IN ( 'LB', 'LBS' ) AND volume_plan_uom = 2
																																THEN CAST( Planner_Volume_Plan.Actual_CS * Net_Weight as decimal( 18,2 ) )
																																ELSE Planner_Volume_Plan.Actual_CS
																													END, 0 )
															ELSE 0
												END
									ELSE
												CASE WHEN Planner_Volume_Plan.Planner_Week_ID = #local.qPeriods.Period_ID#
															THEN ISNULL( CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Inventory_UM IN ( 'LB', 'LBS' ) AND volume_plan_uom = 2
																																THEN CAST( Planner_Volume_Plan.Forecast_CS * Net_Weight as decimal( 18,2 ) )
																																ELSE Planner_Volume_Plan.Forecast_CS
																													END, 0 )
															ELSE 0
												END
									END
									) AS #column#_CS_#local.qPeriods.Period_ID#

							,SUM(
													CASE WHEN  Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN
																CASE WHEN Planner_Volume_Plan.Planner_Week_ID = #local.qPeriods.Period_ID#
																			THEN ISNULL( CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Inventory_UM IN ( 'LB', 'LBS' ) AND volume_plan_uom = 2
																																				THEN CAST( Planner_Volume_Plan.Actual_LBS * Net_Weight as decimal( 18,2 ) )
																																				ELSE Planner_Volume_Plan.Actual_LBS
																																	END, 0 )
																			ELSE 0
																END
													ELSE
																CASE WHEN Planner_Volume_Plan.Planner_Week_ID = #local.qPeriods.Period_ID#
																			THEN ISNULL( CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Inventory_UM IN ( 'LB', 'LBS' ) AND volume_plan_uom = 2
																																				THEN CAST( Planner_Volume_Plan.Forecast_LBS * Net_Weight as decimal( 18,2 ) )
																																				ELSE Planner_Volume_Plan.Forecast_LBS
																																	END, 0 )
																			ELSE 0
																END
													END
											) AS #column#_LBS_#local.qPeriods.Period_ID#
								<cfelse>
						,SUM( CASE WHEN Planner_Volume_Plan.Planner_Week_ID = #local.qPeriods.Period_ID#
									THEN ISNULL( CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Inventory_UM IN ( 'LB', 'LBS' ) AND volume_plan_uom = 2
														THEN CAST( Planner_Volume_Plan.#column#_CS * Net_Weight as decimal( 18,2 ) )
														ELSE Planner_Volume_Plan.#column#_CS
													END, 0 )
									ELSE 0
								END ) AS #column#_CS_#local.qPeriods.Period_ID#
						,SUM( CASE WHEN Planner_Volume_Plan.Planner_Week_ID = #local.qPeriods.Period_ID#
								THEN ISNULL( CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Inventory_UM = 'CS' AND volume_plan_uom = 1
												THEN CAST( Planner_Volume_Plan.#column#_LBS / Net_Weight as decimal( 18,2 ) )
												ELSE Planner_Volume_Plan.#column#_LBS
												END, 0 )
								ELSE 0
								END) AS #column#_LBS_#local.qPeriods.Period_ID#
								</cfif>
						</cfloop>
						<cfif Authorized_Distribution_List_Enabled eq "1">
							,SUM(CASE WHEN Planner_Week.Planner_Week_ID = #local.qPeriods.Period_ID# THEN ISNULL(ex.ADL_Exlude, 0) ELSE 0 END) AS ADL_Exclude_#local.qPeriods.Period_ID#
						<cfelse>
							,0 AS ADL_Exclude_#local.qPeriods.Period_ID#
						</cfif>
					</cfloop>
			FROM    Planners
			INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
						ON 1=1
			INNER JOIN Planner_Template
					ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
						 AND Planner_Template.Deleted = 0
			INNER JOIN Planner_Week
					ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
						 AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
						 AND Planner_Week.Deleted = 0

			<cfif arguments.product_list_type eq constants.type_code>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID IN ( <cfqueryparam value="#arguments.product_list#" list="true"> )
				INNER JOIN Type_Code_Desc ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			<cfelseif arguments.product_list_type eq constants.type_group>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.Type_Group_Desc_ID IN ( <cfqueryparam value="#arguments.product_list#" list="true"> )
				INNER JOIN Type_Group_Desc ON Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
			<cfelseif arguments.product_list_type eq constants.q_brand>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.Q_Brand_ID IN ( <cfqueryparam value="#arguments.product_list#" list="true"> )
				INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID
			<cfelseif arguments.product_list_type eq constants.brand>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.Brand_ID IN ( <cfqueryparam value="#arguments.product_list#" list="true"> )
				INNER JOIN Brand ON Brand.Brand_ID = BSA_Foodservice_Items_Master.Brand_ID
			<cfelseif arguments.product_list_type eq constants.prod_var_a>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.Prod_Var_A_ID IN ( <cfqueryparam value="#arguments.product_list#" list="true"> )
				INNER JOIN Prod_Var_A ON Prod_Var_A.Prod_Var_A_ID = BSA_Foodservice_Items_Master.Prod_Var_A_ID
			<cfelse>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN ( <cfqueryparam value="#arguments.product_list#" list="true"> )
			</cfif>

			<cfif local.product_group_level_id_aux eq constants.type_code>
				INNER JOIN Type_Code_Desc ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			<cfelseif local.product_group_level_id_aux eq constants.type_group>
				INNER JOIN Type_Group_Desc ON Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
			<cfelseif local.product_group_level_id_aux eq constants.q_brand>
				INNER JOIN Q_Brand_Desc ON Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID
			<cfelseif local.product_group_level_id_aux eq constants.brand>
				INNER JOIN Brand ON Brand.Brand_ID = BSA_Foodservice_Items_Master.Brand_ID
			<cfelseif local.product_group_level_id_aux eq constants.prod_var_a>
				INNER JOIN Prod_Var_A ON Prod_Var_A.Prod_Var_A_ID = BSA_Foodservice_Items_Master.Prod_Var_A_ID
			</cfif>

			LEFT JOIN Planner_Volume_Plan
					ON Planner_Volume_Plan.Planner_Week_ID = Planner_Week.Planner_Week_ID
						 AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
						 AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
					<cfif this.udf.is_planner_indirect_category( local.qProgram.planner_ID )>
						AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
					<cfelse>
						AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
					</cfif>
					<cfif local.filterSegment>
						AND Planner_Volume_Plan.Business_Segment_ID = Planner_Template.Business_Segment_ID
					</cfif>
			<cfif Authorized_Distribution_List_Enabled eq "1">
			LEFT JOIN ##Tmp_ADL_Excluded_Item_Key_List ex
				ON	ex.Item_Key = BSA_Foodservice_Items_Master.#local.qProductGroup.Product_Group_Attribute_ID_Field#
				AND	ex.Planner_Week_ID = Planner_Week.Planner_Week_ID
			</cfif>
			WHERE   Planners.Planner_ID = ( SELECT Planner_ID FROM Contract_Main WHERE Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#"> )
				GROUP BY Planners.Customer_ID
						<cfif arguments.product_list_type eq constants.type_code>
							,Type_Code_Desc.Type_Code_Desc_ID, Type_Code_Desc.Type_Code_Desc
							,Type_Code_Desc.Type_Code_Legacy

							<cfset local.group_desc_field_aux = "Type_Code_Desc.Type_Code_Desc" />

						<cfelseif arguments.product_list_type eq constants.type_group>
							,Type_Group_Desc.Type_Group_Desc_ID, Type_Group_Desc.Type_Group_Desc
							,Type_Group_Desc.Type_Group_Legacy

							<cfset local.group_desc_field_aux = "Type_Group_Desc.Type_Group_Desc" />

						<cfelseif arguments.product_list_type eq constants.q_brand>
							,Q_Brand_Desc.Q_Brand_ID, Q_Brand_Desc.Q_Brand
							,Q_Brand_Desc.Q_Brand_Legacy

							<cfset local.group_desc_field_aux = "Q_Brand_Desc.Q_Brand" />

						<cfelseif arguments.product_list_type eq constants.brand>
							,Brand.Brand_ID, Brand.Brand_Name
							,Brand.Brand

							<cfset local.group_desc_field_aux = "Brand.Brand_Name" />

						<cfelseif arguments.product_list_type eq constants.prod_var_a>
							,Prod_Var_A.Prod_Var_A_ID, Prod_Var_A.Prod_Var_A_Desc
							,Prod_Var_A.Prod_Var_A

							<cfset local.group_desc_field_aux = "Prod_Var_A.Prod_Var_A_Desc" />
						<cfelse>
							,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Description
							,BSA_Foodservice_Items_Master.Item
						</cfif>
		</cfquery>

		<cfreturn local.qVolumes>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="tmp_planner_distributors" hint="Create a temp table with all distributors in a planner.">
		<cfargument name="plannerID" required="true" type="numeric">

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_planner_distributors') IS NOT NULL
				DROP TABLE ##tmp_planner_distributors
			IF OBJECT_ID('tempdb..##tmp_planner_operators') IS NOT NULL
				DROP TABLE ##tmp_planner_operators
		</cfquery>

		<cfif this.udf.is_planner_indirect_category( arguments.plannerID )>
			<cfquery name="local.create" datasource="#application.datasource#">
				CREATE TABLE ##tmp_planner_distributors ( BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER )
				INSERT  INTO ##tmp_planner_distributors (BSA_Foodservice_Customers_ID) VALUES ('00000000-0000-0000-0000-000000000000')

				SELECT	DISTINCT BSA_Operator_ID
				INTO	##tmp_planner_operators
				FROM    Planner_Operators p
				WHERE   Planner_ID = #arguments.plannerID# 	 /*  Do not use cfqueryparam as we are using this temp table in other query. */
			</cfquery>
		<cfelse>
			<cfquery name="local.create" datasource="#application.datasource#">
				CREATE TABLE ##tmp_planner_distributors ( BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER )

			 /*  If planner has individual distributor */
				INSERT  INTO ##tmp_planner_distributors
						( BSA_Foodservice_Customers_ID )
						SELECT	DISTINCT
								Customer_ID
						FROM    Planners p
						WHERE   Planner_ID = #arguments.plannerID# 	 /*  Do not use cfqueryparam as we are using this temp table in other query. */
								AND IsNull(Distributor_Group_Level_ID, 0) = 0

			 /*  If planner has group distributor */
				INSERT  INTO ##tmp_planner_distributors
						( BSA_Foodservice_Customers_ID )
						SELECT	DISTINCT
								Distributor_ID
						FROM    Planner_Customer_Group_Members p
						WHERE   Planner_ID = #arguments.plannerID# 	 /*  Do not use cfqueryparam as we are using this temp table in other query. */

				CREATE TABLE ##tmp_planner_operators ( BSA_Operator_ID int )
				INSERT INTO ##tmp_planner_operators (BSA_Operator_ID) VALUES (0)
			</cfquery>
		</cfif>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="tmp_ADL_Excludes" hint="Create a temp table with all excludes for distributors in a planner.">
		<cfargument name="plannerID" required="true" type="numeric">

		<cfset Authorized_Distribution_List_Enabled = application.oApplicationAppSettingsManager.getApplicationAppSettings().get_Setting('Authorized_Distribution_List_Enabled') />

		<cfquery name="local.dropCreate" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Tmp_ADL_Exclude_Dist_Prod') IS NOT NULL
			DROP TABLE ##Tmp_ADL_Exclude_Dist_Prod

			CREATE TABLE ##Tmp_ADL_Exclude_Dist_Prod (BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER, BSA_Foodservice_Items_Master_ID UNIQUEIDENTIFIER, Planner_Week_ID int)

			IF OBJECT_ID('tempdb..##Tmp_ADL_Exclude_Products') IS NOT NULL
			DROP TABLE ##Tmp_ADL_Exclude_Products

			CREATE TABLE ##Tmp_ADL_Exclude_Products (BSA_Foodservice_Items_Master_ID UNIQUEIDENTIFIER, Planner_Week_ID int)
		</cfquery>

		<cfif Authorized_Distribution_List_Enabled eq "1">
			<cfquery name="local.populate" datasource="#application.datasource#">
				DECLARE @Distributor_Group_Level_ID int,
						@Customer_ID uniqueidentifier
				SELECT	@Distributor_Group_Level_ID = p.Distributor_Group_Level_ID,
						@Customer_ID = Customer_ID
				FROM	Planners p
				WHERE   p.Planner_ID = #arguments.plannerID# 	 /*  Do not use cfqueryparam as we are using this temp table in other query. */

				INSERT INTO ##Tmp_ADL_Exclude_Dist_Prod (BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master_ID, Planner_Week_ID)
				SELECT	ex.BSA_Foodservice_Customers_ID, ex.BSA_Foodservice_Items_Master_ID, Planner_Week_ID
				FROM	Authorized_Distribution_List_Exclude ex
				WHERE	ex.Distributor_Group_ID = @Customer_ID
				AND		ex.Distributor_Group_Level_ID = @Distributor_Group_Level_ID
				UNION
				SELECT	ex.BSA_Foodservice_Customers_ID, ex.BSA_Foodservice_Items_Master_ID, Planner_Week_ID
				FROM	Authorized_Distribution_List_Exclude ex
				WHERE	EXISTS (SELECT 1 FROM ##tmp_planner_distributors d WHERE d.BSA_Foodservice_Customers_ID = ex.BSA_Foodservice_Customers_ID)

				INSERT INTO ##Tmp_ADL_Exclude_Products (BSA_Foodservice_Items_Master_ID, Planner_Week_ID)
				SELECT	DISTINCT ex.BSA_Foodservice_Items_Master_ID, Planner_Week_ID
				FROM	##Tmp_ADL_Exclude_Dist_Prod ex
			</cfquery>
		</cfif>

		<cfreturn Authorized_Distribution_List_Enabled />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerCategory" returnType="string">
		<cfargument name="plannerID" required="true" type="numeric">

		<cfif not isDefined("request.planner_category")>
			<cfset request.planner_category = getPlannerLite(arguments.plannerID).Category />
		</cfif>

		<cfreturn request.planner_category />
	</cffunction>


	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="tmp_vol_filter_products" hint="Create a temp table which will hold all products updated from volume plan.">

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_vol_filter_products_from_cf') IS NOT NULL
				DROP TABLE ##tmp_vol_filter_products_from_cf
		</cfquery>

		<cfquery name="local.create" datasource="#application.datasource#">
			CREATE TABLE ##tmp_vol_filter_products_from_cf (Product_ID UNIQUEIDENTIFIER)
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="tmp_planner_template_filter_products" hint="Create a temp table which will get thelist of products based on planner template filter." returnType="boolean">
		<cfargument name="plannerID" required="true" type="numeric">

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_planner_template_filter_products') IS NOT NULL
				DROP TABLE ##tmp_planner_template_filter_products
		</cfquery>

		<cfquery name="local.create" datasource="#application.datasource#">
			DECLARE @Planner_ID int,
					@Planner_Template_ID int,
					@Planner_Template_Filter bit = 0,
					@Product_Group_Level_ID varchar(10),
					@Product_Group_Attribute_Master_ID_Field VARCHAR(100),
					@sSql1 VARCHAR(4000)

			set @Planner_ID = #arguments.plannerID#

			select	@Planner_Template_ID = Planner_Template_ID
			from	Planners p
			where	p.Planner_ID = @Planner_ID


			CREATE TABLE ##tmp_planner_template_filter_products (
					Product_ID uniqueidentifier NOT NULL
			)

			<!--- Find if there is a planner template filter --->
			select	TOP 1 @Planner_Template_Filter = 1
			from	Planner_Template_Filters ptf
			where	ptf.Planner_Template_ID = @Planner_Template_ID
			and		ptf.Allow_Filter = 1
			and		ptf.PG_Group_Type = 1

			IF @Planner_Template_Filter = 1
			BEGIN

					<!--- SP will insert into temp table ##tmp_planner_template_filter_products --->
					<!--- Earlier we used INSERT INTO ##tmp_planner_template_filter_products EXEC Planner_Template_Products, but it gave error "an insert exec statement cannot be nested" --->
					EXEC Planner_Template_Products @Planner_Template_ID, '##tmp_planner_template_filter_products'

			END


			SELECT @Planner_Template_Filter as Planner_Template_Filter
		</cfquery>

		<cfreturn local.create.Planner_Template_Filter />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerVolume" access="remote" returnformat="json" hint="Returns volume plan based on a given planner ID.">

		<cfinclude template="/planners/create/planner_volume_constants.cfm">
		<cfset DateToCompare = dateFormat(now(), 'mm/dd/yyyy')>

		<cfscript>
			local.qPeriods = ( form.period eq constants.by_week ? getPlannerWeeks( form.plannerId ) : getPlannerMonths( form.plannerId ) );
			local.all_rows = [];

			local.numberFormat = ",";
			variables.readonly = ( form.mode neq constants.edit
									or form.product_group_level_id neq request.defaultProductFilterAttr.Product_Group_Level_ID
									or form.period neq constants.by_week );

			tmp_planner_distributors( form.plannerID );
			local.Authorized_Distribution_List_Enabled = tmp_ADL_Excludes(form.plannerID);
			local.planner_template_product_filter = tmp_planner_template_filter_products(form.plannerID);

			local.product_group_level_id_aux = 0;
			local.group_desc_field_aux = "";

			// If product, then order results based on group description so that products that belong to same group are together
			if(arguments.product_group_level_id == 0 || arguments.product_group_level_id == 9 || arguments.product_group_level_id == ""){
				local.product_group_level_id_aux = application.appSettingsGet.get_Setting('Retail_Margin_Sub_Total_Group');
				if(local.product_group_level_id_aux == '')
					local.product_group_level_id_aux = 11;
					/* get the group description cols for sorting products */
					if (local.product_group_level_id_aux == constants.type_code)
						local.group_desc_field_aux = "Type_Code_Desc.Type_Code_Desc";
					else if (local.product_group_level_id_aux == constants.type_group)
						local.group_desc_field_aux = "Type_Group_Desc.Type_Group_Desc";
					else if (local.product_group_level_id_aux == constants.q_brand)
						local.group_desc_field_aux = "Q_Brand_Desc.Q_Brand";
					else if (local.product_group_level_id_aux == constants.brand)
						local.group_desc_field_aux = "Brand.Brand_Name";
					else if ( local.product_group_level_id_aux == constants.prod_var_a)
						local.group_desc_field_aux = "Prod_Var_A.Prod_Var_A_Desc";
			}
			local.Product_Group_Attribute_Master_ID_Field = tmp_color_for_volume_plan( form.plannerID , arguments.product_group_level_id , form.period );
		</cfscript>

		<cfset local.qGetPlanner = getPlanner />
		<cfset local.filterSegment = getSegmentFilter() />
		<cfset local.plannerSegment = Val(getPlanner.Business_Segment_ID) />
		<!---------------------------------->
		<!--- show total rows is enabled --->
		<!--- ------------------------------------------------------------------------------------------------------------------ --->
		<cfif form.totals neq "">

			<cfif form.filter_product_group_level_id neq ''>
				<cfquery name="local.qFilter" datasource="#application.datasource#">
						select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
								a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
								a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
								a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
								a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
						from	Product_Group_Attribute a
						where   Product_Group_Level_ID = #form.filter_product_group_level_id#
				</cfquery>
			</cfif>

			<cfquery name="local.qTotals" datasource="#application.datasource#">
				SELECT
						<cfif form.period eq constants.by_week>
							Planner_Week.Planner_Week_Start_Date
						<cfelse>
							Planner_Week.Display_Year as Planner_Year
							,Planner_Week.Display_Month as Planner_Month
						</cfif>
						,SUM(ISNULL(Planner_Volume_Plan.Actual_CS, 0))         AS Actual_CS
						,SUM(ISNULL(Planner_Volume_Plan.Actual_LBS, 0))        AS Actual_LBS
						,SUM(ISNULL(Planner_Volume_Plan.AOP_CS, 0))            AS AOP_CS
						,SUM(ISNULL(Planner_Volume_Plan.AOP_LBS, 0))           AS AOP_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Demand_Plan_CS, 0))    AS Demand_Plan_CS
						,SUM(ISNULL(Planner_Volume_Plan.Demand_Plan_LBS, 0))   AS Demand_Plan_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Base_CS, 0))  AS Forecast_Base_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Base_LBS, 0)) AS Forecast_Base_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_CS, 0))       AS Forecast_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_LBS, 0))      AS Forecast_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Lift_CS, 0))  AS Forecast_Lift_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Lift_LBS, 0)) AS Forecast_Lift_LBS
						<cfif local.qGetPlanner.Approved>
						,SUM(ISNULL(Planner_Locked_Volume_Plan.Locked_CS, 0)) AS Locked_Forecast_CS
						,SUM(ISNULL(Planner_Locked_Volume_Plan.Locked_LBS, 0)) AS Locked_Forecast_LBS
						<cfelse>
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_CS, 0)) AS Locked_Forecast_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_LBS, 0)) AS Locked_Forecast_LBS
						</cfif>
						,SUM(ISNULL(Planner_Volume_Plan.Prior_Year_CS, 0))     AS Prior_Year_CS
						,SUM(ISNULL(Planner_Volume_Plan.Prior_Year_LBS, 0))    AS Prior_Year_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_CS, 0))       AS Indirect_CS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_LBS, 0))      AS Indirect_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_Percent_Forecast_CS, 0))    AS Indirect_Percent_Forecast_CS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_Percent_Forecast_LBS, 0))   AS Indirect_Percent_Forecast_LBS
						,SUM(CASE WHEN Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN ISNULL(Planner_Volume_Plan.Actual_CS, 0) ELSE ISNULL(Planner_Volume_Plan.Forecast_CS, 0) END) AS YTD_CS
            ,SUM(CASE WHEN Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN ISNULL(Planner_Volume_Plan.Actual_LBS, 0) ELSE ISNULL(Planner_Volume_Plan.Forecast_LBS, 0) END) AS YTD_LBS

				FROM    Planners
				INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
						ON 1=1
				INNER JOIN Planner_Template
						ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
							 AND Planner_Template.Deleted = 0
				INNER JOIN Planner_Week
						ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
							 AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
							 AND Planner_Week.Deleted = 0
				LEFT JOIN Planner_Volume_Plan
						ON Planner_Volume_Plan.Planner_Week_ID = Planner_Week.Planner_Week_ID
							 AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							<cfif local.planner_template_product_filter>
							AND Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID IN (SELECT Product_ID FROM ##tmp_planner_template_filter_products)
							</cfif>
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
								AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
							<cfelse>
								AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
							</cfif>
							<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = '#local.plannerSegment#'
							</cfif>

				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID

				<cfif local.qGetPlanner.Approved>
				LEFT JOIN Planner_Locked_Volume_Plan
						ON Planner_Locked_Volume_Plan.Planner_ID = Planners.Planner_ID
						AND Planner_Locked_Volume_Plan.Planner_Week_ID = Planner_Week.Planner_Week_ID
						AND Planner_Locked_Volume_Plan.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						AND Planner_Locked_Volume_Plan.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
						<cfif this.udf.is_planner_indirect_category( form.plannerID )>
							AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Locked_Volume_Plan.BSA_Operator_ID)
						</cfif>
				</cfif>
				WHERE   Planners.Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#form.plannerId#">

					<cfif form.filter_product_list neq "">
						<cfif local.qFilter.Product_Group_Attribute_ID_Field neq "PG_Product_Category_ID">
							AND BSA_Foodservice_Items_Master.#local.qFilter.Product_Group_Attribute_ID_Field# IN ( <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.filter_product_list#"> )
						<cfelse>
							AND EXISTS (
										SELECT TOP 1 1
										  FROM PG_Product_Members m
										 WHERE m.PG_Product_Category_ID IN ( <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.filter_product_list#"> )
													AND m.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
													AND m.Deleted = 0
										)
						</cfif>
					</cfif>

						<cfif form.period eq constants.by_week>
							GROUP BY Planner_Week.Planner_Week_Start_Date
							ORDER BY Planner_Week.Planner_Week_Start_Date
						<cfelse>
							/*
                            GROUP BY CONVERT(VARCHAR(7), Planner_Week.Planner_Week_Start_Date, 126)
							ORDER BY CONVERT(VARCHAR(7), Planner_Week.Planner_Week_Start_Date, 126)
                            */
                            GROUP BY Planner_Week.Display_Year, Planner_Week.Display_Month
                            ORDER BY Planner_Week.Display_Year, Planner_Week.Display_Month
						</cfif>
			</cfquery>

			<cfquery name="local.qGrandTotal" dbtype="query">
				SELECT	 SUM(Actual_CS)           AS Actual_CS
						,SUM(Actual_LBS)          AS Actual_LBS
						,SUM(AOP_CS)              AS AOP_CS
						,SUM(AOP_LBS)             AS AOP_LBS
						,SUM(Demand_Plan_CS)      AS Demand_Plan_CS
						,SUM(Demand_Plan_LBS)     AS Demand_Plan_LBS
						,SUM(Forecast_Base_CS)    AS Forecast_Base_CS
						,SUM(Forecast_Base_LBS)   AS Forecast_Base_LBS
						,SUM(Forecast_CS)         AS Forecast_CS
						,SUM(Forecast_LBS)        AS Forecast_LBS
						,SUM(Forecast_Lift_CS)    AS Forecast_Lift_CS
						,SUM(Forecast_Lift_LBS)   AS Forecast_Lift_LBS
						,SUM(Locked_Forecast_CS)  AS Locked_Forecast_CS
						,SUM(Locked_Forecast_LBS) AS Locked_Forecast_LBS
						,SUM(Prior_Year_CS)       AS Prior_Year_CS
						,SUM(Prior_Year_LBS)      AS Prior_Year_LBS
						,SUM(Indirect_CS)         AS Indirect_CS
						,SUM(Indirect_LBS)        AS Indirect_LBS
						,SUM(YTD_CS) AS YTD_CS
            ,SUM(YTD_LBS) AS YTD_LBS
				FROM 	[local].qTotals
			</cfquery>

			<cfscript>
				local.prod_attr = "p0";
				local.uom_abbr  = ( form.uom eq constants.cases ? "_CS" : "_LBS");
			</cfscript>

			<cfset local.forecast_cnt = 0>
			<!----------------------------->
			<!--- process all forecasts --->
			<!--------------------------------------------------------------------------------------------------------------------------------------------->
			<cfloop list="#form.forecasts#" index="local.forecast">
				<!--- skip this loop when qTotals query is empty --->
				<cfif local.qTotals.recordCount eq 0>
					<cfbreak>
				</cfif>
				<cfscript>
					local.forecast_cnt    = local.forecast_cnt + 1;
					local.column_prefixes = [];
					local.row_labels      = [];
				</cfscript>

				<!-------------------------------------------------->
				<!--- identify column prefixes to pull data from --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<!--- AOP --->
				<cfif local.forecast eq constants.aop>
					<cfscript>
						local.column_prefixes = [ "AOP" ];
						local.row_labels      = [ "AOP" ];
					</cfscript>
				<!--- PY --->
				<cfelseif local.forecast eq constants.prior_year>
					<cfscript>
						local.column_prefixes = [ "Prior_Year" ];
						local.row_labels      = [ "LY" ];
					</cfscript>
				<!--- Locked FCST --->
				<cfelseif local.forecast eq constants.locked_forecast>
					<cfscript>
						local.column_prefixes = [ "Locked_Forecast" ];
						local.row_labels      = [ "Locked FCST" ];
					</cfscript>
				<!--- Latest FCST --->
				<cfelseif local.forecast eq constants.latest_forecast>
					<cfscript>
						local.column_prefixes = [ "Forecast" ];
						local.row_labels      = [ "Latest FCST" ];
					</cfscript>
					<cfif form.show_base_lift eq "1">
						<cfscript>
							local.column_prefixes[2] = "Forecast_Base";
							local.column_prefixes[3] = "Forecast_Lift";
							local.row_labels[2]      = "&nbsp; &rarr; Base";
							local.row_labels[3]      = "&nbsp; &rarr; Lift";
						</cfscript>
					</cfif>
				<!--- Actual --->
				<cfelseif local.forecast eq constants.actual>
					<cfscript>
						local.column_prefixes = [ "Actual" ];
						local.row_labels      = [ "Actual" ];
					</cfscript>
				<!--- Indirect Volume --->
				<cfelseif local.forecast eq constants.indirect_volume>
					<cfscript>
						local.column_prefixes = [ "Indirect" ];
						local.row_labels      = [ "Indirect Volume" ];
					</cfscript>
				<!--- Demand Plan --->
				<cfelseif local.forecast eq constants.demand_plan>
					<cfscript>
						local.column_prefixes = [ "Demand_Plan" ];
						local.row_labels      = [ "Demand" ];
					</cfscript>
				<!--- YTD --->
			<cfelseif local.forecast eq constants.YTD>
				<cfscript>
					local.column_prefixes = [ "YTD" ];
					local.row_labels      = [ "YTD" ];
				</cfscript>
				</cfif>
				<!--------------------------------------------->
				<!--- pulling data based on column prefixes --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfloop from="1" to="#arrayLen(local.column_prefixes)#" index="local.cnt">
					<cfscript>
						local.one_row = [ "", "", "" ];
						if ( forecast_cnt eq 1 and local.cnt eq 1 ) {
							local.one_row[2] = "<b>TOTAL</b>";
						}
						local.one_row[3] = "";                              // not in use for total section
						local.one_row[4] = local.row_labels[ local.cnt ];   // add subtotal label

						local.entry_value = local.qGrandTotal[ local.column_prefixes[ local.cnt ] & local.uom_abbr ] [ 1 ];
						local.one_row[5]  = numberFormat(local.entry_value, local.numberFormat);   // add subtotal value
					</cfscript>

					<!--- loop thru all weeks --->
					<cfoutput query="local.qTotals">
						<cfscript>
							local.entry_value = local.qTotals[ local.column_prefixes[ local.cnt ] & local.uom_abbr ] [ local.qTotals.currentRow ];
							arrayAppend( local.one_row, numberFormat(local.entry_value, local.numberFormat) );        // add week total
						</cfscript>
					</cfoutput>

					<cfscript>
						if ( local.forecast_cnt eq listLen( form.forecasts ) )
							arrayAppend( local.one_row, 'totals divider' );
						else
							arrayAppend( local.one_row, 'totals' );

						// add to the overall array
						arrayAppend( local.all_rows, local.one_row );
					</cfscript>
				</cfloop>
			</cfloop>   <!--- list="#form.forecasts#" index="local.forecast" --->
		</cfif>  <!--- <cfif form.totals neq ""> --->

		<!------------------------>
		<!--- volume plan body --->
		<!--- ------------------------------------------------------------------------------------------------------------------ --->
		<cfquery name="local.qInit" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Tmp_Planner_Perf_Types') IS NOT NULL
				DROP TABLE ##Tmp_Planner_Perf_Types

			IF OBJECT_ID('tempdb..##Tmp_Planner_Volume_Plan') IS NOT NULL
				DROP TABLE ##Tmp_Planner_Volume_Plan


			IF OBJECT_ID('tempdb..##Tmp_Distinct_Products') IS NOT NULL
				DROP TABLE ##Tmp_Distinct_Products

			IF OBJECT_ID('tempdb..##Tmp_Product_Week_Color') IS NOT NULL
				DROP TABLE ##Tmp_Product_Week_Color


			<cfif (form.product_group_level_id eq 0 or form.product_group_level_id eq 9 or form.product_group_level_id eq "")>
                select	 'BSA_Foodservice_Items_Master_ID' AS Product_Group_Attribute_Master_ID_Field,
                            'BSA_Foodservice_Items_Master' AS Product_Group_Attribute_Table,
                            'BSA_Foodservice_Items_Master_ID' AS Product_Group_Attribute_ID_Field,
                            'Description' AS Product_Group_Attribute_Name_Field,
                            'Item' AS Product_Group_Attribute_Number_Field
            <cfelse>
                select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
                            a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
                            a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
                            a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
                            a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
                from	Product_Group_Attribute a
                where	Product_Group_Level_ID = #form.product_group_level_id#
            </cfif>
		</cfquery>

		<cfset local.is_aux_group_in_used = ( local.product_group_level_id_aux neq 0 and local.product_group_level_id_aux neq 9 )>

        <cfif local.is_aux_group_in_used>
            <cfquery name="local.qInit_Aux" datasource="#application.datasource#">
                select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
                            a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
                            a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
                            a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
                            a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
                from	Product_Group_Attribute a
                where	Product_Group_Level_ID = #local.product_group_level_id_aux#
            </cfquery>
        </cfif>

        <cfif form.filter_product_group_level_id neq ''>
            <cfquery name="local.qFilter" datasource="#application.datasource#">
                    select	 a.Product_Group_Attribute_Master_ID_Field AS Product_Group_Attribute_Master_ID_Field,
                            a.Product_Group_Attribute_Table AS Product_Group_Attribute_Table,
                            a.Product_Group_Attribute_ID_Field AS Product_Group_Attribute_ID_Field,
                            a.Product_Group_Attribute_Name_Field AS Product_Group_Attribute_Name_Field,
                            a.Product_Group_Attribute_Number_Field AS Product_Group_Attribute_Number_Field
                    from	Product_Group_Attribute a
                    where   Product_Group_Level_ID = #form.filter_product_group_level_id#
            </cfquery>
        </cfif>

        <cfscript>
            local.item_key    = "BSA_Foodservice_Items_Master." & local.qInit.Product_Group_Attribute_Master_ID_Field;
            local.item        = "grp." & local.qInit.Product_Group_Attribute_Number_Field;
            local.description = "grp." & local.qInit.Product_Group_Attribute_Name_Field;
            local.inner_join  = "INNER JOIN "
                                    & local.qInit.Product_Group_Attribute_Table & " grp "
                                    & " ON grp." & local.qInit.Product_Group_Attribute_ID_Field
                                    & " = BSA_Foodservice_Items_Master." & local.qInit.Product_Group_Attribute_Master_ID_Field;
            local.aux_join = local.is_aux_group_in_used
                                ? "INNER JOIN "
                                    & local.qInit_Aux.Product_Group_Attribute_Table
                                    & " ON " & local.qInit_Aux.Product_Group_Attribute_Table
                                    & "." & local.qInit_Aux.Product_Group_Attribute_ID_Field
                                    & " = BSA_Foodservice_Items_Master." & local.qInit_Aux.Product_Group_Attribute_Master_ID_Field
                                : '';
            local.group_desc_field_aux = local.is_aux_group_in_used
											? local.qInit_Aux.Product_Group_Attribute_Table & "." & local.qInit_Aux.Product_Group_Attribute_Name_Field
											: '';
        </cfscript>


		<cfquery name="local.qVolumes" datasource="#application.datasource#">

			select	Planner_Perf_Types_ID, Sort_Order as Perf_Sort_Order, Color,
					Right('000' + CAST(Sort_Order as varchar(5)), 3) + ':' + Color as Sort_Order_Color
			into	##Tmp_Planner_Perf_Types
			from	Planner_Perf_Types


			SELECT
					<cfif local.is_aux_group_in_used>
						CAST( LTRIM(RTRIM(#local.group_desc_field_aux#)) AS VARCHAR(100) ) AS Aux_Group_Desc,
					<cfelse>
						<!--- product--->
						CAST( LTRIM(RTRIM('#local.group_desc_field_aux#')) AS VARCHAR(100) ) AS Aux_Group_Desc,
                    </cfif>

                    #local.item_key# AS Item_Key,
                    #local.description# AS Description,
                    #local.item# AS Group_ID,
                    <cfif local.qInit.Product_Group_Attribute_Table neq 'BSA_Foodservice_Items_Master'>
                        'A' AS Active_Code
                    <cfelse>
                        BSA_Foodservice_Items_Master.Active_Code AS Active_Code
                    </cfif>

					<cfif form.period eq constants.by_week> <!--- By Week --->
						, Planner_Volume_Plan.Planner_Week_ID as Period_ID
						, Planner_Volume_Plan.Planner_Week_ID as Period_Order
					<cfelse><!--- By month --->
                        /* use planner month defined in planner_week table - do not use the calendar month based on planner start date */
                        , REPLACE(RIGHT(CONVERT(VARCHAR, DATEFROMPARTS(Planner_Week.Display_Year, Planner_Week.Display_Month, 1), 106), 8), ' ', '_') as Period_ID
                        , CONVERT(VARCHAR(7), DATEFROMPARTS(Planner_Week.Display_Year, Planner_Week.Display_Month, 1), 126) as Period_Order
					</cfif>

					,SUM( ISNULL(Planner_Volume_Plan.Actual_CS, 0 ) )        AS Actual_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Actual_LBS, 0) )        AS Actual_LBS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.AOP_CS, 0 ) )           AS AOP_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.AOP_LBS, 0) )           AS AOP_LBS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Demand_Plan_CS, 0 ) )   AS Demand_Plan_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Demand_Plan_LBS, 0) )   AS Demand_Plan_LBS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Forecast_Base_CS, 0 ) ) AS Forecast_Base_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Forecast_Base_LBS, 0) ) AS Forecast_Base_LBS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Forecast_CS, 0 ) )      AS Forecast_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Forecast_LBS, 0) )      AS Forecast_LBS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Forecast_Lift_CS, 0 ) ) AS Forecast_Lift_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Forecast_Lift_LBS, 0) ) AS Forecast_Lift_LBS_SUM
					<cfif local.qGetPlanner.Approved>
                        ,SUM( ISNULL(Planner_Locked_Volume_Plan.Locked_CS, 0) )         AS Locked_Forecast_CS_SUM
                        ,SUM( ISNULL(Planner_Locked_Volume_Plan.Locked_LBS, 0) )        AS Locked_Forecast_LBS_SUM
					<cfelse>
                        ,SUM( ISNULL(Planner_Volume_Plan.Forecast_CS, 0) )         AS Locked_Forecast_CS_SUM
                        ,SUM( ISNULL(Planner_Volume_Plan.Forecast_LBS, 0) )        AS Locked_Forecast_LBS_SUM
					</cfif>
					,SUM( ISNULL(Planner_Volume_Plan.Prior_Year_CS, 0 ) )    AS Prior_Year_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Prior_Year_LBS, 0) )    AS Prior_Year_LBS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Indirect_CS, 0 ) )      AS Indirect_CS_SUM
					,SUM( ISNULL(Planner_Volume_Plan.Indirect_LBS, 0 ) )     AS Indirect_LBS_SUM

					,SUM(CASE WHEN Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN ISNULL(Planner_Volume_Plan.Actual_CS, 0) ELSE ISNULL(Planner_Volume_Plan.Forecast_CS, 0) END) AS YTD_CS_SUM
          ,SUM(CASE WHEN Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN ISNULL(Planner_Volume_Plan.Actual_LBS, 0) ELSE ISNULL(Planner_Volume_Plan.Forecast_LBS, 0) END) AS YTD_LBS_SUM

					<cfif form.uom eq constants.cases>
						,SUM(ISNULL(Planner_Volume_Plan.Actual_CS, 0 )) AS Actual_CS
						,SUM(ISNULL(Planner_Volume_Plan.Actual_Percent_Forecast_CS, 0 )) AS Actual_Percent_Forecast_CS
						,SUM(ISNULL(Planner_Volume_Plan.AOP_CS, 0) ) AS AOP_CS
						,SUM(ISNULL(Planner_Volume_Plan.Demand_Plan_CS, 0) ) AS Demand_Plan_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Base_CS, 0 )) AS Forecast_Base_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_CS, 0 )) AS Forecast_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Lift_CS, 0 )) AS Forecast_Lift_CS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Percent_Prior_Year_CS, 0 )) AS Forecast_Percent_Prior_Year_CS
						<cfif local.qGetPlanner.Approved>
    						,SUM(ISNULL(Planner_Locked_Volume_Plan.Locked_CS, 0 )) AS Locked_Forecast_CS
						<cfelse>
	    					,cast(null as decimal(20, 2)) AS Locked_Forecast_CS
						</cfif>
						,SUM(ISNULL(Planner_Volume_Plan.Prior_Year_CS, 0 )) AS Prior_Year_CS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_CS, 0 )) AS Indirect_CS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_Percent_Forecast_CS, 0 )) AS Indirect_Percent_Forecast_CS
						,SUM(CASE WHEN Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN ISNULL(Planner_Volume_Plan.Actual_CS, 0) ELSE ISNULL(Planner_Volume_Plan.Forecast_CS, 0) END) AS YTD_CS
					<cfelse>
						,SUM(ISNULL(Planner_Volume_Plan.Actual_LBS, 0)) AS Actual_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Actual_Percent_Forecast_LBS, 0)) AS Actual_Percent_Forecast_LBS
						,SUM(ISNULL(Planner_Volume_Plan.AOP_LBS, 0)) AS AOP_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Demand_Plan_LBS, 0) ) AS Demand_Plan_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Base_LBS, 0)) AS Forecast_Base_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_LBS, 0)) AS Forecast_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Lift_LBS, 0)) AS Forecast_Lift_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Forecast_Percent_Prior_Year_LBS, 0)) AS Forecast_Percent_Prior_Year_LBS
						,SUM(CASE WHEN Planner_Week.Planner_Week_End_Date < '#DateToCompare#' THEN ISNULL(Planner_Volume_Plan.Actual_LBS, 0) ELSE ISNULL(Planner_Volume_Plan.Forecast_LBS, 0) END) AS YTD_LBS
						<cfif local.qGetPlanner.Approved>
		    				,SUM(ISNULL(Planner_Volume_Plan.Locked_LBS, 0)) AS Locked_Forecast_LBS
						<cfelse>
			    			,cast(null as decimal(20, 2)) AS Locked_Forecast_LBS
						</cfif>
						,SUM(ISNULL(Planner_Volume_Plan.Prior_Year_LBS, 0)) AS Prior_Year_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_LBS, 0 )) AS Indirect_LBS
						,SUM(ISNULL(Planner_Volume_Plan.Indirect_Percent_Forecast_LBS, 0 )) AS Indirect_Percent_Forecast_LBS
					</cfif>
						,CAST('' as VARCHAR(50)) AS Color
						,SubString(Min(PY_Perf.Sort_Order_Color), 5, 10) AS Prior_Year_Color
						,CAST(0 as INT) AS Program_Count
			INTO	##Tmp_Planner_Volume_Plan
			FROM    Planners

			INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
					ON 1=1
			INNER JOIN Planner_Template
					ON Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
						 AND Planner_Template.Deleted = 0
			INNER JOIN Planner_Week
					ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
						 AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
						 AND Planner_Week.Deleted = 0
			INNER JOIN Planner_Volume_Plan
					ON Planner_Volume_Plan.Planner_Week_ID = Planner_Week.Planner_Week_ID
						 AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
					<cfif this.udf.is_planner_indirect_category( form.plannerID )>
						AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
					<cfelse>
						AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
					</cfif>
					<cfif local.filterSegment>
						AND Planner_Volume_Plan.Business_Segment_ID = '#local.plannerSegment#'
					</cfif>
			INNER JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
			LEFT JOIN ##Tmp_Planner_Perf_Types PY_Perf
					ON PY_Perf.Planner_Perf_Types_ID = Planner_Volume_Plan.Prior_Year_Program_Perf_Type_ID

            #local.inner_join#
            #local.aux_join#

            <cfif local.qGetPlanner.Approved>
				LEFT JOIN Planner_Locked_Volume_Plan
						ON Planner_Locked_Volume_Plan.Planner_ID = Planners.Planner_ID
						AND Planner_Locked_Volume_Plan.Planner_Week_ID = Planner_Week.Planner_Week_ID
						AND Planner_Locked_Volume_Plan.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						AND Planner_Locked_Volume_Plan.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
					<cfif this.udf.is_planner_indirect_category( form.plannerID )>
						AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Locked_Volume_Plan.BSA_Operator_ID)
					</cfif>
            </cfif>


			WHERE   Planners.Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#form.plannerId#">
					<cfif local.planner_template_product_filter>
						AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (SELECT Product_ID FROM ##tmp_planner_template_filter_products)
					</cfif>
					<cfif form.filter_product_list neq "">
						<cfif local.qFilter.Product_Group_Attribute_ID_Field neq "PG_Product_Category_ID">
							AND BSA_Foodservice_Items_Master.#local.qFilter.Product_Group_Attribute_ID_Field# IN ( <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.filter_product_list#"> )
						<cfelse>
							AND EXISTS (
										SELECT TOP 1 1
										  FROM PG_Product_Members m
										 WHERE m.PG_Product_Category_ID IN ( <cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#form.filter_product_list#"> )
													AND m.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
													AND m.Deleted = 0
										)
						</cfif>
					</cfif>

				GROUP BY Planners.Customer_ID,
						<cfif local.is_aux_group_in_used>
                            #local.group_desc_field_aux#,
                        </cfif>
                        BSA_Foodservice_Items_Master.#local.qInit.Product_Group_Attribute_ID_Field#,
                        grp.#local.qInit.Product_Group_Attribute_Name_Field#,
                        grp.#local.qInit.Product_Group_Attribute_Number_Field#
                        <cfif local.qInit.Product_Group_Attribute_Table eq 'BSA_Foodservice_Items_Master'>
                        ,BSA_Foodservice_Items_Master.Active_Code
                        </cfif>
						<cfif form.period eq constants.by_week> <!--- By Week --->
							, Planner_Volume_Plan.Planner_Week_ID
						<cfelse><!--- By month --->
                            , Planner_Week.Display_Year, Planner_Week.Display_Month
                        </cfif>
				    ORDER BY Aux_Group_Desc, Period_Order


				<!--- Get distinct list of products from main query --->
				SELECT 	DISTINCT Aux_Group_Desc, Item_Key, Description, Group_ID
				INTO	##Tmp_Distinct_Products
				FROM	##Tmp_Planner_Volume_Plan

				<!--- Get the color per week/month for those products --->
				SELECT	prod.Aux_Group_Desc, prod.Item_Key, prod.Description, prod.Group_ID,
						clr.Period_ID, clr.Period_Order, Max(clr.Perf_Color) AS Color
				INTO	##Tmp_Product_Week_Color
				FROM	##Tmp_Distinct_Products as prod
				INNER JOIN ##Color_Per_Week clr
				ON		clr.Item_Key = prod.Item_Key
				GROUP BY prod.Aux_Group_Desc, prod.Item_Key, prod.Description, prod.Group_ID, clr.Period_ID, clr.Period_Order

				<!--- Update Color --->
				UPDATE	s
				SET		Color = pwc.Color
				FROM	##Tmp_Planner_Volume_Plan s
				INNER JOIN ##Tmp_Product_Week_Color pwc
				ON		pwc.Item_Key = s.Item_Key
				AND		pwc.Period_ID = s.Period_ID

				<!--- Insert missing entries --->
				INSERT INTO ##Tmp_Planner_Volume_Plan (Aux_Group_Desc, Item_Key, Description, Group_ID, Active_Code, Period_ID, Period_Order, Color)
				SELECT	Aux_Group_Desc, Item_Key, Description, Group_ID, 'A', Period_ID, Period_Order, Color
				FROM	##Tmp_Product_Week_Color pwc
				WHERE	NOT EXISTS (
					SELECT	*
					FROM	##Tmp_Planner_Volume_Plan s
					WHERE	pwc.Item_Key = s.Item_Key
					AND		pwc.Period_ID = s.Period_ID
				)

				/*******  Find the number of programs per product/group ******/
				UPDATE	##Tmp_Planner_Volume_Plan
				SET		Program_Count = total.Program_Count
				FROM	##Tmp_Planner_Volume_Plan
				INNER JOIN (
					SELECT	Item_key, Count(DISTINCT Contract_Main_ID) as Program_Count
					FROM	##Color_Planner_Groups
					GROUP BY Item_key
				) total
				ON	total.Item_Key = ##Tmp_Planner_Volume_Plan.Item_Key

				/*******  Find the sum at products/group level from all periods ******/
				UPDATE	##Tmp_Planner_Volume_Plan
				SET		Actual_CS_SUM = total.Actual_CS_SUM,
						Actual_LBS_SUM = total.Actual_LBS_SUM,
						AOP_CS_SUM = total.AOP_CS_SUM,
						AOP_LBS_SUM = total.AOP_LBS_SUM,
						Demand_Plan_CS_SUM = total.Demand_Plan_CS_SUM,
						Demand_Plan_LBS_SUM = total.Demand_Plan_LBS_SUM,
						Forecast_Base_CS_SUM = total.Forecast_Base_CS_SUM,
						Forecast_Base_LBS_SUM = total.Forecast_Base_LBS_SUM,
						Forecast_CS_SUM = total.Forecast_CS_SUM,
						Forecast_LBS_SUM = total.Forecast_LBS_SUM,
						Forecast_Lift_CS_SUM = total.Forecast_Lift_CS_SUM,
						Forecast_Lift_LBS_SUM = total.Forecast_Lift_LBS_SUM,
						Locked_Forecast_CS_SUM = total.Locked_Forecast_CS_SUM,
						Locked_Forecast_LBS_SUM = total.Locked_Forecast_LBS_SUM,
						Prior_Year_CS_SUM = total.Prior_Year_CS_SUM,
						Prior_Year_LBS_SUM = total.Prior_Year_LBS_SUM,
						Indirect_CS_SUM = total.Indirect_CS_SUM,
						Indirect_LBS_SUM = total.Indirect_LBS_SUM,
						YTD_CS_SUM = total.YTD_CS_SUM,
						YTD_LBS_SUM = total.YTD_LBS_SUM

				FROM	##Tmp_Planner_Volume_Plan
				INNER JOIN (
					SELECT	Item_Key
							,SUM( ISNULL(Actual_CS_SUM, 0 ) )        AS Actual_CS_SUM
							,SUM( ISNULL(Actual_LBS_SUM, 0) )        AS Actual_LBS_SUM
							,SUM( ISNULL(AOP_CS_SUM, 0 ) )           AS AOP_CS_SUM
							,SUM( ISNULL(AOP_LBS_SUM, 0) )           AS AOP_LBS_SUM
							,SUM( ISNULL(Demand_Plan_CS_SUM, 0 ) )   AS Demand_Plan_CS_SUM
							,SUM( ISNULL(Demand_Plan_LBS_SUM, 0) )   AS Demand_Plan_LBS_SUM
							,SUM( ISNULL(Forecast_Base_CS_SUM, 0 ) ) AS Forecast_Base_CS_SUM
							,SUM( ISNULL(Forecast_Base_LBS_SUM, 0) ) AS Forecast_Base_LBS_SUM
							,SUM( ISNULL(Forecast_CS_SUM, 0 ) )      AS Forecast_CS_SUM
							,SUM( ISNULL(Forecast_LBS_SUM, 0) )      AS Forecast_LBS_SUM
							,SUM( ISNULL(Forecast_Lift_CS_SUM, 0 ) ) AS Forecast_Lift_CS_SUM
							,SUM( ISNULL(Forecast_Lift_LBS_SUM, 0) ) AS Forecast_Lift_LBS_SUM
							,SUM( ISNULL(Locked_Forecast_CS_SUM, 0) )         AS Locked_Forecast_CS_SUM
							,SUM( ISNULL(Locked_Forecast_LBS_SUM, 0) )        AS Locked_Forecast_LBS_SUM
							,SUM( ISNULL(Prior_Year_CS_SUM, 0 ) )    AS Prior_Year_CS_SUM
							,SUM( ISNULL(Prior_Year_LBS_SUM, 0) )    AS Prior_Year_LBS_SUM
							,SUM( ISNULL(Indirect_CS_SUM, 0 ) )      AS Indirect_CS_SUM
							,SUM( ISNULL(Indirect_LBS_SUM, 0 ) )     AS Indirect_LBS_SUM
							,SUM( ISNULL(YTD_CS_SUM, 0 ) )    AS YTD_CS_SUM
							,SUM( ISNULL(YTD_LBS_SUM, 0) )    AS YTD_LBS_SUM

					FROM	##Tmp_Planner_Volume_Plan
					GROUP BY Item_Key
				) total
				ON	total.Item_Key = ##Tmp_Planner_Volume_Plan.Item_Key

				/*******  Output the results ******/
				<!---
				Calendar / Volume plan when displaying Items: Order = Group_Desc, Item #
				Calendar / Volume plan when displaying groups: Order = Group Desc
				---->
				SELECT	*
				FROM	##Tmp_Planner_Volume_Plan

				<cfif application.util.query.get_setting( "Sort_Planner_Products_By", 0 ) is "Description">
					ORDER BY Description, Period_Order
				<cfelse>
					ORDER BY Aux_Group_Desc,
						<cfif arguments.product_group_level_id eq 0 or arguments.product_group_level_id eq 9 or arguments.product_group_level_id eq "">
							Group_ID
						<cfelse>
							Description, Group_ID
						</cfif>
						,Period_Order
				</cfif>

		</cfquery>

		<cfif Authorized_Distribution_List_Enabled eq "1">
			<cfquery name="local.qdrop" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##Tmp_ADL_Exclude_Item_Key') IS NOT NULL
				DROP TABLE ##Tmp_ADL_Exclude_Item_Key
			</cfquery>

			<cfquery name="local.qADLExcludes" datasource="#application.datasource#">
				SELECT	DISTINCT i.#local.qInit.Product_Group_Attribute_ID_Field# as Item_Key, ex.Planner_Week_ID
				INTO	##Tmp_ADL_Exclude_Item_Key
				FROM	##Tmp_ADL_Exclude_Products ex
				INNER JOIN BSA_Foodservice_Items_Master i
				ON		i.BSA_Foodservice_Items_Master_ID = ex.BSA_Foodservice_Items_Master_ID

				<!--- Find groups where all products are excluded
				Table Authorized_Distribution_List_Exclude
				If no entry exists in this table - ADL_Excluded = 0 (eg: 0,0=>ADL_Excluded=0)
				If some entry exists in this table - ADL_Excluded = 0 (eg: 0,1=>ADL_Excluded=0)
				If all entries exists in this table - ADL_Excluded = 1 (eg: 1,1=>ADL_Excluded=1)
				--->
				SELECT	tmp.Item_Key, tmp.Planner_Week_ID as Period_ID
				FROM	##Tmp_ADL_Exclude_Item_Key tmp
				INNER JOIN BSA_Foodservice_Items_Master i
				ON		i.#local.qInit.Product_Group_Attribute_ID_Field# = tmp.Item_Key
				AND		i.Deleted = 0
				AND		i.Active_Code = 'A'
				LEFT JOIN ##Tmp_ADL_Exclude_Products ex
				ON		ex.BSA_Foodservice_Items_Master_ID = i. BSA_Foodservice_Items_Master_ID
				ANd		ex.Planner_Week_ID = tmp.Planner_Week_ID
				GROUP BY tmp.Item_Key, tmp.Planner_Week_ID
				Having Min(CASE WHEN ex.BSA_Foodservice_Items_Master_ID IS NULL THEN 0 ELSE 1 END) = 1
			</cfquery>

		<cfelse>
			<cfquery name="local.qADLExcludes" datasource="#application.datasource#">
				SELECT '' as Item_Key, 0 as Period_ID
			</cfquery>
		</cfif>


		<cfscript>
			variables.production = 1;
			variables.endrow     = ( variables.production ? local.qVolumes.recordCount : 50 );
			// disable inputs when mode is not edit
			local.disabled       = ( variables.readonly ? "disabled=disabled" : "" );
			local.uom_abbr       = ( form.uom eq constants.cases ? "_CS" : "_LBS" );
		</cfscript>

		<!--- create a virtual query with one row and columns with zero values --->
		<cfset local.qZero = application.util.query.rowZeros( local.qVolumes.columnList )>

		<!--------------------------------->
		<!--- display products :: begin --->
		<!--------------------------------->

		<cfoutput query="local.qVolumes" group="item_key">
			<cfscript>
				local.prod_attr    = "p#local.qVolumes.currentRow#";
				local.forecast_cnt = 0;
			</cfscript>

			<!--- process all forecasts --->
			<cfloop list="#form.forecasts#" index="local.forecast">
				<cfscript>
					local.forecast_cnt    = local.forecast_cnt + 1;
					local.column_prefixes = [];
					local.row_labels      = [];
				</cfscript>
				<!--- AOP --->
				<cfif local.forecast eq constants.aop>
					<cfscript>
						local.column_prefixes = [ "AOP" ];
						local.row_labels      = [ "AOP" ];
					</cfscript>
				<!--- PY --->
				<cfelseif local.forecast eq constants.prior_year>
					<cfscript>
						local.column_prefixes = [ "Prior_Year" ];
						local.row_labels      = [ "LY" ];
					</cfscript>
				<!--- Locked FCST --->
				<cfelseif local.forecast eq constants.locked_forecast>
					<cfscript>
						local.column_prefixes = [ "Locked_Forecast" ];
						local.row_labels      = [ "Locked FCST" ];
					</cfscript>
				<!--- Latest FCST --->
				<cfelseif local.forecast eq constants.latest_forecast>
					<cfscript>
						local.column_prefixes = [ "Forecast" ];
						local.row_labels      = [ "Latest FCST" ];
					</cfscript>
					<cfif form.show_base_lift eq "1">
						<cfscript>
							local.column_prefixes[2] = "Forecast_Base";
							local.column_prefixes[3] = "Forecast_Lift";
							local.row_labels[2]      = "&nbsp; &rarr; Base";
							local.row_labels[3]      = "&nbsp; &rarr; Lift";
						</cfscript>
					</cfif>
				<!--- FC % PY --->
				<cfelseif local.forecast eq constants.forecast_percent_prior_year>
					<cfscript>
						local.column_prefixes = [ local.forecast ];   // calculated on-the-fly column, no total
						local.row_labels      = [ "FC % LY" ];
					</cfscript>
				<!--- Actual --->
				<cfelseif local.forecast eq constants.actual>
					<cfscript>
						local.column_prefixes = [ "Actual" ];
						local.row_labels      = [ "Actual" ];
					</cfscript>
				<!--- Actual % FC --->
				<cfelseif local.forecast eq constants.actual_percent_forecast>
					<cfscript>
						local.column_prefixes = [ local.forecast ];   // calculated on-the-fly column, no total
						local.row_labels      = [ "Actual % FC" ];
					</cfscript>
				<!--- Indirect Volume --->
				<cfelseif local.forecast eq constants.indirect_volume>
					<cfscript>
						local.column_prefixes = [ "Indirect" ];
						local.row_labels      = [ "Indirect Volume" ];
					</cfscript>
				<!--- Indirect Volume % FC --->
				<cfelseif local.forecast eq constants.indirect_percent>
					<cfscript>
						local.column_prefixes = [ local.forecast ];   // calculated on-the-fly column, no total
						local.row_labels      = [ "Indirect % FCST" ];
					</cfscript>
				<!--- Demand --->
				<cfelseif local.forecast eq constants.demand_plan>
					<cfscript>
						local.column_prefixes = [ "Demand_Plan" ];
						local.row_labels      = [ "Demand" ];
					</cfscript>
				<!--- YTD --->
			<cfelseif local.forecast eq constants.YTD>
				<cfscript>
					local.column_prefixes = [ "YTD" ];
					local.row_labels      = [ "YTD" ];
				</cfscript>
				</cfif>

				<!--------------------------------------------->
				<!--- pulling data based on column prefixes --->
				<!--------------------------------------------------------------------------------------------------------------------------------------------->
				<cfloop from="1" to="#arrayLen(local.column_prefixes)#" index="local.cnt">
					<cfscript>
						local.column_prefix = local.column_prefixes[ local.cnt ];
						local.one_row       = [ local.qVolumes.Item_Key ];    // hidden product item key
						// -------------- //
						// product column //
						// -------------------------------------------------------------------------------------------------------------------------------------
						if ( forecast_cnt eq 1 and local.cnt eq 1 ) {
							// show product information only once only on the first line
							// local.one_row[2] = "#local.qVolumes.group_id#|" & itemDescription( local.qVolumes.description );
							local.product_info = local.qVolumes.group_id & " " & local.qVolumes.description;
							local.one_row[2]   = ( local.qVolumes.Active_Code eq 'N'
														? "<i class='inactive' title='In-Active #request.product_label#'>&##1138;</i>"
														: "" )
														& local.product_info;
													// & left(local.product_info, 30)
													//& ( len(local.product_info) gt 30 ? "..." : "" );
						}
						else {
							// do not show anything in product column when it is not on the first line
							local.one_row[2] = "";
						}

						local.one_row[3] = local.prod_attr;                 // hidden product sequential number
						local.one_row[4] = local.row_labels[ local.cnt ];   // subtotal label

						// --------------- //
						// subtotal column //
						// -------------------------------------------------------------------------------------------------------------------------------------
						if ( local.forecast eq constants.forecast_percent_prior_year
						  or local.forecast eq constants.actual_percent_forecast
						  or local.forecast eq constants.indirect_percent ) {
							local.one_row[5] = "";     // no subtotal value for calculated percentage rows
						}
						else {
							local.column_name = local.column_prefix & local.uom_abbr & "_SUM";
							local.entry_value = local.qVolumes[ local.column_name ] [ local.qVolumes.currentRow ];

							// ---------------------------------------------------------------------------------------------
							// calculate latest FCST subtotal based on displayed weekly forecasts (whole values)
							// existing subtotals are based on backend fractional forecasts - created mismatched subtotals
							// ---------------------------------------------------------------------------------------------
							if ( local.column_prefix is "Forecast" ) {
								var _query = queryExecute( " SELECT #( local.uom_abbr contains "LB" ? "Forecast_LBS" : "Forecast_CS" )# AS volume
							                                   FROM [local].qVolumes
							                                  WHERE Item_Key = '#local.qVolumes.item_key#'
								                            ", [], { dbtype: "query" } );
								local.entry_value = 0;
								// ---------------------------------------------------------------------------------------------
								// total up all individual volumes based on their whole values (displayed on the page) wr 117611
								// ---------------------------------------------------------------------------------------------
								for ( local.row in _query ) {
                                   local.entry_value += val( replace( numberFormat( local.row.volume, local.numberFormat ), ",", '', "all" ) );
								}
							}

							local.one_row[5]  = numberFormat(local.entry_value, local.numberFormat);
						}
					</cfscript>

					<cfloop query="local.qPeriods">

						<cfquery name="local.qVolumeByPeriod" dbtype="query">
							SELECT *
							  FROM [local].qVolumes
							  WHERE Item_Key = '#local.qVolumes.item_key#'
							    AND Period_ID = '#local.qPeriods.Period_ID#'
						</cfquery>
						<!--- volume for period not available use a virtual query --->
						<cfif local.qVolumeByPeriod.recordCount eq 0>
							<cfquery name="local.qVolumeByPeriod" dbtype="query">
								SELECT *
								  FROM [local].qZero
							</cfquery>
						</cfif>


						<cfset ADL_Excluded = 0 />
						<cfif Authorized_Distribution_List_Enabled eq "1">
							<cfquery name="local.qADL_Exclude" dbtype="query">
								SELECT *
								  FROM [local].qADLExcludes
								  WHERE Item_Key = '#local.qVolumes.item_key#'
									AND Period_ID = '#local.qPeriods.Period_ID#'
							</cfquery>
							<cfif local.qADL_Exclude.recordCount>
								<cfset ADL_Excluded = 1 />
							</cfif>
						</cfif>


						<cfscript>
							// --------------------------------------- //
							// calculated on-the-fly percentage values //
							// ---------------------------------------------------------------------------------------------------------------------------------
							if ( local.column_prefix eq constants.forecast_percent_prior_year ) {
								local.prior_year  = local.qVolumeByPeriod[ 'Prior_Year' & local.uom_abbr ];
								local.forecast    = local.qVolumeByPeriod[ 'Forecast' & local.uom_abbr ];
								local.entry_value = ( val(local.prior_year) eq 0
														? 0
														: val(local.forecast) / val(local.prior_year) * 100 );
							}
							else if ( local.column_prefix eq constants.actual_percent_forecast ) {
								local.actual      = local.qVolumeByPeriod[ 'Actual' & local.uom_abbr ];
								local.forecast    = local.qVolumeByPeriod[ 'Forecast' & local.uom_abbr ];
								local.entry_value = ( val(local.forecast) eq 0
														? 0
														: val(local.actual) / val(local.forecast) * 100 );
							}
							else if ( local.column_prefix eq constants.indirect_percent ) {
								local.indirect    = local.qVolumeByPeriod[ 'Indirect' & local.uom_abbr ];
								local.forecast    = local.qVolumeByPeriod[ 'Forecast' & local.uom_abbr ];
								local.entry_value = ( val(local.forecast) eq 0
														? 0
														: val(local.indirect) / val(local.forecast) * 100 );
							}

							// --------------------- //
							// non-calculated values //
							// ---------------------------------------------------------------------------------------------------------------------------------
							else {
								local.column_name = local.column_prefix & local.uom_abbr;
								local.entry_value = local.qVolumeByPeriod[ local.column_name ];
							}

							// ---------------------- //
							// latest forecast values //
							// ---------------------------------------------------------------------------------------------------------------------------------
							if ( local.column_prefix eq constants.latest_forecast ) {
								// input name components = i.<customer_guid>.<product_guid>.<planner_week_id>
								//                              #1 = 'i'
								//                              #2 = customer id
								//                              #3 = product id
								//                              #4 = period id ( week id | month id )
								//                              delimiter = '.'
								// period is the delimeter : "diff" attribute defaults to zero (means value is unchanged), it becomes 1 when its value is changed
								// pass back a list of 2 entries separated by a vertical bar |
								//   1.  numeric forecast value
								//   2.  input name
								local.background_color = local.qVolumeByPeriod[ "color" ];
								arrayAppend( local.one_row, numberFormat( local.entry_value, local.numberFormat )
																& "|"
																& ( form.period neq constants.by_week or now() gte local.qPeriods.Planner_Week_Start_Date or ADL_Excluded eq 1
																	? "disabled"
																	: "name=i.#local.qVolumes.Item_Key#.#local.qPeriods.Period_ID#"
																	)
																& "|"
																& ( local.background_color neq ""
																		? "background-color:##" & local.background_color
																			& ";color:" & application.util.string.foregroundColor( local.background_color )
																		: "" )
																);
							}
							// --------------- //
							// indirect volume //
							// ------------------------------------------------------------------------------------------------------------
							else if (local.column_prefix eq "Indirect") {
								local.special_symbol = "";
								local.indirect = local.qVolumeByPeriod[ 'Indirect' & local.uom_abbr ];
								local.forecast = local.qVolumeByPeriod[ 'Forecast' & local.uom_abbr ];
								// add special character to subtotal label
								if (val(local.indirect) gt val(local.forecast)) {
									local.special_symbol = "&bigstar; ";
									if (not local.one_row[4] contains trim(local.special_symbol)) {
										local.one_row[4] = local.one_row[4] & " " & trim(local.special_symbol);
									}
								}
								arrayAppend( local.one_row, local.special_symbol & numberFormat(local.entry_value, local.numberFormat) );
							}
							else {
								local.background_color = local.qVolumeByPeriod[ "prior_year_color" ];
								local.color_attrs = ( local.forecast neq constants.prior_year or local.background_color eq ""
														? ""
														: "|" & "background-color:##" & local.background_color
															& ";color:" & application.util.string.foregroundColor( local.background_color )
													);
								arrayAppend( local.one_row, numberFormat(local.entry_value, local.numberFormat) & local.color_attrs );
							}
						</cfscript>
					</cfloop>

					<cfscript>
						arrayAppend(local.one_row, "");	// row_type
						arrayAppend(local.one_row, '"' & local.qVolumes.group_id & " - " & local.qVolumes.description & '"');  // prod_tooltip
						arrayAppend(local.one_row, local.qVolumes.program_count);	// program_count
						arrayAppend( local.all_rows, local.one_row );
					</cfscript>
				</cfloop>

			</cfloop>   <!--- list="#form.forecasts#" index="local.forecast" --->
		</cfoutput>

		<!--- Calculate the Total Number of Pages for your records. --->
		<cfset local.totalRecords = local.qVolumes.recordcount * 7>
		<cfset local.totalPages = ceiling(local.totalRecords / arguments.rows)>

		<!--- The JSON return.
			Total - Total Number of Pages we will have calculated above
			Page - Current page user is on
			Records - Total number of records
			rows = our data
		--->

		<cfreturn {total=#local.totalPages#, page=#Arguments.page#, records=#local.totalRecords#, rows=local.all_rows}>
	</cffunction>












	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerVolume" output="true" hint="Save volume plan based on given values.">
		<cfargument name="volumes" required="true" hint="The submitted form.">

		<cfset local.delimiter = ".">
		<cfinclude template="/planners/create/planner_volume_constants.cfm">

		<cfset tmp_planner_distributors( arguments.volumes.plannerID )>
		<cfset local.Authorized_Distribution_List_Enabled = tmp_ADL_Excludes(form.plannerID) />
		<cfset tmp_vol_filter_products()> <!--- Created temp table ##tmp_vol_filter_products_from_cf --->

		<cfset local.filterSegment = getSegmentFilter() />
		<cfset local.plannerSegment = Val(getPlanner.Business_Segment_ID) />

		<cfquery datasource="#application.datasource#">
			DROP TABLE IF EXISTS ##Tmp_Planner_Week
		</cfquery>
		<cfquery name="local.planner_weeks" datasource="#application.datasource#">
			SELECT	Planner_Week.*
			INTO	##Tmp_Planner_Week
			FROM   Planners
			INNER JOIN Planner_Template
				ON Planner_Template.Planner_Template_Id = Planners.Planner_Template_Id
				AND Planner_Template.Deleted = 0
			INNER JOIN Planner_Week
				ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
				AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
			AND Planner_Week.Deleted = 0
			WHERE  Planners.Planner_Id  = #form.plannerID#  /*Do not use cfqueryparam*/
		</cfquery>

		<cfloop collection="#arguments.volumes#" item="local.input_name">
			<cfif listFirst(local.input_name, local.delimiter) eq 'i' and listLen(local.input_name, local.delimiter) eq 3>
				<cfscript>
					// input name components = i.<customer_guid>.<product_guid>.<planner_week_id>
					//                              #1 = 'i'
					//                              #2 = product id
					//                              #3 = week id
					//                              delimiter = '.'
					local.product_key  = listGetAt( local.input_name, 2, local.delimiter );
					local.week_id      = listGetAt( local.input_name, 3, local.delimiter );
					// remove all commas to avoid SQL error
					local.entry_value  = ( trim( arguments.volumes[ local.input_name ] ) eq "" ? 0 : replace( arguments.volumes[ local.input_name ], ",", "", "all" ) );
				</cfscript>

				<!--- no product group is involved --->
				<cfif arguments.volumes.product_group_level_id eq "">
					<!--- look for volume plan in the given week --->
					<cfquery name="local.distributor_product" datasource="#application.datasource#">
						SELECT  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
								,Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
								,Planner_Volume_Plan.BSA_Operator_ID
							<cfelse>
								,0 as BSA_Operator_ID
							</cfif>
								,SUM(ISNULL( Forecast_CS, 0))  AS Forecast_CS
								,SUM(ISNULL( Forecast_LBS, 0)) AS Forecast_LBS
								,BSA_Foodservice_Items_Master.Net_Weight
								,BSA_Foodservice_Items_Master.Active_Code
							FROM Planner_Volume_Plan
						INNER JOIN BSA_Foodservice_Items_Master
								ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
						INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
								ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
						WHERE Planner_Volume_Plan.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								 AND Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
						<cfif this.udf.is_planner_indirect_category( form.plannerID )>
							AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
						<cfelse>
							AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
						</cfif>
						<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
						</cfif>
						<!--- Include records with some kind of volume --->
						AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
						<cfif Authorized_Distribution_List_Enabled eq "1">
							AND NOT EXISTS (
								SELECT 	1
								FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
								WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								AND		ex.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
							)
						</cfif>
								 GROUP BY BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master.Net_Weight, BSA_Foodservice_Items_Master.Active_Code
								<cfif this.udf.is_planner_indirect_category( form.plannerID )>
									, Planner_Volume_Plan.BSA_Operator_ID
								</cfif>
					</cfquery>

					<!--- volume plan for the specific week are not there, get from other weeks within the planner --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( form.plannerID )>
									,Planner_Volume_Plan.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
								FROM Planner_Volume_Plan
							INNER JOIN BSA_Foodservice_Items_Master
									ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
							INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
								ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							INNER JOIN ##Tmp_Planner_Week Planner_Week
								ON Planner_Week.Planner_Week_ID = Planner_Volume_Plan.Planner_Week_ID
							WHERE Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
								AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
							<cfelse>
								AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
							</cfif>
							<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
							</cfif>
							<!--- Include records with some kind of volume --->
							AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
							<cfif Authorized_Distribution_List_Enabled eq "1">
								AND NOT EXISTS (
									SELECT 	1
									FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
									WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
									AND		ex.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								)
							</cfif>
						</cfquery>
					</cfif>

					<!--- volume plan for other weeks are not there,  --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT   BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( form.plannerID )>
									,o.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
							FROM BSA_Foodservice_Items_Master
							INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers ON 1 = 1
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
								INNER JOIN ##tmp_planner_operators o ON 1 = 1
							</cfif>
							WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
							<cfif Authorized_Distribution_List_Enabled eq "1">
								AND NOT EXISTS (
									SELECT 	1
									FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
									WHERE 	ex.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
									AND		ex.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								)
							</cfif>
						</cfquery>
					</cfif>

				<cfelse>
					<!--- handle product group - locate existing products with the same group level with volume plan entry in given week --->
					<cfquery name="local.distributor_product" datasource="#application.datasource#">
						SELECT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
								,Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
								,Planner_Volume_Plan.BSA_Operator_ID
							<cfelse>
								,0 as BSA_Operator_ID
							</cfif>
								,SUM(ISNULL( Forecast_CS, 0))  AS Forecast_CS
								,SUM(ISNULL( Forecast_LBS, 0)) AS Forecast_LBS
								,BSA_Foodservice_Items_Master.Net_Weight
								,BSA_Foodservice_Items_Master.Active_Code
							FROM Planner_Volume_Plan
						 INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
								ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
						 INNER JOIN BSA_Foodservice_Items_Master
								ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
								<cfif arguments.volumes.product_group_level_id eq constants.type_code>
									AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_group_level_id eq constants.type_group>
									AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_group_level_id eq constants.q_brand>
									AND BSA_Foodservice_Items_Master.Q_Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_group_level_id eq constants.brand>
									AND BSA_Foodservice_Items_Master.Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								<cfelseif arguments.volumes.product_group_level_id eq constants.prod_var_a>
									AND BSA_Foodservice_Items_Master.Prod_Var_A_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
								</cfif>
						 WHERE Planner_Volume_Plan.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
						<cfif this.udf.is_planner_indirect_category( form.plannerID )>
							AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
						<cfelse>
							AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
						</cfif>
						<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
						</cfif>
						<!--- Include records with some kind of volume --->
						AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
						<cfif Authorized_Distribution_List_Enabled eq "1">
							AND NOT EXISTS (
								SELECT 	1
								FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
								WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								AND		ex.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
								AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
							)
						</cfif>
						GROUP BY BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master.Net_Weight, BSA_Foodservice_Items_Master.Active_Code
						<cfif this.udf.is_planner_indirect_category( form.plannerID )>
							, Planner_Volume_Plan.BSA_Operator_ID
						</cfif>
						ORDER BY CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END /*  We want inactive items to come first */
					</cfquery>

					<!--- volume plan for the specific week are not there, get from other weeks within the planner --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Planner_Volume_Plan.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( form.plannerID )>
									,Planner_Volume_Plan.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
									,CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END x
								FROM Planner_Volume_Plan
							 INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers
									ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
							 INNER JOIN BSA_Foodservice_Items_Master
									ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
									<cfif arguments.volumes.product_group_level_id eq constants.type_code>
										AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_group_level_id eq constants.type_group>
										AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_group_level_id eq constants.q_brand>
										AND BSA_Foodservice_Items_Master.Q_Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_group_level_id eq constants.brand>
										AND BSA_Foodservice_Items_Master.Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_group_level_id eq constants.prod_var_a>
										AND BSA_Foodservice_Items_Master.Prod_Var_A_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									</cfif>
							INNER JOIN ##Tmp_Planner_Week Planner_Week
								ON Planner_Week.Planner_Week_ID = Planner_Volume_Plan.Planner_Week_ID
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
								WHERE EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
							<cfelse>
								WHERE ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
							</cfif>
							<cfif local.filterSegment>
							AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
							</cfif>
							<!--- Include records with some kind of volume --->
							AND (Planner_Volume_Plan.Prior_Year_CS != 0 OR Planner_Volume_Plan.Forecast_CS != 0 OR Planner_Volume_Plan.Actual_CS != 0)
							<cfif Authorized_Distribution_List_Enabled eq "1">
								AND NOT EXISTS (
									SELECT 	1
									FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
									WHERE 	ex.BSA_Foodservice_Customers_ID = Planner_Volume_Plan.BSA_Foodservice_Customers_ID
									AND		ex.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
									AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
								)
							</cfif>
							ORDER BY CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END /*  We want inactive items to come first */
						</cfquery>
					</cfif>

					<!--- volume plan for other weeks are not there,  --->
					<cfif local.distributor_product.recordCount eq 0>
						<cfquery name="local.distributor_product" datasource="#application.datasource#">
							SELECT  DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
									BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
								<cfif this.udf.is_planner_indirect_category( form.plannerID )>
									,o.BSA_Operator_ID
								<cfelse>
									,0 as BSA_Operator_ID
								</cfif>
									,0 AS Forecast_CS
									,0 AS Forecast_LBS
									,BSA_Foodservice_Items_Master.Net_Weight
									,BSA_Foodservice_Items_Master.Active_Code
									,CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END x
							FROM BSA_Foodservice_Items_Master
							INNER JOIN ##tmp_planner_distributors BSA_Foodservice_Customers ON 1 = 1
							<cfif this.udf.is_planner_indirect_category( form.plannerID )>
							INNER JOIN ##tmp_planner_operators o ON 1 = 1
							</cfif>
							WHERE 1 = 1
									<cfif arguments.volumes.product_list_type eq constants.type_code>
										AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.type_group>
										AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.q_brand>
										AND BSA_Foodservice_Items_Master.Q_Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.brand>
										AND BSA_Foodservice_Items_Master.Brand_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									<cfelseif arguments.volumes.product_list_type eq constants.prod_var_a>
										AND BSA_Foodservice_Items_Master.Prod_Var_A_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.product_key#">
									</cfif>
								<cfif Authorized_Distribution_List_Enabled eq "1">
									AND NOT EXISTS (
										SELECT 	1
										FROM 	##Tmp_ADL_Exclude_Dist_Prod ex
										WHERE 	ex.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
										AND		ex.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
										AND		ex.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
									)
								</cfif>
							ORDER BY CASE WHEN BSA_Foodservice_Items_Master.Active_Code = 'A' THEN 1 ELSE 0 END /*  We want inactive items to come first */
						</cfquery>
					</cfif>
				</cfif>  <!--- arguments.volumes.product eq ""> --->


				<cfif local.distributor_product.recordCount>
					<!--- sum up the previous totals --->
					<cfquery name="local.previous" dbtype="query">
						<cfif arguments.volumes.uom eq constants.cases>
							SELECT SUM(Forecast_CS) AS TotalValue FROM [local].distributor_product
						<cfelse>
							SELECT SUM(Forecast_LBS) AS TotalValue FROM [local].distributor_product
						</cfif>
					</cfquery>

					<cfset local.applied_value = 0>
					<cfset local.delta_value   = local.entry_value - local.previous.TotalValue>

					<cfif local.delta_value neq 0>
						<!--- update all products within the group --->
						<cfloop query="local.distributor_product">
							<cfscript>
								local.original_value = ( arguments.volumes.uom eq constants.cases ? local.distributor_product.Forecast_CS : local.distributor_product.Forecast_LBS );

								if ( local.entry_value eq 0 ) {
									// zero it out
									local.new_value = 0;
								}
								else if ( local.previous.TotalValue eq 0 ) {
									// split the delta value evenly based on number of products
									local.new_value = max( local.original_value + ( local.delta_value / local.distributor_product.recordCount ), 0 );
								}
								else {
									// split the delta value based on original value & original total
									local.new_value = max( local.original_value + ( local.delta_value / local.previous.TotalValue * local.original_value ), 0 );
								}

								if(local.distributor_product.active_code != 'A'){
									// when product is inactive set volume to 0
									local.new_value = 0;

								}

								// last row, just use the remaining amount and ignore the calculated value to avoid rounding problems
								if ( local.distributor_product.currentRow eq local.distributor_product.recordCount ) {
									 local.new_value = max( local.original_value + ( local.delta_value - local.applied_value ), 0 );
								}
							</cfscript>

							<cfquery name="local.update" datasource="#application.datasource#" result="local.result">
								UPDATE Planner_Volume_Plan
									<cfif arguments.volumes.uom eq constants.cases>
										SET  Forecast_CS = #local.new_value#
											,Forecast_Lift_CS = #local.new_value# - ISNULL(Forecast_Base_CS, 0)
											,Forecast_LBS = #local.new_value# * #Net_Weight#
											,Forecast_Lift_LBS = (#local.new_value# - ISNULL(Forecast_Base_CS, 0)) * #Net_Weight#
											,Forecast_updated = 1
									<cfelse>
										SET  Forecast_LBS = #local.new_value#
											,Forecast_Lift_LBS = #local.new_value# - ISNULL(Forecast_Base_LBS, 0)
											,Forecast_CS = #local.new_value# / #Net_Weight#
											,Forecast_Lift_CS = (#local.new_value# - ISNULL(Forecast_Base_LBS, 0)) / #Net_Weight#
											,Forecast_updated = 1
									</cfif>
									/* wip and rfa - update locked forecast column */
									<cfif getPlanner.Status_ID lt 3>
										<cfif arguments.volumes.uom eq constants.cases>
											,Locked_CS = #local.new_value#
											,Locked_LBS = #local.new_value# * #Net_Weight#
										<cfelse>
											,Locked_LBS = #local.new_value#
											,Locked_CS = #local.new_value# / #Net_Weight#
										</cfif>
									</cfif>
								 WHERE Planner_Volume_Plan.Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
										 AND Planner_Volume_Plan.BSA_Foodservice_Customers_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Customers_ID#">
										 AND Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">
									<cfif this.udf.is_planner_indirect_category( form.plannerID )>
										AND Planner_Volume_Plan.BSA_Operator_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.distributor_product.BSA_Operator_ID#">
									<cfelse>
										AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
									</cfif>
									<cfif local.filterSegment>
										AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
									</cfif>
							</cfquery>

							<cfif local.result.recordCount eq 0 and local.new_value neq 0>


								<!--- D73583 - Retail Planner - Volume Plan Error #2224 in Volpi Stage: Adding extra check to prevent primary key violation --->
								<cfquery name="local.qCheckForPrimaryKey" datasource="#application.datasource#">
									SELECT 	*
									FROM 	Planner_Volume_Plan
									WHERE 	Planner_Week_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">
									AND 	BSA_Foodservice_Customers_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Customers_ID#">
									AND 	BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">
									<cfif this.udf.is_planner_indirect_category( form.plannerID )>
										AND Planner_Volume_Plan.BSA_Operator_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.distributor_product.BSA_Operator_ID#">
									<cfelse>
										AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
									</cfif>
									<cfif local.filterSegment>
									AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">
									</cfif>
								</cfquery>

								<cfif local.qCheckForPrimaryKey.recordCount eq 0>

									<cfquery name="local.insert" datasource="#application.datasource#">
										INSERT Planner_Volume_Plan ( Forecast_CS, Forecast_Lift_CS,
																	 Forecast_LBS, Forecast_Lift_LBS,
																	 /* wip and rfa - update locked forecast column */
																	 <cfif getPlanner.Status_ID lt 3>
																			Locked_CS, Locked_LBS,
																	 </cfif>
																	 Planner_Week_ID,
																	 BSA_Foodservice_Customers_ID,
																	 BSA_Foodservice_Items_Master_ID,
																	 BSA_Operator_ID,
																	 Business_Segment_ID,
																	 Prior_Year_CS,
																	 Prior_Year_LBS,
																	 Forecast_Percent_Prior_Year_CS,
																	 Forecast_Percent_Prior_Year_LBS,
																	 Forecast_Updated   )
															VALUES ( <cfif arguments.volumes.uom eq constants.cases>
																		#local.new_value#, #local.new_value#, (#local.new_value# * #Net_Weight#), (#local.new_value# * #Net_Weight#),
																	<cfelse>
																		(#local.new_value# / #Net_Weight#), (#local.new_value# / #Net_Weight#), #local.new_value#, #local.new_value#,
																	 </cfif>
																	 /* wip and rfa - update locked forecast column */
																	 <cfif getPlanner.Status_ID lt 3>
																		 <cfif arguments.volumes.uom eq constants.cases>
																			#local.new_value#, (#local.new_value# * #Net_Weight#),
																		<cfelse>
																			(#local.new_value# / #Net_Weight#), #local.new_value#,
																		 </cfif>
																	 </cfif>
																	 <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.week_id#">,
																	 <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Customers_ID#">,
																	 <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">,
																	<cfif this.udf.is_planner_indirect_category( form.plannerID )>
																		<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.distributor_product.BSA_Operator_ID#">,
																	<cfelse>
																		0,
																	</cfif>
																	<cfif local.filterSegment>
																	 <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.plannerSegment#">,
																	<cfelse>
																	 0,
																	</cfif>
																	 0,
																	 0,
																	 100,
																	 100,
																	 1 )
									</cfquery>

								</cfif>

							</cfif>

							<cfquery name="local.insert" datasource="#application.datasource#">
								INSERT INTO ##tmp_vol_filter_products_from_cf (Product_ID)
								VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.distributor_product.BSA_Foodservice_Items_Master_ID#">)
							</cfquery>

							<!--- keep track of applied values total --->
							<cfset local.applied_value = local.applied_value + ( local.new_value - local.original_value )>
						</cfloop>  <!--- query="local.distributor_product" --->
					</cfif>     <!--- local.delta_value neq 0 --->
				</cfif>     <!--- local.distributor_product.recordCount --->

			</cfif>
		</cfloop>

		<cfstoredproc procedure="Planner_Program_Product_Volume_From_Volume_Plan" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "0" null="yes" />
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@New_Product_ID" value = "" null="yes" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Planner_ID" value = "#arguments.volumes.plannerID#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Filter_On_Product" value = "1" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Include_New_Product_Members_Only" value = "0" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@Volume_Plan_Updated" value = "1" null="no" />
		</cfstoredproc>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="productFilterAttributes" returntype="query" hint="Returns product filter attributes (q_brand, type code, type brand, etc..) based on a given planner template ID.">
		<cfargument name="templateID" type="numeric" required="true">
		<cfargument name="default_view" type="string" required="false" default="" hint="Pass blank to get all, pass 1 to get only the default view">

		<cfquery name="local.filterAttributes" datasource="#application.datasource#">
			SELECT  Product_Group_Level.Product_Group_Level_ID
					,Product_Group_Level.Group_Level_Desc AS Description
					,Product_Group_Attribute.Product_Group_Attribute_Table AS LookupTable
					,Default_View
			FROM    Planner_Template_Filters
			INNER JOIN Product_Group_Level
					ON Planner_Template_Filters.Group_Level_ID = Product_Group_Level.Product_Group_Level_ID
			INNER JOIN Product_Group_Attribute
					ON Planner_Template_Filters.Group_Level_ID = Product_Group_Attribute.Product_Group_Level_ID
			WHERE   Planner_Template_Filters.Planner_Template_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.templateID#">
					AND Planner_Template_Filters.Allow_In_Search = 1
				 /* AND Planner_Template_Filters.PG_Group_Type = 1 */
					AND Product_Group_Level.Product_Group_Level_Type NOT IN ( 0, 1, 4 )
					AND Product_Group_Level.Deleted = 0
					AND Product_Group_Level.Active = 1
					<cfif arguments.default_view neq "">
						AND Default_View = #arguments.default_view#
					</cfif>
					ORDER BY Product_Group_Level.Group_Level_Desc
		</cfquery>

		<cfreturn local.filterAttributes />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerSummary" hint="Returns planner summary based on a given planner ID.">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="includeIndirectProgramCount" type="numeric" required="false" default="0">

		<!--- gather programs information --->
		<cfquery name="local.programs" datasource="#application.datasource#">
			SELECT  Contract_Main_ID
					,PCPO.Created_Type
					,ProgramType_ID
					,Contract_Status_Type_IDX
					,Planner_Perf_Type_ID
					,Planner_Budget_ID
			FROM    Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO
					ON ProgramControl_Panel_Options_ID = ProgramType_ID
			WHERE   CM.Deleted = 0
					AND Contract_Title IS NOT NULL
					AND CM.Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerId#">
		</cfquery>

		<cfscript>
			local.summary = {};
			local.planner = getPlanner(arguments.plannerId);

			local.summary.programs_count = local.programs.recordCount;
			local.summary.rfa_programs   = 0;
			local.summary.wip_programs   = 0;

			local.summary.indirect_programs_count = 0;
			local.summary.indirect_rfa_programs   = 0;
		</cfscript>

		<!--- count different program statuses --->
		<cfloop query="local.programs">
			<cfscript>
				if (local.programs.contract_status_type_idx eq 1) {
					local.summary.wip_programs++;
				}
				else if (local.programs.contract_status_type_idx eq 2) {
					local.summary.rfa_programs++;
				}
			</cfscript>
		</cfloop>

		<cfif arguments.includeIndirectProgramCount>
			<!--- gather programs information from indirect planners --->
			<cfquery name="local.indirectPrograms" datasource="#application.datasource#">
				SELECT  Contract_Status_Type_IDX, count(*) as program_count
				FROM    Planners p
				INNER JOIN Contract_Main CM
				ON		CM.Planner_ID = p.Planner_ID
				WHERE   p.Parent_Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.plannerId#">
						AND CM.Deleted = 0
						AND Contract_Title IS NOT NULL
				GROUP BY Contract_Status_Type_IDX
			</cfquery>

			<!--- count different program statuses --->
			<cfloop query="local.indirectPrograms">
				<cfscript>
					local.summary.indirect_programs_count++;
					if (local.indirectPrograms.contract_status_type_idx eq 2) {
						local.summary.indirect_rfa_programs++;
					}
				</cfscript>
			</cfloop>
		</cfif>


		<cfset lIgnoreColumns = "Actual_CS,Actual_LBS" />

		<!--- copy columns from getPlanner() query --->
		<cfloop list="#local.planner.columnList#" index="local.column">
			<cfif not listFindNoCase(lIgnoreColumns, local.column)>
				<cfset local.summary[ local.column ] = local.planner[ local.column ]>
			</cfif>
		</cfloop>

		<cfreturn local.summary>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerPrograms" returntype="query" hint="Returns planner programs based on a given planner ID.">
		<cfargument name="plannerID" type="numeric" required="true">

		<cfscript>
			appsettings                         = application.oapplicationappsettingsmanager.getapplicationappsettings();
			local.programManager                = CreateObject("component","mvc.Models.Program.programManager");
			local.prgSettings                   = local.programManager.getProgramLevelSettings();
			local.profileSettings               = CreateObject("component","components.user.Profile").getProfileSettings(request.AccessStructure.Profiles_ID);
			local.showProgramTradeSpendORVolume = 0;
			local.showVersionLevelTradeSpend    = 0;
			local.showVersionLevelVolume        = 0;
			local.showPayment                   = 0;
			this.getPlannerProgramComponents(plannerID=arguments.plannerID);
			this.getPlannerProgramClaimMechanics(plannerID=arguments.plannerID);
			local.userID                        = request.AccessStructure.User_ID;
			local.include_sub_status             = 0;
			local.UsersToEvaluate                = "";
			/* we need to display the number of programs in under review, pending approval, agreed sub status*/
			if(local.profileSettings.RFA_Agreed EQ 1 OR local.profileSettings.RFA_Agreed EQ 2){
			     local.include_sub_status = 1;
			     local.compProgramManager = CreateObject("component", "components.programs.ProgramManager").init();
			     local.qGetApprovableUsers = local.compProgramManager.getApprovableUsers(
			                         programId = 0,
			                         PlannerId = arguments.plannerID);

			     // Get users above this user
			     positionId = CreateObject("component", "components.user.UserManager").getPositionId(local.userID, 0);
			     lPositionsAbove = CreateObject("component", "components.geography.position").getPositionsAbove(positionId,0);

			     if(len(trim(lPositionsAbove)) > 0) {
			         stStruct = StructNew();
			         stStruct.userPosition = lPositionsAbove;
			         UserPositionsAbove = CreateObject("component", "components.user.userManager").search(stStruct);
			         local.UsersToEvaluate = ValueList(UserPositionsAbove.User_ID);
			     }
			     local.UsersToEvaluate = Listappend(local.UsersToEvaluate, local.userID);
			     local.UsersToEvaluate = listqualify(local.UsersToEvaluate, "'", ",");

			}
		</cfscript>

		<cfif appSettings.getProgramSearchDollarsAndVolume()>
			<cfif
				(
				<!--- If "Display Trade $" setting is ON --->
				(local.prgSettings.Display_Trade_Dollars eq 1)
				OR
				<!--- If "Display Volume" setting is ON --->
				(local.prgSettings.Display_Volume eq 1)
				OR
				<!--- If "Display Payment $" setting is ON --->
				(local.prgSettings.Display_Payment_Dollars eq 1)
				)
				>
					<cfset local.showProgramTradeSpendORVolume = 1>
			</cfif>
			<!--- TRADE SPEND DOLLARS --->
			<!--- If "Display Trade $" setting is ON --->
			<cfif local.prgSettings.Display_Trade_Dollars eq 1>
				<cfif local.prgSettings.Display_Trade_Dollars_Type eq 1>
					<!--- "Version value" option is selected. If "local.showVersionLevelTradeSpend" is 0, then "Total program value" option is selected
					--->
					<cfset local.showVersionLevelTradeSpend = 1>
				</cfif>
			</cfif>
			<!--- VOLUME --->
			<!--- If "Display Volume" setting is ON --->
			<cfif local.prgSettings.Display_Volume eq 1>
				<cfif local.prgSettings.Display_Volume_Type eq 1>
					<!--- "Version value" option is selected. If "local.showVersionLevelTradeSpend" is 0,
					then "Total program value" option is selected
					--->
					<cfset local.showVersionLevelVolume = 1>
				</cfif>
			</cfif>
			<!--- PAYMENT DOLLARS (payment dollars only have a "Total program value". There is no "version value". --->
			<!--- If "Display Payment $" setting is ON --->
			<cfif local.prgSettings.Display_Payment_Dollars eq 1>
				<cfset local.showPayment = 1>
			</cfif>
		</cfif>
		<cfif local.showProgramTradeSpendORVolume>
			<cfset local.programManager.getVolumeAndTradeSpendAndPaymentDollars(plannerID=arguments.plannerID, ignoreBudget = 1)>
		</cfif>

        <cfquery datasource="#application.datasource#">
            if object_id('tempdb..##Tmp_PlannerPrograms') is not null
            	drop table ##Tmp_PlannerPrograms

            if object_id('tempdb..##Tmp_Planner_Approvable_Users') is not null
            	drop table ##Tmp_Planner_Approvable_Users
        </cfquery>

		<cfquery name="local.qPlannerPrograms" datasource="#application.datasource#">
			SELECT
				CM.Contract_main_ID,
				CST.Contract_Status_Type_Desc,
				CASE
                	WHEN CM.Contract_Status_Type_IDX = 2 THEN DATEDIFF(d, CM.Broker_Approved_Date, GETDATE())
                    ELSE NULL
				END  AS RFA_Days,
				CM.contract_number,
				CM.Contract_Title,
				CM.Contract_Start_Date,
				CM.Contract_End_Date,
				CM.Delivery_Start_Date,
				CM.Delivery_End_Date,
				'Details' as Details,
				PCPO.Created_Type,
				CM.ProgramType_ID,
				CM.Contract_Status_Type_IDX,
				CM.Planner_Perf_Type_ID,
				CM.Contract_Quantity,
				PPT.Description,
				CM.Planner_Budget_ID,
				BUD.Budget_Desc,
				<cfif appSettings.getpaymenthistoryon()>
					cast(IsNull(CMAD.Payment_History,'') as varchar(1))
				<cfelse>
					cast('' as varchar(1))
				</cfif>
				AS Payment_History
				<!--- TRADE SPEND: TOTAL PROGRAM VALUE --->
				<cfif local.showProgramTradeSpendORVolume AND local.showVersionLevelTradeSpend eq 0>
					,cast(ISNULL(Replace(ltrim(rtrim(##TotalPrgTradeSpendAndVolume.Estimated_Program_Spend)),',',''),'0') as varchar(30))
				<!--- TRADE SPEND: VERSION VALUE --->
				<cfelseif local.showVersionLevelTradeSpend>
					,cast(ISNULL(Replace(ltrim(rtrim(IsNull(##PrgVersionlevelTradeSpendAndVolume.Estimated_Committed_Dollar,CMAD.Program_Spend))),',',''),'0') as varchar(30))
				<cfelse>
					,cast('0' as varchar(1))
				</cfif>
				AS Committed_Dollar
				<!--- PAYMENT DOLLARS: TOTAL PROGRAM VALUE.
					THERE IS NO VERSION VALUE. BILLBACK PAYMENT IS ALWAYS CALCULATED FOR ALL THE PROGRAM VERSIONS COMBINED.
					EVERY VERSION OF THE PROGRAM IN THE Paid_Amount COLUMN OF THE Contract_Main_Aux_Data
					TABLE HAS THE SAME AMOUNT, AS THE TOTAL AMOUNT OF ALL THE VERSIONS COMBINED IS UPDATED FOR
					ALL THE VERSIONS.
				--->
				<cfif local.showPayment>
					,cast(ISNULL(Replace(ltrim(rtrim(ISNULL(##TotalPrgTradeSpendAndVolume.actual_dollar,CMAD.Paid_Amount))),',',''),'0') as varchar(25))
				<cfelse>
					,cast('0' as varchar(1))
				</cfif>
				AS Actual_Dollar
				<!--- VOLUME: TOTAL PROGRAM VALUE --->
				<cfif local.showProgramTradeSpendORVolume AND local.showVersionLevelVolume eq 0>
					,cast(ISNULL(Replace(ltrim(rtrim(##TotalPrgTradeSpendAndVolume.Contract_Quantity)),',',''),'0') as varchar(30))
				<!--- VOLUME: VERSION VALUE --->
				<cfelseif local.showVersionLevelVolume>
					,cast(ISNULL(Replace(ltrim(rtrim(Contract_Main.Contract_Quantity)),',',''),'0') as varchar(30))
				<cfelse>
					,cast('0' as varchar(1))
				</cfif>
				AS Program_Volume,
				UOM.Abbreviation As Volume_UOM,
				CASE
					WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
					WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
					ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
				END as Version,
				ppt.Slotting,
				PCPO.Release_Settlement,
				CM.Released,
				CM.Sending_To_External_Client,
				CM.Sent_To_External_Client,
				CM.Contract_Reference_Number,
				CM.External_Client_Ack_Date,
				STUFF((SELECT ', ' + P.Component_Name
					FROM ##PlnrPrgCompInfo P
					WHERE P.Contract_Main_ID = CM.Contract_Main_ID
					ORDER BY Component_Name
					FOR XML PATH('')), 1, 1, '') Components,
				STUFF((SELECT ', ' + PCM.Payment_Type_Name
					FROM ##PrgClaimMechInfo PCM
					WHERE PCM.Contract_Main_ID = CM.Contract_Main_ID
					ORDER BY Payment_Type_Name
					FOR XML PATH('')), 1, 1, '') ClaimMechanics,
				STUFF((SELECT  ', ' + im.item
			FROM BSA_Foodservice_Items_Master im
				inner join Contract_Products cp on cp.BSA_Foodservice_Items_Master_ID = im.BSA_Foodservice_Items_Master_ID and cp.Contract_Main_ID = CM.Contract_Main_ID and cp.Deleted = 0
			ORDER BY im.Item
			FOR XML PATH('')), 1, 1, '') Items,

			CM.Manual_Cancel,
			CASE
    		WHEN CM.Cancelled_Date ! = ''
    			THEN  U1.Name_First + ' ' + U1.Name_last
    		ELSE ''
    		END
    	 	 As Cancelled_By,
			convert(varchar(50), CM.Cancelled_Date, 101) AS Cancelled_Date,
			/* 1 - Auto renewed */
			CM.is_autorenew,

			/* 2 - Auto renew pairs */
			condRenewed = CASE WHEN CM.is_autorenew = 1 AND PAR.Renewed = 1 THEN 1 ELSE 0 END,

			/* 3 - */
			CM.Best_Plan_Program,

			/* 5 - Disagreed */
			LEN(CM.Disagreed_User_ID) AS DisAgreed_Len,

			/* 6 - Doc attached */
						((SELECT TOP 1 Program_ID
			           FROM Contract_Attachments
			           WHERE Contract_Attachments.Program_ID = CM.Contract_Main_ID
			           AND Contract_Attachments.Deleted = 0
			           )) AS Contract_Attachments_Exists,
			/* 8 - Revision */
			condRevision = CASE WHEN (CM.Is_A_Revision=1 AND CM.Revision_Of_Contract_Main_ID != '' AND CM.Revision_Of_Contract_Main_ID IS NOT NULL) THEN 1 ELSE 0 END,

			/* 9 - Expiring No Revision*/
			ExpiringNoRevision = CASE WHEN (CM.Contract_Status_Type_IDX = 6 AND Is_A_Revision = 0) THEN 1 ELSE 0 END,

			/* 10 - Rollover */
			LEN(CM.Rollover_from_Contract_Main_ID) AS Rollover_Len,

			/* 11 - Released */
			condReleased = CASE WHEN (PCPO.Release_Settlement =1 AND CM.Released = 1) THEN 1 ELSE 0 END,

			/* 12 - NOT Released */
			condNotReleased = CASE WHEN (PCPO.Release_Settlement =1 AND CM.Released = 0) THEN 1 ELSE 0 END,

			/* 13 - Acknowledged */
			Acknowledged = CASE WHEN CM.Approved=1 AND CM.sent_to_external_client=1 THEN 1 ELSE 0 END,
			/* 14 - Not Acknowledged */
			NotAcknowledged = CASE WHEN (CM.Manual_Cancel = 0 AND CM.Approved = 1 AND CM.sending_to_external_client = 1 AND CM.sent_to_external_client = 0 AND CM.Cancel_Sent_To_External_Client=0) THEN 1 ELSE 0 END,

			/* 15 - Uploaded 2 means uploaded */
			CM.Creation_Method,
			/* 16 - Restrict from BB */
			dbo.udf_GetRestrictFromBB(CM.Contract_Main_ID) AS RestrictedBB,

			CM.Business_Segment_ID,
			CM.Legacy_Deal_ID,
			CMAD.Program_Spend,
			CAST(0 as int) as Program_Sub_Status_ID,
			CAST('' as varchar(25)) as Program_Sub_Status_Desc
			INTO ##Tmp_PlannerPrograms
			FROM Contract_Main CM
			INNER JOIN Contract_Status_Types CST ON CST.Contract_Status_Type_ID = CM.Contract_Status_Type_IDX
			INNER JOIN Program_Control_Panel_Options PCPO ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			INNER JOIN Contract_Main_Aux_Data CMAD ON CMAD.Contract_Main_ID = CM.Contract_Main_ID
			LEFT JOIN Planner_Perf_Types PPT ON PPT.Planner_Perf_Types_ID = CM.Planner_Perf_Type_ID

            LEFT JOIN Budget_Program_Selection bps ON bps.Program_ID = CM.Contract_Main_ID
			LEFT JOIN Budget BUD ON BUD.Budget_ID = bps.Budget_ID
			INNER JOIN Planners on Planners.Planner_ID = CM.Planner_ID
			INNER JOIN Planner_Template on Planners.Planner_Template_ID = Planner_Template.Planner_Template_ID
			LEFT JOIN Units_of_Measure UOM ON CM.Contract_Quantity_UOM_IDX = UOM.Unit_Of_Measure_ID
			LEFT JOIN _Users U1 ON U1.User_ID = CM.Cancelled_By
			LEFT JOIN Program_Auto_Renew PAR
            ON CM.Contract_Main_ID = PAR.Program_ID
            AND PAR.Deleted = 0
			<cfif local.showProgramTradeSpendORVolume>
				LEFT JOIN ##TotalPrgTradeSpendAndVolume
				ON ##TotalPrgTradeSpendAndVolume.Contract_Number = CM.Contract_Number

				<cfif local.showVersionLevelTradeSpend>
				LEFT JOIN ##PrgVersionlevelTradeSpendAndVolume
				ON ##PrgVersionlevelTradeSpendAndVolume.Contract_Main_ID = CM.Contract_Main_ID
				</cfif>
			</cfif>
			WHERE
			CM.Deleted = 0 AND  CM.Contract_Title IS NOT NULL
			AND CM.Planner_ID = <cfqueryparam value='#arguments.plannerID#'>
            <cfif local.include_sub_status>
                SELECT 	*,
                    Position_Rank = Rank() OVER (Partition By Planner_ID Order By Service_Zone_ID Desc, Service_Region_ID Desc, Service_Market_ID Desc, Authority_Sequence_Order Desc),
                    Position_Type = CASE
                                        WHEN Service_Zone_ID IS NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 0
                                        WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 1
                                        WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NULL THEN 2
                                        WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NOT NULL THEN 3
                                    END
                INTO    ##Tmp_Planner_Approvable_Users
                FROM 	##Tmp_Program_CRA_List

                <!--- Program_Sub_Status_ID = 2 = Pending Approval --->
                UPDATE  p
                SET     Program_Sub_Status_ID = 102,
                        Program_Sub_Status_Desc = 'Pending Approval'
                FROM    ##Tmp_PlannerPrograms p
                WHERE   Contract_Status_Type_IDX = 2
                AND     EXISTS (
                    SELECT  *
                    FROM    ##Tmp_Planner_Approvable_Users cra
                    WHERE   cra.Contract_Main_ID = p.Contract_Main_ID
                    AND     cra.User_ID = '#local.userID#'
                    AND		cra.Position_Rank = 1
                )

                <!--- Program_Sub_Status_ID = 3 = Agreed --->
                UPDATE  p
                SET     Program_Sub_Status_ID = 103,
                        Program_Sub_Status_Desc = 'Agreed'
                FROM    ##Tmp_PlannerPrograms p
                WHERE   Contract_Status_Type_IDX = 2
                AND     EXISTS (
                   SELECT	1
                    FROM	Program_Agree_All_Group Program_Agree
                    WHERE   p.Contract_Main_ID = Program_Agree.ProgramId
                    AND     Program_Agree.User_ID IN (#preservesinglequotes(local.UsersToEvaluate)#) /* Include all users above this user also */
                )

                <!--- Program_Sub_Status_ID = 1 = Under Review --->
                UPDATE  p
                SET     Program_Sub_Status_ID = 101,
                        Program_Sub_Status_Desc = 'Under Review'
                FROM    ##Tmp_PlannerPrograms p
                WHERE   Contract_Status_Type_IDX = 2
                AND     Program_Sub_Status_ID = 0
            </cfif>

            SELECT  *
            FROM    ##Tmp_PlannerPrograms
		</cfquery>

		<cfreturn local.qPlannerPrograms />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="refreshPlannerTimeline" returntype="query"  hint="runs calendar sp">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="refesh" type="boolean"  required="false" default="false">
		<cfargument name="dataOnly" type="boolean"  required="false" default="true">

		<cfstoredproc procedure="Populate_Planner_Calendar" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" value="#arguments.plannerID#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" value="#arguments.refesh#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" value="#arguments.dataOnly#">
			<cfprocresult name="qryPopulatePlannerTimeline">
		</cfstoredproc>

		<cfreturn qryPopulatePlannerTimeline >
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getTimelinePrograms" hint="Returns planner timeline programs based on a given URL planner ID.">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="number_of_records" type="string" required="false" default="all">

		<cfscript>
			local.all_rows        = [];
			local.qTLProductRates = this.refreshPlannerTimeline( form.plannerID, 1, 1);
		</cfscript>

		<cfif ( arguments.number_of_records neq "all" )>
			<cfquery name="local.record" dbtype="query" maxrows="1">
				SELECT * FROM [local].qTLProductRates
			</cfquery>

			<cfreturn local.record>
		<cfelse>
			<cfoutput query="local.qTLProductRates">
				<cfscript>
					local.program                             = {};
					local.program["item_key"]                 = local.qTLProductRates.item_key;
					local.program["group_number"]             = local.qTLProductRates.group_number;
					local.program["description"]              = trim(replace(local.qTLProductRates.description, '"', "&quot;", "all"));
					local.program["contract_main_id"]         = local.qTLProductRates.contract_main_id;
					local.program["contract_number"]          = local.qTLProductRates.contract_number;
					local.program["start_date"]               = dateFormat(local.qTLProductRates.performance_start_date, "m/d/yyyy");
					local.program["end_date"]                 = dateFormat(local.qTLProductRates.performance_end_date, "m/d/yyyy");
					local.program["delivery_start_date"]      = dateFormat(local.qTLProductRates.delivery_start_date, "m/d/yyyy");
					local.program["delivery_end_date"]        = dateFormat(local.qTLProductRates.delivery_end_date, "m/d/yyyy");
					local.program["contract_title"]           = replace(local.qTLProductRates.contract_title, "'", "&apos;", "all");
					local.program["target_nuc_promoted"]      = local.qTLProductRates.target_nuc_promoted;
					local.program["target_nuc_blended"]       = local.qTLProductRates.target_nuc_blended;
					local.program["retailer_unit_cost"]       = local.qTLProductRates.retailer_unit_cost;
					local.program["volume"]                   = local.qTLProductRates.volume;
					local.program["rate"]                     = local.qTLProductRates.rate;
					local.program["contract_status"]          = local.qTLProductRates.contract_status;
					local.program["planner_perf_id"]          = local.qTLProductRates.planner_perf_id;
					local.program["planner_perf_desc"]        = local.qTLProductRates.planner_perf_desc;
					local.program["perf_sort_order"]          = local.qTLProductRates.perf_sort_order;
					local.program["retailer_profit"]          = local.qTLProductRates.retailer_profit;
					local.program["everyday_unit_price"]      = local.qTLProductRates.everyday_unit_price;
					local.program["retailer_margin"]          = local.qTLProductRates.retailer_margin;
					local.program["uom"]                      = local.qTLProductRates.uom;
					local.program["unit"]                     = local.qTLProductRates.unit;
					local.program["price"]                    = local.qTLProductRates.price;
					local.program["template_budget"]          = local.qTLProductRates.template_budget;
					local.program["template_mkt_evt"]         = local.qTLProductRates.template_mkt_evt;
					local.program["template_nuc_target"]      = local.qTLProductRates.template_nuc_target;
					local.program["template_ruc"]             = local.qTLProductRates.template_ruc;
					local.program["template_mup"]             = local.qTLProductRates.template_mup;
					local.program["template_retailer_margin"] = local.qTLProductRates.template_retailer_margin;
					local.program["alternate_customer_on"]    = local.qTLProductRates.alternate_customer_on;
					local.program["distributor_group_count"]  = local.qTLProductRates.distributor_group_count;
					local.program["distributor_count"] 		  = local.qTLProductRates.distributor_count;

					arrayAppend( local.all_rows, local.program );
				</cfscript>
			</cfoutput>
			<cfreturn local.all_rows>
		</cfif>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->
	<cffunction name="getPlannerMargin" access="public" returntype="query" output="false" hint="runs the margin for the planner">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="userID" type="string" required="false" default="">
		<cfargument name="include_slotting" required="false" default="1"/>
		<cfargument name="cachedWithinSecs" type="numeric" required="false" default="0">

		<cfif arguments.cachedWithinSecs gt 0>
			<cfset cachedwithinTime = CreateTimespan(0,0,arguments.cachedWithinSecs,0) />
		<cfelse>
			<cfset cachedwithinTime = CreateTimespan(0,0,0,0) />
		</cfif>

		<cfif this.debug_log><cflog text="getPlannerMargin() - include_slotting = #arguments.include_slotting#" file="include_slotting"></cfif>
		<cfstoredproc procedure="Planner_Margin_Calc" datasource="#application.datasource#" cachedwithin="#cachedwithinTime#">
			<cfprocparam cfsqltype="cf_sql_integer" value="#arguments.plannerID#">
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.include_slotting#">
			<cfprocresult name="qryMargin">
		</cfstoredproc>

		<cfreturn qryMargin />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->
	<cffunction name="getPlannerApproval" access="remote" returnformat="json" hint="Returns planner approval based on a given planner ID.">

		<cfparam name="form.uom" default="c">
		<cfparam name="form.approval_margin_type" default=0>

		<cfscript>
			local.all_rows       = [];	// Building the array of rows to pass back to jqGrid
			local.qMargin        = getPlannerMargin( form.plannerid, request.AccessStructure.user_id, form.include_slotting );
		</cfscript>

		<!--- process all products --->
		<cfloop query="local.qMargin">
			<cfscript>
				local.single_row = [];

				// save hidden values at the top to avoid positioning problems
				local.single_row[ 1 ] = local.qMargin.BSA_Foodservice_Items_Master_ID;
				local.single_row[ 2 ] = local.qMargin.row_type;
				local.single_row[ 3 ] = local.qMargin.delivery_type;
				local.single_row[ 4 ] = local.qMargin.contract_main_id;
				local.single_row[ 5 ] = local.qMargin.user_action_message;
				if(local.qMargin.Above_EZ_Rate){
					local.single_row[ 6 ] = "Item rate is above max template rate of " & (form.uom eq 'c' ? NumberFormat(local.qMargin.EZ_Rate_CS, "_,_.00") : NumberFormat(local.qMargin.EZ_Rate_LB, "_,_.0000"));
				}
				else{
					local.single_row[ 6 ] = "";
				}

				local.counter       = 6;
				local.empty_columns = 0;
				if (local.qMargin.row_type eq "prod") {
					local.counter++; local.single_row[ local.counter ] = local.qMargin.item & "<br>" & local.qMargin.Description;
					local.empty_columns = 3;
				}
				else if (local.qMargin.row_type eq "pgm") {
					local.counter++; local.single_row[ local.counter ] = local.qMargin.product_program;
					local.counter++; local.single_row[ local.counter ] = dateFormat(local.qMargin.Contract_Start_Date, 'medium');
					local.counter++; local.single_row[ local.counter ] = dateFormat(local.qMargin.Contract_End_Date, 'medium');
					local.counter++; local.single_row[ local.counter ] = local.qMargin.contract_Status;
				}
				else if (local.qMargin.row_type eq "group") {
					local.counter++; local.single_row[ local.counter ] = local.qMargin.product_program;
					local.empty_columns = 3;
				}
				else if (local.qMargin.row_type eq "planner") {
					local.counter++; local.single_row[ local.counter ] = "PLANNER SUMMARY";
					local.empty_columns = 3;
				}

				for ( local.empty_index = 1; local.empty_index lte local.empty_columns; local.empty_index++ ) {
					local.counter++; local.single_row[ local.counter ] = "";
				}

				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Volume_CS : local.qMargin.Volume_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Sales_CS : local.qMargin.Sales_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Allowance_CS : local.qMargin.Allowance_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.tpa_cs : local.qMargin.tpa_lb);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Net_Sales_CS : local.qMargin.Net_Sales_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Cost_CS : local.qMargin.Cost_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Operating_Income_CS : local.qMargin.Operating_Income_LB);

				if ( form.approval_margin_type neq 3 ) {
					local.counter++; local.single_row[ local.counter ] = val( local.qMargin.Margin_Percent ) * 100;
				}

				local.counter++; local.single_row[ local.counter ] = local.qMargin.Target_Margin;
				if (form.approval_margin_type eq 1) {
					local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Trade_CS : local.qMargin.Trade_LB);
				}

				if ( form.approval_margin_type eq 1 or ( form.approval_margin_type eq 0 and form.Display_Trade_Percent_on_Margin eq 1 ) ) {
					local.counter++; local.single_row[ local.counter ] = local.qMargin.Trade_Percent;
				}

				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.Target_NUC_CS : local.qMargin.Target_NUC_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.NUC_CS : local.qMargin.NUC_LB);
				local.counter++; local.single_row[ local.counter ] = (form.uom eq 'c' ? local.qMargin.NUC_Variance_CS : local.qMargin.NUC_Variance_LB);

				local.counter++; local.single_row[ local.counter ] = local.qMargin.user_action;

				arrayAppend( local.all_rows, local.single_row );
			</cfscript>
		</cfloop>

		<!--- collect unique messages to send back --->
		<cfquery name="local.message" dbtype="query">
			SELECT DISTINCT(User_Action_Message)
			  FROM [local].qMargin
			 WHERE User_Action_Message > ''
		</cfquery>

		<cfset local.program_messages = []>
		<!--- append a message number to the beginning of each message when there are multiple messages --->
		<cfoutput query="local.message">
			<cfset arrayAppend(local.program_messages, local.message.currentRow & ". " & local.message.user_action_message)>
		</cfoutput>
		<cfscript>
			local.program_messages = local.message.recordCount gt 1
										? arrayToList( local.program_messages, "<br>" )
										: local.message.user_action_message;
			local.totalRecords = local.qMargin.recordcount * 7;
			local.totalPages   = ceiling(local.totalRecords / arguments.rows);
			return {total=#local.totalPages#, page=#Arguments.page#, records=#local.totalRecords#, rows=local.all_rows, messages=local.program_messages};
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerApproval" output="true">
		<cfargument name="approval_form" required="true">

		<cfscript>
			local.delimiter = "_";
			local.agreeds   = [];
			local.workFlowManager = createObject("component", "components.workflow.WorkFlowManager");
		</cfscript>

		<cfloop collection="#arguments.approval_form#" item="local.input_name">
			<cfset local.action = listFirst(local.input_name, local.delimiter)>
			<cfif (local.action eq "approve" or local.action eq "agree") and listLen(local.input_name, local.delimiter) eq 3>
				<cfscript>
					// input name components = approve_<contract_main_id>_<product_guid>
					//                              #1 = 'approve' | 'agree'
					//                              #2 = contract_main_id
					//                              #3 = product id
					//                              delimiter = '_'
					local.contract_main_id                = listGetAt( local.input_name, 2, local.delimiter );
					local.bsa_foodservice_items_master_id = listGetAt( local.input_name, 3, local.delimiter );
				</cfscript>

				<cfif local.action eq "approve">
					<cfquery name="local.approve" datasource="#application.datasource#">
						IF NOT EXISTS (
											SELECT 1
											  FROM Program_Type_Code_Approval_Info
											 WHERE Program_ID = #local.contract_main_id#
											   AND Product_ID = '#local.bsa_foodservice_items_master_id#'
											   AND    Approve = 1
											   AND       Type = 1
											   AND    Deleted = 0
										)
							INSERT INTO Program_Type_Code_Approval_Info
										( Program_ID, Product_ID, Approve, Type, User_ID )
								VALUES 	( #local.contract_main_id#, '#local.bsa_foodservice_items_master_id#', 1, 1, '#request.AccessStructure.user_id#')
					</cfquery>
				<cfelse>
					<cfquery name="local.agree" datasource="#application.datasource#">
						IF NOT EXISTS (
											SELECT 1
											  FROM Program_Type_Code_Approval_Info
											 WHERE Program_ID = #local.contract_main_id#
											   AND Product_ID = '#local.bsa_foodservice_items_master_id#'
											   AND      Agree = 1
											   AND       Type = 2
											   AND    User_ID = '#request.AccessStructure.user_id#'
											   AND    Deleted = 0
										)
							INSERT INTO Program_Type_Code_Approval_Info
										( Program_ID, Product_ID, Agree, Type, User_ID )
								VALUES 	( #local.contract_main_id#, '#local.bsa_foodservice_items_master_id#', 1, 2, '#request.AccessStructure.user_id#')
					</cfquery>
					<!--- keep track of unique agreed programs --->
					<cfif arrayFind(local.agreeds, local.contract_main_id) eq 0>
						<cfset arrayAppend(local.agreeds, local.contract_main_id)>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<!--- scan all agreed programs --->
		<cfloop array="#local.agreeds#" index="local.agreed_program">
			<cfset local.reasons = []>

			<!--- scan for agreed reasons for a program - reason is stored in the value attribute of the hidden input element --->
			<cfloop collection="#arguments.approval_form#" item="local.input_name">
				<cfif findNoCase("agree_" & local.agreed_program & "_", local.input_name) eq 1>
					<cfif arrayFindNoCase(local.reasons, arguments.approval_form[ local.input_name ]) eq 0>
						<cfset arrayAppend(local.reasons, arguments.approval_form[ local.input_name ] )>
					</cfif>
				</cfif>
			</cfloop>

			<!--- save agreed reasons --->
			<cfif arrayLen(local.reasons)>
				<cfset local.workFlowManager.saveProgramAgreeReason(local.agreed_program, request.AccessStructure.user_id, arrayToList(local.reasons, "|"))>
			</cfif>
		</cfloop>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerProfile" returntype="query" hint="Returns planner profiles data with perf types ">
		<cfargument name="plannerID" type="numeric" required="true">

		<cfquery name="local.qPlannerProfile" datasource="#application.datasource#">
			SELECT	P.Planner_Number,
					P.Planner_ID,
					P.Planner_Title,
					P.Planner_Nickname,
					P.Planner_Perf_Start_Day,
					P.Planner_Expected_Margin,
					PPT.Description,
					PPT.Color,
					PPT.Sort_Order,
					PP.Planner_Profile_ID,
					PPT.Planner_Perf_Types_ID,
					CASE
                                  WHEN PP.Planner_Profile_ID IS NULL AND PPT.Default_Use = 1 THEN PPT.Default_Duration /* Use default value from settings panel */
                                  ELSE PP.Duration /* Use value saved on planner  */
                                  END as Duration,
                                  CASE
                                  WHEN PP.Planner_Profile_ID IS NULL AND PPT.Default_Use = 1 THEN PPT.Default_Delivery_Days_Start /* Use default value from settings panel */
                                  ELSE PP.Planner_Delivery_Days_Start /* Use value saved on planner  */
                                  END as Planner_Delivery_Days_Start,
                                  CASE
                                  WHEN PP.Planner_Profile_ID IS NULL AND PPT.Default_Use = 1 THEN PPT.Default_Delivery_Days_End /* Use default value from settings panel */
                                  ELSE PP.Planner_Delivery_Days_End /* Use value saved on planner  */
                                  END as Planner_Delivery_Days_End,

					PP.Created_By,
					PP.Created_Date,
					PP.Updated_Date,
					PP.Updated_By,
					PTPT.Planner_Template_Perf_Types_ID
			FROM 	dbo.Planners P
						LEFT JOIN Planner_Template_Perf_Types PTPT
							ON PTPT.Planner_Template_ID = P.Planner_Template_ID
								AND PTPT.Deleted = 0
							 /*  For regular planner look for Selected = 1, for indirect planner look for Indirect_Selected = 1 */
								AND CASE WHEN ISNULL(P.Parent_Planner_ID, 0) = 0 THEN PTPT.Selected ELSE PTPT.Indirect_Selected END = 1
						LEFT JOIN dbo.Planner_Perf_Types PPT
							ON PPT.Planner_Perf_Types_ID = PTPT.Planner_Perf_Types_ID
								AND PPT.Deleted = 0
						LEFT JOIN Planner_Profile PP
							ON PP.Planner_Perf_Types_ID = PTPT.Planner_Perf_Types_ID
								AND PP.Planner_ID = P.Planner_ID
								AND PP.Deleted = 0
								AND PP.Deleted = 0
								AND PTPT.Deleted = 0
			WHERE  P.Planner_ID = '#arguments.plannerID#'
			ORDER BY PPT.Sort_Order
		</cfquery>

		<cfreturn local.qPlannerProfile />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerProfile" output="true" hint="Save Planner Profile based on given values.">
		<cfargument name="ppFormData" required="true" hint="The submitted form.">

		<cfset this.savePlannerData(arguments.ppFormData) />
		<cfset this.savePlannerProfileData(arguments.ppFormData) />
		<cfset this.savePlannerProfileProductData(arguments.ppFormData) />

		<cfreturn />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerData" output="true" hint="Save Planner data based on given values.">
		<cfargument name="ppFormData" required="true" hint="The submitted form.">

		<cfquery name="local.qUpdatePlanner" datasource="#application.datasource#">
			UPDATE
				Planners
			SET
				Planner_Title = '#ppFormData.txtPlannerTitle#',
				Planner_NickName = '#ppFormData.txtPlannerNickName#',
				Planner_Perf_Start_Day = #ppFormData.selWeekday#
			WHERE
				Planner_ID = #ppFormData.plannerID#
		</cfquery>

		<cfreturn />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerProfileData" output="true" hint="Save Planner Profile based on given values.">
		<cfargument name="ppFormData" required="true" hint="The submitted form.">

		<cfif ppFormData.profileRowCount NEQ 0>
			<cfset profileRows = this.getPlannerProfile( plannerID=ppFormData.plannerID ) />
			<cfloop query="profileRows">
				<cfif (((evaluate("ppFormData.Duration_#Planner_Template_Perf_Types_ID#") NEQ "") OR (evaluate("DaysLessStart_#Planner_Template_Perf_Types_ID#") NEQ "") OR (evaluate("ppFormData.DaysLessEnd_#Planner_Template_Perf_Types_ID#") NEQ "")) AND profileRows.Planner_Profile_ID EQ "")>
					<!--- INSERT --->
					<cfset DurationVal		= evaluate("ppFormData.Duration_#Planner_Template_Perf_Types_ID#") />
					<cfset PlannerDDSVal	= evaluate("ppFormData.DaysLessStart_#Planner_Template_Perf_Types_ID#") />
					<cfset PlannerDDEVal	= evaluate("ppFormData.DaysLessEnd_#Planner_Template_Perf_Types_ID#") />

					<cfset useLakebaseForlocal_qInsertPlannerProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_profile")>
<cfif useLakebaseForlocal_qInsertPlannerProfile>
	<cftry>
		<cfset application.oLakebase.insertRow("planner_profile", {
			"planner_id" = "#profileRows.Planner_ID#",
			"planner_perf_types_id" = "#profileRows.Planner_Perf_Types_ID#",
			"deleted" = "0",
			"duration" = "#DurationVal#",
			"planner_delivery_days_start" = "#PlannerDDSVal#",
			"planner_delivery_days_end" = "#PlannerDDEVal#",
			"created_by" = "#request.AccessStructure.user_id#",
			"created_date" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_qInsertPlannerProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_qInsertPlannerProfile>
<cfquery name="local.qInsertPlannerProfile" datasource="#application.datasource#">
						INSERT INTO Planner_Profile
							( Planner_ID, Planner_Perf_Types_ID, Deleted, Duration, Planner_Delivery_Days_Start, Planner_Delivery_Days_End, Created_By, Created_Date )
						VALUES
							( #profileRows.Planner_ID#,
								#profileRows.Planner_Perf_Types_ID#,
								0,
								'#DurationVal#',
								'#PlannerDDSVal#',
								'#PlannerDDEVal#',
								'#request.AccessStructure.user_id#',
								getDate()
							)
					</cfquery>
</cfif>
				<cfelseif (profileRows.Planner_Profile_ID NEQ "")>
					<!--- UPDATE --->
					<cfset DurationVal		= evaluate("ppFormData.Duration_#Planner_Template_Perf_Types_ID#") />
					<cfset PlannerDDSVal	= evaluate("ppFormData.DaysLessStart_#Planner_Template_Perf_Types_ID#") />
					<cfset PlannerDDEVal	= evaluate("ppFormData.DaysLessEnd_#Planner_Template_Perf_Types_ID#") />

					<cfquery name="local.qUpdatePlannerProfile" datasource="#application.datasource#">
						UPDATE	Planner_Profile
						SET 	Duration                    = '#DurationVal#',
								Planner_Delivery_Days_Start = '#PlannerDDSVal#' ,
								Planner_Delivery_Days_End   = '#PlannerDDEVal#',
								Updated_By                  = '#request.AccessStructure.user_id#',
								Updated_Date                = getDate()
						WHERE	Planner_Profile_ID = #profileRows.Planner_Profile_ID#
					</cfquery>
				</cfif>
			</cfloop>
			<cfreturn 1 />
		<cfelse>
			<cfreturn 0 />
		</cfif>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getProdAttrData" output="false">

		<cfargument name="groupLevelId" required="false" default="">

		<cfscript>

			//set local variables
			var nGroupLevelId	= "";
			var qGetAttr		= "";


			//assign local variables
			nGroupLevelId	= arguments.groupLevelId;

		</cfscript>

		<cfquery name="qGetAttr" datasource="#application.datasource#">
			SELECT	Product_Group_Attribute_Table,
					Product_Group_Attribute_ID_Field,
					Product_Group_Attribute_Master_ID_Field,
					Product_Group_Attribute_Name_Field,
					Product_Group_Attribute_Number_Field,
					Product_Group_Level.Is_PG
			FROM 	Product_Group_Attribute
			INNER JOIN Product_Group_Level
			ON 		Product_Group_Level.Product_Group_Level_ID = Product_Group_Attribute.Product_Group_Level_ID
			WHERE 	Product_Group_Attribute.Product_Group_Level_ID = '#nGroupLevelId#'
		</cfquery>

		<cfreturn qGetAttr />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- get a planner summary--->
	<cffunction name="getPlannerSummaryData" access="public" returntype="query" output="false">
		<cfargument name="plannerId" required="true" type="numeric">
		<cfargument name="include_slotting" required="false" default="1">
		<cfargument name="cachedWithinSecs" type="numeric" required="false" default="0">

		<!--- call margin routine to populate data for latest trade & sales --->
		<cfset local.qMargin = getPlannerMargin( arguments.plannerId, request.AccessStructure.user_id, arguments.include_slotting, arguments.cachedWithinSecs ) />
		<cfif arguments.cachedWithinSecs gt 0>
			<cfset cachedwithinTime = CreateTimespan(0,0,arguments.cachedWithinSecs,0) />
		<cfelse>
			<cfset cachedwithinTime = CreateTimespan(0,0,0,0) />
		</cfif>

		<cfif this.debug_log><cflog text="getPlannerSummaryData() - include_slotting = #arguments.include_slotting#" file="include_slotting"></cfif>
		<cfstoredproc procedure="Planner_Summary_Data" datasource="#application.datasource#" cachedwithin="#cachedwithinTime#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.plannerId#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.include_slotting#">
			<cfprocresult name="local.plannerSummary">
		</cfstoredproc>

		<cfreturn local.plannerSummary />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- get a planner summary struct --->
	<cffunction name="getPlannerSummaryStruct" access="remote">
		<cfargument name="plannerId" required="true" type="numeric" />

		<cfscript>
			local.result            = {};
			local.result["status"]  = "success";
			local.result["message"] = "";
			local.summary           = getPlannerSummaryData( arguments.plannerid );
		</cfscript>

		<!--- copy summary columns --->
		<cfloop list="#local.summary.columnList#" index="local.column">
			<cfset local.result[ lcase(local.column) ] = local.summary[ local.column ]>
		</cfloop>

		<cfreturn  local.result >
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerProfileProductData" hint="Returns profile page everyday unit price for products based on a given planner ID and product group level ID.">
		<cfargument name="plannerID" type="numeric" required="true">
		<cfargument name="product_group_level_id" required="false">
		<cfargument name="filter_product_group_level_id" required="false" default="">
		<cfargument name="filter_product_list" required="false" default="">


		<cfscript>
			getPlannerProducts( arguments.plannerId,
								arguments.product_group_level_id,
								"profile",
								arguments.filter_product_group_level_id,
								arguments.filter_product_list );
		</cfscript>

		<cfquery name="qPlannerProfileProducts" datasource="#application.datasource#">
			SELECT 	Planner_Products.BSA_Foodservice_Customers_ID, Planner_Products.Item_Key, Planner_Products.Item, Planner_Products.Description,
					ISNULL(Profile_Products.EveryDay_Unit_Price, 0) AS EveryDay_Unit_Price,
					Profile_Products.EveryDay_Unit_Price_UOM AS UOM,
					Profile_Products.Planner_Profile_Products_ID
			FROM 	tempdb..##tmp_planner_items Planner_Products
			LEFT JOIN Planner_Profile_Products Profile_Products
					ON Profile_Products.BSA_Foodservice_Customers_ID = Planner_Products.BSA_Foodservice_Customers_ID
					AND Profile_Products.BSA_FoodService_Items_Master_Id = Planner_Products.Item_Key
					AND Profile_Products.Planner_ID =  <cfqueryparam cfsqltype="cf_sql_numeric"  value="#arguments.plannerID#" />
		</cfquery>

		<cfreturn qPlannerProfileProducts />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getSavedPlannerProfileProductData" hint="Returns saved everyday unit price data">
		<cfargument name="plannerID" type="numeric" required="true">

		<cfquery name="qPlannerProfileProducts" datasource="#application.datasource#">
			SELECT 	Profile_Products.BSA_Foodservice_Customers_ID, Profile_Products.BSA_FoodService_Items_Master_Id as Item_Key, 				ISNULL(Profile_Products.EveryDay_Unit_Price, 0) AS EveryDay_Unit_Price,
					ISNULL(Profile_Products.EveryDay_Unit_Price_UOM, 5) AS UOM,
					Profile_Products.Planner_Profile_Products_ID
			FROM 	Planner_Profile_Products Profile_Products
			WHERE 	Profile_Products.Planner_ID =  <cfqueryparam cfsqltype="cf_sql_numeric"  value="#arguments.plannerID#" />
		</cfquery>

		<cfreturn qPlannerProfileProducts />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="savePlannerProfileProductData" hint="Saves everyday unit price for products entered on planner profile page">
		<cfargument name="ppFormData" required="true" hint="The submitted form.">

		<cfif ppFormData.profileProductRowCount NEQ 0>
			<cfset qPlannerProfileProducts = this.getPlannerProfileProductData( ppFormData.plannerID, ppFormData.product_group_level_id ) />
			<cfloop query="qPlannerProfileProducts">
                <!--- If user filtered product list, not all products will be in the form scope --->
                <cfif StructKeyExists(ppFormData, "#qPlannerProfileProducts.Item_Key#")>
                    <cfset everyDayUnitPrice = ppFormData["#qPlannerProfileProducts.Item_Key#"] />
                    <cfset everyDayUnitPriceUOM = ppFormData["#qPlannerProfileProducts.Item_Key#_uom"] />
                    <cfif qPlannerProfileProducts.Planner_Profile_Products_ID NEQ "" >
                        <!--- UPDATE --->
                        <cfquery name="local.qUpdatePlannerProfile" datasource="#application.datasource#">
                            UPDATE	Planner_Profile_Products
                            SET 	EveryDay_Unit_Price             = '#everyDayUnitPrice#',
                                EveryDay_Unit_Price_UOM         = '#everyDayUnitPriceUOM#',
                                Updated_Date                    = getDate()
                            WHERE	Planner_ID                      = '#ppFormData.plannerID#'
                            AND		BSA_Foodservice_Customers_ID    = '#qPlannerProfileProducts.BSA_Foodservice_Customers_ID#'
                            AND		BSA_Foodservice_Items_Master_ID = '#qPlannerProfileProducts.Item_Key#'
                        </cfquery>
                    <cfelse>
                        <!--- INSERT --->
                        <cfquery name="local.qInsertPlannerProfileProducts" datasource="#application.datasource#">
                            INSERT INTO Planner_Profile_Products
                                ( Planner_ID, BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master_ID, EveryDay_Unit_Price, EveryDay_Unit_Price_UOM, Created_Date )
                            VALUES
                                (
                                    '#ppFormData.plannerID#',
                                    '#qPlannerProfileProducts.BSA_Foodservice_Customers_ID#',
                                    '#qPlannerProfileProducts.Item_Key#',
                                    '#everyDayUnitPrice#',
                                    '#everyDayUnitPriceUOM#',
                                    getDate()
                                )
                        </cfquery>
                    </cfif>
                </cfif>
			</cfloop>
			<cfreturn 1 />
		<cfelse>
			<cfreturn 0 />
		</cfif>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="saveTimeLineEntry" access="remote" hint="Save timeline entry and return a status result">
		<cfargument name="plannerid" type="numeric" required="true">
		<cfargument name="contract_main_id" type="numeric" required="true">
		<cfargument name="start_date" type="date" required="true">
		<cfargument name="end_date" type="date" required="true">
		<cfargument name="delivery_start_date" type="date" required="true">
		<cfargument name="delivery_end_date" type="date" required="true">
		<cfargument name="indirect_planner" type="numeric" default="0">
		<cfargument name="parent_planner_id" type="numeric" default="0">

		<cfscript>
			local.ppm = createObject("component","mvc.Models.Planner.PlannerProgramManager");
			local.ppm.updatePlannerProgram( arguments );

			local.result            = {};
			local.result["status"]  = "success";
			local.result["message"] = "";
			local.summary           = getPlannerSummaryData( arguments.plannerid );
		</cfscript>

		<!--- copy summary columns --->
		<cfloop list="#local.summary.columnList#" index="local.column">
			<cfset local.result[ lcase(local.column) ] = local.summary[ local.column ]>
		</cfloop>

		<cfreturn ( local.result )>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="createTimeLineEntry" access="remote" hint="Create new timeline entry and return a status result">
		<cfargument name="plannerid" type="numeric" required="true">
		<cfargument name="rate" type="numeric" required="true">
		<cfargument name="start_date" type="date" required="true">
		<cfargument name="end_date" type="date" required="true">
		<cfargument name="planner_perf_id" type="numeric" required="true">

		<cfscript>
			// local.ppm = createObject("component","mvc.Models.Planner.PlannerProgramManager");
			local.new_program = getTimelinePrograms( arguments.plannerID, "1" );

			local.result            = {};
			local.result["status"]  = "success";
			local.result["message"] = "";
			local.summary           = getPlannerSummaryData( arguments.plannerid );
		</cfscript>

		<!--- copy new program columns --->
		<cfloop list="#local.new_program.columnList#" index="local.column">
			<cfset local.result[ lcase(local.column) ] = local.new_program[ local.column ]>
		</cfloop>

		<!--- copy summary columns --->
		<cfloop list="#local.summary.columnList#" index="local.column">
			<cfset local.result[ lcase(local.column) ] = local.summary[ local.column ]>
		</cfloop>

		<cfreturn ( local.result )>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="copyTimeLineProgram" access="remote" hint="copied existing timeline program and returns a status result">
		<cfargument name="plannerid" type="numeric" required="true">
		<cfargument name="contract_main_id" type="numeric" required="true">
		<cfargument name="start_date" type="date" required="true">
		<cfargument name="end_date" type="date" required="true">
		<cfargument name="delivery_start_date" type="date" required="true">
		<cfargument name="delivery_end_date" type="date" required="true">
		<cfargument name="planner_perf_id" type="numeric" required="true">
		<cfargument name="user_id" type="string" required="true">
		<cfargument name="indirect_planner" type="numeric" default="0">
		<cfargument name="parent_planner_id" type="numeric" default="0">

		<cfscript>
			local.ppm               = createObject("component","mvc.Models.Planner.PlannerProgramManager");
			local.new_program       = local.ppm.copyPlannerProgram( arguments );
			local.result            = {};
			local.result["status"]  = "success";
			local.result["message"] = "";
			local.summary           = getPlannerSummaryData( arguments.plannerid );
		</cfscript>

		<!--- copy program columns --->
		<cfloop list="#local.new_program.columnList#" index="local.column">
			<cfset local.result[ lcase(local.column) ] = local.new_program[ local.column ]>
		</cfloop>

		<!--- copy summary columns --->
		<cfloop list="#local.summary.columnList#" index="local.column">
			<cfset local.result[ lcase(local.column) ] = local.summary[ local.column ]>
		</cfloop>

		<cfreturn ( local.result )>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getCRA" returnType="void" hint="Gets list of users who are currently responsible for approval">
		<cfargument name="plannerid" type="numeric" required="true">

		<cfscript>
			local.ProgramManager = CreateObject("component", "components.programs.ProgramManager").init();
			local.qGetApprovableUsers = local.ProgramManager.getApprovableUsers(
						programId = 0,
						PlannerId = arguments.plannerId);
		</cfscript>

		<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
				if object_id('tempdb..##Tmp_Planner_Approvable_Users') is not null
				drop table ##Tmp_Planner_Approvable_Users
		</cfquery>

		<cfquery name="qPlannerCRARank" datasource="#application.datasource#">
			SELECT 	*,
					Position_Rank = Rank() OVER (Order By Service_Zone_ID Desc, Service_Region_ID Desc, Service_Market_ID Desc, Authority_Sequence_Order Desc),
					Position_Type = CASE
							WHEN Service_Zone_ID IS NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 0
							WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 1
							WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NULL THEN 2
							WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NOT NULL THEN 3
							END
			INTO    ##Tmp_Planner_Approvable_Users
			FROM 	##Tmp_Program_CRA_List

			<!----
			Filter on Position_Rank = 1. We don't want zone users to be displayed in CRA list if there are region users in the CRA list.
			This is to avoid below scenario,

			PGM1 CRA = RegionAUser1 -> Then ZoneAUser1
			PGM2 CRA = RegionAUser2 -> Then ZoneAUser1
			Planner CRA = RegionAUser1, RegionAUser2

			After RegionAUser1 agrees to the planner we will have below,
			PGM1 CRA = ZoneAUser1
			PGM2 CRA = RegionAUser2 -> Then ZoneAUser1
			Planner CRA = RegionAUser2  (We do not want to show ZoneAUser1 at this point. we want to wait till RegionAUser2 agrees to the planner)

			After RegionAUser2 agrees to the planner we will have below,
			PGM1 CRA = ZoneAUser1
			PGM2 CRA = ZoneAUser1
			Planner CRA = ZoneAUser1
			---->
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getApprovableUsers" returnType="query" hint="Returns ist of users who are currently responsible for approval">
		<cfargument name="plannerid" type="numeric" required="true">

		<cfscript>
			getCRA(arguments.plannerId);
		</cfscript>

		<cfquery name="qPlannerCRAUsers" datasource="#application.datasource#">
			<!----
			Filter on Position_Rank = 1. We don't want zone users to be displayed in CRA list if there are region users in the CRA list.
			This is to avoid below scenario,

			PGM1 CRA = RegionAUser1 -> Then ZoneAUser1
			PGM2 CRA = RegionAUser2 -> Then ZoneAUser1
			Planner CRA = RegionAUser1, RegionAUser2

			After RegionAUser1 agrees to the planner we will have below,
			PGM1 CRA = ZoneAUser1
			PGM2 CRA = RegionAUser2 -> Then ZoneAUser1
			Planner CRA = RegionAUser2  (We do not want to show ZoneAUser1 at this point. we want to wait till RegionAUser2 agrees to the planner)

			After RegionAUser2 agrees to the planner we will have below,
			PGM1 CRA = ZoneAUser1
			PGM2 CRA = ZoneAUser1
			Planner CRA = ZoneAUser1
			---->
			SELECT  *
			FROM    ##Tmp_Planner_Approvable_Users
			WHERE   Position_Rank = 1
			ORDER BY Position_Type, User_Full_Name, User_Email, User_ID, Contract_Main_ID
		</cfquery>

		<cfreturn qPlannerCRAUsers />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerNextApprovableUsers" returnType="query" hint="Returns ist of users who are currently responsible for approval">
		<cfargument name="plannerid" type="numeric" required="true">

		<cfscript>
			local.WorkFlowManager = CreateObject("component", "components.workflow.WorkFlowManager").init();
			local.qGetNextApprovableUsers = local.WorkFlowManager.getNextApprovableUsers(
						programId = 0,
						PlannerId = arguments.plannerId);

			getCRA(arguments.plannerId);
		</cfscript>

		<cfquery name="qPlannerNRAUsers" datasource="#application.datasource#">
			SELECT 	t.User_Full_Name, t.User_Email, t.User_ID, t.Position_Label, t.Authority_Sequence_Name, t.Profiles_Desc,
				t.Contract_Number, t.Contract_Title, t.Contract_Main_ID, t.Created_Type,
					Position_Rank = Rank() OVER (Order By Service_Zone_ID Desc, Service_Region_ID Desc, Service_Market_ID Desc, Authority_Sequence_Order Desc),
					Position_Type = CASE
							WHEN Service_Zone_ID IS NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 0
							WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL THEN 1
							WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NULL THEN 2
							WHEN Service_Zone_ID IS NOT NULL AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NOT NULL THEN 3
							END
			FROM 	##Tmp_Program_NRA_List t
			INNER JOIN Planner_Profiles_Settings
			ON      Planner_Profiles_Settings.Profiles_ID =  t.Profiles_ID
			AND     Planner_Profiles_Settings.Planner_approval_rights = 1
			UNION
			SELECT  t.User_Full_Name, t.User_Email, t.User_ID, t.Position_Label, t.Authority_Sequence_Name, t.Profiles_Desc,
				t.Contract_Number, t.Contract_Title, t.Contract_Main_ID, t.Created_Type,
					t.Position_Rank, t.Position_Type
			FROM    ##Tmp_Planner_Approvable_Users t
			WHERE   Position_Rank != 1
			ORDER BY Position_Type, User_Full_Name, User_Email, User_ID, Contract_Main_ID
		</cfquery>

		<cfreturn qPlannerNRAUsers />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="itemDescription" hint="Returns item description on calendar page and volume page">
		<cfargument name="item" required="true">
		<cfargument name="break_at" required="false" default="27">

		<cfscript>
			// convert long item description into array, replace quotes with HTML codes
			local.small_strings = application.util.string.splitToArray( application.util.string.replaceQuotes( arguments.item ), arguments.break_at );

			// insert line break and ... to long item description
			return local.small_strings[1] & ( arrayLen( local.small_strings ) eq 1
												? ""
												: "<br>" & local.small_strings[2] & ( arrayLen( local.small_strings ) eq 2
																					? ""
                                                                                    : "..." )

											 );
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerMissingItems" hint="Returns missing items/groups between planners, used when copying">
		<cfargument name="source_planner_Id" required="true" type="numeric" />
		<cfargument name="target_planner_Id" required="true" type="numeric" />

		<cfscript>
			var nPlannerToId 			= 0;
			var nPlannerFromId 			= 0;

			var qGetToPlannerData		= "";
			var qGetFromPlannerData		= "";

			var qGetToItems				= "";
			var qGetFromItems			= "";

			var strToItemsList			= "";
			var strFromItemsList		= "";

			nPlannerToId = arguments.target_planner_Id;
			nPlannerFromId = arguments.source_planner_Id;

			qGetToPlannerData = getPlanner(nPlannerToId);
			qGetFromPlannerData = getPlanner(nPlannerFromId);

			qGetToProductGroupID = productFilterAttributes(qGetToPlannerData.Planner_Template_ID, 1);
			qGetFromProductGroupID = productFilterAttributes(qGetFromPlannerData.Planner_Template_ID, 1);

			request.planner_category = qGetToPlannerData.Category;
			qGetToItems = getPlannerProducts(nPlannerToId, qGetToProductGroupID.Product_Group_Level_ID);

			request.planner_category = qGetFromPlannerData.Category;
			qGetFromItems = getPlannerProducts(nPlannerFromId, qGetFromProductGroupID.Product_Group_Level_ID);

			strToItemsList = ValueList(qGetToItems.item_key);
			strFromItemsList = valueList(qGetFromItems.item_key);
		</cfscript>

		<cfquery name="qGetPlannerMissingItems" dbtype="query">
			select 	distinct Item_Key, Item, Description
			from	qGetFromItems
			where	Item_Key NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#strToItemsList#">)
			ORDER BY Description
		</cfquery>

		<cfreturn qGetPlannerMissingItems />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerImportPrograms" output="false" hint="get programs from source planner for items in target planner">
		<cfargument name="source_planner" type="numeric" required="true" hint="source planner ID">
		<cfargument name="products_list" type="string" required="false" default="" hint="The list of products from target">
		<cfargument name="target_planner" type="numeric" required="true" hint="target planner ID">

        <cfquery datasource="#application.datasource#">
            IF Object_id('tempdb..##Planner_Week_All') IS NOT NULL
                DROP TABLE ##Planner_Week_All

            IF Object_id('tempdb..##Tmp_Import_Planner_Programs') IS NOT NULL
                DROP TABLE ##Tmp_Import_Planner_Programs
        </cfquery>

        <cfquery name="local.qPlannerTemplate" datasource="#application.datasource#">
            SELECT pl.planner_template_id, pt.Business_Segment_ID
              FROM planners pl
                      INNER JOIN planner_template pt ON pl.planner_template_id = pt.planner_template_id
             WHERE pl.planner_ID = #arguments.target_planner#
        </cfquery>

        <cfset local.qProgramTemplates = createObject("component","components.programs.template.TemplateManager").getRetailPlannerTemplates(  qPlannerTemplate.planner_template_id
                                                                                                                                            , qPlannerTemplate.Business_Segment_ID )>

		<cfquery name="local.qPlannerImportPrograms" datasource="#application.datasource#">
            /*** \mvc\Models\Planner\PlannerManager.cfc - getPlannerImportPrograms() ***/
            DECLARE @From_Planner_ID                      INT = #arguments.source_planner#,
                    @To_Planner_ID                        INT = #arguments.target_planner#,
                    @From_Planner_Start_Corrected_Week_ID INT,
                    @To_Planner_Start_Corrected_Week_ID   INT

            SELECT DISTINCT Planner_Year,
                            planner_Week_Start_Date,
                            Planner_Week_end_Date,
                            Planner_Week_ID,
                            PY_Week_Start_Date,
                            PY_Week_End_Date,
                            Dense_rank()
                            OVER(
                                ORDER BY planner_Week_Start_Date) AS Corrected_Week_ID
            INTO   ##Planner_Week_All
            FROM   Planner_Week
            WHERE  Planner_Week.Deleted = 0

            SELECT @From_Planner_Start_Corrected_Week_ID = Corrected_Week_ID
            FROM   planners
                INNER JOIN planner_template
                        ON planners.planner_template_id = planner_template.planner_template_id
                INNER JOIN ##Planner_Week_All pw
                        ON planner_template.Planner_Start_Date BETWEEN Planner_Week_Start_Date AND Planner_Week_End_Date
            WHERE  planner_id = @From_Planner_ID

            SELECT @To_Planner_Start_Corrected_Week_ID = Corrected_Week_ID
            FROM   planners
                INNER JOIN planner_template
                        ON planners.planner_template_id = planner_template.planner_template_id
                INNER JOIN ##Planner_Week_All pw
                        ON planner_template.Planner_Start_Date BETWEEN Planner_Week_Start_Date AND Planner_Week_End_Date
            WHERE  planner_id = @To_Planner_ID


            SELECT DISTINCT cm.contract_main_id,
                            cst.contract_status_type_desc,
                            cm.contract_number,
                            cm.contract_title,
                            cm.contract_start_date,
                            cm.contract_end_date,
                            cm.delivery_start_date,
                            cm.delivery_end_date,
                            cm.performance_start_date,
                            cm.performance_end_date,
                            pcpo.created_type,
                            cm.programtype_id,
                            cm.contract_status_type_idx,
                            cm.planner_perf_type_id,
                            ppt.description,
                           CASE
								WHEN LEN(CM.revision_version) = 4 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 4)
								WHEN LEN(CM.revision_version) = 5 THEN RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 5)
								ELSE RIGHT('000' + CAST(CM.revision_version AS VARCHAR(10)), 3)
							END             AS version,
                            target_planner_template.Planner_Start_Date                                 AS To_Planner_Start_Date,
                            target_planner_template.Planner_End_Date                                   AS To_Planner_End_Date,
                            Prg_Duration = DATEDIFF(d, cm.contract_start_date, cm.contract_end_date)            +    1,
                            Prg_Perf_Duration = DATEDIFF(d, cm.performance_start_date, cm.performance_end_date) +    1,
                            Program_Start_Week_Index = pwf.Corrected_Week_ID                                    -    @From_Planner_Start_Corrected_Week_ID, /* /*  no. of weeks from planner start */ */
                            From_Prg_Start_Offset = DATEDIFF(d, pwf.Planner_Week_Start_Date, cm.contract_start_date),
                            From_Prg_Perf_Start_Offset = DATEDIFF(d, pwf.Planner_Week_Start_Date, cm.performance_start_date),
                            CAST(NULL AS DATE) AS To_Prg_Week_Start_Date,
                            CAST(NULL AS DATE) AS New_contract_start_date,
                            CAST(NULL AS DATE) AS New_contract_end_date,
                            CAST(NULL AS DATE) AS New_performance_start_date,
                            CAST(NULL AS DATE) AS New_performance_end_date,
                            CAST(0 AS    BIT)  AS Program_End_Adjusted
            INTO            ##Tmp_Import_Planner_Programs
            FROM            contract_main CM
            INNER JOIN      contract_status_types CST
            ON              cst.contract_status_type_id = cm.contract_status_type_idx
            INNER JOIN      program_control_panel_options PCPO
            ON              pcpo.programcontrol_panel_options_id = cm.programtype_id

            AND pcpo.First_Parent_ID IN ( #listQualify( valueList(local.qProgramTemplates.First_Parent_ID), "'" )# )
            INNER JOIN      planners
            ON              planners.planner_id = cm.planner_id
            INNER JOIN      planner_template
            ON              planners.planner_template_id = planner_template.planner_template_id
            INNER JOIN      planners target_planners
            ON              target_planners.planner_id = @To_Planner_ID
            INNER JOIN      planner_template target_planner_template
            ON              target_planners.planner_template_id = target_planner_template.planner_template_id
            LEFT JOIN       planner_perf_types PPT
            ON              ppt.planner_perf_types_id = cm.planner_perf_type_id
            INNER JOIN      contract_products cp
            ON              cp.contract_main_id = cm.contract_main_id
                            AND cp.deleted = 0
            LEFT JOIN       ##Planner_Week_All pwf
            ON              cm.contract_start_date BETWEEN pwf.Planner_Week_Start_Date AND pwf.Planner_Week_End_Date
            WHERE           cm.deleted = 0
                            AND cm.planner_id = @From_Planner_ID
							<cfif arguments.products_list gt ''>
                            	AND cp.bsa_foodservice_items_master_id IN ( < cfqueryparam cfsqltype = "cf_sql_varchar" value = "#arguments.products_list#" list = "true" > )
							</cfif>
                            AND cm.contract_title IS NOT NULL
                            AND cm.contract_start_date >= planner_template.planner_start_date
                            AND cm.contract_end_date <= planner_template.planner_end_date
                            AND ISNULL(PPT.Accrual, 0) = 0

            /* Do not include accrual program */
            UPDATE pgm
               SET To_Prg_Week_Start_Date = pwt.Planner_Week_Start_Date
              FROM ##Tmp_Import_Planner_Programs pgm
                    INNER JOIN ##Planner_Week_All pwt
                        ON Corrected_Week_ID = @To_Planner_Start_Corrected_Week_ID + pgm.Program_Start_Week_Index

            UPDATE ##Tmp_Import_Planner_Programs
               SET  New_contract_start_date    = Dateadd(d, From_Prg_Start_Offset, To_Prg_Week_Start_Date),
                    New_contract_end_date      = Dateadd(d, From_Prg_Start_Offset + Prg_Duration, To_Prg_Week_Start_Date),
                    New_performance_start_date = Dateadd(d, From_Prg_Perf_Start_Offset, To_Prg_Week_Start_Date),
                    New_performance_end_date   = Dateadd(d, From_Prg_Perf_Start_Offset
                                                            + Prg_Perf_Duration, To_Prg_Week_Start_Date)

            UPDATE ##Tmp_Import_Planner_Programs
               SET Program_End_Adjusted = 1,
                   New_contract_end_date = To_Planner_End_Date
             WHERE New_contract_end_date > To_Planner_End_Date

            UPDATE ##Tmp_Import_Planner_Programs
               SET Program_End_Adjusted = 1,
                   New_performance_end_date = To_Planner_End_Date
             WHERE New_performance_end_date > To_Planner_End_Date

            SELECT *
              FROM ##Tmp_Import_Planner_Programs
             WHERE New_contract_start_date BETWEEN To_Planner_Start_Date AND To_Planner_End_Date
                    AND New_contract_start_date <= New_contract_end_date
		</cfquery>

		<cfreturn local.qPlannerImportPrograms>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="reassign" output="false" hint="Reassign RSP in planners">
		<cfargument name="input_form" required="true">

		<cfscript>
			local.delimiter = "_";
		</cfscript>

		<cfloop collection="#arguments.input_form#" item="local.element">
			<!--- look for element starts with "rsp" & uses '_' as delimiter --->
			<cfif listLen(local.element, local.delimiter) eq 2 and listFirst(local.element, local.delimiter) is "rsp">
				<cfset local.planner_id = listGetAt(local.element, 2, local.delimiter)>
				<cfset local.new_rsp_id = arguments.input_form[ local.element ]>

				<cftransaction>
					<cfquery datasource="#application.datasource#">
						UPDATE Planners
						   SET RSP_ID = '#local.new_rsp_id#'
								,Creator_Position_ID = '#arguments.input_form.Chosen_Position_Id#'   /*  WR75987 */
						WHERE Planner_ID = #local.planner_id#
					</cfquery>

					<cfquery name="local.programs" datasource="#application.datasource#">
						SELECT Contract_Main_ID, Contract_Number
						  FROM Contract_Main
						 WHERE Planner_ID = #local.planner_id#
					</cfquery>

					<!--- D92945: reassgin issue when no programs exist on planner  --->
					<cfif local.programs.recordCount >
						<cfquery datasource="#application.datasource#">
							UPDATE Contract_Main
							   SET Original_Creating_User_Position_ID = Creating_User_Position_ID
							WHERE Planner_ID = #local.planner_id#

							UPDATE Contract_Main
							   SET Creating_User_Position_ID = '#arguments.input_form.Chosen_Position_Id#'
									,Responsible_User_Id = '#local.new_rsp_id#'
							WHERE Planner_ID = #local.planner_id#
						</cfquery>

						<cfquery datasource="#application.datasource#">
							<cfoutput query="local.programs">
								INSERT INTO Program_Owner
									( 	Contract_Main_ID
										,Contract_Number
										,Responsible_User_ID
										,Creating_User_Position_ID
										,Reassigned_By )
								VALUES
									(	#local.programs.contract_main_ID#
										,'#local.programs.contract_number#'
										,'#local.new_rsp_id#'
										,'#arguments.input_form.Chosen_Position_Id#'
										,'#request.AccessStructure.User_ID#' )
							</cfoutput>
						</cfquery>

						<cfoutput query="local.programs">
							<cfstoredproc procedure="Populate_Program_Approvable_Positions" datasource="#application.datasource#">
								<cfprocparam type="In" CFSQLType="CF_SQL_Integer" dbVarName="@@CONTRACT_MAIN_ID" value="#local.programs.contract_main_ID#">
							</cfstoredproc>
						</cfoutput>
					</cfif>  <!--- local.programs.recordCount  --->
				</cftransaction>
			</cfif>
		</cfloop>


	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getSelectSQL" output="false" hint="Returns select string">
	 <cfargument name="columnName" required="true">

		<cfscript>
			var retStr 		= "";
			var strColumn 	= "";

		 	strColumn = arguments.columnName;

			retStr = "CASE WHEN Planner_Template.Program_Default_UOM = 1 AND Planners.volume_plan_uom = 1 AND Inventory_UM = 'CS'
						THEN
							Planner_Volume_Plan.#strColumn# / CAST(BSA_Foodservice_Items_Master.Net_Weight as float)
						ELSE
							Planner_Volume_Plan.#strColumn#
						END";
		</cfscript>

		<cfreturn trim(retStr) />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerOperators" output="false" hint="Returns Operators for Indirect Planners">
	 <cfargument name="plannerTemplateId" required="true" type="numeric" />

        	<cfstoredproc procedure="Planner_Template_Operators" datasource="#application.datasource#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.plannerTemplateId#">
			<cfprocresult name="local.plannerOperators">
		</cfstoredproc>

		<cfreturn local.plannerOperators />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="lockIndirects" output="false" hint="Lock indirect planners for a given direct planner">
		<cfargument name="parent_planner_id" required="true" type="numeric">

		<cfset local.success = false>
		<cftransaction>
			<!--- count number of locked indirect planners belong to the given direct planner --->
			<cfquery name="local.qLocked" datasource="#application.datasource#">
				SELECT COUNT(1) AS Count
				  FROM Planners ip
	             INNER JOIN Lock
	                ON Main_Id           = 'Planner'
	               AND Secondary_ID      = ip.Planner_ID
	               AND Locked_By_User_Id > ''
	               AND Locked_By_User_Id <> <cfqueryparam value="#request.AccessStructure.user_id#">
				 WHERE parent_planner_id = <cfqueryparam value="#arguments.parent_planner_id#">
				   AND Deleted = 0
			</cfquery>

			<!--- continue when there is no locked indirect planner --->
			<cfif local.qLocked.count eq 0>
				<cfquery name="local.qIndirect" datasource="#application.datasource#">
					SELECT Planner_ID
					  FROM Planners
					 WHERE parent_planner_id = <cfqueryparam value="#arguments.parent_planner_id#">
					   AND Deleted = 0
				</cfquery>

				<cfset local.success_locks = 0>
				<cfset local.lock_obj      = createObject("component", "components.general.lock")>

				<!--- lock all indirect planners belong to the given direct planner --->
				<cfloop query="local.qIndirect">
					<!--- pass false as 3rd parameter to allow multiple locks, the default allows only one locked planner per user --->
					<cfif local.lock_obj.lock("Planner", local.qIndirect.Planner_ID, false)>
						<cfset local.success_locks++>
					</cfif>
				</cfloop>

				<cfset local.success = ( local.success_locks eq local.qIndirect.recordCount )>
			</cfif>

			<cfif local.success>
				<cftransaction action = "commit"/>
			<cfelse>
				<cftransaction action = "rollback"/>
			</cfif>
		</cftransaction>

		<cfreturn local.success>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="unLockIndirects" output="false" hint="Unlock indirect planners for a given direct planner" access="remote">
		<cfargument name="parent_planner_id" required="true" type="numeric">
		<cfargument name="user_id" required="true">

		<cfset local.success = false>
		<cftransaction>
			<!--- count number of locked indirect planners belong to the given direct planner --->
			<cfquery name="local.qLocked" datasource="#application.datasource#">
				SELECT COUNT(1) AS Count
				  FROM Planners ip
	             INNER JOIN Lock
	                ON Main_Id           = 'Planner'
	               AND Secondary_ID      = ip.Planner_ID
	               AND Locked_By_User_Id > ''
				 WHERE parent_planner_id = <cfqueryparam value="#arguments.parent_planner_id#">
				   AND Deleted = 0
			</cfquery>

			<cfif local.qLocked.count eq 0>
				<cfset local.success = true>
			<cfelse>
				<!--- get all locked indirect planners by a given user --->
				<cfquery name="local.qIndirect" datasource="#application.datasource#">
					SELECT Planner_ID
					  FROM Planners ip
		             INNER JOIN Lock
		                ON Main_Id           = 'Planner'
		               AND Secondary_ID      = ip.Planner_ID
		               AND Locked_By_User_Id = <cfqueryparam value="#arguments.user_id#">
					 WHERE parent_planner_id = <cfqueryparam value="#arguments.parent_planner_id#">
					   AND Deleted = 0
				</cfquery>

				<cfset local.unlocks  = 0>
				<cfset local.lock_obj = createObject("component", "components.general.lock")>

				<!--- unlock all indirect planners belong to the given direct planner --->
				<cfoutput query="local.qIndirect">
					<cfif local.lock_obj.unLockByID("Planner", local.qIndirect.Planner_ID)>
						<cfset local.unlocks++>
					</cfif>
				</cfoutput>

				<cfset local.success = ( local.unlocks eq local.qIndirect.recordCount )>
			</cfif>
		</cftransaction>

		<cfreturn local.success>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getCustomers" output="false" hint="Return customer group and customers in a planner">
		<cfargument name="plannerID" required="true">
		<cfargument name="is_group" required="false" default="0">
		<cfset display_shr_ship_to = application.util.query.get_Setting('Display_Distributor_ID', 0)>

		<cfif arguments.is_group>
			<cfquery name="local.getCustomers" datasource="#application.datasource#">
				SELECT  g.Group_GUID AS ID
					,g.Group_Number  AS Number
					,g.Group_Desc    AS Description
				FROM  Planners                          p
					INNER JOIN All_Customer_Group_Types g
						ON g.Group_GUID = p.Customer_ID
				WHERE p.Planner_ID = <cfqueryparam value="#arguments.plannerID#">
						AND  IsNull ( p.Distributor_Group_Level_ID, 0 ) NOT IN ( 0, -1, -2 )

				UNION

				SELECT  g.Group_GUID AS ID
					,g.Group_Number  AS Number
					,g.Group_Desc    AS Description
				FROM  Planners                          p
					INNER JOIN Planner_Customer_Groups  pg
						ON pg.Planner_ID = p.Planner_ID
					INNER JOIN All_Customer_Group_Types g
						ON g.Group_GUID  = pg.Distributor_Group_ID
				WHERE  p.Planner_ID                 = <cfqueryparam value="#arguments.plannerID#">
				AND  p.Distributor_Group_Level_ID = -2

				ORDER BY g.Group_Number
			</cfquery>
		<cfelse>
			<cfquery name="local.getCustomers" datasource="#application.datasource#">
				SELECT c.Shr_Ship_To AS Number,
					c.Name AS Description,
					c.BSA_Foodservice_Customers_ID AS ID
				FROM Planners p
				INNER JOIN BSA_Foodservice_Customers c
					ON c.BSA_Foodservice_Customers_ID = p.Customer_ID
				WHERE p.Planner_ID                            = <cfqueryparam value="#arguments.plannerID#">
				AND ISNULL(p.Distributor_Group_Level_ID, 0) = 0

				UNION

				SELECT <cfif display_shr_ship_to eq '1'> c.Shr_Ship_To <cfelse> c.ship_to </cfif> AS Number,
					c.Name  AS Description,
					c.BSA_Foodservice_Customers_ID AS ID
				FROM Planner_Customer_Group_Members p
				INNER JOIN BSA_Foodservice_Customers c
					ON c.BSA_Foodservice_Customers_ID = p.Distributor_ID
				WHERE p.Planner_ID = <cfqueryparam value="#arguments.plannerID#">

				ORDER BY c.Name
			</cfquery>
		</cfif>

		<cfreturn local.getCustomers>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getMSAOperators" output="false" hint="Return operators in a MSA planner">
		<cfargument name="plannerID" required="true">

		<cfquery name="local.qOperators" datasource="#application.datasource#">
			SELECT bo.Legacy_ID,
			       bo.Operator_Name,
                   bo.bsa_operator_id
			  FROM Planners p
                    INNER JOIN Planner_Operators po
                        ON po.Planner_ID = #arguments.plannerID# AND po.Deleted = 0
			        INNER JOIN BSA_Operator bo
			            ON bo.BSA_Operator_ID = po.BSA_Operator_ID
			 WHERE p.Planner_ID = <cfqueryparam value="#arguments.plannerID#">
                    ORDER BY bo.Operator_Name
		</cfquery>

		<cfreturn local.qOperators>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="tmp_color_for_volume_plan" returnType="String" hint="Create a temp table with all colors for volume plan.">
		<cfargument name="plannerID" required="true" type="numeric">
		<cfargument name="productGroupLevelId" required="true" type="string">
		<cfargument name="period" required="true" type="string">

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Color_Per_Week') IS NOT NULL
				DROP TABLE ##Color_Per_Week

			IF OBJECT_ID('tempdb..##Color_Planner_Details') IS NOT NULL
				DROP TABLE ##Color_Planner_Details

			IF OBJECT_ID('tempdb..##Color_Planner_Products') IS NOT NULL
				DROP TABLE ##Color_Planner_Products

			IF OBJECT_ID('tempdb..##Color_Planner_Groups') IS NOT NULL
				DROP TABLE ##Color_Planner_Groups

		</cfquery>


		<cfquery name="local.create" datasource="#application.datasource#">
			declare	@Product_Group_Attribute_Master_ID_Field varchar(255)

			<cfif arguments.productGroupLevelId eq "" or arguments.productGroupLevelId eq "0" or arguments.productGroupLevelId eq "9">
				select	@Product_Group_Attribute_Master_ID_Field = 'BSA_Foodservice_Items_Master_ID'
			<cfelse>
				select	@Product_Group_Attribute_Master_ID_Field = a.Product_Group_Attribute_Master_ID_Field
				from	Product_Group_Attribute a
				where	Product_Group_Level_ID = #arguments.productGroupLevelId# <!--- Do not use cfqueryparam --->
			</cfif>

			/* Get planner programs */
			SELECT	cm.Contract_Main_ID,
					Contract_Start_Date, Contract_End_Date,
					CAST ('' AS INT) Program_Week_Start_ID, CAST ('' AS INT) Program_Week_End_ID,
					CM.Planner_Perf_Type_ID, PPT.Description AS Perf_Desc, PPT.Sort_Order AS Perf_Sort_Order, PPT.Color AS Perf_Color
			INTO	##Color_Planner_Details
			FROM	Planners P
			INNER JOIN	Contract_Main CM	ON	CM.Planner_ID = P.Planner_ID  AND	CM.Deleted = 0 AND Cm.Manual_Cancel = 0
			LEFT JOIN	Planner_Perf_Types PPT	ON PPT.Planner_Perf_Types_ID = CM.Planner_Perf_Type_ID AND PPT.Deleted = 0
			INNER JOIN Program_Control_Panel_Options t ON t.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			WHERE	P.Deleted = 0
			AND		P.Planner_ID = #arguments.plannerID#  <!--- Do not use cfqueryparam --->
			AND		ISNULL(PPT.Accrual, 0) = 0 /*  Performance types flagged as "Accrual" should not be available */

			UPDATE	##Color_Planner_Details
			SET		Program_Week_Start_ID = Planner_Week_ID
			FROM	Planner_Week
			WHERE	##Color_Planner_Details.Contract_Start_Date BETWEEN Planner_Week_Start_Date AND Planner_Week_End_Date

			UPDATE	##Color_Planner_Details
			SET		Program_Week_End_ID = Planner_Week_ID
			FROM	Planner_Week
			WHERE	##Color_Planner_Details.Contract_End_Date BETWEEN Planner_Week_Start_Date AND Planner_Week_End_Date

			/* Get planner program products */
			SELECT	DISTINCT P.*, /* CP.Contract_Products_ID, */
					CP.BSA_Foodservice_Items_Master_ID,
					CAST(null as uniqueidentifier) as Item_key
			INTO	##Color_Planner_Products
			FROM	##Color_Planner_Details P
			INNER JOIN	Contract_Products CP
			ON		CP.Contract_Main_ID = P.Contract_Main_ID AND CP.Deleted = 0
			WHERE	CP.Is_Group = 0
			AND		CP.Deleted = 0

			/* Get product group desc (based on configuration) per product */
			EXEC('
			UPDATE	t
			SET		Item_key = i.' + @Product_Group_Attribute_Master_ID_Field + '
			FROM	##Color_Planner_Products t
			INNER JOIN BSA_Foodservice_Items_Master i
			ON		i.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID')

			/* Get planner program group summary */
			select	DISTINCT Item_key,
					Contract_Main_ID, Program_Week_Start_ID, Program_Week_End_ID,
					Perf_Sort_Order, Perf_Color
			into	##Color_Planner_Groups
			from	##Color_Planner_Products
			WHERE	Item_key IS NOT NULL

			/* Combine program groups and weeks */
			select	r.*,
					<cfif arguments.period eq constants.by_week> <!--- By Week --->
						pw.Planner_Week_ID as Period_ID,
						pw.Planner_Week_ID as Period_Order,
						ROW_NUMBER() OVER (PARTITION BY pw.Planner_Week_ID, r.Item_key ORDER BY Perf_Sort_Order) as RowNum
					<cfelse><!--- By month --->
						REPLACE(RIGHT(CONVERT(VARCHAR, pw.Planner_Week_Start_Date, 106), 8), ' ', '_') as Period_ID,
						CONVERT(VARCHAR(7), pw.Planner_Week_Start_Date, 126) as Period_Order,
						ROW_NUMBER() OVER (PARTITION BY REPLACE(RIGHT(CONVERT(VARCHAR, pw.Planner_Week_Start_Date, 106), 8), ' ', '_'), r.Item_key ORDER BY Perf_Sort_Order) as RowNum
					</cfif>
			into	##Color_Per_Week
			from	##Color_Planner_Groups r
			inner join Planner_Week pw
			on		pw.Planner_Week_ID between r.Program_Week_Start_ID and r.Program_Week_End_ID

			/* We only need one record per group/week */
	 		Delete	##Color_Per_Week where	RowNum != 1

			select @Product_Group_Attribute_Master_ID_Field as Product_Group_Attribute_Master_ID_Field

		</cfquery>

		<cfreturn local.create.Product_Group_Attribute_Master_ID_Field />

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="deletePlannerProducts" output="false" hint="Delete products in planner">
		<cfargument name="form" required="true" hint="The submitted form.">

		<cfscript>
			local.qPeriods = getPlannerWeeks( form.plannerID );
			tmp_planner_distributors( form.plannerID );
			local.isGroup = 0;
			local.Product_Group_Attribute_Master_ID_Field = "BSA_Foodservice_Items_Master_ID";
			if(arguments.form.Product_Group_Level_ID neq "" and arguments.form.Product_Group_Level_ID neq "0" and arguments.form.Product_Group_Level_ID neq "9"){
				local.isGroup = 1;
				local.gGetAttr = getProdAttrData(arguments.form.Product_Group_Level_ID);
				local.Product_Group_Attribute_Master_ID_Field = local.gGetAttr.Product_Group_Attribute_Master_ID_Field;
			}
		</cfscript>

		<cfquery name="local.qGetPlanner" datasource="#application.datasource#">
			SELECT 	PT.Business_Segment_ID
			FROM 	Planners P
			INNER JOIN Planner_Template PT
			ON 		PT.Planner_Template_ID = P.Planner_Template_ID
			WHERE 	Planner_ID = <cfqueryparam value="#form.plannerID#">
		</cfquery>

		<cfset local.filterSegment = getSegmentFilter() />
		<cfset local.plannerSegment = Val(local.qGetPlanner.Business_Segment_ID) />

        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('tempdb..##delete_planner_products') IS NOT NULL
                DROP TABLE ##delete_planner_products
        </cfquery>

		<cfquery datasource="#application.datasource#">
			SELECT 	Planner_Volume_Plan.Planner_volume_plan_id
				   ,Planner_Volume_Plan.Bsa_foodservice_customers_id
				   ,Planner_Volume_Plan.Bsa_foodservice_items_master_id
				   ,Planner_Volume_Plan.Planner_week_id
				   ,Planner_Volume_Plan.Business_Segment_ID
				   ,Planner_Volume_Plan.BSA_Operator_ID
              INTO ##delete_planner_products
			  FROM Planner_Volume_Plan
			<cfif local.isGroup eq 1>
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan.BSA_Foodservice_Items_Master_ID
			</cfif>
			 WHERE Planner_Volume_Plan.Bsa_foodservice_customers_id IN (SELECT BSA_Foodservice_Customers_ID FROM ##tmp_planner_distributors)
			<cfif local.isGroup eq 1>
			   AND BSA_Foodservice_Items_Master.#local.Product_Group_Attribute_Master_ID_Field# IN (<cfqueryparam value="#form.product_list#" list="true">)
			<cfelse>
			   AND Planner_Volume_Plan.Bsa_foodservice_items_master_id IN (<cfqueryparam value="#form.product_list#" list="true">)
			</cfif>
			   AND Planner_Volume_Plan.Planner_week_id IN (<cfqueryparam value="#valueList(local.qPeriods.Period_ID)#" list="true" cfsqltype="cf_sql_integer">)
			<cfif this.udf.is_planner_indirect_category( form.plannerID )>
				AND EXISTS (SELECT 1 FROM ##tmp_planner_operators o WHERE o.BSA_Operator_ID = Planner_Volume_Plan.BSA_Operator_ID)
			<cfelse>
				AND ISNULL(Planner_Volume_Plan.BSA_Operator_ID, 0) = 0
			</cfif>
			<cfif local.filterSegment>
				AND Planner_Volume_Plan.Business_Segment_ID = <cfqueryparam value="#local.plannerSegment#" cfsqltype="cf_sql_integer">
			</cfif>

					DELETE Planner_Volume_Plan
            WHERE planner_volume_plan_id IN (SELECT Planner_volume_plan_id FROM ##delete_planner_products)

					INSERT INTO Planner_Volume_Plan_Deleted_Records
							(
								Bsa_foodservice_customers_id,
								Bsa_foodservice_items_master_id,
								Planner_week_id,
								Business_Segment_ID,
								BSA_Operator_ID
							)
                SELECT Bsa_foodservice_customers_id, Bsa_foodservice_items_master_id, Planner_week_id, Business_Segment_ID, BSA_Operator_ID
                    FROM ##delete_planner_products
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerRFAPrograms" hint="get list of programs that are in RFA status for a given planner" returntype="query">
		<cfargument name="plannerId" type="numeric" required="true">
		<cfargument name="columnList" type="string" required="false">

		<cfscript>
			if ( structKeyExists(arguments, "columnList") is false ) {
				arguments.columnList = arrayToList([ "Contract_Main.Contract_Main_ID",
													 "Contract_Number",
													 "Contract_Title",
													 "convert(varchar(12), contract_start_date, 107) as Contract_Start_Date",
													 "convert(varchar(12), contract_end_date, 107) as Contract_End_Date"
													]);
			}
		</cfscript>

		<cfquery name="local.getPlannerRFAPrograms" datasource="#application.datasource#">
			DECLARE @Alert_RFA_Programs_Days INT;
			SELECT	@Alert_RFA_Programs_Days = ISNULL(Alert_RFA_Programs_Days, 0)
			  FROM Planner_Template
			    INNER JOIN dbo.Planners
			        ON Planners.Planner_Template_ID = Planner_Template.Planner_Template_ID
			           AND Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			SELECT	#arguments.columnList#
			FROM 	Contract_Main
			WHERE 	Contract_Main.Contract_Status_Type_IDX = 2
			AND		Contract_Main.Deleted = 0
			AND		(ISNULL(Contract_Main.Planner_ID, 0) <> 0)
			AND		Contract_Main.Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			AND     DATEDIFF(day, GETDATE(), Contract_Start_Date) <= @Alert_RFA_Programs_Days
		</cfquery>

		<cfreturn local.getPlannerRFAPrograms />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerPendingAcceptPrograms" hint="get list of programs that are in Pending Accept status for a given planner" returntype="query">
		<cfargument name="plannerId" type="numeric" required="true">
		<cfargument name="columnList" type="string" required="false">

		<cfscript>
			if ( structKeyExists(arguments, "columnList") is false ) {
				arguments.columnList = arrayToList([ "Contract_Main.Contract_Main_ID",
													 "Contract_Number",
													 "Contract_Title",
													 "convert(varchar(12), contract_start_date, 107) as Contract_Start_Date",
													 "convert(varchar(12), contract_end_date, 107) as Contract_End_Date"
													]);
			}
		</cfscript>

		<cfquery name="local.getPlannerPendingAcceptPrograms" datasource="#application.datasource#">
			DECLARE @Alert_Pending_Accept_Programs_Days INT;
			SELECT	@Alert_Pending_Accept_Programs_Days = ISNULL(Alert_Pending_Accept_Programs_Days, 0)
			  FROM Planner_Template
			    INNER JOIN dbo.Planners
			        ON Planners.Planner_Template_ID = Planner_Template.Planner_Template_ID
			           AND Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			SELECT	#arguments.columnList#
			FROM    Contract_Main
					INNER JOIN	Contract_Main_Aux_Data
					ON  Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE	Contract_Main.Deleted = 0
			AND		Contract_Main_Aux_Data.Pending_Status_Email_Sent = 0
			AND		Contract_Main.Contract_Status_Type_IDX = 10
			AND		(ISNULL(Contract_Main.Planner_ID, 0) <> 0)
			AND		Contract_Main.Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			AND     DATEDIFF(day, GETDATE(), Contract_Start_Date) <= @Alert_Pending_Accept_Programs_Days
		</cfquery>

		<cfreturn local.getPlannerPendingAcceptPrograms />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="saveVolumePlanUOM" access="remote">
		<cfargument name="plannerId" required="true">
		<cfargument name="uom" required="true">

		<cfquery name="local.saveVolumePlanUOM" datasource="#application.datasource#">
			UPDATE Planners
			   SET Volume_Plan_UOM = <cfqueryparam value="#(trim(arguments.uom) is "C" ? 1 : 2)#">
			 WHERE Planner_ID = <cfqueryparam value="#arguments.plannerId#">
		</cfquery>
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerProgramComponents" output="false" hint="Returns Operators for Indirect Planners">
		<cfargument name="plannerId" type="numeric" required="true">

		<!--- Delete the temp tables in a separate query. --->
		<cfquery name="qDelTempTables" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##PlnrPrgCompInfo') IS NOT NULL
			DROP TABLE  ##PlnrPrgCompInfo
		</cfquery>

		<cfquery name="qGetPlannerProgramComponentInfo" datasource="#application.datasource#">
			CREATE TABLE ##PlnrPrgCompInfo
			(
				Planner_ID int,
				Contract_Main_ID int,
				Component_ID int,
				Component_Name nvarchar(50)
			)

			DECLARE @plannerId INT = #arguments.plannerId#
			INSERT INTO ##PlnrPrgCompInfo (Planner_ID, Contract_Main_ID, Component_ID, Component_Name)
			<!--- Rebate --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   prc.Program_Rebates_Component_Name_ID,
				   prcn.Program_Rebates_Component_Name
			FROM     Contract_main cm
					 INNER JOIN Program_Rebates_Component prc
						 ON prc.Program_ID = cm.Contract_Main_ID
							AND prc.Deleted = 0
					 INNER JOIN dbo.Program_Rebates_Component_Name prcn
						 ON prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
							AND prcn.Deleted = 0
			WHERE   cm.Deleted = 0
					AND cm.Planner_ID = @plannerId
			UNION
			<!--- Fixed --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   pfc.Program_Fixed_Component_Name_ID,
				   pfcn.Program_Fixed_Component_Name
			FROM     dbo.Contract_Main cm
					 INNER JOIN Program_Fixed_Component pfc
						 ON pfc.Program_ID = cm.Contract_Main_ID
							AND pfc.Deleted = 0
					 INNER JOIN dbo.Program_Fixed_Component_Name pfcn
						 ON pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
							AND pfcn.Deleted = 0
			WHERE   cm.Deleted = 0
					AND cm.Planner_ID = @plannerId
			UNION
			<!--- Lumpsum --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   pls.Program_Lump_Sum_Name_ID,
				   plsn.Program_Lump_Sum_Name
			FROM     Contract_main cm
					 INNER JOIN dbo.Program_Lump_Sums pls
						 ON pls.Program_ID = cm.Contract_Main_ID
							AND pls.Deleted = 0
					 INNER JOIN dbo.Program_Lump_Sum_Name plsn
						 ON plsn.Program_Lump_Sum_Name_ID = pls.Program_Lump_Sum_Name_ID
							AND plsn.Deleted = 0
			WHERE   cm.Deleted = 0
					AND cm.Planner_ID = @plannerId
			UNION
			<!--- Growth --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   pgc.Program_Growth_Components_Name_Id,
				   pgcn.Program_Growth_Components_Name
			FROM   Contract_main cm
				   INNER JOIN dbo.Program_Growth_Components pgc
					   ON pgc.Program_ID = cm.Contract_Main_ID
						  AND pgc.Deleted = 0
				   INNER JOIN dbo.Program_Growth_Components_Name pgcn
					   ON pgcn.Program_Growth_Components_Name_Id = pgc.Program_Growth_Components_Name_Id
						  AND pgcn.Deleted = 0
			WHERE  cm.Deleted = 0
				   AND cm.Planner_ID = @plannerId
			ORDER BY Contract_Main_ID
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getPlannerProgramClaimMechanics" output="false" hint="Returns Operators for Indirect Planners">
		<cfargument name="plannerId" type="numeric" required="true">

		<!--- Delete the temp tables in a separate query. --->
		<cfquery name="qDelTempTables" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##PrgClaimMechInfo') IS NOT NULL
			DROP TABLE  ##PrgClaimMechInfo
		</cfquery>

		<cfquery name="qGetPlannerProgramClaimMechanics" datasource="#application.datasource#">
			CREATE TABLE ##PrgClaimMechInfo
			(
				Planner_ID        INT,
				Contract_Main_ID  INT,
				Claim_Mechanics   INT,
				Payment_Type_Name NVARCHAR(50)
			)

			DECLARE @plannerId INT = #arguments.plannerId#
			INSERT INTO ##PrgClaimMechInfo (Planner_ID, Contract_Main_ID, Claim_Mechanics, Payment_Type_Name)
			<!--- Rebate --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   prc.Claim_Mechanics,
				   pt_r.Payment_Type_Name
			FROM     Contract_main cm
					 INNER JOIN Program_Rebates_Component prc
						 ON prc.Program_ID = cm.Contract_Main_ID
							AND prc.Deleted = 0
					 INNER JOIN dbo.Payment_Type pt_r
						 ON pt_r.Payment_Type_ID = prc.Claim_Mechanics
							AND pt_r.active = 1
							AND pt_r.Deleted = 0
			WHERE   cm.Deleted = 0
					AND cm.Planner_ID = @plannerId
			UNION
			<!--- Fixed --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   pfc.claim_mechanics,
				   pt_f.Payment_Type_Name
			FROM     dbo.Contract_Main cm
					 INNER JOIN Program_Fixed_Component pfc
						 ON pfc.Program_ID = cm.Contract_Main_ID
							AND pfc.Deleted = 0
					 INNER JOIN dbo.Payment_Type pt_f
						 ON pt_f.Payment_Type_ID = pfc.Claim_Mechanics
							AND pt_f.active = 1
							AND pt_f.Deleted = 0
			WHERE   cm.Deleted = 0
					AND cm.Planner_ID = @plannerId
			UNION
			<!--- Lumpsum --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   pls.Claim_Mechanics,
				   pt_l.Payment_Type_Name
			FROM     Contract_main cm
					 INNER JOIN dbo.Program_Lump_Sums pls
						 ON pls.Program_ID = cm.Contract_Main_ID
							AND pls.Deleted = 0
					 INNER JOIN dbo.Payment_Type pt_l
						 ON pt_l.Payment_Type_ID = pls.Claim_Mechanics
							AND pt_l.active = 1
							AND pt_l.Deleted = 0
			WHERE   cm.Deleted = 0
					AND cm.Planner_ID = @plannerId
			UNION
			<!--- Growth --->
			SELECT @plannerId,
				   cm.Contract_Main_ID,
				   pgc.Claim_Mechanics,
				   pt_g.Payment_Type_Name
			FROM   Contract_main cm
				   INNER JOIN dbo.Program_Growth_Components pgc
					   ON pgc.Program_ID = cm.Contract_Main_ID
				   INNER JOIN dbo.Payment_Type pt_g
					   ON pt_g.Payment_Type_ID = pgc.Claim_Mechanics
						  AND pt_g.active = 1
						  AND pt_g.Deleted = 0
			WHERE  cm.Deleted = 0
				   AND cm.Planner_ID = @plannerId
			ORDER BY Contract_Main_ID
		</cfquery>

	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<cffunction name="getSegmentFilter" access="public" returntype="numeric" output="false">

		<cfset useLakebaseForlocal_getSegmentSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment_enabled")>
<cfif useLakebaseForlocal_getSegmentSetting>
	<cftry>
		<cfset local.getSegmentSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment_enabled", {
				"select" = "planner_volume_plan_segment_enable"
			}), "planner_volume_plan_segment_enable"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_getSegmentSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_getSegmentSetting>
<cfquery name="local.getSegmentSetting" datasource="#application.datasource#">
			SELECT Planner_Volume_Plan_Segment_Enable FROM Business_Segment_Enabled
		</cfquery>
</cfif>

		<cfreturn Val(local.getSegmentSetting.Planner_Volume_Plan_Segment_Enable) />
	</cffunction>

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

	<!--- ------------------------------------------------------------------------------------------------------------------ --->

    <cffunction name="getTargets" output="false">
        <cfargument name="planner_id" required="true" type="numeric">

        <cfstoredproc procedure="Planner_Target_Sales_Data" datasource="#application.datasource#">
            <cfprocparam cfsqltype="cf_sql_numeric" value="#arguments.planner_id#" type="in">

            <cfprocresult name="local.qSpending" resultset="1">
            <cfprocresult name="local.qSlotting" resultset="2">
        </cfstoredproc>

        <cfquery name="local.qTotals" datasource="#application.datasource#">
            SELECT  '' AS SUB_PRODUCT_GROUP_ID
                    ,'' AS SUB_PRODUCT_GROUP_NUMBER
                    ,'TOTAL' AS SUB_PRODUCT_GROUP_DESC
                    ,0.00 AS TARGET_REVENUE_FINAL
                    ,0.00 AS TARGET_TRADE_FUND_FINAL
                    ,0.00 AS APPROVED_INCREMENTAL_FUNDS
                    ,0.00 AS LE_TRADE_FUND
                    ,0.00 AS SLOTTING_FUND_FINAL
                    ,0.00 AS DEMO_FUND_FINAL
                    ,0.00 AS LE_REVENUE
                    ,0.00 AS LE_TRADE_SPEND
                    ,0.00 AS LE_SPEND_DEMO
                    ,0.00 AS LE_SPEND_SLOTTING
                    ,0.00 AS LE_TRADE_FUND_BALANCE
                    ,0.00 AS LE_SLOTTING_BALANCE
                    ,0.00 AS LE_DEMO_BALANCE
                    ,0.00 AS GAP_TO_TARGET
                    ,0.00 AS TARGET_TRADE_RATE
                    ,0.00 AS LE_TRADE_RATE
        </cfquery>

		<cfreturn [local.qSpending, local.qSlotting, local.qTotals]>
	</cffunction>

	<!--- get a planner accrual summary--->
	<cffunction name="getPlannerAccrualSummaryData" access="public" returntype="query" output="false">
		<cfargument name="plannerId" required="true" type="numeric">

		<cfquery name="local.plannerAccrualSummary" datasource="#application.datasource#">


			DECLARE @Planner_Id int = #arguments.plannerId#

			DECLARE @Planner_Template_ID int,
					@Planner_Start_Date DATE,
					@Planner_End_Date DATE,
					@Planner_Template_Filter bit

			SELECT	@Planner_Template_ID = p.Planner_Template_ID,
					@Planner_Start_Date = pt.Planner_Start_Date,
					@Planner_End_Date = pt.Planner_End_Date
			FROM	Planners p
					INNER JOIN Planner_Template pt
					ON pt.Planner_Template_ID = p.Planner_Template_ID
			WHERE	p.Planner_Id = @Planner_Id

			SELECT	TOP 1 @Planner_Template_Filter = 1
			FROM	dbo.Planner_Template_Filters ptf
			WHERE	ptf.Planner_Template_ID = @Planner_Template_ID
			AND		ptf.Allow_Filter = 1
			AND		ptf.PG_Group_Type = 1

		 /*  Get planner distributors */
			IF OBJECT_ID('tempdb..##tmp_acc_planner_distributors') IS NOT NULL
			DROP TABLE ##tmp_acc_planner_distributors

			CREATE TABLE ##tmp_acc_planner_distributors (Distributor_ID UNIQUEIDENTIFIER)

		 /*  If planner has individual distributor */
			insert into ##tmp_acc_planner_distributors (Distributor_ID)
			select	DISTINCT Customer_ID
			from	Planners p
			where	p.Planner_ID = @Planner_ID
			and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

		 /*  If planner has group distributor */
			INSERT INTO ##tmp_acc_planner_distributors (Distributor_ID)
			SELECT DISTINCT Distributor_ID
			FROM   Planner_Customer_Group_Members p
			WHERE  p.Planner_ID = @Planner_ID

			IF OBJECT_ID('tempdb..##tmp_accrual_programs') IS NOT NULL
			DROP TABLE ##tmp_accrual_programs

			SELECT	gla.Contract_Main_ID, gla.Contract_Number, gla.Total_Program_Spend_For_Planner, cm.Effective_End_Date
			INTO	##tmp_accrual_programs
			FROM	GLA_Planner_Accrual_Programs gla
			INNER JOIN Contract_Main cm
			ON		cm.Contract_Main_ID = gla.Contract_Main_ID
			WHERE	gla.Planner_ID = @Planner_Id

			IF OBJECT_ID('tempdb..##tmp_acc_products') IS NOT NULL
			DROP TABLE ##tmp_acc_products

			SELECT	Product_ID
			INTO	##tmp_acc_products
			FROM	GLA_Planner_Template_Products gla
			WHERE	gla.Planner_Template_ID = @Planner_Template_ID

			IF OBJECT_ID('tempdb..##tmp_accrual_actual') IS NOT NULL
			DROP TABLE ##tmp_accrual_actual

			SELECT	gla.Contract_Number, SUM(gla.Amount) as Amount
			INTO	##tmp_accrual_actual
			FROM	##tmp_accrual_programs p
			INNER JOIN GLA_Combined gla
			ON		gla.Contract_Main_ID = p.Contract_Main_ID
			WHERE	gla.Fiscal_End >= @Planner_Start_Date
			AND		gla.Fiscal_Start <= @Planner_End_Date
			AND		EXISTS (
				SELECT	1
				FROM	##tmp_acc_planner_distributors d
				WHERE	d.Distributor_ID = gla.Distributor_ID
			)
			AND 	(ISNULL(@Planner_Template_Filter,0) = 0 OR EXISTS (SELECT 1 FROM ##tmp_acc_products prod WHERE prod.Product_ID = gla.Product_ID))
			GROUP BY gla.Contract_Number


			SELECT	Sofar_Accrual_Dollar = ISNULL(SUM(ISNULL(act.Amount, 0)), 0),
					Togo_Accrual_Dollar = ISNULL(SUM(
							CASE WHEN p.Max_Effective_End_Date IS NOT NULL AND p.Max_Effective_End_Date > GetDate()
								AND ISNULL(p.Total_Estimate, 0) > ISNULL(act.Amount, 0)
							THEN ISNULL(p.Total_Estimate, 0) - ISNULL(act.Amount, 0)
							ELSE 0 END), 0),
					Total_Accrual_Dollar = ISNULL(SUM(ISNULL(act.Amount, 0)), 0) +
							ISNULL(SUM(
							CASE WHEN p.Max_Effective_End_Date IS NOT NULL AND p.Max_Effective_End_Date > GetDate()
								AND ISNULL(p.Total_Estimate, 0) > ISNULL(act.Amount, 0)
							THEN ISNULL(p.Total_Estimate, 0) - ISNULL(act.Amount, 0)
							ELSE 0 END), 0)
			FROM	(
				SELECT	Contract_Number, SUM(Total_Program_Spend_For_Planner) as Total_Estimate,
						Max(Effective_End_Date) as Max_Effective_End_Date
				FROM	##tmp_accrual_programs
				GROUP BY Contract_Number
			) p
			LEFT JOIN ##tmp_accrual_actual act
			ON		act.Contract_Number = p.Contract_Number

        </cfquery>

		<cfreturn local.plannerAccrualSummary />

	</cffunction>

    <!--- ------------------------------------------------------------------------------------------------------------------ --->

    <cffunction name="updateProgramLockType" output="false">
        <cfargument name="qProgramList" required="true" type="query">

        <cfset programManager = createObject( "component", "components.programs.ProgramManager" ) />

        <cfloop query="arguments.qProgramList">
        	<cfif Action eq "approved">
        		<cfset programManager.setProgramLockType(Contract_Main_ID) />
        	</cfif>
        </cfloop>

    </cffunction>

	<cffunction name="plannerEZRatesExists" output="false">
        <cfargument name="plannerId" type="numeric" required="true">

        <cfset var bExists = 0 />

        <cfquery name="local.qCheckPlannerEZrates" datasource="#application.datasource#">
			SELECT	1
			FROM	Planners p
					INNER JOIN Contract_Main cm
					on cm.Planner_ID = p.Planner_ID
					and cm.Deleted = 0
					INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID and pcpo.EZButton_On = 1
			WHERE	p.Planner_ID = <cfqueryparam value="#arguments.plannerId#">
		</cfquery>

		<cfif local.qCheckPlannerEZrates.RecordCount>
			<cfset bExists = 1 />
		</cfif>

		<cfreturn bExists />

    </cffunction>

	<cffunction name="getProgramsByPlannerId" output="false">
		<cfargument name="plannerId" type="numeric" required="true">

		<cfquery name="qGetProgramData" datasource="#application.datasource#">
			SELECT 	DISTINCT Contract_Main_ID, Contract_Number, Responsible_User_ID,
					CASE WHEN Approved = 1 THEN
						CASE
							WHEN LEN(revision_version) = 4 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 4)
							WHEN LEN(revision_version) = 5 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 5)
							ELSE RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 3)
						END
					ELSE '0'
					END as Version
			FROM	Contract_Main
			WHERE	Planner_ID = <cfqueryparam value="#arguments.plannerId#">
			AND		(Deleted = 0 or Approved = 1)
			ORDER BY 	Contract_Number, Contract_Main_ID
		</cfquery>

		<cfreturn qGetProgramData />

	</cffunction>

	<cffunction name="getPlannerWorkflow" output="false">
		<cfargument name="plannerId" type="numeric" required="true">

		<cfquery name="qGetPlannerWorkflowData" datasource="#application.datasource#">

		 /* Created By Data */
			select	distinct
					p.Planner_Number,
					'Created' as Action,
					u.Name_First + ' ' + u.Name_Last as Name,
					up.Position_Description as User_Position,
					pr.Profiles_Desc as Profile,
					atc.Authority_Sequence_Name as Authority_Sequence,
					p.Created_Date as Action_Date,
					1 as Column_Order
			from	Planners p
					inner join _Users u on u.User_ID = p.Created_By
					inner join User_Position_Holders uph on uph.User_ID = u.User_ID and uph.User_Position_Type = 'P' and uph.Deleted = 0
					inner join User_Positions up on up.User_Positions_ID = uph.User_Positions_ID
					inner join Profiles pr on pr.Profiles_ID = u.Profiles_ID
					inner join Authority_Sequence atc on atc.Authority_Sequence_ID = u.Authority_Sequence_ID
			where	p.Planner_ID = <cfqueryparam value="#arguments.plannerId#">

			union

		 /* RFA By Data */
			select	distinct
					p.Planner_Number,
					'RFA''d' as Action,
					u.Name_First + ' ' + u.Name_Last as Name,
					up.Position_Description as User_Position,
					pr.Profiles_Desc as Profile,
					atc.Authority_Sequence_Name as Authority_Sequence,
					p.RFA_Date as Action_Date,
					1 as Column_Order
			from	Planners p
					inner join _Users u on u.User_ID = p.RFA_By
					inner join User_Position_Holders uph on uph.User_ID = u.User_ID and uph.User_Position_Type = 'P' and uph.Deleted = 0
					inner join User_Positions up on up.User_Positions_ID = uph.User_Positions_ID
					inner join Profiles pr on pr.Profiles_ID = u.Profiles_ID
					inner join Authority_Sequence atc on atc.Authority_Sequence_ID = u.Authority_Sequence_ID
			where	p.Planner_ID = <cfqueryparam value="#arguments.plannerId#">

			union

		 /* Approved By Data */
			select	distinct
					p.Planner_Number,
					'Approved' as Action,
					u.Name_First + ' ' + u.Name_Last as Name,
					up.Position_Description as User_Position,
					pr.Profiles_Desc as Profile,
					ats.Authority_Sequence_Name as Authority_Sequence,
					p.Approved_Date as Action_Date,
					2 as Column_Order
			from	Planners p
					inner join _Users u on u.User_ID = p.Approver_ID
					inner join User_Position_Holders uph on uph.User_ID = u.User_ID and uph.User_Position_Type = 'P' and uph.Deleted = 0
					inner join User_Positions up on up.User_Positions_ID = uph.User_Positions_ID
					inner join Profiles pr on pr.Profiles_ID = u.Profiles_ID
					left join Authority_Sequence ats on ats.Authority_Sequence_ID = u.Authority_Sequence_ID
			where	p.Planner_ID = <cfqueryparam value="#arguments.plannerId#">

			order by Column_Order
		</cfquery>

		<cfreturn qGetPlannerWorkflowData />

	</cffunction>

	<cffunction name="checkTPO" output="false">
		<cfargument name="plannerId" type="numeric" required="true">

		<cfset var bExists = 0 />
		<cfquery name="qCheckForTPO" datasource="#application.datasource#">
			select  1
			from	Planners p
			inner join Contract_Main cm on cm.Planner_ID = p.Planner_ID
			where	exists (select * from LOG_Y_DEAL_Program_Upload where BA_Program_ID = cm.Contract_Number)
			and		p.Planner_ID = <cfqueryparam value="#arguments.plannerId#">
		</cfquery>

		<cfif qCheckForTPO.RecordCount>
			<cfset bExists = 1 />
		</cfif>

		<cfreturn bExists />

	</cffunction>
</cfcomponent>
