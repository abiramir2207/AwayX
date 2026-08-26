<CFSET PAGE_TITLE="Email Billback">

<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<BLOCKQUOTE>

<BR><BR>
<H4 STYLE="Color: Red;">
The following Fax has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<CFQUERY NAME="Fax_Documents" DATASOURCE = "#Application.Datasource#">
	SELECT 		Doc_Uni_Name,
				doc_title 
	FROM		Document_Details
	WHERE 		1=2 <CFIF isdefined("FORM.Doc_ID")> OR Doc_ID IN (#ListQualify(FORM.Doc_ID, "'", ",")#)</CFIF> 
</CFQUERY>
</CFOUTPUT>

<CFSET HTML_File_Path = Form.HTML_File_Path>
<CFSET Display_None_Attachments = 1>
<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>

		<CFOUTPUT>
		<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0">
		<TR>
			<TD VALIGN="top"><B>Date:</B></TD>
			<TD ROWSPAN="100%" BGCOLOR="Orange"></TD>
			<TD>#Form.SenderDate#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>From:</B></TD>
			<TD>#Form.Senderaddress#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
		<TR>
			<TD VALIGN="top">Enclosure:</TD>
			<TD>Payble Number: #FORM.Payable_No#			
			<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")><br>#Doc_Title#</CFIF></CFLOOP></CFIF>
			</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Program</B></TD>
			<TD>
			<CFIF NOT FileExists("#Application.Doc_Path##HTML_File_Path#")>
				
				<CFINCLUDE TEMPLATE="Billback_Summary_Save.cfm">
				<CFSET HTML_File_Path=Billback_HTML_File_Path>
			</CFIF>
			<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##HTML_File_Path#">
			</TD>
		</TR>
		
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
			
		</TR>
		</TABLE>
		</CFOUTPUT>
</CFSAVECONTENT> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#</CFOUTPUT>	

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
        <span style="font-size: 13pt">#FORM.Senderaddress#</span></font></TD>
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Subject:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.Sendersubject#</span></font></TD>
 </TR>
  <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Message:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.Message_Body#</span></font></TD>
 </TR> 
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Enclosure:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">Please find the following document(s)<BR><BR>
		&nbsp;&nbsp;&nbsp;&nbsp;Payable Number: #FORM.Payable_No#
		<CFIF Fax_Documents.recordcount GT 0>
			<CFLOOP QUERY="Fax_Documents">
				<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>	
				<br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#
				</CFIF>
			</CFLOOP>
		</CFIF>
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
<!--- <CFSET Finddot = FIND(".",#HTML_File_Path#)>
#FINDDOT#<br> --->
 <CFSET CS_File_Name = replace(#HTML_File_Path#,".","_CS.")>
 
 <CFFILE action = "write"
		file="#Application.Doc_Path#\#CS_File_Name#"
		output="#Cover_sheet#">    
<!--- #APPLICATIONPATH# #HTML_File_Path# --->

</CFOUTPUT>

<!------<CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Form_Fax_Numbers#" DELIMITERS=";">
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP>----->
<!--- <cfinvoke 
     component="components.general.General_Functions" 
     method="Get_Fax_Email_Address" 
     Source_Fax_Numbers="#Form_Fax_Numbers#"
     Name_First="#request.AccessStructure.Name_First#"
     Name_Last="#request.AccessStructure.Name_Last#"
     returnVariable="Fax_Numbers_List"> --->


<cfset Fax_Numbers_List = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=Form_Fax_Numbers,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />

<!--- <CFLOCATION URL="#APPLICATIONPATH##CS_File_Name#" ADDTOKEN="no">
<CFABORT> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFMAIL TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com" 
		SUBJECT="#Form.SenderSubject#"> --->
	<CF_EMAILWRAPPER TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="#Form.SenderSubject#"
		messageType="2" 
		generatedby="3" 
		apparea="3" 
		userid="#request.AccessStructure.user_id#">
		
<!--- 		<CFMAILPARAM FILE = "#APPLICATIONPATH##CS_File_Name#">
		<CFMAILPARAM FILE = "#APPLICATIONPATH##HTML_File_Path#"> --->
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##CS_File_Name#" store="yes" />
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##HTML_File_Path#" store="yes" />
		<CFIF Fax_Documents.recordcount GT 0>		
		<CFLOOP QUERY = "Fax_Documents">
		<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>		
		<!--- <CFMAILPARAM FILE = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#"> --->
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#" store="yes" />
		</CFIF>
		</CFLOOP>
		</CFIF> 
		<!--- #Form.Message_Body# --->
<!--- </CFMAIL>  --->
</CF_EMAILWRAPPER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


 
<CF_button
	button_name		=	""
	button_caption	=	"return to summary"
	button_action	=	"window.location.href='../capture/Billback_Summary.cfm?BBID=#Form.Billback_ID#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to billback summary..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
 
 
 
 
</BLOCKQUOTE>
</BODY>
</HTML>

