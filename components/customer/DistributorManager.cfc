<cfcomponent hint="Distributor Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.customer.DistributorManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="search" output="true" returntype="query">
		
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="useCache" required="false" type="numeric" default="0">
		<cfargument name="showDistExceptions" required="false" type="numeric" default="0">
		<cfargument name="positionID" required="false" type="numeric" default="0">
		<cfargument name="PlannerID" required="false" type="numeric" default="0">
		

		<cfset this.search = arguments.search>

		<cfset cacheSpan = CreateTimeSpan(0, 0, 0, 0) />
		<cfif arguments.useCache EQ 1>
			<cfset cacheSpan = APPLICATION.masterDataCacheSpan />
		</cfif>

		<!------ set defaults ----->
		<cfset appSettings = this.search.appSettings>
		<cfif isDefined("this.search.GetSettings")>
			<cfset GetSettings = this.search.GetSettings>
			<cfset Rebate_Recipient_On = GetSettings.Rebate_Recipient_On>
		<cfelse>
			<cfset Rebate_Recipient_On = appsettings.getCustsearchRebaterecipientOn()>
		</cfif>

		<cfparam name="this.search.getSettings.Distributor_Product_Integrity_Rule_ID" default="">

		<!--- BJF D11212 Distributor Product Integrity --->
		<cfset RestrictByRule = 0>
		<cfif appsettings.getDistributor_Product_Integrity_On() IS 1 AND len(trim(this.search.getSettings.Distributor_Product_Integrity_Rule_ID)) GT 0>
			<cfset useLakebaseForGetIntegrityRuleType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
<cfif useLakebaseForGetIntegrityRuleType>
	<cftry>
		<cfset GetIntegrityRuleType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_product_integrity_rule", {
				"distributor_product_integrity_rule_id" = "eq.#this.search.getSettings.Distributor_Product_Integrity_Rule_ID#",
				"select" = "inclusive_restriction"
			}), "inclusive_restriction"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetIntegrityRuleType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetIntegrityRuleType>
<cfquery name="GetIntegrityRuleType" datasource="#application.datasource#">
			SELECT Inclusive_Restriction
			FROM Distributor_Product_Integrity_Rule
			WHERE Distributor_Product_Integrity_Rule_ID = #this.search.getSettings.Distributor_Product_Integrity_Rule_ID#
			</cfquery>
