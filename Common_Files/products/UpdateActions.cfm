<CFSWITCH EXPRESSION="#Form.Document_ID#">
	<CFCASE VALUE="CategoryMaintanence">
		 <CFIF Form.Product_Category_ID EQ 0>
		 	<CFQUERY NAME="SaveNewProductCategory" datasource="#application.datasource#" DBTYPE="ODBC">
				INSERT INTO Product_Categories
				(Category_Title, Category_Description, Company_Main_ID)
				VALUES
				('#Form.Category_Title#', '#Form.Category_Description#', '#request.AccessStructure.Company_Main_ID#')
			</CFQUERY>
		 
		 <CFELSE>
		 	<CFQUERY NAME="SaveCategoryChanges" datasource="#application.datasource#" DBTYPE="ODBC">
				UPDATE Product_Categories
				SET 
						Category_Title 			= 	'#Form.Category_Title#',
						Category_Description	=	'#Form.Category_Description#'
				WHERE
						Product_Category_ID 	=	'#Form.Product_Category_ID#'  
			</CFQUERY>		 
		 </CFIF>
		
		<CFLOCATION URL="Product_Category_Maintenance.cfm?Product_Category_ID">
	</CFCASE>
</CFSWITCH>