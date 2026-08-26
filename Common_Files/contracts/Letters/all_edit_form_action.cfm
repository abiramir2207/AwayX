<cfoutput>


<!---
FILE: 		all_edit_form_action.cfm
FILENAME:   all_edit_form.action.cfm
CREATED: 	12/15/2007 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]


FUNCTIONALITY:
- 	This CF8 custom tag triggers the cvreation of revised html, pdf, xml files.
--->

<!--- let's put the pieces of our puzzle together...--->
<!--- the cfform submitted datagrid will only show changes from last state in a structure of arrays... --->

<cfinclude template="include_display_letters.cfm">

<cfif isDefined("form.edit")>

	<!--- I.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <cfdump var="#form.dgDistributorInfo.bDisplayDistributor#" label="1A DISTRIBUTOR FORM form.dgDistributorInfo.bDisplayDistributor" expand="no"><br />
  <cfdump var="#form.dgDistributorInfo.original.bDisplayDistributor#" label="1B DISTRIBUTOR FORM form.dgDistributorInfo.original.bDisplayDistributor" expand="no"><br />
  <cfdump var="#form.dgDistributorInfo.contract_distributors_id#" label="1C DISTRIBUTOR FORM form.dgDistributorInfo.contract_distributors_id" expand="no"><br />
  <cfdump var="#form.dgOperatorInfo.bDisplayOperator#" label="2A OPERATOR FORM form.dgOperatorInfo.bDisplayOperator" expand="no"><br />
  <cfdump var="#form.dgOperatorInfo.original.bDisplayOperator#" label="2B OPERATOR FORM form.dgOperatorInfo.original.bDisplayOperator" expand="no"><br />
  <cfdump var="#form.dgOperatorInfo.operator_id#" label="2C OPERATOR FORM form.dgOperatorInfo.operator_id" expand="no"><br />
  <cfdump var="#form.dgFixedPriceInfo.bDisplayFixedPriceProduct#" label="3A FIXED PRICE FORM form.dgFixedPriceInfo.bDisplayFixedPriceProduct" expand="no"><br />
  <cfdump var="#form.dgFixedPriceInfo.original.bDisplayFixedPriceProduct#" label="3B FIXED PRICE FORM form.dgFixedPriceInfo.original.bDisplayFixedPriceProduct" expand="no"><br />
  <cfdump var="#form.dgFixedPriceInfo.item#" label="3C FIXED PRICE FORM form.dgFixedPriceInfo.item" expand="no"><br />
  <cfdump var="#form.dgFixedPriceInfo.bsa_id_uom_comp_id#" label="3D FIXED PRICE FORM form.dgFixedPriceInfo.bsa_id_uom_comp_id" expand="no"><br />
	<cfdump var="#form.dgFixedPriceInfo.customer_product_number#" label="3E FIXED PRICE FORM form.dgFixedPriceInfo.customer_product_number" expand="no"><br />
  <cfdump var="#form.dgRebateInfo.bDisplayRebateProduct#" label="4A REBATE FORM form.dgRebateInfo.bDisplayRebateProduct" expand="no"><br />
  <cfdump var="#form.dgRebateInfo.original.bDisplayRebateProduct#" label="4B REBATE FORM form.dgRebateInfo.original.bDisplayRebateProduct" expand="no"><br />
  <cfdump var="#form.dgRebateInfo.item#" label="4C REBATE FORM form.dgRebateInfo.item" expand="no"><br />
  <cfdump var="#form.dgRebateInfo.bsa_id_uom_comp_id#" label="4D REBATE FORM form.dgRebateInfo.bsa_id_uom_comp_id" expand="no"><br />
	<cfdump var="#form.dgRebateInfo.customer_product_number#" label="4E REBATE FORM form.dgRebateInfo.customer_product_number" expand="no"><br />
  <!--- 5.) BidRequest Deprecated <cfdump var="#form.dgBidRequestInfo.bDisplayBidRequestProduct#" label="5A BID REQUEST FORM form.dgBidRequestInfo.bDisplayBidRequestProduct"><br /> NA
  <cfdump var="#form.dgBidRequestInfo.item#" label="5B BID REQUEST FORM form.dgBidRequestInfo.item"><br /> NA
	<cfdump var="#form.dgBidRequestInfo.bsa_id_uom_comp_id#" label="5C BID REQUEST FORM form.dgBidRequestInfo.bsa_id_uom_comp_id"><br /> NA
	<cfdump var="#form.dgBidRequestInfo.customer_product_number#" label="5D BID REQUEST FORM form.dgBidRequestInfo.customer_product_number"><br /> NA --->
  <cfdump var="#form.dgLumpSumInfo.bDisplayLumpSum#" label="6A LUMP SUM FORM form.dgLumpSumInfo.bDisplayLumpSum" expand="no"><br />
  <cfdump var="#form.dgLumpSumInfo.original.bDisplayLumpSum#" label="6B LUMP SUM FORM form.dgLumpSumInfo.original.bDisplayLumpSum" expand="no"><br />
  <cfdump var="#form.dgLumpSumInfo.program_lump_sum_id#" label="6C LUMP SUM FORM form.dgLumpSumInfo.program_lump_sum_id" expand="no"><br />
  <!--- 7.) Growth On Deck --->
  <cfdump var="#form.dgClauseInfo.bDisplayClause#" label="8A CLAUSE form.dgClauseInfo.bDisplayClause FORM" expand="no"><br />
  <cfdump var="#form.dgClauseInfo.original.bDisplayClause#" label="8B CLAUSE form.dgClauseInfo.original.bDisplayClause FORM" expand="no"><br />
  <cfdump var="#form.dgClauseInfo.clause_library_id#" label="8C CLAUSE form.dgClauseInfo.clause_library_id FORM" expand="no"><br />
  ///////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->
  
  <cfparam name="form.bAddcustomerproductnumbers"		type="boolean" 	default="0">
  
  <cfparam name="form.bLetterDisplayFreight"				type="boolean" 	default="0">
  <cfparam name="form.customerFreightUom"				type="string" 	default="">
  
  <cfparam name="form.bIncludeVolumePage"				type="boolean" 	default="0">
  <cfparam name="form.bInsertWatermark"					type="boolean" 	default="0">
  <cfparam name="form.consignee"						type="string"	default="">
  <cfparam name="form.distributor_name"					type="string"	default="All #application.returned_customer_setting.distributor_label_plural#">
  <cfparam name="form.operator_name"					type="string"	default="All #application.returned_customer_setting.operator_label_plural#">
  <cfparam name="form.prior_program_letter_id" 				type="numeric" 	default="0">
  <cfparam name="form.program_id" 							type="numeric" 	default="0">
  <cfparam name="form.relative_path"						type="string"	default="">
  <cfparam name="form.reviewed" 							type="boolean" 	default="0">
  <cfparam name="form.revised_doc_title"					type="string" 	default="">
  <cfparam name="form.pages_to_delete_from_prior_letter"	type="string" 	default="">
  <cfparam name="form.pages_to_delete_from_this_letter"		type="string" 	default="">
  <cfparam name="form.distributor_id"				type="string"	default="">
  
  <!--- initial XML file for THIS LETTER Pre Current Edits being requested now... --->
  <cfparam name="form.xml_fileName_relativeURL"				type="string"	default="">
	
	<cfset url.cmid = form.program_id>
	<cfset variables.CSL_Contract_Main_ID = form.program_id>

  <!--- The Deal Letters V2 ALWAYS Starts with the original data... --->
	<cfinclude template="doc_modules/inc_all_vars.cfm">

  <cfif findNoCase("dist",form.relative_path,1)>
		<cfset variables.abbreviation = "dis">
	<cfelseif findNoCase("oper",form.relative_path,1)>
    <cfset variables.abbreviation = "opr">
  <cfelse>
    <!--- none on purpose... --->
  </cfif>
  
  <!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
  <cfinclude template="doc_modules/inc_init_vars.cfm">
  <!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
  <!--- Dev Note: KAL; D15961: Add Claim Rates to PDF Letters --->
  <cfparam name="variables.qProgramClaimRates"			type="query" 	default="#queryNew('Claim_Rates')#">
  <!--- End Note: KAL; D15961: Add Claim Rates to PDF Letters --->
  <!--- alpha order The Magnificent 7 --->
  <cfparam name="variables.qProgramBidRequestInitial"	type="query" 	default="#queryNew('Bid_Request')#">
  <cfparam name="variables.qProgramClauseInitial"		type="query" 	default="#queryNew('Clause')#">
  <cfparam name="variables.qProgramDistributorInitial"	type="query" 	default="#queryNew('Distributor')#">
  <cfparam name="variables.qProgramFixedPriceInitial"	type="query" 	default="#queryNew('Fixed_Price')#">
  <cfparam name="variables.qProgramLumpSumInitial"		type="query" 	default="#queryNew('Lump_Sum')#">
  <cfparam name="variables.qProgramOperatorInitial"		type="query" 	default="#queryNew('Operator')#">
  <cfparam name="variables.qProgramRebateInitial"		type="query" 	default="#queryNew('Rebate')#">
  
  <!--- II.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <!--- output order The Magnificent 7 --->
  <cfdump var="#variables.qProgramDistributorInitial#" label="variables.qProgramDistributorInitial ALL EDIT FORM ACTION">
  <cfdump var="#variables.qProgramOperatorInitial#" label="variables.qProgramOperatorInitial ALL EDIT FORM ACTION">
  <cfdump var="#variables.qProgramFixedPriceInitial#" label="variables.qProgramFixedPriceInitial ALL EDIT FORM ACTION">
  <cfdump var="#variables.qProgramRebateInitial#" label="variables.qProgramRebateInitial ALL EDIT FORM ACTION">
  <!---
  <cfdump var="#variables.qProgramBidRequestInitial#" label="variables.qProgramBidRequestInitial ALL EDIT FORM ACTION">
	--->
  <!--- Note: 7.) Growth On Deck --->
  <cfdump var="#variables.qProgramLumpSumInitial#" label="variables.qProgramLumpSumInitial ALL EDIT FORM ACTION">
  <cfdump var="#variables.qProgramClauseInitial#" label="variables.qProgramClauseInitial ALL EDIT FORM ACTION">
  <cfabort>
	////////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->


<cfset objProgramClaimRatesReport = CreateObject("component", "components.programs.ProgramClaimRatesReport").init() />

