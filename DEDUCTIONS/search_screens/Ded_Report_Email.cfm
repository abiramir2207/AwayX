<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>


<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<CFIF FORM.Form_Submitted EQ "">
	<CFSET URL.From = "Email">
	<FORM NAME="Comm_Options" ACTION="Ded_Report_Email.cfm" METHOD="POST">
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FileName" VALUE="#URL.FileName#">
	</CFOUTPUT>
	<CFINCLUDE TEMPLATE="/Deductions/Communications/Email_Fax_Print/Email_Body.cfm">
	<BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD>
				<CF_button
					button_name	=	""
					button_caption	=	"send email"
					button_action	=	"confirmCompletionEmail()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								>
			</TD>
		</TR>
	</TABLE>
	</FORM>
<CFELSE>
	<CFOUTPUT>
	<CF_EMAILWRAPPER 
			TO					=	"#FORM.Send_To#"
	        FROM				=	"#request.AccessStructure.User_Email#"
	        SUBJECT				=	"#Form.Sendersubject#"
			TYPE				=	"html" 
			MESSAGETYPE			="1" 
			GENERATEDBY			="3" 
			APPAREA				="13" 
			USERID				="#request.AccessStructure.user_id#"	>		
			
			<TABLE WIDTH="100%">
			<TR VALIGN="top">
			<TD>
			#Form.Message_Body#
			</TD>
			</TR>
			</TABLE>
				
			<cf_EmailWrapperParam file = "#FORM.FileName#" store="yes" desc="Deduction Report"> 
			
	</CF_EMAILWRAPPER>
	
	<cfset useLakebaseForSenderName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
	<cfif useLakebaseForSenderName>
		<cftry>
			<cfset SenderName = application.oLakebase.toQuery(
				application.oLakebase.selectRows("_users", {
					"select" = "name_first,name_last",
					"user_id" = "eq.#request.AccessStructure.User_ID#"
				}),
				"name_first,name_last"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSenderName = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSenderName>
	<CFQUERY NAME="SenderName" DATASOURCE="#Application.Datasource#">
		SELECT Name_First, Name_last FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#'
	</CFQUERY>
	</cfif>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Wait While Sending Email with Deduction Report Attached...</FONT></B></TD>			
		</TR>
		<TR>
			<TD>
				<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD><B><FONT COLOR="Navy" SIZE="2">From:</FONT></B></TD>
						<TD><B><FONT COLOR="Navy" SIZE="2">#SenderName.Name_First# #SenderName.Name_last#</FONT></B></TD>
					</TR>
					<TR>
						<TD><B><FONT COLOR="Navy" SIZE="2">To:</FONT></B></TD>
						<TD><B><FONT COLOR="Navy" SIZE="2">#FORM.Send_To#</FONT></B></TD>
					</TR>
					<TR>
						<TD><B><FONT COLOR="Navy" SIZE="2">Attachment:</FONT></B></TD>
						<TD><B><FONT COLOR="Navy" SIZE="2">Deduction Report</FONT></B></TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
	</TABLE>	
	
	</CFOUTPUT>
	<SCRIPT language="JavaScript">	
		window.setTimeout('window.close()', 3000);
	</SCRIPT>  
</CFIF>
<SCRIPT language="JavaScript" src="/script/javascript/string_functions.min.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
<SCRIPT language="JavaScript">
function confirmCompletionEmail()
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
	
	//var recipients = combineEmails(document.all.Send_To.value, document.all.Send_To_2.value);
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Send_To_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Send_To_2]').val();
	</cfif>
	var recipients = combineEmails(jQuery("textarea[name=Send_To]").val(),recipients_2); //ChromeFix
	if ( recipients.length == 0 )   /*25704*/
	{
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Send_To);
	}
	else
	{
		clearQueue(document.all.error_Send_To);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
  		// hide email recipient input
  		//document.all.Send_To.style.visibility = 'hidden';
	 	// combine int email recipients & ext email recipients
	 	//document.all.Send_To.value = recipients;//ChromeFix
		jQuery("textarea[name=Send_To]").hide().val(recipients);
		//Email.submit()
		document.Comm_Options.Form_Submitted.value = 1;
		document.Comm_Options.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}
</SCRIPT>
<CF_MessageWindow>
</body>
</html>
