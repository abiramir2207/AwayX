<!---<cfset StructDelete(application,"oLetterManager")>--->
<cfsilent>
	<!--- 
	FILE:         
	FILENAME:     Common_Files/contracts/Letters/generate_opr_dis_letters.cfm
	CREATED:         12/19/2007 - RBL
	EDITED:            08/08/2008 - 
	EDITED:            08/16/2010 - Milan [Convert to Itext in Java]
	
	FUNCTIONALITY:
	- This file generates letters as requested for the user. It should ALWAYS generate 3 versions of 
	each of 8 options [html, pdf, xml] [xml to also/or be stored in LTM within a new column in the 
	Program_Letters table datatyped as xml... RBL --->
	<!--- These parameters are required for this template to process correctly --->
	<!--- Q: why do we have CID and CMID, etc. --->

  
	<cfparam name="url.CMID" type="numeric" default="0">
	<cfparam name="url.custprodnum" type="boolean" default="0">
	<cfparam name="url.freightpage" type="boolean" default="0">
	<cfparam name="url.freightuom" type="string" default="Lb">
	<cfparam name="url.volumepage" type="boolean" default="0">
	<cfparam name="url.watermark" type="boolean" default="0">

  <cfparam name="url.letterInclFixedPrice" type="boolean" default="0">
  <cfparam name="url.letterInclFreightPricing" type="boolean" default="0">
  <cfparam name="url.letterInclLumpsum" type="boolean" default="0">
  <cfparam name="url.letterInclRebate" type="boolean" default="0">
  <cfparam name="url.IncludeInactive" type="boolean" default="0">
	<cfinclude template="include_display_letters.cfm">
	<!--- WARNING WARNING :-) we need this here BEFORE we hit the include_vars template... --->
	<cfif url.CMID AND NOT isDefined("CSL_Contract_Main_ID")>
		<cfset CSL_Contract_Main_ID = url.CMID>
	</cfif>

	<!--- Tech Note D13826 and D14567 RBL - Deal Letters TOTALLY reworked. Lots of deprecated code below... --->
</cfsilent>

