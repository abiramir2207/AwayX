<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<CFSET FORM.Program_ID = cryp.value>
<cfparam name="Is_Group" default="0" />
<cfparam name="This_Has_Groups" default="0" />
<cfparam name="form.Like_Product" default="">
<cfparam name="form.Is_Like_Product_Exist" default="0">
<cfparam name="form.RedirectPath" default="" />
<cfparam name="form.EZTemplate" default="0">
<!--- lock checker --->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfif form.EZTemplate EQ 0>
	<CFSET LockChecker_CID  = FORM.Program_ID>
	<CFINCLUDE TEMPLATE="LockChecker.cfm">
</cfif>
<!--- lock checker --->
<cfif Not isDefined("session.group_rebate_type_search_id")><cfset session.group_rebate_type_search_id = 0 ></cfif>
<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />

<cfif form.deletedateexclusions EQ 1>
	<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT 	Program_Control_Panel_Options.Date_Exclusions_ON
		FROM 	Program_Control_Panel_Options
		INNER JOIN Contract_Main
		ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		WHERE 	Contract_Main_ID = #form.program_id#
	</cfquery>

	<cfif GetSettings.Date_Exclusions_ON EQ 1>
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(form.program_id,0)>
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

<!--- (Dev Note: Milan; D7226) Delete previous products only if the same product existed in growth discount type --->
	<cfif form.Is_Like_Product_Exist eq 1>
				<cfloop list="#Product_List#" index="Prod">
					<cfset Existing_LikeProduct = ProdManager.getSimilarExistingProduct('#FORM.Program_ID#', '#Prod#')>
						<cfif Existing_LikeProduct.Recordcount neq 0>
							<cfset ProdManager.setDeleteSimilarExistingProduct('#FORM.Program_ID#','#Prod#')>
						</cfif>
				</cfloop>

<!--- Add Products (These products are generic and not related to any discount type) --->
				<cfloop list="#form.Like_Product#" index="LikeProd">
							<cfset ProdManager.setSimilarExistingProduct('#FORM.Program_ID#','#LikeProd#')>
				</cfloop>
	</cfif>
<!--- End Note: Milan; D7226 --->


<!--- START: 77405	Consolidated Growth View - Anand Rao/25-Jun-2018 --->
	<cfif (appSettings.get_Setting('Growth_Consolidated_View') EQ '1')>
		<cfset Default_UOM_Val  =  FORM.Global_UOM />
		<cfif (isDefined("FORM.TierCount") and FORM.TierCount NEQ "")>
			<cfloop index="LoopCount" from="1" to="#FORM.TierCount#" step="1">
				<cfif (isDefined("FORM.Discount_Amount_#LoopCount#") AND evaluate("FORM.Discount_Amount_#LoopCount#") NEQ "")>
					<cfquery name="qUpdateTierTable" datasource="#application.datasource#">
						UPDATE
							Program_Growth_Component_Tiers
						SET
							Default_Rate = '#evaluate("FORM.Discount_Amount_#LoopCount#")#',
							Default_UOM = '#Default_UOM_Val#'
						WHERE
							Program_ID = '#FORM.Program_ID#' AND
							Tier_Number = '#LoopCount#' AND
							Deleted = 0 AND
							Program_Growth_Component_ID= '#FORM.Component_ID#'
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>


	</cfif>

<!--- END: 77405	Consolidated Growth View - Anand Rao/25-Jun-2018 --->

