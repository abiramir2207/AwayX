<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
 <cfset encryp_program_id = FORM.Program_ID>
 <cfparam name="form.deletedateexclusions" default="0">
 <cfparam name="form.Like_Product" default="">
 <cfparam name="form.Is_Like_Product_Exist" default="0">
 <cfparam name="RedirectPath" default="">
 <cfparam name="form.EZTemplate" default="0">
 <cfparam name="form.fixedfreight_on" default="0">
 <cfparam name="VendorSelection" default="">
 <cfparam name="form.priceListID" default="">
 <cfparam name="form.bFromMargin" default="0">
 <cfparam name="FORM.currentTxtPercentage" default="">
 <cfparam name="form.DoNotRedirectToNextPage" default="0">

<cfset FORM.Program_ID = '#cryp.value#'>
<cfset variables.resetFreight = false />
<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset compBusRule = createObject("component","components.programs.fixed.FixedComponentBusinessRule")>
<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset fixedComponentObj = CreateObject("component", "components.programs.Fixed.FixedComponent") />
<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight") />
<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- lock checker --->
<cfif form.EZTemplate EQ 0>
<CFSET LockChecker_CID  = cryp.value>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
</cfif>
<!--- lock checker --->

<CFQUERY NAME = "Date_exclusion_settings" datasource="#Application.Datasource#">
	SELECT	Date_Exclusions_ON, Ideal_Price
	FROM	  Contract_Main
	INNER JOIN Program_Control_Panel_Options
	ON		 Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE Contract_Main.Contract_Main_ID =  #Form.Contract_Main_ID#
</CFQUERY>

<cfif form.deletedateexclusions EQ 1>
	<cfif Date_exclusion_settings.Date_Exclusions_ON EQ 1>
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(Form.Contract_Main_ID,0)>
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
<!--- Delete all the existing instances --->
<CFTRANSACTION ACTION="BEGIN">
<CFQUERY NAME="deletecontractproducts" datasource="#application.datasource#">
	UPDATE contract_products
	set deleted = 1
	where contract_main_id = '#FORM.Program_ID#'
	and Product_Type_ID = 1
</CFQUERY>

<CFQUERY NAME="deletefixedproductdata" datasource="#application.datasource#">
	UPDATE Program_Fixed_Price_Product_Data
	set deleted = 1
	where Program_ID = '#FORM.Program_ID#'
</CFQUERY>

<!--- Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  START
Changed/Added: SELECT Statement to prevent having multiple active records for same program--->
<cfquery name="Pull_Won_By" datasource="#application.datasource#">
	SELECT *
	FROM Program_Bid_Won_By
	WHERE Program_Bid_Won_By_Code = '#FORM.Program_ID#' AND Deleted = 0
</cfquery>
<cfset other_desc_list = valuelist(Pull_Won_By.Program_Bid_Won_By_Description,",")>
<!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->

<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
--->
<CFQUERY NAME="qGetVolumeOverrideSelection" datasource="#application.datasource#">
	SELECT	DISTINCT Dont_Count_Volume, Program_Fixed_Component_Name_ID
	FROM	Program_Fixed_Component
	WHERE	Deleted = 0
	AND		Program_ID = '#FORM.Program_ID#'
	AND		Dont_Count_Volume = 1
</CFQUERY>

<CFQUERY NAME="deletefixedcomponentdata" datasource="#application.datasource#">
	UPDATE Program_Fixed_Component
	set deleted = 1
	where Program_ID = '#FORM.Program_ID#'
</CFQUERY>
<!--- End Delete all the existing instances --->

<!--- If "Use Fixed Price Type" app setting is ON --->
<cfif appSettings.getUseFixedPriceType()>
<!--- Only if the "priceListID" (priceBracket) exists --->
	<cfif form.priceListID neq "">
		<!--- Check whether the "priceListID" (priceBracket) got modified. --->
		<cfset priceBracketUpdate = GenProgramManager.getPriceListBracketOverridden(FORM.Program_ID,form.priceListID,1)>
		<!--- If the "priceListID" (priceBracket) got modified. --->
		<cfif priceBracketUpdate eq 1>
			<CFQUERY NAME="qUpdPriceBracket" datasource="#application.datasource#">
				UPDATE Contract_Main_Aux_Data
				SET Price_List_ID = '#form.priceListID#'
						,PriceBracket_Update = 1
						,PriceBracket_Update_Date = getdate()
						,PriceBracket_Update_By = '#request.AccessStructure.User_ID#'
				WHERE contract_Main_ID = '#FORM.Program_ID#'
			</CFQUERY>
		</cfif>
	</cfif>
