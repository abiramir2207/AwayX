<!---  
       Name:          BillbackSwitchProducts.cfc           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  11/12/2009
       Created By:    Tim Ford
       Description:   This handles for all backend function related to Billback switch products
--->
<cfcomponent displayname="BillbackSwitchProducts">

	<cffunction name="saveSwitchProducts" output="false">
	
		<cfargument name="billbackId" 			type="string" required="yes" />
		<cfargument name="billbackProgramId" 	type="string" required="yes" />
		<cfargument name="programId" 			type="string" required="yes" />
		<cfargument name="productIdOld" 		type="string" required="yes" />
		<cfargument name="productIdNew" 		type="string" required="yes" />
		<cfargument name="userID" 				type="string" required="yes" />
		<cfargument name="billbackProductId" 	type="string" required="yes" />
		
		<cfset var var_ExistingBillbackProductID = "" />
		
		<!--- check to see if the product we are switching to belongs to the same billback program--->
		<cfquery name="qIsProductAlreadyInBillback" dataSource="#application.datasource#">
			SELECT	*
			FROM	Billback_Product
			WHERE	Billback_Program_ID = 	<cfqueryparam 	cfsqltype="CF_SQL_VARCHAR"	value="#arguments.billbackProgramId#"/>
			AND		Product_ID 			= 	<cfqueryparam 	cfsqltype="CF_SQL_VARCHAR"	value="#arguments.productIdNew#"/>
			AND		Deleted				=	<cfqueryparam 	cfsqltype="CF_SQL_BIT"		value="0"/>
		</cfquery>
		
		<!---handle for the product that already exists--->
		<cfif qIsProductAlreadyInBillback.RecordCount>
		
			<cfset var_ExistingBillbackProductID = qIsProductAlreadyInBillback.Billback_Product_ID />
			
			<cfset this.saveProductOnBillbackProgram(arguments.billbackId, arguments.billbackProgramId, arguments.programId, arguments.productIdOld, arguments.productIdNew, arguments.billbackProductId, var_ExistingBillbackProductID) />
			
		<cfelse>

			<cfset this.saveProductNotOnBillbackProgram(arguments.billbackId, arguments.billbackProgramId, arguments.programId, arguments.productIdOld, arguments.productIdNew, arguments.billbackProductId) />
						
		</cfif>
		
		<!---only update if we have an old product id --->
		<cfif len(trim(arguments.productIdOld))>
			<cfquery name="qUpdateBillbackProductDiscount" dataSource="#application.datasource#">
				UPDATE	BB_Product_Discount
				SET		Product_ID 			= 	<cfqueryparam value="#arguments.productIdNew#" 	cfsqltype="CF_SQL_VARCHAR" />
				WHERE	Product_ID 			= 	<cfqueryparam value="#arguments.productIdOld#" 	cfsqltype="CF_SQL_VARCHAR" />
				AND		Billback_ID			=	<cfqueryparam value="#arguments.billbackId#" 	cfsqltype="CF_SQL_VARCHAR" />
				AND		Program_ID			=	<cfqueryparam value="#arguments.programId#" 	cfsqltype="CF_SQL_INTEGER" />
			</cfquery>
		</cfif>

	
		<cfset this.logSwitchProducts(arguments.billbackId, arguments.billbackProgramId, arguments.billbackProductId, arguments.programId, arguments.productIdOld, arguments.productIdNew, arguments.userID) />
		
	</cffunction>
	
	
	<cffunction name="saveProductOnBillbackProgram" output="false">
	
		<cfargument name="billbackId" 					type="string" required="yes" />
		<cfargument name="billbackProgramId" 			type="string" required="yes" />
		<cfargument name="programId" 					type="string" required="yes" />
		<cfargument name="productIdOld" 				type="string" required="yes" />
		<cfargument name="productIdNew" 				type="string" required="yes" />
		<cfargument name="billbackProductId" 			type="string" required="yes" />
		<cfargument name="existingbillbackProductId" 	type="string" required="yes" />
		
		<cfset var var_Item = "" />
		<cfset var var_selectedVolumeType = 0 />
		<cfset var qGetSelectedVolumeType = "" />
		
		<!---get the quantity and volume of the product that already exists--->
		<cfquery name="qGetExistingData" dataSource="#application.datasource#">
			SELECT	Billback_Product_ID,
					BB_Product_Quantity,
					BB_Product_UOM,
					CASE  WHEN Billback_Product.BB_Product_UOM = 1 THEN	BB_Product_Quantity
					ELSE (CAST(BB_Product_Quantity AS FLOAT) * CAST(ISNULL(BSA_Foodservice_Items_Master.Net_Weight, 1.00) AS FLOAT))
					END AS Case_Quantity,
					CASE  WHEN Billback_Product.BB_Product_UOM = 1 
					THEN (CAST(BB_Product_Quantity AS FLOAT) / CAST(ISNULL(BSA_Foodservice_Items_Master.Net_Weight, 1.00) AS FLOAT))
					ELSE BB_Product_Quantity
					END AS Pound_Quantity
			FROM	Billback_Product
					LEFT JOIN BSA_Foodservice_Items_Master ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
			WHERE	Billback_Product_ID	= 	<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.billbackProductId#"/>
		</cfquery>
			
		<!--- Update Existing Billback Product --->
		<cfquery name="qUpdateExistingBillbackProduct" dataSource="#application.datasource#">
			UPDATE	Billback_Product
			SET		BB_Product_Quantity = 
					CASE 
						WHEN Billback_Product.BB_Product_UOM = 1 THEN CAST(BB_Product_Quantity AS FLOAT) + #numberformat(qGetExistingData.Case_Quantity)# 
						ELSE CAST(BB_Product_Quantity AS FLOAT) + #numberformat(qGetExistingData.Pound_Quantity)#
					END
			WHERE	Billback_Product_ID 			= 	<cfqueryparam 	cfsqltype="CF_SQL_VARCHAR"	value="#arguments.existingbillbackProductId#"/>
			AND		Deleted							=	<cfqueryparam 	cfsqltype="CF_SQL_BIT"		value="0"/>
		</cfquery>
		
		<!---get Billback Product Detail Data for the Product we're switching from --->
		<cfquery name="qGetExistingProductDetailData" dataSource="#application.datasource#">
			SELECT	BB_Product_Type_ID,
					BB_Rate,
					Distributor_ID_Earned
			FROM	Billback_Product_Detail
			WHERE	Billback_Product_ID = 	<cfqueryparam	value="#arguments.billbackProductId#" cfsqltype="CF_SQL_VARCHAR" />
			AND		Deleted 			=	<cfqueryparam 	value="0" cfsqltype="CF_SQL_BIT"/>
		</cfquery>
		
		<!---loop over product detail and check if there is an entry for the product type--->
		<cfloop query="qGetExistingProductDetailData">
		
			<!---check if entry exists for the product being switched to--->
			<cfquery name="qDoesDetailProductTypeExist" dataSource="#application.datasource#">
				SELECT	*
				FROM	Billback_Product_Detail
				WHERE	Deleted = 0
				AND		BB_Product_Type_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#qGetExistingProductDetailData.BB_Product_Type_ID#" />
				AND		Billback_Product_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR"	value="#arguments.existingbillbackProductId#"/>
			</cfquery>
			
			<!---if it exists then update the rate --->
			<cfif qDoesDetailProductTypeExist.RecordCount>
			
				<cfquery name="qUpdateBillbackProductDetail" dataSource="#application.datasource#">
					UPDATE	Billback_Product_Detail
					SET		BB_Rate = BB_Rate + CAST(#qGetExistingProductDetailData.BB_Rate# AS DECIMAL(24,9))
					WHERE	Deleted = 0
					AND		BB_Product_Type_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#qGetExistingProductDetailData.BB_Product_Type_ID#" />
					AND		Billback_Product_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR"	value="#arguments.existingbillbackProductId#"/>
				</cfquery>
			
			<!---otherwise insert a new entry--->
			<cfelse>
				
				<cfset useLakebaseForqAddBillbackProductDetail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForqAddBillbackProductDetail>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_product_detail", {
			"billback_product_id" = "#arguments.existingbillbackProductId#",
			"billback_id" = "#arguments.billbackId#",
			"bb_product_type_id" = "#qGetExistingProductDetailData.BB_Product_Type_ID#",
			"bb_rate" = "#qGetExistingProductDetailData.BB_Rate#",
			"distributor_id_earned" = "#qGetExistingProductDetailData.Distributor_ID_Earned#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddBillbackProductDetail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddBillbackProductDetail>
<cfquery name="qAddBillbackProductDetail" dataSource="#application.datasource#">
				
					INSERT INTO Billback_Product_Detail
					(
						Billback_Product_ID,
						Billback_ID,
						BB_Product_Type_ID,
						BB_Rate,
						Distributor_ID_Earned
					)
					VALUES
					(
						'#arguments.existingbillbackProductId#',
						'#arguments.billbackId#',
						'#qGetExistingProductDetailData.BB_Product_Type_ID#',
						'#qGetExistingProductDetailData.BB_Rate#',
						'#qGetExistingProductDetailData.Distributor_ID_Earned#'
					)
				</cfquery>
</cfif>
			
			</cfif>
		
		</cfloop>
		
		<!--- now delete old billback product detail --->
		<cfquery name="qDeleteOldProductDetail" dataSource="#application.datasource#">
			UPDATE	Billback_Product_Detail
			SET		Deleted = 1
			WHERE	Deleted = 0
			AND		Billback_Product_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR"	value="#arguments.billbackProductId#"/>
			</cfquery>
				
		<!--- Ge the Item value for the new product to update Item in BB_Item_Invoice_Level --->
		<cfquery name="qGetItemValue" dataSource="#application.datasource#">
			SELECT	RTRIM(BSA_Foodservice_Items_Master.Item) + CHAR(13) + RTRIM(BSA_Foodservice_Items_Master.Description) AS Item
			FROM	BSA_Foodservice_Items_Master
			WHERE	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.productIdNew#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>
		
		<cfset var_Item = qGetItemValue.Item />
		
		<!--- Find the selected volume type for existing record  --->
		<cfset var_selectedVolumeType = 0 />
		<cfquery name="qGetSelectedVolumeType" datasource="#application.datasource#">
			SELECT	Selected_Vol_Type
			FROM	BB_Item_Invoice_Level
			WHERE 	Billback_Product_ID = <cfqueryparam value="#arguments.existingbillbackProductId#"	cfsqltype="CF_SQL_VARCHAR"/>
		</cfquery>
		<cfif qGetSelectedVolumeType.recordCount>
			<cfif qGetSelectedVolumeType.Selected_Vol_Type NEQ "">
				<cfset var_selectedVolumeType = qGetSelectedVolumeType.Selected_Vol_Type />
			</cfif>
		</cfif>
				
		<!--- Update Billback Item Invoice Level with the new Product GUID, Billback Product GUID and Item value --->
		<cfquery name="qUpdateBillbackItemInvoiceLevel" dataSource="#application.datasource#">
			UPDATE	BB_Item_Invoice_Level
			SET		Product_ID			= 	<cfqueryparam value="#arguments.productIdNew#"				cfsqltype="CF_SQL_VARCHAR"/>,
					Item 				=	<cfqueryparam value="#var_Item#"							cfsqltype="CF_SQL_VARCHAR"/>,
					Billback_Product_ID = 	<cfqueryparam value="#arguments.existingbillbackProductId#"	cfsqltype="CF_SQL_VARCHAR"/>
				<cfif var_selectedVolumeType EQ 1> <!--- Claimed --->
					,Selected_Vol_Type 	= 1,
					Selected_Vol_CS 	= Claimed_CS,
					Selected_Vol_LB 	= Claimed_LB
				<cfelseif var_selectedVolumeType EQ 2> <!--- Expected --->
					,Selected_Vol_Type 	= 2,
					Selected_Vol_CS 	= Expected_CS,
					Selected_Vol_LB 	= Expected_LB
				</cfif>		
			WHERE	Billback_Product_ID = 	<cfqueryparam value="#arguments.billbackProductId#"			cfsqltype="CF_SQL_VARCHAR"/>
			AND		Deleted				=	<cfqueryparam value="0"										cfsqltype="CF_SQL_BIT"/>
		</cfquery>
		
		<!---delete the old billback product entry --->
		<cfquery name="qDeleteOldBillbackProduct" dataSource="#application.datasource#">
			UPDATE	Billback_Product
			SET		Deleted				=	<cfqueryparam	cfsqltype="CF_SQL_BIT"		value="1"/>
			WHERE	Billback_Product_ID	= 	<cfqueryparam 	cfsqltype="CF_SQL_VARCHAR"	value="#arguments.billbackProductId#"/>
			AND		Deleted				=	<cfqueryparam 	cfsqltype="CF_SQL_BIT"		value="0"/>
		</cfquery>
	
	</cffunction>
	
	<cffunction name="saveProductNotOnBillbackProgram" output="false">
	
		<cfargument name="billbackId" 			type="string" required="yes" />
		<cfargument name="billbackProgramId" 	type="string" required="yes" />
		<cfargument name="programId" 			type="string" required="yes" />
		<cfargument name="productIdOld" 		type="string" required="yes" />
		<cfargument name="productIdNew" 		type="string" required="yes" />
		<cfargument name="billbackProductId" 	type="string" required="yes" />
		
		<cfset var var_Item = "" />
		
		<!--- Update Billback Product with the new GUID --->
		<cfquery name="qUpdateBillbackProduct" dataSource="#application.datasource#">
			UPDATE	Billback_Product
			SET		Product_ID 						= 	<cfqueryparam	cfsqltype="CF_SQL_VARCHAR" 	value="#arguments.productIdNew#" />,
					Product_Type_ID 				= 	<cfqueryparam 	cfsqltype="CF_SQL_INTEGER"	value="1" />,
					BB_Unknown_Product_Item_Number	=	<cfqueryparam	cfsqltype="CF_SQL_VARCHAR" 	null="yes" />,
					BB_Unknown_Product_Description	=	<cfqueryparam	cfsqltype="CF_SQL_VARCHAR" 	null="yes" />,
					Invalid_Product					=	<cfqueryparam	cfsqltype="CF_SQL_VARCHAR" 	null="yes" />,
					Invalid_Product_Desc			=	<cfqueryparam	cfsqltype="CF_SQL_VARCHAR" 	null="yes" />
			WHERE	Billback_Product_ID 			= 	<cfqueryparam 	cfsqltype="CF_SQL_VARCHAR"	value="#arguments.billbackProductId#"/>
			AND		Deleted							=	<cfqueryparam 	cfsqltype="CF_SQL_BIT"		value="0"/>
		</cfquery>
		
		
		<!--- Ge the Item value for the new product to update Item in BB_Item_Invoice_Level --->
		<cfquery name="qGetItemValue" dataSource="#application.datasource#">
			SELECT	RTRIM(BSA_Foodservice_Items_Master.Item) + CHAR(13) + RTRIM(BSA_Foodservice_Items_Master.Description) AS Item
			FROM	BSA_Foodservice_Items_Master
			WHERE	BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.productIdNew#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>
		
		<cfset var_Item = qGetItemValue.Item />
		
		<!--- Update Billback Item Invoice Level with the new GUID and Item value --->
		<cfquery name="qUpdateBillbackItemInvoiceLevel" dataSource="#application.datasource#">
			UPDATE	BB_Item_Invoice_Level
			SET		Product_ID			= 	<cfqueryparam value="#arguments.productIdNew#"		cfsqltype="CF_SQL_VARCHAR"/>,
					Item 				=	<cfqueryparam value="#var_Item#"					cfsqltype="CF_SQL_VARCHAR"/>		
			WHERE	Billback_Product_ID = 	<cfqueryparam value="#arguments.billbackProductId#"	cfsqltype="CF_SQL_VARCHAR"/>
			AND		Deleted				=	<cfqueryparam value="0"								cfsqltype="CF_SQL_BIT"/>
		</cfquery>
			
	
	</cffunction>
	
	<cffunction name="logSwitchProducts" output="false">
	
		<cfargument name="billbackId" 			type="string" required="yes" />
		<cfargument name="billbackProgramId" 	type="string" required="yes" />
		<cfargument name="billbackProductId" 	type="string" required="yes" />
		<cfargument name="programId" 			type="string" required="yes" />
		<cfargument name="productIdOld" 		type="string" required="yes" />
		<cfargument name="productIdNew" 		type="string" required="yes" />
		<cfargument name="userID" 				type="string" required="yes" />
		
		<cfset var var_isNull = "no" />
		<!--- if the old product id is null then log a null value --->
		<cfif not len(trim(arguments.productIdOld))>
			<cfset var_isNull = "yes" />
		</cfif>

		<cfquery name="qLogBillbackSwitchProducts" dataSource="#application.datasource#">
		
			INSERT INTO Billback_Switch_Products_Log
				(Billback_ID, Billback_Program_ID, Billback_Product_ID, Program_ID, Old_Product_ID, New_Product_ID, User_ID)
			VALUES
				(
					<cfqueryparam value="#arguments.billbackId#" 		cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.billbackProgramId#"	cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.billbackProductId#"	cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.programId#" 		cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#arguments.productIdOld#" 		cfsqltype="CF_SQL_VARCHAR" null="#var_isNull#" />,
					<cfqueryparam value="#arguments.productIdNew#" 		cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.userID#" 			cfsqltype="CF_SQL_VARCHAR" />
				)
		
		</cfquery>
	
	</cffunction>
	
</cfcomponent>