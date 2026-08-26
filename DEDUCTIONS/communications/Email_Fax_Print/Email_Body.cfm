<CFPARAM NAME="URL.FROM" DEFAULT="">

<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/fixed_popup.js"></SCRIPT>
<!--- <body onload = "mytimer = setTimeout('fcsOnMe()', 25);"> --->
<body>
<cfset appSettings = application.appSettingsGet />


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details <CFIF URL.FROM EQ "Email">( Email )<CFELSE>( Fax )</CFIF>:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;" onFocus="skipcycle=true" onBlur="skipcycle=false"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;" onFocus="skipcycle=true" onBlur="skipcycle=false"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="" STYLE="width:460px;" onFocus="skipcycle=true" onBlur="skipcycle=false"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message:&nbsp;&nbsp;</B></TD>
	<TD ><TEXTAREA NAME="Message_Body" COLS="75" ROWS="3" STYLE="width:460px;" onFocus="skipcycle=true" onBlur="skipcycle=false"></TEXTAREA></TD>
</TR>

<!--- <SCRIPT language="JavaScript">
var spinnerwind;
var file_name;
function confirmation(file)
{
	file_name = file;
	var view_confirm = confirm("Large files, may take several minutes to open....");
	if (view_confirm == true)
	{
		spinnerwind = NewWindow("/Common_Files/Documents/Document_Load_Message.cfm", 'spinner111', '800', '600', 'Yes', 'No', true);				
		var timeout = window.setTimeout('gotoview()', 7500);		
	}
}

function gotoview()
{
	spinnerwind.close();
	NewWindow('http://<CFOUTPUT>#CGI.server_name#</CFOUTPUT>/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/' + file_name, 'nameeeeee', '800', '600', 'Yes', 'Yes');
}
</SCRIPT> --->

</CFOUTPUT>


<!--- <CFINCLUDE template="Email_Fax_Program_Attachments.cfm"> --->

<CFIF URL.FROM EQ "Email">

<!---
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Send_To"></span></TD>
	<TD>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
		<TD><TEXTAREA NAME="Send_To" COLS="75" ROWS="5" STYLE="WIDTH:225px;" ONKEYPRESS="javaSCript: return Valid_Key_On_Email_Object();" onFocus="skipcycle=true" onBlur="skipcycle=false"><cfif appSettings.getIncludeUsersEmailAuto()><cfoutput>#request.AccessStructure.User_Email#</cfoutput></cfif></TEXTAREA>
	</TD>
	<TD ALIGN="left">
	<CF_Email_Address_Lookup 
			Destination_Form_Name="Comm_Options"
			Destination_Field_Name="Send_To"
			width="200"
			size="5"
			Alert="true">
	</TD>
	</TABLE>
	</TD>
--->

  <tr>
    <td colspan=3><SPAN CLASS='title2'>Recipients' Email Addresses</SPAN><HR COLOR="Orange">
    </td>
  </tr>
  <!--25704 - 2011-mar-15 added ext. contacts-->
  <cfscript>
    intEmails_value = "";
    if ( appSettings.getIncludeUsersEmailAuto() ) {
      intEmails_value =  intEmails_value & request.AccessStructure.User_Email;
    }
  </cfscript>

  <!--get the shared code for companyCodes() function-->
  <cfinclude template="\deductions\companycodes.cfm">   
  
  <cfparam name="URL.Deduction_ID" default="">
  
  <cfif Len(URL.Deduction_ID)>
    <cfset company_codes = CompanyCodes(URL.Deduction_ID)>
  <cfelse>
    <cfset company_codes = "">
  </cfif>
  
  <cf_emailRecipient
          intEmails_name  = "Send_To"  
          intEmails_value = #intEmails_value#
          intEmails_size  = "rows=2 cols=100"
          extEmails_size  = "rows=2 cols=100"
          usage           = ""
          company_codes   = #company_codes#  >
</TR>
<!---<TR>
	<TD></TD>
	<TD>
	<FONT COLOR="Red"><B><I>To add more recipients, add email addresses separating them with a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
--->
<CFELSEIF URL.From EQ "Fax">
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients Fax #:&nbsp;&nbsp;</B><span id="error_Fax_Number"></span></TD>
	<TD>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
			<TR>				
				<TD>
					<TEXTAREA NAME="Fax_Number" COLS="75" ROWS="5" onKeyUp="clenseText(this, '0123456789;')" STYLE="width:460px;" onFocus="skipcycle=true" onBlur="skipcycle=false"></TEXTAREA><BR>
					<FONT COLOR="Red"><B><I>
						YOU MUST PRECEDE THE AREA CODE WITH A "1"<BR>
						To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
						Please make sure that there are no spaces, dashes in the FAX number.
						</I></B></FONT>
				</TD>
			</TR>
		</TABLE>
	</TD>
</TR>
</CFIF>
</TABLE>

<BR>
</body>
