<cfparam name="form.Dynamic_Static_Groups" default="0" />
<cfparam name="form.Is_Group" default="0" />
<cfparam name="Pricing_Level_ID" default="0" />
<cfparam name="form.Level_1" default="" />
<cfparam name="form.Level_2" default="" />
<cfparam name="form.Level_3" default="" />
<cfparam name="form.Like_Product" default="">
<cfparam name="form.Is_Like_Product_Exist" default="0">
<cfparam name="form.RedirectPath" default="" />
<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").init().get() />
<cfset OffInvoiceDAO = CreateObject("component", "components.programs.Off_Invoice.OffInvoiceDAO") />
<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset qGetOIProgramComponents = OffInvoiceDAO.getOIProgramComponents(FORM.Contract_Main_ID) />
<cfset GetSettings = programManager.getProgramTemplateInfo(FORM.Contract_Main_ID) />

<cfset Display_Basis_Treatment_Code = 0 />
<cfif GetSettings.Include_Treatment_Basis_Code>
	<cfset Display_Basis_Treatment_Code = 1 />
</cfif>
<cfset BasisCodeManager = CreateObject("component","components.Operating_Group.BasisCodeManager").init() />

<!--- Clear out products first --->
<cfquery name="ClearOutContractProducts" datasource="#application.datasource#">
	UPDATE 	Contract_Products
	SET 	Deleted = 1
	WHERE 	Contract_Main_ID = <cfqueryparam value="#Form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
	AND		Product_Type_ID = 8
	AND		Deleted = 0
</cfquery>

<!--- Clear out margin calculation --->
<cfquery name="ClearOutContractMargins" datasource="#application.datasource#">
	UPDATE 	Contract_Product_Margin
	SET 	Deleted = 1
	WHERE 	Contract_Main_ID = <cfqueryparam value="#Form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
	AND		Product_Type_ID = 8
	AND		Deleted = 0
</cfquery>

<cfquery name="ClearOutOffInvoice" datasource="#application.datasource#">
	UPDATE 	Program_OffInvoice_Product_Data
	SET 	Deleted = 1
	WHERE 	Program_ID = <cfqueryparam value="#Form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
	AND		Deleted = 0
</cfquery>

<!--- Clear out components --->
<cfquery name="ClearOutContractProducts" datasource="#application.datasource#">
	UPDATE 	Program_OffInvoice_Component
	SET 	Deleted = 1
	WHERE 	Program_ID = <cfqueryparam value="#Form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
	AND		Deleted = 0
</cfquery>

<cfinclude template="off-invoice-functions.cfm" />

<!--- (Dev Note: Milan; D7226)  Delete previous products only if the same product existed in off-invoice discount type --->
<cfif form.Is_Like_Product_Exist eq 1>
		<cfloop list="#Product_List#" index="Prod">
			<cfset Existing_LikeProduct = ProdManager.getSimilarExistingProduct('#FORM.Contract_Main_ID#', '#Prod#')>
				<cfif Existing_LikeProduct.Recordcount neq 0>
					<cfset ProdManager.setDeleteSimilarExistingProduct('#FORM.Contract_Main_ID#','#Prod#')>
				</cfif>
		</cfloop>	

<!--- Add Products (These products are generic and not related to any discount type) --->
		<cfloop list="#form.Like_Product#" index="LikeProd">
					<cfset ProdManager.setSimilarExistingProduct('#FORM.Contract_Main_ID#','#LikeProd#')>
		</cfloop>
</cfif>
<!--- End Note: Milan; D7226 --->

