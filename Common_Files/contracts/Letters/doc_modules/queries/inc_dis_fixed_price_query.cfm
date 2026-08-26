<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_dis_fixed_price_query.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			03/13/2008- RBL

FUNCTIONALITY:
- This header include includes the query of queries for Distributor Fixed Price Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="thisTag.bAddcustomerproductnumbers" 	type="boolean" 	default="0">
<cfparam name="url.custprodnum" 										type="boolean" 	default="0">

</cfsilent>

<!--- IF we want customer_product_numbers AND we do NOT yet have them... --->
<cfif (thisTag.bAddcustomerproductnumbers OR url.custprodnum) AND NOT listFindNoCase(thisTag.qGetFixedPriceProducts.columnList,"customer_product_number",",")>
	<cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
  <cfloop query="thisTag.qGetFixedPriceProducts">
    <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>  
  </cfloop>
<cfset queryAddColumn(thisTag.qGetFixedPriceProducts,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>              
</cfif>

<cfquery name="thisTag.qGetFixedPricePaidToProducts" datasource="#application.datasource#">
    SELECT 	*
    FROM		##TMP_Fixed_Price_Details
    WHERE 	Fixed_Component_Paid_to IN (<cfif thisTag.stPDFBodyInfo.bDisPaysToOperator>'2'<cfelse>'0'</cfif>,<cfif thisTag.stPDFBodyInfo.bDisPaysToDistributor>'1'<cfelse>'0'</cfif>)
    AND			Fixed_Price_Num <> 0
      
      <!--- This is when customer_product_number needs to be shown. "thisTag.qGetLetterSettings" and "thisTag.qProgramDistributorInitial" 
            is set in "generate_convert_scope.cfm" 
      --->
      <cfif thisTag.qGetLetterSettings.Distributor_Letter_Type eq 1>
	AND BSA_Foodservice_Customers_ID = '#thisTag.qProgramDistributorInitial.BSA_Foodservice_Customers_ID[thisTag.qProgramDistributorInitial.currentRow]#'
      </cfif>

    ORDER BY Program_Fixed_Component_Id,Fixed_Component_Paid_to,item
</cfquery>
<!--- NOTE: Fixed Price should always be in Program_Fixed_Component_Id,Fixed_Component_Paid_to,item ORDER --->