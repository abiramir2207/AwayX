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
			
		//if(document.all.Fax_Number.value.length == 0) CHROMEFIX
		var fnStr = jQuery("textarea[name=Fax_Number]").val();
		if(fnStr.length == 0)
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
	

<FORM ACTION="PL_Fax_Send.cfm" METHOD="post" NAME="Fax">

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

<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="92" ROWS="4"></TEXTAREA><BR>
</TD>
</TR>
</TABLE>
</CFOUTPUT>

<BR><BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Fax Numbers</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="75" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Fax_Number"></span></TD>
	<TD>
		<TEXTAREA NAME="Fax_Number" COLS="92" ROWS="4" onKeyUp="clenseText(this, '0123456789;')"></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX	 number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>



<BR>
<TABLE ALIGN="Center">
	<TR>
		<TD>
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


		</TD>
	</TR>
</TABLE>

<!--- <cfoutput>#savethis_todispaly#</cfoutput> --->
<CFSET Unique_ID = createUUID()>
<CFSET File_Name = "#Replace(Unique_ID,"-","_","all")#.html">

<CFFILE ACTION	=	"WRITE"
		FILE	=  	"#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\#File_Name#"
		OUTPUT	=	"#savethis_todispaly#">
<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="Descp" VALUE="#Get_Desc.Descp#">
<INPUT TYPE="Hidden" NAME="PL_ID" VALUE="#URL.PL_ID#">
<INPUT TYPE="Hidden" NAME="File_Name" VALUE="#File_Name#">
</CFOUTPUT>
</FORM>
</body>
</html>
