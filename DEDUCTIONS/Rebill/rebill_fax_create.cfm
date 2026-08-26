<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Fax Rebill Letter</TITLE>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
		<script>

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
		if(document.all.Form_Fax_Numbers.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one fax number", document.all.error_Fax_Numbers);
		}
		else
		{
			clearQueue(document.all.error_Form_Fax_Numbers);
		}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		Fax.submit()
		
	}
	else 
	{
		showMessageWindow()
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
<FORM ACTION="rebill_fax_send.cfm" METHOD="post" NAME="Fax" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;" READONLY></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;" READONLY></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Rebill Notice" STYLE="width: 500px;"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>

<BR><BR>
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
WHERE DD_Rebill_Log_ID = '#DD_Rebill_Log_ID#'
</cfquery>
</cfif>
<SPAN CLASS="title2">Recipients' Fax Numbers</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Fax_Numbers"></span></TD>
	<TD>
		<TEXTAREA NAME="Form_Fax_Numbers" COLS="75" ROWS="5" onKeyUp="clenseText(this, '0123456789;')"></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>

<cfoutput>
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="DD_Rebill_Log_ID" value="#DD_Rebill_Log_ID#">
</cfoutput>

<BR CLEAR="ALL">
<BR>



<TABLE ALIGN="center">
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send fax"
				button_action	=	"confirmCompletion();"
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
 
</FORM>


<BR><BR>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Billback Details</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##Billback_HTML_File_Path#">

</BLOCKQUOTE>
</BODY>
</HTML>

 