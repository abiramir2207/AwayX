<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\email_statement.cfm
      Date:     Jan 2012
      Author:   Chris Nguyen
      Purpose:  Email BB statement with external contacts displayed in a grid with checkboxes

      Parameters:

        1. URL.Attachments (required): Commas-delimited list of attachments (use full path)
        2. URL.Billback_ID (required): Billback ID
----------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title>Billback</title>
 <style>
 .title2 {
 	font-weight:bold;
 	font-size:10pt;
 }
  .email_130 {
 	cursor : pointer;
 }
  .cancel_130 {
 	cursor : pointer;
 }
 </style>
</head>
<body>
<cfparam name="url.attachments" default="">  <!---full path of attachments delimited by commas--->

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>
<cfset appSettings = genSettingsManager.get()>

<!--------------------------------------------------------------------------------------------------------------------->

<cfif StructKeyExists(form, "submitted") and form.submitted eq cgi.script_name>
	<cfset StructAppend(form, url, "no")>   <!---merge URL into form--->
	<!---<cfdump var="#form#" label="" format="html" showudfs="false" metainfo="false">--->
	<cf_emailwrapper
				to = "#form.recipient_email_address#"
				from = "#form.senderAddress#"
				subject = "#form.senderSubject#"
				type = "html"
				messagetype = "1"
				generatedby	=	"3"
				apparea	=	"3"
				userid =	"#request.accessstructure.user_id#">
		<table width="100%">
			<tr valign="top">
				<td>#form.message_body#</td>
			</tr>
		</table>
		<cfloop list="#form.attachments#" index="vars.attachment">
			<cf_emailwrapperparam file = "#vars.attachment#">
		</cfloop>
	</cf_emailwrapper>
	<BR><BR>
	<H4 STYLE="Color: Red;">
	The following Email has been sent...<BR><BR>
	</H4>
	<table border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td align="right" width="150"><b>Date:&nbsp;&nbsp;</b></td>
		<td><input type="text" name="SenderDate" size="30" value="#dateformat(now(), 'mmmmm d, yyyy')#" style="width: 2	50px;"></td>
	</tr>
	<tr>
		<td align="right"><b>From:&nbsp;&nbsp;</b><span id="error_SenderAddress"></span></td>
		<td><input type="text" name="SenderAddress" size="30" value="#form.senderAddress#>" style="width: 250px;"></td>
	</tr>
	<tr>
		<td align="right"><b>Subject:&nbsp;&nbsp;</b><span id="error_SenderSubject"></span></td>
		<td><input type="text" name="SenderSubject" size="30" value="#form.senderSubject#" style="width:500px"></td>
	</tr>
	<tr>
		<td align="right" valign="top"><b>Message Body:&nbsp;&nbsp;</b></td>
		<td><textarea name="Message_Body" cols="75" rows="5">#form.message_body#</textarea></td>
	</tr>
	<tr>
		<td align="right" valign="top"><b>Recipients:&nbsp;&nbsp;</b></td>
		<td><textarea name="Message_Body" cols="75" rows="5">#form.recipient_email_address#</textarea></td>
	</tr>
	</table>
	<div style="margin:35px 0 0 150px;">
		<a class="close_130" style="margin-left:30px;">#actionLinkFormat("close window")#</a>
	</div>
	<cfinclude template="/common_files/jQuery.cfm">
	<script>
		$('.close_130').click(function() { window.close(); } );
	</script>
	<cfabort>       <!---bail out--->
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="qBillBack" datasource="#application.datasource#">
	SELECT BB_Code, BB_Title
		FROM Billback
	 WHERE Billback.Deleted = 0
		 AND Billback.Billback_ID = '#URL.Billback_ID#'
</cfquery>

<form method="post" name="email_statement" id="email_statement" action="#cgi.script_name#?#cgi.query_string#">
<input type="hidden" name="submitted" value="#cgi.script_name#">

<div class="title2">Message Details</div>
<hr color="orange">
<table border="0" cellpadding="2" cellspacing="0">
<tr>
	<td align="right" width="150"><b>Date:&nbsp;&nbsp;</b></td>
	<td><input type="text" name="SenderDate" size="30" value="#dateformat(now(), 'mmmmm d, yyyy')#" style="width: 2	50px;"></td>
