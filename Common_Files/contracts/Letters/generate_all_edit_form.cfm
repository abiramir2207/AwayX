<cfsilent>
<!---
FILE: 		
FILENAME: generate_all_edit_form.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		03/16/2009 - RBL [MVC v11]
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This form allows the authorized user to edit a pre-existing program letter with deletions ONLY...

LEGEND:
Bid Request 		should always be in Program_Bidrequest_Component_Id,Program_Bidrequest_Component_Paid_to,item ORDER
Fixed Price 		should always be in Program_Fixed_Component_Id,Fixed_Component_Paid_to,item ORDER
Lump Sum Items		should always be in item ORDER
Rebate 				should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER
--->

<!--- These parameters are required for this template to process correctly --->

<!--- ACTION: Need to break the datagrids up for fixed, bid request, rebates, and lump sums BY COMPONENT --->

<!--- CSL_Contract_Main_ID for folder_name --->
<cfparam name="attributes.program_id" 							type="numeric" 	default="0">
<cfparam name="attributes.program_letter_id" 					type="numeric" 	default="0">

<!--- nameformat
<cfparam name="attributes.file_name" 								type="string" 	default=""> --->

<!--- opr_path OR Dis_path --->
<cfparam name="attributes.relative_path" 						type="string" 	default="">

<!--- queries from the VARS Include for scoping... [begin] --->
<cfparam name="attributes.qGetLetterSettings" 					type="query" 		default="#queryNew('Letter_Settings')#">
<cfparam name="attributes.qGetProgramDetails" 					type="query" 		default="#queryNew('Program_Details')#">
<cfparam name="attributes.qGetTemplateSettings" 				type="query" 		default="#queryNew('Template_Settings')#">
<!--- The Magnificent 7 --->
<cfparam name="attributes.qProgramBidRequest"					type="query" 		default="#queryNew('Bid_Request')#">
<cfparam name="attributes.qProgramClause"						type="query" 		default="#queryNew('Clause')#">
<cfparam name="attributes.qProgramDistributor"					type="query" 		default="#queryNew('Distributor')#">
<cfparam name="attributes.qProgramFixedPrice"					type="query" 		default="#queryNew('Fixed_Price')#">
<cfparam name="attributes.qProgramLumpSum"						type="query" 		default="#queryNew('Lump_Sum')#">
<cfparam name="attributes.qProgramOperator"						type="query" 		default="#queryNew('Operator')#">
<cfparam name="attributes.qProgramRebate"						type="query" 		default="#queryNew('Rebate')#">
<!--- queries from the VARS Include for scoping... [end] --->

<cfparam name="attributes.pages"								type="numeric"		default="0">

<!--- header structure [all strings on purpose] --->
<cfparam name="attributes.stPDFHeaderInfo" 						type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFHeaderInfo.company_address" 		type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.company_logo_path" 	type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.contract_number" 		type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.program_id" 			type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.program_title" 		type="string" 	default="">

<!--- footer structure --->
<cfparam name="attributes.stPDFEndInfo" 						type="struct" 	default="#structNew()#">

<!--- BODY structure [all boolean] --->
<cfparam name="attributes.stPDFBodyInfo" 						type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequest" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPrice" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayGrowth" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSum" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebate" 		type="boolean"	default="0">

<!--- D16586 [begin] --->
<cfparam name="attributes.stPDFBodyInfo.bTemplateAllowFreightLetters" type="boolean"	default="0">
<!--- D16586 [end] --->

<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequestDis" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayBidRequestOpr" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPriceDis" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPriceOpr" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSumDis" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSumOpr" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebateDis" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebateOpr" 		type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bDisLettersRequired" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisPaysToDistributor" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisPaysToOperator" 	type="boolean"	default="0">

<cfparam name="attributes.stPDFBodyInfo.bOprLettersRequired" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOprPaysToDistributor" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOprPaysToOperator" 	type="boolean"	default="0">

<!--- intro structure --->
<cfparam name="attributes.stPDFIntroInfo" 										type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFIntroInfo.company" 								type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_end_date" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_start_date" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.freight_notes" 						type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.lsFreightBrackets" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_email" 		type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_first_name" 	type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_last_name" 	type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_phone" 		type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_title" 		type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.template_name" 						type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.total_program_value" 					type="string" 	default="">

<!--- initial xml file for THIS LETTER Pre Current Edits being requested now... --->
<cfparam name="attributes.xml_fileName_relativeURL"								type="string"	default="">

<!--- Overwrite the default values with ANY incoming ones --->
<cfset structAppend(thisTag,attributes,true)>

<cfparam name="thisTag.pagesToDeleteFromPriorLetter"	type="string" default="">
<cfparam name="thisTag.pagesToDeleteFromThisLetter"		type="string" default="">

<!--- IF we are editing a PRE-edited letter, we need this info from it! [begin] --->
<cfparam name="thisTag.lsPreFormDisplayDistributorOn" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayDistributorOff" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayOperatorOn" 			type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayOperatorOff" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayFixedPriceOn" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayFixedPriceOff" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayRebateOn" 			type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayRebateOff" 			type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayBidRequestOn" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayBidRequestOff" 		type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayLumpSumOn" 			type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayLumpSumOff" 			type="string" default="">
<!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
<cfparam name="thisTag.lsPreFormDisplayClauseOn" 			type="string" default="">
<cfparam name="thisTag.lsPreFormDisplayClauseOff" 			type="string" default="">
TEMPORARILY COMMENT OUT CLAUSE [end] --->
<!--- IF we are editing a PRE-edited letter, we need this info from it! [end] --->

<!--- |||||||||| Data Prep / CheckBoxes, etc. |||||||||| [begin] --->

<!--- IF we have an Operator letter... --->
<cfif findNoCase("operators",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "opr">
  <!--- Flash form skin --->
	<cfset thisTag.skin = "haloBlue">
	<cfset thisTag.letter_type = "OPERATOR">
<!--- IF we have a Distributor letter... --->  
<cfelseif findNoCase("distributors",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "dis">
  <!--- Flash form skin --->
	<cfset thisTag.skin = "haloGreen">
	<cfset thisTag.letter_type = "DISTRIBUTOR">
</cfif>

<cfinclude template="/get_access_profile.cfm">

<!--- Milan (34393) - When the user clicks on "modify" button to edit a letter, we need to show the HTML code for "Clauses" 
and "Signature".While editing a letter, we do not call the Itext Code for "Clauses" and "Signature",rather the HTML code.
--->
<cfset ShowHTML = 1>

<!--- XXXXXXXXXX Get info for/from XML Doc [begin] XXXXXXXXXX --->

<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXX ACTION: We are now [3/20/08] reading and writing the XML to & from the DB instead of a written file. XXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
KEEP THIS [begin]
<cfdump var="#thisTag.program_letter_id#" label="thisTag.program_letter_id">
<cfdump var="#thisTag.qGetXML.Letter_xml[1]#" label="from query">
<cfdump var="#xmlParse(thisTag.qGetXML.Letter_xml[1])#" label="parsedXml">
<cfxml casesensitive="no" variable="xProgramXML_d">
	#xmlFormat(thisTag.qGetXML.Letter_xml[1])#
</cfxml>
<cfdump var="#xProgramXML_d#" label="from query within an xml tag">
<cfset xProgramXML_set = trim(thisTag.qGetXML.Letter_xml[1])>
<cfdump var="#xProgramXML_set#" label="set directly from the query">
<cfdump var="#xProgramXML#" label="from file">
<cfset xProgramXML = thisTag.qGetXML.Letter_xml[1]>
<cfabort>

writing file version: <cfxml casesensitive="no" variable="xProgramXML">
	<cfinclude template="#thisTag.xml_fileName_relativeURL#">
</cfxml>
KEEP THIS [end]
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXX ACTION: We are now [3/20/08] reading and writing the XML to & from the DB instead of a written file. XXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

<!--- MVC V11 Edit [begin] IN doc_modules/inc_all_vars.cfm
<cfscript>
 application.oController.getObject("mvc.Models.LetterManager");
</cfscript>
MVC V11 Edit [end] doc_modules/inc_all_vars.cfm --->

<!--- D16774 8/14/08 [begin]
<!--- X1.) Let's grab our XML data typed variable representing THIS letter's DNA... --->
<cfset useLakebaseForthisTag_qGetXML = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForthisTag_qGetXML>
	<cftry>
		<cfset thisTag.qGetXML = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#thisTag.program_letter_id#",
				"select" = "letter_xml"
			}), "letter_xml"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForthisTag_qGetXML = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForthisTag_qGetXML>
<cfquery name="thisTag.qGetXML" datasource="#application.datasource#">
  SELECT	Letter_xml
  FROM		Program_Letters
  WHERE 	Program_Letters.Program_Letters_ID = #thisTag.program_letter_id#
</cfquery>
</cfif>
--->

<!--- NOTE: XML is an empty string at this point...
<cfdump var="#application.oLetterManager.getAllLetterInfo(thisTag.program_letter_id)#">
<cfabort> --->

<!--- <cfset thisTag.xInitialProgramLetterXML = application.oLetterManager.getLetterXML(thisTag.program_letter_id)> --->
<!--- D16774 8/14/08 [end] --->

<!--- <cfdump var="#thisTag.xInitialProgramLetterXML#" label="thisTag.xInitialProgramLetterXML">
<cfabort> --->

<!--- X2.) Let's parse our XML variable with which to generate our initial edit form for THIS letter... --->
<!--- <cfset xProgramXML = xmlParse(thisTag.xInitialProgramLetterXML)> --->
<cfset xProgramXML = xmlParse(application.oLetterManager.getLetterXML(thisTag.program_letter_id))>

<!--- <cfdump var="#xProgramXML#" label="xProgramXML">
<cfabort> --->

<!--- <cfdump var="#xProgramXML#" label="xProgramXML"> --->

<!--- X3.) Include our XML script to evaluate THIS letter's DNA via xmlSearch() --->
<cfinclude template="inc_xml_script.cfm">

<!--- XXXXXXXXXX Get info for/from XML Doc [end] XXXXXXXXXX --->

<!--- If THIS letter is per distributor... --->
<cfif listLen(trim(lsDistributorNamesByLetterFromXML),",") EQ 1>
	<cfset thisTag.dis_consignee = replace(lsDistributorNamesByLetterFromXML,'##','','ALL')>
<cfelse>
	<cfset thisTag.dis_consignee = "All #application.returned_customer_setting.distributor_label_plural#">
</cfif>
<!--- If THIS letter is per operator... --->  
<cfif listLen(trim(lsOperatorNamesByLetterFromXML),",") EQ 1>
	<cfset thisTag.opr_consignee = lsOperatorNamesByLetterFromXML>
<cfelse>
	<cfset thisTag.opr_consignee = "All #application.returned_customer_setting.operator_label_plural#">
</cfif>  
<!--- put all the pieces of our title puzzle together... --->  
<cfif len(trim(thisTag.dis_consignee)) AND len(trim(thisTag.opr_consignee))>
	<cfset thisTag.consignee = "#thisTag.dis_consignee# | #thisTag.opr_consignee#">
<cfelseif len(trim(thisTag.dis_consignee))>
	<cfset thisTag.consignee = "#thisTag.dis_consignee#">
<cfelseif len(trim(thisTag.opr_consignee))>
	<cfset thisTag.consignee = "#thisTag.opr_consignee#">
<cfelse>  
	<cfset thisTag.consignee = "#company_name#">
</cfif>

<!--- A.) Distributor Names --->
<!--- B.) Distributor IDs --->
<!--- C.) Operator Names --->
<!--- D.) Operator IDs --->

<!--- E.) Show Customer Product Numbers ? [begin] --->
<cfset thisTag.bAddcustomerproductnumbers = trim(bAddCustomerProductNumbersFromXML)>

<cfif thisTag.bAddcustomerproductnumbers>
  <cfparam name="thisTag.lsPreFormFixedPriceCustomerProductNumbers" 	type="string" default="">
  <cfparam name="thisTag.lsPreFormRebateCustomerProductNumbers" 		type="string" default="">
  <cfparam name="thisTag.lsPreFormLumpsumCustomerProductNumbers" 	type="string" default="">
  <cfparam name="thisTag.lsPreFormBidRequestCustomerProductNumbers" 	type="string" default="">
</cfif>
<!--- E.) Show Customer Product Numbers ? [end] --->

<!--- F.) Include Volume Page ? [begin] --->
<cfset thisTag.bIncludeVolumePage = trim(bIncludeVolumePageFromXML)>
<!--- F.) Include Volume Page ? [end] --->

<!--- G.) Insert Watermark ? [begin] --->
<cfset thisTag.bInsertWatermark = trim(bInsertWatermarkFromXML)>
<!--- G.) Insert Watermark ? [end] --->

<!--- H.) Include Freight ? [begin] --->
<cfset thisTag.bLetterDisplayFreight = trim(bLetterDisplayFreightFromXML)>
<!--- H.) Include Freight ? [end] --->

