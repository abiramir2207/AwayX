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
The following Email has been sent...<BR><BR>
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


<CFSAVECONTENT VARIABLE = "coverpage">
Enclosed: please find the following documents#chr(13)#&nbsp;&nbsp;&nbsp;&nbsp;Payable Number: #FORM.Payable_No#<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>#chr(13)#&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</CFIF></CFLOOP></CFIF>	
</CFSAVECONTENT>
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
			<TD VALIGN="top"><B>Attachments:</B></TD>
			<TD>Payable Number: #FORM.Payable_No#
				<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")><br>#Doc_Title#</CFIF></CFLOOP></CFIF>
			</TD>
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


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Repalcing Billback file name with Billback title																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF isdefined("FORM.Deviation")>
	<CFSET Billback_FN_Title = "Deviations_#FORM.BB_Title#">
<CFELSE>
	<CFSET Billback_FN_Title = "Billback_#FORM.BB_Title#">
</CFIF>


<CF_Naming_Email_Attachments 
				Title="#Billback_FN_Title#" 
				Relative_Src_File_Path="#HTML_File_Path#"  
				Relative_Dest_Dir_Path ="Temp_Files\Billback" 
				Return_Variable_Name="Billback_FN">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Repalcing Doc_Uni_name with title																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <CFIF NOT DirectoryExists("#APPLICATIONPATH#\common_files\documents\Doc_Email\BB_#request.AccessStructure.User_ID#")>
	<CFDIRECTORY 	ACTION		=	"CREATE"
					DIRECTORY	=	"#APPLICATIONPATH#\common_files\documents\Doc_Email\BB_#request.AccessStructure.User_ID#">	
</CFIF>	 --->

<CFSET Record_Count = 0>
<CFOUTPUT QUERY="Fax_Documents">
<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>
	<CFSET Record_Count = Record_Count + 1>
	<CFSET search = ".">
	<CFSET content = Doc_Uni_Name>
	<CFSET File_Extension = Find(search,content)>
	<CFSET length = len(content)>
	<CFSET right_len = length-File_Extension>
	<CFSET File_Extension = right(content,right_len)>
	
	<CF_Naming_Email_Attachments 
				Title="#Doc_Title#" 
				Relative_Src_File_Path="data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#"  
				Relative_Dest_Dir_Path ="Temp_Files\Billback\Document" 
				Return_Variable_Name="Dis_File_Name"
				File_Extension="#File_Extension#">
	
	<CFIF Record_Count EQ 1>
		<CFSET Dis_File_Name_String = "#Dis_File_Name#">
	<CFELSE>
		<CFSET Dis_File_Name_String = "#Dis_File_Name_String#;#Dis_File_Name#">
	</CFIF>	
</CFIF>	
	
</CFOUTPUT>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


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
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"
		MESSAGETYPE = 	"1"
		generatedBy	=	"3"
		appArea		=	"3" 
		userid		=	"#request.AccessStructure.user_id#">		
		
		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>		
		</TR>
		<TR VALIGN="top">
		<TD>
		Attachments:Please find the following documents<br>&nbsp;&nbsp;&nbsp;&nbsp;Payable Number: #FORM.Payable_No#
		<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")><br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</CFIF></CFLOOP></CFIF>
		</TD> 
		</TR>
		</TABLE>
	<!--- The cfmailparam IS the file being attached --->
	<!--- <cfmailparam file = "#Billback_FN#"> --->
	<cf_emailwrapperparam file = "#Billback_FN#" store="yes">
	<CFIF isdefined("Dis_File_Name_String")>		
		<CFLOOP INDEX = "disp_item" LIST = "#Dis_File_Name_String#" DELIMITERS = ";">
			<!--- <CFMAILPARAM FILE = "#disp_item#"> --->
			<CF_EMAILWRAPPERPARAM FILE = "#disp_item#">
		</CFLOOP>	
		<!--- <CFLOOP QUERY = "Fax_Documents">
			<CFIF FILEEXISTS("#APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#")>
			<CFMAILPARAM FILE = "#APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#"><!---  --->
			</CFIF>
		</CFLOOP> --->
	</CFIF>
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
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

