<!--- 
FILE: 		
FILENAME: 	Common_Files/contracts/Letters/show_opr_dis_letters.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		03/16/2009 - RBL [MVC v11]

FUNCTIONALITY:
- This file displays the list of generated letters to the user. It also offers options to email or print one or more selected letters from same list...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="url.bAll"						type="boolean"	default="0">
<cfparam name="form.letter_id"					type="numeric" 	default="0">
<cfparam name="url.msg"							type="string"	default="">
<!--- this is a great example of something that should be numeric defaulted to 0. I am sure if I do this it will throw error, so I reluctantly will not... RBL --->
<cfparam name="url.CID" 										default="">
<!--- this should be scoped --->
<cfparam name="emailaddresslist" 				type="string" 	default="">
<cfparam name="variables.bLettersAvailable" 	type="boolean" 	default="0">
<cfparam name="url.print"						type="boolean"	default="0">

<cfparam name="url.delete"						type="boolean"	default="0">
<cfparam name="url.LID"							type="numeric"	default="0">
<cfparam name="reportType"						type="string"	default="">
<!--- <cfparam name="url.PTID"						type="string"	default=""> --->


<cfinclude template="include_display_letters.cfm">

<cfif url.delete>

	<cfif url.bAll>

		<!--- LID=#url.LID#& --->

        <cfwindow
          center="true"
          closable="false"
          draggable="true"
          height=70
          initShow="true"
          modal="true"
          name="pdfDeletion"
          resizable="false"
          source="delete_letter.cfm?CID=#url.CID#&bAll=1"
          title="ALL PDF Letters for Program:#url.CID# Are NOW Deleted!"
          width=340/>
      
      <cfelse>
      
      	<cfwindow 
          center="true"
          closable="false"
          draggable="true"
          height=70
          initShow="true"
          modal="true"
          name="pdfDeletion"
          resizable="false"
          source="delete_letter.cfm?LID=#url.LID#&CID=#url.CID#&bAll=0"
          title="PDF Letter #url.LID# Is NOW Deleted!"
          width=340/>
      
      </cfif>
      
      <cfabort>
  
</cfif>

<!--- Tech Note D13826 and D14567 RBL - Deal Letters TOTALLY reworked. Lots of deprecated code below... --->

<!--- MVC V11 Edit [begin] --->
<cfscript>
 application.oController.getObject("mvc.Models.LetterManager");
</cfscript>
<!--- MVC V11 Edit [end] --->

<head>
	<title>Letters</title>
</head>
<body bgcolor="White" text="Black" link="Blue" vlink="Blue" alink="Red" leftmargin="0" topmargin="0" onLoad="popupInit()">
<script language="JavaScript" src="/script/javascript/string_functions.js"></script>
<script language="JavaScript" src="/script/javascript/string_validations.js"></script>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 11px;}
	#header {font-size: 12px;}
	.cLinks{font-size:13px;}
</style>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">

<CF_MessageWindow>	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif len(trim(URL.CID))>
	<cfset CSL_Contract_Main_ID = URL.CID>
</cfif>
<cfset CSL_CallingPageCode = "letters">

<!--- IF we got nuttin... [begin] (1 of 2) --->
<cfquery name="variables.qAllLtr" datasource="#application.datasource#">
  SELECT	COUNT(Program_Letters_ID) as netCount
  FROM		Program_Letters
  WHERE 	program_id = '#URL.CID#'
</cfquery>
<!--- nada... --->
<cfif NOT variables.qAllLtr.netCount>
    <CF_CRYP type="en" string="#URL.CID#" key="#request.key#" return="abstr">
    <cfset EncryptedCID = abstr.value>
    <!--- redirect --->
	<cflocation url="/Common_Files/contracts/contract_letters.cfm?CID=#EncryptedCID#" addtoken="yes">
    <cfabort>
</cfif>
<!--- IF we got nuttin... [end] --->

<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left: 10px; top: 0px">
  	<cfinclude template="/common_files/contracts/contract_status_legend.cfm">
  </div>
<cfelse>
	<cfinclude template="/common_files/contracts/contract_status_legend.cfm">
</cfif>

<cfif application.programlayout EQ 1>
 <div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 180px; top: 10px;">
</cfif>
   
<cfset FORM.Contract_Main_ID = CSL_Contract_Main_ID>

<!--- create some temporary objects... RBL --->
<cfset variables.oProgramData = createObject("component","components.programs.program") />
<cfset variables.oUserData = createObject("component","components.user.usermanager") />
<!--- retreive the query data... RBL --->
<cfset variables.qProgramInfo = variables.oProgramData.getProgramInfo(CSL_Contract_Main_ID)>


<cfset variables.qUserInfo = variables.oUserData.getUser(variables.qProgramInfo.responsible_user_id[1])>

<cfset variables.authorRSPFirstName = trim(variables.qUserInfo.name_first[1])>
<cfset variables.authorRSPLastName = trim(variables.qUserInfo.name_last[1])>
<cfset variables.authorRSPEmail = trim(variables.qUserInfo.user_email[1])>
<!---
<cfquery name="variables.qGetAuthorID" datasource="#application.datasource#">
	SELECT User_ID
	FROM dbo._Users
	WHERE Name_First = '#variables.authorRSPFirstName#'
	AND Name_Last = '#variables.authorRSPLastName#'