<!----- delete not selected products --------------->
<CFQUERY NAME="getProductsToDelete" datasource="#application.datasource#">
		SELECT		Program_Growth_Components.Program_ID, Contract_Products.Contract_Products_ID, Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID, Contract_Products.Pricing_Level_ID
		FROM Program_Growth_Components
		INNER JOIN Contract_Products
		INNER JOIN Program_Growth_Component_Product_Data
		ON Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
		ON Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
		WHERE (Program_Growth_Components.Program_Growth_Component_ID = '#FORM.Component_ID#')
		AND (Contract_Products.Deleted = 0)
		AND (Program_Growth_Component_Product_Data.Deleted = 0)
		AND (Program_Growth_Components.Program_ID = '#FORM.Program_ID#')
		<CFIF listlen(FORM.Product_List) GT 0> AND (Contract_Products.BSA_Foodservice_Items_Master_ID NOT IN(#listqualify(Product_List, "'")#))</CFIF>
</CFQUERY>

<CFSET listofitemstodelete = valuelist(getProductsToDelete.Contract_Products_ID)>
<CFSET List_Program_Growth_Component_Product_Data_ID_To_Delete = valueList(getProductsToDelete.Program_Growth_Component_Product_Data_ID)>

<CFSET Pricing_Level_ID = valuelist(getProductsToDelete.Pricing_Level_ID)>
<cfset minPricingLevelID = ArrayMax(ListToArray(Pricing_Level_ID))>

<CFTRANSACTION isolation="read_uncommitted">
	<CFIF listlen(listofitemstodelete) GT 0>
		<CFQUERY NAME="deleteCurrentProgramProducts" datasource="#application.datasource#">
			UPDATE Contract_Products
			SET Deleted = 1
			WHERE Contract_Products_ID IN(#listofitemstodelete#)
		</CFQUERY>

<!---77408 Product Group sequencing START--->
<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
		<cfloop from=#minPricingLevelID# to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			<CFQUERY NAME="checkLevels" datasource="#application.datasource#">
				SELECT *
				FROM Contract_Products
				WHERE Deleted = 0
				AND Pricing_Level_ID = #levels#
				AND Product_Type_ID = 4
			</CFQUERY>
			<cfif checkLevels.Recordcount EQ 0>
				<cfset nextLevel = levels + 1>
				<CFQUERY NAME="checkLevels" datasource="#application.datasource#">
					UPDATE Contract_Products
					SET Pricing_Level_ID = #levels#
					WHERE Pricing_Level_ID = #nextLevel#
					AND Product_Type_ID = 4
					AND Deleted = 0
				</CFQUERY>
			</cfif>
		</cfloop>
</cfif>
<!---77408 Product Group sequencing END--->

		<CFQUERY NAME="DeleteProductMargin" datasource="#application.datasource#">
			UPDATE Contract_Product_Margin
			SET Deleted = 1
			WHERE Contract_Product_ID IN(#listofitemstodelete#)
		</CFQUERY>

	<CFQUERY NAME="deleteCurrentComponentProducts_1" datasource="#application.datasource#">
		UPDATE Program_Growth_Component_Product_Data
		SET Deleted = 1
		WHERE Program_Growth_Component_Product_Data_ID IN(#valuelist(getProductsToDelete.Program_Growth_Component_Product_Data_ID)#) AND Program_Growth_Component_ID = '#FORM.Component_ID#'
	</CFQUERY>

	<CFQUERY NAME="deleteCurrentComponentProducts_2" datasource="#application.datasource#">
		UPDATE Program_Growth_Component_Product_Tier_Data
		SET Deleted = 1
		WHERE Program_Growth_Component_Product_Data_ID IN(#List_Program_Growth_Component_Product_Data_ID_To_Delete#)
		</CFQUERY>
	</CFIF>
</CFTRANSACTION>

<CFQUERY NAME="getActiveProducts" datasource="#application.datasource#">
		SELECT Program_Growth_Components.Program_ID, Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID,
		Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
		FROM Program_Growth_Components
		INNER JOIN Contract_Products
		INNER JOIN Program_Growth_Component_Product_Data
		ON Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
		ON Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_ID
		WHERE (Contract_Products.Deleted = 0)
		AND (Program_Growth_Component_Product_Data.Deleted = 0)
		AND (Program_Growth_Components.Program_ID = '#FORM.Program_ID#')
		AND (Program_Growth_Components.Program_Growth_Component_ID = '#FORM.Component_ID#')
</CFQUERY>

<cfset listofactiveproducts = trim(valuelist(getActiveProducts.BSA_Foodservice_Items_Master_ID))>

<cfset thisProduct_Tier_Data_List ="">


<cfset programManager = CreateObject("component", "components.programs.program") />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset qProgram = programManager.getProgramInfo(Form.Program_ID) />
<cfset allProductSelected = false>
<cfif form.EZTemplate EQ 0>
<cfset contractSpan = DateDiff("d", qProgram.Contract_Start_Date, qProgram.Contract_End_Date) + 1 />
<cfset TotalWeeklyQty = (qProgram.Contract_Quantity * 7) / contractSpan />
<cfset weeklyVolume = ProductGroupManager.getPerProductVolume(Form.Program_ID, qProgram) />
<cfelse>
<cfset weeklyVolume =0>
</cfif>

<!---get settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />

<CFSET GrowthDataStruct = StructNew()>
<!--- holds all the products supplied from the form page --->
<CFSET GrowthDataStruct.Products = StructNew()>

<CFLOOP INDEX="This_Product_ID" LIST="#FORM.Product_List#">
	<CFSET Field_Name_Product_ID = replace(This_Product_ID, "-", "_", "ALL")>
	<cfif isDefined("Tier_#ListFirst(FORM.Tier_List)#_Product_Rate_#Field_Name_Product_ID#")>
		<!--- add a placeholder for this products information --->
		<CFSET ProductCount = ListLen(StructKeyList(GrowthDataStruct.Products))+1>
		<CFSET "GrowthDataStruct.Products.Product_#ProductCount#" = StructNew()>
		<!--- make it easier to access this level structure --->
		<CFSET ThisLevelStruct = evaluate("GrowthDataStruct.Products.Product_#ProductCount#")>
		<!---- insert product id ---->
		<CFSET temp = StructInsert(ThisLevelStruct, "BSA_Foodservice_Items_Master_ID", This_Product_ID)>

		<cfif session.group_rebate_type_search_id  gt 0>
			<cfset qProductGroup = ProductGroupManager.getGroupFromProduct(This_Product_ID,1,session.group_rebate_type_search_id,FORM.Program_ID) />
		<cfelse>
			<cfset qProductGroup = ProductGroupManager.getGroupFromProduct(This_Product_ID, 1) />
		</cfif>
		<!------ Find product group ----->
		<CFSET ThisLevelStruct.productGroupLevel = qProductGroup.Product_Group_Level_ID>
		<CFSET ThisLevelStruct.productGroupId = qProductGroup.Product_Group_ID>
		<cfset ThisLevelStruct.weeklyQty = weeklyVolume>
		<cfif ThisLevelStruct.productGroupLevel EQ 1>
			<cfset ThisLevelStruct.weeklyQty = TotalWeeklyQty>
			<cfset allProductSelected = true>
		</cfif>
		<!--- create a Tiers Collection --->
		<CFSET ThisLevelStruct.Tier_Rates = StructNew()>
		<!--- add the tiers to the tiers colection --->
		<CFLOOP INDEX="This_Tier_ID" LIST="#FORM.Tier_List#" DELIMITERS=",">
			<CFSET ThisLevelStruct = evaluate("GrowthDataStruct.Products.Product_#ProductCount#")>
			<cfset TierCount = ListLen(StructKeyList(ThisLevelStruct.Tier_Rates))+1>
			<CFSET "ThisLevelStruct.Tier_Rates.Tier_#TierCount#" = StructNew()>
			<!--- make it easier to access this level structure --->
			<CFSET ThisLevelStruct = evaluate("ThisLevelStruct.Tier_Rates.Tier_#TierCount#")>
			<CFSET temp = StructInsert(ThisLevelStruct, "Program_Growth_Component_Tier_ID", replace(This_Tier_ID,"_","-","ALL"))>
			<CFSET temp = StructInsert(ThisLevelStruct, "Rate", evaluate("Tier_#This_Tier_ID#_Product_Rate_#Field_Name_Product_ID#"))>
			<CFSET temp = StructInsert(ThisLevelStruct, "Rate_UOM", evaluate("Tier_#This_Tier_ID#_Product_Rate_#Field_Name_Product_ID#_UOM"))>
		</CFLOOP>
	</cfif>
</CFLOOP>
<cfif session.group_rebate_type_search_id  gt 0	and form.product_list neq "">
	<cfset form.GROUPLEVELPRODUCTS = 1 >
	<cfset maxPricingLevelForSelectedRebateType = ProductGroupManager.getMaxPricingLevelForSelectedRebateType(session.group_rebate_type_search_id,FORM.Program_ID) />
	<cfloop index="i" from="1" to="#maxPricingLevelForSelectedRebateType#" step="1">
		<cfset qProductGroupFromSelectedRebateType = ProductGroupManager.getGroupFromSelectedRebateType(form.product_list,session.group_rebate_type_search_id,FORM.Program_ID,i) />
		<cfif qProductGroupFromSelectedRebateType.recordCount gt 0>
			<cfset "form.LEVEL_#i#" = valueList(qProductGroupFromSelectedRebateType.product_group_id) >
			<cfset "form.GROUPLEVEL_#i#" = qProductGroupFromSelectedRebateType.product_group_level_id >
		</cfif>
	</cfloop>
</cfif>
<!--- walk the data for data recording--->
<CFLOOP INDEX="Product_Collection" LIST="#StructKeyList(GrowthDataStruct.Products)#" DELIMITERS=",">
	<CFSET Product_Data_Collection = evaluate("GrowthDataStruct.Products.#Product_Collection#")>
	<CFSET Product_ID = Product_Data_Collection.BSA_Foodservice_Items_Master_ID>
	<cfset Is_Group = 0 />

	<cfparam name="form.Pricing_Level_ID" default="0" />
<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
<!--- REARRANGE LEVELS --->
<cfif len(form["Level_#levels#"]) EQ 0>

<cfloop from="#levels#" to="#request.AccessStructure.numberOfProductGroupLevels#" index="A">
	<cfif A LT request.AccessStructure.numberOfProductGroupLevels>
	<cfset nextLevel = A + 1>
	<cfset "form.level_#A#" = form["level_#nextLevel#"]>
	<cfset "form.level_#nextLevel#" = "">
	<cfset "form.GroupLevel_#A#" = form["GroupLevel_#nextLevel#"]>
	<cfset "form.GroupLevel_#nextLevel#" = "">
</cfif>
</cfloop>

</cfif>
		<cfif ListFindNoCase(form["Level_#levels#"], Product_ID)>
				<cfif Evaluate("form.GroupLevel_#levels#") neq 9>
					<cfset Is_Group = 1 />
					<cfset This_Has_Groups = 1 />
					<cfset Product_Data_Collection.productGroupId = Product_Data_Collection.BSA_Foodservice_Items_Master_ID />
				</cfif>
				<cfset form.Pricing_Level_ID = levels />
				<cfset Product_Data_Collection.productGroupLevel = Evaluate("form.GroupLevel_#levels#") />
			</cfif>
	</cfloop>
<!---77408 Product Group sequencing END--->

	<CFTRANSACTION isolation="read_uncommitted">
	<CFIF listfind(trim(listofactiveproducts),Product_ID, ",") EQ 0>
	<cfparam name="form.Prod_Default_#replace(product_id, "-", "_", "ALL")#" default="0">
		<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
			SET NOCOUNT ON
			INSERT INTO Contract_Products	(
					BSA_Foodservice_Items_Master_ID
				, Contract_Main_ID
				, Product_Type_ID
				, Product_Group_Level_ID
				, Product_Group_ID
				, Pricing_Level_ID
				, Is_Group
				, Dynamic_Static_Groups
				, EZButton_On_Default)
			VALUES 	(
				  '#Product_ID#'
				, '#FORM.Program_ID#'
				, 4
				, <cfif val(Product_Data_Collection.productGroupLevel)> #Product_Data_Collection.productGroupLevel# <cfelse> 0 </cfif>
				, '#Product_Data_Collection.productGroupId#'
				, #form.Pricing_Level_ID#
				, #Is_Group#
				, #form.Dynamic_Static_Groups#
				, #evaluate("Prod_Default_#replace(product_id, "-", "_", "ALL")#")#
				)
			SELECT Contract_Products_ID = @@IDENTITY
			SET NOCOUNT OFF
		</CFQUERY>

		<cfset this.Contract_Products_ID = saveContractProducts.Contract_Products_ID />

		<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Product_Data (Program_Growth_Component_ID, Contract_Products_ID, Weekly_Volume, Is_Group)
			VALUES ('#FORM.Component_ID#', '#saveContractProducts.Contract_Products_ID#', '#Product_Data_Collection.weeklyQty#', #Is_Group#)
		</CFQUERY>

		<CFSET Product_Data_Collection.Program_Growth_Component_Product_Data_ID = InsertNewProduct.Program_Growth_Component_Product_Data_ID>

	<CFELSE>

		<CFQUERY NAME="Get_Program_Growth_Component_Product_Data_ID" DBTYPE="query">
			SELECT	Program_Growth_Component_Product_Data_ID, Contract_Products_ID
			FROM	getActiveProducts
			WHERE BSA_Foodservice_Items_Master_ID = '#Product_ID#'
		</CFQUERY>

		<cfset this.Contract_Products_ID = Get_Program_Growth_Component_Product_Data_ID.Contract_Products_ID />
		<cfparam name="form.Prod_Default_#replace(product_id, "-", "_", "ALL")#" default="0">

		<!---update contract products to handle for items that have been added into other levels--->
		<cfif not Is_Group>

			<cfquery name="qUpdateContractProductsForExistingProducts" datasource="#application.datasource#">
				UPDATE 	Contract_Products
				SET		Product_Group_Level_ID = 9,
						Product_Group_ID = '',
						Captured_From_Group = 0,
						Pricing_Level_ID = #form.Pricing_Level_ID#,
						EZButton_On_Default = #evaluate("Prod_Default_#replace(product_id, "-", "_", "ALL")#")#
				WHERE	Deleted = 0
				AND		Contract_Products_ID = #this.Contract_Products_ID#
			</cfquery>
		<cfelse>
			<cfquery name="qUpdateContractProducts_EZDefaultSetting" datasource="#application.datasource#">
				UPDATE 	Contract_Products
				SET		EZButton_On_Default = #evaluate("Prod_Default_#replace(product_id, "-", "_", "ALL")#")#
				WHERE	Deleted = 0
				AND		Contract_Products_ID = #this.Contract_Products_ID#
			</cfquery>
		</cfif>

		<CFSET Product_Data_Collection.Program_Growth_Component_Product_Data_ID = Get_Program_Growth_Component_Product_Data_ID.Program_Growth_Component_Product_Data_ID>

	</CFIF>
	<!--- loop through the tiers and update those records --->
	<CFLOOP INDEX="Tier_Collection" LIST="#StructKeyList(Product_Data_Collection.TIER_RATES)#">
		<CFSET Product_Tier_Data = evaluate("Product_Data_Collection.Tier_Rates.#Tier_Collection#")>

		<!--- check for tier information --->
		<CFQUERY NAME="getProductTierInformation" datasource="#application.datasource#">
			SELECT Program_Growth_Component_Product_Tier_Data_ID
			FROM Program_Growth_Component_Product_Tier_Data
			WHERE 	Program_Growth_Component_Product_Data_ID 	= '#Product_Data_Collection.Program_Growth_Component_Product_Data_ID#'
			AND Program_Growth_Component_Tier_ID = '#Product_Tier_Data.Program_Growth_Component_Tier_ID#'
			AND Deleted = '0'
		</CFQUERY>

		<!--- 76380 decimal places START--->
			<cfset decimalprecision = GenProgramManager.decimalPrecisionByUOM(Product_Tier_Data.RATE_UOM,1)>
		<!--- 76380 decimal places END--->

		<!--- if there is tier info update it --->
		<CFIF getProductTierInformation.recordcount GT 0>

			<!--- update tier information --->
			<CFQUERY NAME="updateTierInformation" datasource="#application.datasource#">
					UPDATE Program_Growth_Component_Product_Tier_Data
					SET Rate 	=
					<cfif Product_Tier_Data.RATE_UOM eq 1>
					'#NumberFormat(Product_Tier_Data.RATE, decimalprecision)#'
					<cfelse>
					'#Product_Tier_Data.RATE#'
					</cfif>
					, Unit_Of_Measure_ID							= '#Product_Tier_Data.RATE_UOM#'
					, Is_Group									= #Is_Group#
					, Captured_From_Group							= 0
					WHERE Program_Growth_Component_Product_Data_ID 	= '#Product_Data_Collection.Program_Growth_Component_Product_Data_ID#'
					AND Program_Growth_Component_Tier_ID = '#Product_Tier_Data.Program_Growth_Component_Tier_ID#'
					AND Deleted	= '0'
			</CFQUERY>
		<CFELSE>
			<!--- insert new tier info--->
			<CFQUERY NAME="insertTierInformation" datasource="#application.datasource#">
				INSERT INTO Program_Growth_Component_Product_Tier_Data	(	Program_Growth_Component_Product_Data_ID,Program_Growth_Component_Tier_ID,Rate,Unit_Of_Measure_ID, Is_Group)
				VALUES
				('#Product_Data_Collection.Program_Growth_Component_Product_Data_ID#','#Product_Tier_Data.Program_Growth_Component_Tier_ID#',<cfif Product_Tier_Data.RATE_UOM eq 1> '#NumberFormat(Product_Tier_Data.RATE, decimalprecision)#'<cfelse>'#Product_Tier_Data.RATE#'</cfif>,'#Product_Tier_Data.RATE_UOM#', #Is_Group#)
			</CFQUERY>
		</CFIF>
	</CFLOOP>
		<CFTRANSACTION ACTION="COMMIT">	</CFTRANSACTION>
</CFLOOP>

<!---flag groups to be processed if adding groups--->
<cfif This_Has_Groups>
	<cfquery name="qFlagGroup" datasource="#application.datasource#">

		UPDATE	Contract_Main
		SET		Group_Processed = 1
		WHERE	Deleted = 0
		AND 	Contract_Main_ID = #FORM.Program_ID#

	</cfquery>

</cfif>

<cfif allProductSelected>
	<cfset ProductGroupManager.updateOtherAvgProductVolume(Form.Program_ID) />
</cfif>
	<!------ get volume uom ----->
	<cfif qProgram.recordCount>

	 	<!------ update volume ----->
		<cfquery name="qUpdateVolume" datasource="#application.datasource#">
			UPDATE	Program_Growth_Component_Product_Data
			SET 	Captured_From_Group = 0
						, Program_Growth_Component_Product_Data.Weekly_Volume =
					(
						SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
						FROM	Program_Product_Volume
						WHERE Program_Product_Volume.Deleted = 0
						AND Program_Product_Volume.Program_ID = Contract_Products.Contract_Main_ID
						AND Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					)
			FROM	Program_Growth_Component_Product_Data
			INNER JOIN	Contract_Products
			ON Contract_Products.Deleted = 0
			AND Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
			WHERE Program_Growth_Component_Product_Data.Deleted = 0
			AND (Program_Growth_Component_Product_Data.Weekly_Volume IS NULL OR ISNUMERIC(Program_Growth_Component_Product_Data.Weekly_Volume) = 0)
			AND Contract_Products.Contract_Main_ID = #Form.Program_ID#
		</cfquery>

	</cfif>

<!---77408 Product Group sequencing START--->
<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
	<!--- BELOW FUNCTION WILL UPDATE LEVELS CORRECTLY--->
	<cfset oProgram = CreateObject("component", "components.programs.program").UpdateProductsPricingLevel(contract_main_id = Form.Program_ID, Product_Type_ID = 4)>
</cfif>
<!---77408 Product Group sequencing END--->

	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

	<!---call SP to update program contract quantity --->
	<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

<cfif form.RedirectPath EQ "">
	<CFLOCATION URL="Contract_Discount_Growth.cfm?CID=#cryp.string#&EZTemplate=#form.EZTemplate#">
<cfelse>
	<CFLOCATION URL="Contract_Discount_Growth_Margin.cfm?CID=#cryp.string#&marginedit_saved=1">
</cfif>