<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_opr_fixed_price_query.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			03/13/2008 - RBL

FUNCTIONALITY:
- This header include includes the query of queries for Operator Fixed Price Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->

</cfsilent>

<cfquery name="thisTag.qGetRebatePaidToProducts" datasource="#application.datasource#">
    SELECT	* 
	FROM ##TMP_Rebate_Price_Details
    WHERE Component_Paid_to IN (<cfif thisTag.stPDFBodyInfo.bOprPaysToOperator>2<cfelse>0</cfif>,<cfif thisTag.stPDFBodyInfo.bOprPaysToDistributor>1<cfelse>0</cfif>)
    ORDER BY item,Program_Rebates_Component_ID,Component_Paid_to
</cfquery>
<!--- NOTE: Rebate should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER --->							