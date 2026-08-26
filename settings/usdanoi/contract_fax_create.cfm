<CFSET PAGE_TITLE="Fax Contract">
<CFSET GROUP="contracts">
<CFSET Fax_number = "">
<CFSET Fax_List = "">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
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
		if(document.all.Fax_Number.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one fax number", document.all.error_Fax_Number);
		}
		else
		{
			clearQueue(document.all.error_Fax_Number);
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

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>


<!--- 
<BR><BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=9>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->



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

<CFSET completepath_email=url.file>




<FORM ACTION="contract_fax_send.cfm" METHOD="post" NAME="Fax">




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
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="USDA NOI Report" STYLE="width:540px;"></TD>
</TR>
<INPUT TYPE="Hidden" NAME="Program_no" VALUE="">
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA><BR>
</TD>
</TR>
</TABLE>
</CFOUTPUT>

<BR><BR>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<!--- <CFINCLUDE template="Email_Fax_Program_Attachments.cfm"> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Fax Numbers</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Fax_Number"></span></TD>
	<TD>
		<TEXTAREA NAME="Fax_Number" COLS="75" ROWS="5" onKeyUp="clenseText(this, '0123456789;')" STYLE="width:540px;"><CFOUTPUT>#Fax_Number#</CFOUTPUT></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>



<BR><BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Program Details</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFINCLUDE TEMPLATE="#url.file#">

<input type="Hidden" name="file" value="<cfoutput>#url.file#</cfoutput>">
<br clear="all">
<BR>

<CF_button
	button_name		=	""
	button_caption	=	"send fax"
	button_action	=	"javascript:confirmCompletion();"
	button_type		=	"link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to send a fax..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">






</FORM>
</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

