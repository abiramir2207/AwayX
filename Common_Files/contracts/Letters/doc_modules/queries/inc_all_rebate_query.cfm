<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_all_rebate_query.cfm
CREATED: 		03/12/2007 - RBL
EDITED:			03/12/2008- RBL

FUNCTIONALITY:
- This query include includes the query of queries for all rebate...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->
</cfsilent>

<cfquery name="variables.qGetDisRebates" datasource="#application.datasource#">
    SELECT	* 
	FROM ##TMP_Rebate_Price_Details
    WHERE Component_Paid_to IN (<cfif variables.stPDFBodyInfo.bDisPaysToOperator>2<cfelse> 0</cfif>,<cfif variables.stPDFBodyInfo.bDisPaysToDistributor>1<cfelse>0</cfif>)
    ORDER BY item,Program_Rebates_Component_ID
</cfquery>

<!--- ACTION: 3/12/2008 I question the accuracy of the above SQL filter. What about operator? --->