</cfquery>
<cfset variables.authorRSPID = variables.qGetAuthorID.User_ID />
--->

<cfset variables.authorRSPID = variables.qProgramInfo.responsible_user_id />

<!--- We do NOT want the user_id visible in the pdf info. [begin]
ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
Moved here from inside loop. Now it is the RSP by Program.
Ask Karen if we wish to have detail by user/pdf generator? [end] --->

<cfinclude template="/common_files/contracts/minimal_contract_info.cfm">

<cfoutput>

<form action="email_or_print.cfm" method="post" name="LetterForm">
<!--- 
Dev Note:69439 - When user wants to email claim rates report and letter in one email,we need to send below hidden variables also.
--->
<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
	<input type="hidden" name="attachments" value="#form.attachments#">
	<input type="hidden" name="clause" value="#form.clause#">
	<input type="hidden" name="mode" value="#form.mode#">
	<input type="hidden" name="paidToList" value="#form.paidToList#">
	<input type="hidden" name="paid_To" value="#form.paid_To#">
	<input type="hidden" name="program_id_list" value="#form.program_id_list#">
	<input type="hidden" name="reportType" value="#form.reportType#">
	<input type="hidden" name="skipLock" value="1">
	<input type="hidden" name="subject" value="#form.subject#">
</cfif>

<cfset bShowAllLetters = 1>
<cfset FilterByID = "">
<!--- Dev Note: 69439 - When user wants to email just claim rates report OR claim rates report AND program letter in one email.
In this case reportType is "ProgramClaimRatesReportAndLetters".
Note: These are the steps:
- User creates a "claim rate" report for a distributor.
- User clicks on a link called "email cmail rates and letters".
- User will only see the letter generated for that distributor
- User wull select the letter and click on "email aditional contacts"
- User will select the email id of the distributor and send the email.
--->
<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
	<cfset bShowAllLetters = 0>
	<cfset FilterByID = form.PaidToList>
</cfif>
<!--- ==========================================================
===================== Operator [begin] =========================
=========================================================== --->
<cfinvoke 
    component="#application.oLetterManager#" 
    method="getLetters"
    program_id="#CSL_Contract_Main_ID#"
    letter_type="1"
    order_by_clause="program_letters.operator_name,created_date DESC"	
	showAllLetters="#bShowAllLetters#"
    returnVariable="variables.qGetOprLetters">

