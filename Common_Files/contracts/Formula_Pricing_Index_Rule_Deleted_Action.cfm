<cf_cryp type="de" key="#request.key#" string="#FORM.Delete_Rule_ID#">
<CFSET Rule_ID = cryp.value>

<cf_cryp type="de" key="#request.key#" string="#FORM.CID#">
<CFSET Program_ID = cryp.value>

<CFTRANSACTION ACTION="BEGIN">
	<!------
	<CFQUERY NAME="DELETERuleCommData" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Comm_Data
		SET 
			Active = 0,
			Deleted = 1
		WHERE 
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Deleted = 0
			AND
			Active = 1
	</CFQUERY>
	
	<CFQUERY NAME="DELETERuleOverage" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Overage
		SET 
			Active = 0,
			Deleted = 1
		WHERE 
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Deleted = 0
			AND
			Active = 1
	</CFQUERY>
	----------->
	
	<CFQUERY NAME="getAllContractProductsIDs" datasource="#application.datasource#">
		SELECT 
			Contract_Product_ID 
		FROM 
			Program_Formula_Pricing_Rule_Products
		WHERE 
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="DELETERuleProducts" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Products
		SET 
			Active = 0,
			Deleted = 1
		WHERE 
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			AND
			Deleted = 0
			AND
			Active = 1
	</CFQUERY>
	
	<CFQUERY NAME="DELETERule" datasource="#application.datasource#">
		UPDATE Program_Formula_Pricing_Rule_Mapped
		SET 
			Deleted = 1
		WHERE 
			Program_Formula_Pricing_Rule_Mapped_ID = '#Rule_ID#'
			AND
			Deleted = 0
			
	</CFQUERY>
	
	<CFIF getAllContractProductsIDs.recordcount GT 0>
		<CFQUERY NAME="DELETE_Contract_Products" datasource="#application.datasource#">
			UPDATE Contract_Products
			SET Deleted = 1
			WHERE Contract_Products_ID IN(#valuelist(getAllContractProductsIDs.Contract_Product_ID)#)
		</CFQUERY>
	</CFIF>
	
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Program_ID#" null="no">
				   
	</cfstoredproc>
	
	<CFTRANSACTION ACTION="COMMIT">
</CFTRANSACTION>

<!------ Start Clause Code ----->
<cfset discountTypeId = 5>
<cfset programId = Program_ID>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<CFLOCATION URL="Formula_Pricing_Index.cfm?CID=#FORM.CID#">

