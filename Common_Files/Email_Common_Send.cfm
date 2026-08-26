<!------
Email_Common_Send.cfm
----->
<CFSET RETURN_URL_KEYWORK = "RETURN_URL_">
<CFSET PAGE_TITLE="Email Document">
<CFPARAM NAME="Form.CC_Recipient_Email_Address" DEFAULT="">
<cfparam name="form.attachment_Type" default="htm">       <!---28598--->
<cfparam name="form.pdf_footer" default="">

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
The following <CFOUTPUT>#LCase(Form.FAX_EMAIL)#</CFOUTPUT> has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Dev Note: KAL; 8425 --->
<cfset FORM.HTML_File_Path = ReplaceNoCase("#Form.HTML_File_Path#", "/Common_Documents", "", "ALL")>

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
			<CFSET EMAIL_SEND_AS_FORM_ELEMS = "">
			<CFLOOP COLLECTION="#Form#" ITEM="FormItem">
				<CFSET "#FormItem#"="#Evaluate("Form.#FormItem#")#">
				<CFOUTPUT>
				<CFIF Left(FormItem, Len(RETURN_URL_KEYWORK)) EQ RETURN_URL_KEYWORK>
					<CFSET EMAIL_SEND_AS_FORM_ELEMS = ListAppend(EMAIL_SEND_AS_FORM_ELEMS, "#Right(FormItem, Evaluate("#Len(FormItem)# - #Len(RETURN_URL_KEYWORK)#"))#=#Evaluate("#FormItem#")#", "&")>
				</CFIF>
				</CFOUTPUT>
			</CFLOOP>
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

<CFSET Proper_File_Title = FORM.Document_Title_File_Title>

<cfif form.attachment_Type neq "pdf">
<CF_Naming_Email_Attachments
				Title= "#Proper_File_Title#"
				Relative_Src_File_Path="#HTML_File_Path#"
				Relative_Dest_Dir_Path ="\Temp_Files\Billback\BB_Details"
				Return_Variable_Name="Proper_File_Path">
<cfelse>
	<!---28598--->
	<CFSET vars.CT_File_Path = "">
	<cfif IsDefined("request.ApplicationPath")>
		<CFSET vars.CT_File_Path = request.ApplicationPath>
	<cfelseif IsDefined("ApplicationPath")>
		<cfset vars.CT_File_Path = ApplicationPath>
	</cfif>

	<cfif IsDefined("Application.Doc_Path")>
		<CFSET vars.CT_File_Path = Application.Doc_Path>
	</cfif>

	<!--read the html version of the attachment-->
	<cffile action="read" file="#vars.CT_File_Path##HTML_File_Path#" variable="vars.html" >

  <!--convert it into pdf format-->
	<cfoutput>
	<cfdocument format="PDF" name="vars.pdf">
		<!--- <cfdocumentitem type="header"><h1>request.pdf_header</h1></cfdocumentitem> --->
		<cfif len(trim(form.pdf_footer))>
			<!--- Use a footer with current page of totalpages format. --->
			<cfdocumentitem type="footer">
				<div style="text-align:center;font:arial;font-size:10px;">
					#form.pdf_footer# Page #cfdocument.currentPageNumber# of #cfdocument.TotalPageCount#
				</div>
			</cfdocumentitem>
		</cfif>
    #vars.html#
  </cfdocument>
	</cfoutput>

	<cfset PDF_File_Path = ReplaceNoCase(HTML_File_Path, '.htm', '.pdf')>

	<!--create pdf file-->
	<cfpdf action="write" destination="#vars.CT_File_Path##PDF_File_Path#" source="vars.pdf" overwrite="yes">

	<CF_Naming_Email_Attachments
					Title= "#Proper_File_Title#"
					Relative_Src_File_Path="#PDF_File_Path#"
					Relative_Dest_Dir_Path ="\Temp_Files\Billback\BB_Details"
					Return_Variable_Name="Proper_File_Path"
					File_Extension="#form.attachment_Type#">
</cfif>

<CFIF FORM.FAX_EMAIL EQ "FAX">

<cfset Fax_Numbers_List = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=Form_Fax_Numbers,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFMAIL
	TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com"
		SUBJECT="#Form.SenderSubject#"
		MIMEATTACH="#APPLICATIONPATH##HTML_File_Path#"
		TYPE="HTML">
		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		</TABLE>
</CFMAIL> --->
<CF_EMAILWRAPPER
	TO="#Fax_Numbers_List#"
	FROM="#application.CompanyFaxFromEmail#"
	SUBJECT="#Form.SenderSubject#"
	TYPE="HTML"
	messageType="2"
	generatedby="3"
	apparea="3"
	userid="#request.AccessStructure.user_id#">

		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		</TABLE>

	<cf_EmailWrapperParam file = "#Application.Doc_Path##HTML_File_Path#" store="yes">

</CF_EMAILWRAPPER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFELSE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send email..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <CFMAIL TO			=	"#Form.Recipient_Email_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"> --->
	<cfoutput>
	<CF_EMAILWRAPPER
		TO			=	"#Form.Recipient_Email_Address#"
		CC			= "#Form.CC_Recipient_Email_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"
		messagetype="1"
		generatedby="3"
		apparea="3"
		userid="#request.AccessStructure.user_id#">

		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		</TABLE>
	<!--- The cfmailparam IS the file being attached --->
	<!--- <cfmailparam file = "#Proper_File_Path#"> --->
	<cf_EmailWrapperParam file = "#Proper_File_Path#" store="yes">
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfparam name="Form.Provide_Close_Link" 	default="">
<TABLE>
<TR>
<CFIF Len(Trim(Form.Redirect_To_File_Path)) GT 0>
<TD>
<CF_button
	button_name		=	""
	button_caption	=	"return to the document"
	button_action	=	"window.location.href='#Form.Redirect_To_File_Path#?#EMAIL_SEND_AS_FORM_ELEMS#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to the document..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
</TD>
</CFIF>
<CFIF Form.Provide_Close_Link EQ "1">
<TD>
<CF_button
	button_name		=	""
	button_caption	=	"close window"
	button_action	=	"window.close();"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to close this window ..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
</TD>
</CFIF>
</TR>
</TABLE>
 <BR><BR>
 <CFOUTPUT>#Body_Content#</CFOUTPUT>

</BLOCKQUOTE>
</BODY>
</HTML>

