<CFSET PAGE_TITLE="Fax Billback Letter">

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
			<TD VALIGN="top"></TD>
			<TD></TD>
			
		</TR>
		</TABLE>
		</CFOUTPUT>
</CFSAVECONTENT> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset useLakebaseForGetLetterInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_log")>
<cfif useLakebaseForGetLetterInfo>
	<cftry>
		<cfset GetLetterInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill_log", {
				"dd_rebill_log_id" = "eq.#DD_Rebill_Log_ID#"
			}),
			"html_file_location"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetLetterInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLetterInfo>
<cfquery name="GetLetterInfo" datasource="#application.datasource#">
SELECT * FROM DD_Rebill_Log
WHERE DD_Rebill_Log_ID = #DD_Rebill_Log_ID#
</cfquery>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#</CFOUTPUT>	

<cfinclude template="#GetLetterInfo.HTML_File_Location#">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

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
 <CFSET CS_File_Name = replace(#GetLetterInfo.File_Location#,".","_CS.")>
 
 <CFFILE action = "write"
		file="#CS_File_Name#"
		output="#Cover_sheet#">    
<!--- #APPLICATIONPATH# #HTML_File_Path# --->

</CFOUTPUT>


<cfset Fax_Numbers_List = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=Form_Fax_Numbers,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />

<!--- <CFLOCATION URL="#APPLICATIONPATH##CS_File_Name#" ADDTOKEN="no">
<CFABORT> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CF_EMAILWRAPPER TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="#Form.SenderSubject#"
		messageType="2" 
		generatedby="3" 
		apparea="13" 
		userid="#request.AccessStructure.user_id#">
		
<!--- 		<CFMAILPARAM FILE = "#APPLICATIONPATH##CS_File_Name#">
		<CFMAILPARAM FILE = "#APPLICATIONPATH##HTML_File_Path#"> --->
		<CF_EMAILWRAPPERPARAM FILE = "#CS_File_Name#" store="yes" />
		<CF_EMAILWRAPPERPARAM FILE = "#GetLetterInfo.File_Location#" store="yes" />
		
		<!--- #Form.Message_Body# --->
<!--- </CFMAIL>  --->
</CF_EMAILWRAPPER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


 
<CF_button
	button_name		=	""
	button_caption	=	"return to deductions"
	button_action	=	"window.location.href='/deductions/inc_deduction_details.cfm?Deduction_ID=#Form.Deduction_ID#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to deduction..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
 
 
 
 
</BLOCKQUOTE>
</BODY>
</HTML>

