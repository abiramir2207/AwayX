


<CFSET PAGE_TITLE="Fax Contract">
<CFSET GROUP="contracts">

<!--- <CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo"> --->

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
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<BR><BR>

<H4 STYLE="COLOR: Red;">
The following Fax has been sent...<BR><BR>
</H4>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFPARAM NAME="FORM.Attach_Payment_Det" DEFAULT="0">
<CFPARAM NAME="userfaxnumber" DEFAULT="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<cfset useLakebaseForFaxDocuments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForFaxDocuments>
	<cftry>
		<cfif isdefined("FORM.Doc_ID")>
			<cfset Fax_Documents = application.oLakebase.toQuery(
				application.oLakebase.selectRows("document_details", { "select" = "doc_uni_name,doc_title", "doc_id" = "in.(#FORM.Doc_ID#)" })
			)>
		<cfelse>
			<cfset Fax_Documents = application.oLakebase.toQuery([], "Doc_Uni_Name,doc_title")>
		</cfif>
		<cfcatch type="any">
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

<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUserFaxNumber()>
<CFQUERY NAME="getuserfaxnumber" DATASOURCE = "#Application.Datasource#">
	select Work_Fax_1 + ' ' + Work_Fax_2 + ' ' + Work_Fax_3 as fax_number
	from _users
	where user_id = '#request.AccessStructure.user_id#'
</CFQUERY>
<cfif getuserfaxnumber.recordcount GT 0>
<cfset userfaxnumber = getuserfaxnumber.fax_number>
</cfif>
</cfif>

</CFOUTPUT>

<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		11px;
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
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUserFaxNumber()>
			<TR>
			<TD VALIGN="top"><B>Fax Number:</B></TD>
			<TD>#userfaxnumber#</TD>
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
		<TR>
			<TD VALIGN="top"><B>Enclosure:</B></TD>
			<TD>Program Number: #FORM.Program_no#
			<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")><br>#Doc_Title#</CFIF></CFLOOP></CFIF>
			<CFIF FORM.Attach_Payment_Det NEQ 0>
			<br>Payment Addresses
			</CFIF>
			</TD>
		</TR>
		<!---
		<TR>
			<TD VALIGN="top"><B>Program</B></TD>
			<TD><CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#Form.Program_Name#"></TD>
		</TR>
		--->
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>
		</CFOUTPUT>
</CFSAVECONTENT> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#</CFOUTPUT>

	<!--- get install path --->	
	<CFSET InstallPath = request.APPLICATIONPATH>
	<!--- END get install path --->

<CFSET FILEPATH='#Application.Doc_Path#\temp_files\contracts\contract_documents\'&'#Form.Program_Name#'>


<!--- Append to the list of fax numbers the "@faxmail.com" suffix to properly build the email address --->
<CFSET Fax_List="">
<CFLOOP INDEX="item" LIST="#Form.Fax_Number#" DELIMITERS=";">
	<CFSET Fax_List=Fax_List&trim(item)&"@faxmail.com"&";">
</CFLOOP>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build the "To" field so that the recipient seees the correct "From" information				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------
<CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Fax_Number#" DELIMITERS=";">
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP>
----->
<!--- <cfinvoke 
	component="components.general.General_Functions" 
	method="Get_Fax_Email_Address" 
	Source_Fax_Numbers="#Fax_Number#"
	Name_First="#request.AccessStructure.Name_First#"
	Name_Last="#request.AccessStructure.Name_Last#"
	returnVariable="Fax_Numbers_List"> --->

<cfset Fax_Numbers_List = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=Fax_Number,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />

<!--- ------------------------------------------------------------------------------------------- --->
<!--- Cover Sheet --->
<!--- ------------------------------------------------------------------------------------------- --->

<CFSET Formula_File_Path = "#Application.Doc_Path#\temp_files\contracts\contract_documents\Formula_#Form.Program_Name#">
<CFSET Program_ID = Form.Program_CID>

<CFSET Show_Formula_Details = false>
<CFIF IsDefined("FORM.Formula_Details")>
	<CFIF FORM.Formula_Details EQ "Formula_Details">
		<CFSET Show_Formula_Details = true>
	</CFIF>
</CFIF>
<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 0>
<CFIF Show_Formula_Details>
	<CFSET Fax_Version = 1>
	<CFINCLUDE template="Formula_Price_Products_Summary_Save.cfm">
