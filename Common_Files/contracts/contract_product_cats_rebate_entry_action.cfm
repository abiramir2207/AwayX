<CF_Cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<CFSET FORM.Program_ID = cryp.value>

<CFIF len(trim(FORM.newProgramGlobalVolume)) GT 0>
	<cfquery name="saveNewProgramVolume" datasource="#application.datasource#">
		UPDATE Contract_Main
		SET Contract_Quantity = '#trim(FORM.newProgramGlobalVolume)#'
		WHERE Contract_Main_ID = '#FORM.Program_ID#'
	</cfquery>
</CFIF>


<!--- Loop through form elements --->
<CFLOOP index="ListFormElement" list="#FORM.FieldNames#">
<cfoutput>#ListFormElement#</cfoutput><br>

	<CFSET currentFormElement = ListToArray(ListFormElement, "_")>
	<CFIF NOT arraylen(currentFormElement)  GTE 10><CFSET currentFormElement[10] = "NOTHING"></CFIF>
	<CFIF UCASE(currentFormElement[1]) EQ "CATEGORY" AND UCASE(currentFormElement[10]) EQ "VOLUME">
		<CFSET TypeGroup_ID = currentFormElement[2]>
		<CFSET QBrand_ID	= currentFormElement[3]>
		<CFSET TypeCode_ID 	= currentFormElement[4]>
		<CFSET Brand_ID 	= currentFormElement[5]>
		
		<cfquery name="getProductCategoryID" datasource="#application.datasource#">
			SELECT Program_Product_Category_ID
			FROM Program_Product_Categories
			WHERE 
				TypeGroup_desc_ID 	= '#TypeGroup_ID#'
				AND
				Qbrand_desc_ID 		= '#QBrand_ID#'
				AND
				TypeCode_desc_ID	= '#TypeCode_ID#'
				AND
				Brand_ID			= '#Brand_ID#'
				AND
				Program_ID 			= '#FORM.Program_ID#' 
				AND 
				isContract 			= 1
				AND 
				Deleted 			= 0
			</cfquery>

			<CFSET FormVariableName = Mid(ListFormElement,1, len(ListFormElement)-7)>
			
			<CFSET product_BSA_Foodservice_Items_Master_ID = currentFormElement[7]>
	
			<CFSET product_Volume = evaluate("FORM.#FormVariableName#_VOLUME")>
				<CFIF len(trim(product_Volume)) EQ 0><CFSET product_Volume = 0></CFIF>
	
			<CFSET product_Volume_UOM = 1>
	
			<CFSET product_Rate = evaluate("FORM.#FormVariableName#_RATE")>
				<CFIF len(trim(product_Rate)) EQ 0><CFSET product_Rate = 0></CFIF>
	
			<CFSET product_Rate_UOM = evaluate("FORM.#FormVariableName#_RATE_UOM")>
			
			
			<!--- check for the data combination i'm about to insert --->
			<cfset useLakebaseForcheckForThisCombo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_category_product_rates_volumes")>
<cfif useLakebaseForcheckForThisCombo>
	<cftry>
		<cfset checkForThisCombo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_product_category_product_rates_volumes", {
				"program_id" = "eq.#FORM.Program_ID#",
				"bsa_foodservice_items_master_id" = "eq.#product_BSA_Foodservice_Items_Master_ID#",
				"deleted" = "eq.0",
				"select" = "program_product_category_id"
			}), "program_product_category_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckForThisCombo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckForThisCombo>
<cfquery name="checkForThisCombo" datasource="#application.datasource#">
				SELECT Program_Product_Category_ID
				FROM Program_Product_Category_Product_Rates_Volumes
				WHERE
					Program_ID 								= '#FORM.Program_ID#'
					AND
					BSA_Foodservice_Items_Master_ID		= '#product_BSA_Foodservice_Items_Master_ID#'
					AND 
					Deleted 								= 0
			</CFQUERY>
</cfif>
			
			<cfoutput>#checkForThisCombo.recordcount#</cfoutput>
			<!--- INSERT NEW RECORD --->
			<CFIF checkForThisCombo.recordcount EQ 0>
			<!--- INSERT PER PRODUCT DATA --->
				<cfset useLakebaseForinsertProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_category_product_rates_volumes")>
<cfif useLakebaseForinsertProductData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_product_category_product_rates_volumes", {
			"program_product_category_id" = "#getProductCategoryID.Program_Product_Category_ID#",
			"program_id" = "#FORM.Program_ID#",
			"iscontract" = "#FORM.Program_Volume_UOM#",
			"bsa_foodservice_items_master_id" = "#product_BSA_Foodservice_Items_Master_ID#",
			"volume" = "#product_Volume#",
			"volume_uom" = "#product_Volume_UOM#",
			"rate" = "#product_Rate#",
			"rate_uom" = "#product_Rate_UOM#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertProductData>
<cfquery name="insertProductData" datasource="#application.datasource#">
					INSERT INTO Program_Product_Category_Product_Rates_Volumes
					(
						Program_Product_Category_ID,
						Program_ID,
						isContract,
						BSA_Foodservice_Items_Master_ID,
						Volume,
						Volume_UOM,
						Rate,
						Rate_UOM
					)
					VALUES
					(
						'#getProductCategoryID.Program_Product_Category_ID#',
						'#FORM.Program_ID#',
						'#FORM.Program_Volume_UOM#',
						'#product_BSA_Foodservice_Items_Master_ID#',
						'#product_Volume#',
						'#product_Volume_UOM#',
						'#product_Rate#',
						'#product_Rate_UOM#'
					)
				</cfquery>
</cfif>			
			<!--- UPDATE EXISTING RECORD --->
			<CFELSE>
				<cfset useLakebaseForupdateProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_category_product_rates_volumes")>
<cfif useLakebaseForupdateProductData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_product_category_product_rates_volumes",
			{
				"program_id" = "eq.#FORM.Program_ID#",
				"bsa_foodservice_items_master_id" = "eq.#product_BSA_Foodservice_Items_Master_ID#",
				"deleted" = "eq.0"
			},
			{
				"volume" = "#product_Volume#",
				"volume_uom" = "#product_Volume_UOM#",
				"rate" = "#product_Rate#",
				"rate_uom" = "#product_Rate_UOM#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateProductData>
<cfquery name="updateProductData" datasource="#application.datasource#">
					UPDATE Program_Product_Category_Product_Rates_Volumes
					SET
						Volume									=	'#product_Volume#',
						Volume_UOM								=	'#product_Volume_UOM#',
						Rate									=	'#product_Rate#',
						Rate_UOM								=	'#product_Rate_UOM#'
					WHERE
						Program_ID 								= 	'#FORM.Program_ID#'
						AND
						BSA_Foodservice_Items_Master_ID		= 	'#product_BSA_Foodservice_Items_Master_ID#'
						AND 
						Deleted 								= 0
				</cfquery>
</cfif>			
			</CFIF>
	</CFIF>
</CFLOOP>

<CF_cryp type="en" key="#request.key#" string="#FORM.Program_ID#">
<CFLOCATION url="contract_edit_menu.cfm?CID=#cryp.value#">