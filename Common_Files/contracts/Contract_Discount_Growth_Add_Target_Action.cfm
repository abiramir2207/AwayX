<cfparam name="Action" default="Create">
<cfparam name="form.EZTemplate" default="0">
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET Contract_Main_ID = cryp.value>

<cfparam name="Comparison_Type" 	default="0">
<cfparam name="Sample_Period" 		default="">
<cfparam name="Target_Bonus"		default=0>
<cfparam name="form.Pricing_Level_ID" default="0" />
<cfparam name="form.Level_1" default="" />
<cfparam name="form.GroupLevel_1" default="0" />
<cfparam name="form.Dynamic_Static_Groups" default="0" />
<!---Program_Growth_Comparison_Period_UOM is for "Amount" OR "Volume" for growth tiers calculation--->
<cfparam name="form.Program_Growth_Comparison_Period_UOM" default ="0">
			
<cfset useLakebaseForGetParentComponentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForGetParentComponentInfo>
	<cftry>
		<cfset GetParentComponentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", { "program_growth_component_id" = "eq.#Component_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetParentComponentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetParentComponentInfo>
	<cfquery name="GetParentComponentInfo" datasource="#application.datasource#">
		SELECT *
		FROM 	Program_Growth_Components
		WHERE 	Program_Growth_Component_ID = '#Component_ID#'
	</cfquery>
</cfif>

<cfset FORM.groupLevelProducts = 0 />
<cfset FORM.productGroupId = "" />
<cfif Len(FORM.Product_Level_1) GT 0>
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
	<cfset form.Product_List = groupLevelProductId />
	<cfset FORM.groupLevelProducts = 1 />
	<cfset FORM.productGroupId = FORM.Product_Level_1 />
</cfif>

<cfif form.deletedateexclusions EQ 1>
<cfquery name="GetSettings" datasource="#application.datasource#">

	SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Program_Control_Panel_Options
			INNER JOIN Contract_Main ON 
			Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = #Contract_Main_ID#
	
</cfquery>