<!--- I.) Customer FOB UOM ? [begin] --->
<cfset thisTag.customerFreightUom = trim(customerFreightUomFromXML)>
<!--- I.) Customer FOB UOM  ? [end] --->

<!--- J.) Delete Pages from Prior Letter [begin] --->
<cfset thisTag.pagesToDeleteFromPriorLetter = trim(pagesToDeleteFromPriorLetterFromXML)>
<!--- J.) Delete Pages from Prior Letter [end] --->

<!--- K.) Delete Pages from This Letter [begin] --->
<cfset thisTag.pagesToDeleteFromThisLetter = trim(pagesToDeleteFromThisLetterFromXML)>
<!--- K.) Delete Pages from This Letter [end] --->

<!--- JK2.) Cumulative Deleted Pages Prior [begin] --->
<cfset thisTag.cumulativePagesDeletedFromThisLetter = listAppend(thisTag.pagesToDeleteFromPriorLetter,thisTag.pagesToDeleteFromThisLetter,',')>
<!--- JK2.) Cumulative Deleted Pages Prior [end] --->

<!--- L.) Contract Number --->
<!--- M.) Contract Start Date --->
<!--- N.) Contract End Date --->
<!--- O.) Title --->

<!--- 1.) IF we have some Distributors to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.qProgramDistributor.recordCount>

	<!--- A.) IF we are working with a letter BY distributor... [begin] --->
  
  <!--- Let's compare our incoming XML Distributor Lists to our Distributor Query --->
  <cfset thisTag.lsDistributorNames = trim(lsDistributorNamesByLetterFromXML)>
  <cfset thisTag.lsDistributorIDs = trim(lsDistributorIDsByLetterFromXML)>
  
  <!--- If THIS letter is per distributor... --->
  <cfif listLen(thisTag.lsDistributorIDs,",") EQ 1>
  
		<!--- set gross to incoming... --->
  	<cfset thisTag.qProgramDistributorGross = thisTag.qProgramDistributor>

    <cfquery name="thisTag.qProgramDistributor" dbtype="query">
      SELECT 	*
      FROM 		thisTag.qProgramDistributorGross
      WHERE		contract_distributors_id IN (#thisTag.lsDistributorIDs#)
    </cfquery>
    
  <!--- otherwise the length of the list should equal the length of the query per our business rules, but we won't ask on purpose... --->  
  <cfelse>

		<!--- add CheckBox to Distributor Grid... [begin] --->
    <cfset thisTag.aDisplayDistributor = arrayNew(1)>
    <!--- ON/OFF: organize Distributor lists for pre form values --->
    <cfset thisTag.lsPreFormDisplayDistributorOn = "">
    <cfset thisTag.lsPreFormDisplayDistributorOff = "">
    <cfloop query="thisTag.qProgramDistributor">
      <!--- numeric id --->
      <cfif listFind(lsDistributorIDsFromXML,thisTag.qProgramDistributor.contract_distributors_id,",")>
        <cfset arrayAppend(thisTag.aDisplayDistributor,1)>
        <!--- ON: let's collate our incoming Distributor display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayDistributorOn = listAppend(thisTag.lsPreFormDisplayDistributorOn,trim(thisTag.qProgramDistributor.contract_distributors_id),",")>
      <cfelse>
        <cfset arrayAppend(thisTag.aDisplayDistributor,0)>
        <!--- OFF: let's collate our incoming Distributor display OFF values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayDistributorOff = listAppend(thisTag.lsPreFormDisplayDistributorOff,trim(thisTag.qProgramDistributor.contract_distributors_id),",")>
      </cfif>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramDistributor,"bDisplayDistributor","Bit",thisTag.aDisplayDistributor)>
    <!--- add CheckBox to Distributor Grid... [end] --->
  
  </cfif>
  <!--- A.) IF we a distributor list OR are perhaps workign with a letter BY distributor... [end] --->

</cfif>
<!--- 1.) IF we have some Distributors to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- 2.) IF we have some Operators to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.qProgramOperator.recordCount>

  <!--- A.) IF we are working with a letter BY operator... [begin] --->
  
  <!--- Let's compare our incoming XML Operator Lists to our Operator Query --->
  <cfset thisTag.lsOperatorNames = trim(lsOperatorNamesByLetterFromXML)>
  <cfset thisTag.lsOperatorIDs = trim(lsOperatorIDsByLetterFromXML)>
  
  <!--- If THIS letter is per operator... --->
  <cfif listLen(thisTag.lsOperatorIDs,",") EQ 1>
  
		<!--- set gross to incoming... --->
    <cfset thisTag.qProgramOperatorGross = thisTag.qProgramOperator>

    <cfquery name="thisTag.qProgramOperator" dbtype="query">
      SELECT 	*
      FROM 		thisTag.qProgramOperatorGross
      WHERE		operator_id IN (#thisTag.lsOperatorIDs#)
    </cfquery>
    
  <!--- otherwise the length of the list should equal the length of the query per our business rules, but we won't ask on purpose... --->  
  <cfelse>

		<!--- add CheckBox to Operator Grid... [begin] --->
    <cfset thisTag.aDisplayOperator = arrayNew(1)>
    <!--- ON/OFF: organize Operator lists for pre form values --->
    <cfset thisTag.lsPreFormDisplayOperatorOn = "">
    <cfset thisTag.lsPreFormDisplayOperatorOff = "">
    <cfloop query="thisTag.qProgramOperator">
      <!--- numeric id --->
      <cfif listFind(lsOperatorIDsFromXML,thisTag.qProgramOperator.operator_id,",")>
        <cfset arrayAppend(thisTag.aDisplayOperator,1)>
        <!--- ON: let's collate our incoming Operator display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayOperatorOn = listAppend(thisTag.lsPreFormDisplayOperatorOn,trim(thisTag.qProgramOperator.operator_id),",")>
      <cfelse>
        <cfset arrayAppend(thisTag.aDisplayOperator,0)>
        <!--- OFF: let's collate our incoming Operator display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayOperatorOff = listAppend(thisTag.lsPreFormDisplayOperatorOff,trim(thisTag.qProgramOperator.operator_id),",")>
      </cfif>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramOperator,"bDisplayOperator","Bit",thisTag.aDisplayOperator)>
    <!--- add CheckBox to Operator Grid... [end] --->
  
  </cfif>
  <!--- B.) IF we a operator list OR are perhaps working with a letter BY operator... [end] --->
  
