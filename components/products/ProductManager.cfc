<cfcomponent hint="Product Manager" extends="components.Base">
	<cfset variables.searchForm = "" />

	<cffunction name="init" output="false" returntype="components.products.ProductManager">
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		<cfset setSearchForm(arguments.search) />
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getSearchForm" returntype="struct" access="public" output="false">
		<cfreturn variables.searchForm />
	</cffunction>
	<!--- setter ---->
	<cffunction name="setSearchForm" returntype="void" access="package">
		<cfargument name="searchForm" required="true" type="struct">
		<cfset variables.searchForm = arguments.searchForm />
	</cffunction>

	<cffunction name="search" output="true" returntype="query">

		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		<cfargument name="useCache" required="false" type="numeric" default="0">

		<cfset this.cacheSpan = CreateTimeSpan(0, 0, 0, 0) />
		<cfif arguments.useCache EQ 1>
			<cfset this.cacheSpan = APPLICATION.masterDataCacheSpan />
		</cfif>

		<!---if the search struct is not empty then set it to that struct--->
		<cfif IsStruct(arguments.search) and not StructIsEmpty(arguments.search)>
			<cfset setSearchForm(arguments.search) />
		</cfif>

		<cfset this.search = this.getSearchForm() />


	<!--- By Default search the Mini Item Master table (180 days) --->
		<cfparam name="QueryMasterProductTable"  default="1">

		<cfset ListofFields = "Distributor_List,Ship_To">
			<cfloop List="#ListofFields#" index="FormFieldsCheck">
				<cfif IsDefined("#FormFieldsCheck#")>
					 <cfif Evaluate(FormFieldsCheck) NEQ "" AND Evaluate(FormFieldsCheck) NEQ 0>
					 	<cfset QueryMasterProductTable = 0>
					 </cfif>
				</cfif>
			</cfloop>

	<!--- List of fields to decide whether the Item Master table needs to be queried or not (If the search is using any of these fields,
		  Use the Item Master table for the search) --->
		<cfset ListofFields ="Q_Brand_ID,Type_Group_Desc_ID,Type_Code_Desc_ID,Brand_ID,Search_Class_Code_ID,item_number,upc_number,description_string,Line_Of_Biz,Rebate_Type_Search_ID">
			<cfloop List="#ListofFields#" index="FormFieldsCheck">
				<cfif IsDefined("#FormFieldsCheck#")>
				  <cfif Evaluate(FormFieldsCheck) NEQ "" AND Evaluate(FormFieldsCheck) NEQ 0>
					<cfset QueryMasterProductTable = 1>
					<cfbreak>
				</cfif>
				</cfif>
			</cfloop>

	<!--- These are some additional fields besides the ones on top (If the search is using any of these fields,
		  Use the Item Master table for the search). If it's any of the product hierarchies OR the Product Status is not "Active" --->
			<cfif QueryMasterProductTable eq 0>
				<cfloop List="#FieldNames#" index="FormFieldsCheck">
					<cfif Left(FormFieldsCheck,17) eq "Product_Hierarchy">
						<cfset ProductHierarchyField = FormFieldsCheck>
						<cfif Evaluate(ProductHierarchyField) NEQ "" AND Evaluate(ProductHierarchyField) NEQ 0>
							<cfset QueryMasterProductTable = 1>
							<cfbreak>
						</cfif>
					</cfif>

					<cfif FormFieldsCheck eq "Product_Status">
						<cfif Evaluate(FormFieldsCheck) neq 'A'>
							<cfset QueryMasterProductTable = 1>
							<cfbreak>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>

		<cfif QueryMasterProductTable eq 1><cfset bsaItemMasterTableName = 'BSA_Foodservice_Items_Master'><cfelse><cfset  bsaItemMasterTableName = 'BSA_Mini_Item_Master'></cfif>
		<!------ set defaults ----->
		<cfif NOT isDefined("this.search.appSettings")>
			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset appSettings = genSettingsManager.get()>
		<cfelse>
			<cfset appSettings = this.search.appSettings>
		</cfif>


		<!--- BJF D11212 Distributor Product Integrity --->
		<cfset RestrictByRule = 0>
		<cfif appsettings.getDistributor_Product_Integrity_On() IS 1>
		<cfif isDefined("this.search.DTPS_Program_ID")>

		<cfquery name="GetRuleID" datasource="#application.datasource#">
		SELECT ISNULL(Distributor_Product_Integrity_Rule_ID, 0) AS Distributor_Product_Integrity_Rule_ID
		FROM Program_Control_Panel_Options
			INNER JOIN Contract_Main
			ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			AND Contract_Main.Contract_Main_ID = '#this.search.DTPS_Program_ID#'
		</cfquery>

		<cfif GetRuleID.Recordcount IS 1 AND NOT GetRuleID.Distributor_Product_Integrity_Rule_ID AND NOT len(trim(GetRuleID.Distributor_Product_Integrity_Rule_ID))>
			<cfset useLakebaseForGetIntegrityRuleType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
<cfif useLakebaseForGetIntegrityRuleType>
	<cftry>
		<cfset GetIntegrityRuleType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_product_integrity_rule", {
				"distributor_product_integrity_rule_id" = "eq.#GetRuleID.Distributor_Product_Integrity_Rule_ID#",
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
			WHERE Distributor_Product_Integrity_Rule_ID = #GetRuleID.Distributor_Product_Integrity_Rule_ID#
			</cfquery>
