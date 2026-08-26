<!---
Name: 			claim_form_email_create.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	07/17/2009
Created By:		Tim Ford     
Description:	This file is responsible for displaying an email form for the One Page Claim Form
--->

<cfparam name="url.emailFormId" 		default="0" />
<cfparam name="url.emailClaimFormId" 	default="0" />
<cfset appSettings = application.appSettingsGet />
<cfset variables.brokerProgramManager = createObject('component','components.Billback.BrokerProgramsManager').init(application.datasource) />
<cfset variables.qGetClaim = variables.brokerProgramManager.getClaim(url.emailFormId) />
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Claim Email</TITLE>
	
  <script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>  <!--25704-->
<script>

	var ErrorCount = 0;
	function confirmCompletion()
	{
		var ErrorCount = 0;
		 //ChromeFix
		// var recipients = combineEmails(document.all.Recipient_Email_Address.value, document.all.Recipient_Email_Address_2.value);
		<cfif application.appSettingsGet.External_Contacts_Option eq 0>
			var recipients_2 = jQuery('input[name=Recipient_Email_Address_2]').val();
	    <cfelse>
		    var recipients_2 = jQuery('textarea[name=Recipient_Email_Address_2]').val();
		</cfif>
		 var recipients = combineEmails(jQuery("textarea[name=Recipient_Email_Address]").val(),recipients_2); //ChromeFix ::  Recipient_Email_Address_2 is undefined and we need to reference textarea via jQuery
		if ( recipients.length == 0 )   /*25704*/
		{
			ErrorCount++;
			queueMessage("You must enter at least one email address", document.all.error_Recipient_Email_Address);
		}
		else
		{
			clearQueue(document.all.error_Recipient_Email_Address);
		}
		
		if(ErrorCount == 0) 
		{
    	// hide email recipient input
    	// document.all.Recipient_Email_Address.style.visibility = 'hidden';
			// combine int email recipients & ext email recipients
			//document.all.Recipient_Email_Address.value = recipients; //ChromeFix
			jQuery("textarea[name=Recipient_Email_Address]").hide().val(recipients);
			Email.submit();
		}
		else 
		{
			showMessageWindow();
		}
	}
</script>
<CF_MessageWindow>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<STYLE>
	textarea
	{
		font-size:	12px;
		width:		500px;
	}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the email create page  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR>
<FORM ACTION="claim_form_email_send.cfm" METHOD="post" NAME="Email" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="1">
	<TR>
		<TD ALIGN="right" WIDTH="150">
			<B>Date:&nbsp;&nbsp;</B>
		</TD>
		<TD>
			#dateformat(now(), 'mmmmm d, yyyy')#
			<INPUT TYPE="hidden" NAME="SenderDate" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#">
		</TD>
	</TR>
	<TR>
		<TD ALIGN="right">
			<B>From:&nbsp;&nbsp;</B>
		</TD>
		<TD>
			#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)
		</TD>
	</TR>
	<TR>
		<TD ALIGN="right">
			<B>Subject:&nbsp;&nbsp;</B></span>
		</TD>
		<TD>
			Claim For BA Program #variables.qGetClaim.BA_Id# #variables.qGetClaim.Desc_Number#
			<INPUT TYPE="hidden" NAME="SenderSubject" VALUE="Claim For BA Program #variables.qGetClaim.BA_Id# #variables.qGetClaim.Desc_Number#">
		</TD>
	</TR>
	<TR>
		<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
		<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
	</TR>
</TABLE>
<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
	<TR VALIGN="top">
		<TD ALIGN="right" WIDTH="150" VALIGN="TOP">
			<B>Recipients:&nbsp;&nbsp;</B><span id="error_Recipient_Email_Address"></span>
		</TD>
		<TD>
			<TEXTAREA NAME="Recipient_Email_Address" COLS="5" ROWS="5" STYLE="width:300px;"></TEXTAREA>
		</TD>
		<TD ALIGN="left">
			<CF_Email_Address_Lookup 
				Destination_Form_Name="Email"
				Destination_Field_Name="Recipient_Email_Address"
				width="200"
				size="5"
				Alert="true">
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

<cf_emailRecipient
          intEmails_name  = "Recipient_Email_Address"  
          company_codes   = #QuotedValueList(QGetClaim.Payto_Num)#  >

<BR CLEAR="ALL">
<BR>

<TABLE ALIGN="center">
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send email package"
				button_action	=	"confirmCompletion();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"return to claim view"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to close..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
	</TR>
</TABLE>
</BLOCKQUOTE>

<input type="hidden" name="Form_ID" value="#url.emailFormId#" />
<input type="hidden" name="ClaimForm_ID" value="#url.emailClaimFormId#" />
</CFOUTPUT>
</FORM>







</BODY>
</HTML>

 