<cfif variables.qGetOprLetters.recordCount>

  <!--- D17619 [begin] RBL 12/01/08 style="margin-left:30px;" --->
  <font color="##ff0000"><i>#url.msg#</i></font>
  <!--- D17619 [end] RBL 12/01/08 --->
  
  <!--- width="800" --->
  <table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;">
    <tr>
      <td colspan="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>9<cfelse>8</cfif>" style="font-size:14px;" bgcolor="##C6FFC6"><b>#application.returned_customer_setting.operator_label_singular# Section</b></td>
    </tr>
    <tr>
      <td width="50" style="font-size: 12px;"><input name="opr_check_all" type="checkbox" onClick="selectall('O');"><span id="checkopr"></span></td>
      <td width="80" wrap style="font-size: 12px; font-weight:bold">Letters</td>
      <td width="120" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.operator_label_singular# Name</td>
      <td width="120" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.distributor_label_singular# Name</td>
      <td width="80" style="font-size: 12px; font-weight:bold">Date</td>
      <td width="100" nowrap style="font-size: 12px; font-weight:bold">Created By</td>
      <td width="120" style="font-size: 12px; font-weight:bold" nowrap>Email Addresses</td>
      <!--- <td width="30" style="font-size: 12px; font-weight:bold">Print</td> --->
	  <!--- Letter modification is not available for HTML letters --->
	  <cfif appSettings.getlettersavailable() neq 2>
      <td width="80" style="font-size: 12px; font-weight:bold" align="center">Modify</td>
	  </cfif>
      <!--- IF the current user is the same as the author... --->
      <cfif request.accessStructure.User_ID EQ variables.authorRSPID>
      	<td width="80" style="font-size: 12px; font-weight:bold" align="center">Delete</td>
      </cfif>
    </tr>
    
    <cfset variables.bLettersAvailable = 1>
    <cfset  variables.bNoDistributors = 0>
    <cfloop query="variables.qGetOprLetters">
    
      <!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
      <cfif application.oLetterManager.letterExistsInDBwithXMLandAsFile(variables.qGetOprLetters.program_letters_id)> 
      <!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
    
		  <!--- <cfset current_opr_letter_name_htm = trim(variables.qGetOprLetters.letter_name) & '.htm'>
          <cfset current_opr_letter_name_htm_tip = lCase(replace(current_opr_letter_name_htm,'_',' ','all'))>
          <cfset current_opr_absolute_path_htm = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_htm#"> --->
          <cfset current_opr_letter_name_pdf = trim(variables.qGetOprLetters.letter_name) & '.pdf'>
          <cfset current_opr_letter_name_pdf_tip = lCase(replace(current_opr_letter_name_pdf,'_',' ','all'))>
          <cfset current_opr_absolute_path_pdf = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_pdf#">
          <!--- <cfset current_opr_letter_name_xml = trim(variables.qGetOprLetters.letter_name) & '.xml'>
          <cfset current_opr_letter_name_xml_tip = lCase(replace(current_opr_letter_name_xml,'_',' ','all'))>
          <cfset current_opr_absolute_path_xml = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_xml#"> --->
          
          <cfset current_opr_absolute_path = application.doc_path & '\data_files\created\contracts\letters\output\operators\' & CSL_Contract_Main_ID & '\' & current_opr_letter_name_pdf>
          
          <cfif fileExists(current_opr_absolute_path)>
            <cfpdf
              action = "getinfo"
              name = "stPDFInfo" 
              source = "#current_opr_absolute_path#"
              password = "#CSL_Contract_Main_ID#">
              
            <!--- This can be replaced with the selectAnyData() method in MVC V2.
            Needs to be inside loop because of the possibility of various authors.
            We do NOT want the user_id visible in the pdf info. [begin]
			ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
			Moved up top by program for now. Ask Karen if we wish to have detail by user/pdf generator?
			
            <cfset variables.authorRSPFirstName = trim(listGetAt(stPDFInfo.author,1," "))>
            <cfset variables.authorRSPLastName = trim(listGetAt(stPDFInfo.author,2," "))>
            <cfquery name="variables.qGetAuthorID" datasource="#application.datasource#">
                SELECT User_ID
                FROM dbo._Users
                WHERE Name_First = '#variables.authorRSPFirstName#'
                AND Name_Last = '#variables.authorRSPLastName#'
            </cfquery>
            <cfset variables.authorRSPID = variables.qGetAuthorID.User_ID />
			
            ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
			This can be replaced with the selectAnyData() method in MVC V2.
            Needs to be inside loop because of the possibility of various authors.
            We do NOT want the user_id visible in the pdf info. [end] --->
    
						<tr>
								<td width="50"><span id="error_oprcheckbox"></span><span id="checkAllOprLetters"><input name="letter_id" type="checkbox" value="#program_letters_id#"></span></td>
								<td width="80">
									<!--- <a href="#current_opr_absolute_path_htm#" target="htm" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_opr_letter_name_htm_tip#')" onMouseOut="popOut()"><img src="images/icon_TXT.gif" border="0"></a>   --->
									<a href="/GetDocument.cfm?FilePath=data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_pdf#" style="cursor:pointer;" onMouseOver="initTheTooltip('VIEW and/or PRINT Letter #variables.qGetOprLetters.program_letters_id# #current_opr_letter_name_pdf_tip# [#stPDFInfo.TotalPages# Pages]')" onMouseOut="popOut()">
										<img src="images/icon_PDF.gif" border="0">
									</a>
									<!---  <a href="#current_opr_absolute_path_xml#" target="xml" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_opr_letter_name_xml_tip#')" onMouseOut="popOut()"><img src="images/icon_XML.gif" border="0"></a> --->
								</td>
								<td width="120">#operator_name#</td>
								<td width="120"><cfif Distributor_name eq "">&nbsp;</cfif>#Distributor_name#</td>
								<td width="80">#dateformat(variables.qGetOprLetters.created_date,"mm/dd/yyyy")#</td>
								<td width="100" nowrap>#user_name#<cfif findNoCase("system_generated",letter_name,1)>(S)</cfif></td>
								<td width="120"><span id="checkAllOprEmail"><input type="text" name="email_address_#program_letters_id#"  size="30"  value="#variables.authorRSPEmail#"></span><span id="error_oprAddress"></span></td>
								<!--- <td width="30">
								<a style="cursor:pointer;" href="email_or_print.cfm?print=1&lid=#program_letters_id#&cid=#CSL_Contract_Main_ID#"><img src="/images/printImg.gif" alt="PRINT #lCase(current_opr_letter_name_pdf_tip)#"></a></td> --->
								<!--- If "no distributors" option was selected in the letter, then pass that value in the "variables.bNoDistributors" variable --->
		 <!--- Letter modification is not available for HTML letters --->
		 <cfif appSettings.getlettersavailable() neq 2>
		<td width="80" align="center">
		   <cfif variables.qGetOprLetters.Distributor_Name eq 'No #application.returned_customer_setting.distributor_label_plural#'>
			<cfset variables.bNoDistributors = 1>
		   </cfif>
               <a href="all_opr_doc_modules_edit_form.cfm?CMID=#variables.qGetOprLetters.program_id#&LID=#variables.qGetOprLetters.program_letters_id#&pages=#stPDFInfo.TotalPages#&bNoDistributors=#variables.bNoDistributors#" style="cursor:pointer;"><img src="/images/pm_edit.gif" border="0" title="MODIFY Letter #variables.qGetOprLetters.program_letters_id# #lCase(current_opr_letter_name_pdf_tip)# [#stPDFInfo.TotalPages# Pages]"></a>
                </td>
		 </cfif>
                <!--- D17454 [begin] --->
                <!--- IF the current user is the same as the author... --->
                <cfif request.accessStructure.User_ID EQ variables.authorRSPID>
                    <td width="80" align="center">
                    	<!--- &PTID=#thisProgramID# --->
                          <a href="#includeLettersFilename#?LID=#variables.qGetOprLetters.program_letters_id#&CID=#variables.qGetOprLetters.program_id#&delete=1" style="cursor:pointer;"><!--- <img src="/common_files/contracts/letters/images/icon_delete.jpg" border="0" alt="DELETE Letter #variables.qGetOprLetters.program_letters_id# #lCase(current_opr_letter_name_pdf_tip)# [#stPDFInfo.TotalPages# Pages]"> --->
                          <img src="/Images/scissor.gif" width="14" height="9" border="0" title="DELETE Letter #variables.qGetOprLetters.program_letters_id# #lCase(current_opr_letter_name_pdf_tip)# [#stPDFInfo.TotalPages# Pages]"></a>                    
                    </td>
                </cfif>
                <!--- D17454 [end] --->
            </tr>
            
          </cfif>
    
          <input type="hidden" name="letter_path_#program_letters_id#" value="#variables.qGetOprLetters.letter_path#">
          <input type="hidden" name="Include_File_path" value="/data_files/created/contracts/letters/output/operators/#CSL_Contract_Main_ID#/#current_opr_letter_name_pdf#">
      
      <!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
      <cfelse>
      
      	<cfscript>
			application.oLetterManager.deletePDFLetterInDBandFile(variables.qGetOprLetters.program_letters_id);
		</cfscript>
      <!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
      
      <!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
      </cfif>  
      <!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->

    </cfloop>
  </table>
