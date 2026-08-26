<!---
File: contract_email_create.cfm
Edited By: Brad Lee 10/21/08 [D17257]
--->

<CFSET PAGE_TITLE="Email Contract">
<CFSET GROUP="contracts">
<cfparam name="sort" default="name_last"><!--- name_last --->
<cfparam name="url.EZTemplate" default="0">
<cfparam name="form.resetToWip" default="0" />
<cfparam name="variables.message_body" type="string" default="">

<cfset appSettings = application.appSettingsGet />

<cfif (Not isDefined("dup_warn_msg") and isDefined("form.check_contract_number")) OR isDefined("URL.DupContractIDList")>
	<CFINCLUDE TEMPLATE="\common_files\contracts\contract_approve_duplicate_warning_save.cfm">
	<cfset dup_warn_msg = dupWarningMessage>
</cfif>

<cfparam name="dup_warn_msg" default="">

<cfif Not isDefined("session.rec_addr") and isDefined("form.check_contract_number")>
	<cfset session.rec_addr = form.creator_email_addr>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.min.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<script>

var ErrorCount = 0;
function confirmCompletion(disableClickedButtonName)
{

	var ErrorCount = 0;

	if(document.all.SenderAddress.value.length == 0)
	{
		ErrorCount++;
		queueMessage("You must enter your email address", document.all.error_SenderAddress);
	}
	else
	{
		clearQueue(document.all.error_SenderAddress);
	}

	if(document.all.SenderSubject.value.length == 0)
	{
		ErrorCount++;
		queueMessage("You must enter a subject", document.all.error_SenderSubject);
	}
	else
	{
		clearQueue(document.all.error_SenderSubject);
	}

	var sBroker_Address = jQuery('textarea[name=Broker_Address]').val();
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Broker_Address_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Broker_Address_2]').val();
	</cfif>
	var recipients = combineEmails(sBroker_Address, recipients_2); //ChromeFix

  if ( recipients.length == 0 )   /*25704*/
	{
		ErrorCount++;
		queueMessage("Please enter at least one email address", document.all.error_Broker_Address);
	}
	else
	{
		clearQueue(document.all.error_Broker_Address);
	}

<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0)
	{
  	// hide email recipient input
  	//document.all.Broker_Address.style.visibility = 'hidden';
		// combine int email recipients & ext email recipients
  	//document.all.Broker_Address.value = recipients;  //ChromeFix
	jQuery("textarea[name=Broker_Address]").hide().val(recipients);
		Email.submit();
		disableButton(disableClickedButtonName, true, false);
		<cfif structKeyExists(url,'emailType') and url.emailType is 'BusinessCon'>

		</cfif>
	}
	else
	{
		showMessageWindow()
	}
}


</script>
<CF_MessageWindow>

</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<STYLE>
	textarea
		{
			font-size:	12px;
			width:		500px;
		}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decode all of the URL Variables and retrieve the necessary data to populate the email fields	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif isDefined("URL.passedForm") and URL.passedForm EQ "dupForm">
	<cfelseif structKeyExists(url,'emailType') and url.emailType is "BusinessCon">
	<cfparam name="completepath_email" 	default="">
</cfif>
<!--- decode the key values--->
<cfif isDefined("URL.contractMainId")>
<!--- handle dup form email notification --->
	<CFSET URL.Contract_Main_ID = URL.contractMainId >
<cfelse>
	<!--- Decode the Program ID that comes from the URL.TID variable --->
	<cf_cryp	type = "de" string = "#URL.PID#" key = "#request.key#">
	<CFSET URL.Contract_Main_ID=cryp.value>
</cfif>

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<cfif isDefined("URL.FID")>
	<!--- Decode the path of the file to be sent --->
	<cf_cryp	type = "de" string = "#URL.FID#" key = "#request.key#">
	<CFSET completepath_email=cryp.value>
</cfif>
<!--- <CFOUTPUT>#completepath_email#</CFOUTPUT> --->
<!--- Get the program number --->
<CFQUERY NAME="Get_Program_Details" datasource="#application.datasource#">
	Select		Contract_Main_ID,
				Contract_Number,
				Contract_Title,
				contract_status_type_idx,
				programtype_id,
				Creator_ID,
				Responsible_User_ID,
				PCPO.Market_Price
	From		Contract_Main
				INNER JOIN	Program_Control_Panel_Options PCPO ON
				Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	Where		Contract_Main_ID	=	#URL.Contract_Main_ID#
