<cfsilent>
<!---
FILE: 			Generate Program PDF
FILENAME:   	generate_program_pdf.cfm
CREATED: 		12/15/2007 - RBL
EDITED:			03/16/2009 - RBL [MVC v11 - named lock around cfdocument, etc.]
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]
EDITED:			09/15/2010 - Milan [Add template setting to show/hide info on the letter]

FUNCTIONALITY:
- 	This CF8 custom tag generates a pdf file [with OR without a watermark] from an html template.
ACTION: Prior to production after 1/31/2008 corrections - modify links from doc relative to site rel AND Test!

LEGEND:
Bid Request 		should always be in Program_Bidrequest_Component_Id,Program_Bidrequest_Component_Paid_to,item ORDER
Fixed Price 		should always be in Program_Fixed_Component_Id,Fixed_Component_Paid_to,item ORDER
Lump Sum Items	should always be in item ORDER
Rebate 					should always be in item,Program_Rebates_Component_ID,Component_Paid_to ORDER
--->

<!--- IMPORTANT TECH NOTE: Request Size Limits in CF Admin: Maximum Size of Post Data 1000MB, Request Throttle Threshold 5MB, Request Throttle Memory 1000MB --->  

<!--- ||| These parameters [in alpha] are required for this template to process correctly --->

<!--- we're gonna need a bigger boat... request timeout in seconds 2400=40min wow!---->
<cfsetting requesttimeout="2400">

<!--- CSL_Contract_Main_ID for folder_name --->
<cfparam name="attributes.CMID" 						type="numeric" 	default="0">

<!--- letter_id --->
<cfparam name="attributes.current_program_letter_id"	type="numeric"	default="0">

<!--- nameFormat --->
<cfparam name="attributes.file_name" 					type="string" 	default="">

<!--- queries from the VARS Include for scoping... [begin] --->
<cfparam name="attributes.qGetLetterSettings" 			type="query" 		default="#queryNew('Letter_Settings')#">
<cfparam name="attributes.qGetProgramDetails" 			type="query" 		default="#queryNew('Program_Details')#">
<cfparam name="attributes.qGetTemplateSettings" 		type="query" 		default="#queryNew('Template_Settings')#">
<cfparam name="attributes.qProgramClaimRates"			type="query" 		default="#queryNew('expected_fixed_price_claim_rate_per_case, net_weight', 'Decimal, Decimal')#">
<cfparam name="attributes.claimRateDate"				default="#DateFormat(now(), 'mm/dd/yyyy')#">

<!--- The Magnificent 7 --->
<cfparam name="attributes.qProgramBidRequest"			type="query" 		default="#queryNew('Bid_Request')#">
<cfparam name="attributes.qProgramClause"				type="query" 		default="#queryNew('Clause')#">
<cfparam name="attributes.qProgramDistributor"			type="query" 		default="#queryNew('Distributor')#">
<cfparam name="attributes.qProgramFixedPrice"			type="query" 		default="#queryNew('Fixed_Price,item')#">
<cfparam name="attributes.qProgramLumpSum"				type="query" 		default="#queryNew('Lump_Sum')#">
<cfparam name="attributes.qProgramOperator"				type="query" 		default="#queryNew('Operator')#">
<cfparam name="attributes.qProgramRebate"				type="query" 		default="#queryNew('Rebate')#">
<cfparam name="attributes.qProgramGrowth"				type="query" 		default="#queryNew('Growth')#">
<!--- queries from the VARS Include for scoping... [end] --->

<!--- OPR_path OR DIS_path --->
<cfparam name="attributes.relative_path" 				type="string" 	default="">

<cfparam name="attributes.revised_doc_title" 			type="string" 	default="">

<!--- END structure --->
<cfparam name="attributes.stPDFEndInfo" 				type="struct" 	default="#structNew()#">

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
<cfparam name="attributes.stPDFBodyInfo.bPreDefinedPageBreaks" type="boolean"	default="0"> 

<cfparam name="attributes.stPDFBodyInfo.bDistributorDiscountType" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorDiscountType" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorComponentName" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorComponentName" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorClaimMechanism" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorClaimMechanism" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorPayableTo" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorPayableTo" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorPricingType" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorPricingType" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorPaymentFrequency" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorPaymentFrequency" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorUOM" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorUOM" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorGTIN" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorGTIN" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDistributorProductAttribute_1" type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bOperatorProductAttribute_1" type="boolean"	default="0">


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

<!--- HEADER structure [all strings on purpose] --->
<cfparam name="attributes.stPDFHeaderInfo" 						type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFHeaderInfo.company_address" 		type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.company_logo_path" 	type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.contract_number" 		type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.program_id" 			type="string" 	default="">
<cfparam name="attributes.stPDFHeaderInfo.program_title" 		type="string" 	default="">

<!--- NO FOOTER struct... --->

<!--- INTRO structure --->
<cfparam name="attributes.stPDFIntroInfo" 										type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFIntroInfo.company" 								type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_end_date" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_start_date" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.freight_notes" 						type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.lsFreightBrackets" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.program_payment_frequency" 			type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.program_pricing_type" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.qNotes" 								type="query" 	default="#queryNew('contract_evaluation_notes_id')#">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_email" 		type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_first_name" 	type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_last_name" 	type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_phone" 		type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.responsible_sales_person_title" 		type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.template_name" 						type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.total_program_value" 					type="string" 	default="">

<cfparam name="attributes.template_name" 										type="string" 	default="">

<!--- set preferred fontFamily [CSS syntax] to be embedded in all pdf docs --->
<!---
<cfparam name="attributes.preferred_fontFamily" 								type="string" 	default="">
--->
<!--- logo for watermark [gif,jpg,png] IF none sent, NO watermark --->
<cfparam name="attributes.watermark_image" 										type="string" 	default="blacksmithApplicationsInc.gif">   

<cfparam name="attributes.bAddcustomerproductnumbers"							type="boolean" 	default="0">
<cfparam name="attributes.bLetterDisplayFreight"								type="boolean"	default="0">
<cfparam name="attributes.bIncludeVolumePage"									type="boolean" 	default="0">
<cfparam name="attributes.bInsertWatermark"										type="boolean" 	default="0">
<cfparam name="attributes.customerFreightUom"									type="string"	default="">

<cfparam name="attributes.consignee"											type="string" 	default="">

<cfparam name="attributes.lsDistributorNames" 									type="string" 	default="">
<cfparam name="attributes.lsDistributorIDs" 									type="string" 	default="">
<cfparam name="attributes.lsOperatorNames" 										type="string" 	default="">
<cfparam name="attributes.lsOperatorIDs" 										type="string" 	default="">

<cfparam name="attributes.pages_to_delete_from_prior_letter"					type="string"	default="">
<cfparam name="attributes.pages_to_delete_from_this_letter"						type="string"	default="">

<cfset factory = CreateObject("java","coldfusion.server.ServiceFactory")>
		
<!--- Get CF debugging service --->
<cfset cfdebugger=factory.getDebuggingService()>

	<!--- If CF debugging is ON, Turn it off --->
	<cfif cfdebugger.IsEnabled()>
				<cfset cfdebugger.setEnabled(0)>
	</cfif>

<!--- ||| Overwrite the default values with incoming... --->
<cfset structAppend(thisTag, attributes, true)>

<!--- Initial container of 'all discount' item IDs --->
<cfparam name="thisTag.lsProgramAllDiscountItemGUIDs" 							type="string" default="">

<!--- [html, pdf] --->
<cfset thisTag.doc_type = "pdf">

<cfset thisTag.host 			= cgi.http_host />
<cfset thisTag.protocol 		= application.HTTPVar />