</cfif>
<!--- ==========================================================
===================== Operator [end] ===========================
=========================================================== --->
<br />

<!--- ==========================================================
===================== Distributor [begin] ======================
=========================================================== --->
<cfinvoke 
    component="#application.oLetterManager#"
    method="getLetters"
    program_id="#CSL_Contract_Main_ID#"
    letter_type="2"
	FilterByID="#FilterByID#"
    order_by_clause="program_letters.Distributor_Name,created_date DESC"
    returnVariable="variables.qGetDisLetters">
    <!--- D16774 8/14/08 [end] ---> 

<cfif variables.qGetDisLetters.recordCount>

<!---	When there are only distributor letters and not operator letters, then we still need to show message: 'x letters successfully emailed' when the user emails the letters.
	When there are both (distributor and operators), then this message at the top of the page (before the operator section) is valid for both on emailing.
--->
<cfif variables.qGetOprLetters.recordCount eq 0>
<font color="##ff0000"><i>#url.msg#</i></font>
</cfif>

<cfset getdistributoremail = application.oLetterManager.getdistributoremail(CSL_Contract_Main_ID)>
<!--- D16774 8/14/08 [end] --->
 
  <table width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>750</cfif>" class="maintable" border="0" cellpadding="0" cellspacing="0" style="margin-left:0px;">
    <tr>
      <td colspan="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>9<cfelse>8</cfif>" style="font-size: 14px;" bgcolor="##C6FFC6"><b>#application.returned_customer_setting.distributor_label_singular# Section</b></td>
    </tr>
    <tr>
      <td width="50" style="font-size: 12px;"><input name="dis_check_all" type="checkbox" onClick="selectall('D');"><span id="checkdis"></span></td>
      <td width="80" style="font-size: 12px; font-weight:bold">Letters</td>
      <td width="120" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.distributor_label_singular# Name</td>
      <td width="120" style="font-size: 12px; font-weight:bold" wrap>#application.returned_customer_setting.operator_label_singular# Name</td>
      <td width="80" style="font-size: 12px; font-weight:bold">Date</td>
      <td width="100" nowrap style="font-size: 12px; font-weight:bold">Created By</td>
      <td width="120" style="font-size: 12px; font-weight:bold" nowrap>Email Addresses</td>
      <!--- <td width="30" style="font-size: 12px; font-weight:bold">Print</td> --->
	  <!--- Letter modification is not available for HTML letters --->
	  <cfif appSettings.getlettersavailable() neq 2>
      <td width="80" style="font-size: 12px; font-weight:bold" align="center">Modify</td>
	  </cfif>
      <!--- IF the current user is the same as the author... --->
      <cfif request.accessStructure.User_ID EQ variables.authorRSPID>
      	<td width="80" style="font-size: 12px; font-weight:bold" align="center">Delete</td>
      </cfif>
    </tr>
    <cfset variables.bLettersAvailable = 1>

    <cfloop query="variables.qGetDisLetters">
    
      <!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
      <cfif application.oLetterManager.letterExistsInDBwithXMLandAsFile(variables.qGetDisLetters.program_letters_id)> 
      <!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
    	
		  <!--- <cfset current_dis_letter_name_htm = trim(variables.qGetDisLetters.letter_name) & '.htm'>
          <cfset current_dis_letter_name_htm_tip = lCase(replace(current_dis_letter_name_htm,'_',' ','all'))>
          <cfset current_dis_absolute_path_htm = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_htm#"> --->
          <cfset current_dis_letter_name_pdf = trim(variables.qGetDisLetters.letter_name) & '.pdf'>
          <cfset current_dis_letter_name_pdf_tip = lCase(replace(current_dis_letter_name_pdf,'_',' ','all'))>
          <cfset current_dis_absolute_path_pdf = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_pdf#">
          <!--- <cfset current_dis_letter_name_xml = trim(variables.qGetDisLetters.letter_name) & '.xml'>
          <cfset current_dis_letter_name_xml_tip = lCase(replace(current_dis_letter_name_xml,'_',' ','all'))>
          <cfset current_dis_absolute_path_xml = "#Application.Doc_Mapping#/data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_xml#"> --->
          
          <!--- #application.doc_path#\data_files\created\contracts\letters\output\operators\#CSL_Contract_Main_ID#\#current_dis_letter_name_pdf# --->
          
          <cfset current_dis_absolute_path = application.doc_path & '\data_files\created\contracts\letters\output\distributors\' & CSL_Contract_Main_ID & '\' & current_dis_letter_name_pdf>
      
		<cfif fileExists(current_dis_absolute_path)>
        
            <cfpdf
              action = "getinfo"
              name = "stPDFInfo" 
              source = "#current_dis_absolute_path#"
              password = "#CSL_Contract_Main_ID#">
    
            <!--- This can be replaced with the selectAnyData() method in MVC V2.
            Needs to be inside loop because of the possibility of various authors.
            We do NOT want the user_id visible in the pdf info. [begin]
			ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
			Moved up top by program for now. Ask Karen if we wish to have detail by user/pdf generator?
			
            <cfset variables.authorRSPFirstName = trim(listGetAt(stPDFInfo.author,1," "))>
            <cfset variables.authorRSPLastName = trim(listGetAt(stPDFInfo.author,2," "))>
            <cfquery name="variables.qGetAuthorID" datasource="#application.datasource#">
                SELECT User_ID
                FROM dbo._Users
                WHERE Name_First = '#variables.authorRSPFirstName#'
                AND Name_Last = '#variables.authorRSPLastName#'
            </cfquery>
            <cfset variables.authorRSPID = variables.qGetAuthorID.User_ID />
			
            ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION ACTION
			This can be replaced with the selectAnyData() method in MVC V2.
            Needs to be inside loop because of the possibility of various authors.
            We do NOT want the user_id visible in the pdf info. [end] --->
              
			<cfif len(trim(variables.qGetDisLetters.distributor_id))>
                <cfset useLakebaseForgetdisemailaddress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getdistributoremail")>
