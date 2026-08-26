<cfsilent>
<!---
FILE: 			Generate Program XML
FILENAME:   generate_program_xml.cfm
CREATED: 		12/31/2007 - RBL
EDITED:			08/15/2008 - RBL

FUNCTIONALITY:
- 	This CF8 custom tag generates an xml file representing program.

LEGEND:
Bid Request 		should always be in Program_Bidrequest_Component_Id,Program_Bidrequest_Component_Paid_to,item ORDER
Fixed Price 		should always be in Program_Fixed_Component_Id,Fixed_Component_Paid_to,item ORDER
Lump Sum Items	should always be in item ORDER
Rebate 					should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER
--->

<!--- ||| These parameters [in alpha] are required for this template to process correctly --->

<!--- we're gonna need a bigger boat... request timeout in seconds 1200=20min---->
<cfsetting requesttimeout="1200">

<!--- CSL_Contract_Main_ID for folder_name --->
<cfparam name="attributes.CMID" 										type="numeric" 	default="0">

<!--- nameformat --->
<cfparam name="attributes.file_name" 									type="string" 	default="">

<!--- queries from the VARS Include for scoping... [begin] --->
<cfparam name="attributes.qGetLetterSettings" 							type="query" 		default="#queryNew('Letter_Settings')#">
<cfparam name="attributes.qGetProgramDetails" 							type="query" 		default="#queryNew('Program_Details')#">
<cfparam name="attributes.qGetTemplateSettings" 						type="query" 		default="#queryNew('Template_Settings')#">
<!--- The Magnificent 7 --->
<cfparam name="attributes.qProgramBidRequest"							type="query" 		default="#queryNew('Bid_Request')#">
<cfparam name="attributes.qProgramClause"								type="query" 		default="#queryNew('Clause')#">
<cfparam name="attributes.qProgramDistributor"							type="query" 		default="#queryNew('Distributor')#">
<cfparam name="attributes.qProgramFixedPrice"							type="query" 		default="#queryNew('Fixed_Price')#">
<cfparam name="attributes.qProgramLumpSum"								type="query" 		default="#queryNew('Lump_Sum')#">
<cfparam name="attributes.qProgramOperator"								type="query" 		default="#queryNew('Operator')#">
<cfparam name="attributes.qProgramRebate"								type="query" 		default="#queryNew('Rebate')#">
<!--- queries from the VARS Include for scoping... [end] --->

<!--- opr_path OR dis_path --->
<cfparam name="attributes.relative_path" 								type="string" 	default="">

<!--- BODY structure [all boolean] --->
<cfparam name="attributes.stPDFBodyInfo" 								type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequest" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPrice" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayGrowth" 				type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSum" 				type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebate" 				type="boolean"	default="0">

<!--- D16586 [begin] not used for xml as of 8/8/08 --->
<cfparam name="attributes.stPDFBodyInfo.bTemplateAllowFreightLetters" type="boolean"	default="0">
<!--- D16586 [end] --->

<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequestDis" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequestOpr" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPriceDis" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPriceOpr" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSumDis" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSumOpr" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebateDis" 				type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebateOpr" 				type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bDisLettersRequired" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisPaysToDistributor" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisPaysToOperator" 			type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bOprLettersRequired" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOprPaysToDistributor" 			type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOprPaysToOperator" 			type="boolean"	default="0">

<!--- header structure [all strings on purpose] --->
<cfparam name="attributes.stPDFHeaderInfo" 								type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFHeaderInfo.contract_number" 				type="string" 	default="">

<!--- NO Footer struct... --->

<!--- intro structure --->
<cfparam name="attributes.stPDFIntroInfo" 								type="struct" 	default="#structNew()#">
<!--- <cfparam name="attributes.stPDFIntroInfo.company" 				type="string" 	default=""> --->
<cfparam name="attributes.stPDFIntroInfo.contract_end_date" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_start_date" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.program_payment_frequency" 	type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.program_pricing_type" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.qNotes" 						type="query" 		default="#queryNew('contract_evaluation_notes_id')#">

<cfparam name="attributes.bAddcustomerproductnumbers"					type="boolean" 	default="0">
<cfparam name="attributes.bLetterDisplayFreight"						type="boolean"	default="0">
<cfparam name="attributes.bIncludeVolumePage"							type="boolean" 	default="0">
<cfparam name="attributes.bInsertWatermark"								type="boolean" 	default="0">
<cfparam name="attributes.customerFreightUom"							type="string"		default="">

