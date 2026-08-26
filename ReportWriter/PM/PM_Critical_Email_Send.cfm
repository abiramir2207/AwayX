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


<CFINCLUDE TEMPLATE="PM_Critical_Query.cfm">
<CFINCLUDE TEMPLATE="PM_Critical_Display_Details.cfm">

<CFSET Unique_ID = createUUID()>

<!--- <CFOUTPUT>#Details#</CFOUTPUT> --->
<!--- <CFFILE ACTION	=	"WRITE"
		FILE	=  	"#APPLICATIONPATH#\Common_Files\Price_List\Temp_Email_Fax\#File_Name#"
		OUTPUT	=	"#savethis_todispaly#"> --->

<CFIF NOT DirectoryExists("#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#")>
	<CFDIRECTORY 	ACTION		=	"CREATE"
					DIRECTORY	=	"#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#">	
</CFIF>	

<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#\Critical_Projects.html")>		
	<CFFILE	ACTION	=	"DELETE"
			FILE	=	"#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#\Critical_Projects.html">
</CFIF>

<CFFILE ACTION	=	"WRITE"
		FILE	=  	"#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#\Critical_Projects.html"
		OUTPUT	=	"#Details#">
		
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
			apparea="6" 
			userid="#request.AccessStructure.user_id#"> 
			
		<TABLE WIDTH="100%">		
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		<TR VALIGN="top">
		<TD>
		Attachment: Critical Projects
		</TD>
		</TR>
		</TABLE>				
		<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#\Critical_Projects.html")>
			<!--- <CFMAILPARAM FILE = "#APPLICATIONPATH#\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#\Critical_Projects.html"> --->
			<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path#\temp_files\ReportWriter\PM\PM_Critical_Email\#request.AccessStructure.User_ID#\Critical_Projects.html" store="yes">
		</CFIF>
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
			With critial projects detail as an attachment<BR><BR>
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