<cfif useLakebaseForgetdisemailaddress>
	<cftry>
		<cfset getdisemailaddress = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getdistributoremail", {
				"bsa_foodservice_customers_id" = "eq.#variables.qGetDisLetters.distributor_id#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetdisemailaddress = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetdisemailaddress>
<cfquery name="getdisemailaddress" dbtype="query">
                select distinct user_email from
                getdistributoremail 
                where bsa_foodservice_customers_id = '#variables.qGetDisLetters.distributor_id#'
                </cfquery>
</cfif>
                <cfset emailaddresslist = ValueList(getdisemailaddress.user_email)>
            <cfelse>
            	<cfset emailaddresslist = "">
            </cfif>
            <tr id="TR_Dis_Letters">
                <td width="50"><span id="error_discheckbox"></span><span id="checkAllDisLetters"><input name="letter_id" type="checkbox" value="#program_letters_id#"></span></td>
								<td width="80">
									<!--- <a href="#current_dis_absolute_path_htm#" target="htm" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_dis_letter_name_htm_tip#')" onMouseOut="popOut()"><img src="images/icon_TXT.gif" border="0"></a>  --->
									<a href="/GetDocument.cfm?FilePath=data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_pdf#" style="cursor:pointer;" onMouseOver="initTheTooltip('VIEW and/or PRINT Letter #variables.qGetDisLetters.program_letters_id# #current_dis_letter_name_pdf_tip#  [#stPDFInfo.TotalPages#] Pages')" onMouseOut="popOut()">
										<img src="images/icon_PDF.gif" border="0">
									</a>
									<!---  <a href="#current_dis_absolute_path_xml#" target="xml" style="cursor:pointer;" onMouseOver="initTheTooltip('#current_dis_letter_name_xml_tip#')" onMouseOut="popOut()"><img src="images/icon_XML.gif" border="0"></a>  --->
								</td>
								<td width="120">#Distributor_name#</td>
								<td width="120"><cfif operator_name eq "">&nbsp;</cfif>#operator_name#</td>
								<td width="80">#dateformat(variables.qGetDisLetters.created_date,"mm/dd/yyyy")#</td>
								<td width="100" nowrap>#user_name#<cfif findNoCase("system_generated",letter_name,1)>(S)</cfif></td>
								<td width="120"><span id="checkAllDisEmail"><input type="text" name="email_address_#program_letters_id#" size="30" value="#emailaddresslist#"></span><span id="error_disAddress"></span></td>
								<!--- <td width="30">
								<a style="cursor:pointer;" href="email_or_print.cfm?print=1&lid=#program_letters_id#&cid=#CSL_Contract_Main_ID#"><img src="/images/printImg.gif" alt="PRINT #lCase(current_dis_letter_name_pdf_tip)#"></a>
								</td> --->
								<!--- Letter modification is not available for HTML letters --->
								<cfif appSettings.getlettersavailable() neq 2>
								<td width="80" align="center">
										<a href="all_dis_doc_modules_edit_form.cfm?CMID=#variables.qGetDisLetters.program_id#&LID=#variables.qGetDisLetters.program_letters_id#&pages=#stPDFInfo.TotalPages#&Dist_ID=<cfif distributor_ID eq "">0<cfelse>#distributor_ID#</cfif>&claim_rate_date=#dateformat(Claim_Rates_Date,'mm/dd/yyyy')#" style="cursor:pointer;"><img src="/images/pm_edit.gif" border="0" title="MODIFY Letter #variables.qGetDisLetters.program_letters_id# #lCase(current_dis_letter_name_pdf_tip)# [#stPDFInfo.TotalPages# Pages]"></a>
								</td>
								</cfif>
								<!--- D17454 [begin] --->
								<!--- IF the current user is the same as the author... --->
								<cfif request.accessStructure.User_ID EQ variables.authorRSPID>
										<td width="80" align="center">
											<!--- &PTID=#thisProgramID# --->
													<a href="#includeLettersFilename#?LID=#variables.qGetDisLetters.program_letters_id#&CID=#variables.qGetDisLetters.program_id#&delete=1" style="cursor:pointer;"><!--- <img src="/common_files/contracts/letters/images/icon_delete.jpg" border="0" alt="DELETE Letter #variables.qGetDisLetters.program_letters_id# #lCase(current_dis_letter_name_pdf_tip)# [#stPDFInfo.TotalPages# Pages]"> ---><img src="/Images/scissor.gif" width="14" height="9" border="0" alt="DELETE Letter #variables.qGetDisLetters.program_letters_id# #lCase(current_dis_letter_name_pdf_tip)# [#stPDFInfo.TotalPages# Pages]"></a>
                   						 </td>
								</cfif>
								<!--- D17454 [end] --->
						</tr>
						
					</cfif>

          <input type="hidden" name="letter_path_#program_letters_id#" value="#variables.qGetDisLetters.letter_path#">
          <input type="hidden" name="Include_File_path" value="/data_files/created/contracts/letters/output/distributors/#CSL_Contract_Main_ID#/#current_dis_letter_name_pdf#">
      
      <!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
      <cfelse>
      
      	<cfscript>
			application.oLetterManager.deletePDFLetterInDBandFile(variables.qGetDisLetters.program_letters_id);
		</cfscript>
      <!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
      
      <!--- [begin] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [begin] --->
      </cfif>  
      <!--- [end] VERIFY we have 3 pieces of current letter puzzle we MUST have to display,edit,print,email,etc... [end] --->
      
    </cfloop>
  </table> 
