<CFSET PAGE_TITLE="Fax Reimbursement">

<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>


<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">
function hide_PleaseWaitMessage()
{
 document.all.PleaseWaitMessage.style.display='none';
}
document.body.onload=new Function ("hide_PleaseWaitMessage();");
</SCRIPT>

<!---Include header--->
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<BLOCKQUOTE>

<BR><BR>

<cfif len(Form.Fax_Numbers) GT 0>
<H4 STYLE="Color: Red;">
The following Fax has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<cfset ShowLinks = 0>
		
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
			<TD VALIGN="top"><B>Program</B></TD>
			<TD>
			<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
		<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
		
		<!--- Build file name --->
		<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
			<CFSET HTML_File_Path="\temp_files\billback\reimbursements\utilities\htmlfiles\#filename_email#.htm">
			<CFIF NOT FileExists("#Application.Doc_Path##HTML_File_Path#")>
				<CFINCLUDE TEMPLATE="Summary_Save.cfm">
				<CFSET HTML_File_Path=HTML_File_Path>
			</cfif>
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

<!--- ---------------------------------------------------------------------------------------- --->
<!--- Cover Sheet --->
<!--- ---------------------------------------------------------------------------------------- --->
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
        <span style="font-size: 13pt">#Form.Message_Body#</span></font></TD>  
 </TR>
  <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Comments:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">
<!--- 		<TABLE>
			<TR>
				<TD ALIGN="Right">Distributor Name:</TD>
				<TD>#DistributorName#</TD>
			</TR>
			<TR>
				<TD ALIGN="Right">Program Number:</TD>
				<TD>#GetProgramNumber.Contract_Number#</TD>
			</TR>
			<TR>
				<TD ALIGN="Right">Program Title:</TD>
				<TD>#ProgramName#</TD>
			</TR>
		</TABLE>---> --->
		<!--- Distributor Name: #DistributorName#<BR>Program Number: #GetProgramNumber.Contract_Number#<BR>Program Title: #ProgramName# ---></span></font></TD>  
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
        <br>
        <br>
        <br>

&nbsp;</TD>  
 </TR>
</TABLE> 
<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
 </CFSAVECONTENT>

<CFSET CS_HTML_File_Path="\temp_files\billback\reimbursements\utilities\htmlfiles\CS_#filename_email#.html">


<CFFILE action = "write"
		file="#Application.Doc_Path##CS_HTML_FILE_Path#"
		output="#Cover_sheet#">    
 </CFOUTPUT>
<!--- ###################################################################################### --->

<CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Form.Fax_Numbers#" DELIMITERS=";">
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->

<!---  <CFMAIL TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com" 
		SUBJECT="#Form.SenderSubject#"> --->
	 <CF_EMAILWRAPPER 
	 	TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="#Form.SenderSubject#"
		messageType="2"
		generatedby="3" 
		apparea="3" 
		userid="#request.AccessStructure.user_id#">
		<!--- #Form.Message_Body# --->
		<!--- #Cover_sheet# --->
<!--- 		<CFMAILPARAM FILE = "#ApplicationPath##CS_HTML_FILE_Path#">
		<CFMAILPARAM FILE = "#ApplicationPath##HTML_File_Path#"> --->
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##CS_HTML_FILE_Path#" store="yes" />
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##HTML_File_Path#" store="yes" />

<!--- </CFMAIL>   --->
</CF_EMAILWRAPPER>
<cfelse>
You did not include a fax number to send this information to.

</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfset ReturnPage = "/billbacks/reimbursements/detail.cfm?BB_Reimbursement_ID=" & BB_Reimbursement_ID>


 <table width="100%"><tr>
 <td>
<CF_button
	button_name		=	""
	button_caption	=	"return to summary"
	button_action	=	"window.location.href='#ReturnPage#'"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to billback summary..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
	</td>

	</tr></table>
</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

