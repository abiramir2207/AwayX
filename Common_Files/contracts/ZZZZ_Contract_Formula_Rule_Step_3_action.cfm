<!------<cfdump VAR="#FORM#">----->

<cfparam name="Form.Program_Formula_Pricing_Rule_ID" 	default="">
<cfparam name="URL.RID" 	default="#Form.Program_Formula_Pricing_Rule_ID#">

<CF_CRYP type="de" key="#request.key#" string="#URL.RID#">
<CFSET FORM.Program_Formula_Pricing_Rule_ID = cryp.value>


<cfparam name="Form.CID" 	default="">
<cfparam name="URL.CID" 	default="#Form.CID#">
<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

<cfparam name="Form.Update" 	default=0>


<!------ Make Active  ----->
<CFSET Rule_ID=FORM.Program_Formula_Pricing_Rule_ID>
<cfset useLakebaseForactivateRule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rules")>
<cfif useLakebaseForactivateRule>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rules",
			{
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"deleted" = "eq.0"
			},
			{
				"active" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForactivateRule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForactivateRule>
<CFQUERY NAME="activateRule" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Rules
	SET Active = 1
	WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>

<cfset useLakebaseForactivateRuleCommData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_comm_data")>
<cfif useLakebaseForactivateRuleCommData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rule_comm_data",
			{
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"deleted" = "eq.0"
			},
			{
				"active" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForactivateRuleCommData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForactivateRuleCommData>
<CFQUERY NAME="activateRuleCommData" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Rule_Comm_Data
	SET Active = 1
	WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>

<cfset useLakebaseForactivateRuleOverage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_overage")>
<cfif useLakebaseForactivateRuleOverage>
	<cftry>
		<cfset application.oLakebase.updateRows("program_formula_pricing_rule_overage",
			{
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"deleted" = "eq.0"
			},
			{
				"active" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForactivateRuleOverage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForactivateRuleOverage>
<CFQUERY NAME="activateRuleOverage" datasource="#application.datasource#">
	UPDATE Program_Formula_Pricing_Rule_Overage
	SET Active = 1
	WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>
<!------ Make Active  ----->







<CFSET whereClause="">

<CFQUERY NAME="Get_Active_Products" datasource="#application.datasource#">
	SELECT	cp.BSA_Foodservice_Items_Master_ID
	FROM	Program_Formula_Pricing_Rule_Products fp,  Contract_Products cp
	WHERE	
			fp.Program_Formula_Pricing_Rule_ID 		= '#FORM.Program_Formula_Pricing_Rule_ID#'	
	AND		fp.Program_ID							='#cryp.value#'
	AND		cp.Contract_Products_ID 				= fp.Contract_Product_ID
	AND		fp.Active								= 1
	AND		fp.Deleted 								= 0	
	AND		cp.Deleted								= 0
</CFQUERY>
<CFSET activeProductList=ValueList(Get_Active_Products.BSA_Foodservice_Items_Master_ID,",")>


<CFQUERY NAME="Update_Formula_Price_Rebate_Type" datasource="#application.datasource#">
	UPDATE		Contract_Main
	SET			Formula_Price_Rebate_Type 	= 	#Form.Formula_Price_Rebate_Type#
	WHERE		Contract_Main_ID			=	#cryp.value#	
</CFQUERY>

<CFLOOP INDEX="Product_ID" LIST="#FORM.ABS_FINAL_PRODUCT_LIST#">
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		--Added By Deepa
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		--Added By Deepa
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!------<CFIF Get_Active_Products.recordCount LTE 0>		----->
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
			'#cryp.value#',
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
			Active
		)
		VALUES
		(
			'#cryp.value#',
			'#FORM.Program_Formula_Pricing_Rule_ID#',
			'#saveNewProduct.contract_products_id#',
			'#Evaluate("Form.WEEKLYVOLUME_#ThisProductIDFormattedForHTMLFormElementName#")#',
			'#Evaluate("Form.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#")#',
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
				cp.Contract_Main_ID			=	'#cryp.value#'
				AND
				fp.Program_ID							=	'#cryp.value#'
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
				cp.Deleted									=	0
	</CFQUERY>
	<CFIF get_CP_ID.recordCount GT 0>
		<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(Product_ID,"-","_", "ALL")>
		<CFQUERY NAME="updateFormulaProduct" datasource="#application.datasource#">
			UPDATE		Program_Formula_Pricing_Rule_Products
			SET			
			Weekly_Volume = '#Evaluate("Form.WEEKLYVOLUME_#ThisProductIDFormattedForHTMLFormElementName#")#',
			Product_Overage = '#Evaluate("Form.Overage_LB_#ThisProductIDFormattedForHTMLFormElementName#")#'
			WHERE		
							Program_ID							=	'#cryp.value#'
					AND		Program_Formula_Pricing_Rule_ID		=	'#FORM.Program_Formula_Pricing_Rule_ID#'
					AND		Active								=	1
					AND		Deleted								=	0
					AND		Contract_Product_ID					=	#get_CP_ID.contract_products_id#
		</CFQUERY>
	</CFIF>
</CFIF>

<CFSET whereClause="#whereClause# OR BSA_Foodservice_Items_Master_ID='#Product_ID#' ">
</CFLOOP>


		<CFQUERY datasource="#application.datasource#" NAME="Delete_Not_Selected">
		UPDATE	Program_Formula_Pricing_Rule_Products
		SET		Active = 0,
				Deleted	=	1
		WHERE
				Program_Formula_Pricing_Rule_ID 		= '#FORM.Program_Formula_Pricing_Rule_ID#'
		AND		Program_ID							='#cryp.value#'
		AND		Active								= 1
		AND		Deleted 								= 0
		<CFIF Len(whereClause) GT 0>
		AND		NOT EXISTS(
			SELECT	BSA_Foodservice_Items_Master_ID cp
			FROM	Contract_Products cp
			WHERE	
					cp.Contract_Products_ID 				= Contract_Product_ID
			AND		(1=2 
					<CFIF Len(FORM.ABS_FINAL_PRODUCT_LIST) GT 0>
						OR BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.ABS_FINAL_PRODUCT_LIST, "'", ",")#)
					</CFIF>
					)	
		)
		</CFIF>
		</CFQUERY>
		
		<CFQUERY datasource="#application.datasource#" NAME="Delete_Not_Selected">
		UPDATE			Contract_Products
		SET				Deleted = 0
		WHERE	
					Contract_Main_ID						= #cryp.value#
				AND	NOT (1=2 
						<CFIF Len(FORM.ABS_FINAL_PRODUCT_LIST) GT 0>
						OR BSA_Foodservice_Items_Master_ID IN (#ListQualify(FORM.ABS_FINAL_PRODUCT_LIST, "'", ",")#)
						</CFIF>
						)
		</CFQUERY>
		
	
<CFSET UPDATE = 0>
<CFQUERY datasource="#application.datasource#" NAME="Find_If_Active">
SELECT	Active
FROM	Program_Formula_Pricing_Rules
WHERE	Program_Formula_Pricing_Rule_ID 		= '#FORM.Program_Formula_Pricing_Rule_ID#'
AND		Deleted = 0
</CFQUERY>
<CFIF Find_If_Active.RecordCount GT 0>
	<CFSET UPDATE = Find_If_Active.Active>
</CFIF>


<CFSET generateReleaseProgramID = cryp.value>
<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">


<CFIF UPDATE EQ 1>
	<!------<CFOUTPUT>
		<FORM ACTION="Formula_Pricing_Index_Rule_Summary.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
			<INPUT  TYPE="Hidden" NAME="Rule_ID" VALUE="#URL.RID#">
			<INPUT  TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
			<INPUT  TYPE="Hidden" NAME="Edit" VALUE="1">
		</FORM>
	</CFOUTPUT>
	<script>
			document.all.MyForm.submit();
	</script>----->
	<CFLOCATION URL="Formula_Pricing_Index_Rule_Summary.cfm?CID=#URL.CID#&RID=#URL.RID#">
	
	<!------<CFLOCATION URL="Formula_Pricing_Index_Rule_Summary.cfm?CID=#URL.CID#">----->
<CFELSE>
	<!------<CFLOCATION URL="Contract_Formula_Rule_Step_4.cfm?CID=#URL.CID#&RID=#URL.RID#">----->
	<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.CID#">
</CFIF>

