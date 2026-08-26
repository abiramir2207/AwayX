<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<CFPARAM NAME="FORM.Component_ID" DEFAULT="">

<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>

<!--- lock checker --->
<CFSET LockChecker_CID  = FORM.Program_ID>
<CFINCLUDE TEMPLATE="LockChecker.cfm">
<!--- lock checker --->


<CFQUERY NAME="getProductsToDelete" datasource="#application.datasource#">
SELECT     dbo.Program_Growth_Components.Program_ID, dbo.Contract_Products.Contract_Products_ID, 
                      dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
FROM         dbo.Program_Growth_Components INNER JOIN
                      dbo.Contract_Products INNER JOIN
                      dbo.Program_Growth_Component_Product_Data ON 
                      dbo.Contract_Products.Contract_Products_ID = dbo.Program_Growth_Component_Product_Data.Contract_Products_ID ON 
                      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID
WHERE     (dbo.Program_Growth_Components.Program_Growth_Component_ID = '#FORM.Component_ID#') AND (dbo.Contract_Products.Deleted = 0) AND (dbo.Program_Growth_Component_Product_Data.Deleted = 0) AND 
                      (dbo.Program_Growth_Components.Program_ID = '#FORM.Program_ID#') <CFIF listlen(Product_List) GT 0> AND (dbo.Contract_Products.BSA_Foodservice_Items_Master_ID NOT IN(#listqualify(Product_List, "'")#))</CFIF>
</CFQUERY>
<CFSET listofitemstodelete = valuelist(getProductsToDelete.Contract_Products_ID)>
<CFSET List_Program_Growth_Component_Product_Data_ID_To_Delete = valueList(getProductsToDelete.Program_Growth_Component_Product_Data_ID)>
<CFTRANSACTION isolation="read_uncommitted">
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

	<CFQUERY NAME="deleteCurrentComponentProducts_1" datasource="#application.datasource#">
		UPDATE Program_Growth_Component_Product_Data
		SET Deleted = 1
		WHERE Program_Growth_Component_Product_Data_ID IN(#valuelist(getProductsToDelete.Program_Growth_Component_Product_Data_ID)#) AND Program_Growth_Component_ID = '#FORM.Component_ID#'
	</CFQUERY>

	<CFQUERY NAME="deleteCurrentComponentProducts_2" datasource="#application.datasource#">
		UPDATE Program_Growth_Component_Product_Tier_Data
		SET Deleted = 1
		WHERE Program_Growth_Component_Product_Data_ID IN(#List_Program_Growth_Component_Product_Data_ID_To_Delete#)
	</CFQUERY>

</CFIF>

<CFQUERY NAME="getActiveProducts" datasource="#application.datasource#">
SELECT     dbo.Program_Growth_Components.Program_ID, dbo.Contract_Products.Contract_Products_ID, 
                      dbo.Contract_Products.BSA_Foodservice_Items_Master_ID
FROM         dbo.Program_Growth_Components INNER JOIN
                      dbo.Contract_Products INNER JOIN
                      dbo.Program_Growth_Component_Product_Data ON 
                      dbo.Contract_Products.Contract_Products_ID = dbo.Program_Growth_Component_Product_Data.Contract_Products_ID ON 
                      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID
WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Program_Growth_Component_Product_Data.Deleted = 0) AND 
                      (dbo.Program_Growth_Components.Program_ID = '#FORM.Program_ID#') AND (dbo.Program_Growth_Components.Program_Growth_Component_ID = '#FORM.Component_ID#')

</CFQUERY>
<cfset listofactiveproducts = valuelist(getActiveProducts.BSA_Foodservice_Items_Master_ID)>
<cfset FORM.groupLevelProducts = 0 />
<cfset FORM.productGroupId = "" />
<cfif Len(FORM.Product_Level_1) GT 0>
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	<cfset groupLevelProductId = ProductGroupManager.getProductForGroupProducts(1, form.Product_Level_1) />
	<cfset form.Product_List = groupLevelProductId />
	<cfset FORM.groupLevelProducts = 1 />
	<cfset FORM.productGroupId = FORM.Product_Level_1 />
</cfif>

<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#" DELIMITERS=",">
	<CFIF listfind(listofactiveproducts,Product_ID, ",") EQ 0>
		<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
			INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Product_Group_ID, Dynamic_Static_Groups)
			VALUES
			('#Product_ID#', '#FORM.Program_ID#', 4, #ORM.groupLevelProducts#, '#FORM.productGroupId#', #form.Dynamic_Static_Groups#)
		</CFQUERY>
		
		<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Product_Data
			(Program_Growth_Component_ID, Contract_Products_ID)
			VALUES
			('#FORM.Component_ID#', '#saveContractProducts.Contract_Products_ID#')
		</CFQUERY>
	</CFIF>
</CFLOOP>

	<!------ get volume uom ----->
	<cfset programManager = CreateObject("component", "components.programs.program") />
	<cfset qProgram = programManager.getProgramInfo(Form.Program_ID) />
	
	<cfif qProgram.recordCount>
	
	 	<!------ update volume ----->
		<cfquery name="qUpdateVolume" datasource="#application.datasource#">
			UPDATE	Program_Growth_Component_Product_Data
			SET 	Program_Growth_Component_Product_Data.Weekly_Volume = 
					(
						SELECT	TOP 1 Program_Product_Volume.<cfif qProgram.Contract_Quantity_UOM_IDX EQ 1>Volume_CS<cfelse>Volume_LB</cfif>
						FROM	Program_Product_Volume
						WHERE
								Program_Product_Volume.Deleted = 0
								AND
								Program_Product_Volume.Program_ID = Program_Growth_Component_Product_Data.Program_ID
								AND
								Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					)
			FROM	Program_Growth_Component_Product_Data
					INNER JOIN	Contract_Products
					ON
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
			WHERE
					Program_Growth_Component_Product_Data.Deleted = 0
					AND
					Program_Growth_Component_Product_Data.Weekly_Volume IS NULL
					AND
					Program_Growth_Component_Product_Data.Program_ID = #Form.Program_ID#
		</cfquery>
		
	</cfif>
	
	<!---call SP to update program product volume --->
	<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Form.Program_ID#" null="no">
				   
	</cfstoredproc>

	<!---call SP to update program contract quantity --->
	<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#Form.Program_ID#" null="no">

	</cfstoredproc>

	
	<CFTRANSACTION ACTION="COMMIT">
	
</CFTRANSACTION>
<CFLOCATION URL="#CGI.HTTP_REFERER#" addtoken="No">