</cfif>
			<!--- You only restrict the search if the rule is inclusive, otherwise your just pick it up on RFA --->
			<cfif GetIntegrityRuleType.Inclusive_Restriction EQ 1>
				<cfset RestrictByRule = 1>
			</cfif>
		<!--- Got to rule ID --->
		</cfif>
		<!--- Program ID is defined --->
		</cfif>
		<!--- app setting for integrity is on --->
		</cfif>


		<!------ sorting code ----->
		<cfparam name="this.search.sort_by" 	default="">
		<cfparam name="this.search.sort_Order" 	default="">
		<CFSET sql_Sort_By = "Product_Table.Item">
		<CFSWITCH expression="#this.search.sort_by#">
			<CFCASE value="Type_Code_Desc">
				<CFSET sql_Sort_By="Type_Code_Desc.Type_Code_Desc">
			</CFCASE>
			<CFCASE value="Type_Group_Desc">
				<CFSET sql_Sort_By="Type_Group_Desc.Type_Group_Desc">
			</CFCASE>
			<CFCASE value="Product_Hierarchy_Name">
				<CFSET sql_Sort_By="Product_Hierarchy.Product_Hierarchy_Name">
			</CFCASE>
			<CFCASE value="Brand">
				<CFSET sql_Sort_By="Brand.Brand_Name">
			</CFCASE>
			<CFCASE value="ItemNumber">
				<CFSET sql_Sort_By="Product_Table.Item">
			</CFCASE>
			<CFCASE value="UPC">
				<CFSET sql_Sort_By="Product_Table.UPC">
			</CFCASE>
			<CFCASE value="Description">
				<CFSET sql_Sort_By="Product_Table.Description">
			</CFCASE>
			<CFCASE value="Prod Hierarchy">
				<CFSET sql_Sort_By="Product_Hierarchy.Product_Hierarchy">
			</CFCASE>
			<CFCASE value="Prod Hierarchy Name">
				<CFSET sql_Sort_By="Product_Hierarchy.Product_Hierarchy_Name">
			</CFCASE>
			<!--- Dev Note: Drachala; D27390: template product search tool and sorting START --->
			<CFCASE value="Business Segment">
				<CFSET sql_Sort_By="Bus_Seg.Business_Unit_Desc">
			</CFCASE>
		   <!--- Dev Note: Drachala; D27390: template product search tool and sorting END --->
		</CFSWITCH>
		<CFIF Super.variableExist("this.search.FromBBProgProdForm", "") AND this.search.FromBBProgProdForm EQ 1 AND appSettings.getUseProductHierarchy()>
			<CFIF sql_Sort_By NEQ "Product_Hierarchy.Product_Hierarchy" AND  sql_Sort_By NEQ "Product_Hierarchy.Product_Hierarchy_Name">
				<CFSET sql_Sort_By = "Product_Hierarchy.Product_Hierarchy">
			</CFIF>
		</CFIF>
		<CFSET sql_Sort_By_Order=" ASC">
		<CFIF this.search.sort_Order EQ "DESC">
			<CFSET sql_Sort_By_Order=" DESC">
		</CFIF>
		<cfif isDefined("this.search.GROUP_REBATE_TYPE_SEARCH_ID") and this.search.GROUP_REBATE_TYPE_SEARCH_ID GT 0>
			<cfset qGetProducts = this.getGroupProducts()/>
			<cfif isDefined("this.search.REBATETYPESELECTED") and this.search.REBATETYPESELECTED eq 3>
				<cfset groupHighestLevel = qGetProducts.max_pricing_level />
				<cfset qGetProducts = this.getGroupProductsWithHighestLevel()/>
			</cfif>
			<cfreturn qGetProducts />
		</cfif>

        <cfset this.search.bApplyPlannerTemplateFilter = 0 />
        <cfif isDefined("this.search.plannerId") and val(this.search.plannerId)>
            <cfset this.search.bApplyPlannerTemplateFilter = CreateObject("component", "mvc.Models.Planner.PlannerManager").tmp_planner_template_filter_products(this.search.plannerId) />
        </cfif>

		<cfif QueryMasterProductTable eq 1>
			<cfset qGetProducts = this.getItemsFromItemsMaster()/>
		<cfelse>
			<!------ Get Product ----->
			<!--- Query the Mini products table from the product Search --->
			<cfset qGetProducts = this.getItemsFromMiniItemsMaster()/>
        </cfif>

		<cfreturn qGetProducts />
    </cffunction>


	<cffunction name="getGroupProducts" returntype="query" access="public">
		<cfquery name="qGetGroupProducts" datasource="#application.datasource#">
			SELECT	DISTINCT
				 contract_products.BSA_Foodservice_Items_Master_ID,
				 case
				 	WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products'
				 	when Contract_Products.Product_Group_Level_ID = 8	then
						isnull(type_group_desc.type_group_desc,'N/A')
				 	<cfif appSettings.getUseProductHierarchy()>
				 	when Contract_Products.Product_Group_Level_ID >=2 and contract_products.product_group_level_id < 7 then
						isnull(Product_Hierarchy.Product_Hierarchy_Name, 'N/A')
					</cfif>
					<cfif isDefined("this.search.businessSegmentsOn") and isDefined("this.search.Business_Segment_ID")>
						<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
							<cfif appSettings.getClassCodesOn()>
								when contract_products.product_group_level_id = 10  then
									isnull(Class_Code.Class_Code_Desc, 'N/A')
							</cfif>
						</cfif>
					</cfif>
					else 'Group Products'
				 end as Description,
				'N/A' as Active_Code,
				'N/A' as Line_Of_Business_Name,
				'N/A' as Line_Of_Business,
				CASE
					WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
						'N/A'
					WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE Deleted = 0 AND Product_Group_Level_Type NOT IN (1,2,0)) THEN
						'Group Product'
					WHEN Contract_Products.Product_Group_Level_ID IN (SELECT Product_Group_Level_ID FROM Product_Group_Level WHERE Deleted = 0 AND Product_Group_Level_Type = 2) THEN
						Product_Hierarchy.Product_Hierarchy
					ELSE
						'Group Product'
				END As Item,
				'N/A' as UPC,
				'N/A' as Brand_Name,
				'N/A' as Q_Brand_ID,
				'N/A' as Q_Brand,
				'N/A' as Type_Code_Desc,
				type_group_desc.type_group_desc as Type_Group_Desc,
				0 as Catch_Weight,
				0 as Gross_Weight,
				0 as Net_Weight
				<cfif appSettings.getUseProductHierarchy()>
					,Product_Hierarchy.Product_Hierarchy,
					Product_Hierarchy.Product_Hierarchy_ID,
					Product_Hierarchy.Product_Hierarchy_Name
				</cfif>
				<cfif isDefined("this.search.businessSegmentsOn") and isDefined("this.search.Business_Segment_ID")>
					<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
						<cfif appSettings.getClassCodesOn()>
							,isnull(Class_Code.Class_Code_Desc, 'N/A') as Class_Code_Desc
						</cfif>
					</cfif>
				</cfif>
				,contract_products.pricing_level_id,
				(select max(contract_products.Pricing_Level_ID) from contract_products where deleted = 0 <CFIF Super.variableExist("this.search.DTPS_PROGRAM_ID", "")>and contract_main_id = #this.search.DTPS_PROGRAM_ID#</CFIF> and product_type_id = #this.search.GROUP_REBATE_TYPE_SEARCH_ID#) as max_pricing_level
			FROM	Contract_Products
			LEFT JOIN 	Business_Segment
					ON	Business_Segment.Deleted = 0
					AND	CAST(Business_Segment.Business_Segment_ID as nvarchar(50)) = Contract_Products.Product_Group_ID
			LEFT JOIN Product_Hierarchy
					ON Contract_Products.Product_Group_ID = Product_Hierarchy.Product_Hierarchy_ID
					AND Product_Hierarchy.Deleted = 0
			LEFT JOIN Type_Group_Desc
					ON Contract_Products.product_group_id = Type_Group_Desc.Type_Group_Desc_ID
			<cfif Super.variableExist("this.search.businessSegmentsOn", "") AND Super.variableExist("this.search.Business_Segment_ID", "")>
				<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
					<cfif appSettings.getClassCodesOn()>
						LEFT JOIN Class_Code
						ON Contract_Products.Product_Group_ID = class_code.class_code_uuid
					</cfif>
				</CFIF>
			</cfif>
			WHERE 	Contract_Products.Deleted = 0
			<CFIF Super.variableExist("this.search.DTPS_PROGRAM_ID", "")>
				AND	Contract_Products.Contract_Main_ID = #this.search.DTPS_PROGRAM_ID#
			</CFIF>
			AND		Contract_Products.product_type_id = #this.search.GROUP_REBATE_TYPE_SEARCH_ID#
			AND 	(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
		</cfquery>
		<cfreturn qGetGroupProducts />
	</cffunction>
	<cffunction name="getGroupProductsWithHighestLevel" returntype="query" access="public">
		<cfquery dbtype="query" name="qGetGroupProductsWithHighestLevel">
			select *
			from qGetGroupProducts
			<cfif isDefined("groupHighestLevel") and groupHighestLevel neq 0 and groupHighestLevel neq "">
				where pricing_level_id = #groupHighestLevel#
			</cfif>
		</cfquery>
		<cfreturn qGetGroupProductsWithHighestLevel />
	</cffunction>

	<cffunction name="getProductSearchWhereClause" returntype="string" access="public">
		<cfoutput>
		<cfsavecontent variable="sProductSearchWhereClause">
			<cfif Super.variableExist("this.search.ignoreMasterDeleted", "")>
				<cfif this.search.ignoreMasterDeleted NEQ 1>
				AND 	Product_Table.Deleted = 0
				</cfif>
			<cfelse>
			AND 	Product_Table.Deleted = 0
			</cfif>
			<cfif Super.variableExist("this.search.categoryList", "")>
				AND Product_Table.Category_ID IN(#replace(this.search.categoryList, "''", "'", "ALL")#)
			</cfif>
			<!--- Product_Status --->
			<CFIF Super.variableExist("this.search.Product_Status", "0")>
				<!---
					D50381: Need to filter to In-Active items Product Search/Anand Rao/21-May-2015
					If the page does not come from the create list only then include the Active_Code
				--->
				<cfif ((NOT (isDefined("FORM.Passed_Form") AND FORM.Passed_FORM EQ "comCreateListForm")) OR (isDefined("this.search.CalledFrom") AND this.search.calledFrom EQ "createList")) >
					AND Product_Table.Active_Code = '#this.search.Product_Status#'
				</cfif>
			</CFIF>
			<!------ Code for Create List ----->
			<!------ If create list, don't need to worry about other other filters ----->
			<!------ But restrictions should be put outside the else condition because it always applies ----->
			<cfif Super.variableExist("this.search.passed_form", "") AND Super.variableExist("this.search.itemList", "")>
				AND Product_Table.Item IN ( #PreserveSingleQuotes(this.search.itemList)# )
			<cfelse>
				<CFIF (Super.variableExist("this.search.Program_ID", "") AND NOT (isDefined("this.search.CalledFrom")))>
					AND Contract_Products.Contract_Main_ID IN(#this.search.Program_ID#)
					AND Contract_Products.Deleted = 0
					AND
						( /* -- start and */
							( /* --start Product_Type_ID = 1 */
								Contract_Products.Product_Type_ID = 1
								AND
									exists(
												SELECT Program_Fixed_Price_Product_Data_ID
												FROM Program_Fixed_Price_Product_Data
												WHERE len(Fixed_Price_Value) > 0 AND Deleted = 0 AND Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
											)

							) /* --end Product_Type_ID = 1 */
							OR
							( /* --start Product_Type_ID = 2 */
								Contract_Products.Product_Type_ID = 2
								AND
									exists	(
												SELECT Program_Rebates_Product_Data_ID
												FROM Program_Rebates_Product_Data
												WHERE /* --len(Rebate_Value) > 0 AND */
												Deleted = 0 AND Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
											)
							) /* --end Product_Type_ID = 2 */
							OR
								( /* --start Product_Type_ID = 3 */
									Contract_Products.Product_Type_ID = 3
									AND
										exists	(
													SELECT Program_Lump_Sum_Product_Data_ID
													FROM Program_Lump_Sum_Product_Data
													WHERE Deleted = 0 AND Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
												)

								)/* --end Product_Type_ID = 3 */
							OR
							( /* --start Product_Type_ID = 4 */
								Contract_Products.Product_Type_ID = 4
								AND
									exists	(
												SELECT	Program_Growth_Component_Product_Data.Contract_Products_ID
												FROM	Program_Growth_Component_Product_Data
												INNER JOIN	Program_Growth_Components
														ON 	Program_Growth_Component_Product_Data.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
												INNER JOIN	Program_Growth_Component_Tiers
														ON 	Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID
												INNER JOIN	Program_Growth_Component_Product_Tier_Data
														ON 	Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID
														AND Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID
												WHERE	(Program_Growth_Components.Deleted = 0)
												AND 	(Program_Growth_Component_Tiers.Tier_Number = N'1')
												AND 	(Program_Growth_Component_Tiers.Deleted = 0)
												AND 	(Program_Growth_Component_Product_Tier_Data.Deleted = 0)
												AND 	(Program_Growth_Component_Product_Data.Deleted = 0)
												AND 	(Program_Growth_Components.Deleted = 0)
												AND 	(LEN(Program_Growth_Component_Product_Tier_Data.Rate) > 0)
												AND 	Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
											)
							) /* --end Product_Type_ID = 4 */
							OR
							( /* --start Product_Type_ID = 5 */
								Contract_Products.Product_Type_ID = 5
								AND
									exists	(
												SELECT Program_Formula_Pricing_Rule_Product_ID
												FROM Program_Formula_Pricing_Rule_Products
												WHERE len(Price) > 0 AND Deleted = 0 AND Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
											)
							) /* --end Product_Type_ID = 5 */
							OR
							( /* --start Product_Type_ID = 10 */
								Contract_Products.Product_Type_ID = 10
								AND
									exists	(
												SELECT Program_Bid_Request_Product_ID
												FROM Program_Bid_Request_Product
												WHERE Program_Bid_Request_Product.Deleted = 0
												AND Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
											)
							) /* --end Product_Type_ID = 10 */
						) /* -- end */
					</cfif>
				</CFIF>

				<!---User permissions--->
				<!---Only execute this code in circumstances where there is a responsible user -- eg from programs--->

				<cfif isDefined("ResponsibleUser")>
					<cfif appsettings.getSalesOrgOn() IS 1>
						<!---LOB--->
						AND Product_Table.Line_of_Business_ID IN (SELECT Line_Of_Business_ID FROM User_LOB WHERE User_ID = '#ResponsibleUser#' AND Deleted = 0)
					</cfif>
					<cfif appsettings.getDistributionChannelOn() IS 1>
						<!---Type Code--->
						AND Product_Table.Type_Code_Desc_ID IN (SELECT Type_Code_ID FROM User_Type_Code WHERE User_ID = '#ResponsibleUser#' AND Deleted = 0)
					</cfif>
				</cfif>
				<!--- type group --->
				<CFIF Super.variableExist("this.search.Type_Group_Desc_ID", "0")>
					AND Product_Table.Type_Group_Desc_ID = '#this.search.Type_Group_Desc_ID#'
				</CFIF>
				<!--- type code --->
				<CFIF Super.variableExist("this.search.Type_Code_Desc_ID", "0")>
					AND Product_Table.Type_Code_Desc_ID = '#this.search.Type_Code_Desc_ID#'
				</CFIF>
				<!--- Q_Brand_ID --->
				<CFIF Super.variableExist("this.search.Q_Brand_ID", "0")>
					AND Q_Brand_Table.Q_Brand_ID = '#this.search.Q_Brand_ID#'
				</CFIF>
				<!--- Brand_ID --->
				<CFIF Super.variableExist("this.search.Brand_ID", "0")>
					AND Product_Table.Brand_ID = '#this.search.Brand_ID#'
				</CFIF>
				<!--- Line Of Business --->
				<CFIF Super.variableExist("this.search.Line_Of_Biz", "0")>
					AND Product_Table.Line_Of_Business_ID = '#this.search.Line_Of_Biz#'
				</CFIF>
				<!--- description search --->
				<CFIF Super.variableExist("this.search.Description_String", "")>
					AND Product_Table.Description 	like 	'%#preservesinglequotes(this.search.Description_String)#%'
				</CFIF>
				<!--- ITEM # search --->
				<CFIF Super.variableExist("this.search.item_number", "")>
				    <cfset this.search.item_number = trim(this.search.item_number)>

                    <cfparam name="this.search.match_type" default="">
                    <cfif this.search.match_type is "exact">
                        AND Product_Table.Item = '#preservesinglequotes(this.search.item_number)#'
                    <cfelse>
                        AND Product_Table.Item like '%#preservesinglequotes(this.search.item_number)#%'
                    </cfif>
				</CFIF>
				<!--- UPC search --->
				<CFIF Super.variableExist("this.search.upc_number", "")>
					AND Product_Table.UPC 	like 	'%#preservesinglequotes(this.search.upc_number)#%'
				</CFIF>
				<CFIF Super.variableExist("this.search.Rebate_Type_Search_ID", "")>
					<CFIF this.search.Rebate_Type_Search_ID NEQ 0>
						AND
						<CFIF listlen(trim(this.search.List_Of_Rebate_Product_ID)) GT 0>
							<!--- Product_Table.BSA_Foodservice_Items_Master_ID IN(#replace(this.search.List_Of_Rebate_Product_ID, "#chr(39)##chr(39)#", chr(39), "ALL")#) --->
							Contract_Products.Product_Type_ID = '#this.search.Rebate_Type_Search_ID#'
							AND Contract_Products.Contract_Main_ID = '#this.search.DTPS_PROGRAM_ID#'
							<!--- Dev Note:Milan; 11613. Include items not deleted --->
							AND Contract_Products.Deleted = 0
						<CFELSE>
							0=1
						</CFIF>
					</CFIF>
				</CFIF>
				<cfif isdefined("this.search.Only_Show_Products_From_These_Groups")>
					<cfif trim(this.search.Only_Show_Products_From_These_Groups) EQ 666>
						AND 0 = 1
					<cfelse>
						<cfif trim(this.search.Only_Show_Products_From_These_Groups) NEQ 0 AND trim(this.search.Only_Show_Products_From_These_Groups) NEQ "">
							AND <cfif application.returned_customer_setting.approval_on_type_code EQ 1>Product_Table.Type_Code_Desc_ID<cfelse>Product_Table.Type_Group_Desc_ID</cfif>
								IN(#listqualify(this.search.Only_Show_Products_From_These_Groups, "'")#)
						<cfelse><!--- nothing ---></cfif>
					</cfif>
				</cfif>
				<!------ class code search filter ----->
				<cfparam name="this.search.Search_Class_Code_ID" 	default="0">
				<CFIF this.search.Search_Class_Code_ID NEQ 0 AND this.search.Search_Class_Code_ID NEQ "">
					AND Product_Table.Class_Code_ID = '#this.search.Search_Class_Code_ID#'
				</CFIF>
				<!------ product hierarchy search filter ----->
				<cfif appSettings.getUseProductHierarchy()>
					<cfparam name="this.search.productHierarchyLevelList" 	default="">
					<cfloop list="#this.search.productHierarchyLevelList#" delimiters="," index="thisHierLevel">
						<cfif isDefined("this.search.Product_Hierarchy_#thisHierLevel#")>
						<CFIF Evaluate("this.search.Product_Hierarchy_#thisHierLevel#") NEQ 0>
							AND Product_Table.Product_Hierarchy_ID IN
							(
							SELECT 	Product_Hierarchy_ID
							FROM 	udf_GetProductChainBelow('#Evaluate("this.search.Product_Hierarchy_#thisHierLevel#")#')
							WHERE	Product_Hierarchy_Level = #this.search.maxProductHierarchyLevel#
							)
						</CFIF>
						</cfif>
					</cfloop>
				</cfif>
				<!------ End create list else ----->
				<!------ Add all restrictions here ----->
				<!------ Business Segment restriction ----->
				<cfif isDefined("this.search.businessSegmentsOn") and isDefined("this.search.Business_Segment_ID")>
					<!---
						Dev Notes: D27225: EZ Button Changes/Anand Rao
						Check if the EZTemplate value is 1 and Business_Segment_ID_List is present and is not
						null and if yes, then filter based on the Business_Segment_ID_List
					--->
					<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0 and ((isDefined("this.search.EZTemplate") and this.search.EZTemplate EQ 0) OR  NOT isDefined("this.search.EZTemplate"))>
						<cfif appSettings.getClassCodesOn()>
							<cfif IsDefined("this.search.UserClassCodes")>
							<cfif this.search.UserClassCodes neq "">
							AND Product_Table.class_code_id IN (#this.search.UserClassCodes#)
							<cfelse>
							AND 1=2
							</cfif>
							</cfif>
							AND class_code.Business_Segment_ID = #this.search.Business_Segment_Id#
						<cfelse>
							AND Product_Table.Business_Segment_ID = #this.search.Business_Segment_Id#
						</cfif>
					<cfelseif (isDefined("this.search.EZTemplate") AND this.search.EZTemplate EQ 1 AND isDefined("this.search.Business_Segment_ID_List") AND this.search.Business_Segment_ID_List NEQ "")>
							AND Product_Table.Business_Segment_ID IN (#this.search.Business_Segment_ID_List#)
					</cfif>

				</cfif>
				<!------ Line_Of_Business restriction ----->
				<cfif appsettings.getSalesOrgOn() and isDefined("this.search.Line_Of_Business_ID") and this.search.Line_Of_Business_ID NEQ "" and this.search.Line_Of_Business_ID NEQ "NULL">
					and Product_Table.Line_Of_Business_ID = '#this.search.Line_Of_Business_ID#'
				</cfif>

				<!------ Filter for all other active attribute drop downs ----->
				<!--- We need to filter the search results in 2 situations
				-- Tempalte is filtered on a product group
				-- A drop down value is selected
				--->
				<cfif isDefined("this.search.qGetProductGroupAttributesGroupTemplate")>
				<cfloop query="this.search.qGetProductGroupAttributesGroupTemplate">
					<cfset ProductAttributeDropDownName = "Product_Attribute_#this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />
					<cfset typeId = this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID />
					<cfif this.search.qGetProductGroupAttributesGroupTemplate.Allow_Filter>
						<!--- Template is filtered on a product group --->
						<cfif (this.search.qGetProductGroupAttributesGroupTemplate.PG_Flag EQ 0) AND (this.search.qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field NEQ "PG_Product_Category_ID")>
					    AND CAST(Product_Table.#this.search.qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field# as varchar(50))
							IN (SELECT Product_group_ID FROM Product_Group_Template_Selection
								WHERE Deleted = 0 AND Active = 1 AND
									PG_Flag = 0 AND
									Template_ID = #this.search.FirstParentID# AND
									Product_Group_Level_ID = #this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID#)
             			<cfelse>
             			<!--- Planning groups / Anand Rao/10-Jan-2011 --->
                		AND PGPM_#typeId#.PG_Product_Category_ID IN (SELECT Product_group_ID FROM Product_Group_Template_Selection WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 1 AND Template_ID = #this.search.FirstParentID# AND Product_Group_Level_ID = #this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID#)
						AND PGPM_#typeId#.PG_Type_ID = #typeId#
             			</cfif>
					</cfif>
					<cfif isDefined("this.search.#ProductAttributeDropDownName#")>
						<cfset ProductAttributeDropDownValue = Evaluate("this.search.#ProductAttributeDropDownName#") />
						<cfif ProductAttributeDropDownValue NEQ "" AND ProductAttributeDropDownValue NEQ "0">
							<!--- A drop down value is selected --->
							<cfif (this.search.qGetProductGroupAttributesGroupTemplate.PG_Flag EQ 0) AND (this.search.qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field NEQ "PG_Product_Category_ID")>
						    AND Product_Table.#this.search.qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field# = '#ProductAttributeDropDownValue#'
	             			<cfelse>
	             			<!--- Planning groups / Anand Rao/10-Jan-2011 --->
	                		AND PGPM_#typeId#.#this.search.qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field# = '#ProductAttributeDropDownValue#'
	             			</cfif>
						</cfif>
					</cfif>
       			</cfloop>
				</cfif>

				<!------ Add to product query for restrict on product group ----->
				<cfparam name="this.search.restrictOnProductGroup" 	default="0">
				<cfparam name="this.search.restrictOnProductGroupList" 	default="">
				<cfif this.search.restrictOnProductGroup EQ "1" AND isDefined("this.search.approvalGroupType")>
					AND
					<cfif Len(restrictOnProductGroupList) EQ 0>1=2
					<cfelseif this.search.approvalGroupType.groupLevelType EQ 5>Q_Brand_Table.#this.search.approvalGroupType.productGroupIDField# IN (#ListQualify(restrictOnProductGroupList, "'", ",")#)
					<cfelse>Product_Table.#this.search.approvalGroupType.MasterIDField# IN (#ListQualify(restrictOnProductGroupList, "'", ",")#)
					</cfif>
				</cfif>
				<!------ Add to product query for restrict on product group for each profile ----->
				<cfparam name="this.search.restrictOnProfileProductGroup" 	default="0">
				<cfparam name="this.search.restrictOnModifyingProductGroupList" 	default="">
				<cfif this.search.restrictOnProfileProductGroup EQ "1" AND isDefined("this.search.approvalGroupType")>
					AND
					<cfif Len(restrictOnModifyingProductGroupList) EQ 0>0=0
					<cfelseif this.search.approvalGroupType.groupLevelType EQ 5>Q_Brand_Table.#this.search.approvalGroupType.productGroupIDField#  NOT IN (#ListQualify(restrictOnModifyingProductGroupList, "'", ",")#)
					<cfelse>Product_Table.#this.search.approvalGroupType.MasterIDField# NOT IN (#ListQualify(restrictOnModifyingProductGroupList, "'", ",")#)
					</cfif>
				</cfif>
				<!------ Add operating group restriction ----->
				<cfif isDefined("this.search.operatingGroupProductGroupFilter") AND isArray(this.search.operatingGroupProductGroupFilter)>
					<cfset operatingGroupProductGroupFilterArrayLen = ArrayLen(this.search.operatingGroupProductGroupFilter) />
					<cfloop index="counter" from="1" to="#operatingGroupProductGroupFilterArrayLen#">
						<cfset thisOperatingGroupProductGroupFilter = this.search.operatingGroupProductGroupFilter[counter] />
						<cfif thisOperatingGroupProductGroupFilter.Group_ID EQ "">AND 1=2
						<cfelseif thisOperatingGroupProductGroupFilter.productGroupType.groupLevelType EQ 5>
						AND Q_Brand_Table.#thisOperatingGroupProductGroupFilter.productGroupType.productGroupIDField# IN (#ListQualify(thisOperatingGroupProductGroupFilter.Group_ID, "'", ",")#)
						<cfelse>
						AND Product_Table.#thisOperatingGroupProductGroupFilter.productGroupType.MasterIDField# IN (#ListQualify(thisOperatingGroupProductGroupFilter.Group_ID, "'", ",")#)
						</cfif>
					</cfloop>
				</cfif>
				<!------ Operating group restriction end ----->
				<!------ Add to product query for restrict on product group ----->
				<CFIF IsDefined("this.search.Product_Hierarchy_ID")>
					AND Product_Hierarchy.Product_Hierarchy_ID = '#this.search.Product_Hierarchy_ID#'
				</CFIF>
				<CFIF IsDefined("this.search.BSA_Foodservice_Items_Master_ID")>
					AND Product_Table.BSA_Foodservice_Items_Master_ID = '#this.search.BSA_Foodservice_Items_Master_ID#'
				</CFIF>
				<cfif IsDefined("this.search.exclude_sig_products")>
					<cfif this.search.exclude_sig_products EQ 1>
						AND Product_Table.specialty_product = 0
					</cfif>
				</cfif>
				<cfif isdefined("this.search.EZButton_On")>
					<cfif this.search.EZButton_On EQ 1>
						<cfif isdefined("this.search.EZButtonProductList") AND (isdefined("this.search.Filter_EZButton_Products") AND this.search.Filter_EZButton_Products EQ 1)>
							<cfif Len(this.search.EZButtonProductList) EQ 0>
							AND 1 = 2
							<cfelse>
							AND Product_Table.BSA_Foodservice_Items_Master_ID IN
							(#ListQualify(this.search.EZButtonProductList, "'", ",")#)
							</cfif>
						</cfif>
					</cfif>
				</cfif>
                <cfif isdefined("this.search.bApplyPlannerTemplateFilter")>
                    <cfif this.search.bApplyPlannerTemplateFilter>
                        AND Product_Table.BSA_Foodservice_Items_Master_ID IN (SELECT Product_ID FROM ##tmp_planner_template_filter_products)
                    </cfif>
                </cfif>
			</cfsavecontent>
			</cfoutput>

			<cfreturn sProductSearchWhereClause />
	</cffunction>

	<cffunction name="getItemsFromItemsMaster" returntype="query" access="public">

        <cfquery datasource="#application.datasource#">
            IF OBJECT_ID('TEMPDB..##TMP_BSA_Foodservice_Items_Master') IS NOT NULL
                DROP TABLE ##TMP_BSA_Foodservice_Items_Master
        </cfquery>

		<cfquery name="qGetItemsFromItemsMaster" datasource="#application.datasource#" result="qResult"><!--- cachedwithin="#this.cacheSpan#" --->
			SELECT DISTINCT
				Product_Table.BSA_Foodservice_Items_Master_ID,  Product_Table.Description, Product_Table.Active_Code,Line_Of_Business.Line_Of_Business_Name,Line_Of_Business.Line_Of_Business,
				Product_Table.Type_Group_Desc_ID, Product_Table.UPC, Product_Table.Item,
				Type_Code_Desc.Type_Code_Desc, Brand.Brand_Name,
				Q_Brand_Table.Q_Brand_ID,Q_Brand_Table.Q_Brand, Type_Group_Desc.Type_Group_Desc,
				Product_Table.Catch_Weight, Product_Table.Gross_Weight,
				Product_Table.Net_Weight,
				<!--- Development Note: KAL on 06/13/05;  Added below lines of addtional columns as per D6923  --->
				Product_Table.Inven_UoM, Product_Table.Shelf_Life, Product_Table.Length, Product_Table.Width, Product_Table.Height,
				Product_Table.Cases_Layer, Product_Table.Layers_Pallet, Product_Table.Cases_Pallet, Product_Table.Case_Cube

				<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
					,Bus_Seg.Business_Unit_Desc
				</cfif>

				<cfif appSettings.getUseProductHierarchy()>,Product_Hierarchy.Product_Hierarchy,Product_Hierarchy.Product_Hierarchy_ID,Product_Hierarchy.Product_Hierarchy_Name</cfif>
				<cfif isDefined("this.search.businessSegmentsOn") and isDefined("this.search.Business_Segment_ID")>
					<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
						<cfif appSettings.getClassCodesOn()>,Class_Code.Class_Code_Desc</cfif>
					</cfif>
                </cfif>
            INTO ##TMP_BSA_Foodservice_Items_Master
			FROM	BSA_Foodservice_Items_Master Product_Table
			INNER JOIN Line_Of_Business
					ON Line_Of_Business.Line_Of_Business_ID = Product_Table.Line_Of_Business_ID
			INNER JOIN Type_Code_Desc
					ON Product_Table.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
			INNER JOIN Brand
					ON Product_Table.Brand_ID = Brand.Brand_ID
     <!--- Planning groups / Anand Rao / 10-Jan-2011 --->
		<cfif isDefined("this.search.qGetProductGroupAttributesGroupTemplate")>
			<cfloop query="this.search.qGetProductGroupAttributesGroupTemplate">

				<!--- We need to filter the search results in 2 situations
				-- Tempalte is filtered on a product group
				-- A drop down value is selected
				 --->
				<!--- do this only for planning groups --->
				<!--- Below logic is to add extra JOINs on planning group tables so that we can filter later in the where clause --->
				<cfif this.search.qGetProductGroupAttributesGroupTemplate.PG_Flag>
					<cfset typeId = this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID />
					<cfset applyThisGroupInFilter = 0 />
					<cfset ProductAttributeDropDownName = "Product_Attribute_#this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />

					<cfif this.search.qGetProductGroupAttributesGroupTemplate.Allow_Filter><!--- Tempalte is filtered on a product group --->
						<cfset applyThisGroupInFilter = 1 />
					<cfelseif isDefined("this.search.#ProductAttributeDropDownName#")>
						<cfset ProductAttributeDropDownValue = Evaluate("this.search.#ProductAttributeDropDownName#") />
						<cfif ProductAttributeDropDownValue NEQ "" AND ProductAttributeDropDownValue NEQ "0"><!--- A drop down value is selected --->
			                <cfset applyThisGroupInFilter = 1 />
						</cfif>
					</cfif>
					<cfif applyThisGroupInFilter>
						INNER JOIN PG_Product_Members as PGPM_#typeId#
		                ON		PGPM_#typeId#.BSA_Foodservice_Items_Master_ID = Product_Table.BSA_Foodservice_Items_Master_ID
		                INNER JOIN PG_Product_Category as PGPC_#typeId#
		                ON		PGPC_#typeId#.PG_Product_Category_ID = PGPM_#typeId#.PG_Product_Category_ID
						<!---AND 		PGPC_#typeId#.PG_Type_ID = PGPM_#typeId#.PG_Type_ID
						INNER JOIN PG_Product_Category_Definition PGPCD_#typeId#
						ON PGPCD_#typeId#.Product_Group_ID =  Cast(CONVERT(varchar(50), PGPM_#typeId#.BSA_Foodservice_Items_Master_ID) AS VARCHAR(50))
						AND  PGPCD_#typeId#.PG_Product_Category_ID = PGPC_#typeId#.PG_Product_Category_ID
						AND PGPCD_#typeId#.PG_Type_ID = PGPC_#typeId#.PG_Type_ID--->
					</cfif>
				</cfif>
        	</cfloop>
		</cfif>

				<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
			 	LEFT JOIN Business_Segment Bus_Seg
					ON Bus_Seg.Business_Segment_ID = Product_Table.Business_Segment_ID
				</cfif>

			<cfif application.returned_customer_setting.use_product_q_brand EQ 1>
				INNER JOIN	Product_Q_Brand_Desc
						ON 	Product_Table.BSA_Foodservice_Items_Master_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
						AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
				INNER JOIN	Q_Brand_Desc Q_Brand_Table
						ON Product_Q_Brand_Desc.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
			<cfelse>
				INNER JOIN	Q_Brand_Desc Q_Brand_Table
						ON 	Product_Table.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
			</cfif>
	        INNER JOIN	Type_Group_Desc
					ON Product_Table.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
	        <CFIF ( NOT (isDefined("this.search.CalledFrom") AND this.search.calledFrom EQ "createList")  AND Super.variableExist("this.search.Program_ID", "") )or ( isDefined("this.search.List_Of_Rebate_Product_ID") and listlen(trim(this.search.List_Of_Rebate_Product_ID)) GT 0)>
		        <cfif appSettings.getProductReplacementEnabled() and Super.variableExist("this.search.Program_ID", "")>
			    <!---
			    D13872 JRS -Identify how to handle BB purchase validation when sku number changes
			    If product replacement is set in the settings panel to product A = Product B
			    When user searches for products inside billbacks for a program which just has Product A, return Product B also additionally.
			    --->
		        LEFT JOIN Item_Replacement
		        ON	Item_Replacement.Original_Item_ID = Product_Table.BSA_Foodservice_Items_Master_ID
				AND	Item_Replacement.Deleted = 0
				</cfif>
				INNER JOIN Contract_Products
						ON (Product_Table.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						<cfif appSettings.getProductReplacementEnabled() and Super.variableExist("this.search.Program_ID", "")>
						OR	Item_Replacement.Replacement_Item_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						</cfif>
						)
			</CFIF>
			<cfif appSettings.getUseProductHierarchy()>
				LEFT JOIN Product_Hierarchy
						ON	Product_Table.Product_Hierarchy_ID = Product_Hierarchy.Product_Hierarchy_ID
						AND	Product_Hierarchy.Deleted = 0
			</cfif>
			<cfif Super.variableExist("this.search.businessSegmentsOn", "") AND Super.variableExist("this.search.Business_Segment_ID", "")>
				<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
					<cfif appSettings.getClassCodesOn()>
						INNER JOIN Class_Code
								ON Product_Table.class_code_id = class_code.class_code_id
					</cfif>
				</CFIF>
			</cfif>

			<!--- D11212 Distributor Product Integrity --->
			<cfif appsettings.getDistributor_Product_Integrity_On() IS 1 AND RestrictByRule IS 1>
			INNER JOIN Distributor_Product_Integrity_Products
						ON Distributor_Product_Integrity_Products.Product_ID = Product_Table.BSA_Foodservice_Items_Master_ID
						AND Distributor_Product_Integrity_Products.Deleted = 0
						AND Distributor_Product_Integrity_Products.Distributor_Product_Integrity_Rule_ID = '#GetRuleID.Distributor_Product_Integrity_Rule_ID#'
			</cfif>

			WHERE	0=0
			<!--- The common where clause conditions for both Mian and Mini Item maste is to be added inside the function getProductSearchWhereClause()  --->
			<cfset productSearchWhereClause = getProductSearchWhereClause() />
			#preserveSingleQuotes(productSearchWhereClause)#
			<!---------------------------------- Add Main Item Master Query specific conditions here  ------------------->
				<!------ TODO ----->
				<CFIF Super.variableExist("this.search.SHOW_INVOICE_FILTER", "") AND Super.variableExist("this.search.SHOW_INVOICE_FILTER", "0")>
					<CFPARAM NAME="this.search.Ship_To" DEFAULT="">
					<CFIF ((Super.variableExist("this.search.Distributor", "") AND Super.variableExist("this.search.Distributor", "0")) OR Super.variableExist("this.search.Ship_To", ""))
						<!--- AND Super.variableExist("this.search.Invoice_Days", "")--->OR Super.variableExist("Distributor_List", "")>
						AND EXISTS ( SELECT 1 FROM Product_Customer_Group_Invoice WHERE Customer_ID IN (#ListQualify(Distributor_List, "'")#) AND Product_ID = Product_Table.BSA_Foodservice_Items_Master_ID )
					</CFIF>
				</CFIF>
				<CFPARAM NAME="this.search.Prod_Name" 	DEFAULT="">
				<CFIF this.search.Prod_Name neq "">
					AND Product_Table.Description like '#this.search.Prod_Name#%'
				</CFIF>

			<!---------------------------------- Main Item Master Query specific conditions - End  ------------------->

                <cfparam name="this.search.include_companion" default="0">
                /* remmove alias from sort by variable (i.e. Type_Group_Desc.Type_Group_Desc would become Type_Group_Desc) */
                <cfset sql_Sort_By = listLast(sql_Sort_By,'.')>

                <cfif this.search.include_companion neq '1'>
                    SELECT * FROM ##TMP_BSA_Foodservice_Items_Master Product_Table
                <cfelse>
                    /* gather additional companion items based on selected items */
                    SELECT *
                    FROM ##TMP_BSA_Foodservice_Items_Master
                    UNION
                    SELECT DISTINCT
                        Product_Table.BSA_Foodservice_Items_Master_ID,
                        Product_Table.Description,
                        Product_Table.Active_Code,
                        Line_Of_Business.Line_Of_Business_Name,
                        Line_Of_Business.Line_Of_Business,
                        Product_Table.Type_Group_Desc_ID,
                        Product_Table.UPC,
                        Product_Table.Item,
                        Type_Code_Desc.Type_Code_Desc,
                        Brand.Brand_Name,
                        Q_Brand_Table.Q_Brand_ID,
                        Q_Brand_Table.Q_Brand,
                        Type_Group_Desc.Type_Group_Desc,
                        Product_Table.Catch_Weight,
                        Product_Table.Gross_Weight,
                        Product_Table.Net_Weight,
                        Product_Table.Inven_UoM,
                        Product_Table.Shelf_Life,
                        Product_Table.Length,
                        Product_Table.Width,
                        Product_Table.Height,
                        Product_Table.Cases_Layer,
                        Product_Table.Layers_Pallet,
                        Product_Table.Cases_Pallet,
                        Product_Table.Case_Cube
                    FROM BSA_Foodservice_Items_Master Product_Table
                        INNER JOIN Line_Of_Business
                            ON Line_Of_Business.Line_Of_Business_ID = Product_Table.Line_Of_Business_ID
                        INNER JOIN Type_Code_Desc
                            ON Product_Table.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
                        INNER JOIN Brand
                            ON Product_Table.Brand_ID = Brand.Brand_ID
                        INNER JOIN Q_Brand_Desc Q_Brand_Table
                            ON Product_Table.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
                        INNER JOIN Type_Group_Desc
                            ON Product_Table.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
                    WHERE Product_Table.Deleted = 0
                        AND Product_Table.Active_Code = 'A'
                        AND Product_Table.Item IN
                            (
                                SELECT DISTINCT Companion_Item.Companion_Item
                                  FROM Companion_Item
                                        JOIN ##TMP_BSA_Foodservice_Items_Master ON ##TMP_BSA_Foodservice_Items_Master.Type_Code_Desc = Companion_Item.Type_Code_Desc
                                WHERE Companion_Item.Deleted = 0
                            )
                </cfif>

                <cfif isdefined("sql_Sort_By") AND isdefined("sql_Sort_By_Order")>
                    ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
                </cfif>
            </cfquery>

			<cfreturn qGetItemsFromItemsMaster />
	</cffunction>

	<cffunction name="getItemsFromMiniItemsMaster" returntype="query" access="public" output="false">

		<cfquery name="qGetItemsFromMiniItemsMaster" datasource="#application.datasource#" >
			SELECT DISTINCT
	 			Product_Table.BSA_Foodservice_Items_Master_ID,  Product_Table.Description, Product_Table.Active_Code,Line_Of_Business.Line_Of_Business_Name,Line_Of_Business.Line_Of_Business,
	            Product_Table.Type_Group_Desc_ID, Product_Table.UPC, Product_Table.Item,
				Type_Code_Desc.Type_Code_Desc, Brand.Brand_Name,
				Q_Brand_Table.Q_Brand_ID,Q_Brand_Table.Q_Brand, Type_Group_Desc.Type_Group_Desc,
				Product_Table.Catch_Weight, Product_Table.Gross_Weight,
				Product_Table.Net_Weight
				<cfif appSettings.getUseProductHierarchy()>,Product_Hierarchy.Product_Hierarchy,Product_Hierarchy.Product_Hierarchy_ID,Product_Hierarchy.Product_Hierarchy_Name</cfif>
				<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
					,Bus_Seg.Business_Unit_Desc
				</cfif>
				<cfif isDefined("this.search.businessSegmentsOn") and isDefined("this.search.Business_Segment_ID")>
					<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
						<cfif appSettings.getClassCodesOn()>,Class_Code.Class_Code_Desc</cfif>
					</cfif>
				</cfif>

			FROM	BSA_Mini_Item_Master Product_Table
			INNER JOIN Line_Of_Business
					ON Line_Of_Business.Line_Of_Business_ID = Product_Table.Line_Of_Business_ID
			INNER JOIN Type_Code_Desc
					ON Product_Table.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID
			INNER JOIN Brand
					ON Product_Table.Brand_ID = Brand.Brand_ID
			<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
			 	LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = Product_Table.Business_Segment_ID
			</cfif>

     		<cfif isDefined("this.search.qGetProductGroupAttributesGroupTemplate")>
				<cfloop query="this.search.qGetProductGroupAttributesGroupTemplate">
	          		<!--- We need to filter the search results in 2 situations
					-- Tempalte is filtered on a product group
					-- A drop down value is selected
					 --->
					<!--- do this only for planning groups --->
					<!--- Below logic is to add extra JOINs on planning group tables so that we can filter later in the where clause --->
					<cfset typeId = this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID />
					<cfset ProductAttributeDropDownName = "Product_Attribute_#this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />

					<cfif this.search.qGetProductGroupAttributesGroupTemplate.PG_Flag>
					<cfset applyThisGroupInFilter = 0 />
					<cfset ProductAttributeDropDownName = "Product_Attribute_#this.search.qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />

					<cfif this.search.qGetProductGroupAttributesGroupTemplate.Allow_Filter><!--- Tempalte is filtered on a product group --->
						<cfset applyThisGroupInFilter = 1 />
					<cfelseif isDefined("this.search.#ProductAttributeDropDownName#")>
						<cfset ProductAttributeDropDownValue = Evaluate("this.search.#ProductAttributeDropDownName#") />
						<cfif ProductAttributeDropDownValue NEQ "" AND ProductAttributeDropDownValue NEQ "0"><!--- A drop down value is selected --->
			                <cfset applyThisGroupInFilter = 1 />
						</cfif>
					</cfif>
					<cfif applyThisGroupInFilter>
						INNER JOIN PG_Product_Members as PGPM_#typeId#
		                ON		PGPM_#typeId#.BSA_Foodservice_Items_Master_ID = Product_Table.BSA_Foodservice_Items_Master_ID
		                INNER JOIN PG_Product_Category as PGPC_#typeId#
		                ON		PGPC_#typeId#.PG_Product_Category_ID = PGPM_#typeId#.PG_Product_Category_ID
					</cfif>
				</cfif>
        		</cfloop>
			</cfif>

			<cfif application.returned_customer_setting.use_product_q_brand EQ 1>
				INNER JOIN	Product_Q_Brand_Desc
						ON 	Product_Table.BSA_Foodservice_Items_Master_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
						AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
				INNER JOIN	Q_Brand_Desc Q_Brand_Table
						ON Product_Q_Brand_Desc.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
			<cfelse>
				INNER JOIN	Q_Brand_Desc Q_Brand_Table
						ON 	Product_Table.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
			</cfif>
	        INNER JOIN	Type_Group_Desc
					ON Product_Table.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
	        <CFIF Super.variableExist("this.search.Program_ID", "")>
				INNER JOIN Contract_Products
						ON Product_Table.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			</CFIF>
			<cfif appSettings.getUseProductHierarchy()>
				LEFT JOIN Product_Hierarchy
						ON	Product_Table.Product_Hierarchy_ID = Product_Hierarchy.Product_Hierarchy_ID
						AND	Product_Hierarchy.Deleted = 0
			</cfif>
			<cfif Super.variableExist("this.search.businessSegmentsOn", "") AND Super.variableExist("this.search.Business_Segment_ID", "")>
				<cfif this.search.businessSegmentsOn eq 1 and this.search.Business_Segment_ID neq 0>
					<cfif appSettings.getClassCodesOn()>
						INNER JOIN Class_Code
								ON Product_Table.class_code_id = class_code.class_code_id
					</cfif>
				</CFIF>
			</cfif>
			<CFPARAM NAME="this.search.Ship_To" DEFAULT="">
			<CFIF this.search.Ship_To NEQ "">
				INNER JOIN BSA_Foodservice_Customers
						ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Product_Table.Customer_ID
			</CFIF>

			<!--- D11212 Distributor Product Integrity --->
			<cfif appsettings.getDistributor_Product_Integrity_On() IS 1 AND RestrictByRule IS 1>
			INNER JOIN Distributor_Product_Integrity_Products
						ON Distributor_Product_Integrity_Products.Product_ID = Product_Table.BSA_Foodservice_Items_Master_ID
						AND Distributor_Product_Integrity_Products.Deleted = 0
						AND Distributor_Product_Integrity_Products.Distributor_Product_Integrity_Rule_ID = '#GetRuleID.Distributor_Product_Integrity_Rule_ID#'
			</cfif>
			WHERE	0=0
			<!--- The common where clause conditions for both Mian and Mini Item maste is to be added inside the function getProductSearchWhereClause()  --->
			<cfset productSearchWhereClause = getProductSearchWhereClause() />
			#preserveSingleQuotes(productSearchWhereClause)#
			<!---------------------------------- Add Mini Item Master Query specific conditions here  ------------------->
				<!------ TODO ----->
				<CFIF (((Super.variableExist("this.search.Distributor", "") AND Super.variableExist("this.search.Distributor", "0")) OR Super.variableExist("this.search.Ship_To", ""))) OR variableExist("Distributor_List")>
					<CFIF this.search.Ship_To NEQ "">
						AND BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#this.search.Ship_To#%'
					</CFIF>
					<!--- WHERE --->
					<CFIF (Super.variableExist("this.search.Distributor", "") AND Super.variableExist("this.search.Distributor", "0"))>
						AND Product_Table.Customer_ID = '#this.search.Distributor#'
					</CFIF>
					<CFIF (Super.variableExist("Distributor_List", "") AND Super.variableExist("Distributor_List", "0"))>
						AND EXISTS ( SELECT 1 FROM Product_Customer_Group_Invoice WHERE Customer_ID IN (#ListQualify(Distributor_List, "'")#) AND Product_ID = Product_Table.BSA_Foodservice_Items_Master_ID)
					</CFIF>
				</CFIF>

				<CFPARAM NAME="this.search.Prod_Name" 	DEFAULT="">
				<CFIF this.search.Prod_Name neq "">
					AND Product_Table.Description like '#this.search.Prod_Name#%'
				</CFIF>
			<!---------------------------------- Mini Item Master Query specific conditions - End  ------------------->
				<cfif isdefined("sql_Sort_By") AND isdefined("sql_Sort_By_Order")>
					ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
				</cfif>
		</cfquery>
		<cfreturn qGetItemsFromMiniItemsMaster />
	</cffunction>

	<cffunction name="getUOMId" output="false" returntype="numeric">
		<cfargument name="UOMString" type="string" required="true" />

		<cfset returnUOM = 1 />
		<cfif UCase(Trim(arguments.UOMString)) EQ "LB">
			<cfset returnUOM = 2 />
		</cfif>
		<cfreturn returnUOM />
	</cffunction>

		<cffunction name="getproducts" output="false" returntype="query">
		<cfargument name="product_list" type="string" required="true" />
		<cfquery name="qGetProducts" datasource="#application.datasource#">
			select item,BSA_Foodservice_Items_Master_ID,description
			<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
				,Bus_Seg.Business_Unit_Desc
			</cfif>
			from BSA_Foodservice_Items_Master
			<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
				LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Items_Master.Business_Segment_ID
			</cfif>
			where 0 = 0
			<cfif listlen(arguments.product_list) GT 0>
						and BSA_Foodservice_Items_Master_ID IN (#listqualify(arguments.product_list, "'")#)
					<cfelse>
							and 1	=	2
					</cfif>

		</cfquery>
			<cfreturn qGetProducts />
	</cffunction>

	<cffunction name="setDeleteSimilarExistingProduct" output="false">
		<cfargument name="ProgramID" type="string" required="true"/>
		<cfargument name="ProductID" required="true"/>
			<cfset useLakebaseForqsetDeleteSimilarExistingProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("similar_existing_product")>
<cfif useLakebaseForqsetDeleteSimilarExistingProduct>
	<cftry>
		<cfset application.oLakebase.updateRows("similar_existing_product",
			{
				"contract_main_id" = "eq.#arguments.ProgramID#",
				"bsa_foodservice_items_master_id" = "eq.#arguments.ProductID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqsetDeleteSimilarExistingProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqsetDeleteSimilarExistingProduct>
<cfquery name="qsetDeleteSimilarExistingProduct" datasource="#application.datasource#">
			  UPDATE Similar_Existing_Product
			  SET Deleted = 1
			  WHERE Contract_Main_ID = '#arguments.ProgramID#'
			  AND BSA_Foodservice_Items_Master_ID = '#arguments.ProductID#'
		   </cfquery>
</cfif>
	</cffunction>

	<cffunction name="setSimilarExistingProduct" output="false">
		<cfargument name="ProgramID" type="string" required="true" />
		<cfargument name="Like_Product"  required="true" default=""/>
		  <cfif arguments.Like_Product neq "">
		    <cfquery name="qsetDeleteSimilarExistingProduct" datasource="#application.datasource#">
			  INSERT INTO Similar_Existing_Product
			  (Contract_Main_ID, BSA_Foodservice_Items_Master_ID)
			  VALUES
			  ('#arguments.ProgramID#', '#arguments.Like_Product#')
		   </cfquery>
		 </cfif>
	</cffunction>

	<cffunction name="getSimilarExistingProduct" output="false" returntype="query">
		<cfargument name="ProgramID" type="string" required="true" />
		<cfargument name="ProdID" required="true" default=""/>
		<cfquery name="qgetSimilarExistingProduct" datasource="#application.datasource#">
			SELECT BSA_Foodservice_Items_Master_ID
			FROM Similar_Existing_Product
			WHERE Contract_Main_ID = '#arguments.ProgramID#'
			<cfif ProdID neq "">
			AND BSA_Foodservice_Items_Master_ID = '#arguments.ProdID#'
			</cfif>
			AND Deleted = 0
		</cfquery>
			<cfreturn qgetSimilarExistingProduct />
	</cffunction>

	<cffunction name="getProductUOM" output="false" returntype="query">

		<cfargument name="EZProgramID" type="string" required="true" />
		<cfargument name="ProdID" required="true" default=""/>

		<cfquery name="qgetProductUOM" datasource="#application.datasource#">
			select      Program_Rebates_Component_Data.Unit_Of_Measure_Id
			from  contract_products
			inner join Program_Rebates_Product_Data
			on    Program_Rebates_Product_Data.contract_products_id = contract_products.contract_products_id
			and Program_Rebates_Product_Data.deleted = 0
			and contract_products.contract_main_id =  Program_Rebates_Product_Data.program_id
			inner join Program_Rebates_Component_Data
			on    Program_Rebates_Component_Data.Program_Rebates_Product_Data_id = Program_Rebates_Product_Data.Program_Rebates_Product_Data_Id
			and Program_Rebates_Component_Data.deleted = 0
			where Contract_Products.Contract_Main_ID =  '#arguments.EZProgramID#'
			and contract_products.product_type_id = 2
			AND contract_products.deleted = 0
			and   Contract_Products.BSA_Foodservice_Items_Master_ID =  '#arguments.ProdID#'
		</cfquery>
			<cfreturn qgetProductUOM />
	</cffunction>

	<cffunction name="populateProductGroupMembers" access="public" returntype="void" output="true">
		<cfargument name="programId" type="string" required="true" />
		<cfquery name="qPopulateProductGroupMembers" datasource="#application.datasource#">
			EXEC SP_CAPTURE_ALL_FOR_GROUPS <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</cffunction>
</cfcomponent>