<cfparam name="attributes.pages_to_delete_from_prior_letter"			type="string"		default="">
<cfparam name="attributes.pages_to_delete_from_this_letter"				type="string"		default="">

<cfparam name="attributes.consignee"									type="string" 	default="">
<cfparam name="attributes.current_program_letter_id" 					type="numeric" 	default="0">
<cfparam name="attributes.prior_program_letter_id" 						type="numeric" 	default="0">
<cfparam name="attributes.revised_doc_title" 							type="string" 	default="">

<cfparam name="attributes.lsDistributorNames" 							type="string" 	default="">
<cfparam name="attributes.lsDistributorIDs" 							type="string" 	default="">
<cfparam name="attributes.lsOperatorNames" 								type="string" 	default="">
<cfparam name="attributes.lsOperatorIDs" 								type="string" 	default="">

<!--- ||| Overwrite the default values with incoming... --->
<cfset structAppend(thisTag, attributes, true)>

<cfset thisTag.host 			= cgi.http_host />
<cfset thisTag.protocol 		= application.HTTPVar />

<cfif findNoCase("dist",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "dis">
<cfelseif findNoCase("oper",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "opr">
<cfelse>
  <!--- none on purpose... --->
</cfif>

<cfset thisTag.relative_url = replace(thisTag.relative_path,'\','/','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'-','_','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'&','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'.','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'''','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'##','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,' ','_','all')>
<cfset thisTag.xml_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.CMID & "/" & thisTag.file_name & ".xml">
<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
<cfset thisTag.xml_file_path = expandPath(thisTag.xml_file_path_string)>
<cfset thisTag.xml_file_path = lCase(thisTag.xml_file_path)>

</cfsilent>

<!--- HTML [begin] --->
<cfoutput>

<!--- || I.) Create xml file... --->
<cfxml variable="thisTag.xProgramLetter">
 <program program_id="#thisTag.stPDFHeaderInfo.program_id#" current_letter_id="#thisTag.current_program_letter_id#" prior_letter_id="#thisTag.prior_program_letter_id#" name="#Replace(thisTag.stPDFIntroInfo.template_name,'&',' ','ALL')#">
 	<consignee>#XmlFormat(thisTag.consignee)#</consignee>
 	<letter_title>#XmlFormat(thisTag.revised_doc_title)#</letter_title>
	<contract_number>#XmlFormat(thisTag.stPDFHeaderInfo.contract_number)#</contract_number>
	<contract_start_date>#XmlFormat(thisTag.stPDFIntroInfo.contract_start_date)#</contract_start_date>
	<contract_end_date>#XmlFormat(thisTag.stPDFIntroInfo.contract_end_date)#</contract_end_date>
  <program_payment_frequency>#XmlFormat(thisTag.stPDFIntroInfo.program_payment_frequency)#</program_payment_frequency>
  <program_pricing_type>#XmlFormat(thisTag.stPDFIntroInfo.program_pricing_type)#</program_pricing_type>
  <info>
  	<customer_freight_uom>#XmlFormat(thisTag.customerFreightUom)#</customer_freight_uom>
    <!--- D16586 concerns [begin] --->
  	<include_freight_page>#XmlFormat(thisTag.bLetterDisplayFreight)#</include_freight_page>
    <!--- D16586 concerns [end] --->
  	<include_volume_page>#XmlFormat(thisTag.bIncludeVolumePage)#</include_volume_page>
    <insert_watermark>#XmlFormat(thisTag.bInsertWatermark)#</insert_watermark>
    <pages_to_delete_from_prior_letter>#XmlFormat(thisTag.pages_to_delete_from_prior_letter)#</pages_to_delete_from_prior_letter>
    <pages_to_delete_from_this_letter>#XmlFormat(thisTag.pages_to_delete_from_this_letter)#</pages_to_delete_from_this_letter>
  	<program_letter_distributor_names>#XmlFormat(Replace(Replace(thisTag.lsDistributorNames,"É","E","ALL"),"’","'","ALL"))#</program_letter_distributor_names>
  	<program_letter_distributor_ids>#XmlFormat(thisTag.lsDistributorIDs)#</program_letter_distributor_ids>
  	<program_letter_operator_names>#XmlFormat(Replace(Replace(thisTag.lsOperatorNames,"É","E","ALL"),"’","'","ALL"))#</program_letter_operator_names>
  	<program_letter_operator_ids>#XmlFormat(thisTag.lsOperatorIDs)#</program_letter_operator_ids>
    <show_customer_product_numbers>#XmlFormat(thisTag.bAddcustomerproductnumbers)#</show_customer_product_numbers>
	</info>
	<!--- 1.) Distributors [begin] --->
		<cfif thisTag.qProgramDistributor.recordCount>
      <distributors>
        <cfloop query="thisTag.qProgramDistributor">
          <distributor>
            <bsa_id>#XmlFormat(thisTag.qProgramDistributor.bsa_foodservice_customers_id)#</bsa_id>
            <id>#XmlFormat(thisTag.qProgramDistributor.contract_distributors_id)#</id>
            <name>#XmlFormat(Replace(Replace(thisTag.qProgramDistributor.name,"É","E","ALL"),"’",""))#</name>
            <city>#XmlFormat(thisTag.qProgramDistributor.city)#</city>
            <state>#XmlFormat(thisTag.qProgramDistributor.state)#</state>
          </distributor>
        </cfloop>
      </distributors>
    </cfif>
	<!--- Distributors [end] --->
	<!--- 2.) Operators [begin] --->
  	<cfif thisTag.qProgramOperator.recordCount>
      <operators>
        <cfloop query="thisTag.qProgramOperator">
          <operator>
            <id>#XmlFormat(thisTag.qProgramOperator.operator_id)#</id>
            <name>#XmlFormat(Replace(Replace(thisTag.qProgramOperator.operator_name,"É","E","ALL"),"’","'","ALL"))#</name>
            <city>#XmlFormat(thisTag.qProgramOperator.operator_city)#</city>
            <state>#XmlFormat(thisTag.qProgramOperator.operator_state)#</state>
          </operator>
        </cfloop>
      </operators>
  	</cfif>
	<!--- Operators [end] --->
	<!--- 3.) Fixed Price [begin] --->
		<cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation)>
      <fixed_price>
          <cfloop query="thisTag.qProgramFixedPrice">
          	<cfset thisTag.current_FixedPriceBsaID_UOM_CompID = thisTag.qProgramFixedPrice.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramFixedPrice.abbreviation&'_'&thisTag.qProgramFixedPrice.Program_Fixed_Component_ID>
						<!--- just to be SURE... --->
						<cfset thisTag.current_FixedPriceBsaID_UOM_CompID = trim(replace(thisTag.current_FixedPriceBsaID_UOM_CompID,' ','','ALL'))>
            <product>
              <bsa_id_uom_comp_id>#XmlFormat(thisTag.current_FixedPriceBsaID_UOM_CompID)#</bsa_id_uom_comp_id>
              <item_id>#XmlFormat(thisTag.qProgramFixedPrice.item)#</item_id>
              <description>#XmlFormat(Replace(Replace(thisTag.qProgramFixedPrice.description,"&"," ","ALL"),"##"," ","ALL"))#</description>
              <price_per_pound>#XmlFormat(numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,"__.9999"))#</price_per_pound>
              <price_per_case>#XmlFormat(numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,"_99.99"))#</price_per_case>
              <rate>#XmlFormat(thisTag.qProgramFixedPrice.fixed_price_value)#</rate>
              <uom_id>#XmlFormat(thisTag.qProgramFixedPrice.unit_of_measure_id)#</uom_id>
              <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
			  <cfif thisTag.bAddcustomerproductnumbers>
              	<!--- IF we are returning FROM an EDIT... --->
              	<cfif listFindNoCase(thisTag.qProgramFixedPrice.columnList,"customer_product_number",",")>
                  <cfif len(trim(thisTag.qProgramFixedPrice.customer_product_number))>
              			<customer_product_number>#XmlFormat(thisTag.qProgramFixedPrice.customer_product_number)#</customer_product_number>
                  <cfelse>
                  	<customer_product_number></customer_product_number>
                  </cfif>
                </cfif>
              </cfif>
  			  <!--- Let's add a customer_product_number if environment calls for it... [end] --->
            </product>
          </cfloop>
      </fixed_price>
    </cfif>
	<!--- Fixed Price [end] --->
	<!--- 4.) Rebate [begin] --->
		<cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayRebate'&thisTag.abbreviation)>
      <rebate>
        <cfloop query="thisTag.qProgramRebate">
        	<cfset thisTag.current_RebateBsaID_UOM_CompID = thisTag.qProgramRebate.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramRebate.abbreviation&'_'&thisTag.qProgramRebate.Program_Rebates_Component_ID>
					<!--- just to be SURE... --->
					<cfset thisTag.current_RebateBsaID_UOM_CompID = trim(replace(thisTag.current_RebateBsaID_UOM_CompID,' ','','ALL'))>
          <product>
            <bsa_id_uom_comp_id>#XmlFormat(thisTag.current_RebateBsaID_UOM_CompID)#</bsa_id_uom_comp_id>
            <item_id>#XmlFormat(thisTag.qProgramRebate.item)#</item_id>
            <description>#XmlFormat(Replace(Replace(Replace(thisTag.qProgramRebate.description,'?',''),"&"," ","ALL"),"##"," ","ALL"))#</description>
            <rate>#XmlFormat(thisTag.qProgramRebate.rate)#</rate>
            <uom_id>#XmlFormat(thisTag.qProgramRebate.unit_of_measure_id)#</uom_id>
            <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
						<cfif thisTag.bAddcustomerproductnumbers>
              <!--- IF we are returning FROM an EDIT... --->
              <cfif listFindNoCase(thisTag.qProgramRebate.columnList,"customer_product_number",",")>
                <cfif len(trim(thisTag.qProgramRebate.customer_product_number))>
                  <customer_product_number>#XmlFormat(thisTag.qProgramRebate.customer_product_number)#</customer_product_number>
                <cfelse>
                  <customer_product_number></customer_product_number>
                </cfif>
              </cfif>
            </cfif>
            <!--- Let's add a customer_product_number if environment calls for it... [end] --->
          </product>
        </cfloop>
      </rebate>
    </cfif>
	<!--- Rebate [end] --->
  <!--- 5.) Bid Request [begin] --->
		<cfif thisTag.stPDFBodyInfo.bDisplayBidRequest AND thisTag.qProgramBidRequest.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayBidRequest'&thisTag.abbreviation)>
      <bid_request>
         <cfloop query="thisTag.qProgramBidRequest">
         	<cfset thisTag.current_BidRequestBsaID_UOM_CompID = thisTag.qProgramBidRequest.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramBidRequest.abbreviation&'_'&thisTag.qProgramBidRequest.Program_Bidrequest_Component_Id>
					<!--- just to be SURE... --->
					<cfset thisTag.current_BidRequestBsaID_UOM_CompID = trim(replace(thisTag.current_BidRequestBsaID_UOM_CompID,' ','','ALL'))>
          <product>
            <bsa_id_uom_comp_id>#XmlFormat(thisTag.current_BidRequestBsaID_UOM_CompID)#</bsa_id_uom_comp_id>
            <item_id>#XmlFormat(thisTag.qProgramBidRequest.item)#</item_id>
            <description>#XmlFormat(thisTag.qProgramBidRequest.description)#</description>
            <price_per_pound>#XmlFormat(numberFormat(thisTag.qProgramBidRequest.fixed_price_per_pound,"__.9999"))#</price_per_pound>
            <price_per_case>#XmlFormat(numberFormat(thisTag.qProgramBidRequest.fixed_price_per_case,"_99.99"))#</price_per_case>
            <rate>#XmlFormat(thisTag.qProgramBidRequest.rate)#</rate>
            <uom_id>#XmlFormat(thisTag.qProgramBidRequest.unit_of_measure_id)#</uom_id>
            <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
						<cfif thisTag.bAddcustomerproductnumbers>
              <!--- IF we are returning FROM an EDIT... --->
              <cfif listFindNoCase(thisTag.qProgramBidRequest.columnList,"customer_product_number",",")>
                <cfif len(trim(thisTag.qProgramBidRequest.customer_product_number))>
                  <customer_product_number>#XmlFormat(thisTag.qProgramBidRequest.customer_product_number)#</customer_product_number>
                <cfelse>
                  <customer_product_number></customer_product_number>
                </cfif>
              </cfif>
            </cfif>
            <!--- Let's add a customer_product_number if environment calls for it... [end] --->
          </product>
        </cfloop>
      </bid_request>
    </cfif>
	<!--- Bid Request [end] --->
	<!--- 6.) Lump Sum [begin] --->
    <cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayLumpSum'&thisTag.abbreviation)>
      <lump_sum>
         <cfloop query="thisTag.qProgramLumpSum">
	     <cfset thisTag.current_LumpSumBsaID_CompID = thisTag.qProgramLumpSum.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramLumpSum.Program_Lump_Sum_ID>
	     <!--- just to be SURE... --->
	     <cfset thisTag.current_LumpSumBsaID_CompID = trim(replace(thisTag.current_LumpSumBsaID_CompID,' ','','ALL'))>
	 <product>
           <bsa_id_comp_id>#XmlFormat(thisTag.current_LumpSumBsaID_CompID)#</bsa_id_comp_id>
	   <item_id>#XmlFormat(thisTag.qProgramLumpSum.item)#</item_id>
           <description>#XmlFormat(Replace(Replace(Replace(thisTag.qProgramLumpSum.description,'?',''),"&"," ","ALL"),"##"," ","ALL"))#</description>
           <ls_description>#XmlFormat(thisTag.qProgramLumpSum.program_lump_sum_name)#</ls_description>
           <amount>#XmlFormat(thisTag.qProgramLumpSum.lump_sum_amount)#</amount>
	   <!--- Let's add a customer_product_number if environment calls for it... [begin]--->
	    <cfif thisTag.bAddcustomerproductnumbers>
              <!--- IF we are returning FROM an EDIT... --->
              <cfif listFindNoCase(thisTag.qProgramLumpSum.columnList,"customer_product_number",",")>
                <cfif len(trim(thisTag.qProgramLumpSum.customer_product_number))>
                  <customer_product_number>#XmlFormat(thisTag.qProgramLumpSum.customer_product_number)#</customer_product_number>
                <cfelse>
                  <customer_product_number></customer_product_number>
                </cfif>
              </cfif>
            </cfif>
            <!--- Let's add a customer_product_number if environment calls for it... [end] --->
	 </product>
	 </cfloop>
      </lump_sum>
    </cfif>
	<!--- Lump Sum [end] --->
	<!--- 7.) Growth [begin] ON DECK
	<cfif thisTag.stPDFBodyInfo.bDisplayGrowth>
	</cfif>
	Growth [end] --->
    <!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
	SINCE WE HACE COMMENTED OUT ALL REFERNCES TO CLAUSES WITHIN THE EDIT AREA, THIS WILL ONLY SURFACE IF THE ORIGINAL LETTER HAS CLAUSES
	TEMPORARILY COMMENT OUT CLAUSE [end] --->
	<!--- 8.) Clauses [begin] --->
		<cfif thisTag.qProgramClause.recordCount>
      <clauses>
        <cfloop query="thisTag.qProgramClause">
          <id>#XmlFormat(thisTag.qProgramClause.clause_library_id)#</id>
        </cfloop>
      </clauses>
    </cfif>
	<!--- Clauses [end] --->

 </program>
</cfxml>

<!--- <cfdump var="#thisTag.xProgramLetter#" label="thisTag.xProgramLetter"> --->

<!--- remove carriage returns from our xml do and convert to a string with which to write our xml file... we'll need this OUTSIDE of this CT... --->
<cfset request.sProgramLetterXML=toString(stripCR(thisTag.xProgramLetter))>
<cfset request.sProgramLetterXML = Replace(request.sProgramLetterXML,'<?xml version="1.0" encoding="UTF-8"?>','','ALL') >
<!--- <cfdump var="#request.sProgramLetterXML#" label="request.sProgramLetterXML">
<cfabort> --->

<!--- KEEP TEMPORARILY <cfset thisTag.xml_file_path_string = "../../../common_documents" & thisTag.relative_url & thisTag.CMID & "/" & replace(thisTag.file_name,'-','_') & ".xml">
<cfset thisTag.xml_file_path = lcase(expandPath(thisTag.xml_file_path_string))> --->

<!--- TECH NOTE: We may decide to eventually make this an App Setting... [save xml files to disk and/or db]
ACTION: As of 2/02/08 however, we are doing both - storing program letter xml files in the program_letters table AND writing to file system... --->

<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXX ACTION: We are now [3/20/08] reading and writing the XML to & from the DB instead of a written file. XXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
KEEP THIS [begin]
<cfparam name="thisTag.bWriteXMLfileToDisk" type="boolean" default="1">
<cfif thisTag.bWriteXMLfileToDisk>
	<!--- Save the XML document to disk [XML]
  <cftry> --->
  	<!--- get in line... --->
		<cflock timeout="10" type="exclusive">
  		<cffile action="write" nameconflict="overwrite" file="#thisTag.xml_file_path#" output="#request.sProgramLetter#">
    </cflock>
    <!--- IF we have an 'oops'...
		<cfcatch type="any">
				<b>#cfcatch.Detail#</b>
		</cfcatch>
	</cftry> --->
  <!--- Adding to the program_letters table in 2 other templates...
<cfelse> --->
</cfif>
KEEP THIS [end]
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXX ACTION: We are now [3/20/08] reading and writing the XML to & from the DB instead of a written file. XXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

</cfoutput>
<!--- HTML [end] --->