
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Repalcing Trade Planner file name with title																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CF_Naming_Email_Attachments 
				Title="TP_#TP_Title#" 
				Relative_Src_File_Path="#HTML_File_Path#"  
				Relative_Dest_Dir_Path ="Temp_Files\TradePlanner" 
				Return_Variable_Name="TP_FN">
				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfoutput>

<CFSET HTML_File_Path = Form.HTML_File_Path>

<!--- <CFMAIL TO			=	"#Form.Recipient_Email_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"> --->
	<cf_EmailWrapper 
		TO = "#Form.Recipient_Email_Address#"
		FROM = "#request.AccessStructure.User_Email#"
        SUBJECT = "#Form.Sendersubject#"
		TYPE = "html"
		MESSAGETYPE = "1"
		generatedBy="3"
		appArea="2"
		userId= "#request.AccessStructure.user_id#">
				
		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		</TABLE>
	<!--- The cfmailparam IS the file being attached --->
<!--- 	<cfmailparam file = "#TP_FN#"> --->
	<cf_EmailWrapperParam file="#TP_FN#" store="yes" />

<!--- </CFMAIL> --->
</cf_EmailWrapper>
</cfoutput>