</cfif>
<!--- 2.) IF we have some Operators to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- 3.) IF we want to show 'Fixed Price' AND we have some 'Fixed Price' to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation)>
  	<!--- A.) Let's add the XML XRef column... [begin] --->
    <cfset thisTag.aFixedPriceBsaID_UOM_CompID = arrayNew(1)>
    <cfloop query="thisTag.qProgramFixedPrice">
    	<cfset thisTag.current_FixedPriceBsaID_UOM_CompID = thisTag.qProgramFixedPrice.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramFixedPrice.abbreviation&'_'&thisTag.qProgramFixedPrice.Program_Fixed_Component_ID>
			<!--- just to be SURE... --->
			<cfset thisTag.current_FixedPriceBsaID_UOM_CompID = trim(replace(thisTag.current_FixedPriceBsaID_UOM_CompID,' ','','ALL'))>
    	<cfset arrayAppend(thisTag.aFixedPriceBsaID_UOM_CompID,thisTag.current_FixedPriceBsaID_UOM_CompID)>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramFixedPrice,"bsa_id_uom_comp_id","VarChar",thisTag.aFixedPriceBsaID_UOM_CompID)>
    <!--- A.) Let's add the XML XRef column... [end] --->
		<!--- B.) Let's add the CheckBox for the Fixed Price Products Grid... [begin] --->
    <cfset thisTag.aDisplayFixedPriceProduct = arrayNew(1)>
    <!--- ON/OFF: organize Fixed Price lists for pre form values --->
    <cfset thisTag.lsPreFormDisplayFixedPriceOn = "">
    <cfset thisTag.lsPreFormDisplayFixedPriceOff = "">
    <cfloop query="thisTag.qProgramFixedPrice">
      <!--- string id --->
      <cfif listContainsNoCase(replace(lsFixedPriceProductIDUOMCOMPsFromXML," ","","ALL"),trim(thisTag.qProgramFixedPrice.bsa_id_uom_comp_id),",")>
        <cfset arrayAppend(thisTag.aDisplayFixedPriceProduct,1)>
        <!--- ON: let's collate our incoming Fixed Price display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayFixedPriceOn = listAppend(thisTag.lsPreFormDisplayFixedPriceOn,trim(replace(thisTag.qProgramFixedPrice.bsa_id_uom_comp_id," ","","ALL")))>
      <cfelse>
        <cfset arrayAppend(thisTag.aDisplayFixedPriceProduct,0)>
				<!--- OFF: let's collate our incoming Fixed Price display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayFixedPriceOff = listAppend(thisTag.lsPreFormDisplayFixedPriceOff,trim(replace(thisTag.qProgramFixedPrice.bsa_id_uom_comp_id," ","","ALL")))>
      </cfif>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramFixedPrice,"bDisplayFixedPriceProduct","Bit",thisTag.aDisplayFixedPriceProduct)>
    <!--- B.) Let's add the CheckBox for the Fixed Price Products Grid... [end] --->
    
  	<!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [begin] --->
    <cfif thisTag.bAddcustomerproductnumbers>
    	<!--- IF we do NOT already have incoming customer_product_numberS... --->
      <cfif NOT listFindNoCase(thisTag.qProgramFixedPrice.columnList,"customer_product_number",",")>
      	<!--- IF we HAVE incoming XML for customer product numbers... --->
      	<cfif bFixedPriceCustomerProductNumbers AND isArray(aFixedPriceProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aFixedPriceProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND thisTag.qProgramFixedPrice.recordCount>
        	 <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
        	 <cfset thisTag.fixedPrice_rowCounter = 0>
        	 <!--- let's loop through the GROSS container... [IMPORTANT: INITIAL QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
           <cfloop query="thisTag.qProgramFixedPrice">
              <!--- string id --->
      				<cfif listContainsNoCase(replace(lsFixedPriceProductIDUOMCOMPsFromXML," ","","ALL"),trim(thisTag.qProgramFixedPrice.bsa_id_uom_comp_id),",")>
              	<cfset thisTag.fixedPrice_rowCounter = thisTag.fixedPrice_rowCounter+1>
                <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers, trim(aFixedPriceProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter[thisTag.fixedPrice_rowCounter].XmlText))>
              <cfelse>
              	<!--- na --->
                <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
              </cfif>
            </cfloop>
        <!--- IF we DO NOT have incoming XML for customer product numbers... --->
        <cfelse>
        	<cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
          <cfloop query="thisTag.qProgramFixedPrice">
            <!--- start with na --->       
            <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
          </cfloop>
        </cfif>
        <cfset queryAddColumn(thisTag.qProgramFixedPrice,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
        <!--- let's pass our incoming customer product numbers pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormFixedPriceCustomerProductNumbers = arrayToList(thisTag.aFixedPriceCustomerProductNumbers,",")>
      </cfif>
    </cfif>
    <!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [end] --->
</cfif>
<!--- 3.) IF we want to show 'Fixed Price' AND we have some 'Fixed Price' to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- 4.) IF we want to show 'Rebate' AND we have some 'Rebate' to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayRebate'&thisTag.abbreviation)>

  	<!--- A.) Let's add the XML XRef column... [begin] --->
  	<cfset thisTag.aRebateBsaID_UOM_CompID = arrayNew(1)>
  	<cfloop query="thisTag.qProgramRebate">
    	<cfset thisTag.current_RebateBsaID_UOM_CompID = thisTag.qProgramRebate.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramRebate.abbreviation&'_'&thisTag.qProgramRebate.Program_Rebates_Component_ID>
			<!--- just to be SURE... --->
			<cfset thisTag.current_RebateBsaID_UOM_CompID = trim(replace(thisTag.current_RebateBsaID_UOM_CompID,' ','','ALL'))>
    	<cfset arrayAppend(thisTag.aRebateBsaID_UOM_CompID,thisTag.current_RebateBsaID_UOM_CompID)>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramRebate,"bsa_id_uom_comp_id","VarChar",thisTag.aRebateBsaID_UOM_CompID)>
    <!--- A.) Let's add the XML XRef column... [end] --->
		<!--- B.) Let's add the CheckBox for the Rebate Products Grid... [begin] --->
    <cfset thisTag.aDisplayRebateProduct = arrayNew(1)>
    <!--- ON/OFF: organize Rebate lists for pre form values --->
    <cfset thisTag.lsPreFormDisplayRebateOn = "">
    <cfset thisTag.lsPreFormDisplayRebateOff = "">
    <cfloop query="thisTag.qProgramRebate">
      <!--- string id --->
      <cfif listContainsNoCase(replace(lsRebateProductIDUOMCOMPsFromXML," ","","ALL"),trim(thisTag.qProgramRebate.bsa_id_uom_comp_id),",")>
        <cfset arrayAppend(thisTag.aDisplayRebateProduct,1)>
        <!--- ON: let's collate our incoming Rebate display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayRebateOn = listAppend(thisTag.lsPreFormDisplayRebateOn,trim(replace(thisTag.qProgramRebate.bsa_id_uom_comp_id," ","","ALL")))>
      <cfelse>
        <cfset arrayAppend(thisTag.aDisplayRebateProduct,0)>
        <!--- OFF: let's collate our incoming Rebate display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayRebateOff = listAppend(thisTag.lsPreFormDisplayRebateOff,trim(replace(thisTag.qProgramRebate.bsa_id_uom_comp_id," ","","ALL")))>
      </cfif>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramRebate,"bDisplayRebateProduct","Bit",thisTag.aDisplayRebateProduct)>
    <!--- B.) Let's add the CheckBox for the Rebate Products Grid... [end] --->
  	<!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [begin] --->
    <cfif thisTag.bAddcustomerproductnumbers>
    	<!--- IF we do NOT already have incoming customer_product_numberS... --->
      <cfif NOT listFindNoCase(thisTag.qProgramRebate.columnList,"customer_product_number",",")>
      	<!--- IF we HAVE incoming XML for customer product numbers... --->
      	<cfif bRebateCustomerProductNumbers AND isArray(aRebateProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aRebateProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND thisTag.qProgramRebate.recordCount>
        	 <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
        	 <cfset thisTag.rebate_rowCounter = 0>
        	 <!--- let's loop through the GROSS container... [IMPORTANT: INITIAL QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
           <cfloop query="thisTag.qProgramRebate">
              <!--- string id --->
      				<cfif listContainsNoCase(replace(lsRebateProductIDUOMCOMPsFromXML," ","","ALL"),trim(thisTag.qProgramRebate.bsa_id_uom_comp_id),",")>
              	<cfset thisTag.rebate_rowCounter = thisTag.rebate_rowCounter+1>
                <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers, trim(aRebateProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter[thisTag.rebate_rowCounter].XmlText))>
              <cfelse>
              	<!--- na --->
                <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
              </cfif>
            </cfloop>
        <!--- IF we DO NOT have incoming XML for customer product numbers... --->
        <cfelse>
        	<cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
          <cfloop query="thisTag.qProgramRebate">
            <!--- start with na --->       
            <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
          </cfloop>
        </cfif>
        <cfset queryAddColumn(thisTag.qProgramRebate,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
        <!--- let's pass our incoming customer product numbers pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormRebateCustomerProductNumbers = arrayToList(thisTag.aRebateCustomerProductNumbers,",")>
      </cfif>
    </cfif>
    <!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [end] --->
</cfif>
<!--- 4.) IF we want to show 'Rebate' AND we have some 'Rebate' to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- 5.) IF we want to show 'Bid Request' AND we have some 'Bid Request' to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.stPDFBodyInfo.bDisplayBidRequest AND thisTag.qProgramBidRequest.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayBidRequest'&thisTag.abbreviation)>
    <!--- A.) Let's add the XML XRef column... [begin] --->
    <cfset thisTag.aBidRequestBsaID_UOM_CompID = arrayNew(1)>
    <cfloop query="thisTag.qProgramBidRequest">
    	<cfset thisTag.current_BidRequestBsaID_UOM_CompID = thisTag.qProgramBidRequest.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramBidRequest.abbreviation&'_'&thisTag.qProgramBidRequest.Program_BidRequest_Component_ID>
			<!--- just to be SURE... --->
			<cfset thisTag.current_BidRequestBsaID_UOM_CompID = trim(replace(thisTag.current_BidRequestBsaID_UOM_CompID,' ','','ALL'))>
    	<cfset arrayAppend(thisTag.aBidRequestBsaID_UOM_CompID,thisTag.current_BidRequestBsaID_UOM_CompID)>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramBidRequest,"bsa_id_uom_comp_id","VarChar",thisTag.aBidRequestBsaID_UOM_CompID)>
    <!--- A.) Let's add the XML XRef column... [end] --->
    <!--- B.) Let's add the CheckBox for the Bid Request Products Grid... [begin] --->
    <cfset thisTag.aDisplayBidRequestProduct = arrayNew(1)>
    <!--- ON/OFF: organize Bid Request lists for pre form values --->
    <cfset thisTag.lsPreFormDisplayBidRequestOn = "">
    <cfset thisTag.lsPreFormDisplayBidRequestOff = "">
    <cfloop query="thisTag.qProgramBidRequest">
      <!--- string id --->
      <cfif listContainsNoCase(replace(lsBidRequestProductIDUOMCOMPsFromXML," ","","ALL"),trim(thisTag.qProgramBidRequest.bsa_id_uom_comp_id),",")>
        <cfset arrayAppend(thisTag.aDisplayBidRequestProduct,1)>
        <!--- ON: let's collate our incoming Bid Request display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayBidRequestOn = listAppend(thisTag.lsPreFormDisplayBidRequestOn,trim(replace(thisTag.qProgramBidRequest.bsa_id_uom_comp_id," ","","ALL")))>
      <cfelse>
        <cfset arrayAppend(thisTag.aDisplayBidRequestProduct,0)>
        <!--- OFF: let's collate our incoming Bid Request display ON values pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormDisplayBidRequestOff = listAppend(thisTag.lsPreFormDisplayBidRequestOff,trim(replace(thisTag.qProgramBidRequest.bsa_id_uom_comp_id," ","","ALL")))>
      </cfif>
    </cfloop>
    <cfset queryAddColumn(thisTag.qProgramBidRequest,"bDisplayBidRequestProduct","Bit",thisTag.aDisplayBidRequestProduct)>
    <!--- B.) Let's add the CheckBox for the Bid Request Products Grid... [end] --->
  	<!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [begin] --->
    <cfif thisTag.bAddcustomerproductnumbers>
    	<!--- IF we do NOT already have incoming customer_product_numberS... --->
      <cfif NOT listFindNoCase(thisTag.qProgramBidRequest.columnList,"customer_product_number",",")>
      	<!--- IF we HAVE incoming XML for customer product numbers... --->
      	<cfif bBidRequestCustomerProductNumbers AND isArray(aBidRequestProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aBidRequestProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND thisTag.qProgramBidRequest.recordCount>
        	 <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
        	 <cfset thisTag.bidRequest_rowCounter = 0>
        	 <!--- let's loop through the GROSS container... [IMPORTANT: INITIAL QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
           <cfloop query="thisTag.qProgramBidRequest">
              <!--- string id --->
      				<cfif listContainsNoCase(replace(lsBidRequestProductIDUOMCOMPsFromXML," ","","ALL"),trim(thisTag.qProgramBidRequest.bsa_id_uom_comp_id),",")>
              	<cfset thisTag.bidRequest_rowCounter = thisTag.bidRequest_rowCounter+1>
                <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers, trim(aBidRequestProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter[thisTag.bidRequest_rowCounter].XmlText))>
              <cfelse>
              	<!--- na --->
                <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
              </cfif>
            </cfloop>
        <!--- IF we DO NOT have incoming XML for customer product numbers... --->
        <cfelse>
        	<cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
          <cfloop query="thisTag.qProgramBidRequest">
            <!--- start with na --->       
            <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
          </cfloop>
        </cfif>
        <cfset queryAddColumn(thisTag.qProgramBidRequest,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
        <!--- let's pass our incoming customer product numbers pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormBidRequestCustomerProductNumbers = arrayToList(thisTag.aBidRequestCustomerProductNumbers,",")>
      </cfif>
    </cfif>
    <!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [end] --->  
</cfif>
<!--- 5.) IF we want to show 'Bid Request' AND we have some 'Bid Request' to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- 6.) IF we want to show 'Lump Sum' AND we have some 'Lump Sum' to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayLumpSum'&thisTag.abbreviation)>

  	<!--- A.) Let's add the XML XRef column... [begin] --->
  	<cfset thisTag.aLumpsumBsaID_CompID = arrayNew(1)>

  	<cfloop query="thisTag.qProgramLumpSum">
		<cfset thisTag.current_LumpsumBsaID_CompID = thisTag.qProgramLumpSum.BSA_Foodservice_Items_Master_ID&'_'&thisTag.qProgramLumpSum.Program_Lump_Sum_ID>

		<!--- just to be SURE... --->
		<cfset thisTag.current_LumpsumBsaID_CompID = trim(replace(thisTag.current_LumpsumBsaID_CompID,' ','','ALL'))>

    	        <cfset arrayAppend(thisTag.aLumpsumBsaID_CompID,thisTag.current_LumpsumBsaID_CompID)>

	</cfloop>
 <!--- We do not have to go to the UOM level for lumpsum and so we have bsa_id_comp_id and not bsa_id_uom_comp_id--->
 <cfset queryAddColumn(thisTag.qProgramLumpSum,"bsa_id_comp_id","VarChar",thisTag.aLumpsumBsaID_CompID)>
    
  <!---	 B.) Let's add the CheckBox for the Lump Sums Grid... [begin] --->
	<cfset thisTag.aDisplayLumpSum = arrayNew(1)>
  <!--- ON/OFF: organize Lump Sum lists for pre form values --->
  <cfset thisTag.lsPreFormDisplayLumpSumOn = "">
  <cfset thisTag.lsPreFormDisplayLumpSumOff = "">
	<cfloop query="thisTag.qProgramLumpSum">
		<!--- numeric id --->
		<cfif listFind(lsLumpSumIDsFromXML,thisTag.qProgramLumpSum.bsa_id_comp_id)>
			<cfset arrayAppend(thisTag.aDisplayLumpSum,1)>
      <!--- ON: let's collate our incoming Lump Sum display ON values pre form for submitting with form to carry values forward... --->
      <cfset thisTag.lsPreFormDisplayLumpSumOn = listAppend(thisTag.lsPreFormDisplayLumpSumOn,trim(thisTag.qProgramLumpSum.bsa_id_comp_id),",")>
		<cfelse>
			<cfset arrayAppend(thisTag.aDisplayLumpSum,0)>
      <!--- OFF: let's collate our incoming Lump Sum display ON values pre form for submitting with form to carry values forward... --->
      <cfset thisTag.lsPreFormDisplayLumpSumOff = listAppend(thisTag.lsPreFormDisplayLumpSumOff,trim(thisTag.qProgramLumpSum.bsa_id_comp_id),",")>
		</cfif>
	</cfloop>
	<cfset queryAddColumn(thisTag.qProgramLumpSum,"bDisplayLumpSum","Bit",thisTag.aDisplayLumpSum)>
	<!--- B.) Let's add the CheckBox for the Lump Sums Grid... [end] --->



	<!--- C.) Let's add a customer_product_number ONLY IF environment calls for it... [begin] --->
    <cfif thisTag.bAddcustomerproductnumbers>
    	<!--- IF we do NOT already have incoming customer_product_numberS... --->
      <cfif NOT listFindNoCase(thisTag.qProgramLumpSum.columnList,"customer_product_number",",")>
      	<!--- IF we HAVE incoming XML for customer product numbers... --->
      	<cfif bLumpsumCustomerProductNumbers AND isArray(aLumpsumProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aLumpsumProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND thisTag.qProgramLumpSum.recordCount>
        	 <cfset thisTag.aLumpsumCustomerProductNumbers = arrayNew(1)>
        	 <cfset thisTag.Lumpsum_rowCounter = 0>
        	 <!--- let's loop through the GROSS container... [IMPORTANT: INITIAL QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
           <cfloop query="thisTag.qProgramLumpSum">
              <!--- string id --->
      				<cfif listContainsNoCase(replace(lsLumpSumIDsFromXML," ","","ALL"),trim(thisTag.qProgramLumpSum.bsa_id_comp_id),",")>
              	<cfset thisTag.Lumpsum_rowCounter = thisTag.Lumpsum_rowCounter+1>
                <cfset arrayAppend(thisTag.aLumpsumCustomerProductNumbers, trim(aLumpsumProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter[thisTag.Lumpsum_rowCounter].XmlText))>
              <cfelse>
              	<!--- na --->
                <cfset arrayAppend(thisTag.aLumpsumCustomerProductNumbers,"na")>
              </cfif>
            </cfloop>
        <!--- IF we DO NOT have incoming XML for customer product numbers... --->
        <cfelse>
        	<cfset thisTag.aLumpsumCustomerProductNumbers = arrayNew(1)>
          <cfloop query="thisTag.qProgramLumpSum">
            <!--- start with na --->       
            <cfset arrayAppend(thisTag.aLumpsumCustomerProductNumbers,"na")>
          </cfloop>
        </cfif>
        <cfset queryAddColumn(thisTag.qProgramLumpSum, "customer_product_number","VarChar",thisTag.aLumpsumCustomerProductNumbers)>
        <!--- let's pass our incoming customer product numbers pre form for submitting with form to carry values forward... --->
        <cfset thisTag.lsPreFormLumpsumCustomerProductNumbers = arrayToList(thisTag.aLumpsumCustomerProductNumbers,",")>
      </cfif>
    </cfif>



</cfif>
<!--- 6.) IF we want to show 'Lump Sum' AND we have some 'Lump Sum' to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- 7.) IF we want to show 'Growth' AND we have some 'Growth' to start with, let's default them to 'true' aka 'checked' [begin]
thisTag.qProgramShowGrowth.recordCount ON DECK --->
<!--- <cfif thisTag.stPDFBodyInfo.bDisplayGrowth> --->
	<!--- add CheckBox to Show Growth Grid... [begin]
	<cfset thisTag.aDisplayShowGrowth = arrayNew(1)>
	<cfloop query="thisTag.qProgramGrowth">
		<cfset arrayAppend(thisTag.aDisplayGrowth,"1")>
	</cfloop>
	<cfset queryAddColumn(thisTag.qProgramGrowth,"bDisplayGrowth","Bit",thisTag.aDisplayGrowth)>
	add CheckBox to Growth Products Grid... [end] --->
