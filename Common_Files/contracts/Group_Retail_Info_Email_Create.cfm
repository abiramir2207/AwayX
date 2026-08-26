<CFSET PAGE_TITLE="Email Retail Product Info">
<cfparam name="sort" default="name_last">
<cfparam name="Type" default="">

<cfset appSettings = application.appSettingsGet />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_validations.min.js"></SCRIPT>
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
	
	//var recipients = combineEmails(document.all.Broker_Address.value, document.all.Broker_Address_2.value);  /*25704*/
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Broker_Address_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Broker_Address_2]').val();
	</cfif>
	var recipients = combineEmails(jQuery("textarea[name=Broker_Address]").val(),recipients_2); //ChromeFix
  if ( recipients.length == 0 ) {
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Broker_Address);
	}
	else
	{
		clearQueue(document.all.error_Broker_Address);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
    // hide email recipient input
  //	document.all.Broker_Address.style.visibility = 'hidden';
		// combine int email recipients & ext email recipients
  	//document.all.Broker_Address.value = recipients; //ChromeFix
	jQuery("textarea[name=Broker_Address]").hide().val(recipients);
		Email.submit()
		disableButton(disableClickedButtonName, true, false);
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
<!---<CFINCLUDE TEMPLATE="/includes/header.cfm">--->
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
<cfif isDefined("URL.passedForm")>
	<cfparam name="completepath_email" 	default="">
</cfif>

<!--- decode the key values--->
<cfif isDefined("URL.contractMainId")>
<!--- handle dup form email notification --->
	<CFSET URL.Contract_Main_ID = URL.contractMainId >
<cfelse>
	<!--- Decode the Program ID that comes from the URL.CID variable --->
	<cf_cryp	type = "de" string = "#URL.CID#" key = "#request.key#">
	<CFSET URL.Contract_Main_ID=cryp.value>
</cfif>

<cfif isDefined("URL.FID")>
	<!--- Decode the path of the file to be sent --->
	<cf_cryp	type = "de" string = "#URL.FID#" key = "#request.key#">
	<CFSET completepath_email=cryp.value>
</cfif>

<!--- Get the program details --->
<cfset useLakebaseForGet_Program_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGet_Program_Details>
	<cftry>
		<cfset Get_Program_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#URL.Contract_Main_ID#",
				"select" = "contract_main_id,contract_number,contract_title,contract_status_type_idx,programtype_id,creator_id"
			}), "contract_main_id,contract_number,contract_title,contract_status_type_idx,programtype_id,creator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Program_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Program_Details>
<CFQUERY NAME="Get_Program_Details" datasource="#application.datasource#">
	Select		Contract_Main_ID,
				Contract_Number,
				Contract_Title,
				contract_status_type_idx,
				programtype_id,
				Creator_ID
	From		Contract_Main
	Where		Contract_Main_ID	=	#URL.Contract_Main_ID#
</CFQUERY>
</cfif>

<!---<CFINCLUDE TEMPLATE="Group_Retail_Info_Email_Fax_Handler.cfm">--->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FORM ACTION="Group_Retail_Info_email_send.cfm" METHOD="post" NAME="Email" ID="Email">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Program #Get_Program_Details.Contract_Number# - #Get_Program_Details.Contract_Title#<cfif isDefined("URL.passedForm")> ( Duplicate Program Alert )</cfif>" STYLE="width:540px;"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD ><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA></TD>
</TR>
</TABLE>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--25704 - 2011-mar-15 added ext. contacts-->
<cfscript>
  intEmails_value = "";
  if ( appSettings.getIncludeUsersEmailAuto() ) {
    intEmails_value =  request.AccessStructure.User_Email;
  }
</cfscript>


<!---
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Broker_Address"></span>
	</TD>
	<TD>&nbsp;<br><TEXTAREA NAME="Broker_Address" COLS="75" ROWS="5" STYLE="WIDTH:300px;" ONKEYPRESS="javaSCript: return Valid_Key_On_Email_Object();"><CFOUTPUT><cfif appSettings.getIncludeUsersEmailAuto()>#request.AccessStructure.User_Email#</cfif></CFOUTPUT></TEXTAREA>
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
								size="5"
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

<!--get the shared code for companyCodes() function-->
<cfinclude template="\common_files\programs\companyCodes.cfm">   

<cf_emailRecipient
    intEmails_name  = "Broker_Address"  
    intEmails_value = #intEmails_value#
    company_codes   = #companyCodes(Get_Program_Details.Contract_Main_ID)#  >


<cfif Not isDefined("URL.passedForm")>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<HR COLOR="Orange">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfif isDefined("URL.FID")>
		<CFSET reversed_completepath_email=reverse(completepath_email)>
		<CFSET filename_enail=reverse(left(reversed_completepath_email, find("\", reversed_completepath_email)-1))>
		<INPUT NAME="Program_Name" TYPE="hidden" VALUE="<CFOUTPUT>#filename_enail#</CFOUTPUT>">
	</cfif>
</cfif>

<BR CLEAR="ALL">
<BR>

<!--- Encrypt the CID the file --->
<cf_cryp	type = "en" string = "#Get_Program_Details.Contract_Main_ID#" key = "#request.key#">
<CFSET CID=cryp.value>

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
	</TR>
</TABLE>

<cfoutput>
<INPUT TYPE="Hidden" NAME="Program_no" VALUE="#Get_Program_Details.Contract_Number#">
<INPUT TYPE="Hidden" NAME="Prog_Title" VALUE="#Get_Program_Details.Contract_Title#">
<INPUT TYPE="Hidden" NAME="PassedForm" VALUE="dupForm">
<INPUT TYPE="hidden" NAME="Program_CID" VALUE="#Get_Program_Details.Contract_Main_ID#">
<INPUT TYPE="Hidden" NAME="Type" VALUE="#Type#">
</cfoutput>
</FORM>

</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
