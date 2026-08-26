<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		11px;
			}
	</STYLE>

		<CFOUTPUT>
		<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0">
		<TR>
			<TD VALIGN="top" ALIGN="Right"><B>Date:</B></TD>			
			<TD>#Form.SenderDate#</TD>
		</TR>
		<TR>
			<TD VALIGN="top" ALIGN="Right"><B>From:</B></TD>
			<TD>#Form.Senderaddress#</TD>
		</TR>
		<TR>
			<TD VALIGN="top" ALIGN="Right"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top" ALIGN="Right"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
		<TR>
			<TD VALIGN="top" ALIGN="Right"><B>Enclosure:</B></TD>
			<TD>#FORM.Descp# (#FORM.PL_ID#)
			
			</TD>
		</TR>		
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>
		</CFOUTPUT>
</CFSAVECONTENT> 


<CFOUTPUT>
 <CFSAVECONTENT VARIABLE = "Cover_sheet"> 
<TABLE CELLPADDING="5" CELLSPACING="15" BORDER="0"  width="95%">
 <TR>
  <TD NOWRAP ALIGN="Right" COLSPAN="4">
  <b>
  <font face="Arial" size="5">#application.returned_customer_setting.Company_Name#</font></b>  
  </TD>
 </TR>
 <TR>
  <TD COLSPAN="4" style="border-bottom-style: solid; border-bottom-width: 4" valign="top"></TD>
 </TR>
 <TR>
  <TD STYLE="FONT:72px;" COLSPAN="4" valign="top"><font face="Arial"><b>
        <br>
        F a x<br>
&nbsp;</b></font></TD>
 </TR>
 <TR>
  <TD width="75" rowspan="6" valign="top">&nbsp;</TD> 
  <TD ROWSPAN="6" valign="top">&nbsp;</TD>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Date:</font></B></TD>
  <TD WIDTH="100%" STYLE="FONT:16px;" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.SenderDate# </span></font></TD>  
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">From:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.SenderAddress#</span></font></TD>
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Subject:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.SenderSubject#</span></font></TD>
 </TR>
  <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Message:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.Message_Body#</span></font></TD>
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Comments:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">Please find the following documents<BR><BR>
		&nbsp;&nbsp;&nbsp;&nbsp;Price List: #FORM.Descp# (#FORM.PL_ID#)
			</span></font></TD>  
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;">&nbsp;</TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top"><br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
       
&nbsp;</TD>  
 </TR>
</TABLE> 
 
<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
</CFSAVECONTENT>
</CFOUTPUT>
 
<CFSET Unique_ID = createUUID()>
<CFSET Fax_All_File_Name = "#Replace(Unique_ID,"-","_","all")#.html">
<CFSET CSFile_Name = "#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\CS_#File_Name#">			    

<CFFILE action = "write"
		file="#CSFile_Name#"
		output="#Cover_sheet#">
		
<CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Fax_Number#" DELIMITERS=";">
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP>

<CF_EMAILWRAPPER 
	TO="#Fax_Numbers_List#"
    FROM="#application.CompanyFaxFromEmail#" 
	SUBJECT="#SenderSubject#"
	messageType="2"
	generatedby="3" 
	apparea="12" 
	userid="#request.AccessStructure.user_id#">		
		
		<CF_EMAILWRAPPERPARAM FILE = "#CSFIle_Name#" store="yes" />
		<CFIF FILEEXISTS("#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\#File_Name#")>		
			<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\#File_Name#" store="yes" />
		</CFIF>
</CF_EMAILWRAPPER> 

<!--- <CFMAIL TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com" 
		SUBJECT="#SenderSubject#"
		>		
		<CFMAILPARAM FILE = "#CSFIle_Name#">
		<CFIF FILEEXISTS("#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\#File_Name#")>		
			<CFMAILPARAM FILE = "#Application.Doc_Path#\temp_Files\Price_List\Temp_Email_Fax\#File_Name#">
		</CFIF>
</CFMAIL>  --->

<TABLE ALIGN="Center">
	<TR>
		<TD><BR><BR><BR><BR><H4 STYLE="Color: Red;">
			The following Fax has been sent...<BR><BR>
			</H4>
		</TD>
	</TR>
	<TR>
		<TD><CFOUTPUT>#Body_Content#</CFOUTPUT></TD>
	</TR>
	<TR>
		<TD><BR><BR><BR><BR><H4 STYLE="Color: Red;">
			Enclosure: Price List: <CFOUTPUT>#FORM.Descp# (#FORM.PL_ID#)</CFOUTPUT>
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
