<cfcomponent hint="This class is only used for database access. It holds all the queries for Customer Groups">

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>


	<cffunction name="getCustomerGroups" output="false" returntype="query">

		<cfargument name="lGroup" required="false" default="" />
		<cfargument name="bAllDistAndGroup" required="false" default="" />
		<cfargument name="searchFilter" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="checkLGroup" required="false" default="0" />
		<cfargument name="qGetTopLevelGroups" type="query" required="false" default="#QueryNew("")#" />
		<cfargument name="searchFilterRequired" type="numeric" required="false" default="0" />
		<cfargument name="groupCombinationOn" type="numeric" required="false" default="0" />
		<cfargument name="groupCombinationDefinitionHeaderID" type="numeric" required="false" default="0" />
		<cfargument name="Distributor_Name" type="string" required="false" default="" />
		<cfargument name="businessSegmentId" required="false" type="numeric" default="0" />
		<cfargument name="Program_ID" required="false" type="numeric" default="0" />
		<cfargument name="FirstParentID" required="false" type="numeric" default="0" />
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		<cfargument name="showDistExceptions" type="numeric" required="false" default="0" />
		<cfargument name="plannerID" type="numeric" required="false" default="0" />		
		
		<cfset var filter = structnew()>

		<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
		<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "">
			<cfset DistributorGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = FORM.Top_Level) />	
		</cfif>	
		<cfif arguments.groupCombinationOn EQ 1>
			<cfset qGetTopLevelGroups = getDistributorLevels(1, "", "") />

			<CFQUERY NAME="qGetCustomerGroups" datasource="#application.datasource#">

				SELECT	DISTINCT Customer_Group_Combination.Customer_Group_Combination_ID BSA_Foodservice_Customers_ID,
						Customer_Group_Combination.Group_Combination_Desc Name,
						'' Address_1,
						'' City,
						'' State,
						'' country_code,
						'' ZipCode,
						'' Family_Name,
						'' Ship_To,
						'A' Active_Code,
						<cfif NOT appSettings.getDistributorMultiPosition()>
						'' Broker_Name,
						'' Zone_Name,
						'' Region_Name,
						</cfif>
						'' Buying_Group_Name,
						'' Shr_Ship_To,
						Distributor_Group_Level_ID,
						'' WHSE
				FROM	Customer_Group_Combination

				INNER JOIN Customer_Group_Combination_Definition_Header
				ON		Customer_Group_Combination_Definition_Header.Customer_Group_Combination_Definition_Header_ID = Customer_Group_Combination.Customer_Group_Combination_Definition_Header_ID

				WHERE	Customer_Group_Combination.Customer_Group_Combination_Definition_Header_ID = <cfqueryparam value="#arguments.groupCombinationDefinitionHeaderID#" cfsqltype="CF_SQL_INTEGER">
				AND		Customer_Group_Combination.Deleted = 0

				<cfloop query="qGetTopLevelGroups">
					<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
					<!--- removed hard coded DropDownName in select_distributors.cfm
					<cfif Distributor_Group_Level_Type_ID EQ 2>
						<cfset DistributorAttributeDropDownName = "Family_Name" />
					<cfelseif Distributor_Group_Level_Type_ID EQ 3>
						<cfset DistributorAttributeDropDownName = "Buying_Group" />
					<cfelseif Distributor_Group_Level_Type_ID EQ 4>
						<cfset DistributorAttributeDropDownName = "Line_Of_Biz" />
					<cfelseif Distributor_Group_Level_Type_ID EQ 5>
						<cfset DistributorAttributeDropDownName = "Cust_Id" />
					</cfif>
					--->
					<cfif isDefined("arguments.searchFilter.#DistributorAttributeDropDownName#")>
						<cfset searchVal = Evaluate("arguments.searchFilter.#DistributorAttributeDropDownName#") />
						<cfif searchVal NEQ "0" AND searchVal NEQ "">
						AND	Customer_Group_Combination.Customer_Group_Combination_ID IN
						(
						SELECT 	DISTINCT Customer_Group_Combination.Customer_Group_Combination_ID
						FROM	Customer_Group_Combination
						INNER	JOIN Customer_Group_Combination_Detail
						ON		Customer_Group_Combination.Customer_Group_Combination_ID = Customer_Group_Combination_Detail.Customer_Group_Combination_ID
						WHERE	Customer_Group_Combination.Deleted = 0
						AND		Customer_Group_Combination.Level_ID = #arguments.groupCombinationDefinitionHeaderID#
						AND		Customer_Group_Combination_Detail.Member_Group_Level_ID = #Distributor_Group_Level_ID#
						AND 	Customer_Group_Combination_Detail.Member_Group_ID = '#searchVal#'
						)
						</cfif>
					</cfif>
				</cfloop>

					<!--- Search on First Letter of the Group_Combination_Desc --->
					<cfif arguments.Distributor_Name neq "">
					AND
						(
						Customer_Group_Combination.Group_Combination_Desc LIKE '#preservesinglequotes(arguments.Distributor_Name)#%'
						)
					</cfif>
				ORDER BY Customer_Group_Combination.Group_Combination_Desc  ASC

			</CFQUERY>
		<cfelse>
			<CFQUERY NAME="qGetCustomerGroups" datasource="#application.datasource#">
				<cfif (arguments.plannerID NEQ 0)>
					IF OBJECT_ID('tempdb..##tmp_planner_dist') IS NOT NULL
						DROP TABLE ##tmp_planner_dist
						
						DECLARE @Planner_ID int = #arguments.plannerID#
						            
						SELECT DISTINCT Customer_ID AS Distributor_ID
						INTO   ##tmp_planner_dist
						FROM   Planners p
						WHERE  p.Planner_ID = @Planner_ID
						AND           ISNULL(p.Distributor_Group_Level_ID, 0) = 0
						UNION
						SELECT DISTINCT Distributor_ID
						FROM   Planner_Customer_Group_Members p
						WHERE p.Planner_ID = @Planner_ID 
				</cfif>

				SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Customers.Name,
						BSA_Foodservice_Customers.Address_1,
						BSA_Foodservice_Customers.City,
						BSA_Foodservice_Customers.State,
						BSA_Foodservice_Customers.country_code,
						BSA_Foodservice_Customers.ZipCode,
						Distributor_Family.Family_Name,
						BSA_Foodservice_Customers.Ship_To,
						BSA_Foodservice_Customers.Active_Code,
						<cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Broker_Name,
						Service_Zones.Zone_Name,
						Service_Regions.Region_Name,
						</cfif>
						Distributor_Buying_Groups.Buying_Group_Name,
						BSA_Foodservice_Customers.Shr_Ship_To,
						Distributor_Group_Distributor.Distributor_Group_Level_ID,
						'' WHSE
						<cfif appsettings.getShow_Fixed_Freight()>
						,
						CASE
							WHEN Contract_Distributors.Warehouse_Master_ID = 0
							OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN
								Warehouse_Master.Warehouse_Master_ID
							ELSE
							Contract_Distributors.Warehouse_Master_ID
							END
						As Warehouse_Master_ID,
						Contract_Distributors.Overridden_Warehouse_Master_ID,
										CASE
							WHEN Contract_Distributors.Warehouse_Master_ID = 0
							OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN
								Warehouse_Master.Warehouse_Master_ID
							ELSE
							Contract_Distributors.Default_Warehouse_Master_ID
							END
						As Default_Warehouse_Master_ID,
						Warehouse_Master.Warehouse_Code,
						Warehouse_Master.Warehouse_Name,
						Warehouse_Master.Warehouse_Address_1,
						Warehouse_Master.Warehouse_Address_2,
						Warehouse_Master.Warehouse_City,
						Warehouse_Master.Warehouse_State,
						Warehouse_Master.Warehouse_Zip,
						Warehouse_Master.Warehouse_Country_Code
						</cfif>
						<cfif appSettings.getPlanningGroups()>            
						,PGT.PG_Type_code
						,PGT.PG_Type_Name
						</cfif>
						<!--- Distributor exceptions do not exist for groups and so we need to use "0" for "Exclude_Distributor" --->
						,0 As Exclude_Distributor
						<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "">
							,DMEMT.#DistributorGroupAttributeInfo.NameField# As Group_Name, 
			  				DMEMT.#DistributorGroupAttributeInfo.IDField# As Group_ID,
							DMEMT.#DistributorGroupAttributeInfo.NumberField# As Group_Number						
						</cfif>						
				FROM	BSA_Foodservice_Customers
						LEFT OUTER JOIN Distributor_Family ON
							BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
						LEFT OUTER JOIN Distributor_Buying_Groups ON
							BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
						LEFT OUTER JOIN Line_Of_Business ON
							BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID
						<cfif appSettings.getDistributorMultiPosition()>
						LEFT JOIN Market_Distributor
							ON Market_Distributor.Deleted = 0
							AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						LEFT JOIN Service_Markets
							ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
						</cfif>
						LEFT OUTER JOIN BSA_Foodservice_Brokers ON
							<cfif appSettings.getDistributorMultiPosition()>
							BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
							<cfelse>
							BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							</cfif>
						LEFT OUTER JOIN Service_Regions ON
							<cfif appSettings.getDistributorMultiPosition()>
							Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
							<cfelse>
							BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
							</cfif>
						LEFT OUTER JOIN Service_Zones ON
							Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
						LEFT OUTER JOIN Distributor_Group_Distributor ON
							BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Distributor_Group_Distributor.Distributor_ID
							AND Distributor_Group_Distributor.Deleted = 0
						LEFT OUTER JOIN Distributor_Group_Level ON
							Distributor_Group_Level.Distributor_Group_Level_ID = Distributor_Group_Distributor.Distributor_Group_Level_ID

            <cfif appSettings.getPlanningGroups()>
            LEFT JOIN PG_Type PGT
					  ON		PGT.PG_Type_ID = Distributor_Group_Distributor.Distributor_Group_Level_ID
            </cfif>						
            <cfif appsettings.getShow_Fixed_Freight()>
            LEFT JOIN Contract_Distributors
						ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
            
						AND Contract_Distributors.Is_Group = 1
						AND Contract_Distributors.Contract_Main_ID = '#arguments.Program_ID#'
						AND Contract_Distributors.Deleted = 0
						<!--- If the warehouse is not selected for a program, Join with BSA_Foodservice_Customers,
							  else Join Contract_Distributors
						--->
						LEFT JOIN Warehouse_Master
						ON
						Warehouse_Master.Warehouse_Master_ID =
						CASE
							WHEN Contract_Distributors.Warehouse_Master_ID IN ('',0)
							OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN
							BSA_Foodservice_Customers.Warehouse_Master_ID
							ELSE
							Contract_Distributors.Warehouse_Master_ID
						END
						</cfif>
						<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "">
						 LEFT JOIN #DistributorGroupAttributeInfo.tableName#	DMEMT		
        				ON CAST(DMEMT.#DistributorGroupAttributeInfo.IDField# AS VARCHAR(50))   = 	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 
						</cfif>
				WHERE	0 = 0
				AND 	BSA_Foodservice_Customers.DELETED = 0
				AND 	
				(				
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN 
					( 
					SELECT PG_Customer_Category_ID FROM PG_Customer_Category PGCC WHERE Active = 1 AND Deleted = 0
					) 
					<!--- No planning groups --->
					OR
					ISNULL(Distributor_Group_Level.Is_PG, 0) = 0                     		
				)
				
				<cfset filter.count = 0>
				<!---Search filter--->
				<!--- family name --->
				<CFIF isDefined("arguments.searchFilter.Family_Name") and arguments.searchFilter.Family_Name NEQ 0>
					AND Distributor_Family.Family_ID = '#arguments.searchFilter.Family_Name#'
					<cfset filter.count = filter.count + 1>    <!---30072 track no. of filters--->
				</CFIF>

				<!--- buying group --->
				<CFIF isDefined("arguments.searchFilter.Buying_Group") and arguments.searchFilter.Buying_Group NEQ 0>
					AND Distributor_Buying_Groups.Buying_Group_ID = '#arguments.searchFilter.Buying_Group#'
					<cfset filter.count = filter.count + 1>    <!---30072 track no. of filters--->
				</CFIF>

				<!--- Line Of Business --->
				<CFIF isDefined("arguments.searchFilter.Line_Of_Biz") and arguments.searchFilter.Line_Of_Biz NEQ 0>
					AND Line_Of_Business.Line_Of_Business_ID = '#arguments.searchFilter.Line_Of_Biz#'
					<cfset filter.count = filter.count + 1>    <!---30072 track no. of filters--->
				</CFIF>

				<!--- Cust_Id --->
				<CFIF isDefined("arguments.searchFilter.Cust_Id") and arguments.searchFilter.Cust_Id NEQ 0>
					AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#arguments.searchFilter.Cust_Id#'
					AND	Ship_To = 'Group'
					<cfset filter.count = filter.count + 1>    <!---30072 track no. of filters--->
				</CFIF>
				
				<!--- 	<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "" AND isDefined("FORM.FinalItemList") AND FORM.FinalItemList NEQ "">
					AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN  ('#Replace(FORM.FinalItemList,",","','","ALL")#')
					AND	Ship_To = 'Group'
				</cfif> --->
				<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "" AND isDefined("FORM.BusinessSegmentsON") AND 
					FORM.BusinessSegmentsON EQ 1 AND isDefined("FORM.Business_Segment_ID") AND FORM.Business_Segment_ID NEQ "">
					AND BSA_Foodservice_Customers.Business_Segment_ID IN  (#FORM.Business_Segment_ID#)
				</cfif>
				
				<cfloop query="arguments.qGetTopLevelGroups">
					<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
					<CFIF isDefined("arguments.searchFilter.#DistributorAttributeDropDownName#") and Evaluate("arguments.searchFilter.#DistributorAttributeDropDownName#") NEQ 0>
						AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Evaluate("arguments.searchFilter.#DistributorAttributeDropDownName#")#'
						AND	Ship_To = 'Group'
						<cfset filter.count = filter.count + 1>    <!---30072 track no. of filters--->
					</CFIF>					
				</cfloop>

				<!--- Search on First Letter of the Distributor Name --->
				<cfif arguments.Distributor_Name neq "">
					AND
						(
						BSA_Foodservice_Customers.Name LIKE '#preservesinglequotes(arguments.Distributor_Name)#%'
						)
						<cfset filter.count = filter.count + 1>    <!---30072 track no. of filters--->
				</cfif>

				<cfif trim(arguments.lGroup) neq "">
				AND	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN(#listqualify(arguments.lGroup, "'", ",")#)
						<cfset filter.count = filter.count + 1>      <!---31125--->
				<cfelseif arguments.checkLGroup EQ 1>
				AND	1 = 2
				</cfif>

				<cfif filter.count eq 0>  <!---30072 if no filter is selected then add conditions for the dropdowns displayed on search page--->
					AND ( 1=2    
					<CFIF isDefined("arguments.searchFilter.Family_Name")>
						OR Distributor_Group_Level.Distributor_Group_Level_Type_ID = 2
					</CFIF>
					<CFIF isDefined("arguments.searchFilter.Buying_Group")>
						OR Distributor_Group_Level.Distributor_Group_Level_Type_ID = 3
					</CFIF>
					<CFIF isDefined("arguments.searchFilter.Line_Of_Biz")>
						OR Distributor_Group_Level.Distributor_Group_Level_Type_ID = 4
					</CFIF>
					<CFIF isDefined("arguments.searchFilter.Cust_Id")>
						OR Distributor_Group_Level.Distributor_Group_Level_Type_ID = 5
					</CFIF>
				  </cfif>
					<cfloop query="arguments.qGetTopLevelGroups">
						<!--- removed hard coded DropDownName in select_distributors.cfm
						<cfswitch expression="#Distributor_Group_Level_Type_ID#">
							<cfcase value="2">
								<cfset DistributorAttributeDropDownName = "Family_Name" />
							</cfcase>
							<cfcase value="3">
								<cfset DistributorAttributeDropDownName = "Buying_Group" />
							</cfcase>
							<cfcase value="4">
								<cfset DistributorAttributeDropDownName = "Line_Of_Biz" />
							</cfcase>
							<cfcase value="5">
								<cfset DistributorAttributeDropDownName = "Cust_Id" />
							</cfcase>
							<cfdefaultcase>
								<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
							</cfdefaultcase>
						</cfswitch>
						--->
						<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
						<CFIF isDefined("arguments.searchFilter.#DistributorAttributeDropDownName#")>
							<cfif filter.count eq 0> OR (Distributor_Group_Level.Distributor_Group_Level_Type_ID = #Distributor_Group_Level_Type_ID#</cfif>
							<cfif arguments.qGetTopLevelGroups.Allow_Filter AND arguments.FirstParentID neq 0>
								<!--- Apply the template filter --->
								AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (SELECT Distributor_Group_ID 
																								FROM Customer_Group_Template_Selection CGTS
																								WHERE Deleted = 0 AND Active = 1 
																								AND Template_ID = #arguments.FirstParentID# 
																								<cfif arguments.TemplateFiltersID NEQ 0 and isNumeric(arguments.TemplateFiltersID)>
																									AND CGTS.Template_Filters_Id = <cfqueryparam value="#arguments.TemplateFiltersID#" cfsqltype="CF_SQL_INTEGER">
																								</cfif>
																							AND Distributor_Group_Level_ID = #Distributor_Group_Level_Type_ID#)
							</cfif>
							<cfif filter.count eq 0> )</cfif>
						</CFIF>
					</cfloop>
				<cfif filter.count eq 0> )</cfif>

				<cfif arguments.businessSegmentId NEQ 0>
				AND		BSA_Foodservice_Customers.Business_segment_id = '#arguments.businessSegmentId#'
				</cfif>

				<cfif arguments.bAllDistAndGroup neq 1>
				AND		Ship_To = 'Group'
				</cfif>
		<cfif appSettings.getSuppressGroupsZeroItems() AND isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "">
			AND EXISTS (<cfif DistributorGroupAttributeInfo.tableName EQ "PG_Customer_Category">
							SELECT 1
							FROM   BSA_Foodservice_Customers MEM
							INNER JOIN PG_Customer_Members M
							ON		M.PG_Customer_Category_ID = DMEMT.PG_Customer_Category_ID
							AND	M.Deleted = 0
							AND  	MEM.BSA_Foodservice_Customers_ID = M.BSA_Foodservice_Customers_ID
							AND     MEM.Ship_To != 'Group'
							AND     MEM.Active_Code = 'A'
							AND     MEM.Deleted = 0
						<cfelse>
			                           SELECT 1
			                           FROM   BSA_Foodservice_Customers MEM
									   <cfif (arguments.plannerID NEQ 0)>
										   INNER JOIN ##tmp_planner_dist planner_dist ON planner_dist.Distributor_ID = MEM.BSA_Foodservice_Customers_ID
										</cfif>	
			                           WHERE  MEM.#DistributorGroupAttributeInfo.MasterIDField# = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			                           AND           MEM.Ship_To != 'Group'
			                           AND           MEM.Deleted = 0
			                           AND           MEM.Active_Code = 'A'
						</cfif>)
		</cfif>
				<!--- We need to get a list of distributor exceptions. They exist on the distributor weight page. --->
				<cfif arguments.showDistExceptions eq 1>
				UNION

				SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Customers.Name,
						BSA_Foodservice_Customers.Address_1,
						BSA_Foodservice_Customers.City,
						BSA_Foodservice_Customers.State,
						BSA_Foodservice_Customers.country_code,
						BSA_Foodservice_Customers.ZipCode,
						Distributor_Family.Family_Name,
						BSA_Foodservice_Customers.Ship_To,
						BSA_Foodservice_Customers.Active_Code,
						<cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Broker_Name,
						Service_Zones.Zone_Name,
						Service_Regions.Region_Name,
						</cfif>
						Distributor_Buying_Groups.Buying_Group_Name,
						BSA_Foodservice_Customers.Shr_Ship_To,
						Distributor_Group_Distributor.Distributor_Group_Level_ID,
						'' WHSE
						<cfif appsettings.getShow_Fixed_Freight()>
						,
						CASE
							WHEN Contract_Distributors.Warehouse_Master_ID = 0
							OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN
								Warehouse_Master.Warehouse_Master_ID
							ELSE
							Contract_Distributors.Warehouse_Master_ID
							END
						As Warehouse_Master_ID,
						Contract_Distributors.Overridden_Warehouse_Master_ID,
										CASE
							WHEN Contract_Distributors.Warehouse_Master_ID = 0
							OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN
								Warehouse_Master.Warehouse_Master_ID
							ELSE
							Contract_Distributors.Default_Warehouse_Master_ID
							END
						As Default_Warehouse_Master_ID,
						Warehouse_Master.Warehouse_Code,
						Warehouse_Master.Warehouse_Name,
						Warehouse_Master.Warehouse_Address_1,
						Warehouse_Master.Warehouse_Address_2,
						Warehouse_Master.Warehouse_City,
						Warehouse_Master.Warehouse_State,
						Warehouse_Master.Warehouse_Zip,
						Warehouse_Master.Warehouse_Country_Code					
						</cfif>
						<cfif appSettings.getPlanningGroups()>            
						 ,PGT.PG_Type_code
						 ,PGT.PG_Type_Name
						</cfif>
						<!--- This query is for "Distributor exceptions" and so we need to use "1" for "Exclude_Distributor" --->
						,1 As Exclude_Distributor
						<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ "">
							,NULL As Group_Name, 
			  				NULL As Group_ID,
							NULL Group_Number						
						</cfif>
				FROM	BSA_Foodservice_Customers

						INNER JOIN Contract_Distributors_Exceptions 
						ON Contract_Distributors_Exceptions.Contract_Main_ID = '#arguments.Program_ID#'
						AND Contract_Distributors_Exceptions.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID

						LEFT OUTER JOIN Distributor_Family ON
							BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
						LEFT OUTER JOIN Distributor_Buying_Groups ON
							BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
						LEFT OUTER JOIN Line_Of_Business ON
							BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID
						<cfif appSettings.getDistributorMultiPosition()>
						LEFT JOIN Market_Distributor
							ON Market_Distributor.Deleted = 0
							AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						LEFT JOIN Service_Markets
							ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
						</cfif>
						LEFT OUTER JOIN BSA_Foodservice_Brokers ON
							<cfif appSettings.getDistributorMultiPosition()>
							BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
							<cfelse>
							BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
							</cfif>
						LEFT OUTER JOIN Service_Regions ON
							<cfif appSettings.getDistributorMultiPosition()>
							Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
							<cfelse>
							BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
							</cfif>
						LEFT OUTER JOIN Service_Zones ON
							Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
						LEFT OUTER JOIN Distributor_Group_Distributor ON
							BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Distributor_Group_Distributor.Distributor_ID
							AND Distributor_Group_Distributor.Deleted = 0
						LEFT OUTER JOIN Distributor_Group_Level ON
							Distributor_Group_Level.Distributor_Group_Level_ID = Distributor_Group_Distributor.Distributor_Group_Level_ID
							 
						<cfif appSettings.getPlanningGroups()>
						LEFT JOIN PG_Type PGT
						ON PGT.PG_Type_ID = Distributor_Group_Distributor.Distributor_Group_Level_ID
						 </cfif>						
						<cfif appsettings.getShow_Fixed_Freight()>
						<!--- If the warehouse is not selected for a program, Join with BSA_Foodservice_Customers,
							  else Join Contract_Distributors
						--->
						LEFT JOIN Warehouse_Master
						ON
						Warehouse_Master.Warehouse_Master_ID =
						CASE
							WHEN Contract_Distributors.Warehouse_Master_ID IN ('',0)
							OR Contract_Distributors.Warehouse_Master_ID IS NULL THEN
							BSA_Foodservice_Customers.Warehouse_Master_ID
							ELSE
							Contract_Distributors.Warehouse_Master_ID
						END
						</cfif>
				</cfif>
				ORDER BY Name  ASC

			</CFQUERY>
		</cfif>

		<cfreturn qGetCustomerGroups />

	</cffunction>

	<cffunction name="getCustomersInGroup" output="false">

		<cfargument name="customerGroupId" required="false" default="" />
		<cfargument name="customerGroupLevelId" required="false" default="" />
		<cfargument name="dynamicGroups" required="false" default="0" />
		<cfargument name="Program_ID" required="false" type="numeric" default="0" />
 
		<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
        
        <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
        <cfset busSegIdForProgram = 0 />
        <cfif isDefined("arguments.Program_ID") AND arguments.Program_ID NEQ "0" AND businessSegManager.isEnabledForDistributor()>
            <cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(arguments.Program_ID) />
        </cfif>

		<cfif isDefined("arguments.Program_ID") AND arguments.Program_ID NEQ "0">
			<cfquery name="qGetFirstParentID" datasource="#application.datasource#">
				SELECT First_Parent_ID,
					Template_Filters_Id 
				FROM Contract_Main CM
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
				WHERE  Contract_Main_ID = #arguments.program_ID#
			</cfquery>
			<cfset FirstParentID = qGetFirstParentID.First_Parent_ID />
			<cfset TemplateFiltersId = qGetFirstParentID.Template_Filters_Id />
			<!--- <cfset CustomerGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() /> --->
			<!--- <cfset qGetProductGroupAttributesGroupTemplate = ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1,FirstParentID=FirstParentID) />  --->
			<cfset qGetCustomerGroupAttributesGroupTemplate = this.getDistributorLevelsGroupTemplate(active=1, templateID=FirstParentID) />
		</cfif>	
	
    <cfquery name="qGetCustomers" datasource="#application.datasource#">
      SELECT Is_PG 
      FROM Distributor_Group_Level
      WHERE Distributor_Group_Level_ID = #arguments.customerGroupLevelId#
    </cfquery>
    
		<CFQUERY NAME="qGetCustomers" datasource="#application.datasource#">

			SELECT	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Address_1,
					BSA_Foodservice_Customers.City,
					BSA_Foodservice_Customers.State,
					BSA_Foodservice_Customers.country_code,
					BSA_Foodservice_Customers.ZipCode,
					Distributor_Family.Family_Name,
					BSA_Foodservice_Customers.Ship_To,
					BSA_Foodservice_Customers.Active_Code,
					--BSA_Foodservice_Brokers.Broker_Name,
					--Service_Zones.Zone_Name,
					--Service_Regions.Region_Name,
					Distributor_Buying_Groups.Buying_Group_Name,
					BSA_Foodservice_Customers.Shr_Ship_To

			FROM	BSA_Foodservice_Customers
					LEFT JOIN	Distributor_Family ON
					BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
					LEFT JOIN	Distributor_Buying_Groups ON
					BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
					LEFT JOIN  Line_Of_Business ON
					BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID

          			LEFT JOIN PG_Customer_Members PGCM ON PGCM.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
            
			<cfif (isDefined("qGetCustomerGroupAttributesGroupTemplate") AND qGetCustomerGroupAttributesGroupTemplate.RecordCount GTE 1)>
				<cfloop query="qGetCustomerGroupAttributesGroupTemplate">
	          		 
					<cfset typeId = qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID />
					<cfset CustomerAttributeDropDownName = "Customer_Attribute_#qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID#" />					
					
					<cfif qGetCustomerGroupAttributesGroupTemplate.PG_Flag>
					<cfset applyThisGroupInFilter = 0 />
					<cfset CustomerAttributeDropDownName = "Customer_Attribute_#qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID#" />
					
					<cfif qGetCustomerGroupAttributesGroupTemplate.Allow_Filter><!--- Tempalte is filtered on a product group --->
						<cfset applyThisGroupInFilter = 1 />
					<cfelseif isDefined("#CustomerAttributeDropDownName#")>
						<cfset CustomerAttributeDropDownValue = Evaluate("#CustomerAttributeDropDownName#") />
						<cfif CustomerAttributeDropDownValue NEQ "" AND CustomerAttributeDropDownValue NEQ "0"><!--- A drop down value is selected --->
			                <cfset applyThisGroupInFilter = 1 />
						</cfif>
					</cfif>
					<cfif applyThisGroupInFilter>
						INNER JOIN PG_Customer_Members as PGPM_#typeId#
		                ON		PGPM_#typeId#.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		                INNER JOIN PG_Customer_Category as PGPC_#typeId#
		                ON		PGPC_#typeId#.PG_Customer_Category_ID = PGPM_#typeId#.PG_Customer_Category_ID
					</cfif>
				</cfif>
        		</cfloop>
			</cfif>
 
					<cfif isDefined("arguments.dynamicGroups") and arguments.dynamicGroups>
					INNER JOIN Customer_Group_Members ON
                    BSA_Foodservice_Customers.Buying_Group_ID = Customer_Group_Members.Customer_Group_ID
			        AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Customer_Group_Members.BSA_Foodservice_Customers_ID
                    AND Customer_Group_Members.End_Date >= getDate() - 1
					</cfif>
			WHERE	0 = 0
			AND		BSA_Foodservice_Customers.DELETED = 0
			AND 	BSA_Foodservice_Customers.Active_Code = 'A'
            <cfif isDefined("arguments.Program_ID") AND arguments.Program_ID NEQ "0" AND businessSegManager.isEnabledForDistributor() AND busSegIdForProgram NEQ 0>
            AND 	BSA_Foodservice_Customers.Business_Segment_ID = #busSegIdForProgram#
            </cfif>
			<!---Search filter--->
			<cfif (isDefined("qGetCustomerGroupAttributesGroupTemplate") AND qGetCustomerGroupAttributesGroupTemplate.RecordCount GTE 1)>
					<cfloop query="qGetCustomerGroupAttributesGroupTemplate">
						<cfset CustomerAttributeDropDownName = "Customer_Attribute_#qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID#" />
						<cfset typeId = qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID />
						<cfif qGetCustomerGroupAttributesGroupTemplate.Allow_Filter>
						<!--- Template is filtered on a product group --->
							<cfif (qGetCustomerGroupAttributesGroupTemplate.PG_Flag EQ 0) AND (qGetCustomerGroupAttributesGroupTemplate.Distributor_Group_Attribute_Master_ID_Field NEQ "PG_Customer_Category_ID")>
					    		AND CAST(BSA_Foodservice_Customers.#qGetCustomerGroupAttributesGroupTemplate.Distributor_Group_Attribute_Master_ID_Field# as varchar(50)) 
									IN (SELECT Distributor_group_ID 
									FROM Customer_Group_Template_Selection 
									WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 0 
									AND Template_ID = #FirstParentID#
									<cfif TemplateFiltersID NEQ 0 AND IsNumeric(TemplateFiltersID)>
										AND Template_Filters_Id = <cfqueryparam value="#TemplateFiltersID#" cfsqltype="CF_SQL_INTEGER">
									</cfif>
									AND Distributor_Group_Level_ID = #qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID#)
             				<cfelse>
             			<!--- Planning groups / Anand Rao/10-Jan-2011 --->
                				AND PGPM_#typeId#.PG_Customer_Category_ID 
									IN (SELECT Distributor_Group_ID 
									FROM Customer_Group_Template_Selection 
									WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 1 
									AND Template_ID = #FirstParentID#
									<cfif TemplateFiltersID NEQ 0 AND IsNumeric(TemplateFiltersID)>
										AND Template_Filters_Id = <cfqueryparam value="#TemplateFiltersID#" cfsqltype="CF_SQL_INTEGER">
									</cfif>
									AND Distributor_Group_Level_ID = #qGetCustomerGroupAttributesGroupTemplate.Group_Level_ID#)
             				</cfif>
						</cfif>						
						<cfif isDefined("#CustomerAttributeDropDownName#")>
							<cfset CustomerAttributeDropDownValue = Evaluate("#CustomerAttributeDropDownName#") />
							<cfif CustomerAttributeDropDownValue NEQ "" AND CustomerAttributeDropDownValue NEQ "0">
								<cfif (qGetCustomerGroupAttributesGroupTemplate.PG_Flag EQ 0) AND (qGetCustomerGroupAttributesGroupTemplate.Distributor_Group_Attribute_ID_Field NEQ "PG_Customer_Category_ID")>
						    		AND BSA_Foodservice_Customers.#qGetCustomerGroupAttributesGroupTemplate.Distributor_Group_Attribute_Master_ID_Field# = '#CustomerAttributeDropDownValue#'
	             				<cfelse>
	                				AND PGPM_#typeId#.#qGetCustomerGroupAttributesGroupTemplate.Distributor_Group_Attribute_Master_ID_Field# = '#CustomerAttributeDropDownValue#'
	             				</cfif>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>			
						<!--- family name --->
			<CFIF arguments.customerGroupLevelId eq 2>

			AND Distributor_Family.Family_ID = '#arguments.customerGroupId#'

			<!--- buying group --->
			<cfelseif arguments.customerGroupLevelId eq 3>

			AND Distributor_Buying_Groups.Buying_Group_ID = '#arguments.customerGroupId#'

			<!--- Line Of Business --->
			<cfelseif arguments.customerGroupLevelId eq 4>

			AND Line_Of_Business.Line_Of_Business_ID = '#arguments.customerGroupId#'

			<cfelse>
      

			<cfset qGetTopLevelGroups = getDistributorLevels(-1, arguments.customerGroupLevelId) />
      
      <cfif  qGetCustomers.Is_PG EQ 0>
  			<cfloop query="qGetTopLevelGroups">
  				AND BSA_Foodservice_Customers.#Distributor_Group_Attribute_Master_ID_Field# = '#arguments.customerGroupId#'
  			</cfloop>
      <cfelse>
        AND PGCM.PG_Customer_Category_ID = '#arguments.customerGroupId#'
      </cfif>

			</CFIF>


			ORDER BY Name  ASC

		</CFQUERY>

		<cfreturn qGetCustomers />

	</cffunction>
  
	<cffunction name="getDistributorLevelsAll" output="false" returntype="query">
		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />

  		<cfquery name="qGetDistributorLevels" datasource="#application.datasource#">
			SELECT	Active, Distributor_Group_Level_ID, Distributor_Group_Level_Type_ID, Group_Level_Desc, Search_Sequence_Name,
					Distributor_Group_Attribute_Master_ID_Field, Level_ID, Search_Filter_On,Is_PG
			FROM	Distributor_Group_Level
			WHERE	Deleted = 0
			<cfif arguments.bActive NEQ -1>
			AND		Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.allowList NEQ "">
			AND		Distributor_Group_Level_Type_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			<cfif arguments.disAllowList NEQ "">
			AND		Distributor_Group_Level_Type_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			ORDER BY Group_Level_Desc ASC
		</cfquery>
  		<cfreturn qGetDistributorLevels />

	</cffunction>

	<cffunction name="getDistributorLevels" output="false" returntype="query">
		<cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />
		<cfargument name="Template_ID" type ="numeric" required="false" default = "0" />
		<cfargument name="allowInSearch" type ="numeric" required="false" default = "0" />
		<cfargument name="allowInGroupSearch" type ="numeric" required="false" default = "0" />

 		<cfquery name="qGetDistributorLevels" datasource="#application.datasource#">
			SELECT	DISTINCT 
	          DGL.Active, 
	          DGL.Distributor_Group_Level_ID, 
	          DGL.Distributor_Group_Level_Type_ID, 
	          DGL.Group_Level_Desc, 
	          DGL.Search_Sequence_Name, 
	          DGL.Distributor_Group_Attribute_Master_ID_Field,
	          DGL.Distributor_Group_Attribute_Table,
	          DGL.Distributor_Group_Attribute_Name_Field,
	          DGL.Level_ID, 
	          DGL.Search_Filter_On,
	          DGL.Is_PG,
	          DGL.List_order,
			<cfif arguments.Template_ID neq 0>
			  GT.Allow_In_Search,
		      GT.Allow_Filter
			<cfelse>
			   0 as Allow_In_Search,
		       0 as  Allow_Filter
			</cfif>
			FROM	Distributor_Group_Level DGL
				<cfif arguments.Template_ID neq 0>
			      INNER JOIN Group_Template  GT ON GT.Group_Level_ID  =  DGL.Distributor_Group_Level_ID
			      AND GT.PG_Group_Type = 2 
			      AND GT.deleted = 0
			      AND GT.Active = 1
					<cfif (arguments.allowInSearch EQ "1")>
						AND GT.Allow_In_Search = 1
					</cfif>
					<cfif (arguments.allowInGroupSearch EQ "1")>
			  			AND GT.Allow_In_Group_Search = 1
					</cfif>
			 
					<cfif (arguments.Template_ID NEQ 0 AND arguments.Template_ID NEQ "")>
						AND GT.Template_ID = <cfqueryparam value="#arguments.Template_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID =  GT.Group_Level_ID  
				</cfif>
			WHERE		DGL.Deleted = 0
      
		      <!--- Do not Select planning groups if the appsetting is OFF./Anand Rao/10-Jan-2011--->
		      <cfif NOT(appSettings.getPlanningGroups())>
		       AND DGL.Is_PG = 0
			   <cfelse>
			   	<cfif arguments.Template_ID neq 0>
			   		AND (DGL.Is_PG = 0	OR (DGL.Is_PG = 1 AND PGT.Active = 1))
				</cfif>	
		      </cfif>
					<cfif arguments.bActive NEQ -1>
					AND		DGL.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
					</cfif>
					<cfif arguments.allowList NEQ "">
					AND		DGL.Distributor_Group_Level_Type_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
					</cfif>
					<cfif arguments.disAllowList NEQ "">
					AND		DGL.Distributor_Group_Level_Type_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
					</cfif>
			ORDER BY Group_Level_Desc ASC
		</cfquery>
 
 
		<cfreturn qGetDistributorLevels />

	</cffunction>

	<cffunction name="getDistributorLevelActive" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
		<cfargument name="qGetDistributorLevels" type="query" required="true" />
		<cfargument name="distributorGroupLevelTypeID" type="numeric" required="true" />

		<cfset returnValue = 0 />

		<cfquery name="qGetDistributorLevelActive" dbtype="query">
			SELECT	Active
			FROM	qGetDistributorLevels
			WHERE	Distributor_Group_Level_Type_ID = <cfqueryparam value="#arguments.distributorGroupLevelTypeID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qGetDistributorLevelActive.recordCount>
			<cfset returnValue = qGetDistributorLevelActive.Active />
		</cfif>

		<cfreturn returnValue />

	</cffunction>
  
  <cffunction name="getDistributorLevelSearchFilterOn" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
		<cfargument name="qGetDistributorLevels" type="query" required="true" />
		<cfargument name="distributorGroupLevelTypeID" type="numeric" required="true" />

		<cfset returnValue = 0 />

		<cfquery name="qGetDistributorLevelSearchOn" dbtype="query">
			SELECT	Search_Filter_On
			FROM	qGetDistributorLevels
			WHERE	Distributor_Group_Level_Type_ID = <cfqueryparam value="#arguments.distributorGroupLevelTypeID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qGetDistributorLevelSearchOn.recordCount>
			<cfset returnValue = qGetDistributorLevelSearchOn.Search_Filter_On />
		</cfif>

		<cfreturn returnValue />

	</cffunction>
  <!--- 
      This function is the same as the above function except that it is getting 
      all the Records from the Group_Template Table passing the 
      PG_Group_Type = 2 (for Distributor)
  --->
	<cffunction name="getDistributorLevelsGroupTemplate" output="false" returntype="query">
  
	  <cfargument name="bActive" type="numeric" required="false" default="-1" />
		<cfargument name="allowList" type="string" required="false" default="" />
		<cfargument name="disAllowList" type="string" required="false" default="" />
		<cfargument name="templateID" type="numeric" required="false" default="-1" />
  
		<cfquery name="qGetDistributorLevelsGroupTemplate" datasource="#application.datasource#">
      SELECT	DISTINCT GT.Group_Template_ID, GT.Template_ID,GT.Group_Level_ID,GT.PG_Group_Type,GT.Allow_In_Search,
              GT.Allow_In_Group_Search,GT.Active,GT.Deleted,GT.Created_Date,GT.Updated_Date,GT.Created_By,
              GT.Updated_BY,GT.PG_Flag,GT.Updated_From,GT.Allow_Filter,
			  DGL.*
			  ,Field_name = DGL.Group_level_desc_internal
      FROM	Group_Template GT
	  		LEFT JOIN Distributor_Group_Level DGL 
			on DGL.Distributor_Group_Level_ID = GT.Group_Level_ID
			LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID =  GT.Group_Level_ID  
			WHERE	GT.Deleted = 0 
      AND GT.PG_Group_Type = 2
	AND  (DGL.Is_PG = 0	OR (DGL.Is_PG = 1 AND PGT.Active = 1))
			<cfif arguments.bActive NEQ -1>
			AND		GT.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif arguments.allowList NEQ "">
			AND		GT.Group_Level_ID IN (<cfqueryparam value="#arguments.allowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
			<cfif arguments.disAllowList NEQ "">
			AND		GT.Group_Level_ID NOT IN (<cfqueryparam value="#arguments.disAllowList#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfif>
	      <cfif arguments.templateID NEQ -1>
	      	AND GT.Template_ID = <cfqueryparam value="#arguments.templateID#" cfsqltype="CF_SQL_INTEGER" />
	      </cfif>
      
		</cfquery>
  	<cfreturn qGetDistributorLevelsGroupTemplate />
  
	</cffunction>  
  
  <cffunction name="getDistributorLevelActiveGroupTemplate" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
		<cfargument name="qGetDistributorLevelsGroupTemplate" type="query" required="true" />
		<cfargument name="distributorGroupLevelID" type="numeric" required="true" />

		<cfset returnValue = 0 />

		<cfquery name="qGetDistributorLevelActiveGroupTemplate" dbtype="query">
			SELECT	Allow_In_Group_Search
			FROM	qGetDistributorLevelsGroupTemplate
			WHERE	Group_Level_ID = <cfqueryparam value="#arguments.distributorGroupLevelID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qGetDistributorLevelActiveGroupTemplate.recordCount>
			<cfset returnValue = qGetDistributorLevelActiveGroupTemplate.Allow_In_Group_Search />
		</cfif>

		<cfreturn returnValue />

	</cffunction>
	
  <cffunction name="getDistributorLevelSearchFilterOnGroupTemplate" output="false" returntype="boolean" hint="1=business sgement,2=family,3=buying group,4=line of business">
		<cfargument name="qGetDistributorLevelsGroupTemplate" type="query" required="true" />
		<cfargument name="distributorGroupLevelID" type="numeric" required="true" />

		<cfset returnValue = 0 />
 
		<cfquery name="qGetDistributorLevelSearchOn" dbtype="query">
			SELECT	Allow_In_Search
			FROM	qGetDistributorLevelsGroupTemplate
			WHERE	Group_Level_ID = <cfqueryparam value="#arguments.distributorGroupLevelID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif qGetDistributorLevelSearchOn.recordCount>
			<cfset returnValue = qGetDistributorLevelSearchOn.Allow_In_Search />
		</cfif>

		<cfreturn returnValue />

	</cffunction>
  
	

	<cffunction name="getCustomersInProgram" output="false">

		<cfargument name="customerGroupId" required="true" default="" />
		<cfargument name="programid" required="true" default="0" />
         
		<cfset var qGetCustomers = "" />
		
		<CFQUERY NAME="qGetCustomers" datasource="#application.datasource#">
			select shr_ship_to,ship_to,name 
			from contract_distributors
			inner join BSA_Foodservice_Customers 
			on BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = contract_distributors.BSA_Foodservice_Customers_id
			where contract_main_id = '#arguments.programid#'
			and contract_distributors.deleted = 0
			and contract_distributors.is_group = 0
			and contract_distributors.distributor_group_id = '#arguments.customerGroupId#'
			ORDER BY Name ASC
		</CFQUERY>
		<cfreturn qGetCustomers>
	</cffunction>

	<cffunction name="getBrokerCustomers" output="false">

		<cfargument name="BrokerId" required="true" default="" />

		<CFQUERY NAME="qGetBrokerCustomers" datasource="#application.datasource#">
			SELECT shr_ship_to,name
			FROM BSA_Foodservice_Customers
			WHERE
			<cfset row = 0>
			<cfloop list="#arguments.BrokerId#" index="i">
				<cfset row = row + 1>
				<cfif row NEQ 1>OR </cfif>BSA_Foodservice_Brokers_ID = '#i#'
			</cfloop>
				AND Deleted = 0
				And Active_Code = 'A'
			ORDER BY Name ASC
		</CFQUERY>
		<cfreturn qGetBrokerCustomers />
	</cffunction>

<!--- New Function added for Inserting/Updating the value for the Filters --->
  <cffunction name="fnQryExistingCustomerData" output="false" returntype="query">
    <cfargument name="TemplateID"         required="true" type="numeric"  />
    <cfargument name="TemplateFiltersID"  required="true" type="numeric"  /> 
    <cfargument name="DistributorGroupLevelID"       required="true" type="numeric"  /> 
    <cfargument name="bActive"           required="false" type="numeric"  default="0" />         

    <cfquery name="qGetExistingData" datasource="#application.datasource#">
      SELECT  Customer_Group_Template_Selection_ID,
              Template_ID,
              Distributor_Group_Level_ID,
              Distributor_Group_ID,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Created_By,
              Updated_BY,
              PG_Flag,
              Updated_From,
              Template_Filters_Id 
      FROM    Customer_Group_Template_Selection
      WHERE   Template_ID = #arguments.TemplateID# 
      AND     Template_Filters_ID = #arguments.TemplateFiltersID# 
      AND     Distributor_Group_Level_ID = #arguments.DistributorGroupLevelID# 
      <cfif arguments.bActive EQ "1">
        AND Active = 1 AND Deleted = 0
      </cfif>      
    </cfquery>	
    <cfreturn qGetExistingData />
  </cffunction>  
    
  <cffunction name="fnSaveFilterDataCustomer" output="false" returntype="string">
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />  
    <cfset returnValue = "0" />  
    <!--- Update all the records to inactive before activating them again. --->
 <!---    <cftry> --->
    <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
      UPDATE Customer_Group_Template_Selection 
      SET Active = 0,
          Deleted = 1,
          Updated_By = '#arguments.UserID#',
          Updated_Date = GetDate()
      WHERE   Template_ID = #arguments.stForm.TemplateID# 
      AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID# 
      AND     Distributor_Group_Level_ID = #arguments.stForm.GroupLevelID#       
    </cfquery>
    
<!---     <cfquery name="qGetExistingData" datasource="#application.datasource#">
      SELECT  Customer_Group_Template_Selection_ID,
              Template_ID,
              Distributor_Group_Level_ID,
              Distributor_Group_ID,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Created_By,
              Updated_BY,
              PG_Flag,
              Updated_From,
              Template_Filters_Id 
      FROM    Customer_Group_Template_Selection
      WHERE   Template_ID = #arguments.stForm.TemplateID# 
      AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID# 
      AND     Distributor_Group_Level_ID = #arguments.stForm.GroupLevelID# 
    </cfquery> --->
   
   <cfset qGetExistingData = this.fnQryExistingCustomerData( TemplateID = arguments.stForm.TemplateID, 
                                                             TemplateFiltersID = arguments.stForm.TemplateFiltersID, 
                                                             DistributorGroupLevelID = arguments.stForm.GroupLevelID,
                                                             bActive = 0 ) />
   
    <cfloop index = "ID" list = "#arguments.stForm.FinalDistList#" > 
      <cfset bRecExists = "0" />
      <!--- Loop through qGetExistingData only, if there is already Data for the Combination --->
      <cfif qGetExistingData.RecordCount GTE 1>
        <cfloop query="qGetExistingData">
          <cfif (ID EQ qGetExistingData.Distributor_Group_ID)>
            <!--- record exist so update to active  = 1--->
            <cfset bRecExists = "1" />
            <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
              UPDATE Customer_Group_Template_Selection 
              SET Active = 1,
                  Deleted = 0,
                  Updated_By = '#arguments.UserID#',
                  Updated_Date = GetDate(),
                  Updated_From = 'Template Page'
              WHERE   Template_ID = #arguments.stForm.TemplateID# 
              AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID# 
              AND     Distributor_Group_Level_ID = #arguments.stForm.GroupLevelID#  
              AND Distributor_Group_ID = '#ID#'     
            </cfquery> 
          </cfif>
        </cfloop>
      </cfif>
      <cfif bRecExists EQ "0">
      
		<cfquery name="qryChkISPG" datasource="#application.datasource#">
          SELECT TOP 1 IS_PG  FROM 
          Distributor_Group_Level
          WHERE Distributor_Group_Level_ID = #arguments.stForm.GroupLevelID#
        </cfquery>
        <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
          INSERT INTO Customer_Group_Template_Selection 
          (
              Template_ID,
              Distributor_Group_Level_ID,
              Distributor_Group_ID,
              Active,
              Deleted,
              Created_Date,
              Created_By,
              PG_Flag,
              Updated_From,
              Template_Filters_Id 
          )
          VALUES         
          (
              #arguments.stForm.TemplateID#,
              #arguments.stForm.GroupLevelID#,
              '#ID#',
              1,
              0,
              GetDate(),
              '#arguments.UserID#',
              <cfif ((qryChkISPG.RecordCount EQ 1) AND (qryChkISPG.IS_PG EQ 1))>1<cfelse>0</cfif>,
              'Template Page',
               #arguments.stForm.TemplateFiltersID#  
          )
      </cfquery>
    </cfif>
  </cfloop> 
  <cfset returnValue = "1" />
<!---   <cfcatch>
    <cfreturn returnValue />
  </cfcatch>
 </cftry> --->
 
     <cfreturn returnValue />
  </cffunction>

</cfcomponent>