</cfif>

<!--- (Dev Note: Milan; D7226) Delete previous products only if the same product existed in fixed discount type --->
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

<CFSET insertproductids = "">

	<cfif ! isDefined('compileComponentInfo')>
		<cfinclude template="Contract_Discount_Fixed_Component_Functions.cfm" />
	</cfif>

	<cfif form.EZTemplate EQ 0>
		<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(Form.Program_ID) />
		<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
		<cfset weeklyVolume = ProductGroupManager.getPerProductVolume(Form.Program_ID, qProgram) />
	</cfif>

	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<cfset paymentCycleManager.DeletePaymentCycle(Form.Program_ID, 1) />
	</cfif>

		<cfset program_fixed_component_name_id_list = "" />


		<cfloop from="1" to="#ListLen(form.FIXEDCOMPONENTLIST)#" index="i">
			<cfset temp_comp_id = ListGetAt(form.FIXEDCOMPONENTLIST,i)>
			<cfset fixed_comp_id = getComponentNameId(temp_comp_id) />
			<cfset fixed_comp_paid_to = getComponentPaidTo(temp_comp_id) />
			<cfset fixed_treatment_code = getComponentTreatmentCode(temp_comp_id) />
			<cfset fixed_basis_code = getComponentBasisCode(temp_comp_id) />
			<cfset Claim_Mechanics = getClaimMechanics(temp_comp_id) />
			<cfset GL_Account_ID = getGL_Account_ID(temp_comp_id) />
			<cfset Vendor_Master_ID = getVendor_Master_ID(temp_comp_id) />
			<cfset PaymentCycle = getPaymentCycle(temp_comp_id) />
			<cfset VendorSelection = getVendorSelection(temp_comp_id) />
			<cfset Parent_Program_Fixed_Component_ID = getParentProgramFixedComponentID(temp_comp_id) />
			<cfset program_fixed_component_name_id_list = ListAppend(program_fixed_component_name_id_list, fixed_comp_id) />
			<cfset Payee_Selection = getPayeeSelection(temp_comp_id) />

		<!--- "CHECK IF COMPONENT ALREADY EXIST ON PROGRAM IF YES DONOT INSERT" --->
		<cfquery name="checkComp" datasource="#application.datasource#">
			SELECT *
			FROM Program_Fixed_Component
			WHERE Program_ID = '#FORM.Program_ID#'
			AND Program_Fixed_Component_Name_ID = #fixed_comp_id#
			AND Deleted = 0
		</cfquery>

		<cfif checkComp.Recordcount eq 0>

			<cfquery NAME="deletefixedcomponentdata" datasource="#application.datasource#">
				UPDATE Program_Fixed_Component
				set deleted = 1
				where Program_ID = '#FORM.Program_ID#'
				AND Program_Fixed_Component_Name_ID = #fixed_comp_id#
			</cfquery>

			<!--- "<cfquery NAME="deletecontractproducts" datasource="#application.datasource#">
							UPDATE contract_products
							set deleted = 1
							where contract_main_id = '#FORM.Program_ID#'
							and Product_Type_ID = 1
						</cfquery>" --->
			<cfquery NAME="deletefixedproductdata" datasource="#application.datasource#">
				UPDATE PFPPD
				SET PFPPD.Deleted = 1
				FROM Program_Fixed_Price_Product_Data AS PFPPD
				INNER JOIN Program_Fixed_Component AS PFC
				ON PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID
				WHERE PFC.Program_Fixed_Component_Name_ID  = #fixed_comp_id#
				AND PFPPD.Deleted = 0
				AND	PFC.Program_ID = '#FORM.Program_ID#'
			</cfquery>

		<!--- This happens when app setting called (Restrict_Pay_Each) is ON. It is being passed from claim_mech_info.cfm --->
		<cfif VendorSelection IS "true">
			<cfset VendorSelection = 1>
		</cfif>

		<CFQUERY NAME="qBusRuleReq" datasource="#application.datasource#">
			SELECT 	rule_required, External_ID, Formula_Pricing
			FROM 	Program_Fixed_Component_Name
			WHERE 	Program_Fixed_Component_Name_ID = #fixed_comp_id#
		</CFQUERY>
		<!--- If required business rule, we insert the Id below...at product level --->
		<cfset formulaPricing = qBusRuleReq.Formula_Pricing>
		<cfset isReq = qBusRuleReq.rule_required>
		<cfset fixrule = compBusRule.getComponentRules(fixed_comp_id,1).Program_Fixed_Component_Rule_ID>
		<cfscript>
			thisFormulaPrice = 0;
			if(formulaPricing){
				oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
				q = oFormula.getProgramFormula(#Form.Program_Id#);
				if(q.recordCount != 0){
					if(isnumeric(q.Formula_Price)){
						thisFormulaPrice = q.Formula_Price_Rounded;
					}
				}
			}
		</cfscript>
		<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
		Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
		--->
		<cfset variables.bDontCountVolume = 0 />

		<CFQUERY NAME="qGetVolOverrideTemp" dbtype="query">
			SELECT	Dont_Count_Volume
			FROM	qGetVolumeOverrideSelection
			WHERE	Program_Fixed_Component_Name_ID = #fixed_comp_id#
		</CFQUERY>
		<cfif qGetVolOverrideTemp.RecordCount>
			<cfset variables.bDontCountVolume = qGetVolOverrideTemp.Dont_Count_Volume />
		</cfif>


		<CFQUERY NAME="addNewFixedCategory" datasource="#application.datasource#">
			SET NOCOUNT ON
			INSERT INTO Program_Fixed_Component
			(
				Program_Fixed_Component_Name_ID,
				Fixed_Component_Paid_To,
				Program_ID,
				Treatment_Code_Master_ID,
				Basis_Code_Master_ID,
				Claim_Mechanics,
				GL_Account_ID,
				<cfif VendorSelection neq 0>
				Vendor_Selection,
				</cfif>
				<cfif len(trim(Vendor_Master_ID)) AND Vendor_Master_ID NEQ 0>
					Vendor_Master_ID,
				</cfif>
				Component_External_ID,
				Parent_Program_Fixed_Component_ID,
				Payee_Type,
				Percentage_Of_List_Price,
				Dont_Count_Volume
			)
			VALUES
			(
			<cfqueryparam value="#fixed_comp_id#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#fixed_comp_paid_to#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#FORM.Program_ID#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#fixed_treatment_code#" cfsqltype="CF_SQL_INTEGER" null="#NOT IsNumeric(fixed_treatment_code) OR fixed_treatment_code EQ 0#">,
			<cfqueryparam value="#fixed_basis_code#" cfsqltype="CF_SQL_INTEGER" null="#NOT IsNumeric(fixed_basis_code) OR fixed_basis_code EQ 0#">,
			<cfqueryparam value="#Claim_Mechanics#" cfsqltype="cf_sql_integer">,
			<cfqueryparam value="#GL_Account_ID#" cfsqltype="cf_sql_integer">,
			<cfif VendorSelection neq 0>
				<cfqueryparam value="#VendorSelection#" cfsqltype="cf_sql_integer">,
			</cfif>
			<cfif len(trim(Vendor_Master_ID)) AND Vendor_Master_ID NEQ 0>
				<cfqueryparam value="#Vendor_Master_ID#" cfsqltype="cf_sql_varchar">,
			</cfif>
			<cfqueryparam value="#qBusRuleReq.External_ID#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#Parent_Program_Fixed_Component_ID#" cfsqltype="CF_SQL_INTEGER" null="#NOT IsNumeric(Parent_Program_Fixed_Component_ID) OR Parent_Program_Fixed_Component_ID EQ 0#">,
			<cfqueryparam value="#Payee_Selection#" cfsqltype="CF_SQL_INTEGER" null="#Payee_Selection EQ 0#">,
			<cfqueryparam value="#FORM.currentTxtPercentage#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#variables.bDontCountVolume#" cfsqltype="CF_SQL_BIT">
			)
			SELECT Program_Fixed_Component_ID = @@IDENTITY
			SET NOCOUNT OFF
		</CFQUERY>

		<cfset program_fixed_component_id = addNewFixedCategory.Program_Fixed_Component_ID>

		<cfif appSettings.getPaymentCycleAtDiscountType()>
			<cfset paymentCycleManager.savePaymentCycle(Form.Program_ID, 1, PaymentCycle, program_fixed_component_id) />
		</cfif>
			<!--- ITEMS INSERT --->
			<cfif len(form.product_list) NEQ 0>

		<cfloop from="1" to="#ListLen(form.PRODUCT_LIST)#" index="j">
			<cfset product_id = ListGetAt(form.PRODUCT_LIST,j)>
			<CFQUERY NAME="getcontractproducts" datasource="#application.datasource#">
				SELECT *
				FROM	Contract_Products
				where 	Contract_Main_ID = '#FORM.Program_ID#'
				AND 	product_type_id = 1
				AND 	deleted = 0
				AND 	BSA_Foodservice_Items_Master_ID = '#product_id#'
			</CFQUERY>

			<cfif getcontractproducts.recordcount EQ 0>
					<cfparam name="form.Prod_Default_#replace(product_id, "-", "_", "ALL")#" default="0">
					<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_UOM" default="">

					<cfparam name="form.fixed_#replace(product_id, "-", "_", "ALL")#_Ideal_Price_Type" default="0">
					<cfparam name="form.net_weight_#replace(product_id, "-", "_", "ALL")#" default="0">
					<cfparam name="form.fixed_#replace(product_id, "-", "_", "ALL")#_IP_VolumeCS" default="0">
					<cfparam name="form.fixed_#replace(product_id, "-", "_", "ALL")#_IP_VolumeLB" default="0">

					<cfset UOM_Selection = evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_UOM")>
					<cfset IdealPriceType = evaluate("fixed_#replace(product_id, "-", "_", "ALL")#_Ideal_Price_Type") />

				<cfif Date_exclusion_settings.Ideal_Price AND IdealPriceType EQ 2>
					<cfset netWeight = evaluate("net_weight_#replace(product_id, "-", "_", "ALL")#") />
					<cfset VolumeCS = evaluate("fixed_#replace(product_id, "-", "_", "ALL")#_IP_VolumeCS") />
					<cfset VolumeCS = replace(VolumeCS,",","","ALL")>
					<cfset VolumeLB = evaluate("fixed_#replace(product_id, "-", "_", "ALL")#_IP_VolumeLB") />
					<cfset VolumeLB = replace(VolumeLB,',','','ALL')>

					<cfif ! len(VolumeCS)>
						<cfset VolumeCS = 1>
					</cfif>
					<cfif ! len(VolumeLB)>
						<cfset VolumeLB = 1>
					</cfif>

					<cfif UOM_Selection eq 2>
						<cfset weeklyVolumeLB = (VolumeLB * 7.00) / FORM.prgSpan />
						<cfset weeklyVolumeCS = weeklyVolumeLB / netWeight />
					<cfelse>
						<cfset weeklyVolumeCS = (VolumeCS * 7.00) / FORM.prgSpan />
						<cfset weeklyVolumeLB = weeklyVolumeCS * netWeight />
					</cfif>

					<cfquery name="qSaveVolume" datasource="#application.datasource#">
						DELETE FROM Program_Product_Volume
						WHERE BSA_Foodservice_Items_Master_ID = '#product_id#'
						AND Program_ID = '#FORM.Program_ID#'

						INSERT INTO Program_Product_Volume
							(
								BSA_Foodservice_Items_Master_ID,
								Program_ID,
								Volume_CS,
								Volume_LB,
								Is_Group
							)
						VALUES
							(
								'#product_id#',
								'#FORM.Program_ID#',
								#weeklyVolumeCS#,
								#weeklyVolumeLB#,
								'0'
							)
					</cfquery>
				</cfif>

				<CFQUERY NAME="addFixedcontractproducts" datasource="#application.datasource#">
					SET NOCOUNT ON
					<!--- D30357:Today's Price Wrong on Revision History START--->
					INSERT INTO Contract_Products
								(BSA_Foodservice_Items_Master_ID,
								Contract_Main_ID,
								Product_Type_ID
								<cfif form.EZTemplate EQ 1>,EZButton_On_Default</cfif>,
								Base_Sales_CS)
						VALUES
								('#product_id#',
								'#FORM.Program_ID#',
								1
								<cfif form.EZTemplate EQ 1>,#evaluate("Prod_Default_#replace(product_id, "-", "_", "ALL")#")#</cfif>,
								<cfif isDefined("Base_Sales_CS_#replace(product_id, "-", "_", "ALL")#")>'#evaluate("Base_Sales_CS_#replace(product_id, "-", "_", "ALL")#")#'<cfelse>0</cfif>
								)
					<!--- D30357:Today's Price Wrong on Revision History END--->
					SELECT contract_products_ID = @@IDENTITY
					SET NOCOUNT OFF
				</CFQUERY>
				<CFSET contract_product_id = addFixedcontractproducts.contract_products_ID>
			<CFELSE>
				<cfset contract_product_id = getcontractproducts.contract_products_ID>
			</cfif>
			<!--- <cfoutput>#evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE")#</cfoutput> --->
			<!--- <cfif #evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE")# NEQ 0> --->

			<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Name" default="">
			<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Price" default="">
			<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Time_Frame" default="">
			<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Name_ID" default="">
			<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_MaxVolumeFixedPrice" default="0.0">
			<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Volume" default="0">

			<cfset Competitor_Name_ID = evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Name_ID") />
			<cfset Competitor_Price = evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Price") />
			<cfset Competitor_Time_Frame = evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_Competitor_Time_Frame") />


<!--- Dev Note: drachala; D28500:   START
Changed/Added: When User selects Other, we will insert record into table "Program_Bid_Won_By"  text box value into column "Program_Bid_Won_By_Description"
and  Program ID into column Program_Bid_Won_By_Code which later used to Update Deleted column = 1 --->


<cfif Competitor_Name_ID EQ -1>
	  <cfset other_desc = #evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_CompetitorSourceOther")#>

	<!--- see if "other" record exists --->
	<cfquery name="getOtherWonBy" datasource="#application.datasource#">
		SELECT Program_Bid_Won_By_Description, Program_Bid_Won_By_ID
		FROM	Program_Bid_Won_By
		WHERE Program_Bid_Won_By_Description = '#other_desc#'
	</cfquery>
	<!--- Dont insert if it already exists --->
	<cfif getOtherWonBy.RecordCount>
		<cfset Competitor_Name_ID = getOtherWonBy.Program_Bid_Won_By_ID>
	<cfelse>
		<cfquery name="Other_Won_By" datasource="#application.datasource#">
			SET NOCOUNT ON
			INSERT INTO Program_Bid_Won_By(
				Program_Bid_Won_By_Code,
				Program_Bid_Won_By_Description,
				Active,
				Deleted,
				Updated_By)
			VALUES(
				#FORM.Program_ID#,
				'#other_desc#',
				0,
				0,
				'#request.AccessStructure.User_ID#')
			SELECT Program_Bid_Won_By_ID = @@IDENTITY
			SET NOCOUNT OFF
		</cfquery>
		<cfset Competitor_Name_ID = Other_Won_By.Program_Bid_Won_By_ID>
	</cfif>

</cfif>
<!--- End Dev Note: drachala; D28500: Add functionality to require user to enter value for 'other' on Comp Name  --->
	<!--- param value to handle for adding products for the first time --->
	<cfparam name="FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE" default="">
	<cfset Rate = evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE") />

	<cfset User_Picked_Fixed_Price = Rate />

	<!------63887 :: Need new UOM for Per Hundred Weight (CWT) START --->
	<cfif UOM_Selection EQ 6 OR formulaPricing EQ 1>
		<cfset UOM_Selection = 2>
		<cfset User_Selected_Uom = 6>
		<cfset Rate = Rate / 100 />
	<cfelseif UOM_Selection EQ 5 OR UOM_Selection EQ 7> <!--- 76541 Eaches --->
		<cfset net_weight = evaluate("net_weight_#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#") />
		<cfset case_count = evaluate("case_count_#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#") />
		<cfset Sleeve_count = evaluate("Sleeve_count_#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#") />
		<cfset Inventory_UM = evaluate("Inventory_UM_#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#") />

		<cfif UOM_Selection EQ 5>
			<cfset Rate = Rate * case_count /> <!--- EA to CS --->
			<cfset User_Selected_Uom = 5 />
			<cfset UOM_Selection = 1 />
		<cfelse>
			<cfset Rate = Rate * Sleeve_count /> <!--- SL to CS --->
			<cfset User_Selected_Uom = 7 />
		</cfif>
		<cfif Inventory_UM eq "LB">
			<cfset UOM_Selection = 2 />
			<cfset Rate = Rate / net_weight /> <!--- CS to LB --->
		</cfif>
	<cfelse>
		<cfset User_Selected_Uom = 0>
	</cfif>
	<!------63887 :: Need new UOM for Per Hundred Weight (CWT) END --->

		<!--- 76380 decimal places START--->
			<cfif len(UOM_Selection) EQ 0>
				<cfset UOM_Selection = 0>
			</cfif>
			<cfset decimalprecision = GenProgramManager.decimalPrecisionByUOM(UOM_Selection,1)>
		<!--- 76380 decimal places END--->

			<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
					INSERT INTO Program_Fixed_Price_Product_Data
						(Program_ID,
						Contract_Products_ID,
						Fixed_Price_Value,
						Unit_Of_Measure_ID,
						Program_Fixed_Component_ID,
						Volume,
						Competitor_Name_ID,
						Competitor_Price,
						Competitor_Time_Frame,
						Program_Fixed_Component_Name_Rule_ID
						,Max_Volume_Fixed_Price <!--- 62455  --->
						,User_Picked_UOM<!--- 63887 --->
						,User_Picked_Fixed_Price <!--- 76541 --->
						)
					VALUES
						('#FORM.Program_ID#',
						'#contract_product_id#',
						<cfif formulaPricing EQ 0><!--- It NOT is calculated in the Formula --->
							<CFIF evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE") EQ "">'0'
							<CFELSE>
								 <cfif evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_UOM") eq "1">
								  	'#NumberFormat(evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE"),decimalprecision)#'
								 <cfelse>
								 	'#Rate#'<!--- 63887 --->
								</cfif>
							</CFIF>
						<CFELSE>
							#thisFormulaPrice#
						</CFIF>,
						<cfif evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_UOM") eq "">
							1
						<cfelse>
							#UOM_Selection#
						</cfif>,<!--- 63887 --->
						#Program_Fixed_Component_ID#,
						'#evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_VOLUME")#',
						'#Competitor_Name_ID#',
						<cfif not IsNumeric(Competitor_Price)>
						NULL,
						<cfelse>
						#Competitor_Price#,
						</cfif>
						'#Competitor_Time_Frame#',
						<cfif isReq>
							'#fixrule#')
						<cfelse>
							<!--- param value to handle for adding products for the first time --->
							<cfparam name="fix_rule_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#" default="">
							'#evaluate("fix_rule_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#")#'
						</cfif>
						<cfif IsNumeric(evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_MaxVolumeFixedPrice"))>
						,'#evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_MaxVolumeFixedPrice")#' <!--- 62455  --->
						<cfelse>
						,'0.0'
						</cfif>
						, #User_Selected_Uom#<!--- 63887 --->
						, <cfif User_Picked_Fixed_Price eq "">'0'<cfelse>#User_Picked_Fixed_Price#</cfif><!--- 76541 --->
						)
			</CFQUERY>

		<!--- </cfif> --->

	<cfif form.fixedfreight_on EQ 1>
	<CFIF evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE") EQ "">
	<cfset "form.FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE" = 0>
	</cfif>
		<CFQUERY NAME="deletefixedfreightdata" datasource="#application.datasource#">
		UPDATE Program_Fixed_Freight_Rates
		set delivered_price = #evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE")#,
		FOB_Price = #evaluate("FIXED_C#fixed_comp_id#_P#replace(ListGetAt(form.PRODUCT_LIST,j), "-", "_", "ALL")#_#i#_RATE")# - Freight_Rate
		where Program_ID = #FORM.contract_main_id#
		and product_id = '#product_id#'
		and Component_Name_Id = #fixed_comp_id#
		</CFQUERY>
					</cfif>
				</cfloop><!--- ITEMS LOOP --->
			</cfif>
	</cfif>
</cfloop><!--- COMPONENT LOOP --->

		<!---  Dev Note - (79237) - If any of the fixed price component has a 2nd (child) component, then set the 2nd components rate, UOM and "pais to" same as that component.--->
		<cfset GenProgramManager.updateSecondComponentRates(form.Program_ID,1)>


		<!--- D30253 : Rebate Grid dropping strategy code from 2200 START--->
		<!---- if freight is on, find out if current program has any freight components selected and save a flag ---->
		<cfset IsFreightTemplate = GenProgramManager.GetIsProgramFreightOn(FORM.Program_ID)>
		<cfif IsFreightTemplate eq 1>
			<cfset ProgramFreight = CreateObject("component", "components.freight.ProgramFreight") />
    <cfscript>
		ProgramFreight.Freight(
								Program_ID								= 	#form.Program_ID#,
								program_fixed_component_name_id_list 	= 	#program_fixed_component_name_id_list#
		);
	</cfscript>
</cfif>
<!--- D30253 : Rebate Grid dropping strategy code from 2200 END--->
<cfif form.EZTemplate EQ 0>
<cfif qProgram.recordCount>

	 	<!------ update volume ----->
		<cfquery name="qUpdateVolume" datasource="#application.datasource#">
			UPDATE	Program_Fixed_Price_Product_Data
			SET 	Program_Fixed_Price_Product_Data.Volume =
					(
						SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
						FROM	Program_Product_Volume
						WHERE
								Program_Product_Volume.Deleted = 0
								AND
								Program_Product_Volume.Program_ID = Program_Fixed_Price_Product_Data.Program_ID
								AND
								Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					)
			FROM	Program_Fixed_Price_Product_Data
					INNER JOIN	Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
			WHERE
					Program_Fixed_Price_Product_Data.Deleted = 0
					AND
					Program_Fixed_Price_Product_Data.Volume IS NULL
					AND
					Program_Fixed_Price_Product_Data.Program_ID = #Form.Program_ID#
		</cfquery>

	</cfif>
</cfif>


	<!--- update freight rates incase delivered prices are changed after saving the freight rates. --->

	<cfif form.fixedfreight_on EQ 1>

		<CFQUERY NAME="deletefixedfreightdata" datasource="#application.datasource#">
		UPDATE Program_Fixed_Freight_Rates
		set deleted = 1
		where Program_ID = #FORM.contract_main_id#
		<cfif form.Product_List NEQ "">
		and product_id not in (#ListQualify(form.Product_List, "'", ",")#)
		</cfif>
		</CFQUERY>
	</cfif>

	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

	<!---call SP to update program contract quantity --->
	<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

<CFTRANSACTION ACTION="COMMIT">

</CFTRANSACTION>


<cfif form.bFromMargin>
	<script>
		window.close();
		window.opener.location.reload();
	</script>
	<cfabort />
</cfif>
<cfset useLakebaseForgetProgramType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetProgramType>
	<cftry>
		<cfset getProgramType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#FORM.Program_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramType>
<CFQUERY NAME="getProgramType" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main
	WHERE Contract_Main_ID = #FORM.Program_ID#
</CFQUERY>
</cfif>
<!--- 	used for business_rule_popup...url could not handle size of list...reset session varto keep things tidy--->
<cfset session.fix_Product_List = "">
<!------ Start Clause Code ----->
<cfset discountTypeId = 1>
<cfset programId = FORM.Program_ID>
<cfset templateId = getProgramType.ProgramType_ID>
<cfset addClauseMode = FORM.Product_List NEQ "">
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->
<cfif form.EZTemplate EQ 0>
<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
<CFSET redirector_FromPage_ID = 5>
<cfinclude template="internal_redirector_based_on_settings.cfm">

<!--- Dev Note (71410). The user should not be redirected to the next page (Rebate or program summary page etc), when a component is added.
The user should only be redirected after clickimg on the "save" link.
--->
<cfif form.DoNotRedirectToNextPage eq 1>
	<CFSET redirector_NextLocation="Contract_Discount_Fixed_Component.cfm">
</cfif>

<cfif RedirectPath EQ "">
	<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#encryp_program_id#">
	<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
	<CFLOCATION url= "#redirectURL#" />
<cfelse>
	<CFLOCATION URL="contract_discount_fixed_component_margin.cfm?CID=#encryp_program_id#">
</cfif>
<cfelse>
<script>window.close();</script>
</cfif>
<!--- <cfset locateBackTo = "/Common_Files/contracts/Contract_Discount_Rebates.cfm.cfm?CID=#encryp_program_id#" />

<cflocation URL="#locateBackTo#"> --->
