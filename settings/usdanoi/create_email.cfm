

<CFSET PAGE_TITLE="Email NOI Report">
<CFSET GROUP="contracts">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
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
	
	var ValidEmail1 = replaceInvalidEmailCharsAndValidate(document.all.Recipient_Email_Address)
	var sBroker_Address = document.all.Recipient_Email_Address.value;
	
	if(sBroker_Address.length == 0)
	{
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Broker_Address);
	}
	else if(ValidEmail1!=true)
	{
		ErrorCount++;
	 	queueMessage("Invalid email Address <font size=2><b>" + ValidEmail1 + "</b></font> ! Please re-enter.", document.all.error_Broker_Address);
	}
	else
	{
		clearQueue(document.all.error_Broker_Address);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
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

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<STYLE>
	textarea
		{
			font-size:	12px;
			width:		500px;
		}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decode all of the URL Variables and retrieve the necessary data to populate the email fields	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<FORM ACTION="/common_files/email_common_send.cfm" METHOD="post" NAME="Email" ID="MyForm">




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="USDA Report" STYLE="width:540px;"></TD>
</TR>
<INPUT TYPE="Hidden" NAME="Program_no" VALUE="">
<INPUT TYPE="Hidden" NAME="Prog_Title" VALUE="">

<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD ><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA></TD>
</TR>
</TABLE>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

</CFOUTPUT>


<!--- <CFINCLUDE template="Email_Fax_Program_Attachments.cfm"> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Broker_Address"></span></TD>
	<TD><TEXTAREA NAME="Recipient_Email_Address" COLS="75" ROWS="5" STYLE="WIDTH:540px;" ONKEYPRESS="javaSCript: return Valid_Key_On_Email_Object();"></TEXTAREA>
	</TD>
	<TD ALIGN="left"> <!--- Dev Note: KAL; 8425 --->
	<!--- <CF_Email_Address_Lookup 
			Destination_Form_Name="Email"
			Destination_Field_Name="Broker_Address"
			width="200"
			size="5"
			Alert="true"> --->
	</TD>
</TR>
<TR>
	<TD></TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
</TABLE>

<BR><BR>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <SPAN CLASS="title2">Report Details</SPAN> ---> <!--- Dev Note: KAL; 8425 --->
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <CFSET reversed_completepath_email=reverse(completepath_email)>
<!--- <CFOUTPUT>#left(reversed_completepath_email, find("\", reversed_completepath_email)-1)#</CFOUTPUT> --->
<CFSET filename_enail=reverse(left(reversed_completepath_email, find("\", reversed_completepath_email)-1))>
<!--- <CFOUTPUT>#filename_enail#</CFOUTPUT> ---> --->

<!--- <CFINCLUDE TEMPLATE="#url.file#"> ---> <!--- Dev Note: KAL; 8425 --->


<INPUT NAME="FAX_EMAIL" TYPE="hidden" VALUE="email">
<INPUT NAME="Document_Title_File_Title" TYPE="hidden" VALUE="USDA NOI Report">
<input name="HTML_FILE_PATH" type="hidden" value="<cfoutput>#url.file#</cfoutput>">
<INPUT NAME="Redirect_To_File_Path" TYPE="hidden" VALUE="">


<BR CLEAR="ALL">
<BR>



<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send email package"
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


</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
