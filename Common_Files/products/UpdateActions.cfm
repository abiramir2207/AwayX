<CFSWITCH EXPRESSION="#Form.Document_ID#">
	<CFCASE VALUE="CategoryMaintanence">
		 <CFIF Form.Product_Category_ID EQ 0>
		 	<cfset useLakebaseForSaveNewProductCategory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_categories")>
<cfif useLakebaseForSaveNewProductCategory>
	<cftry>
		<cfset application.oLakebase.insertRow("product_categories", {
			"category_title" = "#Form.Category_Title#",
			"category_description" = "#Form.Category_Description#",
			"company_main_id" = "#request.AccessStructure.Company_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSaveNewProductCategory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveNewProductCategory>
<CFQUERY NAME="SaveNewProductCategory" datasource="#application.datasource#" DBTYPE="ODBC">
				INSERT INTO Product_Categories
				(Category_Title, Category_Description, Company_Main_ID)
				VALUES
				('#Form.Category_Title#', '#Form.Category_Description#', '#request.AccessStructure.Company_Main_ID#')
			</CFQUERY>
</cfif>
		 
		 <CFELSE>
		 	<cfset useLakebaseForSaveCategoryChanges = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_categories")>
<cfif useLakebaseForSaveCategoryChanges>
	<cftry>
		<cfset application.oLakebase.updateRows("product_categories",
			{
				"product_category_id" = "eq.#Form.Product_Category_ID#"
			},
			{
				"category_title" = "#Form.Category_Title#",
				"category_description" = "#Form.Category_Description#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSaveCategoryChanges = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveCategoryChanges>
<CFQUERY NAME="SaveCategoryChanges" datasource="#application.datasource#" DBTYPE="ODBC">
				UPDATE Product_Categories
				SET 
						Category_Title 			= 	'#Form.Category_Title#',
						Category_Description	=	'#Form.Category_Description#'
				WHERE
						Product_Category_ID 	=	'#Form.Product_Category_ID#'  
			</CFQUERY>
</cfif>		 
		 </CFIF>
		
		<CFLOCATION URL="Product_Category_Maintenance.cfm?Product_Category_ID">
	</CFCASE>
</CFSWITCH>