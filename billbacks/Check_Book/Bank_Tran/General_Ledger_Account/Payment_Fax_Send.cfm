
<!--- http://www.easylink.com --->
<CFSAVECONTENT VARIABLE = "Fax_Body">
<CFOUTPUT> 
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>Date:</B></TD>
		<TD>&nbsp;&nbsp;#Form.SenderDate#</TD>
	</TR>
	<TR>
		<TD VALIGN="top" ALIGN="Right"><B>From:</B></TD>
		<TD>&nbsp;&nbsp;#Form.Sender_Name#</TD>
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
        <span style="font-size: 13pt">#FORM.Sender_Name#</span></font></TD>
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
<CFIF Not isdefined("FORM.Att_File_List")>
	<CFSET CSFile_Name = "#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\CS_#FORM.Att_File_Name#">
<CFELSE>
	<CFSET Unique_ID = createUUID()>
	<CFSET Fax_All_File_Name = "#Replace(Unique_ID,"-","_","all")#.html">
	<CFSET CSFile_Name = "#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\CS_#Fax_All_File_Name#">
</CFIF> 


 <CFFILE action = "write"
		file="#CSFile_Name#"
		output="#Cover_sheet#">

<CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Fax_Number#" DELIMITERS=";">
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP>



<CFMAIL TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="#SenderSubject#"
		>		
		<CFMAILPARAM FILE = "#CSFIle_Name#">
		
		
		<CFIF isdefined("FORM.Att_File_List")>
			<CFLOOP	INDEX="Separated_File_Name" LIST="#Form.Att_File_Name#" DELIMITERS=",">
				<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\#Separated_File_Name#")>
					<CFMAILPARAM FILE = "#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\#Separated_File_Name#">
				</CFIF>
			</CFLOOP>			
		<CFELSE>
			<CFIF FILEEXISTS("#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\#FORM.Att_File_Name#")>		
				<CFMAILPARAM FILE = "#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\General_Ledger_Account\Fax_Files\#FORM.Att_File_Name#">
			</CFIF>
		</CFIF>	
		
		
</CFMAIL> 





<CFIF not isdefined("FORM.Att_File_List")>
<H4 STYLE="Color: Red;">
The following Fax has been sent...<BR><BR>
</H4>
<CFOUTPUT>#Fax_Body#</CFOUTPUT>
<CFINCLUDE template="#Application.Doc_Mapping#/temp_files/billback/check_book/Bank_Tran/General_Ledger_Account/Fax_Files/#FORM.Att_File_Name#">
<CFELSE>
<TABLE ALIGN="Center">
	<TR>
		<TD><BR><BR><BR><BR><H4 STYLE="Color: Red;">
			The following Fax has been sent...<BR><BR>
			</H4>
		</TD>
	</TR>
	<TR>
		<TD><CFOUTPUT>#Fax_Body#</CFOUTPUT></TD>
	</TR>
	<TR>
		<TD><BR><BR><BR><BR><H4 STYLE="Color: Red;">
			Enclosure: All Payment Requests...
			</H4>
		</TD>
	</TR>
</TABLE>
</CFIF>

<SCRIPT language="JavaScript">
function close_window()
{
	window.close();
}
window.setTimeout('close_window()', 3000);
</SCRIPT>