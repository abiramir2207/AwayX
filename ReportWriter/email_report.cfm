<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
      Template: 
      Date:     2013 June
      Author:   Chris Nguyen
      Purpose:  
      
      Parameters:
      
        1. form.Attachments (required): Commas-delimited list of attachments (use full path)
        2. form.Subject (optional)
----------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<html lang="en">
<head>
 <cfparam name="form.subject"     default="">  
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <cfoutput><title>#form.subject#</title></cfoutput>
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
 font {
 	font-family: Arial;
 	font-size: 1em;
 }
 </style>
</head>
<body>

<cfparam name="form.attachments" default="">  <!---full path of attachments delimited by commas--->

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>
<cfset appSettings = genSettingsManager.get()>

<!--------------------------------------------------------------------------------------------------------------------->

<cfif StructKeyExists(form, "submitted") and form.submitted eq cgi.script_name>
	<cfset StructAppend(form, url, "no")>   <!---merge URL into form--->
	<!---<cfdump var="#form#" label="" format="html" showudfs="false" metainfo="false" abort=true>--->
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
		<cfif StructKeyExists(form, 'clause')>
			#replaceNoCase(replaceNoCase(form.clause,'<pre>',''),'</pre>','')#
		</cfif>
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
		<a class="close_130" style="margin-left:30px;">#application.util.string.actionLinkFormat("close window")#</a>
	</div>
	<cfinclude template="/common_files/jQuery.cfm">
	<script>
		$('.close_130').click(function() { window.close(); } );
	</script>
	<cfabort>       <!---bail out--->
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<form method="post" name="email_statement" id="email_statement" action="#cgi.script_name#?#cgi.query_string#">
<input type="hidden" name="submitted" value="#cgi.script_name#">
<input type="hidden" name="attachments" value="#form.attachments#">
<input type="hidden" name="subject" value="#form.subject#">

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
	<td><input type="text" name="SenderSubject" size="30" value="#form.subject#" style="width:500px"></td>
</tr>
<tr>
	<td align="right" valign="top"><b>Message Body:&nbsp;&nbsp;</b></td>
	<td><textarea name="Message_Body" id="Message_Body" cols="100" rows="8"></textarea></td>
</tr>
</table>
<br>
<cfset showFormActions()>   <!---display actions at the top section--->

<!--------------------------------------------------------------------------------------------------------------------->

<div class="title2">Recipients' Email Addresses</div>
<hr color="orange">

<!---assign field name to internal email address textarea--->
<cfset emailFieldName = "recipient_email_address">

<cfmodule template="/customtags/emailRecipient.cfm"
          intEmails_name  =  #emailFieldName#
          extEmails_grid  = "no"
          include         = "internal"
          intEmails_label = ""
          company_codes   = ""  >

<cfif StructKeyExists(form, 'clause') and form.clause neq "<pre></pre>">
	<div class="title2" style="margin-top:10px;">Clause</div>
	<hr color="orange">
	#replaceNoCase(replaceNoCase(form.clause,'<pre>',''),'</pre>','')#
	<input type="hidden" name="clause" value="#HTMLCodeFormat(form.clause)#">
</cfif>
</form>

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
</body>
</html>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="showFormActions" access="public" output="true">
<div style="margin-left:200px;">
	<a class="email_130">#application.util.string.actionLinkFormat("email")#</a>  
	<a class="cancel_130" style="margin-left:30px;">#application.util.string.actionLinkFormat("cancel")#</a>
</div>
<br>
</cffunction>
