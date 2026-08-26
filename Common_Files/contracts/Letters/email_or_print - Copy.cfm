<cfsilent>
<!--- 
FILE: 		
FILENAME: 	Common_Files/contracts/Letters/email_or_print.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		12/01/2008 - RBL [D17619]

FUNCTIONALITY:
- This action page facilitates requests from user to either email, print, add to calendar - 1 or multiple selected letters from same list of one (1) program...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="form.letter_id" 			type="string" 	default="">
<cfparam name="form.contract_main_id" 	type="string" 	default="">

<!--- MVC V11 Edit [begin] --->
<cfscript>
 application.oController.getObject("mvc.Models.LetterManager");
</cfscript>
<!--- MVC V11 Edit [end] --->

</cfsilent>

<!--- be polite, let 'em know was up... --->
<cfif NOT len(trim(form.letter_id))>
	<cfif isDefined("form.print_letters.x")>
		<cfset variables.msg="please select letter(s) to print">
		<cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#">
		<cfabort>
	<cfelseif isDefined("form.email_letters.x")>
		<cfset variables.msg="please select letter(s) to email">
		<cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#">
		<cfabort>
  <cfelseif isDefined("form.calendar_letters.x")>
		<cfset variables.msg="please select letter(s) for calendar">
		<cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#">
		<cfabort>  
	</cfif>
</cfif>
<!--- be polite, let 'em know was up... --->

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::> TESTING WSDL/CFC ONLY [begin] <::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- <cfif isDefined("form.generateLetters")>

	<cfparam name="form.bAddCustomerProductNumbers" type="boolean" 	default="0">
  <cfparam name="form.bLetterDisplayFreight" 				type="boolean" 	default="0">
  <cfparam name="form.bIncludeVolumePage" 				type="boolean" 	default="0">
  <cfparam name="form.bInsertWatermark" 					type="boolean" 	default="0">
  <cfparam name="form.contractMainID" 						type="numeric" 	default="0">
  <cfparam name="form.customerFreightUOM"					type="string"		default="Cs">

	<!--- <cfset variables.currentURL = "http://" & cgi.http_host & CGI.SCRIPT_NAME>
	<cfset variables.generatorFolderPath = listDeleteAt(variables.currentURL,listLen(variables.currentURL,'/'),'/')>
	<cfset variables.generatorURL = listAppend(variables.generatorFolderPath,'generate_opr_dis_letters.cfm','/')> --->

	<cfoutput>
    <cfhttp url="#expandPath('generate_opr_dis_letters.cfm')#" resolveurl="no" redirect="no">
      <cfhttpparam name="CMID" 				value="#form.contractMainID#" type="url">
      <cfhttpparam name="custprodnum" value="#form.bAddCustomerProductNumbers#" type="url">
      <cfhttpparam name="freightpage" value="#form.bLetterDisplayFreight#" type="url">
      <cfhttpparam name="volumepage" 	value="#form.bIncludeVolumePage#" type="url">
      <cfhttpparam name="watermark" 	value="#form.bInsertWatermark#" type="url">
      <cfhttpparam name="freightuom" 	value="#form.customerFreightUom#" type="url">
    </cfhttp>
  	<!--- <cflocation url="view_letters.cfm?CID=#url.CMID#" addtoken="yes"> --->
  </cfoutput> --->  
  <!--- <cfabort> --->

	<!--- <cfoutput> --->

		<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED <cfset variables.currentURL = "http://" & cgi.http_host & CGI.SCRIPT_NAME>
    <cfset variables.webServiceFolderPath = listDeleteAt(currentURL,listLen(currentURL,'/'),'/')>
    <cfset variables.webServiceURL = listAppend(webServiceFolderPath,'edi.cfc?wsdl','/')> --->
  
  	<!--- <cfset variables.oEDI = createObject("component", "components.programs.letters.EDI") /> --->
  
  	<!--- <cfdump var="#variables.oEDI#" label="variables.oEDI">
    <cfabort> --->
  
  	<!--- <cfobject component="EDI" name="variables.oEDI">
  
  	<cfinvoke
      component="#variables.oEDI#"
      method="generateLetters"
      returnVariable="variables.letterGenerationStatus">
        <cfinvokeargument name="bAddCustomerProductNumbers" value="#form.bAddCustomerProductNumbers#">
        <cfinvokeargument name="bLetterDisplayFreight" value="#form.bLetterDisplayFreight#">
        <cfinvokeargument name="bIncludeVolumePage" value="#form.bIncludeVolumePage#">
        <cfinvokeargument name="bInsertWatermark" value="#form.bInsertWatermark#">
        <cfinvokeargument name="contractMainID" value="#form.contractMainID#">
    </cfinvoke>
      
      <cfdump var="#variables.letterGenerationStatus#" label="variables.letterGenerationStatus">
      <cfabort> --->
      
    	<!--- customerFreightUOM="Cs" --->
      
      <!--- <cfset variables.msg = "#form.contract_main_id# Letters Generated = #uCase(yesNoFormat(letterGenerationStatus))#">
      <cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#" addtoken="yes">
      <cfabort> --->
      
      <!--- Were letters generated? #uCase(yesNoFormat(letterGenerationStatus))#
      <br />
      <cfabort> --->
  
    <!--- <cfinvoke
      webservice="#variables.webServiceURL#"
      method="generateLetters"
      bAddCustomerProductNumbers="0"
      bIncludeVolumePage="0"
      bInsertWatermark="0"
      aProgramIDs="#variables.aProgramIDs#"> --->
    
    <!--- </cfoutput> --->
    