<cfset bShowClaimRateDate = objProgramClaimRatesReport.IsClaimRatesAvailableOnProgram(url.cmid)>

	<!--- XXXXXXXXXX Get info for/from XML Doc [begin] XXXXXXXXXX --->

	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXX ACTION: We are now [3/20/08] reading and writing the XML to & from the DB instead of a written file. XXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	KEEP THIS [begin]
	<!--- /// XML X Ref [begin] /// --->
	<cfxml casesensitive="no" variable="xProgramXML">
  	<!--- Let's examine our original XML file --->
		<cfinclude template="#form.xml_fileName_relativeURL#">
	</cfxml>
	KEEP THIS [end]
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXX ACTION: We are now [3/20/08] reading and writing the XML to & from the DB instead of a written file. XXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

	<!--- X1.) Let's grab our XML data typed variable representing THIS letter's DNA from STARTING Letter ... --->
    
	<!--- D16774 8/14/08 [begin]
    <cfquery name="thisTag.qGetXML" datasource="#application.datasource#">
        SELECT	Letter_xml
        FROM	Program_Letters
        WHERE 	Program_Letters.Program_Letters_ID = #form.prior_program_letter_id#
    </cfquery>
    --->
    <cfset thisTag.xInitialProgramLetterXML = application.oLetterManager.getLetterXML(form.prior_program_letter_id)>
    <!--- D16774 8/14/08 [end] --->
  
  
  <!--- X2.) Let's parse our XML variable with which to generate our initial edit form for THIS letter... --->
  <cfset xProgramXML = xmlParse(thisTag.xInitialProgramLetterXML)>

	<!--- X3.) Include our XML script to evaluate THIS letter's DNA via xmlSearch() --->
  <cfinclude template="inc_xml_script.cfm">	

	<!--- XXXXXXXXXX Get info for/from XML Doc [end] XXXXXXXXXX --->

	<!--- III.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <cfdump var="#lsDistributorIDsFromXML#" expand="no">1 DISTRIBUTOR List Comparing Initial Query to XML for THIS Letter [SAME Only If Initial Letter]<br />
  <cfdump var="#lsOperatorIDsFromXML#" expand="no">2 OPERATOR List Comparing Initial Query to XML for THIS Letter [SAME Only If Initial Letter]<br />
  <cfdump var="#lsFixedPriceProductIDUOMCOMPsFromXML#" expand="no">3 FIXED PRICE List Comparing Initial Query to XML for THIS Letter [SAME Only If Initial Letter]<br />
  <cfdump var="#lsRebateProductIDUOMCOMPsFromXML#" expand="no">4 REBATE List Comparing Initial Query to XML for THIS Letter [SAME Only If Initial Letter]<br />
  <!--- 5.) Bid Request Deprecated <cfdump var="#lsBidRequestProductIDUOMCOMPsFromXML#">5 BID REQUEST List Comparing Initial Query to XML for THIS Letter [SAME If Initial Letter]<br /> NA --->
  <cfdump var="#lsLumpSumIDsFromXML#" expand="no">6 LUMP SUM List Comparing Initial Query to XML for THIS Letter [SAME Only If Initial Letter]<br />
  <!--- 7.) Note: Growth On Deck --->
  <cfdump var="#lsClauseIDsFromXML#" expand="no">8 CLAUSE List Comparing Initial Query to XML for THIS Letter [SAME Only If Initial Letter]<br />
	////////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->

	<!--- 1.) INITIAL LIST FROM XML - IF are starting with some 'Distributors'... [begin] --->
  <cfif isDefined('variables.qProgramDistributorInitial') AND variables.qProgramDistributorInitial.recordCount>
		<!--- distributor [begin] --->
    <cfquery name="variables.qProgramDistributorPostXML"  datasource="#application.datasource#">
      SELECT 	*
      FROM 	##TMP_qProgramDistributorInfo
      WHERE 	0=0
      <!--- If THIS letter is per distributor... --->
      <cfif listLen(trim(lsDistributorIDsByLetterFromXML),",") EQ 1>
        <!--- IMPORTANT: 'numeric' id compared to list from XML above --->
        AND contract_distributors_id IN (#lsDistributorIDsByLetterFromXML#)
      <cfelse>
        <!--- IMPORTANT: 'numeric' id compared to list from XML above --->
        AND contract_distributors_id IN (#lsDistributorIDsFromXML#)
      </cfif>
    </cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramDistributorPostXML",variables.qProgramDistributorInitial,true)>  
  </cfif>
  <!--- 1.) INITIAL LIST FROM XML - IF are starting with some 'Distributors'... [end] --->

  <!--- 2.) INITIAL LIST FROM XML - IF we are starting with some 'Operators'... [begin] --->
  <cfif isDefined('variables.qProgramOperatorInitial') AND variables.qProgramOperatorInitial.recordCount>
		<!--- operator [begin] --->
    <cfquery name="variables.qProgramOperatorPostXML" datasource="#application.datasource#">
      SELECT 	*
      <!--- ORIGINAL query from above --->
      FROM 	##TMP_qProgramOperatorInfo
      WHERE 	0=0
      <!--- If THIS letter is per operator... --->
      <cfif listLen(trim(lsOperatorIDsByLetterFromXML),",") EQ 1>
        <!--- IMPORTANT: 'numeric' id compared to list from XML above --->
        AND operator_id IN (#lsOperatorIDsByLetterFromXML#)
      <cfelse>
      	<!--- IMPORTANT: 'numeric' id compared to list from XML above --->
      	AND operator_id IN (#lsOperatorIDsFromXML#)
			</cfif>
    </cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramOperatorPostXML",variables.qProgramOperatorInitial,true)>  
  </cfif>
  <!--- 2.) INITIAL LIST FROM XML - IF we are starting with some 'Operators'... [end] --->
	
  <!--- 3.) INITIAL LIST FROM XML - IF we want to SHOW 'Fixed Price' AND we are starting with some 'Fixed Price' products... [begin] --->
	<cfif isDefined('variables.qProgramFixedPriceInitial') AND variables.stPDFBodyInfo.bDisplayFixedPrice AND variables.qProgramFixedPriceInitial.recordCount>
  	<!--- Starting Point = APPEND customer_product_number FIRST [if we don't have], then we'll make mods below... --->
		<cfif isDefined("form.lsPreFormFixedPriceCustomerProductNumbers") AND NOT listFindNoCase(variables.qProgramFixedPriceInitial.columnList,"customer_product_number",",")>
    	<!--- same length --->
      <cfset variables.aFixedPriceCustomerProductNumbers = listToArray(form.lsPreFormFixedPriceCustomerProductNumbers,",")>
      <cfset queryAddColumn(variables.qProgramFixedPriceInitial,"customer_product_number","VarChar",variables.aFixedPriceCustomerProductNumbers)>
    </cfif>
    <!--- fixed price [begin] --->
    <cfquery name="variables.qProgramFixedPricePostXML" datasource="#application.datasource#">
      SELECT *
      <!--- ORIGINAL query from above --->
			FROM 		##TMP_Fixed_Price_Details
			WHERE 	0=0
      <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
      AND BSA_Foodservice_Items_Master_ID+'_'
      <!--- Dev Note: Milan (24785). For some reason, without using the exact length of abbreviation, the query did not return any records.
      I was testing on "LBS" Abbreviation 
      --->
      +
      case len(abbreviation)
        when 1 Then
	cast(abbreviation as varchar(1))
	when 2 Then
	cast(abbreviation as varchar(2))
      	when 3 Then
	cast(abbreviation as varchar(3))
     end

      +'_'+CAST(Program_Fixed_Component_ID AS VARCHAR) IN  (#replace(listQualify(lsFixedPriceProductIDUOMCOMPsFromXML,"'",",")," ","","ALL")#)
      <!--- Earlier "query of query" was being used. I copied the ORDER BY from "inc_dis_fixed_price_query.cfm"/"inc_opr_fixed_price_query.cfm". --->
      ORDER BY Program_Fixed_Component_Id,Fixed_Component_Paid_to,item
    </cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramFixedPricePostXML",variables.qProgramFixedPriceInitial,true)>   
	</cfif>
  <!--- 3.) INITIAL LIST FROM XML - IF we want to SHOW 'Fixed Price' AND we are starting with some 'Fixed Price' products... [end] --->

	<!--- 4.) INITIAL LIST FROM XML - IF we want to SHOW 'Rebate' AND we are starting with some 'Rebate' products... [begin] --->
	<cfif isDefined('variables.qProgramRebateInitial') AND variables.stPDFBodyInfo.bDisplayRebate AND variables.qProgramRebateInitial.recordCount>
  	<!--- Starting Point = APPEND customer_product_number FIRST [If we don't have], then we'll make mods below... --->
		<cfif isDefined("form.lsPreFormRebateCustomerProductNumbers") AND NOT listFindNoCase(variables.qProgramRebateInitial.columnList,"customer_product_number",",")>
      <cfset variables.aRebateCustomerProductNumbers = listToArray(form.lsPreFormRebateCustomerProductNumbers,",")>
      <cfset queryAddColumn(variables.qProgramRebateInitial,"customer_product_number","VarChar",variables.aRebateCustomerProductNumbers)>
    </cfif>
	<!--- rebate [begin] --->
	<cfquery name="variables.qProgramRebatePostXML" datasource="#application.datasource#">
			SELECT 	*
      <!--- ORIGINAL query from above --->
			FROM 		##TMP_Rebate_Price_Details
      WHERE 	0=0
			<!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
      AND BSA_Foodservice_Items_Master_ID+'_'      
      <!--- Dev Note: Milan (24785). For some reason, without using the exact length of abbreviation, the query did not return any records.
      I was testing on "LBS" Abbreviation 
      --->
      +
      case len(abbreviation)
	when 1 Then
	cast(abbreviation as varchar(1))
	when 2 Then
	cast(abbreviation as varchar(2))
	when 3 Then
	cast(abbreviation as varchar(3))
     end
      +'_'+CAST(Program_Rebates_Component_ID AS VARCHAR) IN  (#replace(listQualify(lsRebateProductIDUOMCOMPsFromXML,"'",",")," ","","ALL")#)
       <!--- Earlier "query of query" was being used. I copied the ORDER BY from "inc_dis_rebate_query.cfm"/"inc_opr_rebate_query.cfm". 
             Note: Rebate should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER 
        --->
      ORDER BY item,Program_Rebates_Component_ID,Component_Paid_to
	</cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramRebatePostXML",variables.qProgramRebateInitial,true)>   
	</cfif>
  <!--- 4.) INITIAL LIST FROM XML - IF we want to SHOW 'Rebate' AND we are starting with some 'Rebate' products... [end] --->

   <!--- Comment this block. ProgramBidRequest is no longer used [begin] --->
   <!---
	<!--- 5.) INITIAL LIST FROM XML - IF we want to SHOW 'Bid Request' AND we are starting with some 'Bid Request' products... [begin] --->
	<cfif isDefined('variables.qProgramBidRequestInitial') AND variables.stPDFBodyInfo.bDisplayBidRequest AND variables.qProgramBidRequestInitial.recordCount>

  	<!--- Starting Point = APPEND customer_product_number FIRST [If we don't have], then we'll make mods below... --->
	<cfif isDefined("form.lsPreFormBidRequestCustomerProductNumbers") AND NOT listFindNoCase(variables.qProgramBidRequestInitial.columnList,"customer_product_number",",")>
	      <cfset variables.aBidRequestCustomerProductNumbers = listToArray(form.lsPreFormBidRequestCustomerProductNumbers,",")>
	      <cfset queryAddColumn(variables.qProgramBidRequestInitial,"customer_product_number","VarChar",variables.aBidRequestCustomerProductNumbers)>
	</cfif>
		<!--- bid request [begin] --->
		<cfquery name="variables.qProgramBidRequestPostXML" dbtype="query">
			SELECT 	*
      <!--- ORIGINAL query from above --->
			FROM 		variables.qProgramBidRequestInitial
			WHERE 	0=0
      <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
      AND BSA_Foodservice_Items_Master_ID+'_'+abbreviation+'_'+CAST(Program_BidRequest_Component_ID AS VARCHAR) IN  (#replace(listQualify(lsBidRequestProductIDUOMCOMPsFromXML,"'",",")," ","","ALL")#)
		</cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramBidRequestPostXML",variables.qProgramBidRequestInitial,true)>     
	</cfif>
  <!--- 5.) INITIAL LIST FROM XML - IF we want to SHOW 'Bid Request' AND we are starting with some 'Bid Request' products... [end] --->
  --->
  <!--- Comment this block. ProgramBidRequest is no longer used [end] --->

	<!--- 6.) INITIAL LIST FROM XML - IF we want to SHOW 'Lump Sum' AND we are starting with some 'Lump Sum' products... [begin] --->
	<cfif variables.stPDFBodyInfo.bDisplayLumpSum AND variables.qProgramLumpSumInitial.recordCount>

	 <!--- Starting Point = APPEND customer_product_number FIRST [If we don't have], then we'll make mods below... --->
	<cfif isDefined("form.lsPreFormLumpsumCustomerProductNumbers") AND NOT listFindNoCase(variables.qProgramLumpSumInitial.columnList,"customer_product_number",",")>
	      <cfset variables.aLumpsumCustomerProductNumbers = listToArray(form.lsPreFormLumpsumCustomerProductNumbers,",")>
	      <cfset queryAddColumn(variables.qProgramLumpSumInitial,"customer_product_number","VarChar",variables.aLumpsumCustomerProductNumbers)>
	</cfif>

		<!--- lump sum [begin] --->
		<cfquery name="variables.qProgramLumpSumPostXML" datasource="#application.datasource#">
			SELECT 	*
      <!--- ORIGINAL query from above --->
			FROM 		##TMP_LumpSum_Details
			WHERE 	0=0
			<!--- IMPORTANT: 'string' id compared to list from XML above --->
			<!--- When we do not have products for the lumpsum component in the lumpsum --->
			<cfif Left(lsLumpSumIDsFromXML,1) eq "_">
			AND '_'+program_lump_sum_id IN (#listQualify(lsLumpSumIDsFromXML,"'",",")#)
			<cfelse>
			<!--- When we have products for the lumpsum component in the lumpsum --->
			AND BSA_Foodservice_Items_Master_ID+'_'+program_lump_sum_id IN (#listQualify(lsLumpSumIDsFromXML,"'",",")#)
			</cfif>
			ORDER BY Program_Lump_Sum_ID,Component_Paid_to
		</cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramLumpSumPostXML",variables.qProgramLumpSumInitial,true)>  
	</cfif>
  <!--- 6.) INITIAL LIST FROM XML - IF we want to SHOW 'Lump Sum' AND we are starting with some 'Lump Sum' products... [end] --->
	
  <!--- 7.) INITIAL LIST FROM XML - 'Growth' On Deck --->
  
    <!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
	<!--- 8.) INITIAL LIST FROM XML - IF we are starting with some 'Clauses'... [begin] --->
	<cfif variables.qProgramClauseInitial.recordCount>
		<!--- clauses [begin] --->
		<cfquery name="variables.qProgramClausePostXML" dbtype="query">
			SELECT 	*
      <!--- ORIGINAL query from above --->
			FROM 		variables.qProgramClauseInitial
			WHERE 	0=0
			<!--- IMPORTANT: 'numeric' id compared to list from XML above --->
			AND clause_library_id IN (#lsClauseIDsFromXML#)
		</cfquery>
  <cfelse>  
  	<cfset structInsert(variables,"qProgramClausePostXML",variables.qProgramClauseInitial,true)>  
	</cfif>
  <!--- 8.) INITIAL LIST FROM XML - IF we are starting with some 'Clauses'... [end] --->
  TEMPORARILY COMMENT OUT CLAUSE [end] --->
  
	<!--- /// XML X Ref [end] /// --->
  
  <!--- IV.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <cfdump var="#variables.qProgramDistributorPostXML#" label="1 DISTRIBUTOR NET variables.qProgramDistributorPostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]" expand="no">
  <cfdump var="#variables.qProgramOperatorPostXML#" label="2 OPERATOR NET variables.qProgramOperatorPostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]" expand="no">
  <cfdump var="#variables.qProgramFixedPricePostXML#" label="3 FIXED PRICE NET variables.qProgramFixedPricePostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]" expand="no">
  <cfdump var="#variables.qProgramRebatePostXML#" label="4 REBATE NET variables.qProgramRebatePostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]" expand="no">
  <!---
	<cfdump var="#variables.qProgramBidRequestPostXML#" label="5 BID REQUEST NET variables.qProgramBidRequestPostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]"> NA
	--->
  <cfdump var="#variables.qProgramLumpSumPostXML#" label="6 LUMP SUM NET variables.qProgramLumpSumPostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]" expand="no">
  <!--- Note: 7.) Growth On Deck --->
  <cfdump var="#variables.qProgramClausePostXML#" label="8 CLAUSE NET variables.qProgramClausePostXML [SAME If Initial Letter, DIFFERENT IF Edited @ Least 1x]" expand="no">
	////////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->
  
  <!--- ====================================================================
	============ OK... let's reinvent ourselves NOW... [begin] ===============
	======================================================================--->
  
  <!--- IF we are editing a PRE-edited letter, we need this info from it! [begin] --->
  <cfparam name="form.lsPreFormDisplayDistributorOn" 		type="string" default="">
  <cfparam name="form.lsPreFormDisplayDistributorOff" 		type="string" default="">
  <cfparam name="form.lsPreFormDisplayOperatorOn" 			type="string" default="">
  <cfparam name="form.lsPreFormDisplayOperatorOff" 			type="string" default="">
  <cfparam name="form.lsPreFormDisplayFixedPriceOn" 		type="string" default="">
  <cfparam name="form.lsPreFormDisplayFixedPriceOff" 		type="string" default="">
  <cfparam name="form.lsPreFormDisplayRebateOn" 			type="string" default="">
  <cfparam name="form.lsPreFormDisplayRebateOff" 			type="string" default="">
  <cfparam name="form.lsPreFormDisplayBidRequestOn" 		type="string" default="">
  <cfparam name="form.lsPreFormDisplayBidRequestOff" 		type="string" default="">
  <cfparam name="form.lsPreFormDisplayLumpSumOn" 			type="string" default="">
  <cfparam name="form.lsPreFormDisplayLumpSumOff" 			type="string" default="">
  <!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
  <cfparam name="form.lsPreFormDisplayClauseOn" 			type="string" default="">
  <cfparam name="form.lsPreFormDisplayClauseOff" 			type="string" default="">
  TEMPORARILY COMMENT OUT CLAUSE [end] --->
  
		<!--- Let's default customer_product_numbers if environment calls for them... [begin] --->
    <cfif form.bAddcustomerproductnumbers>
      <cfparam name="form.lsPreFormFixedPriceCustomerProductNumbers" 	type="string" default="">
      <cfparam name="form.lsPreFormRebateCustomerProductNumbers" 		type="string" default="">
      <cfparam name="form.lsPreFormBidRequestCustomerProductNumbers" 	type="string" default="">
    </cfif>
    <!--- Let's default customer_product_numbers if environment calls for them... [end] --->
  
  <!--- IF we are editing a PRE-edited letter, we need this info from it! [end] --->

	<!--- TESTING KEEP [begin]
  <cfdump var="#form.lsPreFormDisplayDistributorOn#" 	label="form.lsPreFormDisplayDistributorOn">
  <cfdump var="#form.lsPreFormDisplayDistributorOff#" label="form.lsPreFormDisplayDistributorOff">
  <cfdump var="#form.lsPreFormDisplayOperatorOn#" 		label="form.lsPreFormDisplayOperatorOn">
  <cfdump var="#form.lsPreFormDisplayOperatorOff#" 		label="form.lsPreFormDisplayOperatorOff">
  <cfdump var="#form.lsPreFormDisplayFixedPriceOn#" 	label="form.lsPreFormDisplayFixedPriceOn">
  <cfdump var="#form.lsPreFormDisplayFixedPriceOff#" 	label="form.lsPreFormDisplayFixedPriceOff">
  <cfdump var="#form.lsPreFormDisplayRebateOn#" 			label="form.lsPreFormDisplayRebateOn">
  <cfdump var="#form.lsPreFormDisplayRebateOff#" 			label="form.lsPreFormDisplayRebateOff">
  <!---
	<cfdump var="#form.lsPreFormDisplayBidRequestOn#" 		label="form.lsPreFormDisplayBidRequestOn">
  <cfdump var="#form.lsPreFormDisplayBidRequestOff#" 	label="form.lsPreFormDisplayBidRequestOff">
	--->
  <cfdump var="#form.lsPreFormDisplayLumpSumOn#" 			label="form.lsPreFormDisplayLumpSumOn">
  <cfdump var="#form.lsPreFormDisplayLumpSumOff#" 		label="form.lsPreFormDisplayLumpSumOff">
  <cfdump var="#form.lsPreFormDisplayClauseOn#" 			label="form.lsPreFormDisplayClauseOn">
  <cfdump var="#form.lsPreFormDisplayClauseOff#" 			label="form.lsPreFormDisplayClauseOff">
  TESTING KEEP [end] --->

  <!--- 1.) FROM FORM - Distributor... [begin] --->
	<cfif structKeyExists(form,"dgDistributorInfo.bDisplayDistributor") AND structkeyExists(form,"dgDistributorInfo.contract_distributors_id")>
		<cfif isArray(form.dgDistributorInfo.bDisplayDistributor) AND isArray(form.dgDistributorInfo.contract_distributors_id)>
			<cfif arrayLen(form.dgDistributorInfo.bDisplayDistributor) AND arrayLen(form.dgDistributorInfo.contract_distributors_id)>
      	<!--- IF we have current edit requests for DISTRIBUTOR from the form to get to this point,
				then we need to coordinate our final lists of On and Off AT THIS POINT... --->
				<cfset variables.lsPostFormDisplayDistributorOn	= "">
				<cfset variables.lsPostFormDisplayDistributorOff = "">
				<cfloop from="1" to="#arrayLen(form.dgDistributorInfo.contract_distributors_id)#" index="current_distributor">
					<cfif isDefined("form.dgDistributorInfo.bDisplayDistributor")>
          	<!--- CH CH CH CHanges... If user DEselects a row that WAS selected prior... --->
          	<cfif form.dgDistributorInfo.bDisplayDistributor[current_distributor] EQ "false" AND form.dgDistributorInfo.ORIGINAL.bDisplayDistributor[current_distributor]>
                <cfset variables.lsPostFormDisplayDistributorOff = listAppend(variables.lsPostFormDisplayDistributorOff,trim(form.dgDistributorInfo.contract_distributors_id[current_distributor]),",")> 
						<!--- CH CH CH CHanges... If user SELECTS a row that was NOT selected prior... --->
						<cfelseif form.dgDistributorInfo.bDisplayDistributor[current_distributor] EQ "true" AND NOT form.dgDistributorInfo.ORIGINAL.bDisplayDistributor[current_distributor]>
              <cfset variables.lsPostFormDisplayDistributorOn = listAppend(variables.lsPostFormDisplayDistributorOn,trim(form.dgDistributorInfo.contract_distributors_id[current_distributor]),",")>
            <cfelse>
            	<!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... Empty on purpose --->
            </cfif>
          </cfif>
				</cfloop>
        <!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
        <cfset form.lsPreFormDisplayDistributorOn = replace(form.lsPreFormDisplayDistributorOn," ","","ALL")>
        <cfset form.lsPreFormDisplayDistributorOff = replace(form.lsPreFormDisplayDistributorOff," ","","ALL")>
        <cfset variables.lsPostFormDisplayDistributorOn = replace(variables.lsPostFormDisplayDistributorOn," ","","ALL")>
        <cfset variables.lsPostFormDisplayDistributorOff = replace(variables.lsPostFormDisplayDistributorOff," ","","ALL")>
				<!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
        <cfif listLen(form.lsPreFormDisplayDistributorOn,",") AND listLen(variables.lsPostFormDisplayDistributorOff,",")>
          	<cfloop list="#variables.lsPostFormDisplayDistributorOff#" index="current_distributor_post_off">
            	<cfset variables.current_distributor_post_off_index = listFind(form.lsPreFormDisplayDistributorOn,current_distributor_post_off,",")>
              <cfset form.lsPreFormDisplayDistributorOn = listDeleteAt(form.lsPreFormDisplayDistributorOn,variables.current_distributor_post_off_index,",")>
            </cfloop>  
        </cfif>
        <!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
        <cfif listLen(form.lsPreFormDisplayDistributorOff,",") AND listLen(variables.lsPostFormDisplayDistributorOn,",")>
          	<cfloop list="#variables.lsPostFormDisplayDistributorOn#" index="current_distributor_post_on">
            	<cfset variables.current_distributor_post_on_index = listFind(form.lsPreFormDisplayDistributorOff,current_distributor_post_on,",")>
              <cfset form.lsPreFormDisplayDistributorOff = listDeleteAt(form.lsPreFormDisplayDistributorOff,variables.current_distributor_post_on_index,",")>
            </cfloop>  
        </cfif>
        <!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
        <cfif listLen(form.lsPreFormDisplayDistributorOff,",") AND listLen(variables.lsPostFormDisplayDistributorOff,",")>
          <cfset variables.lsFinalAllDisplayDistributorOff = listAppend(variables.lsPostFormDisplayDistributorOff,form.lsPreFormDisplayDistributorOff)>
        <!--- Nothing New Distributor Off ... --->
        <cfelseif listLen(form.lsPreFormDisplayDistributorOff,",")>
        	<cfset variables.lsFinalAllDisplayDistributorOff = form.lsPreFormDisplayDistributorOff>
        <!--- Nothing Old Distributor Off... --->
        <cfelseif listLen(variables.lsPostFormDisplayDistributorOff,",")>
        	<cfset variables.lsFinalAllDisplayDistributorOff = variables.lsPostFormDisplayDistributorOff>
        <!--- No Distributor Off... [numeric] --->
        <cfelse>
          <cfset variables.lsFinalAllDisplayDistributorOff = 0>
        </cfif>
        <!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
        <cfif listLen(form.lsPreFormDisplayDistributorOn,",") AND listLen(variables.lsPostFormDisplayDistributorOn,",")>
          <cfset variables.lsFinalAllDisplayDistributorOn = listAppend(variables.lsPostFormDisplayDistributorOn,form.lsPreFormDisplayDistributorOn)>
        <!--- Nothing new - Distributor On ... --->
        <cfelseif listLen(form.lsPreFormDisplayDistributorOn,",")>
        	<cfset variables.lsFinalAllDisplayDistributorOn = form.lsPreFormDisplayDistributorOn>
        <!--- Nothing Old - Distributor On... --->
        <cfelseif listLen(variables.lsPostFormDisplayDistributorOn,",")>
        	<cfset variables.lsFinalAllDisplayDistributorOn = variables.lsPostFormDisplayDistributorOn>
        <!--- No Distributor On... [numeric] --->
        <cfelse>
          <cfset variables.lsFinalAllDisplayDistributorOn = 0>
        </cfif>
        <!--- ALWAYS START FROM ORIGINAL QUERY! --->
				<cfquery name="variables.qProgramDistributorPostFormNet" datasource="#application.datasource#">
					SELECT 	*
					FROM 		##TMP_qProgramDistributorInfo
					WHERE 	0=0
          <!--- ON first... --->
					<cfif listLen(variables.lsFinalAllDisplayDistributorOn)>
          	<!--- IMPORTANT: 'numeric' id compared to edit list from incoming flash form's structure of arrays... --->
						AND		contract_distributors_id IN (#variables.lsFinalAllDisplayDistributorOn#)
					</cfif>
          <!--- OFF second... --->
					<cfif listLen(variables.lsFinalAllDisplayDistributorOff)>
          	<!--- IMPORTANT: 'numeric' id compared to edit list from incoming flash form's structure of arrays... --->
						AND 	contract_distributors_id NOT IN (#variables.lsFinalAllDisplayDistributorOff#)
					</cfif>
				</cfquery>
				<cfset structInsert(variables,"qProgramDistributorEdited",variables.qProgramDistributorPostFormNet,true)>
      <cfelse>  
      	<cfset structInsert(variables,"qProgramDistributorEdited",variables.qProgramDistributorPostXML,true)> 
			</cfif>
    <cfelse>
      <cfset structInsert(variables,"qProgramDistributorEdited",variables.qProgramDistributorPostXML,true)>
		</cfif>
  <cfelse>
    <cfset structInsert(variables,"qProgramDistributorEdited",variables.qProgramDistributorPostXML,true)>
	</cfif>
	<!--- 1.) FROM FORM - Distributor... [end] --->

	<!--- 2.) FROM FORM - Operator... [begin] --->
	<cfif structKeyExists(form,"dgOperatorInfo.bDisplayOperator") AND structkeyExists(form,"dgOperatorInfo.operator_id")>
		<cfif isArray(form.dgOperatorInfo.bDisplayOperator) AND isArray(form.dgOperatorInfo.operator_id)>
			<cfif arrayLen(form.dgOperatorInfo.bDisplayOperator) AND arrayLen(form.dgOperatorInfo.operator_id)>
      	<!--- IF we have current edit requests for OPERATOR from the form to get to this point,
				then we need to coordinate our final lists of On and Off AT THIS POINT... --->
				<cfset variables.lsPostFormDisplayOperatorOn	= "">
				<cfset variables.lsPostFormDisplayOperatorOff = "">
				<cfloop from="1" to="#arrayLen(form.dgOperatorInfo.operator_id)#" index="current_operator">
					<cfif isDefined("form.dgOperatorInfo.bDisplayOperator")>
          	<!--- CH CH CH CHanges... If user DEselects a row that WAS selected prior... --->
          	<cfif form.dgOperatorInfo.bDisplayOperator[current_operator] EQ "false" AND form.dgOperatorInfo.ORIGINAL.bDisplayOperator[current_operator]>
                <cfset variables.lsPostFormDisplayOperatorOff = listAppend(variables.lsPostFormDisplayOperatorOff,trim(form.dgOperatorInfo.operator_id[current_operator]),",")> 
						<!--- CH CH CH CHanges... If user SELECTS a row that was NOT selected prior... --->
						<cfelseif form.dgOperatorInfo.bDisplayOperator[current_operator] EQ "true" AND NOT form.dgOperatorInfo.ORIGINAL.bDisplayOperator[current_operator]>
              <cfset variables.lsPostFormDisplayOperatorOn = listAppend(variables.lsPostFormDisplayOperatorOn,trim(form.dgOperatorInfo.operator_id[current_operator]),",")>
            <cfelse>
            	<!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... Empty on purpose --->
            </cfif>
          </cfif>
				</cfloop>
        <!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
        <cfset form.lsPreFormDisplayOperatorOn = replace(form.lsPreFormDisplayOperatorOn," ","","ALL")>
        <cfset form.lsPreFormDisplayOperatorOff = replace(form.lsPreFormDisplayOperatorOff," ","","ALL")>
        <cfset variables.lsPostFormDisplayOperatorOn = replace(variables.lsPostFormDisplayOperatorOn," ","","ALL")>
        <cfset variables.lsPostFormDisplayOperatorOff = replace(variables.lsPostFormDisplayOperatorOff," ","","ALL")>
				<!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
        <cfif listLen(form.lsPreFormDisplayOperatorOn,",") AND listLen(variables.lsPostFormDisplayOperatorOff,",")>
          	<cfloop list="#variables.lsPostFormDisplayOperatorOff#" index="current_operator_post_off">
            	<cfset variables.current_operator_post_off_index = listFind(form.lsPreFormDisplayOperatorOn,current_operator_post_off,",")>
              <cfset form.lsPreFormDisplayOperatorOn = listDeleteAt(form.lsPreFormDisplayOperatorOn,variables.current_operator_post_off_index,",")>
            </cfloop>  
        </cfif>
        <!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
        <cfif listLen(form.lsPreFormDisplayOperatorOff,",") AND listLen(variables.lsPostFormDisplayOperatorOn,",")>
          	<cfloop list="#variables.lsPostFormDisplayOperatorOn#" index="current_operator_post_on">
            	<cfset variables.current_operator_post_on_index = listFind(form.lsPreFormDisplayOperatorOff,current_operator_post_on,",")>
              <cfset form.lsPreFormDisplayOperatorOff = listDeleteAt(form.lsPreFormDisplayOperatorOff,variables.current_operator_post_on_index,",")>
            </cfloop>  
        </cfif>
        <!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
        <cfif listLen(form.lsPreFormDisplayOperatorOff,",") AND listLen(variables.lsPostFormDisplayOperatorOff,",")>
          <cfset variables.lsFinalAllDisplayOperatorOff = listAppend(variables.lsPostFormDisplayOperatorOff,form.lsPreFormDisplayOperatorOff)>
          <!--- <cfdump var="#variables.lsFinalAllDisplayOperatorOff#"> should be 2 w/5140 and 5305<br /><font></font><br /> OK --->

        <!--- Nothing New - Operator Off ... --->
        <cfelseif listLen(form.lsPreFormDisplayOperatorOff,",")>
        	<cfset variables.lsFinalAllDisplayOperatorOff = form.lsPreFormDisplayOperatorOff>
        <!--- Nothing Old - Operator Off... --->
        <cfelseif listLen(variables.lsPostFormDisplayOperatorOff,",")>
        	<cfset variables.lsFinalAllDisplayOperatorOff = variables.lsPostFormDisplayOperatorOff>
        <!--- No Operator Off... [numeric] --->
        <cfelse>
          <cfset variables.lsFinalAllDisplayOperatorOff = 0>
        </cfif>
        <!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
        <cfif listLen(form.lsPreFormDisplayOperatorOn,",") AND listLen(variables.lsPostFormDisplayOperatorOn,",")>
          <cfset variables.lsFinalAllDisplayOperatorOn = listAppend(variables.lsPostFormDisplayOperatorOn,form.lsPreFormDisplayOperatorOn)>
        <!--- Nothing new Operator On ... --->
        <cfelseif listLen(form.lsPreFormDisplayOperatorOn,",")>
        	<cfset variables.lsFinalAllDisplayOperatorOn = form.lsPreFormDisplayOperatorOn>
        <!--- Nothing Old Operator On... --->
        <cfelseif listLen(variables.lsPostFormDisplayOperatorOn,",")>
        	<cfset variables.lsFinalAllDisplayOperatorOn = variables.lsPostFormDisplayOperatorOn>
        <!--- No Operator On... [numeric] --->
        <cfelse>
          <cfset variables.lsFinalAllDisplayOperatorOn = 0>
        </cfif>
        <!--- ALWAYS START FROM ORIGINAL QUERY! --->
				<cfquery name="variables.qProgramOperatorPostFormNet" datasource="#application.datasource#">
					SELECT 	*
					FROM 		##TMP_qProgramOperatorInfo
					WHERE 	0=0
          <!--- ON first... --->
					<cfif listLen(variables.lsFinalAllDisplayOperatorOn)>
          	<!--- IMPORTANT: 'numeric' id compared to edit list from incoming flash form's structure of arrays... --->
						AND		operator_id IN (#variables.lsFinalAllDisplayOperatorOn#)
					</cfif>
          <!--- OFF second... --->
					<cfif listLen(variables.lsFinalAllDisplayOperatorOff)>
          	<!--- IMPORTANT: 'numeric' id compared to edit list from incoming flash form's structure of arrays... --->
						AND 	operator_id NOT IN (#variables.lsFinalAllDisplayOperatorOff#)
					</cfif>
				</cfquery>
				<cfset structInsert(variables,"qProgramOperatorEdited",variables.qProgramOperatorPostFormNet,true)>
      <cfelse>  
      	<cfset structInsert(variables,"qProgramOperatorEdited",variables.qProgramOperatorPostXML,true)>  
			</cfif>
    <cfelse>
    	<cfset structInsert(variables,"qProgramOperatorEdited",variables.qProgramOperatorPostXML,true)>  
		</cfif>
  <cfelse>
  	<cfset structInsert(variables,"qProgramOperatorEdited",variables.qProgramOperatorPostXML,true)>
	</cfif>
	<!--- 2.) FROM FORM - Operator... [end] --->

	<!--- 3.) FROM FORM - Fixed Price... [begin] --->
	<cfif variables.stPDFBodyInfo.bDisplayFixedPrice>
		<cfif structKeyExists(form,"dgFixedPriceInfo.bDisplayFixedPriceProduct") AND structKeyExists(form,"dgFixedPriceInfo.ORIGINAL.bDisplayFixedPriceProduct") AND structkeyExists(form,"dgFixedPriceInfo.bsa_id_uom_comp_id")>
			<cfif isArray(form.dgFixedPriceInfo.bDisplayFixedPriceProduct) AND isArray(form.dgFixedPriceInfo.original.bDisplayFixedPriceProduct) AND isArray(form.dgFixedPriceInfo.bsa_id_uom_comp_id)>
				<cfif (arrayLen(form.dgFixedPriceInfo.bsa_id_uom_comp_id) EQ arrayLen(form.dgFixedPriceInfo.bDisplayFixedPriceProduct)) AND (arrayLen(form.dgFixedPriceInfo.bsa_id_uom_comp_id) EQ arrayLen(form.dgFixedPriceInfo.original.bDisplayFixedPriceProduct))>
					<!--- IF we have current edit requests for FIXED PRICE from the form to get to this point,
					then we need to coordinate our final lists of On and Off AT THIS POINT... --->
					<cfset variables.lsPostFormDisplayFixedPriceOn	= "">
					<cfset variables.lsPostFormDisplayFixedPriceOff = "">
					<cfloop from="1" to="#arrayLen(form.dgFixedPriceInfo.bsa_id_uom_comp_id)#" index="current_fixed_price">
						<!--- CH CH CH CHanges... If user DEselects a row that WAS selected prior... --->
            <cfif form.dgFixedPriceInfo.bDisplayFixedPriceProduct[current_fixed_price] EQ "false" AND form.dgFixedPriceInfo.ORIGINAL.bDisplayFixedPriceProduct[current_fixed_price]>
              <cfset variables.lsPostFormDisplayFixedPriceOff = listAppend(variables.lsPostFormDisplayFixedPriceOff,trim(form.dgFixedPriceInfo.bsa_id_uom_comp_id[current_fixed_price]),",")> 
            <!--- CH CH CH CHanges... If user SELECTS a row that was NOT selected prior... --->
            <cfelseif form.dgFixedPriceInfo.bDisplayFixedPriceProduct[current_fixed_price] EQ "true" AND NOT form.dgFixedPriceInfo.ORIGINAL.bDisplayFixedPriceProduct[current_fixed_price]>
              <cfset variables.lsPostFormDisplayFixedPriceOn = listAppend(variables.lsPostFormDisplayFixedPriceOn,trim(form.dgFixedPriceInfo.bsa_id_uom_comp_id[current_fixed_price]),",")>
            <cfelse>
              <!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... Empty on purpose --->
            </cfif>
					</cfloop>

          <!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
					<cfset form.lsPreFormDisplayFixedPriceOn = replace(form.lsPreFormDisplayFixedPriceOn," ","","ALL")>
          <cfset form.lsPreFormDisplayFixedPriceOff = replace(form.lsPreFormDisplayFixedPriceOff," ","","ALL")>
          <cfset variables.lsPostFormDisplayFixedPriceOn = replace(variables.lsPostFormDisplayFixedPriceOn," ","","ALL")>
          <cfset variables.lsPostFormDisplayFixedPriceOff = replace(variables.lsPostFormDisplayFixedPriceOff," ","","ALL")>
          <!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
          <cfif listLen(form.lsPreFormDisplayFixedPriceOn,",") AND listLen(variables.lsPostFormDisplayFixedPriceOff,",")>
              <cfloop list="#variables.lsPostFormDisplayFixedPriceOff#" index="current_fixedPrice_post_off">
                <cfset variables.current_fixedPrice_post_off_index = listFind(form.lsPreFormDisplayFixedPriceOn,current_fixedPrice_post_off,",")>
                <cfset form.lsPreFormDisplayFixedPriceOn = listDeleteAt(form.lsPreFormDisplayFixedPriceOn,variables.current_fixedPrice_post_off_index,",")>
              </cfloop>  
          </cfif>
          <!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
          <cfif listLen(form.lsPreFormDisplayFixedPriceOff,",") AND listLen(variables.lsPostFormDisplayFixedPriceOn,",")>
              <cfloop list="#variables.lsPostFormDisplayFixedPriceOn#" index="current_fixedPrice_post_on">
                <cfset variables.current_fixedPrice_post_on_index = listFind(form.lsPreFormDisplayFixedPriceOff,current_fixedPrice_post_on,",")>
                <cfset form.lsPreFormDisplayFixedPriceOff = listDeleteAt(form.lsPreFormDisplayFixedPriceOff,variables.current_fixedPrice_post_on_index,",")>
              </cfloop>  
          </cfif>
          <!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
          <cfif listLen(form.lsPreFormDisplayFixedPriceOff,",") AND listLen(variables.lsPostFormDisplayFixedPriceOff,",")>
            <cfset variables.lsFinalAllDisplayFixedPriceOff = listAppend(variables.lsPostFormDisplayFixedPriceOff,form.lsPreFormDisplayFixedPriceOff)>
          <!--- Nothing New - Fixed Price Off ... --->
					<cfelseif listLen(form.lsPreFormDisplayFixedPriceOff,",")>
            <cfset variables.lsFinalAllDisplayFixedPriceOff = form.lsPreFormDisplayFixedPriceOff>
          <!--- Nothing Old - Fixed Price Off... --->
          <cfelseif listLen(variables.lsPostFormDisplayFixedPriceOff,",")>
            <cfset variables.lsFinalAllDisplayFixedPriceOff = variables.lsPostFormDisplayFixedPriceOff>
          <!--- No Fixed Price Off... [string] --->
          <cfelse>
            <cfset variables.lsFinalAllDisplayFixedPriceOff = "none">
          </cfif>
          <!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
          <cfif listLen(form.lsPreFormDisplayFixedPriceOn,",") AND listLen(variables.lsPostFormDisplayFixedPriceOn,",")>
            <cfset variables.lsFinalAllDisplayFixedPriceOn = listAppend(variables.lsPostFormDisplayFixedPriceOn,form.lsPreFormDisplayFixedPriceOn)>
          <!--- Nothing New - Fixed Price On ... --->
					<cfelseif listLen(form.lsPreFormDisplayFixedPriceOn,",")>
            <cfset variables.lsFinalAllDisplayFixedPriceOn = form.lsPreFormDisplayFixedPriceOn>
          <!--- Nothing Old - Fixed Price On... --->
          <cfelseif listLen(variables.lsPostFormDisplayFixedPriceOn,",")>
            <cfset variables.lsFinalAllDisplayFixedPriceOn = variables.lsPostFormDisplayFixedPriceOn>
          <!--- No Fixed Price On... [string] --->
          <cfelse>
            <cfset variables.lsFinalAllDisplayFixedPriceOn = "none">
          </cfif>
          <!--- ALWAYS START FROM ORIGINAL QUERY! --->
	<cfquery name="variables.qProgramFixedPricePostFormNet" datasource="#application.datasource#">
		SELECT 	*
		FROM 		##TMP_Fixed_Price_Details
		WHERE 	0=0
	<!--- ON first... Must be Gross --->
						<cfif listLen(variables.lsFinalAllDisplayFixedPriceOn)>
              <!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
              AND		BSA_Foodservice_Items_Master_ID+'_'
	      <!---Dev Note: Milan (24785). For some reason, without using the exact length of abbreviation, the query did not return any records.
		 I was testing on "LBS" Abbreviation 
	      --->
	      +
	      case len(abbreviation)
		when 1 Then
		cast(abbreviation as varchar(1))
		when 2 Then
		cast(abbreviation as varchar(2))
		when 3 Then
		cast(abbreviation as varchar(3))
	     end
	      
	      +'_'+CAST(Program_Fixed_Component_ID AS VARCHAR) IN (#replace(listQualify(variables.lsFinalAllDisplayFixedPriceOn,"'",",")," ","","ALL")#)
            </cfif>
            <!--- OFF second... OK as Net ? --->
            <cfif listLen(variables.lsFinalAllDisplayFixedPriceOff)>
              <!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
              AND		BSA_Foodservice_Items_Master_ID+'_'
	      <!--- Dev Note: Milan (24785). For some reason, without using the exact length of abbreviation, the query did not return any records.
		 I was testing on "LBS" Abbreviation 
	      --->
		+
	      case len(abbreviation)
		when 1 Then
		cast(abbreviation as varchar(1))
		when 2 Then
		cast(abbreviation as varchar(2))
		when 3 Then
		cast(abbreviation as varchar(3))
	     end
	      
	      +'_'+CAST(Program_Fixed_Component_ID AS VARCHAR) NOT IN (#replace(listQualify(variables.lsFinalAllDisplayFixedPriceOff,"'",",")," ","","ALL")#)
	      <!--- Earlier "query of query" was being used. I copied the ORDER BY from "inc_dis_fixed_price_query.cfm"/"inc_opr_fixed_price_query.cfm". --->
	      ORDER BY Program_Fixed_Component_Id,Fixed_Component_Paid_to,item
            </cfif>
	</cfquery>
          <cfset structInsert(variables,"qProgramFixedPriceEdited",variables.qProgramFixedPricePostFormNet,true)>
        <cfelse>  
      		<cfset structInsert(variables,"qProgramFixedPriceEdited",variables.qProgramFixedPricePostXML,true)>  
				</cfif>
      <cfelse>
      	<cfset structInsert(variables,"qProgramFixedPriceEdited",variables.qProgramFixedPricePostXML,true)>
			</cfif>
    <cfelse>
    	<cfset structInsert(variables,"qProgramFixedPriceEdited",variables.qProgramFixedPricePostXML,true)>
		</cfif>
  <cfelse>
  	<cfset structInsert(variables,"qProgramFixedPriceEdited",variables.qProgramFixedPriceInitial,true)>	  
	</cfif>

	<!--- 
	Dev Note:(51134 and 55293) - On WR 48572, code was modified where user can select which discount type to generate letter for, on the letter generation page ("contract_letters.cfm"). 
	In an example, user checked the "freight" checkbox (code on "contract_letters.cfm") and did not select the 'fixed price" checkbox and generated the letter. Only the 
	freight data was added to the letter, which is good,but when that letter is edited by the user, "freight" data was missing because, "var_qProgramLetterFreightFixedComponentNet" 
	query did not return any records on "ProgramLetterFreightManager.cfc". One of the reasons was that "variables.stPDFBodyInfo.bDisplayFixedPrice" was 1 (true),when there was no 
	fixed products to display. 

	To solve the above issue, I made sure that "variables.stPDFBodyInfo.bDisplayFixedPrice" (fixed price display) is set to OFF, when there are no fixed price products included on the
	edit screen.
	--->
	<cfif IsDefined("variables.qProgramFixedPricePostFormNet")>
		<cfif variables.qProgramFixedPricePostFormNet.recordcount eq 0>
			<cfset variables.stPDFBodyInfo.bDisplayFixedPrice = 0>
		</cfif>
	</cfif>
	<!--- 3.) FROM FORM - Fixed Price... [end] --->

	<!--- 4.) FROM FORM - Rebate... [begin] --->
	<cfif variables.stPDFBodyInfo.bDisplayRebate>
		<cfif structKeyExists(form,"dgRebateInfo.bDisplayRebateProduct") AND structKeyExists(form,"dgRebateInfo.ORIGINAL.bDisplayRebateProduct") AND structkeyExists(form,"dgRebateInfo.bsa_id_uom_comp_id")>
			<cfif isArray(form.dgRebateInfo.bDisplayRebateProduct) AND isArray(form.dgRebateInfo.original.bDisplayRebateProduct) AND isArray(form.dgRebateInfo.bsa_id_uom_comp_id)>
				<cfif (arrayLen(form.dgRebateInfo.bsa_id_uom_comp_id) EQ arrayLen(form.dgRebateInfo.bDisplayRebateProduct)) AND (arrayLen(form.dgRebateInfo.bsa_id_uom_comp_id) EQ arrayLen(form.dgRebateInfo.original.bDisplayRebateProduct))>
					<!--- IF we have current edit requests for REBATE from the form to get to this point,
					then we need to coordinate our final lists of On and Off AT THIS POINT... --->
					<cfset variables.lsPostFormDisplayRebateOn	= "">
					<cfset variables.lsPostFormDisplayRebateOff = "">
					<cfloop from="1" to="#arrayLen(form.dgRebateInfo.bsa_id_uom_comp_id)#" index="current_rebate">					
						<!--- CH CH CH CHanges... If user DEselects a row that WAS selected prior... --->
						<cfif form.dgRebateInfo.bDisplayRebateProduct[current_rebate] EQ "false" AND form.dgRebateInfo.ORIGINAL.bDisplayRebateProduct[current_rebate]>
							<cfset variables.lsPostFormDisplayRebateOff = listAppend(variables.lsPostFormDisplayRebateOff,trim(form.dgRebateInfo.bsa_id_uom_comp_id[current_rebate]),",")> 
						<!--- CH CH CH CHanges... If user SELECTS a row that was NOT selected prior... --->
						<cfelseif form.dgRebateInfo.bDisplayRebateProduct[current_rebate] EQ "true" AND NOT form.dgRebateInfo.ORIGINAL.bDisplayRebateProduct[current_rebate]>
							<cfset variables.lsPostFormDisplayRebateOn = listAppend(variables.lsPostFormDisplayRebateOn,trim(form.dgRebateInfo.bsa_id_uom_comp_id[current_rebate]),",")>
						<cfelse>
						<!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... Empty on purpose --->
						</cfif>
					</cfloop>
	
					<!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
					<cfset form.lsPreFormDisplayRebateOn = replace(form.lsPreFormDisplayRebateOn," ","","ALL")>
					<cfset form.lsPreFormDisplayRebateOff = replace(form.lsPreFormDisplayRebateOff," ","","ALL")>
					<cfset variables.lsPostFormDisplayRebateOn = replace(variables.lsPostFormDisplayRebateOn," ","","ALL")>
					<cfset variables.lsPostFormDisplayRebateOff = replace(variables.lsPostFormDisplayRebateOff," ","","ALL")>
					<!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
					<cfif listLen(form.lsPreFormDisplayRebateOn,",") AND listLen(variables.lsPostFormDisplayRebateOff,",")>
						<cfloop list="#variables.lsPostFormDisplayRebateOff#" index="current_rebate_post_off">
							<cfset variables.current_rebate_post_off_index = listFind(form.lsPreFormDisplayRebateOn,current_rebate_post_off,",")>
							<cfset form.lsPreFormDisplayRebateOn = listDeleteAt(form.lsPreFormDisplayRebateOn,variables.current_rebate_post_off_index,",")>
						</cfloop>  
					</cfif>
					<!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
					<cfif listLen(form.lsPreFormDisplayRebateOff,",") AND listLen(variables.lsPostFormDisplayRebateOn,",")>
						<cfloop list="#variables.lsPostFormDisplayRebateOn#" index="current_rebate_post_on">
							<cfset variables.current_rebate_post_on_index = listFind(form.lsPreFormDisplayRebateOff,current_rebate_post_on,",")>
							<cfset form.lsPreFormDisplayRebateOff = listDeleteAt(form.lsPreFormDisplayRebateOff,variables.current_rebate_post_on_index,",")>
						</cfloop>  
					</cfif>
					<!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
					<cfif listLen(form.lsPreFormDisplayRebateOff,",") AND listLen(variables.lsPostFormDisplayRebateOff,",")>
						<cfset variables.lsFinalAllDisplayRebateOff = listAppend(variables.lsPostFormDisplayRebateOff,form.lsPreFormDisplayRebateOff)>
					<!--- Nothing New - Rebate Off ... --->
					<cfelseif listLen(form.lsPreFormDisplayRebateOff,",")>
						<cfset variables.lsFinalAllDisplayRebateOff = form.lsPreFormDisplayRebateOff>
					<!--- Nothing Old - Rebate Off... --->
					<cfelseif listLen(variables.lsPostFormDisplayRebateOff,",")>
						<cfset variables.lsFinalAllDisplayRebateOff = variables.lsPostFormDisplayRebateOff>
					<!--- No Rebate Off... [string] --->
					<cfelse>
						<cfset variables.lsFinalAllDisplayRebateOff = "none">
					</cfif>
					<!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
					<cfif listLen(form.lsPreFormDisplayRebateOn,",") AND listLen(variables.lsPostFormDisplayRebateOn,",")>
						<cfset variables.lsFinalAllDisplayRebateOn = listAppend(variables.lsPostFormDisplayRebateOn,form.lsPreFormDisplayRebateOn)>
					<!--- Nothing New - Rebate On ... --->
					<cfelseif listLen(form.lsPreFormDisplayRebateOn,",")>
						<cfset variables.lsFinalAllDisplayRebateOn = form.lsPreFormDisplayRebateOn>
					<!--- Nothing Old - Rebate On... --->
					<cfelseif listLen(variables.lsPostFormDisplayRebateOn,",")>
						<cfset variables.lsFinalAllDisplayRebateOn = variables.lsPostFormDisplayRebateOn>
					<!--- No Rebate On... [string] --->
					<cfelse>
						<cfset variables.lsFinalAllDisplayRebateOn = "none">
					</cfif>
	          		<!--- ALWAYS START FROM ORIGINAL QUERY! --->
					<cfquery name="variables.qProgramRebatePostFormNet" datasource="#application.datasource#">
						SELECT 	*
						FROM 		##TMP_Rebate_Price_Details
						WHERE 	0=0
						<!--- ON first... Must be Gross --->
						<cfif listLen(variables.lsFinalAllDisplayRebateOn)>
			              <!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
			              AND		BSA_Foodservice_Items_Master_ID+'_'				      
				      <!--- Dev Note: Milan (24785). For some reason, without using the exact length of abbreviation, the query did not return any records.
				      I was testing on "LBS" Abbreviation 
				      --->
				     + 
				     case len(abbreviation)
					when 1 Then
					cast(abbreviation as varchar(1))
					when 2 Then
					cast(abbreviation as varchar(2))
					when 3 Then
					cast(abbreviation as varchar(3))
				     end
				      +'_'+CAST(Program_Rebates_Component_ID AS VARCHAR) IN (#replace(listQualify(variables.lsFinalAllDisplayRebateOn,"'",",")," ","","ALL")#)
			            </cfif>
			            <!--- OFF second... OK as Net ? --->
			            <cfif listLen(variables.lsFinalAllDisplayRebateOff)>
			              <!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
			              AND		BSA_Foodservice_Items_Master_ID+'_'
				      <!--- Dev Note: Milan (24785). For some reason, without using the exact length of abbreviation, the query did not return any records.
				      I was testing on "LBS" Abbreviation 
				      --->
				     +
				      case len(abbreviation)
					when 1 Then
					cast(abbreviation as varchar(1))
					when 2 Then
					cast(abbreviation as varchar(2))
					when 3 Then
					cast(abbreviation as varchar(3))
				     end
				      +'_'+CAST(Program_Rebates_Component_ID AS VARCHAR) NOT IN (#replace(listQualify(variables.lsFinalAllDisplayRebateOff,"'",",")," ","","ALL")#)
			              <!--- Earlier "query of query" was being used. I copied the ORDER BY from "inc_dis_rebate_query.cfm"/"inc_opr_rebate_query.cfm". 
					    Note: Rebate should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER 
				      --->
				    ORDER BY item,Program_Rebates_Component_ID,Component_Paid_to
				    </cfif>
				      </cfquery>
					<cfset structInsert(variables,"qProgramRebateEdited",variables.qProgramRebatePostFormNet,true)>
			
			
					<!--- D18220: Adding Cutomer Product Number to Letters 
					Once we changed the generate_program_pdf file to use temp table instead of the query getting passed,
					what ever change we do to the query qProgramRebateEdited will not be accounted fro while generating the pdf.
					So we will need to make teh changes in the temp table ##TMP_Rebate_Price_Details
					--->
					<cfif listLen(variables.lsFinalAllDisplayRebateOff)>
						<cfquery name="variables.qDeleteFromRebateTempTable" datasource="#application.datasource#">
							DELETE
							FROM	##TMP_Rebate_Price_Details
							WHERE	BSA_Foodservice_Items_Master_ID + '_'+ rtrim(abbreviation) + '_' + CAST(Program_Rebates_Component_ID AS VARCHAR) IN (#replace(listQualify(variables.lsFinalAllDisplayRebateOff,"'",",")," ","","ALL")#)
						</cfquery>
					</cfif>
		
        		<cfelse>  
      				<cfset structInsert(variables,"qProgramRebateEdited",variables.qProgramRebatePostXML,true)>  
				</cfif>
      		<cfelse>
       			<cfset structInsert(variables,"qProgramRebateEdited",variables.qProgramRebatePostXML,true)> 
			</cfif>
    	<cfelse>
    		<cfset structInsert(variables,"qProgramRebateEdited",variables.qProgramRebatePostXML,true)>  
		</cfif>
  	<cfelse>
  		<cfset structInsert(variables,"qProgramRebateEdited",variables.qProgramRebateInitial,true)> 
	</cfif>
	
	
	
	<!--- 4.) FROM FORM - Rebate... [end] --->

	<!--- 5.) FROM FORM - Bid Request... [begin] --->
	<cfif variables.stPDFBodyInfo.bDisplayBidRequest>
		<cfif structKeyExists(form,"dgBidRequestInfo.bDisplayBidRequestProduct") AND structKeyExists(form,"dgBidRequestInfo.ORIGINAL.bDisplayBidRequestProduct") AND structkeyExists(form,"dgBidRequestInfo.bsa_id_uom_comp_id")>
			<cfif isArray(form.dgBidRequestInfo.bDisplayBidRequestProduct) AND isArray(form.dgBidRequestInfo.original.bDisplayBidRequestProduct) AND isArray(form.dgBidRequestInfo.bsa_id_uom_comp_id)>
				<cfif (arrayLen(form.dgBidRequestInfo.bsa_id_uom_comp_id) EQ arrayLen(form.dgBidRequestInfo.bDisplayBidRequestProduct)) AND (arrayLen(form.dgBidRequestInfo.bsa_id_uom_comp_id) EQ arrayLen(form.dgBidRequestInfo.original.bDisplayBidRequestProduct))>
					<!--- IF we have current edit requests for BID REQUEST from the form to get to this point,
					then we need to coordinate our final lists of On and Off AT THIS POINT... --->
					<cfset variables.lsPostFormDisplayBidRequestOn	= "">
					<cfset variables.lsPostFormDisplayBidRequestOff = "">
					<cfloop from="1" to="#arrayLen(form.dgBidRequestInfo.bsa_id_uom_comp_id)#" index="current_fixed_price">
						<!--- CH CH CH CHanges... If user DEselects a row that WAS selected prior... --->
            <cfif form.dgBidRequestInfo.bDisplayBidRequestProduct[current_bid_request] EQ "false" AND form.dgBidRequestInfo.ORIGINAL.bDisplayBidRequestProduct[current_bid_request]>
              <cfset variables.lsPostFormDisplayBidRequestOff = listAppend(variables.lsPostFormDisplayBidRequestOff,trim(form.dgBidRequestInfo.bsa_id_uom_comp_id[current_bid_request]),",")> 
            <!--- CH CH CH CHanges... If user SELECTS a row that was NOT selected prior... --->
            <cfelseif form.dgBidRequestInfo.bDisplayBidRequestProduct[current_bid_request] EQ "true" AND NOT form.dgBidRequestInfo.ORIGINAL.bDisplayBidRequestProduct[current_bid_request]>
              <cfset variables.lsPostFormDisplayBidRequestOn = listAppend(variables.lsPostFormDisplayBidRequestOn,trim(form.dgBidRequestInfo.bsa_id_uom_comp_id[current_bid_request]),",")>
            <cfelse>
              <!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... Empty on purpose --->
            </cfif> 
					</cfloop>

          <!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
					<cfset form.lsPreFormDisplayBidRequestOn = replace(form.lsPreFormDisplayBidRequestOn," ","","ALL")>
          <cfset form.lsPreFormDisplayBidRequestOff = replace(form.lsPreFormDisplayBidRequestOff," ","","ALL")>
          <cfset variables.lsPostFormDisplayBidRequestOn = replace(variables.lsPostFormDisplayBidRequestOn," ","","ALL")>
          <cfset variables.lsPostFormDisplayBidRequestOff = replace(variables.lsPostFormDisplayBidRequestOff," ","","ALL")>
          <!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
          <cfif listLen(form.lsPreFormDisplayBidRequestOn,",") AND listLen(variables.lsPostFormDisplayBidRequestOff,",")>
              <cfloop list="#variables.lsPostFormDisplayBidRequestOff#" index="current_bidRequest_post_off">
                <cfset variables.current_bidRequest_post_off_index = listFind(form.lsPreFormDisplayBidRequestOn,current_bidRequest_post_off,",")>
                <cfset form.lsPreFormDisplayBidRequestOn = listDeleteAt(form.lsPreFormDisplayBidRequestOn,variables.current_bidRequest_post_off_index,",")>
              </cfloop>  
          </cfif>
          <!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
          <cfif listLen(form.lsPreFormDisplayBidRequestOff,",") AND listLen(variables.lsPostFormDisplayBidRequestOn,",")>
              <cfloop list="#variables.lsPostFormDisplayBidRequestOn#" index="current_bidRequest_post_on">
                <cfset variables.current_bidRequest_post_on_index = listFind(form.lsPreFormDisplayBidRequestOff,current_bidRequest_post_on,",")>
                <cfset form.lsPreFormDisplayBidRequestOff = listDeleteAt(form.lsPreFormDisplayBidRequestOff,variables.current_bidRequest_post_on_index,",")>
              </cfloop>  
          </cfif>
          <!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
          <cfif listLen(form.lsPreFormDisplayBidRequestOff,",") AND listLen(variables.lsPostFormDisplayBidRequestOff,",")>
            <cfset variables.lsFinalAllDisplayBidRequestOff = listAppend(variables.lsPostFormDisplayBidRequestOff,form.lsPreFormDisplayBidRequestOff)>
          <!--- Nothing New - Bid Request Off ... --->
					<cfelseif listLen(form.lsPreFormDisplayBidRequestOff,",")>
            <cfset variables.lsFinalAllDisplayBidRequestOff = form.lsPreFormDisplayBidRequestOff>
          <!--- Nothing Old - Bid Request Off... --->
          <cfelseif listLen(variables.lsPostFormDisplayBidRequestOff,",")>
            <cfset variables.lsFinalAllDisplayBidRequestOff = variables.lsPostFormDisplayBidRequestOff>
          <!--- No Bid Request Off... [string] --->
          <cfelse>
            <cfset variables.lsFinalAllDisplayBidRequestOff = "none">
          </cfif>
          <!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
          <cfif listLen(form.lsPreFormDisplayBidRequestOn,",") AND listLen(variables.lsPostFormDisplayBidRequestOn,",")>
            <cfset variables.lsFinalAllDisplayBidRequestOn = listAppend(variables.lsPostFormDisplayBidRequestOn,form.lsPreFormDisplayBidRequestOn)>
          <!--- Nothing New - Bid Request On ... --->
					<cfelseif listLen(form.lsPreFormDisplayBidRequestOn,",")>
            <cfset variables.lsFinalAllDisplayBidRequestOn = form.lsPreFormDisplayBidRequestOn>
          <!--- Nothing Old - Bid Request On... --->
          <cfelseif listLen(variables.lsPostFormDisplayBidRequestOn,",")>
            <cfset variables.lsFinalAllDisplayBidRequestOn = variables.lsPostFormDisplayBidRequestOn>
          <!--- No Bid Request On... [string] --->
          <cfelse>
            <cfset variables.lsFinalAllDisplayBidRequestOn = "none">
          </cfif>
          <!--- ALWAYS START FROM ORIGINAL QUERY! --->
					<cfquery name="variables.qProgramBidRequestPostFormNet" dbtype="query">
						SELECT 	*
						FROM 		variables.qProgramBidRequestInitial
						WHERE 	0=0
						<!--- ON first... Must be Gross --->
						<cfif listLen(variables.lsFinalAllDisplayBidRequestOn)>
              <!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
              AND		BSA_Foodservice_Items_Master_ID+'_'+abbreviation+'_'+CAST(Program_BidRequest_Component_ID AS VARCHAR) IN (#replace(listQualify(variables.lsFinalAllDisplayBidRequestOn,"'",",")," ","","ALL")#)
            </cfif>
            <!--- OFF second... OK as Net ? --->
            <cfif listLen(variables.lsFinalAllDisplayBidRequestOff)>
              <!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
              AND		BSA_Foodservice_Items_Master_ID+'_'+abbreviation+'_'+CAST(Program_BidRequest_Component_ID AS VARCHAR) NOT IN (#replace(listQualify(variables.lsFinalAllDisplayBidRequestOff,"'",",")," ","","ALL")#)
            </cfif>
					</cfquery>
          <cfset structInsert(variables,"qProgramBidRequestEdited",variables.qProgramBidRequestPostFormNet,true)>
        <cfelse>  
      		<cfset structInsert(variables,"qProgramBidRequestEdited",variables.qProgramBidRequestPostXML,true)>  
				</cfif>
      <cfelse>
      	<cfset structInsert(variables,"qProgramBidRequestEdited",variables.qProgramBidRequestPostXML,true)>
			</cfif>
    <cfelse>
    	<cfset structInsert(variables,"qProgramBidRequestEdited",variables.qProgramBidRequestPostXML,true)>  
		</cfif>
  <cfelse>
  	<cfset structInsert(variables,"qProgramBidRequestEdited",variables.qProgramBidRequestInitial,true)> 
	</cfif>
	<!--- 5.) FROM FORM - Bid Request... [end] --->

	<!--- 6.) FROM FORM - Lump Sum... [begin] --->
	<cfif variables.stPDFBodyInfo.bDisplayLumpSum>
		<cfif structKeyExists(form,"dgLumpSumInfo.bDisplayLumpSum") AND structkeyExists(form,"dgLumpSumInfo.bsa_id_comp_id")>
			<cfif isArray(form.dgLumpSumInfo.bDisplayLumpSum) AND isArray(form.dgLumpSumInfo.bsa_id_comp_id)>
				<cfif arrayLen(form.dgLumpSumInfo.bDisplayLumpSum) AND arrayLen(form.dgLumpSumInfo.bsa_id_comp_id)>
				<!--- IF we have current edit requests for LUMP SUM from the form to get to this point,
				then we need to coordinate our final lists of On and Off AT THIS POINT... --->
				<cfset variables.lsPostFormDisplayLumpSumOn	= "">
				<cfset variables.lsPostFormDisplayLumpSumOff = "">
					<cfloop from="1" to="#arrayLen(form.dgLumpSumInfo.bsa_id_comp_id)#" index="current_lump_sum">
         	<cfif isDefined("form.dgLumpSumInfo.bDisplayLumpSum")>
							<cfif form.dgLumpSumInfo.bDisplayLumpSum[current_lump_sum] EQ "false" AND form.dgLumpSumInfo.ORIGINAL.bDisplayLumpSum[current_lump_sum]>
                <cfset variables.lsPostFormDisplayLumpSumOff = listAppend(variables.lsPostFormDisplayLumpSumOff,trim(form.dgLumpSumInfo.bsa_id_comp_id[current_lump_sum]),",")>
              <!--- Note: This var is NOT boolean. It may be "undefined" for unchanged rows from the datagrid so... elseIF --->
              <cfelseif form.dgLumpSumInfo.bDisplayLumpSum[current_lump_sum] EQ "true" AND NOT form.dgLumpSumInfo.ORIGINAL.bDisplayLumpSum[current_lump_sum]>
                <cfset variables.lsPostFormDisplayLumpSumOn = listAppend(variables.lsPostFormDisplayLumpSumOn,trim(form.dgLumpSumInfo.bsa_id_comp_id[current_lump_sum]),",")>
              <cfelse>
            		<!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... --->
              </cfif>
            </cfif>
					</cfloop>
					<!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
					<cfset form.lsPreFormDisplayLumpSumOn = replace(form.lsPreFormDisplayLumpSumOn," ","","ALL")>
          <cfset form.lsPreFormDisplayLumpSumOff = replace(form.lsPreFormDisplayLumpSumOff," ","","ALL")>
          <cfset variables.lsPostFormDisplayLumpSumOn = replace(variables.lsPostFormDisplayLumpSumOn," ","","ALL")>
          <cfset variables.lsPostFormDisplayLumpSumOff = replace(variables.lsPostFormDisplayLumpSumOff," ","","ALL")>
          <!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
          <cfif listLen(form.lsPreFormDisplayLumpSumOn,",") AND listLen(variables.lsPostFormDisplayLumpSumOff,",")>
              <cfloop list="#variables.lsPostFormDisplayLumpSumOff#" index="current_lumpSum_post_off">
                <cfset variables.current_lumpSum_post_off_index = listFind(form.lsPreFormDisplayLumpSumOn,current_lumpSum_post_off,",")>
                <cfset form.lsPreFormDisplayLumpSumOn = listDeleteAt(form.lsPreFormDisplayLumpSumOn,variables.current_lumpSum_post_off_index,",")>
              </cfloop>  
          </cfif>
          <!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
          <cfif listLen(form.lsPreFormDisplayLumpSumOff,",") AND listLen(variables.lsPostFormDisplayLumpSumOn,",")>
              <cfloop list="#variables.lsPostFormDisplayLumpSumOn#" index="current_lumpSum_post_on">
                <cfset variables.current_lumpSum_post_on_index = listFind(form.lsPreFormDisplayLumpSumOff,current_lumpSum_post_on,",")>
                <cfset form.lsPreFormDisplayLumpSumOff = listDeleteAt(form.lsPreFormDisplayLumpSumOff,variables.current_lumpSum_post_on_index,",")>
              </cfloop>  
          </cfif>
          <!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
          <cfif listLen(form.lsPreFormDisplayLumpSumOff,",") AND listLen(variables.lsPostFormDisplayLumpSumOff,",")>
            <cfset variables.lsFinalAllDisplayLumpSumOff = listAppend(variables.lsPostFormDisplayLumpSumOff,form.lsPreFormDisplayLumpSumOff)>
          <!--- Nothing New - Lump Sum Off ... --->
					<cfelseif listLen(form.lsPreFormDisplayLumpSumOff,",")>
            <cfset variables.lsFinalAllDisplayLumpSumOff = form.lsPreFormDisplayLumpSumOff>
          <!--- Nothing Old - Lump Sum Off... --->
          <cfelseif listLen(variables.lsPostFormDisplayLumpSumOff,",")>
            <cfset variables.lsFinalAllDisplayLumpSumOff = variables.lsPostFormDisplayLumpSumOff>
          <!--- No Lump Sum Off... [numeric] --->
          <cfelse>
            <cfset variables.lsFinalAllDisplayLumpSumOff = 0>
          </cfif>
          <!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
          <cfif listLen(form.lsPreFormDisplayLumpSumOn,",") AND listLen(variables.lsPostFormDisplayLumpSumOn,",")>
            <cfset variables.lsFinalAllDisplayLumpSumOn = listAppend(variables.lsPostFormDisplayLumpSumOn,form.lsPreFormDisplayLumpSumOn)>
          <!--- Nothing New - Lump Sum On ... --->
					<cfelseif listLen(form.lsPreFormDisplayLumpSumOn,",")>
            <cfset variables.lsFinalAllDisplayLumpSumOn = form.lsPreFormDisplayLumpSumOn>
          <!--- Nothing Old - LumpSum On... --->
          <cfelseif listLen(variables.lsPostFormDisplayLumpSumOn,",")>
            <cfset variables.lsFinalAllDisplayLumpSumOn = variables.lsPostFormDisplayLumpSumOn>
          <!--- No Lump Sum On... [numeric] --->
          <cfelse>
            <cfset variables.lsFinalAllDisplayLumpSumOn = 0>
          </cfif>
	 <!--- ALWAYS START FROM ORIGINAL QUERY! --->
					<cfquery name="variables.qProgramLumpSumPostFormNet" datasource="#application.datasource#">
						SELECT 	*
						FROM 		##TMP_LumpSum_Details
						WHERE 	0=0
						<!--- ON first... --->
						<cfif listLen(variables.lsFinalAllDisplayLumpSumOn)>
            	<!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
							<!--- When we do not have products for the lumpsum component in the lumpsum --->
							<cfif Left(variables.lsFinalAllDisplayLumpSumOn,1) eq "_">
							AND	'_'+Program_Lump_Sum_ID IN (#listQualify(variables.lsFinalAllDisplayLumpSumOn,"'",",")#)
							<cfelse>
							<!--- When we have products for the lumpsum component in the lumpsum --->
							AND	BSA_FoodService_Items_Master_ID+'_'+Program_Lump_Sum_ID IN (#listQualify(variables.lsFinalAllDisplayLumpSumOn,"'",",")#)
							</cfif>
						</cfif>
            <!--- OFF second... --->
						<cfif listLen(variables.lsFinalAllDisplayLumpSumOff)>
            	<!--- IMPORTANT: 'string' id compared to edit list from incoming flash form's structure of arrays... --->
							<!--- When we do not have products for the lumpsum component in the lumpsum --->
							<cfif Left(variables.lsFinalAllDisplayLumpSumOff,1) eq "_">
							AND 	'_'+Program_Lump_Sum_ID NOT IN (#listQualify(variables.lsFinalAllDisplayLumpSumOff,"'",",")#)	
							<cfelse>
							<!--- When we have products for the lumpsum component in the lumpsum --->
							AND 	BSA_FoodService_Items_Master_ID+'_'+Program_Lump_Sum_ID NOT IN (#listQualify(variables.lsFinalAllDisplayLumpSumOff,"'",",")#)
							</cfif>
						</cfif>
						ORDER BY Program_Lump_Sum_ID,Component_Paid_to
					</cfquery>
					<cfset structInsert(variables,"qProgramLumpSumEdited",variables.qProgramLumpSumPostFormNet,true)>
 			
					<!---  Adding Cutomer Product Number to Letters 
					Once we changed the generate_program_pdf file to use temp table instead of the query getting passed,
					what ever change we do to the query qProgramLumpsumEdited will not be accounted for while generating the pdf.
					So we will need to make teh changes in the temp table ##TMP_LumpSum_Details
					--->
					<cfif listLen(variables.lsFinalAllDisplayLumpsumOff)>
						<cfquery name="variables.qDeleteFromLumpsumTempTable" datasource="#application.datasource#">
							DELETE
							FROM	##TMP_LumpSum_Details
							<!--- When we do not have products for the lumpsum component in the lumpsum --->
							<cfif Left(variables.lsFinalAllDisplayLumpsumOff,1) eq "_">
							WHERE	'_'+ CAST(Program_Lump_Sum_ID AS VARCHAR) IN (#replace(listQualify(variables.lsFinalAllDisplayLumpsumOff,"'",",")," ","","ALL")#)
							<cfelse>
							<!--- When we have products for the lumpsum component in the lumpsum --->
							WHERE	BSA_Foodservice_Items_Master_ID + '_' + CAST(Program_Lump_Sum_ID AS VARCHAR) IN (#replace(listQualify(variables.lsFinalAllDisplayLumpsumOff,"'",",")," ","","ALL")#)
							</cfif>
						</cfquery>
					</cfif>
		
        <cfelse>  
      		<cfset structInsert(variables,"qProgramLumpSumEdited",variables.qProgramLumpSumPostXML,true)>  
				</cfif>
      <cfelse>
      	<cfset structInsert(variables,"qProgramLumpSumEdited",variables.qProgramLumpSumPostXML,true)>  
			</cfif>
    <cfelse>
    	<cfset structInsert(variables,"qProgramLumpSumEdited",variables.qProgramLumpSumPostXML,true)>  
		</cfif>
  <cfelse>
  	<cfset structInsert(variables,"qProgramLumpSumEdited",variables.qProgramLumpSumInitial,true)> 
	</cfif>
	<!--- 6.) FROM FORM - Lump Sum... [end] --->

	<!--- 7.) Note: FROM FORM - 'Growth' On Deck --->

    <!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
    <!--- 8.) FROM FORM - Clause... [begin] --->
	<cfif structKeyExists(form,"dgClauseInfo.bDisplayClause") AND structkeyExists(form,"dgClauseInfo.clause_library_id")>
    <cfif isArray(form.dgClauseInfo.bDisplayClause) AND isArray(form.dgClauseInfo.clause_library_id)>
      <cfif arrayLen(form.dgClauseInfo.bDisplayClause) AND arrayLen(form.dgClauseInfo.clause_library_id)>
        <!--- IF we have current edit requests for CLAUSE from the form to get to this point,
				then we need to coordinate our final lists of On and Off AT THIS POINT... --->
				<cfset variables.lsPostFormDisplayClauseOn	= "">
				<cfset variables.lsPostFormDisplayClauseOff = "">
        <cfloop from="1" to="#arrayLen(form.dgClauseInfo.clause_library_id)#" index="current_clause">
          <cfif isDefined("form.dgClauseInfo.bDisplayClause")>
						<cfif form.dgClauseInfo.bDisplayClause[current_clause] EQ "false" AND form.dgClauseInfo.ORIGINAL.bDisplayClause[current_clause]>
              <cfset variables.lsPostFormDisplayClauseOff = listAppend(variables.lsPostFormDisplayClauseOff,trim(form.dgClauseInfo.clause_library_id[current_clause]),",")>
            <!--- Note: This var is NOT boolean. It may be "undefined" for unchanged rows from the datagrid so... elseIF --->
            <cfelseif form.dgClauseInfo.bDisplayClause[current_clause] EQ "true" AND NOT form.dgClauseInfo.ORIGINAL.bDisplayClause[current_clause]>
              <cfset variables.lsPostFormDisplayClauseOn = listAppend(variables.lsPostFormDisplayClauseOn,trim(form.dgClauseInfo.clause_library_id[current_clause]),",")>
            <cfelse>
              <!--- IF the value of the checkbox is "undefined" for current row of THIS datagrid, there is not change... --->
            </cfif>
          </cfif>
        </cfloop>

				<!--- 1.) Let's make ABSOLUTELY sure there are no spaces in here... before the query below... --->
				<cfset form.lsPreFormDisplayClauseOn = replace(form.lsPreFormDisplayClauseOn," ","","ALL")>
        <cfset form.lsPreFormDisplayClauseOff = replace(form.lsPreFormDisplayClauseOff," ","","ALL")>
        <cfset variables.lsPostFormDisplayClauseOn = replace(variables.lsPostFormDisplayClauseOn," ","","ALL")>
        <cfset variables.lsPostFormDisplayClauseOff = replace(variables.lsPostFormDisplayClauseOff," ","","ALL")>
        <!--- 2.) IF we have a list of prior ONs and a list of post OFFs, then we need to SUBTRACT the post OFFs from the pre ONs... --->
        <cfif listLen(form.lsPreFormDisplayClauseOn,",") AND listLen(variables.lsPostFormDisplayClauseOff,",")>
            <cfloop list="#variables.lsPostFormDisplayClauseOff#" index="current_clause_post_off">
              <cfset variables.current_clause_post_off_index = listFind(form.lsPreFormDisplayClauseOn,current_clause_post_off,",")>
              <cfset form.lsPreFormDisplayClauseOn = listDeleteAt(form.lsPreFormDisplayClauseOn,variables.current_clause_post_off_index,",")>
            </cfloop>  
        </cfif>
        <!--- 3.) IF we have a list of prior OFFs and a list of post ONs, then we need to SUBTRACT the post ONs from the pre OFFs... --->
        <cfif listLen(form.lsPreFormDisplayClauseOff,",") AND listLen(variables.lsPostFormDisplayClauseOn,",")>
            <cfloop list="#variables.lsPostFormDisplayClauseOn#" index="current_clause_post_on">
              <cfset variables.current_clause_post_on_index = listFind(form.lsPreFormDisplayClauseOff,current_clause_post_on,",")>
              <cfset form.lsPreFormDisplayClauseOff = listDeleteAt(form.lsPreFormDisplayClauseOff,variables.current_clause_post_on_index,",")>
            </cfloop>  
        </cfif>
        <!--- 4.) IF we have a list of prior OFFs and a list of post OFFs, then we need to ADD the NET pre OFFs to the NET post OFFs... --->
        <cfif listLen(form.lsPreFormDisplayClauseOff,",") AND listLen(variables.lsPostFormDisplayClauseOff,",")>
          <cfset variables.lsFinalAllDisplayClauseOff = listAppend(variables.lsPostFormDisplayClauseOff,form.lsPreFormDisplayClauseOff)>
        <!--- Nothing New - Clause Off ... --->
        <cfelseif listLen(form.lsPreFormDisplayClauseOff,",")>
        	<cfset variables.lsFinalAllDisplayClauseOff = form.lsPreFormDisplayClauseOff>
        <!--- Nothing Old - Clause Off... --->
        <cfelseif listLen(variables.lsPostFormDisplayClauseOff,",")>
        	<cfset variables.lsFinalAllDisplayClauseOff = variables.lsPostFormDisplayClauseOff>
        <!--- No Clause Off... [numeric] --->
        <cfelse>
          <cfset variables.lsFinalAllDisplayClauseOff = 0>
        </cfif>
        <!--- 5.) IF we have a list of prior ONs and a list of post ONs, then we need to ADD the NET pre ONs to the NET post ONs... --->
        <cfif listLen(form.lsPreFormDisplayClauseOn,",") AND listLen(variables.lsPostFormDisplayClauseOn,",")>
          <cfset variables.lsFinalAllDisplayClauseOn = listAppend(variables.lsPostFormDisplayClauseOn,form.lsPreFormDisplayClauseOn)>
        <!--- Nothing New - Clause On ... --->
        <cfelseif listLen(form.lsPreFormDisplayClauseOn,",")>
        	<cfset variables.lsFinalAllDisplayClauseOn = form.lsPreFormDisplayClauseOn>
        <!--- Nothing Old - Clause On... --->
        <cfelseif listLen(variables.lsPostFormDisplayClauseOn,",")>
        	<cfset variables.lsFinalAllDisplayClauseOn = variables.lsPostFormDisplayClauseOn>
        <!--- No Clause On... [numeric] --->
        <cfelse>
          <cfset variables.lsFinalAllDisplayClauseOn = 0>
        </cfif>
        <!--- ALWAYS START FROM ORIGINAL QUERY! --->
        <cfquery name="variables.qProgramClausePostFormNet" dbtype="query">
          SELECT 	*
          FROM 		variables.qProgramClauseInitial
          WHERE 	0=0
          <!--- ON first... Must be Gross --->
          <cfif listLen(variables.lsFinalAllDisplayClauseOn)>
            <!--- IMPORTANT: 'numeric' id compared to edit list from incoming flash form's structure of arrays... --->
            AND		clause_library_id IN (#variables.lsFinalAllDisplayClauseOn#)
          </cfif>
          <!--- OFF second... OK as Net --->
          <cfif listLen(variables.lsFinalAllDisplayClauseOff)>
            <!--- IMPORTANT: 'numeric' id compared to edit list from incoming flash form's structure of arrays... --->
            AND 	clause_library_id NOT IN (#variables.lsFinalAllDisplayClauseOff#)
          </cfif>
        </cfquery>
        <cfset structInsert(variables,"qProgramClauseEdited",variables.qProgramClausePostFormNet,true)>
      <cfelse>  
      	<cfset structInsert(variables,"qProgramClauseEdited",variables.qProgramClausePostXML,true)>  
      </cfif>
    <cfelse>
    	<cfset structInsert(variables,"qProgramClauseEdited",variables.qProgramClausePostXML,true)> 
    </cfif>
  <cfelse>
  	<cfset structInsert(variables,"qProgramClauseEdited",variables.qProgramClausePostXML,true)> 
  </cfif>
	<!--- 8.) FROM FORM - Clause... [end] --->
    TEMPORARILY COMMENT OUT CLAUSE [end] --->
  
  <!--- =======================================================
	============== Customer Product Numbers [begin] =============
	===================== FROM EDIT FORM =================== --->
  
  <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
	<cfif form.bAddcustomerproductnumbers>

    <!--- <cfdump var="#variables.qProgramFixedPriceEdited#" label="variables.qProgramFixedPriceEdited"> --->

			<!--- 3.) FROM FORM - Fixed Price... [begin] --->
      <cfif variables.stPDFBodyInfo.bDisplayFixedPrice>
        <cfif structKeyExists(form,"dgFixedPriceInfo.customer_product_number") AND structkeyExists(form,"dgFixedPriceInfo.bsa_id_uom_comp_id")>
          <cfif isArray(form.dgFixedPriceInfo.customer_product_number) AND isArray(form.dgFixedPriceInfo.bsa_id_uom_comp_id)>
            <cfif arrayLen(form.dgFixedPriceInfo.customer_product_number) EQ arrayLen(form.dgFixedPriceInfo.bsa_id_uom_comp_id)>
              <!--- let's pour our incoming customer_product_number into a container... --->
              <cfset variables.aFixedPriceCustomerProductNumbers 	= arrayNew(1)>
              <cfloop query="variables.qProgramFixedPriceEdited">
              
              	<cfset variables.current_fixedPrice_bsa_id_uom_comp_id = trim(variables.qProgramFixedPriceEdited.BSA_Foodservice_Items_Master_ID) & '_' & trim(variables.qProgramFixedPriceEdited.abbreviation) & '_' & trim(toString(variables.qProgramFixedPriceEdited.Program_Fixed_Component_ID))>
                
                <cfloop from="1" to="#arrayLen(form.dgFixedPriceInfo.bsa_id_uom_comp_id)#" index="current_product_number">
                  <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
									<cfif variables.current_fixedPrice_bsa_id_uom_comp_id EQ trim(replace(form.dgFixedPriceInfo.bsa_id_uom_comp_id[current_product_number]," ","","ALL"))>
                     <cfset arrayAppend(variables.aFixedPriceCustomerProductNumbers,trim(form.dgFixedPriceInfo.customer_product_number[current_product_number]))>
                     <!--- let's break out of the inside loop IF we find a match... --->
                     <cfbreak>
                   </cfif>
                </cfloop>
                	<!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
									<cfif variables.qProgramFixedPriceEdited.currentRow GT arrayLen(variables.aFixedPriceCustomerProductNumbers)>
                  	<!--- if we have not found our perfect match yet, then we keep the pre-existing value at this point... --->
                    <cfset arrayAppend(variables.aFixedPriceCustomerProductNumbers,variables.qProgramFixedPriceEdited.customer_product_number[currentRow])>
                  </cfif>
              </cfloop>
              <cfloop query="variables.qProgramFixedPriceEdited">
              	<!--- let's modify the values in our query container at this point, merging pre-existing with just edited... --->
              	<cfset querySetCell(variables.qProgramFixedPriceEdited,"customer_product_number",variables.aFixedPriceCustomerProductNumbers[variables.qProgramFixedPriceEdited.currentRow],variables.qProgramFixedPriceEdited.currentRow)>
              </cfloop>
          </cfif>
        <cfelse>
        	<!--- all set --->  
        </cfif>
      <cfelse>
        	<!--- all set --->  
      </cfif>
    <cfelse>
        	<!--- all set --->  
    </cfif>
    <!--- 3.) FROM FORM - Fixed Price... [end] --->

		<!--- 4.) FROM FORM - Rebate... [begin] --->
		<cfif variables.stPDFBodyInfo.bDisplayRebate>
      <cfif structKeyExists(form,"dgRebateInfo.customer_product_number") AND structkeyExists(form,"dgRebateInfo.bsa_id_uom_comp_id")>
        <cfif isArray(form.dgRebateInfo.customer_product_number) AND isArray(form.dgRebateInfo.bsa_id_uom_comp_id)>
          <cfif arrayLen(form.dgRebateInfo.customer_product_number) EQ arrayLen(form.dgRebateInfo.bsa_id_uom_comp_id)>
            <!--- let's pour our incoming customer_product_number into a container... --->
            <cfset variables.aRebateCustomerProductNumbers 	= arrayNew(1)>
            <cfloop query="variables.qProgramRebateEdited">
            
              <cfset variables.current_rebate_bsa_id_uom_comp_id = trim(variables.qProgramRebateEdited.BSA_Foodservice_Items_Master_ID) & '_' & trim(variables.qProgramRebateEdited.abbreviation) & '_' & trim(toString(variables.qProgramRebateEdited.Program_Rebates_Component_ID))>
              
              <cfloop from="1" to="#arrayLen(form.dgRebateInfo.bsa_id_uom_comp_id)#" index="current_product_number">
                <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
                <cfif variables.current_rebate_bsa_id_uom_comp_id EQ trim(replace(form.dgRebateInfo.bsa_id_uom_comp_id[current_product_number]," ","","ALL"))>
                   <cfset arrayAppend(variables.aRebateCustomerProductNumbers,trim(form.dgRebateInfo.customer_product_number[current_product_number]))>
                   <!--- let's break out of the inside loop IF we find a match... --->
                   <cfbreak>
                 </cfif>
              </cfloop>
                <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
                <cfif variables.qProgramRebateEdited.currentRow GT arrayLen(variables.aRebateCustomerProductNumbers)>
                  	<!--- if we have not found our perfect match yet, then we keep the pre-existing value at this point... --->
                    <cfset arrayAppend(variables.aRebateCustomerProductNumbers,variables.qProgramRebateEdited.customer_product_number[currentRow])>
                  </cfif>
              </cfloop>
              <cfloop query="variables.qProgramRebateEdited">
              	<!--- let's modify the values in our query container at this point, merging pre-existing with just edited... --->
              	<cfset querySetCell(variables.qProgramRebateEdited,"customer_product_number",variables.aRebateCustomerProductNumbers[variables.qProgramRebateEdited.currentRow],variables.qProgramRebateEdited.currentRow)>
				
				<!--- D18220: Adding Cutomer Product Number to Letters 
				Once we changed the generate_program_pdf file to use temp table instead of the query getting passed,
				what ever change we do to the query qProgramRebateEdited will not be accounted fro while generating the pdf.
				So we will need to make teh changes in the temp table ##TMP_Rebate_Price_Details
				--->
				<cfquery name="var_qUpdateTempTable" datasource="#application.datasource#">
					UPDATE	##TMP_Rebate_Price_Details
					SET		customer_product_number = '#variables.aRebateCustomerProductNumbers[variables.qProgramRebateEdited.currentRow]#'
					WHERE	Program_Rebates_Component_ID = '#variables.qProgramRebateEdited.Program_Rebates_Component_ID#'
					AND		BSA_Foodservice_Items_Master_ID = '#variables.qProgramRebateEdited.BSA_Foodservice_Items_Master_ID#'
				</cfquery>
              </cfloop>
          </cfif>
        <cfelse>
        	<!--- all set --->  
        </cfif>
      <cfelse>
        	<!--- all set --->  
      </cfif>
    <cfelse>
        	<!--- all set --->  
    </cfif>
    <!--- 4.) FROM FORM - Rebate... [end] --->

    <!--- 4.) FROM FORM - Lumpsum... [begin] --->
		<cfif variables.stPDFBodyInfo.bDisplayLumpSum>
      <cfif structKeyExists(form,"dgLumpsumInfo.customer_product_number") AND structkeyExists(form,"dgLumpsumInfo.bsa_id_comp_id")>
        <cfif isArray(form.dgLumpsumInfo.customer_product_number) AND isArray(form.dgLumpsumInfo.bsa_id_comp_id)>
          <cfif arrayLen(form.dgLumpsumInfo.customer_product_number) EQ arrayLen(form.dgLumpsumInfo.bsa_id_comp_id)>
            <!--- let's pour our incoming customer_product_number into a container... --->
            <cfset variables.aLumpsumCustomerProductNumbers 	= arrayNew(1)>
            <cfloop query="variables.qProgramLumpsumEdited">
            
              <cfset variables.current_lumpsum_bsa_id_comp_id = trim(variables.qProgramLumpsumEdited.BSA_Foodservice_Items_Master_ID) & '_'& trim(toString(variables.qProgramLumpsumEdited.Program_Lump_Sum_ID))>
              
              <cfloop from="1" to="#arrayLen(form.dgLumpsumInfo.bsa_id_comp_id)#" index="current_product_number">
                <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
                <cfif variables.current_Lumpsum_bsa_id_comp_id EQ trim(replace(form.dgLumpsumInfo.bsa_id_comp_id[current_product_number]," ","","ALL"))>
                   <cfset arrayAppend(variables.aLumpsumCustomerProductNumbers,trim(form.dgLumpsumInfo.customer_product_number[current_product_number]))>
                   <!--- let's break out of the inside loop IF we find a match... --->
                   <cfbreak>
                 </cfif>
              </cfloop>
                <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
                <cfif variables.qProgramLumpsumEdited.currentRow GT arrayLen(variables.aLumpsumCustomerProductNumbers)>
                  	<!--- if we have not found our perfect match yet, then we keep the pre-existing value at this point... --->
                    <cfset arrayAppend(variables.aLumpsumCustomerProductNumbers,variables.qProgramLumpsumEdited.customer_product_number[currentRow])>
                  </cfif>
              </cfloop>

              <cfloop query="variables.qProgramLumpsumEdited">
              	<!--- let's modify the values in our query container at this point, merging pre-existing with just edited... --->
              	<cfset querySetCell(variables.qProgramLumpsumEdited,"customer_product_number",variables.aLumpsumCustomerProductNumbers[variables.qProgramLumpsumEdited.currentRow],variables.qProgramLumpsumEdited.currentRow)>
				
				<!--- Adding Cutomer Product Number to Letters 
				Once we changed the generate_program_pdf file to use temp table instead of the query getting passed,
				what ever change we do to the query qProgramLumpsumEdited might not be accounted for while generating the pdf.
				So we will need to make the changes in the temp table ##TMP_LumpSum_Details
				--->
				<cfquery name="var_qUpdateTempTable" datasource="#application.datasource#">
					UPDATE	##TMP_LumpSum_Details
					SET		customer_product_number = '#variables.aLumpsumCustomerProductNumbers[variables.qProgramLumpsumEdited.currentRow]#'
					WHERE	Program_Lump_Sum_ID = '#variables.qProgramLumpsumEdited.Program_Lump_Sum_ID#'
					<!--- When we have product in the lumpsum. Some programs have lumpsum without products --->
					<cfif variables.qProgramLumpsumEdited.BSA_Foodservice_Items_Master_ID neq "">
					AND	BSA_Foodservice_Items_Master_ID = '#variables.qProgramLumpsumEdited.BSA_Foodservice_Items_Master_ID#'
					</cfif>
				</cfquery>
              </cfloop>
          </cfif>
        <cfelse>
        	<!--- all set --->  
        </cfif>
      <cfelse>
        	<!--- all set --->  
      </cfif>
    <cfelse>
        	<!--- all set --->  
    </cfif>
    <!--- 4.) FROM FORM - Lumpsum... [end] --->
			
    <!--- 5.) FROM FORM - Bid Request... [begin] --->
		<cfif variables.stPDFBodyInfo.bDisplayBidRequest>
			<cfif structKeyExists(form,"dgBidRequestInfo.customer_product_number") AND structkeyExists(form,"dgBidRequestInfo.bsa_id_uom_comp_id")>
        <cfif isArray(form.dgBidRequestInfo.customer_product_number) AND isArray(form.dgBidRequestInfo.bsa_id_uom_comp_id)>
          <cfif arrayLen(form.dgBidRequestInfo.customer_product_number) EQ arrayLen(form.dgBidRequestInfo.bsa_id_uom_comp_id)>
            <!--- let's pour our incoming customer_product_number into a container... --->
            <cfset variables.aBidRequestCustomerProductNumbers 	= arrayNew(1)>
            <cfloop query="variables.qProgramBidRequestEdited">
            
              <cfset variables.current_bidRequest_bsa_id_uom_comp_id = trim(variables.qProgramBidRequestEdited.BSA_Foodservice_Items_Master_ID) & '_' & trim(variables.qProgramBidRequestEdited.abbreviation) & '_' & trim(toString(variables.qProgramBidRequestEdited.Program_Bid_Component_ID))>
              
                <cfloop from="1" to="#arrayLen(form.dgBidRequestInfo.bsa_id_uom_comp_id)#" index="current_product_number">
                  <!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
                  <cfif variables.current_bidRequest_bsa_id_uom_comp_id EQ trim(replace(form.dgBidRequestInfo.bsa_id_uom_comp_id[current_product_number]," ","","ALL"))>
                     <cfset arrayAppend(variables.aBidRequestCustomerProductNumbers,trim(form.dgBidRequestInfo.customer_product_number[current_product_number]))>
                     <!--- let's break out of the inside loop IF we find a match... --->
                     <cfbreak>
                   </cfif>
                </cfloop>
								<!--- IMPORTANT: 'string' BSA_ID compared to list from XML above [concatenating for unique row identifier HERE] --->
                <cfif variables.qProgramBidRequestEdited.currentRow GT arrayLen(variables.aBidRequestCustomerProductNumbers)>
                  	<!--- if we have not found our perfect match yet, then we keep the pre-existing value at this point... --->
                    <cfset arrayAppend(variables.aBidRequestCustomerProductNumbers,variables.qProgramBidRequestEdited.customer_product_number[currentRow])>
                  </cfif>
              </cfloop>
              <cfloop query="variables.qProgramBidRequestEdited">
              	<!--- let's modify the values in our query container at this point, merging pre-existing with just edited... --->
              	<cfset querySetCell(variables.qProgramBidRequestEdited,"customer_product_number",variables.aBidRequestCustomerProductNumbers[variables.qProgramBidRequestEdited.currentRow],variables.qProgramBidRequestEdited.currentRow)>
              </cfloop>
          </cfif>
        <cfelse>
        	<!--- all set --->  
        </cfif>
      <cfelse>
        	<!--- all set --->  
      </cfif>
    <cfelse>
        	<!--- all set --->  
    </cfif>
    <!--- 5.) FROM FORM - Bid Request... [end] --->  

  </cfif>



  <!--- Let's add a customer_product_number if environment calls for it... [end] --->

  <!--- ===============  FROM EDIT FORM =======================
	============== Customer Product Numbers [end] ===============
	======================================================== --->

	<!--- V.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <cfdump var="#variables.lsPostFormDisplayDistributorOn#">1 DISTRIBUTOR KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <cfdump var="#variables.lsPostFormDisplayOperatorOn#">2 OPERATOR KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <cfdump var="#variables.lsPostFormDisplayFixedPriceOn#">3 FIXED PRICE KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <cfdump var="#variables.lsPostFormDisplayRebateOn#">4 REBATE KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <!---
	<cfdump var="#variables.lsPostFormDisplayBidRequestOn#">5 BID REQUEST KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br /> NA
	--->
  <cfdump var="#variables.lsPostFormDisplayLumpSumOn#">6 LUMP SUM KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <!--- Note: 7.) Growth On Deck --->
  <cfdump var="#variables.lsPostFormDisplayClauseOn#">8 CLAUSE KEEP [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  ////////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->
  
  <!--- VI.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <cfdump var="#variables.lsPostFormDisplayDistributorOff#">1 DISTRIBUTOR REMOVE [False] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <cfdump var="#variables.lsPostFormDisplayOperatorOff#">2 OPERATOR REMOVE [False] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <cfdump var="#variables.lsPostFormDisplayFixedPriceOff#">3 FIXED PRICE REMOVE [False] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <cfdump var="#variables.lsPostFormDisplayRebateOff#">4 REBATE REMOVE [False] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  <!---
	<cfdump var="#variables.lsBidRequestRemove#">5 BID REQUEST REMOVE [False] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br /> NA
	--->
  <cfdump var="#variables.lsPostFormDisplayLumpSumOff#">6 LUMP SUM REMOVE [False] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br /> 
  <!--- Note: 7.) Growth On Deck --->
  <cfdump var="#variables.lsPostFormDisplayClauseOff#">8 CLAUSE REMOVE [True] List Comparing NET Query From FORM to Submitted FORM Changes for THIS Letter<br />
  ////////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->
  
  <!--- VII.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
  <cfdump var="#variables.qProgramDistributorEdited#" label="1 DISTRIBUTOR FINAL NET NET variables.qProgramDistributorEdited to generate NET Edited Letter NOW">
  <cfdump var="#variables.qProgramOperatorEdited#" label="2 OPERATOR FINAL NET NET variables.qProgramOperatorEdited to generate NET Edited Letter NOW">
  <cfdump var="#variables.qProgramFixedPriceEdited#" label="3 FIXED PRICE FINAL NET NET variables.qProgramFixedPriceEdited to generate NET Edited Letter NOW">
  <cfdump var="#variables.qProgramRebateEdited#" label="4 REBATE FINAL NET NET variables.qProgramRebateEdited to generate NET Edited Letter NOW">
  <!---
	<cfdump var="#variables.qProgramBidRequestEdited#" label="5 BID REQUEST FINAL NET NET variables.qProgramBidRequestEdited to generate NET Edited Letter NOW"> NA
	--->
  <cfdump var="#variables.qProgramLumpSumEdited#" label="6 LUMP SUM FINAL NET NET variables.qProgramLumpSumEdited to generate NET Edited Letter NOW">
  <!--- Note: 7.) Growth On Deck --->
  <cfdump var="#variables.qProgramClauseEdited#" label="8 CLAUSE FINAL NET NET variables.qProgramClauseEdited to generate NET Edited Letter NOW">
  <cfabort>
	////////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->
  
	<!--- ====================================================================
	============ OK... let's reinvent ourselves NOW... [end] =================
	======================================================================--->
	<!--- in display order The Magnificent 7 --->
	<cfparam name="variables.qProgramDistributorEdited"	type="query"	default="#queryNew('Name')#">
	<cfparam name="variables.qProgramOperatorEdited"	type="query"	default="#queryNew('Operator_Name')#">
	<cfparam name="variables.qProgramFixedPriceEdited"	type="query"	default="#queryNew('fixed_price')#">
  	<cfparam name="variables.qProgramRebateEdited"		type="query"	default="#queryNew('rebate')#">
	<cfparam name="variables.qProgramBidRequestEdited"	type="query"	default="#queryNew('bid_request')#">
	<cfparam name="variables.qProgramLumpSumEdited"		type="query"	default="#queryNew('lump_sum')#">
    <cfparam name="variables.qProgramClauseEdited"		type="query"	default="#queryNew('clause')#">
  	<!--- Note: 'Growth' On Deck 7 --->

	<!--- We will no longer be editing the Clause section in the edit form, so let's just pass the value right through for the edited letter... [begin] --->
    <cfset variables.qProgramClauseEdited = variables.qProgramClauseInitial>
    <!--- We will no longer be editing the Clause section in the edit form, so let's just pass the value right through for the edited letter... [end] --->

	<!--- IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
	IIIIIIIII Let's create a watermark image [begin] IIIIIIIIII
	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII --->
	
	<!--- <cfdump var="#getFileFromPath(application.appsettingsget.letters_company_logo_path)#" label="getFileFromPath(application.appsettingsget.letters_company_logo_path)">
	<cfdump var="#expandPath(application.appsettingsget.letters_company_logo_path)#" label="expandPath(application.appsettingsget.letters_company_logo_path)">
	<cfabort> --->
	
	<!--- IF we already have a .jpg... --->
	<cfif listLast(application.appsettingsget.letters_company_logo_path,'.') EQ 'jpg'>
	
		<!--- use original .jpg as watermark... --->
		<cfset variables.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
		
	<!--- IF we originally have a .gif, convert it to a .jpg and write the image to the file system... --->  
	<cfelseif listLast(application.appsettingsget.letters_company_logo_path,'.') EQ 'gif'>
	
		<cfimage
			action="convert"
			source="#expandPath(application.appsettingsget.letters_company_logo_path)#"
			destination="#replace(expandPath(application.appsettingsget.letters_company_logo_path),'gif','jpg','all')#"
			overwrite="true">
	
		<cfset variables.watermark_image = replace(getFileFromPath(application.appsettingsget.letters_company_logo_path),'gif','jpg','all')>
	
	<!--- IF we originally have a .png, convert it to a .jpg and write the image to the file system... --->  
	<cfelseif listLast(application.appsettingsget.letters_company_logo_path,'.') EQ 'png'>
	
		<cfimage
			action="convert"
			source="#expandPath(application.appsettingsget.letters_company_logo_path)#"
			destination="#replace(expandPath(application.appsettingsget.letters_company_logo_path),'png','jpg','all')#"
			overwrite="true">
	
		<cfset variables.watermark_image = replace(getFileFromPath(application.appsettingsget.letters_company_logo_path),'png','jpg','all')>
		
	<!--- IF we have a file other than a .jpg or a .gif or it is undefined at the moment... --->  
	<cfelse>
	
		<cfset variables.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
	
	</cfif>
	
	<!--- IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
	IIIIIIIII Let's create a watermark image [end] IIIIIIIIIIII
	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII --->

	<!--- D16774 8/14/08 [begin]
	<!--- Get info for initial Doc [begin] --->
	<cfset useLakebaseForvariables_qGetLetterInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForvariables_qGetLetterInfo>
	<cftry>
		<cfset variables.qGetLetterInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#form.prior_program_letter_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qGetLetterInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qGetLetterInfo>
