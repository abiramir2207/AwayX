<cfquery name="GetExistingProducts" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Products
	WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
</cfquery>	
<CFLOOP INDEX="LoopCount" FROM="1" TO="#Form.ProductCount#" STEP="1">
	<CFIF isdefined("FORM.UPC_#LoopCount#")>
		<CFQUERY NAME="UpdateContractProductsRebate" datasource="#application.datasource#">
			UPDATE 
				Contract_Products
			SET 
				Discount_Value 	=	'#evaluate("FORM.UPC_#LoopCount#_rebate")#',
				Pricing_Rule	=	'#evaluate("FORM.UPC_#LoopCount#_Pricing_Rule")#',
				Editor_ID		=	'#request.AccessStructure.User_ID#'
			WHERE 
				Contract_Main_ID = '#FORM.Contract_Main_ID#'
				AND
				Product_UPC = '#trim(evaluate("FORM.UPC_#LoopCount#_value"))#'
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="UpdateContractProductsRebate" datasource="#application.datasource#">
			UPDATE 
				Contract_Products
			SET 
				Discount_Value 	=	'#evaluate("FORM.UPC_#LoopCount#_rebate")#',
				Pricing_Rule	=	'#evaluate("FORM.UPC_#LoopCount#_Pricing_Rule")#',
				Editor_ID		=	'#request.AccessStructure.User_ID#'
			WHERE 
				Contract_Main_ID = '#FORM.Contract_Main_ID#'
				AND
				Product_UPC = '#trim(evaluate("FORM.UPC_#LoopCount#_value"))#'
		</CFQUERY>

<!--- 		<CFQUERY NAME="UpdateContractProductsRebate" datasource="#application.datasource#">
			DELETE 
			FROM	
				Contract_Products
			WHERE 
				Contract_Main_ID = '#FORM.Contract_Main_ID#'
				AND
				Product_UPC = '#trim(evaluate("FORM.DELETE_#LoopCount#"))#'
		</CFQUERY>		
 --->	</CFIF>
</CFLOOP>

	<CF_CRYP type="en" string="#Form.Contract_Main_ID#" key="#request.key#">
	
	<CFIF GetExistingProducts.recordcount NEQ 0>
		<CFLOCATION URL="Contract_Edit_Menu.cfm?CID=#cryp.value#">
	<CFELSE>
		<CFLOCATION URL="contract_create_3_form.cfm?CID=#cryp.value#">
	</CFIF>