<!--- </cfif> --->
<!--- 7.) IF we want to show 'Growth' AND we have some 'Growth' to start with, let's default them to 'true' aka 'checked' [end] --->

<!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
<!--- 8.) IF we have some 'Clause' to start with, let's default them to 'true' aka 'checked' [begin] --->
<cfif thisTag.qProgramClause.recordCount>
	<!--- Add CheckBox to Rebate Products Grid AND Clean Up the clauses... for display in the dataGrid... [begin] --->
	<cfset thisTag.aDisplayClause = arrayNew(1)>  
  <cfset thisTag.aCleanClauses = arrayNew(1)>
  <!--- ON/OFF: organize Clause lists for pre form values --->
  <cfset thisTag.lsPreFormDisplayClauseOn = "">
  <cfset thisTag.lsPreFormDisplayClauseOff = "">
	<cfloop query="thisTag.qProgramClause">
		<!--- numeric id --->
		<cfif listFind(lsClauseIDsFromXML,thisTag.qProgramClause.clause_library_id)>
			<cfset arrayAppend(thisTag.aDisplayClause,1)>
      <!--- ON: let's collate our incoming Clause display ON values pre form for submitting with form to carry values forward... --->
      <cfset thisTag.lsPreFormDisplayClauseOn = listAppend(thisTag.lsPreFormDisplayClauseOn,trim(thisTag.qProgramClause.clause_library_id),",")>
		<cfelse>
			<cfset arrayAppend(thisTag.aDisplayClause,0)>
      <!--- OFF: let's collate our incoming Clause display ON values pre form for submitting with form to carry values forward... --->
      <cfset thisTag.lsPreFormDisplayClauseOff = listAppend(thisTag.lsPreFormDisplayClauseOff,trim(thisTag.qProgramClause.clause_library_id),",")>
		</cfif>
    <!--- remove ALL HTML tags [wickets and attributes] with RegEx --->
		<cfset thisTag.current_clause = ReReplaceNoCase(thisTag.qProgramClause.Clause_Library_Body,"<[^>]*(>|$)", "" , "ALL" )>
    <cfset thisTag.current_clause = stripCR(thisTag.current_clause)>
    <cfset arrayAppend(thisTag.aCleanClauses,thisTag.current_clause)>
	</cfloop>
  <!--- Add CheckBox to Clauses Grid... --->
	<cfset queryAddColumn(thisTag.qProgramClause,"bDisplayClause","Bit",thisTag.aDisplayClause)>
	<!--- Clean Up the clauses... for display in the dataGrid... --->
  <cfset queryAddColumn(thisTag.qProgramClause,"clean_clause","VarChar",thisTag.aCleanClauses)>
  <!--- Add CheckBox to Rebate Products Grid AND Clean Up the clauses... for display in the dataGrid... [end] --->
</cfif>
<!--- 8.) IF we have some 'Clause' to start with, let's default them to 'true' aka 'checked' [end] --->
TEMPORARILY COMMENT OUT CLAUSE [end] --->

<!--- |||||||||| Data Prep / CheckBoxes |||||||||| [end] --->

<!--- This is essentially referring to one situation for the header of the edit form... --->
<cfset thisTag.doc_type = "html">

</cfsilent>

<!--- LATER Let's make the submit button enabled ONLY after data changes...
reviewed.value != 'true' ||
<cfsavecontent variable="requireInfo">
	if(revised_doc_title.text == '')
	{
	  edit.enabled = false;
	}
	else
	{
	  edit.enabled = true;
	}
</cfsavecontent>
--->

<!--- HTML Starts Here --->
<!--- TESTING <script type="text/javascript">
<!--
function openPDFWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}
//-->
</script> --->

<cfoutput>

<table width="100%" cellpadding="0" cellspacing="0">
<!--- header --->
<tr>
	<td width="100%">
		<cfinclude template="doc_modules/inc_all_header.cfm">
	</td>
</tr>

<!--- I.) ////// KEEP Temporarily TESTING [begin] //////////////////////////////////////
<cfdump var="#thisTag.qProgramDistributor#">
<cfdump var="#thisTag.qProgramOperator#">
<cfdump var="#thisTag.qProgramFixedPrice#">
<cfdump var="#thisTag.qProgramRebate#">
<cfdump var="#thisTag.qProgramBidRequest#">
<cfdump var="#thisTag.qProgramLumpSum#">
<cfdump var="#thisTag.qProgramClause#">
<cfabort>
I.) ////// KEEP Temporarily TESTING [end] //////////////////////////////////////// --->
<!--- intro
<tr>
	<td>
		<cfinclude template="doc_modules/inc_all_intro.cfm">
	</td>
