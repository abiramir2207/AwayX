<!doctype html>
<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Date:
      Author:   Chris Nguyen
      Purpose:

      Parameters:

----------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<cfoutput>
<head>
	<cfsavecontent variable="head_content">
		<title>Email Planner</title>
		<style>
		.title2 {
			font-weight:bold;
			font-size:10pt;
		}
		.email_130,
		.cancel_130 {
			cursor : pointer;
		}
		table.email { margin-bottom: 25px; }
			table.email tr { height:32px; }
			table.email td:nth-child(1) { font-weight:bold; text-align:left; width:88px; }
		.recipients { margin-left:95px; width:700px; border:0; }
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<!--- <cfdump var="#form#"> --->
<cfparam name="form.senderSubject" default="">
<cfparam name="form.attachments"   default="">  <!---full path of attachments delimited by commas--->
<cfparam name="form.attachment_content" default="">

<!--------------------------------------------------------------------------------------------------------------------->

<cfif StructKeyExists(form, "submitted") and form.submitted eq cgi.script_name>
	<cfinclude template="/common_files/jQuery.cfm">
	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQueryUI.cfm">
	<cfset StructAppend(form, url, "no")>   <!---merge URL into form--->
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
			<cf_emailwrapperparam file = "#expandPath( '/common_documents/temp_files/' & vars.attachment)#">
		</cfloop>
	</cf_emailwrapper>
	<div style="font-size:14px;letter-spacing:0.75px;color:red" class="shadow">The following email has been sent...</div>
	<hr class="two">
	<table border="0" cellpadding="2" cellspacing="0" class="sent email">
		<tr>
			<td>Date:</td>
			<td><input type="text" name="SenderDate" size="30" value="#dateformat(now(), 'mmmmm d, yyyy')#" style="width: 2	50px;"></td>
		</tr>
		<tr>
			<td>From:<span id="error_SenderAddress"></span></td>
			<td><input type="text" name="SenderAddress" size="30" value="#form.senderAddress#>" style="width: 250px;"></td>
		</tr>
		<tr>
			<td>Subject:<span id="error_SenderSubject"></span></td>
			<td><input type="text" name="SenderSubject" size="30" value="#form.senderSubject#" style="width:500px"></td>
		</tr>
		<tr>
			<td valign="top">Message Body:</td>
			<td><textarea name="Message_Body" cols="75" rows="5">#form.message_body#</textarea></td>
		</tr>
		<cfif form.attachments neq "">
			<tr>
				<td>Attachments:</td>
				<td>#form.attachments#</td>
			</tr>
		</cfif>
		<tr>
			<td valign="top">Recipients:</td>
			<td><textarea name="Message_Body" cols="75" rows="5">#form.recipient_email_address#</textarea></td>
		</tr>
	</table>
	<div style="margin:25px 0 0 150px;">
		<a class="close_130 primary" style="margin-left:30px;">#application.util.string.LinkFormat("close window")#</a>
	</div>
	<script>
		$('.close_130').click(function() { window.close(); } );
	</script>
	<cfabort>       <!---bail out--->

<cfelseif form.attachments neq "" and form.attachment_content neq "">
	<cffile action="write" file="#expandPath( '/common_documents/temp_files/' & form.attachments)#" output="#form.attachment_content#"></cffile>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<form method="post" name="email_statement" id="email_statement">
<input type="hidden" name="submitted" value="#cgi.script_name#">
<input type="hidden" name="attachments" value="#form.attachments#">

<div class="title2 shadow">Message Details</div>
<hr class="four">
<table border="0" cellpadding="2" cellspacing="0" class="email">
	<tr>
		<td>Date:</td>
		<td><input type="text" name="SenderDate" size="30" value="#dateformat(now(), 'mmmmm d, yyyy')#" style="width: 2	50px;"></td>
	</tr>
	<tr>
		<td>From:<span id="error_SenderAddress"></span></td>
		<td><input type="text" name="SenderAddress" size="30" value="#request.accessstructure.name_first# #request.accessstructure.name_last# <#request.accessstructure.user_email#>" style="width: 250px;"></td>
	</tr>
	<tr>
		<td>Subject:<span id="error_SenderSubject"></span></td>
		<td><input type="text" name="SenderSubject" size="30" value="#form.senderSubject#" style="width:500px"></td>
	</tr>
	<tr>
		<td valign="top">Message Body:</td>
		<td><textarea name="Message_Body" cols="75" rows="5"></textarea></td>
	</tr>
	<cfif form.attachments neq "">
		<tr>
			<td>Attachments:</td>
			<td>#form.attachments#</td>
		</tr>
	</cfif>
</table>

<!--------------------------------------------------------------------------------------------------------------------->

<div class="title2 shadow">Recipients' Email Addresses</div>
<hr class="four">

<!---assign field name to internal email address textarea--->
<cfset emailFieldName = "recipient_email_address">
<cfmodule template="/customtags/emailRecipient.cfm"
          intEmails_name  =  #emailFieldName#
          table_class     = "recipients"
          intEmails_size  = "rows=6 cols=115"
          extEmails_size  = "rows=6 cols=115"
          company_codes   = ""  >
</form>

<div style="margin:15px 105px;">
	<a class="email_130 primary">#application.util.string.LinkFormat("email")#</a>
	<a class="cancel_130 secondary" style="margin-left:30px;">#application.util.string.LinkFormat("cancel")#</a>
</div>
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
<cfinclude template="/common_files/focus.cfm">
</body>
</cfoutput>
</html>
