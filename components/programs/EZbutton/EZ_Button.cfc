<!---------------------------------------------------------------------------------------------------------------------
            Template: \ Components\Programs\EZButton\EZ_Button.cfc
            Date:     20-May-2020
            Author:   Dinesh Rachala
            Purpose:  EZ Button Functions
----------------------------------------------------------------------------------------------------------------------->
<cfcomponent>

	<cffunction name="getEZCompID" output="false" returntype="any">
		<cfargument name="contract_main_id"	type="numeric"	required="true">

		<cfquery name="getEZCompID" datasource="#application.datasource#">
			SELECT Program_rebates_Component_ID
			FROM   Program_Rebates_component
			WHERE  Program_ID = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="CF_SQL_INTEGER">
			AND Deleted =0
		</cfquery>

			<cfreturn getEZCompID>
	</cffunction>

	<cffunction name="deleteItems" output="false" access="remote" returntype="any">
		<cfargument name="Contract_Main_ID"	type="numeric"	required="true">
		<cfargument name="Contract_Products_ID"	type="numeric"	required="true">
		<cfargument name="Program_Rebates_Product_Data_ID"	type="numeric"	required="true">
		<cfargument name="Type"	type="numeric"	required="true">
		<cfargument name="Pricing_Level_ID"	type="numeric"	required="true">
		<cfargument name="IS_Group"	type="numeric"	required="true">

		<cfif arguments.type>
			<cfquery name="deleteSingleItem" datasource="#application.datasource#">
				UPDATE Contract_Products
				SET Deleted = 1
				WHERE Contract_Products_ID = <cfqueryparam value="#arguments.Contract_Products_ID#"  cfsqltype="CF_SQL_NUMERIC">
				AND Product_Type_ID = 2

				UPDATE program_rebates_product_data
				SET Deleted = 1
				WHERE Contract_Products_ID = <cfqueryparam value="#arguments.Contract_Products_ID#"  cfsqltype="CF_SQL_NUMERIC">

				UPDATE program_rebates_component_data
				SET Deleted = 1
				WHERE Program_Rebates_Product_Data_ID = <cfqueryparam value="#arguments.Program_Rebates_Product_Data_ID#"  cfsqltype="CF_SQL_NUMERIC">
			</cfquery>
			<!---- UPDATE PRICING LEVEL IF GROUP IS DELETED --->
			<cfif arguments.IS_Group>
				<cfquery name="GPLD" datasource="#application.datasource#">
					SELECT Pricing_Level_ID
					FROM Contract_Products
					WHERE Product_Type_ID = 2
					AND Pricing_Level_ID = #arguments.Pricing_Level_ID#
					AND Contract_Main_ID = #arguments.Contract_Main_ID#
					AND Deleted = 0
				</cfquery>

				<cfif GPLD.recordcount EQ 0>

					<cfloop from="#arguments.Pricing_Level_ID#" to="#request.AccessStructure.numberOfProductGroupLevels#" index="PL">
						<cfset NextPL = #PL# + 1>
					<!---	<cfif PL EQ arguments.Pricing_Level_ID>
							<cfset useLakebaseForupdPL = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForupdPL>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"product_type_id" = "eq.2",
				"pricing_level_id" = "eq.#NextPL#",
				"contract_main_id" = "eq.#arguments.Contract_Main_ID#",
				"deleted" = "eq.0"
			},
			{
				"pricing_level_id" = "#arguments.Pricing_Level_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdPL = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdPL>
<cfquery name="updPL" datasource="#application.datasource#">
								UPDATE Contract_Products
								SET Pricing_Level_ID = #arguments.Pricing_Level_ID#
								WHERE Product_Type_ID = 2
								AND Pricing_Level_ID = #NextPL#
								AND Contract_Main_ID = #arguments.Contract_Main_ID#
								AND Deleted = 0
						</cfquery>
</cfif>
						<cfelse> </cfif>---->
						<cfquery name="updPL" datasource="#application.datasource#">
								UPDATE Contract_Products
								SET Pricing_Level_ID = #PL#
								WHERE Product_Type_ID = 2
								AND Pricing_Level_ID = #NextPL#
								AND Contract_Main_ID = #arguments.Contract_Main_ID#
								AND Deleted = 0
						</cfquery>
					</cfloop>
				</cfif>
			</cfif>
		<cfelse>
			<cfquery name="deleteAllItems" datasource="#application.datasource#">

				UPDATE PRCD
				SET PRCD.Deleted =1
				FROM program_rebates_component_data PRCD
				INNER JOIN program_rebates_product_data PRPD
				ON PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
				WHERE PRPD.Program_ID = <cfqueryparam value="#arguments.Contract_Main_ID#"  cfsqltype="CF_SQL_NUMERIC">
				AND PRPD.Deleted = 0

				UPDATE PRPD
				SET PRPD.Deleted =1
				FROM program_rebates_product_data PRPD
				INNER JOIN Contract_Products CP
				ON CP.Contract_Products_ID = PRPD.Contract_Products_ID
				WHERE CP.Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#"  cfsqltype="CF_SQL_NUMERIC">
				AND CP.Product_Type_ID = 2
				AND CP.Deleted = 0
				AND PRPD.Deleted =0

				UPDATE Contract_Products
				SET Deleted = 1
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.Contract_Main_ID#"  cfsqltype="CF_SQL_NUMERIC">
				AND Product_Type_ID = 2
				AND Deleted = 0

			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="massApply" output="false" access="remote" returntype="any">
		<cfargument name="Contract_Main_ID"	type="numeric"	required="true">
		<cfargument name="Rate" type="any" required="true">
		<cfargument name="UOM"	type="numeric"	required="true">
		<cfargument name="Search" type="any" required="true">
		<cfargument name="Groups" type="numeric" required="true">

		<cfquery name="massApplyRate" datasource="#application.datasource#">
				UPDATE  PRCD
				SET PRCD.Rate = '#arguments.Rate#'
							,PRCD.Unit_Of_Measure_ID = <cfqueryparam value="#arguments.UOM#"  cfsqltype="CF_SQL_NUMERIC">
				FROM program_rebates_component_data PRCD
				INNER JOIN program_rebates_product_data PRPD
				ON PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
				INNER JOIN Contract_Products CP
				ON CP.Contract_Products_ID = PRPD.Contract_Products_ID
				INNER JOIN BSA_Foodservice_Items_Master BSA
				ON BSA.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				LEFT JOIN All_Product_Group_Types APGT
				ON APGT.Group_GUID = CP.bsa_foodservice_items_master_id
				WHERE PRPD.Program_ID = <cfqueryparam value="#arguments.Contract_Main_ID#"  cfsqltype="CF_SQL_NUMERIC">
				AND PRPD.Deleted = 0
				AND PRCD.Deleted = 0
				AND CP.Deleted = 0

				<cfif len(arguments.Search)>
				AND ( BSA.item LIKE '%#arguments.Search#%'
					  OR BSA.description LIKE '%#arguments.Search#%'
						OR APGT.Group_Number LIKE '%#arguments.Search#%'
					)
			 </cfif>

		<cfif arguments.Groups>
				<!--- RUN CAPTURE GROUPS --->
			<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.Contract_Main_ID#" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@From_EZ_Template" value = "1" null="no">
			</cfstoredproc>
		</cfif>

		</cfquery>

	</cffunction>

	<cffunction name="AddProductsRGroups" output="false" returntype="any">
		<cfargument name="Contract_Main_ID"	type="numeric"	required="true">
		<cfargument name="BSA_Foodservice_Items_Master_ID"	type="any"	required="true">
		<cfargument name="Program_Rebates_Component_ID"	type="numeric"	required="true">
		<cfargument name="PricingLevelID"	type="numeric"	required="true" default="0">
		<cfargument name="Is_Group"	type="numeric"	required="false" default="0">
		<cfargument name="Product_Rate"	type="any" required="false" default="">
		<cfargument name="Product_UOM"	type="any" required="false" default="">

		<cfset defaultUOM = 1>
		<cfif arguments.Is_Group>
			<cfset useLakebaseForgetGroupLevelID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("all_product_group_types")>
<cfif useLakebaseForgetGroupLevelID>
	<cftry>
		<cfset getGroupLevelID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("all_product_group_types", {
				"group_guid" = "eq.#arguments.BSA_Foodservice_Items_Master_ID#",
				"deleted" = "eq.0",
				"select" = "product_group_level_id"
			}), "product_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupLevelID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupLevelID>
<cfquery name="getGroupLevelID" datasource="#application.datasource#">
				SELECT Product_Group_Level_ID
				FROM All_Product_Group_Types
				WHERE Group_GUID = '#arguments.BSA_Foodservice_Items_Master_ID#'
				AND Deleted = 0
			</cfquery>
</cfif>
			<cfset Product_Group_Level_ID = getGroupLevelID.Product_Group_Level_ID>
		<cfelse>
			<cfquery name="InvUOM" datasource="#application.datasource#">
				SELECT Units_of_Measure.Unit_Of_Measure_ID
				FROM BSA_Foodservice_Items_Master
				INNER JOIN Units_of_Measure
				ON Units_of_Measure.Abbreviation = BSA_Foodservice_Items_Master.Inventory_UM
				WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
				AND Deleted = 0
			</cfquery>
			<cfif len(InvUOM.Unit_Of_Measure_ID)>
				<cfset defaultUOM = InvUOM.Unit_Of_Measure_ID>
			</cfif>
			<cfif len(arguments.Product_UOM)>
				<cfquery name="InvUOM" datasource="#application.datasource#">
					SELECT Unit_Of_Measure_ID from Units_of_Measure where Abbreviation in ('#arguments.Product_UOM#') OR Abbreviation_Singular in ('#arguments.Product_UOM#')
				</cfquery>
				<cfset defaultUOM = InvUOM.Unit_Of_Measure_ID>
			</cfif>
			<cfset Product_Group_Level_ID = 9>
		</cfif>

		<cfset InsertRecords(
				#arguments.Contract_Main_ID#
			, #arguments.BSA_Foodservice_Items_Master_ID#
			, #arguments.Program_Rebates_Component_ID#
			, #arguments.PricingLevelID#
			, #arguments.Is_Group#
			, #arguments.BSA_Foodservice_Items_Master_ID#
			, #Product_Group_Level_ID#
			, #defaultUOM#
			, #arguments.Product_Rate#
			)>
	</cffunction>

<cffunction name="InsertRecords" output="false" returntype="any">
	<cfargument name="Contract_Main_ID"	type="numeric"	required="true">
	<cfargument name="BSA_Foodservice_Items_Master_ID"	type="any"	required="true">
	<cfargument name="Program_Rebates_Component_ID"	type="numeric"	required="true">
	<cfargument name="PricingLevelID"	type="numeric"	required="true">
	<cfargument name="IS_Group"	type="numeric"	required="true" default="0">
	<cfargument name="Product_Group_ID"	type="any"	required="true" default="">
	<cfargument name="Product_Group_Level_ID"	type="numeric"	required="true" default="9">
	<cfargument name="defaultUOM"	type="numeric"	required="true" default="1">
	<cfargument name="Product_Rate"	type="any"	required="false" default="0.0000">

		<cfquery name="CProducts" datasource="#application.datasource#">
				INSERT INTO Contract_Products(
				BSA_Foodservice_Items_Master_ID
				,Contract_Main_ID
				,Product_Type_ID
				,Pricing_Level_ID
				,IS_Group
				,Product_Group_ID
				,Product_Group_Level_ID)
				Values(
				'#arguments.BSA_Foodservice_Items_Master_ID#'
				,#arguments.Contract_Main_ID#
				,2
				,#arguments.PricingLevelID#
				,#arguments.IS_Group#
				,'#arguments.Product_Group_ID#'
				,#arguments.Product_Group_Level_ID#)

				SELECT SCOPE_IDENTITY() AS Contract_Products_ID
		</cfquery>

		<cfquery name="PrgProdData" datasource="#application.datasource#">
				INSERT INTO program_rebates_product_data(
					Program_ID
				, Contract_Products_ID)
				Values(
					#arguments.Contract_Main_ID#
				, #CProducts.Contract_Products_ID#)

				SELECT SCOPE_IDENTITY() AS Program_Rebates_Product_Data_ID
		</cfquery>

		<cfquery name="PrdCompData" datasource="#application.datasource#">
			INSERT INTO program_rebates_component_data(
				Program_Rebates_Product_Data_ID
			, Program_Rebates_Component_ID
			, Rate
			, Unit_Of_Measure_ID)
			Values(
				#PrgProdData.Program_Rebates_Product_Data_ID#
			, #arguments.Program_Rebates_Component_ID#
			, '#arguments.Product_Rate#'
			, #arguments.defaultUOM#)
		</cfquery>
	</cffunction>

	<cffunction name="saveRateUom" output="false" access="remote" returntype="any">
		<cfargument name="cmid" required="true" type="numeric">
		<cfargument name="bsaid" required="true" type="any">
		<cfargument name="rate" required="false" value="0.0000" type="any">
		<cfargument name="uom" required="false" value="0" type="numeric">
		<cfargument name="type" required="true" type="numeric">
		<cfargument name="group" required="true" type="numeric">

		<cfquery name="updRateUOM" datasource="#application.datasource#">
			UPDATE PRCD
			SET Unit_Of_Measure_ID = #arguments.uom#, Rate = '#arguments.rate#'
			FROM Program_Rebates_Component_Data PRCD
			INNER JOIN Program_Rebates_Product_Data PRPD
			ON PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
			INNER JOIN Contract_Products CP
			ON CP.Contract_Products_ID = PRPD.Contract_Products_ID
			WHERE CP.BSA_Foodservice_Items_Master_ID = '#arguments.bsaid#'
			AND CP.Contract_Main_ID = #arguments.cmid#
			AND CP.Deleted = 0
			AND PRCD.Deleted = 0
			AND PRPD.Deleted = 0
		</cfquery>

		<cfif arguments.group>
				<!--- RUN CAPTURE GROUPS --->
			<cfstoredproc procedure="SP_CAPTURE_ALL_FOR_GROUPS" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.cmid#" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@Default_One_Case" value = "1" null="no">
				<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@From_EZ_Template" value = "1" null="no">
			</cfstoredproc>
		</cfif>
	</cffunction>
</cfcomponent>