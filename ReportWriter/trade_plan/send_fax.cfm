<cfoutput>
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
        <span style="font-size: 13pt">#application.returned_customer_setting.distributor_label_singular#: #FORM.Distributor#</span></font> </TD>  
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

<CFSET HTML_File_Path = Form.HTML_File_Path>
<CFSET CS_HTML_File_Path = #Replace(Form.HTML_File_Path,".","_CS.")#>


<CFFILE action = "write"
		file="#Application.Doc_Path##CS_HTML_File_Path#"
		output="#Cover_sheet#">  


<!--- <CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Fax_Numbers#" DELIMITERS=";">
	<cfset item = trim(item) />
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP> --->

<!--- <cfinvoke 
	component="components.general.General_Functions" 
 	method="Get_Fax_Email_Address" 
 	Source_Fax_Numbers="#Fax_Numbers#"
 	Name_First="#request.AccessStructure.Name_First#"
 	Name_Last="#request.AccessStructure.Name_Last#"
 	returnVariable="Fax_Numbers_List"
> --->

<!---convert numbers--->
<cfset Fax_Numbers_List = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=Fax_Numbers,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <CFMAIL TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com" 
		SUBJECT="#Form.SenderSubject#"
		TYPE="HTML"> --->
		
	<CF_EMAILWRAPPER TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="#Form.SenderSubject#"
		messageType="2"
		generatedby="3" 
		apparea="2" 
		userid="#request.AccessStructure.user_id#">
		
<!--- 		<CFMAILPARAM FILE = "#APPLICATIONPATH##CS_HTML_File_Path#">
		<CFMAILPARAM FILE = "#APPLICATIONPATH##HTML_File_Path#"> --->
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##CS_HTML_File_Path#" store="yes" />
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##HTML_File_Path#" store="yes" />

<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</cfoutput>