</cfif>
<!--- ==========================================================
===================== Distributor [end] ========================
=========================================================== --->

<!--- D17491 - RBL IF we just DELETED ALL in cleanup code under the hood And we don't have anything left NOW...
check one more time right now... [begin] MUST DO TWICE --->

<!--- IF we got nuttin... [begin] (2 of 2) --->
<cfquery name="variables.qAllNetLtr" datasource="#application.datasource#">
  SELECT	COUNT(Program_Letters_ID) as netCount
  FROM		Program_Letters
  WHERE 	program_id = '#URL.CID#'
</cfquery>
<!--- nada... --->
<cfif NOT variables.qAllNetLtr.netCount>
    <!--- redirect &WeAreNotGood --->
	<cflocation url="/Common_Files/contracts/contract_letters.cfm?CID=#EncryptedCID#" addtoken="yes">
    <cfabort>
<!--- <cfelse>
TEST - We're good! --->
</cfif>
<!--- IF we got nuttin... [end] MUST DO TWICE --->

<!--- D17491 - RBL IF we just DELETED ALL in cleanup code under the hood And we don't have anything left NOW...
check one more time right now... [END] --->

<cfif url.print>
  
  <cfwindow
    center="true"
    closable="false"
    draggable="true"
    height=400
    initShow="true"
    modal="true"
    name="pdfSmallWin"
    resizable="false"
    title="Combined PDF Print Instructions"
    width=400>
        <ol>
          <li>Click PDF thumbnail below to open All requested PDFs in window.</li>
          <li>Once PDFs are open, click printer icon to print All requested PDFs as one document to selected printer in selected quality.</li>
          <li>This small window will close upon opening the larger window containing All requested and combined PDFs.</li>
       </ol>
       <cfset pdf_relative_path = application.doc_path & "/temp_files/program/combined#CSL_Contract_Main_ID#PDFPrint.pdf">
       <!---
				javascript:ColdFusion.Window.show('pdfLargeWin');
				--->
        <div align="center" onClick="javascript:ColdFusion.Window.hide('pdfSmallWin')">
          <a href="/GetDocument.cfm?FilePath=#pdf_relative_path#" target="pdfLargeWin">
            <img src="thumbnails/tn_page_1.png" border="0" align="absmiddle" title="Click to Print All Selected PDF Letters"/>
          </a>
        </div>
        <div align="right" onClick="javascript:ColdFusion.Window.hide('pdfSmallWin')">
<font size="1" color="Red">[</font> &nbsp;<font size="1" color="Blue"><a href="javascript:history.back()">back</a></font>&nbsp;<font size="1" color="Red">]</font>
        <!--- <cfcontent type="application/pdf" file="#expandPath('combinedPDFPrint.pdf')#" deletefile="yes"> --->
        </div>
    </cfwindow>

</cfif>