</tr>
--->
<!--- editable content via flashform... --->
<tr>
	<td width="100%">
  
  	<!--- TESTING KEEP [begin]
  	<cfdump var="#thisTag.lsPreFormDisplayDistributorOn#" 	label="thisTag.lsPreFormDisplayDistributorOn">
    <cfdump var="#thisTag.lsPreFormDisplayDistributorOff#" 	label="thisTag.lsPreFormDisplayDistributorOff">
    <cfdump var="#thisTag.lsPreFormDisplayOperatorOn#" 			label="thisTag.lsPreFormDisplayOperatorOn">
    <cfdump var="#thisTag.lsPreFormDisplayOperatorOff#" 		label="thisTag.lsPreFormDisplayOperatorOff">
    <cfdump var="#thisTag.lsPreFormDisplayFixedPriceOn#" 		label="thisTag.lsPreFormDisplayFixedPriceOn">
    <cfdump var="#thisTag.lsPreFormDisplayFixedPriceOff#" 	label="thisTag.lsPreFormDisplayFixedPriceOff">
    <cfdump var="#thisTag.lsPreFormDisplayRebateOn#" 				label="thisTag.lsPreFormDisplayRebateOn">
    <cfdump var="#thisTag.lsPreFormDisplayRebateOff#" 			label="thisTag.lsPreFormDisplayRebateOff">
    <!--- <cfdump var="#thisTag.lsPreFormDisplayBidRequestOn#" 		label="thisTag.lsPreFormDisplayBidRequestOn">
    <cfdump var="#thisTag.lsPreFormDisplayBidRequestOff#" 	label="thisTag.lsPreFormDisplayBidRequestOff"> --->
    <cfdump var="#thisTag.lsPreFormDisplayLumpSumOn#" 			label="thisTag.lsPreFormDisplayLumpSumOn">
    <cfdump var="#thisTag.lsPreFormDisplayLumpSumOff#" 			label="thisTag.lsPreFormDisplayLumpSumOff">
    <cfdump var="#thisTag.lsPreFormDisplayClauseOn#" 				label="thisTag.lsPreFormDisplayClauseOn">
    <cfdump var="#thisTag.lsPreFormDisplayClauseOff#" 			label="thisTag.lsPreFormDisplayClauseOff">
    <cfabort>
  	TESTING KEEP [end] --->
    
    <!--- <cfdump var="#thisTag#" label="thisTag">
    <cfdump var="#variables#" label="variables">
    <cfabort> --->

		<!--- Operator - haloBlue... haloGreen - Distributor...  [other ops=halosilver, haloblue, haloorange] TIMEOUT set to 30 seconds... 300000 --->
	<!--- Pass distributor_id in the url from the form --->
    <cfform height="440" format="flash" skin="#thisTag.skin#" name="project_#lCase(thisTag.letter_type)#_form" action="all_edit_form_action.cfm?dist_id=#url.Dist_ID#" method="post" preservedata="yes" timeout="10000">

		  	<cfformgroup type="panel" tooltip="#dateFormat(thisTag.stPDFIntroInfo.contract_start_date, "m/d/yy")#-#dateFormat(thisTag.stPDFIntroInfo.contract_end_date,"m/d/yy")# #UCase(thisTag.stPDFHeaderInfo.program_title)# (#thisTag.consignee#: #programLetterTitle# version) - Letter Info" label=" #dateFormat(thisTag.stPDFIntroInfo.contract_start_date, "m/d/yy")#-#dateFormat(thisTag.stPDFIntroInfo.contract_end_date,"m/d/yy")# #UCase(thisTag.stPDFHeaderInfo.program_title)# (#thisTag.consignee#: #programLetterTitle# version) - Letter Instructions: UNCHECK Items to Remove">
          <cfinput type="hidden" name="abbreviation" 						value="#thisTag.abbreviation#">
          <cfinput type="hidden" name="consignee"							value="#thisTag.consignee#">
          <cfinput type="hidden" name="distributor_name"					value="#thisTag.dis_consignee#">
          <cfinput type="hidden" name="letter_type" 						value="#thisTag.letter_type#">
          <cfinput type="hidden" name="operator_name"						value="#thisTag.opr_consignee#">
          <cfinput type="hidden" name="prior_program_letter_id" 			value="#thisTag.program_letter_id#">
		  <cfinput type="hidden" name="program_id" 							value="#thisTag.program_id#">
		  <cfinput type="hidden" name="relative_path"						value="#thisTag.relative_path#">
		  <cfinput type="hidden" name="xml_fileName_relativeURL" 			value="#thisTag.xml_fileName_relativeURL#">
			<cfif thisTag.qProgramDistributor.recordCount>
		  		<cfinput type="hidden" name="distributor_id"					value="#thisTag.qProgramDistributor.BSA_Foodservice_Customers_ID#">
			</cfif>
		  <!--- forward valueLists follow... --->
          <cfinput type="hidden" name="lsPreFormDisplayDistributorOn" 		value="#thisTag.lsPreFormDisplayDistributorOn#">
          <cfinput type="hidden" name="lsPreFormDisplayDistributorOff" 		value="#thisTag.lsPreFormDisplayDistributorOff#">
          <cfinput type="hidden" name="lsPreFormDisplayOperatorOn" 			value="#thisTag.lsPreFormDisplayOperatorOn#">
          <cfinput type="hidden" name="lsPreFormDisplayOperatorOff" 		value="#thisTag.lsPreFormDisplayOperatorOff#">
          <cfinput type="hidden" name="lsPreFormDisplayFixedPriceOn" 		value="#thisTag.lsPreFormDisplayFixedPriceOn#">
          <cfinput type="hidden" name="lsPreFormDisplayFixedPriceOff" 		value="#thisTag.lsPreFormDisplayFixedPriceOff#">
          <cfinput type="hidden" name="lsPreFormDisplayRebateOn" 			value="#thisTag.lsPreFormDisplayRebateOn#">
          <cfinput type="hidden" name="lsPreFormDisplayRebateOff" 			value="#thisTag.lsPreFormDisplayRebateOff#">
          <cfinput type="hidden" name="lsPreFormDisplayBidRequestOn" 		value="#thisTag.lsPreFormDisplayBidRequestOn#">
          <cfinput type="hidden" name="lsPreFormDisplayBidRequestOff" 		value="#thisTag.lsPreFormDisplayBidRequestOff#">
          <cfinput type="hidden" name="lsPreFormDisplayLumpSumOn" 			value="#thisTag.lsPreFormDisplayLumpSumOn#">
          <cfinput type="hidden" name="lsPreFormDisplayLumpSumOff" 			value="#thisTag.lsPreFormDisplayLumpSumOff#">
          <!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
          <cfinput type="hidden" name="lsPreFormDisplayClauseOn" 			value="#thisTag.lsPreFormDisplayClauseOn#">
          <cfinput type="hidden" name="lsPreFormDisplayClauseOff" 			value="#thisTag.lsPreFormDisplayClauseOff#">
          TEMPORARILY COMMENT OUT CLAUSE [end] --->
	  <cfif IsDefined("attributes.claimRateDate")>
		<cfinput type="hidden" name="claim_Rate_Date" 				value="#attributes.claimRateDate#">
	  </cfif>

		  <cfinput type="hidden" name="bLetterDisplayFreight" 				value="#thisTag.bLetterDisplayFreight#">
          <cfinput type="hidden" name="customerFreightUom" 					value="#thisTag.customerFreightUom#">
          
		  <cfinput type="hidden" name="bIncludeVolumePage" 					value="#thisTag.bIncludeVolumePage#">
          <cfinput type="hidden" name="bInsertWatermark" 					value="#thisTag.bInsertWatermark#">
		  <cfinput type="hidden" name="bAddcustomerproductnumbers" 			value="#thisTag.bAddcustomerproductnumbers#">
          <cfif thisTag.bAddcustomerproductnumbers>
            <!--- forward valueLists follow... --->
            <cfinput type="hidden" name="lsPreFormFixedPriceCustomerProductNumbers" value="#thisTag.lsPreFormFixedPriceCustomerProductNumbers#">
            <cfinput type="hidden" name="lsPreFormRebateCustomerProductNumbers" 		value="#thisTag.lsPreFormRebateCustomerProductNumbers#">
	    <cfinput type="hidden" name="lsPreFormLumpsumCustomerProductNumbers" 		value="#thisTag.lsPreFormLumpsumCustomerProductNumbers#">	    
            <cfinput type="hidden" name="lsPreFormBidRequestCustomerProductNumbers" value="#thisTag.lsPreFormBidRequestCustomerProductNumbers#">
          </cfif>

          <cfformitem type="script">
            public function updateOnOffGrid(grid:mx.controls.DataGrid, columnToUpdate:String, ckBx:mx.controls.CheckBox) {
            
                for (var currentRow = 0; currentRow < grid.dataProvider.length; currentRow++)
                {
                    grid.dataProvider.editField(currentRow, columnToUpdate, ckBx.value);
                }

            }

	      public function tnView(lbl,ckBx, tn, record_count, previously_deleted_pages)
		{
		
		/* Reset the "Pages to Delete Now" textbox */
		lbl.text = '';

		/* Initialize an array to hold the "unchecked" checkboxes, i.e. pages to delete */
		var chkbox_array = [ ];
	
		for (var currentRow = 0; currentRow < record_count; currentRow++)
		{
			/* If unchecked, add to array */
			if (ckBx[currentRow].value == false)
			{
				chkbox_array.push(ckBx[currentRow].label);
			}
			/* If checked, delete from array */
			else
			{
				chkbox_array.splice(currentRow,ckBx[currentRow].label);
			}
		  
		  /* Hide/Show the Image of the page based on the checkbox status */
		  tn[currentRow].visible = ckBx[currentRow].value;
		  _root.rdPg.radioList[currentRow].visible = ckBx[currentRow].value;

		  /* If a page has been previously deleted, then do not show the page, checkbox, radio
		     button for that page.
		  */
		  HidePreviouslyDeleted(previously_deleted_pages,ckBx, tn)
		}
	
		/* "Pages to Delete Now" textbox has the pages to delete as a comma separated list */
		lbl.text = chkbox_array.join(",");
	
	}
			
            public function previewPage(pdfurl:String)
            {
            	getURL(pdfurl, '_blank');
            }

	   public function HidePreviouslyDeleted(pages,cbPg,tnPg)
	   {
		/* Initialize array to hold the pages previously deleted  */
		var Arrpages = [ ];
		var lastChar = "";

		lastChar = pages.charAt(pages.length-1);
		
		/* Remove the trailing comma, if one exists. */
		if(lastChar == ","){
			pages = pages.slice(0,-1);
		}
		
		/* Create an array of the pages passed */
		Arrpages = pages.split(",");
		
		/* If there is at least 1 previously deleted page */
		if(pages != '')
		{
			/* Loop through the array of previously deleted pages */
			for (var currentRow = 0; currentRow < Arrpages.length; currentRow++)
			{
			        /* Hide for previously deleted pages */

				/* Hide checkbox */
				cbPg[Arrpages[currentRow] -1].visible = false;

				/* Hide Image */
				tnPg[Arrpages[currentRow] -1].visible = false;

				/* Hide radio button */
				_root.rdPg.radioList[Arrpages[currentRow] -1].visible = false;
				
			}
		}
	   }
	  </cfformitem>
		      <!--- Pass #thisTag.cumulativePagesDeletedFromThisLetter#. We cannot use control_name.value etc. It does not work --->
		      <cfformgroup type="accordion" label="#thisTag.stPDFHeaderInfo.program_title# Program #thisTag.letter_type# Options" onChange="HidePreviouslyDeleted('#thisTag.cumulativePagesDeletedFromThisLetter#',cbPg,tnPg,rdPg)">

			<!--- 1.) IF we have some 'Distributor'... --->
            <cfif thisTag.qProgramDistributor.recordCount>
              <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# DISTRIBUTOR Data" type="page">
              	<!--- IF we have a letter for ONE distributor... --->
           	  <cfif thisTag.qProgramDistributor.recordCount NEQ 1>
              		<cfinput type="checkbox" name="selectAll_distributor" value="1" label="Select OR Deselect Entire Distributor Section" onClick="updateOnOffGrid(dgDistributorInfo,'bDisplayDistributor',selectAll_distributor);">
              </cfif>
                <cfgrid name="dgDistributorInfo" query="thisTag.qProgramDistributor" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" 	font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE">
                	<!--- IF we have a letter for ONE distributor... --->
               	  <cfif thisTag.qProgramDistributor.recordCount NEQ 1>
            				<cfgridcolumn name="bDisplayDistributor" 			header="List on PDF" 		display="yes" 	type="boolean" 				select="yes" 	width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  </cfif>
            			<cfgridcolumn name="contract_distributors_id" header="Distributor ID" display="no" 	type="numeric"				select="no" 	width="100">
                  <cfgridcolumn name="shr_ship_to" 				header="Distributor ID" 		display="yes" 	type="numeric"				select="no" 	width="100">
                  <cfgridcolumn name="name" 							header="Distributor" 		display="yes" 	type="string_nocase"	select="no" 	width="350">
                  <cfgridcolumn name="city" 							header="City" 					display="yes" 	type="string_nocase"	select="no" 	width="200">
                  <cfgridcolumn name="state" 							header="State" 					display="yes" 	type="string_nocase" 	select="no" 	width="50">
                </cfgrid>
              </cfformgroup>
            </cfif>
		        
		        <!--- 2.) IF we have some 'Operator'... --->
            <cfif thisTag.qProgramOperator.recordCount>
              <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# OPERATOR Data" type="page">
              	<!--- IF we have a letter for ONE operator... --->
           	  <cfif thisTag.qProgramOperator.recordCount NEQ 1>
              		<cfinput type="checkbox" name="selectAll_operator" value="1" label="Select OR Deselect Entire Operator section" onClick="updateOnOffGrid(dgOperatorInfo,'bDisplayOperator',selectAll_operator);">
              </cfif>
                <cfgrid name="dgOperatorInfo" query="thisTag.qProgramOperator" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE">
                <!--- IF we have a letter for ONE operator... --->
           		  <cfif thisTag.qProgramOperator.recordCount NEQ 1>
                	<cfgridcolumn name="bDisplayOperator" 			header="List on PDF" 		display="yes" 	type="boolean" 				select="yes" 	width="100" bgcolor="##FFFFFF" textcolor="##990000">
                </cfif>
            			<cfgridcolumn name="operator_id" 			header="Operator ID" 		display="yes" 	type="numeric"				select="no" 	width="100">
                  <cfgridcolumn name="legacy_id" 				header="Legacy ID" 			display="yes" 	type="string_nocase"	select="no" 	width="100">
                  <cfgridcolumn name="operator_name" 		header="Operator" 			display="yes" 	type="string_nocase"	select="no" 	width="350">
                  <cfgridcolumn name="operator_city" 		header="City" 					display="yes" 	type="string_nocase"	select="no" 	width="200">
                  <cfgridcolumn name="operator_state" 	header="State" 					display="yes" 	type="string_nocase" 	select="no" 	width="50">
                </cfgrid>
              </cfformgroup>
            </cfif>
		    
		    		<!--- 3.) IF we want to show 'Fixed Price' AND we have some 'Fixed Price'... --->
	          <cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount>
            
<!--- =========== POPULATE GRID FOR Fixed Price, Rebate, Bid Request (Growth On Deck) ======================================================================
= We need to employ bindings here for the possibility of the Customer Product Numbers if and when appSettings is ON for this client AND ====================
= we also need the option of selecting OR deselecting ALL with bindings preferably, SO... we can not use the query attribute of the cfgrid and must ========
= populate the dataGrid in this fashion w/a loop over an array of structs with cfGridRow. Note: When the query attribute is employed, the cfGridRow ========
= tag is ignored. There was a known issue with the visibility of entered data on selectable/editable columns. I believe that this is fixed now. RBL ========
======================================================================================================================================================= --->

<!--- let's loop over our NET Query and build our array of structs with which to populate EDITABLE dataGrid... --->
<cfset thisTag.aFixedPriceProducts = arrayNew(1)>
<cfloop query="thisTag.qProgramFixedPrice">
              
	<cfset thisTag.stCurrentFixedPriceProduct = structNew()>
                
	<cfset structInsert(thisTag.stCurrentFixedPriceProduct,"bDisplayFixedPriceProduct",thisTag.qProgramFixedPrice.bDisplayFixedPriceProduct,true)>
  <cfif thisTag.bAddcustomerproductnumbers>
    <!--- IF empty string incoming, 'na'... --->
    <cfif len(trim(thisTag.qProgramFixedPrice.customer_product_number[currentRow]))>
      <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"customer_product_number",trim(thisTag.qProgramFixedPrice.customer_product_number[currentRow]),true)>
    <cfelse>
      <!--- we will only display this in our edit grid... --->
      <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"customer_product_number","na",true)>
    </cfif>
  </cfif>
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"bsa_id_uom_comp_id",trim(replace(thisTag.qProgramFixedPrice.bsa_id_uom_comp_id[currentRow],' ','','ALL')),true)>
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"item",trim(thisTag.qProgramFixedPrice.item[currentRow]),true)>
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"description",trim(thisTag.qProgramFixedPrice.description[currentRow]),true)>
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"program_fixed_component_id",trim(thisTag.qProgramFixedPrice.program_fixed_component_id[currentRow]),true)>  
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"program_fixed_component_name",trim(thisTag.qProgramFixedPrice.program_fixed_component_name[currentRow]),true)>
  <cfif thisTag.qProgramFixedPrice.Fixed_Component_Paid_to[currentRow] EQ 1>
  	<cfset structInsert(thisTag.stCurrentFixedPriceProduct,"fixed_component_paid_to_description",application.returned_customer_setting.distributor_label_singular,true)>
	<cfelse>
  	<cfset structInsert(thisTag.stCurrentFixedPriceProduct,"fixed_component_paid_to_description",application.returned_customer_setting.operator_label_singular,true)>
	</cfif>
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"fixed_price_per_pound",'$'&trim(numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound[currentRow],'_9.9999')),true)>
  <cfset structInsert(thisTag.stCurrentFixedPriceProduct,"fixed_price_per_case",'$'&trim(numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case[currentRow],'_99.99')),true)> 
  
  <cfset arrayAppend(thisTag.aFixedPriceProducts,thisTag.stCurrentFixedPriceProduct)>

</cfloop>
            
<!--- #UCase(thisTag.qProgramFixedPrice.Program_Fixed_Component_Name[1])# #thisTag.qProgramFixedPrice.Program_Fixed_Component_Id[1]# () --->           
            
	            <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# FIXED PRICE Data" type="page">
                <cfinput type="checkbox" name="selectAll_fixedPrice" value="1" label="Select OR Deselect Entire Fixed Price Section (delay)" onClick="updateOnOffGrid(dgFixedPriceInfo,'bDisplayFixedPriceProduct',selectAll_fixedPrice);">
		            <cfgrid name="dgFixedPriceInfo" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE">
			            <cfgridcolumn name="bDisplayFixedPriceProduct" 	header="List on PDF" 		display="yes" 	type="boolean" 				select="yes" 	width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
					  <cfif thisTag.bAddcustomerproductnumbers>
										<cfgridcolumn name="customer_product_number"	header="Customer Product Number" display="yes" 	type="string_nocase"	select="yes" width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  </cfif>
                  <!--- Let's add a customer_product_number if environment calls for it... [end] --->
									<cfgridcolumn name="bsa_id_uom_comp_id" 																				display="no" 		type="string_nocase"	select="no">                
									<cfgridcolumn name="item" 												header="Item ID" 							display="yes" 	type="string_nocase"	select="no" 	width="100">
			            <cfgridcolumn name="description" 									header="Description" 					display="yes" 	type="string_nocase"	select="no" 	width="250">
                  <cfgridcolumn name="program_fixed_component_id" 	header="Comp ID" 							display="no" 	type="numeric"				select="no" 	width="50">
                  <cfgridcolumn name="program_fixed_component_name" header="Comp Name"						display="yes" 	type="string_nocase"	select="no" 	width="100">
                  <cfgridcolumn name="fixed_component_paid_to_description" header="Comp Paid To"	display="yes" 	type="string_nocase"	select="no" 	width="150">
                  <cfgridcolumn name="fixed_price_per_pound" 				header="Price Per Pound"			display="yes" 	type="string_nocase" 	select="no" 	width="100">
			            <cfgridcolumn name="fixed_price_per_case" 				header="Price Per Case" 			display="yes" 	type="string_nocase" 	select="no" 	width="100">
                  <!--- let's loop over NET Array of structs and populate EDITABLE dataGrid... --->
                  <cfloop from="1" to="#arrayLen(thisTag.aFixedPriceProducts)#" index="current_fixedPrice">

