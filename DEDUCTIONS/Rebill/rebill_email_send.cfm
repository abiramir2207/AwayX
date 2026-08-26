<CFSET PAGE_TITLE="Email Rebill Letter">

<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<BLOCKQUOTE>

<BR><BR>
<H4 STYLE="Color: Red;">
The following Email has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>

		<CFOUTPUT>
		<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0">
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
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
		
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>
		</CFOUTPUT>
</CFSAVECONTENT> 


<cfset useLakebaseForGetLetterInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_log")>
<cfif useLakebaseForGetLetterInfo>
	<cftry>
		<cfset GetLetterInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill_log", {
				"dd_rebill_log_id" = "eq.#DD_Rebill_Log_ID#"
			}),
			"html_file_location"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetLetterInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLetterInfo>
<cfquery name="GetLetterInfo" datasource="#application.datasource#">
SELECT * FROM DD_Rebill_Log
WHERE DD_Rebill_Log_ID = #DD_Rebill_Log_ID#
</cfquery>
</cfif>

<cfinclude template="#GetLetterInfo.HTML_File_Location#">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send email..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<cfoutput>
	<CF_EMAILWRAPPER 
		TO			=	"#Form.Recipient_Email_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"
		MESSAGETYPE = 	"1"
		generatedBy	=	"3"
		appArea		=	"13" 
		userid		=	"#request.AccessStructure.user_id#">		
		
		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>		
		</TR>
		
		</TABLE>
	<!--- The cfmailparam IS the file being attached --->
	<!--- <cfmailparam file = "#Billback_FN#"> --->
	<cf_emailwrapperparam file = "#GetLetterInfo.File_Location#" store="yes">
	
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


 
<CF_button
	button_name		=	""
	button_caption	=	"return to deduction"
	button_action	=	"window.location.href='/deductions/deduction.cfm&Deduction_ID=#Form.Deduction_ID#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to deduction..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
 
 
 
 
</BLOCKQUOTE>
</BODY>
</HTML>