<cfquery name="variables.qGetLetterInfo" datasource="#application.datasource#">
	  SELECT 			*
	  FROM 				program_letters
	  WHERE 			program_letters.program_letters_id = #form.prior_program_letter_id# 
	</cfquery>
</cfif>
	<!--- Get info for initial Doc [end] --->
	--->
	<cfset variables.qGetLetterInfo = application.oLetterManager.getAllLetterInfo(form.prior_program_letter_id)>
	<!--- D16774 8/14/08 [end] --->
  
	<!--- set preferred fontFamily [CSS syntax] to be embedded in all pdf docs generated here...
	NOTE: [must be resident on user's client machine at time of pdf creation] --->
	<!---
	<cfset variables.preferred_fontFamily = "Century Gothic">
	--->
	
	<!--- TO DELETE #request.AccessStructure.user_id#_edited_ --->
  
	<!--- OK, we need to reidentify the variable - nameformat... --->
  <cfif findNoCase("system_generated",variables.qGetLetterInfo.letter_path[1],1)>
  
		<!--- IF this is the first edit of an original document... [either way] (we always retain the original name and date, since everything starts from there) --->
    <cfset variables.nameformat = replace(reReplaceNoCase(getFileFromPath(variables.qGetLetterInfo.letter_path[1]),"_system_generated(.*)","_edited_#dateformat(now(),"mm_dd_yyyy")#_#timeformat(now(),"hh_mm_sstt")#","all"),".htm","")>
  
  <cfelseif findNoCase("edited",variables.qGetLetterInfo.letter_path[1],1)>
  
		<!--- IF this is a subsequent edit of a document edited prior... [either way] (we always retain the original name and date, since everything starts from there) --->
		<cfset variables.nameformat = replace(reReplaceNoCase(getFileFromPath(variables.qGetLetterInfo.letter_path[1]),"_edited(.*)","_edited_#dateformat(now(),"mm_dd_yyyy")#_#timeformat(now(),"hh_mm_sstt")#","all"),".htm","")>
  
  </cfif>
  
<cfset variables.relative_url = replace(form.relative_path,'\','/','all')>
<cfset variables.nameformat = replace(variables.nameformat,'-','_','all')>
<cfset variables.nameformat = replace(variables.nameformat,'/','_','all')>
<cfset variables.nameformat = replace(variables.nameformat,'\','_','all')>
<cfset variables.nameformat = replace(variables.nameformat,'(','_','all')>
<cfset variables.nameformat = replace(variables.nameformat,')','_','all')>
<cfset variables.nameformat = replace(variables.nameformat,',','','all')>
<cfset variables.nameformat = replace(variables.nameformat,'&','','all')>
<cfset variables.nameformat = replace(variables.nameformat,'.','','all')>
<cfset variables.nameformat = replace(variables.nameformat,'''','','all')>
<cfset variables.nameformat = replace(variables.nameformat,'##','','all')>
<cfset variables.nameformat = replace(variables.nameformat,' ','','all')>
<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & form.program_id & "/" & variables.nameformat & ".htm">
<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
<cfset variables.html_file_path = lCase(variables.html_file_path)>

	<cfif findNoCase("operators",form.relative_path,1)>
		<cfset variables.letter_type = 1>
	<cfelseif findNoCase("distributors",form.relative_path,1)>
		<cfset variables.letter_type = 2>
	</cfif>

		<!--- HTML off off off   > DO NOT DELETE THIS BLOCK <  off off off  HTML off
		off off off off | Let's turn OFF the HTML Version for now  [BEGIN] | off off
		off off off off off off off off off off off off off off off off off off  off
		--->
		 <!--- CREATE HTML of our Edited doc including Revised Doc Title... --->
		 <!---
     <cfsavecontent variable = "DealLetterContent">
       <cf_generate_program_html
       			bAddcustomerproductnumbers="#form.bAddcustomerproductnumbers#"
						bLetterDisplayFreight="#form.bLetterDisplayFreight#"
            bIncludeVolumePage="#form.bIncludeVolumePage#"
						bInsertWatermark="#form.bInsertWatermark#"
            CMID="#CSL_Contract_Main_ID#"
            consignee="#form.consignee#"
						customerFreightUom="#form.customerFreightUom#"
            file_name="#variables.nameformat#"
            lsContractMainIDs="#List_Of_Contract_Main_IDs#"
            lsDistributorNames="#valueList(variables.qProgramDistributorEdited.name,', ')#"
            lsDistributorIDs="#valueList(variables.qProgramDistributorEdited.contract_distributors_id,',')#" 
            lsOperatorNames="#valueList(variables.qProgramOperatorEdited.operator_name,', ')#"
            lsOperatorIDs="#valueList(variables.qProgramOperatorEdited.operator_id,',')#" 
						oAppSettings="#appsettings#"
           <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
            qGetLetterSettings="#getlettersettings#"
            qGetProgramDetails="#getprogramdetails#"
            qGetTemplateSettings="#gettemplatesettings#"
            qProgramBidRequest="#variables.qProgramBidRequestEdited#"
            qProgramClause="#variables.qProgramClauseEdited#"
            qProgramDistributor="#variables.qProgramDistributorEdited#"
            qProgramFixedPrice="#variables.qProgramFixedPriceEdited#"
            qProgramLumpSum="#variables.qProgramLumpSumEdited#"
            qProgramOperator="#variables.qProgramOperatorEdited#"
            qProgramRebate="#variables.qProgramRebateEdited#"											
            relative_path="#form.relative_path#"
            revised_doc_title="#form.revised_doc_title#"
            stPDFBodyInfo="#variables.stPDFBodyInfo#"
            stPDFEndInfo="#variables.stPDFEndInfo#"
            stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
            stPDFIntroInfo="#variables.stPDFIntroInfo#">
     </cfsavecontent>
   
    <cf_writing_email_attachment
        Naming_Format="#variables.nameformat#"
        File_Extension="htm"
        Relative_Path="#form.relative_path#"
        iscustomerletter = "1"
        isletter_system_generated = "0"
        folder_name="#CSL_Contract_Main_ID#"
        Output_Content="#DealLetterContent#"
        addNewLine="No"
        Return_File_Name="fName"
        Return_Letter_Name="lname">

		HTML off off off off off off off off off off off off off off off HTML off
		off off off off | Let's turn OFF the HTML version for now [END] off   off
		off off off off off off off off off off off off off off off off off  --->

    <!--- ACTION: TO DELETE watermark_image="#getFileFromPath(application.appsettingsget.letters_company_logo_path)#" --->		
	
  	<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
		XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

  	<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
  	<!--- INSERT record of our Edited doc... --->
  	<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
       	INSERT INTO	Program_Letters
      	(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,distributor_id,created_by,system_generated,Claim_Rates_Date)
       	values
      	(#CSL_Contract_Main_ID#,#variables.letter_type#,'#variables.nameformat#','#variables.html_file_path#',
        '#form.operator_name#','#form.distributor_name#','#distributor_id#','#user_id#',0,<cfif bShowClaimRateDate AND IsDefined("form.claim_rate_date") AND form.claim_rate_date NEQ "">'#form.claim_rate_date#'<cfelse>null</cfif>)
   	</cfquery>

    <!--- D16774 8/14/08 [begin]
    <!--- B.) Let's idemtify our new Program Letter ID... --->
    <cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
        SELECT  	MAX(Program_Letters_ID) AS new_letter_id
        FROM 			Program_Letters
        WHERE			deleted = 0
    </cfquery>
    --->
    <cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
	<!--- D16774 8/14/08 [end] --->
    

 <cfif bShowClaimRateDate AND IsDefined("form.claim_rate_date") AND form.claim_rate_date NEQ "">
    <!--- CREATE PDF of our Edited doc including Revised Doc Title... --->
    <!--- The only extra argument is "claimRateDate" --->
    <cf_generate_program_pdf
    	bAddcustomerproductnumbers="#form.bAddcustomerproductnumbers#"
        bLetterDisplayFreight="#form.bLetterDisplayFreight#"
        bIncludeVolumePage="#form.bIncludeVolumePage#"
        bInsertWatermark="#form.bInsertWatermark#"
        CMID="#CSL_Contract_Main_ID#"
        consignee="#form.consignee#"
        customerFreightUom="#form.customerFreightUom#"
        file_name="#variables.nameformat#"
        lsContractMainIDs="#List_Of_Contract_Main_IDs#"
        current_program_letter_id="#variables.currentLetterID#"
        lsDistributorNames="#valueList(variables.qProgramDistributorEdited.name,', ')#"
        lsDistributorIDs="#valueList(variables.qProgramDistributorEdited.contract_distributors_id,',')#" 
        lsOperatorNames="#valueList(variables.qProgramOperatorEdited.operator_name,', ')#"
        lsOperatorIDs="#valueList(variables.qProgramOperatorEdited.operator_id,',')#"
        oAppSettings="#appsettings#"
        pages_to_delete_from_prior_letter="#form.pages_to_delete_from_prior_letter#"
        pages_to_delete_from_this_letter="#form.pages_to_delete_from_this_letter#"
        <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
        qGetLetterSettings="#getlettersettings#"
        qGetProgramDetails="#getprogramdetails#"
        qGetTemplateSettings="#gettemplatesettings#"
        qProgramBidRequest="#variables.qProgramBidRequestEdited#"
        qProgramClause="#variables.qProgramClauseEdited#"
        qProgramDistributor="#variables.qProgramDistributorEdited#"
        qProgramFixedPrice="#variables.qProgramFixedPriceEdited#"
        qProgramLumpSum="#variables.qProgramLumpSumEdited#"
        qProgramOperator="#variables.qProgramOperatorEdited#"
        qProgramRebate="#variables.qProgramRebateEdited#"											
	qProgramClaimRates="#variables.qProgramClaimRatesReport#"   
        relative_path="#form.relative_path#"
        revised_doc_title="#form.revised_doc_title#"
        stPDFBodyInfo="#variables.stPDFBodyInfo#"
        stPDFEndInfo="#variables.stPDFEndInfo#"
        stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
        stPDFIntroInfo="#variables.stPDFIntroInfo#"
        watermark_image="#variables.watermark_image#"
	claimRateDate = "#form.claim_rate_date#">
<cfelse>
    <cf_generate_program_pdf
    	bAddcustomerproductnumbers="#form.bAddcustomerproductnumbers#"
        bLetterDisplayFreight="#form.bLetterDisplayFreight#"
        bIncludeVolumePage="#form.bIncludeVolumePage#"
        bInsertWatermark="#form.bInsertWatermark#"
        CMID="#CSL_Contract_Main_ID#"
        consignee="#form.consignee#"
        customerFreightUom="#form.customerFreightUom#"
        file_name="#variables.nameformat#"
        lsContractMainIDs="#List_Of_Contract_Main_IDs#"
        current_program_letter_id="#variables.currentLetterID#"
        lsDistributorNames="#valueList(variables.qProgramDistributorEdited.name,', ')#"
        lsDistributorIDs="#valueList(variables.qProgramDistributorEdited.contract_distributors_id,',')#" 
        lsOperatorNames="#valueList(variables.qProgramOperatorEdited.operator_name,', ')#"
        lsOperatorIDs="#valueList(variables.qProgramOperatorEdited.operator_id,',')#"
        oAppSettings="#appsettings#"
        pages_to_delete_from_prior_letter="#form.pages_to_delete_from_prior_letter#"
        pages_to_delete_from_this_letter="#form.pages_to_delete_from_this_letter#"
        <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
        qGetLetterSettings="#getlettersettings#"
        qGetProgramDetails="#getprogramdetails#"
        qGetTemplateSettings="#gettemplatesettings#"
        qProgramBidRequest="#variables.qProgramBidRequestEdited#"
        qProgramClause="#variables.qProgramClauseEdited#"
        qProgramDistributor="#variables.qProgramDistributorEdited#"
        qProgramFixedPrice="#variables.qProgramFixedPriceEdited#"
        qProgramLumpSum="#variables.qProgramLumpSumEdited#"
        qProgramOperator="#variables.qProgramOperatorEdited#"
        qProgramRebate="#variables.qProgramRebateEdited#"											
	qProgramClaimRates="#variables.qProgramClaimRatesReport#"   
        relative_path="#form.relative_path#"
        revised_doc_title="#form.revised_doc_title#"
        stPDFBodyInfo="#variables.stPDFBodyInfo#"
        stPDFEndInfo="#variables.stPDFEndInfo#"
        stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
        stPDFIntroInfo="#variables.stPDFIntroInfo#"
        watermark_image="#variables.watermark_image#">
</cfif>
    
    <!--- CREATE XML of our Edited doc including Revised Doc Title... --->
    <cf_generate_program_xml
    	bAddcustomerproductnumbers="#form.bAddcustomerproductnumbers#"
        bLetterDisplayFreight="#form.bLetterDisplayFreight#"
        bIncludeVolumePage="#form.bIncludeVolumePage#"
        bInsertWatermark="#form.bInsertWatermark#"
        CMID="#CSL_Contract_Main_ID#"
        consignee="#form.consignee#"
        customerFreightUom="#form.customerFreightUom#"
        file_name="#variables.nameformat#"
        prior_program_letter_id="#form.prior_program_letter_id#"
        current_program_letter_id="#variables.currentLetterID#"
        lsDistributorNames="#valueList(variables.qProgramDistributorEdited.name,', ')#"
        lsDistributorIDs="#valueList(variables.qProgramDistributorEdited.contract_distributors_id,',')#" 
        lsOperatorNames="#valueList(variables.qProgramOperatorEdited.operator_name,', ')#"
        lsOperatorIDs="#valueList(variables.qProgramOperatorEdited.operator_id,',')#"
        pages_to_delete_from_prior_letter="#form.pages_to_delete_from_prior_letter#"
        pages_to_delete_from_this_letter="#form.pages_to_delete_from_this_letter#"	
        qGetLetterSettings="#getlettersettings#"
        qGetProgramDetails="#getprogramdetails#"
        qGetTemplateSettings="#gettemplatesettings#"
        qProgramBidRequest="#variables.qProgramBidRequestEdited#"
        qProgramClause="#variables.qProgramClauseEdited#"
        qProgramDistributor="#variables.qProgramDistributorEdited#"
        qProgramFixedPrice="#variables.qProgramFixedPriceEdited#"
        qProgramLumpSum="#variables.qProgramLumpSumEdited#"
        qProgramOperator="#variables.qProgramOperatorEdited#"
        qProgramRebate="#variables.qProgramRebateEdited#"									
		qProgramClaimRates="#variables.qProgramClaimRatesReport#"
        relative_path="#form.relative_path#"
        revised_doc_title="#form.revised_doc_title#"
        stPDFBodyInfo="#variables.stPDFBodyInfo#"
        stPDFEndInfo="#variables.stPDFEndInfo#"
        stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
        stPDFIntroInfo="#variables.stPDFIntroInfo#">

		<!--- D16774 8/14/08 [begin]
		<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
        <cfset useLakebaseForqUpdateXML = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForqUpdateXML>
	<cftry>
		<cfset application.oLakebase.updateRows("program_letters",
			{
				"program_letters_id" = "eq.#variables.currentLetterID#"
			},
			{
				"letter_xml" = "#trim(request.sProgramLetterXML)#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateXML = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateXML>
<cfquery name="qUpdateXML" datasource="#application.datasource#">
            UPDATE	Program_Letters
            SET 	Letter_xml = '#trim(request.sProgramLetterXML)#'
            WHERE 	Program_Letters_ID = #variables.currentLetterID#
        </cfquery>
</cfif>
		--->
        <cfinvoke 
                component="#application.oLetterManager#" 
                method="updateLetterXML"
                program_letter_id="#variables.currentLetterID#"
                sProgramLetterXML="#trim(request.sProgramLetterXML)#">
		<!--- D16774 8/14/08 [end] --->

		<!--- ================================================================================
		================= NOTICATION OF EDITED GENERATION OF LETTERS [begin] =================
		================================================================================= --->
		<cfif getLetterSettings.notification_type EQ 2>
			<cflocation url="#includeLettersFilename#?CID=#url.CMID#">
		<cfelse>
			<cfset useLakebaseForqgetUseremail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqgetUseremail>
	<cftry>
		<cfset qgetUseremail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#URL.user_id#",
				"deleted" = "eq.0",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetUseremail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetUseremail>
<cfquery name="qgetUseremail" datasource="#application.datasource#">
					select user_email
					from _users
					where user_id = '#URL.user_id#'
					and deleted = 0
			</cfquery>
</cfif>
			
			<!--- Question: IF we do NOT identify the query, we will only get the first row. Is this desired? RBL --->
      
		  <cfif qgetUseremail.recordCount>
		<!--- By using "programLettersEmail=1", the logic for "from" and "replyTo" is populated on "EmailWrapper.cfm"  --->
              <CF_EMAILWRAPPER 
                  TO			=	"#qgetUseremail.user_email#"
                  FROM		=	"#qgetUseremail.user_email#"
                  SUBJECT		=	"#appSettings.getletterssubject()#"
                  TYPE		=	"html" 
                  messagetype="1" 
                  generatedby="2"
                  appArea="1"
		  programLettersEmail="1"
              >
                  Your initial letter(s) are generated and ready to view.	
              </CF_EMAILWRAPPER>
          </cfif>
        
		</cfif>
		<!--- ================================================================================
		================= NOTICATION OF EDITED GENERATION OF LETTERS [begin] =================
		================================================================================= --->

		<cfset variables.msg = "#form.program_id# Edited #form.letter_type# Doc #form.prior_program_letter_id# #form.revised_doc_title# Created">
  
  	<cflocation url="#includeLettersFilename#?msg=#variables.msg#&CID=#form.program_id#">

</cfif>

</cfoutput>
<cfabort>