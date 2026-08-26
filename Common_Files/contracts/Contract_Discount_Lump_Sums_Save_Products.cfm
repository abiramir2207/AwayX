<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<CFPARAM NAME="form.deletedateexclusions" DEFAULT="0">
<CFPARAM NAME="FORM.Contract_Quantity_UOM_IDX" DEFAULT="0">
<cfparam name="form.EZTemplate" default="0">
<CFPARAM NAME="FORM.Prod_Id" DEFAULT="">
<CFPARAM NAME="lumpsum_product_error" DEFAULT ="no"><!---D27822--->
<cfparam name="form.ShowSampleRelated" default="0">

<!---get settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />

<cfset C_ID = FORM.Program_ID>

<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">

<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT 	Program_Control_Panel_Options.*
	FROM 	Program_Control_Panel_Options
	INNER JOIN Contract_Main
	ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main_ID = '#cryp.value#'
</cfquery>

	<cfif form.deletedateexclusions EQ 1>
		<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(cryp.value,0)>
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

<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1 and NOT isDefined("Form.onlyproducts")>
	<cfinclude template = "Contract_Discount_Lump_Sums_Save_New_Lump_Sum.cfm">
</cfif>

<cfset FORM.Program_ID = cryp.value>

<!--- lock checker --->
<cfif form.EZTemplate EQ 0>
	<CFSET LockChecker_CID  = FORM.Program_ID>
	<CFINCLUDE TEMPLATE="LockChecker.cfm">
</cfif>
<!--- lock checker --->


<!---*******************************************************DELETE PRODUCTS********************************************************************--->
<cfif isDefined("form.Delete")>

	<cfparam name="ItemList" default="">
	<cfparam name="form.Delete_Product_Id" default="">

	<cfloop list="#FORM.Prod_Id#" index="ez_product_id" delimiters=",">
		<cfif form.EZTemplate EQ 1>
			<cfparam name="form.Prod_Default_#replace(ez_product_id, "-", "_", "ALL")#" default="0">
			<cfquery name="updateEZDefaultSettings" datasource="#application.datasource#">
				update contract_products
				set EZButton_On_Default = #evaluate("Prod_Default_#replace(ez_product_id, "-", "_", "ALL")#")#
				where contract_main_id = '#FORM.Program_ID#'
				and deleted = 0
				and product_type_id = 3
				and BSA_Foodservice_Items_Master_ID = '#ez_product_id#'
			</cfquery>
		</cfif>
	</cfloop>

	<cfloop list="#form.Delete_Product_Id#" index="product_id" delimiters=",">

		<cfquery name="qGetContractProds" datasource="#application.datasource#">
			SELECT	Program_Lump_Sum_Product_Data.Contract_Products_ID, Contract_Products.Is_Group,	Contract_Products.Product_Group_ID, Contract_Products.Pricing_Level_ID
			FROM 	Program_Lump_Sum_Product_Data,	Contract_Products
			WHERE 	Program_Lump_Sum_Product_Data.Program_Lump_Sum_Product_Data_ID = '#product_id#'
			AND		Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
			AND		Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
			AND		Contract_Products.Deleted = 0
			AND		Program_Lump_Sum_Product_Data.Deleted = 0
		</cfquery>

		<!---if this is a group then clean up for all the items in this group--->
		<cfif qGetContractProds.Is_Group eq 1>
			<!---get the contract products for this group/lump sum combination--->
			<cfquery name="qDelLumpSumProdData" datasource="#application.datasource#">
				DELETE	Contract_Products
				FROM 	Contract_Products
				INNER JOIN Program_Lump_Sum_Product_Data
				ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND Program_Lump_Sum_Product_Data.Deleted = 0
				AND Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
				WHERE 	Contract_Products.Deleted = 0
				AND Contract_Products.Is_Group = 0
				AND Contract_Products.Product_Group_ID = '#qGetContractProds.Product_Group_ID#'
			</cfquery>

			<cfquery name="qDelContractProds" datasource="#application.datasource#">
				DELETE 	Program_Lump_Sum_Product_Data
				FROM 	Program_Lump_Sum_Product_Data
				INNER JOIN Contract_Products
				ON Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
				AND Contract_Products.Deleted = 0
				AND Contract_Products.Is_Group = 0
				AND Contract_Products.Product_Group_ID = '#qGetContractProds.Product_Group_ID#'
				WHERE 	Program_Lump_Sum_Product_Data.Deleted = 0
				AND 	Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
			</cfquery>

		</cfif>

		<cfif qGetContractProds.RecordCount>

			<cfquery name="qDelContractProds" datasource="#application.datasource#">
				UPDATE 	Contract_Products
				SET 	Deleted = 1
				WHERE 	Contract_Products_ID = #qGetContractProds.Contract_Products_ID#
			</cfquery>

			<cfset useLakebaseForcheck4Levels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForcheck4Levels>
	<cftry>
		<cfset check4Levels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"pricing_level_id" = "eq.#qGetContractProds.Pricing_Level_ID#",
				"contract_main_id" = "eq.#FORM.Program_ID#",
				"deleted" = "eq.0",
				"product_type_id" = "eq.3"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck4Levels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck4Levels>