</CFQUERY>
<cfset useLakebaseForgetCreatorEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetCreatorEmail>
	<cftry>
		<cfset getCreatorEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_Program_Details.Creator_ID#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCreatorEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCreatorEmail>
<cfquery name="getCreatorEmail" datasource="#application.datasource#">
	Select User_Email
	From _Users
	Where User_ID = '#Get_Program_Details.Creator_ID#'
</cfquery>
</cfif>
<cfset useLakebaseForgetRSPEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetRSPEmail>
	<cftry>
		<cfset getRSPEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_Program_Details.Responsible_User_ID#",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRSPEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRSPEmail>
<cfquery name="getRSPEmail" datasource="#application.datasource#">
	Select User_Email
	From _Users
	Where User_ID = '#Get_Program_Details.Responsible_User_ID#'
</cfquery>
</cfif>
<cfif url.EZTemplate EQ 1>
<cfset useLakebaseForGet_Template_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGet_Template_Details>
	<cftry>
		<cfset Get_Template_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#Get_Program_Details.programtype_id#",
				"select" = "created_type"
			}), "created_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Template_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Template_Details>
<CFQUERY NAME="Get_Template_Details" datasource="#application.datasource#">
	Select		created_type
	From		Program_Control_Panel_Options
	Where		ProgramControl_Panel_Options_ID	=	#Get_Program_Details.programtype_id#
</CFQUERY>
</cfif>
</cfif>

<!--- Get the broker emails --->
<CFQUERY NAME="Get_Broker_Details" datasource="#application.datasource#">
	Select		Contract_Brokers.BSA_Foodservice_Brokers_ID,
				BSA_Foodservice_Brokers.E_Mail
	From		Contract_Brokers,
				BSA_Foodservice_Brokers
	Where		Contract_Brokers.Contract_Main_ID	=	#URL.Contract_Main_ID#
				AND
				Contract_Brokers.Deleted = 0
				AND
				BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID	=	Contract_Brokers.BSA_Foodservice_Brokers_ID
</CFQUERY>
<!--- Clean the email list: replace commas with semi-colons and if the first is blank, remove it --->
<CFSET Broker_Address=rereplace(valuelist(Get_Broker_Details.E_Mail), ",+", "; ", "All")>
<CFSET Broker_Address=request.app_general_functions.cleanEmailAddress(Broker_Address)>
<CFIF left(Broker_Address,1) EQ ";">
	<CFSET Broker_Address=mid(Broker_Address,3, len(Broker_Address))>
</CFIF>

<!---
	Tim Ford - 09/25/2013: Label 39042 - Program Summary - remove email option.
	Added code to remove Market Price data from emails
--->
<cfif Get_Program_Details.Market_Price eq 1>
	<cfset CSLGetContractInfo.Market_Price = Get_Program_Details.Market_Price />
	<cfset bHideMarketPrice = 1 />
	<cfinclude template="email_fax_handler.cfm" />
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<FORM ACTION="contract_email_send.cfm" METHOD="post" NAME="Email" ID="Email">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="forgetrade@bigredflame.com" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
<cfif url.EZTemplate EQ 0>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Program #Get_Program_Details.Contract_Number# - #Get_Program_Details.Contract_Title#<cfif isDefined("URL.passedForm")> ( Duplicate Program Alert )</cfif><cfif structKeyExists(url,"emailType") and url.emailType is "BusinessCon"> (Reset to WIP)</cfif>" STYLE="width:540px;"></TD>
<cfelse>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="EZ TEMPLATE SETTING - #Get_Template_Details.Created_Type#" STYLE="width:540px;"></TD>
</cfif>
</TR>

<!--- 17257 [begin] --->
<cfif structKeyExists(url,'emailType') AND url.emailType EQ 'BusinessCon'>
	<cfquery name="contractNum" datasource="#application.datasource#">
		select 	contract_number,Is_A_Revision, ProgramType_ID,
				Reset_Date, Reset_User_ID,
				_users.Name_First + ' ' + _users.Name_Last as Reset_User_Name
		from 	contract_main
		left join _users
		on	 	_users.user_id = Reset_User_ID
		where 	contract_main_id = '#URL.Contract_Main_ID#'
	</cfquery>

	<cfquery name="evalNotes" datasource="#application.datasource#">
		select 	Contract_Evaluation_Notes.Entered_By,
				Contract_Evaluation_Notes.Eval_Action,
				Contract_Evaluation_Notes.Notes,
				Contract_Evaluation_Notes.Created_Date,
				Contract_Evaluation_Notes.Contract_Notes_Type
		from 	Contract_Evaluation_Notes
		where 	Contract_Evaluation_Notes.Contract_Number = '#contractNum.contract_number#'
		and 	Contract_Evaluation_Notes.Contract_Notes_Type = '1'
		and		Entered_By = '#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#'
		and		Contract_Evaluation_Notes.Deleted = 0
		order by Created_Date DESC
	</cfquery>

