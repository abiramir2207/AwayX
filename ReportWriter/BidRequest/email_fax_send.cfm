<cfoutput>

<cfparam name="url.command" default="">
<cfparam name="form.command" default="#url.command#">
<cfparam name="form.from_address" default="#request.AccessStructure.User_Email#" />
<cfparam name="form.messageType" default="1" />
<cfparam name="form.redirectTo" default="" />

<CFSET HTML_File_Path = Form.HTML_File_Path>

<!---Handle for fax--->
<cfif form.command eq "fax">

	<CFSAVECONTENT VARIABLE = "Cover_sheet"> 
	
		<TABLE CELLPADDING="5" CELLSPACING="15" BORDER="0"  width="95%">
	 		<TR>
	  			<TD NOWRAP ALIGN="Right" COLSPAN="4">
	  				<b><font face="Arial" size="5">#application.returned_customer_setting.Company_Name#</font></b>  
	 	 		</TD>
	 		</TR>
	 		<TR>
	  			<TD COLSPAN="4" style="border-bottom-style: solid; border-bottom-width: 4" valign="top"></TD>
	 		</TR>
	 		<TR>
	  			<TD STYLE="FONT:72px;" COLSPAN="4" valign="top">
					<font face="Arial"><b><br>F a x<br>&nbsp;</b></font>
				</TD>
	 		</TR>
	 		<TR>
				<TD width="75" rowspan="6" valign="top">&nbsp;</TD> 
				<TD ROWSPAN="6" valign="top">&nbsp;</TD>
				<TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Date:</font></B></TD>
				<TD WIDTH="100%" STYLE="FONT:16px;" valign="top">
					<font face="Arial">
					<span style="font-size: 13pt">#FORM.SenderDate# </span></font>
				</TD>  
	 		</TR>
	 		<TR>
	  			<TD VALIGN="top" STYLE="FONT:16px;">
					<B><font size="5" face="Arial">From:</font></B>
				</TD>
	  			<TD STYLE="FONT:16px;" width="100%" valign="top">
					<font face="Arial">
					<span style="font-size: 13pt">#FORM.SenderAddress#</span></font>
				</TD>
	 		</TR>
	 		<TR>
	  			<TD VALIGN="top" STYLE="FONT:16px;">
					<B><font size="5" face="Arial">Subject:</font></B>
				</TD>
	  			<TD STYLE="FONT:16px;" width="100%" valign="top">
					<font face="Arial">
					<span style="font-size: 13pt">#FORM.SenderSubject#</span></font>
				</TD>
	 		</TR>
	  		<TR>
	  			<TD VALIGN="top" STYLE="FONT:16px;">
					<B><font size="5" face="Arial">Message:</font></B>
				</TD>
	  			<TD STYLE="FONT:16px;" width="100%" valign="top">
					<font face="Arial">
					<span style="font-size: 13pt">#FORM.Message_Body#</span></font>
				</TD>
	 		</TR>
	 		<TR>
				<TD VALIGN="top" STYLE="FONT:16px;">&nbsp;</TD>
	  			<TD STYLE="FONT:16px;" width="100%" valign="top">
					<br><br><br<br><br><br><br><br><br>&nbsp;
				</TD>  
	 		</TR>
		</TABLE> 
	 
		<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
	
	</CFSAVECONTENT>
	

	<CFSET CS_HTML_File_Path = Replace(Form.HTML_File_Path,".","_CS.") />
	
	
	<CFFILE action = "write"
			file="#Application.Doc_Path##CS_HTML_File_Path#"
			output="#Cover_sheet#">  
	
	<CF_Naming_Email_Attachments 
		Title="Proposal Report" 
		Relative_Src_File_Path="#CS_HTML_File_Path#"  
		Relative_Dest_Dir_Path ="Temp_Files\Report" 
		Return_Variable_Name="BR_CS"
	>

	<!---convert numbers--->
	<cfset Form.Recipient_Email_Address = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=form.Recipient_Email_Address,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />
	
	<!---change from address--->
	<cfset form.from_address = application.CompanyFaxFromEmail />
	<!---change message type--->
	<cfset form.messageType = 2 />
	
</cfif>

<CF_Naming_Email_Attachments 
	Title="Proposal Report" 
	Relative_Src_File_Path="#HTML_File_Path#"  
	Relative_Dest_Dir_Path ="Temp_Files\Report" 
	Return_Variable_Name="BR_FN"
>

<cf_EmailWrapper 
	TO = "#Form.Recipient_Email_Address#"
	FROM = "#form.from_address#"
	SUBJECT = "#Form.Sendersubject#"
	TYPE = "html"
	MESSAGETYPE = "#form.messageType#"
	generatedBy="3"
	appArea="1"
	userId= "#request.AccessStructure.user_id#">
			
	<TABLE WIDTH="100%">
		<TR VALIGN="top">
			<TD>
				#Form.Message_Body#
			</TD>
		</TR>
	</TABLE>
	
	<!---Handle for fax--->
	<cfif form.command eq "fax">
		<CF_EMAILWRAPPERPARAM FILE ="#BR_CS#" store="yes" />
	</cfif>
	
	<!--- The cfmailparam IS the file being attached --->
	<cf_EmailWrapperParam file="#BR_FN#" store="yes" />

</cf_EmailWrapper>

<!---redirect back to report page --->
<cflocation url="index.cfm?#form.redirectTo#" />
</cfoutput>