<cfif url.CMID>
	<cfset oProgramData = createObject("component","components.programs.program") />
    <cfset qProgramInfo = oProgramData.getProgramInfo(url.CMID)>
    <cfset contract_title = replace(qProgramInfo.Contract_Title," ","_","ALL") />
	<cfset contract_title = replaceList(contract_title, "*,/,',-,(,)","_") />
	<cfset contract_title = replace(contract_title, "__","_","ALL") />
	<!--- IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
	IIIIIIIII Let's create a watermark image [begin] IIIIIIIIII
	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII --->
	<!--- IF we already have a .jpg... --->
	<cfif listLast(application.appsettingsget.letters_company_logo_path, '.') EQ 'jpg'>
	
		<!--- use original .jpg as watermark... --->
		<cfset variables.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
	
		<!--- IF we originally have a .gif, convert it to a .jpg and write the image to the file system...
		 --->
	<cfelseif listLast(application.appsettingsget.letters_company_logo_path, '.') EQ 'gif'>
	
		<cfimage action="convert" 
		         source="#expandPath(application.appsettingsget.letters_company_logo_path)#" 
		         destination="#replace(expandPath(application.appsettingsget.letters_company_logo_path),'gif','jpg','all')#" 
		         overwrite="true">
	
		<cfset variables.watermark_image = replace(getFileFromPath(application.appsettingsget.letters_company_logo_path), 'gif','jpg', 'all')>
	
		<!--- IF we originally have a .png, convert it to a .jpg and write the image to the file system...
		 --->
	<cfelseif listLast(application.appsettingsget.letters_company_logo_path, '.') EQ 'png'>
	
		<cfimage action="convert" 
		         source="#expandPath(application.appsettingsget.letters_company_logo_path)#" 
		         destination="#replace(expandPath(application.appsettingsget.letters_company_logo_path),'png','jpg','all')#" 
		         overwrite="true">
	
		<cfset variables.watermark_image = replace(getFileFromPath(application.appsettingsget.letters_company_logo_path), 'png','jpg','all')>
	
		<!--- IF we have a file other than a .jpg or a .gif or it is undefined at the moment... --->
	<cfelse>
	
		<cfset variables.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
	</cfif>

	<!--- IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
	IIIIIIIII Let's create a watermark image [end] IIIIIIIIIIII
	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII --->
	<cfset objProgramClaimRatesReport = CreateObject("component", "components.programs.ProgramClaimRatesReport").init()/>

	<!--- The Deal Letters V2 ALWAYS Starts with the original data... --->
	<cfinclude template="doc_modules/inc_all_vars.cfm">

	<cfset bShowClaimRateDate = objProgramClaimRatesReport.IsClaimRatesAvailableOnProgram(CSL_Contract_Main_ID)>

	<!--- we do not show "claim rates" for "letters available - custom 2" app setting OR when "Dont_Show_Claim_Rates_On_Program_Letters" app setting is ON  --->
	<cfif appSettings.getlettersavailable() eq 2 OR appSettings.get_Setting('Dont_Show_Claim_Rates_On_Program_Letters') eq '1'>
		<cfset bShowClaimRateDate = 0>
	</cfif>

	<!--- alpha order The Magnificent 7
	<cfparam name="variables.qProgramBidRequestInitial"        type="query"     
	default="#queryNew('Bid_Request')#">
	<cfparam name="variables.qProgramClauseInitial"                type="query"     
	default="#queryNew('Clause')#">
	<cfparam name="variables.qProgramDistributorInitial"    type="query"     
	default="#queryNew('Distributor')#">
	<cfparam name="variables.qProgramFixedPriceInitial"        type="query"     
	default="#queryNew('Fixed_Price')#">
	<cfparam name="variables.qProgramLumpSumInitial"            type="query"     
	default="#queryNew('Lump_Sum')#">
	<cfparam name="variables.qProgramOperatorInitial"            type="query"     
	default="#queryNew('Operator')#">
	<cfparam name="variables.qProgramRebateInitial"                type="query"     
	default="#queryNew('Rebate')#"> --->
	<!--- output order
	  <cfdump var="#variables.qProgramDistributorInitial#" label="variables.qProgramDistributorInitial 
	GENERATE OPR DIS LETTERS">
	  <cfdump var="#variables.qProgramOperatorInitial#" label="variables.qProgramOperatorInitial 
	GENERATE OPR DIS LETTERS">
	  <cfdump var="#variables.qProgramFixedPriceInitial#" label="variables.qProgramFixedPriceInitial 
	GENERATE OPR DIS LETTERS">
	  <cfdump var="#variables.qProgramRebateInitial#" label="variables.qProgramRebateInitial GENERATE 
	OPR DIS LETTERS">
	  <cfdump var="#variables.qProgramBidRequestInitial#" label="variables.qProgramBidRequestInitial 
	GENERATE OPR DIS LETTERS">
	  <cfdump var="#variables.qProgramLumpSumInitial#" label="variables.qProgramLumpSumInitial GENERATE
	 OPR DIS LETTERS">
	  <cfdump var="#variables.qProgramClauseInitial#" label="variables.qProgramClauseInitial GENERATE 
	OPR DIS LETTERS">
	 <cfabort>
	--->
	<cfoutput>
	<!--- <cfdump var="#variables.stPDFBodyInfo#" label="stPDFBodyInfo" abort="true" /> --->
		<!--- set preferred fontFamily [CSS syntax] to be embedded in all pdf docs generated here...
		  NOTE: [must be resident on user's client machine at time of pdf creation, then embedded] 
		  Tech Note: perhaps this may be some form of app setting in future... --->
		<!--- For HTML Letter, we need "preferred_fontFamily" variable for correct font. --->
		<cfif appSettings.getlettersavailable() eq 2>
			<cfset variables.preferred_fontFamily = "Century Gothic">
		</cfif>
	
<!--- ================================================================================
========================== INITIAL GENERATION OF LETTERS [begin] =====================
================================================================================== --->  
  
<!--- =================================================================================
==================================== OPERATOR [begin] =================================
================================================================================== --->
<cfif getLetterSettings.Letter_Type EQ 1 or getLetterSettings.Letter_Type EQ 3>

<!--- Dev Note: Milan (20639). It does not matter whether we want to generate multiple operators or one operator 
			per letter.Just delete all existing operator letter(s), before creating new letter(s). 
--->
<!---				<cfinvoke 
---					component="#application.oLetterManager#" 
---					method="deleteAllProgramPDFLettersInDBandFile"
---					program_id="#CSL_Contract_Main_ID#"
---					check_operator = "1">--->
  	<!--- <cfset LetterManager.deleteLetters(CSL_Contract_Main_ID,1)> --->
  	<cfset variables.template_name = "#company_name# #appSettings.getOperatorLetterName()#">

    <cfif getLetterSettings.Operator_Letter_Type EQ 2>
    
		<!--- what type of letter are we creating RIGHT NOW --->
		<cfset variables.abbreviation = "opr">
		
		<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
		<cfinclude template="doc_modules/inc_init_vars.cfm">
		<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
		
		<!--- TESTING <cfdump var="#variables.qProgramDistributorInitial#" label="variables.qProgramDistributorInitial GENERATE OPR DIS LETTERS">
		 <cfdump var="#variables.qProgramOperatorInitial#" label="variables.qProgramOperatorInitial GENERATE OPR DIS LETTERS">
		 <cfdump var="#variables.qProgramFixedPriceInitial#" label="variables.qProgramFixedPriceInitial GENERATE OPR DIS LETTERS">
		 <cfdump var="#variables.qProgramRebateInitial#" label="variables.qProgramRebateInitial GENERATE OPR DIS LETTERS">
		 <cfdump var="#variables.qProgramBidRequestInitial#" label="variables.qProgramBidRequestInitial GENERATE OPR DIS LETTERS">
		 <cfdump var="#variables.qProgramLumpSumInitial#" label="variables.qProgramLumpSumInitial GENERATE OPR DIS LETTERS">
		 <cfdump var="#variables.qProgramClauseInitial#" label="variables.qProgramClauseInitial GENERATE OPR DIS LETTERS">
		 <cfabort> --->
		
		<cfset variables.lsOperatorNames = valueList(variables.qProgramOperatorInitial.Operator_Name,", ")>
		<cfset variables.lsOperatorIDs = valueList(variables.qProgramOperatorInitial.operator_id,",")>
		<!--- All distributors --->
		<cfif getLetterSettings.Opr_letter_settings EQ 2>

      	<!--- 	================================================
				==== Operator 1 of 6 (Multi Oper & All Dist)====
				================================================	--->
	      	<cfset variables.lsDistributorNames = valueList(variables.qProgramAllDistributorInitial.Name,", ")>
	        <cfset variables.lsDistributorIDs = valueList(variables.qProgramAllDistributorInitial.contract_distributors_id,",")>
			<cfif appSettings.getlettersavailable() eq 2>
				<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allOperators_allDistributors_")>  
			<cfelse>	
			    <cfset variables.nameformat = LetterName("#contract_number#_allOperators_allDistributors_")>  <!---25704--->
			</cfif>    
			    <cfset variables.relative_url = replace(opr_path,'\','/','all')>
	        <cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
	        <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
	        <cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
	        <cfset variables.html_file_path = lCase(variables.html_file_path)>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
         
				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
	   
					<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

				<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
				<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
				INSERT INTO	Program_Letters
				(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
				values
				(#CSL_Contract_Main_ID#,1,'#variables.nameformat#','#variables.html_file_path#',
				'All #application.returned_customer_setting.operator_label_plural#',
				'All #application.returned_customer_setting.distributor_label_plural#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
				</cfquery>
				
				<!--- D16774 8/14/08 [begin] --->
				<!--- B.) Let's idemtify our new Program Letter ID... --->
				<!---
				<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
					SELECT  MAX(Program_Letters_ID) AS new_letter_id
					FROM 	Program_Letters
					WHERE	deleted = 0
				</cfquery>
				--->
				<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
				<!--- D16774 8/14/08 [end] --->
 
				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
        <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
				<!--- For PDF Letters, Call "generate_program_pdf" --->
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    oAppSettings="#appsettings#"	
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#"
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    claimRateDate = "#url.claim_rate_date#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#"
                    watermark_image="#variables.watermark_image#">

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#" 
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#">

			<!--- D16774 8/14/08 [begin] --->
			<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
			<!---
            <cfquery name="qUpdateXML" datasource="#application.datasource#">
                UPDATE	Program_Letters
                SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
                WHERE 	Program_Letters_ID = #variables.currentLetterID#
            </cfquery> 
			--->
            <cfinvoke 
                    component="#application.oLetterManager#" 
                    method="updateLetterXML"
                    program_letter_id="#variables.currentLetterID#"
                    sProgramLetterXML="#trim(request.sProgramLetterXML)#">
            		<!--- D16774 8/14/08 [end] --->
            		
		<!--- one distributor per letter --->
		<cfelseif getLetterSettings.Opr_Letter_Settings EQ 1>
	        <cfloop query="variables.qProgramAllDistributorInitial">

	      	<!--- 	================================================
					==== Operator 2 of 6 (Multi Oper & 1 Dist)====
					================================================	--->
	          <!--- what type of letter are we creating RIGHT NOW --->
	          <cfset variables.abbreviation = "opr">
	          
	          <!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
	          <cfinclude template="doc_modules/inc_init_vars.cfm">
	          <!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->

  		      <cfset variables.lsDistributorNames = variables.qProgramAllDistributorInitial.Name>
	          <cfset variables.lsDistributorIDs = variables.qProgramAllDistributorInitial.contract_distributors_id>
	    	  <cfif appSettings.getlettersavailable() eq 2>
				<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allOperators_#variables.qProgramAllDistributorInitial.Name#_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
			  <cfelse>		
	    		  <cfset variables.nameformat = LetterName("#contract_number#_allOperators_#variables.qProgramAllDistributorInitial.Name#_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
	    	  </cfif>
	          <cfset variables.relative_url = replace(opr_path,'\','/','all')>
	          <cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
			  <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
	          <cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
	          <cfset variables.html_file_path = lCase(variables.html_file_path)>
		
						<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
						XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
						XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	
					<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
					<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
	                  INSERT INTO	Program_Letters
	                  (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
	                  values
	                  (#CSL_Contract_Main_ID#,1,'#variables.nameformat#','#variables.html_file_path#',
	                  'All #application.returned_customer_setting.operator_label_plural#',
	                  '#lsDistributorNames#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
	        </cfquery>
	
					<!--- D16774 8/14/08 [begin] --->
					<!--- B.) Let's idemtify our new Program Letter ID... --->
					<!---
					<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
						SELECT  	MAX(Program_Letters_ID) AS new_letter_id
						FROM 			Program_Letters
						WHERE			deleted = 0
					</cfquery>
					--->
					  <cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
					  <!--- D16774 8/14/08 [end] --->
	
					<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->  
					<!--- For PDF Letters, Call "generate_program_pdf" --->
	                <cf_generate_program_pdf
	                    bAddcustomerproductnumbers="0"
	                    bLetterDisplayFreight="#url.freightpage#"
	                    bIncludeVolumePage="#url.volumepage#"
	                    bInsertWatermark="#url.watermark#"
	                    CMID="#CSL_Contract_Main_ID#"
	                    customerFreightUom="#url.freightuom#"
	                    file_name="#variables.nameformat#"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#"
	                    lsOperatorNames="#variables.lsOperatorNames#" 
	                    lsOperatorIDs="#variables.lsOperatorIDs#" 
	                    oAppSettings="#appsettings#"	
	                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
	                    qGetLetterSettings="#getlettersettings#"
	                    qGetProgramDetails="#getprogramdetails#"
	                    qGetTemplateSettings="#gettemplatesettings#"
	                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"  
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"   
	                    claimRateDate = "#url.claim_rate_date#"
                    	relative_path="#opr_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
	                    template_name="#variables.template_name#"
	                    watermark_image="#variables.watermark_image#">
	
	                <cf_generate_program_xml
	                    bAddcustomerproductnumbers="0"
	                    bLetterDisplayFreight="#url.freightpage#"
	                    bIncludeVolumePage="#url.volumepage#"
	                    bInsertWatermark="#url.watermark#"
	                    CMID="#CSL_Contract_Main_ID#"
	                    customerFreightUom="#url.freightuom#"
	                    file_name="#variables.nameformat#"
	                    prior_program_letter_id="0"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#"
	                    lsOperatorNames="#variables.lsOperatorNames#"
	                    lsOperatorIDs="#variables.lsOperatorIDs#"  
	                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"  
	                    qProgramGrowth="#variables.qProgramGrowthInitial#"
	                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
	                    relative_path="#opr_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#">	
	
				<!--- D16774 8/14/08 [begin] --->
				<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
				<!---
	            <cfquery name="qUpdateXML" datasource="#application.datasource#">
	                UPDATE	Program_Letters
	                SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
	                WHERE 	Program_Letters_ID = #variables.currentLetterID#
	            </cfquery>
				--->
	            <cfinvoke 
	                    component="#application.oLetterManager#" 
	                    method="updateLetterXML"
	                    program_letter_id="#variables.currentLetterID#"
	                    sProgramLetterXML="#trim(request.sProgramLetterXML)#">
	            		<!--- D16774 8/14/08 [end] --->
	
	        </cfloop>
	        
    <!--- 	================================================
		==== Operator 3 of 6 (Multi Oper & No Dist)====
		================================================	--->
		<cfelseif getLetterSettings.Opr_Letter_Settings EQ 3>
			<cfif appSettings.getlettersavailable() eq 2>
				<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allOperators_noDistributors_")>
			<cfelse>	
	  		    <cfset variables.nameformat = LetterName("#contract_number#_allOperators_noDistributors_")>
	  		</cfif>
    			<cfset variables.relative_url = replace(opr_path,'\','/','all')>
	        <cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
	        <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
	        <cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
	        <cfset variables.html_file_path = lCase(variables.html_file_path)>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
         
				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->

					<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

				<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
				<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
				INSERT INTO	Program_Letters
				(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
				values
				(#CSL_Contract_Main_ID#,1,'#variables.nameformat#','#variables.html_file_path#',
				'All #application.returned_customer_setting.operator_label_plural#',
				'No #application.returned_customer_setting.distributor_label_plural#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
				</cfquery>
				
				<!--- D16774 8/14/08 [begin] --->
				<!--- B.) Let's idemtify our new Program Letter ID... --->
				<!---
				<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
					SELECT  MAX(Program_Letters_ID) AS new_letter_id
					FROM 	Program_Letters
					WHERE	deleted = 0
				</cfquery>
				--->
				<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
				<!--- D16774 8/14/08 [end] --->

  				<!--- Set lsDistributorNames and lsDistributorIDs to blank and initialize 
  				a blank query for "qProgramDistributor"
  				--->
				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
					
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->
			<cfif appSettings.getlettersavailable() eq 2>
				<cf_generate_program_pdf_html
                    CMID="#CSL_Contract_Main_ID#"
                    file_name="#variables.nameformat#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    oAppSettings="#appsettings#"	
                    preferred_fontFamily="#variables.preferred_fontFamily#"
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#">
			<cfelse>
				<!--- For PDF Letters, Call "generate_program_pdf" --->										
				<cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    oAppSettings="#appsettings#"	
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#"
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    claimRateDate = "#url.claim_rate_date#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#"
                    watermark_image="#variables.watermark_image#">
			</cfif>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#" 
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#">

			<!--- D16774 8/14/08 [begin] --->
			<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
			<!---
            <cfquery name="qUpdateXML" datasource="#application.datasource#">
                UPDATE	Program_Letters
                SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
                WHERE 	Program_Letters_ID = #variables.currentLetterID#
            </cfquery> 
			--->

            <cfinvoke 
                    component="#application.oLetterManager#" 
                    method="updateLetterXML"
                    program_letter_id="#variables.currentLetterID#"
                    sProgramLetterXML="#trim(request.sProgramLetterXML)#">
            		<!--- D16774 8/14/08 [end] --->
		</cfif> 
      
    <cfelseif getLetterSettings.Operator_Letter_Type EQ 1>
		<cfloop query="variables.qProgramOperatorInitial">
	
			<!--- what type of letter are we creating RIGHT NOW --->
			<cfset variables.abbreviation = "opr">
			
			<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
			<cfinclude template="doc_modules/inc_init_vars.cfm">
			<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
			
			<cfset variables.lsOperatorNames = variables.qProgramOperatorInitial.Operator_Name>
			<cfset variables.lsOperatorIDs = variables.qProgramOperatorInitial.operator_id>
			
			<!--- All distributors --->
			<cfif getLetterSettings.Opr_letter_settings EQ 2>                 
	      	<!--- 	============================================
					==== Operator 4 of 6 (1 Oper & All Dist)====
					============================================	--->
	
				<cfset variables.lsDistributorNames = valueList(variables.qProgramAllDistributorInitial.Name,", ")>
				<cfset variables.lsDistributorIDs = valueList(variables.qProgramAllDistributorInitial.contract_distributors_id,",")>
				<cfif appSettings.getlettersavailable() eq 2>
					<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(lsOperatorNames)#_allDistributors_")>
				<cfelse>
					<cfset variables.nameformat = LetterName("#contract_number#_#trim(lsOperatorNames)#_allDistributors_")>   <!---25704--->
				</cfif>
				<cfset variables.relative_url = replace(opr_path,'\','/','all')>
				<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
				<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
				<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
				<cfset variables.html_file_path = lCase(variables.html_file_path)>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
			
				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->

					<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

				<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
				<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
					INSERT INTO	Program_Letters
					(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
					values
					(#CSL_Contract_Main_ID#,1,'#variables.nameformat#','#variables.html_file_path#','#lsOperatorNames#',
					'All #application.returned_customer_setting.distributor_label_plural#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
				</cfquery>
			
				<!--- D16774 8/14/08 [begin] --->
				<!--- B.) Let's idemtify our new Program Letter ID... --->
				<!---
					<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
						SELECT  MAX(Program_Letters_ID) AS new_letter_id
						FROM 	Program_Letters
						WHERE	Deleted = 0
					</cfquery>
				--->
				<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
				<!--- D16774 8/14/08 [end] --->

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
				<!--- For PDF Letters, Call "generate_program_pdf" --->				
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    oAppSettings="#appsettings#"
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#"
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   	
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"   	
                    claimRateDate = "#url.claim_rate_date#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#"
                    watermark_image="#variables.watermark_image#">

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   		
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#">	

				<!--- D16774 8/14/08 [begin] --->
                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
								<!---
                <cfquery name="qUpdateXML" datasource="#application.datasource#">
                    UPDATE	Program_Letters
                    SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
                    WHERE 	Program_Letters_ID = #variables.currentLetterID#
                </cfquery>
                --->
                <cfinvoke 
                   component="#application.oLetterManager#" 
                   method="updateLetterXML"
                   program_letter_id="#variables.currentLetterID#"
                   sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                   <!--- D16774 8/14/08 [end] --->
		
		<!--- multiple distributors per letter  --->
		<cfelseif getLetterSettings.Opr_Letter_Settings EQ 1>		
	            <cfloop query="variables.qProgramAllDistributorInitial">

		      	<!--- 	==========================================
						==== Operator 5 of 6 (1 Oper & 1 Dist)====
						==========================================	--->
	            
					<!--- what type of letter are we creating RIGHT NOW --->
					<cfset variables.abbreviation = "opr">
					
					<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
					<cfinclude template="doc_modules/inc_init_vars.cfm">
					<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
					<cfset variables.lsDistributorNames = variables.qProgramAllDistributorInitial.Name>
					<cfset variables.lsDistributorIDs = variables.qProgramAllDistributorInitial.contract_distributors_id>
					<cfif appSettings.getlettersavailable() eq 2>
						<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(lsOperatorNames)#_#variables.qProgramAllDistributorInitial.Name#_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)> 
					<cfelse>		
						<cfset variables.nameformat = LetterName("#contract_number#_#trim(lsOperatorNames)#_#variables.qProgramAllDistributorInitial.Name#_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>   <!---25704--->
					</cfif>	
					<cfset variables.relative_url = replace(opr_path,'\','/','all')>
					<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
					<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
					<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
					<cfset variables.html_file_path = lCase(variables.html_file_path)>

					<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->


					<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	
					<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
					<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
					    INSERT INTO	Program_Letters
					    (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
					    values
					    (#CSL_Contract_Main_ID#,1,'#variables.nameformat#','#variables.html_file_path#',
					    '#lsOperatorNames#','#lsDistributorNames#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
					</cfquery>

					<!--- D16774 8/14/08 [begin] --->
					<!--- B.) Let's idemtify our new Program Letter ID... --->
					<!---
						<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
							SELECT  	MAX(Program_Letters_ID) AS new_letter_id
							FROM 			Program_Letters
							WHERE			deleted = 0
						</cfquery>
					                  --->
					<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
					<!--- D16774 8/14/08 [end] --->
	
					<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? ---> 
					<!--- For PDF Letters, Call "generate_program_pdf" --->						
	                <cf_generate_program_pdf
	                    bAddcustomerproductnumbers="0"
	                    bLetterDisplayFreight="#url.freightpage#"
	                    bIncludeVolumePage="#url.volumepage#"
	                    bInsertWatermark="#url.watermark#"
	                    CMID="#CSL_Contract_Main_ID#"
	                    customerFreightUom="#url.freightuom#"
	                    file_name="#variables.nameformat#"
	                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#"
	                    lsOperatorNames="#variables.lsOperatorNames#"
	                    lsOperatorIDs="#variables.lsOperatorIDs#"  
	                    oAppSettings="#appsettings#"
	                   <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
	                    qGetLetterSettings="#getlettersettings#"
	                    qGetProgramDetails="#getprogramdetails#"
	                    qGetTemplateSettings="#gettemplatesettings#"
	                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"   
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"   
	                    claimRateDate = "#url.claim_rate_date#"
                    	relative_path="#opr_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
	                    template_name="#variables.template_name#"
	                    watermark_image="#variables.watermark_image#">
	
	                <cf_generate_program_xml
	                    bAddcustomerproductnumbers="0"
	                    bLetterDisplayFreight="#url.freightpage#"
	                    bIncludeVolumePage="#url.volumepage#"
	                    bInsertWatermark="#url.watermark#"
	                    CMID="#CSL_Contract_Main_ID#"
	                    customerFreightUom="#url.freightuom#"
	                    file_name="#variables.nameformat#"
	                    prior_program_letter_id="0"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#"
	                    lsOperatorNames="#variables.lsOperatorNames#"
	                    lsOperatorIDs="#variables.lsOperatorIDs#" 
	                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"   	
	                    qProgramGrowth="#variables.qProgramGrowthInitial#"
	                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
	                    relative_path="#opr_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#" 
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#">		
	
					<!--- D16774 8/14/08 [begin] --->
					<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
					<!---
		            <cfquery name="qUpdateXML" datasource="#application.datasource#">
		                UPDATE	Program_Letters
		                SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
		                WHERE 	Program_Letters_ID = #variables.currentLetterID#
		            </cfquery>
					--->
		            <cfinvoke 
	                    component="#application.oLetterManager#" 
	                    method="updateLetterXML"
	                    program_letter_id="#variables.currentLetterID#"
	                    sProgramLetterXML="#trim(request.sProgramLetterXML)#">
	            		<!--- D16774 8/14/08 [end] --->
	
	            </cfloop>

		<!--- 	================================================
		==== Operator 6 of 6 (1 Oper & No Dist)====
		================================================	--->
		<cfelseif getLetterSettings.Opr_Letter_Settings EQ 3>
			<cfif appSettings.getlettersavailable() eq 2>
				<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(lsOperatorNames)#_noDistributors_")>
			<cfelse>   
        		<cfset variables.nameformat = LetterName("#contract_number#_#trim(lsOperatorNames)#_noDistributors_")>   <!---25704--->
        	</cfif>
				<cfset variables.relative_url = replace(opr_path,'\','/','all')>
				<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
				<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
				<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
				<cfset variables.html_file_path = lCase(variables.html_file_path)>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
			
				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->


					<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

				<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
				<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
					INSERT INTO	Program_Letters
					(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
					values
					(#CSL_Contract_Main_ID#,1,'#variables.nameformat#','#variables.html_file_path#','#lsOperatorNames#',
					'No #application.returned_customer_setting.distributor_label_plural#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
				</cfquery>
			
				<!--- D16774 8/14/08 [begin] --->
				<!--- B.) Let's idemtify our new Program Letter ID... --->
				<!---
					<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
						SELECT  MAX(Program_Letters_ID) AS new_letter_id
						FROM 	Program_Letters
						WHERE	Deleted = 0
					</cfquery>
				--->
				<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
				<!--- D16774 8/14/08 [end] --->

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->				
			<cfif appSettings.getlettersavailable() eq 2>
				<cf_generate_program_pdf_html
                    CMID="#CSL_Contract_Main_ID#"
                    file_name="#variables.nameformat#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    oAppSettings="#appsettings#"
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#">
			<cfelse>
				<!--- For PDF Letters, Call "generate_program_pdf" --->		
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    oAppSettings="#appsettings#"
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#"
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   	
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"   	
                    claimRateDate = "#url.claim_rate_date#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#"
                    watermark_image="#variables.watermark_image#">
			</cfif>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"  
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#opr_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#">	

				<!--- D16774 8/14/08 [begin] --->
                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
								<!---
                <cfquery name="qUpdateXML" datasource="#application.datasource#">
                    UPDATE	Program_Letters
                    SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
                    WHERE 	Program_Letters_ID = #variables.currentLetterID#
                </cfquery>
                --->
                <cfinvoke 
                   component="#application.oLetterManager#" 
                   method="updateLetterXML"
                   program_letter_id="#variables.currentLetterID#"
                   sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                   <!--- D16774 8/14/08 [end] --->
          	</cfif>
		</cfloop>
	</cfif>
</cfif>
<!--- =================================================================================
==================================== OPERATOR [end] ===================================
================================================================================== --->

<!--- =================================================================================
==================================== DISTRIBUTOR [begin] ==============================
================================================================================== --->	 
<cfif getLetterSettings.Letter_Type EQ 2 or  getLetterSettings.Letter_Type EQ 3>
	<cfset variables.template_name = company_name & ' ' & appSettings.getDistributorLetterName()>
	<!--- <cfset LetterManager.deleteLetters(CSL_Contract_Main_ID,2)> --->

	<cfif getLetterSettings.Distributor_Letter_Type EQ 2>

<!--- Dev Note: Milan (20639). When the user wants to to generate multiple distributors per letter,
			Just delete all existing distributor letter(s), before creating new letter(s).
--->
<!---				<cfinvoke 
---					component="#application.oLetterManager#" 
---					method="deleteAllProgramPDFLettersInDBandFile"
---					program_id="#CSL_Contract_Main_ID#"
---					check_distributor="1">
--->		<!--- what type of letter are we creating RIGHT NOW --->
		<cfset variables.abbreviation = "dis">
		
		<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
		<cfinclude template="doc_modules/inc_init_vars.cfm">
		<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
		
		<cfset variables.lsDistributorNames = valueList(variables.qProgramDistributorInitial.Name,", ")>
		<cfset variables.lsDistributorIDs = valueList(variables.qProgramDistributorInitial.contract_distributors_id,",")>
		
		<cfif getLetterSettings.Dis_letter_settings EQ 2>
		 <!--- 	=================================================
				=== Distributor 1 of 4 (Multi Dist & All Oper)===
				=================================================	--->
				
			<cfset variables.lsOperatorNames = valueList(variables.qProgramOperatorInitial.Operator_Name,", ")>
			<cfset variables.lsOperatorIDs = valueList(variables.qProgramOperatorInitial.operator_id,",")>
			<cfif appSettings.getlettersavailable() eq 2>
				<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allDistributors_allOperators_")>  
			<cfelse>
				<cfset variables.nameformat = LetterName("#contract_number#_allDistributors_allOperators_")>  <!---25704--->
			</cfif>	
			<cfset variables.relative_url = replace(dis_path,'\','/','all')>
			<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
			<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
			<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
			<cfset variables.html_file_path = lCase(variables.html_file_path)>

			<cfquery name="getOperatorCount" datasource="#application.datasource#">
			      SELECT COUNT(BSA_Operator_ID) As OperatorNum
			      FROM Contract_Operators
			      WHERE Contract_Main_ID = '#CSL_Contract_Main_ID#'
			      AND deleted = 0
			  </cfquery>

			<!--- If there is only one operator in the program, show the operator name, else 'All Operators' --->
			<cfif getOperatorCount.OperatorNum eq 1>
				<cfset OperatorName = '#variables.lsOperatorNames#'>
			<cfelse>
				<cfset OperatorName = 'All #application.returned_customer_setting.operator_label_plural#'>
			</cfif>

      		<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
					
				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed?          --->
		
					<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

			<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
            <cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
                INSERT INTO	Program_Letters
                (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
                values
                (#CSL_Contract_Main_ID#,2,'#variables.nameformat#','#variables.html_file_path#',
                '#OperatorName#',
                'All #application.returned_customer_setting.distributor_label_plural#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
             </cfquery>

			<!--- D16774 8/14/08 [begin] --->
			<!--- B.) Let's idemtify our new Program Letter ID... --->
			<!---
				<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
				SELECT  	MAX(Program_Letters_ID) AS new_letter_id
				FROM 			Program_Letters
				WHERE			deleted = 0
				</cfquery>
			--->
			<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
			<!--- D16774 8/14/08 [end] --->

			<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
			<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->   		
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->				
			<cfif appSettings.getlettersavailable() eq 2>
			 <cf_generate_program_pdf_html
				CMID="#CSL_Contract_Main_ID#"
				file_name="#variables.nameformat#"
				lsContractMainIDs="#List_Of_Contract_Main_IDs#"
				current_program_letter_id="#variables.currentLetterID#"
				lsDistributorNames="#variables.lsDistributorNames#"
				lsDistributorIDs="#variables.lsDistributorIDs#"
				lsOperatorNames="#variables.lsOperatorNames#"
				lsOperatorIDs="#variables.lsOperatorIDs#" 
				oAppSettings="#appsettings#"
				<!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
				qGetLetterSettings="#getlettersettings#"
				qGetProgramDetails="#getprogramdetails#"
				qGetTemplateSettings="#gettemplatesettings#"
				qProgramClause="#variables.qProgramClauseInitial#"
				qProgramDistributor="#variables.qProgramDistributorInitial#"
				qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
				qProgramLumpSum="#variables.qProgramLumpSumInitial#"
				qProgramOperator="#variables.qProgramOperatorInitial#"	
				qProgramRebate="#variables.qProgramRebateInitial#"  
				relative_path="#dis_path#"
				stPDFBodyInfo="#variables.stPDFBodyInfo#"
				stPDFEndInfo="#variables.stPDFEndInfo#"
				stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
				stPDFIntroInfo="#variables.stPDFIntroInfo#"
				template_name="#variables.template_name#">
			<cfelse>
			 <!--- For PDF Letters, Call "generate_program_pdf" --->
			 <cf_generate_program_pdf
				bAddcustomerproductnumbers="0"
				bLetterDisplayFreight="#url.freightpage#"
				bIncludeVolumePage="#url.volumepage#"
				bInsertWatermark="#url.watermark#"
				CMID="#CSL_Contract_Main_ID#"
				customerFreightUom="#url.freightuom#"
				file_name="#variables.nameformat#"
				lsContractMainIDs="#List_Of_Contract_Main_IDs#"
				current_program_letter_id="#variables.currentLetterID#"
				lsDistributorNames="#variables.lsDistributorNames#"
				lsDistributorIDs="#variables.lsDistributorIDs#"
				lsOperatorNames="#variables.lsOperatorNames#"
				lsOperatorIDs="#variables.lsOperatorIDs#" 
				oAppSettings="#appsettings#"
				<!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
				qGetLetterSettings="#getlettersettings#"
				qGetProgramDetails="#getprogramdetails#"
				qGetTemplateSettings="#gettemplatesettings#"
				qProgramBidRequest="#variables.qProgramBidRequestInitial#"
				qProgramClause="#variables.qProgramClauseInitial#"
				qProgramDistributor="#variables.qProgramDistributorInitial#"
				qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
				qProgramLumpSum="#variables.qProgramLumpSumInitial#"
				qProgramOperator="#variables.qProgramOperatorInitial#"	
				qProgramRebate="#variables.qProgramRebateInitial#" 
				qProgramGrowth="#variables.qProgramGrowthInitial#"
				qProgramClaimRates="#variables.qProgramClaimRatesReport#"  
				claimRateDate = "#url.claim_rate_date#"
				relative_path="#dis_path#"
				stPDFBodyInfo="#variables.stPDFBodyInfo#"
				stPDFEndInfo="#variables.stPDFEndInfo#"
				stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
				stPDFIntroInfo="#variables.stPDFIntroInfo#"
				template_name="#variables.template_name#"
				watermark_image="#variables.watermark_image#">
			</cfif>

			<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
			<cf_generate_program_xml
				bAddcustomerproductnumbers="0"
				bLetterDisplayFreight="#url.freightpage#"
				bIncludeVolumePage="#url.volumepage#"
				bInsertWatermark="#url.watermark#"
				CMID="#CSL_Contract_Main_ID#"
				customerFreightUom="#url.freightuom#"
				file_name="#variables.nameformat#"
				prior_program_letter_id="0"
				current_program_letter_id="#variables.currentLetterID#"
				lsDistributorNames="#variables.lsDistributorNames#"
				lsDistributorIDs="#variables.lsDistributorIDs#"
				lsOperatorNames="#variables.lsOperatorNames#"
				lsOperatorIDs="#variables.lsOperatorIDs#"
				qProgramBidRequest="#variables.qProgramBidRequestInitial#"
				qProgramClause="#variables.qProgramClauseInitial#"
				qProgramDistributor="#variables.qProgramDistributorInitial#"
				qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
				qProgramLumpSum="#variables.qProgramLumpSumInitial#"
				qProgramOperator="#variables.qProgramOperatorInitial#"	
				qProgramRebate="#variables.qProgramRebateInitial#" 
				qProgramGrowth="#variables.qProgramGrowthInitial#"
				qProgramClaimRates="#variables.qProgramClaimRatesReport#"
				relative_path="#dis_path#"
				stPDFBodyInfo="#variables.stPDFBodyInfo#" 
				stPDFEndInfo="#variables.stPDFEndInfo#"
				stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
				stPDFIntroInfo="#variables.stPDFIntroInfo#">	

			<!--- D16774 8/14/08 [begin] --->
			<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
			<!---
            <cfquery name="qUpdateXML" datasource="#application.datasource#">
                UPDATE	Program_Letters
                SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
                WHERE 	Program_Letters_ID = #variables.currentLetterID#
            </cfquery>
			--->
            <cfinvoke 
				component="#application.oLetterManager#" 
				method="updateLetterXML"
				program_letter_id="#variables.currentLetterID#"
				sProgramLetterXML="#trim(request.sProgramLetterXML)#">
				<!--- D16774 8/14/08 [end] --->

		<cfelse>

			<cfloop query="variables.qProgramOperatorInitial">
			
			 <!--- 	===============================================
					=== Distributor 2 of 4 (Multi Dist & 1 Oper)===
					===============================================	--->
        
				<!--- what type of letter are we creating RIGHT NOW --->
				<cfset variables.abbreviation = "dis">
				
				<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
				<cfinclude template="doc_modules/inc_init_vars.cfm">
				<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->

				<cfset variables.lsOperatorNames = variables.qProgramOperatorInitial.Operator_Name>
				<cfset variables.lsOperatorIDs = variables.qProgramOperatorInitial.operator_id>
				<cfif appSettings.getlettersavailable() eq 2>
					<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allDistributors_#variables.qProgramOperatorInitial.Operator_Name#_")>
				<cfelse>		
					<cfset variables.nameformat = LetterName("#contract_number#_allDistributors_#variables.qProgramOperatorInitial.Operator_Name#_")>
				</cfif>
				<cfset variables.relative_url = replace(dis_path,'\','/','all')>
				<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
				<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
				<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
				<cfset variables.html_file_path = lCase(variables.html_file_path)>

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->

				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed?  --->


				<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
				XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

				<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
				<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
                     INSERT INTO	Program_Letters
                     (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by,Claim_Rates_Date)
                     values
                     (#CSL_Contract_Main_ID#,2,'#variables.nameformat#','#variables.html_file_path#',
                     '#trim(lsOperatorNames)#','All #application.returned_customer_setting.distributor_label_plural#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
                 </cfquery>

				<!--- D16774 8/14/08 [begin] --->
                <!--- B.) Let's idemtify our new Program Letter ID... --->
						<!---
					<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
					SELECT  	MAX(Program_Letters_ID) AS new_letter_id
					FROM 			Program_Letters
					WHERE			deleted = 0
					</cfquery>
                --->
                <cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
                <!--- D16774 8/14/08 [end] --->

				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed?  --->           
			<!--- For PDF Letters, Call "generate_program_pdf_html" --->
			<cfif appSettings.getlettersavailable() eq 2>
			    <cf_generate_program_pdf_html
                    CMID="#CSL_Contract_Main_ID#"
                    file_name="#variables.nameformat#"
                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#" 
                    oAppSettings="#appsettings#"
                   <!----preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#" 
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"  
                    relative_path="#dis_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#">
			<cfelse>
				<!--- For PDF Letters, Call "generate_program_pdf" --->					
                 <cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#" 
                    oAppSettings="#appsettings#"
                   <!----preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#" 
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"  
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    claimRateDate = "#url.claim_rate_date#"
                    relative_path="#dis_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#"
                    watermark_image="#variables.watermark_image#">
		</cfif>
				<!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#" 
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramDistributorInitial#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#dis_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#">	

				<!--- D16774 8/14/08 [begin] --->
				<!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
				<!---
	            <cfquery name="qUpdateXML" datasource="#application.datasource#">
	                UPDATE	Program_Letters
	                SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
	                WHERE 	Program_Letters_ID = #variables.currentLetterID#
	            </cfquery>
				--->
	            <cfinvoke 
                    component="#application.oLetterManager#" 
                    method="updateLetterXML"
                    program_letter_id="#variables.currentLetterID#"
                    sProgramLetterXML="#trim(request.sProgramLetterXML)#">							
            		<!--- D16774 8/14/08 [end] --->

			</cfloop>
		</cfif>
		
	<cfelseif getLetterSettings.Distributor_Letter_Type EQ 1>

		<cfloop query="variables.qProgramDistributorInitial">

			<!--- Dev Note: KAL; D17147: Letters show all distributors when select one distributor per letter
				  Both the Distributors where begin passed in each iterator of the operator	 
			--->

			<cfquery name="variables.qProgramCurrentDistributor"  datasource="#application.datasource#">
				SELECT 	*
				FROM 	##TMP_qProgramDistributorInfo
				WHERE	BSA_FOODSERVICE_CUSTOMERS_ID = '#trim(qProgramDistributorInitial.BSA_FOODSERVICE_CUSTOMERS_ID[currentRow])#'
				AND	 	CONTRACT_DISTRIBUTORS_ID = #qProgramDistributorInitial.CONTRACT_DISTRIBUTORS_ID[currentRow]#
			</cfquery>
			<!--- End Note: KAL; D17147: Letters show all distributors when select one distributor per letter --->

    
			<!--- what type of letter are we creating RIGHT NOW --->
			<cfset variables.abbreviation = "dis">
				
			<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
			<cfinclude template="doc_modules/inc_init_vars.cfm">					
			<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
		
			<cfset variables.lsDistributorNames = variables.qProgramDistributorInitial.Name>
      		<cfset variables.lsDistributorIDs = variables.qProgramDistributorInitial.contract_distributors_id>
			<cfset dist_id = variables.qProgramDistributorInitial.BSA_Foodservice_Customers_id>

	<!--- Dev Note: Milan (20639). When the user wants to to generate one distributor per letter. Do the following:
				a) If we already had a letter with multiple distributors before, delete it before generating new letter(s).
				OR
				b) If we already had one distributor per letter before, Just delete and recreate the letters for the requested distributors.
					 Leave the other distributor letters untouched.
	--->					
<!---				<cfinvoke 
---					component="#application.oLetterManager#" 
---					method="deleteAllProgramPDFLettersInDBandFile"
---					program_id="#CSL_Contract_Main_ID#"
---					distributor_id="#dist_id#">
--->
			<cfif getLetterSettings.Dis_letter_settings EQ 2>
			 <!--- 	=============================================
					=== Distributor 3 of 4 (1 Dist & All Oper)===
					=============================================	--->
					
				<cfset lsOperatorNames = valueList(variables.qProgramOperatorInitial.Operator_Name,", ")>
				<cfset variables.lsOperatorIDs = valueList(variables.qProgramOperatorInitial.operator_id,",")>
				<cfif appSettings.getlettersavailable() eq 2>
					<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(lsDistributorNames)#_allOperators_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)> 
				<cfelse>		
					<cfset variables.nameformat = LetterName("#contract_number#_#trim(lsDistributorNames)#_allOperators_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>  <!---25704--->
				</cfif>
				<cfset variables.relative_url = replace(dis_path,'\','/','all')>
				<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
				<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
				<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
				<cfset variables.html_file_path = lCase(variables.html_file_path)>

				<cfquery name="getOperatorCount" datasource="#application.datasource#">
				      SELECT COUNT(BSA_Operator_ID) As OperatorNum
				      FROM Contract_Operators
				      WHERE Contract_Main_ID = '#CSL_Contract_Main_ID#'
				      AND deleted = 0
				</cfquery>

				  <!--- If there is only one operator in the program, show the operator name, else 'All Operators' --->
				  <cfif getOperatorCount.OperatorNum eq 1>
					<cfset OperatorName = '#variables.lsOperatorNames#'>
				  <cfelse>
					<cfset OperatorName = 'All #application.returned_customer_setting.operator_label_plural#'>
				  </cfif>

				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
	
			<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

				<!---	 A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
					<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
						INSERT INTO	Program_Letters
						(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,distributor_id,created_by,Claim_Rates_Date)
						values
						(#CSL_Contract_Main_ID#,2,'#variables.nameformat#','#variables.html_file_path#',
						'#OperatorName#',
						'#trim(lsDistributorNames)#','#dist_id#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
					</cfquery>					

					<!--- D16774 8/14/08 [begin] --->
					<!--- B.) Let's idemtify our new Program Letter ID... --->
					<!---
						<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
							SELECT  	MAX(Program_Letters_ID) AS new_letter_id
							FROM 			Program_Letters
							WHERE			deleted = 0
						</cfquery>
					--->
					<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
					<!--- D16774 8/14/08 [end] --->

				<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->      
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->				
			<cfif appSettings.getlettersavailable() eq 2>
			 <cf_generate_program_pdf_html
                    CMID="#CSL_Contract_Main_ID#"
                    file_name="#variables.nameformat#"
                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"
                    oAppSettings="#appsettings#"
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#" 
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"  
                    relative_path="#dis_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#">
			<cfelse>
				<!--- For PDF Letters, Call "generate_program_pdf" --->
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="#url.custprodnum#"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#"
                    oAppSettings="#appsettings#"
                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
                    qGetLetterSettings="#getlettersettings#"
                    qGetProgramDetails="#getprogramdetails#"
                    qGetTemplateSettings="#gettemplatesettings#" 
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"  
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    claimRateDate = "#url.claim_rate_date#"
                    relative_path="#dis_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
                    template_name="#variables.template_name#"
                    watermark_image="#variables.watermark_image#">
                    <!--- D16774 qProgramDistributor="#variables.qProgramDistributorInitial#" --->
			</cfif>

                <cf_generate_program_xml
                    bAddcustomerproductnumbers="#url.custprodnum#"
                    bLetterDisplayFreight="#url.freightpage#"
                    bIncludeVolumePage="#url.volumepage#"
                    bInsertWatermark="#url.watermark#"
                    CMID="#CSL_Contract_Main_ID#"
                    customerFreightUom="#url.freightuom#"
                    file_name="#variables.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#variables.currentLetterID#"
                    lsDistributorNames="#variables.lsDistributorNames#"
                    lsDistributorIDs="#variables.lsDistributorIDs#"
                    lsOperatorNames="#variables.lsOperatorNames#"
                    lsOperatorIDs="#variables.lsOperatorIDs#" 
                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
                    qProgramClause="#variables.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
                    qProgramOperator="#variables.qProgramOperatorInitial#"	
                    qProgramRebate="#variables.qProgramRebateInitial#"   
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"   										
                    relative_path="#dis_path#"
                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
                    stPDFEndInfo="#variables.stPDFEndInfo#"
                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
                    stPDFIntroInfo="#variables.stPDFIntroInfo#">
                    <!--- D16774 qProgramDistributor="#variables.qProgramDistributorInitial#" --->	

				<!--- D16774 8/14/08 [begin] --->
                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
								<!---
                <cfquery name="qUpdateXML" datasource="#application.datasource#">
                    UPDATE	Program_Letters
                    SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
                    WHERE 	Program_Letters_ID = #variables.currentLetterID#
                </cfquery>
                --->
                <cfinvoke 
                    component="#application.oLetterManager#" 
                    method="updateLetterXML"
                    program_letter_id="#variables.currentLetterID#"
                    sProgramLetterXML="#trim(request.sProgramLetterXML)#"> 
            		<!--- D16774 8/14/08 [end] --->

			<cfelse>
		
				<cfloop query="variables.qProgramOperatorInitial">

				<!--- 	===========================================
						=== Distributor 4 of 4 (1 Dist & 1 Oper)===
						===========================================	--->

					<!--- what type of letter are we creating RIGHT NOW --->
					<cfset variables.abbreviation = "dis">
					
					<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
					<cfinclude template="doc_modules/inc_init_vars.cfm">
					<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->
					
					<cfset variables.lsOperatorNames = variables.qProgramOperatorInitial.Operator_Name>
					<cfset variables.lsOperatorIDs = variables.qProgramOperatorInitial.operator_id>
					<cfif appSettings.getlettersavailable() eq 2>
						<cfset variables.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(lsDistributorNames)#_#variables.qProgramOperatorInitial.Operator_Name#_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
					<cfelse>	
						<cfset variables.nameformat = LetterName("#contract_number#_#trim(lsDistributorNames)#_#variables.qProgramOperatorInitial.Operator_Name#_",variables.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
					</cfif>	
					<cfset variables.relative_url = replace(dis_path,'\','/','all')>
					<cfset variables.html_file_path_string = application.doc_mapping & variables.relative_url & url.CMID & "/" & variables.nameformat & ".htm">
			<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
					<cfset variables.html_file_path = expandPath(variables.html_file_path_string)>
					<cfset variables.html_file_path = lCase(variables.html_file_path)>

					<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
	
       				<!--- 	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
							XXX ACTION: We will ultimately be reading and writing the XML to & from the DB instead of a written file. XXX
							XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
       
					<!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
					<cfquery name="qInsertLetterSettings" datasource="#application.datasource#">
						INSERT INTO	Program_Letters
						(Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,distributor_id,created_by,Claim_Rates_Date)
						values
						(#CSL_Contract_Main_ID#,2,'#variables.nameformat#','#variables.html_file_path#',
						'#trim(lsOperatorNames)#','#trim(lsDistributorNames)#','#dist_id#','#user_id#',<cfif bShowClaimRateDate> '#url.claim_rate_date#'<cfelse>null</cfif>)
					</cfquery>
				
					<!--- D16774 8/14/08 [begin] --->
					<!--- B.) Let's idemtify our new Program Letter ID... --->
					<!---
					<cfquery name="qGetCurrentProgramLetterID" datasource="#application.datasource#">
						SELECT  MAX(Program_Letters_ID) AS new_letter_id
						FROM 	Program_Letters
						WHERE	deleted = 0
					</cfquery>
					 --->
					<cfset variables.currentLetterID = application.oLetterManager.getLastLetterID()>
					<!--- D16774 8/14/08 [end] --->
              
					<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->    
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->
			<cfif appSettings.getlettersavailable() eq 2>
			 	<cf_generate_program_pdf_html
	                    CMID="#CSL_Contract_Main_ID#"
	                    file_name="#variables.nameformat#"
	                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#" 
	                    lsOperatorNames="#variables.lsOperatorNames#"
	                    lsOperatorIDs="#variables.lsOperatorIDs#"
	                    oAppSettings="#appsettings#"
	                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
	                    qGetLetterSettings="#getlettersettings#"
	                    qGetProgramDetails="#getprogramdetails#"
	                    qGetTemplateSettings="#gettemplatesettings#" 
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"
	                    relative_path="#dis_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
	                    template_name="#variables.template_name#">
			<cfelse>
					<!--- For PDF Letters, Call "generate_program_pdf" --->
	                <cf_generate_program_pdf
	                    bAddcustomerproductnumbers="#url.custprodnum#"
	                    bLetterDisplayFreight="#url.freightpage#"
	                    bIncludeVolumePage="#url.volumepage#"
	                    bInsertWatermark="#url.watermark#"
	                    CMID="#CSL_Contract_Main_ID#"
	                    customerFreightUom="#url.freightuom#"
	                    file_name="#variables.nameformat#"
	                    lsContractMainIDs="#List_Of_Contract_Main_IDs#"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#" 
	                    lsOperatorNames="#variables.lsOperatorNames#"
	                    lsOperatorIDs="#variables.lsOperatorIDs#"
	                    oAppSettings="#appsettings#"
	                    <!---preferred_fontFamily="#variables.preferred_fontFamily#"--->
	                    qGetLetterSettings="#getlettersettings#"
	                    qGetProgramDetails="#getprogramdetails#"
	                    qGetTemplateSettings="#gettemplatesettings#" 
	                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"  
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"
	                    claimRateDate = "#url.claim_rate_date#"
                    	relative_path="#dis_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#"
	                    template_name="#variables.template_name#"
	                    watermark_image="#variables.watermark_image#">
			</cfif>
		
                	<cf_generate_program_xml
	                    bAddcustomerproductnumbers="#url.custprodnum#"
	                    bLetterDisplayFreight="#url.freightpage#"
	                    bIncludeVolumePage="#url.volumepage#"
	                    bInsertWatermark="#url.watermark#"
	                    CMID="#CSL_Contract_Main_ID#"
	                    customerFreightUom="#url.freightuom#"
	                    file_name="#variables.nameformat#"
	                    prior_program_letter_id="0"
	                    current_program_letter_id="#variables.currentLetterID#"
	                    lsDistributorNames="#variables.lsDistributorNames#"
	                    lsDistributorIDs="#variables.lsDistributorIDs#" 
	                    lsOperatorNames="#variables.lsOperatorNames#"
	                    lsOperatorIDs="#variables.lsOperatorIDs#" 
	                    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
	                    qProgramClause="#variables.qProgramClauseInitial#"
	                    qProgramDistributor="#variables.qProgramDistributorInitial#"
	                    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
	                    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
	                    qProgramOperator="#variables.qProgramOperatorInitial#"	
	                    qProgramRebate="#variables.qProgramRebateInitial#"   
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"									
	                    relative_path="#dis_path#"
	                    stPDFBodyInfo="#variables.stPDFBodyInfo#"
	                    stPDFEndInfo="#variables.stPDFEndInfo#"
	                    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
	                    stPDFIntroInfo="#variables.stPDFIntroInfo#">	
		
					<!--- D16774 8/14/08 [begin] --->
	                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
					<!---
	                <cfquery name="qUpdateXML" datasource="#application.datasource#">
	                    UPDATE	Program_Letters
	                    SET 		Letter_xml = '#trim(request.sProgramLetterXML)#'
	                    WHERE 	Program_Letters_ID = #variables.currentLetterID#
	                </cfquery>
						--->
	            		   <cfinvoke 
	                    component="#application.oLetterManager#" 
	                    method="updateLetterXML"
	                    program_letter_id="#variables.currentLetterID#"
	                    sProgramLetterXML="#trim(request.sProgramLetterXML)#">
	           <!---   D16774 8/14/08 [end] --->
		
				</cfloop>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<!--- =================================================================================
==================================== DISTRIBUTOR [END] ================================
================================================================================== --->

<!--- =================================================================================
========================== INITIAL GENERATION OF LETTERS [end] ========================
================================================================================== --->

 </cfoutput>

	<!--- =================================================================================
	================= NOTICATION OF INITIAL GENERATION OF LETTERS [begin] =================
	================================================================================== --->
	<cfif getLetterSettings.notification_type EQ 2>
  
  	<cfoutput>
      <div align="center" onClick="javascript:ColdFusion.Window.hide('pdfGeneration')" style="background-color:##eeeeee;height:100%;width:100%;">
 <font size="1" color="Black"><b>Complete!</b></font>&nbsp;<font size="1" color="Red">[</font> &nbsp;<font size="1" color="Blue"><a href="#includeLettersFilename#?CID=#url.CMID#">View All <!--- #url.CMID# --->Program Letters</a></font>&nbsp;<font size="1" color="Red">]</font>
      </div>
    </cfoutput>
  
  	<!--- KEEP &#session.urltoken# <cflocation url="#includeLettersFilename#?CID=#url.CMID#"> --->
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
		<cfoutput>
	<cfif qgetUseremail.recordCount>
	<!--- By using "programLettersEmail=1", the logic for "from" is populated on "EmailWrapper.cfm"  --->
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
    </cfoutput>
	</cfif>
  <!--- =================================================================================
	================= NOTICATION OF INITIAL GENERATION OF LETTERS [begin] =================
	================================================================================== --->

</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="LetterName" output="true" returntype="string" 
  hint="Cleans up unfriendly characters, removes old letter using letter name prefix, appends current date-time & a fixed suffix to letter name, & returns it.">
  <cfargument name="namePrefix" type="string" required="true">
  <cfargument name="distributor_id" type="string" required="false" default="">

  <cfset var loc = StructNew()>
  <cfscript>
    loc.letterName = arguments.namePrefix;
    
    // clean up unfriendly characters
		loc.letterName = replace( replace(loc.letterName, '-', '_', 'all'), '/', '_', 'all' );
    loc.letterName = replace( replace(loc.letterName, '\', '_', 'all'), '(', '_', 'all' );
    loc.letterName = replace( replace(loc.letterName, ')', '_', 'all'), ',', '',  'all' );
    loc.letterName = replace( replace(loc.letterName, '&', '',  'all'), '.', '',  'all' );
    loc.letterName = replace( replace(loc.letterName, '''' ,'', 'all'), '##' ,'', 'all' );
    loc.letterName = replace( replace(loc.letterName, ' ', '',  'all'), "", "",  'all'	);

    loc.nameSuffix = "_system_generated";
  </cfscript>
  
  <!---remove old letter using the cleaned letter name prefix + letter name suffix --->
	<cfinvoke 
		component   = "#application.oLetterManager#" 
		method      = "deleteLettersbyName"
		program_id  = "#CSL_Contract_Main_ID#"
		letter_name = #(loc.letterName & '%' & loc.nameSuffix)#
		distributor_id = '#arguments.distributor_id#'>
  
  <!---insert current date-time into the middle of the letter name--->
  <cfreturn loc.letterName 
            & dateformat(now(),"mm_dd_yyyy") 
            & "_" 
            & timeformat(now(),"hh_mm_sstt") 
            & loc.nameSuffix>    
</cffunction>

