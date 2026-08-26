<cfparam name="form.Level_1" default="" />
<cfparam name="form.GroupLevel_1" default="0" />
<cfparam name="form.Dynamic_Static_Groups" default="0" />
<cfparam name="form.Pricing_Level_ID" default="0" />

<cfset FORM.groupLevelProducts = 0 />
<cfset FORM.productGroupId = "" />
<cfif Len(FORM.Product_Level_1) GT 0>
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
	<cfset form.Product_List = groupLevelProductId />
	<cfset FORM.groupLevelProducts = 1 />
	<cfset FORM.productGroupId = FORM.Product_Level_1 />
</cfif>

<cfset useLakebaseForGetParentComponentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForGetParentComponentInfo>
	<cftry>
		<cfset GetParentComponentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", {
				"program_growth_component_id" = "eq.#Component_ID#",
				"select" = "rate_type,program_growth_component_type_id,component_name,component_uom"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetParentComponentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetParentComponentInfo>
	<cfquery name="GetParentComponentInfo" datasource="#application.datasource#">
	SELECT Rate_Type, Program_Growth_Component_Type_ID , Component_Name, Component_UOM FROM Program_Growth_Components WHERE Program_Growth_Component_ID = '#Component_ID#'
	</cfquery>
</cfif>

<!---Add to Component--->
	<cfset useLakebaseForInsertIntoComponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForInsertIntoComponent>
	<cftry>
		<cfset application.oLakebase.insertRow("program_growth_components", {
			"program_id" = "#Contract_Main_ID#",
			"tier_count" = "1",
			"rate_type" = "#GetParentComponentInfo.Rate_Type#",
			"component_name" = "#GetParentComponentInfo.Component_Name#",
			"deleted" = "0",
			"component_uom" = "#GetParentComponentInfo.Component_UOM#",
			"program_growth_component_type_id" = "#GetParentComponentInfo.Program_Growth_Component_Type_ID #",
			"isparent" = "0",
			"parent_id" = "#Component_ID#",
			"is_rate" = "0",
			"is_volume" = "1",
			"target_order" = "1"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoComponent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoComponent>
<cfquery name="InsertIntoComponent" datasource="#application.datasource#">
	INSERT INTO Program_Growth_Components
	(
		Program_ID,	Tier_Count,	Rate_Type, Component_Name, Deleted,	Component_UOM, Program_Growth_Component_Type_ID ,	IsParent, Parent_ID, Is_Rate, Is_Volume, Target_Order
	)
	VALUES
	(
		#Contract_Main_ID#,	1, #GetParentComponentInfo.Rate_Type#, '#GetParentComponentInfo.Component_Name#', 0, '#GetParentComponentInfo.Component_UOM#', #GetParentComponentInfo.Program_Growth_Component_Type_ID #, 0, '#Component_ID#', 0, 1, 1
	)
	</cfquery>
</cfif>


<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#" DELIMITERS=",">
	
	<!---param data that may not always come through--->
	<cfparam name="Is_Group" default="0" />
	
	<!---if level one isn't empty then we know we have groups so handle for that--->
	<cfif trim(form.Level_1) neq "">
	
		<cfset Is_Group = 1 />
		<cfset form.Pricing_Level_ID = 1 />
		<cfset FORM.groupLevelProducts = form.GroupLevel_1 />
		<cfset FORM.productGroupId = Product_ID />
		
	</cfif>
	
	
	<cfset useLakebaseForsaveContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForsaveContractProducts>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_products", {
			"bsa_foodservice_items_master_id" = "#Product_ID#",
			"contract_main_id" = "#Contract_Main_ID#",
			"product_type_id" = "4",
			"product_group_level_id" = "#FORM.groupLevelProducts#",
			"product_group_id" = "#FORM.productGroupId#",
			"pricing_level_id" = "#form.Pricing_Level_ID#",
			"is_group" = "#Is_Group#",
			"dynamic_static_groups" = "#form.Dynamic_Static_Groups#",
			"discounted_item" = "0"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveContractProducts>
<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
	
		INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Product_Group_ID, Pricing_Level_ID, Is_Group, Dynamic_Static_Groups, Discounted_Item)
		VALUES
			('#Product_ID#', '#Contract_Main_ID#', 4, #FORM.groupLevelProducts#, '#FORM.productGroupId#', #form.Pricing_Level_ID#, #Is_Group#,  #form.Dynamic_Static_Groups#, 0)
			
	</CFQUERY>
</cfif>
	
	<!---set this contract product id--->
	<cfset this.Contract_Products_ID = saveContractProducts.Contract_Products_ID />
			
	<cfset useLakebaseForInsertNewProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_product_data")>
<cfif useLakebaseForInsertNewProduct>
	<cftry>
		<cfset application.oLakebase.insertRow("program_growth_component_product_data", {
			"program_growth_component_id" = "#InsertIntoComponent.A_ID#",
			"contract_products_id" = "#saveContractProducts.Contract_Products_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertNewProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertNewProduct>
<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
	
		INSERT INTO Program_Growth_Component_Product_Data
			(Program_Growth_Component_ID, Contract_Products_ID)
		VALUES
			('#InsertIntoComponent.A_ID#', '#saveContractProducts.Contract_Products_ID#')
			
	</CFQUERY>
</cfif>
	
	<!---if it's a group then call stored procedure to populate items in that group--->
	<!---TSF: Modification Label 6676--->
<!--- 	<cfif Is_Group eq 1>
	
		<cfstoredproc procedure="CAPTURE_DISCOUNT_GROUP_ITEMS" datasource="#application.datasource#">
							
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Contract_Main_ID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@PRODUCT_TYPE_ID" value = "4" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@PRODUCT_GROUP_LEVEL_ID" value = "#FORM.groupLevelProducts#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_GROUP_ID" value = "#FORM.productGroupId#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@PRICING_LEVEL_ID" value = "#form.Pricing_Level_ID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@DYNAMIC_STATIC_GROUPS" value = "#form.Dynamic_Static_Groups#" null="no">
							   
		</cfstoredproc>
		
		<cfstoredproc procedure="CAPTURE_GROWTH_GROUP_ITEMS" datasource="#application.datasource#">
		
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_PRODUCTS_ID" value = "#this.Contract_Products_ID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Contract_Main_ID#" null="no">
		
		</cfstoredproc>
	
	</cfif> --->
			
	
</CFLOOP>

<cflocation url="Contract_Discount_Growth_Add_Component_Products.cfm?Contract_Main_ID=#Contract_Main_ID#&CID=#URL.CID#&CompID=#Component_ID#">
