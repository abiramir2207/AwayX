<cfset Encryp_Program_ID = FORM.Program_ID>
<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>

<!--- lock checker --->
<CFSET LockChecker_CID  = FORM.Program_ID>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
<!--- lock checker --->

<CFTRANSACTION ACTION="BEGIN">

	<CFQUERY NAME="deleteProducts" datasource="#application.datasource#">
		UPDATE 	Contract_Products
		SET 	Deleted = 1
		WHERE 	Contract_Main_ID = #FORM.Program_ID#
		AND		Product_Type_ID = 3
		AND		Contract_Products_ID IN 
				(
					SELECT Contract_Products_ID 
					FROM Program_Lump_Sum_Product_Data
					WHERE Program_Lump_Sum_ID = '#FORM.Component_ID#'
				)
	</CFQUERY>
	
	<CFQUERY NAME="deletecomponent" datasource="#application.datasource#">
		UPDATE Program_Lump_Sums
		SET Deleted = 1
		WHERE Program_Lump_Sum_ID = '#FORM.Component_ID#'
	</CFQUERY>
	
	<CFQUERY NAME="deletecomponentproducts" datasource="#application.datasource#">
		UPDATE Program_Lump_Sum_Product_Data
		SET Deleted = 1
		WHERE Program_Lump_Sum_ID = '#FORM.Component_ID#'
	</CFQUERY>
	
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">
				   
	</cfstoredproc>

<cftransaction action="commit" />

</CFTRANSACTION>

<!------ Start Clause Code ----->
<cfset discountTypeId = 3>
<cfset programId = cryp.value>
<cfinclude template="/Clause_Library/Clause_Discount_Type_Add_Remove.cfm">
<!------ End  Clause Code ----->

<cfset locateBackTo = "Contract_Discount_Lump_Sums.cfm?CID=#Encryp_Program_ID#" />

<CFLOCATION URL="#locateBackTo#">