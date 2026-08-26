<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\Letters\emailQuoteLetter.cfm
      Date:     Sep 22, 2011
      Author:   Chris Nguyen
      Purpose:  Email Quote Letter

      Required parameter:
      - URL.Contract_Main_ID (integer)
      - URL.Contract_Number  (varchar)

----------------------------------------------------------------------------------------------------------------------->

<cfset URL.Email = 1>

<cfset vars.file_prefix = "Quote_Letter_" & Replace(URL.Contract_Number, " ", "_", "all")>

<cfparam name="URL.lang" default="">

<CFQUERY NAME="getContractInfo" datasource="#application.datasource#">
	SELECT 	a.Contract_Title
          ,a.Contract_Number
          ,b.Label_Set_Default
          ,a.ProgramType_ID
	  FROM 	Contract_main a
          INNER JOIN Program_Control_Panel_Options b ON b.ProgramControl_Panel_Options_ID = a.ProgramType_ID
	 WHERE 	a.Contract_main_ID = '#url.contract_main_id#'
</CFQUERY>
<cfset variables.translate = request.AccessStructure.User_Language eq "French"
                             AND getContractInfo.Label_Set_Default eq "French">

<!--- prevent problem in including this template more than once --->
<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
  <cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
</cfif>

<CF_Email_Common_Form
			Include_File_path = "/common_files/contracts/letters/quoteLetter.cfm"
			Document_Title = "Quote Letter"
			Document_Number_Variable = "URL.Contract_Number"
			Document_Title_Variable = '"#getWords(getContractInfo.contract_title, 6)#"'
			Document_Title_File_Prefix = "#vars.file_prefix#"
      PDF_Footer = "#getContractInfo.Contract_Number# - "
      Language = "#URL.lang#"
			Fax_Email = "Email"
			Attachment_Type = "pdf"
	>