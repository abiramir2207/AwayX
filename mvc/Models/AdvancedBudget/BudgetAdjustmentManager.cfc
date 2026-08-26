<cfcomponent alias="mvc.Models.AdvancedBudget.BudgetAdjustmentManager">

	<cffunction name="getPositions" returntype="query" access="public" hint="Will return a query with all budget positions" output="false">
		<cfargument name="budget_ID" type="numeric" required="true"/>

		<cfset var vars = structnew() / >

		<cfquery name="vars.budget" datasource="#application.datasource#">
	    SELECT Budget.Business_Segment_Id
	           , Position_Control_Type
	           , Allocation_Position_Level
	           , Budget_Owner_Position_ID
			  FROM Budget
       WHERE Budget.Budget_Id = <cfqueryparam value="#arguments.budget_Id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!---Allocation Control Point = Position--->
		<cfif vars.budget.Position_Control_Type eq "2">
			<cfquery name="vars.positions" datasource="#application.datasource#">
				SELECT User_Positions_ID
				      ,Position_Label
			       	,position_number = CASE
			                            WHEN up.Service_Market_Id IS NOT NULL THEN SERVICE_MARKETS.Market_Number
			                            WHEN up.Service_Region_Id IS NOT NULL
			                                 AND up.Service_Market_Id IS NULL THEN SERVICE_REGIONS.Region_Number
			                            WHEN up.Service_Zone_Id IS NOT NULL
			                                 AND up.Service_Region_Id IS NULL
			                                 AND up.Service_Market_Id IS NULL THEN SERVICE_ZONES.Zone_Number
			                            ELSE 'HQ'
			                          END
					FROM User_Positions up
				       LEFT JOIN SERVICE_REGIONS ON SERVICE_REGIONS.Service_Region_Id = up.Service_Region_Id
				       LEFT JOIN SERVICE_ZONES ON SERVICE_ZONES.Service_Zone_Id = up.Service_Zone_Id
				       LEFT JOIN SERVICE_MARKETS ON SERVICE_MARKETS.Service_Market_Id = up.Service_Market_Id
				 WHERE User_Positions_ID = #vars.budget.Budget_Owner_Position_ID#
			</cfquery>

		<!---Allocation Control Point = Headquarter--->
		<cfelseif vars.budget.Allocation_Position_level eq "0">
			<cfquery name="vars.positions" datasource="#application.datasource#">
				SELECT User_Positions_ID
				      ,Position_Label
							,Position_Number = 'HQ'
				  FROM User_Positions
				 WHERE Deleted = 0 AND Service_Zone_ID IS NULL
			</cfquery>

		<!---Allocation Control Point = Region/SubRegion/Territory--->
		<cfelseif vars.budget.Allocation_Position_level eq "1"
		       or vars.budget.Allocation_Position_level eq "2"
		       or vars.budget.Allocation_Position_level eq "3">
			<cfquery name="vars.positions" datasource="#application.datasource#">
				SELECT DISTINCT
				       up.User_Positions_ID
				      ,up.Position_Label
							,Position_Number = CASE
                                  WHEN up.Service_Market_Id IS NOT NULL THEN Service_Markets.Market_Number
                                  WHEN up.Service_Region_Id IS NOT NULL
                                       AND up.Service_Market_Id IS NULL THEN Service_Regions.Region_Number
                                  WHEN up.Service_Zone_Id IS NOT NULL
                                       AND up.Service_Region_Id IS NULL
                                       AND up.Service_Market_Id IS NULL THEN Service_Zones.Zone_Number
                                  ELSE 'HQ'
                                END
				  FROM (
				       -- get list of distributors selected in the budget
				       SELECT Distributor_Group_Id AS bsa_foodservice_customers_id
				         FROM BUDGET_DISTRIBUTOR
				        WHERE Budget_Id = <cfqueryparam value="#arguments.budget_Id#" cfsqltype="cf_sql_integer">
				              AND Distributor_Group_Level_Id = 0
				              AND Deleted = 0
				         UNION
				         -- get list of distributor members for planning groups selected in the budget
				         SELECT ALL_CUSTOMER_GROUP_TYPE_MEMBERS.bsa_FoodService_Customers_Id
				           FROM BUDGET_DISTRIBUTOR
				                INNER JOIN ALL_CUSTOMER_GROUP_TYPE_MEMBERS ON ALL_CUSTOMER_GROUP_TYPE_MEMBERS.Distributor_Group_Level_Id = BUDGET_DISTRIBUTOR.Distributor_Group_Level_Id
				                                                              AND ALL_CUSTOMER_GROUP_TYPE_MEMBERS.Distributor_Group_Id = BUDGET_DISTRIBUTOR.Distributor_Group_Id
				          WHERE BUDGET_DISTRIBUTOR.Budget_Id = <cfqueryparam value="#arguments.budget_Id#" cfsqltype="cf_sql_integer">
				                AND BUDGET_DISTRIBUTOR.Distributor_Group_Level_Id != 0
				                AND BUDGET_DISTRIBUTOR.Deleted = 0
				          GROUP BY ALL_CUSTOMER_GROUP_TYPE_MEMBERS.bsa_FoodService_Customers_Id
				       ) AS budget_distributors

		       INNER JOIN BUDGET b ON b.Budget_Id = <cfqueryparam value="#arguments.budget_Id#" cfsqltype="cf_sql_integer">

		       <cfif application.appSettingsGet.getDistributorMultiPosition() eq "1">
			       INNER JOIN MARKET_DISTRIBUTOR ON MARKET_DISTRIBUTOR.Distributor_Id = budget_distributors.bsa_FoodService_Customers_Id
			                                        AND MARKET_DISTRIBUTOR.Deleted = 0
			       INNER JOIN SERVICE_MARKETS ON SERVICE_MARKETS.Service_Market_Id = MARKET_DISTRIBUTOR.Service_Market_Id
															    			<cfif application.appSettingsGet.getPositionFieldsFilterOnProgramSegment() eq "1">
																						AND SERVICE_MARKETS.Business_Segment_Id = b.Business_Segment_Id -- filter on budget segment
																				</cfif>
		       <cfelse>
			       INNER JOIN BSA_Foodservice_Customers c ON c.BSA_Foodservice_Customers_ID = Budget_Distributors.bsa_foodservice_customers_id
			       INNER JOIN BSA_Foodservice_Brokers br ON br.BSA_Foodservice_Brokers_ID = c.BSA_Foodservice_Brokers_ID
			       INNER JOIN Service_Markets ON Service_Markets.Service_Market_ID = b.Service_Market_ID
															    			<cfif application.appSettingsGet.getPositionFieldsFilterOnProgramSegment() eq "1">
																						AND SERVICE_MARKETS.Business_Segment_Id = b.Business_Segment_Id -- filter on budget segment
																				</cfif>
		       </cfif>

		       INNER JOIN SERVICE_REGIONS ON SERVICE_REGIONS.Service_Region_Id = SERVICE_MARKETS.Service_Region_Id
		       INNER JOIN SERVICE_ZONES ON SERVICE_ZONES.Service_Zone_Id = SERVICE_REGIONS.Service_Zone_Id
		       INNER JOIN USER_POSITIONS up

				   <cfif vars.budget.Allocation_Position_Level eq "1">
				       ON up.Service_Zone_ID = Service_Zones.Service_Zone_ID AND up.Service_Region_ID is null
				   <cfelseif vars.budget.Allocation_Position_Level eq "2">
				       ON up.Service_Region_ID = Service_Regions.Service_Region_ID AND up.Service_Market_ID is null
				   <cfelseif vars.budget.Allocation_Position_Level eq "3">
				       ON up.Service_Market_Id = SERVICE_MARKETS.Service_Market_Id
				   </cfif>
			</cfquery>

		<!---we should never get to this logic!--->
		<cfelse>
			<cfquery name="vars.positions" datasource="#application.datasource#">
				SELECT User_Positions_ID
				      ,Position_Label
							,Position_Number = ''
				  FROM User_Positions
				 WHERE 1 = 2
			</cfquery>
		</cfif>

		<cfreturn vars.positions />
	</cffunction>

	<cffunction name="getDistributors" returntype="query" access="public" hint="Will return a query with all budget distributors" output="false">
		<cfargument name="budget_ID" type="numeric" required="true"/>

		<cfset var vars = structnew() / >

		<cfquery name="vars.distributors" datasource="#application.datasource#">
			SELECT Name
			       ,Family_Name
			       ,bsa_FoodService_Customers_Id
			       ,Address_1
			       ,City
			       ,State
			       ,ZipCode
			       ,shr_Ship_To
			  FROM BSA_FOODSERVICE_CUSTOMERS cust
				<!---do these small queries for better performance--->
			  <cfif application.appSettingsGet.getDistributorMultiPosition() eq "1"
			    and application.appSettingsGet.getPositionFieldsFilterOnProgramSegment() eq "1">
						INNER JOIN Market_Distributor market ON market.distributor_id = cust.bsa_foodservice_customers_id
                                                AND market.deleted = 0
            INNER JOIN Service_Markets sm ON sm.Service_Market_ID = market.Service_Market_ID
																				 AND sm.Business_Segment_ID = ( SELECT Business_Segment_Id
                                                                          FROM BUDGET
                                                                         WHERE BUDGET.Budget_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budget_ID#" />)
			  </cfif>
			 WHERE cust.bsa_FoodService_Customers_Id IN ( SELECT mem.bsa_FoodService_Customers_Id
																										  FROM BUDGET_DISTRIBUTOR
																										       INNER JOIN ALL_CUSTOMER_GROUP_TYPE_MEMBERS mem ON mem.Distributor_Group_Level_Id = BUDGET_DISTRIBUTOR.Distributor_Group_Level_Id
																										                                                     AND mem.Distributor_Group_Id = BUDGET_DISTRIBUTOR.Distributor_Group_Id
																										 WHERE BUDGET_DISTRIBUTOR.Budget_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budget_ID#" />
																										       AND BUDGET_DISTRIBUTOR.Distributor_Group_Level_Id != 0
																										       AND BUDGET_DISTRIBUTOR.Deleted = 0
			                                              UNION
			                                              SELECT Distributor_Group_Id
			                                                FROM BUDGET_DISTRIBUTOR
			                                               WHERE Budget_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.budget_ID#" />
			                                                     AND Distributor_Group_Level_Id = 0
			                                                     AND Deleted = 0 )
			       AND cust.Deleted = 0
			       AND cust.Active_Code = 'A'
		</cfquery>

		<cfreturn vars.distributors />
	</cffunction>

	<cffunction name="getBudgetAdjustmentTypes" returntype="query" access="public" hint="Will return a query with all adjustment types" output="false">
		<cfargument name="AdjustmentTypeId" type="numeric" required="false" default="0" />
		<cfargument name="Active" type="numeric" required="false"/>

		<cfset var vars = structnew() / >

		<cfquery name="vars.adjustmentTypes" datasource="#application.datasource#">
			SELECT Budget_Adjustment_Type_Id
			       ,Code
			       ,Description
			       ,Active
			       ,Created_Date
			       ,Deleted
			       ,Is_In_Use = ISNULL( (SELECT TOP(1) 1
			                               FROM Budget_Adjustment b
			                              WHERE b.Budget_Adjustment_Type_ID = Budget_Adjustment_Type.Budget_Adjustment_Type_ID), 0 )
			  FROM Budget_Adjustment_Type
			 WHERE Budget_Adjustment_Type.Deleted = 0
						<cfif arguments.AdjustmentTypeId neq "0">
							AND Budget_Adjustment_Type_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AdjustmentTypeId#" />
						</cfif>
						<cfif structkeyexists(arguments, "active")>
							AND Budget_Adjustment_Type.Active = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.active#" />
						</cfif>
		</cfquery>

		<cfreturn vars.adjustmentTypes />
	</cffunction>

	<cffunction name="saveBudgetAdjustmentType" returntype="void" access="public" hint="Will save the Budget adjustment type into the database" output="true">
		<cfset var vars = structnew()>

		<cfparam name="form.active" default="0">
		<!--- If record is in database, then update it --->
		<cfquery name="vars.Update_Record" datasource="#application.datasource#" result="vars.Update_Record_Results">
			UPDATE Budget_Adjustment_Type
			   SET  Code = <cfqueryparam value="#form.code#" cfsqltype="cf_sql_varchar">
			       ,Description = <cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">
			       ,Active = <cfqueryparam value="#form.active#" cfsqltype="cf_sql_bit">
			 WHERE Budget_Adjustment_Type_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Budget_Adjustment_Type_Id#" />
		</cfquery>

		<!--- If record isn't in database, insert it --->
		<cfif vars.Update_Record_Results.recordcount eq 0>
			<cfquery name="vars.insert_record" datasource="#application.datasource#">
				INSERT Budget_Adjustment_Type
				       (Code, Description, Active)
				VALUES ( <cfqueryparam value="#form.code#" cfsqltype="cf_sql_varchar">
				        ,<cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">
				        ,<cfqueryparam value="#form.active#" cfsqltype="cf_sql_bit"> )
			</cfquery>
		</cfif>
	</cffunction>

</cfcomponent>