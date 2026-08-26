<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_all_bid_request_query.cfm
CREATED: 		03/12/2007 - RBL
EDITED:			03/12/2008- RBL

FUNCTIONALITY:
- This query include includes the query of queries for all bid request...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>

<cfquery name="variables.qGetBidRequestPaidToProducts" dbtype="query">
    SELECT 	* from variables.getBidRequestProducts
    WHERE 	0 = 0
    AND  	Program_Bidrequest_Component_Paid_to IN (<cfif variables.stPDFBodyInfo.bDisPaysToOperator>'2'<cfelse> '0'</cfif>,<cfif variables.stPDFBodyInfo.bDisPaysToDistributor>'1'<cfelse>'0'</cfif>) 
</cfquery>

<!--- ACTION: 3/12/2008 I question the accuracy of the above SQL filter. What about operator? --->
      
<!--- RBL added for 2 FOB Prices 12/17/07 [begin]                      
<cfset variables.aLBFOBPrices = arrayNew(1)>
<cfset variables.aCSFOBPrices = arrayNew(1)>

<cfoutput query="variables.qGetBidRequestPaidToProducts">
  <cfquery name="variables.qGetFOBPrices" datasource="#application.datasource#">
      SELECT 		Price_List_Detail.LB_FOB_Price,Price_List_Detail.CS_FOB_Price
      FROM 			Price_List_Detail
      WHERE 		Price_List_Detail.product_id = '#trim(variables.qGetBidRequestPaidToProducts.bsa_foodservice_items_master_id)#'
      AND 			Price_List_Detail.active_code = 'A'
      AND			Price_List_Detail.deleted = 0
      ORDER BY 		Price_List_Detail.created_date DESC
  </cfquery>

  <cfif variables.qGetFOBPrices.recordCount>
    <cfset arrayAppend(variables.aLBFOBPrices,variables.qGetFOBPrices.LB_FOB_Price[1])>
    <cfset arrayAppend(variables.aCSFOBPrices,variables.qGetFOBPrices.CS_FOB_Price[1])>
  <cfelse>
    <cfset arrayAppend(variables.aLBFOBPrices,"0.00")>
    <cfset arrayAppend(variables.aCSFOBPrices,"0.00")>
  </cfif>
</cfoutput>

<cfset queryAddColumn(variables.qGetBidRequestPaidToProducts,"LB_FOB_Price","VarChar",variables.aLBFOBPrices)>
<cfset queryAddColumn(variables.qGetBidRequestPaidToProducts,"CS_FOB_Price","VarChar",variables.aCSFOBPrices)>
RBL added for 2 FOB Prices 12/17/07 [end] --->