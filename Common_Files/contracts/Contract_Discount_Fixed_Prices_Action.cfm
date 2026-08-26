<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<CFSET Cryp_Program_ID = FORM.Program_ID>
<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>
<cfparam name="form.RedirectPath" default="" />

<!--- lock checker --->
<CFSET LockChecker_CID  = cryp.value>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
<!--- lock checker --->

<CFQUERY NAME="saveRebateType" datasource="#application.datasource#">
	UPDATE Contract_Main
	SET Fixed_Price_Rebate_Type = '#FORM.Fixed_Price_Rebate_Type#'
	WHERE Contract_Main_ID = '#cryp.value#'
</CFQUERY>



<CFQUERY NAME="getProductsToDelete" datasource="#application.datasource#">
SELECT     	Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, 
			Program_Fixed_Price_Product_Data.Program_ID, Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID
FROM		Contract_Products 
			INNER JOIN	Program_Fixed_Price_Product_Data 
			ON 
			Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
WHERE     
			(Contract_Products.Deleted = 0) 
			AND (Program_Fixed_Price_Product_Data.Deleted = 0) 
			AND (Program_Fixed_Price_Product_Data.Program_ID = '#FORM.Program_ID#') 
			<CFIF listlen(Product_List) GT 0> 
			AND (Contract_Products.BSA_Foodservice_Items_Master_ID NOT IN(#listqualify(FORM.Product_List, "'")#))
			</CFIF>

</CFQUERY>
<CFSET listofitemstodelete = valuelist(getProductsToDelete.Contract_Products_ID)>
<CFTRANSACTION ACTION="BEGIN">
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

	<CFQUERY NAME="deleteCurrentProgramProductsFromFixedPriceTable" datasource="#application.datasource#">
		UPDATE Program_Fixed_Price_Product_Data
		SET Deleted = 1
		WHERE Contract_Products_ID IN(#listofitemstodelete#)
	</CFQUERY>	
</CFIF>

<CFQUERY NAME="getActiveProducts" datasource="#application.datasource#">
	SELECT     	Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, 
				Program_Fixed_Price_Product_Data.Program_ID, Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID
FROM			Contract_Products 
				INNER JOIN	Program_Fixed_Price_Product_Data 
				ON
				Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID
WHERE     
				(Contract_Products.Deleted = 0) 
				AND (Program_Fixed_Price_Product_Data.Deleted = 0) 
				AND (Program_Fixed_Price_Product_Data.Program_ID = '#FORM.Program_ID#')
</CFQUERY>

<cfset qProgram = CreateObject("component", "components.programs.program").getProgramInfo(Form.Program_ID) />
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset weeklyVolume = ProductGroupManager.getPerProductVolume(Form.Program_ID, qProgram) />

	
<cfset listofactiveproducts = valuelist(getActiveProducts.BSA_Foodservice_Items_Master_ID)>
<cfset Program_Fixed_Price_Product_Data_ID_List = valuelist(getActiveProducts.Program_Fixed_Price_Product_Data_ID)>
<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#">
	<CFSET Form_Product_ID = Replace(Product_ID, "-", "_", "ALL")>
	<CFIF NOT ListFindNoCase(listofactiveproducts,Product_ID,",")>
		<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
			INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID)
			VALUES
			('#Product_ID#', '#FORM.Program_ID#', 1)
		</CFQUERY>
		
		<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Fixed_Price_Product_Data
			(Program_ID, Contract_Products_ID, Fixed_Price_Value, Unit_Of_Measure_ID, Volume)
			VALUES
			('#FORM.Program_ID#', '#saveContractProducts.Contract_Products_ID#', '#evaluate("FORM.FIXED_PRICE_VALUE_#Form_Product_ID#")#', #evaluate("FORM.FIXED_PRICE_UOM_#Form_Product_ID#")#, '#weeklyVolume#')
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="Get_Program_Fixed_Price_Product_Data_ID" DBTYPE="query">
			SELECT	Program_Fixed_Price_Product_Data_ID
			FROM	getActiveProducts
			WHERE
					BSA_Foodservice_Items_Master_ID = '#Product_ID#'
		</CFQUERY>
		<CFIF Get_Program_Fixed_Price_Product_Data_ID.RecordCount GT 0>
			<CFQUERY NAME="updateFixedPriceData" datasource="#application.datasource#">
				UPDATE Program_Fixed_Price_Product_Data
				SET 
					Fixed_Price_Value 	= '#evaluate("FORM.FIXED_PRICE_VALUE_#Form_Product_ID#")#',
					Unit_Of_Measure_ID	= #evaluate("FORM.FIXED_PRICE_UOM_#Form_Product_ID#")#
					<cfif weeklyVolume NEQ "NULL">
					,Volume				= '#weeklyVolume#'
					</cfif>
				WHERE Program_Fixed_Price_Product_Data_ID = '#Get_Program_Fixed_Price_Product_Data_ID.Program_Fixed_Price_Product_Data_ID#'
			</CFQUERY>	
		</CFIF>		
	</CFIF>	
</CFLOOP>


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
	
	<!------ update discount type payment cycle ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
		<cfparam name="FORM.PaymentCycle" 	default="0">
		<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />
		<cfset paymentCycleManager.savePaymentCycle(Form.Program_ID, 1, FORM.PaymentCycle) />
	</cfif>
	
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">
				   
	</cfstoredproc>
			
	<CFTRANSACTION ACTION="COMMIT">
			
</CFTRANSACTION>

<CFQUERY NAME="getProgramType" datasource="#application.datasource#">
	SELECT ProgramType_ID
	FROM Contract_Main 
	WHERE Contract_Main_ID = #FORM.Program_ID#
</CFQUERY>

<!------ Start Clause Code ----->
<cfset discountTypeId = 1>
<cfset programId = FORM.Program_ID>
<cfset templateId = getProgramType.ProgramType_ID>
<cfset addClauseMode = FORM.Product_List NEQ "">
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->				
<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
<CFSET redirector_FromPage_ID = 5>
<cfinclude template="internal_redirector_based_on_settings.cfm">

<cfif form.RedirectPath EQ "">
	<cfset redirectURL = "redirect.cfm?destination=#redirector_NextLocation#&CID=#Cryp_Program_ID#" />
	<cfif qualPopup eq 1> <cfset redirectURL &= "&pop019=qualifications" /> </cfif>
	<CFLOCATION url= "#redirectURL#" />
<cfelse>	
	<CFLOCATION url="Contract_Discount_Fixed_Component_margin.cfm?CID=#encryp_program_id#&marginedit_saved=1">
</cfif>			
