<cfsilent>
<!---
FILENAME:   	generate_program_pdf_html.cfm
CREATED: 		12/15/2007 - RBL 
EDITED: 		11/1/2011 - Milan
	(The file Brad initially created is "generate_program_pdf". I copied some code
	from there for this file and so I have included Brad's name as the initial developer)
EDITED:			1/18/2012 - Milan
	(Delete blank pages. Since deleting blank pages is done using Itext, the functionality to
	add header/footer is done using Itext too.
	Note: We need to look for blank pages and when we include header/footer, we cannot have
	blank pages.
	)

FUNCTIONALITY:
- 	This custom tag generates a pdf file.
--->

<!--- IMPORTANT TECH NOTE: Request Size Limits in CF Admin: Maximum Size of Post Data 1000MB, Request Throttle Threshold 5MB, Request Throttle Memory 1000MB --->  

<!--- we're gonna need a bigger boat... request timeout in seconds 2400=40min wow!---->
<!---
<cfsetting requesttimeout="2400">
--->

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

<!--- Main Info to be shown on the letter --->
<cfparam name="attributes.qProgramClause"				type="query" 		default="#queryNew('Clause')#">
<cfparam name="attributes.qProgramDistributor"			type="query" 		default="#queryNew('Distributor')#">
<cfparam name="attributes.qProgramFixedPrice"			type="query" 		default="#queryNew('Fixed_Price,item')#">
<cfparam name="attributes.qProgramLumpSum"				type="query" 		default="#queryNew('Lump_Sum')#">
<cfparam name="attributes.qProgramOperator"				type="query" 		default="#queryNew('Operator')#">
<cfparam name="attributes.qProgramRebate"				type="query" 		default="#queryNew('Rebate')#">
<!--- queries from the VARS Include for scoping... [end] --->

<!--- OPR_path OR DIS_path --->
<cfparam name="attributes.relative_path" 				type="string" 	default="">

<cfparam name="attributes.revised_doc_title" 			type="string" 	default="">

<!--- END structure --->
<cfparam name="attributes.stPDFEndInfo" 				type="struct" 	default="#structNew()#">

<!--- BODY structure [all boolean] --->
<cfparam name="attributes.stPDFBodyInfo" 						type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFBodyInfo.bDisplayFixedPrice" 	type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayLumpSum" 		type="boolean"	default="0">
<cfparam name="attributes.stPDFBodyInfo.bDisplayRebate" 		type="boolean"	default="0">

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
<cfparam name="attributes.stPDFHeaderInfo.created_type" 		type="string" 	default="">

<!--- NO FOOTER struct... --->

<!--- INTRO structure --->
<cfparam name="attributes.stPDFIntroInfo" 										type="struct" 	default="#structNew()#">
<cfparam name="attributes.stPDFIntroInfo.company" 								type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_end_date" 					type="string" 	default="">
<cfparam name="attributes.stPDFIntroInfo.contract_start_date" 					type="string" 	default="">
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
<cfparam name="attributes.preferred_fontFamily" 								type="string" 	default="">

<cfparam name="attributes.lsDistributorNames" 									type="string" 	default="">
<cfparam name="attributes.lsDistributorIDs" 									type="string" 	default="">
<cfparam name="attributes.lsOperatorNames" 										type="string" 	default="">
<cfparam name="attributes.lsOperatorIDs" 										type="string" 	default="">

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

</cfsilent>

<!--- [begin] Check "Customer Acceptance Block" template setting --->
<cfset bCustomerAcceptanceBlock = 0>

<!--- If it is an "operator" letter, check whether "Customer Acceptance Block" is ON at the letter tab of the template --->
<cfif thisTag.abbreviation eq "opr">
  <cfset bCustomerAcceptanceBlock = thisTag.stPDFBodyInfo.bOperatorCustomerAcceptanceBlock>
<cfelse>
<!--- If it is a "distributor" letter, check whether "Customer Acceptance Block" is ON at the letter tab of the template --->
  <cfset bCustomerAcceptanceBlock = thisTag.stPDFBodyInfo.bDistributorCustomerAcceptanceBlock>
</cfif>
<!--- [end] Check "Customer Acceptance Block" template setting 	--->

<!---	Get the template setting to get "LeftSideDataRowCount" and "RightSideDataRowCount" variables. These variables are used to decide
	the space between the header and the content of each page of the letter. When we have more rows of header, te margintop property
	of "<CFDOCUMENT>" will increase.
--->
<cfinclude template = "doc_modules/template_settings.cfm">

<!---	The header and the footer are created in Itext and not "<CFDOCUMENT>" because we need to delete empty pages from the pdf file and that can be deleted
	using Itext and not just be any cf tag. To delete an empty (blank) page using Itext, we canot have header and footer, otherwise we cannot know whether
	the file is empty as we look for the data size of the page.
	Since the header and footer are created using Itext and the body of the pdf is created using "<CFDOCUMENT>", the  margin between the header and the body
	content is not automatically adjusted based on size of the header (Note: There could be extra rows on the header based on template setting).
	"LeftSideDataRowCount" and "LeftSideDataRowCount" variables keeps a count of rows on the header. For every row added, the "marginTop" property of "<CFDOCUMENT>" needs to increase.
--->

<!--- Default setting. When we do not have any extra template setting ON to show even one additional row of header (ZERO) --->
<cfif LeftSideDataRowCount eq 0 AND RightSideDataRowCount eq 0>
	<cfset Margin_From_Top = "1.00"><!--- standard margin size (without any additional header rows to add) --->
<!---
NOTE: 
TO GET THE REQUIRED MARGIN FROM TOP, WE NEED TO CHECK WHETHER THE ENTRIES ON THE LEFT SIDE OF THE HEADER OR RIGHT SIDE OF THE HEADER REQUIRE X AMOUNT OF ROWS.
FOR EG: IF THE LEFT SIDE OF THE HEADER REQURES 3 ENTRIES (3 NEW ROWS) BUT THE RIGHT SIDE REQUIRES ONLY 1 ROW, THEN WE WILL NEED TO ADD THREE NEW ROWS FOR THE HEADER.
THAT IS WHY THE CODE CHECKS FOR THE HIGHEST NUMBER OF NEW ROWS (3) FIRST AND THEN GOES TO 2, THEN 1.
--->

<!--- When we have extra template setting ON to show THREE additional rows of header --->
<cfelseif LeftSideDataRowCount eq 3 OR RightSideDataRowCount eq 3>
	<cfset Margin_From_Top = "1.45">

<!--- When we have extra template setting ON to show TWO additional rows of header --->
<cfelseif LeftSideDataRowCount eq 2 OR RightSideDataRowCount eq 2>
	<cfset Margin_From_Top = "1.30">

<!--- When we have extra template setting ON to show ONE additional rows of header --->
<cfelseif LeftSideDataRowCount eq 1 OR RightSideDataRowCount eq 1>
	<cfset Margin_From_Top = "1.15">

</cfif>

<!---32417/38179 - increase top margin when a 3rd and/or a 2nd line is required is required for long program title. 
             programTitlePart2 and programTitlePart3 is populated in doc_modules\template_settings.cfm--->
<cfif (IsDefined("programTitlePart2") and len(programTitlePart2)) or (IsDefined("programTitlePart3") and len(programTitlePart3))>
	<cfset Margin_From_Top = Val(Margin_From_Top) + 0.15>
</cfif>

<!---37669 - increase top margin when either a 3rd and/or a 2nd line is required for long template name. 
             templateNamePart2 and templateNamePart3 are populated in doc_modules\template_settings.cfm.--->
<cfif (IsDefined("templateNamePart2") and len(templateNamePart2)) or (IsDefined("templateNamePart3") and len(templateNamePart3))>
	<cfset Margin_From_Top = Val(Margin_From_Top) + 0.15>

	<!--- Further increase top margin when we have template name on the 3rd line and we already do not have that additional
	margin from the program title's 3rd line. 
	--->
	<cfif (IsDefined("templateNamePart3") and len(templateNamePart3)) and len(programTitlePart3) eq 0>
		<cfset Margin_From_Top = Val(Margin_From_Top) + 0.15>
	</cfif>
</cfif>

<cflock type="exclusive" timeout="#application.stMvcAppInfo.lockTimeoutSeconds#" name="#thisTag.file_name#">
<!--- || I.) Create initial PDF doc... --->