<!--- Let's add a customer_product_number if environment calls for it... [begin] --->
<cfif thisTag.bAddcustomerproductnumbers>
  <cfgridrow data="#thisTag.aFixedPriceProducts[current_fixedPrice].bDisplayFixedPriceProduct#,#thisTag.aFixedPriceProducts[current_fixedPrice].customer_product_number#,#thisTag.aFixedPriceProducts[current_fixedPrice].bsa_id_uom_comp_id#,#thisTag.aFixedPriceProducts[current_fixedPrice].item#,#thisTag.aFixedPriceProducts[current_fixedPrice].description#,#thisTag.aFixedPriceProducts[current_fixedPrice].program_fixed_component_id#,#thisTag.aFixedPriceProducts[current_fixedPrice].program_fixed_component_name#,#thisTag.aFixedPriceProducts[current_fixedPrice].fixed_component_paid_to_description#,#thisTag.aFixedPriceProducts[current_fixedPrice].fixed_price_per_pound#,#thisTag.aFixedPriceProducts[current_fixedPrice].fixed_price_per_case#">
<cfelse>
  <cfgridrow data="#thisTag.aFixedPriceProducts[current_fixedPrice].bDisplayFixedPriceProduct#,#thisTag.aFixedPriceProducts[current_fixedPrice].bsa_id_uom_comp_id#,#thisTag.aFixedPriceProducts[current_fixedPrice].item#,#thisTag.aFixedPriceProducts[current_fixedPrice].description#,#thisTag.aFixedPriceProducts[current_fixedPrice].program_fixed_component_id#,#thisTag.aFixedPriceProducts[current_fixedPrice].program_fixed_component_name#,#thisTag.aFixedPriceProducts[current_fixedPrice].fixed_component_paid_to_description#,#thisTag.aFixedPriceProducts[current_fixedPrice].fixed_price_per_pound#,#thisTag.aFixedPriceProducts[current_fixedPrice].fixed_price_per_case#">
</cfif>

                  </cfloop>
                  
		          	</cfgrid>
	            </cfformgroup>
		        </cfif>

		        <!--- 4.) IF we want to show 'Rebate' AND we have some 'Rebate'... --->
	          <cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount>
            
<!--- =========== POPULATE GRID FOR Fixed Price, Rebate, Bid Request (Growth On Deck) ======================================================================
= We need to employ bindings here for the possibility of the Customer Product Numbers if and when appSettings is ON for this client AND ====================
= we also need the option of selecting OR deselecting ALL with bindings preferably, SO... we can not use the query attribute of the cfgrid and must ========
= populate the dataGrid in this fashion w/a loop over an array of structs with cfGridRow. Note: When the query attribute is employed, the cfGridRow ========
= tag is ignored. There is a known issue with the visibility of entered data on selectable/editable columns. Testing to fix hopefully in this fashion. RBL =
======================================================================================================================================================= --->

<!--- let's loop over our NET Query and build our array of structs with which to populate EDITABLE dataGrid... --->
<cfset thisTag.aRebateProducts = arrayNew(1)>
<cfloop query="thisTag.qProgramRebate">
              
	<cfset thisTag.stCurrentRebateProduct = structNew()>
                
	<cfset structInsert(thisTag.stCurrentRebateProduct,"bDisplayRebateProduct",thisTag.qProgramRebate.bDisplayRebateProduct,true)>
  <cfif thisTag.bAddcustomerproductnumbers>
    <!--- IF empty string incoming, 'na'... --->
    <cfif len(trim(thisTag.qProgramRebate.customer_product_number[currentRow]))>
      <cfset structInsert(thisTag.stCurrentRebateProduct,"customer_product_number",trim(thisTag.qProgramRebate.customer_product_number[currentRow]),true)>
    <cfelse>
      <!--- we will only display this in our edit grid... --->
      <cfset structInsert(thisTag.stCurrentRebateProduct,"customer_product_number","na",true)>
    </cfif>
  </cfif>
  <cfset structInsert(thisTag.stCurrentRebateProduct,"bsa_id_uom_comp_id",trim(replace(thisTag.qProgramRebate.bsa_id_uom_comp_id[currentRow],' ','','ALL')),true)>
  <cfset structInsert(thisTag.stCurrentRebateProduct,"item",trim(thisTag.qProgramRebate.item[currentRow]),true)>
  <cfset structInsert(thisTag.stCurrentRebateProduct,"description",trim(thisTag.qProgramRebate.description[currentRow]),true)>
  <cfset structInsert(thisTag.stCurrentRebateProduct,"program_rebate_component_id",trim(thisTag.qProgramRebate.program_rebates_component_id[currentRow]),true)>  
  <cfset structInsert(thisTag.stCurrentRebateProduct,"program_rebate_component_name",trim(thisTag.qProgramRebate.program_rebates_component_name[currentRow]),true)>

  <cfif thisTag.qProgramRebate.Component_Paid_to[currentRow] EQ 1>
  	<cfset structInsert(thisTag.stCurrentRebateProduct,"rebate_component_paid_to_description",application.returned_customer_setting.distributor_label_singular,true)>
	<cfelse>
  	<cfset structInsert(thisTag.stCurrentRebateProduct,"rebate_component_paid_to_description",application.returned_customer_setting.operator_label_singular,true)>
	</cfif>
  <cfset structInsert(thisTag.stCurrentRebateProduct,"rebate_price_per_pound",'$'&trim(numberFormat(thisTag.qProgramRebate.rebate_price_per_pound[currentRow],'_9.9999')),true)>
  <cfset structInsert(thisTag.stCurrentRebateProduct,"rebate_price_per_case",'$'&trim(numberFormat(thisTag.qProgramRebate.rebate_price_per_case[currentRow],'_99.99')),true)> 

	<cfset arrayAppend(thisTag.aRebateProducts,thisTag.stCurrentRebateProduct)>

</cfloop>

<!--- #UCase(thisTag.qProgramRebate.Program_Rebates_Component_Name[1])# #thisTag.qProgramRebate.Program_Rebates_Component_Id[1]# () --->
            
	            <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# REBATE Data" type="page">
                <cfinput type="checkbox" name="selectAll_rebate" value="1" label="Select OR Deselect Entire Rebate Section (delay)" onClick="updateOnOffGrid(dgRebateInfo,'bDisplayRebateProduct',selectAll_rebate);">
		            <cfgrid name="dgRebateInfo" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE">
			            <cfgridcolumn name="bDisplayRebateProduct" 	header="List on PDF" 		display="yes" 	type="boolean" 				select="yes" 	width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
					  <cfif thisTag.bAddcustomerproductnumbers>
										<cfgridcolumn name="customer_product_number"	header="Customer Product Number" 	display="yes" type="string_nocase"	select="yes" width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  </cfif>
                  <!--- Let's add a customer_product_number if environment calls for it... [end] --->
									<cfgridcolumn name="bsa_id_uom_comp_id" 																				display="no" 		type="string_nocase"	select="no">                
									<cfgridcolumn name="item" 													header="Item ID" 						display="yes" 	type="string_nocase"	select="no" 	width="100">
			            <cfgridcolumn name="description" 										header="Description" 				display="yes" 	type="string_nocase"	select="no" 	width="250">
                  <cfgridcolumn name="program_rebate_component_id" 		header="Comp ID" 						display="no" 	type="numeric"				select="no" 	width="50">
                  <cfgridcolumn name="program_rebate_component_name" 	header="Comp Name"					display="yes" 	type="string_nocase"	select="no" 	width="100">
                  <cfgridcolumn name="rebate_component_paid_to_description" header="Comp Paid To"	display="yes" 	type="string_nocase"	select="no" 	width="150">
                  <cfgridcolumn name="rebate_price_per_pound" 				header="Price Per Pound" 		display="yes" 	type="string_nocase" 	select="no" 	width="100">
			            <cfgridcolumn name="rebate_price_per_case" 					header="Price Per Case" 		display="yes" 	type="string_nocase" 	select="no" 	width="100">
                  <!--- let's loop over NET Array of structs and populate EDITABLE dataGrid... --->
                  <cfloop from="1" to="#arrayLen(thisTag.aRebateProducts)#" index="current_rebate">

<!--- Let's add a customer_product_number if environment calls for it... [begin] --->
<cfif thisTag.bAddcustomerproductnumbers>
  <cfgridrow data="#thisTag.aRebateProducts[current_rebate].bDisplayRebateProduct#,#thisTag.aRebateProducts[current_rebate].customer_product_number#,#thisTag.aRebateProducts[current_rebate].bsa_id_uom_comp_id#,#thisTag.aRebateProducts[current_rebate].item#,#thisTag.aRebateProducts[current_rebate].description#,#thisTag.aRebateProducts[current_rebate].program_rebate_component_id#,#thisTag.aRebateProducts[current_rebate].program_rebate_component_name#,#thisTag.aRebateProducts[current_rebate].rebate_component_paid_to_description#,#thisTag.aRebateProducts[current_rebate].rebate_price_per_pound#,#thisTag.aRebateProducts[current_rebate].rebate_price_per_case#">
<cfelse>
  <cfgridrow data="#thisTag.aRebateProducts[current_rebate].bDisplayRebateProduct#,#thisTag.aRebateProducts[current_rebate].bsa_id_uom_comp_id#,#thisTag.aRebateProducts[current_rebate].item#,#thisTag.aRebateProducts[current_rebate].description#,#thisTag.aRebateProducts[current_rebate].program_rebate_component_id#,#thisTag.aRebateProducts[current_rebate].program_rebate_component_name#,#thisTag.aRebateProducts[current_rebate].rebate_component_paid_to_description#,#thisTag.aRebateProducts[current_rebate].rebate_price_per_pound#,#thisTag.aRebateProducts[current_rebate].rebate_price_per_case#">
</cfif>
                  </cfloop>
                  
		          	</cfgrid>
	            </cfformgroup>
		        </cfif>

            <!--- 5.) IF we want to show 'Bid Request' AND we have some 'Bid Request'... --->
	          <cfif thisTag.stPDFBodyInfo.bDisplayBidRequest AND thisTag.qProgramBidRequest.recordCount>
            
<!--- =========== POPULATE GRID FOR Fixed Price, Rebate, Bid Request (Growth On Deck) ======================================================================
= We need to employ bindings here for the possibility of the Customer Product Numbers if and when appSettings is ON for this client AND ====================
= we also need the option of selecting OR deselecting ALL with bindings preferably, SO... we can not use the query attribute of the cfgrid and must ========
= populate the dataGrid in this fashion w/a loop over an array of structs with cfGridRow. Note: When the query attribute is employed, the cfGridRow ========
= tag is ignored. There is a known issue with the visibility of entered data on selectable/editable columns. I believe that this is fixed now. RBL =========
======================================================================================================================================================= --->            

<!--- let's loop over our NET Query and build our array of structs with which to populate EDITABLE dataGrid... --->
<cfset thisTag.aBidRequestProducts = arrayNew(1)>
<cfloop query="thisTag.qProgramBidRequest">
              
	<cfset thisTag.stCurrentBidRequestProduct = structNew()>
                
	<cfset structInsert(thisTag.stCurrentBidRequestProduct,"bDisplayBidRequestProduct",thisTag.qProgramBidRequest.bDisplayBidRequestProduct,true)>
  <cfif thisTag.bAddcustomerproductnumbers>
    <!--- IF empty string incoming, 'na'... --->
    <cfif len(trim(thisTag.qProgramBidRequest.customer_product_number[currentRow]))>
      <cfset structInsert(thisTag.stCurrentBidRequestProduct,"customer_product_number",trim(thisTag.qProgramBidRequest.customer_product_number[currentRow]),true)>
    <cfelse>
      <!--- we will only display this in our edit grid... --->
      <cfset structInsert(thisTag.stCurrentBidRequestProduct,"customer_product_number","na",true)>
    </cfif>
  </cfif>
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"bsa_id_uom_comp_id",trim(replace(thisTag.qProgramBidRequest.bsa_id_uom_comp_id[currentRow],' ','','ALL')),true)>
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"item",trim(thisTag.qProgramBidRequest.item[currentRow]),true)>
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"description",trim(thisTag.qProgramBidRequest.description[currentRow]),true)>
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"program_bidRequest_component_id",trim(thisTag.qProgramBidRequest.program_bidRequest_component_id[currentRow]),true)>  
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"program_bidRequest_component_name",trim(thisTag.qProgramBidRequest.program_bidRequest_component_name[currentRow]),true)>
  <cfif thisTag.qProgramBidRequest.Program_BidRequest_Component_Paid_to[currentRow] EQ 1>
  	<cfset structInsert(thisTag.stCurrentBidRequestProduct,"bidRequest_component_paid_to_description",application.returned_customer_setting.distributor_label_singular,true)>
	<cfelse>
  	<cfset structInsert(thisTag.stCurrentBidRequestProduct,"bidRequest_component_paid_to_description",application.returned_customer_setting.operator_label_singular,true)>
	</cfif>
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"bid_request_per_pound",'$'&trim(numberFormat(thisTag.qProgramBidRequest.bid_request_per_pound[currentRow],'_9.9999')),true)>
  <cfset structInsert(thisTag.stCurrentBidRequestProduct,"bid_request_per_case",'$'&trim(numberFormat(thisTag.qProgramBidRequest.bid_request_per_case[currentRow],'_99.99')),true)> 

	<cfset arrayAppend(thisTag.aBidRequestProducts,thisTag.stCurrentBidRequestProduct)>