<cfset variables.message_body = reReplaceNoCase(trim(evalNotes.Notes),"<br>",chr(13),"ALL") & chr(13) & chr(13) & 'Reset By: ' & contractNum.Reset_User_Name & chr(13) & 'Date Reset: ' & dateFormat(contractNum.Reset_Date, 'mm/dd/yyyyy')>
<!--- 17257 [end] --->
</cfif>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD ><!--- 17257 [begin] ---><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;">#variables.message_body#</TEXTAREA><!--- 17257 [end] ---></TD>
</TR>
</TABLE>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<SCRIPT language="JavaScript">

<!--- 17257 <cfif structKeyExists(url,'emailType') AND url.emailType EQ 'BusinessCon'>
      document.Email.Message_Body.value = <cfoutput>'#evalNotes.Notes#'</cfoutput> + '\n';
	  document.Email.Message_Body.value += <cfoutput>'Reset By: #contractNum.Reset_User_Name# \n'</cfoutput>;
	  document.Email.Message_Body.value += <cfoutput>'Date Reset: #DateFormat(contractNum.Reset_Date, 'MM/DD/YYYY')#'</cfoutput>;
</cfif> --->
</SCRIPT>

</CFOUTPUT>

<cfif url.EZTemplate EQ 0>
<cfif Not isDefined("URL.passedForm")>
	<CFINCLUDE template="Email_Fax_Program_Attachments.cfm">
</cfif>
</cfif>

<cfif isDefined("URL.passedForm") and (Broker_Address EQ "" or Not isDefined("Broker_Address"))>
	<cfset Broker_Address = session.rec_addr >
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Broker_Address"></span>
	</TD>
	<TD>&nbsp;<br><TEXTAREA NAME="Broker_Address" COLS="75" ROWS="15" STYLE="WIDTH:300px;" ONKEYPRESS="javaSCript: return Valid_Key_On_Email_Object();"><CFOUTPUT><cfif appSettings.getIncludeUsersEmailAuto()>#request.AccessStructure.User_Email#<!--- <cfif len(Broker_Address) GT 0>;</cfif> ---></cfif><!--- #Broker_Address# ---><cfif structKeyExists(url,'emailType') and url.emailType is "BusinessCon"><cfif getCreatorEmail.RecordCount><cfif appSettings.getIncludeUsersEmailAuto()>;</cfif>#getCreatorEmail.User_Email#</cfif></cfif></CFOUTPUT></TEXTAREA>
	</TD>
	<TD ALIGN="left">
				<TABLE cellpadding="0" cellspacing="0">
					<TR><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
						<TD nowrap><span title="Sort by Last Name">
							<CF_button
								button_name		=	""
								button_caption	=	"Last"
								button_action	=	"sortOptionslast(document.all.Email.E_User_Email_Address)"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"Last"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></span>
						</TD>
						<!--- <TD><span title="Sort by First Name">
							<CF_button
								button_name		=	""
								button_caption	=	"First"
								button_action	=	"sortOptionsfirst(document.all.Email.E_User_Email_Address)"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"First"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></span> <!---  window.location.href='' --->
						</TD> --->
						<TD><span title="Sort by Email">
							<CF_button
								button_name		=	""
								button_caption	=	"Email"
								button_action	=	"sortOptionsemail(document.all.Email.E_User_Email_Address)"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"Email"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></span>
						</TD>
					</TR>
					<TR>
						<TD id="EmLook" colspan="4">
							<CF_Email_Address_Lookup
								Destination_Form_Name="Email"
								Destination_Field_Name="Broker_Address"
								width="350"
								size="15"
								Alert="true"
								sort ="#sort#">
						</TD>
					</TR>
				</TABLE>
	</TD>
</TR>
<TR>
	<TD></TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
</TABLE>
--->