</tr>
<tr>
	<td align="right"><b>From:&nbsp;&nbsp;</b><span id="error_SenderAddress"></span></td>
	<td><input type="text" name="SenderAddress" size="30" value="#request.accessstructure.name_first# #request.accessstructure.name_last# <#request.accessstructure.user_email#>" style="width: 250px;"></td>
</tr>
<tr>
	<td align="right"><b>Subject:&nbsp;&nbsp;</b><span id="error_SenderSubject"></span></td>
	<td><input type="text" name="SenderSubject" size="30" value="billback #qBillback.BB_Code# - #qBillback.BB_Title#" style="width:500px"></td>
</tr>
<tr>
	<td align="right" valign="top"><b>Message Body:&nbsp;&nbsp;</b></td>
	<td><textarea name="Message_Body" cols="75" rows="5"></textarea></td>
</tr>
</table>
<br>
<cfset showFormActions()>   <!---display actions at the top section--->

<!--------------------------------------------------------------------------------------------------------------------->

<div class="title2">Recipients' Email Addresses</div>
<hr color="orange">

<!--get company codes function for finding external contacts-->
<cfinclude template="\billbacks\common\companycodes.cfm">

<!---assign field name to internal email address textarea--->
<cfset emailFieldName = "recipient_email_address">

<cfmodule template="/customtags/emailRecipient.cfm"
          intEmails_name  =  #emailFieldName#
          extEmails_grid  = "yes"
          company_codes   = #CompanyCodes(URL.Billback_ID)#  >
</form>

<cfset showFormActions()>   <!---display actions at the bottom section--->
<cfmodule template="/customtags/messageWindow.cfm">

<!--------------------------------------------------------------------------------------------------------------------->

<script language="javascript" src="/script/javascript/string_functions.min.js"></script>

<script>
<!---cancel action--->
$('.cancel_130').click(function() {
	window.close();
});
<!---submit action--->
$('.email_130').click(function() {
	var ErrorCount = 0;
	<!---require sender email address--->
	if ( $.trim($('input[name=SenderAddress]').val()) ) {
		clearQueue(document.all.error_SenderAddress);
	}
	else {
		ErrorCount++;
		queueMessage("Please enter your email address", document.all.error_SenderAddress);
	}

	<!---require email subject--->
	if ( $.trim($('input[name=SenderSubject]').val()) ) {
		clearQueue(document.all.error_SenderSubject);
	}
	else {
		ErrorCount++;
		queueMessage("Please enter a subject", document.all.error_SenderSubject);
	}

	<!---gather ext contact email addresses selected via checkboxes--->
	var contacts = '';
	var recipients = $.trim($('textarea[name=#emailFieldName#]').val());
	<cfif appSettings.External_Contacts_Option neq 0>
		var contacts = selected_contacts();
		<!---combine internal & external email addresses--->
		var recipients = $.trim( combineEmails( $('textarea[name=#emailFieldName#]').val(), $('textarea[name=#emailFieldName#_2]').val()) );
	</cfif>

	<!---make sure there is at least 1 email address--->
	if ( ( recipients.length ) || ( contacts.length ) ) {
		clearQueue(document.all.error_#emailFieldName#);
		<!---combine int/ext email addresses & ext contact selected via checkboxes--->
		recipients = $.trim( combineEmails(recipients, contacts) );
		<!---stuff all email addresses into internal email address field--->
 		$('textarea[name=#emailFieldName#]').hide().val( recipients );
	}
	else {
	  ErrorCount++;
	  queueMessage("Please enter at least one email address", document.all.error_#emailFieldName#);
	}

	if (ErrorCount)
		showMessageWindow();
	else
		$('##email_statement').submit();
});
</script>
</body>
</html>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="actionLinkFormat" access="public" returntype="string" output="false">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="style" type="string" required="false" default="classic"/>

	<cfscript>
		switch (arguments.style) {
			case "classic":
				return "<b><font color='red'>[ </font>" & arguments.action & " <font color='red'> ]</font></b>"; break;
			default:
				return arguments.action;
		}
	</cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="showFormActions" access="public" output="true">
<div style="margin-left:200px;">
	<a class="email_130">#actionLinkFormat("email")#</a>
	<a class="cancel_130" style="margin-left:30px;">#actionLinkFormat("cancel")#</a>
</div>
<br>
</cffunction>
