<cfsilent>
<!--- 
FILE:     /common_files/contracts/letters/auto_generate_gateway.cfm
FILENAME: auto_generate_gateway.cfm
CREATED:  03/31/2008 - RBL
EDITED:   08/14/2008 - RBL
EDITED:   08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This CUSTOM TAG allows the caller to submit all vars for one program id at a time and automatically generate program deal letters for that program id transparently...
--->

</cfsilent>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfswitch expression="#thisTag.executionMode#">
  
  
  <!--- let's initialize our thisTag in start mode --->
  
  <cfcase value="start">
    
    
    <!--- || These parameters are required for this template to process correctly || --->
    
    <!--- legend: if one distributor per letter, do we want cusrtomer product numbers 1=yes, 0=no --->
    <cfparam name="attributes.bAddCustomerProductNumbers" type="boolean"  default="0">
    <!--- legend: 1=for auto generated letters via scheduled tasks, 0=manually by contract main id [bAuto] --->
    <cfparam name="attributes.bAuto"                      type="boolean"  default="1">
    <!--- IF arriving here from a submitted form rather than a cfModule call... --->
    <cfparam name="attributes.bFormSubmitted"             type="boolean"  default="0">
    <cfparam name="attributes.bLetterDisplayFreight"        type="boolean"  default="0">
    <cfparam name="attributes.claimRateDate"            type="date"   default="#DateFormat(now(), 'mm/dd/yyyy')#">
    <cfparam name="attributes.bIncludeVolumePage"         type="boolean"  default="0">
    <cfparam name="attributes.bInsertWatermark"           type="boolean"  default="0">
    <!--- When we are on the last in list passed, for a return redirect [bListLast] (this logic would need to be defined in the calling page) --->
    <cfparam name="attributes.bListLast"                  type="boolean"  default="0">
    <cfparam name="attributes.contract_main_id"           type="numeric"  default="0">
    <!--- legend: lb=pounds, cs=cases [customerFreightUom] --->
    <cfparam name="attributes.customerFreightUom"         type="string"   default="lb">
    <!--- legend: 1=one distributor per distributor letter, 2=multiple distributors per distributor letter [distributor_letter_type] --->
    <cfparam name="attributes.distributor_letter_type"    type="numeric"  default="2">
    <!--- legend: 1=one operator per distributor letter, 2=all operators per distributor letter [dis_letter_settings] --->
    <cfparam name="attributes.dis_letter_settings"        type="numeric"  default="2">
    <!--- legend: 1=operator, 2=distributor, 3=both [letter_type] --->
    <cfparam name="attributes.letter_type"                type="numeric"  default="3">
    <!--- legend: 2=generate letters WITHOUT email notification [notification_type] (NOTE: notification_type MUST always be 2 here) --->
    <cfparam name="attributes.notification_type"          type="numeric"  default="2">
    <!--- legend: 1=one operator per operator letter, 2=multiple operators per operator letter [operator_letter_type] --->
    <cfparam name="attributes.operator_letter_type"       type="numeric"  default="2">
    <!--- legend: 1=one distributor per operator letter, 2=all distributors per operator letter [opr_letter_settings], 3=no distributors --->
    <cfparam name="attributes.opr_letter_settings"        type="numeric"  default="2">
    <!--- legend: default setting for timeout in seconds for the custom tag - this affects each iteration of the ct (module) but we really care about the caller --->
    <cfparam name="attributes.timeout_seconds"            type="numeric"  default="3600">

    <cfparam name="attributes.dist_id"		type="string" default="">
    <cfparam name="attributes.custprodnum"	type="boolean" default="0">
    <cfparam name="attributes.volumepage"       type="boolean" default="0">
    <cfparam name="attributes.watermark"        type="boolean" default="0">
    <cfparam name="attributes.freightpage"      type="boolean" default="0">
    <cfparam name="attributes.generateoperatorletters"      type="boolean" default="1">
    
    <!--- legend: [1 of 2] user_id required for full functionality. A valid user ID MUST be passed in... [begin] --->
    <cfparam name="attributes.user_id"            type="string" default="">
    <!--- legend: [1 of 2] user_id required for full functionality. A valid user ID MUST be passed in... [end] --->

    <!---legend: list of operator IDs to be processed (applicable to individual operator letters), if value is blank process all--->
    <cfparam name="attributes.operator_ids"           type="string" default="">    <!---25704--->
    <!---legend: list of distributor IDs to be processed (applicable to individual distributor letters), if value is blank process all--->
    <cfparam name="attributes.distributor_ids"        type="string" default="">    <!---25704--->
    <cfparam name="url.custprodnum" type="boolean" default="0">
    
    <!--- Overwrite the default values with ANY incoming ones --->
    <cfset structAppend(thisTag,attributes,true)>
    
    <cfoutput>
    <!--- we're gonna need a bigger boat... request timeout in seconds 3600=1hr wow! ltrs avg 2 min ea ---->
    <cfsetting requesttimeout="#thisTag.timeout_seconds#">
    </cfoutput>
    
    <!--- MVC V11 Tech Note: this is actually included below within the include inc_all_vars.cfm ---> 
    <cfset thisTag.LetterManager = application.oController.getObject("mvc.Models.LetterManager") />
    
    <!--- let's compile the necessary keys within a struct to pass to our LetterManager cfc maintaining legacy key names... --->
    <cfset thisTag.stLetterSettings = structNew()>
    <cfset structInsert(thisTag.stLetterSettings,'Letter_Type',thisTag.letter_type,true)>
    <cfset structInsert(thisTag.stLetterSettings,'Operator_Letter_Type',thisTag.operator_letter_type,true)>
    <cfset structInsert(thisTag.stLetterSettings,'Distributor_Letter_Type',thisTag.distributor_letter_type,true)>
    <cfset structInsert(thisTag.stLetterSettings,'Opr_Letter_Settings',thisTag.opr_letter_settings,true)>
    <cfset structInsert(thisTag.stLetterSettings,'Dis_Letter_Settings',thisTag.dis_letter_settings,true)>
    <cfset structInsert(thisTag.stLetterSettings,'notification_type',thisTag.notification_type,true)>
    <cfset structInsert(thisTag.stLetterSettings,'Addcustomerproductnumbers',thisTag.bAddCustomerProductNumbers,true)>

    <cfset oProgramData = createObject("component","components.programs.program") />
    <cfset qProgramInfo = oProgramData.getProgramInfo(thisTag.contract_main_id)>
    <cfset contract_title = replace(qProgramInfo.Contract_Title," ","_","ALL") />
    <cfset contract_title = replaceList(contract_title, "*,/,',-,(,)","_") />
    <cfset contract_title = replace(contract_title, "__","_","ALL") />
    <!--- [2 of 2] legend: program_id aka contract_main_id, structure with specific keys noted above, user_id --->
    <cfset thisTag.automatic_letter_generation_user_id = "">
    <!--- IF we STILL do NOT have a user_id at this point... --->
    
    <cfif NOT len(trim(thisTag.user_id))>
      
      <!--- get from program so we do not bomb and actually display however it will reflect responsible_user_id's string when showing... --->
      <cfset thisTag.automatic_letter_generation_user_id = thisTag.qProgramInfo.responsible_user_id[1]>
      
    <cfelse>
      
      <!--- used the actual passed_in user_id... --->
      <cfset thisTag.automatic_letter_generation_user_id = thisTag.user_id>
      
    </cfif>
    
    <cfset thisTag.LetterManager.saveLetterSettings(thisTag.contract_main_id,thisTag.stLetterSettings,thisTag.automatic_letter_generation_user_id)>
    <!--- TO DELETE request.AccessStructure.user_id --->
    
    
  </cfcase>
  
  
  <!--- let's perform our processing in end mode --->
  
  <cfcase value="end">
    
    
    <!--- Generate Letters [begin] --->
    <cfoutput>
    
    <!--- insert gen_opr_dis_ltr code [begin] --->
    
    
    <cfif thisTag.contract_main_id>
      
      
      <!--- IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
      IIIIIIIII Let's create a watermark image [begin] IIIIIIIIII
      IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII --->
      
      <!--- let's save some processing time... --->
      
      <cfif thisTag.bInsertWatermark>
        
        
        <!--- IF we already have a .jpg... --->
        
        <cfif listLast(application.appsettingsget.letters_company_logo_path,'.') EQ 'jpg'>
          
          
          <!--- use original .jpg as watermark... --->
          <cfset thisTag.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
          
          <!--- IF we originally have a .gif, convert it to a .jpg and write the image to the file system... --->  
          
        <cfelseif listLast(application.appsettingsget.letters_company_logo_path,'.') EQ 'gif'>
          
          
          <cfimage
          action="convert"
          source="#expandPath(application.appsettingsget.letters_company_logo_path)#"
          destination="#replace(expandPath(application.appsettingsget.letters_company_logo_path),'gif','jpg','all')#"
          overwrite="true">
          
          <cfset thisTag.watermark_image = replace(getFileFromPath(application.appsettingsget.letters_company_logo_path),'gif','jpg','all')>
          
          <!--- IF we originally have a .png, convert it to a .jpg and write the image to the file system... --->  
          
        <cfelseif listLast(application.appsettingsget.letters_company_logo_path,'.') EQ 'png'>
          
          
          <cfimage
          action="convert"
          source="#expandPath(application.appsettingsget.letters_company_logo_path)#"
          destination="#replace(expandPath(application.appsettingsget.letters_company_logo_path),'png','jpg','all')#"
          overwrite="true">
          
          <cfset thisTag.watermark_image = replace(getFileFromPath(application.appsettingsget.letters_company_logo_path),'png','jpg','all')>
          
          <!--- IF we have a file other than a .jpg or a .gif or it is undefined at the moment... --->  
          
        <cfelse>
          
          
          <cfset thisTag.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
          
          
        </cfif>
        
        
        
      <cfelse>
        
        
        <!--- just to be safe, but we'll never see this... --->
        <cfset thisTag.watermark_image = getFileFromPath(application.appsettingsget.letters_company_logo_path)>
        
        
      </cfif>
      
      <!--- IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
      IIIIIIIII Let's create a watermark image [end] IIIIIIIIIIII
      IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII --->
      
      <!--- the following include [inc_all_vars] wants it dished up this way, so... --->
      <cfset url.CMID = thisTag.contract_main_id>
      		
	  <!--- From approvalLeter.cfm, we do not send "dist_id" for operator and Internal letters --->
	  <cfif IsDefined("thisTag.Dist_ID")>
      		<cfset url.Dist_ID = thisTag.dist_ID>   
		   <cfif url.Dist_ID eq "">
			<!--- The CFC considers "0" as blank --->
			<cfset 	url.Dist_ID = 0>	
		   </cfif>
	  </cfif>

	    <cfif IsDefined("thisTag.custprodnum")>
		<cfset url.custprodnum = thisTag.custprodnum>
	    </cfif>

	    <cfif IsDefined("thisTag.volumepage")>
		<cfset url.volumepage = thisTag.volumepage>
	    </cfif>

	    <cfif IsDefined("thisTag.watermark")>
		<cfset url.watermark = thisTag.watermark>
	    </cfif>

	    <cfif IsDefined("thisTag.freightpage")>
		<cfset url.freightpage = thisTag.freightpage>
	    </cfif>
      
      <!--- The Deal Letters V2 ALWAYS Starts with the original data... [let's hit this once here] --->
      <cfinclude template="doc_modules/inc_all_vars.cfm">
      
      <!--- this initial logic was not intended for within a CT, but we prefer to scope. We are not dumping structs,
      so let's grab these local vars as a whole, append the thisTag scope, and be done with it :-)... --->
      <cfset structAppend(thisTag,variables,true)>
      
      <!--- set preferred fontFamily [CSS syntax] to be embedded in all pdf docs generated here...
      NOTE: [must be resident on user's client machine at time of pdf creation, then embedded] 
      Tech Note: perhaps this may be some form of app setting in future... --->
      <!--- For HTML Letter, we need "preferred_fontFamily" variable for correct font. --->
	  <cfif appSettings.getlettersavailable() eq 2>
      		<cfset thisTag.preferred_fontFamily = "Century Gothic">
	  </cfif>
           
      <!--- ================================================================================
      ========================== INITIAL GENERATION OF LETTERS [begin] =====================
      ================================================================================== --->  
      
      <!--- =================================================================================
      ==================================== OPERATOR [begin] =================================
      ================================================================================== --->
  <cfif thisTag.generateoperatorletters eq 1>    
      <cfif thisTag.getLetterSettings.Letter_Type EQ 1 or thisTag.getLetterSettings.Letter_Type EQ 3>
        
        <!--- <cfset LetterManager.deleteLetters(thisTag.contract_main_id,1)> --->
        <cfset thisTag.template_name = "#company_name# #appSettings.getOperatorLetterName()#">
        
        
        <cfif thisTag.getLetterSettings.Operator_Letter_Type EQ 2>
          
          
          <!--- what type of letter are we creating RIGHT NOW --->
          <cfset thisTag.abbreviation = "opr">
          
          <!--- the following include [inc_init_vars] wants it dished up this way, so... [1 of 8] --->
          <cfset variables.abbreviation = thisTag.abbreviation>
          
          <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
          <cfinclude template="doc_modules/inc_init_vars.cfm">
          <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
          
          <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [1 OF 8] --->
          <cfset structAppend(thisTag,variables,true)>
          
          
          
          <!--- IF we have requested Customer Product Numbers [begin] ... --->
          <!---
          <cfif thisTag.bAddCustomerProductNumbers>
            
            
            <!--- fixed_price --->
            <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
            <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
            
            <cfloop query="thisTag.qProgramFixedPriceInitial">
              
              <!--- string id --->
              <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
              
            </cfloop>
            
            <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
            <!--- bid_request --->
            <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
            <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
            
            <cfloop query="thisTag.qProgramBidRequestInitial">
              
              <!--- string id --->
              <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
              
            </cfloop>
            
            <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
            
            <!--- rebate --->
            <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
            <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
            
            <cfloop query="thisTag.qProgramRebateInitial">
              
              <!--- string id --->
              <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
              
            </cfloop>
            
            <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
            
            
          </cfif>
          --->
          <!--- IF we have requested Customer Product Numbers [end] ... --->
          
          
          
          <cfset thisTag.lsOperatorNames = valueList(thisTag.qProgramOperatorInitial.Operator_Name,", ")>
          <cfset thisTag.lsOperatorIDs = valueList(thisTag.qProgramOperatorInitial.operator_id,",")>
          
          
          <cfif thisTag.getLetterSettings.Opr_letter_settings EQ 2>
            
            
            <!--- ========================================
            ============== operator 1 of 6 (Multi Oper & All Dist) ===============
            ==========================================--->
            <cfset thisTag.lsDistributorNames = valueList(thisTag.qProgramDistributorInitial.Name,", ")>
            <cfset thisTag.lsDistributorIDs = valueList(thisTag.qProgramDistributorInitial.contract_distributors_id,",")>
            <cfif appSettings.getlettersavailable() eq 2>
              <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allOperators_allDistributors_")>
            <cfelse>
              <cfset thisTag.nameformat = LetterName("#contract_number#_allOperators_allDistributors_")>  <!---25704---> 
            </cfif>  

            <cfset thisTag.relative_url = replace(thisTag.opr_path,'\','/','all')>
            <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
            <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
            <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
            <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
            
            <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
            
            <cfset useLakebaseForthisTag_qInsertLetterSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForthisTag_qInsertLetterSettings>
	<cftry>
		<cfset application.oLakebase.insertRow("program_letters", {
			"program_id" = "#thisTag.contract_main_id#",
			"letter_type" = "1",
			"letter_name" = "#thisTag.nameformat#",
			"letter_path" = "#thisTag.html_file_path#",
			"operator_name" = "All #application.returned_customer_setting.operator_label_plural#",
			"distributor_name" = "All #application.returned_customer_setting.distributor_label_plural#",
			"created_by" = "#thisTag.automatic_letter_generation_user_id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForthisTag_qInsertLetterSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForthisTag_qInsertLetterSettings>
<cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
              
              INSERT INTO Program_Letters
              (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
              values
              (#thisTag.contract_main_id#,1,'#thisTag.nameformat#','#thisTag.html_file_path#',
              'All #application.returned_customer_setting.operator_label_plural#',
              'All #application.returned_customer_setting.distributor_label_plural#','#thisTag.automatic_letter_generation_user_id#')
            </cfquery>
</cfif>
            
            <!--- D16774 8/14/08 [begin]
            <!--- B.) Let's idemtify our new Program Letter ID... --->
            
            <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
              
              SELECT    MAX(Program_Letters_ID) AS new_letter_id
              FROM      Program_Letters
              WHERE     deleted = 0
            </cfquery>
            --->
            <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
            <!--- D16774 8/14/08 [end] --->
            
            <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
            <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
			<!--- For PDF Letters, Call "generate_program_pdf" --->
            <cf_generate_program_pdf
                bAddcustomerproductnumbers="0"
                bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                bInsertWatermark="#thisTag.bInsertWatermark#"
                CMID="#thisTag.contract_main_id#"
                customerFreightUom="#thisTag.customerFreightUom#"
                file_name="#thisTag.nameformat#"
                lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames="#thisTag.lsDistributorNames#"
                lsDistributorIDs="#thisTag.lsDistributorIDs#"
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                oAppSettings="#thisTag.appsettings#"
                <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                qGetLetterSettings="#thisTag.getlettersettings#"
                qGetProgramDetails="#thisTag.getprogramdetails#"
                qGetTemplateSettings="#thisTag.gettemplatesettings#"
                qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
               qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"   
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                relative_path="#thisTag.opr_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                template_name="#thisTag.template_name#"
                watermark_image="#thisTag.watermark_image#">
            
            <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
            <cf_generate_program_xml
                bAddcustomerproductnumbers="0"
                bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                bInsertWatermark="#thisTag.bInsertWatermark#"
                CMID="#thisTag.contract_main_id#"
                customerFreightUom="#thisTag.customerFreightUom#"
                file_name="#thisTag.nameformat#"
                prior_program_letter_id="0"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames="#thisTag.lsDistributorNames#"
                lsDistributorIDs="#thisTag.lsDistributorIDs#"
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                relative_path="#thisTag.opr_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#" 
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#">
            
            <!--- D16774 8/14/08 [begin]
            <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
            
            <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
              
              UPDATE  Program_Letters
              SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
              WHERE   Program_Letters_ID = #thisTag.currentLetterID#
            </cfquery>
            --->
           <cfinvoke 
            component="#application.oLetterManager#" 
            method="updateLetterXML"
            program_letter_id="#thisTag.currentLetterID#"
            sProgramLetterXML="#trim(request.sProgramLetterXML)#">
            <!--- D16774 8/14/08 [end] --->
            
            
          <cfelseif thisTag.getLetterSettings.Opr_letter_settings EQ 1>
            
            
            
            <cfloop query="thisTag.qProgramDistributorInitial">
              
              
              <!--- ========================================
              ============== operator 2 of 6 (Multi Oper & 1 Dist) ===============
              ==========================================--->
              
              <!--- what type of letter are we creating RIGHT NOW --->
              <cfset thisTag.abbreviation = "opr">
              
              <!--- the following include [inc_init_vars] wants it dished up this way, so... [2 of 8] --->
              <cfset variables.abbreviation = thisTag.abbreviation>
              
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
              <cfinclude template="doc_modules/inc_init_vars.cfm">
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
              
              <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [2 OF 8] --->
              <cfset structAppend(thisTag,variables,true)>
              
              
              
              
              
              <!--- IF we have requested Customer Product Numbers [begin] ... --->
              <!---
              <cfif thisTag.bAddCustomerProductNumbers>
                
                
                <!--- fixed_price --->
                <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramFixedPriceInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
                <!--- bid_request --->
                <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramBidRequestInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
                
                <!--- rebate --->
                <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramRebateInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
                
                
              </cfif>
              --->
              <!--- IF we have requested Customer Product Numbers [end] ... --->
              
              <cfset thisTag.lsDistributorNames = thisTag.qProgramAllDistributorInitial.Name>
              <cfset thisTag.lsDistributorIDs = thisTag.qProgramAllDistributorInitial.contract_distributors_id>
              <cfif appSettings.getlettersavailable() eq 2>
                  <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allOperators_#thisTag.qProgramAllDistributorInitial.Name#_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
              <cfelse>
                  <cfset thisTag.nameformat = LetterName("#contract_number#_allOperators_#thisTag.qProgramAllDistributorInitial.Name#_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>   <!---25704--->
              </cfif>

              <cfset thisTag.relative_url = replace(thisTag.opr_path,'\','/','all')>
              <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
              <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
              <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
              <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
              
              <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
              
              <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
                
                INSERT INTO Program_Letters
                (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
                values
                (#thisTag.contract_main_id#,1,'#thisTag.nameformat#','#thisTag.html_file_path#',
                'All #application.returned_customer_setting.operator_label_plural#',
                '#thisTag.lsDistributorNames#','#thisTag.automatic_letter_generation_user_id#')
              </cfquery>
              
              <!--- D16774 8/14/08 [begin]
              <!--- B.) Let's idemtify our new Program Letter ID... --->
              
              <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                
                SELECT    MAX(Program_Letters_ID) AS new_letter_id
                FROM      Program_Letters
                WHERE     deleted = 0
              </cfquery>
              --->
              <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
              <!--- D16774 8/14/08 [end] --->
              
              <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->    
			  <!--- For PDF Letters, Call "generate_program_pdf" --->
              <cf_generate_program_pdf
                  bAddcustomerproductnumbers="0"
                  bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                  bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                  bInsertWatermark="#thisTag.bInsertWatermark#"
                  CMID="#thisTag.contract_main_id#"
                  customerFreightUom="#thisTag.customerFreightUom#"
                  file_name="#thisTag.nameformat#"
                  current_program_letter_id="#thisTag.currentLetterID#"
                  lsDistributorNames="#thisTag.lsDistributorNames#"
                  lsDistributorIDs="#thisTag.lsDistributorIDs#"
                  lsOperatorNames="#thisTag.lsOperatorNames#" 
                  lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                  oAppSettings="#thisTag.appsettings#"
                  <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                  qGetLetterSettings="#thisTag.getlettersettings#"
                  qGetProgramDetails="#thisTag.getprogramdetails#"
                  qGetTemplateSettings="#thisTag.gettemplatesettings#"
                  qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                  qProgramClause="#thisTag.qProgramClauseInitial#"
                  qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                  qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                  qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                  qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                  qProgramRebate="#thisTag.qProgramRebateInitial#"   
                  qProgramGrowth="#variables.qProgramGrowthInitial#"
                  qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                  relative_path="#thisTag.opr_path#"
                  stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                  stPDFEndInfo="#thisTag.stPDFEndInfo#"
                  stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                  stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                  template_name="#thisTag.template_name#"
                  watermark_image="#thisTag.watermark_image#">
              
              <cf_generate_program_xml
                  bAddcustomerproductnumbers="0"
                  bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                  bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                  bInsertWatermark="#thisTag.bInsertWatermark#"
                  CMID="#thisTag.contract_main_id#"
                  customerFreightUom="#thisTag.customerFreightUom#"
                  file_name="#thisTag.nameformat#"
                  prior_program_letter_id="0"
                  current_program_letter_id="#thisTag.currentLetterID#"
                  lsDistributorNames="#thisTag.lsDistributorNames#"
                  lsDistributorIDs="#thisTag.lsDistributorIDs#"
                  lsOperatorNames="#thisTag.lsOperatorNames#"
                  lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                  qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                  qProgramClause="#thisTag.qProgramClauseInitial#"
                  qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                  qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                  qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                  qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                  qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                  qProgramGrowth="#variables.qProgramGrowthInitial#"
                  qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                  relative_path="#thisTag.opr_path#"
                  stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                  stPDFEndInfo="#thisTag.stPDFEndInfo#"
                  stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                  stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
              
              <!--- D16774 8/14/08 [begin]
              <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
              
              <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                
                UPDATE  Program_Letters
                SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                WHERE   Program_Letters_ID = #thisTag.currentLetterID#
              </cfquery>
              --->
              <cfinvoke 
              component="#application.oLetterManager#" 
              method="updateLetterXML"
              program_letter_id="#thisTag.currentLetterID#"
              sProgramLetterXML="#trim(request.sProgramLetterXML)#">
              <!--- D16774 8/14/08 [end] --->
              
              
            </cfloop>
            
           <!--- 	================================================
		   ==== Operator 3 of 6 (Multi Oper & No Dist)====
		   ================================================	--->
		   <cfelseif getLetterSettings.Opr_Letter_Settings EQ 3>
          <cfif appSettings.getlettersavailable() eq 2>
			       <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allOperators_noDistributors_")>
          <cfelse>
             <cfset thisTag.nameformat = LetterName("#contract_number#_allOperators_noDistributors_")> 
          </cfif> 

            <cfset thisTag.relative_url = replace(thisTag.opr_path,'\','/','all')>
            <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
            <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
            <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
            <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
            
            <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
            
            <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
              
              INSERT INTO Program_Letters
              (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
              values
              (#thisTag.contract_main_id#,1,'#thisTag.nameformat#','#thisTag.html_file_path#',
              'All #application.returned_customer_setting.operator_label_plural#',
              'No #application.returned_customer_setting.distributor_label_plural#','#thisTag.automatic_letter_generation_user_id#')
            </cfquery>
            
            <!--- D16774 8/14/08 [begin]
            <!--- B.) Let's idemtify our new Program Letter ID... --->
            
            <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
              
              SELECT    MAX(Program_Letters_ID) AS new_letter_id
              FROM      Program_Letters
              WHERE     deleted = 0
            </cfquery>
            --->
            <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
            <!--- D16774 8/14/08 [end] --->
            
			 <!--- Set lsDistributorNames and lsDistributorIDs to blank and initialize 
  				a blank query for "qProgramDistributor"
  			--->
            <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
            <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
				
		<!--- For HTML Letters, Call "generate_program_pdf_html" --->
		<cfif appSettings.getlettersavailable() eq 2>
			<cf_generate_program_pdf_html
                CMID="#thisTag.contract_main_id#"
                file_name="#thisTag.nameformat#"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames=""
                lsDistributorIDs=""
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                oAppSettings="#thisTag.appsettings#"
                <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                qGetLetterSettings="#thisTag.getlettersettings#"
                qGetProgramDetails="#thisTag.getprogramdetails#"
                qGetTemplateSettings="#thisTag.gettemplatesettings#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"   
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                relative_path="#thisTag.opr_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                template_name="#thisTag.template_name#">
		<cfelse>
			<!--- For PDF Letters, Call "generate_program_pdf" --->	
            <cf_generate_program_pdf
                bAddcustomerproductnumbers="0"
                bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                bInsertWatermark="#thisTag.bInsertWatermark#"
                CMID="#thisTag.contract_main_id#"
                customerFreightUom="#thisTag.customerFreightUom#"
                file_name="#thisTag.nameformat#"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames=""
                lsDistributorIDs=""
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                oAppSettings="#thisTag.appsettings#"
                <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                qGetLetterSettings="#thisTag.getlettersettings#"
                qGetProgramDetails="#thisTag.getprogramdetails#"
                qGetTemplateSettings="#thisTag.gettemplatesettings#"
                qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"   
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                relative_path="#thisTag.opr_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                template_name="#thisTag.template_name#"
                watermark_image="#thisTag.watermark_image#">
           </cfif>
            
            <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
            <cf_generate_program_xml
                bAddcustomerproductnumbers="0"
                bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                bInsertWatermark="#thisTag.bInsertWatermark#"
                CMID="#thisTag.contract_main_id#"
                customerFreightUom="#thisTag.customerFreightUom#"
                file_name="#thisTag.nameformat#"
                prior_program_letter_id="0"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames=""
                lsDistributorIDs=""
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                relative_path="#thisTag.opr_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#" 
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#">
            
            <!--- D16774 8/14/08 [begin]
            <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
            
            <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
              
              UPDATE  Program_Letters
              SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
              WHERE   Program_Letters_ID = #thisTag.currentLetterID#
            </cfquery>
            --->
           <cfinvoke 
            component="#application.oLetterManager#" 
            method="updateLetterXML"
            program_letter_id="#thisTag.currentLetterID#"
            sProgramLetterXML="#trim(request.sProgramLetterXML)#">
            <!--- D16774 8/14/08 [end] --->
			
          </cfif>
          
 
          
        <cfelseif thisTag.getLetterSettings.Operator_Letter_Type EQ 1>
          
          
          
          <cfloop query="thisTag.qProgramOperatorInitial">
            
            <cfset excludeThis = false>
            <!---25704 if there is a list of operator IDs to process, apply the filter--->
            <cfif Len(Trim(thisTag.operator_IDs)) 
              and not ListFindNocase(thisTag.operator_IDs, thisTag.qProgramOperatorInitial.operator_id)>
              <cfset excludeThis = true>
            </cfif>
            
            <cfif not excludeThis>
              <!--- what type of letter are we creating RIGHT NOW --->
              <cfset thisTag.abbreviation = "opr">
              
              <!--- the following include [inc_init_vars] wants it dished up this way, so... [3 of 8] --->
              <cfset variables.abbreviation = thisTag.abbreviation>
              
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
              <cfinclude template="doc_modules/inc_init_vars.cfm">
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
              
              <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [3 OF 8] --->
              <cfset structAppend(thisTag,variables,true)>
                            
              <!--- IF we have requested Customer Product Numbers [begin] ... --->
              <!---
              <cfif thisTag.bAddCustomerProductNumbers>
                
                
                <!--- fixed_price --->
                <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramFixedPriceInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
                <!--- bid_request --->
                <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramBidRequestInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
                
                <!--- rebate --->
                <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramRebateInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
                
                
              </cfif>
              --->
              <!--- IF we have requested Customer Product Numbers [end] ... --->
                                          
              <cfset thisTag.lsOperatorNames = thisTag.qProgramOperatorInitial.Operator_Name>
              <cfset thisTag.lsOperatorIDs = thisTag.qProgramOperatorInitial.operator_id>
                            
              <cfif thisTag.getLetterSettings.Opr_letter_settings EQ 2>
                
                <!--- ========================================
                ============== operator 4 of 6 (1 Oper & All Dist) ===============
                ==========================================--->
                <cfset thisTag.lsDistributorNames = valueList(thisTag.qProgramAllDistributorInitial.Name,", ")>
                <cfset thisTag.lsDistributorIDs = valueList(thisTag.qProgramAllDistributorInitial.contract_distributors_id,",")>
                <cfif appSettings.getlettersavailable() eq 2>
                  <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(thisTag.lsOperatorNames)#_allDistributors_")>
                <cfelse>
                  <cfset thisTag.nameformat = LetterName("#contract_number#_#trim(thisTag.lsOperatorNames)#_allDistributors_")>    <!---25704--->
                </cfif>
                <cfset thisTag.relative_url = replace(thisTag.opr_path,'\','/','all')>
                <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
                <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
                <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
                <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
                
                <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
                
                <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
                  
                  INSERT INTO Program_Letters
                  (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
                  values
                  (#thisTag.contract_main_id#,1,'#thisTag.nameformat#','#thisTag.html_file_path#','#thisTag.lsOperatorNames#',
                  'All #application.returned_customer_setting.distributor_label_plural#','#thisTag.automatic_letter_generation_user_id#')
                </cfquery>
                
                <!--- D16774 8/14/08 [begin]
                <!--- B.) Let's idemtify our new Program Letter ID... --->
                
                <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                  
                  SELECT    MAX(Program_Letters_ID) AS new_letter_id
                  FROM      Program_Letters
                  WHERE     deleted = 0
                </cfquery>
                --->
                <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
                <!--- D16774 8/14/08 [end] --->
                
                <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->  
				<!--- For PDF Letters, Call "generate_program_pdf" --->  
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                    bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                    bInsertWatermark="#thisTag.bInsertWatermark#"
                    CMID="#thisTag.contract_main_id#"
                    customerFreightUom="#thisTag.customerFreightUom#"
                    file_name="#thisTag.nameformat#"
                    lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames="#thisTag.lsDistributorNames#"
                    lsDistributorIDs="#thisTag.lsDistributorIDs#"
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                    oAppSettings="#thisTag.appsettings#"
                    <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                    qGetLetterSettings="#thisTag.getlettersettings#"
                    qGetProgramDetails="#thisTag.getprogramdetails#"
                    qGetTemplateSettings="#thisTag.gettemplatesettings#"
                    qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"    
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#thisTag.opr_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                    template_name="#thisTag.template_name#"
                    watermark_image="#thisTag.watermark_image#">
                
                <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                    bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                    bInsertWatermark="#thisTag.bInsertWatermark#"
                    CMID="#thisTag.contract_main_id#"
                    customerFreightUom="#thisTag.customerFreightUom#"
                    file_name="#thisTag.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames="#thisTag.lsDistributorNames#"
                    lsDistributorIDs="#thisTag.lsDistributorIDs#"
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                    qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#thisTag.opr_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
                
                <!--- D16774 8/14/08 [begin]
                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
                
                <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                  
                  UPDATE  Program_Letters
                  SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                  WHERE   Program_Letters_ID = #thisTag.currentLetterID#
                </cfquery>
                --->
                <cfinvoke 
                component="#application.oLetterManager#" 
                method="updateLetterXML"
                program_letter_id="#thisTag.currentLetterID#"
                sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                <!--- D16774 8/14/08 [end] --->
                
                
              <cfelseif thisTag.getLetterSettings.Opr_letter_settings EQ 1>
                
                <cfloop query="variables.qProgramAllDistributorInitial">
                                    
                  <!--- ========================================
                  ============== Operator 5 of 6 (1 Oper & 1 Dist) ===============
                  ==========================================--->
                  
                  <!--- what type of letter are we creating RIGHT NOW --->
                  <cfset thisTag.abbreviation = "opr">
                  
                  <!--- the following include [inc_init_vars] wants it dished up this way, so... [4 of 8] --->
                  <cfset variables.abbreviation = thisTag.abbreviation>
                  
                  <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
                  <cfinclude template="doc_modules/inc_init_vars.cfm">
                  <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
                  
                  <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [4 OF 8] --->
                  <cfset structAppend(thisTag,variables,true)>
                                    
                  <!--- IF we have requested Customer Product Numbers [begin] ... --->
                  <!---
                  <cfif thisTag.bAddCustomerProductNumbers>
                    <!--- fixed_price --->
                    <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
                    <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                    
                    <cfloop query="thisTag.qProgramFixedPriceInitial">
                      
                      <!--- string id --->
                      <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
                      
                    </cfloop>
                    
                    <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
                    <!--- bid_request --->
                    <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
                    <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                    
                    <cfloop query="thisTag.qProgramBidRequestInitial">
                      
                      <!--- string id --->
                      <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
                      
                    </cfloop>
                    
                    <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
                    
                    <!--- rebate --->
                    <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
                    <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                    
                    <cfloop query="thisTag.qProgramRebateInitial">
                      
                      <!--- string id --->
                      <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
                      
                    </cfloop>
                    
                    <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
                    
                    
                  </cfif>
                  --->
                  <!--- IF we have requested Customer Product Numbers [end] ... --->
                                    
                  <cfset thisTag.lsDistributorNames = thisTag.qProgramAllDistributorInitial.Name>
                  <cfset thisTag.lsDistributorIDs = thisTag.qProgramAllDistributorInitial.contract_distributors_id>
                  <cfif appSettings.getlettersavailable() eq 2>
                    <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(thisTag.lsOperatorNames)#_#thisTag.qProgramDistributorInitial.Name#_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
                  <cfelse>    
                    <cfset thisTag.nameformat = LetterName("#contract_number#_#trim(thisTag.lsOperatorNames)#_#thisTag.qProgramDistributorInitial.Name#_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>    <!---25704--->
                  </cfif>
                  <cfset thisTag.relative_url = replace(thisTag.opr_path,'\','/','all')>
                  <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
                  <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
                  <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
                  <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
                  
                  <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
                  
                  <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
                    
                    INSERT INTO Program_Letters
                    (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
                    values
                    (#thisTag.contract_main_id#,1,'#thisTag.nameformat#','#thisTag.html_file_path#',
                    '#thisTag.lsOperatorNames#','#thisTag.lsDistributorNames#','#thisTag.automatic_letter_generation_user_id#')
                  </cfquery>
                  
                  <!--- D16774 8/14/08 [begin]
                  <!--- B.) Let's idemtify our new Program Letter ID... --->
                  
                  <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                    
                    SELECT    MAX(Program_Letters_ID) AS new_letter_id
                    FROM      Program_Letters
                    WHERE     deleted = 0
                  </cfquery>
                  --->
                  <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
                  <!--- D16774 8/14/08 [end] --->
                  
                  <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->  
				  <!--- For PDF Letters, Call "generate_program_pdf" --->   
                  <cf_generate_program_pdf
                      bAddcustomerproductnumbers="0"
                      bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                      bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                      bInsertWatermark="#thisTag.bInsertWatermark#"
                      CMID="#thisTag.contract_main_id#"
                      customerFreightUom="#thisTag.customerFreightUom#"
                      file_name="#thisTag.nameformat#"
                      lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                      current_program_letter_id="#thisTag.currentLetterID#"
                      lsDistributorNames="#thisTag.lsDistributorNames#"
                      lsDistributorIDs="#thisTag.lsDistributorIDs#"
                      lsOperatorNames="#thisTag.lsOperatorNames#"
                      lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                      oAppSettings="#thisTag.appsettings#"
                      <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                      qGetLetterSettings="#thisTag.getlettersettings#"
                      qGetProgramDetails="#thisTag.getprogramdetails#"
                      qGetTemplateSettings="#thisTag.gettemplatesettings#"
                      qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                      qProgramClause="#thisTag.qProgramClauseInitial#"
                      qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                      qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                      qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                      qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                      qProgramRebate="#thisTag.qProgramRebateInitial#"   
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                      relative_path="#thisTag.opr_path#"
                      stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                      stPDFEndInfo="#thisTag.stPDFEndInfo#"
                      stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                      stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                      template_name="#thisTag.template_name#"
                      watermark_image="#thisTag.watermark_image#">
                  
                  <cf_generate_program_xml
                      bAddcustomerproductnumbers="0"
                      bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                      bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                      bInsertWatermark="#thisTag.bInsertWatermark#"
                      CMID="#thisTag.contract_main_id#"
                      customerFreightUom="#thisTag.customerFreightUom#"
                      file_name="#thisTag.nameformat#"
                      prior_program_letter_id="0"
                      current_program_letter_id="#thisTag.currentLetterID#"
                      lsDistributorNames="#thisTag.lsDistributorNames#"
                      lsDistributorIDs="#thisTag.lsDistributorIDs#"
                      lsOperatorNames="#thisTag.lsOperatorNames#"
                      lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                      qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                      qProgramClause="#thisTag.qProgramClauseInitial#"
                      qProgramDistributor="#variables.qProgramAllDistributorInitial#"
                      qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                      qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                      qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                      qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                      relative_path="#thisTag.opr_path#"
                      stPDFBodyInfo="#thisTag.stPDFBodyInfo#" 
                      stPDFEndInfo="#thisTag.stPDFEndInfo#"
                      stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                      stPDFIntroInfo="#thisTag.stPDFIntroInfo#">    
                  
                  <!--- D16774 8/14/08 [begin]
                  <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
                  
                  <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                    
                    UPDATE  Program_Letters
                    SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                    WHERE   Program_Letters_ID = #thisTag.currentLetterID#
                  </cfquery>
                  --->
                  <cfinvoke 
                  component="#application.oLetterManager#" 
                  method="updateLetterXML"
                  program_letter_id="#thisTag.currentLetterID#"
                  sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                  <!--- D16774 8/14/08 [end] --->
                  
                </cfloop>
                
                <!--- ========================================
                ============== Operator 6 of 6 (1 Oper & No Dist) ===============
                ==========================================--->
                <cfelseif thisTag.getLetterSettings.Opr_letter_settings EQ 3>
					         <cfif appSettings.getlettersavailable() eq 2> 
				              <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(thisTag.lsOperatorNames)#_noDistributors_")>
                    <cfelse>
                      <cfset thisTag.nameformat = LetterName("#contract_number#_#trim(thisTag.lsOperatorNames)#_noDistributors_")>
                    </cfif>
                <cfset thisTag.relative_url = replace(thisTag.opr_path,'\','/','all')>
                <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
                <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
                <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
                <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
                
                <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
                
                <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
                  
                  INSERT INTO Program_Letters
                  (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
                  values
                  (#thisTag.contract_main_id#,1,'#thisTag.nameformat#','#thisTag.html_file_path#','#thisTag.lsOperatorNames#',
                  'No #application.returned_customer_setting.distributor_label_plural#','#thisTag.automatic_letter_generation_user_id#')
                </cfquery>
                
                <!--- D16774 8/14/08 [begin]
                <!--- B.) Let's idemtify our new Program Letter ID... --->
                
                <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                  
                  SELECT    MAX(Program_Letters_ID) AS new_letter_id
                  FROM      Program_Letters
                  WHERE     deleted = 0
                </cfquery>
                --->
                <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
                <!--- D16774 8/14/08 [end] --->
                
                <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->  
				
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->				
			<cfif appSettings.getlettersavailable() eq 2>
				<cf_generate_program_pdf_html
                    CMID="#thisTag.contract_main_id#"
                    file_name="#thisTag.nameformat#"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                    oAppSettings="#thisTag.appsettings#"
                    <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                    qGetLetterSettings="#thisTag.getlettersettings#"
                    qGetProgramDetails="#thisTag.getprogramdetails#"
                    qGetTemplateSettings="#thisTag.gettemplatesettings#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"    
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    relative_path="#thisTag.opr_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                    template_name="#thisTag.template_name#">
			<cfelse>
				<!--- For PDF Letters, Call "generate_program_pdf" --->	
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                    bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                    bInsertWatermark="#thisTag.bInsertWatermark#"
                    CMID="#thisTag.contract_main_id#"
                    customerFreightUom="#thisTag.customerFreightUom#"
                    file_name="#thisTag.nameformat#"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                    oAppSettings="#thisTag.appsettings#"
                    <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                    qGetLetterSettings="#thisTag.getlettersettings#"
                    qGetProgramDetails="#thisTag.getprogramdetails#"
                    qGetTemplateSettings="#thisTag.gettemplatesettings#"
                    qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"    
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#thisTag.opr_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                    template_name="#thisTag.template_name#"
                    watermark_image="#thisTag.watermark_image#">
			  </cfif>
                
                <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="0"
                    bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                    bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                    bInsertWatermark="#thisTag.bInsertWatermark#"
                    CMID="#thisTag.contract_main_id#"
                    customerFreightUom="#thisTag.customerFreightUom#"
                    file_name="#thisTag.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames=""
                    lsDistributorIDs=""
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"  
                    qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#queryNew('Name,contract_distributors_id')#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#thisTag.opr_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
                
                <!--- D16774 8/14/08 [begin]
                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
                
                <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                  
                  UPDATE  Program_Letters
                  SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                  WHERE   Program_Letters_ID = #thisTag.currentLetterID#
                </cfquery>
                --->
                <cfinvoke 
                component="#application.oLetterManager#" 
                method="updateLetterXML"
                program_letter_id="#thisTag.currentLetterID#"
                sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                <!--- D16774 8/14/08 [end] --->
                
              </cfif>
            
            </cfif>   <!---if not excludeThis--->
            
          </cfloop>
          
          
        </cfif>

      </cfif>
      </cfif>
      <!--- =================================================================================
      ==================================== OPERATOR [end] ===================================
      ================================================================================== --->
      
      <!--- =================================================================================
      ==================================== DISTRIBUTOR [begin] ==============================
      ================================================================================== --->
      
      <cfif thisTag.getLetterSettings.Letter_Type EQ 2 or  thisTag.getLetterSettings.Letter_Type EQ 3>
        
        <cfset thisTag.template_name = "#company_name# #appSettings.getDistributorLetterName()#">
        <!--- <cfset LetterManager.deleteLetters(thisTag.contract_main_id,2)> --->
        
        
        <cfif thisTag.getLetterSettings.Distributor_Letter_Type EQ 2>
          
          
          <!--- what type of letter are we creating RIGHT NOW --->
          <cfset thisTag.abbreviation = "dis">
          
          <!--- the following include [inc_init_vars] wants it dished up this way, so... [5 of 8] --->
          <cfset variables.abbreviation = thisTag.abbreviation>
          
          <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
          <cfinclude template="doc_modules/inc_init_vars.cfm">
          <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
          
          <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [5 OF 8] --->
          <cfset structAppend(thisTag,variables,true)>
          
          <!--- IF we have requested Customer Product Numbers [begin] ... --->
          
          <cfif thisTag.bAddCustomerProductNumbers>
            <!--- fixed_price --->
            <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
            <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
            
            <cfloop query="thisTag.qProgramFixedPriceInitial">
              
              <!--- string id --->
              <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
              
            </cfloop>
            
            <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
            <!--- bid_request --->
            <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
            <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
            
            <cfloop query="thisTag.qProgramBidRequestInitial">
              
              <!--- string id --->
              <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
              
            </cfloop>
            
            <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
            
            <!--- rebate --->
            <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
            <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
            
            <cfloop query="thisTag.qProgramRebateInitial">
              
              <!--- string id --->
              <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
              
            </cfloop>
            
            <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
            
            
          </cfif>
          
          <!--- IF we have requested Customer Product Numbers [end] ... --->
          
          <cfset thisTag.lsDistributorNames = valueList(thisTag.qProgramDistributorInitial.Name,", ")>
          <cfset thisTag.lsDistributorIDs = valueList(thisTag.qProgramDistributorInitial.contract_distributors_id,",")>
          
          <cfif thisTag.getLetterSettings.Dis_letter_settings EQ 2>
            
            
            <!--- ========================================
            ============== Distributor 1 of 4 (Multi Dist & All Oper) ============
            ==========================================--->
            <cfset thisTag.lsOperatorNames = valueList(thisTag.qProgramOperatorInitial.Operator_Name,", ")>
            <cfset thisTag.lsOperatorIDs = valueList(thisTag.qProgramOperatorInitial.operator_id,",")>
            <cfif appSettings.getlettersavailable() eq 2>
              <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allDistributors_allOperators_")>      
            <cfelse>
              <cfset thisTag.nameformat = LetterName("#contract_number#_allDistributors_allOperators_")> <!---25704--->
            </cfif>  
            <cfset thisTag.relative_url = replace(thisTag.dis_path,'\','/','all')>
            <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
            <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
            <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
            <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>

            <cfquery name="getOperatorCount" datasource="#application.datasource#">
	      SELECT COUNT(BSA_Operator_ID) As OperatorNum
	      FROM Contract_Operators
	      WHERE Contract_Main_ID = '#thisTag.contract_main_id#'
	      AND deleted = 0
	    </cfquery>
	
	     <!--- If there is only one operator in the program, show the operator name, else 'All Operators' --->
	     <cfif getOperatorCount.OperatorNum eq 1>
		<cfset OperatorName = '#thisTag.lsOperatorNames#'>
	     <cfelse>
		<cfset OperatorName = 'All #application.returned_customer_setting.operator_label_plural#'>
	     </cfif>
            
            <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->            
            <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
              
              INSERT INTO Program_Letters
              (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
              values
              (#thisTag.contract_main_id#,2,'#thisTag.nameformat#','#thisTag.html_file_path#',
              '#OperatorName#',
              'All #application.returned_customer_setting.distributor_label_plural#','#thisTag.automatic_letter_generation_user_id#')
            </cfquery>
            
            <!--- D16774 8/14/08 [begin]
            <!--- B.) Let's identify our new Program Letter ID... --->
            
            <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
              
              SELECT    MAX(Program_Letters_ID) AS new_letter_id
              FROM      Program_Letters
              WHERE     deleted = 0
            </cfquery>
            --->
            <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
            <!--- D16774 8/14/08 [end] --->
            
            <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
            <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->  
			
		<!--- For HTML Letters, Call "generate_program_pdf_html" --->				
		<cfif appSettings.getlettersavailable() eq 2> 
			<cf_generate_program_pdf_html
                CMID="#thisTag.contract_main_id#"
                file_name="#thisTag.nameformat#"
                lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames="#thisTag.lsDistributorNames#"
                lsDistributorIDs="#thisTag.lsDistributorIDs#"
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                oAppSettings="#thisTag.appsettings#"
                <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                qGetLetterSettings="#thisTag.getlettersettings#"
                qGetProgramDetails="#thisTag.getprogramdetails#"
                qGetTemplateSettings="#thisTag.gettemplatesettings#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#thisTag.qProgramDistributorInitial#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"  
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                relative_path="#thisTag.dis_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                template_name="#thisTag.template_name#">
		<cfelse>
			<!--- For PDF Letters, Call "generate_program_pdf" --->
            <cf_generate_program_pdf
                bAddcustomerproductnumbers="0"
                bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                bInsertWatermark="#thisTag.bInsertWatermark#"
                CMID="#thisTag.contract_main_id#"
                customerFreightUom="#thisTag.customerFreightUom#"
                file_name="#thisTag.nameformat#"
                lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames="#thisTag.lsDistributorNames#"
                lsDistributorIDs="#thisTag.lsDistributorIDs#"
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                oAppSettings="#thisTag.appsettings#"
                <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                qGetLetterSettings="#thisTag.getlettersettings#"
                qGetProgramDetails="#thisTag.getprogramdetails#"
                qGetTemplateSettings="#thisTag.gettemplatesettings#"
                qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#thisTag.qProgramDistributorInitial#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"  
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                relative_path="#thisTag.dis_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                template_name="#thisTag.template_name#"
                watermark_image="#thisTag.watermark_image#">
			</cfif>
            
            <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
            <cf_generate_program_xml
                bAddcustomerproductnumbers="0"
                bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                bInsertWatermark="#thisTag.bInsertWatermark#"
                CMID="#thisTag.contract_main_id#"
                customerFreightUom="#thisTag.customerFreightUom#"
                file_name="#thisTag.nameformat#"
                prior_program_letter_id="0"
                current_program_letter_id="#thisTag.currentLetterID#"
                lsDistributorNames="#thisTag.lsDistributorNames#"
                lsDistributorIDs="#thisTag.lsDistributorIDs#"
                lsOperatorNames="#thisTag.lsOperatorNames#"
                lsOperatorIDs="#thisTag.lsOperatorIDs#"
                qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                qProgramClause="#thisTag.qProgramClauseInitial#"
                qProgramDistributor="#thisTag.qProgramDistributorInitial#"
                qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                qProgramGrowth="#variables.qProgramGrowthInitial#"
                qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                relative_path="#thisTag.dis_path#"
                stPDFBodyInfo="#thisTag.stPDFBodyInfo#" 
                stPDFEndInfo="#thisTag.stPDFEndInfo#"
                stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
            
            <!--- D16774 8/14/08 [begin]
            <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
            
            <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
              
              UPDATE  Program_Letters
              SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
              WHERE   Program_Letters_ID = #thisTag.currentLetterID#
            </cfquery>
            --->
            <cfinvoke 
            component="#application.oLetterManager#" 
            method="updateLetterXML"
            program_letter_id="#thisTag.currentLetterID#"
            sProgramLetterXML="#trim(request.sProgramLetterXML)#">
            <!--- D16774 8/14/08 [end] --->
            
          <cfelse>
            
            <cfloop query="thisTag.qProgramOperatorInitial">
              
              <!--- ========================================
              ============== Distributor 2 of 4 (Multi Dist & 1 Oper) ============
              ==========================================--->
              
              <!--- what type of letter are we creating RIGHT NOW --->
              <cfset thisTag.abbreviation = "dis">
              
              <!--- the following include [inc_init_vars] wants it dished up this way, so... [6 of 8] --->
              <cfset variables.abbreviation = thisTag.abbreviation>
              
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
              <cfinclude template="doc_modules/inc_init_vars.cfm">
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
              
              <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [6 OF 8] --->
              <cfset structAppend(thisTag,variables,true)>
              
              <!--- IF we have requested Customer Product Numbers [begin] ... --->
              <!---
              <cfif thisTag.bAddCustomerProductNumbers>
                
                
                <!--- fixed_price --->
                <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramFixedPriceInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
                <!--- bid_request --->
                <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramBidRequestInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
                
                <!--- rebate --->
                <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramRebateInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
                
                
              </cfif>
              --->
              <!--- IF we have requested Customer Product Numbers [end] ... --->
              
              <cfset thisTag.lsOperatorNames = thisTag.qProgramOperatorInitial.Operator_Name>
              <cfset thisTag.lsOperatorIDs = thisTag.qProgramOperatorInitial.operator_id>
              <cfif appSettings.getlettersavailable() eq 2>
                <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_allDistributors_#thisTag.qProgramOperatorInitial.Operator_Name#_")>     
              <cfelse>
                 <cfset thisTag.nameformat = LetterName("#contract_number#_allDistributors_#thisTag.qProgramOperatorInitial.Operator_Name#_")>  <!---25704--->
              </cfif>   
              <cfset thisTag.relative_url = replace(thisTag.dis_path,'\','/','all')>
              <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
              <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
              <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
              <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
              
              <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
              
              <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
                
                INSERT INTO Program_Letters
                (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,created_by)
                values
                (#thisTag.contract_main_id#,2,'#thisTag.nameformat#','#thisTag.html_file_path#',
                '#trim(thisTag.lsOperatorNames)#','All #application.returned_customer_setting.distributor_label_plural#','#thisTag.automatic_letter_generation_user_id#')
              </cfquery>
              
              <!--- D16774 8/14/08 [begin]
              <!--- B.) Let's idemtify our new Program Letter ID... --->
              
              <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                
                SELECT    MAX(Program_Letters_ID) AS new_letter_id
                FROM      Program_Letters
                WHERE     deleted = 0
              </cfquery>
              --->
              <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
              <!--- D16774 8/14/08 [end] --->
              
              <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
              <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
			<!--- For PDF Letters, Call "generate_program_pdf_html" --->
			<cfif appSettings.getlettersavailable() eq 2>
			    <cf_generate_program_pdf_html  
                  CMID="#thisTag.contract_main_id#"
                  file_name="#thisTag.nameformat#"
                  lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                  current_program_letter_id="#thisTag.currentLetterID#"
                  lsDistributorNames="#thisTag.lsDistributorNames#"
                  lsDistributorIDs="#thisTag.lsDistributorIDs#"
                  lsOperatorNames="#thisTag.lsOperatorNames#"
                  lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                  oAppSettings="#thisTag.appsettings#"
                  <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                  qGetLetterSettings="#thisTag.getlettersettings#"
                  qGetProgramDetails="#thisTag.getprogramdetails#"
                  qGetTemplateSettings="#thisTag.gettemplatesettings#" 
                  qProgramClause="#thisTag.qProgramClauseInitial#"
                  qProgramDistributor="#thisTag.qProgramDistributorInitial#"
                  qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                  qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                  qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                  qProgramRebate="#thisTag.qProgramRebateInitial#"  
                  qProgramGrowth="#variables.qProgramGrowthInitial#"
                  relative_path="#thisTag.dis_path#"
                  stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                  stPDFEndInfo="#thisTag.stPDFEndInfo#"
                  stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                  stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                  template_name="#thisTag.template_name#">
			<cfelse>          
			  <!--- For PDF Letters, Call "generate_program_pdf" --->
              <cf_generate_program_pdf
                  bAddcustomerproductnumbers="0"
                  bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                  bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                  bInsertWatermark="#thisTag.bInsertWatermark#"
                  CMID="#thisTag.contract_main_id#"
                  customerFreightUom="#thisTag.customerFreightUom#"
                  file_name="#thisTag.nameformat#"
                  lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                  current_program_letter_id="#thisTag.currentLetterID#"
                  lsDistributorNames="#thisTag.lsDistributorNames#"
                  lsDistributorIDs="#thisTag.lsDistributorIDs#"
                  lsOperatorNames="#thisTag.lsOperatorNames#"
                  lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                  oAppSettings="#thisTag.appsettings#"
                  <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                  qGetLetterSettings="#thisTag.getlettersettings#"
                  qGetProgramDetails="#thisTag.getprogramdetails#"
                  qGetTemplateSettings="#thisTag.gettemplatesettings#" 
                  qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                  qProgramClause="#thisTag.qProgramClauseInitial#"
                  qProgramDistributor="#thisTag.qProgramDistributorInitial#"
                  qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                  qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                  qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                  qProgramRebate="#thisTag.qProgramRebateInitial#"  
                  qProgramGrowth="#variables.qProgramGrowthInitial#"
                  qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                  relative_path="#thisTag.dis_path#"
                  stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                  stPDFEndInfo="#thisTag.stPDFEndInfo#"
                  stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                  stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                  template_name="#thisTag.template_name#"
                  watermark_image="#thisTag.watermark_image#">
		  	</cfif>
              
              <!--- multiple distributors - customer_product_numbers ALWAYS OFF 0 --->
              <cf_generate_program_xml
                  bAddcustomerproductnumbers="0"
                  bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                  bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                  bInsertWatermark="#thisTag.bInsertWatermark#"
                  CMID="#thisTag.contract_main_id#"
                  customerFreightUom="#thisTag.customerFreightUom#"
                  file_name="#thisTag.nameformat#"
                  prior_program_letter_id="0"
                  current_program_letter_id="#thisTag.currentLetterID#"
                  lsDistributorNames="#thisTag.lsDistributorNames#"
                  lsDistributorIDs="#thisTag.lsDistributorIDs#"
                  lsOperatorNames="#thisTag.lsOperatorNames#"
                  lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                  qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                  qProgramClause="#thisTag.qProgramClauseInitial#"
                  qProgramDistributor="#thisTag.qProgramDistributorInitial#"
                  qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                  qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                  qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                  qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                  qProgramGrowth="#variables.qProgramGrowthInitial#"
                  qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                  relative_path="#thisTag.dis_path#"
                  stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                  stPDFEndInfo="#thisTag.stPDFEndInfo#"
                  stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                  stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
              
              <!--- D16774 8/14/08 [begin]
              <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
              
              <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                
                UPDATE  Program_Letters
                SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                WHERE   Program_Letters_ID = #thisTag.currentLetterID#
              </cfquery>
              --->
              <cfinvoke 
              component="#application.oLetterManager#" 
              method="updateLetterXML"
              program_letter_id="#thisTag.currentLetterID#"
              sProgramLetterXML="#trim(request.sProgramLetterXML)#">
              <!--- D16774 8/14/08 [end] --->
            </cfloop>
            
          </cfif>
          
          
          
        <cfelseif thisTag.getLetterSettings.Distributor_Letter_Type EQ 1>
		
          <cfloop query="thisTag.qProgramDistributorInitial">
            
            <cfset excludeThis = false>
            <!---25704 if there is a list of distributor IDs to process, apply the filter--->
            <cfif Len(Trim(thisTag.distributor_IDs)) 
              and not ListFindNocase(thisTag.distributor_IDs, thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
              <cfset excludeThis = true>
            </cfif>

            <!---<cflog file="tgn" text="excludeThis=#excludeThis#|id=#thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id#">--->           

            <cfif not excludeThis>
              <!--- Dev Note: KAL; D17147: Letters show all distributors when select one distributor per letter
              Both the Distributors where begin passed in each iterator of the operator  
              --->
              <cfquery name="variables.qProgramCurrentDistributor" dbtype="query">
                
                SELECT  *
                FROM  qProgramDistributorInitial
                WHERE BSA_FOODSERVICE_CUSTOMERS_ID = '#trim(qProgramDistributorInitial.BSA_FOODSERVICE_CUSTOMERS_ID[currentRow])#'
                AND   CONTRACT_DISTRIBUTORS_ID = #qProgramDistributorInitial.CONTRACT_DISTRIBUTORS_ID[currentRow]#
              </cfquery>
              <!--- End Note: KAL; D17147: Letters show all distributors when select one distributor per letter --->
              
              
              <!--- what type of letter are we creating RIGHT NOW --->
              <cfset thisTag.abbreviation = "dis">
              
              <!--- the following include [inc_init_vars] wants it dished up this way, so... [7 of 8] --->
              <cfset variables.abbreviation = thisTag.abbreviation>
              
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
              <cfinclude template="doc_modules/inc_init_vars.cfm">
              <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
              
              <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [7 OF 8] --->
              <cfset structAppend(thisTag,variables,true)>
              
              <!--- IF we have requested Customer Product Numbers [begin] ... --->
              <!---
              <cfif thisTag.bAddCustomerProductNumbers>
                
                
                <!--- fixed_price --->
                <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramFixedPriceInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
                <!--- bid_request --->
                <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramBidRequestInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
                
                <!--- rebate --->
                <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
                <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                
                <cfloop query="thisTag.qProgramRebateInitial">
                  
                  <!--- string id --->
                  <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
                  
                </cfloop>
                
                <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
                
              
              </cfif>
               --->
              <!--- IF we have requested Customer Product Numbers [end] ... --->
              
              <cfset thisTag.lsDistributorNames = thisTag.qProgramDistributorInitial.Name>
              <cfset thisTag.lsDistributorIDs = thisTag.qProgramDistributorInitial.contract_distributors_id>
              <cfset thisTag.dist_id = thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id>

              <cfif thisTag.getLetterSettings.Dis_letter_settings EQ 2>
                
                
                <!--- ========================================
                ============== Distributor 3 of 4 (1 Dist & All Oper) ============
                ==========================================--->
                <cfset thisTag.lsOperatorNames = valueList(thisTag.qProgramOperatorInitial.Operator_Name,", ")>
                <cfset thisTag.lsOperatorIDs = valueList(thisTag.qProgramOperatorInitial.operator_id,",")>
                <cfif appSettings.getlettersavailable() eq 2>
                  <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(thisTag.lsDistributorNames)#_allOperators_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
                <cfelse>    
                  <cfset thisTag.nameformat = LetterName("#contract_number#_#trim(thisTag.lsDistributorNames)#_allOperators_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>    <!---25704--->
					      </cfif>          
                <cfset thisTag.relative_url = replace(thisTag.dis_path,'\','/','all')>
                <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
                <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
                <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
                <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>

		<cfquery name="getOperatorCount" datasource="#application.datasource#">
		      SELECT COUNT(BSA_Operator_ID) As OperatorNum
		      FROM Contract_Operators
		      WHERE Contract_Main_ID = '#thisTag.contract_main_id#'
		      AND deleted = 0
		  </cfquery>

		  <!--- If there is only one operator in the program, show the operator name, else 'All Operators' --->
		  <cfif getOperatorCount.OperatorNum eq 1>
			<cfset OperatorName = '#thisTag.lsOperatorNames#'>
		  <cfelse>
			<cfset OperatorName = 'All #application.returned_customer_setting.operator_label_plural#'>
		  </cfif>     
                
                <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->						
		<cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">                 
                  INSERT INTO Program_Letters
                  (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,distributor_id,created_by)
                  values
                  (#thisTag.contract_main_id#,2,'#thisTag.nameformat#','#thisTag.html_file_path#',
                  '#OperatorName#',
                  '#trim(thisTag.lsDistributorNames)#','#thisTag.dist_id#','#thisTag.automatic_letter_generation_user_id#')
                </cfquery>
                
                <!--- D16774 8/14/08 [begin]
                <!--- B.) Let's idemtify our new Program Letter ID... --->
                
                <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                  
                  SELECT    MAX(Program_Letters_ID) AS new_letter_id
                  FROM      Program_Letters
                  WHERE     deleted = 0
                </cfquery>
                --->
                <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
                <!--- D16774 8/14/08 [end] --->
                
                <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? ---> 
					
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->				
			<cfif appSettings.getlettersavailable() eq 2>
			 	<cf_generate_program_pdf_html
                    CMID="#thisTag.contract_main_id#"
                    file_name="#thisTag.nameformat#"
                    lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames="#thisTag.lsDistributorNames#"
                    lsDistributorIDs="#thisTag.lsDistributorIDs#"
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"
                    oAppSettings="#thisTag.appsettings#"
                    <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                    qGetLetterSettings="#thisTag.getlettersettings#"
                    qGetProgramDetails="#thisTag.getprogramdetails#"
                    qGetTemplateSettings="#thisTag.gettemplatesettings#" 
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"  
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    relative_path="#thisTag.dis_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                    template_name="#thisTag.template_name#">
			<cfelse>
				<!--- For PDF Letters, Call "generate_program_pdf" --->			         
                <cf_generate_program_pdf
                    bAddcustomerproductnumbers="#url.custprodnum#"
                    bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                    bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                    bInsertWatermark="#thisTag.bInsertWatermark#"
                    CMID="#thisTag.contract_main_id#"
                    customerFreightUom="#thisTag.customerFreightUom#"
                    file_name="#thisTag.nameformat#"
                    lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames="#thisTag.lsDistributorNames#"
                    lsDistributorIDs="#thisTag.lsDistributorIDs#"
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#"
                    oAppSettings="#thisTag.appsettings#"
                    <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                    qGetLetterSettings="#thisTag.getlettersettings#"
                    qGetProgramDetails="#thisTag.getprogramdetails#"
                    qGetTemplateSettings="#thisTag.gettemplatesettings#" 
                    qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"  
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#thisTag.dis_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                    template_name="#thisTag.template_name#"
                    watermark_image="#thisTag.watermark_image#">
			</cfif>
			 
                <cf_generate_program_xml
                    bAddcustomerproductnumbers="#url.custprodnum#"
                    bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                    bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                    bInsertWatermark="#thisTag.bInsertWatermark#"
                    CMID="#thisTag.contract_main_id#"
                    customerFreightUom="#thisTag.customerFreightUom#"
                    file_name="#thisTag.nameformat#"
                    prior_program_letter_id="0"
                    current_program_letter_id="#thisTag.currentLetterID#"
                    lsDistributorNames="#thisTag.lsDistributorNames#"
                    lsDistributorIDs="#thisTag.lsDistributorIDs#"
                    lsOperatorNames="#thisTag.lsOperatorNames#"
                    lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                    qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                    qProgramClause="#thisTag.qProgramClauseInitial#"
                    qProgramDistributor="#variables.qProgramCurrentDistributor#"
                    qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                    qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                    qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                    qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                    qProgramGrowth="#variables.qProgramGrowthInitial#"
                    qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                    relative_path="#thisTag.dis_path#"
                    stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                    stPDFEndInfo="#thisTag.stPDFEndInfo#"
                    stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                    stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
                
                <!--- D16774 8/14/08 [begin]
                <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
                
                <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                  
                  UPDATE  Program_Letters
                  SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                  WHERE   Program_Letters_ID = #thisTag.currentLetterID#
                </cfquery>
                --->
                <cfinvoke 
                component="#application.oLetterManager#" 
                method="updateLetterXML"
                program_letter_id="#thisTag.currentLetterID#"
                sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                <!--- D16774 8/14/08 [end] --->
                
                
              <cfelse>
                
                
                
                <cfloop query="thisTag.qProgramOperatorInitial">
                  
                  
                  <!--- ========================================
                  ============== Distributor 4 of 4 (1 Dist & 1 Oper) ============
                  ==========================================--->
                  
                  <!--- what type of letter are we creating RIGHT NOW --->
                  <cfset thisTag.abbreviation = "dis">
                  
                  <!--- the following include [inc_init_vars] wants it dished up this way, so... [8 of 8] --->
                  <cfset variables.abbreviation = thisTag.abbreviation>
                  
                  <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [begin] --->
                  <cfinclude template="doc_modules/inc_init_vars.cfm">
                  <!--- IMPORTANT - This must always follow the above thisTag - IMPORTANT [end] --->
                  
                  <!--- let's append the thisTag scope with the FEW Discount Type variables scoped vars coming back from the init NOW [8 OF 8] --->
                  <cfset structAppend(thisTag,variables,true)>
                  
                  <!--- IF we have requested Customer Product Numbers [begin] ... --->
                  <!---
                  <cfif thisTag.bAddCustomerProductNumbers>
                    
                    
                    <!--- fixed_price --->
                    <cfset thisTag.aFixedPriceCustomerProductNumbers = arrayNew(1)>
                    <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                    
                    <cfloop query="thisTag.qProgramFixedPriceInitial">
                      
                      <!--- string id --->
                      <cfset arrayAppend(thisTag.aFixedPriceCustomerProductNumbers,"na")>
                      
                    </cfloop>
                    
                    <cfset queryAddColumn(thisTag.qProgramFixedPriceInitial,"customer_product_number","VarChar",thisTag.aFixedPriceCustomerProductNumbers)>
                    <!--- bid_request --->
                    <cfset thisTag.aBidRequestCustomerProductNumbers = arrayNew(1)>
                    <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                    
                    <cfloop query="thisTag.qProgramBidRequestInitial">
                      
                      <!--- string id --->
                      <cfset arrayAppend(thisTag.aBidRequestCustomerProductNumbers,"na")>
                      
                    </cfloop>
                    
                    <cfset queryAddColumn(thisTag.qProgramBidRequestInitial,"customer_product_number","VarChar",thisTag.aBidRequestCustomerProductNumbers)>
                    
                    <!--- rebate --->
                    <cfset thisTag.aRebateCustomerProductNumbers = arrayNew(1)>
                    <!--- let's loop through the GROSS container... [IMPORTANT: QUERY MUST BE SAME LENGTH AS FINAL ARRAY CONTAINER HERE] --->
                    
                    <cfloop query="thisTag.qProgramRebateInitial">
                      
                      <!--- string id --->
                      <cfset arrayAppend(thisTag.aRebateCustomerProductNumbers,"na")>
                      
                    </cfloop>
                    
                    <cfset queryAddColumn(thisTag.qProgramRebateInitial,"customer_product_number","VarChar",thisTag.aRebateCustomerProductNumbers)>
                    
                    
                  </cfif>
                  --->
                  <!--- IF we have requested Customer Product Numbers [end] ... --->
                  
                  <cfset thisTag.lsOperatorNames = thisTag.qProgramOperatorInitial.Operator_Name>
                  <cfset thisTag.lsOperatorIDs = thisTag.qProgramOperatorInitial.operator_id>
                  <cfif appSettings.getlettersavailable() eq 2>
                    <cfset thisTag.nameformat = LetterName("General_Mills_#contract_number#_#contract_title#_#trim(thisTag.lsDistributorNames)#_#thisTag.qProgramOperatorInitial.Operator_Name#_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>
                   <cfelse> 
                    <cfset thisTag.nameformat = LetterName("#contract_number#_#trim(thisTag.lsDistributorNames)#_#thisTag.qProgramOperatorInitial.Operator_Name#_",thisTag.qProgramDistributorInitial.Bsa_Foodservice_Customers_Id)>     <!---25704--->
                   </cfif> 
                  <cfset thisTag.relative_url = replace(thisTag.dis_path,'\','/','all')>
                  <cfset thisTag.html_file_path_string = application.doc_mapping & thisTag.relative_url & thisTag.contract_main_id & "/" & thisTag.nameformat & ".htm">
                  <!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping --->
                  <cfset thisTag.html_file_path = expandPath(thisTag.html_file_path_string)>
                  <cfset thisTag.html_file_path = lCase(thisTag.html_file_path)>
                  
                  <!--- A.) Tech Note: Letter_Name is still a .htm file til further notice... --->
                  
                  <cfquery name="thisTag.qInsertLetterSettings" datasource="#application.datasource#">
                    
                    INSERT INTO Program_Letters
                    (Program_id,Letter_Type,Letter_Name,Letter_Path,operator_name,distributor_name,distributor_id,created_by)
                    values
                    (#thisTag.contract_main_id#,2,'#thisTag.nameformat#','#thisTag.html_file_path#',
                    '#trim(thisTag.lsOperatorNames)#','#trim(thisTag.lsDistributorNames)#','#thisTag.dist_id#','#thisTag.automatic_letter_generation_user_id#')
                  </cfquery>
                  
                  <!--- D16774 8/14/08 [begin]
                  <!--- B.) Let's identify our new Program Letter ID... --->
                  
                  <cfquery name="thisTag.qGetCurrentProgramLetterID" datasource="#application.datasource#">
                    
                    SELECT    MAX(Program_Letters_ID) AS new_letter_id
                    FROM      Program_Letters
                    WHERE     deleted = 0
                  </cfquery>
                  --->
                  <cfset thisTag.currentLetterID = application.oLetterManager.getLastLetterID()>
                  <!--- D16774 8/14/08 [end] --->
                  
                  <!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->  
				
			<!--- For HTML Letters, Call "generate_program_pdf_html" --->
			<cfif appSettings.getlettersavailable() eq 2>
			 	  <cf_generate_program_pdf_html  
                      CMID="#thisTag.contract_main_id#"
                      file_name="#thisTag.nameformat#"
                      lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                      current_program_letter_id="#thisTag.currentLetterID#"
                      lsDistributorNames="#thisTag.lsDistributorNames#"
                      lsDistributorIDs="#thisTag.lsDistributorIDs#" 
                      lsOperatorNames="#thisTag.lsOperatorNames#"
                      lsOperatorIDs="#thisTag.lsOperatorIDs#"
                      oAppSettings="#thisTag.appsettings#"
                      <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                      qGetLetterSettings="#thisTag.getlettersettings#"
                      qGetProgramDetails="#thisTag.getprogramdetails#"
                      qGetTemplateSettings="#thisTag.gettemplatesettings#" 
                      qProgramClause="#thisTag.qProgramClauseInitial#"
                      qProgramDistributor="#variables.qProgramCurrentDistributor#"
                      qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                      qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                      qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                      qProgramRebate="#thisTag.qProgramRebateInitial#"  
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      relative_path="#thisTag.dis_path#"
                      stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                      stPDFEndInfo="#thisTag.stPDFEndInfo#"
                      stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                      stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                      template_name="#thisTag.template_name#">										
			<cfelse>        
				  <!--- For PDF Letters, Call "generate_program_pdf" --->
                  <cf_generate_program_pdf
                      bAddcustomerproductnumbers="#url.custprodnum#"
                      bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                      bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                      bInsertWatermark="#thisTag.bInsertWatermark#"
                      CMID="#thisTag.contract_main_id#"
                      customerFreightUom="#thisTag.customerFreightUom#"
                      file_name="#thisTag.nameformat#"
                      lsContractMainIDs="#thisTag.List_Of_Contract_Main_IDs#"
                      current_program_letter_id="#thisTag.currentLetterID#"
                      lsDistributorNames="#thisTag.lsDistributorNames#"
                      lsDistributorIDs="#thisTag.lsDistributorIDs#" 
                      lsOperatorNames="#thisTag.lsOperatorNames#"
                      lsOperatorIDs="#thisTag.lsOperatorIDs#"
                      oAppSettings="#thisTag.appsettings#"
                      <!---preferred_fontFamily="#thisTag.preferred_fontFamily#"--->
                      qGetLetterSettings="#thisTag.getlettersettings#"
                      qGetProgramDetails="#thisTag.getprogramdetails#"
                      qGetTemplateSettings="#thisTag.gettemplatesettings#" 
                      qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                      qProgramClause="#thisTag.qProgramClauseInitial#"
                      qProgramDistributor="#variables.qProgramCurrentDistributor#"
                      qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                      qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                      qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                      qProgramRebate="#thisTag.qProgramRebateInitial#"  
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                      relative_path="#thisTag.dis_path#"
                      stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                      stPDFEndInfo="#thisTag.stPDFEndInfo#"
                      stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                      stPDFIntroInfo="#thisTag.stPDFIntroInfo#"
                      template_name="#thisTag.template_name#"
                      watermark_image="#thisTag.watermark_image#">
			</cfif>
			 
                  <cf_generate_program_xml
                      bAddcustomerproductnumbers="#url.custprodnum#"
                      bLetterDisplayFreight="#thisTag.bLetterDisplayFreight#"
                      bIncludeVolumePage="#thisTag.bIncludeVolumePage#"
                      bInsertWatermark="#thisTag.bInsertWatermark#"
                      CMID="#thisTag.contract_main_id#"
                      customerFreightUom="#thisTag.customerFreightUom#"
                      file_name="#thisTag.nameformat#"
                      prior_program_letter_id="0"
                      current_program_letter_id="#thisTag.currentLetterID#"
                      lsDistributorNames="#thisTag.lsDistributorNames#"
                      lsDistributorIDs="#thisTag.lsDistributorIDs#" 
                      lsOperatorNames="#thisTag.lsOperatorNames#"
                      lsOperatorIDs="#thisTag.lsOperatorIDs#" 
                      qProgramBidRequest="#thisTag.qProgramBidRequestInitial#"
                      qProgramClause="#thisTag.qProgramClauseInitial#"
                      qProgramDistributor="#variables.qProgramCurrentDistributor#"
                      qProgramFixedPrice="#thisTag.qProgramFixedPriceInitial#"
                      qProgramLumpSum="#thisTag.qProgramLumpSumInitial#"
                      qProgramOperator="#thisTag.qProgramOperatorInitial#"  
                      qProgramRebate="#thisTag.qProgramRebateInitial#"                      
                      qProgramGrowth="#variables.qProgramGrowthInitial#"
                      qProgramClaimRates="#variables.qProgramClaimRatesReport#"
                      relative_path="#thisTag.dis_path#"
                      stPDFBodyInfo="#thisTag.stPDFBodyInfo#"
                      stPDFEndInfo="#thisTag.stPDFEndInfo#"
                      stPDFHeaderInfo="#thisTag.stPDFHeaderInfo#"
                      stPDFIntroInfo="#thisTag.stPDFIntroInfo#">  
                  
                  <!--- D16774 8/14/08 [begin]
                  <!--- C.) Let's grab our DNA XML from our XML Custom Tag above via request scope... for future letter mods... --->
                  
                  <cfquery name="thisTag.qUpdateXML" datasource="#application.datasource#">
                    
                    UPDATE  Program_Letters
                    SET     Letter_xml = '#trim(request.sProgramLetterXML)#'
                    WHERE   Program_Letters_ID = #thisTag.currentLetterID#
                  </cfquery>
                  --->
                  <cfinvoke 
                  component="#application.oLetterManager#" 
                  method="updateLetterXML"
                  program_letter_id="#thisTag.currentLetterID#"
                  sProgramLetterXML="#trim(request.sProgramLetterXML)#">
                  <!--- D16774 8/14/08 [end] --->
                </cfloop>
              </cfif>
            </cfif>   <!---if not excludeThis--->
          </cfloop>
          
          
        </cfif>
        
        
      </cfif>
      
      <!--- =================================================================================
      ==================================== DISTRIBUTOR [END] ================================
      ================================================================================== --->
      
      <!--- =================================================================================
      ========================== INITIAL GENERATION OF LETTERS [end] ========================
      ================================================================================== --->
      
      <!--- IF this letter generation IS automatic AND caller employed lisLast logic and this iteration is the last contract_main_id for this instance... --->
      
      <cfif thisTag.bAuto AND thisTag.bListLast>
        
        
        <cfif thisTag.bFormSubmitted>
          
          <!--- back to the beginning and let 'em know... --->
          <cflocation url="/common_files/contracts/letters/auto_generate_form.cfm?lettersGenerated=1" addtoken="yes">
          <cfabort>
          
        <cfelse>
          
          <!--- back to the beginning and let 'em know... --->
          <cflocation url="#cgi.script_name#?lettersGenerated=1" addtoken="yes">
          <cfabort>
          
        </cfif>
        
        
      </cfif>
      
      
      
    </cfif>
    
    
    <!--- insert gen_opr_dis_ltr code [end] --->
    
    </cfoutput>
    <!--- Generate Letters [end] --->
    
    
  </cfcase>
  
  
  
</cfswitch>





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
    loc.letterName = replace(loc.letterName, ' ', '',  'all');

    loc.nameSuffix = "_system_generated";
  </cfscript>
  
  <!---remove old letter using the cleaned letter name prefix + letter name suffix --->
	<cfinvoke 
		component   = "#application.oLetterManager#" 
		method      = "deleteLettersbyName"
		program_id  = "#thisTag.contract_main_id#"
		letter_name = #(loc.letterName & '%' & loc.nameSuffix)#
		distributor_id = '#arguments.distributor_id#'>
  
  <!---insert current date-time into the middle of the letter name--->
  <cfreturn loc.letterName 
            & dateformat(now(),"mm_dd_yyyy") 
            & "_" 
            & timeformat(now(),"hh_mm_sstt") 
            & loc.nameSuffix>    
</cffunction>