<!--25704 - 2011-mar-15 added ext. contacts-->
<cfscript>
  intEmails_value = "";
  if ( appSettings.getIncludeUsersEmailAuto() ) {
    intEmails_value = request.AccessStructure.User_Email;
    if ( structKeyExists(url,'emailType') and url.emailType is "BusinessCon" and getCreatorEmail.RecordCount ) {
      if ( Len(intEmails_value) ) {
        intEmails_value =  intEmails_value & ";";
      }
      intEmails_value = intEmails_value & getCreatorEmail.User_Email;
    }
  }

  if (getRSPEmail.RecordCount AND getRSPEmail.User_email NEQ "" AND getRSPEmail.User_email NEQ getCreatorEmail.User_Email)
  {
  	if ( Len(intEmails_value) ) {
        intEmails_value =  intEmails_value & ";";
      }
      intEmails_value = intEmails_value & getRSPEmail.User_Email;
  }
</cfscript>

<!--get the shared code for companyCodes() function-->
<cfinclude template="\common_files\programs\companyCodes.cfm">
<cfset URL.ECMID = #Get_Program_Details.Contract_Main_ID#>
<cf_emailRecipient
          intEmails_name  = "Broker_Address"
          intEmails_value = #intEmails_value#
          company_codes   = #companyCodes(Get_Program_Details.Contract_Main_ID)#  >

<cfif Not isDefined("URL.passedForm")>
  <!--- Dev Note BSD: 11030 Added check to see if they are coming from Business
        Considerations Page. We don't need to send a file id that is the case --->
  <cfif not structKeyExists(url,'emailType')>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- <SPAN CLASS="title2">Program Details</SPAN> --->
	<HR COLOR="Orange">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CFSET reversed_completepath_email=reverse(completepath_email)>
	<CFSET filename_enail=reverse(left(reversed_completepath_email, find("\", reversed_completepath_email)-1))>
	<INPUT NAME="Program_Name" TYPE="hidden" VALUE="<CFOUTPUT>#filename_enail#</CFOUTPUT>">
    </cfif> <!--- End check for coming from Business Considerstions --->
<cfelse>
	<!--- save the dup warning messages --->
	<div align="center" STYLE="color: red; font-size: 13px; font-weight: bold;">
		<cfoutput>#dup_warn_msg#</cfoutput>
	</div>
</cfif>

<BR CLEAR="ALL">
<BR>

<!--- Encrypt the CID the file --->
<cf_cryp	type = "en" string = "#Get_Program_Details.Contract_Main_ID#" key = "#request.key#">
<CFSET CID=cryp.value>

  <cfif structKeyExists(url,'emailType') and url.emailType is "BusinessCon">
	  <cfset form.resetToWip = 1 />
  </cfif>

<!--- When a user clicks on business considerations and then visits this page on clicking "email note", ResetToWIP is 1. --->
<script language="javascript">
function RedirectCurrentWin()
{
	if(<cfoutput>#form.RESETTOWIP#</cfoutput>)
	{
		window.parent.close();
	}
	else
	{
	<cfoutput>
		window.location.href='contract_edit_menu.cfm?CID=#CID#';
	</cfoutput>
	}
}
</script>

<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	"send"
				button_caption	=	"send email package"
				button_action	=	"confirmCompletion('send_table');"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
<cfif url.EZTemplate EQ 0>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"return to program view"
				button_action	=	"RedirectCurrentWin();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to return to program view..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
</cfif>
	</TR>
</TABLE>

<cfoutput>
<!---D36155: blank email duplicate START--->
<!---<input type="hidden" name="dup_warn_msg" value="#dup_warn_msg#">--->
<textarea name="dup_warn_msg" style="display:none;">#dup_warn_msg#</textarea>
<!---D36155: blank email duplicate END--->
 <input type="hidden" name="EZTemplate" value="#url.EZTemplate#">
 <INPUT TYPE="Hidden" NAME="Program_no" VALUE="#Get_Program_Details.Contract_Number#">
<INPUT TYPE="Hidden" NAME="Prog_Title" VALUE="#Get_Program_Details.Contract_Title#">
<INPUT TYPE="Hidden" NAME="PassedForm" VALUE="dupForm">
<INPUT TYPE="hidden" NAME="Program_CID" VALUE="#Get_Program_Details.Contract_Main_ID#">
 <input type="hidden" name="resetToWip" value="#form.resetToWip#" />
</cfoutput>
</FORM>

</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>