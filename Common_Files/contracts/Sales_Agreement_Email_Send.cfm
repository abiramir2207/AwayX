
<CFSET PAGE_TITLE="Email Contract">

<!--- Encrypt the CID the file --->
<cf_cryp	type = "en" string = "#Form.Program_CID#" key = "#request.key#">
<CFSET CID=cryp.value>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<BR><BR>
<H4 STYLE="Color: Red;">
The following Email has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<cfset useLakebaseForFaxDocuments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForFaxDocuments>
	<cftry>
		<cfif isdefined("FORM.Doc_ID")>
			<cfset Fax_Documents = application.oLakebase.toQuery(
				application.oLakebase.selectRows("document_details", { "doc_id" = "in.(#FORM.Doc_ID#)", "select" = "doc_uni_name,doc_title" })
			)>
		<cfelse>
			<cfset Fax_Documents = application.oLakebase.toQuery([], "Doc_Uni_Name,doc_title")>
		</cfif>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForFaxDocuments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFaxDocuments>
	<CFQUERY NAME="Fax_Documents" DATASOURCE = "#Application.Datasource#">
		SELECT 		Doc_Uni_Name,
					doc_title
		FROM		Document_Details
		WHERE 		1=2 <CFIF isdefined("FORM.Doc_ID")> OR Doc_ID IN (#ListQualify(FORM.Doc_ID, "'", ",")#)</CFIF>
	</CFQUERY>
</cfif>


<CFSAVECONTENT VARIABLE = "coverpage">
Enclosed: please find the following documents#chr(13)#&nbsp;&nbsp;&nbsp;&nbsp;Program Number: #FORM.Program_no#<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents">#chr(13)#&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</CFLOOP></CFIF>	
</CFSAVECONTENT>
</CFOUTPUT>

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
		<cfif isDefined("form.program_name")>
			<TR>
				<TD VALIGN="top"><B>Attachments:</B></TD>
				<TD>Program Number: #FORM.Program_no#
					<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#request.APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#")><br>#Doc_Title#</CFIF></CFLOOP></CFIF>
				</TD>
			</TR>
		</cfif>
		<TR>
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
		<cfif isDefined("form.program_name_private") OR isDefined("form.program_name_public")>
			<TR>
				<TD VALIGN="top"><B>Program</B></TD>
				<TD>
						<!--- Include the private (Internal) file --->
						<cfif Type eq "Internal">
							<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#Form.Program_Name_private#">
						<!--- Include the public (External) file --->
						<cfelseif Type eq "External">
							<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#Form.Program_Name_public#">
						</cfif>
				</TD>
			</TR>
		</cfif>
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>	
		</CFOUTPUT>
</CFSAVECONTENT> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#<BR></CFOUTPUT>	

<cfif isDefined("form.program_name_private") OR isDefined("form.program_name_public")>
						<cfif Type eq "Internal">
						<!--- Path to the private (Internal) file --->
							<CFSET Export_Program_File_Path ="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#Form.Program_Name_private#">
						<!--- Path to the public (External) file --->
						<cfelseif Type eq "External">
							<CFSET Export_Program_File_Path ="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#Form.Program_Name_public#">
						</cfif>

	<CFSET Program_ID = Form.Program_CID>

	<CFSET InstallPath = request.APPLICATIONPATH>

<!--- Email the private (Internal) file --->
	<cfif isDefined("form.program_name_private")>
	<CF_Naming_Email_Attachments 
					Title="Program_#FORM.Prog_Title#" 
					Relative_Src_File_Path="temp_files\contracts\contract_documents\#Form.Program_Name_private#"  
					Relative_Dest_Dir_Path ="Temp_Files\Program" 
					Return_Variable_Name="Export_Program_File_Path">

<!--- Email the public (External) file --->
	<cfelseif isDefined("form.program_name_public")>
	<CF_Naming_Email_Attachments 
					Title="Program_#FORM.Prog_Title#" 
					Relative_Src_File_Path="temp_files\contracts\contract_documents\#Form.Program_Name_public#"  
					Relative_Dest_Dir_Path ="Temp_Files\Program" 
					Return_Variable_Name="Export_Program_File_Path">
	</cfif>

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
					Relative_Dest_Dir_Path ="Temp_Files\Program\Documents" 
					Return_Variable_Name="Dis_File_Name"
					File_Extension="#File_Extension#">
		
		<CFIF Record_Count EQ 1>
			<CFSET Dis_File_Name_String = "#Dis_File_Name#">
		<CFELSE>
			<CFSET Dis_File_Name_String = "#Dis_File_Name_String#;#Dis_File_Name#">
		</CFIF>
	</CFIF>			
	</CFOUTPUT>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send email.................. --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfoutput>
	<CF_EMAILWRAPPER TO			=	"#Broker_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="3" 
		apparea="1" 
		userid="#request.AccessStructure.user_id#">
		
		<TABLE WIDTH="100%">		
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		<cfif isDefined("form.program_name_private") OR isDefined("form.program_name_public")>
			<TR VALIGN="top">
			<TD>
			Attachments:Please find the following documents<br>&nbsp;&nbsp;&nbsp;&nbsp;Program Number: #FORM.Program_no#			
			<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")><br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</CFIF></CFLOOP></CFIF>
			</TD>
			</TR>
		<cfelse>
			<TR>
				<TD>
					<HR>
				</TD>
			</TR>
		</cfif>
		</TABLE>
				<!--- The cf_emailwrapperparam IS the file being attached --->
		<cfif isDefined("form.program_name_private") OR isDefined("form.program_name_public")>
			<cf_emailwrapperparam file = "#Export_Program_File_Path#" store="yes" />			
			<CFIF isdefined("Dis_File_Name_String")>
				<CFLOOP INDEX = "disp_item" LIST = "#Dis_File_Name_String#" DELIMITERS = ";">
					<!--- <CFMAILPARAM FILE = "#disp_item#"> --->
					<CF_EMAILWRAPPERPARAM FILE = "#disp_item#" />
				</CFLOOP>	
			</CFIF>
		</cfif>
</CF_EMAILWRAPPER>
</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_button
	button_name		=	""
	button_caption	=	"return to contract view"
	button_action	=	"sales_agreement_edit_menu.cfm?CID=#CID#"
	button_type		=	"link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to program view..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>