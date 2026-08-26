<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/queries/inc_opr_fixed_price_query.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			03/13/2008- RBL

FUNCTIONALITY:
- This header include includes the query of queries for Operator Fixed Price Deal Letters ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->

</cfsilent>
<cfparam name="url.pages" default="0">

<cfquery name="thisTag.qGetFixedPricePaidToProducts" datasource="#application.datasource#">
    SELECT 	*
    FROM		##TMP_fixed_price_details
    WHERE 	Contract_Main_ID = '#cmid#'
    AND Fixed_Component_Paid_to IN (<cfif thisTag.stPDFBodyInfo.bOprPaysToOperator>'2'<cfelse>'0'</cfif>,<cfif thisTag.stPDFBodyInfo.bOprPaysToDistributor>'1'<cfelse>'0'</cfif>)
    AND			Fixed_Price_Num <> 0 

    <!--- If the request is for "one distributor per letter" AND the request is not for just "Operator" letters - It is either "Distributor" or "Both" letters option.
    Also, when the page is not being edited - url.pages eq 0 OR url.pages EQ "".
    --->
    <cfif thisTag.qGetLetterSettings.Distributor_Letter_Type eq 1 AND thisTag.qGetLetterSettings.Letter_Type neq 1 AND (url.pages eq 0 OR url.pages EQ "")>
	AND BSA_Foodservice_Customers_ID = '#thisTag.qProgramAllDistributorInitial.BSA_Foodservice_Customers_ID[thisTag.qProgramAllDistributorInitial.currentRow]#'
    </cfif>

    ORDER BY Program_Fixed_Component_Id,Fixed_Component_Paid_to,item
</cfquery> 
<!--- NOTE: Fixed Price should always be in Program_Fixed_Component_Id,Fixed_Component_Paid_to,item ORDER --->
     