<!--- </cfif> --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::> TESTING WSDL/CFC ONLY [END] <::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::> EMAIL or PRINT or CALENDAR [begin] <:::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cfif isDefined("form.print_letters.x") OR isDefined("form.email_letters.x")>
<!--- CALENDAR WAIT - OR isDefined("form.calendar_letters.x") OR url.print --->

	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>

<!--- /// some bandaids for some legacy schtuff... [begin] /// --->

<!--- IF we have a request.accessstructure AND it has a user_id key AND it has something in it... --->   
<cfif isDefined("request.accessstructure") AND structKeyExists(request.accessstructure,"user_id") AND len(trim(request.accessstructure.user_id))>
	<cfset variables.user_id = request.accessstructure.user_id >
<!--- OR if we have a url.user_id and it has something in it... --->
<cfelseif isdefined("url.user_id") AND len(trim(url.user_id))>
	<cfset variables.user_id = url.user_id >
<cfelse>
	<cfset variables.user_id = variables.qProgramInfo.responsible_user_id[1]>
</cfif> 

<!--- D29497: Automated Letters Subject Change START
	Moved this two statements out of above CFIF --->
		<cfset variables.oProgramData = createObject("component","components.programs.program") />
        <cfset variables.qProgramInfo = variables.oProgramData.getProgramInfo(form.contract_main_id)>
<!--- D29497: Automated Letters Subject Change END--->
	
<!--- /// some bandaids for some legacy schtuff... [end] /// ---> 

	<cfset useLakebaseForgetuseremail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetuseremail>
	<cftry>
		<cfset getuseremail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#variables.user_id#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetuseremail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetuseremail>
<cfquery name="getuseremail" datasource="#application.datasource#">
	  select user_email from
	  _users
	  where user_id = '#variables.user_id#'
	</cfquery>
</cfif>
    
    <!--- TO DELETE request.AccessStructure.user_id --->

	<cfset fromemail = getuseremail.user_email>
	<cfset subject = appSettings.getletterssubject()>

	<cfoutput>
    
    <!--- Let's identify our comma-delimited list of url's to the pdf's we wish to merge prior to printing... --->
    <cfset variables.lsCompletePathsToPDFs = "">

	<!--- LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    LLLLLLLL    Let's loop over the list of letter_id's that the user has checked off...     LLLLLLLLLLLLLLL
    LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL [begin] LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL --->
    <cfloop list="#form.letter_id#" index="id">
      
      <!--- D16774 8/14/08 [begin]
      <!--- Get info for printing PDF Doc or emailing HTML doc [begin] --->
      <cfset useLakebaseForvariables_qGetLetterInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForvariables_qGetLetterInfo>
	<cftry>
		<cfset variables.qGetLetterInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#id#",
				"select" = "letter_path,letter_name,program_id,created_date"
			}), "letter_path,letter_name,program_id,created_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qGetLetterInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qGetLetterInfo>