<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(Contract_Main_ID,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update contract_main
				set deleted = 1
				where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update program_exclusions
				set deleted = 1
				where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			</CFIF>
		</cfif>
</cfif>
</cfif>

<!---Add Program Growth Components--->
<!---

	Targets are just like components, except they are "children" of components. For any target:
	In Program_Growth_Component
	Tier_Count = 1
	Is_Parent = 0
	Is_Volume = 1
	Is_Rate = 0
	Parent_ID = original component id
	
	In Program_Growth_Component_Tiers
	Range_Start = 0
	Range_End = Target_Amount

--->

<cfif Action IS NOT "Edit">

	<!---Get number of previous tiers--->
	<cfquery name="PreviousTiers" datasource="#application.datasource#">
		SELECT 	COUNT(*) AS Previous_Tier_Count
		FROM 	Program_Growth_Components
		WHERE 	Deleted = 0 
		AND 	Program_Growth_Components.Parent_ID = '#Component_ID#'
	</cfquery>

	<cfset ThisTierNumber = PreviousTiers.Previous_Tier_Count + 1>
	
	<cftransaction isolation="read_uncommitted">
	
		<!---Add to Component--->
		<cfquery name="InsertIntoComponent" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Components
			(
				Program_ID,	Tier_Count,	Rate_Type, Component_Name, Program_Growth_Components_Name_Id, Deleted,	Component_UOM, Comparison_Type,
				Sample_Period, Program_Growth_Component_Type_ID , IsParent, Parent_ID, Is_Rate, Is_Volume, Target_Order, Program_Growth_Comparison_Period_UOM_ID
			)
			VALUES
			(
				#Contract_Main_ID#,	#ThisTierNumber#, #GetParentComponentInfo.Rate_Type#, '#Component_Name#','#GetParentComponentInfo.Program_Growth_Components_Name_Id#', 0, #Target_UOM#, '#Comparison_Type#', '#Sample_Period#', #GetParentComponentInfo.Program_Growth_Component_Type_ID #, 0,
				'#Component_ID#', 0, 1, #ThisTierNumber#, '#form.Program_Growth_Comparison_Period_UOM#'
			)
		</cfquery>
		
		<!---Add to tiers--->
		<cfquery name="InsertIntoTiers" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Tiers
			(
				Program_Growth_Component_ID, Program_ID, Tier_Number, Range_Start, Range_End, Growth_Amount, Deleted
			)
			VALUES
			(
				'#InsertIntoComponent.A_ID#', '#Contract_Main_ID#', 1, 0, '#Target_Amount#', '#Target_Bonus#', 0
			)
		</cfquery>
		
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
<!--- 			<cfif Is_Group eq 1>
				
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
		
		<!----Insert into parent tier table--->
		<cfquery name="UpdateParentTier" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Tiers
			(
				Program_Growth_Component_ID,
				Program_ID,
				Tier_Number,
				Range_Start,
				Range_End,
				Growth_Amount,
				Deleted
			)
			VALUES
			(
				'#Component_ID#',
				#Contract_Main_ID#,
				#ThisTierNumber#,
				0,
				'#Target_Bonus#',
				#Target_Amount#,
				0
			)
		</cfquery>
		
		
	
		<!--- <!------ get volume uom ----->
		<cfset programManager = CreateObject("component", "components.programs.program") />
		<cfset qProgram = programManager.getProgramInfo(Contract_Main_ID) />
		
		<cfif qProgram.recordCount>
		
			<!------ update volume ----->
			<cfquery name="qUpdateVolume" datasource="#application.datasource#">
				UPDATE	Program_Growth_Component_Product_Data
				SET 	Program_Growth_Component_Product_Data.Weekly_Volume = 
						(
							SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
							FROM	Program_Product_Volume
							WHERE
									Program_Product_Volume.Deleted = 0
									AND
									Program_Product_Volume.Program_ID = Program_Growth_Component_Product_Data.Program_ID
									AND
									Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						)
				FROM	Program_Growth_Component_Product_Data
						INNER JOIN	Contract_Products
						ON
						Contract_Products.Deleted = 0
						AND
						Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
				WHERE
						Program_Growth_Component_Product_Data.Deleted = 0
						AND
						Program_Growth_Component_Product_Data.Weekly_Volume IS NULL
						AND
						Program_Growth_Component_Product_Data.Program_ID = #Contract_Main_ID#
			</cfquery>
			
		</cfif>
	
		<!---call SP to update program product volume --->
		<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
					
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Contract_Main_ID#" null="no">
					   
		</cfstoredproc> --->
		
	</cftransaction>	
	
	
	
	<!---Where to go next--->
	<!---Add additional target--->
	<cfif AddTarget IS 1>
	
		<cflocation url="Contract_Discount_Growth_Add_Target.cfm?CID=#url.CID#&Component_ID=#Component_ID#&EZTemplate=#form.EZTemplate#">

	<!---Update parent component and go to next page--->
	<cfelse>
				
		<cfset useLakebaseForUpdateParentComponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
		<cfif useLakebaseForUpdateParentComponent>
			<cftry>
				<cfset application.oLakebase.updateRows("program_growth_components",
					{ "program_growth_component_id" = "eq.#Component_ID#" },
					{ "tier_count" = ThisTierNumber }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateParentComponent = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateParentComponent>
			<cfquery name="UpdateParentComponent" datasource="#application.datasource#">
				UPDATE 	Program_Growth_Components
				SET 	Tier_Count = #ThisTierNumber#
				WHERE 	Program_Growth_Component_ID = '#Component_ID#'
			</cfquery>
		</cfif>

		<cflocation url="contract_discount_Growth_add_component_products.cfm?CompID=#Component_ID#&Program_ID=#Contract_Main_ID#&CID=#url.CID#&Component_Type=#GetParentComponentInfo.Program_Growth_Component_Type_ID#&ChildID=#InsertIntoComponent.A_ID#&EZTemplate=#form.EZTemplate#">
		
	</cfif>

<!---Finish add--->
<cfelse>
<!---Edit--->


	<!---Add to Component--->
	<cfquery name="UpdateComponent" datasource="#application.datasource#">
		UPDATE 	Program_Growth_Components
		SET 	Component_Name = '#form.Component_Name#', 
				Component_UOM = '#Target_UOM#',
				Comparison_Type = '#Comparison_Type#',
				Sample_Period='#Sample_Period#',
				Program_Growth_Comparison_Period_UOM_ID = '#form.Program_Growth_Comparison_Period_UOM#'
		WHERE 	Program_Growth_Components.Program_Growth_Component_ID = '#url.Child_ID#'
	</cfquery>
	
	<!---Add to tiers--->
	<cfset useLakebaseForUpdateTiers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_tiers")>
<cfif useLakebaseForUpdateTiers>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_component_tiers",
			{
				"program_growth_component_id" = "eq.#url.Child_ID#"
			},
			{
				"range_end" = "#Target_Amount#",
				"growth_amount" = "#Target_Bonus#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateTiers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateTiers>
<cfquery name="UpdateTiers" datasource="#application.datasource#">
		UPDATE 	Program_Growth_Component_Tiers
		SET 	Range_End 		= '#Target_Amount#',
				Growth_Amount 	= '#Target_Bonus#'
		WHERE 	Program_Growth_Component_Tiers.Program_Growth_Component_ID = '#url.Child_ID#'
	</cfquery>
</cfif>
	
	<!---Delete all prior products--->
	<cfset useLakebaseForDeletePriorProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_product_data")>
<cfif useLakebaseForDeletePriorProducts>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_component_product_data",
			{
				"program_growth_component_id" = "eq.#Child_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeletePriorProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePriorProducts>
<cfquery name="DeletePriorProducts" datasource="#application.datasource#">
		UPDATE 	Program_Growth_Component_Product_Data 
		SET 	Deleted = 1 
		WHERE 	Program_Growth_Component_ID = '#Child_ID#'
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
			
		<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
			INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Product_Group_ID, Pricing_Level_ID, Is_Group, Dynamic_Static_Groups, Discounted_Item,EZButton_On_Default)
			VALUES
			('#Product_ID#', '#Contract_Main_ID#', 4, #FORM.groupLevelProducts#, '#FORM.productGroupId#', #form.Pricing_Level_ID#, #Is_Group#,  #form.Dynamic_Static_Groups#, 0,#form.EZTemplate#)
		</CFQUERY>
		
		<!---set this contract product id--->
		<cfset this.Contract_Products_ID = saveContractProducts.Contract_Products_ID />
		
		<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Product_Data
				(Program_Growth_Component_ID, Contract_Products_ID)
			VALUES
				('#Child_ID#', '#saveContractProducts.Contract_Products_ID#')
		</CFQUERY>
		
		<!---if it's a group then call stored procedure to populate items in that group--->
		<!---TSF: Modification Label 6676--->
<!--- 		<cfif Is_Group eq 1>
			
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

	<cflocation url="Contract_Discount_Growth_Targets.cfm?Program_ID=#Contract_Main_ID#&Component_ID=#Component_ID#&CID=#URL.CID#&Action=Edit&Component_Type=#GetParentComponentInfo.Program_Growth_Component_Type_ID#&EZTemplate=#form.EZTemplate#">

</cfif>