<!--- The pdf file path where the pdf file is to be written is passed to this file (generate_program_pdf_html.cfm) as ".pdf" in the 
"thisTag.pdf_file_path" variable. Since Itext will need to loop through the file once it is written to the location to delete 
empty pages and add header and footer, I have changed the initial file name to use "_temp_1" as an appended value. This file 
could contain empty pages and so Itext will loop through these pages of the file ("_temp_1") and create another file with a 
"_temp_2" as an appended name and will delete "_temp_1" file. Then Itext will loop through the pages of the ("_temp_2") file, 
and add header and footer to it. Finally, it will create a file with nothing appended to it. That file name will be the original filename.
--->
<cfset thisTag.pdf_file_path = ReplaceNoCase(thisTag.pdf_file_path,".pdf","_temp_1.pdf")>
  
  <!--- [begin] DISPLAY OF LETTERS --->
  <cfdocument filename="#thisTag.pdf_file_path#" format="PDF" pagetype="letter" marginbottom=".6" margintop="#Margin_From_Top#" marginright=".5" marginleft=".5" mimetype="text/html" orientation="portrait" unit="in" useragent="#cgi.http_user_agent#" backgroundvisible="yes" overwrite="yes" fontembed="yes" bookmark="true">
	<!--- WE DO NOT ADD ANY HEADER AND FOOTER ON THIS FILE. WE ADD IT ON "add_header_footer_html.cfm". --->

	<!--- 1.) Intro section - (If "PreDefinedPageBreaks" is ON) --->
    <cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
	  
	   <!--- Intro section [begin] --->
       <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# intro">
			
        <!--- intro [begin] --->			
			<cfinclude template="doc_modules/queries/inc_operator_group_query_html.cfm">
			<cfinclude template="doc_modules/queries/inc_distributor_group_query_html.cfm">			
			<!--- Distributor and Operator --->
			<cfinclude template="doc_modules/inc_all_intro_html.cfm">
        <!--- intro [end] --->
			
      </cfdocumentsection>
      <!--- Intro section [end] --->
	  	
    </cfif>

	<!--- 2.) IF we want fixed price - (If "PreDefinedPageBreaks" is ON) --->
    <cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation) AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
	
	  <!--- /// Fixed Price [begin] --->
      <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Fixed Price">
					
        <!--- content [begin] --->
			<cfinclude template="doc_modules/headers/inc_fixed_price_header_html.cfm">	
        <!--- content [end] --->
			
      </cfdocumentsection>
      <!--- Fixed Price [end] ---> 
      
    </cfif>
   
    

    <!--- 3.) IF we want rebate - (If "PreDefinedPageBreaks" is ON) --->
    <cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayRebate'&thisTag.abbreviation) AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
	
	  <!--- /// Rebate [begin] --->
      <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Rebate">
					
        <!--- content [begin] --->
			<cfinclude template="doc_modules/headers/inc_rebate_header_html.cfm">	
        <!--- content [end] --->
			
      </cfdocumentsection>
      <!--- Rebate [end] ---> 
      
    </cfif>
   

    <!--- 4.) IF we want lump sum - (If "PreDefinedPageBreaks" is ON) --->
    <cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayLumpSum'&thisTag.abbreviation) AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1><!--- /// Lump Sum [begin] --->
      
      <!--- lump sum [begin] --->
      <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Lump Sum">
			
        <!--- content [begin] --->
			<cfinclude template="doc_modules/inc_lump_sum_html.cfm">
        <!--- content [end] --->
			
      </cfdocumentsection>
       <!--- Lump Sum [end] --->
	   	
    </cfif>
  
 
   <!--- 5.) IF we want Signatures - (If "PreDefinedPageBreaks" is ON) --->
   <cfif bCustomerAcceptanceBlock AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
     
     <!--- signature [begin] --->
     <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Signature">
      <!--- content [begin] --->
      		<cfinclude template="doc_modules/inc_signatures_html.cfm">
      <!--- content [end] --->
	  	
    </cfdocumentsection>
    <!--- signature [end] --->
		
   </cfif>
   
    <!--- 6.) IF operator group members exist - (If "PreDefinedPageBreaks" is ON) --->
   <cfinclude template="doc_modules/queries/inc_operator_group_query_html.cfm">
   <cfif thisTag.qOperatorSecondaryDetails.recordCount AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
		
	 <!--- operators [begin] --->
     <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Operators">

			
        <!--- content [begin] --->
			<!--- If there are operator groups in the program, show the group members here --->
        	<cfinclude template="doc_modules/inc_operators_html.cfm">
        <!--- content [end] --->
			
     </cfdocumentsection>
     <!--- distributors [end] --->
	  	
    </cfif>
	

   <!--- 7.) IF distributor groups exist - (If "PreDefinedPageBreaks" is ON) --->
   <cfinclude template="doc_modules/queries/inc_distributor_group_query_html.cfm">
   <cfif thisTag.qDistDetails.recordCount AND thisTag.qDistDetails.Is_Group eq 1 AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
		
	 <!--- distributors [begin] --->
     <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Distributors">

			
        <!--- content [begin] --->
			<!--- If there are distributor groups in the program, show the group members here --->
        	<cfinclude template="doc_modules/inc_distributors_html.cfm">
        <!--- content [end] --->
			
     </cfdocumentsection>
     <!--- distributors [end] --->
	  	
    </cfif>
    
   
	<!--- 8.) IF we have Clauses to display - (If "PreDefinedPageBreaks" is ON) --->
    <cfif thisTag.qProgramClause.recordCount AND thisTag.stPDFBodyInfo.bPreDefinedPageBreaks EQ 1>
	
	  <!---  clauses [begin] --->
      <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# Clause">
        <!--- content [begin] --->
          		<cfinclude template="doc_modules/inc_all_clauses_html.cfm">
        <!--- content [end] --->
		  	
        </cfdocumentsection>
		 <!--- Clauses [end] --->
		 	
    </cfif>
   
    <!--- If "PreDefinedPageBreaks" is ON, code for letters ends above. If "PreDefinedPageBreaks" is OFF, use code below  --->
    <!--- 1 to All.) Show All - If "PreDefinedPageBreaks" is OFF, i.e. we want the pdf file as a continuous flow. No Page breaks. --->
    <cfif thisTag.stPDFBodyInfo.bPreDefinedPageBreaks eq 0>
		
	  <!--- All [begin] --->
      <cfdocumentsection name="#thisTag.current_program_letter_id##uCase(left(thisTag.abbreviation,'1'))# All">
	  	 
        <!--- content [begin] --->
		<cfinclude template="doc_modules/queries/inc_operator_group_query_html.cfm">
		<cfinclude template="doc_modules/queries/inc_distributor_group_query_html.cfm">
		<!--- Operators and distributor. When distributor groups are in the program, list the groups here, else show the distributors  --->
		<cfinclude template="doc_modules/inc_all_intro_html.cfm">

		<!--- IF we want fixed price - Fixed price [begin] --->
		<cfif thisTag.stPDFBodyInfo.bDisplayFixedPrice AND thisTag.qProgramFixedPrice.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayFixedPrice'&thisTag.abbreviation)>
		<p></p>
				<cfinclude template="doc_modules/headers/inc_fixed_price_header_html.cfm">
		</cfif>
		<!--- Fixed price [end] --->
		
		<!--- IF we want rebate - Rebate [begin] --->
		<cfif thisTag.stPDFBodyInfo.bDisplayRebate AND thisTag.qProgramRebate.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayRebate'&thisTag.abbreviation)>
		<p></p>
				<cfinclude template="doc_modules/headers/inc_rebate_header_html.cfm">
		</cfif>
		<!--- Rebate [end] --->
		
		<!--- IF we want lump sum - lump sum [begin] --->
		<cfif thisTag.stPDFBodyInfo.bDisplayLumpSum AND thisTag.qProgramLumpSum.recordCount AND evaluate('thisTag.stPDFBodyInfo.bDisplayLumpSum'&thisTag.abbreviation)>
		<p></p>
				<cfinclude template="doc_modules/inc_lump_sum_html.cfm">
		</cfif>
		<!--- lump sum [end] --->
		
     	<!--- IF we want Signatures - signature [begin] --->
		<cfif bCustomerAcceptanceBlock>		
		<p></p>
				<cfinclude template="doc_modules/inc_signatures_html.cfm">
		</cfif>
		<!--- signature [end] --->
			
		
		<!--- IF we have operator members -  operator members [begin] --->
		<cfif thisTag.qOperatorSecondaryDetails.recordCount>
			
			<!--- Create a page break --->
			<cfdocumentitem type="pagebreak" />
			
			<!--- If there are operator members in the program, show the members here --->
			<cfinclude template="doc_modules/inc_operators_html.cfm">
			
		</cfif>
						
		
		<!--- IF we have distributor groups -  distributor group members [begin] --->
		<cfif thisTag.qDistDetails.recordCount AND thisTag.qDistDetails.Is_Group eq 1>
			
			<!--- Create a page break --->
			<cfdocumentitem type="pagebreak" />
			
			<!--- If there are distributor groups in the program, show the group members here --->
			<cfinclude template="doc_modules/inc_distributors_html.cfm">
			
		</cfif>
		
		<!--- IF we have Clauses to display - clauses [begin] --->
		<cfif thisTag.qProgramClause.recordCount>
			
			<!--- Create a page break --->
			<cfdocumentitem type="pagebreak" />
			  
			  <!--- Include clauses --->
			  <cfinclude template="doc_modules/inc_all_clauses_html.cfm">
			    
		</cfif>
		<!--- clauses [end] --->
		
						  	
        <!--- content [end] --->
			
      </cfdocumentsection>
    </cfif>

  </cfdocument>
  <!--- [end] DISPLAY OF LETTERS --->

			<!---	Step 1: Open the file with the "temp_1" suffix, delete any empty pages, then save it with "temp_2" suffix. 
				At this stage, delete the file with the "temp_1" suffix. We do not need it anymore. 
			--->
			<cfinclude template="doc_modules/delete_empty_pages.cfm">

			<!---	Step 2: Open the file with the "temp_2" suffix, add header and footer and then, then save the file. The is the
				file which we need. Delete the file with the "temp_2" suffix.
			--->
			
			<cfinclude template="doc_modules/add_header_footer_html.cfm">

  <!--- || II.) Add Meta Data to the PDF --->
  <cfset thisTag.stPDFmeta = structNew()>
  <!--- 
  NOTE: this file will always have the inc_all_vars which creates the primary PDF structs...
  --->
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
      
</cflock>