<cfquery name="variables.qGetLetterInfo" datasource="#application.datasource#">
          SELECT 			letter_path,letter_name,program_id,created_date
          FROM 				program_letters
          WHERE 			program_letters.program_letters_id = #id#
        </cfquery>
</cfif>
      <!--- Get info for printing PDF Doc  or emailing HTML doc [end] --->
	  --->
      <cfset variables.qGetLetterInfo = application.oLetterManager.getAllLetterInfo(id)>
	<!--- D16774 8/14/08 [end] --->

      <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      :::::::::::::::::::::::> PRINTING [begin] <::::::::::::::::::::
      :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	  <cfif isDefined("form.print_letters.x")>

		<cfset variables.lsCompletePathsToPDFs = listAppend(variables.lsCompletePathsToPDFs,replace(variables.qGetLetterInfo.letter_path,'htm','pdf','all'),",")>

      <cfelseif isDefined("form.email_letters.x")>

          <cfif NOT len(trim(evaluate('form.email_address_#id#')))>
            <cfset variables.msg="please enter email address(es)">
            <cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#">
            <cfabort>
          </cfif>

          <!--- XXXXXXXXXX info for email [pdf] attachment [begin] XXXXXXXXXX --->
          <cfset variables.pdf_attachment_file_path = replace(variables.qGetLetterInfo.letter_path[1],'.htm','.pdf','all')>
          <cfset variables.pdf_attachment_file_name = uCase(replace(variables.qGetLetterInfo.letter_name[1],'_',' ','all'))>
          <!--- XXXXXXXXXX info for email [pdf] attachment [end] XXXXXXXXXX --->




        <!--- If custom letter (Custom 1) app setting is ON --->
	<cfif appSettings.getlettersavailable() eq 2>

		  <cfquery name="getProgramInfo" datasource="#application.datasource#">
		   SELECT Right(Contract_Number, 7) as Partial_Contract_Number, Right('000' + CAST(Revision_Version as varchar(3)), 3) as Revision_Version, Contract_Title
		   FROM Contract_Main
		   WHERE Contract_Main_ID	= <cfqueryparam cfsqltype="cf_sql_int" value="#form.contract_main_id#">	
		  </cfquery>
		
		<!--- If it is an operator letter --->
		<cfif variables.qGetLetterInfo.Letter_Type eq 1>
			
			<!--- If the letter is not for "All Operators" --->
			<cfif FindNoCase("All ",variables.qGetLetterInfo.Operator_Name) eq 0>
				<cfset OperatorName = " " & "#variables.qGetLetterInfo.Operator_Name#">
			<cfelse>
				<cfset OperatorName = "">
			</cfif>

	  		<cfset subject = getProgramInfo.Partial_Contract_Number 
								& " " 
								& getProgramInfo.Revision_Version 
								& "  " 
								& getProgramInfo.Contract_Title
								& OperatorName
								& "  " 
								& dateformat(variables.qGetLetterInfo.Created_Date,"mm_dd_yyyy")
					            & "_" 
					            & timeformat(variables.qGetLetterInfo.Created_Date,"hh_mm_sstt")  />
		
		<!--- If it is an distributor letter --->
		<cfelseif variables.qGetLetterInfo.Letter_Type eq 2>

			<!--- If the letter is not for "All distributors" --->
			<cfif FindNoCase("All ",variables.qGetLetterInfo.Distributor_Name) eq 0>
				<cfset DistributorName = " " & "#variables.qGetLetterInfo.Distributor_Name#">
			<cfelse>
				<cfset DistributorName = "">
			</cfif>

	  		<cfset subject = getProgramInfo.Partial_Contract_Number 
								& " " 
								& getProgramInfo.Revision_Version 
								& "  " 
								& getProgramInfo.Contract_Title
								& DistributorName
								& "  " 
								& dateformat(variables.qGetLetterInfo.Created_Date,"mm_dd_yyyy")
					            & "_" 
					            & timeformat(variables.qGetLetterInfo.Created_Date,"hh_mm_sstt")  />
		</cfif>

	  <cfelse>
          	<cfset subject = "#lcase(replace(variables.pdf_attachment_file_name, '_', ' ','ALL'))# program letter">
          </cfif>

          <!--- ACTION: server="mail.bigredflame.com" --->
         <!--- changed to cf_EmailWrapper 
          <cfmail to="#Replace(evaluate('form.email_address_#id#'), ' ', ',', 'ALL')#" from="#fromemail#" subject="#subject#" type="html">
            #variables.pdf_attachment_file_name# <b>PROGRAM LETTER</b> is attached...
            <cfmailparam file="#variables.pdf_attachment_file_path#">
          </cfmail>
         --->
	 <!--- By using "programLettersEmail=1", the logic for "from" and "replyTo" is populated on "EmailWrapper.cfm"  --->
          <cf_EmailWrapper 
		to="#Replace(evaluate('form.email_address_#id#'), ' ', ',', 'ALL')#" 
		from="#fromemail#" 
		subject="#subject#" 
		type="HTML"
		messagetype="1" 
		generatedby="1" 
		apparea="1"
		programLettersEmail="1">

		<!--- If custom letter (Custom 1) app setting is ON --->
		<cfif appSettings.getlettersavailable() eq 2>	
		#subject# <b>PROGRAM LETTER</b> is attached...
		<cfelse>
		#variables.pdf_attachment_file_name# <b>PROGRAM LETTER</b> is attached...
		</cfif>
		<cf_emailwrapperparam file = "#variables.pdf_attachment_file_path#" store="yes" />
          </cf_EmailWrapper>

			<!--- D17619 [begin] RBL 12/01/08 --->
			<cfif listLen(form.letter_id,',') GT 1>
                <cfset variables.msg="#listLen(form.letter_id,',')# letters emailed">
            <cfelse>
                <cfset variables.msg="#listLen(form.letter_id,',')# letter emailed">
            </cfif>
            <!--- D17619 [end] RBL 12/01/08 --->

					<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
					:::::::::::::::::::::::> PRINTING [end] <::::::::::::::::::::::
					:::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	  <cfelseif isDefined("form.calendar_letters.x")>

					<!--- CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
					CCCCCCCCCCCCCC Calendar - On Deck [begin] CCCCCCCCCCCCCCCCC
					CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
          
            <!--- <cfparam name="user" default="Brad Lee">
            <cfparam name="password" default="1234Music" intra/ intra\blee>
             --->
            <cfparam name="user_name" 				default="blee"><!--- intra\blee intra/blee blee Brad Lee #lcase(getuseremail.user_email)# --->
            <cfparam name="user_pwd" 					default="1234Music"><!--- 1234Music parrothead --->
            <cfparam name="exchangeServerIP" 	default="mail01.intra.awayx.com">
            <!--- app value for server? --->
        
            <!--- ACTION: TO DELETE - NO combos: Brad Lee|1234Music Brad Lee|parrothead intra/blee|1234Music intra\blee|1234Music ?
            #lcase(trim(getuseremail.user_email))#|1234Music --->
        
            <!--- Open a connection to the exchange server by specifying the required user credentials --->
            <cfexchangeConnection
                action="open"
                username ="#user_name#"
                password="#user_pwd#"
                server="#exchangeServerIP#"
                connection="programLetterConnection">
    
              <!--- X1.) Let's grab our XML data typed variable representing THIS letter's DNA... --->
              <cfset useLakebaseForvariables_qGetXML = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_letters")>
