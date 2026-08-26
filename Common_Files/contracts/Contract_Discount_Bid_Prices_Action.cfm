<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<CFSET Cryp_Program_ID = FORM.Program_ID>
<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>

<!--- lock checker --->
<CFSET LockChecker_CID  = cryp.value>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
<!--- lock checker --->


<!--- update rate type --->
<cfset useLakebaseForupdateRateType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdateRateType>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#form.Program_ID#"
			},
			{
				"bid_price_rebate_type" = "#form.Bid_Price_Rebate_Type#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateRateType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateRateType>
<cfquery name="updateRateType" datasource="#application.datasource#">
UPDATE Contract_Main
SET Bid_Price_Rebate_Type = '#form.Bid_Price_Rebate_Type#'
WHERE Contract_Main_ID = '#form.Program_ID#'
</cfquery>
</cfif>


<CFQUERY NAME="getProductsToDelete" datasource="#application.datasource#">
SELECT     	Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, 
			Program_Bid_Price_Product_Data.Program_ID, Program_Bid_Price_Product_Data.Program_Bid_Price_Product_Data_ID
FROM		Contract_Products 
			INNER JOIN	Program_Bid_Price_Product_Data 
			ON 
			Contract_Products.Contract_Products_ID = Program_Bid_Price_Product_Data.Contract_Products_ID
WHERE     
			(Contract_Products.Deleted = 0) 
			AND (Program_Bid_Price_Product_Data.Deleted = 0) 
			AND (Program_Bid_Price_Product_Data.Program_ID = '#FORM.Program_ID#') 
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

	<CFQUERY NAME="deleteCurrentProgramProductsFromBidPriceTable" datasource="#application.datasource#">
		UPDATE Program_Bid_Price_Product_Data
		SET Deleted = 1
		WHERE Contract_Products_ID IN(#listofitemstodelete#)
	</CFQUERY>	
</CFIF>

<CFQUERY NAME="getActiveProducts" datasource="#application.datasource#">
	SELECT     	Contract_Products.Contract_Products_ID, Contract_Products.BSA_Foodservice_Items_Master_ID, 
				Program_Bid_Price_Product_Data.Program_ID, Program_Bid_Price_Product_Data.Program_Bid_Price_Product_Data_ID
FROM			Contract_Products 
				INNER JOIN	Program_Bid_Price_Product_Data 
				ON
				Contract_Products.Contract_Products_ID = Program_Bid_Price_Product_Data.Contract_Products_ID
WHERE     
				(Contract_Products.Deleted = 0) 
				AND (Program_Bid_Price_Product_Data.Deleted = 0) 
				AND (Program_Bid_Price_Product_Data.Program_ID = '#FORM.Program_ID#')
</CFQUERY>

<cfset listofactiveproducts = valuelist(getActiveProducts.BSA_Foodservice_Items_Master_ID)>
<cfset Program_Bid_Price_Product_Data_ID_List = valuelist(getActiveProducts.Program_Bid_Price_Product_Data_ID)>
<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#">
	<CFSET Form_Product_ID = Replace(Product_ID, "-", "_", "ALL")>
	<CFIF NOT ListFindNoCase(listofactiveproducts,Product_ID,",")>
		<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
			INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID)
			VALUES
			('#Product_ID#', '#FORM.Program_ID#', 9)
		</CFQUERY>
		
		<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Bid_Price_Product_Data
			(Program_ID, Contract_Products_ID, Manual_Rate_Source, Rate_LB, Rate_CS)
			VALUES
			('#FORM.Program_ID#', '#saveContractProducts.Contract_Products_ID#', #evaluate("FORM.Manual_Rate_Source_#Form_Product_ID#")#, '#evaluate("FORM.Rate_LB_#Form_Product_ID#")#', '#evaluate("FORM.Rate_CS_#Form_Product_ID#")#')
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="Get_Program_Bid_Price_Product_Data_ID" DBTYPE="query">
			SELECT	Program_Bid_Price_Product_Data_ID
			FROM	getActiveProducts
			WHERE
					BSA_Foodservice_Items_Master_ID = '#Product_ID#'
		</CFQUERY>
		<CFIF Get_Program_Bid_Price_Product_Data_ID.RecordCount GT 0>
			<CFQUERY NAME="updateBidPriceData" datasource="#application.datasource#">
				UPDATE Program_Bid_Price_Product_Data
				SET 
					Manual_Rate_Source 	= #evaluate("FORM.Manual_Rate_Source_#Form_Product_ID#")#,
					Rate_LB				= '#evaluate("FORM.Rate_LB_#Form_Product_ID#")#',
					Rate_CS				= '#evaluate("FORM.Rate_CS_#Form_Product_ID#")#'
				WHERE Program_Bid_Price_Product_Data_ID = '#Get_Program_Bid_Price_Product_Data_ID.Program_Bid_Price_Product_Data_ID#'
			</CFQUERY>	
		</CFIF>		
	</CFIF>	
</CFLOOP>

	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#FORM.Program_ID#" null="no">
				   
	</cfstoredproc>
			
	<CFTRANSACTION ACTION="COMMIT">
	
</CFTRANSACTION>


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

<CFSET redirector_Program_ID = getProgramType.ProgramType_ID>
<CFSET redirector_FromPage_ID = 10>
<cfinclude template="internal_redirector_based_on_settings.cfm">
<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#Cryp_Program_ID#">		
