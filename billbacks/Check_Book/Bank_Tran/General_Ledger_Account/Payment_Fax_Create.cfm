
<BR>

<FONT SIZE="3" COLOR="Navy"><B>Message Details:</B></FONT>
<HR COLOR="Orange">
<FORM NAME="Prepare_Fax" ACTION="Payment_Fax_Send.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="Att_File_Name" VALUE=<CFOUTPUT>"#File_Name#"</CFOUTPUT>>
<CFIF isdefined("URL.Fax_All")>
<INPUT TYPE="Hidden" NAME="Att_File_List" VALUE="1">
</CFIF>
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
	<TR>
		<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
		<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B></TD>
		<TD><INPUT TYPE="Text" NAME="Sender_Name" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)"STYLE="width: 250px;"> </TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B></TD>	
		<TD><INPUT TYPE="Text" NAME="SenderSubject" SIZE="30" VALUE="Payment Request <CFIF isdefined("NUM_Payment_Request")>(#NUM_Payment_Request#)</CFIF>"></TD>	
	</TR>
	<TR>
		<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
		<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA></TD>
	</TR>
</TABLE>
</CFOUTPUT>
<BR><BR>
<FONT SIZE="3" COLOR="Navy"><B>Recipients' Email Addresses:</B></FONT>
<HR COLOR="Orange">

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B></TD>
	<TD>
		<TEXTAREA NAME="Fax_Number" COLS="75" ROWS="5" <!--- onKeyUp="clenseText(this, '0123456789;')" ---> STYLE="width:540px;"></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>
<BR><BR>
<TABLE ALIGN="Center">
	<TR>
		<TD>
			<CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"Send Fax"
					button_action	=	"document.Prepare_Fax.submit()"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
			</CFOUTPUT>
		</TD>
	</TR>
</TABLE>
</FORM>
<CFIF Not isdefined("URL.Fax_All")>
<!--- <FONT SIZE="3" COLOR="Navy"><B>Payment Details:</B></FONT> --->
<CFOUTPUT>#Mail_Fax#</CFOUTPUT>
</CFIF>

<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
		<script>