<cfif useLakebaseForvariables_qGetXML>
	<cftry>
		<cfset variables.qGetXML = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_letters", {
				"program_letters_id" = "eq.#id#",
				"select" = "letter_xml"
			}), "letter_xml"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qGetXML = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qGetXML>
<cfquery name="variables.qGetXML" datasource="#application.datasource#">
                SELECT	Letter_xml
                FROM		Program_Letters
                WHERE 	Program_Letters.Program_Letters_ID = #id#
              </cfquery>
</cfif>
			  <!--- TECH NOTE: If this comes back, use the application.oLetterManager... --->
              
              <!--- X2.) Let's parse our XML variable with which to generate our initial edit form for THIS letter... --->
              <cfset xProgramXML = xmlParse(variables.qGetXML.Letter_xml[1])>
              
              <!--- X3.) Include our XML script to evaluate THIS letter's DNA via xmlSearch() --->
              <cfinclude template="inc_xml_script.cfm"> 
      
              <!--- Outlook Calendar - Program Letter information --->
              <cfset programLetterInfo = structNew()>
              <cfset programLetterInfo.startTime="#dateFormat(contractStartDateFromXML,'mm/dd/yy hh:mm:ss')#">
              <cfset programLetterInfo.endTime="#dateFormat(contractEndDateFromXML,'mm/dd/yy hh:mm:ss')#">
              <cfset programLetterInfo.subject="Contract Number: #contractNumberFromXML# #dateFormat(contractStartDateFromXML, 'm/d/yy')# - #dateFormat(contractEndDateFromXML, 'm/d/yy')# Program ID:#variables.qGetLetterInfo.program_id# Letter ID:#id# Created: #dateFormat(variables.qGetLetterInfo.created_date[1],'mm/dd/yy')#">
              <cfset programLetterInfo.message="#variables.qGetLetterInfo.letter_name#">
              <!--- <cfset programLetterInfo.requiredAttendees="Brad">
              <cfset programLetterInfo.optionalAttendees="Paul, Karen"> --->
              <cfset programLetterInfo.location="#application.companyname#">
                  
              <!--- Create Calendar Event using the event information passed in the struct. Do NOT dynamically name this connection. Safer not to in the long run. --->
              <cfexchangeCalendar
                  action="create"
                  connection="programLetterConnection"
                  event="#programLetterInfo#"
                  result="lid">
    
            <!--- IMPORTANT! It's polite to close the door behind you, & in this case VERY important so as to not leave unused connections open to the exchange server. --->
            <cfexchangeConnection
                action="close"
                connection="programLetterConnection">
                
            <!---- Display Event --->
            Program Letter: #lid# added to Outlook Calendar<br>
            
        CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
		CCCCCCCCCCCCCC Calendar - On Deck [end] CCCCCCCCCCCCCCCCCC
		CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --->

		  <cfset variables.msg="selected letters to calendar">

      </cfif>
  
    </cfloop>
    <!--- LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    LLLLLLLL    Let's loop over the list of letter_id's that the user has checked off...     LLLLLLLLLLLLLLL
    LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL [end] LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL --->
		
	  <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      :::::::::::::::::::::::> PRINTING [begin] <::::::::::::::::::::
      :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	 <cfif isDefined("form.print_letters.x")>

		  <!--- Let's Merge PDF documents into an output PDF file --->
          <cfpdf
              action = "merge"
              destination="combined#form.contract_main_id#PDFPrint.pdf"
              keepBookmark = "yes"
              overwrite="yes">
              <cfloop list="#variables.lsCompletePathsToPDFs#" index="currentPDFCompletePath">
              	<cfif fileExists(currentPDFCompletePath)>
                	<cfpdfparam source="#currentPDFCompletePath#">
                </cfif>
              </cfloop>
          </cfpdf>    
    
		  <cfif isPDFFile("combined#form.contract_main_id#PDFPrint.pdf")>
            
            <cfpdf
              action = "thumbnail"
              source = "combined#form.contract_main_id#PDFPrint.pdf"
              format = "png"
              imagePrefix = "tn"
              overwrite = "yes"
              pages = "1"
              password = "#trim(form.contract_main_id)#"
              resolution= "high"
              scale = "30"
              transparent = "yes">

				<!--- || I.) Create DDX xml file... #trim(form.contract_main_id)#  --->
            	<cfxml variable="thisTag.xPDFDDX">
                 <DDX xmlns="http://ns.adobe.com/DDX/1.0/"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://ns.adobe.com/DDX/1.0/ coldfusion_ddx.xsd">
                    <PDF result="output1">
                        <TableOfContents
                              maxBookmarkLevel="infinite"
                              createLiveLinks="true"
                              includeInTOC="true"
                              bookmarkTitle="Table of Contents">
                              <Watermark opacity="50%">
                              	<StyledText><p font="Arial,24pt"><b><_LastPageNumber/></b> Pages to Print</p></StyledText>
                              </Watermark>
                              <TableOfContentsEntryPattern applicableLevel="1" >
                              	<StyledText>
                                	<p font="Arial,12pt"><_BookmarkTitle/>
                                    <leader 			leader-pattern="dotted"/>
                                    <_BookmarkPageCitation/>
                                    </p>
                                </StyledText>
                              </TableOfContentsEntryPattern>
                              <TableOfContentsEntryPattern applicableLevel="2" >
                              	<StyledText>
                                	<p font="Arial,14pt" >Section<_BookmarkTitle/>
                                    	<leader leader-pattern="space"/>
                                        <_BookmarkPageCitation/>
                                     </p>
                                 </StyledText>
                               </TableOfContentsEntryPattern>
                              <Header>
                              	<Center>
                                	<StyledText>
                                    	<p color="##990000" font="Arial,18pt"><b>Table of Contents for Selected Letters to Print</b></p>
                                    </StyledText>
                                </Center>
                              </Header>
                              <Footer>
                                  <Right>
                                   <StyledText>
                                    <p color="##990000" font="Arial,14pt">#dateFormat(now(),"mmmm dd, yyyy")#</p>
                                   </StyledText>
                                  </Right>
                           	  </Footer>
                           </TableOfContents>
                        <PDF source="doc1"/>
                    </PDF>   
                 </DDX>
            	</cfxml>
                
                <!--- <PDF source="doc2"/> --->

				<!--- remove CRs from xml and convert to string to write our xml file... --->
                <cfset thisTag.sPDFDDX=toString(stripCR(thisTag.xPDFDDX))>
                
                <cfset thisTag.ddx_xml_file_path_string = "/common_files/contracts/letters/combined" & form.contract_main_id & "PDFPrint.ddx">
                <cfset thisTag.ddx_xml_file_path = lcase(expandPath(thisTag.ddx_xml_file_path_string))>
                
                <!--- KEEP THIS [begin] --->
                <cfparam name="thisTag.bWriteDDXXMLfileToDisk" type="boolean" default="1">
                <cfif thisTag.bWriteDDXXMLfileToDisk>
                    <!--- Save the XML document to disk [XML]> --->
                    <cftry>
                        <!--- get in line... --->
                        <cflock timeout="60" type="exclusive">
                            <cffile action="write" nameconflict="overwrite" file="#thisTag.ddx_xml_file_path#" output="#thisTag.sPDFDDX#">
                        </cflock>
                        <!--- IF we have an 'oops'... ---> 
                        <cfcatch type="any">
                            <b>#cfcatch.Detail#</b>
                        </cfcatch>
                    </cftry>
                </cfif>
                <!--- KEEP THIS [end] --->
                
                <cfif isDDX(thisTag.ddx_xml_file_path)>
                
                    <!--- setup the mapping for the source PDF files --->
                    <cfset stInput = structNew() />
                    <cfset stInput.doc1 = "combined#form.contract_main_id#PDFPrint.pdf" />
                    
                    <!--- setup the mapping for the result PDF files --->
                    <cfset stOutput = structNew() />
                    <cfset stOutput.output1 = "combined#form.contract_main_id#PDFPrint.pdf" />
                    
                      <!--- use the cfpdf tag to process the DDX document --->
                      <cfpdf action="processDDX" 
                           ddxFile="#thisTag.ddx_xml_file_path#"
                           inputFiles="#stInput#"
                           outputFiles="#stOutput#"
                           name="result" />
                
                    We HAVE a valid DDX xml document.
                <cfelse>
                    We do NOT have a valid DDX xml document.
                </cfif>
                
                <cfpdf action = "protect"
                  source = "combined#form.contract_main_id#PDFPrint.pdf"
                  newOwnerPassword = "#trim(form.contract_main_id)#"
                  password="#trim(form.contract_main_id)#"
                  permissions = "AllowAssembly,AllowDegradedPrinting,AllowPrinting,AllowScreenreaders,AllowSecure"
                  destination = "combined#form.contract_main_id#PDFPrint.pdf"
                  encrypt = "RC4_40"
                  overwrite = "yes">
    
    			<!--- D17619 [begin] RBL 12/01/08 --->
                <cfset variables.msg="PDF print">
                <cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#&print=1" addtoken="yes">
                <cfabort>
                <!--- D17619 [end] RBL 12/01/08 --->
              
          <cfelse>
          
            <cfset variables.msg="No PDFs to print"> 
             
          </cfif>
        
      </cfif>
      <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      :::::::::::::::::::::::> PRINTING [end] <::::::::::::::::::::::
      :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

		<!--- D17619 [begin] RBL 12/01/08 --->
		<cflocation url="view_letters.cfm?msg=#variables.msg#&CID=#form.contract_main_id#" addtoken="yes">
        <cfabort>
        <!--- D17619 [end] RBL 12/01/08 --->

	</cfoutput>
  
</cfif>
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::> EMAIL or PRINT or CALENDAR [end] <::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->