<cfsilent>
	<!--- 
	FILE:         
	FILENAME:     doc_modules/inc_init_vars.cfm
	CREATED:         02/13/2008 - RBL
	EDITED:            03/14/2008 - RBL
	EDITED:            09/15/2010 - Milan [Add template setting to show/hide info on the letter]
	
	FUNCTIONALITY:
	- This include template represents a conversion to INITIAL state of all legacy var ingredients for Deal Letters v2...
	Essentially 7 query variables result here with the syntax: qProgram_________Initial...
	THIS TAG MUST ALWAYS FOLLOW THE inc_all_vars.cfm.
	--->
	<!--- These parameters are required for this template to process correctly --->
	<!--- na --->
	<!--- Initital Variables for Deal Letters V2 =====
	====== variable scope conversion [begin] =========
	=============[thisTag > variables]=========== --->

	<!--- 3.) Fixed Price [begin] --->
	<!--- IF we DO wish to display fixed price items at all... --->
	<cfif variables.stPDFBodyInfo.bDisplayFixedPrice>
		<!--- IF we DO wish to display fixed price letters for 'distributors=dis OR operators=opr'... --->
		<cfif evaluate('variables.stPDFBodyInfo.bDisplayFixedPrice' & variables.abbreviation)>
			<cfset variables.return_name = "qGetFixedPricePaidToProducts">
			<cfset variables.file_to_include = "queries/inc_#variables.abbreviation#_fixed_price_query.cfm">
		
			<cf_generate_convert_scope file_to_include="#variables.file_to_include#" 
			                           return_name="#variables.return_name#" 
			                           stpdfbodyinfo="#variables.stPDFBodyInfo#" 
			                           abbreviation="#variables.abbreviation#">
		
			<cfset structInsert(variables, "qProgramFixedPriceInitial", request["#variables.return_name#"], true)>
			<!--- IF we do NOT wish to display fixed price letters for 'distributors=dis OR operators=opr'...--->
		<cfelse>
			<cfset variables.qProgramFixedPriceInitial = queryNew('fixed_price,item,BSA_Foodservice_Items_Master_ID,GTIN')>
		</cfif>
	<cfelse>
		<cfset variables.qProgramFixedPriceInitial = queryNew('fixed_price,item,BSA_Foodservice_Items_Master_ID,GTIN')>
	</cfif>
	<!--- 3.) Fixed Price [end] --->
	<!--- 4.) Rebate [begin] --->
	<!--- IF we DO wish to display rebate items at all... --->
	<cfif variables.stPDFBodyInfo.bDisplayRebate>
		<!--- IF we DO wish to display rebate letters for 'distributors=dis OR operators=opr'... --->
		<cfif evaluate('variables.stPDFBodyInfo.bDisplayRebate' & variables.abbreviation)>
			<cfset variables.return_name = "qGetRebatePaidToProducts">
			<cfset variables.file_to_include = "queries/inc_#variables.abbreviation#_rebate_query.cfm">
			<cf_generate_convert_scope file_to_include="#variables.file_to_include#" 
			                           return_name="#variables.return_name#" 
			                           stpdfbodyinfo="#variables.stPDFBodyInfo#" 
			                           abbreviation="#variables.abbreviation#">
			<cfset structInsert(variables, "qProgramRebateInitial", request["#variables.return_name#"], true)>
			<!--- IF we do NOT wish to display rebate letters for 'distributors=dis OR operators=opr'... --->
		<cfelse>
			<cfset variables.qProgramRebateInitial = queryNew('rebate,item,BSA_Foodservice_Items_Master_ID,GTIN')>
		</cfif>
	<cfelse>
		<cfset variables.qProgramRebateInitial = queryNew('rebate,item,BSA_Foodservice_Items_Master_ID,GTIN')>
	</cfif>
	<!--- 4.) Rebate [end] --->

	<!--- ACTION: TO DELETE 4.) Rebate [begin]
	<cfif variables.stPDFBodyInfo.bDisplayRebate>
	    <cfset variables.return_name = "qGetRebatePaidToProducts">
	  
	    <cfif variables.stPDFBodyInfo.bDisplayRebateDis>
	        <cfset variables.file_to_include = "queries/inc_dis_rebate_query.cfm">    
	    <cfelseif variables.stPDFBodyInfo.bDisplayRebateOpr>
	        <cfset variables.file_to_include = "queries/inc_opr_rebate_query.cfm">
	    </cfif>
	  
	    <cf_generate_convert_scope file_to_include="#variables.file_to_include#" return_name="#variables.return_name#" stPDFBodyInfo="#variables.stPDFBodyInfo#">
	    <cfset structInsert(variables,"qProgramRebateInitial",request["#variables.return_name#"],true)>
	</cfif>
	 4.) Rebate [end] --->

	<!--- 5.) bid request [begin] --->
	<!--- IF we DO wish to display bid request items at all... --->
	<cfif variables.stPDFBodyInfo.bDisplayBidRequest>
		<!--- IF we DO wish to display bid request letters for 'distributors=dis OR operators=opr'... --->
		<cfif evaluate('variables.stPDFBodyInfo.bDisplayBidRequest' & variables.abbreviation)>
			<cfset variables.return_name = "qGetBidRequestPaidToProducts">
			<cfset variables.file_to_include = "queries/inc_#variables.abbreviation#_bid_request_query.cfm">
			<cf_generate_convert_scope file_to_include="#variables.file_to_include#" 
			                           return_name="#variables.return_name#" 
			                           stpdfbodyinfo="#variables.stPDFBodyInfo#">
			<cfset structInsert(variables, "qProgramBidRequestInitial", request["#variables.return_name#"], true)>
			<!--- IF we do NOT wish to display bid request letters for 'distributors=dis OR operators=opr'...--->
		<cfelse>
			<cfset variables.qProgramBidRequestInitial = queryNew('bid_request,BSA_Foodservice_Items_Master_ID')>
		</cfif>
	<cfelse>
		<cfset variables.qProgramBidRequestInitial = queryNew('bid_request,BSA_Foodservice_Items_Master_ID')>
	</cfif>
	<!--- 5.) bid request [end] --->

	<!--- ACTION: TO DELETE 5.) Bid Requests (Q: why are "Bid Requests" handled differently? RBL) 
	[begin] 
	<cfif variables.stPDFBodyInfo.bDisplayBidRequest>
	    <cfset variables.return_name = "qGetBidRequestPaidToProducts">
	  
	    <cfif variables.stPDFBodyInfo.bDisplayBidRequestDis>
	        <cfset variables.file_to_include = "queries/inc_dis_bid_request_query.cfm">
	    <cfelseif variables.stPDFBodyInfo.bDisplayBidRequestOpr>
	        <cfset variables.file_to_include = "queries/inc_opr_bid_request_query.cfm">
	    </cfif>
	  
	    <cf_generate_convert_scope file_to_include="#variables.file_to_include#" return_name="#variables.return_name#" stPDFBodyInfo="#variables.stPDFBodyInfo#">
	    <cfset  structInsert(variables,"qProgramBidRequestInitial",request["#variables.return_name#"],true)>
	</cfif>
	 5.) Bid Requests (Q: why are "Bid Requests" handled differently? RBL) [end] --->

	<!--- 6.) Lump Sum [begin] --->
	<!--- IF we DO wish to display lump sum items at all... --->
	<cfif variables.stPDFBodyInfo.bDisplayLumpSum>
		<!--- IF we DO wish to display lump sum letters for 'distributors=dis OR operators=opr'... --->
		<cfif evaluate('variables.stPDFBodyInfo.bDisplayLumpSum' & variables.abbreviation)>
			<cfquery name="variables.qProgramLumpSumInitial" datasource="#application.datasource#">
				SELECT *
				FROM		##TMP_LumpSum_Details
				WHERE 0 = 0
				<cfif variables.abbreviation EQ "dis">
					AND Component_Paid_to IN 
          (
           <cfif variables.stPDFBodyInfo.bDisPaysToOperator> 2 <cfelse> 0</cfif>,
					 <cfif variables.stPDFBodyInfo.bDisPaysToDistributor> 1 <cfelse> 0 </cfif>
					)
				<cfelse>
					AND Component_Paid_to IN 
          (
					 <cfif variables.stPDFBodyInfo.bOprPaysToOperator> 2 <cfelse> 0 </cfif>,
					 <cfif variables.stPDFBodyInfo.bOprPaysToDistributor> 1 <cfelse> 0 </cfif>
					)
				</cfif>
				
				<!--- If the request is for "one distributor per letter" and the request is not just for "operator Letters", then query to show the distributor 
				product number for a particular distributor. If the request is just for operator letters, then the temp table does not have the
				"BSA_Foodservice_Customers_ID" populated.
				--->
				<cfif getlettersettings.Distributor_Letter_Type eq 1 AND getlettersettings.Letter_Type neq 1 AND qProgramDistributorInitial.BSA_FOODSERVICE_CUSTOMERS_ID neq "">
					AND BSA_Foodservice_Customers_ID = '#qProgramDistributorInitial.BSA_FOODSERVICE_CUSTOMERS_ID#'
				</cfif>

				ORDER BY
				<!---  When Letter app setting is set to "custom 1" --->
				<!---Dev Note:30173 - "Group_Desc" will only be populated when we have product group on the program. In cases, when it is not populated,  
              the value will be null and the query will be ordered by the remaining fields in the ORDER BY clause. --->
				<cfif appSettings.getlettersavailable() eq 2>
					Group_Desc,description
				<cfelse>
					<!--- Standard Letter --->
					Program_Lump_Sum_ID,Component_Paid_to
				</cfif>
				
			</cfquery>
		
			<!--- <cfset structInsert(variables,"qProgramLumpSumInitial",variables.getlumpsums,true)> --->
			<!--- IF we do NOT wish to display bid request letters for 'distributors=dis OR operators=opr'...--->
		<cfelse>
			<cfset variables.qProgramLumpSumInitial = queryNew('lump_sum')>
		</cfif>
	<cfelse>
		<cfset variables.qProgramLumpSumInitial = queryNew('lump_sum')>
	</cfif>
	<!--- 6.) Lump Sum [end] --->
	<!--- ACTION: TO DELETE 6.) 
	<cfif variables.stPDFBodyInfo.bDisplayLumpSum AND (variables.stPDFBodyInfo.bDisplayLumpSumDis OR  variables.stPDFBodyInfo.bDisplayLumpSumOpr) >
	    <cfset structInsert(variables,"qProgramLumpSumInitial",variables.getlumpsums,true)>
	</cfif> --->
	<!--- 7.) Growth [begin] --->
	<cfif variables.stPDFBodyInfo.bDisplayGrowth>
		<!--- IF we DO wish to display growth letters for 'distributors=dis OR operators=opr'... --->
		<cfif evaluate('variables.stPDFBodyInfo.bDisplayGrowth' & variables.abbreviation)>
			<cfquery name="variables.qProgramGrowthInitial" datasource="#application.datasource#">
				SELECT *
				FROM	##TMP_Growth_Details
				WHERE 0 = 0
				<cfif variables.abbreviation EQ "dis">
					AND Component_Paid_to IN 
          (
					 <cfif variables.stPDFBodyInfo.bDisPaysToOperator> 2 <cfelse> 0 </cfif>,
					 <cfif variables.stPDFBodyInfo.bDisPaysToDistributor> 1 <cfelse> 0 </cfif>
					)
				<cfelse>
					<!--- Note: As of now (3/12/2015), the growth does not have "operator" letters and so the below code is not valid. --->
					AND Component_Paid_to IN 
          (
					 <cfif variables.stPDFBodyInfo.bOprPaysToOperator> 2  <cfelse> 0 </cfif> ,
					 <cfif variables.stPDFBodyInfo.bOprPaysToDistributor> 1 <cfelse> 0 </cfif>
					)
				</cfif>
				
				<!--- Note: As of now (3/12/2015), the growth does not have "operator" letters and so the below  comment is not completely valid. --->
				<!--- If the request is for "one distributor per letter" and the request is not just for  "operator Letters", then query to show the distributor 
				product number for a particular distributor. If the request is just for operator letters, then  the temp table does not have the
				"BSA_Foodservice_Customers_ID" populated.
				--->
				<cfif getlettersettings.Distributor_Letter_Type eq 1 AND getlettersettings.Letter_Type neq 1 AND qProgramDistributorInitial.BSA_FOODSERVICE_CUSTOMERS_ID neq "">
					AND BSA_Foodservice_Customers_ID = '#qProgramDistributorInitial.BSA_FOODSERVICE_CUSTOMERS_ID#'
				</cfif>

				ORDER BY Program_Growth_Component_ID,Component_Paid_to
			</cfquery>
		
		<cfelse>
			<cfset variables.qProgramGrowthInitial = queryNew('growth')>
		</cfif>
	<cfelse>
		<cfset variables.qProgramGrowthInitial = queryNew('growth')>
	</cfif>
	<!--- 7.) Growth end] --->

	<!--- 8.) Clauses [begin] --->
	<cfset structInsert(variables, "qProgramClauseInitial", variables.qProgramClauseInfo, true)>
	<!--- 8.) Clauses [end] --->
  
	<!--- Initital Variables for Deal Letters V2 =====
	======= variable scope conversion [end] ==========
	=============[thisTag > variables]=========== --->
</cfsilent>