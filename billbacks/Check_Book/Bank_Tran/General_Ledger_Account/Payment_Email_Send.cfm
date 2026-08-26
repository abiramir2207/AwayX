


<CFSAVECONTENT VARIABLE = "Email_Body">
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>Date:</B></TD>
		<TD>&nbsp;&nbsp;#Form.SenderDate#</TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>From:</B></TD>
		<TD>&nbsp;&nbsp;#Form.Sender_Name#</TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>Subject:</B></TD>
		<TD>&nbsp;&nbsp;#Form.Sendersubject#</TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>Message:</B></TD>
		<TD>&nbsp;&nbsp;#Form.Message_Body#</TD>
	</TR>
</TABLE>
</CFOUTPUT>
</CFSAVECONTENT>

<CFMAIL TO			=	"#Send_To#"
        FROM		=	"forgetrade@bigredflame.com"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html">
		<TABLE HEIGHT="100%" WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		<TR VALIGN="top">
		<TD>
		Attachments: Payment Details
		</TD>
		</TR>
		<TR VALIGN="bottom">
		<TD>
		<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
		</TD>
		</TR>
		</TABLE>
		<CFIF isdefined("FORM.Att_File_List")>
			<CFLOOP	INDEX="Separated_File_Name" LIST="#Form.Att_File_Name#" DELIMITERS=",">
				<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Separated_File_Name#")>
					<CFMAILPARAM FILE = "#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#Separated_File_Name#">
				</CFIF>
			</CFLOOP>
		<CFELSE>
			<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#FORM.Att_File_Name#")>
				<CFMAILPARAM FILE = "#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\#request.AccessStructure.User_ID#\#FORM.Att_File_Name#">
			</CFIF>
		</CFIF>
</CFMAIL>




<CFIF Not isdefined("FORM.Att_File_List")>
<H4 STYLE="Color: Red;">
The following Email has been sent...<BR><BR>
</H4>
<CFOUTPUT>#Email_Body#</CFOUTPUT><BR><BR>
<CFINCLUDE template="#Application.Doc_Mapping#/temp_files/billback/check_book/Bank_Tran/General_Ledger_Account/Email_Files/#request.AccessStructure.User_ID#/#FORM.Att_File_Name#">
<CFELSE>
<TABLE ALIGN="Center">
	<TR>
		<TD><BR><BR><BR><BR><H4 STYLE="Color: Red;">
			The following Email has been sent...<BR><BR>
			</H4>
		</TD>
	</TR>
	<TR>
		<TD><CFOUTPUT>#Email_Body#</CFOUTPUT></TD>
	</TR>
	<TR>
		<TD><BR><BR><H4 STYLE="Color: Red;">
			With all Payment Requests as attachments<BR><BR>
			</H4>
		</TD>
	</TR>
</TABLE>
</CFIF>
<SCRIPT language="JavaScript">
function close_window()
{
	window.close();
}
window.setTimeout('close_window()', 3000);
</SCRIPT>