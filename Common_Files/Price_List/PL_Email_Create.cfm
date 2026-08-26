<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfinclude template="Price_List_Detail_Content.cfm">
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
			
		//if(document.all.Recipient_Address.value.length == 0) CHROMEFIX
		var raddrStr = jQuery("textarea[name=Recipient_Address]").val();
		if(raddrStr.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one email address", document.all.error_Recipient_Address);
		}
		else
		{
			clearQueue(document.all.error_Recipient_Address);
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

<FORM ACTION="PL_Email_Send.cfm" METHOD="post" NAME="Email" ID="MyForm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="75"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="90" VALUE="Price List: #Get_Desc.Descp# (#URL.PL_ID#)"></TD>
</TR>
<!--- <INPUT TYPE="Hidden" NAME="Program_no" VALUE="#Get_Program_Details.Contract_Number#"> --->

<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message:&nbsp;&nbsp;</B></TD>
	<TD ><TEXTAREA NAME="Message_Body" COLS="92" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="75" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Recipient_Address"></span></TD>
	<TD><TEXTAREA NAME="Recipient_Address" COLS="45" ROWS="5"></TEXTAREA>
	</TD>
	<TD ALIGN="left">
	<CF_Email_Address_Lookup 
			Destination_Form_Name="Email"
			Destination_Field_Name="Recipient_Address"
			width="200"
			size="5"
			Alert="true">
	</TD>
</TR>
<TR>	
	<TD>&nbsp;</TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
</TABLE>

<BR><BR>
<TABLE align="center">
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

<CFSET Unique_ID = createUUID()>
<CFSET File_Name = "#Replace(Unique_ID,"-","_","all")#.html">

<CFFILE ACTION	=	"WRITE"
		FILE	=  	"#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\#File_Name#"
		OUTPUT	=	"#savethis_todispaly#">

<INPUT TYPE="Hidden" NAME="File_Name" VALUE=<CFOUTPUT>"#File_Name#"</CFOUTPUT>> 
<INPUT TYPE="Hidden" NAME="Descp" VALUE=<CFOUTPUT>"#Get_Desc.Descp#"</CFOUTPUT>> 
</FORM>


<!--- <cfoutput>#savethis_todispaly#</cfoutput> --->
</body>
</html>