</cfif>
			<!--- You only restrict the search if the rule is inclusive, otherwise your just pick it up on RFA --->
			<cfif GetIntegrityRuleType.Inclusive_Restriction EQ 1>
				<cfset RestrictByRule = 1>
			</cfif>
		</cfif>
		
		<!--- Dev Note(82139) - Filter distributor results based on program position --->
		<cfif arguments.positionID GT 0>
			<cfset userPositionMgr = CreateObject("component", "components.general.UserPositionManager") />
			<cfset strPosition = userPositionMgr.getPositionType(arguments.positionID)>
		</cfif>

		<cfparam name="this.search.sort_by" 	default="">
		<cfparam name="this.search.sort_Order" 	default="">
		<cfparam name="this.search.Dist_Name" 	default="">

		<CFSET sql_Sort_By="Name">
		<CFSWITCH expression="#this.search.sort_by#">
			<CFCASE value="Name">
				<CFSET sql_Sort_By="Name">
			</CFCASE>
			<CFCASE value="Ship To">
				<CFSET sql_Sort_By="Shr_Ship_To">
			</CFCASE>
			<CFCASE value="Address">
				<CFSET sql_Sort_By="BSA_Foodservice_Customers.Address_1">
			</CFCASE>
			<CFCASE value="City">
				<CFSET sql_Sort_By="BSA_Foodservice_Customers.City">
			</CFCASE>
			<CFCASE value="State">
				<CFSET sql_Sort_By="BSA_Foodservice_Customers.State">
			</CFCASE>
			<CFCASE value="Postal Code">
				<CFSET sql_Sort_By="BSA_Foodservice_Customers.ZipCode">
			</CFCASE>
			<CFCASE value="Country Code">
				<CFSET sql_Sort_By="BSA_Foodservice_Customers.Country_Code">
			</CFCASE>
			<CFCASE value="Broker">
				<CFSET sql_Sort_By="BSA_Foodservice_Brokers.Broker_Name">
			</CFCASE>
			<CFCASE value="Family">
				<CFSET sql_Sort_By="Distributor_Family.Family_Name">
			</CFCASE>
			<CFCASE value="Buying Group">
				<CFSET sql_Sort_By="Distributor_Buying_Groups.Buying_Group_Name">
			</CFCASE>
			<CFCASE value="Customer Id">
				<CFSET sql_Sort_By="dbo.Distributor_Customer_ID.Custid_Name">
			</CFCASE>
		</CFSWITCH>

		<CFSET sql_Sort_By_Order=" ASC">
		<CFIF this.search.sort_Order EQ "DESC">
			<CFSET sql_Sort_By_Order=" DESC">
		</CFIF>
		<cfset plannerDistIDsList = "" />
		 <cfif arguments.plannerID NEQ '0'>
			<cfquery name="qGetPlannerDist" datasource="#application.datasource#">
				DECLARE @Planner_ID int = #arguments.plannerID# 
		
				SELECT DISTINCT Customer_ID AS Distributor_ID
				FROM   Planners p
				WHERE  p.Planner_ID = @Planner_ID
				AND           ISNULL(p.Distributor_Group_Level_ID, 0) = 0
				UNION
				SELECT DISTINCT Distributor_ID
				FROM 	Planner_Customer_Group_Members p
				WHERE 	p.Planner_ID = @Planner_ID 
			 
			 </cfquery>
			<cfset plannerDistIDsList = listqualify(valueList(qGetPlannerDist.Distributor_ID), "'", ",") />
		</cfif>
		<cfset newZoneID = 0 />
		<cfif (isDefined("this.search.Zone_ID"))>
			<cfif Find(",",this.search.Zone_ID) EQ 0>
				<cfset newZoneID = this.search.Zone_ID />
			<cfelse>
				<cfloop index = "listItem" list = "#this.search.Zone_ID#">
					<cfif listItem NEQ "0">
						<cfset newZoneID = listItem />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	
		<CFQUERY NAME="qGetDistributors" datasource="#application.datasource#">
			SELECT  	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Customers.Name,
						BSA_Foodservice_Customers.Address_1,
						BSA_Foodservice_Customers.City,
						BSA_Foodservice_Customers.State,
						BSA_Foodservice_Customers.country_code,
						BSA_Foodservice_Customers.ZipCode,
						Distributor_Family.Family_Name,
						BSA_Foodservice_Customers.Ship_To,
						BSA_Foodservice_Customers.Active_Code,
						BSA_Foodservice_Customers.WHSE,
						<cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Broker_Name,
						Service_Zones.Zone_Name,
						Service_Regions.Region_Name,
						</cfif>
						<cfif appSettings.getcustid_on() EQ 1>
						Distributor_Customer_ID.Custid_Name,
						</cfif>
						Distributor_Buying_Groups.Buying_Group_Name,
						BSA_Foodservice_Customers.Shr_Ship_To,
						Distributor_Group_Distributor.Distributor_Group_Level_ID
						<!--- If the warehouse is not selected for a program, then get the warehouse info
							  from Warehouse Master, else get it from the contract_distributors
						--->
						<cfif appsettings.getShow_Fixed_Freight() OR (appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 AND GetTemplateInfo.RFP_Process EQ 1)>
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
						Warehouse_Master.Warehouse_Country_Code,
						CASE
							WHEN DT.Distributor_Type = 'Y' THEN
								'YES'
							ELSE
								'NO'
							END
						As redi
						</cfif>
						<!--- Distributor exceptions do not exist for groups and so we need to use "0" for "Exclude_Distributor" --->
						,0 As Exclude_Distributor

			FROM		BSA_Foodservice_Customers
						LEFT JOIN	Distributor_Family
						ON
						BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
						LEFT JOIN	Distributor_Buying_Groups
						ON
						BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
						LEFT JOIN	Line_Of_Business
						ON
						BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID
						<cfif appSettings.getDistributorMultiPosition()>
						LEFT JOIN Market_Distributor
						ON Market_Distributor.Deleted = 0
						AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						LEFT JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
						</cfif>
						LEFT
						JOIN	BSA_Foodservice_Brokers
						ON
						<cfif appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
						<cfelse>
						BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
						LEFT JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
						</cfif>
						LEFT JOIN	Service_Regions
						ON
						<cfif appSettings.getDistributorMultiPosition()>
						Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
						<cfelse>
						BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
						</cfif>
						LEFT JOIN	Service_Zones
						ON
						Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
						<cfif appSettings.getcustid_on() EQ 1>
						LEFT JOIN Distributor_Customer_ID
						ON Distributor_Customer_ID.Customer_ID = BSA_Foodservice_Customers.Customer_ID
						</cfif>
						LEFT OUTER JOIN Distributor_Group_Distributor ON
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Distributor_Group_Distributor.Distributor_ID
						AND Distributor_Group_Distributor.Deleted = 0
						<!--- Planning groups --->
            
          <!---   LEFT OUTER JOIN PG_Customer_Category ON 
            PG_Customer_Category.PG_Customer_Category_ID = Group_Template. --->
                        
            
            <!--- D11212 Distributor Product Integrity --->
						<cfif appsettings.getDistributor_Product_Integrity_On() IS 1 AND RestrictByRule IS 1>
						INNER JOIN Distributor_Product_Integrity_Distributors
						ON Distributor_Product_Integrity_Distributors.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						AND Distributor_Product_Integrity_Distributors.Deleted = 0
						AND Distributor_Product_Integrity_Distributors.Distributor_Product_Integrity_Rule_ID = '#this.search.getSettings.Distributor_Product_Integrity_Rule_ID#'
						</cfif>	
						<cfif appsettings.getShow_Fixed_Freight()>					
						LEFT JOIN Contract_Distributors
						ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						AND Contract_Distributors.Contract_Main_ID = '#this.search.Contract_Main_ID#'
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
						LEFT JOIN Distributor_Type DT ON 
							DT.Distributor_Type_ID = BSA_Foodservice_Customers.Distributor_Type_ID

				<cfif isDefined("this.search.qGetTopLevelGroups")>
					<cfset customer_types = []>
					<cfloop query="this.search.qGetTopLevelGroups">
    					<!--- TODO only do the below for PG_Flag = 1  put a if checking here --->
              			<cfif (this.search.qGetTopLevelGroups.IS_PG EQ 1)>				
							<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
							<cfset typeId = this.search.qGetTopLevelGroups.Distributor_Group_Level_ID />
							
							<cfset JoinOnPG = 0 />
							<cfif this.search.qGetTopLevelGroups.Allow_Filter>
							  	<cfset JoinOnPG = 1 />
  							<CFELSEIF isDefined("this.search.#DistributorAttributeDropDownName#")>
  								<cfset DistributorAttributeDropDownValue = Evaluate("this.search.#DistributorAttributeDropDownName#") />
    							<cfif DistributorAttributeDropDownValue NEQ "" AND DistributorAttributeDropDownValue NEQ "0">
				                   <cfset JoinOnPG = 1 />
    							</cfif>
  							</CFIF>
		
							<!--- Do the JOIN only once --->
							<cfif JoinOnPG and arrayFindNoCase(customer_types, typeId) eq 0>
								<cfset arrayAppend(customer_types, typeId)>
								INNER JOIN PG_Customer_Members PGCM_#typeId# ON PGCM_#typeId#.PG_Type_ID = #Distributor_Group_Level_Type_ID# 
								AND PGCM_#typeId#.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
								AND PGCM_#typeId#.Deleted = 0				                    
		
							<cfif this.search.qGetTopLevelGroups.Allow_Filter>
							  	AND PGCM_#typeId#.PG_Customer_Category_ID IN (SELECT Distributor_Group_ID 
								  												FROM Customer_Group_Template_Selection CGTS
								  												WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 1 AND 
								  													Template_ID = #this.search.FirstParentID# AND
																						<cfif this.search.TemplateFiltersID NEQ 0 and isNumeric(this.search.TemplateFiltersID)>
																							CGTS.Template_Filters_Id = <cfqueryparam value="#this.search.TemplateFiltersID#" cfsqltype="CF_SQL_INTEGER"> AND
																						</cfif>
																					Distributor_Group_Level_ID = #typeId#)
							</cfif>
  							<cfif isDefined("this.search.#DistributorAttributeDropDownName#")>
  								<cfset DistributorAttributeDropDownValue = Evaluate("this.search.#DistributorAttributeDropDownName#") />
    							<cfif DistributorAttributeDropDownValue NEQ "" AND DistributorAttributeDropDownValue NEQ "0">
				                    AND PGCM_#typeId#.PG_Customer_Category_ID = '#DistributorAttributeDropDownValue#'
    							</cfif>
  							</cfif>
		
							</cfif>
							
              			</cfif><!--- checking for IS_PG Ends--->  
					</cfloop>
				</cfif>
            
			WHERE
						<cfparam name="this.search.checkFinalItemList" 	default="0">
						<!--- Dev Note:Milan (21872). When we have a list of distributors being passed to the query, then it does not
							  matter whether the distributor is deleted or not. In this case, just ignore the deleted bit. Also, the
							  different conditions that I have used here is the same as the one being used to call the "FinalItemList"
							  inside the "IN" clause.
						--->
						<cfset DistributorList = 0>
						<cfif this.search.checkFinalItemList EQ "1">
							<cfif isDefined("this.search.FinalItemList")>
								<cfif listlen(this.search.FinalItemList) GT 0>
									1 = 1
									<!--- In this case, we do not need "BSA_Foodservice_Customers.deleted = 0" condition --->
									<cfset DistributorList = 1>
								</cfif>
							</cfif>
						</cfif>	
						<cfif DistributorList eq 0>
									BSA_Foodservice_Customers.deleted = 0
						AND BSA_Foodservice_Customers.Ship_To != 'Group'
                        </cfif>
                        <cfif appsettings.getCustsearchRebaterecipientOn() AND Rebate_Recipient_On IS 1>
						AND (BSA_Foodservice_Customers.Rebate_Recipient = 'S' OR BSA_Foodservice_Customers.Rebate_Recipient = 'R')
						</cfif>
						<cfif this.search.checkFinalItemList EQ "1">
						<cfif isDefined("this.search.FinalItemList")>
						AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
							<CFIF this.search.FinalItemList EQ "0">IS NULL
							<CFELSEIF listlen(this.search.FinalItemList) GT 0>IN(#listqualify(this.search.FinalItemList, "'", ",")#)
							<CFELSE>!= BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
							</CFIF>
						</cfif>
						</cfif>
						<cfif Super.variableExist("this.search.Distributor_Status", "")>
						AND BSA_Foodservice_Customers.Active_Code = '#this.search.Distributor_Status#'
						</cfif>
						<cfif Super.variableExist("this.search.passed_form", "") AND Super.variableExist("this.search.itemList", "")>
							AND(
									 BSA_Foodservice_Customers.Shr_Ship_To in ( #PreserveSingleQuotes(this.search.itemList)# )
									 OR
									 BSA_Foodservice_Customers.Ship_To in ( #PreserveSingleQuotes(this.search.itemList)# )
									 )
						<cfelse>
							<cfif Super.variableExist("this.search.Ship_To", "")>
								AND (BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#this.search.Ship_To#%'
									OR BSA_Foodservice_Customers.Ship_To LIKE '%#this.search.Ship_To#%'
									OR BSA_Foodservice_Customers.Keyword_Search LIKE '%#this.search.Ship_To#%'
									)
							</cfif>

							<!--- family name --->
							<cfif Super.variableExist("this.search.Family_Name", "") AND Super.variableExist("this.search.Family_Name", "0")>
								AND BSA_Foodservice_Customers.Family_ID = '#this.search.Family_Name#'
							</cfif>

							<!--- buying group --->
							<cfif Super.variableExist("this.search.Buying_Group", "") AND Super.variableExist("this.search.Buying_Group", "0")>
								AND BSA_Foodservice_Customers.Buying_Group_ID = '#this.search.Buying_Group#'
							</cfif>

							<!--- Line Of Business --->
							<cfif Super.variableExist("this.search.Line_Of_Biz", "") AND Super.variableExist("this.search.Line_Of_Biz", "0")>
								AND BSA_Foodservice_Customers.Line_Of_Business_ID = '#this.search.Line_Of_Biz#'
							</cfif>

							<!--- Cust ID --->
							<cfif Super.variableExist("this.search.Cust_Id", "") AND Super.variableExist("this.search.Cust_Id", "0")>
								AND BSA_Foodservice_Customers.Customer_ID = '#this.search.Cust_Id#'
							</cfif>

							<!--- Zone --->
							<cfif Super.variableExist("this.search.Zone_ID", "") AND Super.variableExist("this.search.Zone_ID", "0") AND newZoneID NEQ "0">
								AND Service_Zones.Service_Zone_ID = '#newZoneID#'
							</cfif>

							<!--- Region --->
							<cfif Super.variableExist("this.search.Region_ID", "") AND Super.variableExist("this.search.Region_ID", "0")>
								AND Service_Regions.Service_Region_ID = '#this.search.Region_ID#'
							</cfif>

							<!---D57063 START --->
							<!--- Market --->
							<cfif Super.variableExist("this.search.Market_ID", "") AND Super.variableExist("this.search.Market_ID", "0")>
								AND Service_Markets.Service_Market_ID = '#this.search.Market_ID#'
							</cfif>						
							<!---D57063 END --->

							<!--- Broker --->
							<cfif Super.variableExist("this.search.Broker", "") AND Super.variableExist("this.search.Broker", "0")>
								AND
								(
								<cfset row = 0>
								<cfloop list="#this.search.Broker#" index="i">
									<cfset row = row + 1>
									<cfif row NEQ 1>OR</cfif> BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = '#i#'
								</cfloop>
								)
							</cfif>

							<!--- State --->
							<cfif Super.variableExist("this.search.State", "") AND Super.variableExist("this.search.State", "0")>
								AND BSA_Foodservice_Customers.state = '#this.search.State#'
							</cfif>

							<!--- Country --->
							<cfif Super.variableExist("this.search.country_code", "") AND Super.variableExist("this.search.country_code", "0")>
								AND BSA_Foodservice_Customers.country_code = '#this.search.country_code#'
							</cfif>

							<!------ LOADPRODUCTSFROMTHESEPROGRAMS ----->
							<cfif Super.variableExist("this.search.LOADPRODUCTSFROMTHESEPROGRAMS", "")>
								AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN(SELECT BSA_Foodservice_Customers_ID FROM Contract_Distributors WHERE Contract_Main_ID IN(#this.search.LOADPRODUCTSFROMTHESEPROGRAMS#))
							</cfif>
							<!--- <cfif isDefined("this.search.businessSegmentsOn") AND isDefined("this.search.Business_Segment_ID")>
								<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
								AND BSA_Foodservice_Customers.Business_Segment_ID = #this.search.Business_Segment_ID#
								</cfif>
							</cfif> --->
							<cfif Super.variableExist("this.search.searchstring", "")>
							AND
							(
								BSA_Foodservice_Customers.Name LIKE '%#preservesinglequotes(this.search.searchstring)#%'
								--OR BSA_Foodservice_Customers.City LIKE '%#preservesinglequotes(this.search.searchstring)#%'
								OR Distributor_Family.Family_Name LIKE '%#preservesinglequotes(this.search.searchstring)#%'
								<CFIF isnumeric(form.searchstring)>
								OR BSA_Foodservice_Customers.Shr_Family LIKE '%#preservesinglequotes(this.search.searchstring)#%'
								</CFIF>
								--OR BSA_Foodservice_Brokers.Broker_Name LIKE '%#preservesinglequotes(this.search.searchstring)#%'
								OR BSA_Foodservice_Customers.Keyword_Search LIKE '%#preservesinglequotes(this.search.searchstring)#%'
							)
							</cfif>

							<cfif Super.variableExist("this.search.Dist_Name", "")>
								AND BSA_Foodservice_Customers.Name LIKE '#preservesinglequotes(this.search.Dist_Name)#%'
							</cfif>
						</cfif>
            <!--- 
              Moved the nested if condition here so that the list search would return the right 
              results. -Anand Rao 02/17/09 D18150 --->
            <cfif isDefined("this.search.businessSegmentsOn") AND isDefined("this.search.Business_Segment_ID")>
								<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
								AND BSA_Foodservice_Customers.Business_Segment_ID = #this.search.Business_Segment_ID#
								</cfif>
							</cfif> 
						<cfif appsettings.getSalesOrgOn() and isDefined("this.search.Line_Of_Business_ID") and this.search.Line_Of_Business_ID NEQ "">
						and BSA_Foodservice_Customers.Line_Of_Business_ID = '#this.search.Line_Of_Business_ID#'
						</cfif>
						<!------ Restrictions / user permissions ----->
						<cfif appSettings.getCustomertype()>
							<cfif Super.variableExist("this.search.Customer_Type", "")>
								AND BSA_Foodservice_Customers.#this.search.Customer_Type# = 1
							</cfif>
						</cfif>
						<cfif isDefined("this.search.profileCustTypeSettings")>
							<cfif this.search.profileCustTypeSettings.recordcount GT 0>
							<cfloop query="this.search.profileCustTypeSettings">
								AND
								(
								BSA_Foodservice_Customers.#this.search.profileCustTypeSettings.Customer_Type# = 0
								OR #this.search.profileCustTypeSettings.PROFILE_CUSTOMER_TYPE_VALUE# = 1
								)
							</cfloop>
							</cfif>
						</cfif>
						<!------ Filter for all other active attribute drop downs ----->
						<cfif isDefined("this.search.qGetTopLevelGroups")>
						<cfloop query="this.search.qGetTopLevelGroups">
            				<!--- TODO only if PG_Flag = 0 then do this loop put a if condition checking here   --->
             				<cfif (this.search.qGetTopLevelGroups.IS_PG EQ 0)>
							  <cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
							  
							  <cfif this.search.qGetTopLevelGroups.Allow_Filter>
							  	AND CAST(BSA_Foodservice_Customers.#Distributor_Group_Attribute_Master_ID_Field# as varchar(50)) 
								  		IN (SELECT Distributor_Group_ID 
								  			FROM Customer_Group_Template_Selection CGTS 
								  			WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 0 AND 
								  				Template_ID = #this.search.FirstParentID# AND
												 <cfif this.search.TemplateFiltersID NEQ 0 and isNumeric(this.search.TemplateFiltersID)>
													CGTS.Template_Filters_Id = <cfqueryparam value="#this.search.TemplateFiltersID#" cfsqltype="CF_SQL_INTEGER"> AND
												</cfif>
												Distributor_Group_Level_ID = #this.search.qGetTopLevelGroups.Distributor_Group_Level_ID#)
							  </cfif>
							  <cfif isDefined("this.search.#DistributorAttributeDropDownName#")>
								  <cfset DistributorAttributeDropDownValue = Evaluate("this.search.#DistributorAttributeDropDownName#") />
								  <cfif DistributorAttributeDropDownValue NEQ "" AND DistributorAttributeDropDownValue NEQ "0">
                	 				AND BSA_Foodservice_Customers.#Distributor_Group_Attribute_Master_ID_Field# = '#DistributorAttributeDropDownValue#'
								  </cfif>
							  </cfif>
              				</cfif>
						</cfloop>
						</cfif>
						
						<!--- Dev Note(82139) - Filter distributor results based on program position --->
						<cfif arguments.positionID GT 0>
							<cfif strPosition.positionType eq 1>
								AND Service_Zones.Service_Zone_ID = <cfqueryparam value="#strPosition.positionGUID#" cfsqltype="CF_SQL_VARCHAR">
							<cfelseif strPosition.positionType eq 2>
								AND Service_Regions.Service_Region_ID = <cfqueryparam value="#strPosition.positionGUID#" cfsqltype="CF_SQL_VARCHAR">
							<cfelseif strPosition.positionType eq 3>
								AND Service_Markets.Service_Market_ID = <cfqueryparam value="#strPosition.positionGUID#" cfsqltype="CF_SQL_INTEGER">
							</cfif>
						</cfif>
				
				<cfif arguments.plannerID NEQ '0' AND ListLen(plannerDistIDsList) NEQ 0>
					 AND BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#preserveSinglequotes(plannerDistIDsList)#)
				</cfif> 
				<!--- We need to get a list of distributor exceptions. They exist on the distributor weight page. --->
				<cfif arguments.showDistExceptions eq 1>
				UNION

					SELECT  	DISTINCT BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
						BSA_Foodservice_Customers.Name,
						BSA_Foodservice_Customers.Address_1,
						BSA_Foodservice_Customers.City,
						BSA_Foodservice_Customers.State,
						BSA_Foodservice_Customers.country_code,
						BSA_Foodservice_Customers.ZipCode,
						Distributor_Family.Family_Name,
						BSA_Foodservice_Customers.Ship_To,
						BSA_Foodservice_Customers.Active_Code,
						BSA_Foodservice_Customers.WHSE,
						<cfif NOT appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Broker_Name,
						Service_Zones.Zone_Name,
						Service_Regions.Region_Name,
						</cfif>
						<cfif appSettings.getcustid_on() EQ 1>
						Distributor_Customer_ID.Custid_Name,
						</cfif>
						Distributor_Buying_Groups.Buying_Group_Name,
						BSA_Foodservice_Customers.Shr_Ship_To,
						Distributor_Group_Distributor.Distributor_Group_Level_ID
						<!--- If the warehouse is not selected for a program, then get the warehouse info
							  from Warehouse Master, else get it from the contract_distributors
						--->
						<cfif appsettings.getShow_Fixed_Freight() OR (appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 AND GetTemplateInfo.RFP_Process EQ 1)>
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
						Warehouse_Master.Warehouse_Country_Code,
						CASE
							WHEN DT.Distributor_Type = 'Y' THEN
								'YES'
							ELSE
								'NO'
							END
						As redi
						</cfif>
						<!--- This query is for "Distributor exceptions" and so we need to use "1" for "Exclude_Distributor" --->
						,1 As Exclude_Distributor
			FROM		BSA_Foodservice_Customers

						INNER JOIN Contract_Distributors_Exceptions 
						ON Contract_Distributors_Exceptions.Contract_Main_ID = '#this.search.Contract_Main_ID#'
						AND Contract_Distributors_Exceptions.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID

						LEFT JOIN	Distributor_Family
						ON
						BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
						LEFT JOIN	Distributor_Buying_Groups
						ON
						BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
						LEFT JOIN	Line_Of_Business
						ON
						BSA_Foodservice_Customers.Line_Of_Business_ID = Line_Of_Business.Line_Of_Business_ID
						<cfif appSettings.getDistributorMultiPosition()>
						LEFT JOIN Market_Distributor
						ON Market_Distributor.Deleted = 0
						AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						LEFT JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
						</cfif>	
						LEFT
						JOIN	BSA_Foodservice_Brokers
						ON
						<cfif appSettings.getDistributorMultiPosition()>
						BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
						<cfelse>
						BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
						LEFT JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID
						</cfif>
						LEFT JOIN	Service_Regions
						ON
						<cfif appSettings.getDistributorMultiPosition()>
						Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
						<cfelse>
						BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
						</cfif>
						LEFT JOIN	Service_Zones
						ON
						Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
						<cfif appSettings.getcustid_on() EQ 1>
						LEFT JOIN Distributor_Customer_ID
						ON Distributor_Customer_ID.Customer_ID = BSA_Foodservice_Customers.Customer_ID
						</cfif>
						LEFT OUTER JOIN Distributor_Group_Distributor ON
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Distributor_Group_Distributor.Distributor_ID
						AND Distributor_Group_Distributor.Deleted = 0
						<cfif appsettings.getShow_Fixed_Freight()>	
						LEFT JOIN Contract_Distributors
						ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						AND Contract_Distributors.Contract_Main_ID = '#this.search.Contract_Main_ID#'
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
						LEFT JOIN Distributor_Type DT ON 
							DT.Distributor_Type_ID = BSA_Foodservice_Customers.Distributor_Type_ID
						<!--- Dev Note(82139) - Filter distributor results based on program position --->
						<cfif arguments.positionID GT 0>
							<cfif strPosition.positionType eq 1>
								AND Service_Zones.Service_Zone_ID = <cfqueryparam value="#strPosition.positionGUID#" cfsqltype="CF_SQL_VARCHAR">
							<cfelseif strPosition.positionType eq 2>
								AND Service_Regions.Service_Region_ID = <cfqueryparam value="#strPosition.positionGUID#" cfsqltype="CF_SQL_VARCHAR">
							<cfelseif strPosition.positionType eq 3>
								AND Service_Markets.Service_Market_ID = <cfqueryparam value="#strPosition.positionGUID#" cfsqltype="CF_SQL_INTEGER">
							</cfif>
						</cfif>

				</cfif>

			ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
		</CFQUERY>
		
		<!--- If Search selection tracking is on, this will log the selections in the Search_Selections table --->
	<cfif appSettings.getSearch_Selection_Tracking_On()>
			<cfset SearchSelection = CreateObject("component", "components.reports.SearchSelection").init()>
			
			<cfset SaveSelection = SearchSelection.DistributorSearch("Program Distributor Search","#cgi.HTTP_Host#","#request.accessStructure.User_ID#",this.search, qGetDistributors.recordcount, cfquery.ExecutionTime)>
		</cfif> 
		<!---cfif appSettings.getSearch_Selection_Tracking_On()--->

		<cfreturn qGetDistributors />

	</cffunction>

	<cffunction name="getWarehouses" output="false" returntype="query">

	<cfargument name="sort_by" required="false" default="Warehouse_Name" />
	<cfargument name="sort_Order" required="false" default=" ASC" />
	<cfset useLakebaseForqrygetWarehouses = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("warehouse_master")>
<cfif useLakebaseForqrygetWarehouses>
	<cftry>
		<cfset qrygetWarehouses = application.oLakebase.toQuery(
			application.oLakebase.selectRows("warehouse_master", {
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"order" = "#sort_by#.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetWarehouses = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetWarehouses>
<cfquery name="qrygetWarehouses" datasource="#application.datasource#">
		SELECT *
		FROM Warehouse_Master
		WHERE Deleted = 0
		AND Active_Code = 'A'
		ORDER BY #sort_by# #sort_Order#
	</cfquery>
</cfif>
		<cfreturn qrygetWarehouses />
   	</cffunction>

	<cffunction name="getDistributors" access="public" returntype="query" output="false">

		<cfargument name="Contract_Main_ID_List" type="string" required="true" />
		<cfargument name="EffectiveDate" type="date" required="false" />

		<CFQUERY NAME="qget_Contract_number" datasource="#application.datasource#">
			SELECT DISTINCT Contract_Number 
			FROM Contract_Main
			WHERE Contract_Main_ID IN  (<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#arguments.Contract_Main_ID_List#" />)
		</CFQUERY>

		<CFQUERY NAME="qgetDistributors" datasource="#application.datasource#">
			SELECT Count(Contract_Distributors.BSA_Foodservice_Customers_ID) As Distributor_Count
			FROM	Contract_Distributors
			INNER JOIN Contract_Main
			ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE Contract_Main.Contract_Number IN (#QuotedValueList(qget_Contract_number.Contract_Number)#)
			AND Contract_Distributors.Deleted = 0
			AND	Contract_Distributors.Is_Group = 0	
		</CFQUERY>
		
	  <cfif qgetDistributors.Distributor_Count neq 0>
		<CFQUERY NAME="qgetDistributors" datasource="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Shr_Ship_To,
					BSA_Foodservice_Customers.City,
					BSA_Foodservice_Customers.State,
					BSA_Foodservice_Customers.Address_1,
					BSA_Foodservice_Customers.zipcode,
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			FROM	Contract_Distributors
			INNER JOIN	BSA_Foodservice_Customers
			ON		Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID			
			INNER JOIN Contract_Main
			ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE	Contract_Main.Contract_Number IN (#QuotedValueList(qget_Contract_number.Contract_Number)#)
			AND 	Contract_Distributors.Deleted = 0
			AND		Contract_Distributors.Is_Group = 0	
			AND		<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.EffectiveDate#" /> >= Contract_Main.Effective_Start_Date
			AND		<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.EffectiveDate#" /> <= Contract_Main.Effective_End_Date
			ORDER BY BSA_Foodservice_Customers.Name
		</CFQUERY>
	  </cfif>

		<cfreturn qgetDistributors />

	</cffunction>

	<cffunction name="getPaidToDistributor" access="public" returntype="query" output="false">
		<cfargument name="programId" type="string" required="false" default="" />

		<cfquery name="qGetPaidToDistributor" datasource="#application.datasource#">
				SELECT 	DISTINCT
								C.BSA_Foodservice_Customers_ID as BSA_ID,
								C.Shr_Ship_To as ID,
								C.Name,
								C.Address_1,
								C.City,
								C.State,
								C.zipcode
				FROM 	BSA_Foodservice_Customers C
				<cfif len(arguments.programId) and isNumeric(arguments.programId) >
				INNER JOIN Contract_Distributors CD ON CD.BSA_Foodservice_Customers_ID = C.BSA_Foodservice_Customers_ID
				AND CD.Deleted = 0
				INNER JOIN Contract_Main CM ON CM.Contract_Main_ID = CD.Contract_Main_ID
				AND CM.Deleted = 0
				AND CM.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
				</cfif>
				WHERE C.Deleted = 0
				AND C.Active_Code = 'A'
				ORDER BY C.Name		
		</cfquery>
		<cfreturn qGetPaidToDistributor />
	</cffunction>

	<cffunction name="getPaidToOperator" access="public" returntype="query" output="false">
		<cfargument name="programId" type="string" required="false" default="" />

		<cfquery name="qGetPaidToOperator" datasource="#application.datasource#">
				SELECT 	DISTINCT
								BO.BSA_Operator_ID as BSA_ID,
								ISNULL(BO.Legacy_ID,BO.BSA_Operator_ID) as ID,
								BO.Operator_Name as Name,
								BO.Operator_Address as Address_1,
								BO.Operator_City as City,
								BO.Operator_State as State,
								BO.Operator_Zip as zipcode
				FROM 	BSA_Operator BO
				<cfif len(arguments.programId) and isNumeric(arguments.programId) >
				INNER JOIN Contract_Operators CO ON CO.BSA_Operator_ID = BO.BSA_Operator_ID
				AND CO.Deleted = 0
				INNER JOIN Contract_Main CM ON CM.Contract_Main_ID = CO.Contract_Main_ID
				AND CM.Deleted = 0
				AND CM.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
				</cfif>
				WHERE BO.Deleted = 0
				ORDER BY BO.Operator_Name	
		</cfquery>
		<cfreturn qGetPaidToOperator />
	</cffunction>

	<cffunction name="getProgramDistributorExceptions" access="public" returntype="query" output="false">
		<cfargument name="programId" type="string" required="false" default="" />

		<cfquery name="qGetProgramDistributorExceptions" datasource="#application.datasource#">
				SELECT DISTINCT BSA_Foodservice_Customers_ID
					FROM	Contract_Distributors_Exceptions
				WHERE Contract_Main_ID = '#arguments.programId#'
		</cfquery>
		<cfreturn qGetProgramDistributorExceptions />
	</cffunction>

	<cffunction name="populateCustomerGroupMembers" access="public" returntype="void" output="false">
		<cfargument name="programId" type="string" required="true" />
		
		<cfquery name="qPopulateCustomerGroupMembers" datasource="#application.datasource#">
			EXEC SP_CAPTURE_ALL_FOR_GROUPS_CUSTOMER <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cffunction>

</cfcomponent>