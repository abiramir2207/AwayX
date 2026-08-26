<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Planner Program Email</TITLE>
	<cfinclude template="/common_files/jQuery.cfm">
	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQueryUI.cfm">
<script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>
<script>

	<cfparam name="sort" default="name_last"><!--- name_last --->
	<cfset appSettings = application.appSettingsGet />

	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

	var ErrorCount = 0;

	function confirmCompletion()
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
		<cfif application.appSettingsGet.External_Contacts_Option eq 0>
			var recipients_2 = jQuery('input[name=Recipient_Email_Address_2]').val();
		<cfelse>
			var recipients_2 = jQuery('textarea[name=Recipient_Email_Address_2]').val();
		</cfif>
		var recipients = combineEmails(jQuery("textarea[name=Recipient_Email_Address]").val(),recipients_2); //ChromeFix ::  Recipient_Email_Address_2 is undefined and we need to reference textarea via jQuery
		////jQuery( "input[name=Recipient_Email_Address_2]").val()  document.all.Recipient_Email_Address_2.value  document.all.Recipient_Email_Address.value
		if ( recipients.length == 0 )
		{
			ErrorCount++;
			queueMessage("Please enter at least one email address", document.all.error_Recipient_Email_Address);
		}
		else
		{
			clearQueue(document.all.error_Recipient_Email_Address);
		}

		/// SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX
		if(ErrorCount == 0)
		{
			if (typeof recipients != "undefined") {
				// hide email recipient input
				jQuery("textarea[name=Recipient_Email_Address]").hide().val(recipients);
			}
			Email.submit()
		}
		else
		{
			showMessageWindow()
		}
	}
</script>
<CF_MessageWindow>

</HEAD>

<cfsavecontent variable="variables.content">
	<cfinclude template="planner_program_view.cfm" />
</cfsavecontent>
<cfset form.attachments = "Planner_Program_#CreateUUID()#.html" />

<CFSET this.file_location = Application.Doc_path & "\Temp_Files\#form.attachments#"  />

<!--- Save the file to the server --->
<cffile action="write" file="#this.file_location#" output="#variables.content#">

<cfinclude template="../email.cfm" />