<cfif findNoCase("dist",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "dis">
<cfelseif findNoCase("oper",thisTag.relative_path,1)>
	<cfset thisTag.abbreviation = "opr">
<cfelse>
  <!--- empty string on purpose... D16430 RBL 7/09/08 --->
  <cfset thisTag.abbreviation = "">
</cfif>

<cfset thisTag.relative_url = replace(thisTag.relative_path,'\','/','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'-','_','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'&','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'.','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'''','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,'##','','all')>
<cfset thisTag.file_name = replace(thisTag.file_name,' ','_','all')>

<cfset thisTag.pdf_file_folder_string = application.doc_mapping & thisTag.relative_url & thisTag.CMID>
<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->

<cfset thisTag.pdf_file_folder = expandPath(thisTag.pdf_file_folder_string)>

<cfif NOT directoryExists("#thisTag.pdf_file_folder#")>
	<cfdirectory action = "create" directory = "#thisTag.pdf_file_folder#">	
</cfif>

<cfset thisTag.pdf_file_path_string = thisTag.pdf_file_folder_string & "/" & thisTag.file_name & ".pdf">
<cfset thisTag.pdf_file_path = expandPath(thisTag.pdf_file_path_string)>
<cfset thisTag.pdf_file_path = lCase(thisTag.pdf_file_path)>

  <!--- Freight Summary Schtuff... [begin] --->
  <!--- 7B.) IF we want to include the Freight Summary [begin] --->
  <!--- NOTE: i.) The parent template allows freight, ii.) this letter wants freight iii.) we have distributor(s) associated with this letter's program iv.) we have fixed price items because this letter's program has a fixed price component with a freight information... --->
  <cfif thisTag.stPDFBodyInfo.bTemplateAllowFreightLetters AND thisTag.bLetterDisplayFreight AND thisTag.qProgramDistributor.recordCount>

  	<!--- D16905 AND thisTag.qProgramFixedPrice.recordCount --->
        
        <!--- TEMP [begin]
        <cfset structDelete(application,"oProgramLetterFreightManager")>
        TEMP [end] --->
        
        <!--- MAXIMUM DISTRIBUTORS FOR FREIGHT SECTION FORCED PAGE BREAKS [begin]
		Required Settings = Letter_Type=2(distributor) AND Distributor_Letter_Type=1(one distributor per distributor letter)...
		Code below will cause a page break between distributors within the freight section IF there is a freight section AND IF
		the programDistributor recordCount is equal to or less than the number below.
		Brad calculated this number from the errors experienced of (actual size=84614 where 64000 is allowed) within flash form for editing only...
		to be 75.64% of current recordCount which is/was 102 for Pgm1005329 that I tested with.
		Consequently, Brad multiplied 102 * .7564 and rounded down to 77, otherwise we can not force these page breaks, unless we identify another remedy. --->
        <cfset thisTag.maximumDistributorsForFreightSectionForcedPageBreaks = 77>
        <!--- MAXIMUM DISTRIBUTORS FOR FREIGHT SECTION FORCED PAGE BREAKS [end] --->

        <!--- MVC V11 Edit [begin] --->
				<cfscript>
         application.oController.getObject("mvc.Models.LetterManager");
         application.oController.getObject("components.programs.Letters.ProgramLetterFreightManager");
        </cfscript>
        <!--- MVC V11 Edit [end] --->

		<!--- let's get the whole shabang from the new cfc components.Programs.Letters.ProgramLetterFreightManager --->
        <cfinvoke
        	component="#application.oProgramLetterFreightManager#" 
            method="generateProgramLetterFreightDistributorDatas"
            bLetterDisplayFixedPrice="#thisTag.stPDFBodyInfo.bDisplayFixedPrice#"
            bLetterSectionDisplayFixedPrice="#evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation)#"
            customerFreightUom="#thisTag.customerFreightUom#"
            program_bid_request_status_id="#thisTag.stPDFHeaderInfo.program_bid_request_status_id#"
            program_id="#thisTag.stPDFHeaderInfo.program_id#"
            qProgramDistributor="#thisTag.qProgramDistributor#"
            qProgramFixedPrice="#thisTag.qProgramFixedPrice#"
            returnVariable="thisTag.stPLDIF">
        	<!--- Legend: var_stPLDIF = var_stProgramLetterDistributorItemFreight AllInfo --->

  </cfif>
  <!--- Freight Summary Schtuff... [end] --->
  <!--- NOTE: i.) The parent template allows freight, ii.) this letter wants freight iii.) we have distributor(s) associated with this letter's program iv.) we have fixed price items because this letter's program has a fixed price component with a freight information... --->


<!--- IF we want to include the Volume Page, make sure we only display volume for products already in the letters [begin] --->
<cfif thisTag.bIncludeVolumePage>
	<!---- fixed price ----->
	<cfif thisTag.qProgramFixedPrice.recordCount>
		<cfset thisTag.lsProgramFixedPriceNetItemGUIDs = replace(valueList(thisTag.qProgramFixedPrice.BSA_Foodservice_Items_Master_ID,','),' ','','all')>
		<!--- D16586
		<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.lsProgramFixedPriceNetItemGUIDs) /> --->
        
        <!--- NOTE: Brad changed the logic for this Cumulative & Unique list container throughout letters.
		Brad questions whether the general function uniqueList() works as desired. [ProgramFixedPriceNetItemGUID] --->
        
		<!--- D16586 loop over the lsProgramFixedPriceNetItemGUIDs list [begin] --->
        <cfloop list="#thisTag.lsProgramFixedPriceNetItemGUIDs#" index="thisTag.current_ProgramFixedPriceNetItemGUID">
        
            <!--- IF the current_ProgramFixedPriceNetItemGUID is NOT already in the thisTag.lsProgramAllDiscountItemGUIDs Cumulative & Unique list, ADD IT NOW --->
            <cfif NOT listFindNoCase(thisTag.lsProgramAllDiscountItemGUIDs,trim(thisTag.current_ProgramFixedPriceNetItemGUID),',')>
                <cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.current_ProgramFixedPriceNetItemGUID) />
            </cfif>
        </cfloop>
        <!--- D16586 loop over the lsProgramFixedPriceNetItemGUIDs list [end] --->

	</cfif>
	<!---- freight ----->
	<cfif isDefined("thisTag.stProgramLetterFreightAllInfo.qFOBFixedComp") AND isQuery(thisTag.stProgramLetterFreightAllInfo.qFOBFixedComp) AND thisTag.stProgramLetterFreightAllInfo.qFOBFixedComp.recordCount>
		<cfset thisTag.lsProgramFreightItemGUIDs = replace(valueList(thisTag.stProgramLetterFreightAllInfo.qFOBFixedComp.BSA_Foodservice_Items_Master_ID,','),' ','','all')>
		<!--- D16586
		<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.lsProgramFreightItemGUIDs) /> --->
        
        <!--- NOTE: Brad changed the logic for this Cumulative & Unique list container throughout letters.
		Brad questions whether the general function uniqueList() works as desired. [ProgramFreightItemGUID] --->
        
        <!--- D16586 loop over the lsProgramFreightItemGUIDs list [begin] --->
        <cfloop list="#thisTag.lsProgramFreightItemGUIDs#" index="thisTag.current_ProgramFreightItemGUID">
        
            <!--- IF the current_ProgramFreightItemGUID is NOT already in the thisTag.lsProgramAllDiscountItemGUIDs Cumulative & Unique list, ADD IT NOW --->
            <cfif NOT listFindNoCase(thisTag.lsProgramAllDiscountItemGUIDs,trim(thisTag.current_ProgramFreightItemGUID),',')>
                <cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.current_ProgramFreightItemGUID) />
            </cfif>
        </cfloop>
        <!--- D16586 loop over the lsProgramFreightItemGUIDs list [end] --->
 
	</cfif>
	<!---- rebate ----->
	<cfif thisTag.qProgramRebate.recordCount>
		<cfset thisTag.lsProgramRebateItemGUIDs = replace(valueList(thisTag.qProgramRebate.BSA_Foodservice_Items_Master_ID,','),' ','','all')>
        <!--- D16586
		<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.lsProgramRebateItemGUIDs) /> --->

        <!--- D16586 loop over the lsProgramRebateItemGUIDs list [begin] --->
        <cfloop list="#thisTag.lsProgramRebateItemGUIDs#" index="thisTag.current_ProgramRebateItemGUID">
        
            <!--- IF the current_ProgramRebateItemGUID is NOT already in the thisTag.lsProgramAllDiscountItemGUIDs Cumulative & Unique list, ADD IT NOW --->
            <cfif NOT listFindNoCase(thisTag.lsProgramAllDiscountItemGUIDs,trim(thisTag.current_ProgramRebateItemGUID),',')>
                <cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.current_ProgramRebateItemGUID) />
            </cfif>
        </cfloop>
        <!--- D16586 loop over the lsProgramRebateItemGUIDs list [end] --->

	</cfif>
	<!---- bid request ----->
	<!--- <cfif isDefined("thisTag.qProgramBidRequest") AND listFindNoCase(thisTag.qProgramBidRequest.columnlist,"BSA_Foodservice_Items_Master_ID",",")> --->
    <cfif thisTag.qProgramBidRequest.recordCount>
		<cfset thisTag.lsProgramBidRequestItemGUIDs = replace(valueList(thisTag.qProgramBidRequest.BSA_Foodservice_Items_Master_ID,','),' ','','all')>
        <!--- D16586
		<cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.lsProgramBidRequestItemGUIDs) /> --->
        
        <!--- D16586 loop over the lsProgramBidRequestItemGUIDs list [begin] --->
        <cfloop list="#thisTag.lsProgramBidRequestItemGUIDs#" index="thisTag.current_ProgramBidRequestItemGUID">
        
            <!--- IF the current_ProgramBidRequestItemGUID is NOT already in the thisTag.lsProgramAllDiscountItemGUIDs Cumulative & Unique list, ADD IT NOW --->
            <cfif NOT listFindNoCase(thisTag.lsProgramAllDiscountItemGUIDs,trim(thisTag.current_ProgramBidRequestItemGUID),',')>
                <cfset thisTag.lsProgramAllDiscountItemGUIDs = listAppend(thisTag.lsProgramAllDiscountItemGUIDs, thisTag.current_ProgramBidRequestItemGUID) />
            </cfif>
        </cfloop>
        <!--- D16586 loop over the lsProgramRebateItemGUIDs list [end] --->
        
	</cfif>
	
	<!--- lump sum: list of lump sum products is getting appended in the file inc_*_lump_sum.cfm ---->

	<!---- eliminate duplicates ----->
    <!--- should already be unique NOW... --->
	<!--- D16586 <cfset thisTag.lsProgramAllDiscountItemGUIDs = request.app_general_functions.getUniqueList(thisTag.lsProgramAllDiscountItemGUIDs) /> --->
	
</cfif>
<!--- IF we want to include the Volume Page, make sure we only display volume for products already in the letters [end] --->

</cfsilent>

<!--- get in line... (named instead of scoped!!) --->
 <cflock type="exclusive" timeout="#application.stMvcAppInfo.lockTimeoutSeconds#" name="#thisTag.file_name#">
<!--- || I.) Start Code for PDF doc... --->

<!--- The pdf file path where the pdf file is to be written is passed to this file (generate_program_pdf.cfm) as ".pdf" in the 
"thisTag.pdf_file_path" variable. Since Itext will need to loop through the file once it is written to the location to delete 
empty pages and add header and footer, I have changed the initial file name to use "_temp_1" as an appended value. This file 
could contain empty pages and so Itext will loop through these pages of the file ("_temp_1") and create another file with a 
"_temp_2" as an appended name and will delete "_temp_1" file. Then Itext will loop through the pages of the ("_temp_2") file, 
and add header and footer to it. Finally, it will create a file with nothing appended to it. That file name will be the original 
filename (thisTag.pdf_file_path) passed to this file (generate_program_pdf.cfm).
--->
<cfset thisTag.pdf_file_path = ReplaceNoCase(thisTag.pdf_file_path,".pdf","_temp_1.pdf")>

<!--- Itext Libraries --->
<cfinclude template="doc_modules/inc_all_code_libraries.cfm">

<!--- This contains the intro (beginning) part of the document --->
<cfinclude template="doc_modules/inc_all_intro.cfm">

    <!--- 3.) IF we want fixed_price... --->
    <cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation)>
		<!--- MODIFY CODE FOR THIS APP SETTING ONLY. NO NEED TO MODIFY CODE WHEN THIS APP SETTING IS OFF. EVERY CLIENT SHOULD HAVE THIS APP SETTING ON. --->
    	<cfif thisTag.oAppSettings.getfixedcomponents_on()>

			<cfoutput query="thisTag.qProgramFixedPrice" group="Program_Fixed_Component_Id" groupcasesensitive="no">

				<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for fixed price --->
				<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>				
					<cfset document.newPage()>	
				<cfelse>
					<cfset document.add(chunk.init(chr(13) & chr(10)))>
				</cfif>

				<!--- Add the Fixed Price Header --->
				<!--- If an operator letter --->
				<cfif thisTag.abbreviation eq "opr">
				<!--- If "Discount Type" template setting for operators on letters is set to "Display" --->
					<cfif attributes.stPDFBodyInfo.bOperatorDiscountType>
						<cfset document.add(phrase.init("Component Type: Fixed Price ", GothicBold_Font_Bold_Brown_Nine))>
					<cfelse>
				<!--- Add a new line --->
						<cfset document.add(chunk.init(chr(13) & chr(10)))>
					</cfif>
				<cfelse>
				<!--- If a distributor letter --->
				<!--- If "Discount Type" template setting for distributors on letters is set to "Display" --->
					<cfif attributes.stPDFBodyInfo.bDistributorDiscountType>
						<cfset document.add(phrase.init("Component Type: Fixed Price ", GothicBold_Font_Bold_Brown_Nine))>
					<cfelse>
				<!--- Add a new line --->
						<cfset document.add(chunk.init(chr(13) & chr(10)))>
					</cfif>
				</cfif>

				<!--- Dev Note: KAL; D15961: Claim Rate on PDF Letters : Moved this code here from below section --->
				<cfsilent>
					<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
					:::::::::::: Identify Header Values [begin] ::::::::::::::::
					::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
					
					<!--- ::::::: 1.) PaymentFrequency ::::::: --->
					<!--- 1A.) IF payment cycle @ component level... --->
					<cfif application.appsettingsget.paymentCycleAtDiscountType>
					
						<cfquery name="thisTag.qGetFixedPricePaymentFrequency" datasource="#application.datasource#">
							SELECT	Payment_Cycle.Payment_Cycle
							FROM	Program_Payment_Cycle,Payment_Cycle
							WHERE	Program_Payment_Cycle.Program_ID = <cfqueryparam value="#thisTag.CMID#" cfsqltype="cf_sql_integer">
							AND		Program_Payment_Cycle.Payment_Cycle_ID = Payment_Cycle.Payment_Cycle_ID	
							AND		Program_Payment_Cycle.Discount_Type_id = 1
							AND		Program_Payment_Cycle.Component_ID = <cfqueryparam value="#thisTag.qProgramFixedPrice.Program_Fixed_Component_Id#" cfsqltype="cf_sql_integer">
						</cfquery>
					
						<cfif thisTag.qGetFixedPricePaymentFrequency.recordCount>  
							<cfset thisTag.program_fixed_price_payment_frequency = thisTag.qGetFixedPricePaymentFrequency.Payment_Cycle[1]>
						<cfelse>
							<cfset thisTag.program_fixed_price_payment_frequency = "">
							<!--- TESTING: FP PmtFrq #Program_Fixed_Component_Id# CmpLvl no records --->
						</cfif>
					
					<!---1B.)  IF payment cycle @ program level... --->
					<cfelse>
						<cfset thisTag.program_fixed_price_payment_frequency = thisTag.stPDFIntroInfo.program_payment_frequency>
					</cfif>
					
					<!--- ::::::: 2 Pricing Type ::::::: --->
					<cfset thisTag.program_fixed_price_pricing_type = thisTag.stPDFIntroInfo.program_pricing_type>
					
					
					<!--- identify the external_id --->
					<!---
					<cfquery name="thisTag.qGetFixedPriceExternalID" datasource="#application.datasource#">
						SELECT	Program_Fixed_Component_Name.External_ID
						FROM	Program_Fixed_Component_Name,Program_Fixed_Component
						WHERE	Program_Fixed_Component.Program_Fixed_Component_Name_ID = Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID
						AND		Program_Fixed_Component.Program_ID = <cfqueryparam value="#thisTag.CMID#" cfsqltype="cf_sql_integer">
						AND		Program_Fixed_Component.Program_Fixed_Component_ID = <cfqueryparam value="#thisTag.qProgramFixedPrice.Program_Fixed_Component_Id#" cfsqltype="cf_sql_integer">
					</cfquery>
					--->
					<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::
					:::::::::::: Identify Header Values [end] ::::::::::::::::::
					::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
				</cfsilent>
				<!--- End Note: KAL; D15961: Claim Rate on PDF Letters : Moved this code here from below section --->
				
				<!--- Dev Note: KAL; D15961: Add new column for claim rates to letters - Checking Conditions if claim rate should be shown --->
				<cfset thisTag.bShowClaimRateFixedPage = 0 />
				<cfif thisTag.abbreviation eq "dis" 

					AND thisTag.qProgramFixedPrice.Include_Claim_Rates_Report 
					AND	thisTag.oAppSettings.getProgramClaimRatesReportAvailable()
				>
					<cfif thisTag.qProgramDistributor.recordCount EQ 1 AND (thisTag.qProgramFixedPrice.Fixed_Component_Type eq 2 OR (NOT thisTag.oAppSettings.getShow_Fixed_Freight())) >
							<cfset thisTag.bShowClaimRateFixedPage = 1 />
					</cfif>

					<!--- we do not show "claim rates" for "letters available - custom 2" app setting OR when "Dont_Show_Claim_Rates_On_Program_Letters" app setting is ON  --->
					<cfif thisTag.oAppSettings.getlettersavailable() eq 2 OR thisTag.oAppSettings.get_Setting('Dont_Show_Claim_Rates_On_Program_Letters') eq '1'>
							<cfset thisTag.bShowClaimRateFixedPage = 0>
					</cfif>
				</cfif>
				<!--- End Note: KAL; D15961: Add new column for claim rates to letters - Checking Conditions if claim rate should be shown --->

	      <!--- /// Fixed Price inside A [begin] (HEADER) --->
				<cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_fixed_price_header.cfm">

	      <!--- content [begin] --->
				<!--- Dev Note: KAL; D15961: Claim Rate on PDF Letters : Moved code from here the beginning of the loop --->
				<cfoutput group="Fixed_Component_Paid_to" groupcasesensitive="no">

				<!--- inc_dis_fixed_price_outside A [begin] --->
				<cfset fixedCount = 1>
				<cfoutput>

				<!--- Dev Note: KAL; D15961: Claim Rates on PDF Letters : While we are inside the loop for distributor/component/product, 
							do query of query to get values from qProgramClaimRatesReport based on distributor/discount type/component/product --->
					<cfset thisTag.ClaimRate = 0/>
					<cfif thisTag.bShowClaimRateFixedPage>									
						<cfquery name="thisTag.qCustomerProductComponentClaimRate"  datasource="#application.datasource#">
							SELECT	expected_fixed_price_claim_rate_per_case, net_weight
							FROM 	##tmp_claim_report_results
							WHERE	BSA_FOODSERVICE_CUSTOMERS_ID = <cfqueryparam value="#thisTag.qProgramDistributor.BSA_FOODSERVICE_CUSTOMERS_ID#" cfsqltype="cf_sql_idstamp">
							AND		BSA_FOODSERVICE_ITEMS_MASTER_ID = <cfqueryparam value="#thisTag.qProgramFixedPrice.BSA_FOODSERVICE_ITEMS_MASTER_ID#" cfsqltype="cf_sql_idstamp">
							AND		Component_Name_ID = <cfqueryparam value="#thisTag.qProgramFixedPrice.Program_Fixed_Component_Name_ID#" cfsqltype="cf_sql_integer">
							AND		Component_Type = 'VARIABLE'
						</cfquery>		
						<cfset thisTag.ClaimRate = thisTag.qCustomerProductComponentClaimRate.expected_fixed_price_claim_rate_per_case />
					</cfif>

		<!--- Add the fixed price data rows --->
		<!--- LINE NUMBER --->
		<cfif thisTag.abbreviation eq "opr">	
			<cfif attributes.stPDFBodyInfo.bOperatorLine neq 0>		
				<cfset LineNumber = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.line_number#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset LineNumber = PdfPCell.init(phrase.init(""))>
			</cfif>
		<cfelse>
			<cfif attributes.stPDFBodyInfo.bDistributorLine neq 0>		
				<cfset LineNumber = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.line_number#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset LineNumber = PdfPCell.init(phrase.init(""))>
			</cfif>
		</cfif>
		
		<cfif (thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorLine neq 0) 
		OR 
		(thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorLine neq 0)>		
			<cfset LineNumber.setColspan( javacast("int", 1) )>
			<cfset LineNumber.setBorder(Rectangle.NO_BORDER)>

			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset LineNumber.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset LineNumber.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfif thisTag.abbreviation eq "opr">	
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(LineNumber)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(LineNumber)>
			</cfif>
		</cfif>

		<!--- ITEM --->
		<cfset Item_Number = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.item#", GothicNormal_font_Bold_Black_Eight))>		
		<cfset Item_Number.setColspan( javacast("int", 1) )>
		<cfset Item_Number.setBorder(Rectangle.NO_BORDER)>

		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
			<cfset Item_Number.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Item_Number.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(Item_Number)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(Item_Number)>
		</cfif>

		<!--- GTIN --->
		<cfif thisTag.abbreviation eq "opr">
			<cfif attributes.stPDFBodyInfo.bOperatorGTIN>
				<cfif thisTag.qProgramFixedPrice.GTIN neq "">
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.GTIN#", GothicNormal_font_Bold_Black_Eight))>
				<cfelse>
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(""))>		
				</cfif>
	
				<cfset Cust_Prod_Number_And_GTIN.setColspan( javacast("int", 1) )>
				<cfset Cust_Prod_Number_And_GTIN.setBorder(Rectangle.NO_BORDER)>
						
				<!--- Alternate coloring --->
				<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
					<cfset Cust_Prod_Number_And_GTIN.setBackgroundColor(textColorWhite)>
				<cfelse>
					<cfset Cust_Prod_Number_And_GTIN.setBackgroundColor(textColorLightGray)>
				</cfif>

				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(Cust_Prod_Number_And_GTIN)>
			</cfif>

		<cfelse>
			<!--- CUSTOMER PRODUCT NUMBER AND GTIN --->
			<cfif thisTag.bAddcustomerproductnumbers AND attributes.stPDFBodyInfo.bDistributorGTIN>
				<cfif isDefined("thisTag.qProgramFixedPrice.customer_product_number") AND thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>
					<cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.customer_product_number#" & chr(13) & chr(10) & "#thisTag.qProgramFixedPrice.GTIN#", GothicNormal_font_Bold_Black_Eight))>
				<cfelse>
					<cfif thisTag.qProgramFixedPrice.GTIN NEQ "">
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(chr(13) & chr(10) & "#thisTag.qProgramFixedPrice.GTIN#", GothicNormal_font_Bold_Black_Eight))>
					<cfelse>
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("", GothicNormal_font_Bold_Black_Eight))>
					</cfif>
				</cfif>

			<cfelseif thisTag.bAddcustomerproductnumbers>			
				<cfif isDefined("thisTag.qProgramFixedPrice.customer_product_number") AND thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.customer_product_number#", GothicNormal_font_Bold_Black_Eight))>
				<cfelse>
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(""))>		
				</cfif>

			<cfelseif attributes.stPDFBodyInfo.bDistributorGTIN>	
				<cfif thisTag.qProgramFixedPrice.GTIN neq "">
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.GTIN#", GothicNormal_font_Bold_Black_Eight))>
				<cfelse>
					  <cfset Cust_Prod_Number_And_GTIN = PdfPCell.init(phrase.init(""))>		
				</cfif>
			</cfif>
		

			<cfif thisTag.bAddcustomerproductnumbers OR attributes.stPDFBodyInfo.bDistributorGTIN>		
				<cfset Cust_Prod_Number_And_GTIN.setColspan( javacast("int", 1) )>
				<cfset Cust_Prod_Number_And_GTIN.setBorder(Rectangle.NO_BORDER)>
						
				<!--- Alternate coloring --->
				<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
					<cfset Cust_Prod_Number_And_GTIN.setBackgroundColor(textColorWhite)>
				<cfelse>
					<cfset Cust_Prod_Number_And_GTIN.setBackgroundColor(textColorLightGray)>
				</cfif>

				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(Cust_Prod_Number_And_GTIN)>
			</cfif>
		</cfif>
		
		<!--- ITEM DESCRIPTION --->
		<cfif thisTag.abbreviation eq "opr">	
			<cfif attributes.stPDFBodyInfo.bOperatorProductAttribute_1 neq 0>		
				<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.description#" & chr(13) & chr(10) & "#thisTag.qProgramFixedPrice.operator_product_attribute_1#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.description#", GothicNormal_font_Bold_Black_Eight))>
			</cfif>
		<cfelse>
			<cfif attributes.stPDFBodyInfo.bDistributorProductAttribute_1 neq 0>		
				<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.description#" & chr(13) & chr(10) & "#thisTag.qProgramFixedPrice.distributor_product_attribute_1#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.description#", GothicNormal_font_Bold_Black_Eight))>
			</cfif>
		</cfif>
		 
		<cfset Item_Description.setColspan( javacast("int", 1) )>
		<cfset Item_Description.setBorder(Rectangle.NO_BORDER)>
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
			<cfset Item_Description.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Item_Description.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(Item_Description)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(Item_Description)>
		</cfif>
						
		<!--- NET WEIGHT --->
		<cfif thisTag.abbreviation eq "opr">	
			<cfif attributes.stPDFBodyInfo.bOperatorProductNetWeight neq 0>		
				<cfset NetWeight = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.Net_Weight#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset NetWeight = PdfPCell.init(phrase.init(""))>
			</cfif>
		<cfelse>
			<cfif attributes.stPDFBodyInfo.bDistributorProductNetWeight neq 0>		
				<cfset NetWeight = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.Net_Weight#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset NetWeight = PdfPCell.init(phrase.init(""))>
			</cfif>
		</cfif>
		
		<cfif (thisTag.abbreviation eq "opr" AND attributes.stPDFBodyInfo.bOperatorProductNetWeight neq 0) 
		OR 
		(thisTag.abbreviation eq "dis" AND attributes.stPDFBodyInfo.bDistributorProductNetWeight neq 0)>		
			<cfset NetWeight.setColspan( javacast("int", 1) )>
			<cfset NetWeight.setBorder(Rectangle.NO_BORDER)>

			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset NetWeight.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset NetWeight.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfif thisTag.abbreviation eq "opr">	
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(NetWeight)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(NetWeight)>
			</cfif>
		</cfif>	
		
		<!--- RATE PER POUND --->
		<!--- If an operator letter --->
		<cfif thisTag.abbreviation eq "opr">
		  <!---If "UOM" template setting for Operators on letters is set to either "LB" or "Both" or "per hundred weight (CWT)" or "Program UOM" --->
		  <cfif attributes.stPDFBodyInfo.bOperatorUOM eq 2 OR attributes.stPDFBodyInfo.bOperatorUOM eq 3 OR attributes.stPDFBodyInfo.bOperatorUOM eq 4 OR attributes.stPDFBodyInfo.bOperatorUOM eq 5>
			 <!---If "UOM" template setting for Operators on letters is set to either "LB" or "Both" --->
			<cfif attributes.stPDFBodyInfo.bOperatorUOM eq 2 OR attributes.stPDFBodyInfo.bOperatorUOM eq 3>
				<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,'_9.9999')#", GothicNormal_font_Bold_Black_Eight))>
			<!--- If "UOM" template setting for Operators on letters is set to "per hundred weight (CWT)" --->
			<cfelseif attributes.stPDFBodyInfo.bOperatorUOM eq 4>
				<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_hundred_weight,'_9.9999')#", GothicNormal_font_Bold_Black_Eight))>
			<!--- If "UOM" template setting for Operators on letters is set to "Program UOM" --->
			<cfelseif attributes.stPDFBodyInfo.bOperatorUOM eq 5>
					<cfif thisTag.qProgramFixedPrice.Unit_Of_Measure_ID eq 1>
					<!--- If the product UOM is "CS", show the rate in 2 decimal places --->
							<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.Fixed_Price_Value,'_99.99')#/#thisTag.qProgramFixedPrice.Unit_Of_Measure_Desc_Singular#", GothicNormal_font_Bold_Black_Eight))>
					<!--- If the product UOM is NOT "CS", show the rate in 4 decimal places --->
					<cfelse>
							<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.Fixed_Price_Value,'_9.9999')#/#thisTag.qProgramFixedPrice.Unit_Of_Measure_Desc_Singular#", GothicNormal_font_Bold_Black_Eight))>
					</cfif>
			</cfif>
			
			<cfset FixedPricePerPound.setColspan( javacast("int", 1) )>
			<cfset FixedPricePerPound.setBorder(Rectangle.NO_BORDER)>

			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset FixedPricePerPound.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset FixedPricePerPound.setBackgroundColor(textColorLightGray)>
			</cfif>
			
			<cfif thisTag.abbreviation eq "opr">	
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(FixedPricePerPound)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(FixedPricePerPound)>
			</cfif>
		  </cfif>

		<!--- If a distributor letter --->
		<cfelse>

		 <!---If "UOM" template setting for distributors on letters is set to either "LB" or "Both" or "per hundred weight (CWT)" or "Program UOM" --->
		  <cfif attributes.stPDFBodyInfo.bDistributorUOM eq 2 OR attributes.stPDFBodyInfo.bDistributorUOM eq 3 OR attributes.stPDFBodyInfo.bDistributorUOM eq 4 OR attributes.stPDFBodyInfo.bDistributorUOM eq 5>
			<!---If "UOM" template setting for distributors on letters is set to either "LB" or "Both" --->
			<cfif attributes.stPDFBodyInfo.bDistributorUOM eq 2 OR attributes.stPDFBodyInfo.bDistributorUOM eq 3>
				<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,'_9.9999')#", GothicNormal_font_Bold_Black_Eight))>
			<!--- If "UOM" template setting for distributors on letters is set to "per hundred weight (CWT)" --->
			<cfelseif attributes.stPDFBodyInfo.bDistributorUOM eq 4>
				<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_hundred_weight,'_9.9999')#", GothicNormal_font_Bold_Black_Eight))>
			<!--- If "UOM" template setting for distributors on letters is set to "Program UOM" --->
			<cfelseif attributes.stPDFBodyInfo.bDistributorUOM eq 5>
					<!--- If the product UOM is "CS", show the rate in 2 decimal places --->
					<cfif thisTag.qProgramFixedPrice.Unit_Of_Measure_ID eq 1>
						<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_value,'_99.99')#/#thisTag.qProgramFixedPrice.Unit_Of_Measure_Desc_Singular#", GothicNormal_font_Bold_Black_Eight))>
					<!--- If the product UOM is NOT "CS", show the rate in 4 decimal places --->
					<cfelse>
						<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_value,'_9.9999')#/#thisTag.qProgramFixedPrice.Unit_Of_Measure_Desc_Singular#", GothicNormal_font_Bold_Black_Eight))>
					</cfif>
			</cfif>

			<cfset FixedPricePerPound.setColspan( javacast("int", 1) )>
			<cfset FixedPricePerPound.setBorder(Rectangle.NO_BORDER)>
		
			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset FixedPricePerPound.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset FixedPricePerPound.setBackgroundColor(textColorLightGray)>
			</cfif>
			
			<cfif thisTag.abbreviation eq "opr">
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(FixedPricePerPound)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(FixedPricePerPound)>
			</cfif>
		  </cfif>
		</cfif>

		<!--- RATE PER CASE --->
		<!--- If an operator letter --->
		<cfif thisTag.abbreviation eq "opr">
		  <!---If "UOM" template setting for Operators on letters is set to either "CS" or "Both", include the "CS" column --->
		  <cfif attributes.stPDFBodyInfo.bOperatorUOM eq 1 OR attributes.stPDFBodyInfo.bOperatorUOM eq 3>
			<cfset FixedPricePerCase = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,'_99.99')#", GothicNormal_font_Bold_Black_Eight))>
			<cfset FixedPricePerCase .setColspan( javacast("int", 1) )>
			<cfset FixedPricePerCase .setBorder(Rectangle.NO_BORDER)>
			
			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset FixedPricePerCase.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset FixedPricePerCase.setBackgroundColor(textColorLightGray)>
			</cfif>
			
			<cfif thisTag.abbreviation eq "opr">	
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(FixedPricePerCase)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(FixedPricePerCase)>
			</cfif>
		  </cfif>

		<!--- If a distributor letter --->
		 <cfelse>

		  <!---If "UOM" template setting for distributor on letters is set to either "CS" or "Both", include the "CS" column --->
		  <cfif attributes.stPDFBodyInfo.bDistributorUOM eq 1 OR attributes.stPDFBodyInfo.bDistributorUOM eq 3>
			<cfset FixedPricePerCase = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,'_99.99')#", GothicNormal_font_Bold_Black_Eight))>
			<cfset FixedPricePerCase .setColspan( javacast("int", 1) )>
			<cfset FixedPricePerCase .setBorder(Rectangle.NO_BORDER)>
			
			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset FixedPricePerCase.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset FixedPricePerCase.setBackgroundColor(textColorLightGray)>
			</cfif>
			
			<cfif thisTag.abbreviation eq "opr">	
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(FixedPricePerCase)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(FixedPricePerCase)>
			</cfif>
		  </cfif>

		</cfif>
		
		<!--- CLAIM RATES --->
		<!--- If bShowClaimRateFixedPage is ON --->
		<cfif thisTag.bShowClaimRateFixedPage>
			<cfset Claim_Number = PdfPCell.init(phrase.init("$#numberFormat(thisTag.ClaimRate,'_99.99')#", GothicNormal_font_Bold_Black_Eight))>
			<cfset Claim_Number.setColspan( javacast("int", 1) )>
			<cfset Claim_Number.setBorder(Rectangle.NO_BORDER)>
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
			<cfset Claim_Number.setBackgroundColor(textColorWhite)>
		<cfelse>
			<cfset Claim_Number.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(Claim_Number)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(Claim_Number)>
		</cfif>
		</cfif>      

			<cfset fixedCount = fixedCount + 1>
		</cfoutput>

	<cfif thisTag.abbreviation eq "opr">
			<cfset document.add(table_opr_FixedPrice)>
	<cfelse>
			<cfset document.add(table_dis_FixedPrice)>
	</cfif>

<!--- component table [begin] --->

<!--- Set the length of the array as big as the number of columns in the table --->
<cfset table_fixedprice_component = PdfPTable.init( javacast("int",2) )>
<cfset table_fixedprice_component.setWidthPercentage(100)>

<!--- Count the number of component related info to show for fixed price. Currently, we can have at most 5.
(ComponentName,ClaimMechanism,PayableTo,PricingType,PaymentFrequency)
--->
<!--- The reason why we need to count the number of component related info is this:
- In Itext, we do not add rows to a table specifically. Instead, we specify x number of columns in a table and
when we keep on adding columns to a table, the table knows when to add a new row. For eg: if we have a table with
2 columns. When we the "addCell" method to add a third piece of info, it automatically becomes a new row.
- Using the above example, When we do not provide Itext with the second piece of info when a table has two columns,
then the table will not show on the pdf document, unless the first piece of info has colspan = 2.
--->
<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">

<!--- Check operator settings --->
<cfset TotalComponentRelatedInfoCount_FixedPrice = attributes.stPDFBodyInfo.bOperatorComponentName +  attributes.stPDFBodyInfo.bOperatorClaimMechanism 
+ attributes.stPDFBodyInfo.bOperatorPayableTo  + attributes.stPDFBodyInfo.bOperatorPricingType + attributes.stPDFBodyInfo.bOperatorPaymentFrequency>

	<cfif  attributes.stPDFBodyInfo.bOperatorPaymentFrequency>
	  <cfset LastComponentRelatedInfo = "PaymentFrequency">

	<cfelseif attributes.stPDFBodyInfo.bOperatorPricingType>
	  <cfset LastComponentRelatedInfo = "PricingType">

	<cfelseif attributes.stPDFBodyInfo.bOperatorPayableTo>
	  <cfset LastComponentRelatedInfo = "PayableTo">

	<cfelseif attributes.stPDFBodyInfo.bOperatorClaimMechanism>
	  <cfset LastComponentRelatedInfo = "ClaimMechanism">

	<cfelseif attributes.stPDFBodyInfo.bDistributorComponentName>
	  <cfset LastComponentRelatedInfo = "ComponentName">
	</cfif>

<!--- If a distributor letter --->
<cfelse>

<!--- Check distributor settings --->
<cfset TotalComponentRelatedInfoCount_FixedPrice = attributes.stPDFBodyInfo.bDistributorComponentName +  attributes.stPDFBodyInfo.bDistributorClaimMechanism 
+ attributes.stPDFBodyInfo.bDistributorPayableTo  + attributes.stPDFBodyInfo.bDistributorPricingType + attributes.stPDFBodyInfo.bDistributorPaymentFrequency>

	<cfif  attributes.stPDFBodyInfo.bDistributorPaymentFrequency>
	  <cfset LastComponentRelatedInfo = "PaymentFrequency">

	<cfelseif attributes.stPDFBodyInfo.bDistributorPricingType>
	  <cfset LastComponentRelatedInfo = "PricingType">

	<cfelseif attributes.stPDFBodyInfo.bDistributorPayableTo>
	  <cfset LastComponentRelatedInfo = "PayableTo">

	<cfelseif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
	  <cfset LastComponentRelatedInfo = "ClaimMechanism">

	<cfelseif attributes.stPDFBodyInfo.bDistributorComponentName>
	  <cfset LastComponentRelatedInfo = "ComponentName">
	</cfif>

</cfif>



<!--- If we have at least one component related info to show - either component name/claim mechanism etc --->
<cfif TotalComponentRelatedInfoCount_FixedPrice gt 0>
<!--- Set the length of the array as big as the number of columns in the table --->


<cfset jArr = arrObj.newInstance(jClass, 2)>  

<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
will be used as the width of the columns in the table_fixedprice_component table.
--->
<cfset arrObj.setInt(jArr, 0, 50)>  
<cfset arrObj.setInt(jArr, 1, 50)> 


<cfset table_fixedprice_component.setWidths(jArr)>


<!--- Add the headers for the table columns --->

<!--- Add "Component Name" Info --->

<cfset col_span = 1>

<!--- If there are odd number of component related info to show AND "ComponentName" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
<cfif TotalComponentRelatedInfoCount_FixedPrice MOD 2 eq 1 AND LastComponentRelatedInfo eq "ComponentName">
 <cfset col_span = 2>
</cfif>

<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Component Name" template setting for operators on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bOperatorComponentName>
		<cfset Component_Name_Details = PdfPCell.init(phrase.init("Component Name: " & thisTag.qProgramFixedPrice.Program_Summary_Display_Name, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Component_Name_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Component_Name_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Component_Name_Details)>
	</cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If "Component Name" template setting for distributors on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorComponentName>
		<cfset Component_Name_Details = PdfPCell.init(phrase.init("Component Name: " & thisTag.qProgramFixedPrice.Program_Summary_Display_Name, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Component_Name_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Component_Name_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Component_Name_Details)>
	</cfif>
</cfif>

<!--- Add Claim Mechanism Info --->

<cfset col_span = 1>

<!--- If there are odd number of component related info to show AND "ClaimMechanism" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
<cfif TotalComponentRelatedInfoCount_FixedPrice MOD 2 eq 1 AND LastComponentRelatedInfo eq "ClaimMechanism">
 <cfset col_span = 2>
</cfif>

<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Claim Mechanism" template setting for operators on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bOperatorClaimMechanism>
		<cfset Claim_Mechanism_Details = PdfPCell.init(phrase.init("Claim Mechanism: " & thisTag.qProgramFixedPrice.claim_mechanics, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Claim_Mechanism_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Claim_Mechanism_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Claim_Mechanism_Details)>
	</cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If "Claim Mechanism" template setting for distributors on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
		<cfset Claim_Mechanism_Details = PdfPCell.init(phrase.init("Claim Mechanism: " & thisTag.qProgramFixedPrice.claim_mechanics, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Claim_Mechanism_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Claim_Mechanism_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Claim_Mechanism_Details)>
	</cfif>
</cfif>


<!--- Add Payable to Info --->

<cfset col_span = 1>

<!--- If there are odd number of component related info to show AND "PayableTo" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
<cfif TotalComponentRelatedInfoCount_FixedPrice MOD 2 eq 1 AND LastComponentRelatedInfo eq "PayableTo">
 <cfset col_span = 2>
</cfif>

<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Payable to" template setting for operators on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bOperatorPayableTo>
		<cfif Fixed_Component_Paid_to EQ 1>
			<cfset Payable_To_Details = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.distributor_label_singular, GothicBold_Font_Bold_Brown_Eight))>
		<cfelse>
			<cfset Payable_To_Details = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.operator_label_singular, GothicBold_Font_Bold_Brown_Eight))>
		</cfif>
			<cfset Payable_To_Details.setColspan( javacast("int", #col_span#) )>
			<cfset Payable_To_Details.setBorder(Rectangle.NO_BORDER)> 
			<cfset table_fixedprice_component.addCell(Payable_To_Details)>
	</cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If "Payable to" template setting for distributors on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorPayableTo>
		<cfif Fixed_Component_Paid_to EQ 1>
			<cfset Payable_To_Details = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.distributor_label_singular, GothicBold_Font_Bold_Brown_Eight))>
		<cfelse>
			<cfset Payable_To_Details = PdfPCell.init(phrase.init("Payable to: " & application.returned_customer_setting.operator_label_singular, GothicBold_Font_Bold_Brown_Eight))>
		</cfif>
			<cfset Payable_To_Details.setColspan( javacast("int", #col_span#) )>
			<cfset Payable_To_Details.setBorder(Rectangle.NO_BORDER)> 
			<cfset table_fixedprice_component.addCell(Payable_To_Details)>

	</cfif>
</cfif>


<!--- Add Pricing Type Info --->

<cfset col_span = 1>

<!--- If there are odd number of component related info to show AND "PricingType" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
<cfif TotalComponentRelatedInfoCount_FixedPrice MOD 2 eq 1 AND LastComponentRelatedInfo eq "PricingType">
 <cfset col_span = 2>
</cfif>

<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Pricing Type" template setting for operators on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bOperatorPricingType>
		<cfset Pricing_Type_Details = PdfPCell.init(phrase.init("Pricing Type: " & thisTag.program_fixed_price_pricing_type, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Pricing_Type_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Pricing_Type_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Pricing_Type_Details)>
	</cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If "Pricing Type" template setting for distributors on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorPricingType>
		<cfset Pricing_Type_Details = PdfPCell.init(phrase.init("Pricing Type: " & thisTag.program_fixed_price_pricing_type, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Pricing_Type_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Pricing_Type_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Pricing_Type_Details)>
	</cfif>
</cfif>

<!--- Add Payment Frequency Info --->

<cfset col_span = 1>

<!--- If there are odd number of component related info to show AND "PaymentFrequency" is the last one OR only one, make sure this column's colspan is 2 and not 1 --->
<cfif TotalComponentRelatedInfoCount_FixedPrice MOD 2 eq 1 AND LastComponentRelatedInfo eq "PaymentFrequency">
 <cfset col_span = 2>
</cfif>

<!--- If an operator letter --->
<cfif thisTag.abbreviation eq "opr">
<!--- If "Payment Frequency" template setting for operators on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bOperatorPaymentFrequency>
		<cfset Payment_Frequency_Details = PdfPCell.init(phrase.init("Payment Frequency: " & thisTag.program_fixed_price_payment_frequency, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Payment_Frequency_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Payment_Frequency_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Payment_Frequency_Details)>
	</cfif>
<cfelse>
<!--- If a distributor letter --->
<!--- If "Payment Frequency" template setting for distributors on letters is set to "Display" --->
	<cfif attributes.stPDFBodyInfo.bDistributorPaymentFrequency>
		<cfset Payment_Frequency_Details = PdfPCell.init(phrase.init("Payment Frequency: " & thisTag.program_fixed_price_payment_frequency, GothicBold_Font_Bold_Brown_Eight))>
		<cfset Payment_Frequency_Details.setColspan( javacast("int", #col_span#) )>
		<cfset Payment_Frequency_Details.setBorder(Rectangle.NO_BORDER)> 
		<cfset table_fixedprice_component.addCell(Payment_Frequency_Details)>	
	</cfif>
</cfif>


<!--- Add the table to the pdf document --->
<cfset document.add(table_fixedprice_component)>

</cfif>
 <!--- component table [end] --->

</cfoutput>				

<!--- /// Fixed Price inside A [end] --->          
</cfoutput>


<cfelse>

<!--- /// Fixed Price inside B (HEADER) --->
<cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_fixed_price_header.cfm">

		<!--- /// Fixed Price inside B [begin] --->
    <!--- 1.) fixed [begin] --->
		<cfset fixedCount = 1>
		<cfloop query="thisTag.qProgramFixedPrice">
		<cfif thisTag.bAddcustomerproductnumbers>
			<cfif isDefined("thisTag.qProgramFixedPrice.customer_product_number") AND thisTag.qProgramFixedPrice.customer_product_number NEQ "na" AND len(trim(thisTag.qProgramFixedPrice.customer_product_number))>
				<cfset Cust_Prod_Number = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.customer_product_number#", GothicNormal_font_Bold_Black_Eight))>
			<cfelse>
				<cfset Cust_Prod_Number = PdfPCell.init(phrase.init(""))>		
			</cfif>
				
			<!--- Alternate coloring --->
			<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset Cust_Prod_Number.setBackgroundColor(textColorWhite)>
			<cfelse>
				<cfset Cust_Prod_Number.setBackgroundColor(textColorLightGray)>
			</cfif>

			<cfset Cust_Prod_Number.setColspan( javacast("int", 1) )>
			<cfset Cust_Prod_Number.setBorder(Rectangle.NO_BORDER)>

			<cfif thisTag.abbreviation eq "opr">	
				<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_opr_FixedPrice.addCell(Cust_Prod_Number)>
			<cfelse>
				<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
				<cfset table_dis_FixedPrice.addCell(Cust_Prod_Number)>
			</cfif>
		</cfif>	

		<cfset Item_Number = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.item#", GothicNormal_font_Bold_Black_Eight))>
		<cfset Item_Number.setColspan( javacast("int", 1) )>
		<cfset Item_Number.setBorder(Rectangle.NO_BORDER)>
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset Item_Number.setBackgroundColor(textColorWhite)>
		<cfelse>
				<cfset Item_Number.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(Item_Number)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(Item_Number)>
		</cfif>

		<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.qProgramFixedPrice.description#", GothicNormal_font_Bold_Black_Eight))>
		<cfset Item_Description.setColspan( javacast("int", 1) )>
		<cfset Item_Description.setBorder(Rectangle.NO_BORDER)>

		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset Item_Description.setBackgroundColor(textColorWhite)>
		<cfelse>
				<cfset Item_Description.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(Item_Description)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(Item_Description)>
		</cfif>


		<cfset FixedPricePerPound = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_pound,'_9.9999')#", GothicNormal_font_Bold_Black_Eight))>
		<cfset FixedPricePerPound.setColspan( javacast("int", 1) )>
		<cfset FixedPricePerPound.setBorder(Rectangle.NO_BORDER)>

		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset FixedPricePerPound.setBackgroundColor(textColorWhite)>
		<cfelse>
				<cfset FixedPricePerPound.setBackgroundColor(textColorLightGray)>
		</cfif>

		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(FixedPricePerPound)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(FixedPricePerPound)>
		</cfif>

		<cfset FixedPricePerCase = PdfPCell.init(phrase.init("$#numberFormat(thisTag.qProgramFixedPrice.fixed_price_per_case,'_99.99')#", GothicNormal_font_Bold_Black_Eight))>
		<cfset FixedPricePerCase.setColspan( javacast("int", 1) )>
		<cfset FixedPricePerCase.setBorder(Rectangle.NO_BORDER)>
		
		<!--- Alternate coloring --->
		<cfif thisTag.qProgramFixedPrice.currentRow MOD 2 eq 1>
				<cfset FixedPricePerCase.setBackgroundColor(textColorWhite)>
		<cfelse>
				<cfset FixedPricePerCase.setBackgroundColor(textColorLightGray)>
		</cfif>
		
		<cfif thisTag.abbreviation eq "opr">	
			<cfset table_opr_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_opr_FixedPrice.addCell(FixedPricePerCase)>
		<cfelse>
			<cfset table_dis_FixedPrice.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
			<cfset table_dis_FixedPrice.addCell(FixedPricePerCase)>
		</cfif>

			<!--- Add the table to the pdf document. --->
			<cfif thisTag.abbreviation eq "opr">
					<cfset document.add(table_opr_FixedPrice)>
			<cfelse>
					<cfset document.add(table_dis_FixedPrice)>
			</cfif>

	<cfset fixedCount = fixedCount + 1>
</cfloop>
<!--- 1.) fixed [end] --->

<!--- /// Fixed Price inside B [end] ---> 
</cfif>
				
<!--- This lets Java know that the table is now complete. --->
<cfif thisTag.abbreviation eq "opr">	
	<cfset table_opr_FixedPrice.setComplete(1)>	
<cfelse>
	<cfset table_dis_FixedPrice.setComplete(1)>	
</cfif>

</cfif>
<!--- Fixed Price [end] --->

<!--- 4.) IF we want rebate... --->
  <cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayRebate'&thisTag.abbreviation)>
	<!--- /// Rebate [begin] --->


		<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for rebate --->
		<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>				
			<cfset document.newPage()>	
		<cfelse>
			<cfset document.add(chunk.init(chr(13) & chr(10)))>
		</cfif>

		<!--- Add the Rebate Header --->
				<!--- If an operator letter --->
				<cfif thisTag.abbreviation eq "opr">
				<!--- If "Discount Type" template setting for operators on letters is set to "Display" --->
					<cfif attributes.stPDFBodyInfo.bOperatorDiscountType>
						<cfset document.add(phrase.init("Component Type: #Application.RebateLabel# " & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Nine))>
					<cfelse>
				<!--- Add a new line --->
						<cfset document.add(chunk.init(chr(13) & chr(10)))>
					</cfif>
				<cfelse>
				<!--- If a distributor letter --->
				<!--- If "Discount Type" template setting for distributors on letters is set to "Display" --->
					<cfif attributes.stPDFBodyInfo.bDistributorDiscountType>
						<cfset document.add(phrase.init("Component Type: #Application.RebateLabel# " & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Nine))>
					<cfelse>
				<!--- Add a new line --->
						<cfset document.add(chunk.init(chr(13) & chr(10)))>
					</cfif>
				</cfif>
		
    
		<!--- header [begin] --->	
		<cfinclude template="doc_modules/headers/inc_#thisTag.abbreviation#_rebate_header.cfm">
		<!--- header [end] --->	

		 <!--- header [begin] --->	
		<cfinclude template="doc_modules/inc_#thisTag.abbreviation#_rebate.cfm">
		 <!--- header [end] --->

		<!--- setComplete(1) lets Java know that the table is now complete. --->
			<cfif thisTag.abbreviation eq "opr">
					<cfset document.add(table_opr_Rebate)>
					<cfset table_opr_Rebate.setComplete(1)>	
			<cfelse>
					<cfset document.add(table_dis_Rebate)>
					<cfset table_dis_Rebate.setComplete(1)>	
			</cfif>
    </cfif>
   <!--- Rebate [end] --->

   <!--- 5.) IF we want lump_sum... --->
	 <!--- /// Lump Sum [begin] --->
    <cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayLumpSum'&thisTag.abbreviation)>
		
		<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for Lump sum --->
		<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>
			<cfset document.newPage()>	
		<cfelse>
			<cfset document.add(chunk.init(chr(13) & chr(10)))>
		</cfif>

		<!--- Add the Lumpsum Header --->

		<!--- If an operator letter --->
		<cfif thisTag.abbreviation eq "opr">
		<!--- If "Discount Type" template setting for operators on letters is set to "Display" --->
			<cfif attributes.stPDFBodyInfo.bOperatorDiscountType>
				<cfset document.add(phrase.init("Component Type: #Application.LumpSumLabel# " & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Nine))>
			<cfelse>
		<!--- Add a new line --->
				<cfset document.add(chunk.init(chr(13) & chr(10)))>
			</cfif>
		<cfelse>
		<!--- If a distributor letter --->
		<!--- If "Discount Type" template setting for distributors on letters is set to "Display" --->
			<cfif attributes.stPDFBodyInfo.bDistributorDiscountType>
				<cfset document.add(phrase.init("Component Type: #Application.LumpSumLabel# " & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Nine))>
			<cfelse>
		<!--- Add a new line --->
				<cfset document.add(chunk.init(chr(13) & chr(10)))>
			</cfif>
		</cfif>

		<!--- header [begin] --->
		<cfinclude template="doc_modules/inc_all_lumpsum_combined_header.cfm">
		<!--- header [end] --->

		<!--- Count the number of component related info ON on the template setting [begin]. 
		Currently, we can have at most 4.(ComponentName,ClaimMechanism,PayableTo,PaymentFrequency)
		--->
		<!--- The reason why we need to count the number of component related info is this:
		- In Itext, we do not add rows to a table specifically. Instead, we specify x number of columns in a table and
		when we keep on adding columns to a table, the table knows when to add a new row. For eg: if we have a table with
		2 columns. When we the "addCell" method to add a third piece of info, it automatically becomes a new row.
		- Using the above example, When we do not provide Itext with the second piece of info when a table has two columns,
		then the table will not show on the pdf document, unless the first piece of info has colspan = 2.
		--->
		<!--- If an operator letter --->
		<cfif thisTag.abbreviation eq "opr">
		
		<!--- Check operator settings --->
		<cfset TotalComponentRelatedInfoCount_Lumpsum = attributes.stPDFBodyInfo.bOperatorComponentName +  attributes.stPDFBodyInfo.bOperatorClaimMechanism 
		+ attributes.stPDFBodyInfo.bOperatorPayableTo  + attributes.stPDFBodyInfo.bOperatorPaymentFrequency>

			<cfif  attributes.stPDFBodyInfo.bOperatorPaymentFrequency>
			  <cfset LastComponentRelatedInfo = "PaymentFrequency">

			<cfelseif attributes.stPDFBodyInfo.bOperatorPayableTo>
			  <cfset LastComponentRelatedInfo = "PayableTo">

			<cfelseif attributes.stPDFBodyInfo.bOperatorClaimMechanism>
			  <cfset LastComponentRelatedInfo = "ClaimMechanism">

			<cfelseif attributes.stPDFBodyInfo.bOperatorComponentName>
			  <cfset LastComponentRelatedInfo = "ComponentName">
			</cfif>

		<!--- If a distributor letter --->
		<cfelse>

		<!--- Check distributor settings --->
		<cfset TotalComponentRelatedInfoCount_Lumpsum = attributes.stPDFBodyInfo.bDistributorComponentName +  attributes.stPDFBodyInfo.bDistributorClaimMechanism 
		+ attributes.stPDFBodyInfo.bDistributorPayableTo  + attributes.stPDFBodyInfo.bDistributorPaymentFrequency>

			<cfif  attributes.stPDFBodyInfo.bDistributorPaymentFrequency>
			  <cfset LastComponentRelatedInfo = "PaymentFrequency">

			<cfelseif attributes.stPDFBodyInfo.bDistributorPayableTo>
			  <cfset LastComponentRelatedInfo = "PayableTo">

			<cfelseif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
			  <cfset LastComponentRelatedInfo = "ClaimMechanism">

			<cfelseif attributes.stPDFBodyInfo.bDistributorComponentName>
			  <cfset LastComponentRelatedInfo = "ComponentName">
			</cfif>

		</cfif>
		<!--- Count the number of component related info ON in the template setting [end] --->


		  <!--- content [begin] --->
		  <cfinclude template="doc_modules/inc_#thisTag.abbreviation#_lump_sum.cfm">
		  <!--- content [end] --->		

    		  <!--- setComplete(1) lets Java know that the table is now complete. --->
		  <cfif thisTag.abbreviation eq "opr">
			<cfset table_opr_lumpsum.setComplete(1)>
			<cfset table_opr_lumpsum_component.setComplete(1)>	
		  <cfelse>
			<cfset table_dis_lumpsum.setComplete(1)>
			<cfset table_dis_lumpsum_component.setComplete(1)>
		  </cfif>

    </cfif>
<!--- Lump Sum [end] --->

<!---
*************************NOTE: DO NOT REMOVE THE GROWTH CODE BELOW*************************

Dev Note(48719) - The basic display of growth on letters is below.
In the future, this code can be uncommented and used for standard letters (When "appSettings.getlettersavailable" = 1).
Note: Growth on the program summary page has different displays based on app setting.
All those displays have not been accounted for. Even the editing of letters does not account for GROWTH.
--->
<!---
   <!--- 6.) IF we want Growth... --->
	 <!--- /// Growth [begin] --->
    <cfif thisTag.stPDFBodyInfo.bDisplayGrowth AND thisTag.qProgramGrowth.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayGrowth'&thisTag.abbreviation)>
		
		<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for Growth --->
		<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>				
			<cfset document.newPage()>
		<cfelse>
			<cfset document.add(chunk.init(chr(13) & chr(10)))>
		</cfif>

		<!--- Add the Growth Header --->

		<!--- If an operator letter --->
		<cfif thisTag.abbreviation eq "opr">
		<!--- If "Discount Type" template setting for operators on letters is set to "Display" --->
			<cfif attributes.stPDFBodyInfo.bOperatorDiscountType>
				<cfset document.add(phrase.init("Component Type: #Application.GrowthLabel# " & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Nine))>
			<cfelse>
		<!--- Add a new line --->
				<cfset document.add(chunk.init(chr(13) & chr(10)))>
			</cfif>
		<cfelse>
		<!--- If a distributor letter --->
		<!--- If "Discount Type" template setting for distributors on letters is set to "Display" --->
			<cfif attributes.stPDFBodyInfo.bDistributorDiscountType>
				<cfset document.add(phrase.init("Component Type: #Application.GrowthLabel# " & chr(13) & chr(10), GothicBold_Font_Bold_Brown_Nine))>
			<cfelse>
		<!--- Add a new line --->
				<cfset document.add(chunk.init(chr(13) & chr(10)))>
			</cfif>
		</cfif>

		<!--- header [begin ]--->
		<cfinclude template="doc_modules/inc_all_growth_combined_header.cfm"> 
		<!--- header [end] --->

		<!--- Count the number of component related info ON on the template setting [begin]. 
		Currently, we can have at most 4.(ComponentName,ClaimMechanism,PayableTo,PaymentFrequency)
		--->
		<!--- The reason why we need to count the number of component related info is this:
		- In Itext, we do not add rows to a table specifically. Instead, we specify x number of columns in a table and
		when we keep on adding columns to a table, the table knows when to add a new row. For eg: if we have a table with
		2 columns. When we the "addCell" method to add a third piece of info, it automatically becomes a new row.
		- Using the above example, When we do not provide Itext with the second piece of info when a table has two columns,
		then the table will not show on the pdf document, unless the first piece of info has colspan = 2.
		--->
		<!--- If an operator letter --->
		<cfif thisTag.abbreviation eq "opr">
		
		<!--- Check operator settings --->
		<cfset TotalComponentRelatedInfoCount_Growth = 1 + <!--- -1 is for Volume Range --->  attributes.stPDFBodyInfo.bOperatorComponentName +  attributes.stPDFBodyInfo.bOperatorClaimMechanism 
		+ attributes.stPDFBodyInfo.bOperatorPayableTo  + attributes.stPDFBodyInfo.bOperatorPaymentFrequency>
		
			<cfif  attributes.stPDFBodyInfo.bOperatorPaymentFrequency>
			  <cfset LastComponentRelatedInfo = "PaymentFrequency">

			<cfelseif attributes.stPDFBodyInfo.bOperatorPayableTo>
			  <cfset LastComponentRelatedInfo = "PayableTo">

			<cfelseif attributes.stPDFBodyInfo.bOperatorClaimMechanism>
			  <cfset LastComponentRelatedInfo = "ClaimMechanism">

			<cfelseif attributes.stPDFBodyInfo.bOperatorComponentName>
			  <cfset LastComponentRelatedInfo = "ComponentName">
			</cfif>
			

		<!--- If a distributor letter --->
		<cfelse>

		<!--- Check distributor settings --->
		<cfset TotalComponentRelatedInfoCount_Growth = 1 + <!--- -1 is for Volume Range ---> attributes.stPDFBodyInfo.bDistributorComponentName +  attributes.stPDFBodyInfo.bDistributorClaimMechanism 
		+ attributes.stPDFBodyInfo.bDistributorPayableTo  + attributes.stPDFBodyInfo.bDistributorPaymentFrequency>

			<cfif  attributes.stPDFBodyInfo.bDistributorPaymentFrequency>
			  <cfset LastComponentRelatedInfo = "PaymentFrequency">

			<cfelseif attributes.stPDFBodyInfo.bDistributorPayableTo>
			  <cfset LastComponentRelatedInfo = "PayableTo">

			<cfelseif attributes.stPDFBodyInfo.bDistributorClaimMechanism>
			  <cfset LastComponentRelatedInfo = "ClaimMechanism">

			<cfelseif attributes.stPDFBodyInfo.bDistributorComponentName>
			  <cfset LastComponentRelatedInfo = "ComponentName">
			</cfif>

		</cfif>
		<!--- Count the number of component related info ON in the template setting [end] --->

		   <!--- As of now, (3/12/2015)- 48719, operator letters are not being used and that is why
		  the line  <cfset thisTag.abbreviation = "dis"> below ensures that only the
		  "inc_dis_growth.cfm" gets called. In fact as of now (3/12/2015) "inc_opr_growth.cfm" does not
		  even exist as it seems like "operator growth" is not used.
		  To create operator letters, "inc_opr_growth.cfm" needs to be created based on a mix of
		  "inc_opr_lump_sum.cfm" and "inc_dis_growth.cfm".
		  The code will be copied from "inc_opr_lump_sum.cfm" and then some changes for volume and tier
		  will be modified by copying the code from "inc_dis_growth.cfm".
		  Note:Remove "<cfset thisTag.abbreviation = "dis">" below to generate operator letters, once
		 "inc_opr_growth.cfm" is ready.
		   --->
		   <!--- content [begin] --->
		  <cfset thisTag.abbreviation = "dis">
		  <cfinclude template="doc_modules/inc_#thisTag.abbreviation#_growth.cfm">
		  <!--- content [end] --->		

    		  <!--- setComplete(1) lets Java know that the table is now complete. --->
		  <cfif thisTag.abbreviation eq "opr">
			<cfset table_opr_growth.setComplete(1)>
			<cfset table_opr_growth_component.setComplete(1)>	
		  <cfelse>
			<cfset table_dis_growth.setComplete(1)>
			<cfset table_dis_growth_component.setComplete(1)>
		  </cfif>

    </cfif>
<!--- Growth [end] --->
--->

    <!--- 6A.) IF we want to include the volume page --->
    <cfif thisTag.bIncludeVolumePage AND len(trim(thisTag.lsProgramAllDiscountItemGUIDs))> 
		<cfif thisTag.abbreviation eq "opr">
			<cfset bShowVolumeSummary = thisTag.stPDFBodyInfo.bOperatorShowVolumeSummary>
		<cfelse>
			<cfset bShowVolumeSummary = thisTag.stPDFBodyInfo.bDistributorShowVolumeSummary>
		</cfif>
	
			<!--- Volume Page [start] --->	
	 		<cfinclude template="doc_modules/inc_all_volume.cfm">
			<!--- Volume Page [end] --->	
		</cfif>

	<!--- 6B.) IF we want to include the Freight Summary [begin] --->
    <!--- NOTE: i.) The parent template allows freight, ii.) this letter wants freight iii.) we have distributor(s) associated with this letter's program iv.) we have fixed price items because this letter's program has a fixed price component with a freight information... --->
    <cfif thisTag.stPDFBodyInfo.bTemplateAllowFreightLetters AND thisTag.bLetterDisplayFreight>

    <!--- D16905 AND thisTag.qProgramFixedPrice.recordCount --->
		<!--- Dev Note; Kal; Edit a distributor letter generated for multiple distributor. Remove all the distributors and you will still get the error : Element STPLDIF.APROGRAMDISTRIBUTOR is undefined in THISTAG --->    
    	<cfif thisTag.qProgramDistributor.recordCount AND thisTag.stPLDIF.qFOBFixedComp.recordCount>
    <!--- Freight Page [begin] --->
				

		<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for fixed price --->
		<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>				
			<cfset document.newPage()>	
		<cfelse>
			<cfset document.add(chunk.init(chr(13) & chr(10)))>
		</cfif>

		<!--- content [begin] --->
		<cfloop from="1" to="#arrayLen(thisTag.stPLDIF.aProgramDistributor)#" index="thisTag.currentDistributor">
		<!--- Dev Note: Milan (26289) - For operator letters, If "one distributor per letter" option is selected", then only print freight for that distributor, else for all distributors.
		      thisTag.qProgramDistributor.recordCount GT 1 means "multiple distributors" option is selected.
		--->
		<cfif thisTag.qProgramDistributor.recordCount GT 1 OR (thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].BSA_FOODSERVICE_CUSTOMERS_ID eq thisTag.qProgramDistributor.BSA_Foodservice_Customers_ID)>
		
				<!--- Go to a new line, if not the first distributor --->
				<cfif thisTag.currentDistributor neq 1>
					<cfset document.add(chunk.init(chr(13) & chr(10)))>
				</cfif>

				<!--- Initialize the table --->
				<cfset table_freight_header = PdfPTable.init( javacast("int",3) )>
				<cfset table_freight_header.setWidthPercentage(100)>

				<!--- Set the length of the array as big as the number of columns in the table --->
				<cfset jArr = arrObj.newInstance(jClass, 3)>  

				<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
				will be used as the width of the columns in the table_freight_header table.
				--->
				<cfset arrObj.setInt(jArr, 0, 40)>  
				<cfset arrObj.setInt(jArr, 1, 25)> 
				<cfset arrObj.setInt(jArr, 2, 35)>

				<cfset table_freight_header.setWidths(jArr)>

				<!--- Freight Header 1 --->
				<cfset Freight_Header = PdfPCell.init(phrase.init("Freight:", GothicBold_Font_Bold_Brown_Eight))>
				<cfset Freight_Header.setColspan( javacast("int", 1) )>
				<cfset Freight_Header.setBorder(Rectangle.NO_BORDER)> 
				<cfset table_freight_header.addCell(Freight_Header)>

				<cfset UOM_Header = PdfPCell.init(phrase.init("UOM: " & thisTag.customerFreightUom, GothicBold_Font_Bold_Brown_Eight))>
				<cfset UOM_Header.setColspan( javacast("int", 1) )>
				<cfset UOM_Header.setBorder(Rectangle.NO_BORDER)> 
				<cfset table_freight_header.addCell(UOM_Header)>

				<cfset Warehouse_Header = PdfPCell.init(phrase.init("Warehouse: " & thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.Warehouse_Name, GothicBold_Font_Bold_Brown_Eight))>
				<cfset Warehouse_Header.setColspan( javacast("int", 1) )>
				<cfset Warehouse_Header.setBorder(Rectangle.NO_BORDER)> 
				<cfset table_freight_header.addCell(Warehouse_Header)>

				<cfset Distributor_Header = PdfPCell.init(phrase.init("Distributor: " & thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.Name & "(" & thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.Shr_Ship_to  & ")", GothicBold_Font_Bold_Brown_Eight))>
				<cfset Distributor_Header.setColspan( javacast("int", 1) )>
				<cfset Distributor_Header.setBorder(Rectangle.NO_BORDER)> 
				<cfset table_freight_header.addCell(Distributor_Header)>

				<cfset Eligible_Dates_Header = PdfPCell.init(phrase.init("Eligible Dates: " & DateFormat(thisTag.stPLDIF.stFOBProgramInfo.Contract_Start_Date,"MM/DD/YYYY") & "-" & DateFormat(thisTag.stPLDIF.stFOBProgramInfo.Contract_End_Date,"MM/DD/YYYY"), GothicBold_Font_Bold_Brown_Eight))>
				<cfset Eligible_Dates_Header.setColspan( javacast("int", 1) )>
				<cfset Eligible_Dates_Header.setBorder(Rectangle.NO_BORDER)> 
				<cfset table_freight_header.addCell(Eligible_Dates_Header)>

				<cfset Eligible_Dates_Header = PdfPCell.init(phrase.init("Bracket: " & thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.Freight_Bracket_Label, GothicBold_Font_Bold_Brown_Eight))>
				<cfset Eligible_Dates_Header.setColspan( javacast("int", 1) )>
				<cfset Eligible_Dates_Header.setBorder(Rectangle.NO_BORDER)> 
				<cfset table_freight_header.addCell(Eligible_Dates_Header)>
				
				<!--- Add the table to the pdf document --->
				<cfset document.add(table_freight_header)>


			<!--- Dev Note: Milan (24557). In label 15961, we used to get data from the ##tmp_claim_report_results inside the second loop ("thisTag.stPLDIF.qFOBFixedComp") and so each
			      query used to run for every distributor/item/component combination. Now there is a change where we get data from the ##tmp_claim_report_results at the distributor
			      level only (inside the first loop above) and then use the query array syntax 
			      [eq: thisTag.qCustomerProductComponentClaimRate['expected_fixed_price_claim_rate_per_case'][thisTag.stPLDIF.qFOBFixedComp.currentrow]] 
			      to extract the correct data inside the second loop. This technique works because the data for query "thisTag.stPLDIF.qFOBFixedComp" which comes from function
			      "getProgramLetterFreightFixedComponentGross" has a "ORDER BY Program_Fixed_Component_Name_ID,Item" and the "##tmp_claim_report_results" query results are also being ordered
			      by the same fields. Since both query results return the product/component results in the same order, we do not have to re-query the temp table.
			--->
			<!--- Dev Note: Milan (24557). If any change in the SELECT clause OR ORDER BY clause OR any other change is made here. A corresponding
			change might need to be made on function "getProgramLetterFreightFixedComponentGross" on "components\programs\letters\ProgramLetterFreightManager.cfc" - 
			There we might need to make the ORDER BY clause same as here and then verify whether both the result sets are same.
			--->
			<!--- Claim rates --->
			<cfquery name="thisTag.qCustomerProductComponentClaimRate"  datasource="#application.datasource#">
				SELECT	expected_fixed_price_claim_rate_per_case, net_weight
				FROM 	##tmp_claim_report_results
				WHERE	BSA_FOODSERVICE_CUSTOMERS_ID = <cfqueryparam value="#thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].BSA_FOODSERVICE_CUSTOMERS_ID#" cfsqltype="cf_sql_idstamp"> 
				AND	Component_Type = 'VARIABLE'
				ORDER BY Component_Name_ID,Item
			</cfquery>

				<cfset thisTag.Program_Fixed_Component_Name_ID_List = "">											
		<cfloop query="thisTag.stPLDIF.qFOBFixedComp">
		<!--- Dev Note: KAL; D15961: Add claim rate in PDF letters --->	
		<cfset thisTag.bShowClaimRateFreightPage = 0>
		<!--- Dev Note: KAL; D15961: When to show claim rates column in freight page 												
			The letter is a distributor letter 
			Fixed price component claim mechanics have "include in claim rate" = ON 
		--->
		<cfif	thisTag.abbreviation eq "dis" 
			AND thisTag.stPLDIF.qFOBFixedComp.Include_Claim_Rates_Report
			AND thisTag.oAppSettings.getProgramClaimRatesReportAvailable()
			>
			<cfset thisTag.bShowClaimRateFreightPage = 1>
		</cfif>

				<!--- End Note: KAL; D15961: Add claim rate in PDF letters --->		
				
				<!--- CONDITION 1 - component_type EQUALS 1 [begin] --->
				<cfif thisTag.stPLDIF.qFOBFixedComp.Fixed_Component_Type EQ 1 and thisTag.stPLDIF.qFOBFixedComp.currentRow EQ 1>
					<!--- this row first on purpose for operator only... --->

				<!--- Set colspan based on the number of columns  --->
				<cfset colNum = 5 />
			
				<!--- If bShowClaimRateFreightPage is ON, add one more column --->
				<cfif thisTag.bShowClaimRateFreightPage>
					<cfset colNum = colNum + 1/>
				</cfif>

				<cfset bAddcustomerproductnumbers = 0>
				
				<!--- Conditional logic to show "Customer Product Number" column - Add one more column --->
				<cfif thisTag.bAddcustomerproductnumbers AND thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.stPDFBodyInfo.bDisplayFixedPriceDis>
					<cfset bAddcustomerproductnumbers = 1>
					<cfset colNum = colNum + 1/>
				</cfif>

				<!--- Initialize the table --->
				<cfset table_dis_Freight_Delivered = PdfPTable.init( javacast("int",colNum) )>
				<cfset table_dis_Freight_Delivered.setWidthPercentage(100)>

				<!--- Set the length of the array as big as the number of columns in the table --->
				<cfset jArr = arrObj.newInstance(jClass, colNum)>  

			<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
			will be used as the width of the columns in the table_dis_Freight_Delivered table.
			--->
			<!--- Since different data columns require different widths, below is the logic for the width based on what column
			needs to be shown
			--->
			<cfif bAddcustomerproductnumbers EQ 0 AND thisTag.bShowClaimRateFreightPage EQ 0>
						<cfset arrObj.setInt(jArr, 0, 17)>  
						<cfset arrObj.setInt(jArr, 1, 43)>  
						<cfset arrObj.setInt(jArr, 2, 14)> 
						<cfset arrObj.setInt(jArr, 3, 13)>  
						<cfset arrObj.setInt(jArr, 4, 13)>  

			<cfelseif bAddcustomerproductnumbers EQ 1 AND thisTag.bShowClaimRateFreightPage EQ 0>
						<cfset arrObj.setInt(jArr, 0, 8)>  
						<cfset arrObj.setInt(jArr, 1, 16)>  
						<cfset arrObj.setInt(jArr, 2, 42)>  
						<cfset arrObj.setInt(jArr, 3, 12)> 
						<cfset arrObj.setInt(jArr, 4, 11)>  
						<cfset arrObj.setInt(jArr, 5, 11)>  

				<cfelseif bAddcustomerproductnumbers EQ 0 AND thisTag.bShowClaimRateFreightPage EQ 1>
						<cfset arrObj.setInt(jArr, 0, 20)>  
						<cfset arrObj.setInt(jArr, 1, 30)>  
						<cfset arrObj.setInt(jArr, 2, 10)> 
						<cfset arrObj.setInt(jArr, 3, 10)>  
						<cfset arrObj.setInt(jArr, 4, 10)>  
						<cfset arrObj.setInt(jArr, 5, 20)>  

				<cfelseif bAddcustomerproductnumbers EQ 1 AND thisTag.bShowClaimRateFreightPage EQ 1>
						<cfset arrObj.setInt(jArr, 0, 8)>  
						<cfset arrObj.setInt(jArr, 1, 15)> 
						<cfset arrObj.setInt(jArr, 2, 30)>  
						<cfset arrObj.setInt(jArr, 3, 9)>  
						<cfset arrObj.setInt(jArr, 4, 9)> 
						<cfset arrObj.setInt(jArr, 5, 9)>
						<cfset arrObj.setInt(jArr, 6, 20)>
				</cfif>


				<cfset table_dis_Freight_Delivered.setWidths(jArr)>

				<!--- Ths table is not complete as yet --->
				<cfset table_dis_Freight_Delivered.setComplete(0)>

					<!--- Freight Header 2 --->
					<cfif bAddcustomerproductnumbers EQ 1>
						<cfset Cust_Prod_Number_Heading = PdfPCell.init(phrase.init("Cust Prod No", GothicBold_Font_Bold_Black_Eight))>
						<cfset Cust_Prod_Number_Heading.setColspan( javacast("int", 1) )>
						<cfset Cust_Prod_Number_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(Cust_Prod_Number_Heading)>
					</cfif>

						<cfset Item_Number_Heading = PdfPCell.init(phrase.init("Item No", GothicBold_Font_Bold_Black_Eight))>
						<cfset Item_Number_Heading.setColspan( javacast("int", 1) )>
						<cfset Item_Number_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(Item_Number_Heading)>

						<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Description", GothicBold_Font_Bold_Black_Eight))>
						<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
						<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(Item_Description_Heading)>

						<cfset Delivered_Heading = PdfPCell.init(phrase.init("Delivered", GothicBold_Font_Bold_Black_Eight))>
						<cfset Delivered_Heading.setColspan( javacast("int", 1) )>
						<cfset Delivered_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(Delivered_Heading)>

						<cfset PUA_Heading = PdfPCell.init(phrase.init("PUA", GothicBold_Font_Bold_Black_Eight))>
						<cfset PUA_Heading.setColspan( javacast("int", 1) )>
						<cfset PUA_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(PUA_Heading)>

						<cfset FOB_FDC_Heading = PdfPCell.init(phrase.init("FOB FDC", GothicBold_Font_Bold_Black_Eight))>
						<cfset FOB_FDC_Heading.setColspan( javacast("int", 1) )>
						<cfset FOB_FDC_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(FOB_FDC_Heading)>

					<cfif thisTag.bShowClaimRateFreightPage EQ 1>
						<cfset Claim_Rate_Heading = PdfPCell.init(phrase.init("Claim Rate [#thisTag.claimRateDate#]", GothicBold_Font_Bold_Black_Eight))>
						<cfset Claim_Rate_Heading.setColspan( javacast("int", 1) )>
						<cfset Claim_Rate_Heading.setBorder(Rectangle.NO_BORDER)>
						<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
						<cfset table_dis_Freight_Delivered.addCell(Claim_Rate_Heading)>
					</cfif>

				<!--- NEW home for the headers... [end] --->

				<!--- CONDITION 2 -  component_type EQUALS 1 [end] --->		
				<cfelseif thisTag.stPLDIF.qFOBFixedComp.Fixed_Component_Type NEQ 1 and thisTag.stPLDIF.qFOBFixedComp.currentRow EQ 1>
							<!--- component_type does NOT equal 1 [begin] --->
							<!--- this row first on purpose for operator only... --->

				<!--- Set colspan based on the number of columns  --->
				<cfset colNum = 3 />
				
				<!--- If bShowClaimRateFreightPage is ON, add one more column --->
				<cfif thisTag.bShowClaimRateFreightPage>
					<cfset colNum = colNum + 1/>
				</cfif>

				<cfset bAddcustomerproductnumbers = 0>

				<!--- Conditional logic to show "Customer Product Number" column - Add one more column --->
				<cfif thisTag.bAddcustomerproductnumbers AND thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.stPDFBodyInfo.bDisplayFixedPriceDis>
					<cfset bAddcustomerproductnumbers = 1>
					<cfset colNum = colNum + 1/>
				</cfif>
				
				<!--- Initialize a table with  columns --->
				<cfset table_dis_Freight_NonDelivered = PdfPTable.init( javacast("int",colNum) )>
				<cfset table_dis_Freight_NonDelivered.setWidthPercentage(100)>
				
				<!--- Set the length of the array as big as the number of columns in the table --->
				<cfset jArr = arrObj.newInstance(jClass, colNum)>  


			<!--- The first index of the array in JAVA starts with 0. Here different indexes are being assigned a value.  These values 
						will be used as the width of the columns in the table_dis_Freight_NonDelivered table.
			--->
			<cfif bAddcustomerproductnumbers EQ 0 AND thisTag.bShowClaimRateFreightPage EQ 0>
				<cfset arrObj.setInt(jArr, 0, 35)>  
				<cfset arrObj.setInt(jArr, 1, 35)>  
				<cfset arrObj.setInt(jArr, 2, 30)> 

			<cfelseif bAddcustomerproductnumbers EQ 1 AND thisTag.bShowClaimRateFreightPage EQ 0>
						<cfset arrObj.setInt(jArr, 0, 15)>  
						<cfset arrObj.setInt(jArr, 1, 30)>  
						<cfset arrObj.setInt(jArr, 2, 30)>  
						<cfset arrObj.setInt(jArr, 3, 25)> 


				<cfelseif bAddcustomerproductnumbers EQ 0 AND thisTag.bShowClaimRateFreightPage EQ 1>
						<cfset arrObj.setInt(jArr, 0, 30)>  
						<cfset arrObj.setInt(jArr, 1, 30)>  
						<cfset arrObj.setInt(jArr, 2, 20)> 
						<cfset arrObj.setInt(jArr, 3, 20)>  


				<cfelseif bAddcustomerproductnumbers EQ 1 AND thisTag.bShowClaimRateFreightPage EQ 1>
						<cfset arrObj.setInt(jArr, 0, 12)>  
						<cfset arrObj.setInt(jArr, 1, 25)> 
						<cfset arrObj.setInt(jArr, 2, 25)>  
						<cfset arrObj.setInt(jArr, 3, 19)>  
						<cfset arrObj.setInt(jArr, 4, 19)> 
				</cfif>

			<cfset table_dis_Freight_NonDelivered.setWidths(jArr)>

			<!--- The table is not complete is yet --->
			<cfset table_dis_Freight_NonDelivered.setComplete(0)>

			<!--- Add the headers for the table columns --->
			<!--- Freight Header 2 --->
			<cfif bAddcustomerproductnumbers EQ 1>
				<cfset Cust_Prod_Number_Heading = PdfPCell.init(phrase.init("Cust Prod No", GothicBold_Font_Bold_Black_Eight))>
				<cfset Cust_Prod_Number_Heading.setColspan( javacast("int", 1) )>
				<cfset Cust_Prod_Number_Heading.setBorder(Rectangle.NO_BORDER)>
				<!---<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
				<cfset table_dis_Freight_NonDelivered.addCell(Cust_Prod_Number_Heading)>
			</cfif>

				<cfset Item_Number_Heading = PdfPCell.init(phrase.init("Item No", GothicBold_Font_Bold_Black_Eight))>
				<cfset Item_Number_Heading.setColspan( javacast("int", 1) )>
				<cfset Item_Number_Heading.setBorder(Rectangle.NO_BORDER)>
				<!---<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
				<cfset table_dis_Freight_NonDelivered.addCell(Item_Number_Heading)>

				<cfset Item_Description_Heading = PdfPCell.init(phrase.init("Description", GothicBold_Font_Bold_Black_Eight))>
				<cfset Item_Description_Heading.setColspan( javacast("int", 1) )>
				<cfset Item_Description_Heading.setBorder(Rectangle.NO_BORDER)>
				<!---<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
				<cfset table_dis_Freight_NonDelivered.addCell(Item_Description_Heading)>

				<cfset FOB_FDC_Heading = PdfPCell.init(phrase.init("FOB FDC", GothicBold_Font_Bold_Black_Eight))>
				<cfset FOB_FDC_Heading.setColspan( javacast("int", 1) )>
				<cfset FOB_FDC_Heading.setBorder(Rectangle.NO_BORDER)>
				<!---<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
				<cfset table_dis_Freight_NonDelivered.addCell(FOB_FDC_Heading)>

			<cfif thisTag.bShowClaimRateFreightPage EQ 1>
				<cfset Claim_Rate_Heading = PdfPCell.init(phrase.init("Claim Rate [#thisTag.claimRateDate#]", GothicBold_Font_Bold_Black_Eight))>
				<cfset Claim_Rate_Heading.setColspan( javacast("int", 1) )>
				<cfset Claim_Rate_Heading.setBorder(Rectangle.NO_BORDER)>
				<!---<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>--->
				<cfset table_dis_Freight_NonDelivered.addCell(Claim_Rate_Heading)>
			</cfif>
		</cfif>

<cfsilent>
		<cfset thisTag.ClaimRate = 0/>
								
		<cfif thisTag.stPLDIF.uomType EQ 1>
																				
			<cfset thisTag.IBF_Rate = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=(val(thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.IBF_Rate)/100) * val(thisTag.stPLDIF.qFOBFixedComp.gross_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
			<cfset thisTag.OBF_Rate = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=(val(thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.OBF_Rate)/100) * val(thisTag.stPLDIF.qFOBFixedComp.gross_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
			<cfset thisTag.Pickup_Allowance = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=(val(thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.Pickup_Allowance)/100) * val(thisTag.stPLDIF.qFOBFixedComp.gross_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
								 
			<!--- Dev Note: KAL; D15961: Claim Rate on PDF Letters, the rate is calculated per CS --->
			<cfif thisTag.bShowClaimRateFreightPage>	
					<cfset thisTag.ClaimRate = val(thisTag.qCustomerProductComponentClaimRate['expected_fixed_price_claim_rate_per_case'][thisTag.stPLDIF.qFOBFixedComp.currentrow])/>
			</cfif>
                                                
			<cfif Unit_Of_Measure_ID EQ 2>
				<cfset thisTag.FOB =  application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=val(thisTag.stPLDIF.qFOBFixedComp.Fixed_Price_Value) * val(thisTag.stPLDIF.qFOBFixedComp.net_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>													 
			<cfelse>
				<cfset thisTag.FOB =  val(thisTag.stPLDIF.qFOBFixedComp.Fixed_Price_Value)>
			</cfif>
			
		<cfelse>
		
			<cfset thisTag.IBF_Rate = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=((val(thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.IBF_Rate)/100)* val(thisTag.stPLDIF.qFOBFixedComp.gross_weight)) / val(thisTag.stPLDIF.qFOBFixedComp.net_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
			<cfset thisTag.OBF_Rate = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=((val(thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.OBF_Rate)/100)* val(thisTag.stPLDIF.qFOBFixedComp.gross_weight)) / val(thisTag.stPLDIF.qFOBFixedComp.net_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
			<cfset thisTag.Pickup_Allowance = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=((val(thisTag.stPLDIF.aProgramDistributor[thisTag.currentDistributor].stFOBProgramDistributorFreight.Pickup_Allowance)/100) * val(thisTag.stPLDIF.qFOBFixedComp.gross_weight)) / val(thisTag.stPLDIF.qFOBFixedComp.net_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen) >
	
			<!--- Dev Note: KAL; D15961: Claim Rate on PDF Letters, the rate is calculated per CS. Convert to LBS --->
			<cfif thisTag.bShowClaimRateFreightPage>
				<cfset thisTag.ClaimRate = (val(thisTag.qCustomerProductComponentClaimRate['expected_fixed_price_claim_rate_per_case'][thisTag.stPLDIF.qFOBFixedComp.currentrow])/ val(thisTag.stPLDIF.qFOBFixedComp.net_weight))/>
			</cfif>
                                                
					<cfif Unit_Of_Measure_ID EQ 1>
						<cfset thisTag.FOB =  application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=val(thisTag.stPLDIF.qFOBFixedComp.Fixed_Price_Value)  / val(thisTag.stPLDIF.qFOBFixedComp.net_weight), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
					<cfelse>
						<cfset thisTag.FOB =  val(thisTag.stPLDIF.qFOBFixedComp.Fixed_Price_Value)>
					</cfif>
					
				</cfif>
																					
         <cfif thisTag.stPLDIF.qFOBFixedComp.Fixed_Component_Type EQ 1>
                                                
							<cfset thisTag.Delivered_Price = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=val(thisTag.FOB) + val(thisTag.IBF_Rate) + val(thisTag.OBF_Rate), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
							<cfset thisTag.FOBDC_Price = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=val(thisTag.Delivered_Price) - val(thisTag.Pickup_Allowance), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
							
						<cfelse>
						
							<!--- ACTION: ask Deepa --->
							<cfset thisTag.Delivered_Price = 0>
							<cfset thisTag.FOBDC_Price = application.oProgramLetterFreightManager.NumericRoundDecimal(iValue=val(thisTag.FOB) + val(thisTag.IBF_Rate), iDecimalLen=thisTag.stPLDIF.iDecimalLen)>
							
					</cfif>
                                                        
				<!--- When UOM is CS --->
				<cfif thisTag.stPLDIF.uomType EQ 1>
				
					<cfset thisTag.IBF_Rate = NumberFormat(thisTag.IBF_Rate,',.99')>
					<cfset thisTag.OBF_Rate = NumberFormat(thisTag.OBF_Rate,',.99')>
					<cfset thisTag.Pickup_Allowance = NumberFormat(thisTag.Pickup_Allowance,',.99')>
					<cfset thisTag.FOB = NumberFormat(thisTag.FOB,',.99')>
					<cfset thisTag.FOBDC_Price = NumberFormat(thisTag.FOBDC_Price,',.99')>
					<cfset thisTag.ClaimRate = NumberFormat(thisTag.ClaimRate,',.99')>
					
					<cfif thisTag.stPLDIF.qFOBFixedComp.Fixed_Component_Type EQ 1>
						<cfset thisTag.Delivered_Price = NumberFormat(thisTag.Delivered_Price,',.99')>
					</cfif>
					
				<cfelse>
				
					<cfset thisTag.IBF_Rate = NumberFormat(thisTag.IBF_Rate,',.9999')>
					<cfset thisTag.OBF_Rate = NumberFormat(thisTag.OBF_Rate,',.9999')>
					<cfset thisTag.Pickup_Allowance = NumberFormat(thisTag.Pickup_Allowance,',.9999')>
					<cfset thisTag.FOB = NumberFormat(thisTag.FOB,',.9999')>
					<cfset thisTag.FOBDC_Price = NumberFormat(thisTag.FOBDC_Price,',.9999')>
					<cfset thisTag.ClaimRate = NumberFormat(thisTag.ClaimRate,',.9999')>
				
					<cfif thisTag.stPLDIF.qFOBFixedComp.Fixed_Component_Type EQ 1>
						<cfset thisTag.Delivered_Price = NumberFormat(thisTag.Delivered_Price,',.9999')>
					</cfif>
					
				</cfif>
		</cfsilent>

		<!--- component_type EQUALS 1 [begin] --->
		<cfif thisTag.stPLDIF.qFOBFixedComp.Fixed_Component_Type EQ 1>
				
				<!--- [begin] Customer Product Number --->
				<cfif thisTag.bAddcustomerproductnumbers AND thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.stPDFBodyInfo.bDisplayFixedPriceDis>
						<cfif thisTag.qProgramFixedPrice.recordCount AND listFindNoCase(thisTag.qProgramFixedPrice.columnlist,'customer_product_number',',')>
								<cfquery name="thisTag.qCustProdNum" dbtype="query">
									SELECT 	DISTINCT(customer_product_number)
									FROM 		thisTag.qProgramFixedPrice
									WHERE		item = '#trim(thisTag.stPLDIF.qFOBFixedComp.item)#'
								</cfquery>
						
								<!--- Get freight Content --->
								<cfif thisTag.qCustProdNum.customer_product_number[1] NEQ "na" AND len(trim(thisTag.qCustProdNum.customer_product_number[1]))>
										<cfset Cust_Prod_Number = PdfPCell.init(phrase.init("#thisTag.qCustProdNum.customer_product_number[1]#", GothicNormal_font_Bold_Black_Eight))>
								<cfelse>
										<!--- Add a spaceholder --->
										<cfset Cust_Prod_Number = PdfPCell.init(phrase.init(chr(160)))>
								</cfif>

						<cfelse>
									<!--- Add a spaceholder --->
								 <cfset Cust_Prod_Number = PdfPCell.init(phrase.init(chr(160)))>
						</cfif>

								<cfset Cust_Prod_Number.setColspan( javacast("int", 1) )>
								<cfset Cust_Prod_Number.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Cust_Prod_Number.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Cust_Prod_Number.setBackgroundColor(textColorLightGray)>
								</cfif>

							<cfif IsDefined("table_dis_Freight_Delivered")>
								<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
								<cfset table_dis_Freight_Delivered.addCell(Cust_Prod_Number)>
							</cfif>

					</cfif>
					<!--- [end] Customer Product Number --->
		
								
								<cfset Item_Number = PdfPCell.init(phrase.init("#thisTag.stPLDIF.qFOBFixedComp.Item#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Item_Number.setColspan( javacast("int", 1) )>
								<cfset Item_Number.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Item_Number.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Item_Number.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_Delivered")>
									<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_Delivered.addCell(Item_Number)>
								</cfif>

								<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.stPLDIF.qFOBFixedComp.Description#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Item_Description.setColspan( javacast("int", 1) )>
								<cfset Item_Description.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Item_Description.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Item_Description.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_Delivered")>
									<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_Delivered.addCell(Item_Description)>
								</cfif>

								<cfset Delivered = PdfPCell.init(phrase.init("#thisTag.Delivered_Price#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Delivered.setColspan( javacast("int", 1) )>
								<cfset Delivered.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Delivered.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Delivered.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_Delivered")>
									<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_Delivered.addCell(Delivered)>
								</cfif>

								<cfset PUA = PdfPCell.init(phrase.init("#thisTag.Pickup_Allowance#", GothicNormal_font_Bold_Black_Eight))>
								<cfset PUA.setColspan( javacast("int", 1) )>
								<cfset PUA.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset PUA.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset PUA.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_Delivered")>
									<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_Delivered.addCell(PUA)>
								</cfif>

								<cfset FOB_FDC = PdfPCell.init(phrase.init("#thisTag.FOBDC_Price#", GothicNormal_font_Bold_Black_Eight))>
								<cfset FOB_FDC.setColspan( javacast("int", 1) )>
								<cfset FOB_FDC.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset FOB_FDC.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset FOB_FDC.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_Delivered")>
									<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_Delivered.addCell(FOB_FDC)>
								</cfif>

							<cfif thisTag.bShowClaimRateFreightPage EQ 1>
								<cfset Claim_Rate = PdfPCell.init(phrase.init("#thisTag.ClaimRate#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Claim_Rate.setColspan( javacast("int", 1) )>
								<cfset Claim_Rate.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Claim_Rate.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Claim_Rate.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_Delivered")>
									<cfset table_dis_Freight_Delivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_Delivered.addCell(Claim_Rate)>
								</cfif>
							</cfif>

             <!--- component_type does NOT equal 1 [begin] --->
						<cfelse>

							<!--- [begin] Customer Product Number --->
							<cfif thisTag.bAddcustomerproductnumbers AND thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.stPDFBodyInfo.bDisplayFixedPriceDis>
									<cfif thisTag.qProgramFixedPrice.recordCount AND listFindNoCase(thisTag.qProgramFixedPrice.columnlist,'customer_product_number',',')>
												<cfquery name="thisTag.qCustProdNum" dbtype="query">
													SELECT 	DISTINCT(customer_product_number)
													FROM 		thisTag.qProgramFixedPrice
													WHERE		item = '#trim(thisTag.stPLDIF.qFOBFixedComp.item)#'
													</cfquery>
											<cfif thisTag.qCustProdNum.customer_product_number[1] NEQ "na" AND len(trim(thisTag.qCustProdNum.customer_product_number[1]))>
													<cfset Cust_Prod_Number = PdfPCell.init(phrase.init("#thisTag.qCustProdNum.customer_product_number[1]#", GothicNormal_font_Bold_Black_Eight))>
											<cfelse>
												<cfset Cust_Prod_Number = PdfPCell.init(phrase.init(chr(160)))>
											</cfif>

									 <cfelse>
												 <cfset Cust_Prod_Number = PdfPCell.init(phrase.init(chr(160)))>
									 </cfif>
											
												<cfset Cust_Prod_Number.setColspan( javacast("int", 1) )>
												<cfset Cust_Prod_Number.setBorder(Rectangle.NO_BORDER)>

												<!--- Alternate coloring --->
												<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
														<cfset Cust_Prod_Number.setBackgroundColor(textColorWhite)>
												<cfelse>
														<cfset Cust_Prod_Number.setBackgroundColor(textColorLightGray)>
												</cfif>

											<cfif IsDefined("table_dis_Freight_NonDelivered")>
												<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
												<cfset table_dis_Freight_NonDelivered.addCell(Cust_Prod_Number)>
											</cfif>

								</cfif>
								<!--- [end] Customer Product Number --->
								
								<cfset Item_Number = PdfPCell.init(phrase.init("#thisTag.stPLDIF.qFOBFixedComp.Item#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Item_Number.setColspan( javacast("int", 1) )>
								<cfset Item_Number.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Item_Number.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Item_Number.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_NonDelivered")>
									<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_NonDelivered.addCell(Item_Number)>
								</cfif>

								<cfset Item_Description = PdfPCell.init(phrase.init("#thisTag.stPLDIF.qFOBFixedComp.Description#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Item_Description.setColspan( javacast("int", 1) )>
								<cfset Item_Description.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Item_Description.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Item_Description.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_NonDelivered")>
									<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_NonDelivered.addCell(Item_Description)>
								</cfif>

								<cfset FOB_FDC= PdfPCell.init(phrase.init("#thisTag.FOBDC_Price#", GothicNormal_font_Bold_Black_Eight))>
								<cfset FOB_FDC.setColspan( javacast("int", 1) )>
								<cfset FOB_FDC.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset FOB_FDC.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset FOB_FDC.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_NonDelivered")>
									<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_NonDelivered.addCell(FOB_FDC)>
								</cfif>

							<cfif thisTag.bShowClaimRateFreightPage EQ 1>
								<cfset Claim_Rate = PdfPCell.init(phrase.init("#thisTag.ClaimRate#", GothicNormal_font_Bold_Black_Eight))>
								<cfset Claim_Rate.setColspan( javacast("int", 1) )>
								<cfset Claim_Rate.setBorder(Rectangle.NO_BORDER)>

								<!--- Alternate coloring --->
								<cfif thisTag.stPLDIF.qFOBFixedComp.currentRow MOD 2 eq 1>
										<cfset Claim_Rate.setBackgroundColor(textColorWhite)>
								<cfelse>
										<cfset Claim_Rate.setBackgroundColor(textColorLightGray)>
								</cfif>

								<cfif IsDefined("table_dis_Freight_NonDelivered")>
									<cfset table_dis_Freight_NonDelivered.setHorizontalAlignment(PdfPCell.ALIGN_LEFT)>
									<cfset table_dis_Freight_NonDelivered.addCell(Claim_Rate)>
								</cfif>
							</cfif>

              </cfif>
													
							<cfset thisTag.Program_Fixed_Component_Name_ID_List = listAppend(thisTag.Program_Fixed_Component_Name_ID_List,thisTag.stPLDIF.qFOBFixedComp.Program_Fixed_Component_Name_Id)>
							<cfif IsDefined("table_dis_Freight_NonDelivered")>
								<cfset document.add(table_dis_Freight_NonDelivered)>
							</cfif>
							</cfloop>
                 <!--- 
                     <cfif thisTag.abbreviation EQ "dis" AND thisTag.currentDistributor LT arrayLen(thisTag.stPLDIF.aProgramDistributor) AND arrayLen(thisTag.stPLDIF.aProgramDistributor) LTE thisTag.maximumDistributorsForFreightSectionForcedPageBreaks>
                         pagebreak
                        </cfif>
									--->
									<cfif IsDefined("table_dis_Freight_Delivered")>
										<cfset document.add(table_dis_Freight_Delivered)>
									</cfif>
		</cfif>
                </cfloop>            
            <!--- content [end] --->
            <!--- Freight Summary [end] --->
        </cfif>   
				
					<!--- The tables are complete --->
					<cfif IsDefined("table_dis_Freight_Delivered")>
						<cfset table_dis_Freight_Delivered.setComplete(1)>
					</cfif>
					<cfif IsDefined("table_dis_Freight_NonDelivered")>
						<cfset table_dis_Freight_NonDelivered.setComplete(1)>
					</cfif>
    </cfif>
    <!--- Freight Page [end] --->
	
	<!--- TEMPORARILY COMMENT OUT CLAUSE [begin]
	SINCE WE HACE COMMENTED OUT ALL REFERNCES TO CLAUSES WITHIN THE EDIT AREA, THIS WILL ONLY SURFACE IF THE ORIGINAL LETTER HAS CLAUSES
	TEMPORARILY COMMENT OUT CLAUSE [end] --->
    
<!--- 7.) IF we have Clauses to display [begin] --->
    <cfif thisTag.qProgramClause.recordCount>
			<cfinclude template="doc_modules/inc_all_clauses.cfm">
    </cfif>
<!--- Clauses [end] --->

<!--- 8.) Signatures [begin] --->
		<cfset bShowSignature = 1>
		<!--- Check the distributor "customer acceptance block" template level setting --->
		<cfif thisTag.abbreviation eq "dis"> 
			<cfif thisTag.stPDFBodyInfo.bDistributorCustomerAcceptanceBlock eq 0>
				<cfset bShowSignature = 0>
			</cfif>
		</cfif>
		<!--- Check the operator "customer acceptance block" template level setting --->
		<cfif thisTag.abbreviation eq "opr">
			<cfif thisTag.stPDFBodyInfo.bOperatorCustomerAcceptanceBlock eq 0>
				<cfset bShowSignature = 0>
			</cfif>
		</cfif>

		<cfif bShowSignature eq 1>
			<!--- If template setting "BA Pre-defined page breaks" is ON, Go to a new page for signature --->
			<cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks>				
				<cfset document.newPage()>	
			<cfelse>
				<cfset document.add(chunk.init(chr(13) & chr(10)))>
			</cfif>
				
			<cfinclude template="doc_modules/inc_#thisTag.abbreviation#_signatures.cfm">
		</cfif>
<!--- Signatures [end] --->

<!--- The content of the pdf document is complete. Close the document --->
<!--- Actually, at this point, the created document has a "temp_1" suffix. --->
<cfset document.close()>

	<!---<cfset thisTag.cumulative_pages_to_delete_from_letter = 0>--->

	<!--- If the request is NOT to delete any pages, then take these steps --->
  <cfif len(trim(thisTag.pages_to_delete_from_prior_letter)) eq 0 AND len(trim(thisTag.pages_to_delete_from_this_letter)) eq 0>
  		
			<!--- Step 1: Open the file with the "temp_1" suffix, delete any empty pages, then save it with "temp_2" suffix. 
			At this stage, delete the file with the "temp_1" suffix. We do not need it anymore --->
			<cfinclude template="doc_modules/delete_empty_pages.cfm">

			<!--- Step 2: Open the file with the "temp_2" suffix, add header and footer and then, then save the file. The is the
						file which we need. Delete the file with the "temp_2" suffix.
			--->
			<cfinclude template="doc_modules/add_header_footer.cfm">
	</cfif>

  <!---<cfset thisTag.cumulative_pages_to_delete_from_letter = listAppend(thisTag.pages_to_delete_from_prior_letter,thisTag.pages_to_delete_from_this_letter,',')>
  <cfelse> 
	--->

			
  <!--- || II.) Add a watermark [optional]... only if we have a .jpg. .gif's will not allow for semi-transparency...'--->
  <!--- ACTION: we should request hi-res jpg's from our clients. Prep in photoshop @ 72dpi and proper dimensions for 2 reasons...
	Quality and the possibility of a Watermark here... Employed CFImage tage to convert to jpg on the fly... --->
  <!--- IF we are good to go - we WANT a watermark image AND we were given a .jpg watermark image, USE it! :-) --->
 <cfif thisTag.bInsertWatermark AND findNoCase(".jpg",thisTag.watermark_image,1)>
    <cfpdf action="addwatermark"
        opacity="1"
        image="../../../images/logon_blacksmith/#thisTag.watermark_image#"
        source="#thisTag.pdf_file_path#"
        overwrite="yes"
        showonprint="yes"
        destination="#thisTag.pdf_file_path#"
        foreground="yes">
  </cfif>

  <!--- || III.) Add Meta Data to the PDF --->
  <!--- Dev Note: (76451) - Removed pdf meta data code --->
  <!---<cfset thisTag.stPDFmeta = structNew()>--->
  <!--- 
  NOTE: this file will always have the inc_all_vars which creates the primary PDF structs...
  --->
  <!---
  <cfset structInsert(thisTag.stPDFmeta,"Author",thisTag.stPDFIntroInfo.responsible_sales_person_first_name & ' ' & thisTag.stPDFIntroInfo.responsible_sales_person_last_name & ' - ' & lCase(thisTag.stPDFIntroInfo.responsible_sales_person_email),true)>
	<cfif thisTag.abbreviation EQ 'dis'>
		<cfset structInsert(thisTag.stPDFmeta,"Title",thisTag.stPDFHeaderInfo.program_title & ' ' & application.appsettingsget.distributor_letter_name & ' - ' & dateFormat(now(),'mm/dd/yy'),true)>
	<cfelseif thisTag.abbreviation EQ 'opr'>
		<cfset structInsert(thisTag.stPDFmeta,"Title",thisTag.stPDFHeaderInfo.program_title & ' ' & application.appsettingsget.operator_letter_name & ' - ' & dateFormat(now(),'mm/dd/yy'),true)>	
	</cfif>
	<cfset structInsert(thisTag.stPDFmeta,"Subject",application.appsettingsget.letterssubject & ' (c) ' & year(now()) & ' ' & application.returned_customer_setting.company_name
,true)>
  <cfset structInsert(thisTag.stPDFmeta,"Keywords",thisTag.stPDFHeaderInfo.contract_number & ' ' & thisTag.stPDFHeaderInfo.program_bid_request_status & ' ' & ' Eligible Dates: ' & dateFormat(thisTag.stPDFIntroInfo.contract_start_date, "m/d/yy") & ' - ' & dateFormat(thisTag.stPDFIntroInfo.contract_end_date, "m/d/yy") & ' Program Category: ' & thisTag.stPDFIntroInfo.template_name & ' Program Volume: ' & thisTag.stPDFIntroInfo.total_program_value,true)>
  
  <cfpdf action="setinfo" source="#thisTag.pdf_file_path#" info="#thisTag.stPDFmeta#" overwrite="yes" >
  --->

	<!--- If the request is to delete pages --->
  <cfif len(trim(thisTag.pages_to_delete_from_prior_letter)) OR len(trim(thisTag.pages_to_delete_from_this_letter))>
  
  	<cfset thisTag.cumulative_pages_to_delete_from_letter = listAppend(thisTag.pages_to_delete_from_prior_letter,thisTag.pages_to_delete_from_this_letter,',')>
 
	<cfinclude template="doc_modules/delete_requested_pages.cfm"> 
			<!---	Since the request is to delete page(s), once the "deletePages" action deletes the requested pages,take these steps:
			--->
			<!--- Step 1: Open the file with the "temp_1" suffix (the file from where the requested pages were deleted), delete any 
						empty pages, then save it with "temp_2" suffix. At this stage, delete the file with the "temp_1" suffix. We do not
						need it anymore.
			--->
				<cfinclude template="doc_modules/delete_empty_pages.cfm">

			<!--- Step 2: Open the file with the "temp_2" suffix, add header and footer and then, then save the file. The is the
						file which we need. Delete the file with the "temp_2" suffix.
			--->
				<cfinclude template="doc_modules/add_header_footer.cfm">
	</cfif>
  

  <!--- Do we need to protect the file? I am commenting the code. --->
  <!--- || IV.) Create a password, encrypt and limit permissions... We DO allow assembly here. We do NOT allow further assembly to already assembled docs.  --->
  <!---
	<cfpdf action = "protect"
      source = "#thisTag.pdf_file_path#"
      newOwnerPassword = "#trim(thisTag.CMID)#"
      permissions = "AllowAssembly,AllowDegradedPrinting,AllowPrinting,AllowScreenreaders,AllowSecure"
      destination = "#thisTag.pdf_file_path#"
      encrypt = "RC4_40"
      overwrite = "yes">
  ---> 
</cflock> 