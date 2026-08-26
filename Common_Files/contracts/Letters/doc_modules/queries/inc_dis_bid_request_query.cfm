<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_dis_bid_request_query.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			03/12/2008- RBL

FUNCTIONALITY:
- This header include includes the query of queries for Distributor Bid Request Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="thisTag.bAddcustomerproductnumbers" 	type="boolean" 	default="0">
<cfparam name="url.custprodnum" 										type="boolean" 	default="0">

</cfsilent>

<cfif NOT listFindNoCase(thisTag.qGetBidRequestProducts.columnList,"Program_Bidrequest_Component_Paid_to",",")>

	<!--- RBL added [begin] --->
  <cfset thisTag.LetterManager = application.oController.getObject("mvc.Models.LetterManager") />                       
  <cfset thisTag.aBidRequestComponentPaidTo = arrayNew(1)>
  <cfset thisTag.aBidRequestPerPound = arrayNew(1)>
  <cfset thisTag.aBidRequestPerCase = arrayNew(1)>
  <cfset thisTag.getBidRequestProductsComponentPaidto = thisTag.LetterManager.getBidRequestProducts(thisTag.qGetBidRequestProducts.contract_main_id[1])>
  
  <cfoutput query="thisTag.qGetBidRequestProducts">
  	<cfloop query="thisTag.getBidRequestProductsComponentPaidto">
    	<cfif (thisTag.qGetBidRequestProducts.BSA_FOODSERVICE_ITEMS_MASTER_ID EQ thisTag.getBidRequestProductsComponentPaidto.BSA_FOODSERVICE_ITEMS_MASTER_ID)
				AND (thisTag.qGetBidRequestProducts.UNIT_OF_MEASURE_ID EQ thisTag.getBidRequestProductsComponentPaidto.UNIT_OF_MEASURE_ID)
				AND (thisTag.qGetBidRequestProducts.PROGRAM_FIXED_COMPONENT_ID EQ thisTag.getBidRequestProductsComponentPaidto.PROGRAM_FIXED_COMPONENT_ID)>
        <cfset arrayAppend(thisTag.aBidRequestComponentPaidTo,thisTag.getBidRequestProductsComponentPaidto.Program_Bidrequest_Component_Paid_to)>
    	</cfif>
    </cfloop>
    <!--- IF UOM is cases... --->
    <cfif thisTag.qGetBidRequestProducts.UNIT_OF_MEASURE_ID EQ 1>
    	<!--- pounds --->
			<cfset arrayAppend(thisTag.aBidRequestPerPound,thisTag.qGetBidRequestProducts.bid_request_value/thisTag.qGetBidRequestProducts.net_weight)>
      <!--- cases --->
      <cfset arrayAppend(thisTag.aBidRequestPerCase,thisTag.qGetBidRequestProducts.bid_request_value)>
      <!--- IF UOM is pounds... --->
    <cfelse>
    	<!--- pounds --->
    	<cfset arrayAppend(thisTag.aBidRequestPerPound,thisTag.qGetBidRequestProducts.bid_request_value)>
      <!--- cases --->
      <cfset arrayAppend(thisTag.aBidRequestPerCase,thisTag.qGetBidRequestProducts.bid_request_value*thisTag.qGetBidRequestProducts.net_weight)>
    </cfif>
  </cfoutput>
  
  <cfset queryAddColumn(thisTag.qGetBidRequestProducts,"Program_Bidrequest_Component_Paid_to","VarChar",thisTag.aBidRequestComponentPaidTo)>
  <cfset queryAddColumn(thisTag.qGetBidRequestProducts,"bid_request_per_pound","Double",thisTag.aBidRequestPerPound)>
  <cfset queryAddColumn(thisTag.qGetBidRequestProducts,"bid_request_per_case","Double",thisTag.aBidRequestPerCase)>
  <!--- RBL added [end] --->

</cfif>

<!--- IF we want customer_product_numbers AND we do NOT yet have them... --->
<cfif (thisTag.bAddcustomerproductnumbers OR url.custprodnum) AND NOT listFindNoCase(thisTag.qGetBidRequestProducts.columnList,"customer_product_number",",")>
	<cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
  <cfloop query="thisTag.qGetBidRequestProducts">
    <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>  
  </cfloop>
<cfset queryAddColumn(thisTag.qGetBidRequestProducts,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>              
</cfif>

<cfquery name="thisTag.qGetBidRequestPaidToProducts" dbtype="query">
    SELECT 	* from thisTag.qGetBidRequestProducts
    WHERE 	0 = 0
    AND  	Program_Bidrequest_Component_Paid_to IN (<cfif thisTag.stPDFBodyInfo.bDisPaysToOperator>'2'<cfelse> '0'</cfif>,<cfif thisTag.stPDFBodyInfo.bDisPaysToDistributor>'1'<cfelse>'0'</cfif>)
    ORDER BY Program_Bidrequest_Component_Id,Program_Bidrequest_Component_Paid_to,item
</cfquery>
<!--- NOTE: Bid Request should always be in Program_Bidrequest_Component_Id,Program_Bidrequest_Component_Paid_to,item ORDER --->