<cfquery name="check4Levels" datasource="#application.datasource#">
				SELECT *
				FROM Contract_Products
				WHERE Pricing_Level_ID = #qGetContractProds.Pricing_Level_ID#
				AND contract_main_id = '#FORM.Program_ID#'
				AND deleted = 0
				AND product_type_id = 3
			</cfquery>
</cfif>

			<cfif check4Levels.RecordCount EQ 0>
				<cfloop from="#qGetContractProds.Pricing_Level_ID#" to="8" index="levels">
				<cfset useLakebaseForupdLevels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForupdLevels>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_products",
			{
				"pricing_level_id" = "eq.#levels# + 1",
				"contract_main_id" = "eq.#FORM.Program_ID#",
				"deleted" = "eq.0",
				"product_type_id" = "eq.3"
			},
			{
				"pricing_level_id" = "#levels#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdLevels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdLevels>
<cfquery name="updLevels" datasource="#application.datasource#">
						UPDATE Contract_Products
						SET Pricing_Level_ID = #levels#
						WHERE Pricing_Level_ID = #levels# + 1
						AND contract_main_id = '#FORM.Program_ID#'
						AND deleted = 0
						AND product_type_id = 3
				</cfquery>
</cfif>
				</cfloop>
			</cfif>

		</cfif>

		<cfset useLakebaseForDeleteItem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_product_data")>
<cfif useLakebaseForDeleteItem>
	<cftry>
		<cfset application.oLakebase.updateRows("program_lump_sum_product_data",
			{
				"program_lump_sum_product_data_id" = "eq.#product_id#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteItem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteItem>
<cfquery name="DeleteItem" datasource="#application.datasource#">
			UPDATE 	Program_Lump_Sum_Product_Data
			SET 	Deleted = 1
			WHERE 	Program_Lump_Sum_Product_Data_ID = '#product_id#'
		</cfquery>
</cfif>

	</cfloop>

	<!--- Dev Note: KAL;  9896 : Lumpsum page to handle for samples: --->
	<cfif form.updateItems eq 1>
		<cfset useLakebaseForqGetProgramLumpSumProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_product_data")>
<cfif useLakebaseForqGetProgramLumpSumProductData>
	<cftry>
		<cfset qGetProgramLumpSumProductData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_product_data", {
				"program_lump_sum_id" = "eq.#FORM.Program_Lump_Sum_ID#",
				"deleted" = "eq.0",
				"order" = "contract_products_id.asc",
				"select" = "program_lump_sum_product_data_id"
			}), "program_lump_sum_product_data_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramLumpSumProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramLumpSumProductData>
<cfquery name="qGetProgramLumpSumProductData" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sum_Product_Data_ID
			FROM 	Program_Lump_Sum_Product_Data
			WHERE 	Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
			AND 	Deleted = 0
			ORDER BY contract_products_Id
		</cfquery>
</cfif>

		<!--- Get the products for the lumpsum component --->
		<cfset LumpSumDataManager = CreateObject("component", "components.programs.lump_sum_components.DataManager").init() />
		<cfset getLumpSumProducts = LumpSumDataManager.getProgramLumpSumProducts(FORM.Program_Lump_Sum_ID, cryp.value) />

		 <!--- Get amount and volume for  program_lump_sum table's amount and volume --->
		<CFSET Lump_Sum_Component_Amount = 0/>
		<CFSET Lump_Sum_Component_Volume_CS = 0/>
		<CFSET Lump_Sum_Component_Volume_LB = 0/>

		<!--- Looping through each product and setting the volume, sampletype, markup% and price for each product --->
		<cfloop query="qGetProgramLumpSumProductData">

			<cfquery name="qGetEachProductID" dbtype="query">
				SELECT	BSA_Foodservice_Items_Master_ID
				FROM	getLumpSumProducts
				WHERE	Program_Lump_Sum_Product_Data_ID = <cfqueryparam value="#qGetProgramLumpSumProductData.Program_Lump_Sum_Product_Data_ID#" cfsqltype="CF_SQL_IDSTAMP">
			</cfquery>


			<cfset FormFieldName = replace(qGetProgramLumpSumProductData.Program_Lump_Sum_Product_Data_ID, "-", "_", "all")>

			<cfif (FORM.ShowSampleRelated EQ 1)>

				<cfparam name="FORM.SAMPLE_TYPE_#FormFieldName#" default="0">
				<cfparam name="FORM.SAMPLE_Qty_#FormFieldName#" default="0">
				<cfparam name="FORM.SAMPLE_UOM_#FormFieldName#" default="0">
				<cfparam name="FORM.Net_Weight_#FormFieldName#" default="0">
				<cfset Item_Sample_Type_ID	= evaluate("FORM.SAMPLE_TYPE_#FormFieldName#") />
				<cfset Item_Sample_Qty		= evaluate("FORM.SAMPLE_Qty_#FormFieldName#") />
				<cfset Item_Sample_UOM		= evaluate("FORM.SAMPLE_UOM_#FormFieldName#") />
				<cfset Item_Sample_NtWt		= evaluate("FORM.Net_Weight_#FormFieldName#") />
				<cfset Item_Sample_Lb		= 0 />
				<cfset Item_Sample_Cs		= 0 />

				<cfif isDefined("FORM.MARK_UP_#FormFieldName#")>
					<cfset Item_Mark_Up_Percent	= evaluate("FORM.MARK_UP_#FormFieldName#") />
				<cfelse>
					<cfset Item_Mark_Up_Percent	= 0/>
				</cfif>

			     <!---
			          Removed the above procedure and added this one written by Deepa
			          for D18299 - Anand Rao, 05-Mar-09
			      --->

			      <cfstoredproc procedure="GET_PROGRAM_PRODUCT_PRICE" datasource="#application.datasource#">
			       		<cfprocparam type = "IN" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value="#FORM.Program_ID#" null="NO">
						<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#qGetEachProductID.BSA_Foodservice_Items_Master_ID#" null="NO">
						<cfprocparam type = "OUT" CFSQLType ="CF_SQL_FLOAT" variable="CS_FOB_Price" dbVarName = "@@CS_PRICE" null="NO">
						<cfprocparam type = "OUT" CFSQLType ="CF_SQL_FLOAT" variable="LB_FOB_Price" dbVarName = "@@LB_PRICE" null="NO">
					</cfstoredproc>

					<cfif LB_FOB_Price EQ "">
						<cfset LB_FOB_Price = 0>
					</cfif>

					<cfif CS_FOB_Price EQ "">
						<cfset CS_FOB_Price = 0>
					</cfif>

					<cfset Price_Multiplier = 0 />
					<cfif Item_Sample_UOM EQ 1> <!--- cases entered --->
						<cfset Item_Sample_Cs		= Item_Sample_Qty />
						<cfset Item_Sample_Lb		= (Item_Sample_Qty * Item_Sample_NtWt) />
						<cfset Price_Multiplier 	= CS_FOB_Price >
					<cfelseif Item_Sample_UOM EQ 2> <!--- pounds entered --->
						<cfset Item_Sample_Lb		= Item_Sample_Qty />
						<cfset Item_Sample_Cs		= (Item_Sample_Qty / Item_Sample_NtWt) />
						<cfset Price_Multiplier 	= LB_FOB_Price >
					</cfif>

					<cfquery name="UpdateSampleItemData" datasource="#application.datasource#">
						UPDATE 	Program_Lump_Sum_Product_Data
						SET 	Sample_Type_ID = <cfqueryparam value="#Item_Sample_Type_ID#" cfsqltype="CF_SQL_INTEGER">,
								Sample_Qty = <cfqueryparam value="#Item_Sample_Qty#" cfsqltype="CF_SQL_FLOAT">,
								Sample_UOM = <cfqueryparam value="#Item_Sample_UOM#" cfsqltype="CF_SQL_INTEGER">,
								Sample_Lb = <cfqueryparam value="#Item_Sample_Lb#" cfsqltype="CF_SQL_VARCHAR">,
								Sample_Cs = <cfqueryparam value="#Item_Sample_Cs#" cfsqltype="CF_SQL_VARCHAR">,
								Mark_Up_Percent = <cfqueryparam value="#Item_Mark_Up_Percent#" cfsqltype="CF_SQL_FLOAT">,
								Sample_Total_Price 	= (#Item_Sample_Qty# * (#Price_Multiplier# + ((#Price_Multiplier# * #Item_Mark_Up_Percent#)/100.00))  )
						WHERE 	Program_Lump_Sum_Product_Data_ID = <cfqueryparam value="#qGetProgramLumpSumProductData.Program_Lump_Sum_Product_Data_ID#" cfsqltype="CF_SQL_IDSTAMP">
					</cfquery>

					<CFSET Lump_Sum_Component_Amount = Lump_Sum_Component_Amount  + (Item_Sample_Qty * (Price_Multiplier  + Price_Multiplier * (Item_Mark_Up_Percent/100.00)))>
					<CFSET Lump_Sum_Component_Volume_Cs = Lump_Sum_Component_Volume_Cs + Item_Sample_Cs />
					<CFSET Lump_Sum_Component_Volume_Lb = Lump_Sum_Component_Volume_Lb + Item_Sample_Lb />
			<cfelse> <!--- UPDATE  the allocation % --->
			<!--- <cfloop query="qGetProgramLumpSumProductData"> --->
				<cfparam name="FORM.PerAllocLS_#FormFieldName#" default="0">
				<cfset PercentageAllocation	= evaluate("FORM.PERALLOCLS_#FormFieldName#") />

				<cfquery name="UpdatePercentAllocData" datasource="#application.datasource#">
						UPDATE 	Program_Lump_Sum_Product_Data
						SET 	Product_Percent_Allocation = <cfqueryparam value="#PercentageAllocation#" cfsqltype="CF_SQL_INTEGER">
						WHERE 	Program_Lump_Sum_Product_Data_ID = <cfqueryparam value="#qGetProgramLumpSumProductData.Program_Lump_Sum_Product_Data_ID#" cfsqltype="CF_SQL_IDSTAMP">
				</cfquery>
			<!--- </cfloop> --->
			</cfif> <!--- End checking for FORM.ShowSampleRelated--->
		</cfloop>
		 <!--- update program_lump_sum table's amount and volume --->
		<cfif (FORM.ShowSampleRelated EQ 1)>
			<cfquery name="UpdateLumpSumComponent"  datasource="#application.datasource#">
				UPDATE 	Program_Lump_Sums
				SET		<cfif FORM.Contract_Quantity_UOM_IDX eq 1> Lump_Sum_Volume = '#Lump_Sum_Component_Volume_Cs#',
						<cfelseif FORM.Contract_Quantity_UOM_IDX eq 2>Lump_Sum_Volume = '#Lump_Sum_Component_Volume_Lb#',</cfif>
						Lump_Sum_Amount = '#Lump_Sum_Component_Amount#'
				WHERE 	Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
				AND 	Deleted = 0
			</cfquery>
		</cfif>
	</cfif>

	<!--- START: 101637	Lump Sum manual allocation/Anand Rao/04-Nov-2020   --->
	<cfif isDefined("form.Delete")>
		<cfquery name="qGetContractProds2" datasource="#application.datasource#">
			SELECT	Program_Lump_Sum_Product_Data_ID,
					Contract_Products_ID,
					Product_Percent_Allocation,
					(SELECT SUM(Product_Percent_Allocation)  FROM Program_Lump_Sum_Product_Data WHERE Program_Lump_Sum_ID ='#FORM.Program_Lump_Sum_ID#' AND	Deleted = 0) AS ProductPercentSum
			FROM 	Program_Lump_Sum_Product_Data
			WHERE
			Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
			AND		Program_Lump_Sum_Product_Data.Deleted = 0
			AND 	Program_Lump_Sum_Product_Data.Is_Group <> 0
			ORDER BY Contract_Products_ID
		</cfquery>
		<cfset percentHasNullOrZero = 0 />
		<cfloop query = "qGetContractProds2">
			<cfif (qGetContractProds2.Product_Percent_Allocation EQ 0 OR qGetContractProds2.Product_Percent_Allocation EQ "")>
				<cfset percentHasNullOrZero = 1 />
			</cfif>
		</cfloop>

		<!--- Check if the sum of the Product_Percent_Allocation returned is equal to 100 if not, then do the following --->
		<cfif qGetContractProds2.Recordcount AND ((qGetContractProds2.ProductPercentSum) NEQ 100 OR percentHasNullOrZero EQ 1)>
			<cfset noOfRows = qGetContractProds2.Recordcount />
			<cfset leftOver = 100 mod noOfRows />

			<cfif leftOver NEQ 0>
				<cfset allocPercentCalculated = (100-leftOver)/noOfRows />
			<cfelse>
				<cfset allocPercentCalculated = 100/noOfRows />
			</cfif>
			<!--- loop over and updatet all the rows with the calculated values --->
			<cfloop query = "qGetContractProds2">
				<cfset reallocPercentCalculated = allocPercentCalculated/>
				<cfif (leftOver NEQ 0)>
					<cfset reallocPercentCalculated++ />
					<cfset leftOver-- />
				</cfif>
				<cfquery name="UpdatePercentAllocData" datasource="#application.datasource#">
						UPDATE 	Program_Lump_Sum_Product_Data
						SET 	Product_Percent_Allocation = <cfqueryparam value="#reallocPercentCalculated#" cfsqltype="CF_SQL_INTEGER">
						WHERE 	Program_Lump_Sum_Product_Data_ID = <cfqueryparam value="#qGetContractProds2.Program_Lump_Sum_Product_Data_ID#" cfsqltype="CF_SQL_IDSTAMP">
				</cfquery>
			</cfloop>
		</cfif>
	</cfif>
	<!--- END: 101637	Lump Sum manual allocation/Anand Rao/04-Nov-2020   --->

	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">
	</cfstoredproc>

	<!---call SP to update program contract quantity --->
	<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">
	</cfstoredproc>

<!---  <CFLOCATION URL="select_lumpsum_products.cfm?CID=#C_ID#&Program_Lump_Sum_ID=#FORM.Program_Lump_Sum_ID#"> --->

<cfif form.EZTemplate EQ 0>
 	<CFLOCATION URL="contract_edit_menu.cfm?CID=#C_ID#">
 <cfelse>
	<CFLOCATION URL="select_lumpsum_products.cfm?CID=#C_ID#&Program_Lump_Sum_ID=#FORM.Program_Lump_Sum_ID#&EZTemplate=#form.EZTemplate#">
 </cfif>

<!---*******************************************************ADDING PRODUCTS********************************************************************--->
<cfelse>

	<CFPARAM NAME="form.Product_Group_ID" DEFAULT="">
	<CFPARAM NAME="form.Product_Group_Level_ID" DEFAULT="">
	<CFPARAM NAME="form.Pricing_Level_ID" DEFAULT="0">
	<cfparam name="FORM.Product_Level_1" 	default="">
	<cfparam name="FORM.Level_1" 			default="">
	<cfset groupLevel = 0>
	<cfset groupId = "">

<!--- Dev Note: Drachala; D27822: Add validation on RFA that lump sum has products START--->
		<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
			<cfquery name="getLumpSumProducts" datasource="#application.datasource#">
				SELECT 	*
				FROM 	fn_GetLumpSumProducts(#FORM.Program_ID#, '#FORM.Program_Lump_Sum_ID#')
			</cfquery>
				     <cfif #getLumpSumProducts.recordcount# GT 0 AND listlen(Product_list) EQ 0>
						  	 <cfset Product_list = ListAppend(Product_list, "#getLumpSumProducts.BSA_FOODSERVICE_ITEMS_MASTER_ID#")>
							 <cfset lumpsum_product_error = "yes">
					 </cfif>
		</cfif>
	<!--- Dev Note: Drachala; D27822: Add validation on RFA that lump sum has products END--->

	<cfif Len(FORM.Product_Level_1) GT 0>

		<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
		<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
		<cfset form.Product_List = groupLevelProductId />
		<cfset groupLevel = 1>
		<cfset groupId = FORM.Product_Level_1>

	</cfif>

	<CFQUERY NAME="getProductsToDelete" datasource="#application.datasource#">

		SELECT	Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, Program_Lump_Sums.Program_Lump_Sum_ID, Program_Lump_Sums.Program_ID
		FROM	Program_Lump_Sums
		INNER JOIN Program_Lump_Sum_Product_Data
		ON Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
		INNER JOIN Contract_Products
		ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
		WHERE   (Contract_Products.Deleted = 0)
		AND 	(Program_Lump_Sum_Product_Data.Deleted = 0)
		AND 	(Program_Lump_Sums.Program_ID = '#FORM.Program_ID#')
		AND 	Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
		<CFIF listlen(Product_List) GT 0>
		AND (Contract_Products.BSA_Foodservice_Items_Master_ID NOT IN(#listqualify(Product_List, "'")#))
		</CFIF>
		<!---handle for groups--->
		<cfif trim(FORM.Level_1) neq "">
		AND Contract_Products.Product_Group_ID NOT IN (#listqualify(FORM.Level_1, "'")#)
		</cfif>

	</CFQUERY>

	<CFSET listofitemstodelete = valuelist(getProductsToDelete.Contract_Products_ID)>

	<CFIF listlen(listofitemstodelete) GT 0>

		<CFQUERY NAME="deleteCurrentProgramProducts" datasource="#application.datasource#">
			UPDATE Contract_Products
			SET Deleted = 1
			WHERE Contract_Products_ID IN(#listofitemstodelete#)
		</CFQUERY>

		<CFQUERY NAME="DeleteProductMargin" datasource="#application.datasource#">
			UPDATE Contract_Product_Margin
			SET Deleted = 1
			WHERE Contract_Product_ID IN(#listofitemstodelete#)
		</CFQUERY>


		<CFQUERY NAME="deleteCurrentProgramProductsFromLumpSumProducts" datasource="#application.datasource#">
			UPDATE Program_Lump_Sum_Product_Data
			SET Deleted = 1
			WHERE Contract_Products_ID IN(#listofitemstodelete#)
		</CFQUERY>

	</CFIF>

	<CFQUERY NAME="getActiveProducts" datasource="#application.datasource#">
		SELECT	Contract_Products.Contract_Products_ID,
				Contract_Products.BSA_Foodservice_Items_Master_ID,
				Program_Lump_Sums.Program_Lump_Sum_ID,
				Program_Lump_Sums.Program_ID
		FROM	Program_Lump_Sums
		INNER JOIN Program_Lump_Sum_Product_Data
		ON Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
		INNER JOIN Contract_Products
		ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
		WHERE	Contract_Products.Deleted = 0
		AND		Program_Lump_Sum_Product_Data.Deleted = 0
		AND 	Program_Lump_Sums.Program_ID = '#FORM.Program_ID#'
		AND 	Program_Lump_Sums.Program_Lump_Sum_ID = '#FORM.Program_Lump_Sum_ID#'
	</CFQUERY>

	<cfset listofactiveproducts = valuelist(getActiveProducts.BSA_Foodservice_Items_Master_ID)>

<!--- handle form.level_1 if it's null and product list is not null ---->
	<cfif form.level_1 eq "" and form.product_list neq "">
		<CFQUERY NAME="getProductListFromItemMaster" datasource="#application.datasource#">
			select *
			from contract_products
			where deleted = 0
			and BSA_Foodservice_Items_Master_ID in (#ListQualify(form.product_list,"'",",","ALL")#)
			and contract_main_id = #FORM.Program_ID#
			and is_group = 1
		</CFQUERY>
		<cfif getProductListFromItemMaster.recordCount gt 0>
			<cfset form.level_1 = valueList(getProductListFromItemMaster.BSA_Foodservice_Items_Master_ID) >
			<cfset form.GroupLevel_1 = getProductListFromItemMaster.product_group_level_id />
		</cfif>
	</cfif>

	<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(FORM.Program_ID) />
<cfif form.EZTemplate EQ 0>
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset weeklyVolume = ProductGroupManager.getPerProductVolume(FORM.Program_ID, qProgram, groupLevel) />
<cfelse>
<cfset weeklyVolume =0>
</cfif>

	<cfparam name="Has_Groups" default="0" />

<!---77408 Product Group sequencing START--->
<cfif application.appSettingsGet.get_Setting('Product_Group_Sequencing') eq '1'>
	<cfloop from="1" to="8" index="levels">
		<cfif len(form['level_#levels#'])>
			<cfloop list="#form['level_#levels#']#" index="products" delimiters=",">
				<cfif listfind(listofactiveproducts,products, ",") EQ 0>
					<cfset form.Pricing_Level_ID = levels />
					<cfset groupLevel = form['GroupLevel_#levels#'] />
					<cfset Has_Groups = 1 />
					<cfset Is_Group = 1 />

					<cfset useLakebaseForsaveContractProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForsaveContractProducts>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_products", {
			"bsa_foodservice_items_master_id" = "#products#",
			"contract_main_id" = "#FORM.Program_ID#",
			"product_type_id" = "3",
			"product_group_level_id" = "#groupLevel#",
			"product_group_id" = "#products#",
			"pricing_level_id" = "#form.Pricing_Level_ID#",
			"is_group" = "#Is_Group#",
			"dynamic_static_groups" = "#form.Dynamic_Static_Groups#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveContractProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveContractProducts>
<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
						INSERT INTO Contract_Products (BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Product_Group_ID, Pricing_Level_ID, Is_Group, Dynamic_Static_Groups)
						VALUES 	('#products#', '#FORM.Program_ID#', 3, #groupLevel#, '#products#', '#form.Pricing_Level_ID#', #Is_Group#, #form.Dynamic_Static_Groups#)
						SELECT SCOPE_IDENTITY() AS Contract_Products_ID
					</CFQUERY>
</cfif>

					<cfset useLakebaseForInsertNewProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_product_data")>
<cfif useLakebaseForInsertNewProduct>
	<cftry>
		<cfset application.oLakebase.insertRow("program_lump_sum_product_data", {
			"program_lump_sum_id" = "#FORM.Program_Lump_Sum_ID#",
			"contract_products_id" = "#saveContractProducts.Contract_Products_ID#",
			"volume" = "#weeklyVolume#",
			"is_group" = "#Is_Group#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertNewProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertNewProduct>
<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
						INSERT INTO Program_Lump_Sum_Product_Data(Program_Lump_Sum_ID, Contract_Products_ID, Volume, Is_Group)
						VALUES	('#FORM.Program_Lump_Sum_ID#', '#saveContractProducts.Contract_Products_ID#', '#weeklyVolume#', #Is_Group#)
					</CFQUERY>
</cfif>

					<cfset listofactiveproducts = listAppend(listofactiveproducts, products)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop list="#form.Product_List#" index="products" delimiters=",">
				<cfif listfind(listofactiveproducts,products, ",") EQ 0>
					<cfset form.Pricing_Level_ID = levels />
					<cfset groupLevel = 9 />
					<cfset Has_Groups = 0 />
					<cfset Is_Group = 0 />

					<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
						INSERT INTO Contract_Products (BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Product_Group_ID, Pricing_Level_ID, Is_Group, Dynamic_Static_Groups)
						VALUES 	('#products#', '#FORM.Program_ID#', 3, #groupLevel#, '', '#form.Pricing_Level_ID#', #Is_Group#, #form.Dynamic_Static_Groups#)
						SELECT SCOPE_IDENTITY() AS Contract_Products_ID
					</CFQUERY>

					<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
						INSERT INTO Program_Lump_Sum_Product_Data(Program_Lump_Sum_ID, Contract_Products_ID, Volume, Is_Group)
						VALUES	('#FORM.Program_Lump_Sum_ID#', '#saveContractProducts.Contract_Products_ID#', '#weeklyVolume#', #Is_Group#)
					</CFQUERY>
				</cfif>
				<cfset listofactiveproducts = listAppend(listofactiveproducts, products)>
			</cfloop>
		</cfif>
	</cfloop>


	<!--- BELOW FUNCTION WILL UPDATE LEVELS CORRECTLY--->
	<cfset oProgram = CreateObject("component", "components.programs.program").UpdateProductsPricingLevel(contract_main_id = Form.Program_ID, Product_Type_ID = 3)>

<cfelse>

	<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#" DELIMITERS=",">
		<CFIF listfind(listofactiveproducts,Product_ID, ",") EQ 0>
			<cfparam name="Is_Group" default="0" />
			<cfparam name="form.Pricing_Level_ID" default="0" />
 			<!---if groups deals are on then handle for it--->
			<cfif Form.Discount_Lump_Sums_Group_Level eq 1>

				<!---if we find any of the id's in the level buckets then we have to handle for the group--->
				<!---handle for each pricing level--->
				<cfif ListFindNoCase(form.Level_1, Product_ID)>

					<cfset form.Pricing_Level_ID = 1 />
					<cfset groupLevel = form.GroupLevel_1 />
					<!---set group id to the product id since the group id is acting like a product id--->
					<cfset groupId = Product_ID />
					<cfset Has_Groups = 1 />
					<cfset Is_Group = 1 />

				<cfelse>

					<cfset Is_Group = 0 />

				</cfif>

			</cfif>

			<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
				INSERT INTO Contract_Products (BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Product_Group_ID, Pricing_Level_ID, Is_Group, Dynamic_Static_Groups)
				VALUES 	('#Product_ID#', '#FORM.Program_ID#', 3, #groupLevel#, '#groupId#', '#form.Pricing_Level_ID#', #Is_Group#, #form.Dynamic_Static_Groups#)
				SELECT SCOPE_IDENTITY() AS Contract_Products_ID
			</CFQUERY>

			<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
				INSERT INTO Program_Lump_Sum_Product_Data(Program_Lump_Sum_ID, Contract_Products_ID, Volume, Is_Group)
				VALUES	('#FORM.Program_Lump_Sum_ID#', '#saveContractProducts.Contract_Products_ID#', '#weeklyVolume#', #Is_Group#)
			</CFQUERY>

			<!---if it's a group then call SP to add all items to contract products for this group--->
		</CFIF>

	</CFLOOP>

	</cfif>
<!---77408 Product Group sequencing END--->
	<!---flag groups to be processed if adding groups--->
	<cfif Has_Groups>

		<cfset useLakebaseForqFlagGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqFlagGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#FORM.Program_ID#"
			},
			{
				"group_processed" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqFlagGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqFlagGroup>
<cfquery name="qFlagGroup" datasource="#application.datasource#">

			UPDATE	Contract_Main
			SET		Group_Processed = 1
			WHERE	Deleted = 0
			AND 	Contract_Main_ID = #FORM.Program_ID#

		</cfquery>
</cfif>

	</cfif>


	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

	<!---call SP to update program contract quantity --->
	<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

	<cfif groupLevel EQ 1>
		<cfset ProductGroupManager.updateOtherAvgProductVolume(Form.Program_ID) />
	</cfif>

	<cfif qProgram.recordCount>

	 	<!------ update volume ----->
		<cfquery name="qUpdateVolume" datasource="#application.datasource#">
			UPDATE	Program_Lump_Sum_Product_Data
			SET 	Program_Lump_Sum_Product_Data.Volume =
					(
						SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
						FROM	Program_Product_Volume
						WHERE
								Program_Product_Volume.Deleted = 0
								AND
								Program_Product_Volume.Program_ID = Contract_Products.Contract_Main_ID
								AND
								Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					)
			FROM	Program_Lump_Sum_Product_Data
					INNER JOIN	Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
			WHERE
					Program_Lump_Sum_Product_Data.Deleted = 0
					AND
					Program_Lump_Sum_Product_Data.Volume IS NULL
					AND
					Contract_Products.Contract_Main_ID = #FORM.Program_ID#
		</cfquery>

	</cfif>

	<cfparam name="Form.Sort_By" 	default="Description">

	<CFLOCATION URL="select_lumpsum_products.cfm?CID=#C_ID#&Program_Lump_Sum_ID=#FORM.Program_Lump_Sum_ID#&EZTemplate=#form.EZTemplate#&lumpsum_product_error=#lumpsum_product_error#">


<!--- <CFSET thisPage=ListFirst(CGI.HTTP_REFERER,"?")>
<CFSET urlList=Mid(CGI.HTTP_REFERER,Len(thisPage)+2,Len(CGI.HTTP_REFERER)-Len(thisPage)-1)>

<CFSET fullUrl="">
<cfloop LIST=#urlList# INDEX="thisURLItem" DELIMITERS="&">
	<CFIF LISTFirst(thisURLItem,"=") NEQ "Sort_By">
		<CFSET fullUrl=ListAppend(fullUrl, "#LISTFirst(thisURLItem,"=")#=#LISTLast(thisURLItem,"=")#","&")>
	</CFIF>
</cfloop>
<CFIF Len(fullUrl) GT 0>
	<CFSET fullUrl="#thisPage#?#fullUrl#&">
<CFELSE>
	<CFSET fullUrl="#thisPage#?">
</CFIF>


<CFLOCATION URL="#fullUrl#Sort_By=#Form.Sort_By#"> --->

<!------<CFLOCATION URL="#CGI.HTTP_REFERER#">----->

</cfif>
