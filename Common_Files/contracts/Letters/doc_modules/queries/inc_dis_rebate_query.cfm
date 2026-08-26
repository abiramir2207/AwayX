<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_dis_rebate_query.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			03/13/2008- RBL

FUNCTIONALITY:
- This header include includes the query of queries for Distributor Rebate Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="thisTag.bAddcustomerproductnumbers" 	type="boolean" 	default="0">
<cfparam name="url.custprodnum" 										type="boolean" 	default="0">

</cfsilent>

<!--- IF we want customer_product_numbers AND we do NOT yet have them... --->
<cfif (thisTag.bAddcustomerproductnumbers OR url.custprodnum) AND NOT listFindNoCase(thisTag.qGetRebateProducts.columnList,"customer_product_number",",")>
	<cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
  <cfloop query="thisTag.qGetRebateProducts">
    <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>  
  </cfloop>
<cfset queryAddColumn(thisTag.qGetRebateProducts,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>              
</cfif>

<cfquery name="thisTag.qGetRebatePaidToProducts" datasource="#application.datasource#">
    SELECT	* 
	FROM ##TMP_Rebate_Price_Details
    WHERE Component_Paid_to IN (<cfif thisTag.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif thisTag.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)
    ORDER BY item,Program_Rebates_Component_ID,Component_Paid_to
</cfquery>
<!--- NOTE: Rebate should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER --->