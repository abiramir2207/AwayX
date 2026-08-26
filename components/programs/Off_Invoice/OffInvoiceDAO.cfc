<!--- OffInvoiceDAO.cfc --->
<cfcomponent>

	<cffunction name="getOIProgramProducts" output="false">
	
		<cfargument name="contractMainId" default="0" required="true" type="numeric" />
		<cfargument name="sortBy" default="" required="false" type="string" />
		<cfargument name="negPos" type="numeric" required="false" default="-1" />
		<cfargument name="useProductQBrand" default="0" required="false" />
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />
		
		<cfset GroupDataManager = CreateObject("component","components.products.Group.DataManager") />
		<!---check for groups, if we have any then we have to filter on Is_Group--->
		<cfset qCheckForGroup = GroupDataManager.getGroupsForProgram(arguments.contractMainId, 8) />
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		<!------ Load From DB ----->
		<CFQUERY NAME="qGetOIProgramProducts" datasource="#application.datasource#">
			SELECT 	TOP 100 PERCENT 
					Contract_Products.Contract_Products_ID, 
					Contract_Products.Product_Group_Level_ID, 
					Contract_Products.Product_Group_ID,
					Contract_Products.Is_Group, 
					Contract_Products.Dynamic_Static_Groups,
					Contract_Products.Pricing_Level_ID,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					<cfif displayGroupType EQ 3><!------ Q Brand ----->
					CASE
						WHEN Q_Brand_Desc.Q_brand IS NULL THEN
							'N/A'
						ELSE
							Q_Brand_Desc.Q_brand
					END AS DisplayGroupName,
					<cfelseif displayGroupType EQ 1><!------ Type Code ----->
					CASE
						WHEN Type_Code_Desc.Type_Code_Desc IS NULL THEN
							'N/A'
						ELSE
							Type_Code_Desc.Type_Code_Desc
					END AS DisplayGroupName,
					<cfelse>
					Type_Code_Desc.Type_Code_Desc AS DisplayGroupName,
					</cfif>
					
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
							'N/A'
						ELSE
							BSA_Foodservice_Items_Master.UPC
					END As UPC, 
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
							''
						WHEN Product_Group_Level.Product_Group_Level_Type = 2 THEN
							Product_Hierarchy.Product_Hierarchy
						ELSE
							BSA_Foodservice_Items_Master.Item
					END As Item,
					CASE 
						WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
							'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products'
						ELSE
							BSA_Foodservice_Items_Master.Description
					END As Description, 
					BSA_Foodservice_Items_Master.Net_Weight,
					Program_OffInvoice_Product_Data.Program_OffInvoice_Product_Data_ID,
					Program_OffInvoice_Product_Data.Discount_Amount,
					Program_OffInvoice_Product_Data.Plus_Minus,
					Program_OffInvoice_Product_Data.UOM,
					ISNULL(Program_OffInvoice_Component.Basis_Code_Master_ID, 0) Basis_Code_Master_ID,
					Program_OffInvoice_Product_Data.Basis_Code_Quantity,
					ISNULL(Program_OffInvoice_Product_Data.Basis_Code_Quantity_UOM, 0) Basis_Code_Quantity_UOM,
					Program_OffInvoice_Product_Data.Basis_Code_Free_Goods,
					ISNULL(Program_OffInvoice_Product_Data.Basis_Code_Free_Goods_UOM, 0) Basis_Code_Free_Goods_UOM,
					Program_OffInvoice_Component.Effective_Margin_Flag,
					CASE
					WHEN ISNULL(Program_OffInvoice_Component.Effective_Margin_Flag, 0) = 1 THEN ISNULL(Program_OffInvoice_Product_Data.Effective_Margin_Percent, 100) 
					ELSE 100 
					END As Effective_Margin_Percent,
					Contract_Products.Contract_Main_ID,
					BSA_Foodservice_Items_Master.Inventory_UM,
					Product_Hierarchy.Unit_Of_Measure_ID AS Hierarchy_UOM,
					Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID,
					Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name
					
			FROM	Contract_Products 
					INNER JOIN BSA_Foodservice_Items_Master ON 
					Contract_Products.BSA_Foodservice_Items_Master_ID =	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
					INNER JOIN Program_OffInvoice_Product_Data ON
					Contract_Products.Contract_Products_ID = Program_OffInvoice_Product_Data.Contract_Products_ID
					LEFT JOIN Program_OffInvoice_Component
					ON	Program_OffInvoice_Component.Deleted = 0
					AND	Program_OffInvoice_Component.Program_OffInvoice_Component_ID = Program_OffInvoice_Product_Data.Program_OffInvoice_Component_ID
					LEFT JOIN Program_OffInvoice_Component_Name
					ON	Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID = Program_OffInvoice_Component.Program_OffInvoice_Component_Name_ID
					<cfif displayGroupType EQ 3><!------ Q Brand ----->
					<CFIF arguments.useProductQBrand EQ 1>
						LEFT JOIN Product_Q_Brand_Desc ON 
						Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
						AND Product_Q_Brand_Desc.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID 
						AND Product_Q_Brand_Desc.Deleted = 0
						<!---INNER JOIN Q_Brand_Desc ON --->
						LEFT JOIN Q_Brand_Desc ON
						Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID 
						AND Q_Brand_Desc.Deleted = 0
					<CFELSE>
						LEFT JOIN Q_Brand_Desc ON 
						Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID 
						AND Q_Brand_Desc.Deleted = 0
					</CFIF>
					<cfelseif displayGroupType EQ 1><!------ Type Code ----->
						LEFT JOIN Type_Code_Desc
						ON
						Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
					<CFELSE>
						LEFT OUTER JOIN	dbo.Type_Code_Desc 
						ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID 
					</cfif>
					LEFT JOIN Business_Segment ON
					Business_Segment.Deleted = 0
					AND CAST(Business_Segment.Business_Segment_ID as nvarchar(50)) = Contract_Products.Product_Group_ID
					LEFT JOIN Product_Hierarchy ON
					CAST(Product_Hierarchy.Product_Hierarchy_ID as nvarchar(50)) = Contract_Products.Product_Group_ID
					LEFT JOIN Product_Group_Level ON
					Product_Group_Level.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID
					
			WHERE	Program_OffInvoice_Product_Data.Deleted = 0
			AND		Contract_Products.Deleted = 0
			AND		Contract_Products.Product_Type_ID = 8
			AND		Contract_Products.Contract_Main_ID = #arguments.contractMainId#
			
			<!---if it's a group deal that has groups then filter on groups--->
			<cfif qCheckForGroup.RecordCount>
			
			AND 	
				(
					Contract_Products.Is_Group = 1
					OR Contract_Products.Product_Group_Level_ID = 9
					
				)
				
			</cfif>
			
			<!---if the negative/positive argument is passed then filter on negative or positive--->
			<cfif arguments.negPos gte 0>
				AND Program_OffInvoice_Product_Data.Plus_Minus = #arguments.negPos#
			</cfif>
			
			<!---if sort by was passed then order by--->
			<cfif trim(arguments.sortBy) neq "">
				ORDER BY #arguments.sortBy#, Item, UPC, Description, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID
			<cfelse>
				<cfif appSettings.getViewPgmSortBy() EQ 0>
					ORDER BY Contract_Products.Pricing_Level_ID,Item, UPC, Description, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID
				<cfelseif appSettings.getViewPgmSortBy() EQ 1>
		 			ORDER BY Description, Item, UPC, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID
				<cfelse>
					ORDER BY Item, UPC, Description, BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID
				</cfif>	
			</cfif>
			
		</CFQUERY>

		<cfreturn qGetOIProgramProducts />
		
	</cffunction>

	<cffunction name="getOIProgramComponents" output="false">
	
		<cfargument name="contractMainId" default="0" required="true" type="numeric" />
		
		<!------ Load From DB ----->
		<CFQUERY NAME="qGetOIProgramComponents" datasource="#application.datasource#">
			SELECT 	Program_OffInvoice_Component.Program_OffInvoice_Component_Name_ID, 
					Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name,
					ISNULL(Program_OffInvoice_Component.Treatment_Code_Master_ID, 0) Treatment_Code_Master_ID,
					ISNULL(Program_OffInvoice_Component.Basis_Code_Master_ID, 0) Basis_Code_Master_ID,
					ISNULL(Required_Effective_Rate_Percent, 0) As Required_Effective_Rate_Percent
			FROM	Program_OffInvoice_Component
			INNER JOIN Program_OffInvoice_Component_Name
			ON		Program_OffInvoice_Component_Name.Program_OffInvoice_Component_Name_ID = Program_OffInvoice_Component.Program_OffInvoice_Component_Name_ID
			WHERE	Program_OffInvoice_Component.Deleted = 0
			AND		Program_OffInvoice_Component.Program_ID = <cfqueryparam value="#arguments.contractMainId#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>

		<cfreturn qGetOIProgramComponents />
		
	</cffunction>

</cfcomponent>