</cfloop>

<!--- #UCase(thisTag.qProgramBidRequest.Program_Bidrequest_Component_Name[1])# #thisTag.qProgramBidRequest.Program_Bidrequest_Component_Id[1]# () --->
            
	            <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# BID REQUEST Data" type="page">
                <cfinput type="checkbox" name="selectAll_bidRequest" value="1" label="Select OR Deselect Entire Bid Requests Section (delay)" onClick="updateOnOffGrid(dgBidRequestInfo,'bDisplayBidRequestProduct',selectAll_bidRequest);">
		            <cfgrid name="dgBidRequestInfo" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE">
			            <cfgridcolumn name="bDisplayBidRequestProduct" 	header="List on PDF" 		display="yes" 	type="boolean" 				select="yes" 	width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
					  <cfif thisTag.bAddcustomerproductnumbers>
										<cfgridcolumn name="customer_product_number"	header="Customer Product Number" 	display="yes" 	type="string_nocase"	select="yes" width="100" bgcolor="##FFFFFF" textcolor="##990000">
                  </cfif>
                  <!--- Let's add a customer_product_number if environment calls for it... [end] --->
									<cfgridcolumn name="bsa_id_uom_comp_id" 																	display="no" 		type="string_nocase"	select="no">                
									<cfgridcolumn name="item" 											header="Item ID" 					display="yes" 	type="string_nocase"	select="no" 	width="100">
			            <cfgridcolumn name="description" 								header="Description" 			display="yes" 	type="string_nocase"	select="no" 	width="250">
                  <cfgridcolumn name="program_bidRequest_component_id" 	header="Comp ID" 				display="yes" 	type="numeric"				select="no" 	width="50">
                  <cfgridcolumn name="program_bidRequest_component_name" header="Comp Name"			display="yes" 	type="string_nocase"	select="no" 	width="100">
                  <cfgridcolumn name="bidRequest_component_paid_to_description" header="Comp Paid To"	display="yes" 	type="string_nocase"	select="no" 	width="150">
                  <cfgridcolumn name="bid_request_per_pound" 			header="Price Per Pound" 	display="yes" 	type="string_nocase" 	select="no" 	width="100">
			            <cfgridcolumn name="bid_request_per_case" 			header="Price Per Case" 	display="yes" 	type="string_nocase" 	select="no" 	width="100">
                  <!--- let's loop over NET Array of structs and populate EDITABLE dataGrid... --->
                  <cfloop from="1" to="#arrayLen(thisTag.aBidRequestProducts)#" index="current_bidRequest">

<!--- Let's add a customer_product_number if environment calls for it... [begin] --->
<cfif thisTag.bAddcustomerproductnumbers>
  <cfgridrow data="#thisTag.aBidRequestProducts[current_bidRequest].bDisplayBidRequestProduct#,#thisTag.aBidRequestProducts[current_bidRequest].customer_product_number#,#thisTag.aBidRequestProducts[current_bidRequest].bsa_id_uom_comp_id#,#thisTag.aBidRequestProducts[current_bidRequest].item#,#thisTag.aBidRequestProducts[current_bidRequest].description#,#thisTag.aBidRequestProducts[current_bidRequest].program_bidRequest_component_id#,#thisTag.aBidRequestProducts[current_bidRequest].program_bidRequest_component_name#,#thisTag.aBidRequestProducts[current_bidRequest].bidRequest_component_paid_to_description#,#thisTag.aBidRequestProducts[current_bidRequest].bid_request_per_pound#,#thisTag.aBidRequestProducts[current_bidRequest].bid_request_per_case#">
<cfelse>
  <cfgridrow data="#thisTag.aBidRequestProducts[current_bidRequest].bDisplayBidRequestProduct#,#thisTag.aBidRequestProducts[current_bidRequest].bsa_id_uom_comp_id#,#thisTag.aBidRequestProducts[current_bidRequest].item#,#thisTag.aBidRequestProducts[current_bidRequest].description#,#thisTag.aBidRequestProducts[current_bidRequest].program_bidRequest_component_id#,#thisTag.aBidRequestProducts[current_bidRequest].program_bidRequest_component_name#,#thisTag.aBidRequestProducts[current_bidRequest].bidRequest_component_paid_to_description#,#thisTag.aBidRequestProducts[current_bidRequest].bid_request_per_pound#,#thisTag.aBidRequestProducts[current_bidRequest].bid_request_per_case#">
</cfif>
                  </cfloop>
                  
		          	</cfgrid>
	            </cfformgroup>
		        </cfif>

		        <!--- 6.) IF we want to show 'Lump Sum' AND we have some 'Lump Sum'... --->
	          <cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount>

		<cfset thisTag.aLumpSumProducts = arrayNew(1)>
		
		<cfloop query="thisTag.qProgramLumpSum">
			<cfset thisTag.stCurrentLumpSumProduct = structNew()>
				
			<cfset structInsert(thisTag.stCurrentLumpSumProduct,"bDisplayLumpSum",thisTag.qProgramLumpSum.bDisplayLumpSum,true)>
		  <cfif thisTag.bAddcustomerproductnumbers>
		    <!--- IF empty string incoming, 'na'... --->
		    <cfif len(trim(thisTag.qProgramLumpSum.customer_product_number[currentRow]))>
		      <cfset structInsert(thisTag.stCurrentLumpSumProduct,"customer_product_number",trim(thisTag.qProgramLumpSum.customer_product_number[currentRow]),true)>
		    <cfelse>
		      <!--- we will only display this in our edit grid... --->
		      <cfset structInsert(thisTag.stCurrentLumpSumProduct,"customer_product_number","na",true)>
		    </cfif>
		  </cfif>
		  <cfset structInsert(thisTag.stCurrentLumpSumProduct,"bsa_id_comp_id",trim(replace(thisTag.qProgramLumpSum.bsa_id_comp_id[currentRow],' ','','ALL')),true)>
		  <cfset structInsert(thisTag.stCurrentLumpSumProduct,"item",trim(thisTag.qProgramLumpSum.item[currentRow]),true)>
		  <cfset structInsert(thisTag.stCurrentLumpSumProduct,"description",trim(thisTag.qProgramLumpSum.description[currentRow]),true)>
		  <cfset structInsert(thisTag.stCurrentLumpSumProduct,"program_lump_sum_id",trim(thisTag.qProgramLumpSum.program_lump_sum_id[currentRow]),true)>  
		  <cfset structInsert(thisTag.stCurrentLumpSumProduct,"Program_Lump_Sum_Name",trim(thisTag.qProgramLumpSum.Program_Lump_Sum_Name[currentRow]),true)>
		  <cfset structInsert(thisTag.stCurrentLumpSumProduct,"lump_sum_amount",trim(thisTag.qProgramLumpSum.lump_sum_amount[currentRow]),true)>
	      <!---
		  <cfif thisTag.qProgramLumpSum.Component_Paid_to[currentRow] EQ 1>
			<cfset structInsert(thisTag.stCurrentLumpSumProduct,"lumpsum_component_paid_to_description",application.returned_customer_setting.distributor_label_singular,true)>
			<cfelse>
			<cfset structInsert(thisTag.stCurrentLumpSumProduct,"lumpsum_component_paid_to_description",application.returned_customer_setting.operator_label_singular,true)>
		  </cfif>
		  --->

			<cfset arrayAppend(thisTag.aLumpSumProducts,thisTag.stCurrentLumpSumProduct)>

		</cfloop>

		<cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# LUMP SUM Data" type="page">
                <cfinput type="checkbox" name="selectAll_lumpSum" value="1" label="Select OR Deselect Entire Lump Sum Section" onClick="updateOnOffGrid(dgLumpSumInfo,'bDisplayLumpSum',selectAll_lumpSum);">
		    <cfgrid name="dgLumpSumInfo" query="thisTag.qProgramLumpSum" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE">
		    <cfgridcolumn name="bDisplayLumpSum" header="List on PDF" 	display="yes" 	type="boolean" 	select="yes" width="100" bgcolor="##FFFFFF" textcolor="##990000">
		      <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
			<cfif thisTag.bAddcustomerproductnumbers>
			 <cfgridcolumn name="customer_product_number"	header="Customer Product Number" display="yes" 	type="string_nocase"	select="yes" width="100" bgcolor="##FFFFFF" textcolor="##990000">
			</cfif>					
		    <cfgridcolumn name="bsa_id_comp_id" display="no" 	type="string_nocase"	select="no">                
		    <cfgridcolumn name="item" header="Item ID" display="yes" type="string_nocase"	select="no" width="100">
		    <cfgridcolumn name="description" header="Description" display="yes" type="string_nocase" select="no" width="250">					
		    <cfgridcolumn name="program_lump_sum_id" header="Lump Sum ID" 	display="no" type="string_nocase" select="no" width="100">
		    <cfgridcolumn name="program_lump_sum_name" 	header="Lumpsum Description" 	display="yes" 	type="string_nocase"	select="no" width="400">
		    <cfgridcolumn name="lump_sum_amount" header="Amount" display="yes" 	type="currency" select="no" width="150">
		    <!--- let's loop over NET Array of structs and populate EDITABLE dataGrid... --->
			<cfloop from="1" to="#arrayLen(thisTag.aLumpSumProducts)#" index="current_lumpsum">

			 <!--- Let's add a customer_product_number if environment calls for it... [begin] --->
			 <cfif thisTag.bAddcustomerproductnumbers>
			  <!--- Milan - It seems that cfgridrow is in order of cfgridcolumn above --->
			  <cfgridrow data="#thisTag.aLumpSumProducts[current_lumpsum].bDisplayLumpSum#,#thisTag.aLumpSumProducts[current_lumpsum].customer_product_number#,#thisTag.aLumpSumProducts[current_lumpsum].bsa_id_comp_id#,#thisTag.aLumpSumProducts[current_lumpsum].item#,#thisTag.aLumpSumProducts[current_lumpsum].description#,#thisTag.aLumpSumProducts[current_lumpsum].program_lump_sum_id#,#thisTag.aLumpSumProducts[current_lumpsum].program_lump_sum_name#,#thisTag.aLumpSumProducts[current_lumpsum].lump_sum_amount#">
			 <cfelse>
			  <cfgridrow data="#thisTag.aLumpSumProducts[current_lumpsum].bDisplayLumpSum#,#thisTag.aLumpSumProducts[current_lumpsum].bsa_id_comp_id#,#thisTag.aLumpSumProducts[current_lumpsum].item#,#thisTag.aLumpSumProducts[current_lumpsum].description#,#thisTag.aLumpSumProducts[current_lumpsum].program_lump_sum_id#,#thisTag.aLumpSumProducts[current_lumpsum].program_lump_sum_name#,#thisTag.aLumpSumProducts[current_lumpsum].lump_sum_amount#">
			 </cfif>
			</cfloop>
		    </cfgrid>
	          </cfformgroup>
		        </cfif>
		        
		        <!--- 7.) IF we want to show 'Growth' yada yada yada ON DECK...
		        <cfif thisTag.stPDFBodyInfo.bDisplayGrowth>
		        	<cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# GROWTH Data" type="page">
		            <cfformitem type="html">
		              <b>On Deck</b>...
		            </cfformitem>
		          </cfformgroup>
		        </cfif> --->

           	  <!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
		   	  <!--- 8.) IF we have some 'Clause'... --->
	   		  <cfif thisTag.qProgramClause.recordCount>
                
		        <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# CLAUSE Data" type="page" height="180">
                <cfinput type="checkbox" name="selectAll_clause" value="1" label="Select OR Deselect Entire Clause Section" onClick="updateOnOffGrid(dgClauseInfo,'bDisplayClause',selectAll_clause);"><!--- disabled="true" --->
			          <cfgrid name="dgClauseInfo" query="thisTag.qProgramClause" colHeaders="true" colHeaderBold="Yes" colHeaderFont="#thisTag.preferred_fontFamily#" colHeaderFontSize="10" font="#thisTag.preferred_fontFamily#" fontSize="10" selectMode="edit" selectcolor="##FFAEAE" height="160" rowheight="130">
			          	<cfgridcolumn name="bDisplayClause" 					header="List on PDF" 		display="yes" 	type="boolean" 				select="no" 	width="100" bgcolor="##FFFFFF" textcolor="##990000">
									<cfgridcolumn name="Clause_Library_ID" 				header="Clause ID" 			display="yes" 	type="string_nocase"	select="no" 	width="100">
                  <!--- Clause_Library_Body --->
				        <cfgridcolumn 	name="clean_clause" 						header="Clause Library" display="yes" 	type="string_nocase"	select="no" 	width="800">
			          </cfgrid>
		        </cfformgroup>
		        </cfif>
		        TEMPORARILY COMMENT OUT CLAUSE [end] --->            
                
                <cfif len(trim(thisTag.cumulativePagesDeletedFromThisLetter))>
					<cfset thisTag.highestCurrentlyKnownLetterPage = listLen(thisTag.cumulativePagesDeletedFromThisLetter,',')+thisTag.pages>
                    <!--- <cfset thisTag.aDeletedPages = listToArray(thisTag.cumulativePagesDeletedFromThisLetter,',',false)>
                    <cfset thisTag.highestDeletedPage = arrayMax(thisTag.aDeletedPages)>
                    <cfset thisTag.highestCurrentlyKnownLetterPage = max(thisTag.highestDeletedPage,thisTag.pages)> --->
                <cfelse>
                    <cfset thisTag.highestCurrentlyKnownLetterPage = thisTag.pages>
                </cfif>
				
                <!--- 9.) So you want to delete some pages from this masterpiece... --->
              <cfformgroup label="#thisTag.stPDFHeaderInfo.program_title# DELETE Pages [#thisTag.pages# of #thisTag.highestCurrentlyKnownLetterPage#]" type="page" height="210">

                	<cfformitem type="html" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:9px;" height="20"><!--- NOTE: The thumbnails below represent the incoming letter's current pre-edit page count of #thisTag.pages# out of the prior page count of #thisTag.highestCurrentlyKnownLetterPage#. It is suggested that you either delete pages below, OR remove items and/or sections above, NOT both. Otherwise you may experience undesirable results. Products and pages do not directly correlate therefore, it becomes impossible to 100% accurately maintain state when using both methodologies. --->To delete a page, deselect the checkmark next to the page number.</cfformitem>
                
                	<cfformgroup type="horizontal" height="30">
                    	<cfformgroup type="vbox">
                        	<cfinput type="text" name="pages_to_delete_from_prior_letter" label="Pages Previously Deleted" value="#listSort(thisTag.cumulativePagesDeletedFromThisLetter,'numeric','asc',',')#" READONLY width="350">
                        </cfformgroup>
                        <cfformgroup type="vbox">
                        	<cfinput type="text" name="pages_to_delete_from_this_letter" label="Pages To Delete Now" READONLY width="350">
                        </cfformgroup>
                    </cfformgroup>

					<!--- D16774 8/14/08 [begin]
					<!--- Let's grab our PDF full path for THIS letter... --->
                    <cfset useLakebaseForthisTag_qGetPDF = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForthisTag_qGetPDF>
	<cftry>
		<cfset thisTag.qGetPDF = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#thisTag.program_letter_id#",
				"select" = "letter_path"
			}), "letter_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForthisTag_qGetPDF = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForthisTag_qGetPDF>
