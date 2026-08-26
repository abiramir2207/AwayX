<!------Contract_Formula_Add_Products_Action.cfm----->
<CFPARAM NAME="FORM.CID" 	DEFAULT="">
<CF_Cryp type="de" key="#request.key#" string="#FORM.CID#">
<CFIF FORM.CID NEQ ""> 
	<CFSET Program_ID = cryp.value>
<CFELSE>
	<CFOUTPUT>
	Invalid Program ID
	</CFOUTPUT>
	<CFABORT>
</CFIF>

<CFPARAM NAME="FORM.Abs_Final_Product_List" 	DEFAULT="">
<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="Program_Rule_ID">
<CFSET FORM.Program_Formula_Pricing_Rule_ID = FORM.Rule_ID>


<CFIF IsDefined("FORM.New_Formula_Pricing_Rule_ID")>
	<CFIF FORM.New_Formula_Pricing_Rule_ID NEQ "">
		<CFINCLUDE TEMPLATE="Contract_Formula_Add_Rule_Action.cfm">
	</CFIF>
</CFIF>


<CFIF FORM.Program_Formula_Pricing_Rule_ID EQ "">
	<CFOUTPUT>
	Invalid Rule ID
	</CFOUTPUT>
	<CFABORT>
</CFIF>


<CFQUERY NAME="Get_Active_Products" datasource="#application.datasource#">
	SELECT	cp.BSA_Foodservice_Items_Master_ID
	FROM	Program_Formula_Pricing_Rule_Products fp,  Contract_Products cp
	WHERE	
			fp.Program_Formula_Pricing_Rule_ID 		= '#FORM.Program_Formula_Pricing_Rule_ID#'	
	AND		fp.Program_ID							= #Program_ID#
	AND		cp.Contract_Products_ID 				= fp.Contract_Product_ID
	AND		fp.Active								= 1
	AND		fp.Deleted 								= 0	
	AND		cp.Deleted								= 0
</CFQUERY>
<CFSET activeProductList=ValueList(Get_Active_Products.BSA_Foodservice_Items_Master_ID,",")>

<CFTRANSACTION ACTION="BEGIN">
<CFQUERY NAME="Update_Formula_Price_Rebate_Type" datasource="#application.datasource#">
	UPDATE		Contract_Main
	SET			Formula_Price_Rebate_Type 	= 	#Form.Formula_Price_Rebate_Type#
	WHERE		Contract_Main_ID			=	#Program_ID#	
</CFQUERY>

<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(Program_ID) />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset weeklyVolume = ProductGroupManager.getPerProductVolume(Program_ID, qProgram) />

<CFLOOP INDEX="Product_ID" LIST="#FORM.ABS_FINAL_PRODUCT_LIST#">
<CFIF NOT ListFindNoCase(activeProductList,Product_ID,",")>
	<CFQUERY NAME="saveNewProduct" datasource="#application.datasource#">
		INSERT INTO Contract_Products
		(
			BSA_Foodservice_Items_Master_ID,
			Contract_Main_ID,
			Product_Type_ID
		)
		VALUES
		(
			'#Product_ID#',
			#Program_ID#,
			5
		)				
	</CFQUERY>
	<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(Product_ID,"-","_", "ALL")>
	<CFQUERY NAME="saveFormulaProduct" datasource="#application.datasource#">
		INSERT INTO Program_Formula_Pricing_Rule_Products
		(
			Program_ID,
			Program_Formula_Pricing_Rule_ID,
			Contract_Product_ID,
			Weekly_Volume,
			Product_Overage,
			Unit_Of_Measure_ID,
			Active
		)
		VALUES
		(
			#Program_ID#,
			'#FORM.Program_Formula_Pricing_Rule_ID#',
			'#saveNewProduct.contract_products_id#',
			'#weeklyVolume#',
			'#Evaluate("Form.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#")#',
			#Evaluate("Form.Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#")#,
			1
		)		
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="get_CP_ID" datasource="#application.datasource#">
		SELECT	
				cp.contract_products_id
		FROM
				Contract_Products cp,
				Program_Formula_Pricing_Rule_Products fp
		WHERE
				cp.Contract_Main_ID			=	'#Program_ID#'
				AND
				fp.Program_ID							=	'#Program_ID#'
				AND
				fp.Program_Formula_Pricing_Rule_ID		=	'#FORM.Program_Formula_Pricing_Rule_ID#'
				AND
				cp.contract_products_id					=	fp.contract_product_id
				AND
				cp.BSA_Foodservice_Items_Master_ID	=	'#Product_ID#'
				AND
				fp.Active								=	1
				AND
				fp.Deleted								=	0
				AND
				cp.Deleted								=	0
	</CFQUERY>
	<CFIF get_CP_ID.recordCount GT 0>
		<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(Product_ID,"-","_", "ALL")>
		<CFQUERY NAME="updateFormulaProduct" datasource="#application.datasource#">
			UPDATE		Program_Formula_Pricing_Rule_Products
			SET			
			Weekly_Volume = '#weeklyVolume#',
			Product_Overage = '#Evaluate("Form.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#")#',
			Unit_Of_Measure_ID = #Evaluate("Form.Overage_UOM_#ThisProductIDFormattedForHTMLFormElementName#")#
			WHERE		
							Program_ID							=	'#Program_ID#'
					AND		Program_Formula_Pricing_Rule_ID		=	'#FORM.Program_Formula_Pricing_Rule_ID#'
					AND		Active								=	1
					AND		Deleted								=	0
					AND		Contract_Product_ID					=	#get_CP_ID.contract_products_id#
		</CFQUERY>
	</CFIF>
