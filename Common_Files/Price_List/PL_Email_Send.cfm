<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFSAVECONTENT VARIABLE = "Email_Body">
<CFOUTPUT> 
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>Date:</B></TD>
		<TD>&nbsp;&nbsp;#Form.SenderDate#</TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>From:</B></TD>
		<TD>&nbsp;&nbsp;#Form.SenderAddress#</TD>
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

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Repalcing Price list file name with description													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CF_Naming_Email_Attachments 
				Title="PL_#Descp#" 
				Relative_Src_File_Path="temp_Files\Price_List\Temp_Email_Fax\#FORM.File_Name#"  
				Relative_Dest_Dir_Path ="Temp_Files\Price_List" 
				Return_Variable_Name="PL_File_name">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <CFMAIL TO			=	"#FORM.Recipient_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html">  --->
	<cfoutput>
	<CF_EMAILWRAPPER 
		TO			=	"#FORM.Recipient_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="3" 
		apparea="12" 
		userid="#request.AccessStructure.user_id#"> 
		<TABLE WIDTH="100%">		
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		<TR VALIGN="top">
		<TD>
		Attachment: Price List Details
		</TD>
		</TR>
		</TABLE>		
		<CFIF FILEEXISTS("#PL_File_name#")>
			<!--- <CFMAILPARAM FILE = "#PL_File_name#"> --->
			<CF_EMAILWRAPPERPARAM FILE = "#PL_File_name#" store="yes">
		</CFIF>		
		<!--- <CFIF FILEEXISTS("#APPLICATIONPATH#\Common_Files\Price_List\Temp_Email_Fax\#FORM.File_Name#")>
			<CFMAILPARAM FILE = "#APPLICATIONPATH#\Common_Files\Price_List\Temp_Email_Fax\#FORM.File_Name#">
		</CFIF> --->
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
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
			With price list detail as an attachment<BR><BR>
			</H4>
		</TD>
	</TR>
</TABLE>


<SCRIPT language="JavaScript">
function close_window()
{
	window.close();
}
window.setTimeout('close_window()', 3000);
</SCRIPT>
</body>
</html>