<!---Create new records--->
<cfif isDefined("Form.ProductList")>
	<!------ get volume uom ----->
	<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(Form.Contract_Main_ID) />
	<cfset contractSpan = DateDiff("d", qProgram.Contract_Start_Date, qProgram.Contract_End_Date) + 1 />
	<cfset TotalWeeklyQty = (qProgram.Contract_Quantity * 7) / contractSpan />
		
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset allProductSelected = false>
	
	<cfset form.ProductList = trim(Replace(form.ProductList, "'", "", "ALL"))>
	<cfset form.ProductList = trim(Replace(form.ProductList, "_", "-", "ALL"))>

	<!---if we have values in level 1 then we know we have groups so lets adjust the product list by pricing level--->
	<cfif trim(form.Level_1) neq "">
		<!---flush product list--->
		<cfset form.ProductList = "" />
		<cfloop index="loopIndx" from="3" to="1" step="-1">
			<cfloop index="inIndx" list="#Evaluate("form.Level_#loopIndx#")#">
				<cfset form.ProductList = ListAppend(form.ProductList, inIndx) />
			</cfloop>
		</cfloop>
	</cfif>
	
	<cfif Form.ProductList EQ "">
		<cfset Form.off_invoice_component_info_list = "" />
	</cfif>

	<cfset off_invoice_component_info_array = getArrayOffInvoiceComponentInfo(form.off_invoice_component_info_list, qGetOIProgramComponents) />
	
	<cfset form.off_invoice_component_list = "" />	
	<!------ save components ----->
	<cfset off_invoice_component_info_len = ArrayLen(off_invoice_component_info_array) />
	<cfloop from="1" to="#off_invoice_component_info_len#" index="index">
		<cfset St_Current_Component			= off_invoice_component_info_array[index] />
		<cfset Current_Component_Name_ID 	= St_Current_Component.ComponentNameId />
		<cfset treatmentCodeId 				= St_Current_Component.treatmentCodeId />
		<cfset basisCodeId 					= St_Current_Component.basisCodeId />
		<cfset EffectiveMarginFlag 			= St_Current_Component.EffectiveMarginFlag />
		<cfset form.off_invoice_component_list = ListAppend(form.off_invoice_component_list, Current_Component_Name_ID) />
	
		<cfquery name="qInsertComponent" datasource="#application.datasource#">
			INSERT INTO Program_OffInvoice_Component (Program_ID, Program_OffInvoice_Component_Name_ID, Treatment_Code_Master_ID, Basis_Code_Master_ID, Effective_Margin_Flag)
			VALUES (	<cfqueryparam value="#Form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#Current_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#treatmentCodeId#" cfsqltype="CF_SQL_INTEGER" null="#Not IsNumeric(treatmentCodeId) or not compareNoCase(treatmentCodeId, "0")#">,
					<cfqueryparam value="#basisCodeId#" cfsqltype="CF_SQL_INTEGER" null="#Not IsNumeric(basisCodeId) or not compareNoCase(basisCodeId, "0")#">,
					<cfqueryparam value="#EffectiveMarginFlag#" cfsqltype="CF_SQL_INTEGER">
					)
		</cfquery>
	</cfloop>
	
	<!------ save products ----->
	<cfloop list="#Form.ProductList#" index="Product_ID">

		<cfset weeklyQty = "">
		
		<!---if level 1 is empty then we know groups weren't added--->
		<cfif trim(form.Level_1) eq "">
		
			<!------ Find product group ----->
			<cfset qProductGroup = ProductGroupManager.getGroupFromProduct(Product_ID, 1) />
			<CFSET productGroupLevel = qProductGroup.Product_Group_Level_ID>
			<CFSET productGroupId = qProductGroup.Product_Group_ID>
				
		<cfelse>
		
			<!---if it's a group in level 1 then set values for it--->
			<cfif trim(form.Level_1) neq "" and ListFindNoCase(form.Level_1, Product_ID)>
			
				<cfset form.Is_Group = 1 />
				<CFSET productGroupLevel = form.GroupLevel_1 />
				<CFSET productGroupId = Product_ID />
				<CFSET Pricing_Level_ID = 1 />
	
			<cfelseif trim(form.Level_2) neq "" and ListFindNoCase(form.Level_2, Product_ID)>
				
				<cfset productGroupLevel = form.GroupLevel_2 />
				<CFSET Pricing_Level_ID = 2 />
				
				<!---if it's a product then set values for product--->
				<cfif form.GroupLevel_2 eq 9>
					<cfset qProductGroup = ProductGroupManager.getGroupFromProduct(Product_ID, 1) />
					<CFSET productGroupId = qProductGroup.Product_Group_ID />
					<cfset form.Is_Group = 0 />
				<cfelse>
					<cfset form.Is_Group = 1 />
					<CFSET productGroupId = Product_ID />
				</cfif>
			
			<cfelseif trim(form.Level_3) neq "" and ListFindNoCase(form.Level_3, Product_ID)>
				
				<cfset productGroupLevel = form.GroupLevel_3 />
				<CFSET Pricing_Level_ID = 3 />
				
				<!---if it's a product then set values for product--->
				<cfif form.GroupLevel_3 eq 9>
					<cfset qProductGroup = ProductGroupManager.getGroupFromProduct(Product_ID, 1) />
					<CFSET productGroupId = qProductGroup.Product_Group_ID />
					<cfset form.Is_Group = 0 />
				<cfelse>
					<cfset form.Is_Group = 1 />
					<CFSET productGroupId = Product_ID />
				</cfif>
				
			</cfif>
			
		</cfif>
		
		<cfif productGroupLevel EQ 1>
			<cfset weeklyQty = TotalWeeklyQty>
			<cfset allProductSelected = true>
		</cfif>

		<cfif productGroupLevel eq "">
			<cfset productGroupLevel = 0>
		</cfif>
			
		<cfquery name="CreateContractProducts" datasource="#application.datasource#">
			SET NOCOUNT ON
			INSERT INTO Contract_Products
			(
				BSA_Foodservice_Items_Master_ID,
				Contract_Main_ID, 
				Product_Type_ID,
				Product_Group_Level_ID, 
				Product_Group_ID,
				Pricing_Level_ID,
				Is_Group,
				Dynamic_Static_Groups
			)
			VALUES
			(
				'#Product_ID#', 
				#Form.Contract_Main_ID#,
				8,
				#productGroupLevel#,
				'#productGroupId#',
				#Pricing_Level_ID#,
				#form.Is_Group#,
				#form.Dynamic_Static_Groups#
				
			)
			SELECT Contract_Products_ID = @@Identity
			SET NOCOUNT OFF
		</cfquery> 
		
		<cfset Product_ID_RE = replace(Product_ID,"-","_", "ALL") />
		<!------ save component-product values ----->
		<cfset off_invoice_component_info_len = ArrayLen(off_invoice_component_info_array) />
		<cfloop from="1" to="#off_invoice_component_info_len#" index="index">
			<cfset St_Current_Component			= off_invoice_component_info_array[index] />
			<cfset Current_Component_Name_ID 	= St_Current_Component.ComponentNameId />
			<cfset basisCodeId 					= St_Current_Component.basisCodeId />
		
			<cfset ComponentFieldNameEnd = "C_#Current_Component_Name_ID#_P_#Product_ID_RE#" />
			
			<cfset basisCodeType = 0 />
			<cfif Display_Basis_Treatment_Code EQ 1>
			<cfif BasisCodeManager.getBasicCodeType(basisCodeId) EQ "Y">
				<cfset basisCodeType = 1 />
			</cfif>
			</cfif>
			<!------ Get Saved component id ----->
			<cfquery name="qGetComponentId" datasource="#application.datasource#">
				SELECT	Program_OffInvoice_Component_ID
				FROM	Program_OffInvoice_Component
				WHERE	Deleted = 0
				AND		Program_ID = <cfqueryparam value="#Form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
				AND		Program_OffInvoice_Component_Name_ID = <cfqueryparam value="#Current_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfset Program_OffInvoice_Component_ID = qGetComponentId.Program_OffInvoice_Component_ID />			
			<cfset Discount_Amount = evaluate("OffInvoice_Value_#ComponentFieldNameEnd#")>
			<cfset UOM = evaluate("OffInvoice_UOM_#ComponentFieldNameEnd#")>
			<cfif NOT isNumeric(Discount_Amount) OR basisCodeType EQ 1><cfset Discount_Amount = 0 /></cfif>
			<cfif NOT isNumeric(UOM)><cfset UOM = 0 /></cfif>
			<cfset Plus_Minus = evaluate("Plus_Minus_#ComponentFieldNameEnd#")>
			
			<cfparam name="comp_basis_code_quantity_#ComponentFieldNameEnd#" 	default="">
			<cfparam name="comp_basis_code_quantity_uom_#ComponentFieldNameEnd#" 	default="">
			<cfparam name="comp_basis_code_free_goods_#ComponentFieldNameEnd#" 	default="">
			<cfparam name="comp_effective_margin_percent_#ComponentFieldNameEnd#" 	default="">
			
			<cfset comp_basis_code_quantity = evaluate("comp_basis_code_quantity_#ComponentFieldNameEnd#")>
			<cfset comp_basis_code_quantity_uom = evaluate("comp_basis_code_quantity_uom_#ComponentFieldNameEnd#")>
			<cfset comp_basis_code_free_goods = evaluate("comp_basis_code_free_goods_#ComponentFieldNameEnd#")>
			<cfset comp_effective_margin_percent = evaluate("comp_effective_margin_percent_#ComponentFieldNameEnd#")>
			<cfif NOT IsNumeric(comp_effective_margin_percent) OR St_Current_Component.EffectiveMarginFlag EQ 0>
				<cfset comp_effective_margin_percent = 100 />
			</cfif>
			
			<cfquery name="CreateOffInvoice" datasource="#application.datasource#">
				INSERT INTO Program_OffInvoice_Product_Data
				(
					Program_ID,
					Contract_Products_ID,
					Discount_Amount,
					UOM,
					Volume,
					Plus_Minus,
					Deleted,
					Is_Group,
					Program_OffInvoice_Component_ID,
					Basis_Code_Quantity,
					Basis_Code_Quantity_UOM,
					Basis_Code_Free_Goods,
					Basis_Code_Free_Goods_UOM,
					Effective_Margin_Percent
				)
				VALUES
				(
					#Form.Contract_Main_ID#,
					#CreateContractProducts.Contract_Products_ID#,
					#Discount_Amount#,
					#UOM#,
					'#weeklyQty#',
					#Plus_Minus#,
					0,
					#form.Is_Group#,
					#Program_OffInvoice_Component_ID#,
					<cfqueryparam value="#comp_basis_code_quantity#" cfsqltype="CF_SQL_FLOAT" null="#NOT IsNumeric(comp_basis_code_quantity)#">,
					<cfqueryparam value="#comp_basis_code_quantity_uom#" cfsqltype="CF_SQL_INTEGER" null="#NOT IsNumeric(comp_basis_code_quantity_uom)#">,
					<cfqueryparam value="#comp_basis_code_free_goods#" cfsqltype="CF_SQL_FLOAT" null="#NOT IsNumeric(comp_basis_code_free_goods)#">,
					<cfqueryparam value="#comp_basis_code_quantity_uom#" cfsqltype="CF_SQL_INTEGER" null="#NOT IsNumeric(comp_basis_code_quantity_uom)#">,
					<cfqueryparam value="#comp_effective_margin_percent#" cfsqltype="CF_SQL_FLOAT">
				)
			</cfquery>
		</cfloop>

	</cfloop> 
	
	<!---if it's a group then flag to process when applying volume--->
	<cfif trim(form.Level_1) neq "">
	
		<cfset useLakebaseForqFlagGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqFlagGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#Form.Contract_Main_ID#"
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
			AND 	Contract_Main_ID = #Form.Contract_Main_ID#
		</cfquery>