</CFIF>

</CFLOOP>


	<CFQUERY datasource="#application.datasource#" NAME="Delete_Not_Selected">
	UPDATE			Contract_Products
	SET				Deleted = 1
	WHERE	
			Contract_Products.Contract_Main_ID						= #Program_ID#
			AND
			EXISTS
			(
				SELECT	Program_Formula_Pricing_Rule_Products.Contract_Product_ID
				FROM	Program_Formula_Pricing_Rule_Products
				WHERE
							Program_Formula_Pricing_Rule_ID 		= '#FORM.Program_Formula_Pricing_Rule_ID#'
				AND		Program_ID							='#Program_ID#'
				AND		Active								= 1
				AND		Deleted 								= 0
				AND		Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
				<CFIF Len(FORM.ABS_FINAL_PRODUCT_LIST) GT 0>
				AND		
					NOT EXISTS(
					SELECT	BSA_Foodservice_Items_Master_ID cp
					FROM	Contract_Products cp
					WHERE	
							cp.Contract_Products_ID 				= Contract_Product_ID
					AND		BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.ABS_FINAL_PRODUCT_LIST, "'", ",")#)
							
				)
				</CFIF>
			)
	</CFQUERY>
	
	<CFQUERY datasource="#application.datasource#" NAME="Delete_Not_Selected">
	UPDATE	Program_Formula_Pricing_Rule_Products
	SET		Active = 0,
			Deleted	=	1
	WHERE
			Program_Formula_Pricing_Rule_ID 		= '#FORM.Program_Formula_Pricing_Rule_ID#'
	AND		Program_ID							='#Program_ID#'
	AND		Active								= 1
	AND		Deleted 								= 0
	<CFIF Len(FORM.ABS_FINAL_PRODUCT_LIST) GT 0>
	AND		
		NOT EXISTS(
		SELECT	BSA_Foodservice_Items_Master_ID cp
		FROM	Contract_Products cp
		WHERE	
				cp.Contract_Products_ID 				= Contract_Product_ID
		AND		BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.ABS_FINAL_PRODUCT_LIST, "'", ",")#)
				
	)
	</CFIF>
	</CFQUERY>
		
	<cfif qProgram.recordCount>
	
	 	<!------ update volume ----->
		<cfquery name="qUpdateVolume" datasource="#application.datasource#">
			UPDATE	Program_Formula_Pricing_Rule_Products
			SET 	Program_Formula_Pricing_Rule_Products.Weekly_Volume = 
					(
						SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
						FROM	Program_Product_Volume
						WHERE
								Program_Product_Volume.Deleted = 0
								AND
								Program_Product_Volume.Program_ID = Program_Formula_Pricing_Rule_Products.Program_ID
								AND
								Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					)
			FROM	Program_Formula_Pricing_Rule_Products
					INNER JOIN	Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_Formula_Pricing_Rule_Products.Contract_Product_ID
			WHERE
					Program_Formula_Pricing_Rule_Products.Deleted = 0
					AND
					Program_Formula_Pricing_Rule_Products.Weekly_Volume IS NULL
					AND
					Program_Formula_Pricing_Rule_Products.Program_ID = #Program_ID#
		</cfquery>
		
	</cfif>
	
	<!------ update discount type payment cycle ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<cfparam name="FORM.PaymentCycle" 	default="0">
		<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
		<cfset paymentCycleManager.savePaymentCycle(Program_ID, 5, FORM.PaymentCycle) />
	</cfif>
	
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Program_ID#" null="no">
				   
	</cfstoredproc>

	<CFTRANSACTION ACTION="COMMIT">
</CFTRANSACTION>

<CFSET generateReleaseProgramID = Program_ID>
<CFSET generateRelease_GeneratePrices = 1>
<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">



<!------ Start Clause Code ----->
<cfset discountTypeId = 5>
<cfset programId = Program_ID>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.CID#">