<cfif variables.bLettersAvailable>
  <table style="margin-left:20px;" width="350">
    <tr>
      <td height="20" align="left" valign="middle">
    		<!--- Let's email 'em... --->
		<span STYLE="color: red;font-size:12px;font-weight:bold;">[ </span><a href="##" onClick="submitRequest('email_letters');" class="cLinks">email program letters</a><span STYLE="color: red;font-size:12px;font-weight:bold;"> ]</span>
		<!---<input type="image" name="email_letters" src="images/btn_email_icon.gif" height="16" width="120" border="0" title="EMAIL selected letter(s) to listed email addresses" style="cursor:pointer;">--->
      </td>
    </tr>
	<cfif appSettings.getExternal_Contacts() neq 0> 
	<tr>
		<td height="20" align="left" valign="middle">
			<!--- Let's email 'em... --->
			<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
				<cfset email_Letters_Option = "email_external_contacts_letters_and_claim_reports">
			<cfelse>
				<cfset email_Letters_Option = "email_external_contacts_letters">
			</cfif>
				<span STYLE="color:red;font-size:12px;font-weight:bold;">[ </span><a href="##" onClick="submitRequest('#email_Letters_Option#');" class="cLinks">email additional contacts</a><span STYLE="color: red;font-size:12px;font-weight:bold;"> ]</span>
		</td>
	</tr>
	</cfif>
	<tr>
    <td height="20" align="left" valign="middle">
        <!--- Let's print 'em... --->
				<span STYLE="color: red;font-size:12px;font-weight:bold;">[ </span><a href="##" onClick="submitRequest('print_letters');" class="cLinks">print program letters</a><span STYLE="color: red;font-size:12px;font-weight:bold;"> ]</span>
				<!---<input type="image" name="print_letters" src="images/btn_print_icon.gif" height="16" width="120" border="0" title="PRINT selected letter(s)" style="cursor:pointer;">--->
      </td>
    </tr>
    <!--- CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
		CCCCCCCCCCCCCC Calendar - On Deck [begin] CCCCCCCCCCCCCCCCC
		CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    <tr>
    <td height="20" align="left" valign="middle">
        <!--- Let's add to our Outlook calendar... --->
        <input type="image" name="calendar_letters" src="images/btn_calendar_icon.gif" height="16" width="120" border="0" title="SCHEDULE selected letters" style="cursor:pointer;">&nbsp;<input type="text" name="user_name" value="blee">&nbsp;<input type="text" name="user_pwd" value="1234Music">&nbsp;<input type="text" name="exchangeServerIP" value="mail01.intra.awayx.com">
      </td>
    </tr>
    CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
		CCCCCCCCCCCCCC Calendar - On Deck [end] CCCCCCCCCCCCCCCCCC
		CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --->
        
    <!--- 17454 [begin] height:50px;width:200px; --->    
    <cfsavecontent variable="delete_toolTip_html">
    	<span style="background-color:##FFFFFF;color:##000000;font-size:12px;font-weight:bold;">CAUTION: Clicking this button will delete ALL letters for this program. This can not be undone.</span>
    </cfsavecontent>
    <!--- IF we have letters AND THE CURRENT USER is the RSP for Pgm --->
    <cfif variables.qAllLtr.netCount AND (request.accessStructure.User_ID EQ variables.authorRSPID)>  
        <tr>
	  <td height="20" align="left" valign="middle"><cftooltip tooltip="#delete_toolTip_html#"><span STYLE="color: red;font-size:12px;font-weight:bold;">[ </span><a href="#includeLettersFilename#?CID=#URL.CID#&delete=1&bAll=1" class="cLinks">delete ALL program letters</a><span STYLE="color: red;font-size:12px;font-weight:bold;"> ]</span></cftooltip></td>
        </tr>
    </cfif>    
    <!--- 17454 [end] --->    
    <tr>
      <td height="20" align="left" valign="middle"><span STYLE="color: red;font-size:12px;font-weight:bold;">[ </span><a href="http://www.adobe.com/products/acrobat/readstep2.html" target="new" class="cLinks">download Adobe Reader</a><span STYLE="color: red;font-size:12px;font-weight:bold;"> ]</span></td>
     </tr>
  </table>

	<!--- WHY do we have so many aliases for this one value? RBL --->
	<input type="hidden" name="contract_main_id" 	value="#CSL_Contract_Main_ID#">
	<input type="hidden" name="requestType">

<!--- OK - If we do NOT have any letters to display in this table, perhaps our user wishes to create some now. Redirect to letters creation template. --->
<cfelse>
	<cflocation url="/Common_Files/contracts/contract_letters.cfm?CID=#EncryptedCID#" addtoken="yes">
  <cfabort>
</cfif> 	
	</form>
</cfoutput>

<!--- Tech Note: Much of the following js may no longer be needed. Have not thoroughly investigated... 2/14/2008 --->
<script>

function submitRequest(request)
{	
	/* Dev Note: 69439 - When user wants to email claim rates report and letter in one email, then we need to open the email window in a separate
	window, so that the passed form variables can be maintained. Without it the form data will be lost. 
	*/
	<cfif ListFindNoCase(reportType,'ProgramClaimRatesReportAndLetters')>
	NewWindow('about:blank','email_Win','870','720','Yes','No');
	LetterForm.target = 'email_Win';
	LetterForm.requestType.value = request;
	LetterForm.submit();
	<cfelse>
	LetterForm.requestType.value = request;
	LetterForm.submit();
	</cfif>
}


