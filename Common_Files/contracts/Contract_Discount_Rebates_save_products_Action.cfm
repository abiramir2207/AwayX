<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">

<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>

<CFQUERY NAME="getProductsToDelete" datasource="#application.datasource#">
SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.BSA_Foodservice_Items_Master_ID, 
                      dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID, dbo.Program_Rebates_Product_Data.Program_ID
FROM         dbo.Contract_Products INNER JOIN
                      dbo.Program_Rebates_Product_Data ON dbo.Contract_Products.Contract_Products_ID = dbo.Program_Rebates_Product_Data.Contract_Products_ID
WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Program_Rebates_Product_Data.Deleted = 0) AND 
                      (dbo.Program_Rebates_Product_Data.Program_ID = '#FORM.Program_ID#') <CFIF listlen(Product_List) GT 0> AND (dbo.Contract_Products.BSA_Foodservice_Items_Master_ID NOT IN(#listqualify(Product_List, "'")#))</CFIF>

</CFQUERY>
<CFSET listofitemstodelete = valuelist(getProductsToDelete.Contract_Products_ID)>
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
	
	<CFQUERY NAME="deleteCurrentProgramProductsFromFixedPriceTable" datasource="#application.datasource#">
		UPDATE Program_Rebates_Product_Data
		SET Deleted = 1
		WHERE Contract_Products_ID IN(#listofitemstodelete#)
	</CFQUERY>		
</CFIF>

<CFQUERY NAME="getActiveProducts" datasource="#application.datasource#">
SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.BSA_Foodservice_Items_Master_ID, 
                      dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID, dbo.Program_Rebates_Product_Data.Program_ID
FROM         dbo.Contract_Products INNER JOIN
                      dbo.Program_Rebates_Product_Data ON dbo.Contract_Products.Contract_Products_ID = dbo.Program_Rebates_Product_Data.Contract_Products_ID
WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Program_Rebates_Product_Data.Deleted = 0) AND 
                      (dbo.Program_Rebates_Product_Data.Program_ID = '#FORM.Program_ID#')

</CFQUERY>
<cfset listofactiveproducts = valuelist(getActiveProducts.BSA_Foodservice_Items_Master_ID)>

<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#" DELIMITERS=",">
	<CFIF listfind(listofactiveproducts,Product_ID, ",") EQ 0>
		<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
			INSERT INTO Contract_Products
			(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID)
			VALUES
			('#Product_ID#', '#FORM.Program_ID#', 2)
		</CFQUERY>
		
		<cfset useLakebaseForInsertNewProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForInsertNewProduct>
	<cftry>
		<cfset application.oLakebase.insertRow("program_rebates_product_data", {
			"program_id" = "#FORM.Program_ID#",
			"contract_products_id" = "#saveContractProducts.Contract_Products_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertNewProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertNewProduct>
<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
			INSERT INTO Program_Rebates_Product_Data
			(Program_ID, Contract_Products_ID)
			VALUES
			('#FORM.Program_ID#', '#saveContractProducts.Contract_Products_ID#')
		</CFQUERY>
</cfif>
	</CFIF>
</CFLOOP>

<cfparam name="Form.Sort_By" 	default="Description">

<CFSET thisPage=ListFirst(CGI.HTTP_REFERER,"?")>
<CFSET urlList=Mid(CGI.HTTP_REFERER,Len(thisPage)+2,Len(CGI.HTTP_REFERER)-Len(thisPage)-1)>

<CFSET fullUrl="">
<cfloop LIST=#urlList# INDEX="thisURLItem" DELIMITERS="&">
	<CFIF LISTFirst(thisURLItem,"=") NEQ "Sort_By">	
		<CFSET fullUrl=ListAppend(fullUrl, "#LISTFirst(thisURLItem,"=")#=#LISTLast(thisURLItem,"=")#","&")>
	</CFIF>
</cfloop>
<CFIF Len(fullUrl) GT 0>
	<CFSET fullUrl="#thisPage#?#fullUrl#&">
<CFELSE>
	<CFSET fullUrl="#thisPage#?">
</CFIF>


<CFLOCATION URL="#fullUrl#Sort_By=#Form.Sort_By#" addtoken="No">

<!------<CFLOCATION URL="#CGI.HTTP_REFERER#">----->