</cfif>
				
	</cfif>
	
	<cfif allProductSelected>
		<cfset ProductGroupManager.updateOtherAvgProductVolume(Form.Contract_Main_ID) />
	</cfif>
			
	<cfif qProgram.recordCount>
	
	 	<!------ update volume ----->
		<cfquery name="qUpdateVolume" datasource="#application.datasource#">
			UPDATE	Program_OffInvoice_Product_Data
			SET 	Program_OffInvoice_Product_Data.Volume = 
					(
						SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
						FROM	Program_Product_Volume
						WHERE
								Program_Product_Volume.Deleted = 0
								AND
								Program_Product_Volume.Program_ID = Program_OffInvoice_Product_Data.Program_ID
								AND
								Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					)
			FROM	Program_OffInvoice_Product_Data
					INNER JOIN	Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_OffInvoice_Product_Data.Contract_Products_ID
			WHERE
					Program_OffInvoice_Product_Data.Deleted = 0
					AND
					Program_OffInvoice_Product_Data.Volume IS NULL
					AND
					Program_OffInvoice_Product_Data.Program_ID = #Form.Contract_Main_ID#
		</cfquery>
		
	</cfif>

</cfif>

<!---call SP to update program product volume --->
<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
	
	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Contract_Main_ID#" null="no">
	   
</cfstoredproc>
			
 <!------ Start Clause Code ----->
<cfset discountTypeId = 8>
<cfset programId = Form.Contract_Main_ID>
<cfset addClauseMode = FORM.ProductList NEQ "">
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

 <CF_cryp type="en" key="#request.key#" string="#Form.Contract_Main_ID#" return="enc">

<!--- Dev Note: 8605 CPM 
If page is called by off-invoice_margin.cfm, the redirectPath variable 
will determine where the user should be directed back to off-invoice_margin. --->
<CFOUTPUT>
<cfif form.RedirectPath EQ "">
	<cflocation url="contract_edit_menu.cfm?CID=#enc.value#" />
<cfelse>
	<cflocation url="off-invoice_margin.cfm?CID=#enc.value#&marginedit_saved=1" />
</cfif>
</CFOUTPUT>