var ErrorCount = 0;
 function submitForm(thisForm)
	{
	var oprbox, opremailbox,errorspan;
	var oprcheckcomplete = 0;
	var ErrorCount = 0
	var discheckcomplete = 0;
	var oprcheckemail = 0;
	var discheckemail = 0;
	
	if (document.getElementById("checkAllOprLetters") != null)
	{
	if(window.checkAllOprLetters.length)
	{
		for(var x=0; x<window.checkAllOprLetters.length;x++)
		{
		
		oprbox = getFirstChild(window.checkAllOprLetters[x]);
		opremailbox =  getFirstChild(window.checkAllOprEmail[x]);
		oprerrorspan = window.error_oprAddress[x];
		if (oprbox.checked == true)
			{
			oprcheckcomplete = 1;
			clearQueue(document.all.checkopr);
			//var ValidEmail1 = true;
			if(opremailbox.value != "" && opremailbox.value != "NULL")
				{
				var ValidEmail1 = replaceInvalidEmailAndValidate(opremailbox.value);
				if(ValidEmail1 != true)
				{
				ErrorCount++;
	 			queueMessage("Invalid email Address", oprerrorspan);
				}
				else
				{
				oprcheckemail = 1;
				clearQueue(oprerrorspan);
				}
				}
			else
				{
					ErrorCount++;
					queueMessage("You must enter an email address", oprerrorspan);
				}
			
			}	
	}
	}
	else
		{
			oprbox = getFirstChild(window.checkAllOprLetters);
			opremailbox =  getFirstChild(window.checkAllOprEmail);
			oprerrorspan = window.error_oprAddress;
		
			if (oprbox.checked == true)
			{
			oprcheckcomplete = 1;
			clearQueue(document.all.checkopr);
			if(opremailbox.value != "" && opremailbox.value != "NULL")
				{

				var  ValidEmail1 = replaceInvalidEmailAndValidate(opremailbox.value);
				
				if(ValidEmail1!=true)
				{
				ErrorCount++;
	 			queueMessage("Invalid email Address", oprerrorspan);
				}
				else
				{
				oprcheckemail = 1;
				clearQueue(oprerrorspan);
				}
				
				}
				
				else
				{
					ErrorCount++;
					queueMessage("You must enter an email address", oprerrorspan);
				}
			
			}
		}
	
	}
	
	if (document.getElementById("checkAllDisLetters") != null)
	{
		if(window.checkAllDisLetters.length)
		{
		for(var x=0; x<window.checkAllDisLetters.length;x++)
		{
		disbox = getFirstChild(window.checkAllDisLetters[x]);
		disemailbox =  getFirstChild(window.checkAllDisEmail[x]);
		diserrorspan = window.error_disAddress[x];
		diserrorcheck = window.error_discheckbox[x];
		if (disbox.checked == true)
			{
			discheckcomplete = 1;
			clearQueue(document.all.checkdis);
			
			//var ValidEmail1 = true;
			if(disemailbox.value != "" && disemailbox.value != "NULL")
				{

				var  ValidEmail1 = replaceInvalidEmailAndValidate(disemailbox.value);
				
				if(ValidEmail1!=true)
				{
				ErrorCount++;
	 			queueMessage("Invalid email Address", diserrorspan);
				}
				else
				{
				discheckemail = 1;
				clearQueue(diserrorspan);
				}
				
				}
			else
				{
					ErrorCount++;
					queueMessage("You must enter an email address", diserrorspan);
				}
			}
		  }
		}
	else
		{
			disbox = getFirstChild(window.checkAllDisLetters);
			disemailbox =  getFirstChild(window.checkAllDisEmail);
			diserrorspan = window.error_disAddress;
			diserrorcheck = window.error_discheckbox;
			if (disbox.checked == true)
			{
			discheckcomplete = 1;
			clearQueue(document.all.checkdis);
			if(disemailbox.value != "" && disemailbox.value != "NULL")
				{

				var  ValidEmail1 = replaceInvalidEmailAndValidate(disemailbox.value);
				
				if(ValidEmail1!=true)
				{
				ErrorCount++;
	 			queueMessage("Invalid email Address", diserrorspan);
				}
				else
				{
				discheckemail = 1;
				clearQueue(diserrorspan);
				}
				
				}
				
				else
				{
					ErrorCount++;
					queueMessage("You must enter an email address", diserrorspan);
				}
			
			}
		}
	}
	if((oprcheckcomplete == 0) && (discheckcomplete == 0))
	{
			if (document.getElementById("checkAllOprLetters") != null)
			{
			ErrorCount++;
			queueMessage("You must select a letter to send", document.all.checkopr);
			}
			if (document.getElementById("checkAllDisLetters") != null)
			{
			ErrorCount++;
			queueMessage("You must select a letter to send", document.all.checkdis);
			}
	}
	
	if(ErrorCount == 0) 
	{
		
		thisForm.submit();
		return false;
		
	}
	else 
	{
		showMessageWindow();
	}	
}
	

function selectall(type){
if (type == 'D')
{
 var obj = window.checkAllDisLetters;
 }
 else if (type == 'O')
 {
 var obj =  window.checkAllOprLetters;
 }
 
			if(obj != null){
				if(obj.length)
				{
					for(var x=0; x<obj.length;x++){
						box = getFirstChild(obj[x])
						if(box.disabled == false)
						{
						if (type == 'O')
						{
						box.checked = document.all.opr_check_all.checked
						}
						else if (type == 'D')
						{
						box.checked = document.all.dis_check_all.checked
						}
						}
						else
						{
							box.disabled = true
						}
					}
				}
				else
				{
					box = getFirstChild(obj)
					if (type == 'O')
						{
						box.checked = document.all.opr_check_all.checked
						}
						else if (type == 'D')
						{
						box.checked = document.all.dis_check_all.checked
						}
				}
			}
		}

 </script>

</body>
