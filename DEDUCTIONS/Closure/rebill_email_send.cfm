<CFSET PAGE_TITLE="Email Rebill">
<CFSET GROUP="contracts">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">
function hide_PleaseWaitMessage()
{
 document.all.PleaseWaitMessage.style.display='none';
}
document.body.onload=new Function ("hide_PleaseWaitMessage();");
</SCRIPT>


<cfif len(trim(Form.Broker_Address)) GT 0>
<BR><BR>
<H4 STYLE="Color: Red;">
The following email has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset ShowDetails=1>
<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>
	
	<cfset Print = 1>

		<CFOUTPUT>
		<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0" width="100%">
		<TR>
			<TD VALIGN="top"><B>Date:</B></TD>
			<TD ROWSPAN="100%" BGCOLOR="Orange"></TD>
			<TD>#Form.SenderDate#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>From:</B></TD>
			<TD>#Form.Senderaddress#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>To:</B></TD>
			<TD>#Form.Broker_Address#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
					<TR>
			<TD VALIGN="top"><B>Rebill:</B></TD>
			<TD><CFINCLUDE TEMPLATE="#Application.Doc_Mapping##HTML_File_Path#"></TD>
		</TR>
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>
		
		</CFOUTPUT>
</CFSAVECONTENT> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#</CFOUTPUT>	

	<cfoutput>

	<CF_EMAILWRAPPER 
		TO			=	"#Broker_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="3" 
		apparea="13" 
		userid="#request.AccessStructure.user_id#"
		app_area_identifier="#Deduction_ID#"
		>
		
		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		</TABLE>
		<!--- <cfmailparam file = "#Invoice_FN#"> --->
	<cf_EmailWrapperParam file = "#FileLocation#" store="yes"> 
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfelse>

You did not enter an email address to which to send this page.
</cfif>

<cfset useLakebaseForUpdateDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDeduction>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{
				"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"dd_closed_by" = request.AccessStructure.User_ID,
				"dd_resolution_code" = ReasonCode,
				"dd_status" = 4,
				"dd_closure_method" = 2
			}
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateDeduction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDeduction>
	<cfquery name="UpdateDeduction" datasource="#application.datasource#">
	UPDATE Deductions
	SET DD_Date_Closed = getdate(),
		DD_Closed_By = '#request.AccessStructure.User_ID#',
		DD_Resolution_Code = '#ReasonCode#',
		DD_Status = 4,
		DD_Closure_Method = 2
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<!---Close any reminders associated with this--->
<cfset useLakebaseForCloseReminders = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
<cfif useLakebaseForCloseReminders>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_reminders",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "dd_reminder_status" = 1 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCloseReminders = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCloseReminders>
	<cfquery name="CloseReminders" datasource="#application.datasource#">
	UPDATE DD_Reminders
	SET DD_Reminder_Status = 1
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<table width="100" align="Center">
<tr>
<td>
<cfoutput>
<CF_button
	button_name		=	""
	button_caption	=	"return to deduction home"
	button_action	=	"window.parent.location.href='/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Return to deduction home..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
	</cfoutput>
</td>

	</tr>
	</table>

	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>