</CFIF>
	<!------ Handle for lumpsum distributor attachment ----->	
	<cfif isDefined("FORM.Lumpsum_Distributor")>
		<CFSET URL.Program_ID = Form.Program_CID>
		<CFSET LumpsumDistributor_Summary_Src_Path = "\common_files\contracts\lumpsum_distributors_display.cfm">
		
		<CFSAVECONTENT variable="LumpsumDistributor_Summary_Content">
			<CFINCLUDE template="#LumpsumDistributor_Summary_Src_Path#">
		</CFSAVECONTENT>
		
		<CF_Writing_Email_Attachment
  				Naming_Format="#Application.LumpsumLabel#_#application.returned_customer_setting.distributor_label_plural#_#FORM.Program_Name#"
				File_Extension=".html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#LumpsumDistributor_Summary_Content#"
				addNewLine="No"
				Return_File_Name="LumpsumDistributor_Summary_FileName"> 
	</cfif>
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
        <span style="font-size: 13pt">Please find the following documents<BR><BR>
		&nbsp;&nbsp;&nbsp;&nbsp;Program Number: #FORM.Program_no#
		<CFIF SHOW_FORMULA_PRICING_DETAIL_INFO><br>&nbsp;&nbsp;&nbsp;&nbsp;[#FORM.Program_no#] Formula Pricing Details</CFIF>
		<cfif isDefined("FORM.Lumpsum_Distributor")><br>&nbsp;&nbsp;&nbsp;&nbsp;[#FORM.Program_no#] #Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</CFIF>
		<CFIF Fax_Documents.recordcount GT 0>
			<CFLOOP QUERY="Fax_Documents">
				<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>	
				<br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#
				</CFIF>
			</CFLOOP>
		</CFIF>	
		<CFIF FORM.Attach_Payment_Det NEQ 0>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;[#FORM.Program_no#] Payment Addresses
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
 
<CFSET CSFile_Name = "#Application.Doc_Path#\temp_files\contracts\contract_documents\cs_#Form.Program_Name#">

 <CFFILE action = "write"
		file="#CSFile_Name#"
		output="#Cover_sheet#">
		    
</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Preparing payable to and Send payment to Address Attachment--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF FORM.Attach_Payment_Det NEQ 0>
	<CFSET ProgramID = FORM.Program_CID>
	<CFSET DetailsAbout = FORM.Attach_Payment_Det>
	<CFSAVECONTENT VARIABLE="PaymentDetails">
	<CFINCLUDE TEMPLATE="PaymentAddressInfo.cfm">
	</CFSAVECONTENT>

	<CF_Writing_Email_Attachment
		Naming_Format="PaymentAddressesOfProgram_#FORM.Program_no#"				
		Relative_Path="\Temp_Files\PaymentAddress\"
		Output_Content="#PaymentDetails#"				
		Return_File_Name="PaymentfName">
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send Fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 <!--- <CFSET Fax_Numbers_List = "19789881277" &"~FR=Ana_Shnakar@Faxmail.com;"> ---> 
 <CF_EMAILWRAPPER TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="#SenderSubject#"
		messageType="2"
		generatedby="3" 
		apparea="1" 
		userid="#request.AccessStructure.user_id#">		
		
		<CF_EMAILWRAPPERPARAM FILE = "#CSFIle_Name#" store="yes" />
		<CF_EMAILWRAPPERPARAM FILE = "#FILEPATH#" store="yes" />
		<!--- Formula Details ------>
		<CFIF SHOW_FORMULA_PRICING_DETAIL_INFO>
			<CF_EMAILWRAPPERPARAM FILE = "#Formula_File_Path#" store="yes" />
		</CFIF>
		<CFIF Fax_Documents.recordcount GT 0>		
		<CFLOOP QUERY = "Fax_Documents">
		<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>		
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#">
		</CFIF>
		</CFLOOP>
		</CFIF> 
		
		<CFIF FORM.Attach_Payment_Det NEQ 0>
		<cf_emailwrapperparam file = "#PaymentfName#" store="yes" />
		</CFIF>
		<cfif isDefined("FORM.Lumpsum_Distributor")>
			<cf_emailwrapperparam file = "#LumpsumDistributor_Summary_FileName#" store="yes" />
		</cfif>
</CF_EMAILWRAPPER> 
<!--- <CFMAIL TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com" 
		SUBJECT="#SenderSubject#">		
		
		<CFMAILPARAM FILE = "#CSFIle_Name#">
		<CFMAILPARAM FILE = "#FILEPATH#">
		<!--- Formula Details ------>
		<CFIF SHOW_FORMULA_PRICING_DETAIL_INFO>
			<CFMAILPARAM FILE = "#Formula_File_Path#">
		</CFIF>
		<CFIF Fax_Documents.recordcount GT 0>		
		<CFLOOP QUERY = "Fax_Documents">
		<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>		
		<CFMAILPARAM FILE = "#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#">
		</CFIF>
		</CFLOOP>
		</CFIF> 
</CFMAIL>  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



 

 
<!--- Encrypt the CID the file --->
<cf_cryp	type = "en" string = "#Form.Program_CID#" key = "#request.key#">
<CFSET CID=cryp.value>


<CF_button
	button_name		=	""
	button_caption	=	"return to contract view"
	button_action	=	"contract_edit_menu.cfm?CID=#CID#"
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

