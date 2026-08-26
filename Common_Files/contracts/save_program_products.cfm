<CFPARAM NAME="FORM.Product_List" DEFAULT="">
<CFPARAM NAME="FORM.Program_ID" DEFAULT="">
<cfabort>
<CFIF len(trim(FORM.Product_List)) EQ 0 OR len(trim(FORM.Program_ID)) EQ 0>
	<CFOUTPUT>#len(trim(FORM.Product_List))# - #len(trim(FORM.Program_ID))#</CFOUTPUT>
	<script>
		history.back()
	</script>
	<cfabort>
</CFIF>

<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>
<CFQUERY NAME="deleteCurrentProgramProducts" datasource="#application.datasource#">
	UPDATE Contract_Products
	SET Deleted = 1
	WHERE Contract_Main_ID = '#FORM.Program_ID#'
</CFQUERY>

<CFLOOP INDEX="Product_ID" LIST="#FORM.Product_List#" DELIMITERS=",">
	<CFQUERY NAME="saveContractProducts" datasource="#application.datasource#">
		INSERT INTO Contract_Products
		(BSA_Foodservice_Items_Master_ID, Contract_Main_ID)
		VALUES
		('#Product_ID#', '#FORM.Program_ID#')
	</CFQUERY>
	
	<CFQUERY NAME="InsertNewProduct" datasource="#application.datasource#">
		INSERT INTO Program_Fixed_Price_Product_Data
		(Program_ID, Contract_Products_ID)
		VALUES
		('#FORM.Program_ID#', '#saveContractProducts.Contract_Products_ID#')
	</CFQUERY>
</CFLOOP>

<CFLOCATION URL="#CGI.HTTP_REFERER#" addtoken="No">