<cfquery name="thisTag.qGetPDF" datasource="#application.datasource#">
                        SELECT	letter_path
                        FROM	Program_Letters
                        WHERE 	Program_Letters.Program_Letters_ID = #thisTag.program_letter_id#
                    </cfquery>
</cfif>
					--->
					<cfset thisTag.currentLetterPath = trim(application.oLetterManager.getLetterPath(thisTag.program_letter_id))>
                    <!--- D16774 8/14/08 [end] --->

					<!--- #thisTag.program_letter_id# --->

		  <!--- Use pages = "1". No need for thumbnail for every page --->
                  <cfpdf
                      action = "thumbnail"
                      source = "#replace(thisTag.currentLetterPath,'.htm','.pdf','all')#"
                      format = "png"
                      imagePrefix = "tn"
                      overwrite = "yes"
                      pages = "1"
                      password = "#thisTag.program_id#"
                      resolution= "high"
                      scale = "8"
                      transparent = "yes">
              
		    <!--- Populate a query for the "Repeater" --->		  
		    <cfset qPage_Count = queryNew("current_thumbnail")>
		    <cfloop from="1" to="#thisTag.highestCurrentlyKnownLetterPage#" index="j"> 
			<cfset queryAddRow(qPage_Count)>
			<cfset querySetCell(qPage_Count, "current_thumbnail",j)>
		    </cfloop>
		    
		<cfformgroup type="tile" label="PDF Remaining Letter Pages">

		  <!--- Repeater --->
		  <cfformgroup  type="repeater" query="qPage_Count">		

              	<cfset thisTag.current_pdf_page_link = replace(thisTag.currentLetterPath,'.htm','.pdf','all')>
                <cfset thisTag.current_pdf_thumbnail_link = "/common_documents#replace(thisTag.relative_path,'\','/','all')##thisTag.program_id#/#getFileFromPath(thisTag.current_pdf_page_link)###page=">

			<cfformgroup type="vbox">
         		  <cfinput name="rdPg" type="radio" label="View {qPage_Count.currentItem.current_thumbnail}" value="{qPage_Count.currentItem.current_thumbnail}" onClick="previewPage('#thisTag.current_pdf_thumbnail_link#' + rdPg.selectedData)"  tooltip="Click to PREVIEW Page {qPage_Count.currentItem.current_thumbnail} of Letter #thisTag.program_letter_id#">
			  <!--- This is the thumbnail of the first page --->
			  <cfinput name="tnPg" type="button" src="thumbnails/tn_page_1.png">

			  <!--- TESTING
					  previewPage(#trim(replace(thisTag.currentLetterPath,'.htm','.pdf','all'))#);
					  ##page=#current_thumbnail#
					  onClick="getURL('javascript:popUpWindow(\'#thisTag.current_pdf_page_link#\',450,300);');" --->
			  <!--- Pass Query recordcount. control_name.value etc does not work with a Repeater --->
			  <!--- Dev Note: Milan (25646) - If the user does not have the ability to delete pages, then disable the checkbox --->
                          <cfif Get_Profile_Settings.Delete_Pages_Program_Letter eq 1>
			  <cfinput name="cbPg" type="checkbox" checked="yes" label="{qPage_Count.currentItem.current_thumbnail}" tooltip="Deselect to DELETE Page {qPage_Count.currentItem.current_thumbnail} from Letter #thisTag.program_letter_id# OR Select to Start Over" onClick="tnView(pages_to_delete_from_this_letter,cbPg,tnPg,'#qPage_Count.recordcount#','#thisTag.cumulativePagesDeletedFromThisLetter#')"> 
			  <cfelse>
			  <cfinput name="cbPg" type="checkbox" checked="yes" label="{qPage_Count.currentItem.current_thumbnail}" tooltip="Deselect to DELETE Page {qPage_Count.currentItem.current_thumbnail} from Letter #thisTag.program_letter_id# OR Select to Start Over" onClick="tnView(pages_to_delete_from_this_letter,cbPg,tnPg,'#qPage_Count.recordcount#','#thisTag.cumulativePagesDeletedFromThisLetter#')" disabled>
			  </cfif>
			</cfformgroup>

                   </cfformgroup>

                 </cfformgroup>

					<!--- TESTING <cfformgroup type="repeater" query="qPDFTN" width="100%" startrow="0">
                    	<cfformgroup type="hbox">
                        	<cfformgroup type="vbox"> --->
                        
                        	<!--- <cfinput name="{'cbPg_' + qPDFTN.currentItem.pdfPage}" type="text" label="{qPDFTN.currentItem.pdfPage}" tooltip="{'cbPg_' + qPDFTN.currentItem.pdfPage}"> --->
                            
                            	<!--- <cfinput type="Text" name="pg" bind="{qPDFTN.currentItem.pdfPage}" width="20"> --->
							<!--- </cfformgroup> --->
                        
                        <!--- "{qPDFTN.pdfPage}" --->
                          <!--- <cfif NOT listFindNoCase(thisTag.cumulativePagesDeletedFromThisLetter,qPDFTN.pdfPage,',')> --->
                             <!--- <cfinput name="tnPg_#qPDFTN.pdfPage#" type="image" src="thumbnails/tn_page_#qPDFTN.pdfPage#.png" tooltip="Click to PREVIEW Page #qPDFTN.pdfPage# of Letter #thisTag.program_letter_id#" label="#qPDFTN.pdfPage#" onClick="previewPage('#replace(thisTag.currentLetterPath,'.htm','.pdf','all')#')"> --->
                             <!--- <cfinput name="cbPg_#qPDFTN.pdfPage#" type="checkbox" checked="yes" label="#qPDFTN.pdfPage#" tooltip="Click to Deselect and DELETE Page #qPDFTN.pdfPage# from Letter #thisTag.program_letter_id#" onClick="tnView(pages_to_delete_from_this_letter,cbPg_#qPDFTN.pdfPage#,tnPg_#qPDFTN.pdfPage#)">  --->
                          <!--- <cfelse>
                            <cfinput name="tnPg_#qPDFTN.pdfPage#" type="hidden" text="Deleted Prior">
                            <cfinput name="cbPg_#qPDFTN.pdfPage#" type="hidden" checked="no" label="#qPDFTN.pdfPage#">
                          </cfif> --->
                          
                        <!--- </cfformgroup> --->
                    <!--- </cfformgroup> --->

                    <!--- TESTING <cfformgroup type="hbox">
                      <cfloop from="1" to="#thisTag.pages#" index="current_thumbnail">
                      	<cfformgroup type="vbox">
                          <cfif NOT listFindNoCase(thisTag.pagesToDeleteFromPriorLetter,current_thumbnail,',')>
                             <cfinput name="tnPg_#current_thumbnail#" type="image" src="thumbnails/tn_page_#current_thumbnail#.png" tooltip="Click to PREVIEW Page #current_thumbnail# of Letter #thisTag.program_letter_id#" label="#current_thumbnail#" onClick="previewPage('#replace(thisTag.currentLetterPath,'.htm','.pdf','all')#')">
                             <cfinput name="cbPg_#current_thumbnail#" type="checkbox" checked="yes" label="#current_thumbnail#" tooltip="Click to Deselect and DELETE Page #current_thumbnail# from Letter #thisTag.program_letter_id#" onClick="tnView(pages_to_delete_from_this_letter,cbPg_#current_thumbnail#,tnPg_#current_thumbnail#)"> 
                             <!--- ;cbPg_#current_thumbnail#.disabled='true'; --->
                          <cfelse>
                            <cfinput name="tnPg_#current_thumbnail#" type="hidden" text="Deleted Prior">
                            <cfinput name="cbPg_#current_thumbnail#" type="hidden" checked="no" label="#current_thumbnail#">
                          </cfif>
                        </cfformgroup>     
                      </cfloop>
                    </cfformgroup> --->

		      </cfformgroup>

		        <!--- 10.) ... and in the end... --->
		        <cfformgroup label="Confirm #thisTag.stPDFHeaderInfo.program_title# Modified #thisTag.letter_type# PDF Letter" type="page">
							<!--- KEEP FOR A BIT IN CASE... <cfselect name="reviewed" label="Above Distributor Info Reviewed?" onChange="#requireInfo#" required="true" message="Please VERIFY that you have reviewed the above distributor info for this Revised Distributor Document to be created for you NOW.">
                <option value="false" selected>I have NOT fully reviewed the above distributor info yet. Please wait.</option>
                <option value="true">I have reviewed the above distributor info completely. Please create distributor document now.</option>
              </cfselect> --->
							<!--- KEEP FOR A BIT IN CASE... <cfinput type="text" name="revised_doc_title" label="Revised #thisTag.letter_type# Document Title" onChange="#requireInfo#" required="true" message="Please enter a TITLE for this Revised #thisTag.letter_type# Document to be created for you NOW."> --->

              <cfinput type="hidden" name="revised_doc_title" value=""> 	     
		          <cfformgroup type="horizontal">
		        		<cfinput type="reset" 		name="reset" 		value="Reset Form">
		          		<cfinput type="submit" 		name="edit" 		value="Create Modified PDF Letter">
                  <!--- enabled="false" --->
		          </cfformgroup>
		        </cfformgroup>
		        
		    	</cfformgroup>
		  	</cfformgroup>
		  </cfform>
		</td>
	</tr>
	<!--- payment types --->
    <!--- <tr>
        <td>
            <cfinclude template="doc_modules/inc_all_payment_type.cfm">
        </td>
    </tr> --->
    <!--- signatures --->
    <tr>
        <td>
           <cfinclude template="doc_modules/inc_all_clauses.cfm">
        </td>
    </tr>
    <tr>
        <td>
           <cfinclude template="doc_modules/inc_#thisTag.abbreviation#_signatures.cfm">
        </td>
    </tr>
</table>

</cfoutput>
<!--- HTML Ends Here --->
